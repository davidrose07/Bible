import logging
from logging.handlers import RotatingFileHandler
import os

CURRENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOG_FILE = os.path.join(CURRENT_DIR, "bible", "logs", "exception.log")


def get_logger(name: str = __name__) -> logging.Logger:
    """
    Return a configured logger that writes to a rotating file.

    Ensures that the logger is configured only once per name,
    even when imported from multiple modules.

    :param name: Logger name, typically use __name__
    :return: Configured logger instance
    """
    logger = logging.getLogger(name)

    if not logger.handlers:
        logger.setLevel(logging.DEBUG)

        handler = RotatingFileHandler(LOG_FILE, maxBytes=10240, backupCount=5)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)

        logger.addHandler(handler)

    return logger
