Rails.application.routes.draw do
  root 'image_post#index'
  put 'image_post/refresh', path: '/refresh/', as: 'refresh'
end
