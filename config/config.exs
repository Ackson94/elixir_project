# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :proxy,
  ecto_repos: [Proxy.Repo]

  # Email Config
config :proxy, Proxy.Emails.Mailer,
adapter: Bamboo.SMTPAdapter,
server: "mail.abbank.co.zm",
port: 25,
# or {:system, "SMTP_USERNAME"}
username: "probaseproxy@abbank.co.zm",
# or {:system, "SMTP_PASSWORD"}
password: "Notify123$",
# can be `:always` or `:never`
tls: :if_available,
allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
# can be `true`
ssl: false,
retries: 2

# Application logs
config :logger,
backends: [:console, {LoggerFileBackend, :info}, {LoggerFileBackend, :error}],
format: "[$level] $message\n"

config :logger, :info,
path: "C:/Proxy/application/logs/info.log",
level: :info

config :logger, :error,
path: "C:/Proxy/application/logs/error.log",
level: :error

# Application logs
# config :logger,
# backends: [:console, {LoggerFileBackend, :info}, {LoggerFileBackend, :error}],
# format: "[$level] $message\n"

# config :logger, :info,
# path: "/home/proxy/logs/info.log",
# level: :info

# config :logger, :error,
# path: "/home/Proxy/logs/error.log",
# level: :error,
# path: "/home/Proxy/certs/",


# # quantum jobs config
# config :logger, level: :debug,

config :proxy, Proxy.Scheduler,
  overlap: false,
  timeout: 30_000,
  timezone: "Africa/Cairo",
  jobs: [
    # login_token_refresh: [
    #   # schedule: "*/15 * * * *",
    #   schedule: "@weekly",
    #   task: {Proxy.Jobs.SessionManager, :fetch_session, []}
    # ],
    # archive_transactions: [
    #   schedule: "@monthly",
    #   task: {Proxy.Jobs.Archive, :perform, []}
    # ]
  ]


# Configures the endpoint
config :proxy, ProxyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2coF997AtdZdanbVLKmYWmDsIt4i35QrvCVS5DWh5JtWZ6UYuy6wTY1c4bC04n6p",
  render_errors: [view: ProxyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Proxy.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "ad59+J1+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"






# ##################################### CREATING LINUX SERVVICE ##############################
# [Unit]
# Description=myApp service
# After=local-fs.target network.target

# [Service]
# Type=simple
# User=deploy
# Group=deploy
# WorkingDirectory=/home/deploy/build/myApp/_build/prod/rel/myApp
# ExecStart=/home/deploy/build/myApp/_build/prod/rel/myApp/bin/myApp start
# ExecStop=/home/deploy/build/myApp/_build/prod/rel/myApp/bin/myApp stop
# EnvironmentFile=/etc/default/myApp.env
# Environment=LANG=en_US.utf8
# Environment=MIX_ENV=prod


# Environment=PORT=4000
# LimitNOFILE=65535
# UMask=0027
# SyslogIdentifier=myApp
# Restart=always


# [Install]
# WantedBy=multi-user.target

# #################### SAMPLE 2 #######################

# [Unit]
# Description=My Phoenix App
# After=network.target

# [Install]
# WantedBy=multi-user.target

# [Service]
# Environment="HOME=/var/app/my-phoenix-app"
# ExecStart=/var/app/my-phoenix-app/_build/prod/rel/my-phoenix-app/bin/my-phoenix-app start
# ExecStop=/var/app/my-phoenix-app/_build/prod/rel/my-phoenix-app/bin/my-phoenix-app stop
# SyslogIdentifier=simple
# Restart=always

# # 'StartLimitInterval' must be greater than 'RestartSec * StartLimitBurst' otherwise the service will be restarted indefinitely.
# # https://serverfault.com/a/800631
# RestartSec=5
# StartLimitBurst=3
# StartLimitInterval=10



# ######## NEXT COMMANDS #######
# sudo systemctl daemon-reload ----RELOADS SERVICES
# sudo systemctl start myapp.service ----STARTS THE SERVICE
# systemctl list-units --type=service ---- LIST SYSTEMMD SERVICES
# systemctl status myapp.service -----CHECK STATUS OF THE SERVICE












# ###### example kind ######
# All systemd services reside in /etc/systemd/system,
# so let’s create a file there to describe our websocket server script.
# vi /etc/systemd/system/chat_server.service

# and then the following is needed:

# [Unit]
# Description=Chat Server Service
# After=network.target

# [Service]
# Type=simple
# User=ankush
# ExecStart=php /home/ankush/chat_server/index.php
# Restart=on-abort


# [Install]
# WantedBy=multi-user.target


# Save the file and the next step is to reload the systemd daemon

# # systemctl daemon-reload
# and to start the service we just created:
# # systemctl start chat_server
# If you see no errors, that was it!

# ############ explanation ##########
# The [Unit] ---part defines a new service unit for systemd
# The After --- tells systemd to launch this service only after the networking services is launched
# The Type=simple tells systemd that this service isn’t supposed to fork itself.only one instance be running
# User=ankush means this service will run as the user “ankush”. We could change this to “root”
# ExecStart, as you can tell, is the actual command to run
# The WantedBy= ---directive tells systemd which target (think of groups) this service is part of.
# results in symbolic links being created inside that target to point to the service.

# More option for Restart logic
# on-failure –--- will be restarted when unclean exit code or signal
# always –--- restart when found down, clean or unclean signal
# on-abnormal –--- unclean signal, watchdog or timeout
# on-success –--- only when it was stopped by a clean signal or exit code

# Configuring Service to Start on Boot
# Once you are satisfied with the script and ensure it works, next you want to configure that so it trigger on boot and start.

# Go to /etc/systemd/system and execute below enable command (change the .service file name with the one you have)
# systemctl enable chat_server.service
# You’ll see a confirmation that it has created a symlink.
# Created symlink from /etc/systemd/system/multi-user.target.wants/chat_server.service to /etc/systemd/system/chat_server.service.
# Restart your server and you should see service starts on the boot.
