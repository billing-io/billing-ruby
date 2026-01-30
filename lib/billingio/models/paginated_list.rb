# frozen_string_literal: true

module BillingIO
  # Generic cursor-paginated list returned by all list endpoints.
  #
  # @attr_reader data        [Array]        items on the current page
  # @attr_reader has_more    [Boolean]      whether more pages exist
  # @attr_reader next_cursor [String, nil]  opaque cursor for the next page
  class PaginatedList
    include Enumerable

    attr_reader :data, :has_more, :next_cursor

    # @param data        [Array]        deserialized model instances
    # @param has_more    [Boolean]      pagination flag
    # @param next_cursor [String, nil]  cursor for fetching the next page
    def initialize(data:, has_more:, next_cursor:)
      @data        = data
      @has_more    = has_more
      @next_cursor = next_cursor
    end

    # Iterate over items on the current page.
    def each(&block)
      @data.each(&block)
    end

    # Number of items on the current page.
    def size
      @data.size
    end
    alias_method :length, :size

    # @return [Boolean]
    def has_more?
      @has_more
    end

    # Build a PaginatedList from a raw API response hash.
    #
    # @param hash      [Hash]  raw response body with "data", "has_more", "next_cursor"
    # @param model_cls [Class] model class that responds to +.from_hash+
    # @return [BillingIO::PaginatedList]
    def self.from_hash(hash, model_cls)
      items = (hash["data"] || []).map { |item| model_cls.from_hash(item) }
      new(
        data:        items,
        has_more:    hash["has_more"] || false,
        next_cursor: hash["next_cursor"]
      )
    end

    def inspect
      "#<BillingIO::PaginatedList size=#{size} has_more=#{@has_more.inspect}>"
    end
  end
end
