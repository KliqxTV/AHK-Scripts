﻿; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk

clipProcess(type)
{
    static prev := "a"
    static curr := "b"
    static changed := false

    if (type !== 1)
    {
        return
    }

    curr := A_Clipboard

    if (prev == curr)
    {
        A_Clipboard := prev
        prev := ""
        return
    }

    if (InStr(A_Clipboard, "open.spotify.com") && RegExMatch(A_Clipboard, "\?.*="))
    {
        A_Clipboard := RegExReplace(A_Clipboard, "\?.*", "")
        changed := true
    }
    else if (InStr(A_Clipboard, "cdn.discordapp.com/avatars") && RegExMatch(A_Clipboard, "webp(\?size=).*"))
    {
        A_Clipboard := RegExReplace(A_Clipboard, "webp(\?size=).*", "png$1" . 4096)
        changed := true
    }
    else if (InStr(A_Clipboard, "www.youtube.com/watch?v="))
    {
        A_Clipboard := StrReplace(A_Clipboard, "www.youtube.com/watch?v=", "youtu.be/")
        changed := true
    }
    else if (InStr(A_Clipboard, "steamcommunity.com") || InStr(A_Clipboard, "store.steampowered.com"))
    {
        if (SubStr(A_Clipboard, 1, StrLen("steam://openurl/")) == "steam://openurl/")
        {
            return
        }
        else
        {
            A_Clipboard := "steam://openurl/" . A_Clipboard
            changed := true
        }

        /*
        if (InStr(A_Clipboard, "https://steamcommunity.com/sharedfiles/filedetails/?id="))
        {
            A_Clipboard := StrReplace(A_Clipboard, "https://steamcommunity.com/sharedfiles/filedetails/?id=", "steam://url/CommunityFilePage/")
            changed := true
        }
        else if (InStr(A_Clipboard, "https://store.steampowered.com/app/"))
        {
            A_Clipboard := RegExReplace(A_Clipboard, ".*app/([0-9]+).*", "steam://store/${1}")
            changed := true
        }
        else
        {
            A_Clipboard := "steam://openurl/" . A_Clipboard
            changed := true
        }
        */
    }
    else if (InStr(A_Clipboard, "open.spotify.com"))
    {
        A_Clipboard := StrReplace(StrReplace(A_Clipboard, "https://open.spotify.com/", "spotify:"), "/", ":")
        changed := true
    }
    else if (InStr(A_Clipboard, "roblox.com/games") && RegExMatch(A_Clipboard, "\?.*="))
    {
        A_Clipboard := RegExReplace(A_Clipboard, "\?.*", "")
        changed := true
    }

    if (changed)
    {
        prev := curr
        changed := false
    }
}
OnClipboardChange(clipProcess)

afkCondition()
{
    global

    if (codebase.collectionOperations.orFunc(WinActive, triggers*))
    {
        if (A_TimeIdlePhysical >= requiredIdleTime
            && !GetKeyState("RButton", "P")
            && !GetKeyState("LButton", "P")
            && !GetKeyState("LAlt", "P")
        )
        {
            Loop
            {
                try
                {
                    return WinGetProcessName("A")
                }
            }
        }
        else
        {
            return true
        }
    }
    else
    {
        return false
    }
}

