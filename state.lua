State = class()

function State:init()
    self:pause()
end

function State:pause()
    self.state = 'paused'
end

function State:resume()
    self.state = 'running'
end
