function evaluateExpression(expression)
    return evaluateCode("return "..tostring(expression))
end

function evaluateCode(source)
    assert(source)

    local f, err = loadstring(source)
    if f then
        local ok, result = pcall(f)
        if ok then
            return result
        end
    else
        log(err)
    end
end