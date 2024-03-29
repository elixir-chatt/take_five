# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :take_five, target: Mix.target()
config :take_five, api_key: System.get_env("TAKE_FIVE_API_KEY")

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :nerves_network,
  regulatory_domain: "US"
  
config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
  ]
  
key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

network = [
          ssid: System.get_env("NERVES_NETWORK_SSID"),
          psk: System.get_env("NERVES_NETWORK_PSK"),
          key_mgmt: String.to_atom(key_mgmt),
          scan_ssid: 1 #if your WiFi setup as hidden
       ]

config :nerves_network, :default,
  wlan0: [
    networks: [
      network
    ]
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]


config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
