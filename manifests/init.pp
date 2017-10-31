# Class: netuitiveagent
# ===========================
#
# Install Netuitive (Metricly) agent
#
# Parameters
# ----------
#
# http://hlp.app.netuitive.com/Content/Integrations/linux.htm
#
# * `netuitive_hostname`
# "Hostname desired. Optionally can be calculated. Default: netuitive_host"

# If you prefer to just use a different way of calculating the hostname
# Uncomment and set this to one of these values:

# smart             = Default. Tries fqdn_short. If that's localhost, uses hostname_short

# fqdn_short        = Default. Similar to hostname -s
# fqdn              = hostname output
# fqdn_rev          = hostname in reverse (com.example.www)

# uname_short       = Similar to uname -n, but only the first part
# uname_rev         = uname -r in reverse (com.example.www)

# hostname_short    = `hostname -s`
# hostname          = `hostname`
# hostname_rev      = `hostname` in reverse (com.example.www)

# shell             = Run the string set in hostname as a shell command and use its
#                     output(with spaces trimmed off from both ends) as the hostname.

# * `netuitive_linux_api_key`
# "Required Linux API key from your account. Default: undefined"

# * `netuitive_statsd_port`
# "Listen port for the local statsd server. Default: 8125"

# * `netuitive_listen_ip`
# "IP address for the local statsd server. Default: 127.0.0.1"

# * `netuitive_conf_file`
# "Installed location for the agent configuration file"
# "Default: /opt/netuitive-agent/conf/netuitive-agent.conf"

#
# Variables
# ----------
#
# * `_hostname`
# The full hostname that will be set. Concatenates the netuitive_hostname and ::hostname facter.

# Examples
# --------
#
# @example
#    class { 'netuitiveagent':
#      netuitive_hostname => [ 'netuitive_host' ],
#    }
#
# Authors
# -------
#
# Simon Overbey
#
# Copyright
# ---------
#
# Copyright 2017 Simon Overbey
#
class netuitiveagent (
  $netuitive_hostname = 'netuitive_host',
  $netuitive_linux_api_key = undef,
  $netuitive_statsd_port = '8125',
  $netuitive_listen_ip = '127.0.0.1',
  $netuitive_conf_file = '/opt/netuitive-agent/conf/netuitive-agent.conf',
) {

  $_hostname = "${netuitive_hostname}-${::hostname}"
  notify { "Netuitive hostname: ${_hostname}": }

  include ::apt

  apt::key { 'netuitive':
    ensure     => 'present',
    key        => '36898B9AC240DD7615A1213DF9CCBD914DC152C7',
    key_source => 'https://repos.app.netuitive.com/netuitive.gpg',
  } ->
  file { '/etc/apt/sources.list.d/netuitive.list':
    ensure  => file,
    content => template("${module_name}/netuitive/netuitive.list.erb"),
    mode    => '0644',
  } ->
  exec { 'apt-get update':
    command => '/usr/bin/apt-get -y update',
  } ->
  package { 'netuitive-agent':
    ensure  => 'latest',
  }

  file { $netuitive_conf_file:
    notify  => Service['netuitive-agent'],
    ensure  => file,
    content => template("${module_name}/netuitive/netuitive-agent.conf.erb"),
    mode    => '0644',
    require => Package['netuitive-agent'],
  }

  service { 'Run Netuitive agent':
    name    => 'netuitive-agent',
    enable  => true,
    ensure  => 'running',
    require => Package['netuitive-agent'],
  }
}