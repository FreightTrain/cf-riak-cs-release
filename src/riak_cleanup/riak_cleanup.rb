#!/var/vcap/packages/ruby/bin/ruby
require 'riak'
require 'daemons'
require 'logger'
require 'yaml'

def delete_obsolete_buckets 

  # Disable warnings about non-optimal queries
  Riak.disable_list_keys_warnings = true
  # Disable warnings about locales
  I18n.enforce_available_locales = false

  # This is effectively a full DB scan - may have to be re-evaluated for large DB sizes
  valid_buckets = ['service_instances', 'service_bindings'] + @client.bucket("service_instances").keys

  current_buckets = @client.buckets.collect { |x| x.name }

  (current_buckets - valid_buckets).each do |bucket|
    @log.info('** deleting bucket ' + bucket + ' **')
    @client.bucket(bucket).keys.each {|k|
      Riak::RObject.new(@client.bucket(bucket), k).delete
    }
  end
end

def load_hosts_lists
  YAML.load_file('/var/vcap/jobs/riak_broker/config/broker.yml')['riak_hosts']
end

Daemons.run_proc(
  'riak_cleanup', 
  :dir_mode => :script,
  :dir => '/var/vcap/sys/run/riak_broker',
  :backtrace => true,
  :log_dir => '/var/vcap/sys/log/riak_broker',
  :log_output => true
) do

    @client = Riak::Client.new(:protocol => "pbc", :nodes => load_hosts_lists.collect { |host| { :host => host, :pb_port => 8087 } } )

    @log = Logger.new(STDOUT)
    while true do
      delete_obsolete_buckets
      sleep 60
    end
end
