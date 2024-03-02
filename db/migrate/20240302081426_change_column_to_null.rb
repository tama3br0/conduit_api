
class ChangeColumnToNull < ActiveRecord::Migration[7.1]
    def up
        # Not Null制約を外す場合　not nullを外したいカラム横にtrueを記載
        change_column_null(:articles, :title, true)
        change_column_null(:articles, :description, true)
        change_column_null(:articles, :body, true)
        change_column_null(:articles, :created_at, true)
        change_column_null(:articles, :updated_at, true)
    end

    def down
        change_column_null(:articles, :title, false)
        change_column_null(:articles, :description, false)
        change_column_null(:articles, :body, false)
        change_column_null(:articles, :created_at, false)
        change_column_null(:articles, :updated_at, false)
    end
end
