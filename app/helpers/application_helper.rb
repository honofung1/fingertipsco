module ApplicationHelper
  def page_title(page_title = '', admin = false)
    base_title = if admin
                   'Fingertips Co APP(管理頁面)'
                 else
                   'Fingertips Co APP'
                 end

    page_title.empty? ? base_title : page_title + ' | ' + base_title
  end
end