sendAfk(exe := "")
{
    global

    defaultDelay := 250
    static kscount := 0

    if (exe == "GTA5.exe")
    {
        Send("{LCtrl down}")
        Send("{d down}")
    }
    else if (exe == "KnockoutCity.exe")
    {
        if (Mod(kscount, 2) == 0)
        {
            ks := "{LAlt}{a up}{d down}"
        }
        else
        {
            ks := "{LAlt}{d up}{a down}"
        }
        Send(ks)
        Sleep(400 + ((kscount - 1) * 61))
        Send("ad{LAlt}")
        if (!WinActive("ahk_exe " . exe) || !afkCondition())
        {
            Send("{s up}{d up}{LAlt}")
        }
    }
    else if (exe == "Rocksmith2014.exe")
    {
        Send("{F13}")
    }
    else if (exe == "RobloxPlayerBeta.exe")
    {
        Send("{w down}")
        Sleep(490)
        Send("{s down}{w up}{Click}")
        Sleep(500)
        Send("{s up}")
    }
    else if (exe == "RainbowSix.exe")
    {
        Send("{g down}")
        Sleep(1000)
        Send("{g up}{w down}")
        Sleep(defaultDelay)
        Send("{w up}{F6 down}")
        Sleep(defaultDelay)
        Send("{F6 up}")
    }
    else if (exe == "DeadByDaylight-Win64-Shipping.exe")
    {
        codebase.Tool("Starting DBD's AFK...")

        Loop
        {
            breakoutDBD()

            Send("{w down}{d up}")
            Sleep(250)
            breakoutDBD()

            Send("{a down}{w up}")
            Sleep(250)
            breakoutDBD()

            Send("{s down}{a up}")
            Sleep(250)
            breakoutDBD()

            Send("{d down}{s up}")
            Sleep(250)
            breakoutDBD()
        }

        breakoutDBD()
        {
            if !WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe")
            {
                Send("{w up}{a up}{s up}{d up}{Alt up}{Tab up}")
                Exit()
            }
        }
    }
    else
    {
        Send("{w down}")
        Sleep(defaultDelay)
        Send("{w up}")
    }
}

