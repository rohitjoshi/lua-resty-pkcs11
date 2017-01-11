local ffi = require("ffi")
local ffi_new = ffi.new
local ffi_cast = ffi.cast
local ffi_sizeof = ffi.sizeof
local ffi_string = ffi.string
local ffi_load = ffi.load

ffi.cdef[[ 
  typedef unsigned char     CK_BYTE;
  typedef unsigned long int CK_ULONG;
  
  typedef void              * CK_VOID_PTR;
  typedef CK_BYTE           * CK_BYTE_PTR;
  typedef CK_ULONG          * CK_ULONG_PTR;
  
  typedef CK_BYTE           CK_UTF8CHAR;
  typedef CK_ULONG          CK_RV;
  typedef CK_ULONG          CK_SLOT_ID;
  typedef CK_ULONG          CK_FLAGS;
  typedef CK_ULONG          CK_SESSION_HANDLE;
  typedef CK_SESSION_HANDLE * CK_SESSION_HANDLE_PTR;
  typedef CK_ULONG          CK_NOTIFICATION;
  typedef CK_ULONG          CK_USER_TYPE;  
  typedef CK_ULONG          CK_ATTRIBUTE_TYPE;
  typedef CK_UTF8CHAR       * CK_UTF8CHAR_PTR;
  typedef CK_ULONG          CK_OBJECT_HANDLE;
  typedef CK_OBJECT_HANDLE  * CK_OBJECT_HANDLE_PTR;
  typedef CK_ULONG          CK_OBJECT_CLASS;

  typedef CK_ULONG          CK_MECHANISM_TYPE;
  typedef CK_MECHANISM_TYPE * CK_MECHANISM_TYPE_PTR;
  typedef struct CK_MECHANISM {
    CK_MECHANISM_TYPE mechanism;
    CK_VOID_PTR       pParameter;
    CK_ULONG          ulParameterLen;  /* in bytes */
  } CK_MECHANISM;
  typedef CK_MECHANISM      * CK_MECHANISM_PTR;

  typedef struct CK_ATTRIBUTE {
      CK_ATTRIBUTE_TYPE type;
      CK_VOID_PTR       pValue;
      CK_ULONG          ulValueLen;  /* in bytes */
  } CK_ATTRIBUTE;
  typedef CK_ATTRIBUTE      * CK_ATTRIBUTE_PTR;

  typedef CK_RV (* CK_NOTIFY)(
      CK_SESSION_HANDLE hSession,   
      CK_NOTIFICATION   event,
      CK_VOID_PTR       pApplication 
  );

  CK_RV C_Initialize (CK_VOID_PTR   pInitArgs);  
  CK_RV C_Finalize (CK_VOID_PTR   pReserved);  

  CK_RV C_OpenSession ( 
      CK_SLOT_ID slotID, 
      CK_FLAGS flags, 
      CK_VOID_PTR pApplication, 
      CK_NOTIFY Notify,
      CK_SESSION_HANDLE_PTR phSession
  );

  CK_RV C_CloseSession (
      CK_SESSION_HANDLE hSession
  );

  CK_RV C_Login (
      CK_SESSION_HANDLE hSession,  /* the session's handle */
      CK_USER_TYPE      userType,  /* the user type */
      CK_UTF8CHAR_PTR   pPin,      /* the user's PIN */
      CK_ULONG          ulPinLen   /* the length of the PIN */
  );

  CK_RV C_Logout (
      CK_SESSION_HANDLE hSession
  );

  CK_RV C_FindObjectsInit (
      CK_SESSION_HANDLE hSession,
      CK_ATTRIBUTE_PTR pTemplate,
      CK_ULONG ulCount
  );

  CK_RV C_FindObjects (
      CK_SESSION_HANDLE hSession,
      CK_OBJECT_HANDLE_PTR phObject,
      CK_ULONG ulMaxObjectCount,
      CK_ULONG_PTR pulObjectCount
  );

  CK_RV C_FindObjectsFinal (
      CK_SESSION_HANDLE hSession
  );

  CK_RV C_EncryptInit (
    CK_SESSION_HANDLE hSession,    /* the session's handle */
    CK_MECHANISM_PTR  pMechanism,  /* the encryption mechanism */
    CK_OBJECT_HANDLE  hKey         /* handle of encryption key */
  );

  CK_RV C_Encrypt (
    CK_SESSION_HANDLE hSession,            /* session's handle */
    CK_BYTE_PTR       pData,               /* the plaintext data */
    CK_ULONG          ulDataLen,           /* bytes of plaintext */
    CK_BYTE_PTR       pEncryptedData,      /* gets ciphertext */
    CK_ULONG_PTR      pulEncryptedDataLen  /* gets c-text size */
  );

  CK_RV C_EncryptUpdate (
    CK_SESSION_HANDLE hSession,           /* session's handle */
    CK_BYTE_PTR       pPart,              /* the plaintext data */
    CK_ULONG          ulPartLen,          /* plaintext data len */
    CK_BYTE_PTR       pEncryptedPart,     /* gets ciphertext */
    CK_ULONG_PTR      pulEncryptedPartLen /* gets c-text size */
  );


  CK_RV C_EncryptFinal (
    CK_SESSION_HANDLE hSession,                /* session handle */
    CK_BYTE_PTR       pLastEncryptedPart,      /* last c-text */
    CK_ULONG_PTR      pulLastEncryptedPartLen  /* gets last size */
  );


  CK_RV C_DecryptInit (
    CK_SESSION_HANDLE hSession,
    CK_MECHANISM_PTR pMechanism,
    CK_OBJECT_HANDLE hKey
  );

  CK_RV C_Decrypt (
    CK_SESSION_HANDLE hSession,
    CK_BYTE_PTR pEncryptedData,
    CK_ULONG ulEncryptedDataLen,
    CK_BYTE_PTR pData,
    CK_ULONG_PTR pulDataLen
  );

  CK_RV C_DecryptUpdate (
    CK_SESSION_HANDLE hSession,
    CK_BYTE_PTR pEncryptedPart,
    CK_ULONG ulEncryptedPartLen,
    CK_BYTE_PTR pPart,
    CK_ULONG_PTR pulPartLen
  );

  CK_RV C_DecryptFinal (
    CK_SESSION_HANDLE hSession,
    CK_BYTE_PTR pLastPart,
    CK_ULONG_PTR pulLastPartLen
  );

  CK_RV C_SignInit (
    CK_SESSION_HANDLE hSession,    /* the session's handle */
    CK_MECHANISM_PTR  pMechanism,  /* the signature mechanism */
    CK_OBJECT_HANDLE  hKey         /* handle of signature key */
  );

  CK_RV C_Sign (
    CK_SESSION_HANDLE hSession,        /* the session's handle */
    CK_BYTE_PTR       pData,           /* the data to sign */
    CK_ULONG          ulDataLen,       /* count of bytes to sign */
    CK_BYTE_PTR       pSignature,      /* gets the signature */
    CK_ULONG_PTR      pulSignatureLen  /* gets signature length */
  );

  CK_RV C_SignUpdate (
    CK_SESSION_HANDLE hSession,  /* the session's handle */
    CK_BYTE_PTR       pPart,     /* the data to sign */
    CK_ULONG          ulPartLen  /* count of bytes to sign */
  );

  CK_RV C_SignFinal (
    CK_SESSION_HANDLE hSession,        /* the session's handle */
    CK_BYTE_PTR       pSignature,      /* gets the signature */
    CK_ULONG_PTR      pulSignatureLen  /* gets signature length */
  );

  CK_RV C_SignRecoverInit (
    CK_SESSION_HANDLE hSession,   /* the session's handle */
    CK_MECHANISM_PTR  pMechanism, /* the signature mechanism */
    CK_OBJECT_HANDLE  hKey        /* handle of the signature key */
  );

  CK_RV C_SignRecover (
    CK_SESSION_HANDLE hSession,        /* the session's handle */
    CK_BYTE_PTR       pData,           /* the data to sign */
    CK_ULONG          ulDataLen,       /* count of bytes to sign */
    CK_BYTE_PTR       pSignature,      /* gets the signature */
    CK_ULONG_PTR      pulSignatureLen  /* gets signature length */
  );

  CK_RV C_VerifyInit (
    CK_SESSION_HANDLE hSession,    /* the session's handle */
    CK_MECHANISM_PTR  pMechanism,  /* the verification mechanism */
    CK_OBJECT_HANDLE  hKey         /* verification key */ 
  );

  CK_RV C_Verify (
    CK_SESSION_HANDLE hSession,       /* the session's handle */
    CK_BYTE_PTR       pData,          /* signed data */
    CK_ULONG          ulDataLen,      /* length of signed data */
    CK_BYTE_PTR       pSignature,     /* signature */
    CK_ULONG          ulSignatureLen  /* signature length*/
  );

  CK_RV C_VerifyUpdate (
    CK_SESSION_HANDLE hSession,  /* the session's handle */
    CK_BYTE_PTR       pPart,     /* signed data */
    CK_ULONG          ulPartLen  /* length of signed data */
  );

  CK_RV C_VerifyFinal (
    CK_SESSION_HANDLE hSession,       /* the session's handle */
    CK_BYTE_PTR       pSignature,     /* signature to verify */
    CK_ULONG          ulSignatureLen  /* signature length */
  );

  CK_RV C_VerifyRecoverInit (
    CK_SESSION_HANDLE hSession,    /* the session's handle */
    CK_MECHANISM_PTR  pMechanism,  /* the verification mechanism */
    CK_OBJECT_HANDLE  hKey         /* verification key */
  );

  CK_RV C_VerifyRecover (
    CK_SESSION_HANDLE hSession,        /* the session's handle */
    CK_BYTE_PTR       pSignature,      /* signature to verify */
    CK_ULONG          ulSignatureLen,  /* signature length */
    CK_BYTE_PTR       pData,           /* gets signed data */
    CK_ULONG_PTR      pulDataLen       /* gets signed data len */
  );

]]


