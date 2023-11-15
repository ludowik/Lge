ProcessManager = class():extends(Node)

function ProcessManager.setup()
    processManager = ProcessManager()
end

function ProcessManager:init()
    self.processIndex = 1
end

function ProcessManager:setSketch(name)
    if not name then return end

    name = name:lower()
    for i, env in ipairs(self.items) do
        if env.__className == name then
            self:setCurrentSketch(i)
            break
        end
    end
end

function ProcessManager:getSketch(nameOrIndex)
    if not nameOrIndex then return end

    if type(nameOrIndex) == 'number' then
        return self.items[nameOrIndex]
        
    else
        nameOrIndex = nameOrIndex:lower()
        for i, env in ipairs(self.items) do
            if env.__className == nameOrIndex then
                return env.sketch
            end
        end
    end
end

function ProcessManager:setCurrentSketch(processIndex)
    local process = self:current()
    if process and process.pause then process:pause() end

    collectgarbage('collect')

    self.processIndex = processIndex

    loadSketch(self.items[self.processIndex])
    local process = self:current()

    _G.env = process.env or _G.env
    setfenv(0, _G.env)
    if process.resume then process:resume() end

    setSettings('sketch', process.__className)

    love.window.setTitle(process.__className)

    process.fb:setContext()
    process.fb:background()
    resetContext()

    if instrument then
        instrument:reset()
    end

    engine.parameter.items[#engine.parameter.items].items[1].label = process.__className
    engine.parameter.items[#engine.parameter.items].items[2] = process.parameter.items[1]

    redraw()
end

LOOP_ITER_PROCESS = 1

function ProcessManager:loopProcesses()
    if self.__loopProcesses then
        self.__loopProcesses = nil
    else
        self.__loopProcesses = {
            startProcess = self:current(),
            famesToDraw = LOOP_ITER_PROCESS
        }
    end
end

function ProcessManager:update(dt)
    -- TODO
    if not self:current() then return end

    if self.__loopProcesses then
        self.__loopProcesses.famesToDraw = self.__loopProcesses.famesToDraw - 1
        if self.__loopProcesses.famesToDraw <= 0 then
            self:next()
            self.__loopProcesses.famesToDraw = LOOP_ITER_PROCESS

            for i in range(10) do
                self:current():updateSketch(dt)
                self:current():drawSketch()
                love.graphics.present()
            end

            if self:current() == self.__loopProcesses.startProcess then
                self.__loopProcesses = nil
            end
        end
    end

    self:current():updateSketch(dt)
end

function ProcessManager:current()
    return self.items[self.processIndex].sketch
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
