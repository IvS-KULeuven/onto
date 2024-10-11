
import logging
import datetime
import time

class DeltaTimeFormatter(logging.Formatter):
    def format(self, record):
        record.delta = "%5.1fs" % (record.relativeCreated / 1000)
        return super().format(record)


LOGFORMAT = "%(delta)s %(levelname)-8s %(message)s"

handler = logging.StreamHandler()
fmt = DeltaTimeFormatter(LOGFORMAT)
handler.setFormatter(fmt)

logging.getLogger().addHandler(handler)
LOGGER = logging.getLogger("Onto")


def setLevel(level):
    LOGGER.setLevel(level)

def info(msg):
    LOGGER.info(msg)

def debug(msg):
    LOGGER.debug(msg)

def error(msg):
    LOGGER.error(msg)

