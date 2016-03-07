#
# Cookbook Name:: .
# Recipe:: webserver
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#install apache and start the service
httpd_service 'customers'  do
	mpm 'prefork'
	action [:create, :start]
end

httpd_config 'customers' do
	instance 'customers'
	source 'customers.conf.erb'
	notifies :restart, 'httpd_service[customers]'
end

#create doc root
directory node['webapp-linux']['document_root'] do
	recursive true
end

password_secret = Chef::EncryptedDataBagItem.load_secret(node['webapp-linux']['passwords']['secret_path'])
user_password_data_bag_item = Chef::EncryptedDataBagItem.load('credentials', 'db_admin_password', password_secret)

template "#{node['webapp-linux']['document_root']}/index.php" do
	source 'index.php.erb'
	owner node['webapp-linux']['user']
	group node['webapp-linux']['group']
	mode '0644'
	action :create
    variables({
        :database_password => user_password_data_bag_item['password']
    })
    
end

firewall_rule 'http' do
	port 80
	protocol :tcp
	action :create
end

httpd_module 'php5' do
    instance 'customers'
end

package 'php5-mysql' do
  action :install
  notifies :restart, 'httpd_service[customers]'
end
