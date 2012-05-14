require 'tilt'
require 'haml'
require 'json'

module Spacedocs
  class << self
    def partial(template_name, locals={})
      Tilt.new("source/#{template_name}").render self, locals
    end

    def doc
      buffer = File.read 'game.json'
      doc_json = JSON.parse buffer

      processed_data = process_data doc_json

      template = Tilt.new("source/class.html.haml")

      processed_data[:docs_data].each do |class_data|
        class_data.each_pair do |class_name, data|
          File.open("source/#{class_name.gsub(/#/, '')}.html", 'w') do |f|
            class_names = processed_data[:class_names]

            f.write(template.render(self, class_name: class_name, method_list: (class_data[class_name]['method_list'] || []), methods: class_data[class_name]['methods'], class_names: class_names, module_map: processed_data[:module_map]))
          end
        end
      end
    end

    def methods_of(source_class, tags)
      output = []
      matching_tags = []

      tags.each do |tag|
        matching_tags << tags if tag['type'] == 'methodOf'
      end

      matching_tags.each do |tags|
        tags.each do |tag|
          output << (source_class + tag['string']) if tag['type'] == 'name'
        end
      end

      output
    end

    def tags_named(name, tags)
      tags.map do |tag|
        tag['string'] if tag['type'] == name
      end.compact
    end

    def method_of_data(tags)
      tags_named('methodOf', tags)
    end

    def name_data(tags)
      tags_named('name', tags)
    end

    def params_data(tags)
      params = {}

      tags.each do |tag|
        if tag['type'] == 'param'
          params["#{tag['name'].gsub(/[\[\]]/, '')}"] = {
            "type" => tag['types'].join(', '),
            "description" => tag['description'],
            "optional" => tag['name'].start_with?('[')
          }
        end
      end

      return params
    end

    def returns_data(tags)
      tags.map do |tag|
        if tag['type'] == 'returns'
          { "type" => tag['string'].split(' ').first.gsub(/[{}]/, ''), "description" => tag['string'].split(' ')[1..-1].join(' ') }
        end
      end.compact
    end

    def see_data(tags)
      tags_named('see', tags)
    end

    def format_class_name(name)
      name.end_with?('#') ? name : name + '.'
    end

    def class_name_data(tags)
      class_names = []

      tags.each do |tag|
        if tag['type'] == 'methodOf'
          class_names << format_class_name(tag['string'])
        end

        if tag['type'] == 'constructor' || tag['type'] == 'namespace'
          tags.each do |tag|
            if tag['type'] == 'name'
              class_names << format_class_name(tag['string'])
            end
          end
        end
      end

      class_names.compact.flatten.uniq
    end

    def process_data(json)
      class_names = []
      tags_list = []
      docs_data = []
      module_map = {}

      json.each do |item|
        tags = item['tags']

        tags_list << tags

        name = name_data(tags).first
        returns = returns_data(tags).first || {}
        see = see_data(tags).first || ""
        method_of = method_of_data(tags).first
        params = params_data(tags)

        class_names << class_name_data(tags)

        if name && method_of
          module_map[method_of] ||= {}
          module_map[method_of][name] = {
            "summary" => item['description']['summary'],
            "code_sample" => item['description']['body'],
            "source" => item['code'],
            "parameters" => params,
            "returns" => returns,
            "see" => see
          }
        end
      end

      class_names = class_names.compact.flatten.uniq.sort

      class_names.each do |source_class|
        method_list = module_map[source_class] ? module_map[source_class].keys : []
        method_data = module_map[source_class] ? module_map[source_class] : {}

        docs_data << {
          "#{source_class}" => {
            "method_list" => method_list,
            "methods" => method_data
          }
        }
      end

      File.open("source/sanity.json", 'w') do |f|
        f.write(docs_data.to_json)
      end

      return { docs_data: docs_data, class_names: class_names, module_map: module_map }
    end
  end
end

Spacedocs.doc