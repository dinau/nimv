# Simple version selector for Nim using choosenim
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

const VERSION {.strdefine.} = "1.3.0" #"ERROR:unkonwn version"
const REL_DATE {.strdefine.} = "2023/01" #"ERROR:unkonwn release date"

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

type
    Action = enum
        update, remove

    NimVer = object
        ver:string
        active:bool
        compiledDate:string
        devVer:string


let sHelp = """
nimv $# ($#): Simple CUI wrapper for Choosenim command.
              from 2021/10 by audin
Usage:
    nimv [Option]
       Option:
            None : Show simple CUI for Choosenim.
            -h, /?, /h, -v, --version: Show thispage.
    .nimv.list: List of old nim versions.
                It can be set show/hide to list up nim version.
                This file can be placed in user home folder."""
var
    seqOldVers: seq[NimVer]
    seqInstalledVers: seq[NimVer]
    # Over written by the values within ".nimv.json"
    fDebug = false
    fDispChoosenimAndNimbleDir = false
    sChoosenimDir:string
    sNimbleDir:string

proc echoColored(str:string,clFg:ForegroundColor = fgWhite,newline:bool = true) =
    when HAVE_COLOR:
        setForegroundColor(clFg, bright = true)
        if newline: echo str else: stdout.write str
        stdout.resetAttributes()
    else:
        if newline: echo str else: stdout.write str

proc updateInstalledVer(seqOutput: seq[string]) =
    seqInstalledVers.setLen(0) # オールクリアで作り直す
    var state = 0
    for line in seqOutput:
        case state
        of 0:
            if line.contains("Versions:"):
                inc state
        of 1:
            let ary = line.strip.split(' ')
            if ary.len >= 2: # has '*' mark at ary[0]
                seqInstalledVers.add NimVer(ver:ary[1],active:true)
            elif (ary.len == 1) and (ary[0].len > 0): # not have '*' mark
                seqInstalledVers.add NimVer(ver:ary[0])
        else: discard
    if state == 0: # 1つしかインストールされていない時
        let sVer = seqOutput[0].strip.split(' ')[1] # 1行目の2項目に選択バージョン番号がある
        if sVer == "":
            echo "ERROR !!: Fail get version in updateInstalledVer()"
            quit 1
        seqInstalledVers.add NimVer(ver:sVer,active:true)
    #
    let (sOut, erCode) = execCmdEx("nim --version", options = {poStdErrToStdOut, poUsePath})
    if erCode == 0:
        let date = sOut.splitLines()[1].strip.split(' ')[2]
        let devVer = sOut.splitLines()[0].strip.split(' ')[3]
        for i,obj in seqInstalledVers:
            if obj.active:
                seqInstalledVers[i].compiledDate = date
                if obj.ver.contains("#"):
                    seqInstalledVers[i].devVer = devVer
                break

proc updateActiveVer(): (bool, string) {.discardable.} =
    var seqCmd:seq[string] = @[]
    seqCmd.add Choosenim
    if "" != sChoosenimDir:
        seqCmd.add("--choosenimDir:\"$#\"" % [sChoosenimDir])
    if "" != sNimbleDir:
        seqCmd.add("--nimbleDir:\"$#\"" % [sNimbleDir])
    seqCmd.add(" --noColor " & "show")
    let cmd = seqCmd.join(" ")
    if fDebug: echo "[[$#]] in updateActiveVer()" % [cmd]
    let (sOut, erCode) = execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath})
    if erCode == 0:
        updateInstalledVer(sOut.splitLines()) # 全行渡す
        result = (true, sOut)
    else:
        result = (false, "0[ERROR]: " & sOut)

proc choosenim(argments: openArray[string]): bool =
    var seqCmd:seq[string] = @[]
    seqCmd.add Choosenim
    if "" != sChoosenimDir:
        seqCmd.add("--choosenimDir:\"$#\"" % [sChoosenimDir])
    if "" != sNimbleDir:
        seqCmd.add("--nimbleDir:\"$#\"" % [sNimbleDir])
    let cmd = [seqCmd.join(" "),argments.join(" ")].join(" ")
    if fDebug: echo "[[$#]] in choosenim()" % [cmd]
    if 0 == execCmd(cmd):
        updateActiveVer()
        result = true

proc showActionMenu(act: Action): seq[NimVer] =
    let sAct = if act == Action.update: "Installable" else: "Deletable"
    let str = fmt"{sAct:>11}"
    echoColored "   .-------------------------------------------."
    echoColored "   | $# versions, select number       |" % [str],if act == Action.update: fgGreen else: fgRed
    echoColored "   `-------------------------------------------'"

    case act
    of Action.update:
        for oldVerObj in seqOldVers:
            var fSame = false
            for installedVerObj in seqInstalledVers:
                if oldVerObj.ver == installedVerObj.ver:
                    fSame = true
                    break
            if not fSame:
                result.add oldVerObj
    of Action.remove:
        for installedVerObj in seqInstalledVers:
            if not installedVerObj.active:
                result.add installedVerObj
    for i, obj in result: # Show versions
        let cNum = if i > 9: ('0'.ord + i + 7).chr else: ('0'.ord + i).chr
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
        #
        var num = -1
        if ch >= '0' and ch <= '9':
            num = ch.ord - '0'.ord
        elif ch >= 'a'and ch <= 'j':
            num = ch.ord - 'a'.ord + 10
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
            result = choosenim( [$act, sVer] )

