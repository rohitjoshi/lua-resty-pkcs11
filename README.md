# lua-resty-pkcs11
PKCS11 binding for Lua: 

lua-resty-pkcs11 is a binding to PKCS11 library which allows to use Hardware Security Module(HSM) for your encryption/decryption.
This has been tested with SoftHSM.
 
For PKCS#11 API details see details see : [PKCS#11 standard](https://emea.emc.com/emc-plus/rsa-labs/standards-initiatives/pkcs-11-cryptographic-token-interface-standard.htm)

##Quick start guide

1. Install [SoftHSM](https://www.opendnssec.org/download/)

2. Generate private key : 
```  
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048 
```

3. Use softhsm2-util to setup slot and upload key. Use "1234" for all PINs.
```  
softhsm2-util --init-token --label "my_token" --slot 0 
softhsm2-util --import ./private_key.pem --token my_token --label my_key_pair --id 01020304
```

4. Check status 
```
softhsm2-util --show-slots
```

5. Update the pkcs11_test.lua to open correct slot. 

6. In src/resty directory run test script :
``` 
luajit pkcs11_test.lua 
```
  
##Basic Usage:
```
local hsm_module = require('pkcs11')

-- init module with softhsm driver 
local ok, err = hsm_module.init({
    driver = "/usr/local/lib/softhsm/libsofthsm2.so"
});

-- open session with slot ID 899348241
local hsmSession, err = hsm_module.new_session(0x359af711)

-- login as read only user
ok, err = hsmSession:login("1234", hsm_module.CKU_USER)

-- get your encryption key identified by ID
key_ptr, err = hsmSession:find_public_key_by_id("\x01\x02\x03\x04")


-- make clean up 
ok, err = hsmSession:logout()
ok, err = hsmSession:close()
ok, err = hsm_module.close()

```
