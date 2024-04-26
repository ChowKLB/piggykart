# Dynamic settings the user can change within the app (helpful for self-hosting)
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  field :render_deploy_hook,
        type: :string,
        default: ENV["RENDER_DEPLOY_HOOK"],
        validates: { allow_blank: true, format: { with: /\Ahttps:\/\/api\.render\.com\/deploy\/srv-.+\z/ } }

  field :upgrades_mode,
        type: :string,
        default: ENV.fetch("UPGRADES_MODE", "manual"),
        validates: { inclusion: { in: %w[manual auto] } }

  field :upgrades_target,
        type: :string,
        default: ENV.fetch("UPGRADES_TARGET", "release"),
        validates: { inclusion: { in: %w[release commit] } }

  field :app_domain, default: ENV["APP_DOMAIN"]

  scope :smtp_configuration do
    field :smtp_host, default: ENV["SMTP_ADDRESS"]
    field :smtp_port, default: ENV["SMTP_PORT"]
    field :smtp_username, default: ENV["SMTP_USERNAME"]
    field :smtp_password, default: ENV["SMTP_PASSWORD"]
  end
end
