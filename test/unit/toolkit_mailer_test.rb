require File.dirname(__FILE__) + '/../test_helper'
require 'toolkit_mailer'

class ToolkitMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_mail_done
    @expected.subject = 'ToolkitMailer#mail_done'
    @expected.body    = read_fixture('mail_done')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ToolkitMailer.create_mail_done(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/toolkit_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
