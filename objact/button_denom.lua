local ui_up = nil
local ui_down = nil
local x = 0
local y = 0
local w = 0
local h = 0
local r = 0
local ui_up = love.graphics.newImage("asset/ui_up.png")
local ui_down = love.graphics.newImage("asset/ui_down.png")
local input_type = false --输入状态
local input_string = "" --键入的内容
objact_denom = { --分度改变用的
    load = function(x1,y1,r1,w1,h1)
        x= x1 --初始化
        y = y1
        w = w1
        h = h1
        r = r1
        input_string = denom.denom
    end,
    draw = function()
        local _width, _height = ui_up:getDimensions( ) -- 得到宽高
        local _scale_w = 1 / _width * w
        local _scale_h = 1 / _height * h
        love.graphics.setColor(1,1,1,1)

        love.graphics.draw(ui_up,x,y,r,_scale_w,_scale_h)
        love.graphics.draw(ui_down,x,y+h,r,_scale_w,_scale_h)
        love.graphics.print(objact_language.get_string_in_languages("denom"),x-50,y)

        love.graphics.setColor(0.1,0.1,0.1,0.5)
        love.graphics.rectangle("fill",x-50,y + h,50,h) --输入框
        love.graphics.setColor(1,1,1,1)
        love.graphics.print(input_string,x-25,y + h) --输入框

        if input_type == true then -- 输入状态
            love.graphics.setColor(1,1,1,1)
            love.graphics.rectangle("line",x-50,y + h,50,h) --输入框外框
        end
    end,
    keyboard = function(key)
        if key == "up" then
            denom.denom = denom.denom + 1
            input_string = denom.denom
        elseif key == "down" then
            denom.denom = math.abs(denom.denom - 2) + 1--防止非自然数
            input_string = denom.denom
        end

        if input_type == true then
            if key == "backspace" then -- 退格
                input_string = string.sub(input_string, 1, -2)
            end
            if key == "return" then -- 关闭 
                input_type = false
                denom.denom = tonumber(input_string) or 4
                input_string = denom.denom
            end
            if string.match(key, "%d") ~= nil then --为数字
                input_string = input_string..key
            end
        end
    end,
    mousepressed = function( x1, y1, button, istouch, presses )
        
        if x1 >= x -50  and x1 <= x and y1 <= y + h + h and y1 >= y + h then -- 在输入框的范围内
            input_type = true
        else
            input_type = false
            denom.denom = tonumber(input_string) or 4
            input_string = denom.denom
        end
        if x1 >= x  and x1 <= x + w and y1 <= y + h and y1 >= y then -- 在up的范围内
            objact_denom.keyboard("up")
            
        elseif x1 >= x  and x1 <= x + w and y1 <= y + h + h and y1 >= y + h then -- 在down的范围内
            objact_denom.keyboard("down")
            
        end
    end,
    textinput = function(input)

    end
}