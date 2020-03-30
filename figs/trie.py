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
        ['',
         ['a',
          ['al',
           ['ala',
            ['alan']],
           ['ali',
            ['alic',
             ['alice']]]]]],
        root=ORIGIN,
        h_sep=2,
        v_sep=1)

    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    for k, v in tree.copy().items():
        if k == '':
            continue
        if k == 'alan':
            tree['alan'] = canvas.new_bullet(center=v, brush_color=colors.RED)
        elif k == 'alice':
            tree['alice'] = canvas.new_bullet(center=v, brush_color=colors.RED)
        else:
            tree[k] = canvas.new_bullet(center=v)

    e = canvas.new_line(src=tree[''], dst=tree['a'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='a',
        location=locations.WEST)
    e = canvas.new_line(src=tree['a'], dst=tree['al'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='l',
        location=locations.WEST)
    e = canvas.new_line(src=tree['al'], dst=tree['ala'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='a',
        location=locations.NORTHWEST)
    e = canvas.new_line(src=tree['ala'], dst=tree['alan'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='n',
        location=locations.WEST)
    e = canvas.new_line(src=tree['al'], dst=tree['ali'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='i',
        location=locations.NORTHEAST)
    e = canvas.new_line(src=tree['ali'], dst=tree['alic'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='c',
        location=locations.EAST)
    e = canvas.new_line(src=tree['alic'], dst=tree['alice'])
    canvas.new_text(
        anchor=e.get_skeleton().center(),
        text='e',
        location=locations.EAST)

    ALICE_START_POINT = Point(3, -3.5)
    alice_docs = draw_doc_chain(canvas, ALICE_START_POINT, ['3', '4'])
    canvas.new_arrow(
        src=tree['alice'],
        dst=alice_docs[0],
        pen_color=colors.RED)

    ALAN_START_POINT = Point(3, -1.5)
    alan_docs = draw_doc_chain(canvas, ALAN_START_POINT, ['1', '2', '3'])
    canvas.new_arrow(
        src=tree['alan'],
        dst=alan_docs[0],
        pen_color=colors.RED)

    print(canvas.draw())
