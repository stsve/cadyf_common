# ==================================================================== #
#            USER PROFILE FLAGS (BASED ON CADYF ENV VARIABLES)
# ==================================================================== #

# Directory where to install
BUILD_HOME:=$(shell [ -z ${CADYF_BUILD} ] && echo "xxx-default_cadyf_build-xxx" || echo "${CADYF_BUILD}")

# Switch between debugging/development or optimized compilation
CPLTOPT:=$(shell [ -z ${CADYF_OPTIMIZE} ] && echo "debug" || echo "${CADYF_OPTIMIZE}")

# FORTRAN compiler to be used (default is open-source gfortran)
F77:=$(shell [ -z ${CADYF_FCOMPILER} ] && echo "gfortran" || echo "${CADYF_FCOMPILER}")

# Set cadyf options
CADYFOPT:=$(shell [ -z ${CADYF_OPTIONS} ] && echo "none" || echo "${CADYF_OPTIONS}")

# ==================================================================== #
#                  GENERIC FLAGS AND VARIABLES DEFINITION
# ==================================================================== #

# Default shell
SHELL := /bin/bash

# Machine/OS/Architecture type definition
UNAME := $(shell uname -s)
ATYPE := $(shell [ "`uname -p`" = "i686" ] && echo "32bits" || echo "64bits")

# Destination directory for all build outputs
BUILDDIR := $(BUILD_HOME)/$(F77)/$(CPLTOPT)

# Library and associated archive
CURDIR := $(shell dirname `pwd`)
ifeq ($(shell basename $(CURDIR)),USAGER) # for user source files (USAGER)
  LIB := usr_$(shell basename `pwd`)
else # for generic source files
  LIB := $(shell basename `pwd`)
endif
LIBNAME := lib$(LIB)
LIBRARY := $(LIBNAME).a

# Executable program associated with this library (if any)
PRGNAME := $(shell basename `pwd`)
PRGLIB  := lib$(PRGNAME).a
PROGRAM := $(PRGNAME)_$(UNAME).exe
ifeq ($(strip $(filter-out amiral cadyf adapt,$(PRGNAME))),)
  MALLRULE:=prg
endif

# Destination directories
DESTINC := $(HOME)/$(BUILDDIR)/inc/$(UNAME)/$(LIB)
DESTDEP := $(HOME)/$(BUILDDIR)/dep/$(UNAME)/$(LIB)
DESTOBJ := $(HOME)/$(BUILDDIR)/obj/$(UNAME)/$(LIB)
DESTMOD := $(HOME)/$(BUILDDIR)/mod/$(UNAME)
DESTLIB := $(HOME)/$(BUILDDIR)/lib/$(UNAME)
DESTPRG := $(HOME)/$(BUILDDIR)/bin

# Make sure that the above directories exist
#
# note: keep this statement near the top of the makefile
#       so that it is executed before anything that could
#       possibly need the directories.
#       Specifying rules to build output directories is not
#       a possible alternative for most makes because these
#       directories are always newer than the target they
#       contain and would thus lead to unnecessary rebuilds.
#       However, with GNU make order-only prerequisites
#       (specified by the pipe symbol) could be used.
#
DUMMY := $(shell \
[ -d $(DESTINC) ] || mkdir -p $(DESTINC); \
[ -d $(DESTDEP) ] || mkdir -p $(DESTDEP); \
[ -d $(DESTOBJ) ] || mkdir -p $(DESTOBJ); \
[ -d $(DESTMOD) ] || mkdir -p $(DESTMOD); \
[ -d $(DESTLIB) ] || mkdir -p $(DESTLIB); \
[ -d $(DESTPRG) ] || mkdir -p $(DESTPRG) )

# For make and the compiler to find arch dependent include files
VPATH := $(DESTINC)
FINCPATH := -I$(DESTINC)

# For make and the compiler to find includes for user source files
ifeq ($(shell basename $(CURDIR)),USAGER)
  VPATH += $(HOME)/$(CADYF_HOME)/src/$(PRGNAME) \
           $(HOME)/$(BUILDDIR)/inc/$(UNAME)/$(PRGNAME)
  FINCPATH += -I$(HOME)/$(CADYF_HOME)/src/$(PRGNAME) \
              -I$(HOME)/$(BUILDDIR)/inc/$(UNAME)/$(PRGNAME)
