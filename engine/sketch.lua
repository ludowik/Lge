Sketch = class() : extends(Index, State, Rect, FrameBuffer, MouseEvent, KeyboardEvent)

function Sketch:init(w, h)
    Index.init(self)
    State.init(self)

    local ws, hs

    if w then
        ws, hs = w, h
    else 
        w = w or (2*X+W)
        h = h or (2*Y+H)
        ws, hs = w/3, h/3
    end
    
    Rect.init(self, 0, 0, w, h)

    FrameBuffer.init(self, w, h)
    MouseEvent.init(self)
    KeyboardEvent.init(self)

    self:initMenu()

    processManager:add(self)
end

function Sketch:__tostring()
    return self.__className
end

function Sketch:initMenu()
    self.parameter = Parameter()
    self.parameter:add(UIExpression('fps', 'getFPS()'))
end

function Sketch:checkReload()
    local fileInfo = love.filesystem.getInfo(env.__sourceFile)
    if fileInfo.modtime > env.__modtime then
        env.__modtime = fileInfo.modtime
        reload(true)
    end
end

function Sketch:updateSketch(dt)
    self:checkReload()
    if self.update then
        self:update(dt)
    end
end

function Sketch:drawSketch()
    love.graphics.setCanvas()
    love.graphics.setShader()
    
    love.graphics.clear(0.1, 0.5, 0.1, 1)

    self:setContext()

    resetStyle()
    resetMatrix()

    self:draw()
    
    love.graphics.setCanvas()
    love.graphics.setShader()

    love.graphics.setColor(colors.white:rgba())
    love.graphics.setBlendMode('alpha')

    love.graphics.origin()

    if originMode() == BOTTOM_LEFT then
        love.graphics.scale(1, -1)
        love.graphics.translate(0, -(2*Y+H))
    end

    love.graphics.draw(self.canvas,
        self.position.x, -- x
        self.position.y, -- y
        0, -- rotation
        self.size.x / self.canvas:getWidth(), -- scale x
        self.size.y / self.canvas:getHeight()) -- scale y
end

function Sketch:draw()
    background()

    local scene = self.scene or env.scene
    if scene then
        scene:layout()
        scene:draw()
    else
        fontSize(W/4)

        textMode(CENTER)
        text(self.__className, self.size.x/2, self.size.y/2)
    end
end

function Sketch:mousepressed(mouse)
    self.active = true

    local scene = self.scene or env.scene
    if scene then
        return scene:mousepressed(mouse)
    end
end

function Sketch:mousemoved(mouse)
end

function Sketch:mousereleased(mouse)
    self.active = false
end
