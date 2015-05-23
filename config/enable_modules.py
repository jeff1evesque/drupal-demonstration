#!/usr/bin/python

## @enable_modules.py
#  This file enables both contrib, and custom drupal modules.
#
#  Note: to review current enabled modules, using drush:
#
#      $ drush pm-list
#      $ drush pm-list > module_list.txt
#
#  Note: to download, and enable the corresponding xx module:
#
#      $ subprocess.check_call(['drush', 'en', '-y', 'xx'])
#
#  Note: to enable xx module:
#
$      $ subprocess.check_call(['drush', 'pm-enable', '-y', 'xx'])
import subprocess

## Contrib Modules: download and enable

## Custom Modules: enable
