#!/usr/bin/python
# -*- coding: utf-8 -*-

import os.path
import pathlib
import sys
import yaml

from jinja2 import Environment, FileSystemLoader


ROOT_PATH = os.path.join(os.path.dirname(__file__), '..')
TARGET_PATH = os.path.join(ROOT_PATH, '..', 'configs')

def main(argv):
    try:
        config_file = argv[1]
    except IndexError as e:
        config_file = os.path.join(ROOT_PATH, 'examples', 'config.yaml')

    with open(config_file) as io:
        config_file = yaml.load(io)

    env = Environment(
        loader=FileSystemLoader(os.path.join(ROOT_PATH, 'templates'),
        encoding='utf8'),
    )

    for t in env.list_templates():
        try:
            template = env.get_template(t)
            content = template.render(config_file)
            target_dir = os.path.join(TARGET_PATH, os.path.dirname(t))
            target_file = os.path.join(TARGET_PATH, t)
            print(target_dir)
            print(target_file)
            pathlib.Path(target_dir).mkdir(parents=True, exist_ok=True)
            with open(target_file, 'w') as io:
                io.write(content)
        except UnicodeDecodeError as e:
            print("Load template error: %s" % t)

if __name__ == '__main__':
    main(sys.argv)
