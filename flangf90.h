/*
 * Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
 * See https://llvm.org/LICENSE.txt for license information.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 */

// from https://github.com/flang-compiler/flang/blob/master/runtime/flang/fioMacros.h
//      https://github.com/flang-compiler/flang/blob/master/runtime/flang/fortDt.h

#ifndef FLANGF90_H_
#define FLANGF90_H_

#define MAXDIMS 7

#define POINT(type, name) type *name

typedef long long __INT_T;

typedef struct F90_Desc F90_Desc;
typedef struct F90_DescDim F90_DescDim;
typedef struct DIST_Desc DIST_Desc;
typedef struct DIST_DescDim DIST_DescDim;

/** \brief Fortran descriptor dimension info 
 *
 * Each F90_Desc structure below has up to \ref MAXDIMS number of F90_DescDim
 * structures that correspond to each dimension of an array. Each F90_DescDim 
 * has 6 fields: \ref lbound, \ref extent, \ref sstride, \ref soffset, 
 * \ref lstride, and \ref ubound.
 *
 * The \ref lbound field is the lowerbound of the dimension.
 *
 * The \ref extent field is the extent of the dimension (e.g., 
 * extent = max((ubound - lbound) + 1), 0).
 *
 * Fields \ref sstride (i.e., section index stride on array) and \ref soffset
 * (i.e., section offset onto array) are not needed in the Fortran runtime.
 * They were needed in languages like HPF. For Fortran, their corresponding
 * macros, \ref F90_DPTR_SSTRIDE_G and \ref F90_DPTR_SOFFSET_G are set to 
 * constants (see below). However, we still need to preserve the space in 
 * F90_DescDim for backward compatibility.
 *
 * The field \ref lstride is the "section index multiplier" for the dimension. 
 * It is used in the mapping of an array section dimension to its original 
 * array. See the __fort_finish_descriptor() runtime routine in dist.c for an 
 * example of how to compute this field. See the print_loop() runtime routine
 * in dbug.c for an example of how to use this field.
 *
 * The \ref ubound field is the upperbound of the dimension.
 */
struct F90_DescDim {/* descriptor dimension info */

  __INT_T lbound;  /**< (1) lower bound */
  __INT_T extent;  /**< (2) array extent */
  __INT_T sstride; /**< (3) reserved */
  __INT_T soffset; /**< (4) reserved */
  __INT_T lstride; /**< (5) section index multiplier */
  __INT_T ubound;  /**< (6) upper bound */
};

/* type descriptor forward reference. Declared in type.h */
typedef struct type_desc TYPE_DESC;

