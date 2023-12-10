Spirale = class() : extends(Sketch)

function Spirale:init()
    Sketch.init(self)

    -- TODO
    -- normalMaterial()

    -- TODO : implement a camera
    -- self.cam = createEasyCam()

    -- local state = getItem('cam_state')
    -- self.cam.setState(state)

    -- TODO : parameter
    self.params = {
        deltaAngle = 32,
        -- {
        --     value = 32,
        --     min = 0,
        --     max = 64,
        -- },

        width = 100,
        widthMax = 500,

        height = 400,
        heightMax = 500,

        noise = 100,
    }

    self.parameter:boolean('rotate', 'rotateSpirale', false)

    self.elapsedTime = 0
end

function Spirale:update(dt)
    if rotateSpirale then
        self.elapsedTime = self.elapsedTime + dt
    end

    -- TODO : implement a camera
    -- storeItem('cam_state', self.cam.getState())
end

function Spirale:draw()
    background(0)

    -- TODO
    --isometric(3)

    perspective()
    lookat(500, 500, 500)

    fill(colors.white)
    
    local angle = 0
    local x, y, z = 0, 0, 0
    local px, py, pz

    local vertices = Array()
    --beginShape(TRIANGLE_STRIP)

    for i = -self.params.height , self.params.height do
        y = y + noise(self.elapsedTime + (i / self.params.noise))
    end
    y = -y / 2

    for i = -self.params.height , self.params.height do
        local n = noise(self.elapsedTime + (i / self.params.noise))
        local n2 = noise(self.elapsedTime * 2 + (i / self.params.noise))

        y = y + n

        x = cos(angle) * self.params.width * n ^ 2
        z = sin(angle) * self.params.width * n ^ 2

        --stroke(Color.hsb(n))
        local clr = Color.hsb(n2, 0.5, 0.5)
        fill(clr)

        strokeSize(n)

        vertices:add({x, y, z, clr.r, clr.g, clr.b})
        vertices:add({0, y, 0, clr.r, clr.g, clr.b})

        -- vertex(x, y, z)
        -- vertex(0, y, 0)

        --  if px then
        --      strokeSize(2)
        --      vertex(0, y, 0, 0, py, 0)
        --      vertex(x, y, z, px, py, pz)
        --  end

        angle = angle + n * rad(self.params.deltaAngle)

        px = x
        py = y
        pz = z
    end

    --endShape()
    Mesh(vertices, 'strip'):draw()
end
