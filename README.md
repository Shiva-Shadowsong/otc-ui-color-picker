**Color Picker** extends _UIColorPicker_, which extends _UIWindow_.

> Use this widget when you need to spawn a window that will allow the user to change the color of something with full control over the resulting HEX value.

> The widget is closed via the 'Done' button, or pressing Esc, at which point it will call its `onClose` field and destroy itself. Connect to the `onClose` field and capture the data from the window before it is destroyed as you wish.

![Example](https://i.imgur.com/sj1lG3Q.png)

### Installation

Make sure to load UIColorPicker during client setup (with dofile in core .otmod).

In the .otui file, there is a line:

```
image-source: /images/ui/window/windowContent
```

Swap this out for the location of a window content background that your client uses.

### Usage:

~~~lua
local picker = g_ui.createWidget('ColorPicker', rootWidget)
connect(picker, {
  onClose = function(self, selectedColor)
    print("The color picked in the window before it was closed was: " .. pickedColor)
  end
})
~~~

Keep in mind UIColorPicker is an extension of UIWindow, so it inherits all UIWindow behaviors as well.
