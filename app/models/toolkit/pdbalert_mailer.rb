class PdbalertMailer < ActionMailer::Base

   def mail_result(params, sent_at = Time.now)
     @subject        = "PDB Alert: match found for #{params['db']}"
     @body["params"] = params
     @recipients     = params['mail']
     @from           = TOOLKIT_MAIL
     @sent_on        = sent_at
     @headers        = {}
   end

  def mail_warning_unchecked(params, sent_at = Time.now)
    @subject        = "PDB Alert: no activity for 1 year. Account deletion pending"
    @body["params"] = params
    @recipients     = params['mail']
    @from           = TOOLKIT_MAIL
    @sent_on        = sent_at
    @headers        = {}
  end

  def mail_warning_long(params, sent_at = Time.now)
    @subject        = "PDB Alert(reminder)"
    @body["params"] = params
    @recipients     = params['mail']
    @from           = TOOLKIT_MAIL
    @sent_on        = sent_at
    @headers        = {}
  end

end
