private.generate_sha256 = function(data)
    local H = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    }
    local K = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    }
    
    local function rightRotate(value, shift)
        return ((value >> shift) | (value << (32 - shift))) & 0xFFFFFFFF
    end
    
    local function chunkProcess(chunk, H)
        local w = {}
        for i = 0, 15 do
            w[i] = (chunk:byte(i*4 + 1) << 24) + (chunk:byte(i*4 + 2) << 16) + 
                   (chunk:byte(i*4 + 3) << 8) + chunk:byte(i*4 + 4)
        end
        for i = 16, 63 do
            local s0 = rightRotate(w[i-15], 7) ~ rightRotate(w[i-15], 18) ~ (w[i-15] >> 3)
            local s1 = rightRotate(w[i-2], 17) ~ rightRotate(w[i-2], 19) ~ (w[i-2] >> 10)
            w[i] = (w[i-16] + s0 + w[i-7] + s1) & 0xFFFFFFFF
        end
        
        local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
        for i = 0, 63 do
            local S1 = rightRotate(e, 6) ~ rightRotate(e, 11) ~ rightRotate(e, 25)
            local ch = (e & f) ~ ((~e) & g)
            local temp1 = (h + S1 + ch + K[i+1] + w[i]) & 0xFFFFFFFF
            local S0 = rightRotate(a, 2) ~ rightRotate(a, 13) ~ rightRotate(a, 22)
            local maj = (a & b) ~ (a & c) ~ (b & c)
            local temp2 = (S0 + maj) & 0xFFFFFFFF
            
            h = g
            g = f
            f = e
            e = (d + temp1) & 0xFFFFFFFF
            d = c
            c = b
            b = a
            a = (temp1 + temp2) & 0xFFFFFFFF
        end
        
        H[1] = (H[1] + a) & 0xFFFFFFFF
        H[2] = (H[2] + b) & 0xFFFFFFFF
        H[3] = (H[3] + c) & 0xFFFFFFFF
        H[4] = (H[4] + d) & 0xFFFFFFFF
        H[5] = (H[5] + e) & 0xFFFFFFFF
        H[6] = (H[6] + f) & 0xFFFFFFFF
        H[7] = (H[7] + g) & 0xFFFFFFFF
        H[8] = (H[8] + h) & 0xFFFFFFFF
    end
    
    local bitlen = #data * 8
    local padding = (56 - (#data % 64)) % 64
    if padding == 0 then padding = 64 end
    local padded = data .. string.char(0x80) .. string.rep(string.char(0), padding - 1) .. 
                   string.pack('>I8', bitlen)
    
    for i = 1, #padded, 64 do
        chunkProcess(padded:sub(i, i+63), H)
    end
    
    local result = ''
    for i = 1, 8 do
        result = result .. string.format('%08x', H[i])
    end
    return result
end
