ProcessManager = class() : extends(Node)

function ProcessManager.setup()
    processManager = ProcessManager()
end

function ProcessManager:add(sketch)
    Node.add(self, sketch)
    self:setCurrentSketch(#self.items)
end

function ProcessManager:setSketch(name)
    if not name then return end
    
    name = name:lower()
    for i,process in ipairs(self.items) do
        if process.__className == name then
            self:setCurrentSketch(i)
            break
        end        
    end
end

function ProcessManager:getSketch(name)
    if not name then return end
    
    name = name:lower()
    for i,process in ipairs(self.items) do
        if process.__className == name then
            return process
        end        
    end
end

function ProcessManager:setCurrentSketch(processIndex)
    local process = self:current()
    if process and process.pause then process:pause() end

    collectgarbage('collect')

    self.processIndex = processIndex
    
    process = self:current()
    _G.env = process.env or _G.env
    setfenv(0, _G.env)
    if process and process.resume then process:resume() end

    love.window.setTitle(process.__className)

    process.fb:setContext()
    process.fb:background()
    resetContext()

    engine.parameter.items[#engine.parameter.items].items[1].label = process.__className
    engine.parameter.items[#engine.parameter.items].items[2] = process.parameter.items[1]

    redraw()
end

function ProcessManager:loop()
    self.loopOverProcess = not self.loopOverProcess
    self.loopLastProcess = self:current()
    self.loopIterProcess = 20
end

function ProcessManager:update(dt)
    if self.loopOverProcess then
        self.loopIterProcess = self.loopIterProcess - 1
        if self.loopIterProcess <= 0 then
            self:next()
            self.loopIterProcess = 20

            if self:current() == self.loopLastProcess then
                self.loopOverProcess = false
            end
        end
    end

    self:current():updateSketch(dt)
end

function ProcessManager:current()
    return self.items[self.processIndex]
end

function ProcessManager:previous()
    local processIndex = self.processIndex - 1
    if processIndex < 1 then
        processIndex = #self.items
    end
    self:setCurrentSketch(processIndex)
    return self:current()
end

function ProcessManager:next()
    local processIndex = self.processIndex + 1
    if processIndex > #self.items then
        processIndex = 1
    end
    self:setCurrentSketch(processIndex)
    return self:current()
end

function ProcessManager:random()
    self:setCurrentSketch(randomInt(#self.items))
    return self:current()
end
