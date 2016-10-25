#ifndef SPTOL_ERROR_H_INCLUDED
#define SPTOL_ERROR_H_INCLUDED

#include <errno.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Check if a value is not zero, print error message and return.
 * @param errcode the value to be checked
 * @param module  the module name of current procedure
 * @param reason  human readable error explanation
 */
#ifndef NDEBUG
#define spt_CheckError(errcode, module, reason) \
    if((errcode) != 0) { \
        spt_ComplainError(module, (errcode), __FILE__, __LINE__, (reason)); \
        return (errcode); \
    }
#else
#define spt_CheckError(errcode, module, reason) \
    if((errcode) != 0) { \
        return (errcode); \
    }
#endif

/**
 * Check if a condition is true, set the error information as the system error, print error message and return.
 * @param cond   the condition to be checked
 * @param module the module name of current procedure
 */
#define spt_CheckOSError(cond, module) \
    if((cond) && errno != 0) { \
        spt_CheckError(errno + SPTERR_OS_ERROR, (module), strerror(errno)); \
    }

/**
 * Check if a condition is true, set the error information as the last CUDA error, print error message and return.
 * @param cond   the condition to be checked
 * @param module the module name of current procedure
 */
#define spt_CheckCudaError(cond, module) \
    if((cond)) { \
        cudaError_t _cuda_error = cudaGetLastError(); \
        if(_cuda_error != 0) { \
            spt_CheckError(_cuda_error + SPTERR_CUDA_ERROR, (module), cudaGetErrorString(_cuda_error)); \
        } \
    }

#ifdef __cplusplus
}
#endif

#endif
