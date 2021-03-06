class Vertex::Edit < ViewComponent
  props :vertex => Vertex

  include Select::Helper

  RightArrow = ViewComponent.new(:span, :class => "f5 ph3") { "→" }
  Break = ViewComponent.new(:br)

  delegate :connection, :to => :vertex
  delegate :source?, :to => :connection
  delegate :target?, :to => :connection

  def render
    ViewContainer.render [header, existing_edges, form]
  end

  def header
    Header.render(:key => header_key,
                  :args => header_args)
  end

  def header_key
    source? ? :send_x_data_to : :send_data_to_x
  end

  def header_args
    { :label => vertex.resource.label }
  end

  def form
    url = connection_vertex_edges_path(:vertex_id => vertex,
                                       :connection_id => connection)

    Form.render(:resource => Edge.new, :url => url, :show_actions => true) do
      blank_source_to_target_field
    end
  end

  def existing_edges
    other_sources_or_targets.map do |vertex|
      source_or_target_select_row(select([vertex_option(vertex)], :disabled => true))
    end
  end

  def blank_source_to_target_field
    source_or_target_select_row(target? ? sources : targets, :break_after => false)
  end

  def source_or_target_select_row(source_or_target_field, break_after: true)
    if target?
      [source_or_target_field, RightArrow.render, current, break_after ? Break.render : nil]
    else
      [current, RightArrow.render, source_or_target_field, break_after ? Break.render : nil]
    end
  end

  def current
    select [vertex_option(vertex)], :disabled => true
  end

  def targets
    select vertex_options(:target?), targets_and_sources_select_attrs
  end

  def sources
    select vertex_options(:source?), targets_and_sources_select_attrs
  end

  def targets_and_sources_select_attrs
    {
      :name => "head_or_tail_vertex_id",
      :autofocus => true,
      :placeholder => true,
      :submits => true,
    }
  end

  def vertex_option(vertex)
    [vertex.id, vertex.resource.label]
  end

  def vertex_options(connection_type)
    vertices(connection_type).map { |vertex| vertex_option(vertex) }
  end

  def vertices(connection_type)
    vertex.user.connections
          .filter(&connection_type)
          .map(&:vertices)
          .flatten
  end

  def other_sources_or_targets
    if target?
      vertex.incoming.map(&:source)
    else
      vertex.outgoing.map(&:target)
    end
  end
end
