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

#include <ParTI.h>
#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"
#include "mex.h"
#include "sptmx.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    spt_mxCheckArgs("sptDumpKruskalTensor", 0, "No", 3, "Three");

    sptKruskalTensor *ktsr = spt_mxGetPointer(prhs[0], 0);
    size_t start_idx = mxGetScalar(prhs[1]);
    char *fn = mxArrayToString(prhs[2]);
    FILE *fp = fopen(fn, "w");
    mxFree(fn);
    if(!fp) {
        mexErrMsgIdAndTxt("ParTI:sptDumpKruskalTensor", "Cannot open file.");
    }

    int result = sptDumpKruskalTensor(ktsr, start_idx, fp);
    fclose(fp);
}
