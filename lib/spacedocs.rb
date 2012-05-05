require 'tilt'
require 'haml'
require 'json'

module Spacedocs
  DIR = Dir.pwd

  class << self
    def doc
      buffer = File.read 'game.json'
      doc_json = JSON.parse buffer

      process_data doc_json

      natives(doc_json).each do |native_json|
        template = Tilt.new("source/native.html.haml")

        File.open("source/#{native_json['ctx']['name']}.html", 'w') do |f|
          f.write(template.render(self, doc_json: doc_json, native_json: native_json))
        end
      end
    end

    def signature(method)
      param_list(method).map{ |p| p[:name] }.join ', '
    end

    def partial(template_name, locals={})
      Tilt.new("#{DIR}/source/#{template_name}").render self, locals
    end

    def param_list(method)
      method['tags'].map do |tag|
        { name: tag['name'], description: tag['description'] } if tag['type'] == 'param'
      end.compact
    end

    def natives(json)
      json.select do |item|
        !item['ctx'].nil?
      end
    end

    def tags_named(type, tags)
      output = []

      tags.each do |tag|
        output << tags if tag['type'] == type
      end

      output
    end

    def methods_of(source_class, tags)
      output = []
      matching_tags = []

      tags.each do |tag|
        matching_tags << tags if (tag['type'] == 'methodOf' && tag['string'] == "#{source_class}#")
      end

      matching_tags.each do |tags|
        tags.each do |tag|
          output << tag['string'] if tag['type'] == 'name'
        end
      end

      output
    end

    def process_data(json)
      output = []
      constructors = []
      class_names = []
      tags_list = []
      method_map = {}
      method_data = {}
      docs_data = []

      json.each do |item|
        tags_list << item['tags']
        methods_of('Date', item['tags'])

        name = nil
        returns = nil
        see = nil
        params = []

        (item['tags']).each do |tag|
          name = tag['string'] if tag['type'] == 'name'
          returns = tag['string'] if tag['type'] == 'returns'
          see = tag['local'] if tag['type'] == 'see'

          if tag['type'] == 'param'
            params << {
              "#{tag['name'].gsub(/[\[\]]/, '')}" => {
                  "type" => tag['types'].join(', '),
                  "description" => tag['description'],
                  "optional" => tag['name'].start_with?('[')
                }
              }
          end

          if tag['type'] == 'methodOf'
            source_class = tag['string'].gsub('#', '')
            class_names << source_class
            method_map["#{source_class}"] = [] unless method_map["#{source_class}"]
          end

          if tag['type'] == 'constructor' || tag['type'] == 'namespace'
            constructors << item['tags']
          end
        end

        method_data[name] = {
          "summary" => item['description']['summary'],
          "code_sample" => item['description']['body'],
          "source" => item['code'],
          "params" => params,
          "returns" => returns,
          "see" => see
        }
      end

      constructors.each do |tags|
        tags.each do |tag|
          if tag['type'] == 'name'
            class_names << tag['string']
            method_map["#{tag['string']}"] = [] unless method_map["#{tag['string']}"]
          end
        end
      end

      class_names = class_names.uniq

      tags_list.each do |tags|
        tags.each do |tag|
          class_names.each do |source_class|
            if tag['type'] == 'methodOf'
              if tag['string'].gsub(/#/, '') == source_class
                methods = methods_of(source_class, tags)
                method_map[source_class] << methods.first
              end
            end
          end
        end
      end

      class_names.each do |source_class|
        data = {}

        (method_map[source_class]).each do |method|
          data[method] = method_data[method]
        end

        docs_data << {
          "#{source_class}" => {
            "method_list" => method_map[source_class],
            "methods" => data
          }
        }
      end

      docs_data
      File.open("sanity.json", 'w') do |f|
        f.write(docs_data.to_json)
      end
    end
  end
end

Spacedocs.doc