local CKR_OK                             = 0x00000000
local CKR_HOST_MEMORY                    = 0x00000002
local CKR_SLOT_ID_INVALID                = 0x00000003
local CKR_GENERAL_ERROR                  = 0x00000005
local CKR_FUNCTION_FAILED                = 0x00000006
local CKR_ARGUMENTS_BAD                  = 0x00000007
local CKR_NEED_TO_CREATE_THREADS         = 0x00000009
local CKR_CANT_LOCK                      = 0x0000000A
local CKR_ATTRIBUTE_READ_ONLY            = 0x00000010
local CKR_ATTRIBUTE_SENSITIVE            = 0x00000011
local CKR_ATTRIBUTE_TYPE_INVALID         = 0x00000012
local CKR_ATTRIBUTE_VALUE_INVALID        = 0x00000013
local CKR_DATA_INVALID                   = 0x00000020
local CKR_DATA_LEN_RANGE                 = 0x00000021
local CKR_DEVICE_ERROR                   = 0x00000030
local CKR_DEVICE_MEMORY                  = 0x00000031
local CKR_DEVICE_REMOVED                 = 0x00000032
local CKR_ENCRYPTED_DATA_INVALID         = 0x00000040
local CKR_ENCRYPTED_DATA_LEN_RANGE       = 0x00000041
local CKR_FUNCTION_CANCELED              = 0x00000050
local CKR_FUNCTION_NOT_PARALLEL          = 0x00000051
local CKR_FUNCTION_NOT_SUPPORTED         = 0x00000054
local CKR_KEY_HANDLE_INVALID             = 0x00000060
local CKR_KEY_SIZE_RANGE                 = 0x00000062
local CKR_KEY_TYPE_INCONSISTENT          = 0x00000063
local CKR_KEY_NOT_NEEDED                 = 0x00000064
local CKR_KEY_CHANGED                    = 0x00000065
local CKR_KEY_NEEDED                     = 0x00000066
local CKR_KEY_INDIGESTIBLE               = 0x00000067
local CKR_KEY_FUNCTION_NOT_PERMITTED     = 0x00000068
local CKR_KEY_NOT_WRAPPABLE              = 0x00000069
local CKR_KEY_UNEXTRACTABLE              = 0x0000006A
local CKR_MECHANISM_INVALID              = 0x00000070
local CKR_MECHANISM_PARAM_INVALID        = 0x00000071
local CKR_OBJECT_HANDLE_INVALID          = 0x00000082
local CKR_OPERATION_ACTIVE               = 0x00000090
local CKR_OPERATION_NOT_INITIALIZED      = 0x00000091
local CKR_PIN_INCORRECT                  = 0x000000A0
local CKR_PIN_INVALID                    = 0x000000A1
local CKR_PIN_LEN_RANGE                  = 0x000000A2
local CKR_PIN_EXPIRED                    = 0x000000A3
local CKR_PIN_LOCKED                     = 0x000000A4
local CKR_SESSION_CLOSED                 = 0x000000B0
local CKR_SESSION_COUNT                  = 0x000000B1
local CKR_SESSION_HANDLE_INVALID         = 0x000000B3
local CKR_SESSION_PARALLEL_NOT_SUPPORTED = 0x000000B4
local CKR_SESSION_READ_ONLY_EXISTS       = 0x000000B7
local CKR_SESSION_READ_WRITE_SO_EXISTS   = 0x000000B8
local CKR_SIGNATURE_INVALID              = 0x000000C0
local CKR_SIGNATURE_LEN_RANGE            = 0x000000C1
local CKR_TEMPLATE_INCOMPLETE            = 0x000000D0
local CKR_TEMPLATE_INCONSISTENT          = 0x000000D1
local CKR_TOKEN_NOT_PRESENT              = 0x000000E0
local CKR_TOKEN_NOT_RECOGNIZED           = 0x000000E1
local CKR_TOKEN_WRITE_PROTECTED          = 0x000000E2
local CKR_USER_ALREADY_LOGGED_IN         = 0x00000100
local CKR_USER_NOT_LOGGED_IN             = 0x00000101
local CKR_USER_PIN_NOT_INITIALIZED       = 0x00000102
local CKR_USER_TYPE_INVALID              = 0x00000103
local CKR_USER_ANOTHER_ALREADY_LOGGED_IN = 0x00000104
local CKR_USER_TOO_MANY_TYPES            = 0x00000105
local CKR_BUFFER_TOO_SMALL               = 0x00000150
local CKR_SAVED_STATE_INVALID            = 0x00000160
local CKR_INFORMATION_SENSITIVE          = 0x00000170
local CKR_STATE_UNSAVEABLE               = 0x00000180
local CKR_CRYPTOKI_NOT_INITIALIZED       = 0x00000190
local CKR_CRYPTOKI_ALREADY_INITIALIZED   = 0x00000191


