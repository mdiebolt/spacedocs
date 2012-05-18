require 'tilt'
require 'haml'
require 'json'
require 'fileutils'

module Spacedocs
  class << self
    def doc(project_dir, file)
      tilt_path = File.dirname(__FILE__)

      #TODO Dangerous
      json = %x[dox < "#{File.join project_dir, file}"]

      doc_json = JSON.parse json

      processed_data = process_data doc_json

      template = Tilt.new(File.join tilt_path, "../source/class.html.haml")

      files = {}

      class_data = processed_data[:docs_data]

      class_data.each_key do |namespace|
        files[namespace] = true
      end

      FileUtils.mkdir_p File.join(project_dir, 'docs')

      files.each_key do |file_name|
        methods = class_data[file_name]['methods']

        File.open(File.join(project_dir, "docs/#{file_name}.html"), 'w') do |f|
          f.write(template.render self, {
            class_name: file_name,
            method_list: methods.keys,
            methods: methods,
            class_names: files.keys
          })
        end
      end
    end

    private
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

    def format_class_name(name)
      if name.end_with?('#')
        name[0...-1]
      else
        name
      end
    end

    def params_data(tags)
      tags.each_with_object({}) do |tag, hash|
        if tag['type'] == 'param'
          hash["#{tag['name'].gsub(/[\[\]]/, '')}"] = {
            "type" => tag['types'].join(', '),
            "description" => tag['description'],
            "optional" => tag['name'].start_with?('[')
          }
        end
      end
    end

    def returns_data(tags)
      tags.map do |tag|
        if tag['type'] == 'returns'
          description = tag['string'].split ' '

          type = description.shift.gsub(/[{}]/, '')
          remaining = description.join ' '

          { "type" => type, "description" => remaining }
        end
      end.compact
    end

    def see_data(tags)
      tags_named('see', tags)
    end

    def class_name_data(tags)
      class_names = []

      tags.each do |tag|
        class_names << format_class_name(tag['string']) if tag['type'] == 'methodOf'

        if tag['type'] == 'constructor' || tag['type'] == 'namespace'
          tags.each do |tag|
            class_names << tag['string'] if tag['type'] == 'name'
          end
        end
      end

      class_names.first
    end

    def process_data(json)
      class_names = []
      tags_list = []
      docs_data = {}
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
          if method_of.end_with?('#')
            name = "##{name}"
            method_of = method_of[0...-1]
          else
            name = ".#{name}"
          end

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
        method_data = module_map[source_class] || {}

        docs_data[source_class] = {
          'methods' => method_data
        }
      end

      #File.open("source/sanity.json", 'w') do |f|
      #  f.write(JSON.pretty_generate(docs_data))
      #end

      return { docs_data: docs_data, class_names: class_names }
    end
  end
end