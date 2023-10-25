Environment = class()

function Environment.__newindex(self, key, ...)
    local result = rawset(self, key, ...)

    -- TODO : useless ?
    self.__ordered = self.__ordered or {}
    table.insert(self.__ordered, key)

    return result
end

-- TODEL
-- function Environment.__index(self, key)
--     local alias = rawget(self, 'alias')
--     key = (alias and alias[key]) or key
--     return rawget(self, key) or rawget(_G, key)
-- end

function Environment:init(name, itemPath, category)
    setmetatable(self, {
        __newindex = Environment.__newindex,
        __index = _G,
    })

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