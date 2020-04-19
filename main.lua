local FONT_SIZE = 22
local COLOR = {0, 1, 0}

function love.load()
    love.mouse.setVisible(false)

    matrixFont = love.graphics.newFont("font.ttf", FONT_SIZE)
    love.graphics.setFont(matrixFont)

    matrix = Matrix(FONT_SIZE)
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    matrix.update(dt)
end

function love.draw()
    matrix.draw()
end

-- Matrix class implementation
function Matrix(fontSize)
    local numColumns = love.graphics.getWidth() / fontSize
    local matrix = {
        numCodeStrings = numColumns * 2,
        codeStrings = {}
    }

    for i = 1, matrix.numCodeStrings do
        matrix.codeStrings[i] = CodeString(numColumns, fontSize)
    end

    function matrix.update(dt)
        for i = 1, matrix.numCodeStrings do
            matrix.codeStrings[i].update(dt)
        end
    end

    function matrix.draw()
        for i = 1, matrix.numCodeStrings do
            matrix.codeStrings[i].draw()
        end
    end

    return matrix
end

-- CodeString class implementation
local CODE_STRING_MIN_NUM_CHARS = 10
local CODE_STRING_MAX_NUM_CHARS = 100
local CODE_STRING_MIN_SPEED = 5
local CODE_STRING_MAX_SPEED = 45
local CODE_STRING_MIN_SPEED_ALPHA = 0.2

function CodeString(numColumns, fontSize)
    local codeString = {}

    function codeString.reset()
        codeString.x = (love.math.random() * numColumns) * fontSize
        codeString.y = -10
        codeString.speed = CODE_STRING_MIN_SPEED + (love.math.random() * (CODE_STRING_MAX_SPEED - CODE_STRING_MIN_SPEED))
        codeString.numChars = love.math.random(CODE_STRING_MIN_NUM_CHARS, CODE_STRING_MAX_NUM_CHARS)
        codeString.fontSize = fontSize
        codeString.chars = {}

        for i = 1, codeString.numChars do
            codeString.chars[i] = getRandomChar()
        end
    end 

    function codeString.update(dt)
        codeString.y = codeString.y + codeString.speed * dt

        local endY = codeString.y - (codeString.numChars * codeString.fontSize)
        if endY >= love.graphics.getHeight() then
            codeString.reset()
        end
    end

    function codeString.draw()
        for i = 1, codeString.numChars do
            local x = codeString.x
            local y = codeString.y - codeString.fontSize * i
            local charIndex = math.mod(math.abs(i - math.floor(codeString.y / codeString.fontSize)), codeString.numChars) + 1

            local r, g, b, a = COLOR[1], COLOR[2], COLOR[3], 1

            -- Set the color of the first few characters shades of white.
            if i == 1 then
                r, g, b = 1, 1, 1
            elseif i <= 4 then
                r, g, b = 0.8, 0.8, 0.8
            else
                a = 1 - i / codeString.numChars
            end

            a = a * math.max(CODE_STRING_MIN_SPEED_ALPHA, codeString.speed / CODE_STRING_MAX_SPEED)
            love.graphics.setColor(r, g, b, a)

            love.graphics.print(string.char(codeString.chars[charIndex]), x, y)

            -- Randomly glitch characters
            if love.math.random(1000) < 5 then
                codeString.chars[i] = getRandomChar()
            end
        end
    end

    codeString.reset()

    return codeString
end

function getRandomChar()
    -- Random char between ASCII '!' and 'z'.
    local charCode = love.math.random(33, 126)

    -- These character codes are empty glyphs in the matrix ttf font,
    -- so re-assign them to known japanese character glyphs.
    if charCode == 96 or charCode == 64 then
        charCode = love.math.random(97, 122)
    end
  
    return charCode
end
