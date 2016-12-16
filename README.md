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

3. Use softhsm2-util to setup slot and upload key
```  
softhsm2-util --init-token --slot 899348241 --label "Test 1 token" 
softhsm2-util --import ./private_key.pem --slot 899348241 --id "12345678" --label "my test key"
```

4. Check status 
```
softhsm2-util --show-slots
```

4. In src/resty directory run test script :
``` 
luajit pkcs11_test.lua 
```
  
##Basic Usage:
```
local hsm_module = require('pkcs11')

-- init module with softhsm driver 
local ok, err = hsm_module.init({
    driver = "/usr/local/Cellar/openssl/1.0.2j/lib/engines/libsofthsm2.so"
});

-- open session with slot ID 899348241
local hsmSession, err = hsm_module.new_session(0x359af711)

-- login as read only user
ok, err = hsmSession:login("1234", hsm_module.CKU_USER)

-- get your encryption key identified by ID
key_ptr, err = hsmSession:find_key("12345678")

-- TODO : use the key for crypto operations 

-- make clean up 
ok, err = hsmSession:logout()
ok, err = hsmSession:close()
ok, err = hsm_module.close()

```
