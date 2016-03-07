#
# Cookbook Name:: webapp-windows
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'webapp-windows::webserver'
include_recipe 'webapp-windows::database'