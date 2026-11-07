param(
    [string]$DocxPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'core_content_files\AI Principal Architect.docx'),
    [string]$OutputRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) 'docs')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:TracePath = Join-Path $env:TEMP 'convert-progress.log'
function Trace {
    param([string]$Message)
    [System.IO.File]::AppendAllText($script:TracePath, "$(Get-Date -Format o) $Message`n")
}
[System.IO.File]::WriteAllText($script:TracePath, '')

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Xml

$script:Wns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
$script:OfficeRelNs = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
$script:PackageRelNs = 'http://schemas.openxmlformats.org/package/2006/relationships'

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $Content = $Content -replace "`r`n", "`n"
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Test-OnOff {
    param($Node)
    if (-not $Node) { return $false }
    $val = $Node.GetAttribute('val', $script:Wns)
    if ([string]::IsNullOrWhiteSpace($val)) { return $true }
    return -not ($val -in @('0', 'false', 'off'))
}

function Get-PlainText {
    param($Node)
    $parts = @()
    foreach ($t in $Node.SelectNodes('.//w:t', $script:Ns)) {
        $parts += $t.InnerText
    }
    return ($parts -join '')
}

function Escape-MdText {
    param([string]$Text)
    if ($null -eq $Text) { return '' }
    $s = $Text
    $s = $s -replace '\\', '\\\\'
    $s = $s -replace '([*_\[\]`])', '\$1'
    $s = $s -replace '<', '&lt;'
    $s = $s -replace '>', '&gt;'
    return $s
}

function Escape-ParagraphStart {
    param([string]$Text)
    $s = $Text
    $s = $s -replace '^(\s*)(\d+)\.(\s)', '$1$2\.$3'
    $s = $s -replace '^(\s*)([-+*>#])(\s)', '$1\$2$3'
    return $s
}

function Convert-Run {
    param($Run)
    $text = ''
    foreach ($child in $Run.ChildNodes) {
        switch ($child.LocalName) {
            't' { $text += $child.InnerText }
            'br' { $text += "`n" }
            'tab' { $text += ' ' }
            'noBreakHyphen' { $text += '-' }
            'softHyphen' { }
        }
    }
    if ($text.Length -eq 0) { return '' }

    $rPr = $Run.SelectSingleNode('./w:rPr', $script:Ns)
    $bold = $false
    $italic = $false
    if ($rPr) {
        $bold = Test-OnOff ($rPr.SelectSingleNode('./w:b', $script:Ns))
        $italic = Test-OnOff ($rPr.SelectSingleNode('./w:i', $script:Ns))
    }

    $leading = [regex]::Match($text, '^\s*').Value
    $trailing = [regex]::Match($text, '\s*$').Value
    $coreStart = $leading.Length
    $coreLen = $text.Length - $leading.Length - $trailing.Length
    if ($coreLen -le 0) { return $text }
    $core = $text.Substring($coreStart, $coreLen)
    $escaped = Escape-MdText $core

    if ($bold -and $italic) { $escaped = "***$escaped***" }
    elseif ($bold) { $escaped = "**$escaped**" }
    elseif ($italic) { $escaped = "*$escaped*" }

    return $leading + $escaped + $trailing
}

function Convert-Inline {
    param($Node)
    $sb = New-Object System.Text.StringBuilder
    foreach ($child in $Node.ChildNodes) {
        switch ($child.LocalName) {
            'r' {
                [void]$sb.Append((Convert-Run $child))
            }
            'hyperlink' {
                $text = Convert-Inline $child
                $rid = $child.GetAttribute('id', $script:OfficeRelNs)
                if ($rid -and $script:RelMap.ContainsKey($rid) -and $text) {
                    $url = $script:RelMap[$rid].Target
                    [void]$sb.Append("[${text}]($url)")
                } else {
                    [void]$sb.Append($text)
                }
            }
            'ins' {
                [void]$sb.Append((Convert-Inline $child))
            }
            'del' { }
            'bookmarkStart' { }
            'bookmarkEnd' { }
            'proofErr' { }
            'sdt' {
                [void]$sb.Append((Convert-Inline $child))
            }
        }
    }
    return $sb.ToString()
}

