#!/usr/bin/python

## @enable_modules.py
#  This file enables drupal themes, and defines a default theme.
#
#  Note: to review current themes
#
#      $ drush pm-list --type=theme
#      $ drush pm-list --type=theme --status=enabled
#
#  Note: to enable xx theme:
#
#      $ subprocess.check_call(['drush', 'en', '-y', 'xx'])
#
#  Note: to set default theme to xx:
#
#      $ subprocess.check_call(['drush', 'vset', 'theme_default', '-y', 'xx'])
import subprocess

## Enable themes

## Set default theme