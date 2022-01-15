/*
[AutoHotkey Updater]
version = 0.014
*/

SelfUpdate = 1 ; Set to 0 to prevent the script from checking for updates to itself.

URL_Base    = https://autohotkey.com/download
URL_Script  = %URL_Base%/Update.ahk
URL_Setup   = %URL_Base%/ahk-install.exe
URL_Version = %URL_Base%/1.1/version.txt


#NoEnv
#Include *i %A_ScriptDir%\UpdateDebug.ahk

if 0 > 0
{
    if IsFunc("_" %True%) ; Recursive call, used to swap exes or elevate the process.
    {
        prms := Object()
        Loop %0%
            prms.Insert(%A_Index%)
        func := prms.Remove(1), _%func%(prms*)
        ExitApp
    }
    else if 1 = SuppressUpToDate ; Suppress "AutoHotkey is up to date" message.
        SuppressUpToDate := true
}

if !A_IsCompiled && SelfUpdate
{
    ; First, check for a newer version of this script.
    URLDownloadToFile %URL_Script%, %A_Temp%\Update.ahk
    IniRead rver, %A_Temp%\Update.ahk, AutoHotkey Updater, version, %A_Space%
    IniRead lver, %A_ScriptFullPath%,  AutoHotkey Updater, version, %A_Space%
    if (lver < rver)
    {
        MsgBox 3, AutoHotkey Updater,
        (LTrim Join`s
        A newer version of this script is available.  It is recommended
        that you use the updated version of the script to install further
        updates.  *** WARNING: If you click yes, any modifications you
        have made to this script will be lost. ***
        `n`nUse the updated script?
        )
        ifMsgBox Yes
        {
            _SelfUpdate(A_Temp "\Update.ahk")
            ExitApp
        }
        ifMsgBox Cancel
        {
            FileDelete %A_Temp%\Update.ahk
            ExitApp
        }
    }
    FileDelete %A_Temp%\Update.ahk
}


; Retrieve latest version number.
try
{
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", URL_Version, false), whr.Send()
    version := whr.ResponseText
    if !(version ~= "^\d+\.\d")
        throw ; 404?
}
catch
{
    MsgBox 48, AutoHotkey Updater, There was a problem checking for updates.  Please check your internet connection or try again later.
    ExitApp
}


if (version <= A_AhkVersion)
    && !RegExMatch(A_AhkVersion, "^\Q" version "\E-")  ; Quick hack for beta -> final version.
{
    if !SuppressUpToDate
        MsgBox 64, AutoHotkey Updater,
        (Ltrim
        AutoHotkey is up to date.
        
        Installed version:`t%A_AhkVersion%
        Latest version:`t%version%
        )
    ExitApp
}

MsgBox 68, AutoHotkey Update Available,
(
An update for AutoHotkey is available.

Installed version:`t%A_AhkVersion%
Latest version:`t%version%

Would you like to install it now?
)
ifMsgBox No
    ExitApp

TempFile := A_Temp "\ahk-install.exe"

; Download the new package
if !Download(URL_Setup, TempFile)
{
    MsgBox 16, AutoHotkey Updater, Update failed due to a download error.
    ExitApp
}

; Run setup
try Run "%TempFile%" /exec kill %A_ScriptHwnd% /exec Downloaded "%TempFile%"
ExitApp


_SelfUpdate(source_path)
{
    ; Copy and Delete instead of Move so that file permissions are inherited correctly.
    FileCopy %source_path%, %A_ScriptFullPath%, 1
    if ErrorLevel
    {
        if !A_IsAdmin
        {   ; Try again as admin.
            if Elevate("SelfUpdate", source_path)
                ExitApp
        }
        MsgBox 16, AutoHotkey Updater, Script update failed.  Error %err%.
        ExitApp
    }
    FileDelete %source_path%
    Reload
}


Elevate(func, prms*)
{
    cmd := func
    for i,prm in prms
    {
        StringReplace prm, prm, `", "", All
        cmd .= " """ prm """"
    }
    if A_IsCompiled
        exe := A_ScriptFullPath
    else
        exe := A_AhkPath, cmd := """" A_ScriptFullPath """ " cmd
    return DllCall("shell32\ShellExecute", "ptr", 0, "str", "RunAs"
                    , "str", exe, "str", cmd, "ptr", 0, "int", 1) > 32
}


; Based on code by Sean and SKAN @ http://www.autohotkey.com/forum/viewtopic.php?p=184468#184468
Download(url, file)
{
    static vt
    if !VarSetCapacity(vt)
    {
        VarSetCapacity(vt, A_PtrSize*11), nPar := "31132253353"
        Loop Parse, nPar
            NumPut(RegisterCallback("DL_Progress", "F", A_LoopField, A_Index-1), vt, A_PtrSize*(A_Index-1))
    }
    global _cu
    SplitPath file, dFile
    SysGet m, MonitorWorkArea, 1
    scale := A_ScreenDPI ? A_ScreenDPI/96 : 1, y := mBottom-52*scale-2, x := mRight-330*scale-2
    , VarSetCapacity(_cu, 100), VarSetCapacity(tn, 520)
    , DllCall("shlwapi\PathCompactPathEx", "str", _cu, "str", url, "uint", 50, "uint", 0)
    Progress Hide CWFAFAF7 CT000020 CB445566 x%x% y%y% w330 h52 B1 FS8 WM700 WS700 FM8 ZH12 ZY3 C11,, %_cu%, AutoHotkeyProgress, Tahoma
    if (0 = DllCall("urlmon\URLDownloadToCacheFile", "ptr", 0, "str", url, "str", tn, "uint", 260, "uint", 0x10, "ptr*", &vt))
        FileCopy %tn%, %file%, 1
    else
        ErrorLevel := 1
    Progress Off
    return !ErrorLevel
}
DL_Progress( pthis, nP=0, nPMax=0, nSC=0, pST=0 )
{
    global _cu
    if A_EventInfo = 6
    {
        Progress Show
        Progress % P := 100*nP//nPMax, % "Downloading:     " Round(np/1024,1) " KB / " Round(npmax/1024) " KB    [ " P "`% ]", %_cu%
    }
    return 0
}