function Get-HeadingLevel {
    param([string]$Text, [bool]$AllBold)
    $t = $Text.Trim()
    if ($t.Length -eq 0) { return 0 }
    if ($t -eq '2. Five architectural dimensions to govern') { return 2 }
    if ($t -match '^\d+\.\d+\.\d+\s') { return 4 }
    if ($t -match '^\d+\.\d+\s') { return 3 }
    if ($t -match '^\d+\.\s') {
        if ($AllBold) { return 2 }
        return 4
    }
    if ($t -match '^[A-Z]\.\s') { return 3 }

    $labels = @(
        '^What this means$',
        '^Key architectural responsibilities$',
        '^Key architectural decisions',
        '^Recommended implementation approach$',
        '^Important architectural components$',
        '^The importance of engineering context$',
        '^Example\b',
        '^Step \d',
        '^Phase \d',
        '^Scenario:',
        '^Three-year ',
        '^Architecture decision brief$',
        '^The Principal Architect decision framework$',
        '^Your response',
        '^Mock CIO',
        '^Five industry examples$',
        '^Your architectural responsibilities$',
        '^Examples?:$',
        '^Recommended resources?:?$',
        '^How the six',
        '^How to architect',
        '^Introduce an AI-assisted',
        '^Governance model',
        '^Metrics to measure',
        '^Preparation guide',
        '^Interview questions',
        '^Suggested ',
        '^A suggested ',
        '^Your interview-ready',
        '^How to position',
        '^Final interview',
        '^Practical ',
        '^Understand AI-powered',
        '^Expand the key',
        '^Application architecture decisions',
        '^Data architecture decisions',
        '^Integration architecture decisions',
        '^Platform architecture decisions',
        '^Operational architecture decisions',
        '^How to prevent',
        '^Worked enterprise',
        '^Key architectural trade-offs',
        '^How this connects',
        '^Your Principal Architect',
        '^A reusable',
        '^Business problem$',
        '^Recommended architectural option$',
        '^Expected business',
        '^Key risks',
        '^Decision requested$',
        '^Current-state',
        '^Target-state',
        '^The three-year',
        '^Architecture review simulation$',
        '^Situation$'
    )
    foreach ($pattern in $labels) {
        if ($t -match $pattern) { return 4 }
    }

    if ($AllBold -and $t.Length -le 140) { return 4 }
    return 0
}

function Get-ImageMarkdown {
    param($Paragraph)
    $result = @()
    foreach ($blip in $Paragraph.SelectNodes('.//a:blip', $script:Ns)) {
        $rid = $blip.GetAttribute('embed', $script:OfficeRelNs)
        if (-not $rid -or -not $script:RelMap.ContainsKey($rid)) { continue }
        $target = $script:RelMap[$rid].Target
        $key = 'word/' + $target
        if ($script:ImageMap.ContainsKey($key)) {
            $file = $script:ImageMap[$key].File
            $alt = $script:ImageMap[$key].Alt
        } else {
            $file = [System.IO.Path]::GetFileName($target)
            $alt = 'Architecture diagram'
        }
        $result += "![$alt](@@ASSET:$file@@)"
    }
    return $result
}

function Convert-ParagraphBlock {
    param($Paragraph, [int]$ParaIndex)
    $plain = Get-PlainText $Paragraph
    $plainTrim = $plain.Trim()

    $images = @(Get-ImageMarkdown $Paragraph)

    $allBold = $false
    if ($plainTrim.Length -gt 0) {
        $boldText = New-Object System.Text.StringBuilder
        foreach ($run in $Paragraph.SelectNodes('.//w:r', $script:Ns)) {
            $rPr = $run.SelectSingleNode('./w:rPr', $script:Ns)
            if ($rPr -and (Test-OnOff ($rPr.SelectSingleNode('./w:b', $script:Ns)))) {
                foreach ($t in $run.SelectNodes('.//w:t', $script:Ns)) {
                    [void]$boldText.Append($t.InnerText)
                }
            }
        }
        $allBold = ($boldText.ToString().Trim() -eq $plainTrim)
    }

    $numIdNode = $Paragraph.SelectSingleNode('./w:pPr/w:numPr/w:numId', $script:Ns)
    if ($numIdNode) {
        $numId = $numIdNode.GetAttribute('val', $script:Wns)
        $ilvlNode = $Paragraph.SelectSingleNode('./w:pPr/w:numPr/w:ilvl', $script:Ns)
        $ilvl = 0
        if ($ilvlNode) { $ilvl = [int]$ilvlNode.GetAttribute('val', $script:Wns) }
        $fmt = 'bullet'
        if ($script:NumToAbstract.ContainsKey($numId)) {
            $aid = $script:NumToAbstract[$numId]
            if ($script:AbstractMap.ContainsKey($aid) -and $script:AbstractMap[$aid].ContainsKey([string]$ilvl)) {
                $fmt = $script:AbstractMap[$aid][[string]$ilvl]
            }
        }
        $marker = if ($fmt -eq 'decimal') { '1.' } else { '-' }
        $indent = '  ' * $ilvl
        $text = (Convert-Inline $Paragraph).Trim()
        if ($text.Length -eq 0) { return $null }
        return [pscustomobject]@{
            Kind = 'list'
            ParaIndex = $ParaIndex
            Markdown = "$indent$marker $text"
            Text = $plainTrim
        }
    }

    $headingLevel = Get-HeadingLevel $plainTrim $allBold
    if ($headingLevel -gt 0) {
        $headingText = Escape-MdText $plainTrim
        return [pscustomobject]@{
            Kind = 'paragraph'
            ParaIndex = $ParaIndex
            Markdown = ('#' * $headingLevel) + ' ' + $headingText
            Text = $plainTrim
            IsHeading = $true
        }
    }

    $inline = (Convert-Inline $Paragraph).Trim()
    $parts = @()
    if ($inline.Length -gt 0) { $parts += Escape-ParagraphStart $inline }
    if ($images.Count -gt 0) { $parts += ($images -join "`n`n") }
    if ($parts.Count -eq 0) { return $null }

    return [pscustomobject]@{
        Kind = 'paragraph'
        ParaIndex = $ParaIndex
        Markdown = ($parts -join "`n`n")
        Text = $plainTrim
    }
}

