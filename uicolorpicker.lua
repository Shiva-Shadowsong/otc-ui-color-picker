UIColorPicker = extends(UIWindow)

function UIColorPicker.create()
  local actionbar = UIColorPicker.internalCreate()
  actionbar.alphaEditing = true
  return actionbar
end

function UIColorPicker:getClassName()
  return 'UIColorPicker'
end

function UIColorPicker:initialize()
  -- Don't even try if mouse is already grabbed by something.
  if g_ui.isMouseGrabbed() then
    self:destroy()
    return
  end

  -- Position where the mouse is:
  local pos = g_window.getMousePosition()
  pos.y = pos.y - self:getHeight()
  pos.x = pos.x - self:getWidth()/2
  self:setPosition(pos)

  -- Set up color sliders:
  local colors = {"red", "green", "blue", "alpha"}
  for _,c in pairs(colors) do
    self:getChildById(c):getChildById('description'):setText(c:uppercaseFirstChar()..":")
    connect(self:getColorSlider(c), {onValueChange = function(slider, value, delta)
      self:updatePreviewer()
    end})
  end

  -- Update all values to reflect current state:
  self:updatePreviewer()

  -- Set up 'Done' button
  self:getChildById('doneButton').onClick = function(button)
    self:close()
  end

  -- Set up 'Apply Hex' button.
  self:getChildById('applyHexButton'):setTooltip("Enter a color's hex code above and press this button to apply it.\nAccepted formats:\n#RRGGBB, #RRGGBBAA (AA = Alpha)")

  self:getChildById('applyHexButton').onClick = function(button)
    local color = tocolor(self:getHexCodeEditor():getText())
    if type(color) == "table" then
      self:setRGBA(color.r, color.g, color.b, color.a)
    end
  end

  self:grabMouse()
  self:focus()
end

function UIColorPicker:updatePreviewer()
  local color = {}
  color.r = self:getColorSlider('red'):getValue()
  color.g = self:getColorSlider('green'):getValue()
  color.b = self:getColorSlider('blue'):getValue()
  color.a = self:getColorSlider('alpha'):getValue()
  local colorstring = colortostring(color)
  self:getChildById('colorPreviewer'):setBackgroundColor(colorstring)
  if colorstring:len() > 7 and color.a == 255 then
    colorstring = colorstring:sub(1,7)
  end
  self:setHexCodeEditorText(colorstring)
end


function UIColorPicker:onMousePress(mousePos, mouseButton)
  -- clicks outside menu area destroys the color picker
  if not self:containsPoint(mousePos) then
    self:close()
  end
  return true
end

function UIColorPicker:onGeometryChange(oldRect, newRect)
  local parent = self:getParent()
  if not parent then return end
  local ymax = parent:getY() + parent:getHeight()
  local xmax = parent:getX() + parent:getWidth()
  if newRect.y + newRect.height > ymax then
    local newy = newRect.y - newRect.height
    if newy > 0 and newy + newRect.height < ymax then self:setY(newy) end
  end
  if newRect.x + newRect.width > xmax then
    local newx = newRect.x - newRect.width
    if newx > 0 and newx + newRect.width < xmax then self:setX(newx) end
  end
  self:bindRectToParent()
end

function UIColorPicker:disableAlphaEditing()
  self.alphaEditing = false
  self:getColorSlider('alpha'):setValue(255)
  self:getChildById('alpha'):hide()
end

function UIColorPicker:getColorSlider(colorname)
  return self:getChildById(colorname):getChildById('slider')
end

function UIColorPicker:getRGBA()
  return self:getChildById('colorPreviewer'):getBackgroundColor()
end

function UIColorPicker:setRGBA(r,g,b,a)
  self:getColorSlider('red'):setValue(r)
  self:getColorSlider('green'):setValue(g)
  self:getColorSlider('blue'):setValue(b)
  self:getColorSlider('alpha'):setValue(self.alphaEditing and a or 255)
  self:updatePreviewer()
end

function UIColorPicker:getHexCodeEditor()
  return self:getChildById('hexcode')
end

function UIColorPicker:setHexCodeEditorText(txt)
  local color = tocolor(txt)
  if type(color) == "table" then
    self:getHexCodeEditor():setText(txt)
  end
end

function UIColorPicker:close()
  signalcall(self.onClose, self, self:getRGBA())
  self:ungrabMouse()
  self:destroy()
end