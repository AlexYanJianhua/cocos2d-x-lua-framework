
module("crypto", package.seeall)

function encryptAES256(plaintext, key)
    return CCCrypto:encryptAES256Lua(plaintext, string.len(plaintext), key, string.len(key))
end

function decryptAES256(ciphertext, key)
    return CCCrypto:decryptAES256Lua(ciphertext, string.len(ciphertext), key, string.len(key))
end

function encodeBase64(plaintext)
    return CCCrypto:encodeBase64Lua(plaintext, string.len(plaintext))
end

function decodeBase64(ciphertext)
    return CCCrypto:decodeBase64Lua(ciphertext)
end

function md5(input, isRawOutput)
    if type(isRawOutput) ~= "boolean" then isRawOutput = false end
    return CCCrypto:MD5Lua(input, string.len(input), isRawOutput)
end
