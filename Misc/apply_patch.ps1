param(
    [string]$PatchFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-TargetPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Get-FileLines {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    $raw = [System.IO.File]::ReadAllText($Path)
    if ($raw.Length -eq 0) {
        return @()
    }

    $normalized = $raw -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"
    return $normalized -split "`n", -1
}

function Write-FileLines {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][AllowEmptyCollection()][string[]]$Lines
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $content = [string]::Join("`r`n", $Lines)
    [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}

function Parse-Patch {
    param([Parameter(Mandatory = $true)][string]$Text)

    $normalized = $Text -replace "`r`n", "`n"
    $normalized = $normalized -replace "`r", "`n"
    $lines = $normalized -split "`n", -1

    if ($lines.Count -lt 2 -or $lines[0] -ne '*** Begin Patch') {
        throw 'Patch must start with *** Begin Patch'
    }

    $commands = New-Object System.Collections.Generic.List[object]
    $index = 1

    while ($index -lt $lines.Count) {
        $line = $lines[$index]

        if ($line -eq '*** End Patch') {
            return $commands
        }

        if ($line.StartsWith('*** Add File: ')) {
            $path = $line.Substring(14)
            $index++
            $contentLines = New-Object System.Collections.Generic.List[string]
            while ($index -lt $lines.Count) {
                $current = $lines[$index]
                if ($current.StartsWith('*** ')) {
                    break
                }
                if (-not $current.StartsWith('+')) {
                    throw "Add File only accepts '+' lines: $current"
                }
                $contentLines.Add($current.Substring(1))
                $index++
            }
            $commands.Add([pscustomobject]@{
                Type = 'add'
                Path = $path
                Lines = [string[]]$contentLines
            }) | Out-Null
            continue
        }

        if ($line.StartsWith('*** Delete File: ')) {
            $commands.Add([pscustomobject]@{
                Type = 'delete'
                Path = $line.Substring(17)
            }) | Out-Null
            $index++
            continue
        }

        if ($line.StartsWith('*** Update File: ')) {
            $oldPath = $line.Substring(17)
            $index++
            $newPath = $oldPath
            if ($index -lt $lines.Count -and $lines[$index].StartsWith('*** Move to: ')) {
                $newPath = $lines[$index].Substring(13)
                $index++
            }

            $hunks = New-Object System.Collections.Generic.List[object]
            $currentHunk = $null

            while ($index -lt $lines.Count) {
                $current = $lines[$index]
                if ($current.StartsWith('*** ')) {
                    break
                }

                if ($current -eq '@@' -or $current.StartsWith('@@ ')) {
                    $currentHunk = [pscustomobject]@{
                        Header = $current
                        Ops = New-Object System.Collections.Generic.List[object]
                    }
                    $hunks.Add($currentHunk) | Out-Null
                    $index++
                    continue
                }

                if ($current -eq '*** End of File') {
                    $index++
                    continue
                }

                if (-not $currentHunk) {
                    throw "Update File missing hunk header before: $current"
                }

                if ($current.Length -eq 0) {
                    throw 'Unexpected empty line in update hunk'
                }

                $prefix = $current.Substring(0, 1)
                if ($prefix -ne ' ' -and $prefix -ne '+' -and $prefix -ne '-') {
                    throw "Invalid update line: $current"
                }

                $currentHunk.Ops.Add([pscustomobject]@{
                    Kind = $prefix
                    Text = $current.Substring(1)
                }) | Out-Null
                $index++
            }

            $commands.Add([pscustomobject]@{
                Type = 'update'
                Path = $oldPath
                NewPath = $newPath
                Hunks = $hunks
            }) | Out-Null
            continue
        }

        throw "Unknown patch directive: $line"
    }

    throw 'Patch must end with *** End Patch'
}

function Find-AnchorIndex {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][AllowEmptyCollection()][string[]]$Source,
        [Parameter(Mandatory = $true)][int]$Start,
        [Parameter(Mandatory = $true)][object]$Hunk
    )

    foreach ($op in $Hunk.Ops) {
        if ($op.Kind -eq ' ' -or $op.Kind -eq '-') {
            for ($i = $Start; $i -lt $Source.Count; $i++) {
                if ($Source[$i] -eq $op.Text) {
                    return $i
                }
            }
            throw "Failed to find hunk anchor: $($op.Text)"
        }
    }

    return $Start
}

function Apply-Update {
    param([Parameter(Mandatory = $true)][object]$Command)

    $sourcePath = Resolve-TargetPath $Command.Path
    $sourceLines = Get-FileLines $sourcePath
    $result = New-Object System.Collections.Generic.List[string]
    $cursor = 0

    foreach ($hunk in $Command.Hunks) {
        $anchor = Find-AnchorIndex -Source $sourceLines -Start $cursor -Hunk $hunk
        while ($cursor -lt $anchor) {
            $result.Add($sourceLines[$cursor]) | Out-Null
            $cursor++
        }

        foreach ($op in $hunk.Ops) {
            if ($op.Kind -eq ' ') {
                if ($cursor -ge $sourceLines.Count -or $sourceLines[$cursor] -ne $op.Text) {
                    throw "Context mismatch in $($Command.Path): expected '$($op.Text)'"
                }
                $result.Add($sourceLines[$cursor]) | Out-Null
                $cursor++
                continue
            }

            if ($op.Kind -eq '-') {
                if ($cursor -ge $sourceLines.Count -or $sourceLines[$cursor] -ne $op.Text) {
                    throw "Delete mismatch in $($Command.Path): expected '$($op.Text)'"
                }
                $cursor++
                continue
            }

            if ($op.Kind -eq '+') {
                $result.Add($op.Text) | Out-Null
                continue
            }
        }
    }

    while ($cursor -lt $sourceLines.Count) {
        $result.Add($sourceLines[$cursor]) | Out-Null
        $cursor++
    }

    $targetPath = Resolve-TargetPath $Command.NewPath
    Write-FileLines -Path $targetPath -Lines ([string[]]$result)

    if ($targetPath -ne $sourcePath -and (Test-Path -LiteralPath $sourcePath)) {
        Remove-Item -LiteralPath $sourcePath -Force
    }
}

if ($PatchFile) {
    $patchText = [System.IO.File]::ReadAllText((Resolve-TargetPath $PatchFile))
} else {
    $patchText = [Console]::In.ReadToEnd()
}

if ([string]::IsNullOrWhiteSpace($patchText)) {
    throw 'Patch text is empty'
}

$commands = Parse-Patch -Text $patchText
foreach ($command in $commands) {
    switch ($command.Type) {
        'add' {
            $target = Resolve-TargetPath $command.Path
            Write-FileLines -Path $target -Lines $command.Lines
        }
        'delete' {
            $target = Resolve-TargetPath $command.Path
            if (Test-Path -LiteralPath $target) {
                Remove-Item -LiteralPath $target -Force
            }
        }
        'update' {
            Apply-Update -Command $command
        }
        default {
            throw "Unsupported command type: $($command.Type)"
        }
    }
}

