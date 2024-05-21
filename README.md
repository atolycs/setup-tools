# My PC setup scripts

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/atolycs/setup-tools)

* Windows
```powershell
$ Set-ExecutionPolicy -Scope Process RemoteSigned
$ Invoke-Webrequest https://setup.atolycs.dev/?os=windows | 
```

* Linux
```bash
$ curl -sLo https://setup.atolycs.dev/?os=linux | bash 
```