local RV_ERR_MSG = {}
RV_ERR_MSG[ CKR_HOST_MEMORY ] = "HSM driver memory allocation error"
RV_ERR_MSG[ CKR_SLOT_ID_INVALID ] = "Unknown slot"
RV_ERR_MSG[ CKR_GENERAL_ERROR ] = "HSM General error"
RV_ERR_MSG[ CKR_FUNCTION_FAILED ] = "HSM processing failed" 
RV_ERR_MSG[ CKR_ARGUMENTS_BAD ] = "Bad arguments provided"
RV_ERR_MSG[ CKR_NEED_TO_CREATE_THREADS ] = "Need to create threads"
RV_ERR_MSG[ CKR_CANT_LOCK ] = "Driver unable to create mutex" 
RV_ERR_MSG[ CKR_DEVICE_ERROR ] = "HSM module error"
RV_ERR_MSG[ CKR_DEVICE_MEMORY ] = "HSM module memory error"
RV_ERR_MSG[ CKR_DEVICE_REMOVED ] = "HSM module removed"
RV_ERR_MSG[ CKR_FUNCTION_CANCELED ] = "Processing stopped"
RV_ERR_MSG[ CKR_OPERATION_NOT_INITIALIZED ] = "HSM module not initialized for the operation"
RV_ERR_MSG[ CKR_PIN_INCORRECT ] = "Incorrect PIN"
RV_ERR_MSG[ CKR_PIN_LOCKED ] = "PIN locked"
RV_ERR_MSG[ CKR_SESSION_CLOSED ] = "Session has been closed"
RV_ERR_MSG[ CKR_SESSION_COUNT ] = "Too many sessions"
RV_ERR_MSG[ CKR_SESSION_HANDLE_INVALID ] = "Invalid session handle"
RV_ERR_MSG[ CKR_SESSION_PARALLEL_NOT_SUPPORTED ] = "CKF_SERIAL_SESSION flag must be set"
RV_ERR_MSG[ CKR_SESSION_READ_ONLY_EXISTS ] = "Read only session alredy exists"
RV_ERR_MSG[ CKR_SESSION_READ_WRITE_SO_EXISTS ] = "Read / Write session already exists"
RV_ERR_MSG[ CKR_SIGNATURE_INVALID ] = "Invalid signarute" 
RV_ERR_MSG[ CKR_SIGNATURE_LEN_RANGE ] = "Invalid length of signature" 
RV_ERR_MSG[ CKR_TEMPLATE_INCOMPLETE ] = "Incomplete template" 
RV_ERR_MSG[ CKR_TEMPLATE_INCONSISTENT ] = "Inconsistent template" 
RV_ERR_MSG[ CKR_TOKEN_NOT_PRESENT ] = "Token not present"
RV_ERR_MSG[ CKR_TOKEN_NOT_RECOGNIZED ] = "Token not recognized"
RV_ERR_MSG[ CKR_TOKEN_WRITE_PROTECTED ] = "Token protected for writting"
RV_ERR_MSG[ CKR_USER_ALREADY_LOGGED_IN ] = "User already logged-in"
RV_ERR_MSG[ CKR_USER_NOT_LOGGED_IN ] = "user not logged-in"
RV_ERR_MSG[ CKR_USER_PIN_NOT_INITIALIZED ] = "User didn't initialized PIN"
RV_ERR_MSG[ CKR_USER_TYPE_INVALID ] = "Unknown user type"
RV_ERR_MSG[ CKR_USER_ANOTHER_ALREADY_LOGGED_IN ] = "Another user already logged-in"
RV_ERR_MSG[ CKR_USER_TOO_MANY_TYPES ] = "Just one user type is allowed"
RV_ERR_MSG[ CKR_BUFFER_TOO_SMALL ] = "Buffer too small"
RV_ERR_MSG[ CKR_SAVED_STATE_INVALID ] = "Invalid saved state"
RV_ERR_MSG[ CKR_INFORMATION_SENSITIVE ] = "Information sensitive"
RV_ERR_MSG[ CKR_STATE_UNSAVEABLE ] = "Unable to save state"
RV_ERR_MSG[ CKR_CRYPTOKI_NOT_INITIALIZED ] = "HSM module not initialized"
RV_ERR_MSG[ CKR_CRYPTOKI_ALREADY_INITIALIZED ] = "HSM module already initialized"
RV_ERR_MSG[ CKR_ATTRIBUTE_READ_ONLY ] = "Read only attribute"               
RV_ERR_MSG[ CKR_ATTRIBUTE_SENSITIVE ] = "Sensitive attribute"               
RV_ERR_MSG[ CKR_ATTRIBUTE_TYPE_INVALID ] = "Invalid attribute type"            
RV_ERR_MSG[ CKR_ATTRIBUTE_VALUE_INVALID ] = "Invalid attribute value"           
RV_ERR_MSG[ CKR_DATA_INVALID ] = "Invalid data"                      
RV_ERR_MSG[ CKR_DATA_LEN_RANGE ] = "Invalid range"                    
RV_ERR_MSG[ CKR_ENCRYPTED_DATA_INVALID ] = "Invalid data"            
RV_ERR_MSG[ CKR_ENCRYPTED_DATA_LEN_RANGE ] = "Invalid range"          
RV_ERR_MSG[ CKR_FUNCTION_NOT_PARALLEL ] = "Parallel call of serial function"             
RV_ERR_MSG[ CKR_FUNCTION_NOT_SUPPORTED ] = "Function not supported"
RV_ERR_MSG[ CKR_KEY_HANDLE_INVALID ] = "Invalid key handle"
RV_ERR_MSG[ CKR_KEY_SIZE_RANGE ] = "Invalid key size"
RV_ERR_MSG[ CKR_KEY_TYPE_INCONSISTENT ] = "Incorrect key type"
RV_ERR_MSG[ CKR_KEY_NOT_NEEDED ] = "Key not needed"
RV_ERR_MSG[ CKR_KEY_CHANGED ] = "Key changed"
RV_ERR_MSG[ CKR_KEY_NEEDED ] = "Key needed"
RV_ERR_MSG[ CKR_KEY_INDIGESTIBLE ] = "Key indigestible"
RV_ERR_MSG[ CKR_KEY_FUNCTION_NOT_PERMITTED ] = "Key function not permitted"
RV_ERR_MSG[ CKR_KEY_NOT_WRAPPABLE ] = "Key not wrappable"
RV_ERR_MSG[ CKR_KEY_UNEXTRACTABLE ] = "Key unextracable"
RV_ERR_MSG[ CKR_MECHANISM_INVALID ] = "Incorrect mechanism provided"
RV_ERR_MSG[ CKR_MECHANISM_PARAM_INVALID ] = "Incorrect mechanism parameter"
RV_ERR_MSG[ CKR_OBJECT_HANDLE_INVALID ] = "Invalid object hadle"             
RV_ERR_MSG[ CKR_OPERATION_ACTIVE ] = "Ongoing operation"                  
RV_ERR_MSG[ CKR_PIN_INVALID ] = "Invalid PIN"                       
RV_ERR_MSG[ CKR_PIN_LEN_RANGE ] = "Invalid size of PIN"                     
RV_ERR_MSG[ CKR_PIN_EXPIRED ] = "Expired PIN"                       



