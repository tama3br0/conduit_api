class Article < ApplicationRecord

    self.primary_key = 'slug'

    before_validation :generate_slug, if: -> { title.present? && slug.blank? }
    before_validation :update_slug, if: -> { title_changed? && !new_record? }

    # def to_custom_json
    #     self.attributes.merge({                     # 記事オブジェクトの属性を含むハッシュを返します。これには、データベースの各列に対応する属性が含まれます（例: title、description、body、created_at、updated_atなど）。
    #              slug: self.title.parameterize,     # slug キーには、記事のタイトルから派生したスラッグがセットされます。parameterize メソッドは、文字列をURLに適した形式に変換します。この場合、記事のタイトルがスペースなどの特殊文字を含んでいる場合、それらをハイフンなどのURLに適した文字に変換します。
    #         createdAt: self.created_at,             # createdAt キーには、記事の作成日時がセットされます。created_at メソッドは、記事が作成された日時を返します。
    #         updatedAt: self.updated_at              # updatedAt キーには、記事の更新日時がセットされます。updated_at メソッドは、記事が最後に更新された日時を返します。
    #     })
    # end

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