millisecondMonitor()
{
    global
    str := ""
    static robloxWasActive := 0

    if (!doTick)
    {
        return
    }

    t := A_TimeIdlePhysical
    idletime.Value := codebase.formatMilliseconds(t, true, 1)

    if (compticks.Value !== ticks)
    {
        compticks.Value := ticks
    }
    if (ticktimer.Value !== "0")
    {
        ticktimer.Value := "0"
    }

    afk := afkCondition()
    proc := ""
    while (proc == "")
    {
        try
        {
            win := WinGetID("A")
            proc := codebase.stringOperations.strEllipsize(WinGetTitle("ahk_id " . win), 40) . "`n" . WinGetProcessName("ahk_id " . win)
        }
    }

    if (afk == false)
    {
        str := "Current process CANNOT satisfy:`n" . proc
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }

        str := "Inactive in current process"
        if (state.Value !== str)
        {
            state.Value := str
        }

        ticks := 0
        oldAfkTick := A_TickCount
    }
    else if (afk == true)
    {
        str := "Current process CAN satisfy:`n" . proc
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }

        str := "Ready"
        if (state.Value !== str)
        {
            state.Value := str
        }

        ticks := 0
        oldAfkTick := A_TickCount
    }
    else
    {
        str := "SATISFIED by current process:`n" . proc
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }
        if (ticktimer.Value !== A_TickCount - oldAfkTick)
        {
            ticktimer.Value := A_TickCount - oldAfkTick
        }

        if (A_TickCount - oldAfkTick > 10000)
        {
            str := "Sending inputs..."
            if (state.Value !== str)
            {
                state.Value := str
            }

            ticks++
            sendAfk(afk)
            oldAfkTick := A_TickCount
        }
        else
        {
            str := "Ready"
            if (state.Value !== str)
            {
                state.Value := str
            }
        }
    }

    if (WinExist("ahk_exe RobloxPlayerBeta.exe"))
    {
        if (WinActive("ahk_exe RobloxPlayerBeta.exe"))
        {
            col := PixelGetColor(2985, 1903)
            for c in ["0xF09D59", "0xF1A363", "0xF1A161", "0xF1A262", "0xF1A160"]
            {
                if (col == c)
                {
                    Click("3000 1903")
                }
            }

            robloxWasActive := 0
            str := codebase.formatMilliseconds(0, true, 1)
            if (robloxAfk.Value !== str)
            {
                robloxAfk.Value := str
            }
        }
        else
        {
            if (robloxWasActive == 0)
            {
                robloxWasActive := A_TickCount
            }
            robloxAfk.Value := codebase.formatMilliseconds(A_TickCount - robloxWasActive, true, 1)

            if (A_TickCount - robloxWasActive >= 1000 * 60 * 18)
            {
                try
                {
                    WinActivate(roblox)
                    WinWaitActive(roblox)
                    sendAfk("RobloxPlayerBeta.exe")
                    robloxWasActive := 0
                    str := codebase.formatMilliseconds(0, true, 1)
                    if (robloxAfk.Value !== str)
                    {
                        robloxAfk.Value := str
                    }
                }
            }
        }
    }
    else
    {
        robloxWasActive := 0
        str := codebase.formatMilliseconds(0, true, 1)
        if (robloxAfk.Value !== str)
        {
            robloxAfk.Value := str
        }
    }
    
    ; Monitors
    /* DISABLED UNTIL IT WORKS CORRECTLY
    static dontmove, winlist
    old := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    dontmove := false
    winlist := WinGetList()
    if (winlist.Length !== (new := WinGetList()).Length)
    {
        winlist := new

        for win in winlist
        {
            ; If a window's client width and height are the monitor's resolution, it's a game running in Fullscreen or Windowed Borderless
            try
            {
                WinGetClientPos(, , &w, &h, win)
                if (WinActive(win) && w == 3840 && h == 2160)
                {
                    dontmove := true
                }
            }
        }
    }
    if (y >= 1080 && y !== 2159 && (x == 0 || x == 3839))
    {
        if (!dontmove)
        {
            MouseMove(x, y / 2, 0)
        }
    }
    CoordMode("Mouse", old)
    */

    ; Dead By Daylight progress bar monitor
    static dbdprev := "0.00"
    static dbd_ttid_1 := 19
    static dbd_ttid_2 := 20
    static dbd_ttid := dbd_ttid_1
    if (WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe"))
    {
        if (true || PixelSearch(&cx, &cy, 1599, 1731, 1599, 1731, "0xFFFFFF", 10) || PixelSearch(&cx, &cy, 1921, 1718, 1921, 1718, "0x1B2121", 10)) ; White hand next to progress bar || Border progress bar
        {
            if (PixelSearch(&cx, &cy, 1671, 1735, 2262, 1735, "0x3C4347", 20))
            {
                ; (cx, cy) is the left-most pixel of the progress bar that is _not_ filled
                percent := Round((100 * (cx - 1671)) / 591, 2)
                c := [
                    Round((80 * (cx - 1671)) / 591, 2) . "/80`t(Generator)",
                    Round((20 * (cx - 1671)) / 591, 2) . "/20`t(Exit Gate)",
                    Round((16 * (cx - 1671)) / 591, 2) . "/16`t(Heal)",
                    Round((14 * (cx - 1671)) / 591, 2) . "/14`t(Totem)"
                ]
                if (percent !== dbdprev)
                {
                    dbdprev := percent
                    ToolTip( , , , (dbd_ttid == dbd_ttid_1 ? dbd_ttid_2 : dbd_ttid_1))
                    ToolTip(codebase.stringOperations.strJoin("`n", , c*) "`n" . percent . "%" , cx, 1735 + 20, (dbd_ttid == dbd_ttid_1 ? dbd_ttid := dbd_ttid_2 : dbd_ttid := dbd_ttid_1))
                }
            }
        }
    }
    else
    {
        ToolTip( , , , (dbd_ttid == dbd_ttid_1 ? dbd_ttid_2 : dbd_ttid_1))
    }

    /*
    static r6prev := "0.00"
    static r6_ttid_1 := 17
    static r6_ttid_2 := 18
    static r6_ttid := r6_ttid_1
    static r6_radiussubconst := 3
    static indices := codebase.range(-86, 270, 4)
    static colors := {
        mi: SubStr(codebase.convert.colors.variation("0xCA1415", 30)[1], 1, 8),
        rf: "0xCA1415",
        ma: SubStr(codebase.convert.colors.variation("0xCA1415", 30)[2], 1, 8)
    }
    if (WinActive("ahk_exe RainbowSix.exe") || WinExist("ahk_exe vlc.exe"))
    {
        if (true)
        {
            for j in indices
            {
                searchx := 1920 + ((41 - r6_radiussubconst) * Cos((j / 360) * 2 * codebase.math.constants.pi))
                searchy := 72 + ((42 - r6_radiussubconst) * Sin((j / 360) * 2 * codebase.math.constants.pi))
                ToolTip((c := PixelGetColor(searchx, searchy)), searchx, searchy, 12)

                if (c == "0x767676")
                {
                    continue
                }
                if (codebase.convert.colors.exclusiveCompare(c, "0xeeeeee"))
                {
                    timeleft := Round(45 * ((356 - (j + 90)) / 356), 2)
                    OutputDebug(timeleft . "sec`n")
                    if (timeleft !== r6prev)
                    {
                        r6prev := timeleft
                    }
                    break
                }
            }
        }
    }
    else
    {
        ToolTip( , , , (r6_ttid == r6_ttid_1 ? r6_ttid_2 : r6_ttid_1))
    }
    */
}

