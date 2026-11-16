$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter nao foi encontrado no PATH. Instale o Flutter e tente novamente.'
}

if (-not (Test-Path $vswhere)) {
    throw 'Visual Studio 2022 com a carga "Desenvolvimento para desktop com C++" e necessario para compilar o aplicativo Windows.'
}

$visualStudio = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $visualStudio) {
    throw 'Instale a carga "Desenvolvimento para desktop com C++" no Visual Studio 2022.'
}

Push-Location $projectRoot
try {
    & flutter build windows --release --target=lib/main.dart
    if ($LASTEXITCODE -ne 0) {
        throw "O build do Flutter falhou com codigo $LASTEXITCODE."
    }

    $executable = Join-Path $projectRoot 'build\windows\x64\runner\Release\fitway.exe'
    if (-not (Test-Path $executable)) {
        throw "O build terminou sem gerar o executavel esperado: $executable"
    }

    Write-Host "Executavel gerado: $executable"
    Write-Host "Distribua junto todos os arquivos da pasta: $(Split-Path $executable)"
}
finally {
    Pop-Location
}
