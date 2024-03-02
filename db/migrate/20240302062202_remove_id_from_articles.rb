class RemoveIdFromArticles < ActiveRecord::Migration[7.1]
    def change
      remove_column :articles, :id, :bigint
    end
end