local function err_out ( ckr , err_prefix )
  local err_string = RV_ERR_MSG[tonumber(ckr)] or ( "Unknown error: " .. tostring(ckr)) 
  return nil, err_prefix .. err_string  
end



local _M = {
  _VERSION = '0.01'
}
local mt = { __index = _M }

--Publicly available flags
_M.CKF_SERIAL_SESSION = 0x00000004
_M.CKF_RW_SESSION     = 0x00000002

--User types 
_M.CKU_SO             = 0
_M.CKU_USER           = 1
_M.CKU_CONTEXT_SPECIFIC = 2

-- SEARCH template constatnts

-- search attributes
_M.CKA_CLASS = 0x00000000
_M.CKA_TOKEN = 0x00000001
_M.CKA_PRIVATE = 0x00000002
_M.CKA_LABEL = 0x00000003
_M.CKA_APPLICATION = 0x00000010
_M.CKA_VALUE = 0x00000011
_M.CKA_OBJECT_ID = 0x00000012
_M.CKA_CERTIFICATE_TYPE = 0x00000080
_M.CKA_ISSUER = 0x00000081
_M.CKA_SERIAL_NUMBER = 0x00000082
_M.CKA_AC_ISSUER = 0x00000083
_M.CKA_OWNER = 0x00000084
_M.CKA_ATTR_TYPES = 0x00000085
_M.CKA_TRUSTED = 0x00000086
_M.CKA_CERTIFICATE_CATEGORY = 0x00000087
_M.CKA_JAVA_MIDP_SECURITY_DOMAIN = 0x00000088
_M.CKA_URL = 0x00000089
_M.CKA_HASH_OF_SUBJECT_PUBLIC_KEY = 0x0000008A
_M.CKA_HASH_OF_ISSUER_PUBLIC_KEY = 0x0000008B
_M.CKA_CHECK_VALUE = 0x00000090
_M.CKA_KEY_TYPE = 0x00000100
_M.CKA_SUBJECT = 0x00000101
_M.CKA_ID = 0x00000102
_M.CKA_SENSITIVE = 0x00000103
_M.CKA_ENCRYPT = 0x00000104
_M.CKA_DECRYPT = 0x00000105
_M.CKA_WRAP = 0x00000106
_M.CKA_UNWRAP = 0x00000107
_M.CKA_SIGN = 0x00000108
_M.CKA_SIGN_RECOVER = 0x00000109
_M.CKA_VERIFY = 0x0000010A
_M.CKA_VERIFY_RECOVER = 0x0000010B
_M.CKA_DERIVE = 0x0000010C
_M.CKA_START_DATE = 0x00000110
_M.CKA_END_DATE = 0x00000111
_M.CKA_MODULUS = 0x00000120
_M.CKA_MODULUS_BITS = 0x00000121
_M.CKA_PUBLIC_EXPONENT = 0x00000122
_M.CKA_PRIVATE_EXPONENT = 0x00000123
_M.CKA_PRIME_1 = 0x00000124
_M.CKA_PRIME_2 = 0x00000125
_M.CKA_EXPONENT_1 = 0x00000126
_M.CKA_EXPONENT_2 = 0x00000127
_M.CKA_COEFFICIENT = 0x00000128
_M.CKA_PRIME = 0x00000130
_M.CKA_SUBPRIME = 0x00000131
_M.CKA_BASE = 0x00000132
_M.CKA_PRIME_BITS = 0x00000133
_M.CKA_SUBPRIME_BITS = 0x00000134
_M.CKA_SUB_PRIME_BITS = 0x00000134
_M.CKA_VALUE_BITS = 0x00000160
_M.CKA_VALUE_LEN = 0x00000161
_M.CKA_EXTRACTABLE = 0x00000162
_M.CKA_LOCAL = 0x00000163
_M.CKA_NEVER_EXTRACTABLE = 0x00000164
_M.CKA_ALWAYS_SENSITIVE = 0x00000165
_M.CKA_KEY_GEN_MECHANISM = 0x00000166
_M.CKA_MODIFIABLE = 0x00000170
_M.CKA_ECDSA_PARAMS = 0x00000180
_M.CKA_EC_PARAMS = 0x00000180
_M.CKA_EC_POINT = 0x00000181
_M.CKA_SECONDARY_AUTH = 0x00000200
_M.CKA_AUTH_PIN_FLAGS = 0x00000201
_M.CKA_ALWAYS_AUTHENTICATE = 0x00000202
_M.CKA_WRAP_WITH_TRUSTED = 0x00000210
_M.CKA_OTP_FORMAT = 0x00000220
_M.CKA_OTP_LENGTH = 0x00000221
_M.CKA_OTP_TIME_INTERVAL = 0x00000222
_M.CKA_OTP_USER_FRIENDLY_MODE = 0x00000223
_M.CKA_OTP_CHALLENGE_REQUIREMENT = 0x00000224
_M.CKA_OTP_TIME_REQUIREMENT = 0x00000225
_M.CKA_OTP_COUNTER_REQUIREMENT = 0x00000226
_M.CKA_OTP_PIN_REQUIREMENT = 0x00000227
_M.CKA_OTP_COUNTER = 0x0000022E
_M.CKA_OTP_TIME = 0x0000022F
_M.CKA_OTP_USER_IDENTIFIER = 0x0000022A
_M.CKA_OTP_SERVICE_IDENTIFIER = 0x0000022B
_M.CKA_OTP_SERVICE_LOGO = 0x0000022C
_M.CKA_OTP_SERVICE_LOGO_TYPE = 0x0000022D
_M.CKA_HW_FEATURE_TYPE = 0x00000300
_M.CKA_RESET_ON_INIT = 0x00000301
_M.CKA_HAS_RESET = 0x00000302
_M.CKA_PIXEL_X = 0x00000400
_M.CKA_PIXEL_Y = 0x00000401
_M.CKA_RESOLUTION = 0x00000402
_M.CKA_CHAR_ROWS = 0x00000403
_M.CKA_CHAR_COLUMNS = 0x00000404
_M.CKA_COLOR = 0x00000405
_M.CKA_BITS_PER_PIXEL = 0x00000406
_M.CKA_CHAR_SETS = 0x00000480
_M.CKA_ENCODING_METHODS = 0x00000481
_M.CKA_MIME_TYPES = 0x00000482
_M.CKA_MECHANISM_TYPE = 0x00000500
_M.CKA_REQUIRED_CMS_ATTRIBUTES = 0x00000501
_M.CKA_DEFAULT_CMS_ATTRIBUTES = 0x00000502
_M.CKA_SUPPORTED_CMS_ATTRIBUTES = 0x00000503
_M.CKA_VENDOR_DEFINED = 0x80000000

