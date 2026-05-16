local Dvd = {}

function Dvd:init()
  local img = "/pat/dvdlogo/dvd.png"
  self.imgSize = root.imageSize(img)
  self.drawable = { image = img, centered = false, fullbright = true }
  self:randomizeColor()

  local r = sb.makeRandomSource()
  self.x = r:randf()
  self.y = r:randf()
  self.xDown = r:randb()
  self.yDown = r:randb()

  self:initExt()
end

function Dvd:update()
  local rect = world.clientWindow()
  local ePos = entity.position()
  
  local lr = self.lastRect or rect
  self.lastRect = rect
  for i = 1, 4 do
    rect[i] = rect[i] + (lr[i] - rect[i]) * 0.6
  end

  local w, h = rect[3] - rect[1], rect[4] - rect[2]
  self.drawable.scale = (w / self.imgSize[1] + h / self.imgSize[2]) / 2
  local scale = self.drawable.scale / 8

  self.x, self.xDown = self:move(self.x, self.xDown, 1, scale / w)
  self.y, self.yDown = self:move(self.y, self.yDown, 1, scale / h)

  local dx = rect[1] - ePos[1]
  local dy = rect[2] - ePos[2]
  local dw = w - (self.imgSize[1] * scale)
  local dh = h - (self.imgSize[2] * scale)
  
  self.drawable.position = {dx + dw * self.x, dy + dh * self.y}
  localAnimator.addDrawable(self.drawable, "Overlay+6769")
end

----------------------------------------- se/osb
function Dvd:initExt()
  if not interface then return end

  local draw
  local screen = camera and camera.screenSize or nil

  if interface.drawDrawable then
    draw = interface.drawDrawable
  elseif interface.bindCanvas then
    local c = interface.bindCanvas("pat_dvd", true)
    screen = function() return c:size() end
    draw = function(...)
      c:clear()
      c:drawDrawable(...)
    end
  end

  if not draw or not screen then return end

  self.update = self.updateExt
  self.drawDrawable = draw
  self.getScreenSize = screen

  local size = screen()
  self.x = self.x * size[1]
  self.y = self.y * size[2]
end

function Dvd:updateExt()
  local size = self.getScreenSize()
  local mx = math.max(0, size[1] - self.imgSize[1])
  local my = math.max(0, size[2] - self.imgSize[2])

  self.x, self.xDown = self:move(self.x, self.xDown, mx, 1)
  self.y, self.yDown = self:move(self.y, self.yDown, my, 1)

  self.drawDrawable(self.drawable, {self.x, self.y}, 1)
end

-----------------------------------------
function Dvd:move(n, down, max, speed)
  n = n + (down and -speed or speed)

  if n <= 0 then
    self:randomizeColor()
    return 0, false
  elseif n >= max then
    self:randomizeColor()
    return max, true
  end
  
  return n, down
end

function Dvd:randomizeColor()
  self.drawable.color = string.format("#%06x", math.random(0x808080, 0xFFFFFF))
end

-----------------------------------------
local _init, _update = init, update
function init() _init() Dvd:init() end
function update(dt) _update(dt) Dvd:update() end
