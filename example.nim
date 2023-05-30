import std/sequtils
import vectorgraphics
import oswindow

type
  Vec2 = object
    x, y: float

var windows: seq[OsWindow]

for i in 0 ..< 4:
  let window = OsWindow.new()
  windows.add(window)
  window.setBackgroundColor(0.1, 0.1, 0.1)
  window.setSize(400, 300)
  window.show()

  let vg = VectorGraphics.new()
  GcRef(vg)
  window.userData = cast[pointer](vg)

  window.onFrame = proc(window: OsWindow) =
    let (width, height) = window.size
    let vg = cast[VectorGraphics](window.userData)
    vg.beginFrame(width, height, window.scale)

    vg.beginPath()
    vg.rect(Vec2(x: 50, y: 50), Vec2(x: 200, y: 200))
    vg.fill()

    vg.endFrame()
    window.swapBuffers()

  window.onClose = proc(window: OsWindow) =
    let vg = cast[VectorGraphics](window.userData)
    GcUnref(vg)

while windows.len > 0:
  for window in windows:
    window.pollEvents()
    window.processFrame()

  windows.keepItIf(it.isOpen)