function Convert-TableCell {
    param($Cell)
    $parts = @()
    foreach ($p in $Cell.SelectNodes('./w:p', $script:Ns)) {
        $text = (Convert-Inline $p).Trim()
        if ($text.Length -gt 0) { $parts += $text }
    }
    $text = $parts -join '<br>'
    $text = $text -replace "`r?`n", '<br>'
    $text = $text -replace '\|', '\|'
    return $text
}

function Convert-TableBlock {
    param($Table, [int]$ParaIndex)
    $rows = $Table.SelectNodes('./w:tr', $script:Ns)
    if ($rows.Count -eq 0) { return $null }

    $matrix = @()
    foreach ($tr in $rows) {
        $cells = @()
        foreach ($tc in $tr.SelectNodes('./w:tc', $script:Ns)) {
            $cells += (Convert-TableCell $tc)
        }
        $matrix += ,$cells
    }
    if ($matrix.Count -eq 0) { return $null }

    $maxCols = ($matrix | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
    if ($maxCols -lt 1) { return $null }

    $lines = @()
    for ($r = 0; $r -lt $matrix.Count; $r++) {
        $row = $matrix[$r]
        while ($row.Count -lt $maxCols) { $row += '' }
        $lines += '| ' + ($row -join ' | ') + ' |'
        if ($r -eq 0) {
            $separator = @()
            for ($c = 0; $c -lt $maxCols; $c++) { $separator += '---' }
            $lines += '| ' + ($separator -join ' | ') + ' |'
        }
    }

    return [pscustomobject]@{
        Kind = 'table'
        ParaIndex = $ParaIndex
        Markdown = ($lines -join "`n")
        Text = 'table'
    }
}

function Get-FlatRangeValues {
    param($Value)
    if ($null -eq $Value) { return }
    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [string])) {
        foreach ($child in $Value) {
            Get-FlatRangeValues $child
        }
    } else {
        Write-Output ([int]$Value)
    }
}

function Test-InRanges {
    param([int]$Index, $Ranges)
    $values = @(Get-FlatRangeValues $Ranges)
    for ($i = 0; $i + 1 -lt $values.Count; $i += 2) {
        if ($Index -ge $values[$i] -and $Index -le $values[$i + 1]) { return $true }
    }
    return $false
}

function Get-BlocksForRanges {
    param($Blocks, $Ranges)
    return @($Blocks | Where-Object { Test-InRanges -Index $_.ParaIndex -Ranges $Ranges })
}

function Format-Blocks {
    param($Blocks)
    if ($null -eq $Blocks) { return "" }
    $Blocks = @($Blocks | Where-Object { $null -ne $_ })
    if ($Blocks.Count -eq 0) { return "" }
    $sb = New-Object System.Text.StringBuilder
    $prevList = $false
    foreach ($block in $Blocks) {
        if ($block.Kind -eq 'list') {
            if (-not $prevList) { [void]$sb.Append("`n") }
            [void]$sb.Append($block.Markdown + "`n")
            $prevList = $true
        } else {
            if ($prevList) { [void]$sb.Append("`n") }
            [void]$sb.Append($block.Markdown + "`n`n")
            $prevList = $false
        }
    }
    $text = $sb.ToString()
    $text = $text -replace "(`n){3,}", "`n`n"
    return $text.Trim() + "`n"
}

function Resolve-Assets {
    param([string]$Markdown, [string]$Prefix)
    $evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
        param($m)
        return $Prefix + $m.Groups[1].Value
    }
    return [regex]::Replace($Markdown, '@@ASSET:([^@]+)@@', $evaluator)
}

function Remove-FirstBlock {
    param($Blocks)
    if ($null -eq $Blocks) { return @() }
    $Blocks = @($Blocks | Where-Object { $null -ne $_ })
    if ($Blocks.Count -eq 0) { return @() }
    if ($Blocks.Count -eq 1) { return @() }
    return @($Blocks[1..($Blocks.Count - 1)])
}

# ---------------------------------------------------------------------------
# Read package
# ---------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $DocxPath)) {
    throw "Source document not found: $DocxPath"
}

$zip = [System.IO.Compression.ZipFile]::OpenRead($DocxPath)
function Read-ZipText {
    param([string]$Name)
    $entry = $zip.GetEntry($Name)
    if (-not $entry) { throw "Missing zip entry: $Name" }
    $reader = New-Object System.IO.StreamReader($entry.Open())
    $text = $reader.ReadToEnd()
    $reader.Close()
    return $text
}

Trace 'reading package'
$docText = Read-ZipText 'word/document.xml'
$relsText = Read-ZipText 'word/_rels/document.xml.rels'
$numText = Read-ZipText 'word/numbering.xml'
Trace 'package read'

