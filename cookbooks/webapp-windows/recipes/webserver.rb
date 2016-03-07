#
# Cookbook Name:: webapp-windows
# Recipe:: webserver
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

dsc_script 'Web-Server' do
	code <<-EOH
	WindowsFeature InstallWebServer
	{
		Name = "Web-Server"
		Ensure = "Present"
	}
	EOH
end

dsc_script 'Web-Asp-Net45' do
	code <<-EOH
	WindowsFeature InstallAspDotNet45
	{
		Name = "Web-Asp-Net45"
		Ensure = "Present"
	}
	EOH
end

dsc_script 'Web-Mgmt-Console' do
	code <<-EOH
	WindowsFeature InstallAspDotNet45
	{
		Name = "Web-Mgmt-Console"
		Ensure = "Present"
	}
	EOH
end

include_recipe 'iis::remove_default_site'

iis_site 'Default Web Site' do
	action [:stop, :delete]
end

iis_pool 'DefaultAppPool' do
	action [:stop, :delete]
end


app_directory = 'C:\inetpubs\apps\Customers'
site_directory = 'C:\inetpub\sites\Customers'

windows_zipfile app_directory do
	source 'https://github.com/learn-chef/manage-a-web-app-windows/releases/download/v0.1.0/Customers.zip'
	action :unzip
	not_if { ::File.exists?(app_directory) }
end

iis_pool 'Products' do
	runtime_version '4.0'
	action :add
end

directory site_directory do
	rights :read, 'IIS_IUSRS'
	recursive true
	action :create
end

iis_site 'Customers' do
	protocol :http
	port 80
	path site_directory
	application_pool 'Products'
	action [:add, :start]
end

iis_app 'Customers' do
	application_pool 'Products'
	path '/Products'
	physical_path app_directory
	action :add
end