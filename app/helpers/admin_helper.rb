module AdminHelper
  MERCHANT_ACCESS_EXCEPTION = %w(Dashboard Analytic)
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

  def link_to_btn(link, title, options={})
    if options[:name].nil?
      case title.downcase
      when 'show'
        options[:name] = "<i class='far fa-chart-bar'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      when 'edit'
        options[:name] = "<i class='fa fa-edit'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      when 'delete', 'remove'
        options[:name] = "<i class='fa fa-trash'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      when 'download'
        options[:name] = "<i class='fa fa-download'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      when 'clone'
        options[:name] = "<i class='fa fa-clone'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      when 'hide_on_web'
        options[:name] = "<i class='fa fa-eye-slash'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      when 'upload'
        options[:name] = "<i class='fa fa-upload'></i><strong>#{t(:"button.#{title}")}</strong>".html_safe
      else
        options[:name] = title.to_s
      end
    end

    if options[:class].nil?
      case title.downcase
      when 'edit'
        options[:class] = "btn btn-success btn-sm"
      when 'delete', 'remove'
        options[:class] = 'btn btn-danger btn-sm disabled'
      when 'clone'
        options[:class] = 'btn btn-info btn-sm'
      else
        options[:class] = 'btn btn-default btn-sm'
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
    icon_text = safe_join([ content_tag(:i, '', class: "fa fa-#{(ACTION_ICONS[action.to_sym] || 'circle')}"), " #{action_text}" ], ' ')

    link = button[:url]

    options = button.except(:action, :url)

    options[:class] ||= ""
    options[:class] << ( %w(delete remove).include?(action) ? ' split-btn-danger' : ' split-btn-default' ) # use red text for delete, grey for default
    options[:class] << ' btn btn-default btn-sm' if top # add btn class to top link for button group style
    options[:class].strip! # remove leading the trailing spaces

    options.merge!( method: :delete ) if %w(delete remove).include?(action) # add method for delete
    # add confirmation message, override the default message if exist
    if %w(delete remove clone hide_on_web).include?(action)
      unless options[:data].present?
        options[:data] = { confirm: t(:'admin.button.confirm') }
      end
    end

    link_to icon_text, link, options
  end

  def format_date(date)
    date.present? ? date.strftime("%Y-%m-%d") : nil
  end

  def format_date_time(date)
    date.present? ? date.strftime("%Y-%m-%d %H:%M") : nil
  end

  def format_boolean(flag)
    flag ? "YES" : "NO" # TODO: I18n
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
    drp_data_hash = {
      drops: direction,
      start: start_date.kind_of?(String) ? start_date : start_date&.strftime('%F'),
      end: end_date.kind_of?(String) ? end_date : end_date&.strftime('%F'),
      separator: separator,
      format: timepicker ? "#{format} HH:mm" : format, # add time format if timepicker is included
      timepicker: timepicker,
      from: t(:'admin.daterangepicker.from'),
      to: t(:'admin.daterangepicker.to'),
      apply: t(:'admin.daterangepicker.apply'),
      cancel: t(:'admin.daterangepicker.cancel')
    }
    drp_data_hash
  end

  def system_date_format
    'YYYY-MM-DD'
  end

end
