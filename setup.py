#!/usr/bin/python3
# coding=utf-8
# pylint: disable=I0011,C0103

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
    Carrier setup script
"""

import pkgutil
import importlib

from setuptools import setup, find_packages


with open("README.md") as f:
    long_description = f.read()


with open("requirements.txt") as f:
    required_dependencies = f.read().splitlines()


console_scripts = ["carrier = carrier.main:main"]
legacy_scripts = "carrier.commands.legacy"
legacy_scripts_path = importlib.import_module(legacy_scripts).__path__
for _, name, _ in pkgutil.iter_modules(legacy_scripts_path):
    console_scripts.append("{name} = {module}.{name}:main".format(
        module=legacy_scripts, name=name
    ))


setup(
    name="carrier",
    version="0.0.1",
    license="Apache License 2.0",
    author="Carrier team",
    author_email="artem_rozumenko@epam.com",
    url="https://github.com/carrier-io",
    description="Carrier | Continuous test execution platform",
    long_description=long_description,
    packages=find_packages(),
    include_package_data=True,
    install_requires=required_dependencies,
    entry_points={"console_scripts": console_scripts},
)
