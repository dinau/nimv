# Package

version       = "1.4.5"
author        = "dinau"
description   = "Simple CUI wrapper for choosenim command"
license       = "MIT"
srcDir        = "src"
bin           = @["nimv"]


# Dependencies

requires "nim >= 0.19.6"

import std/[strutils]

let TARGET = "nimv"

# See "version.nims" included in "config.nims".
#const releaseDate = "2023/01"
var Opts = "" #" -d:VERSION:$# -d:REL_DATE:$# " % [version,releaseDate]



task make,"make":
    let cmd = "nim c -d:strip -o:$# $# $#.nim" % [TARGET.toEXE,Opts,"src/" & TARGET]
    echo cmd
    exec(cmd)

task clean,"clean":
    exec("rm -fr .nimcache")
    rmFile TARGET.toEXE()

task run,"run":
    makeTask()
    exec("$#" % [TARGET.toEXE])

