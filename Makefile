TARGET = nimv

VPATH = src

ifeq ($(OS),Windows_NT)
	EXE = .exe
	DESD_DIR = d:/00emacs-home/vimtool
else
	DESD_DIR = ~/bin
endif

all: genconf$(EXE)  $(TARGET)$(EXE)
	./$<
	@nimble make

%$(EXE): %.nim
	nim c -d:release -d:strip --opt:size -o:$@ $<


clean:
	rm -fr .nimcache
	#@nimble clean
	rm genconf$(EXE) $(TARGET)$(EXE)

setup: all
	cp nimv$(EXE) $(DESD_DIR)
	cp nimv.list  $(DESD_DIR)

purge:
	-rm  $(DESD_DIR)/nimv$(EXE)
	-rm  $(DESD_DIR)/nimv.list


GIT_REPO = ../00rel/nimv

gitup:
	cp -f genconf.nim $(GIT_REPO)
	cp -f LICENSE $(GIT_REPO)
	cp -f Makefile $(GIT_REPO)
	cp -f nimv.list $(GIT_REPO)
	cp -f nimv.nimble $(GIT_REPO)
	cp -f setenv.bat $(GIT_REPO)
	cp -f src/nimv.nim $(GIT_REPO)/src
	cp -f src/nimv.nims $(GIT_REPO)/src
