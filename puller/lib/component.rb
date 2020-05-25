class Component
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper

  class TypeError < ArgumentError
    # @param [Class] component
    # @param [Symbol] prop
    # @param [Class] type
    # @param [Object] val
    def initialize(component, prop, type, val)
      super("#{component} expected :#{prop} to be of type `#{type}` but got `#{val.class}` instead")
    end
  end

  # @param [Hash] args
  # @return [String]
  def self.render(args = {})
    res = new(args).render
    res = res.join if res.is_a? Array
    res.html_safe
  end

  # @param [Array<Symbol>] props
  # @return [Array<Symbol>]
  def self.props(props = nil)
    return @props || [] if props.nil?

    attr_accessor(*props.keys)
    @props = props
  end

  # @param [Symbol] val
  # @param [Class] type
  # @param [Object] val
  # @return [Boolean]
  #
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def self.typecheck!(prop, type, val)
    ok = if type.is_a? Array
           if val.is_a? ActiveRecord::AssociationRelation
             val.name == type.first.name
           elsif val.is_a? Array
             val.first.nil? || val.first.is_a?(type.first)
           else
             false
           end
         else
           val.is_a? type
         end

    raise TypeError.new(name, prop, type, val) unless ok
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  # @param [Hash] args
  # @return [Array<Symbol, Class, Object>]
  def self.zip(args)
    props.each_with_object([]) do |(prop, type), acc|
      acc << [prop, type, args[prop]]
    end
  end

  # @param [Hash] args
  # @raise [TypeError] if a property is passed in with an unexpected type.
  def initialize(args)
    self.class.zip(args).each do |(prop, type, val)|
      self.class.typecheck!(prop, type, val)
      send("#{prop}=", val)
    end
  end

  # @return [String, Array<String>]
  def render
    raise NotImplementedError, "#render is not implemented"
  end

  def t(key, **args)
    I18n.t(key, args)
  end
end
