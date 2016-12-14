local ffi = require("ffi")

ffi.cdef[[ 
  typedef void*             CK_VOID_PTR;

  typedef unsigned long int CK_ULONG;
  
  typedef CK_ULONG          CK_RV;
  typedef CK_ULONG          CK_SLOT_ID;
  typedef CK_ULONG          CK_FLAGS;
  typedef CK_ULONG          CK_SESSION_HANDLE;
  typedef CK_SESSION_HANDLE * CK_SESSION_HANDLE_PTR;
  typedef CK_ULONG          CK_NOTIFICATION;

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

]]


local CKR_OK                            = 0x00000000
local CKR_HOST_MEMORY                   = 0x00000002
local CKR_GENERAL_ERROR                 = 0x00000005
local CKR_FUNCTION_FAILED               = 0x00000006
local CKR_ARGUMENTS_BAD                 = 0x00000007
local CKR_NEED_TO_CREATE_THREADS        = 0x00000009
local CKR_CANT_LOCK                     = 0x0000000A
local CKR_CRYPTOKI_ALREADY_INITIALIZED  = 0x00000191

local RV_ERR_MSG = {}
RV_ERR_MSG[ CKR_HOST_MEMORY ] = "HSM driver memory allocation error"
RV_ERR_MSG[ CKR_GENERAL_ERROR ] = "HSM General error"
RV_ERR_MSG[ CKR_FUNCTION_FAILED ] = "HSM processing failed" 
RV_ERR_MSG[ CKR_ARGUMENTS_BAD ] = "Bad arguments provided"
RV_ERR_MSG[ CKR_NEED_TO_CREATE_THREADS ] = "Need to create threads"
RV_ERR_MSG[ CKR_CANT_LOCK ] = "Driver unable to create mutex" 
RV_ERR_MSG[ CKR_CRYPTOKI_ALREADY_INITIALIZED ] = "HSM module already initialized"



local function err_out ( ckr , err_prefix )
  local err_string = RV_ERR_MSG[ckr] or ( "Unknown error: " .. ckr) 
  return false, err_prefix .. err_string  
end



local _M = {
  _VERSION = '0.01'
}
local mt = { __index = _M }

_M.CKF_SERIAL_SESSION = 0x00000004



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

_M.new_session = function (slotId, flags, application, notificationCallback)
  if not _M.driver then
    return nil, "Module not initialized"
  end

  if not flags then flags = _M.CKF_SERIAL_SESSION end

  local sessionHandlePtr = ffi.new('CK_SESSION_HANDLE[1]')

  local ckr = _M.driver.C_OpenSession(slotId, flags, application, notificationCallback, sessionHandlePtr)
  if not ckr or ckr ~= CKR_OK then
    return err_out(ckr, "Unable to open session: ")
  end

  return setmetatable ({
    _sessionPtr = sessionHandlePtr,
    _sessionHandle = sessionHandlePtr[0],
    close = _M.close_session
  }, mt)

end

return _M
