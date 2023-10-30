defmodule acme.Transaction do

    import Ecto.Query

    alias acme.Processor
    alias acme.EctoFunc
    alias acme.Constant
    alias acme.BaseFunc
    alias acme.Adjustment
    alias acme.Operations


    import Ecto.Query



    def send_payment_req(params) do
        datetime=DateTime.utc_now |> NaiveDateTime.to_string
        ts=String.slice(datetime, 0, 19)

        nw=params[:nw]
        amount="#{params[:amount]}"
        processing_id=params[:processing_id]
        trans_type=params[:trans_type]
        nickname=params[:nickname]

        customer_number=params[:customer_number]
        reference=params[:reference]
        secret_key=params[:secret_key]
        client_key=params[:client_key]
        service_id=params[:service_id]
        payment_mode=params[:payment_mode]

        {:ok, str, url, skey, ckey}=case payment_mode do
            "MOM"->
                map_str=%{
                    customer_number: customer_number,
                    amount: amount,
                    reference: reference,
                    exttrid: processing_id,
                    trans_type: trans_type,
                    nw: nw,
                    service_id: service_id,
                    callback_url: Constant.callback_url(),
                    ts: ts,
                    nickname: nickname
                }

                endpoint_url="#{Constant.Manor_url()}"
                {:ok, map_str, endpoint_url, secret_key, client_key}
        end

        json_payload=Poison.encode!(str)
        IO.inspect json_payload

        signature=  BaseFunc.gen_HMAC(skey, json_payload)
        auth_hdr=["Authorization": "#{ckey}:#{signature}"]
        req_header=auth_hdr ++ Constant.header_str()
        options = [ssl: [{:versions, [:'tlsv1.2']}], timeout: Constant.timeout(), recv_timeout: Constant.timeout(), hackney: [pool: :first_pool]]

        result=HTTPoison.post(url, json_payload, req_header, options)
        IO.inspect result
        #retrieve the POST response and parse it
        case result do

            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                IO.puts "\n\nResponse from #{nw}\n\n"
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
              # EctoFunc.log_err_resp("", processing_id, Poison.encode!(reason), "CTM", nw)
              EctoFunc.log_err_resp("", processing_id, Poison.encode!(reason), trans_type)

              {:error, reason}
        end
    end



    def payment_callback(trans_status, trans_id, trans_ref, trans_msg) do
       # {:ok, Constant.err_return_success()}
        callback=acme.Repo.get_by(acme.Schema.PaymentCallback, [trans_id: trans_ref])
        sub_trans_status=String.slice(trans_status, 0,3)

        if is_nil(callback) do
            EctoFunc.save_callback(trans_status, trans_id, trans_ref, sub_trans_status, trans_msg)
            req_status=if sub_trans_status=="000" do
                true
            else
                false
            end

            case process_callback(trans_ref, req_status) do
                {:ok, _} ->
                    IO.puts "\nSuccess\n"
                    {:ok, Constant.err_return_success()}
                {:error, _} ->
                    IO.puts "\nFailure\n"
                    {:error, Constant.err_return_failure()}
            end
        else
            IO.puts "\n\nCallback for transaction with processing_id: #{trans_ref}, has already been processed; Discarding this transaction...\n"
            EctoFunc.save_duplicate_callback(trans_status, trans_id, trans_ref, sub_trans_status, trans_msg)
            {:error, Constant.err_return_failure()}
        end
    end



    def process_callback(trans_ref, req_status) do
        query=from(pr in "payment_request",
            left_join: pi in "payment_info", on: pr.payment_info_id==pi.id,
            where: pr.processing_id==^trans_ref and is_nil(pr.processed),
            select: %{customer_number: pr.pan, amount: pi.amount, charge: pi.amt_charge, pay_initiator_sub_tot: pi.pay_initiator_sub_tot, payment_req_id: pr.id, trans_type: pi.trans_type,
                payment_info_id: pi.id, processing_id: pr.processing_id, payment_mode: pr.payment_mode, initiator_code: pi.initiator_code, entity_code: pi.entity_code, beneficiary_mobile: pi.pan, beneficiary_code: pi.beneficiary_code, product_code: pi.product_code, qty: pi.product_qty, metric_unit_code: pi.metric_unit_code, beneficiary_name: pi.beneficiary_name},
            limit: 1,
            order_by: [desc: pr.created_at]
        ) |> acme.Repo.all

        if length(query) == 1 do
            IO.puts "\nStarting callback processing...\n"
            result=hd query
            IO.inspect result

            pay_initiator_sub_tot=result[:pay_initiator_sub_tot]
            amount=result[:amount]
            charge=result[:charge]
            processing_id=result[:processing_id]
            trans_type=result[:trans_type]
            payment_info_id=result[:payment_info_id]
            payment_req_id=result[:payment_req_id]
            initiator_code=result[:initiator_code]
            entity_code=result[:entity_code]
            _beneficiary_mobile=result[:beneficiary_mobile]
            beneficiary_name=result[:beneficiary_name]
            customer_number=result[:customer_number]
            beneficiary_code=result[:beneficiary_code]
            product_code=result[:product_code]
            qty=result[:qty]
            metric_unit_code=result[:metric_unit_code]

            if req_status do
                IO.puts "\nIt passed\n"
                IO.puts "\ntrans_type = #{trans_type}\n"

                case trans_type  do
                  "MTC" ->
                    #payout to beneficiary

                      EctoFunc.mark_payment_request(payment_req_id, true)
                      EctoFunc.mark_payment_info(payment_info_id, true)

                      _spawn_response=spawn fn ->
                        case run_final_processes(entity_code, initiator_code, processing_id, amount, charge, pay_initiator_sub_tot, trans_type, customer_number, beneficiary_code, product_code, qty, metric_unit_code, beneficiary_name) do
                          {:ok, _}->
                              {:ok, Constant.err_return_success()}
                          {:error, _}->
                              {:error, Constant.err_return_failure()}
                          _ ->
                            {:ok, Constant.err_return_success()}
                        end
                      end
                      {:ok, Constant.err_return_success()}

                  _ ->
                    {:ok, Constant.err_return_success()}
                end

            else
                IO.puts "\nIt failed\n"
                EctoFunc.mark_payment_request(payment_req_id, false)
                EctoFunc.mark_payment_info(payment_info_id, false)

                Adjustment.reverse_decrease_initiator_wallet_temp(entity_code, initiator_code, processing_id, pay_initiator_sub_tot, charge, trans_type)

                {:error, Constant.err_return_failure()}
            end
        else
            {:error, Constant.err_failed_req()}
        end
    end


    # acme.Transaction.run_final_processes("00000024", "00000031", "6420008053028", 0.100, 0.050, 0.150, "MTC", "233548332502", "", "00000027", 1, "kg", nil)
    def run_final_processes(entity_code, initiator_code, processing_id, _amount, _charge, _pay_initiator_sub_tot, trans_type, customer_number, beneficiary_code, product_code, qty, metric_unit_code, beneficiary_name) do

      case Adjustment.decrease_initiator_wallet(processing_id) do
        {:ok, _wallet_balance_resp} ->

          {:ok, computed_str}=Processor.compute_product_amount(initiator_code, product_code, qty, beneficiary_code)
          fee_details=computed_str.fee_details
          beneficiary_amount=fee_details[:beneficiary_amount_payable]
          {:ok, deductions}=BaseFunc.convert_to_decimal(fee_details[:deductions])
          {:ok, _ben_response}=Operations.extract_beneficiary_deductions(processing_id)

          case Operations.get_initiator_product_details(initiator_code, product_code) do
            {:ok, product_details} ->

              product_name=product_details.product_alias

              case Operations.get_initiator_info(initiator_code) do
                {:ok, initiator_details} ->

                  case Operations.get_entity_info(entity_code) do
                    {:ok, entity_info_det} ->

                      buying_company = entity_info_det.entity_alias
                      case Operations.check_wallet_exist(entity_code) do
                        {:ok, wallet_resp} ->

                          service_id=wallet_resp.service_id
                          secret_key=wallet_resp.secret_key
                          client_key=wallet_resp.client_key
                          sms_sender_id=wallet_resp.sms_sender_id

                          initiator_number=initiator_details.pay_initiator_mobile_number
                          pay_initiator_name = initiator_details.pay_initiator_name
                          product_reference="#{qty} #{metric_unit_code} of #{product_name}"

                          zero_val=Decimal.from_float(0.00)

                          beneficiary_msg=if Decimal.cmp(deductions, zero_val)==:gt do
                            "Payment of GHS #{beneficiary_amount} for #{product_reference} received. \nDeductions: GHS #{deductions}. \nPaid by: #{pay_initiator_name}. \nBuying company: #{buying_company}. \nRef: #{processing_id}"
                          else
                            "Payment of GHS #{beneficiary_amount} for #{product_reference} received. \nPaid by: #{pay_initiator_name}. \nBuying company: #{buying_company}. \nRef: #{processing_id}"
                          end

                          {:ok, _beneficiary_req_response}=BaseFunc.send_sms(entity_code, customer_number, beneficiary_msg, service_id, secret_key, client_key, sms_sender_id, processing_id, "B")

                          {:ok, beneficiary_name}=case Operations.get_beneficiary_list_val?(entity_code) do
                            {:ok, benef_list} ->
                                case benef_list do
                                  "SBL" -> #Strictly beneficiary list

                                    case Operations.get_beneficiary_account(beneficiary_code) do
                                      {:ok, beneficiary_info_detail} ->
                                          {:ok, beneficiary_info_detail.name}
                                      {:error, beneficiary_info_err} ->
                                          {:error, beneficiary_info_err}
                                    end

                                  "NBL" ->
                                    {:ok, beneficiary_name}
                                  _ ->
                                    {:ok, beneficiary_name}
                                end
                            {:error, _reasons} ->
                              {:ok, beneficiary_name}
                          end

                          pay_initiator_msg = "Payment of #{product_reference} to #{beneficiary_name} (#{customer_number}) successful. \nAmount paid: GHS #{beneficiary_amount}. \nRef ID:  #{processing_id}"
                          {:ok, _req_response}=BaseFunc.send_sms(entity_code, initiator_number, pay_initiator_msg, service_id, secret_key, client_key, sms_sender_id, processing_id, "P")

                          merchant_msg_body="Payment of GHS #{beneficiary_amount} made to #{customer_number}. Product: #{product_reference}"
                          Operations.send_merchant_alert(entity_code, trans_type, sms_sender_id, merchant_msg_body, processing_id, service_id, secret_key, client_key)

                          {:ok, Constant.err_return_success()}

                        {:error, wallet_err_resp} ->
                            {:error, wallet_err_resp}
                      end

                    {:error, entity_info_err} ->
                      {:error, entity_info_err}
                  end

                {:error, initiator_details_err} ->
                    {:error, initiator_details_err}
              end

              {:error, product_details_err} ->
                  {:error, product_details_err}
            end

        {:error, wallet_balance_err} ->
          {:error, wallet_balance_err}
      end

    end




    def trans_status_req(params) do
        processing_id=params[:processing_id]
        service_id=params[:service_id]
        skey=params[:secret_key]
        ckey=params[:client_key]
        trans_type=Constant.str_tsc()

        str=%{
            exttrid: processing_id,
            trans_type: trans_type,
            service_id: service_id
        }
        url=Constant.check_trans_status_Manor_url()

        json_payload=Poison.encode!(str)
        IO.inspect json_payload
        IO.inspect url

        signature=  BaseFunc.gen_HMAC(skey, json_payload)
        auth_hdr=["Authorization": "#{ckey}:#{signature}"]
        req_header=auth_hdr ++ Constant.header_str()
        options = [ssl: [{:versions, [:'tlsv1.2']}], timeout: Constant.timeout(), recv_timeout: Constant.timeout(), hackney: [pool: :first_pool]]

        result=HTTPoison.post(url, json_payload, req_header, options)
        IO.inspect result
        #retrieve the POST response and parse it
        case result do

            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                IO.puts "\n\nResponse from #{url}\n\n"
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
              # EctoFunc.log_err_resp("", processing_id, Poison.encode!(reason), "CTM", nw)
              EctoFunc.log_err_resp("", processing_id, Poison.encode!(reason), trans_type)

              {:error, reason}
        end
    end



end
