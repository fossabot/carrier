#!/usr/bin/python3
# coding=utf-8

import logging


def main():
    """ Main """
    # Setup logging
    logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)8s - %(message)s', datefmt='%Y.%m.%d %H:%M:%S')
    logging.info("Welcome to carrier")
