from fathom import Point, ORIGIN
from fathom.tikz import Canvas
from fathom.geometry import *
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

def bbox(ps):
    minx = min(v.x for v in ps)
    miny = min(v.y for v in ps)
    maxx = max(v.x for v in ps)
    maxy = max(v.y for v in ps)
    return [
        Point(minx, maxy),
        Point(maxx, maxy),
        Point(maxx, miny),
        Point(minx, miny)]

if __name__ == '__main__':
    a = Point(0, -1)
    b = Point(1, 0)
    c = Point(0.5, -1.5)
    d = Point(1.5, -2)
    e = Point(2, -1.75)
    f = Point(3, -2.5)
    g = Point(2.75, 0)
    h = Point(3.25, -0.5)

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    canvas.new_text(anchor=a, text='$a$', location=locations.WEST)
    canvas.new_text(anchor=b, text='$b$', location=locations.NORTH)
    canvas.new_text(anchor=c, text='$c$', location=locations.NORTH)
    canvas.new_text(anchor=d, text='$d$', location=locations.SOUTH)
    canvas.new_text(anchor=e, text='$e$', location=locations.NORTHEAST)
    canvas.new_text(anchor=f, text='$f$', location=locations.SOUTH)
    canvas.new_text(anchor=g, text='$g$', location=locations.NORTH)
    canvas.new_text(anchor=h, text='$h$', location=locations.EAST)

    for p in [a, b, c, d, e, f, g, h]:
        canvas.new_bullet(center=p)

    canvas.new_rectangle(vertices=bbox([a, b, c, d, e, f, g, h]))
    canvas.new_rectangle(vertices=bbox([a, b, c, d]), pen_color=colors.RED)
    canvas.new_rectangle(vertices=bbox([a, b]), pen_color=colors.BLUE)
    canvas.new_rectangle(vertices=bbox([c, d]), pen_color=colors.BLUE)
    canvas.new_rectangle(vertices=bbox([e, f, g, h]), pen_color=colors.RED)
    canvas.new_rectangle(vertices=bbox([e, f]), pen_color=colors.BLUE)
    canvas.new_rectangle(vertices=bbox([g, h]), pen_color=colors.BLUE)

    print(canvas.draw())
