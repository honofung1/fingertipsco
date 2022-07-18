class ReportBase
  # include Pagination
  include ActiveModel::Model

  # ReportFormats = %w[csv tsv xlsx html]
  ReportFormats = %w[xlsx] # TODO: Temp to remove other file types
  AllowFormats = ReportFormats + %w[view]
  attr_reader :errors
  attr_accessor :params
  # format: html, csv...
  def initialize(attributes = {})
    @criteria = ReportCriteriaCollection.new(report: self)
    define_criteria(@criteria)
    @params = (attributes || {}).with_indifferent_access
    @errors = ActiveModel::Errors.new(self)
    @has_result = false
  end

  def self.get_format_list
    ReportFormats.collect { |format| [I18n.t(:"reports._common.enums.format.#{format}"), format] }
  end

  def get_criterion_value(criterion_code)
    (@criteria_value_hash || {})[criterion_code]
  end

  def get_criterion_raw_value(criterion_code)
    (@params[:criteria] || {})[criterion_code]
  end

  def locale
    params&.key?(:locale) ? params[:locale] : I18n.locale
  end

  def format
    params[:format]
  end

  def code
    self.class.name.underscore.split('/').first
  end

  # When the base has description of a particular report while the client specific has no description,
  #  the final result of description is used as base description.
  # It is the behaviour of 'vendor_translation_with_fallback'.
  # So, when the base has description,
  #  please keep all client specific has description (maybe copied from base).
  def description
    I18n.t(:"reports.#{code}.description")
  end

  def title
    I18n.t("reports.#{code}.title")
  end

  def criteria
    @criteria
  end

  def valid?
    errors.add(:format, :invalid, message: "Invalid output format #{params[:format]}") unless AllowFormats.include?(params[:format])
    on_validate
    return @errors.size == 0 && @criteria.errors.size == 0
  end

  def class_path
    Rails.root.join("app/reports/#{self.class.name.split('::').first.underscore}")
  end

  def view_path
    "#{class_path}/views"
  end

  def criteria_view_path
    "#{view_path}/_criteria.html.erb"
  end

  def criteria_view_exist?
    File.exist?("#{criteria_view_path}")
  end

  def control_view_path
    "#{view_path}/_control.html.erb"
  end

  def control_view_exist?
    File.exist?("#{control_view_path}")
  end

  def option_view_path
    "#{view_path}/_option.html.erb"
  end

  def option_view_exist?
    File.exist?("#{option_view_path}")
  end

  def html_result_view_path
    "#{view_path}/_html_result_view.html.erb"
  end

  def html_result_view_exist?
    File.exist?("#{html_result_view_path}")
  end

  def run(current_admin)
    @params = params
    @current_admin = current_admin
    @criteria_value_hash = {}.with_indifferent_access
    setup_criteria_value_hash
    # raise OmnitechError.new(:invalid_report_parameters) unless valid?
    raise "Invalid Report parameters" unless valid?
    @result = on_run(params)
    @has_result = true
    return @result
  end

  def setup_criteria_value_hash
    (params[:criteria] || {}).keys.each do |key|
      @criteria_value_hash[key] = @criteria[key].parse_value(params[:criteria][key])
    end

    Rails.logger.debug("criteria_value_hash: #{@criteria_value_hash}")
  end

  def current_admin
    @current_user
  end

  def result?
    @has_result
  end

  def result
    @result
  end

  def supports_pagination?
    false
  end

  def visible_on_catalog?
    # override to return false if report is not meant for admin users to see in the list
    true
  end

  def modify_data_range(key, value)
    { "#{key}_gteq": value[:from], "#{key}_lteq": value[:to] }
  end

  # validation for ActiveModel
  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  def self.cleanse_data_range(date_range_string, is_datetime_str = false) # TODO: this function is coupling with validate_date_range
    date_range_array = date_range_string.split('~').collect { |v| v.strip }
    if date_range_array.size == 2
      from_date = is_datetime(date_range_array.first, is_datetime_str)
      to_date = is_datetime(date_range_array.second, is_datetime_str)
      if from_date && to_date
        return '' if to_date < from_date
      else
        return ''
      end
    else
      return ''
    end
    date_range_string
  end

  def self.cleanse_month_day_range(date_range_string) # TODO: this function is coupling with validate_month_date_range
    date_range_array = date_range_string.split('~').collect { |v| v.strip }
    ap date_range_array
    if date_range_array.size == 2
      from_date = is_datetime(date_range_array.first)
      to_date = is_datetime(date_range_array.second)
      if from_date && to_date
        return date_range_string
      else
        return ''
      end
    else
      return ''
    end
  end

  #############################################################################
  # Protected function
  #############################################################################
  protected

  def define_criteria(criteria)
    # no need to override if there is no criteria, so no enforcement
  end

  def on_validate
    raise NotImplementedError.new('Missing on_validate implementation')
  end

  def on_run(params)
    raise NotImplementedError.new('Missing on_run implementation')
  end

  # Define the report styling
  def style
    styles = {}
    raise NotImplementedError.new('Missing setting up report styling') if styles.blank?
  end

  # Should be overridding if the report have the title before headers
  # data_format should be
  # title_name: { option_here }
  # option should have merge cell length, display name
  def report_title
    {}
  end

  def with_header
    true
  end

  def force_quotes
    true
  end

  def validate_date_range(field_name, date_range_string)
    date_range_array = date_range_string.split('~').collect { |v| v.strip }
    if date_range_array.size == 2
      from_date = ReportBase.is_datetime(date_range_array.first)
      to_date = ReportBase.is_datetime(date_range_array.second)
      if from_date && to_date
        criteria.errors.add(field_name, I18n.t(:'reports._common.date_range_errors.end_date_cannot_be_earlier_than_start_date')) if to_date < from_date
      else
        criteria.errors.add(field_name, I18n.t(:'reports._common.date_range_errors.start_date_is_not_a_date')) unless from_date
        criteria.errors.add(field_name, I18n.t(:'reports._common.date_range_errors.end_date_is_not_a_date')) unless to_date
      end
    else
      criteria.errors.add(field_name, I18n.t(:'reports._common.date_range_errors.is_not_a_date_range'))
    end
  end

  def validate_month_inputs(from_month_field_name, to_month_field_name, from_month, to_month)
    if from_month.present? != to_month.present?
      field_name = if from_month.present?
                     to_month_field_name
                   else
                     from_month_field_name
                   end
      criteria.errors.add(field_name, I18n.t(:"reports._common.birthday_month_errors.date_of_birth_from_to_need_to_fill_togather"))
    end
  end

  #############################################################################
  # Private function
  #############################################################################
  private
  # Not private function here

  def self.is_datetime(date_string, is_datetime_str = false)
    if is_datetime_str
      DateTime.strptime(date_string, "%Y-%m-%d %H:%M") rescue nil
    else
      Date.strptime(date_string, "%Y-%m-%d") rescue nil
    end
  end
