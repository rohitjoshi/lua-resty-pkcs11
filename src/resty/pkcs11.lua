local ffi = require("ffi")

ffi.cdef[[ 
  typedef void*             CK_VOID_PTR;

  typedef unsigned char     CK_BYTE;
  typedef unsigned long int CK_ULONG;
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
local CKR_TOKEN_NOT_PRESENT              = 0x000000E0
local CKR_TOKEN_NOT_RECOGNIZED           = 0x000000E1
local CKR_TOKEN_WRITE_PROTECTED          = 0x000000E2
local CKR_USER_ALREADY_LOGGED_IN         = 0x00000100
local CKR_USER_NOT_LOGGED_IN             = 0x00000101
local CKR_USER_PIN_NOT_INITIALIZED       = 0x00000102
local CKR_USER_TYPE_INVALID              = 0x00000103
local CKR_USER_ANOTHER_ALREADY_LOGGED_IN = 0x00000104
local CKR_USER_TOO_MANY_TYPES            = 0x00000105
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
RV_ERR_MSG[ CKR_TOKEN_NOT_PRESENT ] = "Token not present"
RV_ERR_MSG[ CKR_TOKEN_NOT_RECOGNIZED ] = "Token not recognized"
RV_ERR_MSG[ CKR_TOKEN_WRITE_PROTECTED ] = "Token protected for writting"
RV_ERR_MSG[ CKR_USER_ALREADY_LOGGED_IN ] = "User already logged-in"
RV_ERR_MSG[ CKR_USER_NOT_LOGGED_IN ] = "user not logged-in"
RV_ERR_MSG[ CKR_USER_PIN_NOT_INITIALIZED ] = "User didn't initialized PIN"
RV_ERR_MSG[ CKR_USER_TYPE_INVALID ] = "Unknown user type"
RV_ERR_MSG[ CKR_USER_ANOTHER_ALREADY_LOGGED_IN ] = "Another user already logged-in"
RV_ERR_MSG[ CKR_USER_TOO_MANY_TYPES ] = "Just one user type is allowed"
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
RV_ERR_MSG[ CKR_OBJECT_HANDLE_INVALID ] = "Invalid object hadle"             
RV_ERR_MSG[ CKR_OPERATION_ACTIVE ] = "Ongoing operation"                  
RV_ERR_MSG[ CKR_PIN_INVALID ] = "Invalid PIN"                       
RV_ERR_MSG[ CKR_PIN_LEN_RANGE ] = "Invalid size of PIN"                     
RV_ERR_MSG[ CKR_PIN_EXPIRED ] = "Expired PIN"                       


local CKA_ID                             = 0x00000102

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


_M.init = function ( options ) 

  local driver_library = options['driver'] 
  
  if not driver_library or  #driver_library == 0 then 
    return false, "Missing HSM driver"
  end
  
  local driver = ffi.load(driver_library)

  if not driver then 
    return false, "Unable to load HSM driver : " .. driver_library
  end

  local ckr = driver.C_Initialize(nil)
  
  if not ckr or ckr ~= CKR_OK then
    return err_out (ckr, "Unable to initilize HSM module: ")
  end

  _M.driver = driver
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

  local sessionHandlePtr = ffi.new('CK_SESSION_HANDLE[1]')

  local ckr = _M.driver.C_OpenSession(slot_id, flags, application, notificationCallback, sessionHandlePtr)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Unable to open session: ")
  end

  return setmetatable ({
    _sessionPtr = sessionHandlePtr,
    _sessionHandle = sessionHandlePtr[0],
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
  
  local cast_pin  = ffi.cast ('CK_UTF8CHAR_PTR', pin)

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


_M.find_key = function (self, key_id)

  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not self or not self._sessionPtr then
    return nil, "Not valid session"
  end

  local searchTemplatePtr = ffi.new ( 'CK_ATTRIBUTE[1]' )
  local ul_count = 0

  local cast_key_id  = ffi.cast ('CK_VOID_PTR', key_id)

  searchTemplatePtr[0].type = CKA_ID
  searchTemplatePtr[0].pValue = cast_key_id
  searchTemplatePtr[0].ulValueLen = #key_id

  local ckr = _M.driver.C_FindObjectsInit(self._sessionHandle, searchTemplatePtr, ul_count )
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Key search processing error: ")
  end

  local key_object_ptr = ffi.new('CK_OBJECT_HANDLE[1]')
  local number_of_returned_keys_ptr = ffi.new('CK_ULONG[1]')

  ckr = _M.driver.C_FindObjects(self._sessionHandle, key_object_ptr, 1, number_of_returned_keys_ptr )
  if not ckr or ckr ~= CKR_OK then
    _M.driver.C_FindObjectsFinal(self._sessionHandle)
    return err_out(ckr, "Key search processing error: ")
  end
 
  _M.driver.C_FindObjectsFinal(self._sessionHandle)

  if number_of_returned_keys_ptr[0] == 0 then 
    return nil, "Unable to find required key : " .. key_id
  end

  return key_object_ptr
end

return _M
