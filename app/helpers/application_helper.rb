module ApplicationHelper
  def dc_name(id)
    dcs = Dc.find(:all, :order => :id)
    return dcs[id-1].name_cs
  end

  def dc_select
    @dc_select=""
    dcs = Dc.find(:all, :order => :id)
    for i in 1..$dc.id do
      if i == @dc_id
        @dc_select+="<option value=#{i} selected=\"selected\">#{dcs[i-1].name_cs}</option>\n"
      else
        @dc_select+="<option value=#{i}>#{dcs[i-1].name_cs}</option>\n"
      end
    end

    return @dc_select
  end

  def sex_options
    [[I18n.t('male'), "male"], [I18n.t('female'), "female"]]
  end

end
