#!/usr/bin/env python3
import logging
from subprocess import *
from string import printable
import re
NAME = "collections"

MODULES = (
    ["rtqueue"],
    ["avltree"],
    ["fingertree"]
)

TEST_ARGS = ["-O2"]
TEST_DIR  = "tests"

def setup_logger(logger):
    logger.setLevel(logging.INFO)

    sh = logging.StreamHandler()

    def decorate_emit(fn):
    # add methods we need to the class
        def new(*args):
            levelno = args[0].levelno
            if(levelno >= logging.CRITICAL):
                color = '\x1b[31;1m'
            elif(levelno >= logging.ERROR):
                color = '\x1b[31;1m'
            elif(levelno >= logging.WARNING):
                color = '\x1b[33;1m'
            elif(levelno >= logging.INFO):
                color = '\x1b[32;1m'
            elif(levelno >= logging.DEBUG):
                color = '\x1b[35;1m'
            else:
                color = '\x1b[0m'
            # add colored *** in the beginning of the message
            args[0].msg = "{0}***\x1b[0m {1}".format(color, args[0].msg)

            # new feature i like: bolder each args of message 
            args[0].args = tuple('\x1b[1m' + arg + '\x1b[0m' for arg in args[0].args)
            return fn(*args)
        return new
    sh.emit = decorate_emit(sh.emit)
    logger.addHandler(sh)

if __name__ == "__main__":
    log = logging.getLogger("test")
    setup_logger(log)

    log.info("Detecting Koka Version")
    version = run(["koka", "--version"], stdout=PIPE).stdout.split()[1].strip(b",")
    log.info("Version {}".format(version.decode()))
    log.info("Executing Test Cases")
    success = True
    for i in MODULES:
        test = TEST_DIR + "/" + "/".join(i[:-2]) + "test-" + i[-1]
        src  = test + ".kk"
        log.info("RUNNING {}".format(src))
        res = run(["koka", *TEST_ARGS, "-e", src, "-v0"], stdout=PIPE, stderr=PIPE)
        out = res.stdout.strip()
        if b"success" not in out or res.returncode != 0:
            success = False
            log.error("Failed with code: {}\noutput:\n{}\nstderr:\n {}".format(res.returncode, res.stdout.strip(), res.stderr.strip()))
        else:
            log.info("-> SUCCESS")
    
    if not success:
        exit(1)
