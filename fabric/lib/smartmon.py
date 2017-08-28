#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import os

from fabric.api import *
from fabric.contrib import files

from lib import helpers


@task(default=True)
def install():
    files.upload_template(
        'node-exporter-smartmon.service',
        '/etc/systemd/system/node-exporter-smartmon.service',
        use_sudo=True,
        backup=False,
        template_dir=os.path.join(
            helpers.__fabric_lib_dir, 'templates'
        ),
        context={
            'docker': env['docker']['path'],
        },
        use_jinja=True,
    )
    files.upload_template(
        'node-exporter-smartmon.timer',
        '/etc/systemd/system/node-exporter-smartmon.timer',
        use_sudo=True,
        backup=False,
        template_dir=os.path.join(
            helpers.__fabric_lib_dir, 'templates'
        ),
        use_jinja=True,
    )
    sudo("systemctl daemon-reload")
    sudo("systemctl enable node-exporter-smartmon")
    sudo("systemctl enable node-exporter-smartmon.timer")
    sudo("systemctl restart node-exporter-smartmon")
    sudo("systemctl restart node-exporter-smartmon.timer")
