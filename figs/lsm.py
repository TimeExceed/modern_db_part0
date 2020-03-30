from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *

SEPS_Y = [1, 3, 5]

def level2(canvas):
    canvas.new_text(
        anchor=ORIGIN,
        text='$L_2$',
        location=locations.EAST)
    canvas.new_triangle(
        center=Point(5, 0),
        width=4,
        height=0.8)

def level1(canvas):
    center_y = (SEPS_Y[0] + SEPS_Y[1]) / 2
    canvas.new_text(
        anchor=Point(0, center_y),
        text='$L_1$',
        location=locations.EAST)
    xs = [2, 5, 8]
    for x in xs:
        canvas.new_triangle(
            center=Point(x, center_y),
            width=2,
            height=0.8)
    for x0, x1 in zip(xs, xs[1:]):
        x = (x0 + x1) / 2
        canvas.new_line(
            src=Point(x, center_y + 0.7),
            dst=Point(x, center_y - 0.6),
            line_style=line_styles.DASHED)

def level0(canvas):
    y = (SEPS_Y[1] + SEPS_Y[2]) / 2
    canvas.new_text(
        anchor=Point(0, y),
        text='$L_0$',
        location=locations.EAST)
    canvas.new_triangle(
        center=Point(4.9, -0.3) + Point(0, y),
        width=0.4,
        height=0.1)
    canvas.new_triangle(
        center=Point(6.8, 0.0) + Point(0, y),
        width=0.9,
        height=0.3)
    canvas.new_triangle(
        center=Point(3.8, 0.57) + Point(0, y),
        width=1.2,
        height=0.15)
    canvas.new_triangle(
        center=Point(1.64, -0.09) + Point(0, y),
        width=0.48,
        height=0.31)
    canvas.new_triangle(
        center=Point(4.84, 0.01) + Point(0, y),
        width=0.64,
        height=0.15)
    canvas.new_triangle(
        center=Point(8.60, 0.26) + Point(0, y),
        width=1.37,
        height=0.34)
    canvas.new_triangle(
        center=Point(8.07, -0.29) + Point(0, y),
        width=1.28,
        height=0.46)

def mem(canvas):
    y = SEPS_Y[2] + 0.7

    active = canvas.new_triangle(
        center=Point(4.5, y),
        width=1,
        height=0.4)
    vs = active.get_skeleton().vertices()
    canvas.new_text(
        anchor=geo.centroid([vs[0], vs[2]]),
        text='\\scriptsize active memtable',
        location=locations.SOUTH)

    rect_width = 0.4
    rect_height = 0.4
    oplog = canvas.new_rectangle(
        center=Point(2, y),
        width=rect_width* 4,
        height=rect_height)
    canvas.new_arrow(
        src=oplog,
        dst=active,
        pen_color=colors.BLUE)
    vs = oplog.get_skeleton().vertices()
    xs = repeat(vs[0])
    xs = accumulate(xs, lambda x, _: x + Point(rect_width, 0))
    xs = islice(xs, 1, 4)
    for x in xs:
        canvas.new_line(
            src=x,
            dst=x + Point(0, -rect_height))
    canvas.new_text(
        anchor=geo.centroid([vs[2], vs[3]]),
        text='\\scriptsize oplog',
        location=locations.SOUTH)
    rightmost_oplog = geo.Rectangle(
        center=vs[1] + Point(-rect_width / 2, -rect_height / 2),
        width=rect_width,
        height=rect_height)

    write_pos = rightmost_oplog.center() + Point(0, 0.5)
    canvas.new_text(
        anchor=write_pos,
        text='\\scriptsize write',
        location=locations.NORTH,
        pen_color=colors.BLUE)
    canvas.new_arrow(
        src=write_pos,
        dst=rightmost_oplog.intersect_from_center(write_pos),
        pen_color=colors.BLUE)

    shadow = canvas.new_triangle(
        center=Point(7, y),
        width=1,
        height=0.4)
    vs = shadow.get_skeleton().vertices()
    canvas.new_text(
        anchor=geo.centroid([vs[0], vs[2]]),
        text='\\scriptsize shadowed memtable',
        location=locations.SOUTH)

    canvas.new_arrow(
        src=active,
        dst=shadow,
        pen_color=colors.BLUE,
        line_style=line_styles.DASHED)
    canvas.new_arrow(
        src=shadow,
        dst=Point(7, 4.5),
        pen_color=colors.BLUE,
        line_style=line_styles.DASHED)
    canvas.new_text(
        anchor=Point(7, 5),
        text='dump',
        location=locations.SOUTHEAST)

if __name__ == '__main__':
    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    for y in SEPS_Y:
        canvas.new_line(
            src=Point(0, y),
            dst=Point(10, y),
            line_style=line_styles.DASHED)
    for y in SEPS_Y[:2]:
        canvas.new_arrow(
            src=Point(5, y + 0.3),
            dst=Point(5, y - 0.3))
        canvas.new_text(
            anchor=Point(5, y),
            text='compact',
            location=locations.NORTHEAST)

    level2(canvas)
    level1(canvas)
    level0(canvas)
    mem(canvas)

    print(canvas.draw())
