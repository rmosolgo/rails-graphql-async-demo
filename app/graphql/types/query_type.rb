# frozen_string_literal: true
require "net/http"
module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, null: true], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ID], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :remote_card_count, Int do
      argument :set, String
    end

    def remote_card_count(set:)
      Rails.logger.debug("Starting: #{set}")
      set = set.first(3)
      res = Net::HTTP.get(URI("https://api.scryfall.com/cards/search?q=set:#{set}"))
      data = JSON.parse(res)
      Rails.logger.debug("Finished: #{set}")
      data["total_cards"]
    end

    field :remote_dataloader_count, Int do
      argument :set, String
    end

    def remote_dataloader_count(set:)
      dataloader.with(Sources::RemoteSet, set.first(3)).load(:count)
    end


    field :local_count, Int do
      argument :set, String
    end

    def local_count(set:)
      c = nil
      puts "Started #{set.inspect}"
      c = Card.where(set: set).count(:*)
      puts "Finished #{set.inspect}"
      c
    end

    field :local_dataloader_count, Int do
      argument :set, String
    end

    def local_dataloader_count(set:)
      dataloader.with(Sources::LocalSet, set.first(3)).load(:count)
    end
  end
end
