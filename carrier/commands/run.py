#!/usr/bin/python3
# coding=utf-8

#   Copyright 2019 getcarrier.io
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
    Command: run
"""

from carrier.tools import log
from carrier.data import constants
from carrier.models.command import CommandModel


class Command(CommandModel):
    """ Runs tests defined in config file """

    @staticmethod
    def get_name():
        """ Command name """
        return "run"

    @staticmethod
    def get_help():
        """ Command help message (description) """
        return "run tests according to config"

    def __init__(self, argparser):
        """ Initialize command instance, add arguments """
        argparser.add_argument(
            "-s", "--suite",
            help="test suite to run",
            type=str, required=True
        )
        argparser.add_argument(
            "-c", "--config-file",
            help="path to config file",
            type=str, default=constants.DEFAULT_CONFIG_PATH
        )
        argparser.add_argument(
            "-e", "--config-variable",
            help="name of environment variable with config",
            type=str, default=constants.DEFAULT_CONFIG_ENV_KEY
        )

    def execute(self, args):
        """ Run the command """
        log.info("Running tests")
