xml.instruct!
xml.gpx("creator" => "dencesty.cz",
        "version" => "1.0",
        "xmlns" => "http://www.topografix.com/GPX/1/1",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd") do
  xml.trk do
    xml.name(@race.name_cs)
    xml.trkseg do
      @route.each do |checkpoint|
        xml.trkpt("lat" => checkpoint[:latitude], "lon" => checkpoint[:longitude])
      end
    end
  end
end
