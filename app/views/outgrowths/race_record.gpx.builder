xml.instruct!
xml.gpx("creator" => "dencesty.cz",
        "version" => "1.0",
        "xmlns" => "http://www.topografix.com/GPX/1/1",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd") do
  xml.trk do
    xml.name @race_name
    xml.trkseg do
      @trks.each do |trk|
        xml.trkpt("lat" => trk[:latitude], "lon" => trk[:longitude])
      end
    end
  end
end