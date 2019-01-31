#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: GPL-3.0-or-later

# Automated virt-install(1) frontend.
#
# Copyright © 2019 Kenyon Ralph
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Semantic Versioning. https://semver.org/
version = '0.0.0'

require 'optparse'
require 'ostruct'
require 'yaml'

default_config = 'config.yml'

options = OpenStruct.new

OptionParser.new do |opts|
  opts.version = version
  opts.banner = "Usage: #{opts.program_name} [options] [#{default_config}]
Install a new virtual machine (using virt-install(1)) using given
configuration, which defaults to #{default_config}.\n\n"

  opts.on('-nNAME', '--name=NAME', 'Name to call the new VM') do |n|
    options.name = n
  end

  opts.on(
    :REQUIRED,
    '-pPRESET',
    '--preset=PRESET',
    'virt-install options presets to use (required)'
  ) do |d|
    options.preset = d
  end

  opts.on('-h', '--help', 'Show this help and exit') do
    puts opts
    exit
  end

  opts.on(
    '-V',
    '--version',
    'Output version information and exit'
  ) do
    puts "#{opts.program_name} #{opts.version}"
    puts "Copyright © 2019 Kenyon Ralph
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Kenyon Ralph."
    exit
  end
end.parse!

raise(ArgumentError, 'Invalid number of arguments') if ARGV.length > 1

cfg_file = ARGV[0].nil? ? default_config : ARGV[0]
config = Psych.load_file(cfg_file)

raise(ArgumentError, 'Preset not specified; see --help') if options.preset.nil?

if config[options.preset].nil?
  raise(ArgumentError, 'Preset "' + options.preset + '" not found in ' + cfg_file)
end

cmd = 'virt-install'

config[options.preset].each_pair do |opt, arg|
  case opt.length == 1
  when true
    cmd += " -#{opt} #{arg}"
  when false
    cmd += " --#{opt} #{arg}"
  end
end

p cmd

#system(cmd)
