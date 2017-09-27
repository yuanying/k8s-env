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
from fabric.colors import yellow
from fabric.contrib import files

from lib import helpers

@task
def parted():
    try:
        for device in env.devices[env.host]:
            path  = device['path']
            with settings(warn_only=True):
                result = sudo(
                    "parted {path} mklabel gpt".format(path=path)
                )
            if not result.failed:
                sudo(
                    "parted {path} "
                    "-s mkpart untitled ext4 0G 100% "
                    "-s p".format(path=path)
                )
    except KeyError as e:
        pass

@task
def format():
    try:
        for device in env.devices[env.host]:
            label = device['name']
            path  = device['path']
            with settings(warn_only=True):
                result = sudo(
                    "mkfs.xfs -i size=512 {path} -L {label}".format(
                        path=path,
                        label=label,
                    )
                )
            if result.failed:
                print(yellow("Device is already formated: {}".format(device)))
    except KeyError as e:
        pass

@task(default=True)
def mount():
    try:
        for device in env.devices[env.host]:
            label = device['name']
            mountpath = os.path.join("/var/lib/heketi", label)
            unitname = "-".join(mountpath.split("/")[1:])
            sudo(
                "mkdir -p {mountpath}".format(
                    mountpath=mountpath,
                )
            )
            source = "/dev/disk/by-label/{label}".format(label=label)
            files.upload_template(
                'mount.mount',
                '/etc/systemd/system/{}.mount'.format(unitname),
                use_sudo=True,
                backup=False,
                template_dir=os.path.join(
                    helpers.__fabric_lib_dir, 'templates'
                ),
                context={
                    'source': source,
                    'dest': mountpath,
                },
                use_jinja=True,
            )
            files.upload_template(
                'mount.automount',
                '/etc/systemd/system/{}.automount'.format(unitname),
                use_sudo=True,
                backup=False,
                template_dir=os.path.join(
                    helpers.__fabric_lib_dir, 'templates'
                ),
                context={
                    'source': source,
                    'dest': mountpath,
                },
                use_jinja=True,
            )
            sudo(
                "systemctl daemon-reload && "
                "systemctl enable {unitname}.automount && "
                "systemctl restart {unitname}.automount".format(
                    unitname=unitname,
                )
            )
    except KeyError as e:
        pass


@task
def umount():
    try:
        for device in env.devices[env.host]:
            basename = os.path.basename(device)
            mountpath = os.path.join("/var/lib/heketi", basename)
            unitname = "-".join(mountpath.split("/")[1:])
            sudo(
                "systemctl stop {unitname}.automount && "
                "systemctl disable {unitname}.automount && "
                "systemctl stop {unitname}.mount && "
                "systemctl disable {unitname}.mount".format(
                    unitname=unitname,
                )
            )
            sudo(
                "rm -rf '/etc/systemd/system/{unitname}.*'".format(
                    unitname=unitname,
                )
            )
    except KeyError as e:
        pass
