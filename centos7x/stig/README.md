# Centos 7x Stig

Stigging for this Centos 7x environment, follows guidelines determined by
 [IASE](http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx).
 Specifically, the files contained in this directory, have been downloaded
 from the following source:

- http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx

The corresponding stigging logic, will be found in the following directories,
 within this respository:

- `puppet/environment/development/manifests/stig.pp`
- `puppet/environment/development/modules/high/`
- `puppet/environment/development/modules/medium/`
- `puppet/environment/development/modules/low/`

A complimentary `status.md`, within this directory, will identify which stig
 items have been completed with respect to the guidelines, determined by the
 downloaded [IASE](http://iase.disa.mil/stigs/os/unix-linux/Pages/red-hat.aspx) files.