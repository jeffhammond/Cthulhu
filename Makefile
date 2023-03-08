# Coarray compiler
CAFC       = gfortran
CAFCFLAGS  = -O2 -Wall
CAFCFLAGS += -g3
CAFCFLAGS += -fcoarray=single
CAFCFLAGS += -Wno-c-binding-type
CAFLIBS    = -lgfortran

# Do Concurrent compiler
TARGET     = gpu
NVHPCVERS  = 22.11
DCFC       = nvfortran
DCFCFLAGS  = -O2 -fPIE
DCFCFLAGS += -g
DCFCFLAGS += -stdpar=$(TARGET)
DCLIBS     = -fortranlibs # NVC only

# C compiler for linking - use NVHPC since it knows all the GPU library dependencies
CC         = nvc
CFLAGS     = -O2 -Wall
CFLAGS    += -g
CFLAGS    += -acc=$(TARGET)

all: nstream-coarray.x transpose-coarray.x

prk.mod prk_mod.o: prk_mod.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o prk_mod.o

nstream-coarray.x: nstream-coarray.o prk_mod.o \
                   nstream-kernel-interfaces.o \
                   nstream-kernel-implementations.o nstream-trampoline.o
	$(CC) $(CFLAGS) $^ $(DCLIBS) $(CAFLIBS) -o $@

nstream-coarray.o: nstream-coarray.F90 prk.mod nski.mod
	$(CAFC) $(CAFCFLAGS) -c $< -o $@

nstream-kernel-interfaces.o nski.mod: nstream-kernel-interfaces.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o nstream-kernel-interfaces.o

nstream-kernel-implementations.o: nstream-kernel-implementations.F90
	$(DCFC) $(DCFCFLAGS) -c $< -o $@

nstream-trampoline.o: nstream-trampoline.c trampoline.h
	$(CC) $(CFLAGS) -c $< -o $@

transpose-coarray.x: transpose-coarray.o prk_mod.o \
                     transpose-kernel-interfaces.o \
                     transpose-kernel-implementations.o transpose-trampoline.o
	$(CC) $(CFLAGS) $^ $(DCLIBS) $(CAFLIBS) -o $@

transpose-coarray.o: transpose-coarray.F90 prk.mod tki.mod
	$(CAFC) $(CAFCFLAGS) -c $< -o $@

transpose-kernel-interfaces.o tki.mod: transpose-kernel-interfaces.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o transpose-kernel-interfaces.o

transpose-kernel-implementations.o: transpose-kernel-implementations.F90
	$(DCFC) $(DCFCFLAGS) -c $< -o $@

transpose-trampoline.o: transpose-trampoline.c trampoline.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	-rm -f *.o *.x *.mod
