xml.instruct!
xml.gpx("creator" => "dencesty.cz",
        "version" => "1.0",
        "xmlns" => "http://www.topografix.com/GPX/1/1",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd") do
  xml.metadata do
    xml.link("href" => "http://www.dencesty.cz") do
      xml.text "Záznam ze závodu " + @race.name_cs
      xml.time @race.finish_time.to_time.iso8601
    end
  end
  xml.trk do
    xml.name("(" + @walker.id.to_s + ") " + @walker.nameSurnameYear + "-" + @race.name_cs)
    xml.trkseg do
      @trks.each do |trk|
        xml.trkpt("lat" => trk[:latitude], "lon" => trk[:longitude]) do |trkpt|
          xml.time(trk[:time].to_time.iso8601)
        end
      end
    end
  end
  xml.rte do
    xml.name "Trasa závodu"
    @route.each do |rte|
      xml.rtept("lon" => rte[:longitude], "lat" => rte[:latitude]) do
        xml.name "WP" + rte[:checkid].to_s
      end
    end
  end
end