$docXml = New-Object System.Xml.XmlDocument
$docXml.LoadXml($docText)
$script:Ns = New-Object System.Xml.XmlNamespaceManager($docXml.NameTable)
$script:Ns.AddNamespace('w', $script:Wns)
$script:Ns.AddNamespace('r', $script:OfficeRelNs)
$script:Ns.AddNamespace('a', 'http://schemas.openxmlformats.org/drawingml/2006/main')
$script:Ns.AddNamespace('wp', 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing')

$relsXml = New-Object System.Xml.XmlDocument
$relsXml.LoadXml($relsText)
$relsNs = New-Object System.Xml.XmlNamespaceManager($relsXml.NameTable)
$relsNs.AddNamespace('r', $script:PackageRelNs)
$script:RelMap = @{}
foreach ($rel in $relsXml.SelectNodes('//r:Relationship', $relsNs)) {
    $script:RelMap[$rel.Id] = [pscustomobject]@{
        Target = $rel.GetAttribute('Target')
        Mode = $rel.GetAttribute('TargetMode')
        Type = $rel.GetAttribute('Type')
    }
}

$numXml = New-Object System.Xml.XmlDocument
$numXml.LoadXml($numText)
$numNs = New-Object System.Xml.XmlNamespaceManager($numXml.NameTable)
$numNs.AddNamespace('w', $script:Wns)
$script:AbstractMap = @{}
foreach ($an in $numXml.SelectNodes('//w:abstractNum', $numNs)) {
    $aid = $an.GetAttribute('abstractNumId', $script:Wns)
    $lvls = @{}
    foreach ($lvl in $an.SelectNodes('./w:lvl', $numNs)) {
        $ilvl = $lvl.GetAttribute('ilvl', $script:Wns)
        $fmtNode = $lvl.SelectSingleNode('./w:numFmt', $numNs)
        $fmt = 'bullet'
        if ($fmtNode) { $fmt = $fmtNode.GetAttribute('val', $script:Wns) }
        $lvls[$ilvl] = $fmt
    }
    $script:AbstractMap[$aid] = $lvls
}
$script:NumToAbstract = @{}
foreach ($num in $numXml.SelectNodes('//w:num', $numNs)) {
    $numId = $num.GetAttribute('numId', $script:Wns)
    $aidNode = $num.SelectSingleNode('./w:abstractNumId', $numNs)
    if ($numId -and $aidNode) {
        $script:NumToAbstract[$numId] = $aidNode.GetAttribute('val', $script:Wns)
    }
}

$script:ImageMap = @{
    'word/media/image1.png'  = [pscustomobject]@{ File = 'e03-d-embed-guardrails-sdlc.png'; Alt = 'Embedding architecture guardrails into the software development lifecycle' }
    'word/media/image2.png'  = [pscustomobject]@{ File = 'appendix-e03-duplicate-embed-guardrails-sdlc.png'; Alt = 'Duplicate diagram: embedding architecture guardrails into the software development lifecycle' }
    'word/media/image3.png'  = [pscustomobject]@{ File = 'e04-b-agentic-loan-approval-workflow.png'; Alt = 'Banking loan approval agentic workflow' }
    'word/media/image4.png'  = [pscustomobject]@{ File = 'e04-d-ai-evaluation-framework.png'; Alt = 'AI evaluation framework' }
    'word/media/image5.png'  = [pscustomobject]@{ File = 'e04-e-ai-observability-dashboard.png'; Alt = 'AI observability dashboard' }
    'word/media/image6.png'  = [pscustomobject]@{ File = 'e04-six-capabilities-fit-together.png'; Alt = 'How the six AI capabilities fit together' }
    'word/media/image7.png'  = [pscustomobject]@{ File = 'e05-b-privacy-aware-ai-processing.png'; Alt = 'Privacy-aware AI processing' }
    'word/media/image8.png'  = [pscustomobject]@{ File = 'e05-e-ai-observability-architecture.png'; Alt = 'AI observability architecture' }
    'word/media/image9.png'  = [pscustomobject]@{ File = 'e05-six-enterprise-requirements-fit-together.png'; Alt = 'How the six enterprise requirements fit together' }
    'word/media/image10.png' = [pscustomobject]@{ File = 'e06-ai-powered-pdlc-overview.png'; Alt = 'AI-powered product development lifecycle overview' }
    'word/media/image11.png' = [pscustomobject]@{ File = 'e06-d-ai-generated-testing.png'; Alt = 'AI-generated testing for a loan application' }
    'word/media/image12.png' = [pscustomobject]@{ File = 'e06-ai-powered-pdlc-architecture.png'; Alt = 'Enterprise AI-powered PDLC architecture' }
    'word/media/image13.png' = [pscustomobject]@{ File = 'e06-phase-6-scale-adoption.png'; Alt = 'Scaling AI adoption across engineering teams' }
    'word/media/image14.png' = [pscustomobject]@{ File = 'e07-five-architectural-dimensions.png'; Alt = 'Five architectural dimensions to govern' }
    'word/media/image15.png' = [pscustomobject]@{ File = 'e07-architecture-dimensions-overview.png'; Alt = 'Architecture dimensions overview' }
    'word/media/image16.png' = [pscustomobject]@{ File = 'e07-data-architecture-rag.png'; Alt = 'Enterprise RAG and data architecture' }
    'word/media/image17.png' = [pscustomobject]@{ File = 'e07-integration-loan-processing.png'; Alt = 'AI-enabled loan processing integration' }
    'word/media/image18.png' = [pscustomobject]@{ File = 'e07-banking-target-state-architecture.png'; Alt = 'Target-state banking AI architecture' }
    'word/media/image19.png' = [pscustomobject]@{ File = 'e08-scenario-1-recommended-architecture.png'; Alt = 'Recommended architecture for enterprise AI agent' }
    'word/media/image20.png' = [pscustomobject]@{ File = 'e08-scenario-2-platform-options.png'; Alt = 'Recommended approach for two business units and different AI platforms' }
    'word/media/image21.png' = [pscustomobject]@{ File = 'e08-scenario-4-tco.png'; Alt = 'Total cost of ownership assessment' }
    'word/media/image22.png' = [pscustomobject]@{ File = 'e08-scenario-5-architecture-alternatives.png'; Alt = 'Comparison of multi-agent architecture alternatives' }
}

# ---------------------------------------------------------------------------
# Build ordered blocks
# ---------------------------------------------------------------------------

$body = $docXml.SelectSingleNode('//w:body', $script:Ns)
$blocks = New-Object System.Collections.ArrayList
$paraIndex = -1
foreach ($child in $body.ChildNodes) {
    switch ($child.LocalName) {
        'p' {
            $paraIndex++
            $block = Convert-ParagraphBlock -Paragraph $child -ParaIndex $paraIndex
            if ($null -ne $block) { [void]$blocks.Add($block) }
        }
        'tbl' {
            $block = Convert-TableBlock -Table $child -ParaIndex $paraIndex
            if ($null -ne $block) { [void]$blocks.Add($block) }
        }
        'sdt' { }
    }
}
Trace "blocks built: $($blocks.Count)"

# ---------------------------------------------------------------------------
# Page model
# ---------------------------------------------------------------------------

$expectations = @(
    [pscustomobject]@{
        Number = 1
        Slug = '01-strategic-ai-initiatives'
        Title = 'Lead architecture for strategic AI initiatives across products, platforms, and shared enterprise capabilities'
        IntroRanges = @(, @(3, 5))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'responsibilities.md'; Title = '2. Expand each significant point with examples'; Ranges = @(, @(6, 144)); SkipFirst = $true; Description = 'Strategy translation, target-state architecture, shared platforms, governance, cross-functional leadership, and business value.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '3. Preparation guide: Topics to study and reference links'; Ranges = @(, @(145, 196)); SkipFirst = $true; Description = 'Topics, reference links, and interview questions to study.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '4. Suggested interview preparation exercise'; Ranges = @(, @(197, 209)); SkipFirst = $true; Description = 'A bank enterprise AI platform case study exercise.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = 'Final interview positioning'; Ranges = @(, @(210, 210)); SkipFirst = $false; Description = 'How to position yourself as an enterprise AI architect.' }
        )
    },
    [pscustomobject]@{
        Number = 2
        Slug = '02-business-product-engineering-partnership'
        Title = 'Partner with business units, product leaders, and engineering teams to shape scalable, secure, and practical AI solution architectures'
        IntroRanges = @(, @(211, 211))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'narrative.md'; Title = '1. Two-paragraph interview narrative'; Ranges = @(, @(212, 214)); SkipFirst = $true; Description = 'A concise narrative for opening the interview discussion.' },
            [pscustomobject]@{ File = 'responsibilities.md'; Title = '2. Expand each significant point with industry examples'; Ranges = @(, @(215, 538)); SkipFirst = $true; Description = 'Five industry examples for business, product, engineering, scalable, secure, and practical architecture.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '3. Preparation guide with learning resources'; Ranges = @(, @(539, 564)); SkipFirst = $true; Description = 'Study topics and learning resources for collaboration and architecture.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '4. Practical interview preparation exercise'; Ranges = @(, @(565, 569)); SkipFirst = $true; Description = 'A practical exercise to rehearse the expectation.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = '5. Final interview positioning'; Ranges = @(, @(570, 572)); SkipFirst = $true; Description = 'Closing positioning for the partnership expectation.' }
        )
    },
    [pscustomobject]@{
        Number = 3
        Slug = '03-architecture-standards-guardrails'
        Title = 'Define and evolve architecture standards, reference patterns, and guardrails for AI solutions and AI-enabled software development'
        IntroRanges = @(, @(573, 573))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'narrative.md'; Title = '1. Two-paragraph interview narrative'; Ranges = @(, @(574, 576)); SkipFirst = $true; Description = 'A concise narrative for opening the interview discussion.' },
            [pscustomobject]@{ File = 'responsibilities.md'; Title = '2. Expand each significant point with industry examples'; Ranges = @(, @(577, 938)); SkipFirst = $true; Description = 'Standards, reusable patterns, guardrails, SDLC embedding, evolution, and developer enablement.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '3. Preparation guide with links'; Ranges = @(, @(939, 967)); SkipFirst = $true; Description = 'Reference architectures, security guardrails, and engineering governance resources.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '4. Practical interview case study'; Ranges = @(, @(968, 982)); SkipFirst = $true; Description = 'Banking case study and architecture effectiveness metrics.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = '6. Strong interview closing statement'; Ranges = @(, @(983, 985)); SkipFirst = $true; Description = 'A closing statement for the standards and guardrails expectation.' }
        )
    },
    [pscustomobject]@{
        Number = 4
        Slug = '04-ai-capabilities-agentic-orchestration-governance'
        Title = 'Provide architectural leadership for capabilities, agentic workflows, AI orchestration, evaluations, AI observability, and AI governance'
        IntroRanges = @(, @(1576, 1579))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'responsibilities.md'; Title = '1. Expand the key responsibilities'; Ranges = @(, @(1580, 1727)); SkipFirst = $true; Description = 'Reusable capabilities, agentic workflows, orchestration, evaluation, observability, and governance.' },
            [pscustomobject]@{ File = 'architecture.md'; Title = '2. How the six capabilities fit together'; Ranges = @(, @(1728, 1741)); SkipFirst = $true; Description = 'How the six capabilities connect and the architectural decisions to defend.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '4. Practical interview case study: Enterprise AI platform for a bank'; Ranges = @(, @(1742, 1783)); SkipFirst = $true; Description = 'A step-by-step enterprise AI platform case study.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '5. Preparation guide and recommended resources'; Ranges = @(, @(1784, 1804)); SkipFirst = $true; Description = 'Resources, interview questions, metrics, and a 10-day preparation plan.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = '9. Your interview-ready closing statement'; Ranges = @(, @(1805, 1820)); SkipFirst = $true; Description = 'Closing statement and how to position existing architecture experience.' }
        )
    },
    [pscustomobject]@{
        Number = 5
        Slug = '05-enterprise-requirements-security-privacy-compliance'
        Title = 'Ensure AI solutions align with enterprise requirements for security, privacy, compliance, resiliency, observability, and maintainability'
        IntroRanges = @(, @(1821, 1824))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'responsibilities.md'; Title = '1. Expand the key responsibilities'; Ranges = @(, @(1825, 2095)); SkipFirst = $true; Description = 'Security, privacy, compliance, resiliency, observability, and maintainability responsibilities.' },
            [pscustomobject]@{ File = 'architecture.md'; Title = '2. How the six enterprise requirements fit together'; Ranges = @(, @(2096, 2100)); SkipFirst = $true; Description = 'How the six enterprise requirements connect.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '3. Practical interview case study: Enterprise AI architecture for a bank'; Ranges = @(, @(2101, 2165)); SkipFirst = $true; Description = 'A seven-step banking case study and architecture decision matrix.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '5. Metrics you should discuss in the interview'; Ranges = @(, @(2166, 2195)); SkipFirst = $true; Description = 'Metrics, resources, interview questions, and a 7-day preparation plan.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = '9. Your interview-ready closing statement'; Ranges = @(, @(2196, 2207)); SkipFirst = $true; Description = 'Closing statement and how to position existing architecture experience.' }
        )
    },
    [pscustomobject]@{
        Number = 6
        Slug = '06-ai-powered-pdlc'
        Title = 'Help engineering teams leverage AI-powered PDLC capabilities across coding, testing, documentation, analysis, and delivery workflows'
        IntroRanges = @(, @(2208, 2216))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'responsibilities.md'; Title = '2. Expand the key responsibilities'; Ranges = @(, @(2217, 2583)); SkipFirst = $true; Description = 'Requirements, design, coding, testing, documentation, analysis, and delivery workflows.' },
            [pscustomobject]@{ File = 'architecture.md'; Title = '3. How to architect an enterprise AI-powered PDLC'; Ranges = @(, @(2584, 2634)); SkipFirst = $true; Description = 'Architecture components, engineering context, AI-assisted workflow, and governance model.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '6. Practical enterprise case study: AI-powered PDLC transformation'; Ranges = @(, @(2635, 2690)); SkipFirst = $true; Description = 'A six-phase enterprise PDLC transformation case study.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '7. Metrics to measure AI-powered PDLC success'; Ranges = @(, @(2691, 2713)); SkipFirst = $true; Description = 'Metrics, resources, interview questions, and a 10-day preparation plan.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = '11. Your interview-ready closing statement'; Ranges = @(, @(2714, 2726)); SkipFirst = $true; Description = 'Closing statement and how to position Appian and application architecture experience.' }
        )
    },
    [pscustomobject]@{
        Number = 7
        Slug = '07-architecture-decisions'
        Title = 'Guide architecture decisions across application, data, integration, platform, and operational concerns to avoid fragmented or duplicative solutions'
        IntroRanges = @(, @(2727, 2743))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'architecture-decisions.md'; Title = '3. Application architecture decisions'; Ranges = @(, @(2744, 2963)); SkipFirst = $true; Description = 'Application, data, integration, platform, and operational decisions, plus preventing duplication.' },
            [pscustomobject]@{ File = 'exercises.md'; Title = '9. Worked enterprise case study: Banking AI transformation'; Ranges = @(, @(2964, 3013)); SkipFirst = $true; Description = 'A banking transformation case study and key architectural trade-offs.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '12. Interview questions to prepare'; Ranges = @(, @(3019, 3032)); SkipFirst = $true; Description = 'Interview questions, resources, and a seven-day preparation plan.' },
            [pscustomobject]@{ File = 'positioning.md'; Title = 'Interview positioning and final answer'; Ranges = @(, @(3014, 3018), @(3033, 3038)); SkipFirst = $false; Description = 'How to connect Appian experience and deliver the final interview-ready answer.' }
        )
    },
    [pscustomobject]@{
        Number = 8
        Slug = '08-architecture-reviews-investment'
        Title = 'Participate in architecture reviews, technical strategy discussions, and investment decisions related to AI and platform modernization'
        IntroRanges = @(, @(3039, 3044))
        IntroSkipFirst = $true
        Pages = @(
            [pscustomobject]@{ File = 'exercises.md'; Title = 'Architecture review scenarios and mock interview'; Ranges = @(, @(3045, 3252), @(3284, 3302)); SkipFirst = $false; Description = 'Five architecture review scenarios and a mock CIO/CTO interview.' },
            [pscustomobject]@{ File = 'preparation.md'; Title = '6. Your Principal Architect decision-making framework'; Ranges = @(, @(3253, 3283)); SkipFirst = $true; Description = 'The decision-making framework and reusable architecture decision template.' }
        )
    }
)

