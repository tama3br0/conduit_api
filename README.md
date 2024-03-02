# API ステップ1の実装手順

## 準備

### Railsの構築
```bash
rails new . --api
```

### コントローラの作成
```bash
rails g controller articles
```

- 中の処理については後述


### モデルの作成
```bash
rails g model Article
```

- モデルを作成後、マイグレーションファイルに記述
```rb
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
```

- 思い切ってidカラムを削除
```rb
class RemoveIdFromArticles < ActiveRecord::Migration[7.1]
    def change
      remove_column :articles, :id, :bigint
    end
end
```

- 最後に
```bash
rails db:migrate
```

## CORSとCSRFの解除

- Gemfile
    - gem "rack-cors"のコメントアウトを外す
    - bundle install

- /config/initializers/cors.rb（ない場合は作成）
    - 次の内容のコメントアウトを外す or 書いていなければ実装
```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

- /config/environments/development.rb
  - 次の一文を追記
```rb
  config.action_controller.forgery_protection_origin_check = false #=>追記
```

- app/controllers/application_controller.rb
   - 次の一文を追記
```rb
class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session  #=> これを記述することで、CSRFを解除！
end
```

- app/controllers/api/articles_controller.rb
  - 次の一文を追記
```rb
class Api::ArticlesController < ApplicationController

    skip_before_action :verify_authenticity_token   #=> これを記述することで、CSRFを解除！

    # 中の処理は後述
end
```

## step1の実装

### 1. 次のエンドポイントを設定する
  - GET /api/articles/:slug
  - POST /api/articles
  - PUT /api/articles/:slug
  - DELETE /api/articles/:slug

```rb routes.rb
Rails.application.routes.draw do
    namespace :api do
        resources :articles, param: :slug, only: [:create, :show, :update, :destroy]
    end
end
```

### 2. Createアクションの作成
```json
{
  "article": {
    "title": "How to train your dragon",
    "description": "Ever wonder how?",
    "body": "You have to believe",
  }
}
```

次のような内容でPOSTしたときに、下のような内容を返すようにする

```json
{
  "article": {
    "slug": "how-to-train-your-dragon",
    "title": "How to train your dragon",
    "description": "Ever wonder how?",
    "body": "It takes a Jacobian",
    "createdAt": "2016-02-18T03:22:56.637Z",
    "updatedAt": "2016-02-18T03:48:35.824Z",
  }
}
```

- 確認するポイント
  - ポストした内容以上のものが返ってきている(slug, createdAt, updatedAt)
  - idではなく、slugで管理されている
  - slugは、titleを全て小文字にして-でつないだ状態になっている

```rb articles_controller.rb
class Api::ArticlesController < ApplicationController
    skip_before_action :verify_authenticity_token   #=> これを記述することで、CSRFを解除！

    def create
        @article = Article.new(article_params)
        if @article.save
            render json: { article: @article.to_custom_json }, status: :created
        else
            render json: @article.errors, status: :unprocessable_entity
        end
    end

    private

    def article_params
        params.require(:article).permit(:slug, :title, :description, :body)
    end
end
```

### 3. Articleモデルの実装

- 実装するポイント
  - コントローラにあるto_custom_jsonメソッドの実装
  - 主キーがslugであることを明記
  - POSTしたときに、slugとcreatedAtとupdatedAtを自動で生成するようにする

```rb :article.rb
class Article < ApplicationRecord

    self.primary_key = "slug" #=> 最終的に、これを追記して期待通り動いた

    before_validation :generate_slug, if: -> { title.present? && slug.blank? }
    before_validation :update_slug, if: -> { title_changed? && !new_record? }

    def to_custom_json
        {
            slug: self.slug || title.parameterize,
            title: self.title,
            description: self.description,
            body: self.body,
            createdAt: self.created_at || Time.current,
            updatedAt: self.updated_at || Time.current
        }
    end

    def generate_slug
        self.slug = title.parameterize
    end

    def update_slug
        new_slug = title.parameterize
        if self.class.exists?(slug: new_slug) && self.slug != new_slug
            errors.add(:title, "has already been taken")
        else
            self.slug = new_slug
        end
    end
end
```

