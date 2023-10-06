local settingsFileName = 'settings'

local settings

function saveSettings()
    saveFile(settingsFileName, settings)
end

function saveFile(fileName, table)
    love.filesystem.write(fileName, 'return '..Array.tolua(table))
end

function loadSettings()
    if getOS() == 'web' then return {} end

    return loadFile(settingsFileName) or {
        sketch = 'Hexagone'
    }
end

function loadFile(fileName)
    local ok, f = pcall(
        function ()
            return love.filesystem.load(fileName)
        end)
    if ok and type(f) == 'function' then
        return f()
    end
end

function updateSettings()
    local needUpdate = false
    if settings.sketch ~= processManager:current().__className then
        settings.sketch = processManager:current().__className
        needUpdate = true
    end
    if needUpdate then
        saveSettings()
    end
end

settings = loadSettings()

function setSettings(name, value)
    settings[name] = value
    saveSettings()
end

function getSettings(name, defaultValue)
    return settings[name] or defaultValue
end

setSettings('testBoolean', true)
setSettings('testNumber', 12.12)
setSettings('testString', 'valeur')
setSettings('testTable', {a = 'a'})
setSettings('testNil', nil)