-- class types
_M.CKO_DATA = 0x00000000
_M.CKO_CERTIFICATE = 0x00000001
_M.CKO_PUBLIC_KEY = 0x00000002
_M.CKO_PRIVATE_KEY = 0x00000003
_M.CKO_SECRET_KEY = 0x00000004
_M.CKO_HW_FEATURE = 0x00000005
_M.CKO_DOMAIN_PARAMETERS = 0x00000006
_M.CKO_MECHANISM = 0x00000007

-- well known mechanisms
_M.CKM_RSA_PKCS_KEY_PAIR_GEN = 0x00000000
_M.CKM_RSA_PKCS = 0x00000001
_M.CKM_RSA_9796 = 0x00000002
_M.CKM_RSA_X_509 = 0x00000003
_M.CKM_MD2_RSA_PKCS = 0x00000004
_M.CKM_MD5_RSA_PKCS = 0x00000005
_M.CKM_SHA1_RSA_PKCS = 0x00000006
_M.CKM_RIPEMD128_RSA_PKCS = 0x00000007
_M.CKM_RIPEMD160_RSA_PKCS = 0x00000008
_M.CKM_RSA_PKCS_OAEP = 0x00000009
_M.CKM_RSA_X9_31_KEY_PAIR_GEN = 0x0000000A
_M.CKM_RSA_X9_31 = 0x0000000B
_M.CKM_SHA1_RSA_X9_31 = 0x0000000C
_M.CKM_RSA_PKCS_PSS = 0x0000000D
_M.CKM_SHA1_RSA_PKCS_PSS = 0x0000000E
_M.CKM_DSA_KEY_PAIR_GEN = 0x00000010
_M.CKM_DSA = 0x00000011
_M.CKM_DSA_SHA1 = 0x00000012
_M.CKM_DH_PKCS_KEY_PAIR_GEN = 0x00000020
_M.CKM_DH_PKCS_DERIVE = 0x00000021
_M.CKM_X9_42_DH_KEY_PAIR_GEN = 0x00000030
_M.CKM_X9_42_DH_DERIVE = 0x00000031
_M.CKM_X9_42_DH_HYBRID_DERIVE = 0x00000032
_M.CKM_X9_42_MQV_DERIVE = 0x00000033
_M.CKM_SHA256_RSA_PKCS = 0x00000040
_M.CKM_SHA384_RSA_PKCS = 0x00000041
_M.CKM_SHA512_RSA_PKCS = 0x00000042
_M.CKM_SHA256_RSA_PKCS_PSS = 0x00000043
_M.CKM_SHA384_RSA_PKCS_PSS = 0x00000044
_M.CKM_SHA512_RSA_PKCS_PSS = 0x00000045
_M.CKM_SHA224_RSA_PKCS = 0x00000046
_M.CKM_SHA224_RSA_PKCS_PSS = 0x00000047
_M.CKM_RC2_KEY_GEN = 0x00000100
_M.CKM_RC2_ECB = 0x00000101
_M.CKM_RC2_CBC = 0x00000102
_M.CKM_RC2_MAC = 0x00000103
_M.CKM_RC2_MAC_GENERAL = 0x00000104
_M.CKM_RC2_CBC_PAD = 0x00000105
_M.CKM_RC4_KEY_GEN = 0x00000110
_M.CKM_RC4 = 0x00000111
_M.CKM_DES_KEY_GEN = 0x00000120
_M.CKM_DES_ECB = 0x00000121
_M.CKM_DES_CBC = 0x00000122
_M.CKM_DES_MAC = 0x00000123
_M.CKM_DES_MAC_GENERAL = 0x00000124
_M.CKM_DES_CBC_PAD = 0x00000125
_M.CKM_DES2_KEY_GEN = 0x00000130
_M.CKM_DES3_KEY_GEN = 0x00000131
_M.CKM_DES3_ECB = 0x00000132
_M.CKM_DES3_CBC = 0x00000133
_M.CKM_DES3_MAC = 0x00000134
_M.CKM_DES3_MAC_GENERAL = 0x00000135
_M.CKM_DES3_CBC_PAD = 0x00000136
_M.CKM_CDMF_KEY_GEN = 0x00000140
_M.CKM_CDMF_ECB = 0x00000141
_M.CKM_CDMF_CBC = 0x00000142
_M.CKM_CDMF_MAC = 0x00000143
_M.CKM_CDMF_MAC_GENERAL = 0x00000144
_M.CKM_CDMF_CBC_PAD = 0x00000145
_M.CKM_DES_OFB64 = 0x00000150
_M.CKM_DES_OFB8 = 0x00000151
_M.CKM_DES_CFB64 = 0x00000152
_M.CKM_DES_CFB8 = 0x00000153
_M.CKM_MD2 = 0x00000200
_M.CKM_MD2_HMAC = 0x00000201
_M.CKM_MD2_HMAC_GENERAL = 0x00000202
_M.CKM_MD5 = 0x00000210
_M.CKM_MD5_HMAC = 0x00000211
_M.CKM_MD5_HMAC_GENERAL = 0x00000212
_M.CKM_SHA_1 = 0x00000220
_M.CKM_SHA_1_HMAC = 0x00000221
_M.CKM_SHA_1_HMAC_GENERAL = 0x00000222
_M.CKM_RIPEMD128 = 0x00000230
_M.CKM_RIPEMD128_HMAC = 0x00000231
_M.CKM_RIPEMD128_HMAC_GENERAL = 0x00000232
_M.CKM_RIPEMD160 = 0x00000240
_M.CKM_RIPEMD160_HMAC = 0x00000241
_M.CKM_RIPEMD160_HMAC_GENERAL = 0x00000242
_M.CKM_SHA256 = 0x00000250
_M.CKM_SHA256_HMAC = 0x00000251
_M.CKM_SHA256_HMAC_GENERAL = 0x00000252
_M.CKM_SHA224 = 0x00000255
_M.CKM_SHA224_HMAC = 0x00000256
_M.CKM_SHA224_HMAC_GENERAL = 0x00000257
_M.CKM_SHA384 = 0x00000260
_M.CKM_SHA384_HMAC = 0x00000261
_M.CKM_SHA384_HMAC_GENERAL = 0x00000262
_M.CKM_SHA512 = 0x00000270
_M.CKM_SHA512_HMAC = 0x00000271
_M.CKM_SHA512_HMAC_GENERAL = 0x00000272
_M.CKM_SECURID_KEY_GEN = 0x00000280
_M.CKM_SECURID = 0x00000282
_M.CKM_HOTP_KEY_GEN = 0x00000290
_M.CKM_HOTP = 0x00000291
_M.CKM_ACTI = 0x000002A0
_M.CKM_ACTI_KEY_GEN = 0x000002A1
_M.CKM_CAST_KEY_GEN = 0x00000300
_M.CKM_CAST_ECB = 0x00000301
_M.CKM_CAST_CBC = 0x00000302
_M.CKM_CAST_MAC = 0x00000303
_M.CKM_CAST_MAC_GENERAL = 0x00000304
_M.CKM_CAST_CBC_PAD = 0x00000305
_M.CKM_CAST3_KEY_GEN = 0x00000310
_M.CKM_CAST3_ECB = 0x00000311
_M.CKM_CAST3_CBC = 0x00000312
_M.CKM_CAST3_MAC = 0x00000313
_M.CKM_CAST3_MAC_GENERAL = 0x00000314
_M.CKM_CAST3_CBC_PAD = 0x00000315
_M.CKM_CAST5_KEY_GEN = 0x00000320
_M.CKM_CAST128_KEY_GEN = 0x00000320
_M.CKM_CAST5_ECB = 0x00000321
_M.CKM_CAST128_ECB = 0x00000321
_M.CKM_CAST5_CBC = 0x00000322
_M.CKM_CAST128_CBC = 0x00000322
_M.CKM_CAST5_MAC = 0x00000323
_M.CKM_CAST128_MAC = 0x00000323
_M.CKM_CAST5_MAC_GENERAL = 0x00000324
_M.CKM_CAST128_MAC_GENERAL = 0x00000324
_M.CKM_CAST5_CBC_PAD = 0x00000325
_M.CKM_CAST128_CBC_PAD = 0x00000325
_M.CKM_RC5_KEY_GEN = 0x00000330
_M.CKM_RC5_ECB = 0x00000331
_M.CKM_RC5_CBC = 0x00000332
_M.CKM_RC5_MAC = 0x00000333
_M.CKM_RC5_MAC_GENERAL = 0x00000334
_M.CKM_RC5_CBC_PAD = 0x00000335
_M.CKM_IDEA_KEY_GEN = 0x00000340
_M.CKM_IDEA_ECB = 0x00000341
_M.CKM_IDEA_CBC = 0x00000342
_M.CKM_IDEA_MAC = 0x00000343
_M.CKM_IDEA_MAC_GENERAL = 0x00000344
_M.CKM_IDEA_CBC_PAD = 0x00000345
_M.CKM_GENERIC_SECRET_KEY_GEN = 0x00000350
_M.CKM_CONCATENATE_BASE_AND_KEY = 0x00000360
_M.CKM_CONCATENATE_BASE_AND_DATA = 0x00000362
_M.CKM_CONCATENATE_DATA_AND_BASE = 0x00000363
_M.CKM_XOR_BASE_AND_DATA = 0x00000364
_M.CKM_EXTRACT_KEY_FROM_KEY = 0x00000365
_M.CKM_SSL3_PRE_MASTER_KEY_GEN = 0x00000370
_M.CKM_SSL3_MASTER_KEY_DERIVE = 0x00000371
_M.CKM_SSL3_KEY_AND_MAC_DERIVE = 0x00000372
_M.CKM_SSL3_MASTER_KEY_DERIVE_DH = 0x00000373
_M.CKM_TLS_PRE_MASTER_KEY_GEN = 0x00000374
_M.CKM_TLS_MASTER_KEY_DERIVE = 0x00000375
_M.CKM_TLS_KEY_AND_MAC_DERIVE = 0x00000376
_M.CKM_TLS_MASTER_KEY_DERIVE_DH = 0x00000377
_M.CKM_TLS_PRF = 0x00000378
_M.CKM_SSL3_MD5_MAC = 0x00000380
_M.CKM_SSL3_SHA1_MAC = 0x00000381
_M.CKM_MD5_KEY_DERIVATION = 0x00000390
_M.CKM_MD2_KEY_DERIVATION = 0x00000391
_M.CKM_SHA1_KEY_DERIVATION = 0x00000392
_M.CKM_SHA256_KEY_DERIVATION = 0x00000393
_M.CKM_SHA384_KEY_DERIVATION = 0x00000394
_M.CKM_SHA512_KEY_DERIVATION = 0x00000395
_M.CKM_SHA224_KEY_DERIVATION = 0x00000396
_M.CKM_PBE_MD2_DES_CBC = 0x000003A0
_M.CKM_PBE_MD5_DES_CBC = 0x000003A1
_M.CKM_PBE_MD5_CAST_CBC = 0x000003A2
_M.CKM_PBE_MD5_CAST3_CBC = 0x000003A3
_M.CKM_PBE_MD5_CAST5_CBC = 0x000003A4
_M.CKM_PBE_MD5_CAST128_CBC = 0x000003A4
_M.CKM_PBE_SHA1_CAST5_CBC = 0x000003A5
_M.CKM_PBE_SHA1_CAST128_CBC = 0x000003A5
_M.CKM_PBE_SHA1_RC4_128 = 0x000003A6
_M.CKM_PBE_SHA1_RC4_40 = 0x000003A7
_M.CKM_PBE_SHA1_DES3_EDE_CBC = 0x000003A8
_M.CKM_PBE_SHA1_DES2_EDE_CBC = 0x000003A9
_M.CKM_PBE_SHA1_RC2_128_CBC = 0x000003AA
_M.CKM_PBE_SHA1_RC2_40_CBC = 0x000003AB
_M.CKM_PKCS5_PBKD2 = 0x000003B0
_M.CKM_PBA_SHA1_WITH_SHA1_HMAC = 0x000003C0
_M.CKM_WTLS_PRE_MASTER_KEY_GEN = 0x000003D0
_M.CKM_WTLS_MASTER_KEY_DERIVE = 0x000003D1
_M.CKM_WTLS_MASTER_KEY_DERIVE_DH_ECC = 0x000003D2
_M.CKM_WTLS_PRF = 0x000003D3
_M.CKM_WTLS_SERVER_KEY_AND_MAC_DERIVE = 0x000003D4
_M.CKM_WTLS_CLIENT_KEY_AND_MAC_DERIVE = 0x000003D5
_M.CKM_KEY_WRAP_LYNKS = 0x00000400
_M.CKM_KEY_WRAP_SET_OAEP = 0x00000401
_M.CKM_CMS_SIG = 0x00000500
_M.CKM_KIP_DERIVE = 0x00000510
_M.CKM_KIP_WRAP = 0x00000511
_M.CKM_KIP_MAC = 0x00000512
_M.CKM_CAMELLIA_KEY_GEN = 0x00000550
_M.CKM_CAMELLIA_ECB = 0x00000551
_M.CKM_CAMELLIA_CBC = 0x00000552
_M.CKM_CAMELLIA_MAC = 0x00000553
_M.CKM_CAMELLIA_MAC_GENERAL = 0x00000554
_M.CKM_CAMELLIA_CBC_PAD = 0x00000555
_M.CKM_CAMELLIA_ECB_ENCRYPT_DATA = 0x00000556
_M.CKM_CAMELLIA_CBC_ENCRYPT_DATA = 0x00000557
_M.CKM_CAMELLIA_CTR = 0x00000558
_M.CKM_ARIA_KEY_GEN = 0x00000560
_M.CKM_ARIA_ECB = 0x00000561
_M.CKM_ARIA_CBC = 0x00000562
_M.CKM_ARIA_MAC = 0x00000563
_M.CKM_ARIA_MAC_GENERAL = 0x00000564
_M.CKM_ARIA_CBC_PAD = 0x00000565
_M.CKM_ARIA_ECB_ENCRYPT_DATA = 0x00000566
_M.CKM_ARIA_CBC_ENCRYPT_DATA = 0x00000567
_M.CKM_SKIPJACK_KEY_GEN = 0x00001000
_M.CKM_SKIPJACK_ECB64 = 0x00001001
_M.CKM_SKIPJACK_CBC64 = 0x00001002
_M.CKM_SKIPJACK_OFB64 = 0x00001003
_M.CKM_SKIPJACK_CFB64 = 0x00001004
_M.CKM_SKIPJACK_CFB32 = 0x00001005
_M.CKM_SKIPJACK_CFB16 = 0x00001006
_M.CKM_SKIPJACK_CFB8 = 0x00001007
_M.CKM_SKIPJACK_WRAP = 0x00001008
_M.CKM_SKIPJACK_PRIVATE_WRAP = 0x00001009
_M.CKM_SKIPJACK_RELAYX = 0x0000100a
_M.CKM_KEA_KEY_PAIR_GEN = 0x00001010
_M.CKM_KEA_KEY_DERIVE = 0x00001011
_M.CKM_FORTEZZA_TIMESTAMP = 0x00001020
_M.CKM_BATON_KEY_GEN = 0x00001030
_M.CKM_BATON_ECB128 = 0x00001031
_M.CKM_BATON_ECB96 = 0x00001032
_M.CKM_BATON_CBC128 = 0x00001033
_M.CKM_BATON_COUNTER = 0x00001034
_M.CKM_BATON_SHUFFLE = 0x00001035
_M.CKM_BATON_WRAP = 0x00001036
_M.CKM_ECDSA_KEY_PAIR_GEN = 0x00001040
_M.CKM_EC_KEY_PAIR_GEN = 0x00001040
_M.CKM_ECDSA = 0x00001041
_M.CKM_ECDSA_SHA1 = 0x00001042
_M.CKM_ECDH1_DERIVE = 0x00001050
_M.CKM_ECDH1_COFACTOR_DERIVE = 0x00001051
_M.CKM_ECMQV_DERIVE = 0x00001052
_M.CKM_JUNIPER_KEY_GEN = 0x00001060
_M.CKM_JUNIPER_ECB128 = 0x00001061
_M.CKM_JUNIPER_CBC128 = 0x00001062
_M.CKM_JUNIPER_COUNTER = 0x00001063
_M.CKM_JUNIPER_SHUFFLE = 0x00001064
_M.CKM_JUNIPER_WRAP = 0x00001065
_M.CKM_FASTHASH = 0x00001070
_M.CKM_AES_KEY_GEN = 0x00001080
_M.CKM_AES_ECB = 0x00001081
_M.CKM_AES_CBC = 0x00001082
_M.CKM_AES_MAC = 0x00001083
_M.CKM_AES_MAC_GENERAL = 0x00001084
_M.CKM_AES_CBC_PAD = 0x00001085
_M.CKM_AES_CTR = 0x00001086
_M.CKM_BLOWFISH_KEY_GEN = 0x00001090
_M.CKM_BLOWFISH_CBC = 0x00001091
_M.CKM_TWOFISH_KEY_GEN = 0x00001092
_M.CKM_TWOFISH_CBC = 0x00001093
_M.CKM_DES_ECB_ENCRYPT_DATA = 0x00001100
_M.CKM_DES_CBC_ENCRYPT_DATA = 0x00001101
_M.CKM_DES3_ECB_ENCRYPT_DATA = 0x00001102
_M.CKM_DES3_CBC_ENCRYPT_DATA = 0x00001103
_M.CKM_AES_ECB_ENCRYPT_DATA = 0x00001104
_M.CKM_AES_CBC_ENCRYPT_DATA = 0x00001105
_M.CKM_DSA_PARAMETER_GEN = 0x00002000
_M.CKM_DH_PKCS_PARAMETER_GEN = 0x00002001
_M.CKM_X9_42_DH_PARAMETER_GEN = 0x00002002
_M.CKM_VENDOR_DEFINED = 0x80000000


