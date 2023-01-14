# Simple CUI wrapper for Choosenim command
# modified: 2023/01
# modified: 2022/11,12
# modified: 2021/10
# first: made by audin 2021/01
#
# Required:
#     nim-0.19.6 or later minimum requested. Not colorized.
#     nim-1.4.0  or later recommended. Colorized.
#
import std/[os, strutils, terminal, osproc, strformat]

const VERSION {.strdefine.}: string = "ERROR:unkonwn version"
const REL_DATE {.strdefine.}: string = "ERROR:unkonwn release date"

# In case not existing NimvConfName,use edge versions as default.
const tblOldVersions = [("1.6.10", "2022-11-21"),
                        ("1.6.8", "2022-05-05"),
                        ("1.4.8", "2021-05-25"),
                        ("1.2.18", "2022-02-09"),
                        ("1.0.10", "2020-10-26")]

# Dose terminal library have Color attributes ?
when (NimMajor, NimMinor, NimPatch) >= (1, 4, 0):
    import std/exitprocs
    exitprocs.addExitProc(resetAttributes)
    const HAVE_COLOR = true
else:
    const HAVE_COLOR = false

when defined(windows):
    const Choosenim = "choosenim.cmd"
else:
    const Choosenim = "choosenim"

const NimvConfName = ".nimv.json"
const MaxItems = 20

type
    Action = enum
        update, remove

    NimVer = object
        enabled: bool
        ver: string
        selected: bool
        compiledDate: string
        devVer: string

let sHelp = """
nimv $# ($#): Simple CUI wrapper for Choosenim command.
              from 2021/10 by audin
Usage:
    nimv [option]
       option:
            None : Show simple CUI for Choosenim.
            -h, /?, /h, -v, --version: Show this page.
            -d: Start nimv with debug mode. Shown choosenim command.
    $#: List of old nim versions and configration file to nimv.
                It can be set show/hide to list up the specified nim version.
                This file can be placed in user home folder.""" % [VERSION, REL_DATE, NimvConfName]
var
    seqOldVers, seqInstalledVers: seq[NimVer]
    sMsgUpdateDevel: string # Not used at this time
    # Over written by value within ".nimv.json"
    sChoosenimDir, sNimbleDir: string
    fDebug = false
    fDispChoosenimDirAndNimbleDir = false

proc echoColored(str: string, clFg: ForegroundColor = fgWhite, newline: bool = true) =
    when HAVE_COLOR:
        setForegroundColor(clFg, bright = true)
        if newline: echo str else: stdout.write str
        stdout.resetAttributes()
    else:
        if newline: echo str else: stdout.write str

proc getVerInfo(sVer: string): (bool, bool, string) = # return (result,enabled,compiledDate)
    for obj in seqOldVers:
        if sVer == obj.ver:
            return (true, obj.enabled, obj.compiledDate)

proc updateInstalledVer(seqOutput: seq[string]) =
    seqInstalledVers.setLen(0) # オールクリアで作り直す
    var state = 0
    for line in seqOutput: # Showコマンドの結果出力
        case state
        of 0:
            if line.contains("Versions:"):
                inc state
        of 1:
            let ary = line.strip.split(' ')
            if ary.len >= 2: # has '*' mark at ary[0]
                let sVer = ary[1]
                let (_, _, sDate) = getVerInfo(sVer)
                seqInstalledVers.add NimVer(ver: sVer, selected: true, compiledDate: sDate)
            elif (ary.len == 1) and (ary[0].len > 0): # not have '*' mark
                let sVer = ary[0]
                let (_, _, sDate) = getVerInfo(sVer)
                seqInstalledVers.add NimVer(ver: ary[0], compiledDate: sDate)
        else: discard
    if state == 0: # 1つしかインストールされていない時
        let sVer = seqOutput[0].strip.split(' ')[1] # 1行目の2項目に選択バージョン番号がある
        if sVer == "":
            echoColored "ERROR !!: Fail get version in updateInstalledVer()", fgRed
            quit 1
        let (_, _, sDate) = getVerInfo(sVer)
        seqInstalledVers.add NimVer(ver: sVer, selected: true, compiledDate: sDate)
    #
    for i, obj in seqInstalledVers:
        if obj.ver.contains("#"): # "#devel"だとバージョン番号が不明なので取得 orz
            if obj.selected:
                let (sOut, erCode) = execCmdEx("nim --version", options = {poStdErrToStdOut, poUsePath})
                if erCode == 0:
                    let devVer = sOut.splitLines()[0].strip.split(' ')[3] # 1行目 nimバージョン取得
                    let date = sOut.splitLines()[1].strip.split(' ')[2] # 2行目 Compiled date 取得
                    seqInstalledVers[i].devVer = devVer
                    seqInstalledVers[i].compiledDate = date
                break

