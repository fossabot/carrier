FROM lifedjik/carrier:base
#   Copyright 2018-2019 getcarrier.io
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
LABEL author="artem_rozumenko@epam.com"
LABEL updated.by="ivan_krakhmaliuk@epam.com"

# Carrier
RUN set -x \
  && mkdir -p /opt/virtualenv/carrier \
  && virtualenv -p python3.6 /opt/virtualenv/carrier \
  && /opt/virtualenv/carrier/bin/pip3.6 install git+https://github.com/LifeDJIK/carrier.git@framework \
  && /opt/virtualenv/carrier/bin/python3.6 -c 'import pkg_resources; print("\n".join((ep.name for ep in pkg_resources.iter_entry_points("console_scripts") if ep.module_name.startswith("carrier"))))' \
  | xargs -n 1 bash -c 'update-alternatives --install /usr/bin/$0 $0 /opt/virtualenv/carrier/bin/$0 9999'
