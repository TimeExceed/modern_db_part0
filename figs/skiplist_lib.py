from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *
import math

def draw_doc_chain(canvas, start_pt, ts):
    ps = repeat(start_pt)
    ps = accumulate(ps, lambda x, _: x + Point(1, 0))
    ps = islice(ps, len(ts))
    ps = list(ps)
    for p, t in zip(ps, ts):
        canvas.new_text(anchor=p, text=t)
    bcircles = [canvas.new_circle(center=x, radius=0.2) for x in ps]
    for s, t in zip(bcircles, bcircles[1:]):
        canvas.new_arrow(src=s, dst=t)

    level_n = math.log2(len(ts))
    height = level_n * 0.5 + 0.3
    for x in bcircles:
        canvas.new_line(
            src=x,
            dst=x.get_skeleton().center() + Point(0, height),
            line_style=line_styles.DASHED)
    height = 0.6
    skip = 2
    while skip <= len(ts):
        xs = [(x.get_skeleton().center() + Point(0, height)) for x in bcircles]
        xs = enumerate(xs)
        xs = [x for i, x in xs if i % skip == 0]
        for s, t in zip(xs, xs[1:]):
            canvas.new_arrow(src=s, dst=t)
        height += 0.5
        skip *= 2

    return bcircles
