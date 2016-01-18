#!/usr/bin/python

## @core_update.py: this file performs drupal core update, and is generally
#                   preferred over the 'core_update.py', which overwrites any
#                   customized '.htaccess', or 'robots.txt'.
import subprocess
import os.path

## Variables
webroot         = '/vagrant/webroot/'
htaccess        = webroot + '.htaccess'
htaccess_backup = webroot + '_htaccess'
robots          = webroot + 'robots.txt'
robots_backup   = webroot + '_robots.txt'

## Backup '.htaccess', 'robots.txt'
if os.path.isfile(htaccess):
  subprocess.check_call(['mv', htaccess, htaccess_backup])
if os.path.isfile(robots):
  subprocess.check_call(['mv', robots, robots_backup])

## Core Update: update to latest stable core
subprocess.check_call(['drush', '-y', 'rf', '-r', webroot])
subprocess.check_call(['drush', 'up', 'drupal', '-y', '-r', webroot])

## Restore '.htaccess', 'robots.txt'
if os.path.isfile(htaccess_backup):
  subprocess.check_call(['mv', htaccess_backup, htaccess])
if os.path.isfile(robots_backup):
  subprocess.check_call(['mv', robots_backup, robots])