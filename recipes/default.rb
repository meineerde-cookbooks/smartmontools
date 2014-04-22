package 'smartmontools'

template '/etc/smartd.conf' do
  owner 'root'
  group 'root'
  mode '0644'

  variables lazy do
    addresses = Array(default['smartmontools']['email_addresses'])
    if addresses.empty?
      { :email_addresses => '' }
    else
      { :email_addresses => "-m #{addresses.join(',')}" }
    end
  end
  source 'smartd.conf.erb'
end

case node['smartmontools']['init_style']
when 'init'
  template '/etc/default/smartmontools' do
    owner 'root'
    group 'root'
    mode '0644'

    source 'smartmontools_default.erb'
    notifies :reload, 'service[smartmontools]'
  end

  service 'smartd' do
    action [:stop, :disable]
  end

  service 'smartmontools' do
    if node['smartmontools']['devices'].length > 0
      action [:enable, :start]
      subscribes :reload, 'template[/etc/smartd.conf]'
    else
      Chef::Log.info 'Disabling smartmontools as no checked device is configured.'
      action [:stop, :disable]
    end
  end
when 'runit'
  include_recipe 'runit'

  # Disable default init service
  %w[smartmontools smartd].each do |daemon|
    service "#{daemon}_init" do
      service_name daemon
      # Find a "normal" daemonized smartd process.
      # runit processes are run as children of runsv
      status_command '/usr/bin/pgrep --parent 1 -f \'^/usr/sbin/smartd(\s+|$)\''
      action [:stop, :disable]
      only_if { File.exist?("/etc/init.d/#{daemon}") }
    end
  end

  runit_service 'smartmontools' do
    default_logger true
    if node['smartmontools']['devices'].length > 0
      action [:enable, :start]
      subscribes :usr1, 'template[/etc/smartd.conf]'
    else
      Chef::Log.info 'Disabling smartmontools as no checked device is configured.'
      action [:stop, :disable]
    end
  end
else
  fail "Unknown init style for smartmontools. Please fix the value at node['smartmontools']['init_style']"
end
