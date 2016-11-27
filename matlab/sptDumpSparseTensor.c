/*
    This file is part of SpTOL.

    SpTOL is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    SpTOL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with SpTOL.
    If not, see <http://www.gnu.org/licenses/>.
*/

#include <SpTOL.h>
#include <stdio.h>
#include <stdlib.h>
#include "matrix.h"
#include "mex.h"
#include "sptmx.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    spt_mxCheckArgs("sptDumpSparseTensor", 0, "No", 3, "Three");

    sptSparseTensor *tsr = spt_mxGetPointer(prhs[0]);
    size_t start_idx = mxGetScalar(prhs[1]);
    char *fn = mxArrayToString(prhs[2]);
    FILE *fp = fopen(fn, "w");
    mxFree(fn);
    if(!fp) {
        mexErrMsgIdAndTxt("SpTOL:sptDumpSparseTensor", "Cannot open file.");
    }

    int result = sptDumpSparseTensor(tsr, start_idx, fp);
    fclose(fp);
}
