/*
    This file is part of ParTI!.

    ParTI! is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    ParTI! is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with ParTI!.
    If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef PARTI_SPTENSOR_H
#define PARTI_SPTENSOR_H

#ifdef __cplusplus
extern "C" {
#endif

#include <ParTI.h>
#include "../error/error.h"

int spt_SparseTensorCompareIndices(const sptSparseTensor *tsr1, size_t ind1, const sptSparseTensor *tsr2, size_t ind2);

void spt_SparseTensorCollectZeros(sptSparseTensor *tsr);

int spt_DistSparseTensor(sptSparseTensor * tsr,
    int const nthreads,
    size_t * const dist_nnzs,
    size_t * dist_nrows);

int spt_DistSparseTensorFixed(sptSparseTensor * tsr,
    int const nthreads,
    size_t * const dist_nnzs,
    size_t * dist_nrows);

int spt_SliceSparseTensor(sptSparseTensor *dest, const sptSparseTensor *tsr, const size_t limit_low[], const size_t limit_high[]);

typedef struct spt_TagSplitStatus *spt_SplitStatus;
int spt_StartSplitSparseTensor(spt_SplitStatus *status, const sptSparseTensor *tsr, const size_t cuts_by_mode[]);
int spt_SplitSparseTensor(sptSparseTensor *dest, spt_SplitStatus status);
void spt_FinishSplitSparseTensor(spt_SplitStatus status);

#ifdef __cplusplus
}
#endif

#endif
