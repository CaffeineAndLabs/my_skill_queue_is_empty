defmodule MySkillQueueIsEmpty do
  use Application

  def main(_args) do
    alias MySkillQueueIsEmpty.Mailer, as: Mailer
    alias MySkillQueueIsEmpty.Emails, as: Emails

    IO.puts "Is my skill queue empty ?"
    if get_skill_queue |> skill_queue_empty? do
      Emails.skill_queue_empty_mail |> Mailer.deliver_now
    else
      IO.puts "Queue empty !"
    end
  end

  def get_skill_queue do
    api_key_id = Application.get_env(:my_skill_queue_is_empty, :api_key_id)
    api_v_code = Application.get_env(:my_skill_queue_is_empty, :api_v_code)
    url = "https://api.eveonline.com/char/SkillQueue.xml.aspx?keyID=#{api_key_id}&vCode=#{api_v_code}"
    case HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}]]) do
      {:ok, %HTTPoison.Response {status_code: 200, body: body}} -> body
      {:ok, %HTTPoison.Response {status_code: 400, body: body}} -> body
      {:error, %HTTPoison.Error {reason: reason}} -> reason
    end
  end

  def skill_queue_empty?(doc) do
    xml = Quinn.parse doc
    Quinn.find(xml, [:result, :rowset, :row])
    |> Enum.empty?
  end
end

defmodule MySkillQueueIsEmpty.Mailer do
  use Bamboo.Mailer, otp_app: :my_skill_queue_is_empty
end

# Define your emails
defmodule MySkillQueueIsEmpty.Emails do
  import Bamboo.Email

  def skill_queue_empty_mail do
    to = Application.get_env(:my_skill_queue_is_empty, :mail_to)
    from = Application.get_env(:my_skill_queue_is_empty, :mail_from)
    subject = Application.get_env(:my_skill_queue_is_empty, :mail_subject)
    text_body = Application.get_env(:my_skill_queue_is_empty, :mail_test_body)

    new_email
    |> to(to)
    |> from(from)
    |> subject(subject)
    |> text_body(text_body)
  end
end
