module DcsHelper
  
  def shirt?
    $dc.shirt_price != -1
  end

  def pes_shirt?
    $dc.polyester_shirt_price != -1
  end
  
  def scarf?
    $dc.scarf_price != -1
  end

  def map_bw?
    $dc.map_bw_price != -1
  end
  
  def map_colour?
    $dc.map_color_price != -1
  end
  
end
