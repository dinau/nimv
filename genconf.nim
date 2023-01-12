import std/[os, strutils, pegs, osproc,tables]

let tblEnable = @[
    "1.6.10",
    "1.6.8",
    "1.4.8",
    "1.2.18",
    "1.0.10",
]
let tblAllList = {
    "1.6.10":"2022-11-21",
    "1.6.8" :"2022-09-27",
    "1.6.6" :"2022-05-05",
    "1.6.4" :"2022-02-09",
    "1.6.2" :"2021-12-17",
    "1.6.0" :"2021-10-19",
    "1.4.8" :"2021-05-25",
    "1.4.6" :"2021-04-15",
    "1.4.4" :"2021-02-23",
    "1.4.2" :"2020-11-30",
    "1.4.0" :"2020-10-18",
    "1.2.18":"2022-02-09",
    "1.2.16":"2021-12-16",
    "1.2.14":"2021-11-08",
    "1.2.12":"2021-04-15",
    "1.2.10":"2021-02-23",
    "1.2.8" :"2020-10-26",
    "1.2.6" :"2020-07-29",
    "1.2.4" :"2020-06-26",
    "1.2.2" :"2020-06-16",
    "1.2.0" :"2020-04-03",
    "1.0.10":"2020-10-26",
    "1.0.8" :"2020-07-29",
    "1.0.6" :"2020-01-23",
    "1.0.4" :"2019-11-27",
    "1.0.2" :"2019-10-22",
    "1.0.0" :"2019-09-23",
    "0.20.2":"2019-07-17",
    "0.20.0":"2019-06-06",
    "0.19.6":"2019-05-10",
}.toTable


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
    #seqLines.add  """"nimbleDir":"d:\\nim-data\\nimv-data\\xxx\\nimble","""
    seqLines.add  """"choosenimDir":"","""
    seqLines.add  """"nimbleDir":"","""
    seqLines.add  """"dispChoosenimDirAndNimbleDir":true,"""
    seqLines.add  """"debugMode":false,"""
    seqLines.add  """"oldVers":["""

    for line in sOut.splitLines:
        if line =~ peg" @ {\d+ '.' \d+ '.' \d+}":
            let
                sVer =  matches[0]
                sEnBase = """  {"enable":$#, """
                sEn = sEnBase % ["1"]
                sNEn= sEnBase % ["0"]
                sOther = """"ver":"$#", "date":"$#", "comment":""},""" % [sVer,tblAllList[sVer]]
            var sPair = sNEn & sOther
            for sEnableVer in tbl:
                if sEnableVer == sVer:
                    sPair = sEn & sOther
                    break
            seqLines.add sPair
    seqLines.add "]}"

    ##seqLines.add "1, #devel"
    ##seqLines.add "0, #version-1-6"
    writeFile(sConfName, seqLines.join("\n"))
    if isJp(): echo "\ngenconv.nimsで $# を上書きしました\n" % [sConfName]
    else: echo "\ngenconv.nims updated $#\n" % [sConfName]

proc main() =
    #convToList(".nimv.list",tblEnable)
    convToJson(".nimv.json",tblEnable)

main()

