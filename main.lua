local adresse = "db:80:75:10:c1:c6" -- peripheral adresse



local power = 0
local font = nil
local fontY = 0

function love.load(arg)

	update_timer = 0

	love.joystick.loadGamepadMappings("gamecontrollerdb.map")
	love.graphics.setNewFont(50)
	font = love.graphics.getFont()
	fontY = font:getHeight()

	gatt = io.popen("gatttool -i hci0 -t random -b "..adresse.." -I > /dev/null", "w") -- run gatttool
	gatt:write("connect\n"); -- connect to ble peripheral

end

function tohex(str)
	return (str:gsub('.', function (c)
		return string.format('%02X', string.byte(c))
	end))
end

function love.update(dt)

	update_timer = update_timer + dt

	if update_timer > (1 / frequency) then -- ( 40Hz = 0.025)

		update_timer = 0

		if joy then -- gamepad is plug
			power = 20 * (joy:getGamepadAxis("triggerleft")) -- read gamepad input "https://love2d.org/wiki/GamepadAxis"
		else
			power = 0
		end

		local str = "char-write-req 0x000e "..tohex("Vibrate:"..math.floor(power)..";")
		print(str)
		gatt:write(str.."\n") -- send cmd
		gatt:flush()

	end
end


function love.draw()
	love.graphics.setBackgroundColor(255,  255 - power * 7.75,  255- power * 7.75, 255)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("Power", 300, fontY * 3)
	love.graphics.print(math.floor(power), 350, fontY * 4)
end


function love.keypressed(key, scancode, isrepeat)
	print(key)
	if key == "escape" then love.event.quit() end
end


function love.gamepadpressed( joystick, button )
	print("button",button)
end


function love.joystickadded(joystick)
	joy = joystick
end


function love.quit()
	--serial:close()
	print("quit")
	gatt:write("quit\n")
	gatt:flush()
	os.execute("killall gatttool")
end
