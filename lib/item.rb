class Item
  attr_reader :name, :type, :damage, :defense, :abilities

  def initialize(data)
    @name = data['name']
    @type = data['type']
    @damage = data['damage'] || 0
    @defense = data['defense'] || 0
    @abilities = data['abilities'] || []
  end

  def use(target)
    # Implement item usage logic
  end
end
