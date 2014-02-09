# @author gimli
# @version Apr 7, 2012

SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |nav|
    nav.dom_class = 'walker-menu'
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



    #nav.item :walker_results, I18n.t('My results'),  root_path
    #nav.item :edit, I18n.t('Manage account'), edit_walker_registration_path

    if Time.now < $registration_deadline
      nav.item :registration, I18n.t('Registration') do |registration|
        if is_registered
          registration.item :edit_registration, I18n.t('Show registration'), registration_path
          registration.item :edit_registration, I18n.t('Manage registration'), edit_registration_path
          registration.item :edit_registration, link_to(I18n.t("Sign_out"), {:controller => "registrations", :action => "destroy"}, :method => "delete", :confirm => "Opravdu nechceš jít s námi?")
        else
          registration.item :edit_registration, I18n.t('Sign_in'), new_registration_path
        end
      end
    end

    if is_registered && Time.now > $dc.start_time && Time.now < $report_deadline
      if has_report
        nav.item :report, I18n.t('Reports') do |reports|
          reports.item :edit_report, I18n.t('Edit report'), edit_report_path
          reports.item :edit_report, I18n.t('Show report'), show_report_path
        end
      else
        nav.item :add_report, I18n.t('Add report'), new_report_path
      end
    end

#    if walker_signed_in? 
#      nav.item :edit_walker, I18n.t('Profil'), edit_walker_path
#    end


    if walker_signed_in? && current_walker.username == $admin_name
      nav.item :management, I18n.t('Management'), :class => 'sf-sub-indicator' do |manages|
        manages.item :walkers, I18n.t('Walkers'), admin_walker_list_path
        manages.item :registrations, I18n.t('Registrations'), registration_path
        manages.item :result_setting, I18n.t('Results setting'), admin_results_setting_path
        manages.item :result_setting, I18n.t('Presentation list'), admin_print_list_path
        manages.item :dcs, "Přehled DC", dcs_path 
      end
    end

    #nav.item :forum, I18n.t('Forum'), forum_path
  end

end