end

# Layout for the result of thee report
class ReportResult
  # TODO: Temp to remove meta in the initialize
  attr_reader :data, :format, :headers, :header_labels, :cols_data_type, :cols_style
  def initialize(data:, headers: [], cols_data_type: [], cols_style:[], format:, report:)
    @data = data
    @headers = headers
    @format = format
    @report = report

    @cols_data_type = if cols_data_type.present?
                        cols_data_type
                      else
                        headers.collect { |_| ReportResult.default_excel_col_data_type }
                      end

    @cols_style = if cols_style.present?
                    cols_style
                  else
                    headers.collect { |_| ReportResult.default_col_style }
                  end
  end

  # col_data_types SUPPORT values:  [:date, :time, :float, :integer, :string, :boolean]
  # Reference from here: https://github.com/randym/axlsx/blob/v2.0.0/lib/axlsx/workbook/worksheet/cell.rb#L70
  # Define other col data type in the FIELDMAPS in inner private class (if needed and possible)
  def self.default_excel_col_data_type
    :string
  end

  # Must be having the default :text style hash for each report
  # In the col_style use case, the header and the data style should be same
  # Example
  # def style(worksheet)
  #   style = { text: worksheet.styles.add_style() }
  # end
  def self.default_col_style
    :text
  end

  # Overriding
  def header_labels
    @headers.collect { |header| I18n.t(:"reports.#{@report.code}.columns.#{header}", default: header) }
  end

  def report_code
    @report.code
  end

  def report_style(worksheet)
    @report.style(worksheet)
  end

  def report_title
    @report.report_title
  end

  def get_csv_row_array_from_row(row)
    row_data = row.with_indifferent_access
    @headers.collect { |header| row_data[header] }
  end
end
