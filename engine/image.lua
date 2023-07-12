FrameBuffer = class()

function FrameBuffer:init(w, h)
    self.canvas = love.graphics.newCanvas(w, h, {
        msaa = 5
    })

    local currentCanvas = love.graphics.getCanvas()
    self:setContext()
    self:background()

    love.graphics.setCanvas(currentCanvas)
end

function FrameBuffer:setContext()
    love.graphics.setCanvas(self.canvas)
end

function FrameBuffer:background()
    love.graphics.clear(0, 0, 0, 1)
end


Image = class() : extends(FrameBuffer)

function Image:init(w, h)
    FrameBuffer.init(self, w, h)
end
