import std/[strutils]

# Package

version       = "1.0.0"
author        = "dinau"
description   = "Simple CUI wrapper for choosenim"
license       = "MIT"
srcDir        = "src"
bin           = @["nimv"]


# Dependencies

requires "nim >= 0.19.6"


let TARGET = bin[0]

const releaseDate = "2022/12"
var OPTS = " -d:VERSION:$# -d:REL_DATE:$#" % [version, releaseDate]

task make,"make":
    exec("nim c -d:strip -o:$# $# $#.nim" % [TARGET.toEXE,OPTS, "src/" & TARGET])
    #exec( TARGET.toEXE() )

task clean,"clean":
    rmFile TARGET.toEXE()
    rmDir ".nimcache"

task build,"build":
    makeTask()

task default,"default":
    makeTask()

