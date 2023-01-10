import std/[os, strutils, pegs, osproc]

let tbl_enable = @[
    "1.6.10",
    "1.6.8",
    "1.4.8",
    "1.2.18",
    "1.0.10",
]


when defined(windows):
    const Choosenim = "choosenim.cmd"
else:
    const Choosenim = "choosenim"

proc isJp(): bool =
    const VAL_ENV = ["LANG", "LANGUAGE", "LC_ALL", "LC_CTYPE"]
    for val in VAL_ENV:
        if getEnv(val).toLower =~ peg" 'ja' / 'jp' ":
            result = true
            break

proc convToList(sConfName:string,tbl: seq[string]){.used.} =
    const cmd = Choosenim & " --noColor  versions"
    var (sOut, _) = execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath})
    var seqLines: seq[string]
    seqLines.add "# Enable, Vesion"
    for line in sOut.splitLines:
        if line =~ peg" @ {\d+ '.' \d+ '.' \d+}":
            let sVer =  matches[0]
            var sPair = "0, $#" % [sVer]
            for sEnableVer in tbl:
                if sEnableVer == sVer:
                    sPair = "1, $#" % [sVer]
            seqLines.add sPair
    #seqLines.add "1, #devel"
    #seqLines.add "0, #version-1-6"
    writeFile(sConfName, seqLines.join("\n"))
    if isJp(): echo "\ngenconv.nimsで $# を上書きしました\n" % [sConfName]
    else: echo "\ngenconv.nims updated $#\n" % [sConfName]

#####
proc convToJson(sConfName:string,tbl: seq[string]) =
    const cmd = Choosenim & " --noColor  versions"
    var (sOut, _) = execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath})
    var seqLines: seq[string]
    seqLines.add  "{"
    #seqLines.add  """"choosenimDir":"d:\\nim-data\\nimv-data\\xxx\\choosenim","""
    seqLines.add  """"choosenimDir":"","""
    #seqLines.add  """"nimbleDir":"d:\\nim-data\\nimv-data\\xxx\\nimble","""
    seqLines.add  """"nimbleDir":"","""
    seqLines.add  """"dispChoosenimAndNimbleDir":true,"""
    seqLines.add  """"debugMode":false,"""
    seqLines.add  """"oldVers":["""

    for line in sOut.splitLines:
        if line =~ peg" @ {\d+ '.' \d+ '.' \d+}":
            let sVer =  matches[0]
            var sPair = """  {"enable":0, "ver":"$#", "comment":""},""" % [sVer]
            for sEnableVer in tbl:
                if sEnableVer == sVer:
                    sPair = """  {"enable":1, "ver":"$#", "comment":""},""" % [sVer]
                    break
            seqLines.add sPair
    seqLines.add "]}"
    ##seqLines.add "1, #devel"
    ##seqLines.add "0, #version-1-6"
    writeFile(sConfName, seqLines.join("\n"))
    if isJp(): echo "\ngenconv.nimsで $# を上書きしました\n" % [sConfName]
    else: echo "\ngenconv.nims updated $#\n" % [sConfName]

proc main() =
    #convToList(".nimv.list",tbl_enable)
    convToJson(".nimv.json",tbl_enable)

main()

