snake = {}
local size = 32

math.randomseed(os.time())

function snake:load()
    
    self.texture = love.graphics.newImage("sprites/skins/cobrot.png")
    self.atlas = {}
    
    --load atlas
    for x=0, 10 do
      self.atlas[x+1] = {}
      for y=0, 1 do
        self.atlas[x + 1][y + 1] = love.graphics.newQuad(16*x, 16*y, 16, 16, self.texture:getWidth(), self.texture:getHeight())
      end
    end
    
    --apple atlas
    self.appleTex = love.graphics.newQuad(16*11, 16, 16, 16, self.texture:getWidth(), self.texture:getHeight())
    
    --positions and directions
    self.apple = {7, 5}
    self.direction = {1, 0}
    self.oldDir = {1, 0}
    
    self.grow = false
    self.timer = 0
    
    self.body = {
        {2, 5},
        {3, 5},
        {4, 5}
    }
    
    self.dead = false
end

--  called every frame
function snake:update(dt)
    self:key()
    if self:timerOut(dt) and not self.dead then
        self:move()
        self:check()
        self:die()
    end
end

function snake:pressed(dx, dy)
    local range = 10
    
    if dx > -200 then
    
    if dy < -range and math.abs(dy) > math.abs(dx) and self.oldDir[2] ~= 1 then
        self.direction = {0, -1}
    elseif dy > range and math.abs(dy) > math.abs(dx) and self.oldDir[2] ~= -1 then
        self.direction = {0, 1}
    elseif dx < -range and math.abs(dx) > math.abs(dy) and self.oldDir[1] ~= 1 then
        self.direction = {-1, 0}
    elseif dx > range and math.abs(dx) > math.abs(dy) and self.oldDir[1] ~= -1 then
        self.direction = {1, 0}
    end
    
    end
end

function snake:key()
    if (love.keyboard.isDown('d') or love.keyboard.isDown('right'))and self.oldDir[1] ~= -1 then
      self.direction = {1, 0}
    elseif (love.keyboard.isDown('a') or love.keyboard.isDown('left')) and self.oldDir[1] ~= 1 then
        self.direction = {-1, 0}
    elseif (love.keyboard.isDown('w') or love.keyboard.isDown('up')) and self.oldDir[2] ~= 1 then
        self.direction = {0, -1}
    elseif (love.keyboard.isDown('s') or love.keyboard.isDown('down')) and self.oldDir[2] ~= -1 then
        self.direction = {0, 1}
    end
end

function snake:draw()
  self:cobrotDraw()
  self:appleDraw()
end

function snake:cobrotDraw()
    
    for i, cell in ipairs(self.body) do
        --love.graphics.setColor(0, i/#self.body, 0.5, 1)
        local idX = 1
        local idY = 1
        local dir = self.direction
        
        
        if i == #self.body then
          local beCell = snake:entre(cell, self.body[#self.body - 1])
          if beCell[1] == -1 then 
            idX = 5
            idY = 2
          elseif beCell[1] == 1 then
            idX = 6
            idY = 1
          elseif beCell[2] == -1 then 
            idX = 5
            idY = 1
          else
            idX = 6
            idY = 2
          end
        elseif i == 1 then
          local afCell = snake:entre(cell, self.body[2])
          if afCell[1] == 1 then
            idX = 10
            idY = 2
          elseif afCell[1] == -1 then
            idX = 11
            idY = 1
          elseif afCell[2] == 1 then
            idX = 10
            idY = 1
          else 
            idX = 11
            idY = 2
          end
        else
          local after = snake:entre(cell, self.body[i + 1])
          local before = snake:entre(cell, self.body[i - 1])
          
          if after[1] ~= 0 and before[1] ~= 0 then
            idX = 7
            idY = 2
          elseif (after[2] ~= 0 and before[2] ~= 0) then
            idX = 7
            idY = 1
          elseif (after[1] == 1 and before[2] == 1) or (after[2] == 1 and before[1] == 1) then
            idX = 8
            idY = 1
          elseif (after[1] == -1 and before[2] == 1) or (after[2] == 1 and before[1] == -1) then
            idX = 9
            idY = 1
          elseif (after[1] == 1 and before[2] == -1) or (after[2] == -1 and before[1] == 1) then
            idX = 8
            idY = 2
          else
            idX = 9
            idY = 2
          end
        end
        
        love.graphics.draw(self.texture, self.atlas[idX][idY], map.offset[1] + size*cell[1], map.offset[2] + size*cell[2], 0, 2, 2)
        --love.graphics.rectangle('fill', 30 + size*cell[1], 30 + size*cell[2], size, size)
    end
end

function snake:appleDraw()
    --love.graphics.setColor(0.9, 0.1, 0.2)
    --love.graphics.rectangle('fill', 30 + self.apple[1]*size, 30 + self.apple[2]*size, size, size)
    love.graphics.draw(self.texture, self.appleTex, map.offset[1] + self.apple[1]*size, map.offset[2] + self.apple[2]*size, 0, 2, 2)
end

function snake:move()
    local newbody = {}
    local start = 2
    
    if self.grow then
        start = 1
    end
    
    for i = start, #self.body, 1 do
        newbody[#newbody + 1] = self.body[i]
    end
    
    table.insert(newbody, {newbody[#newbody][1] + self.direction[1], newbody[#newbody][2] + self.direction[2]})
    
    self.oldDir[1] = self.direction[1]
    self.oldDir[2] = self.direction[2]
    
    self.body = newbody
    
    
    self.grow = false
end

function snake:check()
    if self.apple[1] == self.body[#self.body][1] and self.apple[2] == self.body[#self.body][2] then
        self.grow = true
        self:setApple()
    end
end

function snake:entre(cell1, cell2)
  local result = {
    cell2[1] - cell1[1],
    cell2[2] - cell1[2]
  }
  
  return result
end

function snake:timerOut(dt)
    self.timer = self.timer + dt
    if self.timer > 0.2 then
       self.timer = 0
       return true
    end
    return false
end

function snake:setApple()
  local newPos = {}
  
  newPos[1] = math.random(map.min[1], map.max[1])
  newPos[2] = math.random(map.min[2], map.max[2])
  
  while game:getCell(self.body, newPos) >= 1 do
    newPos[1] = math.random(map.min[1], map.max[1])
    newPos[2] = math.random(map.min[2], map.max[2])
  end
  
  self.apple[1] = newPos[1]
  self.apple[2] = newPos[2]
end

function snake:die()
    if self.body[#self.body][1] < map.min[1] or self.body[#self.body][1] > map.max[1] or self.body[#self.body][2] < map.min[2] or self.body[#self.body][2] > map.max[2] or game:getCell(self.body, self.body[#self.body]) >= 2 then
      self.body = {
        {2, 2},
        {3, 2},
        {4, 2}
      }
      self.apple = {7, 2}
      self.direction = {1, 0}
      self.oldDir = {1, 0}
    
      self.grow = false
      self.timer = 0
    
        --self.dead = true
    end
end