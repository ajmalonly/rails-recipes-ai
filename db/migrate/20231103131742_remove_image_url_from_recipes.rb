class RemoveImageUrlFromRecipes < ActiveRecord::Migration[7.1]
  def change
    remove_column :recipes, :image_url, :string
  end
end
