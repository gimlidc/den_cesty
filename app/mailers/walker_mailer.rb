class WalkerMailer < ActionMailer::Base
  default from: "info@dencesty.cz"
  add_template_helper(DcsHelper)
  add_template_helper(RegistrationsHelper)
  
  def send_payment_details(walker)
    
  end
  
  def send_payment_request(registration)
    @walker = registration.walker
    @reg = registration
    mail(to: registration.walker.email, subject: I18n.t("registration payment notification"))
  end
  
  def notify_registration_update(registration)
    @walker = registration.walker
    @reg = registration
    mail(to: registration.walker.email, subject: I18n.t("registration updated"))
  end
  
  def notify_registration_transfer(walkerFrom, walkerTo)
    notify_registration_removed(walkerFrom)
    notify_registration_added(walkerTo)
  end
  
  def notify_registration_removed(walkerFrom, walkerTo)
    @walker = walkerFrom
    @newOwner = walkerTo
    mail(to: walker.email, subject: I18n.t("registration changed owner"))
  end
  
  def notify_registration_added(walkerFrom, walkerTo)
    @walker = walkerTo
    @oldOwner = walkerFrom
    mail(to: walker.email, subject: I18n.t("registration changed owner"))
  end
  
  def send_spam(walker, subj, message_content)
    @message_content = message_content
    mail(to: walker.email, subject: subj)
  end 
  
end
