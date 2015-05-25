#!/usr/bin/python

## @enable_modules.py
#  This file enables various drupal configurations via drush.
import subprocess

## Enable Clean URLs
subprocess.check_call(['drush', 'vset', 'clean_url', '1'])
