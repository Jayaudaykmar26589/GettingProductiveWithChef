#
# Cookbook Name:: settings
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
directory 'C:/temp'

template 'C:/temp/server-info.txt' do
  source 'server-info.txt.erb'
end

