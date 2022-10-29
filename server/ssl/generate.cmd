@echo off
echo Generating SSL certificate...
"P:\Git\usr\bin\openssl.exe" req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365 -nodes -config .\generate.cnf
echo Done
exit