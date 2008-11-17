require 'toolkit/job'
require 'toolkit/perl_job'
require 'toolkit/action'
require 'toolkit/perl_action'
require 'toolkit/perl_forward_action'
require 'toolkit/queue_job'
require 'toolkit/abstract_worker'
require 'toolkit/local_worker'
require 'toolkit/pbs_worker'
require 'toolkit/jobs_cart'

# Validators
Dir.foreach("#{RAILS_ROOT}/app/models/validators") do |file|
  if (!file.sub!(/\.rb$/, '').nil?)
    require "validators/#{file}"
  end
end

# the lowerthe value the higher priority of a state
# running state overrides done
STATUS_CMP = {
  STATUS_INIT    => 4,
  STATUS_QUEUED  => 3,
  STATUS_RUNNING => 2,
  STATUS_DONE    => 5,
  STATUS_ERROR   => 1
};
