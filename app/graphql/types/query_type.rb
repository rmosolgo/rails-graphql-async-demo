# frozen_string_literal: true
require "net/http"

class ActiveRecord::ConnectionAdapters::ConnectionPool
  def my_stat
    synchronize do
      {
        # size: size,
        connections: @connections.size,
        in_use: @connections.select(&:in_use?).map(&:object_id),
        owner_alive: @connections.select { |c| c.owner&.alive? }.map(&:object_id),
        owner: @connections.map { |c| c.owner },
        # current_context: ActiveSupport::IsolatedExecutionState.context,
        # busy: @connections.count { |c| c.in_use? && c.owner.alive? },
        # dead: @connections.count { |c| c.in_use? && !c.owner.alive? },
        # idle: @connections.count { |c| !c.in_use? },
        waiting: num_waiting_in_queue,
      }
    end
  end
end
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
      # pp ActiveRecord::Base.connection_pool.my_stat
      Card.where(set: set).count(:*)
    end

    field :local_dataloader_count, Int do
      argument :set, String
    end

    def local_dataloader_count(set:)
      dataloader.with(Sources::LocalSet, set.first(3)).load(:count)
    end

    field :test_error, String
    def test_error
      raise AsyncGraphqlDemoSchema::TestError
    end
  end
end
