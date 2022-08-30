#include <stdio.h>
#include <stdlib.h>

#include <ISO_Fortran_binding.h>

#include "pgif90.h"

#include "trampoline.h"

// declaration of the Fortran subroutine we are going to call
void transpose_order(int64_t order, int64_t block_order, int64_t col_start,
                     double * restrict T, double * restrict B);

// NVHPC Fortran calling convention for arrays
void transpose_colon(int64_t order, int64_t block_order, int64_t col_start,
                     double * restrict T, double * restrict B,
                     F90_Desc_la * pT, F90_Desc_la * pB);

void transpose_colon_trampoline(int64_t order, int64_t block_order, int64_t col_start,
                              CFI_cdesc_t * dT, CFI_cdesc_t * dB)
{
    double * restrict T = dT->base_addr;
    double * restrict B = dB->base_addr;
#if 1
    transpose_order(order, block_order, col_start, T, B);
#else
    F90_Desc_la pA={0}, pB={0}, pC={0};
    cfi_to_pgi_desc(dA,&pA);
    cfi_to_pgi_desc(dB,&pB);
    cfi_to_pgi_desc(dC,&pC);
    transpose_colon(order, scalar, A, B, C, &pA, &pB, &pC);
#endif
}
