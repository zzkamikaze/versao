
#SingleInstance Force
#NoEnv

Name = Fiesta Online Price Checker ;Script name
;~ Currversion = 8 ;Versão atual do script para a janela de atualização
version = 10   ;Versão atual do script

UrlDownloadToFile, https://raw.githubusercontent.com/zzkamikaze/versao/main/MoradiaVersao.txt, MoradiaVersao.txt ;Downloads Version.ini file
FileRead, new_version, MoradiaVersao.txt ;Reads the version.ini file to see what the new version is
;~ new_version := StrReplace(new_version,"`r`n")
;~ Currversion = %new_version%

if (new_version > version) ;se a versão for mais recente que a versão atual Peça para baixar a nova versão
	{
;~ FileRead, NewVersion, MoradiaVersao.txt ;Reads the New version file to announce the new version in the ask for update qui.
Gui, Update:Add, Text, x5 y10 w185 h25, A new version of %Name% is available ;Announces that there is a new version available
Gui, Update:Add, Text, x5 y40 w145 h25, Current Version: %version%       ;Announces the current version the user is using.
Gui, Update:Add, Text, x5 y55 w145 h200, New Version: %new_version%            ;Reads the downloaded version.ini to tell the new version available 
Gui, Update:Add, Text, x5 y80 w145 h200, Você gostaria de atualizar?      ;Text asking if the user wants to update to the newer version
Gui, Update:Add, Button, x52 y110 w43 h23 gYes, Yes                        ;If pressed it will go to the Yes sub to download the newest version available
Gui, Update:Add, Button, x102 y110 w43 h23 gHome, No                     ;Will skip the update and go to the main functions
Gui, Update:Show, w190 h150, Update?                                     ;Update window title.
}


Home:

return

Yes:
 URLDownloadToFile, https://raw.githubusercontent.com/zzkamikaze/versao/main/autoupdate.ahk, autoupdate.ahk
 ;~ FileDelete C:\Users\Matheus\Desktop\x/upteste.ahk
 msgbox, atualizado, atualizado,atualizado!
return
