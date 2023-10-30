import Config
import Dotenvy

config :acme, acme.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: env!("ACME_DBNAME", :string),
  username: env!("ACME_DBUSER", :string),
  password: env!("ACME_DBPASS", :string),
  hostname: env!("ACME_DBHOST", :string),
  port: env!("ACME_DBPORT", :integer),
  pool_size: 4,
  show_sensitive_data_on_connection_error: true

config :acme, acme.Vault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM, tag: "AES.GCM.V1", key: Base.decode64!(env!("ACME_CLOAK_KEY", :string))}
  ]

  # Get the IP address of the 'bond0' interface
data = :inet.getifaddrs()
{:ok, interfaces} = data

# Find the 'bond0' tuple
bond0_tuple =
  Enum.find(interfaces, fn
    {'bond0', _info} -> true
    _ -> false
  end)

# Get the "addr" value from the "bond0" tuple
{'bond0', info} = bond0_tuple
IO.puts("info: #{inspect(info)}")
addr = Keyword.get(info, :addr)

config :acme, service_ip: addr
config :acme, service_port: env!("ACME_SERVICE_PORT", :integer)

config :cloudex,
    api_key: env!("CLOUDEX_API_KEY", :string ),
    secret: env!("CLOUDEX_SECRET", :string),
    cloud_name: env!("CLOUDEX_CLOUD_NAME", :string)

# Quantum scheduler task configuration
config :acme, acme.Scheduler,
  jobs: [
    # staged_requests: [
    #   schedule: {:extended, "*/10"}, # Runs every two seconds,
    #    task: {acme.Processor, :process_staged_requests, []},
    #    overlap: false
    # ]
  ]