endif

# Machine-dependent archiver
AR      := ar
ARFLAGS := cru
# note: The GNU "ar" and "libtool" generate and update
#       table of contents of archive libraries. The generic
#       "ar"  program does not => use "ranlib libname.a"
RANLIB  := ranlib

# FORTRAN source files
SRCF_FIXED_FORM := $(wildcard *.f)
SRCF_FREE_FORM := $(wildcard *.f90)
SRCF := $(SRCF_FIXED_FORM) $(SRCF_FREE_FORM)

# Get FORTRAN file names from file stem
define create_var_template
  SRC_$$(basename $(1))_FNAME = $(1)
endef
$(foreach file,$(SRCF),$(eval $(call create_var_template,$(file))))

# check
TMPF := $(patsubst %.f,%,$(SRCF_FIXED_FORM)) $(patsubst %.f90,%,$(SRCF_FREE_FORM))
SRC_FNAME := $(foreach file,$(TMPF),$(value SRC_$(file)_FNAME))
ifneq ($(strip $(SRCF)),$(strip $(SRC_FNAME)))
  $(error "Incomplete or wrong FORTRAN file names list...")
endif

# FORTRAN objets from source files
OBJF := $(patsubst %.f,%.o,$(SRCF_FIXED_FORM))
OBJF += $(patsubst %.f90,%.o,$(SRCF_FREE_FORM))

# Objet files in obj directory
OBJLIB := $(patsubst %.f,$(DESTOBJ)/%.o,$(SRCF_FIXED_FORM))
OBJLIB += $(patsubst %.f90,$(DESTOBJ)/%.o,$(SRCF_FREE_FORM))

# FORTRAN dependency files from source files
DEPF := $(patsubst %.f,$(DESTDEP)/%.d,$(SRCF_FIXED_FORM))
DEPF += $(patsubst %.f90,$(DESTDEP)/%.d,$(SRCF_FREE_FORM))

# Module files from source files
MODF := $(patsubst %.f,$(DESTMOD)/%.mod,$(SRCF_FIXED_FORM))
MODF += $(patsubst %.f90,$(DESTMOD)/%.mod,$(SRCF_FREE_FORM))

# External dependencies
IGNORE_MOD_DEPS := lapack95 blas95 f95_precision \
                   omp_lib omp_lib_kinds \
                   mpi \
                   openacc \
                   iso_fortran_env iso_c_binding \
                   ieee_exceptions ieee_arithmetic ieee_features

# Include dependency files from include files
INCF := $(wildcard *.inc)
DEPI := $(patsubst %.inc,$(DESTDEP)/%.inc.d,$(INCF))

# Include dependency files from architecture dependent include files
ARDINC = $(wildcard *.inc_$(ATYPE))
INCF += $(patsubst %.inc_$(ATYPE),$(DESTINC)/%.inc,$(ARDINC))
DEPI += $(patsubst %.inc_$(ATYPE),$(DESTDEP)/%.inc.d,$(ARDINC))

# ==================================================================== #
#                         SET COMPILER FLAGS
# ==================================================================== #

#
# Generic flags (compilation+link)
#
FLAGS_GEN :=

ifeq ($(CADYFOPT),none)

  ifeq ($(F77),gfortran)
    # note: gfortran/gcc: -fopenmp GNU OpenMP and -liomp5 for Intel library
    ifeq ($(PRGNAME),cadyf)
      COMP_FLAGS_OMP := -fopenmp
    else ifeq ($(PRGNAME),adapt)
      COMP_FLAGS_OMP := -fopenmp
    else ifeq ($(PRGNAME),amiral)
      COMP_FLAGS_OMP := -fopenmp
    else ifeq ($(LIB),tria2d)
      COMP_FLAGS_OMP := -fopenmp
    endif

  else ifeq ($(F77),ifort)
    # note: -qopenmp (for libiomp5) MUST be used both to compile AND link
    ifeq ($(PRGNAME),cadyf)
      COMP_FLAGS_OMP := -qopenmp
    else ifeq ($(PRGNAME),adapt)
      COMP_FLAGS_OMP := -qopenmp
    else ifeq ($(PRGNAME),amiral)
      COMP_FLAGS_OMP := -qopenmp
    else ifeq ($(LIB),tria2d)
      COMP_FLAGS_OMP := -qopenmp
    endif

  endif

