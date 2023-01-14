TARGET = nimv
#NIMV_CONF_NAME = .nimv.list
NIMV_CONF_NAME = .nimv.json

VPATH = src

ifeq ($(OS),Windows_NT)
	EXE = .exe
	DESD_DIR = d:/00emacs-home/vimtool
	MYHOME = $(HOMEDRIVE)$(HOMEPATH)
else
	DESD_DIR = ~/bin
	MYHOME = $(HOME)
endif

all: genconf$(EXE)
	@nimble make --verbose
	-cp -f .nimv.json c:/Users/$(USERNAME)/
	@# dll check
	-@strings $(TARGET)$(EXE) | rg -i \.dll
	@# version check
	@echo [nimv.nimlbe]
	-@rg -ie "version\s+=.+" nimv.nimble
	@echo [version.nims]
	-@rg -ie "\d\.\d\.\d" version.nims
	-@ mdmake .

OPT += -d:danger
OPT += -d:strip
#OPT += --passL:"-Wl,--enable-stdcall-fixup"

genconf$(EXE): genconf.nim
	nim c  $(OPT) --opt:size -o:$@ $<
	./$@

.PHONEY: clean setup purge gitup
clean:
	-@nimble clean
	-@rm genconf$(EXE)

run:
	-@nimble run

setup: all
	cp nimv$(EXE) $(DESD_DIR)
	cp $(NIMV_CONF_NAME)  $(DESD_DIR)

purge:
	-rm  $(DESD_DIR)/nimv$(EXE)
	-rm  $(DESD_DIR)/$(NIMV_CONF_NAME)


GIT_REPO = ../00rel/nimv

gitup:
	@-rm $(GIT_REPO)/* $(GIT_REPO)/src/
	cp -f version.nims $(GIT_REPO)
	cp -f config.nims $(GIT_REPO)
	cp -f .gitignore  $(GIT_REPO)
	cp -f genconf.nim $(GIT_REPO)
	cp -f LICENSE $(GIT_REPO)
	cp -f README.md $(GIT_REPO)
	cp -f Makefile $(GIT_REPO)
	cp -f $(NIMV_CONF_NAME) $(GIT_REPO)
	cp -f nimv.nimble $(GIT_REPO)
	cp -f setenv.bat $(GIT_REPO)
	cp -f src/nimv.nim $(GIT_REPO)/src
	-cp -f img/* $(GIT_REPO)/img/
	ls -al $(GIT_REPO)
	ls -al $(GIT_REPO)/src
	ls -al $(GIT_REPO)/img

dlls:
	@strings $(TARGET)$(EXE) | rg -i \.dll
cphome:
	cp -f .nimv.json $(MYHOME)
pretty:
	nimpretty --indent:4 --maxLineLen:200 src/$(TARGET).nim

VER ?= head

remoteInstall:
	nimble install https://github.com/dinau/nimv@#$(VER)

vercheck:
	@echo [nimv.nimlbe]
	@rg -ie "version\s+=.+" nimv.nimble
	@echo [src/nimv.nim]
	@rg -ie "const\s+VERSION.+=" src/nimv.nim
