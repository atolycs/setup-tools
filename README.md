# My PC setup scripts

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/atolycs/setup-tools)

* Windows
```powershell

$ Set-ExecutionPolicy -Scope Process RemoteSigned

# github raw link
$ Invoke-WebRequest https://github.com/atolycs/setup-tools/raw/main/win/install.ps1 | Invoke-Expression

# or
$ iwr https://github.com/atolycs/setup-tools/raw/main/win/install.ps1 | iex


# shorten link on my domain.
$ Invoke-Webrequest https://setup.atolycs.dev/win | Invoke-Expression

# or
$ iwr https://setup.atolycs.dev/win | iex
```

* Linux
```bash

# github raw link
$ curl -sL https://github.com/atolycs/setup-tools/raw/main/linux/install.sh | bash 

# shorten link on my domain.
$ curl -sL https://setup.atolycs.dev/?os=linux | bash 
```