# ---------------------------------------------------------------------------
# Extract images
# ---------------------------------------------------------------------------

$assetsDir = Join-Path $OutputRoot 'assets'
New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null
foreach ($entry in $zip.Entries) {
    if ($entry.FullName -notlike 'word/media/*') { continue }
    $targetName = [System.IO.Path]::GetFileName($entry.FullName)
    if ($script:ImageMap.ContainsKey($entry.FullName)) {
        $targetName = $script:ImageMap[$entry.FullName].File
    }
    $dest = Join-Path $assetsDir $targetName
    $entryStream = $entry.Open()
    $fileStream = [System.IO.File]::Create($dest)
    try {
        $entryStream.CopyTo($fileStream)
    } finally {
        $fileStream.Close()
        $entryStream.Close()
    }
}
$zip.Dispose()
Trace 'images extracted'

# ---------------------------------------------------------------------------
# Render pages
# ---------------------------------------------------------------------------

$expectationIndexPaths = @{}
foreach ($exp in $expectations) {
    Trace "rendering expectation $($exp.Number)"
    $folder = Join-Path $OutputRoot (Join-Path 'expectations' $exp.Slug)
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    $expectationIndexPaths[$exp.Number] = Join-Path $folder 'index.md'

    $introBlocks = Get-BlocksForRanges -Blocks $blocks -Ranges $exp.IntroRanges
    if ($exp.IntroSkipFirst) { $introBlocks = Remove-FirstBlock $introBlocks }
    $introMd = Format-Blocks $introBlocks
    $introMd = Resolve-Assets -Markdown $introMd -Prefix '../../assets/'

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("[Home](../../index.md)`n`n")
    [void]$sb.Append("# Expectation $($exp.Number): $($exp.Title)`n`n")
    if ($introMd.Trim().Length -gt 0) {
        [void]$sb.Append($introMd.Trim() + "`n`n")
    } else {
        [void]$sb.Append("This expectation is organized across the pages below.`n`n")
    }
    [void]$sb.Append("## Pages in this expectation`n`n")
    foreach ($page in $exp.Pages) {
        [void]$sb.Append("- [$($page.Title)]($($page.File)) - $($page.Description)`n")
    }
    [void]$sb.Append("`n## Navigate`n`n")
    $idx = $expectations.IndexOf($exp)
    if ($idx -gt 0) {
        $prev = $expectations[$idx - 1]
        [void]$sb.Append("- Previous: [Expectation $($prev.Number): $($prev.Title)](../$($prev.Slug)/index.md)`n")
    }
    if ($idx -lt $expectations.Count - 1) {
        $next = $expectations[$idx + 1]
        [void]$sb.Append("- Next: [Expectation $($next.Number): $($next.Title)](../$($next.Slug)/index.md)`n")
    }
    [void]$sb.Append("- [Main index](../../index.md)`n")

    Write-TextFile -Path (Join-Path $folder 'index.md') -Content $sb.ToString()

    for ($p = 0; $p -lt $exp.Pages.Count; $p++) {
        $page = $exp.Pages[$p]
        $pageBlocks = Get-BlocksForRanges -Blocks $blocks -Ranges $page.Ranges
        if ($page.SkipFirst) { $pageBlocks = Remove-FirstBlock $pageBlocks }
        $content = Format-Blocks $pageBlocks
        $content = Resolve-Assets -Markdown $content -Prefix '../../assets/'

        $pageSb = New-Object System.Text.StringBuilder
        [void]$pageSb.Append("[Home](../../index.md) / [Expectation $($exp.Number)](index.md)`n`n")
        [void]$pageSb.Append("# $($page.Title)`n`n")
        [void]$pageSb.Append("> Part of Expectation $($exp.Number): $($exp.Title)`n`n")
        if ($content.Trim().Length -gt 0) {
            [void]$pageSb.Append($content.Trim() + "`n`n")
        }
        [void]$pageSb.Append("## Page navigation`n`n")
        if ($p -gt 0) {
            $prevPage = $exp.Pages[$p - 1]
            [void]$pageSb.Append("- Previous: [$($prevPage.Title)]($($prevPage.File))`n")
        }
        if ($p -lt $exp.Pages.Count - 1) {
            $nextPage = $exp.Pages[$p + 1]
            [void]$pageSb.Append("- Next: [$($nextPage.Title)]($($nextPage.File))`n")
        }
        [void]$pageSb.Append("- [Back to Expectation $($exp.Number)](index.md)`n")
        [void]$pageSb.Append("- [Main index](../../index.md)`n")

        Write-TextFile -Path (Join-Path $folder $page.File) -Content $pageSb.ToString()
    }
}
Trace 'expectations rendered'

