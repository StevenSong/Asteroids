require("physics")
physics.start()
physics.setGravity( 0, 0 )
print(display.contentWidth)
print(display.contentHeight)
local background = display.newImageRect( "background.png", display.contentWidth, display.contentHeight )
background.x, background.y = display.contentCenterX, display.contentCenterY
local asteroidCollisionFilter = {categoryBits = 4, maskBits = 3}
local characterCollisionFilter = {categoryBits = 1, maskBits = 4}
local projectileCollisionFilter = {categoryBits = 2, maskBits = 4}
local score = 0
scoreDisp = display.newText( score, 0, 0, "Arial", 48 )
scoreDisp.anchorX, scoreDisp.anchorY = 1, 0
scoreDisp.x, scoreDisp.y = display.contentWidth, 0
local function onCollision(event)
	if event.phase == "began" then
		event.target:removeSelf()
		event.target = nil
	end
	score = score + .5
	scoreDisp.text = score
end
characterSize = display.contentWidth*.1389
local character = display.newImageRect( "Ship.png", characterSize, characterSize )
character.x, character.y = display.contentCenterX, display.contentCenterY
physics.addBody( character, {filter = characterCollisionFilter})
local deltaX, deltaY = 0, 0
local normDeltaX, normDeltaY = 0, 0
local speed = 0
local function calcTraj(trajX, trajY)
	speed = math.random(250, 400)
	deltaX = trajX - character.x
	deltaY = trajY - character.y
	normDeltaX = deltaX / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
	normDeltaY = deltaY / math.sqrt(math.pow(deltaX,2) + math.pow(deltaY,2))
end
local projectile = {}
local count = 1
local projectileSize = display.contentWidth * .009
local function shoot(event)
	if count == 1 then
	else
		local diffX = character.x - event.x
    	local diffY = character.y - event.y
 		character.rotation = math.atan2(diffY, diffX) * (180/math.pi) - 90
		projectile[#projectile+1] = display.newCircle( display.contentCenterX, display.contentCenterY, projectileSize)
		projectile[#projectile]:setFillColor( 1,0,0 )
		physics.addBody( projectile[#projectile], {filter = projectileCollisionFilter} )
		calcTraj(event.x, event.y)
		projectile[#projectile]:setLinearVelocity( normDeltaX*500, normDeltaY*500 )
		projectile[#projectile]:addEventListener( "collision", onCollision )
	end
	count = count + 1
end
local randomX, randomY = 0, 0
local function randomSpawn()
	local side = math.random(4)
	if side == 1 then
		randomX = math.random(display.contentWidth)
		randomY = 0
	elseif side == 2 then
		randomX = display.contentWidth
		randomY = math.random(display.contentHeight)
	elseif side == 3 then
		randomX = math.random(display.contentWidth)
		randomY = display.contentHeight
	elseif side == 4 then
		randomX = 0
		randomY = math.random(display.contentHeight)
	end
end
local asteroid = {}
local asteroidSize = display.contentWidth*.06945
local function spawnAsteroid()
	randomSpawn()
	asteroid[#asteroid+1] = display.newImageRect("asteroid.png", asteroidSize, asteroidSize)
	asteroid[#asteroid].x, asteroid[#asteroid].y = randomX, randomY
	physics.addBody( asteroid[#asteroid], {filter = asteroidCollisionFilter} )
	calcTraj(randomX, randomY)
	asteroid[#asteroid]:setLinearVelocity(-normDeltaX*speed, -normDeltaY*speed)
	asteroid[#asteroid]:addEventListener( "collision", onCollision )
end
local spawn = timer.performWithDelay( 1500, spawnAsteroid, 0 )
gameOver = display.newText( "Restart", display.contentCenterX, display.contentCenterY, "Arial", 70 )
gameOver.isVisible = false
local function onCollisionAlt(event)
	if event.phase == "began" then
		event.target:removeSelf()
		event.target = nil
		timer.pause( spawn )
		Runtime:removeEventListener( "tap", shoot )
		gameOver.isVisible = true
		score = score - .5
		scoreDisp.text = score
	end
end
local function restart()
	gameOver.isVisible = false
	character = display.newImageRect( "Ship.png", characterSize, characterSize )
	character.x, character.y = display.contentCenterX, display.contentCenterY
	physics.addBody( character, {filter = characterCollisionFilter})
	count = 1
	Runtime:addEventListener( "tap", shoot )
	character:addEventListener( "collision", onCollisionAlt )
	timer.resume( spawn )
	score = 0
	scoreDisp.text = score
end
character.isVisible = false
timer.pause( spawn )
start = display.newText( "Start", display.contentCenterX, display.contentCenterY, "Arial", 70 )
local function startGame()
	character.isVisible = true
	timer.resume( spawn )
	start.isVisible = false
	Runtime:addEventListener( "tap", shoot )
end
start:addEventListener( "tap", startGame )
gameOver:addEventListener( "tap", restart )
character:addEventListener( "collision", onCollisionAlt )
--base code done in 2:20
--add scaling speed of asteroid and dynamic speed
--add high score
--dynamic buttons (start, restart, score)
--rounded edges of icon
--higher resolution images