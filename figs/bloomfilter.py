from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *


def bitmap(canvas):
    width = 0.4
    height = 0.4
    rects = repeat(ORIGIN)
    rects = accumulate(rects, lambda x, _: x + Point(width, 0))
    rects = islice(rects, 7)
    rects = [canvas.new_rectangle(
        center=x, width=width, height=height) for x in rects]
    return rects

def key(canvas, rects):
    p = Point(1, 1.5)
    canvas.new_text(anchor=p, text='$k$', location=locations.NORTH)
    canvas.new_arrow(src=p, dst=rects[0])
    canvas.new_arrow(src=p, dst=rects[2])
    canvas.new_arrow(src=p, dst=rects[5])
    canvas.new_text(anchor=Point(0.2, 0.7), text='\\scriptsize $h_0(k)$')
    canvas.new_text(anchor=Point(1.2, 0.5), text='\\scriptsize $h_1(k)$')
    canvas.new_text(anchor=Point(1.8, 0.9), text='\\scriptsize $h_2(k)$')


if __name__ == '__main__':
    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    rects = bitmap(canvas)
    key(canvas, rects)

    print(canvas.draw())
