module SplitDatetime
  module Accessors
    def accepts_split_datetime_for(*attrs)
      opts = { format: "%F", default: lambda { Time.now.change(min: 0) } }

      if attrs.last.class == Hash
        custom = attrs.delete_at(-1)
        opts = opts.merge(custom)
      end

      attrs.each do |attr|
        attr_accessible "#{attr}_date", "#{attr}_hour", "#{attr}_min", "#{attr}_time"

        define_method(attr) do
          super() || opts[:default].call
        end

        define_method("#{attr}_date=") do |date|
          return unless date.present?
          date = Date.parse(date.to_s)
          self.send("#{attr}=", self.send(attr).change(year: date.year, month: date.month, day: date.day))
        end

        define_method("#{attr}_hour=") do |hour|
          return unless hour.present?
          self.send("#{attr}=", self.send(attr).change(hour: hour, min: self.send(attr).min))
        end
        
        define_method("#{attr}_time=") do |time|
          return unless time.present?
          time = DateTime.parse time unless time.is_a?(Date) or time.is_a?(Time)
          self.send("#{attr}=", self.send(attr).change(hour: time.hour, min: time.min))
        end

        define_method("#{attr}_min=") do |min|
          return unless min.present?
          self.send("#{attr}=", self.send(attr).change(min: min))
        end

        define_method("#{attr}_date") do
          self.send(attr).strftime(opts[:format])
        end

        define_method("#{attr}_hour") do
          self.send(attr).hour
        end

        define_method("#{attr}_min") do
          self.send(attr).min
        end
        
        define_method("#{attr}_time") do
          self.send(attr).to_time
        end
        
      end
    end
  end
end
