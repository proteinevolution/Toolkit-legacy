class ToolkitMailer < ActionMailer::Base

  def mail_done(params, sent_at = Time.now)
    @subject        = "MPI Bioinformatics Toolkit: job #{params['jobid']} completed"
    @body["params"] = params
    @recipients     = params['mail']
    @from           = TOOLKIT_MAIL
    @sent_on        = sent_at
    @headers        = {}
  end
  
  def mail_error(params, sent_at = Time.now)
    @subject        = "MPI Bioinformatics Toolkit: error in job #{params['jobid']}"
    @body["params"] = params
    @recipients     = params['mail']
    @from           = TOOLKIT_MAIL
    @sent_on        = sent_at
    @headers        = {}
  end
  
end
