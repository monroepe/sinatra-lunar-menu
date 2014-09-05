require 'pry'
require 'pg'

class Recipe

  attr_reader :id, :name, :instructions, :description

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
  end

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


end

