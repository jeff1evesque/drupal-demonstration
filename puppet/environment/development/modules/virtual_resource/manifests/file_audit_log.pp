### Description: A virtual resource, which can be extended within other
###              modules, or manifests as follows:
###
###              File <| title == '/var/log/audit/audit.log' |> { mode => '600', }
###
### Note: the prefix 'virtual_resource::', corresponds to a puppet convention:
###
###       https://github.com/jeff1evesque/machine-learning/issues/2349
###
class virtual_resource::file_audit_log {
    @file { '/var/log/audit/audit.log':
        ensure => file,
    }
}