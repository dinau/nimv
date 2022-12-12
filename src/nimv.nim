# Simple version selector for Nim using choosenim
# modified: 2022/11
# modified: 2021/10
# first: made by audin 2021/1
#
# Required:
#     nim-0.19.6 or later minimum requested. Not colored.
#     nim-1.4.0  or later recommended. Colored.
#
import std/[os, strutils, terminal, osproc, pegs]

const VERSION {.strdefine.} = "ERROR:unkonwn version"
const REL_DATE {.strdefine.} = "ERROR:unkonwn release date"

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

const NimvConf = "nimv.list"

type
    Action = enum
        update, remove

let sHelp = """
nimv $# ($#): Simple CUI for Chooseim command
              from 2021/10 by audin
Usage:
    nimv [Option]
       Option:
            None : Show Choosenim CUI
            -h, /?, /h, -v, --version: Show help
    nimv.list: List of Old nim versions,set enable or not for install."""
var
    seqOldVersions: seq[string]
    sActiveVer: string
    seqInstalledVer: seq[string]
    fDebug = false

proc updateInstalledVer(seqOutput: seq[string]) =
    seqInstalledVer.setLen(0)
    var state = 0
    for line in seqOutput:
        case state
        of 0:
            if line.contains("Versions:"):
                inc state
        of 1:
            let ary = line.strip.split(peg"\s+")
            if ary.len >= 2: # has '*' mark at ary[0] ?
                seqInstalledVer.add ary[1]
            elif (ary.len == 1) and (ary[0].len > 0): # not have '*' mark
                seqInstalledVer.add ary[0]
        else: discard

proc echoColored(str:string,colf:ForegroundColor) =
    when HAVE_COLOR:
        setForegroundColor(colf, bright = true)
        echo str
        stdout.resetAttributes()
    else:
        echo str

proc updateActiveVer(): (bool, string) {.discardable.} =
    let cmd = Choosenim & " --noColor " & "show"
    if fDebug:
        echo "[[$#]]" % [cmd]
    let (sOut, erCode) = execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath})
    if erCode == 0:
        let seqLines = sOut.splitLines()
        sActiveVer = seqLines[0].split(peg"\s+")[1].strip # Contains "Selected: version"
        updateInstalledVer(seqLines)
        result = (true, sOut)
    else:
        result = (false, "0[ERROR]: " & sOut)

proc choosenim(argments: openArray[string]): bool =
    let cmd = Choosenim & " " & join(argments, " ")
    if fDebug:
        echo "[[$#]]" % [cmd]
    if 0 == execCmd(cmd):
        updateActiveVer()
        result = true

proc showActionMenu(act: Action, sqNewNimVers: var seq[string]) =
    let sAct = if act == Action.update: "install" else: "delete"
    echoColored(" *** [$#]: Select number you'd like to $# ***\n" % [ sAct.toUpper, sAct],
                if act == Action.update: fgGreen else: fgRed)
    case act
    of Action.update:
        for sOldVer in seqOldVersions:
            var fSame = false
            for sInstalledVer in seqInstalledVer:
                if sOldVer == sInstalledVer:
                    fSame = true
                    break
            if not fSame:
                sqNewNimVers.add sOldVer
        for i, sVer in sqNewNimVers:
            echo "  [$#]  nim-$#" % [$i, sVer]
    of Action.remove:
        for sVer in seqInstalledVer:
            if not (sVer == sActiveVer):
                sqNewNimVers.add sVer
        for i, sVer in sqNewNimVers:
            echo "  [$#]  nim-$#" % [$i, sVer]

    echo "  ---"
    echo "  [M] Back to top menu (or [R])"
    echo "  [Q] Exit (or [Enter])"

proc dispatchActionMenu(act: Action): bool =
    result = true
    var seqNewNimVers: seq[string]
    while true:
        seqNewNimVers = @[]
        showActionMenu(act, seqNewNimVers)
        let ch = getch()
        if ch == '\r' or ch == 'q':
            quit 0
        if ch == 'r' or ch == 'm':
            return true
        let num = ch.ord - '0'.ord
        if num >= 0 and num < seqNewNimVers.len:
            var sVer = seqNewNimVers[num]
            if (sVer =~ peg"\s* '#' ") and (act == Action.update):
                let messages = "This may take much time !\nUpdate Devel version ? y/[n]:"
                echoColored(messages, fgYellow)
                if getch() != 'y':
                    return
            if act == Action.remove:
                sVer = "\"" & sVer & "\"" # for Linux: orz
            let cmdArgs = [$act, sVer]
            result = choosenim(cmdArgs)

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
        result = dispatchActionMenu(Action.update)
    of 'r':
        result = dispatchActionMenu(Action.remove)
    of '0'..'9':
        let num = ch.ord - '0'.ord
        if num >= 0 and num < seqInstalledVer.len:
            result = choosenim([seqInstalledVer[num].strip(chars={'#'})])
    of 'a'..'j':
        let num = ch.ord - 'a'.ord + 10
        if num >= 0 and num < seqInstalledVer.len:
            result = choosenim([seqInstalledVer[num].strip(chars={'#'})])
    else:
        result = true

proc showTopMenu() =
    echo "\n *** Installed versions ***"
    echo "     Select number you'd like to change Nim version."
    echo "     *: Active version."
    for i, sVer in seqInstalledVer:
        let cNum = if i > 9: ('0'.ord + i + 7).chr else: ('0'.ord + i).chr
        let sBase = " [$#]  nim-$#" % [$cNum, sVer]
        if sVer == sActiveVer:
            echoColored(sBase & " *", fgGreen)
        else:
            echo sBase
    echo """ ---
 [L]  [L]ist and install other Nim versions
 [U]  [U]pdate to Stable version
 [P]  U[p]date devel version (nim-#devel)
 [R]  [R]emove Nim versions
 [Q]  Exit (or [Enter])"""

# In case not existing NimvConf,use below edge versions
const tblOldVersions = ["1.6.8", "1.4.8", "1.2.18", "1.0.10", "0.19.6", ]

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

    #### Read conf file
    let selfPath = os.getAppFilename()
    echo "[ $# ] (v$#)" % [selfPath,VERSION]
    let p = selfPath.splitFile()
    let confPath = joinPath(p.dir, NimvConf)

    if confPath.fileExists:
        echo "[ $# ]" % [confPath]
        for line in lines(confPath):
            if line =~ peg"\s* '#' (.+)?": continue # Skip comment
            let elms = line.split(',')
            let enable = elms[0].strip
            let sVer = elms[1].strip
            if "0" == enable: continue
            seqOldVersions.add sVer
    else:
        seqOldVersions = @tblOldVersions

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
            discard dispatchTopMenu(arg1[0]) # Specifiy a number to activate one version
            quit 0

    #### Start CUI
    while true:
        showTopMenu()
        if false == dispatchTopMenu(getch()): # Stop here until input one char
            echo "\n\n ERROR !!"

when isMainModule:
    main()

