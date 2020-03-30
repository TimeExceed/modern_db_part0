from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

SEG_WIDTH = 1
SEG_HEIGHT = 0.8

if __name__ == '__main__':
    rects = repeat(ORIGIN, 5)
    rects = accumulate(rects, lambda x, _: x + geo.Point(SEG_WIDTH, 0))
    rects = [geo.Rectangle(center=x, width=SEG_WIDTH, height=SEG_HEIGHT) for x in rects]

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    ops = ['$\\text{op}_{n-2}$', '$\\text{op}_{n-1}$', '$\\text{op}_{n}$']
    sns = ['$\\text{SN}_{n-2}$', '$\\text{SN}_{n-1}$', '$\\text{SN}_{n}$']
    for x, op, sn in zip(rects[2:], ops, sns):
        canvas.new_text(anchor=x.center(), text=op)
        canvas.new_text(
            anchor=x.vertices()[0],
            text=sn,
            location=locations.NORTH)

    canvas.new_text(
        anchor=geo.centroid([rects[0].center(), rects[1].center()]),
        text='\\normalsize \\dots')

    canvas.new_rectangle(
        vertices=[
            rects[0].vertices()[0],
            rects[-1].vertices()[1],
            rects[-1].vertices()[2],
            rects[0].vertices()[3]])
    for x in rects[2:]:
        vs = x.vertices()
        canvas.new_line(src=vs[0], dst=vs[3])

    print(canvas.draw())