endif
FLAGS_GEN += $(COMP_FLAGS_OMP)

#
# Generic flags (compilation only)
#
ifeq ($(F77),gfortran)
  COMP_FLAGS_GEN := -fdefault-integer-8 -fdefault-real-8 -fdefault-double-8 -m64 -mcmodel=large -fimplicit-none -ffree-line-length-none
else ifeq ($(F77),ifort)
  COMP_FLAGS_GEN := -i8 -r8 -m64 -mcmodel=large -implicitnone
endif

# Tell the compiler where to put modules
ifeq ($(F77),gfortran)
  COMP_FLAGS_MOD := -J$(DESTMOD)
else ifeq ($(F77),ifort)
  COMP_FLAGS_MOD := -module $(DESTMOD)
endif

#
# Build-specific compilation flags
#

# Set profiling options for gprof
ifeq ($(CADYFOPT),profiling)
  GPROF_FLAGS := -g -pg
endif

# ---optimize---mode---
ifeq ($(CPLTOPT),optimize)

  COMP_FLAGS_OPTZN := -O3

  # because of an unexplained bug, the tria2d lib
  # must be compiled with limited optimizations
  # otherwise results depend on the directory in
  # which amiral is run!
  ifeq ($(F77),ifort)
     ifeq ($(LIB),tria2d)
        COMP_FLAGS_OPTZN := -O1
     endif
  endif

  ifeq ($(F77),ifort)
    COMP_FLAGS_OPTZN += -fpconstant -zero -fpic -fpie
  endif

# ---debug---mode
else ifeq ($(CPLTOPT),debug)

  COMP_FLAGS_OPTZN := -g -O0

  ifeq ($(F77),gfortran)
      COMP_FLAGS_OPTZN += -fbacktrace -fdump-core
  else ifeq ($(F77),ifort)
      COMP_FLAGS_OPTZN += -fpe0 -traceback
  endif

# ---check---mode
else ifeq ($(CPLTOPT),check)

  COMP_FLAGS_OPTZN := -g -O0
  ifeq ($(F77),gfortran)
    COMP_FLAGS_OPTZN += -fdump-core -fbacktrace -fbounds-check -frange-check -std=legacy
  else ifeq ($(F77),ifort)
   COMP_FLAGS_OPTZN += -fpe0 -check bounds -W1 -warn all,nointerfaces -WB -debug all -traceback \
                 -fstack-security-check -fstack-protector
  endif

########################################################################################
#
# strip out check bound option for the renum library
#
    ifeq ($(LIB),renum) # patch super foireux a degager
      ifeq ($(F77),gfortran)
        COMP_FLAGS_OPTZN := $(filter-out -fbounds-check, $(COMP_FLAGS_OPTZN))
      else ifeq ($(F77),ifort)
        COMP_FLAGS_OPTZN := $(filter-out -check bounds, $(COMP_FLAGS_OPTZN))
      endif
    endif
########################################################################################

endif

#
# PARDISO and MKL
#
PARDISO_OPTS :=
PARDISO_LIBS :=
PARDISO_INFO := Intel MKL pardiso 64

