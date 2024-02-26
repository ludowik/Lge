ReactionDiffusion = class() : extends(Sketch)

local gridIn, gridInIterate
local gridOut, gridOutIterate

local m, n, da, db, f, k

local renderImage

function ReactionDiffusion:init()
    Sketch.init(self)

    self.parameter:link('http://www.karlsims.com/rd.html')

    n = 300
    m = n

    gridIn  = Grid(n, m, function () return {a=1, b=0, c=0} end)
    gridOut = Grid(n, m, function () return {a=1, b=0, c=0} end)

    gridInIterate = Array()
    gridOutIterate = Array()

    local dpi = 1 -- devicePixelRatio
    
    for i=2,n-1 do
        for j=2,m-1 do
            local cellIn = gridIn:get(i, j)
            gridInIterate:push(cellIn)
            cellIn.x = floor((i - i % dpi) / dpi) - 1
            cellIn.y = floor((j - j % dpi) / dpi) - 1
            cellIn.North = gridIn:get(i, j+1)
            cellIn.NE    = gridIn:get(i+1, j+1)
            cellIn.East  = gridIn:get(i+1, j)
            cellIn.SE    = gridIn:get(i+1, j-1)
            cellIn.South = gridIn:get(i, j-1)
            cellIn.SW    = gridIn:get(i-1, j-1)
            cellIn.West  = gridIn:get(i-1, j)
            cellIn.NW    = gridIn:get(i-1, j+1)            

            local cellOut = gridOut:get(i, j)
            gridOutIterate:push(gridOut:get(i, j))
            cellOut.x = floor((i - i % dpi) / dpi) - 1
            cellOut.y = floor((j - j % dpi) / dpi) - 1
            cellOut.North = gridOut:get(i, j+1)
            cellOut.NE    = gridOut:get(i+1, j+1)
            cellOut.East  = gridOut:get(i+1, j)
            cellOut.SE    = gridOut:get(i+1, j-1)
            cellOut.South = gridOut:get(i, j-1)
            cellOut.SW    = gridOut:get(i-1, j-1)
            cellOut.West  = gridOut:get(i-1, j)
            cellOut.NW    = gridOut:get(i-1, j+1)
        end
    end

    local size = .05

    local xc = n/2
    local yc = m/2

    local ns = n * size
    local ms = m * size

    for i = xc-ns, xc+ns do
        for j = yc-ms, yc+ms do
            if vec2(xc, yc):dist(vec2(i, j)) < ns then
                gridIn:get(i, j).b = 1
            end
        end
    end

    renderImage = FrameBuffer(n, m)

    da = 1.0
    db = 0.5

    -- base
    f = .055
    k = .062

    -- -- mitosis
    -- f = .0367
    -- k = .0649

    -- -- coral growth
    -- f = .0545
    -- k = .062
end

function ReactionDiffusion:update(dt)
    for i=1,5 do
        self:updateImage(1)
    end
end

function ReactionDiffusion:updateImage(dt)
    local function laplaceA(cell, v)
        return -cell.a
            + ( cell.North.a + cell.East.a + cell.South.a + cell.West.a) * 0.2
            + ( cell.NE.a + cell.SE.a + cell.SW.a + cell.NW.a) * 0.05
    end
    
    local function laplaceB(cell, v)
        return -cell.b
            + ( cell.North.b + cell.East.b + cell.South.b + cell.West.b) * 0.2
            + ( cell.NE.b + cell.SE.b + cell.SW.b + cell.NW.b) * 0.05
    end

    
    local a, b, abb
    local cellIn, cellOut

    for i=1,#gridInIterate do
        cellIn = gridInIterate[i]
        cellOut = gridOutIterate[i]

        a = cellIn.a
        b = cellIn.b
        
        abb = a * (b^2)

        cellOut.a = a + (da * laplaceA(cellIn) - abb + f*(1-a)) * dt
        cellOut.b = b + (db * laplaceB(cellIn) + abb - b*(k+f)) * dt

        cellOut.c = cellOut.a - cellOut.b
    end

--    gridIn, gridOut = gridOut, gridIn
    gridInIterate, gridOutIterate = gridOutIterate, gridInIterate
end

function ReactionDiffusion:draw()
    background(51)

    renderImage:getImageData()

    local c
    local range = 32
    for i=1,#gridInIterate do
        cellIn = gridInIterate[i]
        c = floor(cellIn.c * range) * range
        renderImage:set(cellIn.x, cellIn.y, c, c, c, 1)
    end

    spriteMode(CENTER)
    sprite(renderImage, W/2, H/2)
end
