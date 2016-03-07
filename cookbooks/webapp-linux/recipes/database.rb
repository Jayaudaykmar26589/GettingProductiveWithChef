#
# Cookbook Name:: webapp-linux
# Recipe:: database
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

mysql2_chef_gem 'default' do
  action :install
end

mysql_client 'default' do
    action :create
end

password_secret = Chef::EncryptedDataBagItem.load_secret(node['webapp-linux']['passwords']['secret_path'])
root_password_databag_item = Chef::EncryptedDataBagItem.load('credentials', 'sql_server_root_password', password_secret)

mysql_service 'default' do 
    initial_root_password root_password_databag_item['password']
    port '3306'
    action [:create, :start]
end

mysql_connection_info = {
        :host => node['webapp-linux']['database']['host'],
        :username => node['webapp-linux']['database']['username'],
        :password => root_password_databag_item['password']
}

mysql_database node['webapp-linux']['database']['dbname'] do
    connection mysql_connection_info
    action :create
 end
 
 user_password_data_bag_item = Chef::EncryptedDataBagItem.load('credentials', 'db_admin_password', password_secret)

mysql_database_user node['webapp-linux']['database']['app']['username'] do
    connection mysql_connection_info
    password user_password_data_bag_item['password']
    database_name node['webapp-linux']['database']['dbname']
    host node['webapp-linux']['database']['host']
    action [:create, :grant]
 end
 
 cookbook_file node['webapp-linux']['database']['seed_file'] do
   source 'create-tables.sql'
   owner 'root'
   group 'root'
   mode '0700'
   action :create
 end

 
 execute 'initialize database' do
   command "mysql -h #{node['webapp-linux']['database']['host']} -u #{node['webapp-linux']['database']['app']['username']} -p#{user_password_data_bag_item['password']} -D #{node['webapp-linux']['database']['dbname']} < #{node['webapp-linux']['database']['seed_file']}"
   not_if "mysql -h #{node['webapp-linux']['database']['host']} -u #{node['webapp-linux']['database']['app']['username']} -p#{user_password_data_bag_item['password']} -D #{node['webapp-linux']['database']['dbname']}  -e 'describe customers;'"
   action :run
 end
 