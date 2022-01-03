::
::    /$$$$$$  /$$     /$$ /$$$$$$        /$$                                  
::   /$$__  $$|  $$   /$$//$$__  $$      | $$                                  
::  | $$  \__/ \  $$ /$$/| $$  \__/  /$$$$$$$ /$$   /$$ /$$$$$$/$$$$   /$$$$$$ 
::  |  $$$$$$   \  $$$$/ |  $$$$$$  /$$__  $$| $$  | $$| $$_  $$_  $$ /$$__  $$
::   \____  $$   \  $$/   \____  $$| $$  | $$| $$  | $$| $$ \ $$ \ $$| $$  \ $$
::   /$$  \ $$    | $$    /$$  \ $$| $$  | $$| $$  | $$| $$ | $$ | $$| $$  | $$
::  |  $$$$$$/    | $$   |  $$$$$$/|  $$$$$$$|  $$$$$$/| $$ | $$ | $$| $$$$$$$/
::   \______/     |__/    \______/  \_______/ \______/ |__/ |__/ |__/| $$____/ 
::                                                                   | $$      
::                                                                   | $$      
::                                                                   |__/      
::           
::+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
::
::  	tool author:  t0rt3rra    https://github.com/t0rt3rra
::
::+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
::
::	about:
::		SYSdump is intended to aid forensic acquisition for live MSwindows systems by parsing some of the more common settings 
::		and files using tools native to the MSwindows command line.  as such, SYSdump will have a limited footprint on the 
::		target OS (if run from USB or external drive) and can dump the results file (SYSDUMPoutput.txt) onto an external 
::		drive or USB thus maintaining forensically-sound target acquisition.  Similarly, batch script is simple-enough for the 
::		lay-person to understand and aids the forensic investigator's testimony in court to the tool's content and its 
::		utility in parsing forensic artifacts.
::
::+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


@echo off

::change output directory, folder, and file name as necessary

echo tool start:
date /T & time /T
CD c:\ & MKDIR SYSDUMP-output-folder & CD SYSDUMP-output-folder
echo sysdump tool running...  window will close on finish...
call :sub >SYSDUMPoutput.txt
exit /b


:sub
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [*] BASIC SYSTEM INFO ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] SYSTEM DATE and TIME ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo. 
date /T & time /T
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] WINDOWS OS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo.
systeminfo 2>NUL
echo.
echo. 
wmic qfe get Caption,Description,HotFixID,InstalledOn 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] UAC? ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo [i] If the results read ENABLELUA REG_DWORD 0x1, part or all of the UAC components are on
REG QUERY HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System\ /v EnableLUA
echo.
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] Registered Anti-Virus(AV) ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName /Format:List | more 
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] MOUNTED DISKS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
(wmic logicaldisk get caption 2>NUL ) || (fsutil fsinfo drives 2>NUL)
echo.
wmic logicaldisk get name, size, systemname, filesystem, volumename, volumeserialnumber /all
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] ENVIRONMENT ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
set
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] INSTALLED SOFTWARE ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
dir /b "C:\Program Files" "C:\Program Files (x86)" | sort 
echo.
reg query HKEY_LOCAL_MACHINE\SOFTWARE
echo.
IF exist C:\Windows\CCM\SCClient.exe echo SCCM is installed (installers are run with SYSTEM privileges, many are vulnerable to DLL Sideloading)
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] UNINSTALLED SOFTWARE ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo. 
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall 2>NUL
echo.
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall 2>NUL
echo.
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] RUNNING PROCESSES ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo [i] is something unexpected running? Check for malicious processes
echo.
tasklist /SVC
echo.
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] RUN ^AT STARTUP ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo. 
wmic startup get caption,command 2>NUL
echo.
autorunsc.exe -m -nobanner -a * -ct /accepteula 2>NUL 
echo.
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run 2>NUL
echo. 
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce 2>NUL
echo. 
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run 2>NUL
echo. 
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce 2>NUL
echo.
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [*] NETWORK ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] CURRENT SHARES ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
net share 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] INTERFACES ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
ipconfig  /all 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] USED PORTS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
netstat -ano 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] FIREWALL ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
netsh advfirewall show allprofiles 2>NUL
echo.
dir %systemroot%\system32\LogFiles\Firewall\pfirewall.log 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] ^ARP ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
arp -A 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] ROUTES ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
route print 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] HOSTS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo [i] the presence of an altered hosts-file could indicate malicious persistence
echo.
echo.
type C:\WINDOWS\System32\drivers\etc\hosts 2>NUL
echo.
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] CACHE DNS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
ipconfig /displaydns | findstr "Record" | findstr "Name Host" 2>NUL
echo.  2>NUL
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] WIFI ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.  2>NUL
echo ^[i^] To get clear^-text password use^: netsh wlan show profile ^<SSID^> key^=clear 2>NUL
echo.  2>NUL
netsh wlan show profiles 2>NUL
echo. 
for /f "tokens=4,* skip=4" %%a in ('netsh wlan show profile') do ( for /f "tokens=*" %%c in ('netsh wlan show profile "%%b" key^=clear') do ( for /f "tokens=3,*" %%d in ('echo %%c^| find /i "Key Content"') do ( echo [SSID: %%b] [PASSWORD: %%e] ) ) )
echo.
echo Exporting profiles to XML.  SSID keys present in exports. Exports saved to output folder  2>NUL
:: exports profiles to .XML 
echo. 
netsh wlan export profile key=clear 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^>[*] BASIC USER INFO ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] CURRENT USER ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
net user %username% 2>NUL
echo. 
net user %USERNAME% /domain 2>NUL
echo. 
whoami /all 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] USERS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
net user 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] GROUPS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
net localgroup 2>NUL
echo.
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] ADMINISTRATORS GROUPS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo.
net localgroup Administrators 2>NUL
echo.
net localgroup Administradores 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] CURRENT LOGGED USERS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
quser 2>NUL
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [*] CREDENTIALS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
echo _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-^> [+] SAVED CREDENTIALS ^<_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
echo.
Echo cmdkey /list
cmdkey /list 2>NUL
echo.
echo Looking inside %userprofile% for saved credentials
echo.
echo %userprofile%\AppData\Roaming\Microsoft\credentials
dir /b %userprofile%\AppData\Roaming\Microsoft\credentials 2>NUL
echo.
echo %userprofile%\AppData\Roaming\Microsoft\Vault
dir /b %userprofile%\AppData\Roaming\Microsoft\Vault 2>NUL
echo.
echo %userprofile%\appdata\local\Microsoft\Vault
dir /b %userprofile%\appdata\local\Microsoft\Vault 2>NUL
echo.
echo %userprofile%\appdata\local\Microsoft\credentials
dir /b %userprofile%\appdata\local\Microsoft\credentials 2>NUL
echo.
echo.
echo tool end time:
date /T
time /T