disClick(obj, *)
{
    global

    ticks := 0
    oldAfkTick := A_TickCount

    if (!(doTick := !(obj.Value)))
    {
        str := "Script functionality disabled`nUncheck the box to re-enable"
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }
    }
}

functions()
{
    global

    ahkproc := []
    for p in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
    {
        ; https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process?redirectedfrom=MSDN
        if (InStr(p.Name, "AutoHotkey"))
        {
            ahkproc.Push(p.CommandLine)
        }
    }
    for cl, c in codebase.collectionOperations.arrayOperations.arrayIndex(ahkproc)
    {
        ; More than one identical process exists! -> reahk!
        if (c >= 3)
        {
            SplitPath(A_ScriptFullPath, , &dir, , , &drv)
            f := FileOpen('reAhk.bat', "w")
            f.Write(drv . "`ncd " . dir . "`ntaskkill /f /im autohotkey64.exe`n`nstart AutoCorrect.ahk`nstart Loops.ahk")
            f.Close()
            Run('reAhk.bat')
        }
    }

    if (WinExist("ahk_exe csgo.exe"))
    {
        c := PixelGetColor(1987, 828)
        if (c == "0x5ACB5E" || c == "0x4CAF50" || c == "0x439246")
        {
            Click("1987 828")
        }
    }

    if (WinExist("ahk_exe msedge.exe"))
    {
        WinKill("ahk_exe msedge.exe")
    }

    if (WinActive("Shut Down Windows"))
    {
        if (MsgBox("Hibernate?", , 0x4) == "Yes")
        {
            DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
        }
    }

    if WinExist("ahk_exe FortniteClient-Win64-Shipping.exe")
    {
        while (RunWait('sc stop kprocesshacker3') !== 1060)
        {
            Sleep(1000)
        }
    }

    if (WinExist("R6 Analyst - Multi Monitor page"))
    {
        WinShow("R6 Analyst - Multi Monitor page")
    }

    if (WinExist("ahk_exe RainbowSix.exe"))
    {
        if (!ProcessExist("CrossOver.exe"))
        {
            Run("C:\Users\User\AppData\Local\Programs\crossover\CrossOver.exe")
            Sleep(10000)
            return
        }
    }

    readOnlyFiles := [
        "C:\Users\User\Documents\My Games\Rainbow Six - Siege\51e0474f-7c98-4afc-902b-8c1367f823d0\GameSettings.ini",
        "C:\Users\User\Documents\EA Games\Mirror's Edge\TdGame\Config\TdEngine.ini"
    ]
    for f in readOnlyFiles
    {
        if (!InStr(FileGetAttrib(f), "R"))
        {
            FileSetAttrib("+R", f)
        }
    }

    if (WinExist("ahk_exe Rocksmith2014.exe"))
    {
        if (!WinExist("Cheat Engine"))
        {
            if (!dodgedCE)
            {
                doDodge := false
                for w in rsDodgeCEtriggers
                {
                    if (WinExist(w))
                    {
                        doDodge := true
                    }
                }

                if (doDodge)
                {
                    MsgBox("One or more processes that don't want Cheat Engine running are currently open. CE will not be launched.")
                    dodgedCE := true
                }
                else
                {
                    dodgedCE := false

                    celoop:
                    Run("E:\Programs\Cheat Engine 7.2\cheatengine-x86_64-SSE4-AVX2.exe", "E:\Programs\Cheat Engine 7.2")
                    Sleep(2500)

                    if (!WinExist("Cheat Engine") || MsgBox("Did Cheat Engine start correctly?", "Correct CE startup", "0x4 T5") == "No")
                    {
                        goto celoop
                    }
                    else
                    {
                        PostMessage(0x0112, 0xF020, , , "Cheat Engine")
                    }
                }
            }
            else
            {
                if (codebase.collectionOperations.andFunc(WinExist, rsDodgeCEtriggers*))
                {
                    dodgedCE := false
                    doDodge := false
                }
            }
        }

        if (!WinExist("ahk_exe RockSniffer.exe"))
        {
            rsnloop:
            Run("E:\Programs\RockSniffer 0.3.4\RockSniffer.exe", "E:\Programs\RockSniffer 0.3.4")
            Sleep(2500)

            if (!WinExist("ahk_exe RockSniffer.exe") || MsgBox("Did RockSniffer start correctly?", "Correct RockSniffer startup", "0x4 T5") == "No")
            {
                goto rsnloop
            }
            else
            {
                PostMessage(0x0112, 0xF020, , , "ahk_exe RockSniffer.exe")
            }

            try
            {
                WinActivate("Rocksmith")
            }
        }

        rsExists := true
    }
    else
    {
        if (rsExists)
        {
            if (MsgBox("Lost track of Rocksmith's process. Kill CE?", "RS closed", 4) == "Yes")
            {
                if (!dodgedCE)
                {
                    try
                    {
                        ProcessClose(WinGetPID("Cheat Engine"))
                    }
                }
                
                try
                {
                    ProcessClose(WinGetPID("ahk_exe RockSniffer.exe"))
                }
            }

            rsExists := false
            doDodge := false
            dodgedCE := false
        }
    }

    if (olExists && !WinExist("ahk_exe outlook.exe"))
    {
        olExists := false

        Run(A_ComSpec . ' /c taskkill /f /im outlook.exe')
    }
    else
    {
        if (WinExist("ahk_exe outlook.exe"))
        {
            olExists := true
        }
    }

    /*
    if (WinActive("ahk_exe vlc.exe"))
    {
        try
        {
            WinGetPos(&x, &y, &w, &h, "ahk_exe vlc.exe")
            if (w !== 1600 || h !== 900)
            {
                WinMove(x, y, 1600, 900, "ahk_exe vlc.exe")
            }
        }
    }
    */

    if (WinExist("ahk_exe sndvol.exe"))
    {
        try
        {
            WinGetPos(&searchx, &searchy, &w, &h, "ahk_exe sndvol.exe")
            if (w < 3000)
            {
                WinMove(searchx, searchy, 3000, h, "ahk_exe sndvol.exe")
            }
        }
    }

    if (WinActive("ahk_group lock"))
    {
        if (lock)
        {
            MouseMove(A_ScreenWidth / 2, A_ScreenHeight / 2, 0)
        }
    }

    if (WinActive("ahk_group noCaps"))
    {
        while (GetKeyState("CapsLock", "T") && !GetKeyState("CapsLock", "P"))
        {
            SetCapsLockState(false)
        }
    }

    if (WinExist("Steam - News"))
    {
        try
        {
            WinClose("Steam - News")
        }
    }
}

