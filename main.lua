function love.load()
  sprites={} --load sprites
  sprites.background=love.graphics.newImage('zombie/sprites/background.png')
  sprites.bullet=love.graphics.newImage('zombie/sprites/bullet.png')
  sprites.zombie=love.graphics.newImage('zombie/sprites/zombie.png')

  player={}
  player.sprite= love.graphics.newImage('zombie/sprites/player.png')
  player.x=love.graphics.getWidth()/2
  player.y=love.graphics.getHeight()/2
  player.speed=300
  player.rotation=0

  zombies={}
  bullets={}

  gameState=1
  maxTime=2
  timer=maxTime
  score=0

  myFont=love.graphics.newFont(50)

end

function love.update(dt) --60fps
  if gameState==2 then
  input(dt)
end
  zombieBehaviour(dt)
  bulletBehaviour(dt)
  isDead()

  if gameState==2 then
    timer=timer-dt
    if(timer <=0) then
      spawnZombie()
      maxTime =maxTime*.95
      timer=maxTime
    end
  end
end

function love.draw()

  love.graphics.draw(sprites.background,0,0)

  menu()
  myScore()

  love.graphics.draw(player.sprite,player.x,player.y, mouseAngle(),nil,nil,player.sprite:getWidth()/2,player.sprite:getHeight()/2)
  for i,z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x,z.y,zombieAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)
  end
  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet,b.x,b.y,nil,b.size,b.size,sprites.bullet:getWidth()/2,sprites.bullet:getHeight()/2)
  end
end


--input
function input(dt)
  if love.keyboard.isDown("k") and player.y< love.graphics.getHeight()then --down
    player.y=player.y+player.speed*dt
  end
  if love.keyboard.isDown("i") and player.y>0 then --up
    player.y=player.y-player.speed*dt
  end
  if love.keyboard.isDown("j") and player.x>0 then --left
    player.x=player.x-player.speed*dt
  end
  if love.keyboard.isDown("l") and player.x<love.graphics.getWidth() then --right
    player.x=player.x+player.speed*dt
  end
end

function love.mousepressed(x, y, b, isTouch)
  if b==1 and gameState==2 then
    spawnBullets()
  end

  if gameState==1 then
    gameState=2
    maxTime=2
    timer=maxTime
    score=0
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
  zombie.x=0
  zombie.y=0
  zombie.speed=100
  zombie.dead=false

  local side=math.random(1, 4)
  if side==1 then
    zombie.x=-30
    zombie.y=math.random(0, love.graphics.getHeight())
  else
    if side==2 then
      zombie.x=math.random(0, love.graphics.getWidth())
      zombie.y=-30
    else
      if side==3 then
        zombie.x=love.graphics.getWidth()+30
        zombie.y=math.random(0, love.graphics.getHeight())
      else
        if side==4 then
          zombie.x=math.random(0, love.graphics.getWidth())
          zombie.y=love.graphics.getHeight()+30
        end
      end
    end
  end

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
        gameState=1
      end
    end
  end
end

--bullets
function spawnBullets()
  bullet={}
  bullet.x=player.x
  bullet.y=player.y
  bullet.speed=500
  bullet.direction =mouseAngle()
  bullet.size=.5
  bullet.dead=false

  table.insert(bullets,bullet)
end

function bulletBehaviour(dt)
  for i,b in ipairs(bullets) do
    b.x=b.x+math.cos(b.direction)*b.speed*dt
    b.y=b.y+math.sin(b.direction)*b.speed*dt
  end

  for i=#bullets,1,-1 do --decrement loops
    local b=bullets[i]
    if(b.x<0 or b.y<0 or b.x>love.graphics.getWidth() or b.y>love.graphics.getHeight()) then
      table.remove(bullets,i)
    end
  end
end

function isDead()
  for i,z in ipairs(zombies) do
    for j,b in ipairs(bullets) do
      if distanceBetween(z.x,z.y,b.x,b.y)<20 then
        z.dead=true
        b.dead=true
        score=score+1
      end
    end
  end

  for i=#zombies, 1,-1 do
    local z=zombies[i]
    if z.dead==true then
      table.remove(zombies,i)
    end
  end
  for i=#bullets,1,-1 do
    local b=bullets[i]
    if(b.dead==true) then
      table.remove(bullets, i)
    end
  end
end

--extra functions
function distanceBetween(x,y,x1,y1)
  return math.sqrt((math.pow(y-y1,2)+math.pow(x-x1,2)))
end

function menu()
  if gameState==1 then
    love.graphics.setFont(myFont)
    love.graphics.printf("Zombie killer, click anywhere",0,50, love.graphics.getWidth(),"center")
  end
end

function myScore()
  if gameState==2 then
    love.graphics.printf("Score: "..score,0, love.graphics.getHeight()-100, love.graphics.getWidth(),"center")
  end
end
