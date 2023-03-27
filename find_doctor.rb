# frozen_string_literal: true

require 'thor'
require 'csv'
require 'pathname'

ENV['THOR_SILENCE_DEPRECATION'] = '1'

class FindDoctor < Thor
  VERSION = '1.0.0'
  class DoctorSchedule
    ATTRS = %i[name monday tuesday wednesday thursday friday saturday sunday].freeze
    attr_reader(*ATTRS)

    def initialize(arr)
      ATTRS.each_with_index do |item, index|
        instance_variable_set("@#{item}", arr[index])
      end
    end
  end

  class Parser
    class Csv
      def initialize(path)
        @path = path
      end

      def execute(&block)
        ::CSV.table(@path).each_with_object([], &block)
      end
    end
  end

  attr_reader :errors

  def initialize(*params)
    super
    @errors = []
  end

  desc 'by_day',
       'Find a doctor by_day.'
  option :day,
         required: true,
         type: :string,
         desc: "Yield a day name as name (like 'Monday') or number accordingly to the ISO 8601 (like 2 for Tuesday)"
  option :type,
         required: true,
         type: :string,
         desc: "Pick up one of types: csv, json, socket, xls, xml. Version #{VERSION} support only csv."
  option :path,
         required: true,
         type: :string,
         desc: "Provide a path (URL or path to the file). Version #{VERSION} support only path to file."

  def by_day
    self.day = options.day.downcase
    self.path = Pathname.new(options.path)
    errors << 'Invalid input value: day' unless iso8601_days_integers.to_a.flatten.include?(day)
    errors << 'Invalid input value: type' unless %w[csv].include?(options.type)
    errors << 'Invalid input value: path' unless path.exist?
    raise Thor::Error, errors.join('. ') unless errors.empty?

    self.day = day.to_i.zero? ? day : iso8601_days_integers.key(day)
    self.type = options.type

    Parser::Csv.new(path).execute do |row, arr|
      arr << DoctorSchedule.new(row)
    end.then do |arr|
      arr.select { |item| item.public_send(day) == 'ON' }
    end.then do |selected|
      selected.each do |doctor|
        puts "#{doctor.name} is available"
      end
    end
  end

  private

  attr_accessor :day, :type, :path

  def iso8601_days_integers
    {
      'monday' => '1',
      'tuesday' => '2',
      'wednesday' => '3',
      'thursday' => '4',
      'friday' => '5',
      'saturday' => '6',
      'sunday' => '7'
    }
  end
end

FindDoctor.start(ARGV)
