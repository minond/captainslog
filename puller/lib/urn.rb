#                      Uniform Resource Names (URNs)
#                   https://tools.ietf.org/html/rfc8141
#
#
#                                 **nid**
#
# The identifier associated with a URN namespace.
#
#
#                                 **nss**
#
# The URN-namespace-specific part of a URN.
#
#
#                              **q-component**
#
# The q-component is intended for passing parameters to either the named
# resource or a system that can supply the requested service, for
# interpretation by that resource or system.  (By contrast, passing parameters
# to URN resolution services is handled by r-components as described in the
# previous section.)
#
#
#                              **r-component**
#
# The r-component is intended for passing parameters to URN resolution services
# (taken broadly, see Section 1.2) and interpreted by those services.  (By
# contrast, passing parameters to the resources identified by a URN, or to
# applications that manage such resources, is handled by q-components as
# described in the next section.)
#
#
#                              **f-component**
#
# The f-component is intended to be interpreted by the client as a
# specification for a location within, or region of, the named resource.  It
# distinguishes the constituent parts of a resource named by a URN.  For a URN
# that resolves to one or more locators that can be dereferenced to a
# representation, or where the URN resolver directly returns a representation
# of the resource, the semantics of an f-component are defined by the media
# type of the representation.
class URN
  attr_reader :nid, :nss, :r, :q, :f

  # @param [String] str
  # @return [URN]
  def self.parse(str)
    _header, nid, rest = str.split(":")
    nss = Encoding.decode_nss(rest)
    r, q, f = Encoding.decode_components(rest)
    new(nid, nss, :r => r, :q => q, :f => f)
  end

  # @param [String] nid
  # @param [String] nss
  # @param [Hash] components
  # @option components [Hash] r, r components
  # @option components [Hash] q, q components
  # @option components [Hash] f, f components
  def initialize(nid, nss, components = {})
    @nid = nid
    @nss = nss
    @r = components[:r]&.compact || {}
    @q = components[:q]&.compact || {}
    @f = components[:f]
  end

  def to_s
    "urn:#{nid}:#{nss}#{r_s}#{q_s}#{f_s}"
  end

private

  def r_s
    "?=" + Encoding.encode_params(r) unless r.empty?
  end

  def q_s
    "?+" + Encoding.encode_params(q) unless q.empty?
  end

  def f_s
    "##{f}" unless f.nil?
  end

  module Encoding
    # @param [Hash] params
    # @return [String]
    def self.encode_params(params)
      params.map do |name, value|
        "#{name}=#{URI.encode_www_form_component(value)}"
      end.join("&")
    end

    # @param [String] str
    # @return [Hash]
    def self.decode_params(str)
      str.split("&").each_with_object({}) do |param, params|
        key, value = param.split("=")
        params[key] = URI.decode_www_form_component(value) if value
      end.with_indifferent_access
    end

    # @param [String] str
    # @return [Tuple<Hash, Hash, String | Nil>]
    def self.decode_components(str)
      r = string_until(string_until(string_from(str, "?="), "?+"), "#")
      q = string_until(string_from(str, "?+"), "#")
      f = string_from(str, "#")
      [decode_params(r || ""), decode_params(q || ""), f]
    end

    # @param [String] str
    # @return [String]
    def self.decode_nss(str)
      string_until(string_until(string_until(str, "?="), "?+"), "#")
    end

    # @param [String] str
    # @param [String] part
    # @return [String, Nil]
    def self.string_from(str, part)
      str[(str.index(part) + part.size)..-1] if str&.include?(part)
    end

    # @param [String] str
    # @param [String] part
    # @return [String]
    def self.string_until(str, part)
      str.present? && str.include?(part) ? str[0..(str.index(part) - 1)] : str
    end
  end
end
