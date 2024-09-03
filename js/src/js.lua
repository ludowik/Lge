js = require 'js'

require 'lua.require'
require 'lua.class'
require 'lua.array'
require 'lua.string'

require 'maths.math'
require 'maths.vec2'
require 'maths.rect'
require 'maths.random'

require 'graphics.color'
require 'graphics.anchor'

require 'events.mouse_event'
require 'events.event_manager'

require 'scene.bind'
require 'scene.layout'
require 'scene.ui'
require 'scene.ui_button'
require 'scene.ui_slider'
require 'scene.node'
require 'scene.scene'
require 'scene.parameter'

require 'engine.sketch'

require 'js.src.graphics'
require 'js.src.transform'

Color.setup()
--EventManager.setup()

function loop()
    return js.global:loop()
end

function noLoop()
    return js.global:noLoop()
end

function noise(...)
    return js.global:noise(...)
end

function __setup()
    window = js.global

    W = js.global.innerWidth
    H = js.global.innerHeight

    CX = W/2
    CY = H/2

    MIN_SIZE = min(W, H)
    MAX_SIZE = max(W, H)

    SIZE = MIN_SIZE

    SCALE = 1

    LEFT = 5
    TOP = 5

    elapsedTime = 0

    env = _G

    parameter = Parameter('right')

    if __sketch then
        print('sketch')
        if __sketch.setup then 
            __sketch.setup()
        end
        
        sketch = __sketch()
        return
    end

    return setup and setup()
end

function __update()
    deltaTime = js.global.deltaTime / 1000
    elapsedTime = elapsedTime + deltaTime

    if sketch then
        if sketch.update then
            sketch:update(deltaTime)
        end
        return
    end
    return update and update(deltaTime)
end

function __draw()
    blendMode(NORMAL)

    js.global:ellipseMode(js.global.RADIUS)
    js.global:angleMode(js.global.RADIANS)
    js.global:colorMode(js.global.RGB, 1)

    local result
    if sketch then
        if sketch.draw then
            sketch:draw()
        end
    else
        result = draw and draw()
    end

    --parameter:draw()

    return result
end

require 'sketch.geometric art.hexagone'
