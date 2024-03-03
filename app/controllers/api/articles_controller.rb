class Api::ArticlesController < ApplicationController

    skip_before_action :verify_authenticity_token   #=> これを記述することで、CSRFを解除！

    before_action :set_article, only: [:show, :update, :destroy]

    def show
        @article = Article.find_by!(slug: params[:slug])
        render json: @article
    end

    # def create
    #     puts "aaaa"
    #     @article = Article.new(article_params)
    #     puts "bbbb"
    #     pp @article.to_custom_json

    #     if @article.save
    #         # render json: {                             => この部分をモデルarticle.rbにto_jsonというメソッドで定義して呼び出すようにリファクタリング
    #         #     article: @article.attributes.merge({
    #         #         slug: @article.title.parameterize,
    #         #         createdAt: @article.created_at,
    #         #         updatedAt: @article.updated_at
    #         #     })
    #         #   }, status: :created

    #         render json: { article: @article.to_custom_json }, status: :created
    #     else
    #         render json: @article.errors, status: :unprocessable_entity
    #     end
    # end

    def create
        @article = Article.new(article_params)
        if @article.save
            render json: { article: @article.to_custom_json }, status: :created
        else
            render json: @article.errors.full_messages, status: :unprocessable_entity
        end
    end

    # PUT /api/articles/:slug
    def update
        if @article.update(article_params)
            render json: { article: @article.to_custom_json }, status: :ok
        else
            render json: @article.errors.full_messages, status: :unprocessable_entity
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
