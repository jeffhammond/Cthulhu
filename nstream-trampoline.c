#include <stdio.h>
#include <stdlib.h>

#include <ISO_Fortran_binding.h>

#include "pgif90.h"

int cfi_to_pgi_kind(CFI_type_t type);
void cfi_to_pgi_desc(const CFI_cdesc_t * d, F90_Desc_la * p);

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

void cfi_to_pgi_desc(const CFI_cdesc_t * d, F90_Desc_la * p)
{
    // this is the ABI version (?)
    p->tag  = 35;

    // array ranks are equivalent
    const int dim = p->rank = (int)d->rank;
    if (dim > MAXDIMS) {
        fprintf(stderr,"NVHPC Fortran does not support arrays of rank > %d\n",MAXDIMS);
        abort();
    }

    // convert CFI types to PGI types
    p->kind = cfi_to_pgi_kind(d->type);

    // size of an element in bytes
    const int len = p->len  = d->elem_len;

    p->lbase = 1;
    p->gbase = NULL;

    for (int i=0; i<dim; i++) {
        p->dim[i].lbound  = (int)d->dim[i].lower_bound;
        p->dim[i].extent  = (int)d->dim[i].extent;
        p->dim[i].sstride = 1;
        p->dim[i].soffset = 0;
        p->dim[i].lstride = (int)d->dim[i].sm / len;
        p->dim[i].ubound  = p->dim[i].lbound + p->dim[i].extent;

        p->lbase -= p->dim[i].lbound * p->dim[i].lstride;
        p->lsize *= p->dim[i].extent;
    }

    p->gsize = p->lsize;
}

int cfi_to_pgi_kind(CFI_type_t type)
{
         if (type==CFI_type_signed_char)          return 14;
    else if (type==CFI_type_size_t)               return 26;
    else if (type==CFI_type_int8_t)               return 32;
    else if (type==CFI_type_int16_t)              return 24;
    else if (type==CFI_type_int32_t)              return 25;
    else if (type==CFI_type_int64_t)              return 26;
    else if (type==CFI_type_float)                return 27;
    else if (type==CFI_type_double)               return 28;
    else if (type==CFI_type_float_Complex)        return  9;
    else if (type==CFI_type_double_Complex)       return 10;
    else                                          return -1;
}
