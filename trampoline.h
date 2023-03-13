#include <stdio.h>
#include <stdlib.h>

#include <ISO_Fortran_binding.h>

#include "flangf90.h"

static inline int cfi_to_flang_kind(CFI_type_t type)
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

static inline void cfi_to_flang_desc(const CFI_cdesc_t * d, F90_Desc_la * p)
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
    p->kind = cfi_to_flang_kind(d->type);

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
