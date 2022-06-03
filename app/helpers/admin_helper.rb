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
        options[:class] = 'btn btn-danger btn-sm'
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
end
