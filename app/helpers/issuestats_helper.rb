module IssuestatsHelper
  def get_issue_intervention_time (issue, intervention_status)
    issue_start_time = IssueStartTime.find_by_issue_id(issue.id)
    if issue_start_time != nil
      start_datetime = issue_start_time.start_datetime
    else
      if (issue.start_date.year == issue.created_on.year &&
          issue.start_date.month == issue.created_on.month &&
          issue.start_date.day == issue.created_on.day)
        start_datetime = issue.created_on
      else
        start_datetime = DateTime.new(issue.start_date.year, issue.start_date.month, issue.start_date.day)
      end
    end

    @journals = Journal.where(journalized_id: issue.id).order("created_on ASC")
    intervention_time = -1;

    @journals.each do |journal|
      action_datetime = journal.created_on
      jdetails = JournalDetail.where(journal_id: journal.id)

      jdetails.each do |jdetail|
        if jdetail.property == 'attr' && jdetail.prop_key == 'status_id' && jdetail.value == intervention_status
          intervention_time = ((action_datetime - start_datetime)/60).to_i
          break
        end
      end

      if intervention_time != -1
        break
      end
    end

    if intervention_time >= 0
      return intervention_time
    else
      return "Not intervened"
    end
  end

  def get_issue_resolve_time (issue, intervention_status, resolve_status)
    @journals = Journal.where(journalized_id: issue.id).order("created_on ASC")
    first_intervene_time = -1

    @journals.each do |journal|
      action_datetime = journal.created_on
      jdetails = JournalDetail.where(journal_id: journal.id)

      if issue.status_id.to_i == intervention_status.to_i
        return "Not resolved"
      end

      jdetails.each do |jdetail|
        if jdetail.property == 'attr' && jdetail.prop_key == 'status_id' && jdetail.value == intervention_status
          first_intervene_time = action_datetime
          break
        end
      end

      if first_intervene_time != -1
        break
      end
    end

    @journals = Journal.where(journalized_id: issue.id).order("created_on DESC")
    resolve_time = -1

    @journals.each do |journal|
      action_datetime = journal.created_on
      jdetails = JournalDetail.where(journal_id: journal.id)

      jdetails.each do |jdetail|
        if jdetail.property == 'attr' && jdetail.prop_key == 'status_id' && jdetail.value == resolve_status && first_intervene_time != -1
          resolve_time = ((action_datetime - first_intervene_time)/60).to_i
          break
        end
      end

      if resolve_time != -1
        break
      end
    end

    if resolve_time >= 0
      return resolve_time
    else
      return "Not resolved"
    end
  end

  def get_time_statistics (issues, intervention_time, resolve_time, intervention_status, resolve_status)
    expired_intervention_count = 0
    nonexpired_intervention_count = 0
    expired_resolve_count = 0
    nonexpired_resolve_count = 0
    not_intervene_count = 0
    not_resolve_count = 0

    issues.each do |issue|
      int_time = get_issue_intervention_time(issue, intervention_status)
      res_time = get_issue_resolve_time(issue, intervention_status, resolve_status)

      if (int_time == "Not intervened")
        not_intervene_count+= 1
      elsif (int_time > intervention_time.to_i)
        expired_intervention_count+= 1
      else
        nonexpired_intervention_count+= 1
      end

      if (res_time == "Not resolved")
        not_resolve_count+= 1
      elsif (res_time > resolve_time.to_i)
        expired_resolve_count+= 1
      else
        nonexpired_resolve_count+= 1
      end
    end

    results = Array.new
    results.push("Expired int: " + expired_intervention_count.to_s)
    results.push("Expired res: " + expired_resolve_count.to_s)
    results.push("Not Expired int: " + nonexpired_intervention_count.to_s)
    results.push("Not Expired res: " + nonexpired_resolve_count.to_s)
    results.push("Not intervened: " + not_intervene_count.to_s)
    results.push("Not resolved: " + not_resolve_count.to_s)

    return results
  end

  def get_time_averages (issues, intervention_time, resolve_time, intervention_status, resolve_status)
    sum_intervention_time = 0.0
    count_intervened_issue = 0
    avg_intervention_time = 0.0

    sum_resolve_time = 0.0
    count_resolved_issue = 0
    avg_resolve_time = 0.0

    issues.each do |issue|
      int_time = get_issue_intervention_time(issue, intervention_status)
      res_time = get_issue_resolve_time(issue, intervention_status, resolve_status)

      if (int_time != "Not intervened")
        count_intervened_issue += 1
        sum_intervention_time += int_time
      end

      if (res_time != "Not resolved")
        count_resolved_issue += 1
        sum_resolve_time += res_time
      end
    end

    avg_intervention_time = sum_intervention_time / count_intervened_issue
    avg_resolve_time = sum_resolve_time / count_resolved_issue

    results = Array.new
    results.push("Avg int time: " + avg_intervention_time.round(1).to_s)
    results.push("Avg res time: " + avg_resolve_time.round(1).to_s)

    return results
  end

end
