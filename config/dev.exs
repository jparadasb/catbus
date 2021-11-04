import Config

config :sms_bus, scraper: SmsBus.Tools.Scraper

config :catbus_dashboard, CatbusDashboardWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "sbaoTVVwNZjwxKAzPe521rJ1SjMZcO5xuukXGfRFw4o7+gK/j4JRjFrLdXZEhF1/",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]}
  ]
