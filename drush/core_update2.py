#!/usr/bin/python

## @core_update.py
#  This file performs drupal core update
import subprocess

## Backup '.htaccess', 'robots.txt'
subprocess.check_call(['mv', '/vagrant/.htaccess', '/vagrant/_htaccess'])
subprocess.check_call(['mv', '/vagrant/robots.txt', '/vagrant/_robots.txt'])

## Core Update: update to latest stable core
subprocess.check_call(['drush', '-y', 'rf'])
subprocess.check_call(['drush', 'up', '-y', 'drupal'])

## Restore '.htaccess', 'robots.txt'
subprocess.check_call(['mv', '/vagrant/_htaccess', '/vagrant/.htaccess'])
subprocess.check_call(['mv', '/vagrant/_robots.txt', '/vagrant/.robots.txt'])