# FITWAY

Aplicativo Flutter para treinos. A inicializacao padrao (`lib/main.dart`) usa o app FITWAY.

## Build para Windows

Requisitos: Flutter, Visual Studio 2022 com **Desenvolvimento para desktop com C++** e o Modo de Desenvolvedor do Windows habilitado (necessario para os symlinks dos plugins Flutter).

Na raiz do projeto, execute:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_windows.ps1
```

O executavel e os arquivos necessarios para distribuicao ficam em `build\windows\x64\runner\Release\`. Distribua a pasta inteira, nao apenas o `.exe`.

As preferencias e os dados do app sao gravados pelo `shared_preferences` na pasta de suporte do usuario no Windows, fora da pasta de instalacao.
