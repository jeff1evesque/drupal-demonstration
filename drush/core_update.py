#!/usr/bin/python

## @core_update.py
#  This file performs drupal core update
import subprocess

## Core Update: update to latest stable core
subprocess.check_call(['drush', '-y', 'rf'])
subprocess.check_call(['drush', 'up', '-y', 'drupal'])