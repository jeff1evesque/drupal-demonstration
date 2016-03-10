### Description: A virtual resource, which can be extended within other
###              modules, or manifests as follows:
###
###              File <| title == '/boot/grub2/grub.cfg' |> { mode => '600', }
###
### Note: the prefix 'virtual_resource::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class virtual_resource::file_grub_cfg {
    @file { '/boot/grub2/grub.cfg':
        ensure => file,
    }
}