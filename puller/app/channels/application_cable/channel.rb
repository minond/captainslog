module ApplicationCable
  class Channel < ActionCable::Channel::Base
    # Streams all model updates for the user. This stream powers the
    # index page.
    #
    # @param [Symbol] model
    def stream_index_updates(model)
      stream_from(stream_name(model)) do |id|
        transmit render_index_update(model, id.to_i)
      end
    end

    # Streams a single record's updates for the user. This stream powers the show
    # page.
    #
    # @param [Symbol] model
    # @param [Integer] requested_record_id
    def stream_show_updates(model, requested_record_id)
      stream_from(stream_name(model)) do |id|
        transmit render_show_update(model, id.to_i) if id.to_i == requested_record_id
      end
    end

    # Generates the user specific stream name for a give model.
    #
    # @param [Symbol] model
    # @return [String]
    def stream_name(model)
      "user/#{current_user.id}/#{model.to_s.pluralize}"
    end

    # @param [Symbol] model
    # @param [Integer] id
    # @return [Hash]
    def render_index_update(model, id)
      record = model_class(model).find(id)

      {
        :id => record.id,
        :component => :row,
        :container => :rows,
        :model => model,
        :html => row_class(model).render(model => record),
      }
    end

    # @param [Symbol] model
    # @param [Integer] id
    # @return [Hash]
    def render_show_update(model, id)
      record = model_class(model).find(id)

      {
        :id => record.id,
        :component => :details,
        :model => model,
        :html => details_class(model).render(model => record),
      }
    end

    # param [Symbol] model
    # @return [Class < ActionRecord::Base]
    def model_class(model)
      model.to_s.classify.safe_constantize
    end

    # param [Symbol] model
    # @return [Class]
    def row_class(model)
      "#{model.to_s.classify}::Row".safe_constantize
    end

    # param [Symbol] model
    # @return [Class]
    def details_class(model)
      "#{model.to_s.classify}::Details".safe_constantize
    end
  end
end
