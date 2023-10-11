function load(reload)
    declareSketches(reload)
    --loadSketches()

    processManager:setSketch(getSettings('sketch', 'sketches'))
end

local environnements = Array()
environnementsList = nil

function declareSketches(reload)
    local function scan(path, category)
        local directoryItems = love.filesystem.getDirectoryItems(path)
        for _,itemName in ipairs(directoryItems) do
            local name = itemName:gsub('%.lua', '')
            local itemPath = path..'/'..itemName

            local info = love.filesystem.getInfo(itemPath)
            if info.type == 'directory' then
                local infoInit = love.filesystem.getInfo(itemPath..'/'..'__init.lua')
                if infoInit then
                    declareSketch(name, itemPath, category, reload)
                else
                    -- recursive scan
                    scan(itemPath, itemName)
                end
            else
                declareSketch(name, itemPath, category, reload)
            end
        end
    end
    scan('sketch')

    environnementsList = Array()
    for k,env in pairs(environnements) do
        environnementsList:add(env)
    end
    environnementsList:sort(function (a, b)
        return (a.__category or '')..'.'..a.__name < (b.__category or '')..'.'..b.__name
    end)
end

Environnement = class()

function Environnement:init(name, itemPath, category)
    setmetatable(self, {__index = _G})
    setfenv(0, self)
    
    local requirePath = itemPath:gsub('%/', '%.'):gsub('%.lua', '')
    require(requirePath)

    self.__name = name
    self.__className = name:gsub('sketch%.', '')
    self.__category = category

    self.__sourceFile = itemPath
    self.__modtime = love.filesystem.getInfo(itemPath).modtime

    self.DeltaTime = 0
    self.ElapsedTime = 0
    self.indexFrame = 0
end
 
function declareSketch(name, itemPath, category, reload)    
    if reload then
        local requirePath = itemPath:gsub('%/', '%.'):gsub('%.lua', '')
        environnements[requirePath] = nil
        package.loaded[requirePath] = nil
    end
    
    if environnements[name] then return environnements[name] end

    local env = Environnement(name, itemPath, category)
    
    for k,v in pairs(env) do
        if isSketch(v) then
            _G[k] = v
            v.env = env
            env.__sketch = v
            break
        end
    end

    if env.__sketch or env.setup or env.draw then
        environnements[name] = env
    end

    processManager:add(env)
end

function isSketch(klass)
    if klass == Sketch then return true end
    if klass == nil or type(klass) ~= 'table' or klass.__inheritsFrom == nil then return false end
    return isSketch(klass.__inheritsFrom[1])
end

function loadSketches()
    for k,env in ipairs(environnementsList) do
        loadSketch(env)
    end
end

function loadSketch(env)
    if env.sketch then return end

    _G.env = env
    env.env = env

    if env.__sketch then
        env.sketch = env.__sketch()
        env.sketch.env = env

    elseif env.setup or env.draw then
        env.sketch = Sketch()
        env.sketch.env = env

        env.sketch.__className = env.__className

        env.parameter = env.sketch.parameter
        
        local function encapsulate(fname)
            if env[fname] then
                env.sketch[fname] = function (_, ...) return env[fname](...) end
            end
        end

        for _,fname in ipairs({
            'setup',
            'update',
            'draw',
            'pause',
            'resume',
            'mousepressed',
            'mousemoved',
            'mousereleased',
            'keypressed',
            'wheelmoved',
        }) do
            encapsulate(fname)
        end

        if env.sketch.setup then
            env.sketch:setup()
        end
    end
end
