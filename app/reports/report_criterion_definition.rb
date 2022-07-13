class ReportCriterionDefinition
  attr_reader :code, :type, :params
  attr_accessor :report
  def initialize(code:, type:, enum: {}, enum_set_name: nil, enum_prefix: nil, enum_model: nil,
                 enum_field: nil, enum_translation: true, enum_translation_field: nil, enumerize_field: nil,
                 enum_object_display_field: nil, state_field: nil, display_name: nil, model: nil,
                 view_code: nil, params: {})
    @code = code
    @type = type
    @enum = enum
    @enum_set_name = enum_set_name.present? ? enum_set_name : code # [TODO] Francis: Strange setting, need global refactor
    @enum_prefix = enum_prefix
    @enum_model = enum_model
    @enum_field = enum_field
    @enum_translation = enum_translation
    @enum_translation_field = enum_translation_field
    @enumerize_field = enumerize_field
    @state_field = state_field
    @enum_object_display_field = enum_object_display_field
    @display_name = display_name
    @model = model
    @view_code = view_code
    @params = params
  end

  def get_select_list
    if !@enum_translation
      @enum.collect { |e_value| [e_value, e_value] }
    elsif @enum_prefix.present?
      @enum.collect { |e_value| [I18n.t(:"#{@enum_prefix}.#{e_value}"), e_value] }
    elsif @enum_model.present? && @enum_field.present? && @enum_translation_field.present?
      @enum.collect do |e_value|
        [@enum_model.find_by(@enum_field => e_value).send(@enum_translation_field), e_value]
      end
    elsif @model.present? && @enumerize_field.present?
      @model.send(@enumerize_field).options
    elsif @model.present? && @state_field.present?
      @enum.collect { |e_value| [@model.public_send("human_#{@state_field}_name", e_value), e_value] }
    elsif @enum_object_display_field.present?
      @enum.collect { |object| [object.send(@enum_object_display_field) || object.code, object.id] }
    else
      @enum.collect do |e_value|
        [I18n.t(:"reports.#{report.code}.enums.#{@enum_set_name}.#{e_value}"), e_value]
      end
    end
  end

  def get_month_list
    (1..12).collect do |month|
      [I18n.l(Date.parse("#{'%02d' % month}/01"), format: "%B"), month]
    end
  end

  # [TODO] Refactor the 'enum' and 'enum_default_blank'
  # [TODO] Refactor the 'date_range' and 'date_range_default_blank'
  def parse_value(value)
    case @type
    when :datetime_range_default_blank
      if value.present?
        time_zone = @report&.current_admin&.time_zone || Time.zone.name
        date_range_array = value.split('~').collect { |v| ActiveSupport::TimeZone[time_zone].parse(default_date_format(v.strip, true)).utc }
        return { from: date_range_array.first.beginning_of_minute, to: date_range_array.last.end_of_minute }
      else
        nil
      end
    when :date_range, :date_range_default_blank
      if value.present?
        date_range_array = value.split('~').collect { |v| default_date_format(v.strip).to_date }
        return { from: date_range_array.first.beginning_of_day, to: date_range_array.last.end_of_day }
      else
        nil
      end
    when :enum, :enum_default_blank, :text, :hidden, :number
      value
    when :month
      value.to_i
    when :product_multi
      value.split(',')
    when :boolean
      value == '1' if value.kind_of?(String)
    end
  end

  def get_default_value
    case @type
    when :date_range
      "#{@params[:default_start_date]} ~ #{@params[:default_end_date]}"
    when :date_range_default_blank, :month_day_range, :datetime_range_default_blank
      ""
    end
  end

  def display_name
    if @display_name.present?
      I18n.t(@display_name)
    elsif @model.present? && @view_code.present?
      @model.human_attribute_name(@view_code)
    else
      I18n.t(:"reports.#{@report.code}.criteria.#{@code}")
    end
  end

  # get date range for admin helper method daterangepicker_data
  # return an array of start_date and end_date, with the separator use
  # set empty start_date and end_date if the result of string split is not suitable
  def get_date_range(separator = ' - ', is_datetime_str = false)
    date_range = @report&.params&.dig(:criteria, @code).to_s.split(separator)
    date_range = date_range.map{ |d| default_date_format(d, is_datetime_str) }.compact
    date_range = ['', ''] if date_range.count != 2
    date_range << separator
    return date_range
  end

  private

  def default_date_format(date_string, is_datetime_str = false)
    format_str = is_datetime_str ? '%F %R' : '%F'
    ReportBase.is_datetime(date_string, is_datetime_str)&.strftime(format_str)
  end
end