proc getDirOptions(): string =
    if "" != sChoosenimDir:
        result = " --choosenimDir:\"$#\" " % [sChoosenimDir]
    if "" != sNimbleDir:
        result &= " --nimbleDir:\"$#\" " % [sNimbleDir]

proc getFullCmd(cmdMain: string): string = [Choosenim, getDirOptions(), cmdMain].join(" ")

proc echoDebug(str: string) =
    if fDebug: echoColored(str, fgRed)

proc execCmdSilent(cmd: string): (int, string) {.discardable.} =
    echoDebug "[ $# ] in execCmdSilent()" % [cmd]
    let (sOut, erCode) = execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath})
    return (erCode, sOut)

when false: # not used at this time
    proc checkUpdateDevel(): string {.used.} =
        let (erCode, sOut) = execCmdSilent(getFullCmd("--noColor versions --installed"))
        if erCode == 0:
            for line in sOut.splitLines():
                if line.contains("update available"):
                    return line.strip

proc updateActiveVer(): (bool, string) {.discardable.} =
    let (erCode, sOut) = execCmdSilent(getFullCmd("--noColor show"))
    if erCode == 0:
        updateInstalledVer(sOut.splitLines()) # 全行渡す
        result = (true, sOut)
    else:
        result = (false, "0[ERROR]: " & sOut)

proc choosenim(cmd: string): bool =
    let sCmd = getFullCmd(cmd)
    echoDebug "[ $# ] in choosenim()" % [sCmd]
    if 0 == execCmd(sCmd):
        updateActiveVer()
        result = true

proc getListNumber(ch: char): int =
    if ch >= '0' and ch <= '9': ch.ord - '0'.ord
    elif ch >= 'a' and ch <= 'j': ch.ord - 'a'.ord + 10
    else: -1

proc getListNumchar(i: int): char =
    if i > 9: ('0'.ord + i + 7).chr else: ('0'.ord + i).chr

proc showActionMenu(act: Action): seq[NimVer] =
    let sAct = if act == Action.update: "Installable" else: "Deletable"
    let str = fmt"{sAct:>11}"
    echoColored "   .-------------------------------------------."
    echoColored "   | $# versions, select number       |" % [str], if act == Action.update: fgYellow else: fgRed
    echoColored "   `-------------------------------------------'"
    case act
    of Action.update:
        for oldVerObj in seqOldVers:
            if not oldVerObj.enabled: continue
            var fSame = false
            for installedVerObj in seqInstalledVers:
                if oldVerObj.ver == installedVerObj.ver:
                    fSame = true
                    break
            if not fSame:
                result.add oldVerObj
    of Action.remove:
        for installedVerObj in seqInstalledVers:
            if not installedVerObj.selected:
                result.add installedVerObj
    for i, obj in result:
        if i >= MaxItems:
            echoColored "Restricted to max {MaxItems} items"
            break
        let cNum = getListNumchar(i)
        echo &"    [{cNum}]  nim-{obj.ver}"

    echo "    ---"
    echo "    [M] Back to top menu (or [R])"
    echo "    [Q] Exit (or [Enter])"

proc dispatchActionMenu(act: Action): bool =
    result = true
    while true:
        let seqNewNimVers = showActionMenu(act)
        let ch = getch()
        if ch == '\r' or ch == 'q':
            quit 0
        if ch == 'r' or ch == 'm':
            return true
        let num = getListNumber(ch)
        if num >= 0 and num < seqNewNimVers.len:
            var sVer = seqNewNimVers[num].ver
            let res = sVer.contains("#")
            if res and (act == Action.update):
                let messages = "This may take much time !\nUpdate Devel version ? y/[n]:"
                echoColored(messages, fgYellow)
                if getch() != 'y':
                    return
            if act == Action.remove:
                sVer = "\"" & sVer & "\"" # for Linux: orz
            result = choosenim($act & " " & sVer)

proc dispatchTopMenu(ch: char): bool =
    case ch
    of '\r', 'q':
        quit 0
    of 'u': # Install stable version
        result = choosenim("update stable")
    of 'p':
        let messages = "This may take much time !\nUpdate Devel version ? y/[n]:"
        echoColored(messages, fgYellow)
        result = true
        if getch() == 'y':
            result = choosenim("update devel")
    of 'l':
        result = dispatchActionMenu(Action.update) #
    of 'r':
        result = dispatchActionMenu(Action.remove)
    else:
        result = true
        let num = getListNumber(ch)
        if num >= 0 and num < seqInstalledVers.len:
            result = choosenim(seqInstalledVers[num].ver.strip(chars = {'#'}))

