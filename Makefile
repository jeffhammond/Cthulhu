# Coarray compiler
CAFC      = gfortran
CAFCFLAGS = -fcoarray=single -Wall -O2

# Do Concurrent compiler
DCFC      = nvfortran
DCFCFLAGS = -stdpar=gpu -O2

all: nstream-coarray.x

%.x: %.o prk_mod.o
	$(CAFC) $(CAFCFLAGS) $^ -o $@

%.o: %.F90 prk.mod
	$(CAFC) $(CAFCFLAGS) -c $< -o $@

prk.mod prk_mod.o: prk_mod.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o prk_mod.o

clean:
	-rm -f *.o *.x *.mod
