class Sources::LocalSet < GraphQL::Dataloader::Source
  def initialize(set)
    @set = set
  end

  def fetch(_ids)
    raise(ArgumentError, _ids) unless _ids == [:count]
    Rails.logger.debug("Started #{self.class} / #{@set}")
    count = Card.where(set: @set).count(:*)
    Rails.logger.debug("Finished #{self.class} / #{@set}")
    [count]
  end
end