## Not sure if that works with older versions of ifort
## and the link tool is far from perfect, we keep using
## manually assigned variables for now
### ### GNU FORTRAN ###
### ifeq ($(F77),gfortran)
###   MKL_LINK_TOOL_COMPILER=gnu_f
###   ifeq ($(CADYFOPT),none)
###     MKL_LINK_TOOL_PARALLEL=yes
###   else
###     MKL_LINK_TOOL_PARALLEL=no
###   endif
### ### INTEL FORTRAN ###
### else ifeq ($(F77),ifort)
###   MKL_LINK_TOOL_COMPILER=intel_f
###   ifeq ($(CADYFOPT),none)
###     PARDISO_OPTS += -qopt-matmul
###     MKL_LINK_TOOL_PARALLEL=yes
###   else
###     PARDISO_OPTS += -qopt-matmul
###     MKL_LINK_TOOL_PARALLEL=no
###   endif
### endif
###
### # Invoke the MKL link tool to obtain compiler options and link flags for the MKL
### MKL_LINK_TOOL     := $(MKLROOT)/tools/mkl_link_tool
### MKL_LINK_TOOL_CMD := --os=lnx --compiler=$(MKL_LINK_TOOL_COMPILER) --arch=intel64 --linking=dynamic --interface=ilp64 --parallel=$(MKL_LINK_TOOL_PARALLEL)
### ifeq ($(MKL_LINK_TOOL_PARALLEL),yes)
###   MKL_LINK_TOOL_CMD += --threading-library=iomp5
### endif
### $(eval MKL_LINK_TOOL_OPTS := $(shell $(MKL_LINK_TOOL) --quiet -opts $(MKL_LINK_TOOL_CMD)))
### $(eval MKL_LINK_TOOL_LIBS := $(shell $(MKL_LINK_TOOL) --quiet -libs $(MKL_LINK_TOOL_CMD)))
###
### PARDISO_OPTS += $(MKL_LINK_TOOL_OPTS)
### PARDISO_LIBS += $(MKL_LINK_TOOL_LIBS)

### GNU FORTRAN ###
ifeq ($(F77),gfortran)
  PARDISO_OPTS := -I$(MKLROOT)/include
  PARDISO_LINK := -L${MKLROOT}/lib/intel64
  ifeq ($(CADYFOPT),none) # compile with the multi-threaded librairies
    PARDISO_LIBS += -Wl,--no-as-needed \
                    -lmkl_gf_ilp64 \
                    -lmkl_intel_thread \
                    -lmkl_core \
                    -liomp5 -lpthread -lm -ldl
  else # compile with sequential librairies
    PARDISO_LIBS += -Wl,--no-as-needed \
                    -lmkl_gf_ilp64 \
                    -lmkl_sequential \
                    -lmkl_core \
                    -lpthread -lm -ldl
  endif
### INTEL FORTRAN ###
else ifeq ($(F77),ifort)
  PARDISO_OPTS := -I$(MKLROOT)/include/intel64/ilp64
  PARDISO_LINK := -L$(MKLROOT)/lib/intel64 -qopt-matmul
  ifeq ($(CADYFOPT),none) # compile with the multi-threaded librairies
    PARDISO_LIBS := -mkl=parallel
  else # compile with sequential librairies
    PARDISO_LIBS := -mkl=sequential
  endif
endif


#
# Compilation flags assembly
#
FFLAGS := $(COMP_FLAGS_OPTZN) $(COMP_FLAGS_GEN) $(FLAGS_GEN) $(GPROF_FLAGS) $(PARDISO_OPTS)

# ==================================================================== #
#                          SET LINKER FLAGS
# ==================================================================== #

# does a user source library (USAGER) exist for this program?
##ifeq ($(shell basename $(CURDIR)),USAGER) # for a user lib it necessarily does!
##  USRLIB := -lusr_$(PRGNAME)
##else # for a src lib, we check if it is available
##  USRLIB := $(shell [ -f $(DESTLIB)/libusr_$(PRGNAME).a ] && echo "-lusr_$(PRGNAME)" || echo "" )
##endif
##
## don't use library for user files... linkers don't take it...
##

