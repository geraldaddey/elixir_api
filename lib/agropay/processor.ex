defmodule acme.Processor do
  import Ecto.Query
  require Decimal

    alias acme.Constant
    alias acme.BaseFunc
    alias acme.EctoFunc
    alias acme.Repo
    alias acme.Transaction
    # alias acme.PdfGenerator
    # alias acme.Function
    alias acme.Adjustment
    alias acme.Operations
    alias acme.Manor




    def accept_entity_balance_check(entity_code) do
        case process_check_wallet_balance(entity_code) do
          {:ok, resp} ->
            {:ok, resp}
          {:error, err_msg} ->
            {:error, err_msg}
        end
    end


    def process_check_wallet_balance(entity_code) do

        if !is_nil(entity_code) do
            #check if SMS wallet configs exists
            case Operations.check_wallet_exist(entity_code) do
                {:ok, wallet_resp} ->
                    IO.inspect wallet_resp

                    client_token=wallet_resp.client_key
                    secret_token=wallet_resp.secret_key
                    endpoint_url=Constant.check_wallet_balance_url()

                    datetime=DateTime.utc_now |> NaiveDateTime.to_string
                    ts=String.slice(datetime, 0, 19)

                    str_params=%{ service_id: wallet_resp.service_id, trans_type: Constant.str_blc(), ts: ts }

                    case Manor.process_Manor_req(str_params, secret_token, client_token, endpoint_url) do
                        {:ok, bal_response} ->

                            # json_payload=Poison.decode!(bal_response)
                            IO.puts "json_payload here"
                            IO.inspect bal_response
                            sms_balance = bal_response["sms_bal"]
                            collection_balance = bal_response["collection_bal"]
                            payout_balance = bal_response["payout_bal"]
                            IO.puts "sms_balance = #{sms_balance}"

                            {:ok, %{resp_code: Constant.err_return_success.resp_code(), resp_desc: Constant.err_return_success.resp_desc(), entity_code: wallet_resp.entity_code, sms_balance: sms_balance, collection_balance: collection_balance, payout_balance: payout_balance}}

                        {:error, err_response} ->
                            {:error, err_response}
                    end

                {:error, err_response} ->
                    {:error, err_response}
            end
        else
            IO.puts "\nentity_div_code not provided.\n"
            {:error, Constant.err_missing_entity_code()}
        end
    end
   ######################################## Payment Request ######################################
   def process_account_inquiry(customer_number, nw, entity_code) do
     case Operations.check_wallet_exist(entity_code) do
         {:ok, wallet_resp} ->
             IO.inspect wallet_resp

             bank_code=case nw do
               "MTN" ->
                  "MTNM"
               "VOD" ->
                  "VODC"
                "AIR" ->
                  "ATGM"
                "TIG" ->
                  "ATGM"
             end

             str_params=%{pan: customer_number, bank_code: bank_code, service_id: wallet_resp.service_id, client_token: client_token, secret_token: secret_key, nw: nw}

             case Manor.account_inquiry(str_params) do
               {:ok, inquiry_reason} ->
                 {:ok, inquiry_reason}
               {:error, error_inquiry_reason} ->
                 {:error, error_inquiry_reason}
             end
         {:error, err_response} ->
             {:error, err_response}
     end
   end





















end




defmodule Util do
  def typeof(self) do
    cond do
      is_float(self)    							-> "float"
      is_number(self)   							-> "number"
      is_atom(self)     							-> "atom"
      is_boolean(self)  							-> "boolean"
      #is_binary(self)   							-> "binary"
      is_function(self) 							-> "function"
      is_list(self)     							-> "list"
      is_tuple(self)    							-> "tuple"
      Regex.match?(~r/foo/, self)					-> "alphabet"
      #String.match?(self, ~r/string[a-zA-Z]+$/) 	-> "alphabet"
      true              							-> "false"
    end
  end



end
