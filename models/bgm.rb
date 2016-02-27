ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Bgm < ActiveRecord::Base
    has_many :posts    
end

class Post < ActiveRecord::Base
    belongs_to :bgm
    has_many :users
end

class User < ActiveRecord::Base
    belongs_to :post
end