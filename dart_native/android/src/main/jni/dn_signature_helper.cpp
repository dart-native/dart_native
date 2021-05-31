//
// Created by Hui on 5/31/21.
//
#include "dn_signature_helper.h"
#include "dn_log.h"
#include <string>

/// Returns a malloc pointer to the result.
char *generateSignature(char **argumentTypes, int argumentCount, char *returnType)
{
  /// include "(" ")" length
  size_t signatureLength = strlen(returnType) + 2;
  /// all argument type length
  for (int i = 0; i < argumentCount; i++)
  {
    signatureLength += strlen(argumentTypes[i]);
  }

  char *signature = (char *)malloc(signatureLength * sizeof(char));
  strcpy(signature, "(");
  int offset = 1;
  for (int i = 0; i < argumentCount; offset += strlen(argumentTypes[i]), i++)
  {
    strcpy(signature + offset, argumentTypes[i]);
  }
  strcpy(signature + offset, ")");
  strcpy(signature + offset + 1, returnType);

  return signature;
}
