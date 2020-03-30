from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *
import b_plus_tree

if __name__ == '__main__':
    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])
    tree = b_plus_tree.tree()

    for p in tree.values():
        p.draw(canvas)

    canvas.new_arrow(
        src=tree['root'].pointers(canvas)[0],
        dst=tree['left'].upleft())
    canvas.new_arrow(
        src=tree['root'].pointers(canvas)[1],
        dst=tree['right'].upleft())
    canvas.new_arrow(
        src=tree['left'].pointers(canvas)[0],
        dst=tree['left_left'].upleft())
    canvas.new_arrow(
        src=tree['left'].pointers(canvas)[1],
        dst=tree['left_mid'].upleft())
    canvas.new_arrow(
        src=tree['left'].pointers(canvas)[2],
        dst=tree['left_right'].upleft())
    canvas.new_arrow(
        src=tree['right'].pointers(canvas)[0],
        dst=tree['right_left'].upleft())
    canvas.new_arrow(
        src=tree['right'].pointers(canvas)[1],
        dst=tree['right_right'].upleft())

    b_plus_tree.link_leaves(
        canvas,
        [tree['left_left'],
         tree['left_mid'],
         tree['left_right'],
         tree['right_left'],
         tree['right_right']])


    print(canvas.draw())
