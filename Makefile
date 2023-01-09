TARGET = nimv
NIMV_CONF_NAME = .nimv.list

VPATH = src

ifeq ($(OS),Windows_NT)
	EXE = .exe
	DESD_DIR = d:/00emacs-home/vimtool
else
	DESD_DIR = ~/bin
endif

all: genconf$(EXE)
	@nimble make --verbose

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
