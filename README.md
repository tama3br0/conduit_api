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


# class CreateArticles < ActiveRecord::Migration[7.1]:
# この行は、CreateArticlesという新しいマイグレーションクラスを定義しています。
# これはActiveRecord::Migrationから継承されており、[7.1]はこのマイグレーションが対応しているRailsバージョンを指定しています。

# def change:
# この行は、changeメソッドの定義を始めます。
# changeメソッドはRailsのマイグレーションで提供される特別なメソッドであり、データベースのスキーマに適用する変更を定義します。

    # create_table :articles, id: :string do |t|:
    # この行は、データベーススキーマに新しいテーブルarticlesを作成します。
    # id: :stringのオプションは、このテーブルの主キーがstring型であることを指定します。
    # do |t|ブロックは、カラムの定義が提供されるブロックを開きます。
    # tは、作成されているテーブルを表すActiveRecord::ConnectionAdapters::TableDefinitionのインスタンスです。

        # t.string :slug, null: false:
        # この行は、articlesテーブルにslugという名前のカラムを追加します。
        # データ型は文字列型で、null: falseのオプションは、このカラムがnull値を含めないことを指定します。

    # add_index :articles, :slug, unique: true:
    # この行は、articlesテーブルのslugカラムにインデックスを追加します。
    # インデックスは、データベーステーブルのクエリの速度を向上させるために使用されます。
    # unique: trueオプションは、slugカラムの値がテーブル内のすべての行で一意であることを指定します。
```

- 思い切ってidカラムを削除
```rb
class RemoveIdFromArticles < ActiveRecord::Migration[7.1]
    def change
      remove_column :articles, :id, :bigint
    end
end

# remove_column :articles, :id, :bigint:
# この行は、articlesテーブルからidカラムを削除します。
# :bigintはこのカラムのデータ型を指定します。
# 通常、Railsではデフォルトでidカラムは自動的に追加されるため、このマイグレーションはデフォルトの挙動を変更し、idカラムを明示的に削除することを意味します。
```

- 最後に
```bash
rails db:migrate
```

```rb
ActiveRecord::Schema[7.1].define(version: 2024_03_02_081426) do
    create_table "articles", id: false, force: :cascade do |t|
        t.string "slug", null: false
        t.string "title"
        t.string "description"
        t.text "body"
        t.datetime "created_at"
        t.datetime "updated_at"
        t.index ["slug"], name: "index_articles_on_slug", unique: true
    end
end


# create_table "articles", id: false, force: :cascade do |t|:
# この行は、articlesというテーブルを作成します。
# id: falseオプションは、このテーブルにデフォルトのプライマリキーを追加しないことを意味します。
# force: :cascadeは、このテーブルが存在する場合には削除して再作成することを指定します。

    # t.string "slug", null: false:
    # この行は、articlesテーブルにslugという名前の文字列型のカラムを追加します。
    # null: falseは、このカラムがnull値を許可しないことを意味します。

    # t.index ["slug"], name: "index_articles_on_slug", unique: true:
    # この行は、articlesテーブルのslugカラムにインデックスを追加します。
    # インデックスはクエリのパフォーマンスを向上させるために使用されます。
    # name: "index_articles_on_slug"はインデックスの名前を指定し、unique: trueはこのインデックスが一意であることを指定します。
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


# Rails.application.config.middleware.insert_before 0, Rack::Cors do:
# この行は、Railsアプリケーションのミドルウェアスタックの先頭（0番目）にRack::Corsを挿入することを指定します。
# Rack::Corsは、CORSポリシーを実装するためのRackミドルウェアです。

# allow do:
# この行は、CORSポリシーで許可を指定するためのブロックを開始します。

    # origins "*":
    # この行は、すべてのオリジンからのリクエストを許可します。*はワイルドカードであり、すべてのオリジンを表します。

    # resource "*",:
    # この行は、すべてのリクエストに対するリソースの設定を指定します。*はすべてのリソースを表します。

    # headers: :any,:
    # この行は、すべてのヘッダーを許可します。

    # methods: [:get, :post, :put, :patch, :delete, :options, :head]:
    # この行は、許可されるHTTPメソッドを指定します。
    # ここでは、GET、POST、PUT、PATCH、DELETE、OPTIONS、HEADがすべてのリクエストに対して許可されています。
```

- /config/environments/development.rb
  - 次の一文を追記
```rb
  config.action_controller.forgery_protection_origin_check = false #=>追記

#   CSRF保護のオリジンチェックを無効にする設定を行っています。
#   この設定により、Railsはリクエストのオリジンをチェックせず、全てのリクエストを許可します。
```

- app/controllers/application_controller.rb
   - 次の一文を追記
```rb
class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session  #=> これを記述することで、CSRFを解除！
end

