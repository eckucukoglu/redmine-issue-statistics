Redmine::Plugin.register :issuestats do
  name 'Issue Statistics'
  url 'https://github.com/eckucukoglu/redmine-issue-statistics'
  description 'Issue statistics'
  author 'Emre Can Kucukoglu'
  author_url 'http://eckucukoglu.com'
  version '0.0.1'
  requires_redmine version_or_higher: '2.5.2'

  menu :project_menu, :issuestats, { :controller => 'issuestats', :action => 'index' }, :caption => 'Statistics', :after => :files, :param => :project_id

  project_module :issuestats do
    permission :view_issue_statistics, :issuestats => [:index, :show]
  end

end
