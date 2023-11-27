
love.graphics.setDefaultFilter("nearest", "nearest")

game = {}
map = {}
map.min = {
  0,
  0
}
map.max = {
  23,
  11
}
map.offset = {
  30,
  30
}

require 'scripts/snake'

function love.load()
  snake:load()
end

function love.update(dt)
  snake:update(dt)
end

function love.touchmoved(id, x, y, dx, dy, p)
  snake:pressed(dx, dy)
end 

function love.draw()
  snake:draw()
  love.graphics.setColor(0, 0.2, 0.8, 0.75)
  love.graphics.rectangle("fill", 0, 0, 120, 80)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(game:tableLenght(snake.body), 16, 35, 0, 3, 3)
end

function game:getCell(t, pos)
  local found = 0
  
  for i, obj in ipairs(t) do
    if obj[1] == pos[1] and obj[2] == pos[2] then
      found = found + 1
    end
  end
  
  return found
end

function game:tableLenght(t)
  local count = 0
  
  for i, obj in ipairs(t) do
    count = count + 1
  end
  
  return count
end