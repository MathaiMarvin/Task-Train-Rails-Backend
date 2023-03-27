Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

 # user
 post "/user", to:"users#register"
 post"/user/login", to:"users#login"
 get "/user/login/check", to:"users#check_login_status"
 delete "/user/logout", to:"users#logout"


# Todos

post '/todos', to: 'todos#create'
post "todos/:id", to: 'todos#update'
delete"todos/:id", to:"todos#destroy"
get"todos", to:"todos#index"

# Verify auth

get '/verify', to: 'application#verify_auth'
end
