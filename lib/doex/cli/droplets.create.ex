defmodule Doex.Cli.Droplets.Create do
  use FnExpr
  alias Doex.Cli.{Parser, Shell}

  @moduledoc"""
  Create a new digital ocean droplet

       doex droplets.create <name> <options>

  The following Digital Ocean options (some with examples) are shown below:

      --region              nyc3
      --size                512mb
      --image               ubuntu-14-04-x64
      --ssh_keys            1234,5467
      --backups             # add option to enable
      --ipv6                # add option to enable
      --user_data           # TODO figure out what this should be
      --private_networking  # add option to enable
      --volumes             # TODO figure out what this should be
      --tags                web,uat,temp

  Additional `doex` options that can be used

      --quiet               If set, keep output to a minimum
      --block               If set, block the process until the droplet is active

  For example

      doex droplets.create mydroplet \

        --region tor1 \

        --tags myt \

        --image ubuntu-14-04-x64 \

        --size 512mb

  If you have a specific config file, `mix help doex.config` then add it as an environment variable

      DOEX_CONFIG=/tmp/my.doex doex droplets.create mydroplet \

        --region tor1 \

        --tags myt \

        --image ubuntu-14-04-x64 \

        --size 512mb

  """

  @options %{
    region: :string,
    size: :string,
    image: :string,
    ssh_keys: :list,
    backups: :boolean,
    ipv6: :boolean,
    user_data: :string,
    private_networking: :boolean,
    volumes: :string,
    tags: :list,
    quiet: :boolean
  }

  def run(raw_args) do
    Doex.start

    raw_args
    |> Parser.parse(@options)
    |> invoke(fn {opts, [name]} -> opts |> Map.put(:name, name) end)
    |> create_droplet
    |> invoke(fn {:ok, %{"droplet" => %{"id" => id}}} -> Shell.info(id) end)
  end

  defp create_droplet(opts) do
    Shell.info("Creating droplet named #{opts[:name]}...", opts)
    Doex.Api.post("/droplets", opts)
    |> invoke(fn resp ->
         if opts[:block] do
           Doex.Cli.Block.block_until(resp)
           Shell.info("DONE, Creating droplet named #{opts[:name]}.", opts)
         else
           Shell.info("WORKING, Creating droplet named #{opts[:name]}.", opts)
         end
         resp
       end)
    |> Shell.inspect(opts)
  end

end
