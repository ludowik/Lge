EventManager = class() : extends(MouseEvent, KeyboardEvent)

function EventManager.setup()
    eventManager = EventManager()
    love.keyboard.setKeyRepeat(true)
end

function EventManager:init()
    self.currentObject = nil
end

function EventManager:mousepressed(id, x, y)
    mouse:pressed(id, x, y)

    eventManager.currentObject = contains(mouse)
    if eventManager.currentObject then
        eventManager.currentObject:mousepressed(mouse)
    end
end

function EventManager:mousemoved(id, x, y)
    mouse:moved(id, x, y)
    
    if eventManager.currentObject then        
        eventManager.currentObject:mousemoved(mouse)
    end
end

function EventManager:mousereleased(id, x, y)
    mouse:released(id, x, y)
    
    if eventManager.currentObject then        
        eventManager.currentObject:mousereleased(mouse)
        eventManager.currentObject = nil
    end

    local mouseDirection = mouse:getDirection(H/3)
    if mouseDirection == 'up' then
        processManager:previous()
    elseif mouseDirection == 'down' then
        processManager:next()
    end
end

function EventManager:keypressed(key, scancode, isrepeat)
    if key == 'r' then
        reload(true)

    elseif key == 'z' then
        makezip()
    
    elseif key == 'i' then
        processManager:setSketch('info')

    elseif key == 's' then
        processManager:setSketch('sketches')

    elseif key == 'l' then
        processManager:loop()
    
    elseif key == 'f' then
        toggleFused()
    
    elseif key == 'escape' then
        quit()
    
    elseif key == 'pageup' then
        processManager:previous()
    
    elseif key == 'pagedown' then
        processManager:next()
    
    elseif key == 'kpenter' then
        processManager:loop()
    end

    processManager:current():keypressed(key, scancode, isrepeat)
end
