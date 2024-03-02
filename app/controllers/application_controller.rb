class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session  #=> これを記述することで、CSRFを解除！
end
