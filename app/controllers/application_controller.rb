require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    #your code here
    if params[:username].blank? || params[:password].blank?
      redirect "/failure"
    else
      user = User.new(:username => params[:username], :password => params[:password])
      if user.save
        redirect "/login"
      else
        redirect "/failure"
      end
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    @balance = @user.balance.nil? ? 0 : @user.balance
    # binding.pry
    erb :account
  end

  post "/deposit" do
    @user = current_user
    @balance = user_balance
    @user.balance = @balance + params[:deposit_amount].to_i
    @user.save
    # binding.pry
    redirect "/account"
  end
  
  post "/withdraw" do
    @user = current_user
    @balance = user_balance
    @withdrawal = params[:withdrawal_amount].to_i
    if @user.sufficient_funds?(@withdrawal)
      @user.balance = @balance - @withdrawal
      # binding.pry
      @user.save
      redirect "/account"
    else
      redirect "/failure"
    end
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    if params[:username].blank?
      redirect "/failure"
    else
      user = User.find_by(:username => params[:username])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect "/account"
      else
        redirect "/failure"
      end 
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end

    def user_balance
      current_user.balance.nil? ? 0 : @user.balance
    end
  end

end
