# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  # navigation.active_leaf_class = 'your_active_leaf_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name| "<span>#{name}</span>"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  # Define the primary navigation
	nav_class = 'sf-menu'

  navigation.items do |top|
		top.dom_class = 'sf-menu'
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #
    top.item :actual, I18n.t('Actual'), root_path
		top.item :rules, I18n.t('Rules'), pages_rules_path
		top.item :recommendations, I18n.t('Recomendations'), pages_recommendations_path

    # Add an item which has a sub navigation (same params, but with block)
#    top.item :reports, 'Reports', url, options do |reports|
#      # Add an item to the sub navigation (same params again)
#      reports.item :report_by_year, 'By year', url, options
#			reports.item :report_by_author, 'By author', url, options
#    end
#
#    # You can also specify a condition-proc that needs to be fullfilled to display an item.
#    # Conditions are part of the options. They are evaluated in the context of the views,
#    # thus you can use all the methods and vars you have available in the views.
#    #primary.item :key_3, 'Admin', url, :class => 'special', :if => Proc.new { current_user.admin? }
#    #primary.item :key_4, 'Account', url, :unless => Proc.new { logged_in? }
#
		top.item :results, I18n.t('Results'), :class => 'sf-sub-indicator' do |results|
			results.item :hall_of_glory, I18n.t('Hall of Glory'), pages_hall_of_glory_path
#			results.item :result_by_year, 'By year', results_by_year_path
		end

		if walker_signed_in? && current_walker.username == $admin_name
			top.item :management, I18n.t('Management'), :class => 'sf-sub-indicator' do |manages|
				manages.item :walkers, I18n.t('Walkers'), admin_walker_list_path
				manages.item :registrations, I18n.t('Registrations'), registration_path
				manages.item :result_setting, I18n.t('Results setting'), admin_results_setting_path, id => $current_dc_id
			end
		end
#		top.item :routes, 'Routes', url
#		top.item :forum, 'Forum', url
#		top.item :gallery, 'Gallery', url

    # you can also specify a css id or class to attach to this particular level
    # works for all levels of the menu
    # primary.dom_id = 'menu-id'
    # primary.dom_class = 'menu-class'

    # You can turn off auto highlighting for a specific level
    # primary.auto_highlight = false

  end

end
