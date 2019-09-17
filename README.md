# Deluge language parser


[![Build Status](https://dev.azure.com/guruzoho/Zoho/_apis/build/status/GuruDhanush.Deluge-Language-Parser?branchName=master)](https://dev.azure.com/guruzoho/Zoho/_build/latest?definitionId=3&branchName=master "Build Status")
[![codecov](https://codecov.io/gh/GuruDhanush/Deluge-Language-Parser/branch/master/graph/badge.svg)](https://codecov.io/gh/GuruDhanush/Deluge-Language-Parser)
![GitHub Releases](https://img.shields.io/github/downloads/GuruDhanush/Deluge-Language-Parser/latest/total)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/GuruDhanush/Deluge-Language-Parser)

Created using parser combinators in dart. More info about deluge can be found [here](https://www.zoho.com/creator/newhelp/script/deluge-overview.html "Deluge"). The package aims to parse cliq compatible deluge  according to the externally available documentation. 


The code is packaged to aot and is released for all three platform Window, Linux and Mac. 

**Demo**: [Online-Editor](https://gurudhanush.github.io/Deluge-Editor/)


## Benchmark

Deluge code from the [extension samples](https://www.zoho.com/cliq/help/platform/code-samples.html "Cliq code samples") was taken and packaged as one file with 55KB size and 1923 LOC. Benchmark ran on i7 7500U @2.7GHZ

| aot   | jit |
|------ | ------|
| 588ms | 436ms | 


Incremental compilation is yet to be implemented. In the mean time some parse requests are debounced. 


## LSP Method status

 Method | Implementation
| - | - |
| initialize | ✅ |
| initialized | ✅ |
| cancelRequest | ✅ |
| window/showMessage | ✅ | 
| window/showMessageRequest | ✅ |
| window/logMessage | ✅ | 
| textDocument/didOpen | ✅ | 
| textDocument/didChange | ✅ |
| textDocument/didClose | ✅ |
| textDocument/publishDiagnostics | ✅ | 
| textDocument/hover | ✅ |
| textDocument/documentSymbol | ✅ |
| textDocument/codeLens |✅ |
| codeLens/resolve |✅ | 


## Custom notification

### custom/updateStatusBarItem

Direction: Server -> Client.

Params: `{ "status": true|false }`


## Compiling for web

Dart apart from compiling to native code which was leveraged in the vscode extension, can also compile to javascript. The lang server can b compiled to javascript and interface with [monaco-editor](https://github.com/microsoft/monaco-editor "Monaco-editor"), the editor that powers vscode. 

The entry point is in `\bin\web.dart`. Its interfaces with monaco-editor via service worker. 

### Features

- Text Sync
- Diagnostics

The seperate web project is hosted in [here](https://github.com/GuruDhanush/Deluge-Editor "Deluge editor").


### Compiling for web

    dart2js .\bin\web.dart -m


---



