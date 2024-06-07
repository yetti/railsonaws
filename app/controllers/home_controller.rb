class HomeController < ApplicationController
  def index
    @user = User.find_by!(name: 'Yetti')
  end
end
