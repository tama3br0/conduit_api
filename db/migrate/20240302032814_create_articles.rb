class CreateArticles < ActiveRecord::Migration[7.1]

    def change
        create_table :articles, id: :string do |t|
            t.string :slug, null: false
            t.string :title
            t.string :description
            t.text :body
            t.timestamps
        end
        add_index :articles, :slug, unique: true
    end
end
