DenCesty::Application.routes.draw do

	devise_for :walkers

	resource :registration

	match 'report/new' => "report#new", :as => :new_report
	match 'report/edit' => "report#edit", :as => :edit_report
	match 'report/show' => "report#show", :as => :show_report
	match 'contacts' => 'pages#contacts', :as => :pages_contacts
	match 'actual' => "pages#actual", :as => :walker_root
	match 'rules' => 'pages#rules', :as => :pages_rules
	match 'hall_of_glory' => 'pages#hall_of_glory', :as => :pages_hall_of_glory
	match 'recommendations' => 'pages#recommendations', :as => :pages_recommendations
	match 'jar12_16' => 'pages#jar12_16', :as => :pages_jar12_16
  match 'pod12_17' => 'pages#pod12_17', :as => :pages_pod12_17
	match 'forum' => 'pages#forum', :as => :pages_forum
	match 'admin/add_report', :as => :admin_add_report
	match 'admin/print_list', :as => :admin_print_list
	match 'admin/walker_list', :as => :admin_walker_list
	match 'admin/results_update', :as => :admin_results_update
	match 'admin/results_setting(.:id)' => 'admin#results_setting', :as => :admin_results_setting
	match 'profile' => "walkers#profile", :as => :walker_profile
	match ':controller(/:action(/:id))'
	match ':action' => 'static#:action'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
	root :to => 'pages#actual'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
