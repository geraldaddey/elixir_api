import Config
import Dotenvy

config :acme, acme.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: env!("ACME_DBNAME", :string),
  username: env!("ACME_DBUSER", :string),
  password: env!("ACME_DBPASS", :string),
  hostname: env!("ACME_DBHOST", :string),
  port: env!("ACME_DBPORT", :integer),
  pool_size: env!("ACME_POOL_SIZE", :integer),
  prepare: :unnamed

config :acme, acme.Vault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: Base.decode64!(env!("ACME_CLOAK_KEY", :string))}
  ]

config :acme, service_port: String.to_integer(env!("ACME_SERVICE_PORT", :string))

config :acme, service_ip: String.to_existing_atom(env!("ACME_SERVICE_IP", :string))

# Quantum scheduler task configuration
config :acme, acme.Scheduler,
  jobs: [
    ##    staged_requests: [
    ##        schedule: {:extended, "*/2"}, # Runs every two seconds,
    ##        task: {acme.Processor, :process_staged_requests, []},
    ##        overlap: false
    ##    ],
    pending_status: [
      # Runs every five minutes,
      schedule: {:cron, "*/5 * * * *"},
      task: {acme.Processor, :pending_payment_status, []},
      overlap: false
    ]
  ]
