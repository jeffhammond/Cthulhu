#include <ISO_Fortran_binding.h>
#include "pgif90.h"

// declaration of the Fortran subroutine we are going to call
void nstream_length(int64_t length, double scalar,
                   double A[restrict length], double B[restrict length], double C[restrict length]);
void nstream_star(int64_t length, double scalar,
                   double * restrict A, double * restrict B, double * restrict C);
void nstream_colon(int64_t length, double scalar,
                   double * restrict A, double * restrict B, double * restrict C,
                   F90_Desc_la * pA, F90_Desc_la * pB, F90_Desc_la * pC);

void nstream_colon_trampoline(int64_t length, double scalar, 
                              CFI_cdesc_t * dA, CFI_cdesc_t * dB, CFI_cdesc_t * dC)
{











}
