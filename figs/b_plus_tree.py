from fathom import Point, ORIGIN
from fathom.tikz import Canvas
import fathom.geometry as geo
import fathom.layout as layout
import fathom.tikz.colors as colors
from itertools import *

BRANCH = 3

class Inner:
    SEG_WIDTH = 0.5
    LEFTMOST_WIDTH = 0.3
    KEY_HEIGHT = 0.5
    PTR_HEIGHT = 0.3

    def __init__(self, center, texts):
        self._texts = texts
        self._center = center
        self._width = (BRANCH - 1) * Inner.SEG_WIDTH + Inner.LEFTMOST_WIDTH
        self._height = Inner.KEY_HEIGHT + Inner.PTR_HEIGHT
        self._ptrs = None
        self._line_color = None

    def set_line_color(self, color):
        self._line_color = color

    def upleft(self):
        return self._center + Point(-self._width / 2, self._height / 2)

    def pointers(self, canvas):
        if self._ptrs is not None:
            return self._ptrs
        upleft_corner = self._center + \
            Point(-self._width / 2, self._height / 2)
        ptrs = repeat(upleft_corner +
                      Point(Inner.LEFTMOST_WIDTH + Inner.SEG_WIDTH / 2,
                            - Inner.KEY_HEIGHT - Inner.PTR_HEIGHT / 2))
        ptrs = accumulate(ptrs, lambda x, _: x + Point(Inner.SEG_WIDTH, 0))
        ptrs = islice(ptrs, len(self._texts))
        ptrs = [canvas.new_bullet(center=p) for p in ptrs]
        p = canvas.new_bullet(
            center=upleft_corner +
            Point(Inner.LEFTMOST_WIDTH/2, -
                  Inner.KEY_HEIGHT - Inner.PTR_HEIGHT / 2))
        ptrs.insert(0, p)
        self._ptrs = ptrs
        return self._ptrs

    def draw(self, canvas):
        upleft = self.upleft()
        self._draw_upleft_corner(canvas, upleft)
        self._draw_lines(canvas, upleft)
        self._draw_texts(canvas, upleft)
        self._draw_ptr_bullets(canvas)

    def _draw_lines(self, canvas, upleft):
        line_color = self._line_color if self._line_color is not None else colors.BLACK
        canvas.new_rectangle(
            center=self._center,
            width=self._width,
            height=self._height,
            pen_color=line_color)
        canvas.new_line(
            src=upleft + Point(0, -Inner.KEY_HEIGHT),
            dst=upleft + Point(self._width, -Inner.KEY_HEIGHT),
            pen_color=line_color)

        vs = repeat(upleft + Point(Inner.LEFTMOST_WIDTH, 0))
        vs = accumulate(vs, lambda x, _: x + Point(Inner.SEG_WIDTH, 0))
        vs = islice(vs, BRANCH - 1)
        for x in vs:
            canvas.new_line(src=x, dst=x + Point(0, -self._height))

    def _draw_texts(self, canvas, upleft):
        start = upleft + \
            Point(Inner.LEFTMOST_WIDTH + Inner.SEG_WIDTH / 2,
                  - Inner.KEY_HEIGHT / 2)
        vs = repeat(start)
        vs = accumulate(vs, lambda x, _: x + Point(Inner.SEG_WIDTH, 0))
        for p, t in zip(vs, self._texts):
            canvas.new_text(anchor=p, text=t)

    def _draw_ptr_bullets(self, canvas):
        self.pointers(canvas)

    def _draw_upleft_corner(self, canvas, upleft):
        center = upleft + \
            Point(Inner.LEFTMOST_WIDTH / 2, -Inner.KEY_HEIGHT / 2)
        canvas.new_rectangle(
            center=center,
            width=Inner.LEFTMOST_WIDTH,
            height=Inner.KEY_HEIGHT,
            pen_color=colors.INVISIBLE,
            brush_color=colors.GRAY)

