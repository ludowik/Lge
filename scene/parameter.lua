Parameter = class():extends(Scene)

function Parameter.setup()
    Parameter.innerMarge = 5
end

function Parameter:initNavigation()
    self.layoutMode = 'left'

    self:action('sketches',
        function ()
            local process = processManager:current()
            if process.__className ~= 'sketches' then            
                processManager:setSketch('Sketches')
                self:setStateForAllGroups('close', true)
            else
                process.env.navigate()
            end
        end,
        {
            styles = {
                fillColor = colors.transparent,
                strokeColor = colors.transparent,
                textColor = colors.transparent,
            },
            fixedPosition = vec2(Anchor(3, 6):pos(0, 0).x, -Y),
            fixedSize = Anchor(3, 4):size(1.25, 1)
        })

    self:action('menu',
        function ()
            -- if #engine.parameter.sketchMenu.items > 1 then return end
            engine.parameter.visible = not engine.parameter.visible
        end,
        {
            styles = {
                fillColor = colors.transparent,
                strokeColor = colors.transparent,
                textColor = colors.transparent,
            },
            fixedPosition = vec2(Anchor(3, 6):pos(1.75, 0).x, -Y),
            fixedSize = Anchor(3, 4):size(1.25, 1)
        })
end

function Parameter:initMenu()
    self.layoutMode = 'right'

    self.menu = self:group('menu')

    self:action('update from git', function ()
        updateScripts(true)
        quit()
    end)
    self:action('update from local', function ()
        updateScripts(false)
        quit()
    end)
    self:action('reload', reload)
    self:action('restart', restart)
    self:action('exit', exit)

    self:space()
    self:action('info', function ()
        processManager:setSketch('Info')
        self:openGroup(self.sketchMenu)
    end)

    self:action('sketches', function ()
        processManager:setSketch('Sketches')        
        self:openGroup(self.sketchMenu)
    end)
    
    self:space()
    self:action('fused', function () toggleFused() end)
    self:action('next', function () processManager:next() end)
    self:action('previous', function () processManager:previous() end)
    self:action('random', function () processManager:random() end)
    self:action('loop', function () processManager:loop() end)

    self.sketchMenu = self:group('sketch', true)
end

function Parameter:init()
    Scene.init(self)
    self.currentGroup = self
end

function Parameter:openGroup(group)
    self:setStateForAllGroups('close', false)
    group.state = 'open'
    group.visible = true
end

function Parameter:closeGroup(group)
    self:setStateForAllGroups('close', true)
    group.state = 'close'
    group.visible = true
end

function Parameter:setStateForAllGroups(state, visible)
    state = state
    visible = visible or false
    self:foreach(
        function(node)
            if node.state then
                node.state = state
                node.visible = visible
            end
        end)
end

function Parameter:group(label, open)
    local newGroup = Node()

    if open then
        self:openGroup(newGroup)
    else
        newGroup.state = 'close'
        newGroup.visible = true
    end

    local newButton = UIButton(label, function ()
        if fused() then return end

        if newGroup.state == 'close' then
            self:openGroup(newGroup)
        else
            if newGroup == self.items[1] then
                self:openGroup(self.items[2])
            else
                self:openGroup(self.items[1])
            end
        end
    end)

    newButton:attrib {
        parent = newGroup,
        styles = {
            fillColor = colors.blue,
            textColor = colors.white,
        },
        mousereleased = function (...)
            MouseEvent.mousereleased(...)
        end,
    }

    newGroup:add(newButton)

    self.currentGroup = newGroup
    self:add(self.currentGroup)

    return newGroup
end

function Parameter:declareParameter(varName, initValue)
    if type(varName) == 'string' and env[varName] == null then
        env[varName] = initValue
    end
end
function Parameter:space()
    self.currentGroup:add(UI())
end

function openURL(url)    
    love.system.openURL(url)
end

function Parameter:link(label, url)
    self.currentGroup:add(UIButton(label, function ()
        openURL(url or label)
    end))
end

function Parameter:linksearch(label)
    self.currentGroup:add(UIButton(label, function ()
        openURL('https://www.google.com/search?q='..label)
    end))
end

function Parameter:action(label, callback, attribs)
    local ui = UIButton(label, callback)
    if attribs then
        ui:attrib(attribs)
    end
    self.currentGroup:add(ui)
end

function Parameter:watch(label, expression)
    self.currentGroup:add(UIExpression(label, expression))
end

function Parameter:boolean(label, varName, initValue, callback)
    self:declareParameter(varName, initValue)
    self.currentGroup:add(UICheck(label, varName, callback))
end

function Parameter:integer(label, varName, min, max, initValue, callback)
    self:declareParameter(varName, initValue or min)
    local ui = UISlider(label, varName, min, max, callback)
    ui.intValue = true
    ui.incrementValue = 1
    self.currentGroup:add(ui)
    return ui
end

function Parameter:number(label, varName, min, max, initValue, callback)
    self:declareParameter(varName, initValue or min)
    local ui = UISlider(label, varName, min, max, callback)
    ui.intValue = false
    ui.incrementValue = 0.2
    self.currentGroup:add(ui)
    return ui
end

function Parameter:draw(x, y)
    self:layout(x, y)
    Scene.draw(self)
end
