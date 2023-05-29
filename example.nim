import std/sequtils
import opengl
import vectorgraphics
import oswindow

type
  Vec2 = object
    x, y: float

var windows: seq[OsWindow]

proc onFrame(window: OsWindow) =
  let (width, height) = window.size
  let vg = cast[VectorGraphics](window.userData)

  window.makeContextCurrent()

  glViewport(0, 0, int32(width), int32(height))
  glClearColor(0.1, 0.1, 0.1, 1.0)
  glClear(GL_COLOR_BUFFER_BIT)

  vg.beginFrame(width, height, 1.0)
  vg.beginPath()
  vg.rect(Vec2(x: 50, y: 50), Vec2(x: 200, y: 200))
  vg.fillColor = (r: 1.0, g: 0.0, b: 0.0, a: 1.0)
  vg.fill()
  vg.endFrame()

  window.swapBuffers()

for i in 0 ..< 4:
  let window = OsWindow.new()
  windows.add(window)
  window.setSize(400, 300)
  window.show()

  opengl.loadExtensions()

  let vg = VectorGraphics.new()
  GcRef(vg)
  window.userData = cast[pointer](vg)

  window.onClose = proc(window: OsWindow) =
    window.makeContextCurrent()
    let vg = cast[VectorGraphics](window.userData)
    GcUnref(vg)

  window.onResize = proc(window: OsWindow, width, height: int) =
    onFrame(window)

while windows.len > 0:
  for window in windows:
    window.pollEvents()
    if window.isOpen:
      onFrame(window)

  windows.keepItIf(it.isOpen)