class Component
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetUrlHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Context
  include ActiveSupport::Configurable
  include ActionController::RequestForgeryProtection

  # rubocop:disable Naming/ConstantName
  Boolean = [FalseClass, TrueClass].freeze
  MaybeBoolean = [NilClass, FalseClass, TrueClass].freeze
  MaybeHash = [NilClass, Hash].freeze
  MaybeString = [NilClass, String].freeze
  # rubocop:enable Naming/ConstantName

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
    # @param [Class] klass, defaults to lookup by controller + action
    # @param [Hash] args
    def component(klass = nil, **args)
      klass ||= "#{controller_path.classify}::#{action_name.classify}".constantize
      render :html => klass.render(args),
             :layout => "layouts/application"
    end
  end

  module Typechecker
    # @param [Symbol] val
    # @param [Class] type
    # @param [Object] val
    # @return [Boolean]
    def self.assert!(prop, type, val)
      raise TypeError.new(name, prop, type, val) unless of_type?(type, val)
    end

    # @param [Class] type
    # @param [Object] val
    # @return [Boolean]
    def self.of_type?(type, val)
      if type.is_a?(Array) && type.size == 1
        of_list_type?(type, val)
      elsif type.is_a? Array
        of_union_type?(type, val)
      else
        val.is_a? type
      end
    end

    # @param [Class] type
    # @param [Object] val
    # @return [Boolean]
    def self.of_list_type?(type, val)
      if val.is_a? ActiveRecord::AssociationRelation
        val.name == type.first.name
      elsif val.is_a? Array
        val.first.nil? || val.first.is_a?(type.first)
      else
        false
      end
    end

    # @param [Class] type
    # @param [Object] val
    # @return [Boolean]
    def self.of_union_type?(type, val)
      type.any? { |t| val.is_a? t }
    end
  end

  # @param [Symbol] tag
  # @param [Hash] attrs
  # @return [Class]
  #
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.new(tag, **attrs, &block)
    return super unless self == Component

    props = attrs.delete(:props) || {}

    Class.new(Component) do
      props props

      define_method(:_tag) { tag }
      define_method(:_attrs) { attrs }
      define_method(:_block) { block }

      def initialize(children = nil, **attr_overrides)
        super(children, _attrs.merge(attr_overrides))
      end

      def render
        content_tag(_tag, _attrs.merge(@attributes.slice(*_attrs.keys))) do
          if children_overrides.present?
            children_overrides
          elsif _block.present?
            html(instance_eval(&_block))
          else
            ""
          end
        end
      end

      def children_overrides
        @children_overrides ||= children
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # @param [Array<String>, String] strs
  # @return [String]
  def self.html(strs)
    strs = strs.join if strs.is_a? Array
    strs&.html_safe || ""
  end

  # @param [Array<String>, String, Nil] children
  # @param [Hash] attrs
  # @return [String]
  def self.render(children = nil, **attrs, &block)
    html(new(children, attrs, &block).render)
  end

  # @param [Array<Symbol>] props
  # @return [Array<Symbol>]
  def self.props(props = nil)
    return @props || [] if props.nil?

    attr_accessor(*props.keys)
    @props = props
  end

  # @param [Hash] attrs
  # @return [Array<Symbol, Class, Object>]
  def self.zip(attrs)
    props.each_with_object([]) do |(prop, type), acc|
      acc << [prop, type, attrs[prop]]
    end
  end

  # @param [Array<String>, String, Nil] children
  # @param [Hash] attrs
  # @raise [TypeError] if a property is passed in with an unexpected type.
  def initialize(children = nil, **attrs)
    @children = proc { |*args| block_given? ? yield(*args) : children }
    @attributes = attrs

    self.class.zip(attrs).each do |(prop, type, val)|
      Typechecker.assert!(prop, type, val)
      send("#{prop}=", val)
    end
  end

  # @return [String, Array<String>]
  def render
    raise NotImplementedError, "#render is not implemented"
  end

  # @param [Array<String>, String] strs
  # @return [String]
  def html(strs)
    self.class.html(strs)
  end

  # @param [Array<Object>] args
  # @return [String]
  def children(*args)
    html(@children.call(*args))
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
