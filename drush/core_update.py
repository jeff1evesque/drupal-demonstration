#!/usr/bin/python

## @core_update.py: this file performs drupal core update, and generally not
#                   preferred over the 'core_update_2.py', since it overwrites any
#                   customized '.htaccess', or 'robots.txt'.
import subprocess

## Core Update: update to latest stable core
subprocess.check_call(['drush', '-y', 'rf'])
subprocess.check_call(['drush', 'up', '-y', 'drupal'])