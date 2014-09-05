require 'pry'
require 'pg'
require_relative 'ingredient'

class Recipe

  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end

  def ingredients
    self.class.find_ingredients(id)
  end

####################
#Class Methods
####################

  def self.db_connection
    begin
      connection = PG.connect(dbname: 'recipes')

      yield(connection)

    ensure
      connection.close
    end
  end


  def self.all
    recipes = []
    query = 'SELECT *
    FROM recipes
    WHERE recipes.instructions IS NOT NULL
    ORDER BY recipes.name;'

    data = db_connection do |conn|
      conn.exec(query)
    end

    data.each do |recipe|
      recipes << Recipe.new(recipe["id"], recipe["name"], recipe["instructions"], recipe["description"])
    end
    recipes
  end

  def self.find(id)
    query = 'SELECT *
    FROM recipes
    WHERE recipes.id = $1;'

    recipe = db_connection do |conn|
      conn.exec_params(query, [id])
    end

    instructions = "This recipe doesn't have any instructions."
    description  = "This recipe doesn't have a description."

    if recipe[0]['instructions'] == nil
      instructions = "This recipe doesn't have any instructions."
    else
      instructions = recipe[0]['instructions']
    end
    if recipe[0]['description'] == nil
      description  = "This recipe doesn't have a description."
    else
      description = recipe[0]['description']
    end

    Recipe.new(recipe[0]['id'], recipe[0]['name'], instructions, description)
  end

  def self.find_ingredients(id)
    ingredients = []

    query = 'SELECT * FROM ingredients
    WHERE ingredients.recipe_id = $1;'

    data = db_connection do |conn|
      conn.exec_params(query, [id])
    end
    data.each do |ingredient|
      ingredients << Ingredient.new(ingredient['id'], ingredient['name'], ingredient['recipe_id'])
    end
    ingredients
  end

end

