import logging
from logging.handlers import RotatingFileHandler
import os

CURRENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class Log(logging.Logger):
    def __init__(self, name=__name__, log_file=f'{CURRENT_DIR}/exception.log'):
        super().__init__(name)
        self.addHandler(self._get_file_handler(log_file))
    
    def _get_file_handler(self, log_file):
        fh = RotatingFileHandler(log_file, maxBytes=10240, backupCount=5)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        fh.setFormatter(formatter)
        return fh
    

    