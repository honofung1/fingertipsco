require 'report_criterion_definition'
class ReportCriteriaCollection
  include Enumerable
  include ActiveModel::Model

  attr_reader :criteria_value_hash

  def initialize(criteria = [], report:)
    @hash = {}.with_indifferent_access
    @report = report
    @criteria_value_hash = {}.with_indifferent_access
    criteria.each { |criterion| add_criterion(criterion) }
  end

  def set_criteria_values(criteria_param)
    @criteria_params = criteria_params
    (criteria || {}).keys.each do |key|
      @criteria_value_hash[key] = @criteria[key].parse_value(criteria_param[key])
    end

    Rails.logger.debug("criteria_value_hash: #{@criteria_value_hash}")
  end

  def add_criterion(criterion)
    criterion.report = @report
    @hash[criterion.code] = criterion
  end

  def each(&block)
    @hash.values.each { |v| block.call(v) }
  end

  def [](key)
    @hash.fetch(key)
  end

  # this is made for form helper to get value
  def method_missing(name, *args, &block)
    if @hash.has_key?(name)
      criterion = @hash[name]
      @report.get_criterion_raw_value(name) || criterion.get_default_value
    else
      super
    end
  end
end
