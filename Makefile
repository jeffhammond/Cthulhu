# Coarray compiler
CAFC       = gfortran
CAFCFLAGS  = -O2 -Wall
CAFCFLAGS += -fcoarray=single
CAFCFLAGS += -Wno-c-binding-type
CAFLIBS    = -lgfortran

# Do Concurrent compiler
NVHPCVERS  = 22.7
DCFC       = nvfortran
DCFCFLAGS  = -stdpar=gpu -O2 -fPIE
#DCFCLIBS   = -L/opt/nvidia/hpc_sdk/Linux_$$(uname -m)/$(NVHPCVERS)/compilers/lib/ \
#             -lacccuda -lacchost -laccdevice -lnvomp -lnvc -lnvcpumath -laccdevaux
#DCFCLIBS  += -L/opt/nvidia/hpc_sdk/Linux_x86_64/22.7/REDIST/cuda/11.7/targets/x86_64-linux/lib/stubs -lcuda
DCLIBS      = -fortranlibs

# C compiler for linking - use NVHPC since it knows all the GPU library dependencies
CC         = nvc
CFLAGS     = -O2 -Wall -acc=gpu

all: nstream-coarray.x

nstream-coarray.x: nstream-coarray.o prk_mod.o nstream-kernel-interfaces.o nstream-kernel-implementations.o
	$(CC) $(CFLAGS) $^ $(DCFCLIBS) $(CAFLIBS) -o $@

nstream-coarray.o: nstream-coarray.F90 prk.mod nski.mod
	$(CAFC) $(CAFCFLAGS) -c $< -o $@

prk.mod prk_mod.o: prk_mod.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o prk_mod.o

nstream-kernel-interfaces.o nski.mod: nstream-kernel-interfaces.F90
	$(CAFC) $(CAFCFLAGS) -c $< -o nstream-kernel-interfaces.o

nstream-kernel-implementations.o: nstream-kernel-implementations.F90
	$(DCFC) $(DCFCFLAGS) -c $< -o $@

clean:
	-rm -f *.o *.x *.mod
