Facter.add(:redis_version) do
    confine :osfamily => 'RedHat'
    setcode do
        Facter::Core::Execution.execute("/usr/bin/yum list redis\* | /usr/bin/grep 2.8 | /usr/bin/awk '{print $2}'")
    end
end
