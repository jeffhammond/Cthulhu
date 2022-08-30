#include <stdio.h>
#include <stdlib.h>

#include <ISO_Fortran_binding.h>

#include "pgif90.h"

#include "trampoline.h"

// declaration of the Fortran subroutine we are going to call
void nstream_length(int64_t length, double scalar,
                   double A[restrict length], double B[restrict length], double C[restrict length]);
void nstream_star(int64_t length, double scalar,
                   double * restrict A, double * restrict B, double * restrict C);

// NVHPC Fortran calling convention for arrays
void nstream_colon(int64_t length, double scalar,
                   double * restrict A,
                   double * restrict B,
                   double * restrict C,
                   F90_Desc_la * pA,
                   F90_Desc_la * pB,
                   F90_Desc_la * pC);

void nstream_colon_trampoline(int64_t length, double scalar, 
                              CFI_cdesc_t * dA, CFI_cdesc_t * dB, CFI_cdesc_t * dC)
{
    double * restrict A = dA->base_addr;
    double * restrict B = dB->base_addr;
    double * restrict C = dC->base_addr;
#if 0
    //nstream_length(length, scalar, A, B, C);
    //nstream_star(length, scalar, A, B, C);
#else
    F90_Desc_la pA={0}, pB={0}, pC={0};
    cfi_to_pgi_desc(dA,&pA);
    cfi_to_pgi_desc(dB,&pB);
    cfi_to_pgi_desc(dC,&pC);
    nstream_colon(length, scalar, A, B, C, &pA, &pB, &pC);
#endif
}
