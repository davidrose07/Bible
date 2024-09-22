import curses


class ListWindow:
    def __init__(self, win, title, item_tuples, width):
        """
        Initialize a list window for displaying selectable items within a curses window.

        :param win: The parent curses window to draw this list.
        :param title: The title of the list window.
        :param item_tuples: A list of tuples representing the items and their indexes.
        :param width: The desired width of the list window.
        """
        self.MAX_ITEMS = curses.LINES - 2     # Maximum items that can be displayed at once.

        self._win = win  # The curses window object where the list will be displayed.
        self._width = width  # The width of the window.
        self._title = title  # The title of the window.
        self._active = False  # Active state of the window.
        self._item_tuples = item_tuples  # Tuples of items to be displayed.
        self.init_color()
        self.select_first()  # Initialize the selection to the first item.

    def init_color(self):
        curses.start_color()
        curses.init_pair(2, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_YELLOW, curses.COLOR_BLACK)

    def set_active(self, is_active):
        """
        Set the active state of the window and redraw.

        :param is_active: Boolean indicating if the window should be active.
        """
        self._active = is_active
        self.draw()

    def get_selection_tuple(self):
        """
        Return the currently selected item tuple.

        :return: Tuple of the current selection.
        """
        return self._selected_tuple

    def set_selection_tuples(self, item_tuples):
        """
        Set the list of item tuples and update the selection if necessary.

        :param item_tuples: A list of item tuples to be displayed.
        """
        self._item_tuples = item_tuples
        if self._selected_tuple not in item_tuples:
            self.select_first()
        else:
            self.draw()

    def increment_selection(self, i):
        """
        Move the selection up or down by 'i' positions.

        :param i: Integer indicating the direction and magnitude of the selection movement.
        """
        new_index = self._selected_tuple[0] + i
        if new_index < 0 or new_index >= len(self._item_tuples):
            return

        self._selected_tuple = self._item_tuples[new_index]

        (bound_lower, bound_upper) = self._bounds

        # Determine if scrolling adjustments are needed.
        shift_up = bound_upper <= new_index < len(self._item_tuples)
        shift_down = 0 <= new_index < bound_lower
        shift = shift_down or shift_up

        if shift:
            self._bounds = (bound_lower + i, bound_upper + i)

        self.draw()

    def select_first(self):
        """
        Select the first item in the list and set the drawing bounds.
        """
        self._selected_tuple = self._item_tuples[0]
        self._bounds = (0, self.MAX_ITEMS)
        self.draw()

    def write_title(self):
        """
        Write the window title, centered and underlined.
        """
        self._win.addnstr(
            0, 0, self._title.center(self._width, " "), self._width, curses.A_UNDERLINE
        )

    def draw(self):
        """
        Redraw the list window, updating the display of items and the selection.
        """
        self._win.clear()
        self.write_title()

        # Display items within the bounds, highlighting the selected one.
        for (i, val) in self._item_tuples[self._bounds[0]: self._bounds[1]]:

            y = 1 + i - self._bounds[0]
            str_len = self._width - 2
            string = str(val).ljust(str_len)

            if i == self._selected_tuple[0]:
                self._win.addnstr(
                    y,
                    0,
                    ">{0}".format(string),
                    str_len + 1,
                    curses.A_STANDOUT if self._active else curses.color_pair(3) |curses.A_BOLD
                )
            else:
                self._win.addnstr(y, 1, string, str_len, curses.color_pair(2))

        self._win.refresh()
