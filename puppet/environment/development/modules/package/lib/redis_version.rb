# local variables
redis_version = '2.8'

Facter.add(:redis_version) do
    confine :osfamily => 'RedHat'
    setcode do
        Facter::Core::Execution.execute("/usr/bin/yum list redis\* | /usr/bin/grep #{$redis_version} | /usr/bin/awk '{print $2}'")
    end
end
