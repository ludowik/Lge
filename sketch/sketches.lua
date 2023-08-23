function setup()
    scene = Scene()
    processManager:foreach(function (env)
        scene:add(UIButton(env.__className,
            function (self)
                processManager:setSketch(self.label)
            end):attrib{
                styles = {
                    fillColor = colors.transparent,
                },
                draw = function (self)
                    UIButton.draw(self)
                    local process = processManager:getSketch(self.label)
                    if process and self.label ~= 'sketches' then
                        love.graphics.draw(process.canvas,
                            self.position.x + self.size.x,
                            self.position.y, 0,
                            self.size.y / H,
                            self.size.y / H)
                    end
                end
            })
    end)
    scene.layoutMode = 'center'
end