slowMonitor()
{
    op := FileRead("C:\Users\User\Desktop\Share\remote.txt")
    switch (op)
    {
        case "overwatch":
            Run("C:\Users\User\Documents\Gayms\Overwatch.lnk")
    }
    FileOpen("C:\Users\User\Desktop\Share\remote.txt", "w")
}

discordThemeUpdate()
{
    try
    {
        theme := FileRead("C:\Users\User\AppData\Roaming\BetterDiscord\themes\Black Minimalistica.theme.css")
        s := InStr(theme, '`t--background-image: /* AHK */')

        theme := FileOpen("C:\Users\User\AppData\Roaming\BetterDiscord\themes\Black Minimalistica.theme.css", "rw")
        line := '`t--background-image: /* AHK */ url("{url}");`r`n}'
        codebase.stringOperations.strComposite(&line, { url: codebase.requests.parseJson(FileRead("E:\YOUTUBE\ETC DATA\Snip\Snip_Metadata.json"))["album"]["images"][1]["url"] })

        theme.Seek(s - 1, 0)
        theme.Write(line)
        theme.Close()
    }
}

#HotIf WinActive("ahk_group lock")
F9::
{
    global
    codebase.Tool(lock := !lock, codebase.Tool.center, 500)
}

; Autorun

GroupAdd("lock", "Sea of Thieves ahk_exe ApplicationFrameHost.exe")
;GroupAdd("lock", "ahk_exe RainbowSix.exe")

