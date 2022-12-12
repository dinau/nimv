import std/[os, strutils, pegs, osproc]

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
let tbl_enable = @[
    "1.6.8",
    "1.4.8",
    "1.2.18",
    "1.0.10",
    "0.19.6",
]

proc convToList(tbl: seq[string]) =
    let cmd = Choosenim & " --noColor  versions"
    var (sOut, _) = execCmdEx(cmd, options = {poStdErrToStdOut, poUsePath})
    var seqLines: seq[string]
    seqLines.add "# Enable, Vesion"
    for line in sOut.splitLines:
        if line =~ peg" @ {\d+ '.' \d+ '.' \d+}":
            let sVer =  matches[0]
            var sPair = "0, $#" % [sVer]
            for sEnableVer in tbl:
                #echo "[$#] [$#]" % [ sEnableVer , sVer]
                if sEnableVer == sVer:
                    sPair = "1, $#" % [sVer]
            seqLines.add sPair
    #seqLines.add "1, #devel"
    seqLines.add "1, #version-1-6"
    writeFile("nimv.list", seqLines.join("\n"))
    if isJp(): echo "\ngenconv.nimsでnimv.listを上書きしました\n"
    else: echo "\ngenconv.nims updated nimv.json\n"

when false:
    import std/[json, strformat]
#                             0    1
    proc convToJson(tbl: seq[(int, string)]) =
        var sOut: seq[string]
        sOut.add """{
    "old_version_list":["""
        for line in tbl:
            let sbEnable = $line[0]
            let sVersion = line[1]
            sOut.add """  {"enable":$#, "version":"$#"},""" % [sbEnable, sVersion]
        sOut.add "]}"
        writeFile("nimv.json", sOut.join("\n"))
        if isJp(): echo "\ngenconv.nimsでnimv.jsonを上書きしました\n"
        else: echo "\ngenconv.nims updated nimv.json\n"

proc main() =
    #convToJson(tbl)
    convToList(tbl_enable)

main()



