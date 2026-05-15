ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap'
# Custom setup to allow simplecov to work with bootsnap
Bootsnap.setup(
  cache_dir: 'tmp/cache',
  ignore_directories: ['node_modules'],
  development_mode: ['', nil, 'development'].include?(ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ENV.fetch('ENV', nil)),
  load_path_cache: !ENV['DISABLE_BOOTSNAP_LOAD_PATH_CACHE'],
  compile_cache_iseq: !ENV['DISABLE_BOOTSNAP_COMPILE_CACHE'] && !defined?(SimpleCov),
  compile_cache_yaml: !ENV['DISABLE_BOOTSNAP_COMPILE_CACHE'],
  readonly: %w[1 true].include?(ENV.fetch('BOOTSNAP_READONLY', nil)),
  revalidation: %w[1 true].include?(ENV.fetch('BOOTSNAP_REVALIDATE', nil))
)