GroupAdd("noCaps", "ahk_exe RainbowSix.exe")
GroupAdd("noCaps", "ahk_exe r5apex.exe")

ProcessSetPriority("BelowNormal")

oldAfkTick := A_TickCount
ticks := 0
requiredIdleTime := 15000
doTick := true

roblox := "Roblox ahk_exe RobloxPlayerBeta.exe"

triggers := [
    "ahk_exe RainbowSix.exe",
    "ahk_exe KnockoutCity.exe",
    ; "ahk_exe GTA5.exe",
    "ahk_exe csgo.exe",
    "ahk_exe VALORANT-Win64-Shipping.exe",
    "ahk_exe bf1.exe",
    "ahk_exe RobloxPlayerBeta.exe",
    "ahk_exe Rocksmith2014.exe",
    "Sea of Thieves",
    ;"Notepad"
]

rsDodgeCEtriggers := [
    "ahk_exe VALORANT-Win64-Shipping.exe",
    "ahk_exe RobloxPlayerBeta.exe",
    "ahk_exe csgo.exe"
]

rsExists := 0
rsAsk := true

dodgedCE := 0

olExists := 0

lock := 1

csBombTimerActive := false
csBombTimerEnd := 0

; AFK GUI
elemWidth := 300
afkgui := Gui("AlwaysOnTop", "AFK GUI")
afkgui.Add("Text", "", "A_TimeIdlePhysical:")
idletime := afkgui.Add("Edit", "ReadOnly r2 w" . elemWidth, "")

afkgui.Add("Text", "", "Completed ticks:")
compticks := afkgui.Add("Edit", "ReadOnly w" . elemWidth, "")

afkgui.Add("Text", "", "Tick timer:")
ticktimer := afkgui.Add("Edit", "ReadOnly w" . elemWidth, "")

afkgui.Add("Text", "", "Script state:")
state := afkgui.Add("Edit", "ReadOnly w" . elemWidth, "")

afkgui.Add("Text", "", "AFK condition:")
afkCond := afkgui.Add("Edit", "ReadOnly w" . elemWidth . " r3", "")

afkgui.Add("Text", "", "Roblox inactivity:")
robloxAfk := afkgui.Add("Edit", "ReadOnly w" . elemWidth . " r2", "")

tempdis := afkgui.Add("CheckBox", "", "Temporarily disable script functionality")
tempdis.OnEvent("Click", disClick)

windowList := afkgui.Add("ListBox", "ReadOnly w" . elemWidth . " r" . triggers.Length, triggers)

editBtn := afkgui.Add("Button", "w" . elemWidth, "Edit")
editBtn.OnEvent("Click", (*) => Edit())
editBtn := afkgui.Add("Button", "w" . elemWidth, "Reload")
editBtn.OnEvent("Click", (*) => Reload())

