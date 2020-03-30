/*********************                                                        */
/*! \file rewrites.h
 ** \verbatim
 ** Top contributors (to current version):
 **   Andrew Reynolds
 ** This file is part of the CVC4 project.
 ** Copyright (c) 2009-2019 by the authors listed in the file AUTHORS
 ** in the top-level source directory) and their institutional affiliations.
 ** All rights reserved.  See the file COPYING in the top-level source
 ** directory for licensing information.\endverbatim
 **
 ** \brief Type for rewrites for strings.
 **/

#include "cvc4_private.h"

#ifndef CVC4__THEORY__STRINGS__REWRITES_H
#define CVC4__THEORY__STRINGS__REWRITES_H

#include <iosfwd>

namespace CVC4 {
namespace theory {
namespace strings {

/** Types of rewrites used by strings
 *
 * This rewrites are documented where they are used in the rewriter.
 */
enum class Rewrite : uint32_t
{
  CTN_COMPONENT,
  CTN_CONCAT_CHAR,
  CTN_CONST,
  CTN_EQ,
  CTN_LEN_INEQ,
  CTN_LEN_INEQ_NSTRICT,
  CTN_LHS_EMPTYSTR,
  CTN_MSET_NSS,
  CTN_NCONST_CTN_CONCAT,
  CTN_REPL,
  CTN_REPL_CHAR,
  CTN_REPL_CNSTS_TO_CTN,
  CTN_REPL_EMPTY,
  CTN_REPL_LEN_ONE_TO_CTN,
  CTN_REPL_SELF,
  CTN_REPL_SIMP_REPL,
  CTN_REPL_TO_CTN,
  CTN_REPL_TO_CTN_DISJ,
  CTN_RHS_EMPTYSTR,
  CTN_RPL_NON_CTN,
  CTN_SPLIT,
  CTN_SPLIT_ONES,
  CTN_STRIP_ENDPT,
  CTN_SUBSTR,
  EQ_LEN_DEQ,
  EQ_NCTN,
  EQ_NFIX,
  FROM_CODE_EVAL,
  IDOF_DEF_CTN,
  IDOF_EMP_IDOF,
  IDOF_EQ_CST_START,
  IDOF_EQ_NORM,
  IDOF_EQ_NSTART,
  IDOF_FIND,
  IDOF_LEN,
  IDOF_MAX,
  IDOF_NCTN,
  IDOF_NEG,
  IDOF_NFIND,
  IDOF_NORM_PREFIX,
  IDOF_PULL_ENDPT,
  IDOF_STRIP_CNST_ENDPTS,
  IDOF_STRIP_SYM_LEN,
  ITOS_EVAL,
  RE_AND_EMPTY,
  RE_ANDOR_FLATTEN,
  RE_CHAR_IN_STR_STAR,
  RE_CONCAT,
  RE_CONCAT_FLATTEN,
  RE_CONCAT_OPT,
  RE_CONCAT_PURE_ALLCHAR,
  RE_CONCAT_TO_CONTAINS,
  RE_EMPTY_IN_STR_STAR,
  RE_IN_DIST_CHAR_STAR,
  RE_IN_SIGMA_STAR,
  RE_LOOP,
  RE_LOOP_STAR,
  RE_OR_ALL,
  RE_SIMPLE_CONSUME,
  RE_STAR_EMPTY,
  RE_STAR_EMPTY_STRING,
  RE_STAR_NESTED_STAR,
  RE_STAR_UNION,
  REPL_CHAR_NCONTRIB_FIND,
  REPL_DUAL_REPL_ITE,
  REPL_REPL_SHORT_CIRCUIT,
  REPL_REPL2_INV,
  REPL_REPL2_INV_ID,
  REPL_REPL3_INV,
  REPL_REPL3_INV_ID,
  REPL_SUBST_IDX,
  REPLALL_CONST,
  REPLALL_EMPTY_FIND,
  RPL_CCTN,
  RPL_CCTN_RPL,
  RPL_CNTS_SUBSTS,
  RPL_CONST_FIND,
  RPL_CONST_NFIND,
  RPL_EMP_CNTS_SUBSTS,
  RPL_ID,
  RPL_NCTN,
  RPL_PULL_ENDPT,
  RPL_REPLACE,
  RPL_RPL_EMPTY,
  RPL_RPL_LEN_ID,
  RPL_X_Y_X_SIMP,
  SPLIT_EQ,
  SPLIT_EQ_STRIP_L,
  SPLIT_EQ_STRIP_R,
  SS_COMBINE,
  SS_CONST_END_OOB,
  SS_CONST_LEN_MAX_OOB,
  SS_CONST_LEN_NON_POS,
  SS_CONST_SS,
  SS_CONST_START_MAX_OOB,
  SS_CONST_START_NEG,
  SS_CONST_START_OOB,
  SS_EMPTYSTR,
  SS_END_PT_NORM,
  SS_GEQ_ZERO_START_ENTAILS_EMP_S,
  SS_LEN_INCLUDE,
  SS_LEN_NON_POS,
  SS_LEN_ONE_Z_Z,
  SS_NON_ZERO_LEN_ENTAILS_OOB,
  SS_START_ENTAILS_ZERO_LEN,
  SS_START_GEQ_LEN,
  SS_START_NEG,
  SS_STRIP_END_PT,
  SS_STRIP_START_PT,
  STOI_CONCAT_NONNUM,
  STOI_EVAL,
  STR_CONV_CONST,
  STR_CONV_IDEM,
  STR_CONV_ITOS,
  STR_CONV_MINSCOPE_CONCAT,
  STR_EMP_REPL_EMP,
  STR_EMP_REPL_EMP_R,
  STR_EMP_REPL_X_Y_X,
  STR_EMP_SUBSTR_ELIM,
  STR_EMP_SUBSTR_LEQ_LEN,
  STR_EMP_SUBSTR_LEQ_Z,
  STR_EQ_CONJ_LEN_ENTAIL,
  STR_EQ_CONST_NHOMOG,
  STR_EQ_HOMOG_CONST,
  STR_EQ_REPL_EMP,
  STR_EQ_REPL_NOT_CTN,
  STR_EQ_REPL_TO_DIS,
  STR_EQ_REPL_TO_EQ,
  STR_EQ_UNIFY,
  STR_LEQ_CPREFIX,
  STR_LEQ_EMPTY,
  STR_LEQ_EVAL,
  STR_LEQ_ID,
  STR_REV_CONST,
  STR_REV_IDEM,
  STR_REV_MINSCOPE_CONCAT,
  SUBSTR_REPL_SWAP,
  SUF_PREFIX_CONST,
  SUF_PREFIX_CTN,
  SUF_PREFIX_EMPTY,
  SUF_PREFIX_EMPTY_CONST,
  SUF_PREFIX_EQ,
  SUF_PREFIX_TO_EQS,
  TO_CODE_EVAL
};

/**
 * Converts an rewrite to a string. Note: This function is also used in
 * `safe_print()`. Changing this functions name or signature will result in
 * `safe_print()` printing "<unsupported>" instead of the proper strings for
 * the enum values.
 *
 * @param r The rewrite
 * @return The name of the rewrite
 */
const char* toString(Rewrite r);

/**
 * Writes an rewrite name to a stream.
 *
 * @param out The stream to write to
 * @param r The rewrite to write to the stream
 * @return The stream
 */
std::ostream& operator<<(std::ostream& out, Rewrite r);

}  // namespace strings
}  // namespace theory
}  // namespace CVC4

#endif /* CVC4__THEORY__STRINGS__REWRITES_H */