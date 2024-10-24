ProcessManager = class():extends(Node)

function ProcessManager.setup()
    processManager = ProcessManager()
end

function ProcessManager.openSketches()
    local sketch = processManager:current()
    if sketch.__className ~= 'sketches' then            
        processManager:setSketch('Sketches')
        engine.parameter.visible = false
    else
        sketch.env.navigate()
    end
end

function ProcessManager:init()
    self.processIndex = 1
end

function ProcessManager:setSketch(name)
    assert(name)

    local index = self:findSketch(name)
    if index then 
        self:setCurrentSketch(index)
    end
end

function ProcessManager:findSketch(name)
    if not name then return end

    name = name:lower()
    for i, env in ipairs(self.items) do
        if env.__name == name then
            return i
        end
    end
end

function ProcessManager:findSketches(keyword)
    if not keyword then return end

    local sketches = Array()

    keyword = keyword:lower()
    for i, env in ipairs(self.items) do
        if env.__name:contains(keyword) then
            sketches:add(i)
        end
    end
    
    return sketches
end

function ProcessManager:getSketch(index)
    if not index then return end
    return self.items[index]
end

function ProcessManager:setCurrentSketch(processIndex)
    local sketch = self:current()
    if sketch then sketch:pause() end

    collectgarbage('collect')
    
    self.processIndex = processIndex
    loadSketch(self.items[self.processIndex])
    
    local sketch = self:current()
    if not sketch then return end

    _G.env = sketch.env

    sketch:resume()

    setSetting('sketch', sketch.env.__name)

    love.window.setTitle(sketch.env.__name)
    log(sketch.env.__name)

    --Graphics.setMode(sketch.size.x, sketch.size.y)

    sketch.fb:setContext()
    sketch.fb:background()
    resetContext()

    if instrument then
        instrument:reset()
    end

    engine.parameter.items[#engine.parameter.items].items[1].label = sketch.env.__name
    engine.parameter.items[#engine.parameter.items].items[2] = sketch.parameter.items[1]

    redraw()
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

local LOOP_PROCESS_DT = 1/60
local LOOP_PROCESS_N = 15
local LOOP_PROCESS_DELAY = LOOP_PROCESS_N * LOOP_PROCESS_DT

function ProcessManager:loopProcesses()
    if self.__loopProcesses then
        self.__loopProcesses = nil
    else
        self.__loopProcesses = {
            startProcess = self:current(),
        }
    end
end

function ProcessManager:update(dt)    
    local sketch = processManager:current()

    if self.__loopProcesses then
        self:updateLoop(dt)
    elseif sketch then
        sketch:updateSketch(dt)
    end
end

function ProcessManager:updateLoop(dt)
    if self.__loopProcesses then
        self:next()

        local sketch = processManager:current()
        assert(sketch)

        local delay = LOOP_PROCESS_DELAY
        local dt = LOOP_PROCESS_DT
        local n = 0
        local startTime = time()

        sketch.env.__autotest = true
        love.window.setVSync(0)
            
        while true do
            n = n + 1

            sketch:updateSketch(dt)
            sketch:drawSketch()

            love.graphics.present()
            
            if time() - startTime > delay or n >= LOOP_PROCESS_N then
                break
            end
        end

        love.window.setVSync(1)
        sketch.env.__autotest = false

        -- captureImage()
        -- captureLogo()

        if sketch == self.__loopProcesses.startProcess then
            self.__loopProcesses = nil
        else
            --self:updateLoop(dt)
        end
    end
end