#
# Path to user objects (if any)
#
# note: for a source library, we check if some object files exist
#       in the user library associated with the current library.
#       For user library, some object files are expected; if not a warning
#       message is displayed at link time (see below) but execution continues.
#
USR_OBJ_DIR := $(HOME)/$(BUILDDIR)/obj/$(UNAME)/usr_$(PRGNAME)
ifeq ($(shell basename $(CURDIR)),USAGER)
  ifneq ($(SRCF),)
    USR_OBJ := $(USR_OBJ_DIR)/*.o
  else
    USR_OBJ :=
  endif
else
  USR_OBJ := $(shell [ `ls $(USR_OBJ_DIR)/*.o 2>/dev/null | wc -w` -ge 1 ] && echo "$(USR_OBJ_DIR)/*.o" || echo "")
endif

#
# main object (cannot use obj file in archive unfortunately)
#
# don't use $(DESTOBJ) path; invalid for user libraries
ifeq ($(F77),gfortran)
  LINK_MAIN_OBJ := $(HOME)/$(BUILDDIR)/obj/$(UNAME)/$(PRGNAME)/$(PRGNAME)_driver.o
endif

#
# linker dependent flags
#
ifeq ($(F77),ifort)
  LINK_FLAGS := -shared-intel
  ifeq ($(PRGNAME),amiral)
    LINK_FLAGS += -threads
  else ifeq ($(PRGNAME),cadyf)
    LINK_FLAGS += -threads
  else ifeq ($(PRGNAME),adapt)
    LINK_FLAGS += -threads
  endif
endif

#
# program dependent flags
#

LINK_FLAGS_PRG := $(LINK_MAIN_OBJ) $(USR_OBJ) -L$(DESTLIB) $(PARDISO_LINK) $(PARDISO_LIBS)
ifeq ($(PRGNAME),amiral)
  LINK_FLAGS_PRG += -lamiral -lrenum -ltinyclip -ltria2d -ldatastructure -lusegmsh \
                    -llinsolv -lglobal -lgauss
else ifeq ($(PRGNAME),cadyf)
  LINK_FLAGS_PRG += -lcadyf -ltinyclip -llinsolv -lglobal -lgauss
else ifeq ($(PRGNAME),adapt)
  LINK_FLAGS_PRG += -ladapt -lcadyf -ltinyclip -llinsolv -lglobal -lgauss
endif

#
# Link flags assembly
#
LDFLAGS = $(LINK_FLAGS_PRG) $(LINK_FLAGS) $(FLAGS_GEN) $(GPROF_FLAGS)

# ==================================================================== #
#                        EXPLICIT RULES FOR MAKE
# ==================================================================== #

# To avoid any confusion with file names
.PHONY: depend lib fprg prg clean clobber echo info flags alllib newlib all new test

# To avoid any confusion, defined used file extensions (suffixes)
.SUFFIXES:
.SUFFIXES: .f .f90 .o .a .d .inc .mod

lib: $(DESTLIB)/$(LIBRARY)
	@:

test:
	@echo "--------------------------------------"
	@echo "SRC_FNAME = $(SRC_FNAME)"
	@echo "SRCF      = $(SRCF)"
	@echo "--------------------------------------"
	@echo "DEPF = $(DEPF)"
	@echo "MODF = $(MODF)"
	@echo "--------------------------------------"

# note: use calls to make to avoid conflicts with dependency files
newlib:
	@make clobber
	@make lib

all: lib $(MALLRULE)
	@:

new:
	@make clobber
	@make all

prg $(PROGRAM): $(DESTPRG)/$(PROGRAM)
	@:

$(DESTLIB)/$(LIBRARY): $(OBJLIB)
	@echo ---------------------------------------------------------------------------
	@echo -n "Updating archive ($(LIBRARY)) ... "
	@cd $(DESTOBJ); $(AR) $(ARFLAGS) $(DESTLIB)/$(LIBRARY) $(OBJF)
	@echo "done"
	@echo ---------------------------------------------------------------------------
	@echo "Library updated: $(LIBNAME)"
	@echo ---------------------------------------------------------------------------

# fprg = prg + link is forced even iwhen no dependency requires it
fprg $(DESTPRG)/$(PROGRAM): $(DESTLIB)/$(LIBRARY)
	@if [ -z $(MALLRULE) ]; then \
		echo "ERROR: Unknown program for library: $(LIB)"; \
		echo "Targets prg or fprg cannot be done: make stops!"; \
		test; \
	fi
	@echo ---------------------------------------------------------------------------
	@if [ -z "$(USR_OBJ)" ] && [ `basename $(CURDIR)` = "USAGER" ]; then \
		echo -e "WARNING: this user library does not define any object files!"; \
		echo ---------------------------------------------------------------------------; \
	fi
	@echo "Linking for program '$(PROGRAM)'... "
	$(F77) $(LDFLAGS) -o $(DESTPRG)/$(PROGRAM)
	@echo "done"
	@if [ $(CPLTOPT) = optimize ] && [ $(CADYFOPT) != profiling ] ; then \
		echo ---------------------------------------------------------------------------; \
		echo "Stripping program '$(PROGRAM)'... "; \
		strip $(DESTPRG)/$(PROGRAM); \
		echo "done"; \
	fi
	@echo ---------------------------------------------------------------------------
	@echo "Installed '$(PROGRAM)' in '$(DESTPRG)'"
	@echo ---------------------------------------------------------------------------

clean:
	@echo $(OBJLIB) $(DESTPRG)/$(PROGRAM) | xargs /bin/rm -f

clobber: clean
	@echo $(DESTINC)/*.inc | xargs /bin/rm -f
	@echo $(DEPF) | xargs /bin/rm -f
	@echo $(DEPI) | xargs /bin/rm -f
	@echo $(MODF) | xargs /bin/rm -f
	@echo $(DESTLIB)/$(LIBRARY) | xargs /bin/rm -f

cleandep:
	@echo $(DEPF) $(DEPI) | xargs /bin/rm -f

echo:
	@echo "------------------------------------"
	@echo "SOURCE FILES <----> DEPENDENCY FILES"
	@echo "------------------------------------"
	@for FILE in $(SRCF_FIXED_FORM); do echo "$$FILE <---> $(DESTDEP)/`basename $$FILE .f`.d"; done
	@for FILE in $(SRCF_FREE_FORM); do echo "$$FILE <---> $(DESTDEP)/`basename $$FILE .f90`.d"; done
	@echo "-------------------------------------"
	@echo "INCLUDE FILES <----> DEPENDENCY FILES"
	@echo "-------------------------------------"
	@for FILE in $(INCF); do echo "$$FILE <---> $(DESTDEP)/`basename $$FILE.d`"; done
	@echo "----------------------------"
	@echo "MACHINE-DEPENDENT FILES INFO"
	@echo "----------------------------"
	@for FILE in $(ARDINC); do \
		echo "$(DESTINC)/`basename $$FILE .inc_$(ATYPE)`.inc ---> $$FILE"; \
	done

flags:
	@echo "---------------------------------------------------------------------------"
	@echo " ARCHITECTURE TYPE : $(UNAME) ($(ATYPE))"
	@echo " OPTIMIZATION MODE : $(CPLTOPT)"
	@echo " COMPILER/LINKER   : $(F77)"
	@echo "---------------------------------------------------------------------------"
	@echo " COMPILER FLAGS"
	@echo "$(FFLAGS) $(COMP_FLAGS_MOD) $(FINCPATH)"
	@echo "---------------------------------------------------------------------------"
	@echo " LINKER FLAGS"
	@echo "$(LDFLAGS)"
	@echo "---------------------------------------------------------------------------"

info:
	@echo "---------------------------------------------------------------------------"
	@echo "                    Makefile for AMIRAL - CADYF - ADAPT                    "
	@echo "---------------------------------------------------------------------------"
	@echo " --> echo    : list dependency files                                       "
	@echo " --> info    : print this message                                          "
	@echo " --> flags   : show compiler and linker flags                              "
	@echo " --> depend  : update dependency files                                     "
	@echo " --> cleandep: remove dependency files                                     "
	@echo " --> lib     : compile all object files and update library archive         "
	@echo " --> prg     : update, if any, the program associated with the library     "
	@echo " --> fprg    : force 'prg' even if no dependency requires it               "
	@echo " --> clean   : remove architecture-dependent includes, objects and program "
	@echo " --> clobber : clean   + remove dependency and module files                "
	@echo "---------------------------------------------------------------------------"
	@echo " --> newlib  : clobber + lib                                               "
	@echo " --> all     : lib   ( + fprg )                                            "
	@echo " --> new     : clobber + all                                               "
	@echo "---------------------------------------------------------------------------"
	@echo " BUILD DIRECTORY       : $(HOME)/$(BUILDDIR)"
	@echo "---------------------------------------------------------------------------"
	@echo " ARCHITECTURE TYPE     : $(UNAME) ($(ATYPE))"
	@echo " OPTIMIZATION MODE     : $(CPLTOPT)"
	@echo " COMPILER/LINKER       : $(F77)"
	@echo " OPTION                : $(CADYFOPT)"
	@echo "---------------------------------------------------------------------------"
	@echo " PARDISO               : $(PARDISO_INFO)"
	@echo "---------------------------------------------------------------------------"
	@echo " LIBRARY NAME          : $(LIB)"
	@echo -n " USER OBJECT FILES     : "
	@[ -z "$(USR_OBJ)" ] && echo "none has been found" || echo "$(USR_OBJ_DIR)"
	@echo -n " ASSOCIATED EXECUTABLE : "
	@[ -z "$(MALLRULE)" ] && echo "none" || echo "$(PROGRAM)"
	@echo "---------------------------------------------------------------------------"
	@if [ -z "$(USR_OBJ)" ] && [ `basename $(CURDIR)` = "USAGER" ]; then \
		echo -e " WARNING: this user library does not define any object files!"; \
		echo ---------------------------------------------------------------------------; \
	fi

depend: $(DEPF) $(DEPI)
	@:

# rules to copy arch-dependent include files in build include directory
%.inc: %.inc_$(ATYPE)
	@[ -f $< ] && /bin/cp -f $< $(DESTINC)/$*.inc

# note: object file (%.o) added to compile one single file at a time
%.o $(DESTMOD)/%.mod: $(DESTOBJ)/%.o
	@:

$(DESTOBJ)/%.o: $(DESTDEP)/%.d
	@echo ---------------------------------------------------------------------------
#	@echo "Compiling target $@ (stem=$*)"
#	@echo " - first prerequisite is: $<"
#	@echo " - all prerequisites are: $^"
#	@echo " - newer prerequisites are: $?"
	$(F77) $(FFLAGS) -c $(SRC_$*_FNAME) -o $(DESTOBJ)/$*.o $(COMP_FLAGS_MOD) $(FINCPATH)
	@if [ -z "$(COMP_FLAGS_MOD)" ] && [ -f $*.mod ]; then /bin/mv -f $*.mod $(DESTMOD); fi

# note: add what follows to the compilation line above
#       in order to use "$CADYF_HOME/scripts/report_unusedvar.sh"
# 1>$*.compile.out 2>$*.compile.err

# ==================================================================== #
#                 MANAGE AND CREATE DEPENDENCY FILES
# ==================================================================== #

# Expand dependency files if necessary (to get target dependencies)
TARGETNODEP := $(filter depend test cleandep clean clobber echo info flags,$(MAKECMDGOALS))
ifeq ($(strip $(TARGETNODEP)),)
  DUMMYDEP:=$(shell make depend)
  -include $(DEPF)
  -include $(DEPI)
endif

$(DESTDEP)/%.inc.d: %.inc
	@echo ---------------------------------------------------------------------------
	@echo "Updating dependency file for $< : $@"
	$(shell \
		[ -f $< ] && prereq=$< || prereq=$(DESTINC)/$<; \
		fnosuf=`basename $< .inc`; \
		inc='[i|I][n|N][c|C][l|L][u|U][d|D][e|E]'; \
		lstinc=`sed -n '/^[ ]*'$$inc'[ ]\{1,\}.*/p' $$prereq | cut -d\' -f2 | cut -d\" -f2`; \
		lstincdef=""; \
		for incfile in $$lstinc; do \
			lstincdef="$$lstincdef $$incfile $(DESTDEP)/$$incfile.d"; \
		done; \
		echo "$$fnosuf.inc $(DESTDEP)/$$fnosuf.inc.d : $$lstincdef" > $@; \
	)

