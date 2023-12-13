data = JSON.parse(File.read("db/oracle-cards-20231213100137.json"))
puts "Removing old cards..."
Card.destroy_all
sets_to_save = [
  "zen",
  "lrw",
  "shm",
  "m10",
]
puts "Creating new cards..."
data.each do |card_json|
  if sets_to_save.include?(card_json["set"])
    puts "Creating #{card_json["name"].inspect}"
    Card.create!(
      name: card_json["name"],
      set: card_json["set"],
      cmc: card_json["cmc"],
      mana_cost: card_json["mana_cost"],
    )
  end
end
