# Coarray compiler
CAFC       = gfortran
CAFCFLAGS  = -O2 -Wall
CAFCFLAGS += -fcoarray=single
CAFCFLAGS += -Wno-c-binding-type

# Do Concurrent compiler
DCFC       = nvfortran
DCFCFLAGS  = -stdpar=gpu -O2

all: nstream-coarray.x

%.x: %.o prk_mod.o nstream-kernel-interfaces.o
	$(CAFC) $(CAFCFLAGS) $^ -o $@

%.o: %.F90 prk.mod nski.mod
	$(CAFC) $(CAFCFLAGS) -c $< -o $@

prk.mod prk_mod.o: prk_mod.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o prk_mod.o

nstream-kernel-interfaces.o nski.mod: nstream-kernel-interfaces.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o nstream-kernel-interfaces.o

clean:
	-rm -f *.o *.x *.mod
