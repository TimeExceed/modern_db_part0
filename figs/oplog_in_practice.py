from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.layout as layout
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

SEG_WIDTH = 1
SEG_HEIGHT = 0.6
HEADER_WIDTH = 1.2
FOOTER_WIDTH = 1.2


def epoch0(canvas, leftmost):
    texts = ['header', 'op', '\\dots', 'idx', 'op', '\\dots', 'idx', 'footer']
    rects = repeat(leftmost + Point(HEADER_WIDTH, 0))
    rects = accumulate(rects, lambda x, _: x + Point(SEG_WIDTH, 0))
    rects = islice(rects, len(texts) - 2)
    rects = [geo.Rectangle(center=x + Point(SEG_WIDTH/2, 0),
                           width=SEG_WIDTH, height=SEG_HEIGHT) for x in rects]
    rects.insert(0, geo.Rectangle(
        center=leftmost + Point(HEADER_WIDTH / 2, 0),
        width=HEADER_WIDTH,
        height=SEG_HEIGHT))
    rects.append(geo.Rectangle(
        center=rects[-1].center() + Point(SEG_WIDTH / 2 + FOOTER_WIDTH / 2, 0),
        width=FOOTER_WIDTH,
        height=SEG_HEIGHT))

    for x, t in zip(rects, texts):
        canvas.new_text(anchor=x.center(), text=t)

    canvas.new_rectangle(
        vertices=[
            rects[0].vertices()[0],
            rects[-1].vertices()[1],
            rects[-1].vertices()[2],
            rects[0].vertices()[3]])

    for x in rects[1:]:
        canvas.new_line(src=x.vertices()[0], dst=x.vertices()[3])


def epoch_m(canvas, leftmost):
    texts = ['header', 'op', '\\dots']
    rects = repeat(leftmost + Point(HEADER_WIDTH, 0))
    rects = accumulate(rects, lambda x, _: x + Point(SEG_WIDTH, 0))
    rects = islice(rects, len(texts) + 1)
    rects = [geo.Rectangle(center=x + Point(SEG_WIDTH/2, 0),
                           width=SEG_WIDTH, height=SEG_HEIGHT) for x in rects]
    rects.insert(0, geo.Rectangle(
        center=leftmost + Point(HEADER_WIDTH / 2, 0),
        width=HEADER_WIDTH,
        height=SEG_HEIGHT))

    for x, t in zip(rects, texts):
        canvas.new_text(anchor=x.center(), text=t)

    canvas.new_rectangle(
        vertices=[
            rects[0].vertices()[0],
            rects[2].vertices()[1],
            rects[2].vertices()[2],
            rects[0].vertices()[3]
        ]
    )
    for x in rects[1:3]:
        canvas.new_line(src=x.vertices()[0], dst=x.vertices()[3])

    v_srcs = rects[3].vertices()
    v_dsts = v_srcs[1:]
    for s, t in zip(v_srcs, v_dsts):
        canvas.new_line(src=s, dst=t, line_style=line_styles.DASHED)

    canvas.new_arrow(src=rects[-1].center(), dst=rects[-2].center())
    canvas.new_text(anchor=rects[-1].center(),
                    text='$\\text{op}_{m,i}$', location=locations.EAST)

if __name__ == '__main__':
    matrix = layout.matrix(
        h_sep=1,
        v_sep=0.8,
        n_rows=3,
        n_cols=2,
        top_left=ORIGIN)

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    canvas.new_text(
        anchor=matrix[0][0],
        text='$\\text{epoch}_0$')
    canvas.new_text(
        anchor=matrix[1][1],
        text='\\normalsize\\dots',
        location=locations.EAST)
    canvas.new_text(
        anchor=matrix[2][0],
        text='$\\text{epoch}_m$')

    epoch0(canvas, matrix[0][1])
    epoch_m(canvas, matrix[2][1])

    print(canvas.draw())
