module AdminHelper
  MERCHANT_ACCESS_EXCEPTION = %w[Dashboard Analytic]
  ACTION_ICONS = {
    show: 'bar-chart-o',
    edit: 'edit',
    delete: 'trash',
    remove: 'trash',
    download: 'download',
    clone: 'clone',
    hide_on_web: 'eye-slash',
    adjust_pricing: 'dollar',
    upload: 'upload',
    retry: 'repeat',
    id_secret_pairs: 'key',
    setup_provision: 'key',
    settings: 'gear',
    decline: 'times-circle'
  }

  def link_to_btn(link, title, options = {})
    if options[:name].nil?
      options[:name] = case title.downcase
                       when 'show'
                         "<i class='far fa-chart-bar'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       when 'edit'
                         "<i class='fa fa-edit'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       when 'delete', 'remove', 'real_delete'
                         "<i class='fa fa-trash'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       when 'download'
                         "<i class='fa fa-download'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       when 'clone'
                         "<i class='fa fa-clone'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       when 'hide_on_web'
                         "<i class='fa fa-eye-slash'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       when 'upload'
                         "<i class='fa fa-upload'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
                       else
                         title.to_s
                       end
    end

    if options[:class].nil?
      options[:class] = case title.downcase
                        when 'edit'
                          "btn btn-success btn-sm"
                        when 'delete', 'remove'
                          'btn btn-danger btn-sm disabled'
                        when 'real_delete'
                          'btn btn-danger btn-sm'
                        when 'clone'
                          'btn btn-info btn-sm'
                        else
                          'btn btn-default btn-sm'
                        end
    end

    html_options = options.except(:name)
    html_options[:title] = t(:"button.#{title}", default: title).humanize

    link_to options[:name].to_s, link, html_options
  end

  def link_with_icon(button, top = false)
    action = button[:action]

    action_text = button[:action_text] || t(:"admin.button.#{action}", default: action).humanize

    # get icon and join with translated action name
    icon_text = safe_join([content_tag(:i, '', class: "fa fa-#{ACTION_ICONS[action.to_sym] || 'circle'}"), " #{action_text}"], ' ')

    link = button[:url]

    options = button.except(:action, :url)

    options[:class] ||= ""
    options[:class] << (%w[delete remove].include?(action) ? ' split-btn-danger' : ' split-btn-default') # use red text for delete, grey for default
    options[:class] << ' btn btn-default btn-sm' if top # add btn class to top link for button group style
    options[:class].strip! # remove leading the trailing spaces

    options.merge!(method: :delete) if %w[delete remove].include?(action) # add method for delete
    # add confirmation message, override the default message if exist
    options[:data] = { confirm: t(:'admin.button.confirm') } if %w[delete remove clone hide_on_web].include?(action) && !options[:data].present?

    link_to icon_text, link, options
  end

  def format_date(date)
    date.present? ? date.strftime("%Y-%m-%d") : nil
  end

  def format_date_time(date)
    date.present? ? date.strftime("%Y-%m-%d %H:%M") : nil
  end

  def format_boolean(flag)
    flag ? "是" : "否" # TODO: I18n
  end

  # TODO: refactor with bettering way
  def format_percentage(amount)
    return t(:'no_record.not_setting') if amount.nil? || amount == 0

    "#{amount}%"
  end

  def format_order_owner_handling_fee(amount)
    return t(:'no_record.not_setting') if amount.nil? || amount == 0

    "¥#{amount}"
  end

  def show_amount_with_currency(currency, amount)
    return t(:'no_record.not_applicable') if amount.nil? || amount == 0

    dollar_sign = currency == "HKD" ? "$" : "¥"
    # "#{currency} #{dollar_sign}#{amount}"
    "#{dollar_sign}#{amount}"
  end

  def prepaid_order_additional_fee_with_sign(type, amount)
    return t(:'no_record.not_applicable') if amount.nil? || amount == 0

    sign = type == "discount" ? "%" : "¥"
    "#{sign}#{amount}"
  end

  def prepaid_order_price_without_tax(order)
    return if order.order_products.blank?

    primary_product = order.order_products.first

    return if primary_product.product_price.nil?
    return if primary_product.product_quantity.nil?

    primary_product.product_price * primary_product.product_quantity
  end

  def daterangepicker_data(
    direction = 'up',
    start_date = 3.months.ago,
    end_date = Time.current,
    separator = ' - ',
    timepicker: false,
    format: system_date_format
  )
    # resume to use %F as this is specific to the daterangepicker component data format requirement
    # replace ... data-drops="down" data-start="<%= 1.year.ago.strftime('%F') %>" data-end="<%= Time.current.strftime('%F') %>" ... in daterange-picker
    # also add i18n translation to daterange-picker buttons
    # add date format from system setting to 'format' in daterangepicker
    {
      drops: direction,
      start: start_date.is_a?(String) ? start_date : start_date&.strftime('%F'),
      end: end_date.is_a?(String) ? end_date : end_date&.strftime('%F'),
      separator:,
      format: timepicker ? "#{format} HH:mm" : format, # add time format if timepicker is included
      timepicker:,
      from: t(:'admin.daterangepicker.from'),
      to: t(:'admin.daterangepicker.to'),
      apply: t(:'admin.daterangepicker.apply'),
      cancel: t(:'admin.daterangepicker.cancel')
    }
  end

  def system_date_format
    'YYYY-MM-DD'
  end

  # Filter out the exactly existing order owner
  # to avoid the code only existing in system setting.yml
  # set the ordering according to name first
  def show_order_in_sidear
    OrderOwner.where(order_code_prefix: SystemSetting.get('order.show_prepaid_order_in_sidebar.order_owner_codes')).order('name ASC')
  end

  def preset_order_shop_from
    SystemSetting.get('order.preset.shop_from')
  end

  # This method checking order product object already has cost or not
  def order_product_has_cost(opt)
    opt.total_cost?
  end

  def normal_order_product?(order_product)
    # special process for clone order action
    return true if params[:action] == "clone"

    order_product.order.order_type == "normal" && !order_product.new_record?
  end
end
