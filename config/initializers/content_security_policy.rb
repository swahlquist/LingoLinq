Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src :self, :data, 'https://fonts.gstatic.com'
  policy.img_src :self, :data, 'https://opensymbols.s3.amazonaws.com'
  policy.script_src :self
  policy.style_src :self, 'https://fonts.googleapis.com'
  policy.connect_src :self, 'https://www.opensymbols.org', 'https://api.stripe.com'
  policy.frame_src :self, 'https://js.stripe.com'
end
