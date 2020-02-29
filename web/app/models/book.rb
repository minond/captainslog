class Book < ApplicationRecord
  include Grouping

  belongs_to :user
  has_many :collections
  has_many :entries
  has_many :shorthands
  has_many :extractors

  after_initialize :constructor

  validates :grouping, :name, :user, :slug, :presence => true
  validates :slug, :uniqueness => { :scope => :user }

  enum :grouping => %i[none day week month year], :_prefix => :group_by

  scope :by_slug, ->(slug) { find_by(:slug => slug) }

  # Tells you if any entries need to be reprocessed. Returns true when an entry
  # exists that was processed before a change to the book's shorthands or
  # extractors.
  #
  # @return [Boolean]
  def dirty?
    entries.exists? && latest_shorthand_or_extractor_update > earliest_entry_processing
  end

  # Returns all entries that were processed before the latest shorthand or
  # processesor updates.
  #
  # @return [Array<Entry>]
  def dirty_entries
    entries.where("processed_at < ?", Time.at(latest_shorthand_or_extractor_update))
  end

  # @return [String]
  def path
    Rails.application.routes.url_helpers.book_path(slug)
  end

  # @param [String] text
  # @param [Time] time
  # @return [Entry]
  def add_entry(text, time = Time.current)
    collection = find_collection(time) || create_collection(time)
    Entry.create(:book => self,
                 :user => user,
                 :collection => collection,
                 :original_text => text)
  end

  # @param [Time] time
  # @return [Array<Entry>]
  def find_entries(time = Time.current)
    find_collection(time)&.entries&.order("created_at desc") || []
  end

  # @param [Time] time
  # @return [Collection, Nil]
  def find_collection(time = Time.current)
    start_time, end_time = grouping_time_range(time)
    res = Collection.by_book_id(id)
    res = start_time && end_time ? res.datetime_between(start_time, end_time) : res
    res.first
  end

  # @param [Time] time
  # @return [Collection]
  def create_collection(time)
    Collection.create(:book => self, :datetime => time)
  end

  # @see `Grouping.grouping_prev_next_times`
  def grouping_prev_next_times(time)
    super
  end

  # Schedules a dirty entry reprocessor
  def schedule_processing
    ScheduleDirtyEntriesReprocessingJob.perform_later self
  end

private

  def constructor
    self.grouping ||= :none
    self.slug = name&.parameterize&.gsub("-", "_") unless slug.present?
  end

  # @return [Integer]
  def latest_shorthand_or_extractor_update
    [latest_shorthand_update, latest_extractor_update].max
  end

  # @return [Integer]
  def latest_shorthand_update
    first_datetime_field(shorthands, :updated_at, :desc)
  end

  # @return [Integer]
  def latest_extractor_update
    first_datetime_field(extractors, :updated_at, :desc)
  end

  # @return [Integer]
  def earliest_entry_processing
    first_datetime_field(entries, :processed_at, :asc)
  end

  # @param [ActiveRecord::Relation] rel
  # @param [Symbol] field
  # @param [Symbol] order
  # @return [Integer]
  def first_datetime_field(rel, field, order)
    rel.order(field => order)
       .first&.send(field)&.to_i || 0
  end
end
