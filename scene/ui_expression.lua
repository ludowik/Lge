UIExpression = class() : extends(UI)

function UIExpression:init(label, expression)
    self.expression = expression or label

    if type(label) == 'table' then
        label = self.expression.name or self.expression.ref
    end

    UI.init(self, label)
end

function UIExpression:getLabel()
    return tostring(self.label):proper()..' = '..self:evaluateExpression()
end

function UIExpression:evaluateExpression()
    local expression = self.expression
    
    local type_expression = type(expression)
    if type_expression == 'string' then
        local f, err = loadstring('return ' .. expression, nil, 't', (_G.env or _G))
        if not f then log(expression, err) return err end
    
        if setfenv then setfenv(f, env) end
        
        local results = {pcall(f)}
        local ok, result = results[1], results[2]
        if not ok then log(expression, result) return result end
        
        return self:formatValue(result)

    elseif type_expression == 'table' then
        return self:formatValue(expression)
    end

    return 'Expression error !'
end

function UIExpression:formatValue(value)
    if type(value) == 'number' then
        return string.formatNumber(value, '.', ' ')
    end
    return tostring(value)
end