# note: do not use file name variables in prerequisite list;
#       this geature is buggy in gmake
#
# to expand twice the prerequisites list below
#.SECONDEXPANSION:
#$(DESTDEP)/%.d: $$(SRC_%_FNAME)
#

$(DESTDEP)/%.d: %.f
	@echo ---------------------------------------------------------------------------
	@echo "Updating dependency file for $< : $@"
	$(shell \
		prereq=$<; \
		[ "`basename $$prereq .f`.f" = "$$prereq" ] && EXT=".f" || EXT=".f90"; \
		fnosuf=`basename $< $$EXT`; \
		mod='[u|U][s|S][e|E]'; \
		lstmod=`sed -n '/^[ ]*'$$mod'[ ]\{1,\}.*/p' $< | \
				sed 's/^[ ]*'$$mod'[ ]*//g' | \
				sed 's/[ \,\&\!\\].*//g'`; \
		lstmoddef=""; \
		for rawmf in $$lstmod; do \
			modfile=`echo "$$rawmf" | tr '[:upper:]' '[:lower:]'`; \
			ignore=false; \
			for ignmod in $(IGNORE_MOD_DEPS); do \
				if [ "$$ignmod" == "$$modfile" ]; then \
					ignore=true; \
					break; \
				fi; \
			done; \
			if ! $$ignore; then \
				lstmoddef="$$lstmoddef $(DESTMOD)/$$modfile.mod"; \
			fi; \
		done; \
		inc='[i|I][n|N][c|C][l|L][u|U][d|D][e|E]'; \
		lstinc=`sed -n '/^[ ]*'$$inc'[ ]\{1,\}.*/p' $< | cut -d\' -f2 | cut -d\" -f2`; \
		lstincdef=""; \
		for incfile in $$lstinc; do \
			lstincdef="$$lstincdef $$incfile $(DESTDEP)/$$incfile.d"; \
		done; \
		if [ -z "$$lstincdef" ]; then \
			echo "$(DESTOBJ)/$$fnosuf.o : $$lstmoddef" > $@; \
		else \
			echo "$(DESTOBJ)/$$fnosuf.o $(DESTDEP)/$$fnosuf.d : $$lstmoddef $$lstincdef" > $@; \
		fi; \
	)

