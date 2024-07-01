class().setup = function ()
    seed(os.time())
end

seed = function (value)
    return love.math.setRandomSeed(value)
end

random = function (min, max)
    if min and max then 
        return love.math.random() * (max-min) + min
    elseif min then         
        return love.math.random() * min
    else
        return love.math.random()
    end
end
randomInt = love.math.random

noise = love.math.simplexNoise or love.math.perlinNoise or love.math.noise
noiseSeed = love.math.setRandomSeed

simplexNoise = love.math.simplexNoise or love.math.noise
perlinNoise = love.math.perlinNoise or love.math.noise
