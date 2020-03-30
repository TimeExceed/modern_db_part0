from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.layout as layout
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *
from skiplist_lib import draw_doc_chain

if __name__ == '__main__':
    tree = layout.tree(
        ['root', ['left'], ['right']],
        root=ORIGIN,
        h_sep=2,
        v_sep=1.5)

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    shawow_canvas = Canvas()
    tree['root'] = shawow_canvas.new_rectangle(
        center=tree['root'],
        width=1,
        height=0.5)
    tree['left'] = shawow_canvas.new_rectangle(
        center=tree['left'],
        width=1,
        height=0.5)
    tree['right'] = shawow_canvas.new_rectangle(
        center=tree['right'],
        width=1,
        height=0.5)
    canvas.new_line(src=tree['root'], dst=tree['left'])
    canvas.new_line(src=tree['root'], dst=tree['right'])
    canvas.new_text(
        anchor=tree['root'].get_skeleton().center(),
        text='[18,21]')
    canvas.new_text(
        anchor=tree['left'].get_skeleton().center(),
        text='[18,18]',
        pen_color=colors.RED)
    canvas.new_text(
        anchor=tree['right'].get_skeleton().center(),
        text='[20,21]',
        pen_color=colors.RED)

    left_docs = draw_doc_chain(canvas, Point(3, 0), ['0', '4'])
    canvas.new_arrow(src=tree['left'], dst=left_docs[0], pen_color=colors.RED)
    right_docs = draw_doc_chain(canvas, Point(3, -2), ['1', '2', '3'])
    canvas.new_arrow(src=tree['right'], dst=right_docs[0], pen_color=colors.RED)

    print(canvas.draw())
