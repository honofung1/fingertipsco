class ReportConfig
  include Singleton

  attr_reader :report_names

  def initialize
    reload
  end

  def reload
    @report_names = Dir.glob(Rails.root.join("app/reports/*/")).collect { |p| p.split('/').last }.sort
  end

  def self.report_name?(name)
    instance.reload if Rails.env.development?

    instance.report_names.include?(name)
  end

  # Pass the report_name to white-list checking and return the klass
  # In this way, we can improve security when using constantize
  def self.klass(report_name)
    raise "Unexpected Error" unless report_name?(report_name) # TODO: I18n

    "#{report_name.camelize}::Report".constantize
  end
end