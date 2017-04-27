# MATLAB NewFocus Model 8742 

MATLAB communication with NewFocus (a Newport corporation) Model 8742 Picomotor Controller / Driver via ethernet (MATLAB `tcpip()`)

## About

The Model 8742 Controller/Driver utilizes an ASCII command set and also outputs system status in ASCII format.  As a result, `fprintf()` and `fscanf()` are used (which write and read text data); not `fwrite()` and `fread()` which write and read binary data.

The Model 8742 runs its own web server that supports sending and receiving commands.  Once you connect it to your local network, visit its IP address from the browser and you can send it commands and view the response. 
