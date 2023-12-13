class Sources::RemoteSet < GraphQL::Dataloader::Source
  def initialize(set)
    @set = set
  end

  def fetch(_ids)
    raise(ArgumentError, _ids) unless _ids == [:count]
    Rails.logger.debug("Started #{self.class} / #{@set}")
    res = Net::HTTP.get(URI("https://api.scryfall.com/cards/search?q=set:#{@set}"))
    data = JSON.parse(res)
    Rails.logger.debug("Finished #{self.class} / #{@set}")
    [data["total_cards"]]
  end
end
