require 'tilt'
require 'haml'
require 'json'

# TODO Link to other pages from index
# build out modules
# build out classes
# build out native prototype stuff
module Spacedocs
  DIR = Dir.pwd

  class << self
    def doc
      buffer = File.read('game.json')
      doc_json = JSON.parse(buffer)

      natives(doc_json).each do |native_json|
        template = Tilt.new("source/native.html.haml")
        File.open("source/#{native_json['ctx']['name']}.html", 'w') {|f| f.write(template.render(self, doc_json: doc_json, native_json: native_json)) }
      end

      # generate the index
      #template = Tilt.new('source/index.html.haml')
      #File.open('source/doc_index.html', 'w') {|f| f.write(template.render(self, doc_json: doc_json)) }
    end

    def signature(method)
      param_list(method).map{ |p| p[:name] }.join(', ')
    end

    def partial(template_name, locals={})
      template = Tilt.new("#{DIR}/source/#{template_name}")
      template.render self, locals
    end

    def param_list(method)
      params = []

      (method['tags']).each do |tag|
        if tag['type'] == 'param'
          params << { name: tag['name'], description: tag['description'] }
        end
      end

      params
    end

    def tags_named(name, tags)
      output = []

      tags.each do |tag|
        if tag['type'] == name
          output << tags
        end
      end

      output
    end

    def natives(json)
      json.select do |item|
        !item['ctx'].nil?
      end
    end

    def modules(json)
      documented_modules = []

      json.each do |token|
        self.tags_named('module', json).first
      end

      documented_modules
    end

    def classes
    end
  end
end

Spacedocs.doc