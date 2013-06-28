module Renderers
  class Sass
    SASS_ENGINE_OPTIONS = {
        cache: false,
        style: :compressed
    }.freeze

    def initialize(template)
      @template = template
    end

    def render
      ::Sass::Engine.new(@template, SASS_ENGINE_OPTIONS).render
    end
  end
end
