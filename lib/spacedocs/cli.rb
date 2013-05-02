require "thor"
require "spacedocs/version"
require "spacedocs"

module Spacedocs
  class CLI < ::Thor
    desc "version", "Show version"
    def version
      p Spacedocs::VERSION
    end

    desc "doc source_file output_directory", "Build API docs based on source_file to output_directory"
    def doc
      current_path = File.dirname(__FILE__)

      # TODO figure out how to actually write
      # STDIN to a file. Need to do this because
      # dox uses < which can only be a file in the filesystem
      File.open(File.join(current_path, 'temp.js'), 'w') do |f|
        f.write(ARGF)
      end

      ::Spacedocs.doc(ARGF, '.')
    end

    default_task :doc
  end
end
