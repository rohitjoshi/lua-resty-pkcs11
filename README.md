# lua-resty-pkcs11
PKCS11(P11) binding for Lua

lua-resty-pkcs11 is a binding to PKCS11 library which allows to use Hardware Security Module(HSM) for your encryption/decryption.
This has been tested with SoftHSM.

Usage:
```
local pkcs11 = require("resty/pkcs11")
local softhsm = "/usr/local/lib/softhsm/libsofthsm.so"
local pkcs = pkcs11:new(softhsm)
if not pkcs then
    ngx.log(log.ERR,  "Failed to load :" , softhsm)
    return
end
  
local ok, code, msg = pkcs:enumerate_slots()

```
