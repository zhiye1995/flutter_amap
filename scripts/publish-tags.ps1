param(
    [switch]$AllowDirty,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
    param([string[]]$Arguments)
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git 命令执行失败: git $($Arguments -join ' ')"
    }
}

function Get-PackageVersion {
    param([string]$PubspecPath)

    if (-not (Test-Path -LiteralPath $PubspecPath)) {
        throw "找不到 pubspec.yaml: $PubspecPath"
    }

    $match = Select-String -LiteralPath $PubspecPath -Pattern '^version:\s*([^\s#]+)' | Select-Object -First 1
    if (-not $match) {
        throw "无法从 $PubspecPath 读取 version"
    }

    return $match.Matches[0].Groups[1].Value
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw '未找到 git，请先安装 Git 并确保 git 已加入 PATH。'
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

$branch = (& git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    throw '当前目录不是有效的 Git 仓库。'
}

$dirtyFiles = @(git status --porcelain)
if ($dirtyFiles.Count -gt 0 -and -not $AllowDirty) {
    Write-Host '工作区存在未提交改动，脚本已停止：' -ForegroundColor Yellow
    $dirtyFiles | ForEach-Object { Write-Host "  $_" }
    Write-Host '请先提交这些改动，或明确使用 -AllowDirty 继续。' -ForegroundColor Yellow
    exit 1
}

$packages = @(
    @{ Name = 'flutter_amap_plus'; Path = 'packages/flutter_amap/pubspec.yaml' },
    @{ Name = 'flutter_amap_navi'; Path = 'packages/flutter_amap_navi/pubspec.yaml' }
)

$tags = foreach ($package in $packages) {
    $version = Get-PackageVersion (Join-Path $repoRoot $package.Path)
    [PSCustomObject]@{
        Package = $package.Name
        Version = $version
        Tag = "$($package.Name)-v$version"
    }
}

$commit = (& git rev-parse --short HEAD).Trim()
Write-Host "将为提交 $commit 创建并推送以下标签：" -ForegroundColor Cyan
$tags | Format-Table Package, Version, Tag

foreach ($item in $tags) {
    $localTag = git tag --list $item.Tag
    if ($localTag) {
        throw "本地标签已存在: $($item.Tag)。脚本不会覆盖已有标签。"
    }

    $remoteTag = git ls-remote --tags origin "refs/tags/$($item.Tag)"
    if ($remoteTag) {
        throw "远端标签已存在: $($item.Tag)。脚本不会覆盖已有标签。"
    }
}

if ($DryRun) {
    Write-Host 'DryRun 模式：未创建或推送任何标签。' -ForegroundColor Yellow
    exit 0
}

$answer = Read-Host '确认创建并推送这些标签吗？请输入 YES'
if ($answer -cne 'YES') {
    Write-Host '已取消，未创建或推送任何标签。'
    exit 0
}

foreach ($item in $tags) {
    Invoke-Git @('tag', '-a', $item.Tag, '-m', "发布 $($item.Package) $($item.Version)")
    Invoke-Git @('push', 'origin', $item.Tag)
}

Write-Host '标签发布完成：' -ForegroundColor Green
$tags | ForEach-Object { Write-Host "  $($_.Tag)" }
