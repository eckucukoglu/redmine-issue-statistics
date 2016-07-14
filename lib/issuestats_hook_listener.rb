class IssuestatsHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "issuestats/issues_add_start_datetime"
  render_on :view_issues_show_description_bottom, :partial => "issuestats/issues_show_start_datetime"

  def controller_issues_new_after_save(context={})

  end

  alias_method :controller_issues_edit_after_save, :controller_issues_new_after_save
end