# ---------------------------------------------------------------------------
# Appendix - duplicate copy of Expectation 3
# ---------------------------------------------------------------------------

$appendixDir = Join-Path $OutputRoot 'appendix'
New-Item -ItemType Directory -Force -Path $appendixDir | Out-Null
$dupRanges = @(, @(986, 1575))
$dupBlocks = Get-BlocksForRanges -Blocks $blocks -Ranges $dupRanges
$dupBlocks = Remove-FirstBlock $dupBlocks
$dupMd = Format-Blocks $dupBlocks
$dupMd = Resolve-Assets -Markdown $dupMd -Prefix '../assets/'

$appSb = New-Object System.Text.StringBuilder
[void]$appSb.Append("[Home](../index.md) / [Expectation 3](../expectations/03-architecture-standards-guardrails/index.md)`n`n")
[void]$appSb.Append("# Appendix: Duplicate Copy of Expectation 3`n`n")
[void]$appSb.Append("> This appendix preserves the second copy of Expectation 3 found in the source document, including the repeated tail. The canonical version is [Expectation 3: Architecture standards and guardrails](../expectations/03-architecture-standards-guardrails/index.md).`n`n")
if ($dupMd.Trim().Length -gt 0) {
    [void]$appSb.Append($dupMd.Trim() + "`n`n")
}
[void]$appSb.Append("## Navigation`n`n")
[void]$appSb.Append("- [Canonical Expectation 3](../expectations/03-architecture-standards-guardrails/index.md)`n")
[void]$appSb.Append("- [Main index](../index.md)`n")
Write-TextFile -Path (Join-Path $appendixDir 'expectation-03-duplicate.md') -Content $appSb.ToString()
Trace 'appendix rendered'

