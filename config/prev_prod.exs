use Mix.Config

config :acme, acme.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("ACME_DBNAME"),
  username: System.get_env("ACME_DBUSER"),
  password: System.get_env("ACME_PASSWORD"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT"),
  prepare: :unnamed,
  pool_size: 40


config :acme, acme.Mailer,
       adapter: Bamboo.SendGridAdapter,
       api_key: System.get_env("SENDGRID_API_KEY")

config :sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY"),
  sandbox_enable: false

config :acme, acme.Vault,
       ciphers: [
         default: {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: Base.decode64!("JcROEK/m0hs4lDa049Lo1wr2iCb54Ew3aFT4pRqcRsw=")}
       ]

config :geoip, provider: :ipstack, api_key: "1c633f4c3f1fd6a5b67f52cc9132049b", use_https: false

config :acme, :json_library, Jason
config :logger, level: :debug
config :acme, service_port: 8333
config :acme, service_ip: {10,136,77,134}
config :acme, ecto_repos: [acme.Repo]

config :cloudex,
    api_key: System.get_env("CLOUDEX_API_KEY"),
    secret: System.get_env("CLOUDEX_SECRET"),
    cloud_name: System.get_env("CLOUDEX_CLOUD_NAME")

#Quantum scheduler task configuration
config :acme, acme.Scheduler,
jobs: [
    check_pending_transactions: [
      schedule: {:cron, "*/20 * * * *"}, # Runs every 20 minutes,
      task: {acme.Operations, :process_transaction_status_check, []},
      overlap: false
    ],
]
