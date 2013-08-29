#!/usr/bin/env ruby

CRED_SCRIPTS_DIR=File.dirname(__FILE__)
BLOB_DATA_DIR=File.join(CRED_SCRIPTS_DIR, 'blobs')

# add our root and lib dirs to the load path
$:.unshift CRED_SCRIPTS_DIR
$:.unshift "#{CRED_SCRIPTS_DIR}/lib/"

cmd = File.basename($0, File.extname($0))
CRED_ENCRYPTING = cmd.match(/encrypt/)

# necessary requires
require 'pi-secrets'

# ---------------------------------------------------------------------------
def print_help
  if CRED_ENCRYPTING
    puts <<-USAGE_EN

    pi-encrypt.rb <env> <filename>
      Encrypt the referenced file for the given environment and key.
    USAGE_EN
  else
    puts <<-USAGE_DE

    pi-decrypt.rb <env> <filename>
      Decrypt the referenced file for the given environment and key.
    USAGE_DE
  end
  puts <<-USAGE
      The key will be requested to prevent leaking of the shared secret in
      bash histories, etc.

    Arguments:
      --help : this message
      <env>  : environment where this file will be used
      <filename> : name of file

  USAGE

  exit
end


# ---------------------------------------------------------------------------
filename    = nil
environment = nil


ARGV.each_with_index do |arg, idx|
  arg = (arg || '').to_s

  if ['--help', '-h'].include?(arg)
    print_help # this will exit
  elsif idx == 0
    environment = arg
  elsif idx == 1
    filename = arg
  else
    puts "ERROR: Unknown argument '#{arg}'.\n\n"
    print_help # this will exit
  end
end

if environment.nil?
  puts "ERROR: environment not given."
  print_help # this will exit
end

if filename.nil?
  puts "ERROR: filename not given."
  print_help # this will exit
end

if CRED_ENCRYPTING
  Pi::Secrets.encrypt(environment, filename)
else
  Pi::Secrets.decrypt(environment, filename)
end
