defmodule acme.Application do

  use Application
  require Logger

  def start(_type, _args) do
  	port=Application.get_env(:acme, :service_port)
    ip=Application.get_env(:acme, :service_ip)


    # List all child processes to be supervised
    children = [
      acme.Repo,
      acme.Vault,
	    acme.Scheduler,
      	Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: acme.Router, options: [port: port, ip: ip])
    ]

    opts = [strategy: :one_for_one, name: acme.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
