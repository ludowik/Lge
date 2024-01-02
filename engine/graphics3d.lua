Graphics3d = class()

function Graphics3d.setup()
    push2globals(Graphics3d)

    Graphics3d.shader = Shader('shader', 'engine/3d')
end

function Graphics3d.params(x, y, z, w, h, d)
    if not w then
        w = x or 1
        x, y, z = 0, 0, 0
    end
    
    h = h or w
    d = d or w

    return x, y, z, w, h, d
end

local boxMesh
function Graphics3d.box(x, y, z, w, h, d)
    x, y, z, w, h, d = Graphics3d.params(x, y, z, w, h, d)

    boxMesh = boxMesh or Mesh(Model.box())
    boxMesh.uniforms.border = 0

    boxMesh.shader = Graphics3d.shader
    boxMesh.shader:update()

    boxMesh:draw(x, y, z, w, h, d)
end

function Graphics3d.boxBorder(x, y, z, w, h, d)
    x, y, z, w, h, d = Graphics3d.params(x, y, z, w, h, d)

    boxMesh = boxMesh or Mesh(Model.box())
    boxMesh.uniforms.border = 1
    
    boxMesh.shader = Graphics3d.shader
    boxMesh.shader:update()

    boxMesh:draw(x, y, z, w, h, d)
end

local teapotMesh
function Graphics3d.teapot(x, y, z, w, h, d)
    x, y, z, w, h, d = Graphics3d.params(x, y, z, w, h, d)

    teapotMesh = teapotMesh or Model.load('teapot.obj')

    teapotMesh.shader = Graphics3d.shader
    teapotMesh.shader:update()

    teapotMesh:draw(x, y, z, w, h, d)
end
