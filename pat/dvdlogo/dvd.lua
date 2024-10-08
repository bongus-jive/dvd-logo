local pos_X = 0
local pos_Y = 0
local speed = 1
local moving_down = math.random() > 0.5
local moving_left = math.random() > 0.5
local imageSize

local function randomColor()
  return string.format("#%06x", math.random(0x808080, 0xFFFFFF))
end

local drawable = {
  image = "/pat/dvdlogo/dvd.png",
  color = randomColor(),
  centered = false
}

function init()
  if interface then
    if interface.drawDrawable then
      drawDrawable = interface.drawDrawable
    elseif interface.bindCanvas then
      local canvas = interface.bindCanvas("pat_dvd", true)
      drawDrawable = function(...)
        canvas:clear()
        canvas:drawDrawable(...)
      end
      getScreenSize = function() return canvas:size() end
    end
  end

  if not getScreenSize and camera and camera.screenSize then
    getScreenSize = camera.screenSize
  end

  if not drawDrawable or not getScreenSize then
    sb.logWarn("'dvd logo' requires StarExtensions or OpenStarbound")
    script.setUpdateDelta(0)
    update = nil
    return
  end

  imageSize = root.imageSize(drawable.image)

  local screenSize = getScreenSize()
  pos_X = math.random(0, screenSize[1])
  pos_Y = math.random(0, screenSize[2])
end

function update()
  local screenSize = getScreenSize()
  local max_X = math.max(0, screenSize[1] - imageSize[1])
  local max_Y = math.max(0, screenSize[2] - imageSize[2])

  pos_X = pos_X + (moving_left and -speed or speed)
  pos_Y = pos_Y + (moving_down and -speed or speed)

  if pos_X <= 0 then
    pos_X = 0
    moving_left = false
    drawable.color = randomColor()
  elseif pos_X >= max_X then
    pos_X = max_X
    moving_left = true
    drawable.color = randomColor()
  end

  if pos_Y <= 0 then
    pos_Y = 0
    moving_down = false
    drawable.color = randomColor()
  elseif pos_Y >= max_Y then
    pos_Y = max_Y
    moving_down = true
    drawable.color = randomColor()
  end

  drawDrawable(drawable, {pos_X, pos_Y}, 1)
end
