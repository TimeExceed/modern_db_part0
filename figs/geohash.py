from fathom import Point, ORIGIN
from fathom.tikz import Canvas
from fathom.geometry import *
import fathom.layout as layout
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

def upside_down(p):
    return Point(p.x, -p.y)

def drop(xs, n):
    for _ in range(n):
        next(xs)
    for x in xs:
        yield x

def fraction(canvas, center, value, text_color):
    SEG_NUM = 3
    SEG_W = 0.2
    SEG_H = 0.4

    ts = repeat((value, 1, 0))
    ts = accumulate(
        ts,
        lambda x, _:
            (x[0], x[1] / 2, 0) if x[0] < x[1] else \
            (x[0] - x[1], x[1] / 2, 1))
    ts = drop(ts, 2)
    ts = ('{}'.format(x) for _, _, x in ts)

    rs = repeat(center + Point(-SEG_W * (SEG_NUM - 1) / 2, 0))
    rs = accumulate(rs, lambda x, _: x + Point(SEG_W, 0))
    rs = (Rectangle(center=x, width=SEG_W, height=SEG_H) for x in rs)
    rs = islice(rs, SEG_NUM)
    rs = list(rs)

    canvas.new_text(
        anchor=centroid([rs[0].vertices()[0],
                         rs[0].vertices()[3]]),
        text='0.',
        location=locations.WEST)

    res = list(zip(rs, ts))
    for r, t in res:
        canvas.new_text(
            anchor=r.center(),
            text=t,
            pen_color=text_color)

    canvas.new_rectangle(
        vertices=[rs[0].vertices()[0],
                  rs[-1].vertices()[1],
                  rs[-1].vertices()[2],
                  rs[0].vertices()[3]])
    for x in rs[1:]:
        canvas.new_line(src=x.vertices()[0], dst=x.vertices()[3])

    return res

def draw_root(canvas, center, left, right):
    SEG_W = 0.2
    SEG_H = 0.4
    n = len(left) + len(right)
    segs = repeat(center + Point(-SEG_W * (n - 1) / 2, 0))
    segs = accumulate(segs, lambda x, _: x + Point(SEG_W, 0))
    segs = (Rectangle(
        center=x,
        width=SEG_W,
        height=SEG_H) \
            for x in segs)
    segs = list(islice(segs, n))

    src = chain(
        ((i * 2, colors.BLUE, x) for i, x in enumerate(left)),
        ((i * 2 + 1, colors.ORANGE, x) for i, x in enumerate(right)))
    for i, c, (r, t) in src:
        d = segs[i]
        canvas.new_text(anchor=d.center(), text=t, pen_color=c)
        canvas.new_arrow(
            src=centroid([r.vertices()[2], r.vertices()[3]]),
            dst=centroid([d.vertices()[0], d.vertices()[1]]))

    canvas.new_rectangle(
        vertices=[segs[0].vertices()[0],
                  segs[-1].vertices()[1],
                  segs[-1].vertices()[2],
                  segs[0].vertices()[3]])
    for x in segs[1:]:
        canvas.new_line(
            src=x.vertices()[0],
            dst=x.vertices()[3])

if __name__ == '__main__':
    tree = layout.tree(
        ['root',
         ['left', ['left_up']],
         ['right', ['right_up']]],
        root=ORIGIN,
        h_sep=2,
        v_sep=1.3)
    for k, v in tree.copy().items():
        tree[k] = upside_down(v)

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    canvas.new_text(anchor=tree['left_up'], text='$121^\\circ$E')
    left_up = canvas.new_rectangle(
        center=tree['left_up'],
        width=1,
        height=0.4,
        pen_color=colors.INVISIBLE)
    left = fraction(canvas, tree['left'], (180 + 121) / 360, colors.BLUE)
    canvas.new_arrow(
        src=left_up,
        dst=centroid([left[1][0].vertices()[0], left[1][0].vertices()[1]]))

    canvas.new_text(anchor=tree['right_up'], text='$31^\\circ$N')
    right_up = canvas.new_rectangle(
        center=tree['right_up'],
        width=1,
        height=0.4,
        pen_color=colors.INVISIBLE)
    right = fraction(canvas, tree['right'], (31 + 90) / 180, colors.ORANGE)
    canvas.new_arrow(
        src=right_up,
        dst=centroid([right[1][0].vertices()[0], right[1][0].vertices()[1]]))

    draw_root(canvas, tree['root'], left, right)

    print(canvas.draw())
