// LJ Perlin

rawset(_G, "perlin", {})

local x, y, z, w

function perlin.randomNumber()
    local t = x ^^ (x << 11)
    x, y, z, w = y, z, w, w ^^ (w >> 19) ^^ t ^^ (t >> 8)
    return w
end

function perlin.randomRange(a, b)
    return a + abs(perlin.randomNumber() % (b - a))
end

function perlin.randomChance(chance)
    return perlin.randomRange(0, FRACUNIT) <= chance
end

function perlin.setSeed(seed)
    x, y, z, w = seed, 3154710, 9406548, 1028369
    for _ = 1, perlin.randomRange(10, 100)
        perlin.randomNumber()
    end
end

perlin.setSeed(5197528)

addHook("NetVars", function(n)
    x = n($)
    y = n($)
    z = n($)
    w = n($)
end)