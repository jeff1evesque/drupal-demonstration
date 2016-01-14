#!/usr/bin/python

## @core_update_2.py: this file performs drupal core update, and is generally
#                     preferred over the 'core_update.py', which overwrites any
#                     customized '.htaccess', or 'robots.txt'.
import subprocess
import os.path

## Variables
htaccess        = '/vagrant/webroot/.htaccess'
htaccess_backup = '/vagrant/webroot/_htaccess'
robots          = '/vagrant/webroot/robots.txt'
robots_backup   = '/vagrant/webroot/_robots.txt'

## Backup '.htaccess', 'robots.txt'
if os.path.isfile(htaccess):
  subprocess.check_call(['mv', htaccess, htaccess_backup])
if os.path.isfile(robots):
  subprocess.check_call(['mv', robots, robots_backup])

## Core Update: update to latest stable core
subprocess.check_call(['drush', '-y', 'rf'])
subprocess.check_call(['drush', 'up', '-y', 'drupal'])

## Restore '.htaccess', 'robots.txt'
if os.path.isfile(htaccess_backup):
  subprocess.check_call(['mv', htaccess_backup, htaccess])
if os.path.isfile(robots_backup):
  subprocess.check_call(['mv', robots_backup, robots])