# この設定により、CSRFトークンがない場合にはセッションをnullに設定し、リクエストを処理します。
# これにより、CSRFトークンがない場合にセッションエラーが発生するのを防ぎ、APIなどでのリクエスト処理を簡略化することができます。
```

- app/controllers/api/articles_controller.rb
  - 次の一文を追記
```rb
class Api::ArticlesController < ApplicationController
    skip_before_action :verify_authenticity_token   #=> これを記述することで、CSRFを解除！
    # 中の処理は後述
end

# verify_authenticity_tokenという名前のアクションフィルターをスキップします。
# このアクションフィルターは、リクエストが有効なCSRFトークンを含んでいるかどうかを検証します。
# したがって、この設定によりCSRFトークンの検証が無効化され、CSRF保護が解除されます。
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

# namespace :api do:
# この行は、apiという名前空間を定義します。名前空間を使用することで、ルーティングを階層化して整理することができます。
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


# class Api::ArticlesController < ApplicationController:
# この行は、Api::ArticlesControllerという名前のコントローラーを定義しています。
# Api::は名前空間を表し、ArticlesControllerはこのコントローラーの名前です。ApplicationControllerを継承しています。

# skip_before_action :verify_authenticity_token:
# この行は、CSRF（Cross-Site Request Forgery）保護を無効にするための設定を行っています。
# CSRF保護を無効にすることで、APIエンドポイントに対するリクエストがCSRFトークンの検証を受けなくなります。

    # @article = Article.new(article_params):
    # この行は、送信されたデータを使用して新しい記事オブジェクトを作成しています。
    # article_paramsメソッドを使用して、許可されたパラメーターのみが使用されます。

    # if @article.save:
    # この行は、記事オブジェクトの保存が成功したかどうかをチェックしています。
    # 成功した場合は、新しい記事のJSON表現を返し、ステータスコードとしてcreated（201）を返します。

    # render json: { article: @article.to_custom_json }, status: :created:
    # この行は、@articleオブジェクトのカスタムJSON表現を返します。
    # status: :createdは、リクエストが成功し、新しいリソースが作成されたことを示します。

    # render json: @article.errors, status: :unprocessable_entity:
    # この行は、記事の保存に失敗した場合に、エラーメッセージとともにunprocessable_entity（422）ステータスコードを返します。

# def article_params:
# この行は、許可された記事のパラメーターを定義するためのメソッドを定義しています。

    # params.require(:article).permit(:slug, :title, :description, :body):
    # この行は、Strong Parametersを使用して、クライアントから受信したデータのうち、許可されたパラメーターのみを抽出します。
    # これにより、不正なデータが送信された場合でも、コントローラーが保護されます。
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

# self.primary_key = "slug":
# この行は、Articleモデルのプライマリキーをslugカラムに設定しています。
# これにより、データベースのレコードはslugカラムの値で一意に識別されます。

# before_validation :generate_slug, if: -> { title.present? && slug.blank? }:
# この行は、バリデーションが行われる前に、titleが存在し、slugが空である場合にgenerate_slugメソッドを呼び出します。
# つまり、新しい記事が作成される際に、slugが自動的に生成されます。

# before_validation :update_slug, if: -> { title_changed? && !new_record? }:
# この行は、バリデーションが行われる前に、titleが変更され、かつ新しいレコードではない場合にupdate_slugメソッドを呼び出します。
# これにより、既存の記事が更新された場合に、slugが自動的に更新されます。


# def to_custom_json:
# この行から始まるブロックは、カスタムのJSON表現を定義するためのメソッドです。
# このメソッドは、ArticleオブジェクトをJSON形式に変換して返します。
# また、created_atとupdated_atがnilの場合に、現在の時間を使用します。

#     slug: self.slug || title.parameterize:
#     self.slugが存在すればそれを、存在しなければtitle.parameterize（タイトルをURLに適した形式に変換したもの）を使用します。

#     title: self.title:
#     記事のタイトルを返します。

#     description: self.description:
#     記事の説明を返します。

#     body: self.body:
#     記事の本文を返します。

#     createdAt: self.created_at || Time.current:
#     記事の作成日時を返します。self.created_atが存在しない場合は現在の時間（Time.current）を使用します。

#     updatedAt: self.updated_at || Time.current:
#     記事の更新日時を返します。self.updated_atが存在しない場合は現在の時間（Time.current）を使用します。



# def generate_slug:
# この行から始まるブロックは、generate_slugメソッドを定義しています。

#     self.slug = title.parameterize:
#     titleをURLに適した形式に変換して、slugに代入します。


# def update_slug:
# このメソッドは、titleが変更された場合にslugを更新します。

#     new_slug = title.parameterize:
#     変更されたtitleをURLに適した形式に変換して、new_slugに代入します。

