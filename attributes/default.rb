# can be 'init' or 'runit'
default['smartmontools']['init_style'] = 'init'
default['smartmontools']['email_addresses'] = ['root']
default['smartmontools']['smartd_opts'] = ['--interval=1800']

default['smartmontools']['device_opts'] = ['-H']
if platform_family == 'debian'
  default['smartmontools']['device_opts'] << '-M exec /usr/share/smartmontools/smartd-runner'
end

# Detect block devices to minitor from OHAI
# You might want to check this to ensure you have the correct devices
default['smartmontools']['devices'] = node['block_device'].inject([]) do |devices, (name, info)|
  if (name =~ /sd[a-z]/) && info['vendor'] == 'ATA'
    # Exclude known devices not support SMART
    next devices if ['VBOX HARDDISK'].include? info['model']
    devices << [name, nil]
  end
  devices
end
