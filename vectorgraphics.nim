{.experimental: "overloadableEnums".}

import ./vectorgraphics/nanovg

type
  Vec2 = concept v
    v.x is float
    v.y is float

  Color = concept c
    c.r is float
    c.g is float
    c.b is float
    c.a is float

  Paint* = NVGpaint

  Winding* = enum
    CounterClockwise
    Clockwise

  PathWinding* = enum
    CounterClockwise
    Clockwise
    Solid
    Hole

  LineCap* = enum
    Butt
    Round
    Square

  LineJoin* = enum
    Round
    Bevel
    Miter

  TextAlignX* = enum
    Left
    Center
    Right

  TextAlignY* = enum
    Top
    Center
    Bottom
    Baseline

  Glyph* = object
    index*: uint64
    x*: float
    minX*, maxX*: float

  VectorGraphics* = ref VectorGraphicsObj
  VectorGraphicsObj* = object
    ctx: NVGcontext

proc `=destroy`*(vg: var VectorGraphicsObj) =
  nvgDelete(vg.ctx)

{.push inline.}

proc new*(_: typedesc[VectorGraphics]): VectorGraphics =
  return VectorGraphics(ctx: nvgCreate(NVG_ANTIALIAS or NVG_STENCIL_STROKES))

proc toNvgColor(color: Color): NVGcolor =
  NVGcolor(r: color.r, g: color.g, b: color.b, a: color.a)

proc toNvgEnum(winding: Winding): cint =
  return case winding:
    of CounterClockwise: NVG_CCW
    of Clockwise: NVG_CW

proc toNvgEnum(winding: PathWinding): cint =
  return case winding:
    of CounterClockwise: NVG_CCW
    of Clockwise: NVG_CW
    of Solid: NVG_SOLID
    of Hole: NVG_HOLE

proc toNvgEnum(cap: LineCap): cint =
  return case cap:
    of Butt: NVG_BUTT
    of Round: NVG_ROUND
    of Square: NVG_SQUARE

proc toNvgEnum(join: LineJoin): cint =
  return case join:
    of Round: NVG_ROUND
    of Bevel: NVG_BEVEL
    of Miter: NVG_MITER

proc beginFrame*(vg: VectorGraphics, width, height: int, scale: float) =
  nvgBeginFrame(vg.ctx, float(width) / scale, float(height) / scale, scale)

proc endFrame*(vg: VectorGraphics) =
  nvgEndFrame(vg.ctx)

proc beginPath*(vg: VectorGraphics) = nvgBeginPath(vg.ctx)
proc moveTo*(vg: VectorGraphics, p: Vec2) = nvgMoveTo(vg.ctx, p.x, p.y)
proc lineTo*(vg: VectorGraphics, p: Vec2) = nvgLineTo(vg.ctx, p.x, p.y)
proc quadTo*(vg: VectorGraphics, c, p: Vec2) = nvgQuadTo(vg.ctx, c.x, c.y, p.x, p.y)
proc arcTo*(vg: VectorGraphics, p0, p1: Vec2, r: float) = nvgArcTo(vg.ctx, p0.x, p0.y, p1.x, p1.y, r)
proc closePath*(vg: VectorGraphics) = nvgClosePath(vg.ctx)
proc arc*(vg: VectorGraphics, c: Vec2, r, a0, a1: float, winding: Winding) = nvgArc(vg.ctx, c.x, c.y, r, a0, a1, winding.toNvgEnum())
proc rect*(vg: VectorGraphics, p, size: Vec2) = nvgRect(vg.ctx, p.x, p.y, size.x, size.y)
proc roundedRect*(vg: VectorGraphics, p, size: Vec2, r: float) = nvgRoundedRect(vg.ctx, p.x, p.y, size.x, size.y, r)
proc roundedRect*(vg: VectorGraphics, p, size: Vec2, radTopLeft, radTopRight, radBottomRight, radBottomLeft: float) = nvgRoundedRectVarying(vg.ctx, p.x, p.y, size.x, size.y, radTopLeft, radTopRight, radBottomRight, radBottomLeft)
proc ellipse*(vg: VectorGraphics, c, r: Vec2) = nvgEllipse(vg.ctx, c.x, c.y, r.x, r.y)
proc circle*(vg: VectorGraphics, c: Vec2, r: float) = nvgCircle(vg.ctx, c.x, c.y, r)
proc fill*(vg: VectorGraphics) = nvgFill(vg.ctx)
proc stroke*(vg: VectorGraphics) = nvgStroke(vg.ctx)
proc saveState*(vg: VectorGraphics) = nvgSave(vg.ctx)
proc restoreState*(vg: VectorGraphics) = nvgRestore(vg.ctx)
proc reset*(vg: VectorGraphics) = nvgReset(vg.ctx)
proc resetTransform*(vg: VectorGraphics) = nvgResetTransform(vg.ctx)
proc `pathWinding=`*(vg: VectorGraphics, winding: PathWinding) = nvgPathWinding(vg.ctx, winding.toNvgEnum())
proc `shapeAntiAlias=`*(vg: VectorGraphics, enabled: bool) = nvgShapeAntiAlias(vg.ctx, cint(enabled))
proc `strokeColor=`*(vg: VectorGraphics, color: Color) = nvgStrokeColor(vg.ctx, color.toNvgColor)
proc `strokePaint=`*(vg: VectorGraphics, paint: Paint) = nvgStrokePaint(vg.ctx, paint)
proc `fillColor=`*(vg: VectorGraphics, color: Color) = nvgFillColor(vg.ctx, color.toNvgColor)
proc `fillPaint=`*(vg: VectorGraphics, paint: Paint) = nvgFillPaint(vg.ctx, paint)
proc `miterLimit=`*(vg: VectorGraphics, limit: float) = nvgMiterLimit(vg.ctx, limit)
proc `strokeWidth=`*(vg: VectorGraphics, width: float) = nvgStrokeWidth(vg.ctx, width)
proc `lineCap=`*(vg: VectorGraphics, cap: LineCap) = nvgLineCap(vg.ctx, cap.toNvgEnum())
proc `lineJoin=`*(vg: VectorGraphics, join: LineJoin) = nvgLineJoin(vg.ctx, join.toNvgEnum())
proc `globalAlpha=`*(vg: VectorGraphics, alpha: float) = nvgGlobalAlpha(vg.ctx, alpha)
proc resetClip*(vg: VectorGraphics) = nvgResetScissor(vg.ctx)
proc clip*(vg: VectorGraphics, p, size: Vec2, intersect = true) =
  if intersect:
    nvgIntersectScissor(vg.ctx, p.x, p.y, size.x, size.y)
  else:
    nvgScissor(vg.ctx, p.x, p.y, size.x, size.y)

