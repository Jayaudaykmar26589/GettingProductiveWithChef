#
# Cookbook Name:: webapp-windows
# Recipe:: database
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'sql_server::server'


create_database_script_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'create-database.sql'))

cookbook_file create_database_script_path do
	source 'create-database.sql'
end

sqlps_module_path = ::File.join(ENV['programfiles(x86)'], 'Microsoft SQL Server\110\Tools\PowerShell\Modules\SQLPS')

powershell_script 'Initialize database' do
	code <<-EOH
	Import-Module "#{sqlps_module_path}"
	Invoke-Sqlcmd -InputFile #{create_database_script_path}
	EOH
	guard_interpreter :powershell_script
	only_if <<-EOH
	Import-Module "#{sqlps_module_path}"
	(Invoke-Sqlcmd -Query "SELECT COUNT(*) AS Count from sys.databases WHERE name='learnchef'").Count -eq 0
	EOH
end
	
grant_access_script_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'grant-access.sql'))

cookbook_file grant_access_script_path do
	source 'grant-access.sql'
end

powershell_script 'Grant SQL access to IIS APPPOOL\Products' do
	code <<-EOH
	Import-Module "#{sqlps_module_path}"
	Invoke-Sqlcmd -InputFile #{grant_access_script_path}
	EOH
	guard_interpreter :powershell_script
	not_if <<-EOH
	Import-Module "#{sqlps_module_path}"
	$sp = Invoke-Sqlcmd -Database learnchef -Query "EXEC sp_helpprotect @username ='IIS APPPOOL\\Products', @name='customers'"
	($sp.ProtectType.Trim() -eq 'Grant') -and ($sp.Action.Trim() -eq 'Select')
	EOH
end

