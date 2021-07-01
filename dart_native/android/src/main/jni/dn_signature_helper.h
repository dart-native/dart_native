//
// Created by Hui on 5/31/21.
//

#ifndef DART_NATIVE_DN_SIGNATURE_HELPER_H
#define DART_NATIVE_DN_SIGNATURE_HELPER_H
#ifdef __cplusplus
extern "C"
{
#endif

  char *generateSignature(char **argumentTypes, int argumentCount, char *returnType);

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_SIGNATURE_HELPER_H