class Leaf:
    RIGHTMOST_WIDTH = 0.3
    SEG_WIDTH = 0.5
    KEY_HEIGHT = 0.5
    PTR_HEIGHT = 0.3

    def __init__(self, center, texts):
        self._texts = texts
        self._center = center
        self._width = (BRANCH - 1) * Leaf.SEG_WIDTH + Leaf.RIGHTMOST_WIDTH
        self._height = Leaf.KEY_HEIGHT + Leaf.PTR_HEIGHT
        self._ptrs = None
        self._tail = None
        self._line_color = None

    def set_line_color(self, color):
        self._line_color = color

    def upleft(self):
        return self._center + Point(-self._width / 2, self._height / 2)

    def leftmost(self):
        return self._center + Point(-self._width/2, 0)

    def text_points(self):
        start = self.upleft() + \
            Point(Leaf.SEG_WIDTH / 2, -Leaf.KEY_HEIGHT / 2)
        vs = repeat(start)
        vs = accumulate(vs, lambda x, _: x + Point(Leaf.SEG_WIDTH, 0))
        vs = islice(vs, BRANCH - 1)
        return list(vs)

    def draw(self, canvas):
        upleft = self.upleft()
        self._draw_lines(canvas, upleft)
        self._draw_texts(canvas, upleft)
        self.pointers(canvas)
        self.tail(canvas)

    def _draw_lines(self, canvas, upleft):
        color = self._line_color if self._line_color is not None else colors.BLACK
        canvas.new_rectangle(
            center=self._center,
            width=self._width,
            height=self._height,
            pen_color=color)
        canvas.new_line(
            src=upleft + Point(0, -Leaf.KEY_HEIGHT),
            dst=upleft + Point(self._width - Leaf.RIGHTMOST_WIDTH, -Leaf.KEY_HEIGHT),
            pen_color=color)
        vs = repeat(upleft)
        vs = accumulate(vs, lambda x, _: x + Point(Leaf.SEG_WIDTH, 0))
        vs = islice(vs, 1, BRANCH)
        for p in vs:
            canvas.new_line(
                src=p, dst=p + Point(0, -self._height), pen_color=color)

    def _draw_texts(self, canvas, upleft):
        for p, t in zip(self.text_points(), self._texts):
            canvas.new_text(anchor=p, text=t)

    def pointers(self, canvas):
        if self._ptrs is not None:
            return self._ptrs
        upleft = self._center + Point(-self._width / 2, self._height / 2)
        start = upleft + Point(Leaf.SEG_WIDTH/2,
                               -Leaf.KEY_HEIGHT - Leaf.PTR_HEIGHT / 2)
        vs = repeat(start)
        vs = accumulate(vs, lambda x, _: x + Point(Leaf.SEG_WIDTH, 0))
        vs = islice(vs, BRANCH - 1)
        self._ptrs = [canvas.new_bullet(center=x) for x in vs]
        return self._ptrs

    def tail(self, canvas):
        if self._tail is not None:
            return self._tail
        p = self._center + Point(self._width / 2 - Leaf.RIGHTMOST_WIDTH / 2, 0)
        self._tail = canvas.new_bullet(center=p)
        return self._tail

def tree():
    s = [
        'root',
        [
            'left',
            ['left_left'],
            ['left_mid'],
            ['left_right'],
        ],
        [
            'right',
            ['right_left'],
            ['right_right'],
        ]
    ]
    t = layout.tree(s, root=ORIGIN, h_sep=2, v_sep=2)
    t['root'] = Inner(t['root'], ['5'])
    t['left'] = Inner(t['left'], ['2', '4'])
    t['right'] = Inner(t['right'], ['7'])
    t['left_left'] = Leaf(t['left_left'], ['0', '1'])
    t['left_mid'] = Leaf(t['left_mid'], ['2'])
    t['left_right'] = Leaf(t['left_right'], ['4'])
    t['right_left'] = Leaf(t['right_left'], ['5', '6'])
    t['right_right'] = Leaf(t['right_right'], ['7', '8'])
    return t

def link_leaves(canvas, leaves):
    for s, t in zip(leaves, leaves[1:]):
        canvas.new_arrow(
            src=s.tail(canvas),
            dst=t.leftmost())