proc dispatchTopMenu(ch: char): bool =
    case ch
    of '\r', 'q':
        quit 0
    of 'u': # Install stable version
        result = choosenim(["update", "stable"])
    of 'p':
        let messages = "This may take much time !\nUpdate Devel version ? y/[n]:"
        echoColored(messages,fgYellow)
        result = true
        if getch() == 'y':
            result = choosenim(["update", "devel"])
    of 'l':
        result = dispatchActionMenu(Action.update) #
    of 'r':
        result = dispatchActionMenu(Action.remove)
    else:
        result = true
        var num = -1
        if ch >= '0' and ch <= '9':
            num = ch.ord - '0'.ord
        elif ch >= 'a'and ch <= 'j':
            num = ch.ord - 'a'.ord + 10
        if num >= 0 and num < seqInstalledVers.len:
            result = choosenim([seqInstalledVers[num].ver.strip(chars={'#'})])

proc showTopMenu() =
    echo        " .-----------------------."
    echoColored " || Installed versions  ||",fgCyan
    echo        " `-----------------------'"
    for i, installedVerObj in seqInstalledVers:
        let cNum = if i > 9: ('0'.ord + i + 7).chr else: ('0'.ord + i).chr
        let sBase = &"  [{cNum}]  nim-{installedVerObj.ver}"
        if installedVerObj.active:
            echoColored(sBase & " *", fgGreen, false)
            if installedVerObj.devVer != "":
                stdout.write &"  ({installedVerObj.compiledDate})"
                echo " v",installedVerObj.devVer
            else:
                echo &" ({installedVerObj.compiledDate})"
        else:
            echo sBase

    echo "    Select number you'd like to change Nim version."
    echo "    *: Active version."
    echo """  ---
  [L] [L]ist and install other Nim versions
  [U] [U]pdate to stable version
  [P] U[p]date devel version (nim-#devel)
  [R] [R]emove Nim versions
  [Q] Exit (or [Enter])"""

# In case not existing NimvConfName,use below edge versions as default.
const tblOldVersions = ["1.6.10", "1.6.8", "1.4.8", "1.2.18", "1.0.10"]

import json
proc main() =
    #### Check choosenim
    if "" == findExe(Choosenim):
        echoColored("Cannot find 'choosenim' command, install it as follows:",fgRed)
        echoColored("nimble install choosenim",fgYellow)
        quit 1

    #### Show Help
    if paramCount() >= 1:
        case paramStr(1)
        of "--help", "-h", "/?", "/h", "-v", "--version":
            echo(sHelp % [VERSION,REL_DATE])
            quit 0

    #### Read conf file (NimvConfName)
    let selfPath = os.getAppFilename()
    stdout.write "[ $# ]" % [selfPath]
    echoColored " Running",fgYellow
    let p = getHomeDir().splitFile()
    let confPathName = joinPath(p.dir, NimvConfName)
    if confPathName.fileExists:
        stdout.write "[ $# ]" % [confPathName]
        echoColored " Activated",fgYellow
        var jnode:JsonNode
        try:
            jnode = parseJson(readfile(confPathName))
        except JsonParsingError as e:
            echo "Json parsing Error: " & e.msg
            echo "  $#" % [confPathName]
            quit 1
        for jElm in jnode["oldVers"].items:
            if 1 == jElm["enable"].getInt:
                seqOldVers.add NimVer(ver:jElm["ver"].getStr)
        fDispChoosenimAndNimbleDir = jnode["dispChoosenimAndNimbleDir"].getBool
        #
        sChoosenimDir = jnode["choosenimDir"].getStr
        if "" != sChoosenimDir:
            if dirExists sChoosenimDir:
                if fDispChoosenimAndNimbleDir:
                    stdout.write &"[ {sChoosenimDir} ]"
                    echoColored " => choosenimDir",fgYellow
            else:
                echoColored "ERROR: Not found [$#] => choosenimDir"  % [sChoosenimDir],fgRed
                sChoosenimDir = ""
        #
        sNimbleDir = jnode["nimbleDir"].getStr
        if "" != sNimbleDir:
            if dirExists sNimbleDir:
               if fDispChoosenimAndNimbleDir:
                   stdout.write &"[ {sNimbledir} ]"
                   echoColored " => nimbleDir",fgYellow
            else:
                echoColored "ERROR: Not found [$#] => nimbleDir"  % [sNimbleDir],fgRed
                sNimbleDir = ""
        #
        fDebug = jnode["debugMode"].getBool

    else:
        echo "[ $# ] Not exists" % [confPathName]
        for sVer in @tblOldVersions:
            seqOldVers.add NimVer(ver:sVer)

    ####
    let (fRes, sRes) = updateActiveVer()
    if fRes == false:
        echo sRes
        quit 1

    #### For commandline
    if os.paramCount() >= 1:
        let arg1 = commandLineParams()[0]
        try:
            discard parseInt(arg1)
        except ValueError:
            if arg1 == "-d":
                fDebug = true
            else:
                # Pass all parameters and execute choosenim
                if false == choosenim(commandLineParams()):
                    let _ = choosenim(["show"])
                quit 0
        if not fDebug:
            discard dispatchTopMenu(arg1[0]) # Specifiy a number to activate a version
            quit 0

    #### Start CUI
    while true:
        showTopMenu()
        if false == dispatchTopMenu(getch()): # Stop here until input one char
            echo "\n\n ERROR !!"

when isMainModule:
    main()

