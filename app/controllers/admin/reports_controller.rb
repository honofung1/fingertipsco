class Admin::ReportsController < Admin::BaseController
  prepend_before_action :load_report, only: [:show, :update, :download]
  before_action :set_content_header
  skip_load_and_authorize_resource

  def index
    @reports = []
    report_names = ReportConfig.instance.report_names
    report_names.each do |report_name|
      report_class = "#{report_name.camelize}::Report".constantize
      report = report_class.new
      @reports << report if report.visible_on_catalog?
    end
  end

  def show
    # DO NOTHING HERE
  end

  # TODO: Add confirm download message
  def download
    @result = @report.run(current_user)

    logger.debug("REPORT CODE  : #{@result.report_code}")
    logger.debug("RESULT HEADER: #{@result.header_labels}")

    respond_to do |format|
      format.html
      format.xlsx do
        @file_name = "#{@report.title}#{Time.now.strftime('%Y%m%d%H%M')}.xlsx"
        response.headers['Content-Disposition'] = "attachment; filename= #{@file_name}"
        # TODO: Move to corn job
        # tmp_file = Rails.root.join(@file_name)
        # File.delete(@file_name) if File.exist?(@file_name)
      end
    end
  end

  private

  def load_report
    @report_class = ReportConfig.klass(params[:id])

    # change date format for system setting value to yyyy-mm-dd for both date and datetime by method cleanse_data_range
    @report = @report_class.new # initialize the report without report_params first
    if report_params.present?
      @report.criteria.each do |criterion|
        # only update format for date or datetime range
        if criterion.type == :date_range_default_blank || criterion.type == :datetime_range_default_blank
          if report_params.dig(:criteria, criterion.code).present?
            report_params[:criteria][criterion.code] = ReportBase.cleanse_data_range(
              report_params[:criteria][criterion.code],
              criterion.type == :datetime_range_default_blank
            )
          end
        end
      end
    end
    # end of cleanse_data_range

    # we need to use @report to avoid FormBuilder to play too smart and try to bind with the object @report on view
    logger.debug("report_params: #{report_params}")
    # @report = @report_class.new(report_params)
    @report.params = report_params if report_params.present?
  end

  def report_params
    params[@report_class.model_name.param_key]
  end

  def set_content_header
    content_header = case params[:action]
    when "index"
      title = t(:'sidebar.report')
      {
        header: title,
        subheader: { title: '' },
        labels: [],
        breadcrumbs: [
          { title: title }
        ]
      }
    when "show", "update", "download"
      title = t(:'sidebar.report')
      {
        header: title,
        subheader: { title: @report.title },
        labels: [],
        breadcrumbs: [
          { url: admin_reports_path, title: title },
          { url: admin_report_path(@report.code), title: @report.title }
        ]
      }
    end

    # override default content_header
    @layout_view_variables[:content_header] = content_header
  end
end
