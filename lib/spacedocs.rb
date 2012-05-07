require 'tilt'
require 'haml'
require 'json'

module Spacedocs
  DIR = Dir.pwd

  class << self
    def partial(template_name, locals={})
      Tilt.new("#{DIR}/source/#{template_name}").render self, locals
    end

    def doc
      buffer = File.read 'game.json'
      doc_json = JSON.parse buffer

      processed_data = process_data doc_json

      template = Tilt.new("source/class.html.haml")

      processed_data[:docs_data].each do |class_data|
        class_data.each_pair do |class_name, data|
          File.open("source/#{class_name}.html", 'w') do |f|
            class_names = processed_data[:class_names]

            f.write(template.render(self, class_name: class_name, class_data: data, class_names: class_names))
          end
        end
      end
    end

    def methods_of(source_class, tags)
      output = []
      matching_tags = []

      tags.each do |tag|
        matching_tags << tags if (tag['type'] == 'methodOf' && tag['string'].gsub(/#/, '') == "#{source_class}")
      end

      matching_tags.each do |tags|
        tags.each do |tag|
          output << tag['string'] if tag['type'] == 'name'
        end
      end

      output
    end

    def name_data(tags)
      tags.map do |tag|
        tag['string'] if tag['type'] == 'name'
      end.compact
    end

    def returns_data(tags)
      tags.map do |tag|
        if tag['type'] == 'returns'
          { "type" => tag['string'].split(' ').first.gsub(/[{}]/, ''), "description" => tag['string'].split(' ')[1..-1].join(' ') }
        end
      end.compact
    end

    def see_data(tags)
      tags.map do |tag|
        tag['local'] if tag['type'] == 'see'
      end.compact
    end

    def process_data(json)
      constructors = []
      class_names = []
      tags_list = []
      method_map = {}
      method_data = {}
      docs_data = []

      json.each do |item|
        tags_list << item['tags']

        name = name_data(item['tags']).first
        returns = returns_data(item['tags']).first
        see = see_data(item['tags']).first

        params = {}

        (item['tags']).each do |tag|
          if tag['type'] == 'param'
            params["#{tag['name'].gsub(/[\[\]]/, '')}"] = {
              "type" => tag['types'].join(', '),
              "description" => tag['description'],
              "optional" => tag['name'].start_with?('[')
            }
          end

          if tag['type'] == 'methodOf'
            source_class = tag['string'].gsub('#', '')
            class_names << source_class
            method_map["#{source_class}"] ||= []
          end

          if tag['type'] == 'constructor' || tag['type'] == 'namespace'
            constructors << item['tags']
          end
        end

        method_data[name] = {
          "summary" => item['description']['summary'],
          "code_sample" => item['description']['body'],
          "source" => item['code'],
          "parameters" => params,
          "returns" => returns,
          "see" => see
        }
      end

      constructors.each do |tags|
        tags.each do |tag|
          if tag['type'] == 'name'
            class_names << tag['string']
            method_map["#{tag['string']}"] ||= []
          end
        end
      end

      class_names = class_names.uniq.sort

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

      return { docs_data: docs_data, class_names: class_names }
    end
  end
end

Spacedocs.doc