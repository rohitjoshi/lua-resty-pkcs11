local hsm_module = require('pkcs11')

local ok, err = hsm_module.init({
    driver = "/usr/local/Cellar/openssl/1.0.2j/lib/engines/libsofthsm2.so"
});

if not ok then print ( err ) return end

print ("Module initialized")

local hsmSession, err = hsm_module.new_session(0x359af711)

if not hsmSession then print ( err ) end

print ( "Session opened = ", tonumber(hsmSession._sessionHandle))


ok, err = hsmSession:login("1234", hsm_module.CKU_USER)
if not ok then 
  print (err)
else
  print ("Login succesfull")
end

ok, err = hsmSession:logout()
if not ok then 
  print (err)
else
  print ("Logout succesfull")
end



ok, err = hsmSession:close()
if not ok then 
  print ( err ) 
else
  print ("Session closed")
end


ok, err = hsm_module.close()
if not ok then
  print (err)
  return
end

print ("Module closed")

