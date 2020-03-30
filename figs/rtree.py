from fathom import Point, ORIGIN
from fathom.tikz import Canvas
from fathom.geometry import *
import fathom.layout as layout
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

def node(canvas, center, **kws):
    SEG_WIDTH = 0.5
    SEG_HEIGHT = 0.4

    vs = repeat(center + Point(-SEG_WIDTH / 2, 0))
    vs = accumulate(vs, lambda x, _: x + Point(SEG_WIDTH, 0))
    vs = islice(vs, 2)
    vs = [Rectangle(center=x, width=SEG_WIDTH, height=SEG_HEIGHT)
        for x in vs]

    canvas.new_rectangle(
        center=center,
        width=SEG_WIDTH * 2,
        height=SEG_HEIGHT,
        **kws)
    canvas.new_line(
        src=center + Point(0, SEG_HEIGHT / 2),
        dst=center + Point(0, -SEG_HEIGHT / 2),
        **kws)

    return vs

def tree_edge(canvas, root, left, right):
    def draw_edge(seg0, seg1):
        canvas.new_arrow(
            src=centroid([seg0.vertices()[2], seg0.vertices()[3]]),
            dst=centroid([seg1.vertices()[0], seg1.vertices()[1]]))
    draw_edge(root[0], left[0])
    draw_edge(root[1], right[0])

if __name__ == '__main__':
    tree = layout.tree(
        ['root',
         ['left', ['left_left'], ['left_right']],
         ['right', ['right_left'], ['right_right']]],
        root=ORIGIN,
        h_sep=1.2,
        v_sep=1)

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    segs_root = node(canvas, tree['root'])
    segs_left = node(canvas, tree['left'], pen_color=colors.RED)
    segs_right = node(canvas, tree['right'], pen_color=colors.RED)
    segs_left_left = node(canvas, tree['left_left'], pen_color=colors.BLUE)
    segs_left_right = node(canvas, tree['left_right'], pen_color=colors.BLUE)
    segs_right_left = node(canvas, tree['right_left'], pen_color=colors.BLUE)
    segs_right_right = node(canvas, tree['right_right'], pen_color=colors.BLUE)

    tree_edge(canvas, segs_root, segs_left, segs_right)
    tree_edge(canvas, segs_left, segs_left_left, segs_left_right)
    tree_edge(canvas, segs_right, segs_right_left, segs_right_right)

    segs = segs_left_left + segs_left_right + segs_right_left + segs_right_right
    ts = ['$a$', '$b$', '$c$', '$d$', '$e$', '$f$', '$g$', '$h$']
    for r, t in zip(segs, ts):
        canvas.new_text(anchor=r.center(), text=t)

    print(canvas.draw())
