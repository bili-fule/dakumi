--输入框
local input_box_objact = {} --对象
local input_string = ""
local input_string_index = 1 --键入位置
local function pass() --默认函数
    --pass
end
local meta_type = {__index ={
    type = "string",
    input_ed = pass,  --输入完成处理完成之前的回调函数
    input_ed_finish = pass, --输入完成处理完成之后的回调函数
    will_draw = pass, --确认是否绘画
}}
function input_box_new(name,var,x,y,w,h,thetype) --名字 与所对应的变量
    local istype = thetype or {}
    if type(thetype) ~= "table" then
        istype = {}
    end
    setmetatable(istype,meta_type)
    fillMissingElements(istype,meta_type.__index)
    input_box_objact[name] = {var = var,x = x,y = y,w = w,h = h,in_input = false,type = istype} --type是用来判断文本类型的（其实只有num和str）
end

function input_box_draw(name)
    if not input_box_objact[name].type.will_draw() then
        return
    end
    love.graphics.setColor(0.15,0.15,0.15,1)
    love.graphics.rectangle("fill",input_box_objact[name].x,input_box_objact[name].y,input_box_objact[name].w,input_box_objact[name].h) --输入框内框
    
    if input_box_query_type_in() == name then
        love.graphics.setColor(0.5,0.5,0.5,0.8) --输入框外框
        love.graphics.rectangle("line",input_box_objact[name].x,input_box_objact[name].y,input_box_objact[name].w,input_box_objact[name].h)
    end

    if loadstring("return _G."..input_box_objact[name].var)() and input_box_objact[name].in_input == false then
        love.graphics.setColor(1,1,1,1)
        pcall(function() love.graphics.printf(tostring(loadstring("return _G."..input_box_objact[name].var)()),input_box_objact[name].x,input_box_objact[name].y,input_box_objact[name].w,"left") end)
            --变量
    end
    if input_box_objact[name].in_input == true then --输入中
        love.graphics.setColor(1,1,1,1) --文字
        if input_string then
            love.graphics.setColor(1,1,1,1)
            pcall(function() love.graphics.printf(string.sub(input_string,1,input_string_index).."|"..string.sub(input_string,input_string_index+1,#input_string),input_box_objact[name].x,input_box_objact[name].y,input_box_objact[name].w,"left") end)
        end
    end
end

function input_box_draw_all()
        for i, v in pairs(input_box_objact) do
            input_box_draw(i)
        end
end


function input_box_mousepressed(x,y) --查询
    for i, v in pairs(input_box_objact) do  -- 赋值
        if input_box_objact[i].in_input == true then 
            input_box_objact[i].type.input_ed(input_string)
            if input_box_objact[i].type.type == "number" and 
            not loadstring("return to"..input_box_objact[i].type.type.."'"..input_string.."'")() then  --有人往数字里面输入字符串
                input_string = 1
            end
            if input_box_objact[i].type.type ~= "number" and type(input_string) ~= 'string' then
                input_string = "1"
            end
            loadstring("_G."..input_box_objact[i].var.."=".. "to"..input_box_objact[i].type.type.."([["..input_string.."]])")()
            input_string = " "
            input_string_index = 1
            input_box_objact[i].type.input_ed_finish(input_string)
        end -- 赋值
    end
    input_string = ""
    for i, v in pairs(input_box_objact) do
        input_box_objact[i].in_input = false --全部初始化

        if x >= input_box_objact[i].x and x <= input_box_objact[i].x + input_box_objact[i].w 
        and y <= input_box_objact[i].y + input_box_objact[i].h and y >= input_box_objact[i].y and 
        input_box_objact[i].type.will_draw() then
                input_box_objact[i].in_input = true
                if loadstring("return _G."..input_box_objact[i].var)() then
                    input_string = tostring(loadstring("return _G."..input_box_objact[i].var)())
                    input_string_index = #input_string
                end
        end
    end
end

function input_box_key(key) --键入内容
    if key == "backspace" then -- 退格
        if #input_string == 1 or type(input_string) ~= "string" then
            input_string = ""
                input_string_index = input_string_index - 1
        else
            if isLastCharChineseOrHalfwidth(string.sub(input_string, 1,input_string_index)) then --中文一个字长度为3
                input_string = string.sub(input_string, 1,input_string_index-3)..string.sub(input_string, input_string_index +1,#input_string)
                if input_string_index >= 3 then
                    input_string_index = input_string_index - 3
                end
            else
                input_string = string.sub(input_string, 1,input_string_index-1)..string.sub(input_string, input_string_index +1,#input_string)
                if input_string_index >= 1 then
                    input_string_index = input_string_index - 1
                end
            end
            local normal_input = pcall(function() love.graphics.print(input_string,0,0) end)
            while normal_input == false and input_string_index > 0 do --删除可能残留的非正常字符
                input_string = string.sub(input_string, 1,input_string_index - 1)..string.sub(input_string, input_string_index +1,#input_string)
                input_string_index = input_string_index - 1
                normal_input = pcall(function() love.graphics.print(input_string,0,0) end)
            end
        end


    elseif key == "up" or key == "right" then
        if input_string_index + 3 <= #input_string and isLastCharChineseOrHalfwidth(string.sub(input_string, 1,input_string_index + 3)) then
            input_string_index = input_string_index + 3
        else
            input_string_index = input_string_index + 1
        end
        local normal_input = pcall(function() love.graphics.print(string.sub(input_string,1,input_string_index).." "..string.sub(input_string,input_string_index+1,#input_string),0,0)  end)
        while normal_input == false  do --可能残留非正常字符
            input_string_index = input_string_index + 1
            normal_input = pcall(function() love.graphics.print(string.sub(input_string,1,input_string_index).." "..string.sub(input_string,input_string_index+1,#input_string),0,0)  end)
        end


    elseif key == "down" or key == "left" then
        if isLastCharChineseOrHalfwidth(string.sub(input_string, 1,input_string_index)) then
            input_string_index = input_string_index - 3
        else
            input_string_index = input_string_index - 1
        end
        local normal_input = pcall(function() love.graphics.print(string.sub(input_string,1,input_string_index).." "..string.sub(input_string,input_string_index+1,#input_string),0,0)  end)
        while normal_input == false and input_string_index > 0 do --可能残留非正常字符
            input_string_index = input_string_index - 1
            normal_input = pcall(function() love.graphics.print(string.sub(input_string,1,input_string_index).." "..string.sub(input_string,input_string_index+1,#input_string),0,0)  end)
        end

    elseif key == "space" then --空格
        input_string = string.sub(input_string,1,input_string_index).." "..string.sub(input_string,input_string_index+1,#input_string)
        input_string_index = input_string_index + 1
    elseif isctrl == true and key == "v"  then
        local text = love.system.getClipboardText( ) --粘贴

        input_string = string.sub(input_string,1,input_string_index)..text..string.sub(input_string,input_string_index,#input_string)
        input_string_index = input_string_index + #text

    elseif key == "return" or key == "escape" then -- 关闭 
        input_type = false
        for i, v in pairs(input_box_objact) do
            if input_box_objact[i].in_input == true then
                input_box_objact[i].type.input_ed(input_string)
            end
            if input_box_objact[i].in_input == true and
            input_box_objact[i].type.type == "number" and 
            not loadstring("return to"..input_box_objact[i].type.type.."'"..input_string.."'")() then  --有人往数字里面输入字符串
                input_string = 1
            end
            if input_box_objact[i].type.type ~= "number" and type(input_string) ~= 'string'then
                input_string = "1"
            end
            if input_box_objact[i].in_input == true then
                loadstring("_G."..input_box_objact[i].var.."=".. "to"..input_box_objact[i].type.type.."([["..input_string.."]])")()
                input_box_objact[i].in_input = false
                input_box_objact[i].type.input_ed_finish(input_string)
            end
        end
    end

    if  type(input_string) == "string" and input_string_index > #input_string  then
        input_string_index = #input_string
    elseif type(input_string) == "string" and input_string_index < 0 then
        input_string_index = 0
    end
end

function input_box_delete(name) --删除
    input_box_objact[name] = nil
end

function input_box_delete_all() --删除 全部
    input_box_objact = {}
end

function input_box_wheelmoved(x,y,name) --滑轮滚动 使全体位移
    input_box_objact[name].y = input_box_objact[name].y + y
end

function input_box_query_type_true() --查询现在所选择的框
    for i, v in pairs(input_box_objact) do
        if input_box_objact[i].input == true then
            return i
        end
    end
end
function input_box_query_type_in() --查询现在所在位置框
    for i, v in pairs(input_box_objact) do
        if mouse.x >= input_box_objact[i].x and mouse.x <= input_box_objact[i].x + input_box_objact[i].w 
        and mouse.y <= input_box_objact[i].y + input_box_objact[i].h and mouse.y >= input_box_objact[i].y then
            return i
        end
    end
end
function input_box_delete_choose() --初始化选择状态
    input_string = ""
    for i, v in pairs(input_box_objact) do
        input_box_objact[i].in_input = false --全部初始化

    end
end
function input_box_textinput(input) --输入文字
    if input:find([[\]]) then
        return
    end
    input_string = string.sub(input_string,1,input_string_index)..input..string.sub(input_string,input_string_index+1,#input_string)
    input_string_index = input_string_index + #input
end