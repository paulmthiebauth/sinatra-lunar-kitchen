require 'pg'
require 'pry'
require_relative 'ingredient'

def db_connection
  begin
    connection = PG.connect(dbname: "recipes")
    yield(connection)
  ensure
    connection.close
  end
end


class Recipe

  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description
    @ingredients = []
  end

  #calling .id on something will grab the recipe id of that item
  def id
    @id
  end

  #calling .name on something will grab the recipe name of that item
  def name
    @name
  end

  def instructions
    @instructions
  end

  def description
    @description
  end

  def ingredients
    @ingredients
  end

  def self.all
    recipe_list = []
    db_connection do |conn|
      conn.exec("SELECT * FROM recipes;").map do |row|
        recipe_list << Recipe.new(row["id"], row["name"], nil, nil)
      end
    end
    recipe_list
  end

  def self.find(id)
    recipe = nil
    db_connection do |conn|
      result = conn.exec_params("SELECT * FROM RECIPES WHERE ID = $1;", [id])
          recipe = Recipe.new(result[0]["id"], result[0]["name"], result[0]["instructions"], result[0]["description"])
      end

    db_connection do |conn|
      conn.exec_params("SELECT * FROM INGREDIENTS WHERE RECIPE_ID = $1;", [id]).map do |row|
        recipe.ingredients << Ingredient.new(row["name"])
      end
    end

    recipe
  end

end
