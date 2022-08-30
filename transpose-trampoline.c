#include <stdio.h>
#include <stdlib.h>

#include <ISO_Fortran_binding.h>

#include "pgif90.h"

#include "trampoline.h"

// NVHPC Fortran calling convention for arrays
void transpose_colon(int32_t block_order,
                     double * restrict TA, double * restrict TB,
                     F90_Desc_la * pTA, F90_Desc_la * pTB);

void transpose_colon_trampoline(int32_t block_order, CFI_cdesc_t * dTA, CFI_cdesc_t * dTB)
{
    double * restrict TA = dTA->base_addr;
    double * restrict TB = dTB->base_addr;
    F90_Desc_la pTA={0}, pTB={0};
    cfi_to_pgi_desc(dTA,&pTA);
    cfi_to_pgi_desc(dTB,&pTB);
    transpose_colon(block_order, TA, TB, &pTA, &pTB);
}
