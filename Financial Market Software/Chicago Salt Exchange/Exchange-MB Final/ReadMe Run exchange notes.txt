In order to run the exchange these steps must be taken

install toolkit as windows service

installutil /i C:\Users\Mike\Dropbox\Chicago Salt Exchange\Exchange-6-9\ApplicationLoaderService\bin\Debug\LoadService.exe

installutil /i D:\Caleb\Dropbox\Chicago Salt Exchange\Exchange-MB Final\ApplicationLoaderService\bin\Debug

install exchange in GAC
C:\Program Files (x86)\Microsoft SDKs\Windows\v8.0A\bin\NETFX 4.0 Tools\gacutil.exe /i C:\Exchange\Exchange\bin\Debug\Exchange.dll


Run as windows service:
if the above steps are taken windows service will start 
up My new reflection example which will start exchange using reflection


Run from my new reflection example
once the exchnge .dll file is added to GAC you should be able to run 
from My new reflection example


Alternatively you can change the exchange to a console application, 
currently saved as class program, and run from VS whithout having to 
follow the above steps



Open an additional VS session and run Trading Engine to begin subbmiting
orders to the exchange









