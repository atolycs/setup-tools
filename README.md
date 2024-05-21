# My PC setup scripts


* Windows
```powershell
$ Set-ExecutionPolicy -Scope Process RemoteSigned
$ Invoke-Webrequest https://setup.atolycs.dev/?os=windows | 
```

* Linux
```bash
$ curl -sLo https://setup.atolycs.dev/?os=linux | bash 
```