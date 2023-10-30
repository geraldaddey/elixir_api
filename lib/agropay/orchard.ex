defmodule acme.Manor do
    import Ecto.Query
  #    import Decimal

    alias acme.Constant
    alias acme.BaseFunc
    alias acme.EctoFunc
    alias acme.Repo


    def process_Manor_req(str_params, secret_token, client_token, endpoint_url) do

        json_payload=Poison.encode!(str_params)
        signature=BaseFunc.gen_HMAC(secret_token, json_payload)

        ##send the POST request
        auth_hdr=["Authorization": "#{client_token}:#{signature}"]
        req_header=auth_hdr ++ Constant.header_str()
        options = [ssl: [{:versions, [:'tlsv1.2']}], timeout: Constant.timeout(), recv_timeout: Constant.timeout(), hackney: [pool: :first_pool]]

        result=HTTPoison.post(endpoint_url, json_payload, req_header, options)
        # IO.inspect result

        case result do

            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                IO.puts "\n\nResponse from Manor\n\n"
                IO.inspect body

                case Poison.decode(body) do
                    {:ok, parsed} ->
                        {:ok, parsed}
                    {:error, _err} ->
                        IO.puts "\n\nUnsupported response format; Invalid json\n\n"
                        {:error, Constant.err_invalid_req_format()}
                end
            {:ok, %HTTPoison.Response{body: body}} ->
                IO.puts "\n\n===========\n"
                IO.inspect body
                IO.puts "\n\n===========\n"

                case Poison.decode(body) do
                    {:ok, parsed} ->
                        {:error, parsed}
                    {:error, _err} ->
                        IO.puts "\n\nUnsupport response format; Invalid json\n\n"
                        {:error, Constant.err_invalid_req_format()}
                end
            {:error, %HTTPoison.Error{reason: reason}} ->
              IO.inspect reason
              {:error, reason}
        end

    end



    def account_inquiry(params) do

      datetime=DateTime.utc_now |> NaiveDateTime.to_string
      ts=String.slice(datetime, 0, 19)

      processing_id=BaseFunc.gen_uniq_id("AI")

      customer_number=params[:pan]
      bank_code=params[:bank_code]
      nw = params[:nw]
      trans_type="AII"
      secret_token=params[:secret_token]
      client_token=params[:client_token]
      service_id=params[:service_id]

      str=%{
          customer_number: customer_number,
          bank_code: bank_code,
          nw: nw,
          trans_type: trans_type,
          service_id: service_id,
          ts: ts,
          exttrid: processing_id
      }

      url="#{Constant.Manor_url()}"

      json_payload=Poison.encode!(str)
      IO.inspect json_payload

      signature=BaseFunc.gen_HMAC(secret_token, json_payload)
      auth_hdr=["Authorization": "#{client_token}:#{signature}"]
      req_header=auth_hdr ++ Constant.header_str()
      options = [ssl: [{:versions, [:'tlsv1.2']}], timeout: Constant.timeout(), recv_timeout: Constant.timeout(), hackney: [pool: :first_pool]]

      result=HTTPoison.post(url, json_payload, req_header, options)
      IO.inspect result
      case result do

          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
              IO.puts "\n\nResponse from name inquiry #{bank_code}\n\n"
              IO.inspect body

              case Poison.decode(body) do
                  {:ok, parsed} ->
                      {:ok, parsed}
                  {:error, _err} ->
                      IO.puts "\n\nUnsupported response format; Invalid json\n\n"
                      {:error, Constant.err_invalid_req_format()}
              end
          {:ok, %HTTPoison.Response{body: body}} ->
              IO.puts "\n\n===========\n"
              IO.inspect body
              IO.puts "\n\n===========\n"

              case Poison.decode(body) do
                  {:ok, parsed} ->
                      {:error, parsed}
                  {:error, _err} ->
                      IO.puts "\n\nUnsupport response format; Invalid json\n\n"
                      {:error, Constant.err_invalid_req_format()}
              end
          {:error, %HTTPoison.Error{reason: reason}} ->
            IO.inspect reason
            EctoFunc.log_err_resp(url, "customer_number", Poison.encode!(reason), trans_type)

            {:error, reason}
      end

    end



end
