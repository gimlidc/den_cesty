DenCesty::Application.routes.draw do

  get "outgrowths/show"
  get "outgrowths/race_record" => 'outgrowths/race_record', :as => :gpx, via: [:get]

  resources :dcs

	devise_for :walkers, controllers: {
	  registrations: 'walkers'
	}
	#resources :walkers, :only => [:index, :edit]

	resource :registration
	
	resource :dc
	
  resources :races do
    resources :scoreboard, :only => [:index, :destroy]
    resources :checkpoints, :only => [:index, :new, :create, :edit, :update, :import, :destroy]
  end
  match 'races/:race_id/checkpoints/import' => 'checkpoints#import', :as => :import_race_checkpoint, via: [:get]
  match 'races/:race_id/checkpoints/upload' => 'checkpoints#upload', via: [:post]
  match 'races/:race_id/checkpoints/map' => 'checkpoints#map', :as => :map_race_checkpoints, via: [:get]
  resources :map, :only => [:show]

	#match 'walkers/edit' => "walkers#edit", :as => :edit_walker
	#match 'walkers/:id' => 'walkers#show', :as => :show_walker, via: [:get]
  match 'registrations/change_owner' => "registrations#change_owner", :as => :change_owner, via: [:get]
  match 'registrations/unregister/(/:id)' => "registrations#unregister", :as => :unregister, via: [:delete]
	match 'report/new' => "report#new", :as => :new_report, via: [:get]	
	match 'report/edit' => "report#edit", :as => :edit_report, via: [:get]	
	match 'report/show' => "report#show", :as => :show_report, via: [:get]	
	match 'report/list' => "report#list", :as => :report_list, via: [:get]
	match 'report/save' => "report#save", :as => :report_patch, via: [:patch]
	match 'tracker_info' => "pages#tracker_info", :as => :tracker_info, via: [:get]
	match 'running_results(/:id)' => "pages#running_results", :as => :running_results, via: [:get]
	match 'contacts' => 'pages#contacts', :as => :pages_contacts, via: [:get]
	match 'actual' => "pages#actual", :as => :walker_root, via: [:get]
	match 'rules' => 'pages#rules', :as => :pages_rules, via: [:get]	
	match 'hall_of_glory' => 'pages#hall_of_glory', :as => :pages_hall_of_glory, via: [:get]
	match 'statistics' => 'pages#statistics', :as => :pages_statistics, via: [:get]
	match 'history' => 'pages#history', :as => :pages_history, via: [:get]
	match 'dc_results' => "pages#dc_results", :as => :dc_results, via: [:get]
	match 'walker_results' => "pages#walker_results", :as => :walker_results, via: [:get]
	match 'recommendations' => 'pages#recommendations', :as => :pages_recommendations, via: [:get]
	match 'jar12_16' => 'pages#jar12_16', :as => :pages_jar12_16, via: [:get]
  match 'pod12_17' => 'pages#pod12_17', :as => :pages_pod12_17, via: [:get]  
	match 'forum' => 'pages#forum', :as => :pages_forum, via: [:get]
	match 'outgrowths/show' => 'outgrowths#show', :as => :outgrowths, via: [:get]
  match 'outgrowths/compare/(/:id)' => 'outgrowths#compare', :as => :outgrowths_compare, via: [:get]
	match 'admin/add_report', :as => :admin_add_report, via: [:get]
	match 'admin/register/(/:id)' => 'admin#register', :as => :admin_register, via: [:get]
	match 'admin/registered', :as => :admin_registered, via: [:get]
  match 'admin/register_do', :as => :admin_register_do, via: [:patch]
	match 'admin/cleanup_unpaid_textile', :as => :admin_cleanup_unpaid_textile, via: [:get]
	match 'admin/cleanup_unpaid_maps', :as => :admin_cleanup_unpaid_maps, via: [:get]
	match 'admin/payment_notification', :as => :admin_payment_notification, via: [:get]
	match 'admin/make_distance_official', via: [:get]
	match 'admin/print_list', :as => :admin_print_list, via: [:get]	
	match 'admin/walker_list', :as => :admin_walker_list, via: [:get]	
	match 'admin/walker_destroy', :as => :admin_walker_destroy, via: [:delete]	
  match 'admin/walker_update', :as => :admin_walker_update, via: [:patch]
	match 'admin/results_update', :as => :admin_results_update, via: [:get]
	match 'admin/results_setting(.:id)' => 'admin#results_setting', :as => :admin_results_setting, via: [:get]
	match 'profile' => "walkers#profile", :as => :walker_profile, via: [:get]	
	match ':controller(/:action(/:id))', via: [:get, :post]
	match ':action' => 'static#:action', via: [:get]

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

  # match ':controller(/:action(/:id(.:format)))', :via => [:get, :post]

end
