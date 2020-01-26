# frozen_string_literal: true

# name: discourse-policy-groupadd
# about: add people who accepted a policy to a certain group in a quick and dirty manner
# version: 1.0
# authors: richard@discoursehosting.com
# url: https://github.com/discoursehosting/discourse-policy-groupadd

enabled_site_setting :policy_groupadd_enabled

PLUGIN_NAME ||= "discourse_policy_groupadd".freeze

after_initialize do
  require File.expand_path('../jobs/scheduled/policy_group_add.rb', __FILE__)
end
