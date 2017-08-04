# local variables
redis_version = '\*.el'

# define facter
Facter.add(:redis_version) do
  confine :osfamily => 'RedHat'
  setcode do
    Facter::Core::Execution.exec("yum list redis\*-#{redis_version}\* | grep 'redis.x86_64' | awk '{print $2}'")
  end
end
