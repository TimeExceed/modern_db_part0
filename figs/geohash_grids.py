from fathom import Point, ORIGIN
from fathom.tikz import Canvas
from fathom.geometry import *
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

if __name__ == '__main__':
    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    canvas.new_polygon(
        vertices=[
            Point(0.8, 0.7),
            Point(0.5, 1.4),
            Point(1.1, 2.8),
            Point(2.2, 2.5),
            Point(2.5, 1.1),
            Point(1.2, 0.5)],
        brush_color=colors.GRAY,
        pen_color=colors.INVISIBLE)

    vs = repeat(ORIGIN)
    vs = accumulate(vs, lambda x, _: x + Point(1, 0))
    vs = list(islice(vs, 4))
    for x in vs:
        canvas.new_line(
            src=x,
            dst=x + Point(0, 3),
            line_style=line_styles.DASHED)

    vs = repeat(ORIGIN)
    vs = accumulate(vs, lambda x, _: x + Point(0, 1))
    vs = list(islice(vs, 4))
    for x in vs:
        canvas.new_line(
            src=x,
            dst=x + Point(3, 0),
            line_style=line_styles.DASHED)

    print(canvas.draw())
