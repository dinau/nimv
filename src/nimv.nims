#var TC = "gcc"
#var TC = "clang"
#var TC = "vcc"
var TC = "tcc"

if "" == findExe(TC): # GCC is default compiler if TC dosn't exist on the PATH
    TC = "gcc"

#const LTO = true
const LTO = false

switch "define", "danger"
switch "opt", "size"

#switch "verbosity","2"

proc commonOpt() =
    switch "passL", "-s"
    switch "passC", "-ffunction-sections"
    switch "passC", "-fdata-sections"
    switch "passC", "-Wl,--gc-sections"
    switch "passL", "-Wl,--gc-sections"

#const NIMCACHE = ".nimcache_" & TC
switch "nimcache", ".nimcache"

case TC
    of "gcc":
        commonOpt()
        when LTO: # These options let linking time slow instead of reducing code size.
            switch "passC", "-flto"
            switch "passL", "-flto"
    of "clang":
        commonOpt()
        #switch "passC","-flto=auto"
        #switch "passL","-flto"

switch "cc", TC

echo ""
echo "#### Compiler: [ ",TC," ] ####"
echo ""

