# Deluge language parser


[![Build Status](https://dev.azure.com/guruzoho/Zoho/_apis/build/status/GuruDhanush.Deluge-Language-Parser?branchName=master)](https://dev.azure.com/guruzoho/Zoho/_build/latest?definitionId=3&branchName=master)

Created using parser combinators in dart.


More info about deluge can be found [here](https://www.zoho.com/creator/newhelp/script/deluge-overview.html)

The package aims to parse cliq compatible deluge  according to the externally available documentation. 

The code is packaged to aot and is released for all three platform Window, Linux and Mac. 

## Benchmark

Deluge code from the [extension samples](https://www.zoho.com/cliq/help/platform/code-samples.html) was taken and packaged as one file with 55KB size and 1923 LOC. Benchmark ran on i7 7500U @2.7GHZ

| aot   | jit |
|------ | ------|
| 588ms | 436ms | 


Incremental compilation is yet to be implemented. In the mean time some parse requests are debounced. 


## LSP Method status

 Method | Implementation
| - | - |
| initialize | ✅ |
| initialized | ✅ |
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


---



