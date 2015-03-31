class ActiveSupport::TimeWithZone
    def as_json(options = {})
        utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    end
end