proc boxGradient*(vg: VectorGraphics, p, size: Vec2, radius, feather: float, innerColor, outerColor: Color): Paint =
  nvgBoxGradient(vg.ctx, p.x, p.y, size.x, size.y, radius, feather, innerColor.toNvgColor, outerColor.toNvgColor)

proc addFont*(vg: VectorGraphics, name, data: string) =
  let font = nvgCreateFontMem(vg.ctx, cstring(name), cstring(data), cint(data.len), 0)
  if font == -1:
    echo "Failed to load font: " & name

proc text*(vg: VectorGraphics, p: Vec2, text: openArray[char]): float {.discardable.} =
  if text.len <= 0:
    return
  return nvgText(
    vg.ctx,
    p.x, p.y,
    cast[cstring](unsafeAddr(text[0])),
    cast[cstring](cast[uint64](unsafeAddr(text[text.len - 1])) + 1),
  )

proc textMetrics*(vg: VectorGraphics): tuple[ascender, descender, lineHeight: float32] =
  nvgTextMetrics(vg.ctx, addr(result.ascender), addr(result.descender), addr(result.lineHeight))

proc textAlign*(vg: VectorGraphics, x: TextAlignX, y: TextAlignY) =
  let nvgXValue = case x:
    of Left: NVG_ALIGN_LEFT
    of Center: NVG_ALIGN_CENTER
    of Right: NVG_ALIGN_RIGHT
  let nvgYValue = case y:
    of Top: NVG_ALIGN_TOP
    of Center: NVG_ALIGN_MIDDLE
    of Bottom: NVG_ALIGN_BOTTOM
    of Baseline: NVG_ALIGN_BASELINE
  nvgTextAlign(vg.ctx, cint(nvgXValue or nvgYValue))

proc `font=`*(vg: VectorGraphics, name: string) = nvgFontFace(vg.ctx, cstring(name))
proc `fontSize=`*(vg: VectorGraphics, size: float) = nvgFontSize(vg.ctx, size)
proc `letterSpacing=`*(vg: VectorGraphics, spacing: float) = nvgTextLetterSpacing(vg.ctx, spacing)
proc translate*(vg: VectorGraphics, amount: Vec2) = nvgTranslate(vg.ctx, amount.x, amount.y)
proc scale*(vg: VectorGraphics, amount: Vec2) = nvgScale(vg.ctx, amount.x, amount.y)

{.pop.}

template width*(glyph: Glyph): auto = glyph.maxX - glyph.minX

proc getGlyphs*(vg: VectorGraphics, position: Vec2, text: openArray[char]): seq[Glyph] =
  if text.len <= 0:
    return

  var nvgPositions = newSeq[NVGglyphPosition](text.len)
  discard nvgTextGlyphPositions(vg.ctx, position.x, position.y, cast[cstring](text[0].unsafeAddr), nil, nvgPositions[0].addr, text.len.cint)
  for i in countdown(nvgPositions.len - 1, 0, 1):
    let glyph = nvgPositions[i]
    if glyph.str != nil:
      nvgPositions.setLen(i + 1)
      break

  result.setLen(nvgPositions.len)
  for i, nvgPosition in nvgPositions:
    result[i].index = cast[uint64](nvgPosition.str) - cast[uint64](text[0].unsafeAddr)
    result[i].x = nvgPosition.x
    result[i].minX = nvgPosition.minx
    result[i].maxX = nvgPosition.maxx