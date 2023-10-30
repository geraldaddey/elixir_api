import Config
import Dotenvy

# For local development, read dotenv files inside the envs/ dir;
# for releases, read them at the RELEASE_ROOT
config_dir_prefix =
    System.fetch_env("RELEASE_ROOT")
    |> case do
        :error ->
            "envs/"
        {:ok, value} ->
            IO.puts("Loading dotenv files from #{value}")
            "#{value}/"
    end

source!([
    System.get_env(),
    "#{config_dir_prefix}.env",
    "#{config_dir_prefix}.#{config_env()}.env",
    "#{config_dir_prefix}.#{config_env()}.local.env",
])


case config_env() do
  :dev ->
    Code.require_file("runtime.dev.exs", "config")

  :prod ->
    Code.require_file("runtime.prod.exs", "config")

  :test ->
    Code.require_file("runtime.test.exs", "config")
end
