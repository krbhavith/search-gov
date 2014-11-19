require 'sanitize'

class Api::SearchOptions
  include ActiveModel::Validations

  LIMIT_RANGE = (1..50).freeze
  DEFAULT_LIMIT = 20
  LIMIT_ERROR_MESSAGE = "must be between #{LIMIT_RANGE.first} and #{LIMIT_RANGE.last}".freeze

  OFFSET_RANGE = (0..1000).freeze
  DEFAULT_OFFSET = 0
  OFFSET_ERROR_MESSAGE = "must be between #{OFFSET_RANGE.first} and #{OFFSET_RANGE.last}".freeze

  attr_accessor :access_key,
                :affiliate,
                :highlighting,
                :limit,
                :offset,
                :query,
                :site

  validates_presence_of :access_key,
                        :affiliate,
                        :query,
                        message: 'must be present'

  validates_length_of :query,
                      maximum: Search::MAX_QUERYTERM_LENGTH

  validates_inclusion_of :limit,
                         within: LIMIT_RANGE,
                         message: LIMIT_ERROR_MESSAGE

  validates_inclusion_of :offset,
                         within: OFFSET_RANGE,
                         message: OFFSET_ERROR_MESSAGE

  validate :must_have_valid_affiliate,
           :must_have_valid_access_key,
           on: :affiliate

  def self.human_attribute_name(attribute_key_name, _options = {})
    attribute_key_name.to_s
  end

  def initialize(params = {})
    self.access_key = params[:access_key]
    self.affiliate = params[:affiliate]

    self.highlighting = is_highlighting_enabled?(
      params[:enable_highlighting])

    limit = params[:limit]
    self.limit = limit.present? ? limit.to_i : DEFAULT_LIMIT

    offset = params[:offset]
    self.offset = offset.present? ? offset.to_i : DEFAULT_OFFSET

    self.query = Sanitize.clean(params[:query].to_s).
      gsub(/[[:space:]]/, ' ').squish
  end

  def attributes
    { access_key: access_key,
      affiliate: site,
      highlighting: highlighting,
      limit: limit,
      next_offset_within_limit: next_offset_within_limit?,
      offset: offset,
      query: query }
  end

  def next_offset_within_limit?
    limit + offset < OFFSET_RANGE.last
  end

  protected

  def is_highlighting_enabled?(enable_highlighting)
    enable_highlighting.nil? || !(enable_highlighting == 'false')
  end

  def must_have_valid_affiliate
    return unless affiliate.present?
    self.site = Affiliate.find_by_name affiliate
    errors.add(:base, 'affiliate not found') unless site
  end

  def must_have_valid_access_key
    return unless site
    errors.add(:base, 'access_key is invalid') unless site.api_access_key == access_key
  end
end