proc showTopMenu() =
    echo " .-----------------------."
    echoColored " || Installed versions  ||", fgCyan
    echo " `-----------------------'"
    for i, installedVerObj in seqInstalledVers:
        if i >= MaxItems:
            echoColored &"Restricted to max {MaxItems} items"
            break
        let cNum = getListNumChar(i)
        let sBase = &"  [{cNum}]  nim-{installedVerObj.ver:<7}"
        let sCompileDate =
            if "" != installedVerObj.compiledDate: &"  ({installedVerObj.compiledDate})"
            else: ""
        if installedVerObj.selected:
            echoColored(sBase & " *", fgGreen, false)
            if installedVerObj.devVer != "":
                stdout.write sCompileDate
                echo " v", installedVerObj.devVer
            else:
                echo sCompileDate
        else:
            stdout.write sBase
            echo "  ", sCompileDate

    echo "    Select number you'd like to change Nim version."
    echo "    *: Active version."
    echo """  ---
  [L] [L]ist and install other Nim versions
  [U] [U]pdate to stable version
  [P] U[p]date devel version (nim-#devel)"""
    if "" != sMsgUpdateDevel: echoColored("        " & sMsgUpdateDevel, fgYellow)
    echo """
  [R] [R]emove Nim versions
  [Q] Exit (or [Enter])"""

import json
proc main() =
    if "" == findExe(Choosenim): # Check choosenim
        echoColored("Cannot find 'choosenim' command, install it refering to", fgRed)
        echoColored("https://github.com/dom96/choosenim", fgYellow)
        quit 1
    # For command line
    var arg1 = ""
    if paramCount() >= 1:
        case paramStr(1)
        of "--help", "-h", "/?", "/h", "-v", "--version": # Show Help
            echo(sHelp % [VERSION, REL_DATE])
            quit 0
        #
        arg1 = commandLineParams()[0]
        try:
            discard parseInt(arg1)
        except ValueError:
            if arg1 == "-d":
                fDebug = true
            else:
                # Pass all parameters to chooseim and execute choosenim
                if false == choosenim(commandLineParams().join(" ")):
                    let _ = choosenim("show")
                quit 0
        if not fDebug:
            updateActiveVer()
            discard dispatchTopMenu(arg1[0]) # Specifiy a number to activate the version
            quit 0

    #### Read conf file (NimvConfName)
    let p = getHomeDir().splitFile()
    let confPathName = joinPath(p.dir, NimvConfName)
    if confPathName.fileExists:
        stdout.write "[ $# ]" % [confPathName]
        echoColored " Loaded", fgYellow
        # Read Json data
        var jnode: JsonNode
        try:
            jnode = parseJson(readfile(confPathName))
        except JsonParsingError as e:
            echoColored "Error! :Json parsing " & e.msg, fgRed
            echo "  $#" % [confPathName]
            quit 1
        # Get debug option
        fDebug = jnode["debugMode"].getBool
        # Make oldVersion object list
        for jElm in jnode["oldVers"].items:
            let bEn = if 1 == jElm["enable"].getInt: true else: false
            seqOldVers.add NimVer(enabled: bEn,
                                  ver: jElm["ver"].getStr,
                                  compiledDate: jElm["date"].getStr)
        # Get "--choosenimDir option"
        fDispChoosenimDirAndNimbleDir = jnode["dispChoosenimDirAndNimbleDir"].getBool
        sChoosenimDir = jnode["choosenimDir"].getStr
        if "" != sChoosenimDir:
            if dirExists sChoosenimDir:
                if fDispChoosenimDirAndNimbleDir:
                    stdout.write &"[ {sChoosenimDir} ]"
                    echoColored " => choosenimDir", fgYellow
            else:
                echoColored "ERROR: Not found [$#] => choosenimDir" % [sChoosenimDir], fgRed
                sChoosenimDir = ""
        # Get "--nimbleDir option"
        sNimbleDir = jnode["nimbleDir"].getStr
        if "" != sNimbleDir:
            if dirExists sNimbleDir:
                if fDispChoosenimDirAndNimbleDir:
                    stdout.write &"[ {sNimbledir} ]"
                    echoColored " => nimbleDir", fgYellow
            else:
                echoColored "ERROR: Not found [$#] => nimbleDir" % [sNimbleDir], fgRed
                sNimbleDir = ""
    else:
        echo "[ $# ] Not exists" % [confPathName]
        for tpVer in @tblOldVersions:
            seqOldVers.add NimVer(enabled: true, ver: tpVer[0], compiledDate: tpVer[1])
    # set debug mode
    if arg1 == "-d": fDebug = true
    if fDebug:
        echoColored "Nimv v$#" % [VERSION],fgYellow
        stdout.write "[ $# ]" % [os.getAppFilename()]
        echoColored " Running", fgYellow
    #
    let (fRes, sRes) = updateActiveVer()
    if fRes == false:
        echo sRes
        quit 1
    # Start CUI
    while true:
        #sMsgUpdateDevel = checkUpdateDevel()
        showTopMenu()
        if false == dispatchTopMenu(getch()): # Stop here until input one char
            echoColored "\n\n ERROR !! : Main loop", fgRed

when isMainModule:
    main()

