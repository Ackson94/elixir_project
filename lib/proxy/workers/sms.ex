defmodule Proxy.Workers.Sms do
  alias Proxy.Settings


  def send(mobile_num, msg) do
    Task.Supervisor.start_child(Proxy.TaskSupervisor, fn -> process_sm(mobile_num, msg) end)
  end

  defp process_sm(mobile_num, msg) do
    case Settings.gateway_configs() do
      nil ->
        {:error, "Gateway configurarions not found"}
      gateway_configs ->
        sms_params = prepare_sm_params(mobile_num, msg, gateway_configs)
        headers = [{"Content-Type", "application/json"}]
        options = [timeout: 50_000, recv_timeout: 60_000, hackney: [:insecure]]
        HTTPoison.post(String.trim(gateway_configs.url), Poison.encode!(sms_params), headers, options)
    end
  end

  defp prepare_sm_params(mobile_num, msg, gateway_configs) do
    %{
      message: msg,
      recipient: ["#{String.trim(mobile_num)}"],
      senderid: String.trim(gateway_configs.sender_id),
      username: String.trim(gateway_configs.username),
      password: String.trim(gateway_configs.password)
    }
  end

end



