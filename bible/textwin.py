import curses


class TextWindow:
    def __init__(self, win, width):
        """
        Initialize a new text display window within a curses window.

        :param win: The parent curses window in which the text window is embedded.
        :param width: The desired width of the text window.
        """
        
        # The parent window containing this text window
        self._outer_win = win
        self._outer_win.box()  # Draw a border around the outer window

        self._width = width  # Store the width of the text window

        # Create an inner window for displaying text, with padding to not overwrite the box border
        self._inner_win = self._outer_win.derwin(
            curses.LINES - 2, self._width - 2, 1, 1
        )
        self.init_color()

    def init_color(self):
        curses.start_color()
        curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)

    def update_text_title(self, title):
        """
        Update the title at the top of the text window.

        :param title: The title to display, centered at the top of the window.
        """
        self._outer_win.clear()  # Clear previous content to update the title
        self._outer_win.box()  # Re-draw the box around the window

        # Center the title within the width of the window
        title_centered = title.center(self._width, " ")
        start_pad = len(title_centered) - len(title_centered.lstrip(" "))

        self._outer_win.addstr(0, start_pad, title, curses.color_pair(2))
        self._outer_win.refresh()  # Refresh the window to display the new title

    def update_text(self, text_tuples):
        """Update the text content of the inner window."""
        self._inner_win.clear()  # Clear the inner window to prepare for new text
        y = 0
        for line, is_red in text_tuples:
            color_pair = curses.color_pair(3) if is_red else curses.color_pair(0)
            try:
                self._inner_win.addstr(y, 0, line, color_pair)
            except curses.error as e:
                # Handle cases where adding text might exceed the window size
                pass
            y += 1
            if y >= curses.LINES - 2:  # Prevent writing outside the window
                break
        self._inner_win.refresh()  # Refresh the inner window to update the display



    """ def update_text(self, text):
        '''
        Update the text content of the inner window.

        :param text: The text content to display in the window.
        '''
        self._inner_win.clear()  # Clear the inner window to prepare for new text
        self._inner_win.addstr(text)  # Add the new text
        self._inner_win.refresh()  # Refresh the inner window to update the display """
   
    

