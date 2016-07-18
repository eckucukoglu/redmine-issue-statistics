class IssuestatsHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "issuestats/issues_add_start_datetime"
  render_on :view_issues_show_details_bottom, :partial => "issuestats/issues_show_start_datetime"

  def controller_issues_new_after_save(context={})
    @project = Project.find(context[:issue][:project_id])
    if @project.module_enabled?("issuestats") == true
      if context[:params][:issuestats][:start_time] != "" && context[:params][:issue][:start_date] != nil
        start_date = context[:params][:issue][:start_date]
        start_time = context[:params][:issuestats][:start_time]
        date = Date.parse(start_date)
        time = Time.parse(start_time)
        start_datetime = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec) #, time.zone)
        old_issue_start_time = IssueStartTime.find_by_issue_id(context[:issue][:id])
        if old_issue_start_time != nil
          old_issue_start_time.update_attributes(:start_datetime => start_datetime, :issue_id => context[:issue][:id])
        else
          issue_start_time = IssueStartTime.new(:start_datetime => start_datetime, :issue_id => context[:issue][:id])
          issue_start_time.save
        end

      end
    end
    return ''
  end

  alias_method :controller_issues_edit_after_save, :controller_issues_new_after_save
end
