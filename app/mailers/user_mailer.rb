class UserMailer < ActionMailer::Base
  default :from => "The Yale Go Pigeon <pigeon@yalego.es>"
  def daily_bulletin(user)
    mail(
      :to => "#{user.name} <#{user.email}>",
      :subject => "Your Daily Bulletin from Yale Go!"
    )
  end
end