$(DESTDEP)/%.d: %.f90
	@echo ---------------------------------------------------------------------------
	@echo "Updating dependency file for $< : $@"
	$(shell \
		prereq=$<; \
		[ "`basename $$prereq .f`.f" = "$$prereq" ] && EXT=".f" || EXT=".f90"; \
		fnosuf=`basename $< $$EXT`; \
		mod='[u|U][s|S][e|E]'; \
		lstmod=`sed -n '/^[ ]*'$$mod'[ ]\{1,\}.*/p' $< | \
				sed 's/^[ ]*'$$mod'[ ]*//g' | \
				sed 's/[ \,\&\!\\].*//g'`; \
		lstmoddef=""; \
		for rawmf in $$lstmod; do \
			modfile=`echo "$$rawmf" | tr '[:upper:]' '[:lower:]'`; \
			ignore=false; \
			for ignmod in $(IGNORE_MOD_DEPS); do \
				if [ "$$ignmod" == "$$modfile" ]; then \
					ignore=true; \
					break; \
				fi; \
			done; \
			if ! $$ignore; then \
				lstmoddef="$$lstmoddef $(DESTMOD)/$$modfile.mod"; \
			fi; \
		done; \
		inc='[i|I][n|N][c|C][l|L][u|U][d|D][e|E]'; \
		lstinc=`sed -n '/^[ ]*'$$inc'[ ]\{1,\}.*/p' $< | cut -d\' -f2 | cut -d\" -f2`; \
		lstincdef=""; \
		for incfile in $$lstinc; do \
			lstincdef="$$lstincdef $$incfile $(DESTDEP)/$$incfile.d"; \
		done; \
		if [ -z "$$lstincdef" ]; then \
			echo "$(DESTOBJ)/$$fnosuf.o : $$lstmoddef" > $@; \
		else \
			echo "$(DESTOBJ)/$$fnosuf.o $(DESTDEP)/$$fnosuf.d : $$lstmoddef $$lstincdef" > $@; \
		fi; \
	)

#
# notes sur la gestion des dependances :
#
# [1] le schema de base est qu'un .mod depend de son .o, qui depend de son .d,
#     qui depend de son .f (cf. regles explicites ci-dessus);
#     un .mod doit dependre de son .o pour compiler dans le bon ordre;
#
# [2] a travers les fichiers de dependances, le .o d'un .f depend
#       (1) des includes necessaires au .f (evident) et leurs fichiers de
#           dependances (pour les includes dans les includes),
#       (2) des .mod des modules utilises mais pas directement des .o de ces
#           modules car si le fichier source du module a change sans que la
#           definition du module ait change, il n'est pas necessaire de
#           recompiler les .f utilisant ce module (aussi, en faisant ainsi,
#           cela permet de recompiler des .f dependant de modules definis
#           dans d'autres librairies);
#
# [3] le fichier de dependances d'un .f ne depend pas des modules utilises dans
#     ce .f car la compilation d'un nouveau .mod ne change pas les dependances;
#     par contre, le fichier de dependances d'un .f doit dependre des includes
#     necessaires a ce .f (et de leurs fichiers de dependances) pour les
#     includes dans les includes.
#