# ---------------------------------------------------------------------------
# Root index
# ---------------------------------------------------------------------------

$rootSb = New-Object System.Text.StringBuilder
[void]$rootSb.Append("# AI Principal Architect - Interview Preparation Guide`n`n")
[void]$rootSb.Append("A linked Markdown edition of ``core_content_files/AI Principal Architect.docx``. The guide is organized around eight principal expectations, each with its own folder and focused pages.`n`n")
[void]$rootSb.Append("## Expectations`n`n")
[void]$rootSb.Append("| # | Expectation | Pages |`n")
[void]$rootSb.Append("|---|---|---|`n")
foreach ($exp in $expectations) {
    $pageLinks = @()
    foreach ($page in $exp.Pages) {
        $pageLinks += "[$($page.Title)](expectations/$($exp.Slug)/$($page.File))"
    }
    $expLink = "[Expectation $($exp.Number): $($exp.Title)](expectations/$($exp.Slug)/index.md)"
    [void]$rootSb.Append("| $($exp.Number) | $expLink | $($pageLinks -join '<br>') |`n")
}
[void]$rootSb.Append("`n## Appendix`n`n")
[void]$rootSb.Append("- [Duplicate copy of Expectation 3](appendix/expectation-03-duplicate.md) - retained for reference; not part of the canonical reading path.`n")
[void]$rootSb.Append("`n## Source`n`n")
[void]$rootSb.Append("- Source document: AI Principal Architect.docx`n")
[void]$rootSb.Append("- All tables, diagrams, and external reference links from the source are preserved in the linked pages.`n")

Write-TextFile -Path (Join-Path $OutputRoot 'index.md') -Content $rootSb.ToString()

Write-Output "Generated Markdown under: $OutputRoot"
Write-Output "Expectations: $($expectations.Count)"
Write-Output "Pages: $(($expectations | ForEach-Object { $_.Pages.Count } | Measure-Object -Sum).Sum)"