afkgui.Show("X-1915 Y5 NoActivate Hide")

; Clipboard GUI
timerSet := true
clipgui := Gui("AlwaysOnTop", "Clipboard GUI")
clp := clipgui.Add("Edit", "WantReturn WantTab +VScroll -HScroll r" . 35 - triggers.Length . " w700", "")
clp.OnEvent("Focus", clp_Change)
clp.OnEvent("LoseFocus", (*) => updateTxt())
clp_Change(*)
{
    global

    SetTimer(clipFetch, 0)
    timerSet := false
    updateTxt()
}

txt := clipgui.Add("Text", "w700")
loseFocusOnCtrlC := clipgui.Add("CheckBox", "Checked", "Take focus on Ctrl+C or Ctrl+X")
updateTxt()
loseFocusOnCtrlC.OnEvent("Click", (*) => updateTxt())

clpbtn := clipgui.Add("Button", "w700", "Reset timer and CHANGE clipboard")
clpbtn.OnEvent("Click", (*) => clpbtn_Click(true))
clpbtn := clipgui.Add("Button", "w700", "Reset timer and DISCARD changes")
clpbtn.OnEvent("Click", (*) => clpbtn_Click(false))
clpbtn_Click(changeClip)
{
    global

    if (changeClip)
    {
        A_Clipboard := clp.Value
    }
    SetTimer(clipFetch, 10, 1)
    timerSet := true
    updateTxt()
}

updateTxt()
{
    global

    txt.Value := "Clipboard edit field " . (!timerSet ? "HAS" : "has NO") . " focus.`t`t`tCtrl-C / Ctrl-X " . (loseFocusOnCtrlC.Value ? "TAKES" : "DOES NOT take") . " focus from the text field."
}

clipFetch()
{
    global

    if (clp.Value != A_Clipboard)
    {
        clp.Value := A_Clipboard
    }
}

afkgui.GetPos(&searchx, &searchy, &w, &h)
clipgui.Show("X-1915 Y" . searchy + h + 5 . " NoActivate Hide")

shgui := Gui( , "Show/Hide GUI")

shafk := shgui.Add("Button", "w150", "Show AFK GUI")
shafk.OnEvent("Click", shafk_Click)
shafk_Click(*)
{
    global

    if (afkshown)
    {
        afkgui.Hide()
        afkshown := false
        shafk.Text := "Show AFK GUI"
    }
    else
    {
        afkgui.Show("NoActivate")
        afkshown := true
        shafk.Text := "Hide AFK GUI"
    }
}

shclip := shgui.Add("Button", "wp", "Show Clipboard GUI")
shclip.OnEvent("Click", shclip_Click)
shclip_Click(*)
{
    global

    if (clipshown)
    {
        clipgui.Hide()
        clipshown := false
        shclip.Text := "Show Clipboard GUI"
    }
    else
    {
        clipgui.Show("NoActivate")
        clipshown := true
        shclip.Text := "Hide Clipboard GUI"
    }
}

afkshown := false
clipshown := false
shgui.Show("X" . searchx + w + 5 . "Y5 NoActivate")

codebase.Tool("Reloaded Loops.ahk", true, , , 50)

if ((f := codebase.directoryOperations.getNewest("E:\YOUTUBE\Captures\Tom Clancy's Rainbow Six  Siege", true, "*.vpj")) !== "")
{
    SplitPath(f, , &dir)
    FileCreateShortcut(f, "C:\Users\user\Desktop\proj.lnk", dir)
}

prio_base := 0
prio_elv := 1
SetTimer(slowMonitor, 10000, prio_elv)
SetTimer(discordThemeUpdate, 2500, prio_base)
SetTimer(functions, 70, prio_base)
SetTimer(clipFetch, 1000, prio_base)
SetTimer(millisecondMonitor, 1, prio_base)

#HotIf loseFocusOnCtrlC.Value
~^c::
~^x::
{
    clipFetch()
    clpbtn_Click(false)
    updateTxt()
}