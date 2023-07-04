Graphics2d = class()

local __paramColor = Color()
function paramColor(clr, ...)
    if clr == nil then return end
    if type(clr) == 'table' then return clr end
    return __paramColor:setComponents(clr, ...)
end

function Graphics2d.background(clr, ...)
    clr = paramColor(clr, ...) or colors.black    
    love.graphics.clear(clr.r, clr.g, clr.b, clr.a)
end

local styles = {}
function stylesSet(name, value)
    if value then
        styles[name] = value
    end
    return styles[name]
end

function stylesGet(name, value)
    return styles[name]
end

function stylesReset(name)
    styles[name] = nil
end

function Graphics2d.resetStyle()
    textMode(CORNER)
    textColor(colors.white)

    noStroke()
    strokeWidth(5)

    fill(colors.gray)
end

function Graphics2d.noFill()
    stylesReset('fillColor')
end

function Graphics2d.fill(clr, ...)
    clr = paramColor(clr, ...)
    return stylesSet('fillColor', clr)
end

function Graphics2d.noStroke()
    stylesReset('strokeColor')
end

function Graphics2d.stroke(clr, ...)
    clr = paramColor(clr, ...)
    return stylesSet('strokeColor', clr)
end

function Graphics2d.strokeWidth(width)
    return stylesSet('strokeWidth', width)
end

function Graphics2d.point(x, y)
    love.graphics.setColor(stroke():rgba())
    love.graphics.setPointSize(strokeWidth())
    love.graphics.points(x, y)
end

function Graphics2d.points(...)
    love.graphics.setColor(stroke():rgba())
    love.graphics.setPointSize(strokeWidth())
    love.graphics.points(...)
end

function Graphics2d.line(x1, y1, x2, y2)
    if stroke() then
        love.graphics.setColor(stroke():rgba())
        love.graphics.setLineWidth(strokeWidth())
        love.graphics.line(x1, y1, x2, y2)
    end
end

function Graphics2d.rect(x, y, w, h)
    if fill() then
        love.graphics.setColor(fill():rgba())
        love.graphics.rectangle('fill', x, y, w, h)
    end
    if stroke() then
        local width = strokeWidth()
        love.graphics.setColor(stroke():rgba())
        love.graphics.setLineWidth(width)
        love.graphics.rectangle('line', x+width/2, y+width/2, w-width, h-width)
    end
end

function Graphics2d.circle(x, y, radius)
    Graphics2d.ellipse(x, y, radius, radius)
end

function Graphics2d.ellipse(x, y, rx, ry)
    ry = ry or rx

    if fill() then
        love.graphics.setColor(fill():rgba())
        love.graphics.ellipse('fill', x, y, rx, ry)
    end
    if stroke() then
        local width = strokeWidth()
        love.graphics.setColor(stroke():rgba())
        love.graphics.setLineWidth(width)
        love.graphics.ellipse('line', x, y, rx-width/2, ry-width/2)
    end
end

CENTER = 'center'
CORNER = 'corner'

function Graphics2d.textColor(mode)
    return stylesSet('textColor', mode)
end

function Graphics2d.textMode(mode)
    return stylesSet('textMode', mode)
end

function Graphics2d.text(str, x, y, limit, align)
    if Graphics2d.textColor() == nil then return end

    x = x or 0
    y = y or 0

    if limit then
        align = align or 'left'
    end
    
    local mode = textMode()
    local ws, hs = textSize(str, limit, align)

    love.graphics.setColor(Graphics2d.textColor():rgba())
    
    if mode == CENTER then
        x, y = x-ws/2, y-hs/2
    end

    if limit then
        love.graphics.printf(str, x, y, limit, align)
    else
        love.graphics.print(str, x, y)
    end
end

function Graphics2d.textSize(str, limit)
    local font = love.graphics.getFont()

    local w, h
    if limit then
        local wrappedtext
        w, wrappedtext = font:getWrap(str, limit or W)
        h = font:getHeight() * #wrappedtext
    else
        w = font:getWidth(str)
        h = font:getHeight()
    end
    return w, h
end
