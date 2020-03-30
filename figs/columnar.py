from fathom import Point, ORIGIN
from fathom.tikz import Canvas
from fathom.geometry import *
import fathom.layout as layout
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *


def file_format(canvas):
    SEG_HEIGHT = 0.8
    SEG_WIDTH = 2
    TEXTS = ['File Header', 'Seg Header', 'Column Data',
             'Column Index', 'Seg Footer', '\\dots', 'File Footer']

    vs = repeat(ORIGIN)
    vs = accumulate(vs, lambda x, _: x + Point(0, -SEG_HEIGHT))
    vs = islice(vs, len(TEXTS))
    vs = list(vs)

    res = []
    for p, t in zip(vs, TEXTS):
        if t.startswith('File'):
            r = canvas.new_rectangle(
                center=p,
                width=SEG_WIDTH,
                height=SEG_HEIGHT,
                brush_color=colors.LIME)
        else:
            r = canvas.new_rectangle(
                center=p,
                width=SEG_WIDTH,
                height=SEG_HEIGHT,
                brush_color=colors.ORANGE)
        res.append(r)

    for p, t in zip(vs, TEXTS):
        canvas.new_text(anchor=p, text=t)

    return res


def index_tree(canvas):
    tree = layout.tree(
        ['', ['l'], ['r']],
        root=Point(3.5, -1),
        h_sep=1,
        v_sep=1)
    root = tree['']
    left = canvas.new_bullet(center=tree['l'])
    right = canvas.new_bullet(center=tree['r'])

    l = canvas.new_line(src=root, dst=left)
    canvas.new_text(
        anchor=centroid(l.get_skeleton().vertices()),
        text='age',
        location=locations.NORTHWEST)
    l = canvas.new_line(src=root, dst=right)
    canvas.new_text(
        anchor=centroid(l.get_skeleton().vertices()),
        text='name',
        location=locations.NORTHEAST)

    return root, left, right


def column_data(canvas, leftmost, texts):
    CELL_WIDTH = 0.8
    CELL_HEIGHT = 0.5

    ps = repeat(leftmost + Point(CELL_WIDTH / 2, 0))
    ps = accumulate(ps, lambda x, _: x + Point(CELL_WIDTH, 0))
    ps = islice(ps, len(texts))
    ps = list(ps)

    for p, t in zip(ps, texts):
        canvas.new_text(anchor=p, text=t)
    canvas.new_rectangle(
        center=centroid([ps[0], ps[-1]]),
        width=CELL_WIDTH*len(ps),
        height=CELL_HEIGHT)


if __name__ == '__main__':
    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])
    shadow_canvas = Canvas()

    segs = file_format(canvas)
    column_index_seg = segs[3]
    column_data_seg = segs[2]

    root, left, right = index_tree(canvas)
    bbox = Rectangle(
        center=centroid([root,
                             left.get_skeleton().center(),
                             right.get_skeleton().center()]),
        width=1.5,
        height=1)
    canvas.new_arrow(
        src=centroid([
            column_index_seg.get_skeleton().vertices()[1],
            column_index_seg.get_skeleton().vertices()[2]]),
        dst=centroid([
            bbox.vertices()[0],
            bbox.vertices()[3]]),
        line_style=line_styles.DASHED)

    age_cell = Point(5, -3)
    column_data(canvas, age_cell, ['18', '20', '21', '21', '18'])
    name_cell = Point(5, -3.5)
    column_data(canvas, name_cell, ['Alice', 'Alice', 'Alice', 'Alan', 'Alan'])
    canvas.new_arrow(
        src=centroid([column_data_seg.get_skeleton().vertices()[1],
                      column_data_seg.get_skeleton().vertices()[2]]),
        dst=centroid([age_cell, name_cell]) + Point(-0.3, 0),
        line_style=line_styles.DASHED)
    canvas.new_arrow(src=left, dst=age_cell)
    canvas.new_arrow(src=right, dst=name_cell)

    print(canvas.draw())