#     if self.class.exists?(slug: new_slug) && self.slug != new_slug:
#     new_slugと同じ値を持つ記事が既に存在し、かつ現在のslugと異なる場合には、エラーを追加します。
#     それ以外の場合は、new_slugをslugに代入します。

#    errors.add(:title, "has already been taken"):
#    この行は、エラーオブジェクトに新しいエラーメッセージを追加しています。
#    :titleはエラーが発生した属性（フィールド）を示し、"has already been taken"はエラーメッセージです。
#    つまり、titleが既に存在する値と重複している場合にエラーを追加します。

#    self.slug = new_slug:
#    この行は、new_slugの値をslugに代入しています。
#    これは、titleが変更された場合に新しいslugを設定するための処理です。
#    重複がない場合にのみslugを更新します。

```

### 4. コントローラにアクションを追加

```rb
class Api::ArticlesController < ApplicationController

    skip_before_action :verify_authenticity_token   #=> これを記述することで、CSRFを解除！

    before_action :set_article, only: [:show, :update, :destroy]

    def show
        @article = Article.find_by!(slug: params[:slug])
        render json: @article
    end

    def create
        @article = Article.new(article_params)
        if @article.save
            render json: { article: @article.to_custom_json }, status: :created
        else
            render json: @article.errors, status: :unprocessable_entity
        end
    end

    def update
        pp @article.to_custom_json
        if @article.update(article_params)
            render json: { article: @article.to_custom_json }, status: :ok
        else
            render json: @article.errors, status: :unprocessable_entity
        end
    end

    def destroy
        @article.destroy
        head :no_content
    end

    private

    def set_article
        @article = Article.find_by!(slug: params[:slug])
    end

    def article_params
        params.require(:article).permit(:slug, :title, :description, :body)
    end
end


# class Api::ArticlesController < ApplicationController:
# この行は、Api::ArticlesControllerという名前のコントローラーを定義し、ApplicationControllerを継承しています。
# これにより、他のコントローラーと同様にRailsアプリケーションのコントローラーとして機能します。

# skip_before_action :verify_authenticity_token:
# この行は、CSRF（Cross-Site Request Forgery）保護を無効にするための設定を行っています。
# これにより、CSRFトークンの検証がスキップされ、APIエンドポイントに対するリクエストが処理されます。

# before_action :set_article, only: [:show, :update, :destroy]:
# この行は、set_articleメソッドをshow、update、destroyアクションの前に実行するように指定しています。
# これにより、これらのアクション内で@articleを設定する必要がなくなります。

# def show:
# この行から始まるブロックは、記事を表示するためのアクションメソッドを定義しています。

#     @article = Article.find_by!(slug: params[:slug]):
#     slugパラメーターに基づいて記事を検索し、見つからない場合はエラーを発生させます。

#     render json: @article:
#     記事オブジェクトをJSON形式でレスポンスとして返します。

# def create:
# この行から始まるブロックは、新しい記事を作成するためのアクションメソッドを定義しています。

#     @article = Article.new(article_params):
#     article_paramsメソッドを使用して、送信されたデータから新しい記事オブジェクトを作成します。

#     if @article.save:
#     記事の保存が成功した場合の処理を行います。

#     render json: { article: @article.to_custom_json }, status: :created:
#     保存された記事をカスタムJSON形式でレスポンスとして返します。

# def update:
# この行から始まるブロックは、記事を更新するためのアクションメソッドを定義しています。

#     @article = Article.find_by!(slug: params[:slug]):
#     slugパラメーターに基づいて記事を検索し、見つからない場合はエラーを発生させます。

#     if @article.update(article_params):
#     記事の更新が成功した場合の処理を行います。

#     render json: { article: @article.to_custom_json }, status: :ok:
#     更新された記事をカスタムJSON形式でレスポンスとして返します。

# def destroy:
# この行から始まるブロックは、記事を削除するためのアクションメソッドを定義しています。

#     @article.destroy:
#     記事を削除します。

#     head :no_content:
#     レスポンスヘッダーを返しますが、レスポンスボディは空です。

# private:
# この行から始まるブロックは、プライベートメソッドを定義しています。

# def set_article:
# この行から始まるブロックは、@articleインスタンス変数を設定するためのメソッドを定義しています。

#     @article = Article.find_by!(slug: params[:slug]): slug
#     パラメーターに基づいて記事を検索し、見つからない場合はエラーを発生させます。

# def article_params:
# この行から始まるブロックは、許可された記事のパラメーターを取得するためのメソッドを定義しています。

#     params.require(:article).permit(:slug, :title, :description, :body):
#     paramsからarticleキーに対応する値を取得し、指定された属性のみを許可します。
```