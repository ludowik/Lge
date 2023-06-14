require 'lua.debug'
require 'lua.require'
require 'lua.string'
require 'class'
require 'index'
require 'event'
require 'rect'
require 'graphics2d'
require 'state'
require 'sketch'
require 'engine'

MySketch = class():extends(Sketch)

function MySketch:init()
    Sketch.init(self)
end

function MySketch:draw()
    love.graphics.clear(255, 0, 0)
    love.graphics.setFont(font)
    text("hello "..self.index, 100 + 100 * self.index, 100)
end

sketches = {
    MySketch(),
    MySketch(),
    MySketch(),
    MySketch(),
    MySketch(),
    MySketch()
}
