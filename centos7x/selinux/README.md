# Selinux

The selinux policy modules are [required](https://github.com/mitchellh/vagrant/issues/6970)
 by this project, since vagrant is implemented. Specifically, all files, and
 sub-directories contained within the mounted `/vagrant` directory, are managed
 by vagrant. This means, the selinux permission cannot be modified from either
 the host, or guest vagrant virtual machine.  Therefore, selinux policy modules are
 [enabled](https://github.com/mitchellh/vagrant/issues/6970#issuecomment-180546269),
 as a workaround alternative.

**Note:** although there isn't a nicer way to define system context, for
 specific directories, within the shared `/vagrant` directory, ownership, and
 permission can still be defined, by the following stanza, within the
 corresponding `Vagrantfile`:

```
...
  ## set general project ownership, and permission
  config.vm.synced_folder './', '/vagrant',
    owner: 'provisioner',
    group: 'provisioner',
    mount_options: ['dmode=755', 'fmode=664']
...
```