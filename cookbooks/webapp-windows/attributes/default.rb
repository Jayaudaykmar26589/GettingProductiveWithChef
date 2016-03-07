default['sql_server']['accept_eula'] = true
default['sql_server']['version'] = '2012'
default['sql_server']['instance_name'] = 'MSSQLSERVER'
default['sql_server']['update_enabled'] = false
default['sql_server']['sysadmins'] = ENV['USERNAME']
default['windows']['windows_package']['success_codes'] = '0,42,127,3010'