local find_a_key_by_id = function ( key_type )
  return function (self, key_id)
    
    local ul_count = 2
    local searchTemplatePtr = ffi_new ( 'CK_ATTRIBUTE[?]', ul_count )
    local cast_key_id  = ffi_cast ('CK_VOID_PTR', key_id)

    local class_type_ptr = ffi_new('CK_OBJECT_CLASS[1]') 
    class_type_ptr[0] = key_type
    searchTemplatePtr[0].type = _M.CKA_CLASS
    searchTemplatePtr[0].pValue = class_type_ptr
    searchTemplatePtr[0].ulValueLen = ffi_sizeof("CK_OBJECT_CLASS")

    searchTemplatePtr[1].type = _M.CKA_ID
    searchTemplatePtr[1].pValue = cast_key_id
    searchTemplatePtr[1].ulValueLen = #key_id 

    return self:find_object( searchTemplatePtr , ul_count)
  end
end

local crypto_init = function (driver_function) 

  return function (self, mechanism_type, h_key_ptr, mech_param, mech_param_size)
    if not _M.driver then
      return nil, "Module not initialized"
    end

    if not self or not self._sessionPtr then
      return nil, "Not valid session"
    end

    local mechanismPtr = ffi_new ( 'CK_MECHANISM[1]' )
    mechanismPtr[0].mechanism = mechanism_type
    mechanismPtr[0].pParameter = mech_param
    mechanismPtr[0].ulParameterLen = mech_param_size or 0

    local ckr = driver_function(self._sessionHandle, mechanismPtr, h_key_ptr[0] )
    if not ckr or ckr ~= CKR_OK then
      return err_out(ckr, "Initialization failed: ")
    end

    return true
    
  end 
