Layout = class()

function Layout:layout(_x, _y, align)
    local x = _x or 0
    local y = _y or UI.innerMarge

    align = align or self.layoutMode or 'left'

    local w, h = 0, 0

    for _,item in ipairs(self.items) do
        item.position:set()
        item.size:set()
    end

    for _,item in ipairs(self.items) do
        if item.visible ~= false then
            if item.layout then
                item:layout(x, y, align)
            else
                item:computeSize()
            end

            -- alignment
            if align == 'right' then
                x = W - item.size.x - UI.innerMarge
            elseif align == 'center' then
                x = W/2 - item.size.x/2
            end

            -- set position
            item.position:set(x, y)

            -- compute next y
            y = y + item.size.y + UI.innerMarge

            -- compute node size
            w = max(w, item.size.x)
            h = h + item.size.y + UI.innerMarge
        end

        if self.state == 'close' then break end
    end

    self.size:set(w, h)
end