/** \brief Fortran descriptor header 
 *
 * The fields minus F90_DescDim below should remain consistent
 * with the object_desc and proc_desc structures of type.h in terms of length 
 * and type. These fields are also mirrored in the Fortran Front-end's
 * rte.h header file.
 *
 * The \ref tag field is used to identify the type of the descriptor. This is
 * typically \ref __DESC, which identifies the descriptor as a regular array
 * section descriptor. If the tag is a basic type, such as an \ref __INT4, 
 * \ref__REAL4, etc. then it is a 1 word pseudo descriptor. The pseudo
 * descriptor is used as a place holder when we want to pass a scalar into a 
 * runtime routine that also requires a descriptor argument.  When tag is
 * \ref __POLY, then we have an object_desc (see its definition in type.h). 
 * When tag is \ref __PROCPTR, we have a proc_desc (see its definition in 
 * type.h). 
 *
 * The \ref rank field equals the total number of dimensions of the associated
 * array. If rank is 0, then this descriptor may be associated with a
 * derived type object, a pointer to a derived type object, or an
 * allocatable scalar.
 * 
 * The \ref kind field holds the base type of the associated array. It is one
 * of the basic types defined in \ref _DIST_TYPE.
 *
 * The \ref flags field holds various descriptor flags defined above. Most of
 * the flags defined above, denoted as reserved,  are not used for Fortran. 
 * The flags that are typically used for Fortran are \ref __ASSUMED_SIZE and 
 * \ref __ASSUMED_SHAPE.
 *
 * The \ref len field holds the byte length of the associated array's base type
 * (see also kind field).
 *
 * The \ref lsize field holds the total number of elements in the associated 
 * array section.
 *
 * In distributed memory languages, such as HPF, \ref gsize represents the total
 * number of elements that are distributed across multiple processors. In 
 * Fortran, the \ref lsize and \ref gsize fields are usually the same, however 
 * this is a case in the reshape intrinsic where \ref gsize != \ref lsize. There
 * may just be an incidental difference during the execution of reshape. There 
 * may also be others in the Fortran runtime where \ref gsize != \ref lsize, 
 * however, they too may just be incidental differences. Therefore, use 
 * \ref lsize instead of \ref gsize when querying the total number of elements
 * in a Fortran array.
 *
 * The \ref lbase field is the index offset section adjustment. It is used in 
 * the mapping of an array section to its original array.  
 * See the \ref __DIST_SET_SECTIONXX and \ref __DIST_SET_SECTIONX macros below  
 * for examples of how to compute this field. See the __fort_print_local() 
 * runtime routine in dbug.c for an example of how to use this field.
 *
 * The \ref gbase field historically was used in distributed memory languages 
 * like HPF. Therefore, \ref gbase is usually 0 and may always be 0 in the  
 * Fortran runtime (needs more investigation to confirm if it's always 0 in 
 * this case).
 *
 * When set, the \ref dist_desc field holds a pointer to the type descriptor of
 * the associated object (see also the \ref TYPE_DESC definition in type.h). 
 *
 * The \ref dim fields hold up to \ref number of F90_DescDim structures. It's
 * also possible that \ref dim is empty when this descriptor is associated with
 * a derived type, a pointer to a derived type, or an allocatable scalar.
 *
 * The number in paranthesis for each field below corresponds with the
 * subscript index in the descriptor. The first 9 values are denoted. 
 * The first index is 1 because we assume Fortran style arrays when we
 * reference these fields in the Fortran front-end. When generating assembly,
 * the first index will be 0. After the gbase field,
 * the subscript value depends on three conditions: Whether the target's
 * pointers are 64-bit, whether the target's native integers are 64-bit, 
 * and whether large arrays are enabled. See the \ref DESC_HDR_LEN macro
 * in the Fortran front-end's rte.h file for more information. The first
 * 9 subscript values are also mirrored in the following macros in
 * rte.h: \ref DESC_HDR_TAG, \ref DESC_HDR_RANK, \ref DESC_HDR_KIND, 
 * \ref DESC_HDR_BYTE_LEN, \ref DESC_HDR_FLAGS, \ref DESC_HDR_LSIZE, 
 * \ref DESC_HDR_GSIZE, \ref DESC_HDR_LBASE, and \ref DESC_HDR_GBASE.
 *
 */
struct F90_Desc {

  __INT_T tag;                 /**< (1) tag field; usually \ref __DESC 
                                        (see also _DIST_TYPE) */
  __INT_T rank;                /**< (2) array section rank */
  __INT_T kind;                /**< (3) array base type */
  __INT_T len;                 /**< (4) byte length of base type */
  __INT_T flags;               /**< (5) descriptor flags */
  __INT_T lsize;               /**< (6) local array section size */
  __INT_T gsize;               /**< (7) global array section size 
                                        (usually same as \ref lsize) */
  __INT_T lbase;               /**< (8) index offset section adjustment */
  POINT(__INT_T, gbase);       /**< (9) global offset of first element of 
                                        section (usually 0) */
  POINT(TYPE_DESC, dist_desc); /**<     When set, this is a pointer to the 
                                        object's type descriptor */
  F90_DescDim dim[MAXDIMS];    /**<     F90 dimensions (Note: We append
                                        \ref rank number of F90_DescDim 
                                        structures to an F90_Desc structure) */
};

#endif // FLANGF90_H_