end


local crypto_in_out = function ( driver_function )
  
  return function (self, data) 
    if not _M.driver then
      return nil, "Module not initialized"
    end

    if not self or not self._sessionPtr then
      return nil, "Not valid session"
    end

    local data_len = #data
    local cast_data = ffi_cast ('CK_BYTE_PTR', data)

    self._buffer_size[0] = _M.max_buffer_size

    local ckr = driver_function(self._sessionHandle, cast_data, data_len, self._buffer, self._buffer_size)
    if not ckr or ckr ~= CKR_OK then
      return err_out(ckr, "Crypto operation failed: ")
    end

    return ffi_string(self._buffer, self._buffer_size[0]), self._buffer_size[0]
  end
end


local crypto_out = function ( driver_function ) 
  return function (self)
    if not _M.driver then
      return nil, "Module not initialized"
    end

    if not self or not self._sessionPtr then
      return nil, "Not valid session"
    end

    self._buffer_size[0] = _M.max_buffer_size

    local ckr = driver_function(self._sessionHandle, self._buffer, self._buffer_size)
    if not ckr or ckr ~= CKR_OK then
      return err_out(ckr, "Crypro operation failed: ")
    end

    return ffi_string(self._buffer, self._buffer_size[0]), self._buffer_size[0]  
  end
end


