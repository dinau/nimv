import std/[os, strutils, pegs, osproc]

let tbl_enable = @[
    "1.6.10",
    "1.6.8",
    "1.4.8",
    "1.2.18",
    "1.0.10",
]

const NimvConfName = ".nimv.list"

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

proc convToList(tbl: seq[string]) =
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
    writeFile(NimvConfName, seqLines.join("\n"))
    if isJp(): echo "\ngenconv.nimsで $# を上書きしました\n" % [NimvConfName]
    else: echo "\ngenconv.nims updated $#\n" % [NimvConfName]

proc main() =
    convToList(tbl_enable)

main()

