class Component
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Context
  include ActiveSupport::Configurable
  include ActionController::RequestForgeryProtection

  attr_accessor :output_buffer

  class TypeError < ArgumentError
    # @param [Class] component
    # @param [Symbol] prop
    # @param [Class] type
    # @param [Object] val
    def initialize(component, prop, type, val)
      super("#{component} expected :#{prop} to be of type `#{type}` but got `#{val.class}` instead")
    end
  end

  module Rendering
    def component(klass, **args)
      render :html => klass.render(args),
             :layout => "layouts/application"
    end
  end

  # @param [Array<String>, String] strs
  # @return [String]
  def self.html(strs)
    strs = strs.join if strs.is_a? Array
    strs.html_safe
  end

  # @param [Array<String>, String, Nil] children
  # @param [Hash] props
  # @return [String]
  def self.render(children = nil, **props, &block)
    html(new(children, props, &block).render)
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

  # @param [Array<String>, String, Nil] children
  # @param [Hash] props
  # @raise [TypeError] if a property is passed in with an unexpected type.
  def initialize(children = nil, **props)
    @children = proc { |*args| block_given? ? yield(*args) : children }

    self.class.zip(props).each do |(prop, type, val)|
      self.class.typecheck!(prop, type, val)
      send("#{prop}=", val)
    end
  end

  # @return [String, Array<String>]
  def render
    raise NotImplementedError, "#render is not implemented"
  end

  # @param [Array<Object>] args
  # @return [String]
  def children(*args)
    self.class.html(@children.call(*args))
  end

  # @param [Symbol] key
  # @param [Hash] args
  # @return [String]
  def t(key, **args)
    I18n.t(key, args)
  end

  # Allows ActionController::RequestForgeryProtection and authenticity token
  # generation to work.
  #
  # @return [Hash]
  def session
    {}
  end
end
