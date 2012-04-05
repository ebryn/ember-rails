require 'tilt/template'
require "execjs"

module EmberRails

  # config.ember_rails.template_root = "templates"
  if defined?(::Rails::Application::Configuration)
    ::Rails::Application::Configuration.module_eval do
      def ember_rails
        EmberRails
      end
    end
  end

  class <<self
    attr_accessor :template_root
  end

  # = Sprockets engine for HandlebarsJS templates
  class HjsTemplate < Tilt::Template

    def self.default_mime_type
      'application/javascript'
    end

    def initialize_engine
    end

    def prepare
    end

    # Generates Javascript code from a HandlebarsJS template.
    # The Ember template name is derived from the lowercase logical asset path
    # by replacing non-alphanumeric characters by underscores.
    def evaluate(scope, locals, &block)
      t = data
      if scope.pathname.to_s =~ /\.mustache\.(handlebars|hjs)/
        t = t.gsub(/\{\{(\w[^\}\}]+)\}\}/){ |x| "{{unbound #{$1}}}" }
      end

      template_name = scope.logical_path
      if EmberRails.template_root
        template_name = template_name.sub(EmberRails.template_root, '').sub(/^\//, '')
      end
      if scope.pathname.to_s =~ /\.raw\.(handlebars|hjs)/
        "Ember.TEMPLATES[\"#{template_name}\"] = Handlebars.template(#{precompile_plain t});\n"
      else
        "Ember.TEMPLATES[\"#{template_name}\"] = Handlebars.template(#{precompile t});\n"
      end
    end

    private

      def precompile_plain(template)
        runtime.call("Handlebars.precompile", template)
      end

      def precompile(template)
        runtime.call("EmberRails.precompile", template)
      end

      def runtime
        Thread.current[:hjs_runtime] ||= ExecJS.compile(ember)
      end

      def ember
        [ "ember-precompiler.js", "ember.js" ].map do |name|
          File.read(File.expand_path(File.join(__FILE__, "..", "..", "..", "vendor/assets/javascripts/#{name}")))
        end.join("\n")
      end

  end

end