local crypto_in  = function ( driver_function ) 
  return function (self, data) 
    if not _M.driver then
      return nil, "Module not initialized"
    end

    if not self or not self._sessionPtr then
      return nil, "Not valid session"
    end

    local data_len = #data
    local cast_data = ffi_cast ('CK_BYTE_PTR', data)

    local ckr = driver_function(self._sessionHandle, cast_data, data_len)
    if not ckr or ckr ~= CKR_OK then
      return err_out(ckr, "Crypro operation failed: ")
    end

    return true
  end
end


_M.init = function ( options ) 

  local driver_library = options['driver'] 
  
  if not driver_library or  #driver_library == 0 then 
    return false, "Missing HSM driver"
  end
  
  local driver = ffi_load(driver_library)

  if not driver then 
    return false, "Unable to load HSM driver : " .. driver_library
  end

  local ckr = driver.C_Initialize(nil)
  
  if not ckr or ckr ~= CKR_OK then
    return err_out (ckr, "Unable to initilize HSM module: ")
  end

  _M.max_buffer_size = options.max_buffer_size or 2048 
  _M.driver = driver

  _M.find_public_key_by_id =  find_a_key_by_id( _M.CKO_PUBLIC_KEY )
  _M.find_private_key_by_id = find_a_key_by_id( _M.CKO_PRIVATE_KEY )
  _M.find_secret_key_by_id = find_a_key_by_id( _M.CKO_SECRET_KEY )

  _M.encrypt_init = crypto_init( _M.driver.C_EncryptInit )
  _M.decrypt_init = crypto_init( _M.driver.C_DecryptInit )
  _M.sign_init =  crypto_init( _M.driver.C_SignInit  )
  _M.verify_init = crypto_init( _M.driver.C_VerifyInit)
  
  _M.encrypt = crypto_in_out ( _M.driver.C_Encrypt )
  _M.encrypt_update =  crypto_in_out ( _M.driver.C_EncryptUpdate )
  _M.decrypt =  crypto_in_out ( _M.driver.C_Decrypt )
  _M.decrypt_update =  crypto_in_out (_M.driver.C_DecryptUpdate )
  _M.sign =  crypto_in_out ( _M.driver.C_Sign )
  _M.encrypt_final  = crypto_out ( _M.driver.C_EncryptFinal )
  _M.decrypt_final =  crypto_out ( _M.driver.C_DecryptFinal )
  _M.sign_final = crypto_out ( _M.driver.C_SignFinal )
  _M.sign_update = crypto_in ( _M.driver.C_SignUpdate )
  _M.verify_update = crypto_in ( _M.driver.C_VerifyUpdate )
  
  return true
end


_M.close = function () 
  if not _M.driver then return true end

  local ckr = _M.driver.C_Finalize(nil)
   _M.driver = nil

  if not ckr or ckr ~= CKR_OK then
    return err_out (ckr, "Unable to close HSM module: ")
  end
  return true
end


_M.close_all_sessions = function (slot_id)
  if not _M.driver then
    return nil, "Module not initialized"
  end

  local ckr = _M.driver.C_CloseAllSessions(slot_id)
   
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Failed to close sessions: ")
  end

  return true
end


_M.close_session = function(self)
  self.close = _M.close
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self._sessionPtr then
    return false, "Not valid session"
  end
  
  local ckr = _M.driver.C_CloseSession(self._sessionHandle)
   
  self._sessionPtr = nil
  self._sessionHandle = nil

  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Failed to close session: ")
  end

  return true
end


_M.new_session = function (slot_id, flags, application, notificationCallback)
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not flags then flags = _M.CKF_SERIAL_SESSION end

  local sessionHandlePtr = ffi_new('CK_SESSION_HANDLE[1]')

  local ckr = _M.driver.C_OpenSession(slot_id, flags, application, notificationCallback, sessionHandlePtr)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Unable to open session: ")
  end

  local out_buf = ffi_new("CK_BYTE[?]", _M.max_buffer_size)
  local out_len = ffi_new("CK_ULONG[1]")
  out_len[0] = _M.max_buffer_size

  return setmetatable ({
    _sessionPtr = sessionHandlePtr,
    _sessionHandle = sessionHandlePtr[0],
    _buffer = out_buf,
    _buffer_size = out_len,
    close = _M.close_session
  }, mt)

end


_M.login = function ( self, pin , user_type )
  
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self or not self._sessionPtr then
    return false, "Not valid session"
  end

  if not user_type then 
    return false, "Invalid user_type"
  end

  if not pin or #pin < 4 then 
    return false, "Invalid PIN"
  end
  
  local cast_pin  = ffi_cast ('CK_UTF8CHAR_PTR', pin)

  local ckr = _M.driver.C_Login(self._sessionHandle, user_type, cast_pin, #pin)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Unable to login: ")
  end

  return true
end


_M.logout = function ( self ) 
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self or not self._sessionPtr then
    return false, "Not valid session"
  end

  local ckr = _M.driver.C_Logout(self._sessionHandle)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Logout processing error: ")
  end

  return true
end


_M.find_object = function (self, searchTemplatePtr, ul_count)

  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self or not self._sessionPtr then
    return nil, "Not valid session"
  end

  
  local ckr = _M.driver.C_FindObjectsInit(self._sessionHandle, searchTemplatePtr, ul_count )
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Key search processing error: ")
  end

  local object_ptr = ffi_new('CK_OBJECT_HANDLE[1]')
  local number_of_returned_objects_ptr = ffi_new('CK_ULONG[1]')

  ckr = _M.driver.C_FindObjects(self._sessionHandle, object_ptr, 1, number_of_returned_objects_ptr )
  if not ckr or ckr ~= CKR_OK then
    _M.driver.C_FindObjectsFinal(self._sessionHandle)
    return err_out(ckr, "Key search processing error: ")
  end
 
  _M.driver.C_FindObjectsFinal(self._sessionHandle)

  if number_of_returned_objects_ptr[0] == 0 then 
    return nil, "Unable to find required object"
  end

  return object_ptr
end


_M.verify = function (self, data_to_verify, signature_to_verify) 
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self or not self._sessionPtr then
    return nil, "Not valid session"
  end

  local data_to_verify_len = #data_to_verify
  local cast_data_to_verify = ffi_cast ('CK_BYTE_PTR', data_to_verify)

  local signature_to_verify_len = #signature_to_verify
  local cast_signature_to_verify = ffi_cast ('CK_BYTE_PTR', signature_to_verify)
  
  local ckr = _M.driver.C_Verify(self._sessionHandle, cast_data_to_verify, data_to_verify_len, cast_signature_to_verify, signature_to_verify_len)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Verification failed: ")
  end

  return true

end


_M.verify_final = function (self, signature_to_verify) 
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self or not self._sessionPtr then
    return nil, "Not valid session"
  end

  local signature_to_verify_len = #signature_to_verify
  local cast_signature_to_verify = ffi_cast ('CK_BYTE_PTR', signature_to_verify)
  
  local ckr = _M.driver.C_Verify(self._sessionHandle,  cast_signature_to_verify, signature_to_verify_len)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Verification failed: ")
  end

  return true

end

return _M
