class WalkerMailer < ActionMailer::Base
  default from: "info@dencesty.cz"
  add_template_helper(DcsHelper)
  add_template_helper(RegistrationsHelper)

  include RegistrationsHelper

  def send_payment_details(walker)
    
  end

  def createQrCode(reg)
    qrstring = "SPD*1.0*ACC:" << $IBAN
    qrstring = qrstring << "*AM:" << price(reg).to_s << "*CC:CZK"
    qrstring = qrstring << "*X-SS:666" << "*X-VS:" << sprintf("%03d", $dc.id) << sprintf("%04d",reg.walker_id)
    qrstring = qrstring << "*MSG:" << reg.walker[:email]

    qrcode = RQRCode::QRCode.new(qrstring)
    # With default options specified explicitly
    return qrcode.as_svg(offset: 0, color: '000',
                         shape_rendering: 'crispEdges',
                         module_size: 4)
  end

  def send_payment_request(registration)
    @walker = registration.walker
    @reg = registration
    @svg = createQrCode(@reg)
    if @reg["goal"].match(/^[0-9]*$/) && @reg["goal"].to_i >= 42 && @reg["goal"].to_i <= $dc30_route_id_max
      @dc_route = Race.find(@reg.goal)
    end
    mail(to: registration.walker.email, subject: I18n.t("registration payment notification"))
  end
  
  def notify_registration_update(registration)
    @walker = registration.walker
    @reg = registration
    @svg = createQrCode(@reg)
    if @reg["goal"].match(/^[0-9]*$/) && @reg["goal"].to_i >= 42 && @reg["goal"].to_i <= $dc30_route_id_max
      @dc_route = Race.find(@reg.goal)
    end
    mail(to: registration.walker.email, subject: I18n.t("registration updated"))
  end
  
  def notify_registration_transfer(walkerFrom, walkerTo)
    notify_registration_removed(walkerFrom, walkerTo)
    notify_registration_added(walkerTo, walkerTo)
  end
  
  def notify_registration_removed(walkerFrom, walkerTo)
    @walker = walkerFrom
    @newOwner = walkerTo
    mail(to: @walker.email, subject: I18n.t("registration changed owner"))
  end
  
  def notify_registration_added(walkerFrom, walkerTo)
    @walker = walkerTo
    @oldOwner = walkerFrom
    mail(to: @walker.email, subject: I18n.t("registration changed owner"))
  end
  
  def send_spam(walker, subj, message_content)
    @message_content = message_content
    mail(to: walker.email, subject: subj)
  end 
  
end
