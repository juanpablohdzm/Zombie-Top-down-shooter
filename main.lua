function love.load()
  sprites={} --load sprites
  sprites.background=love.graphics.newImage('zombie/sprites/background.png')
  sprites.bullet=love.graphics.newImage('zombie/sprites/bullet.png')
  sprites.zombie=love.graphics.newImage('zombie/sprites/zombie.png')

  player={}
  player.sprite= love.graphics.newImage('zombie/sprites/player.png')
  player.x=200
  player.y=200
  player.speed=300
  player.rotation=0

  zombies={}

end

function love.update(dt) --60fps
  input(dt)
  zombieBehaviour(dt)
end

function love.draw()
  love.graphics.draw(sprites.background,0,0)
  love.graphics.draw(player.sprite,player.x,player.y, mouseAngle(),nil,nil,player.sprite:getWidth()/2,player.sprite:getHeight()/2)
  for i,z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x,z.y,zombieAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)
  end
end


--input
function input(dt)
  if love.keyboard.isDown("k") then --down
    player.y=player.y+player.speed*dt
  end
  if love.keyboard.isDown("i") then --up
    player.y=player.y-player.speed*dt
  end
  if love.keyboard.isDown("j") then --left
    player.x=player.x-player.speed*dt
  end
  if love.keyboard.isDown("l") then --right
    player.x=player.x+player.speed*dt
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key=="space" then
    spawnZombie()
  end
end


--angles for player and zombies
function mouseAngle()
  return math.atan2((-player.y+love.mouse.getY()), (-player.x+love.mouse.getX()))
end

function zombieAngle(enemy)
  return math.atan2((player.y-enemy.y), (player.x-enemy.x))
end

--zombie
function spawnZombie()
  zombie={}
  zombie.x=math.random(0, love.graphics.getWidth())
  zombie.y=math.random(0, love.graphics.getHeight())
  zombie.speed=100

  table.insert(zombies,zombie)
end

--zombie behaviour
function zombieBehaviour(dt)
  if zombies ~= nil then --different
    for i,z in ipairs(zombies) do
      angle=zombieAngle(z)
      x=math.cos(angle)
      y=math.sin(angle)

      z.x=z.x+x*z.speed*dt -- with the angle of zombie we get units we need to move
      z.y=z.y+y*z.speed*dt

      if(distanceBetween(z.x,z.y,player.x,player.y) <20) then
        for i,z in ipairs(zombies) do
          zombies[i]=nil
        end
      end
    end
  end
end

--extra functions
function distanceBetween(x,y,x1,y1)
  return math.sqrt((math.pow(y-y1,2)+math.pow(x-x1,2)))
end
