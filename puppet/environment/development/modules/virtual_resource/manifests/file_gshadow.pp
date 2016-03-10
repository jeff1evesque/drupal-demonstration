### Description: A virtual resource, which can be extended within other
###              modules, or manifests as follows:
###
###              File <| title == '/etc/gshadow' |> { mode => '000', }
###
### Note: the prefix 'medium::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class virtual_resource::file_gshadow {
    @file { '/etc/gshadow':
        ensure => file,
    }
}