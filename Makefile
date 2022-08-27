# Coarray compiler
CAFC      = gfortran
CAFCFLAGS = -fcoarray=single -Wall -O2

# Do Concurrent compiler
DCFC      = nvfortran
DCFCFLAGS = -stdpar=gpu -O2

all: main.x

main.x: main.o
	$(CAFC) $(CAFCFLAGS) $^ -o $@

main.o: main.F90
	$(CAFC) $(CAFCFLAGS) -c $^ -o $@

clean:
	-rm -f *.o *.x *.mod
