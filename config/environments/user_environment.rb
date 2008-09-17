module UserSystem
  CONFIG = {
    # Source address for user emails
    :email_from => TOOLKIT_MAIL,

    # Destination email for system errors
    :admin_email => '',

    # Sent in emails to users
    :app_url => DOC_ROOTURL,

    # Sent in emails to users
    :app_name => 'Bioinformatics Toolkit',

    # Email charset
    :mail_charset => 'utf-8',

    # Security token lifetime in hours
    :security_token_life_hours => 24,

    # Two column form input
    :two_column_input => true,

    # Add all changeable user fields to this array.
    # They will then be able to be edited from the edit action. You
    # should NOT include the email field in this array.
    :changeable_fields => [ 'firstname', 'lastname', 'institute', 'street', 'city', 'country', 'modeller_key' ],

    # Set to true to allow delayed deletes (i.e., delete of record
    # doesn't happen immediately after user selects delete account,
    # but rather after some expiration of time to allow this action
    # to be reverted).
    :delayed_delete => false,

    # Default is one week
    :delayed_delete_days => 7,

    # Server environment
    :server_env => "#{RAILS_ENV}"
  }
end
