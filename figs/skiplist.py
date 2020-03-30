from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.tikz.colors as colors
import fathom.tikz.line_styles as line_styles
import fathom.tikz.locations as locations
from itertools import *
from skiplist_lib import draw_doc_chain

if __name__ == '__main__':
    canvas = Canvas(
        preamble=['\\usepackage{amsmath}'],
        leading_instructions=['\\footnotesize'])

    draw_doc_chain(
        canvas,
        ORIGIN,
        ['1', '2', '3', '4', '5', '6', '7', '8', '9'])

    print(canvas.draw())
