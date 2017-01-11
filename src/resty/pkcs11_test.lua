local hsm_module = require('pkcs11')

local ok, err = hsm_module.init({
    driver = "/usr/local/lib/softhsm/libsofthsm2.so"
});

if not ok then print ( err ) return end

print ("Module initialized")

local hsmSession, err = hsm_module.new_session(1853662351)

if not hsmSession then print ( err ) end

print ( "Session opened = ", tonumber(hsmSession._sessionHandle))


ok, err = hsmSession:login("1234", hsm_module.CKU_USER)
if not ok then 
  print (err)
else
  print ("Login succesfull")
end


local plain_data = "abcdef"
local encrypted_data

local key_ptr, err = hsmSession:find_public_key_by_id("\x01\x02\x03\x04")
if not key_ptr then
  print (err)
else
  print ("I have a key")

  ok, err = hsmSession:encrypt_init(hsm_module.CKM_RSA_PKCS, key_ptr)
  if not ok then 
    print (err)
  else
    print ("Encryption init succesfull")
  end
  
  encrypted_data, err = hsmSession:encrypt(plain_data)

  if not encrypted_data then 
    print (err) 
  end
  
  print ("I've encrypted some plain data")

end

key_ptr, err = hsmSession:find_private_key_by_id("\x01\x02\x03\x04")
if not key_ptr then
  print (err)
else
  print ("I have the private key")

  ok, err = hsmSession:decrypt_init(hsm_module.CKM_RSA_PKCS, key_ptr)
  if not ok then 
    print (err)
  else
    print ("Decryption init succesfull")
  end
  
  local returned_plain_data, err = hsmSession:decrypt(encrypted_data)

  if not returned_plain_data then 
    print (err) 
  end
  
  print ("I've decrypted data: " .. returned_plain_data)

end

local signature

ok, err = hsmSession:sign_init(hsm_module.CKM_RSA_X_509, key_ptr)
if not ok then 
  print (err)
else
  print ("Signature init succesfull")
  
  signature, err = hsmSession:sign(plain_data)

  if not signature then 
    print (err) 
  end
  
  print ("I've signed plain data : ")


  key_ptr, err = hsmSession:find_public_key_by_id("\x01\x02\x03\x04")
  if not key_ptr then
    print (err)
  else
    print ("I have a key")

    ok, err = hsmSession:verify_init(hsm_module.CKM_RSA_X_509, key_ptr)
    if not ok then 
      print (err)
    else
      print ("Verification init succesfull")
    end
    
    ok, err = hsmSession:verify(plain_data, signature)

    if not ok then 
      print (err) 
    end
    
    print ("Signed data verified")

  end

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

