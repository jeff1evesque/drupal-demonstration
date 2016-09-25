# local variables
redis_version = '2.8'

# define facter
Facter.add(:redis_version) do
  confine :osfamily => 'RedHat'
  setcode do
    Facter::Core::Execution.exec("yum list -q redis\*-#{redis_version}\* | tail -n+2")
  end
end
