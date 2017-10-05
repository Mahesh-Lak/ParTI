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
#include "hicoo.h"
#include "mttkrp_cuda_kernels.h"


int sptMTTKRPKernelHiCOO(
    const sptIndex mode,
    const sptIndex nmodes,
    const sptNnzIndex nnz,
    const sptIndex R,
    const sptIndex stride,
    const sptElementIndex sb_bits,
    const sptElementIndex sc_bits,
    const int impl_num,
    const sptNnzIndex kptr_begin,
    const sptNnzIndex kptr_end,
    sptIndex * const dev_ndims,
    sptNnzIndex * const dev_cptr,
    sptNnzIndex * const dev_bptr,
    sptBlockIndex ** const dev_binds,
    sptElementIndex ** const dev_einds,
    sptValue * const dev_values,
    sptIndex * const dev_mats_order,
    sptValue ** const dev_mats)
{
    int result = 0;

    /* Maximum settings */
    sptIndex max_nthreads_per_block = 256;
    sptIndex max_nblocks = 32768;
    sptIndex max_nthreadsy = 16;

    sptIndex nthreadsx = 0;
    sptIndex nthreadsy = 0;
    sptIndex nblocks = 0;
    sptIndex shr_size = 0;

    sptNnzIndex all_nblocks = kptr_end - kptr_begin;

    switch(nmodes) {
    case 3: /* 3-D tensors */
        switch(impl_num) {
        case 1: // Naive, 1D
            /* Set number of blocks and threads */
            nthreadsx = (sptIndex)pow(2, sc_bits);
            if(all_nblocks < max_nblocks) {
                nblocks = all_nblocks;
            } else {
                nblocks = max_nblocks;
            }
            shr_size = 2 * nmodes * sizeof(sptIndex);

            printf("Execute spt_MTTKRPKernelNnz3DOneKernel (%u, %u)\n", nblocks, nthreadsx);
            spt_MTTKRPKernelHiCOO_3D_naive<<<nblocks, nthreadsx, shr_size>>>(
                mode,
                nmodes,
                nnz,
                R,
                stride,
                sb_bits,
                sc_bits,
                kptr_begin,
                kptr_end,
                dev_ndims,
                dev_cptr,
                dev_bptr,
                dev_binds,
                dev_einds,
                dev_values,
                dev_mats_order,
                dev_mats);
            break;

        case 2: 
            // dim3 dimBlock(nthreadsx, nthreadsy);
            break;
        }
    break;
    }   // End switch nmodes
    result = cudaThreadSynchronize();
    spt_CheckCudaError(result != 0, "CUDA HiCOO SpTns MTTKRP");

    return 0;
}


/* impl_num = 01  Naive, 1-D */
__global__ void spt_MTTKRPKernelHiCOO_3D_naive(
    const sptIndex mode,
    const sptIndex nmodes,
    const sptNnzIndex nnz,
    const sptIndex R,
    const sptIndex stride,
    const sptElementIndex sb_bits,
    const sptElementIndex sc_bits,
    const sptNnzIndex kptr_begin,
    const sptNnzIndex kptr_end,
    sptIndex * const dev_ndims,
    sptNnzIndex * const dev_cptr,
    sptNnzIndex * const dev_bptr,
    sptBlockIndex ** const dev_binds,
    sptElementIndex ** const dev_einds,
    sptValue * const dev_values,
    sptIndex * const dev_mats_order,
    sptValue ** const dev_mats)
{
    extern __shared__ sptIndex mempool[];
    sptIndex * block_coord = mempool;
    //sptIndex * ele_coord = mempool + nmodes;

    sptNnzIndex all_nblocks = kptr_end - kptr_begin;
    const sptIndex tidx = threadIdx.x;
    sptNnzIndex z;

    sptValue * const mvals = (sptValue*)dev_mats[nmodes];
    sptIndex times_mat_index_1 = dev_mats_order[1];
    sptValue * times_mat_1 = dev_mats[times_mat_index_1];
    sptIndex times_mat_index_2 = dev_mats_order[2];
    sptValue * times_mat_2 = dev_mats[times_mat_index_2];

    sptNnzIndex num_loops_blocks = 1;
    /*if(all_nblocks > gridDim.x) {
        num_loops_blocks = (all_nblocks + gridDim.x - 1) / gridDim.x;
    }*/
    for(sptNnzIndex nb=0; nb<num_loops_blocks; ++nb) {
        sptNnzIndex b = blockIdx.x + nb * gridDim.x;
        /* Block indices */
        for(sptIndex m=0; m<nmodes; ++m)
            block_coord[m] = dev_binds[m][b];

        sptNnzIndex bptr_begin = dev_bptr[b];
        sptNnzIndex bptr_end = dev_bptr[b+1];
        __syncthreads();

        z = tidx + bptr_begin;
        if(z < bptr_end) {
            /* Element indices */
            //for(sptIndex m=0; m<nmodes; ++m)
            //    ele_coord[m] = (block_coord[m] << sb_bits) + dev_einds[m][z];
            
            sptValue const entry = dev_values[z];
            //sptElementIndex const mode_i = ele_coord[mode];
            sptElementIndex const mode_i = (block_coord[mode] << sb_bits) + dev_einds[mode][z];
            //sptElementIndex const tmp_i_1 = ele_coord[times_mat_index_1];
            sptElementIndex const tmp_i_1 = (block_coord[times_mat_index_1] << sb_bits) + dev_einds[times_mat_index_1][z];
            //sptElementIndex const tmp_i_2 = ele_coord[times_mat_index_2];
            sptElementIndex const tmp_i_2 = (block_coord[times_mat_index_2] << sb_bits) + dev_einds[times_mat_index_2][z];

            sptValue tmp_val = 0;
            for(sptIndex r=0; r<R; ++r) {
                tmp_val = entry * times_mat_1[tmp_i_1 * stride + r] * times_mat_2[tmp_i_2 * stride + r];
                atomicAdd(&mvals[mode_i * stride + r], tmp_val);
            }

        }   // End loop entries

    }   // End loop blocks

}
