# defmodule acme.Processor do
#   import Ecto.Query
#   require Decimal
#
#     alias acme.Constant
#     alias acme.BaseFunc
#     alias acme.EctoFunc
#     alias acme.Repo
#     alias acme.Transaction
#     # alias acme.PdfGenerator
#     # alias acme.Function
#     alias acme.Adjustment
#     alias acme.Operations
#     alias acme.Manor
#
#
#
#
#     def accept_entity_balance_check(entity_code) do
#         case process_check_wallet_balance(entity_code) do
#           {:ok, resp} ->
#             {:ok, resp}
#           {:error, err_msg} ->
#             {:error, err_msg}
#         end
#     end
#
#
#     def process_check_wallet_balance(entity_code) do
#
#         if !is_nil(entity_code) do
#             #check if SMS wallet configs exists
#             case Operations.check_wallet_exist(entity_code) do
#                 {:ok, wallet_resp} ->
#                     IO.inspect wallet_resp
#
#                     client_token=wallet_resp.client_key
#                     secret_token=wallet_resp.secret_key
#                     endpoint_url=Constant.check_wallet_balance_url()
#
#                     datetime=DateTime.utc_now |> NaiveDateTime.to_string
#                     ts=String.slice(datetime, 0, 19)
#
#                     str_params=%{ service_id: wallet_resp.service_id, trans_type: Constant.str_blc(), ts: ts }
#
#                     case Manor.process_Manor_req(str_params, secret_token, client_token, endpoint_url) do
#                         {:ok, bal_response} ->
#
#                             # json_payload=Poison.decode!(bal_response)
#                             IO.puts "json_payload here"
#                             IO.inspect bal_response
#                             sms_balance = bal_response["sms_bal"]
#                             collection_balance = bal_response["collection_bal"]
#                             payout_balance = bal_response["payout_bal"]
#                             IO.puts "sms_balance = #{sms_balance}"
#
#                             {:ok, %{resp_code: Constant.err_return_success.resp_code(), resp_desc: Constant.err_return_success.resp_desc(), entity_code: wallet_resp.entity_code, sms_balance: sms_balance, collection_balance: collection_balance, payout_balance: payout_balance}}
#
#                         {:error, err_response} ->
#                             {:error, err_response}
#                     end
#
#                 {:error, err_response} ->
#                     {:error, err_response}
#             end
#         else
#             IO.puts "\nentity_div_code not provided.\n"
#             {:error, Constant.err_missing_entity_code()}
#         end
#     end
#
#
#
#
#     def accept_funds_allocation_request(assigner_entity_code, assignee_entity_code, amount, trans_type, payment_init, season_id, user_id) do
#         case process_funds_allocation(assigner_entity_code, assignee_entity_code, amount, trans_type, payment_init, season_id, user_id) do
#           {:ok, resp} ->
#             {:ok, resp}
#           {:error, err_msg} ->
#             {:error, err_msg}
#         end
#     end
#
#     # "item_data":"pay_initiator_code:0000471~amount:0.10;pay_initiator_code:000003~amount:0.10;pay_initiator_code:000004~amount:0.10;"
#     # payment_init="pay_initiator_code:00000010~amount:0.10;pay_initiator_code:000003~amount:0.10;pay_initiator_code:000004~amount:0.10;"
#     # acme.Processor.process_funds_allocation("00000003", "00000003", 0.10, "PIF", payment_init, 1)
#     def process_funds_allocation(assigner_entity_code, assignee_entity_code, amount, trans_type, payment_init, season_id, user_id) do
#
#       case Operations.validate_checklist_alloc(assigner_entity_code, trans_type) do
#         {:ok, _resp} ->
#           case trans_type do
#             "EFA" -> #Entity Fund Allocation
#
#               case process_entity_funds_allocation(assigner_entity_code, assignee_entity_code, trans_type, amount, season_id, user_id) do
#                 {:ok, resp} ->
#                  {:ok, resp}
#                 {:error, err_msg} ->
#                   {:error, err_msg}
#               end
#
#             "PIF" -> #Payment Initiator Funding
#               case process_pc_funds_allocation(assigner_entity_code, assignee_entity_code, trans_type, amount, payment_init, season_id, user_id) do
#                 {:ok, resp} ->
#                   {:ok, resp}
#                 {:error, err_msg} ->
#                   {:error, err_msg}
#               end
#           end
#         {:error, validation_resp} ->
#           {:error, validation_resp}
#       end
#
#     end
#
#
#     def process_entity_funds_allocation(assigner_entity_code, assignee_entity_code, trans_type, amount, season_id, user_id) do
#
#       pay_initiator_code=""
#
#       case process_check_wallet_balance(assignee_entity_code) do
#         {:ok, entity_bal} ->
#
#             {:ok, entity_balance}=BaseFunc.convert_to_decimal(entity_bal.payout_balance)
#             {:ok, alloc_amount}=BaseFunc.convert_to_decimal(amount)
#
#             IO.puts "assignee_entity_code: #{assignee_entity_code}, alloc_amount: #{alloc_amount}, entity_balance: #{entity_balance}"
#
#             if Decimal.gt?(entity_balance, alloc_amount) || Decimal.equal?(entity_balance, alloc_amount) do
#
#               ref_id=BaseFunc.gen_uniq_id("FA")
#               {:ok, season_id_int}=BaseFunc.convert_to_integer(season_id)
#               {:ok, result}=EctoFunc.save_fund_allocation(assigner_entity_code, assignee_entity_code, pay_initiator_code, alloc_amount, ref_id, trans_type, season_id_int, user_id)
#               fund_alloc_id=result.id
#               #notify approveres
#               case Operations.get_approvers_list(assignee_entity_code, Constant.entity_approver_type()) do
#                 {:ok, approvers_query} ->
#
#                     case Operations.check_wallet_exist(assignee_entity_code) do
#                       {:ok, wallet_resp} ->
#
#                           trans_type_desc="Funds to LBC"
#                           case loop_approvers_list(approvers_query, [], assignee_entity_code, fund_alloc_id, ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key, wallet_resp.sms_sender_id, amount, trans_type_desc, nil, nil) do
#                               {:ok, response} ->
#                                   Operations.send_merchant_alert(assignee_entity_code, trans_type, wallet_resp.sms_sender_id, response.message_body, response.sms_ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key)
#                                   {:ok, Constant.err_fund_alloc_received()}
#                               {:error, error_response} ->
#                                 {:error, error_response}
#                           end
#
#                       {:error, wallet_err_resp} ->
#                           {:error, wallet_err_resp}
#                     end
#
#                 {:error, err} ->
#                   {:error, err}
#               end
#
#             else
#                 {:error, Constant.err_alloc_amount_greater()}
#             end
#
#         {:error, err_msg} ->
#           {:error, err_msg}
#       end
#
#     end
#
#
#     def loop_approvers_list([], arr_acc, entity_code, fund_alloc_id, ref_id, service_id, secret_key, client_key, sms_sender_id, amount, trans_type_desc, sms_ref_id, message_body) do
#       if length(arr_acc)>0 do
#         {:ok, %{sms_ref_id: ref_id, message_body: message_body}}
#       else
#         {:error, Constant.err_empty_approvers_list()}
#       end
#     end
#
#     def loop_approvers_list([hd|tl], arr_acc, entity_code, fund_alloc_id, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id, amount, trans_type_desc, sms_ref_id, merchant_msg_body) do
#
#         fullname=hd[:first_name] <> " " <> hd[:last_name]
#         email=hd[:email]
#         auth_user_id=hd[:auth_user_id]
#
#         {:ok, phone}=BaseFunc.formatPhone(hd[:contact_number])
#         customer_number=to_string(["233", phone])
#         ref_id=BaseFunc.gen_uniq_id("FA")
#
#         EctoFunc.save_approver_record(entity_code, auth_user_id, fund_alloc_id, fund_alloc_ref_id)
#
#         message_body="Hi #{fullname}, you have a transaction pending you. Tranx: #{fund_alloc_ref_id}"
#         {:ok, req_response}=BaseFunc.send_sms(entity_code, customer_number, message_body, service_id, secret_key, client_key, sms_sender_id, fund_alloc_ref_id, Constant.activity_seg_cust())
#
#         merchant_msg_body="#{trans_type_desc} has been initiated and pending. Amount: GHS #{amount}"
#
#         IO.puts "customer_number: #{customer_number}, email: #{email}, message_body: #{message_body}"
#
#         rec=%{first_name: hd[:first_name], last_name: hd[:last_name], contact_number: hd[:contact_number], email: hd[:email]}
#         arr_acc=[rec] ++ arr_acc
#         IO.inspect rec
#
#         loop_approvers_list(tl, arr_acc, entity_code, fund_alloc_id, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id, amount, trans_type_desc, sms_ref_id, merchant_msg_body)
#     end
#
#
#
#
#     def process_pc_funds_allocation(assigner_entity_code, assignee_entity_code, trans_type, amount, payment_init, season_id, user_id) do
#       # "item_data":"pay_initiator_code:0000471~amount:0.10;pay_initiator_code:000003~amount:0.10;pay_initiator_code:000004~amount:0.10;"
#       req_params=%{assigner_entity_code: assigner_entity_code, assignee_entity_code: assignee_entity_code, trans_type: trans_type, amount: amount, payment_init: payment_init, user_id: user_id}
#       case Operations.get_entity_balance(assignee_entity_code) do
#         {:ok, entity_bal} ->
#
#             entity_bal=entity_bal.bal
#             {:ok, entity_balance}=BaseFunc.convert_to_decimal(entity_bal)
#             {:ok, alloc_amount}=BaseFunc.convert_to_decimal(amount)
#             IO.puts "assignee_entity_code: #{assignee_entity_code}, alloc_amount: #{alloc_amount}, entity_balance: #{entity_balance}"
#
#             if Decimal.gt?(entity_balance, alloc_amount) || Decimal.equal?(entity_balance, alloc_amount) do
#
#               fund_alloc_ref_id=BaseFunc.gen_uniq_id("FA")
#
#               payment_init=req_params[:payment_init]
#               IO.puts "About to parse payment_init\n"
#               IO.inspect payment_init
#
#               if !is_nil(payment_init) do
#                   arr=String.split(payment_init, ";", [trim: true])
#                   #num=length(arr)
#                   trans_type_desc="Fund Allocation to PC"
#                   case parse_item_data(arr, req_params, fund_alloc_ref_id, 0, 0.00, nil, season_id, assignee_entity_code, trans_type, trans_type_desc, amount) do
#                       {:ok, response}->
#                           {:ok, response}
#                       {:error, reason}->
#                           {:error, reason}
#                   end
#               else
#                   {:error, Constant.err_invalid_payment_data()}
#               end
#             else
#                 {:error, Constant.err_alloc_amount_greater()}
#             end
#
#         {:error, err_msg} ->
#           {:error, err_msg}
#       end
#
#     end
#
#
#
#
#     def parse_item_data([], req_params, processing_id, cnt, total_amount, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount) do
#         IO.puts "\nTotal items: #{cnt}\n"
#         IO.puts "\nTotal amount to be paid: #{total_amount}\n"
#         IO.puts "notify all authorizers of the transaction."
#         {:ok, Constant.err_return_success()}
#     end
#
#     def parse_item_data([hd|tl], req_params, processing_id, cnt, total_amount, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount) do
#         arr=String.split(hd, "~", [trim: true]) #"pay_initiator_code:0000471~amount:0.10;
#         parse_item_params(arr, %{}, req_params, processing_id, total_amount, 0, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount)
#         parse_item_data(tl, req_params, processing_id, cnt, total_amount, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount)
#     end
#
#     def parse_item_params([], arr_acc, req_params, processing_id, amt_accrual, counter, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount) do
#         amt_accrual=cond do
#             Decimal.is_decimal(amt_accrual)-> amt_accrual
#             true-> Decimal.from_float(amt_accrual)
#         end
#
#         required_keys=[:pay_initiator_code, :amount]
#         checkKeys=required_keys |> Enum.all?(&(Map.has_key?(arr_acc, &1)))
#
#         {:ok, init_str}=pay_initiator_process(arr_acc, checkKeys, counter, req_params, processing_id, amt_accrual, counter, entity_code, season_id, assignee_entity_code)
#         fund_alloc_id=init_str.fund_alloc_id
#
#         case Operations.get_approvers_list(assignee_entity_code, Constant.payout_approver_type()) do
#           {:ok, approvers_query} ->
#               case Operations.check_wallet_exist(assignee_entity_code) do
#                 {:ok, wallet_resp} ->
#
#                     case loop_approvers_list(approvers_query, [], assignee_entity_code, fund_alloc_id, processing_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key, wallet_resp.sms_sender_id, amount, trans_type_desc, nil, nil) do
#                         {:ok, response} ->
#                             Operations.send_merchant_alert(assignee_entity_code, trans_type, wallet_resp.sms_sender_id, response.message_body, response.sms_ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key)
#                             {:ok, Constant.err_fund_alloc_received()}
#                         {:error, error_response} ->
#                           {:error, error_response}
#                     end
#
#                 {:error, wallet_err_resp} ->
#                     {:error, wallet_err_resp}
#               end
#
#           {:error, err} ->
#             {:error, err}
#         end
#
#     end
#
#     def parse_item_params([hd|tl], arr_acc, req_params, processing_id, amt_accrual, counter, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount) do
#         #pay_initiator_code:0000471~amount:0.10;
#         if hd !="" do
#             sub_list2=String.split(hd, ":", [trim: true])
#
#             result=sub_list2 |> Enum.chunk_every(2) |> Enum.map(fn [a, b] -> {String.to_atom(String.trim(a)), String.trim(b)} end) |> Map.new
#
#             key_lst=Map.keys(result)
#             key=hd key_lst
#             arr_acc=Map.put(arr_acc, key, Map.get(result, key))
#
#             parse_item_params(tl, arr_acc, req_params, processing_id, amt_accrual, counter, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount)
#         else
#             parse_item_params(tl, arr_acc, req_params, processing_id, amt_accrual, counter, entity_code, season_id, assignee_entity_code, trans_type, trans_type_desc, amount)
#         end
#     end
#
#
#
#
#     def pay_initiator_process(arr_acc, checkKeys, counter, req_params, processing_id, amt_accrual, counter, entity_code, season_id, assignee_entity_code) do
#       assigner_entity_code=req_params[:assigner_entity_code]
#       assignee_entity_code=req_params[:assignee_entity_code]
#       trans_type=req_params[:trans_type]
#       user_id=req_params[:user_id]
#
#       counter=counter + 1
#       if checkKeys do
#           amount=cond do
#               Decimal.is_decimal(arr_acc[:amount])-> arr_acc[:amount]
#               true-> Decimal.new(arr_acc[:amount])
#           end
#
#           pay_initiator_code=arr_acc[:pay_initiator_code]
#
#           {:ok, season_id_int}=BaseFunc.convert_to_integer(season_id)
#           {:ok, result}=EctoFunc.save_fund_allocation(assigner_entity_code, assignee_entity_code, pay_initiator_code, amount, processing_id, trans_type, season_id_int, user_id)
#           str=%{amt_accrual: amt_accrual, counter: counter, ct: 0, entity_code: entity_code, fund_alloc_id: result.id}
#           {:ok, str}
#       else
#           IO.puts "\nEntity ID is nil\n"
#           str=%{amt_accrual: amt_accrual, counter: counter, ct: 0, entity_code: entity_code, fund_alloc_id: nil}
#           {:ok, str}
#       end
#
#     end
#
#
#
#     def accept_fund_approval(ref_id, approval_status, reason, user_id) do
#       case process_funds_approval(ref_id, approval_status, reason, user_id) do
#           {:ok, resp} ->
#             {:ok, resp}
#           {:error, err_msg} ->
#             {:error, err_msg}
#         end
#     end
#
#
#     # acme.Processor.process_funds_approval("4072907137060", true, "Approved",6)
#     def process_funds_approval(fund_alloc_id, approval_status, reason, auth_user_id) do
#         case EctoFunc.auth_cycle_exists?(auth_user_id, fund_alloc_id) do
#           true ->
#
#             case EctoFunc.auth_user_pending_approval?(auth_user_id, fund_alloc_id) do
#               true ->
#
#                 case Operations.is_last_approver?(fund_alloc_id) do
#                 true ->
#
#                     EctoFunc.mark_auth_cycle_status(fund_alloc_id, auth_user_id, reason, approval_status)
#                     EctoFunc.approve_fund_allocation(fund_alloc_id, approval_status)
#
#                     case Operations.get_fund_details(fund_alloc_id) do
#                       {:ok, details} ->
#                         trans_type = details.trans_type
#                         amount = details.amount
#                         entity_code = details.entity_code
#                         fund_alloc_ref_id = details.ref_id
#
#                         case trans_type do
#                           "EFA" -> #Entity Fund Allocation
#
#                             case Operations.check_wallet_exist(entity_code) do
#                               {:ok, wallet_resp} ->
#
#                                 Adjustment.adjust_entity_wallet(entity_code, amount, fund_alloc_ref_id, trans_type)
#                                 msg_body="Entity Fund allocation has been approved. Amount: GHS #{amount}"
#                                 Operations.send_merchant_alert(entity_code, trans_type, wallet_resp.sms_sender_id, msg_body, fund_alloc_ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key)
#                                 {:ok, Constant.err_fund_approved()}
#
#                               {:error, wallet_err_resp} ->
#                                   {:error, wallet_err_resp}
#                             end
#
#
#                           "PIF" -> #Payout Initiator Funding
#
#                             case Operations.get_pay_initiator_list(fund_alloc_id) do
#                               {:ok, initiator_query} ->
#
#                                   case Operations.check_wallet_exist(entity_code) do
#                                     {:ok, wallet_resp} ->
#
#                                         loop_pay_initiator_list(initiator_query, [], entity_code, fund_alloc_ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key, wallet_resp.sms_sender_id)
#                                         case Operations.get_approvers_list(entity_code, Constant.payout_approver_type()) do
#                                           {:ok, approvers_query} ->
#
#                                               trans_type_desc="Funds to Payout Initiators"
#                                               case loop_approvers_success_approval_list(approvers_query, [], entity_code, fund_alloc_id, fund_alloc_ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key, wallet_resp.sms_sender_id, amount, trans_type_desc, nil, nil) do
#                                                   {:ok, response} ->
#                                                       Operations.send_merchant_alert(entity_code, trans_type, wallet_resp.sms_sender_id, response.message_body, response.sms_ref_id, wallet_resp.service_id, wallet_resp.secret_key, wallet_resp.client_key)
#                                                       {:ok, Constant.err_fund_alloc_received()}
#                                                   {:error, error_response} ->
#                                                     {:error, error_response}
#                                               end
#
#                                           {:error, err} ->
#                                             {:error, err}
#                                         end
#
#                                     {:error, wallet_err_resp} ->
#                                         {:error, wallet_err_resp}
#                                   end
#
#                               {:error, err} ->
#                                 {:error, err}
#                             end
#                         end
#                     end
#
#                 false ->
#
#                   EctoFunc.mark_auth_cycle_status(fund_alloc_id, auth_user_id, reason, approval_status)
#                   if !approval_status do
#                     EctoFunc.mark_fund_alloc_status(fund_alloc_id, false)
#                   end
#
#                   {:ok, Constant.err_fund_approved()}
#                 _ ->
#                   #No pending approval. record must have been approved or rejected.
#                   {:ok, Constant.err_empty_pending_approval()}
#               end
#
#               false ->
#                 {:error, Constant.err_duplicate_approval()}
#             end
#
#           false ->
#             {:error, Constant.err_auth_cycle_not_found()}
#         end
#     end
#
#
#
#     def loop_pay_initiator_list([], arr_acc, entity_code, ref_id, service_id, secret_key, client_key, sms_sender_id) do
#       if length(arr_acc)>0 do
#         {:ok, Constant.err_fund_alloc_received()}
#       else
#         {:error, Constant.err_empty_approvers_list()}
#       end
#     end
#
#     def loop_pay_initiator_list([hd|tl], arr_acc, entity_code, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id) do
#
#         email=""#hd[:email]
#         trans_type=Constant.payment_initiator_type()
#         amount=hd[:amount]
#         pay_initiator_code=hd[:pay_initiator_code]
#
#         {:ok, phone}=BaseFunc.formatPhone(hd[:mobile_number])
#         customer_number=to_string(["233", phone])
#
#         Adjustment.adjust_pay_initiator_and_entity_wallet(entity_code, pay_initiator_code, amount, fund_alloc_ref_id, trans_type)
#         # Adjustment.decrease_entity_wallet(entity_code, amount, fund_alloc_ref_id, trans_type)
#
#         message_body="Hi, GHS #{amount} has been allocated to your account. Tranx: #{fund_alloc_ref_id}"
#         {:ok, req_response}=BaseFunc.send_sms(pay_initiator_code, customer_number, message_body, service_id, secret_key, client_key, sms_sender_id, fund_alloc_ref_id, Constant.activity_seg_cust())
#         IO.puts "customer_number: #{customer_number}, email: #{email}, message_body: #{message_body}"
#
#         rec=%{mobile_number: hd[:mobile_number], email: hd[:email]}
#         arr_acc=[rec] ++ arr_acc
#         IO.inspect rec
#
#         loop_pay_initiator_list(tl, arr_acc, entity_code, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id)
#     end
#
#
#     def loop_approvers_success_approval_list([], arr_acc, entity_code, fund_alloc_id, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id, amount, trans_type_desc, sms_ref_id, merchant_msg_body) do
#       if length(arr_acc)>0 do
#         {:ok, %{sms_ref_id: fund_alloc_ref_id, message_body: merchant_msg_body}}
#         # {:ok, Constant.err_fund_alloc_received()}
#       else
#         {:error, Constant.err_empty_approvers_list()}
#       end
#     end
#
#     def loop_approvers_success_approval_list([hd|tl], arr_acc, entity_code, fund_alloc_id, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id, amount, trans_type_desc, sms_ref_id, merchant_msg_body) do
#
#         fullname=hd[:first_name] <> " " <> hd[:last_name]
#         email=hd[:email]
#         auth_user_id=hd[:auth_user_id]
#
#         {:ok, phone}=BaseFunc.formatPhone(hd[:contact_number])
#         customer_number=to_string(["233", phone])
#         ref_id=BaseFunc.gen_uniq_id("FA")
#
#         EctoFunc.save_approver_record(entity_code, auth_user_id, fund_alloc_id, fund_alloc_ref_id)
#
#         message_body="Hi #{fullname}, Transaction with ID #{fund_alloc_ref_id} has been approved and allocated successfully."
#         {:ok, req_response}=BaseFunc.send_sms(entity_code, customer_number, message_body, service_id, secret_key, client_key, sms_sender_id, fund_alloc_ref_id, Constant.activity_seg_cust())
#
#         merchant_msg_body="#{trans_type_desc} has been approved and allocated successfully. Amount: GHS #{amount}"
#         IO.puts "customer_number: #{customer_number}, email: #{email}, message_body: #{message_body}, merchant_msg_body: #{merchant_msg_body}"
#
#         rec=%{first_name: hd[:first_name], last_name: hd[:last_name], contact_number: hd[:contact_number], email: hd[:email]}
#         arr_acc=[rec] ++ arr_acc
#         IO.inspect rec
#
#         loop_approvers_success_approval_list(tl, arr_acc, entity_code, fund_alloc_id, fund_alloc_ref_id, service_id, secret_key, client_key, sms_sender_id, amount, trans_type_desc, fund_alloc_ref_id, merchant_msg_body)
#     end
#
#
#
#
#     def accept_validate_service_code(service_code, customer_number) do
#       case process_service_code_validation(service_code, customer_number) do
#         {:ok, response} ->
#           {:ok, response}
#         {:error, reason} ->
#           {:error, reason}
#       end
#     end
#
#     # acme.Processor.process_service_code_validation("170","0553659353")
#     def process_service_code_validation(service_code, customer_number) do
#
#       case EctoFunc.service_code_exists?(service_code) do
#         true ->
#
#           query=from(asc in "assigned_service_code",
#               left_join: ei in "entity_info", on: asc.entity_code==ei.assigned_code,
#               left_join: eei in "entity_extra_info", on: ei.assigned_code==eei.entity_code,
#               where: asc.service_code==^service_code and asc.active_status==true and asc.del_status==false and ei.active_status==true and ei.del_status==false,
#               select: %{service_code_id: asc.id, entity_code: ei.assigned_code, entity_name: ei.entity_name, entity_alias: ei.entity_alias, entity_type_code: ei.entity_type_code, activity_cat_code: ei.activity_cat_code, benef_list: eei.benef_list}
#           ) |> acme.Repo.all
#
#           if length(query) > 0 do
#               result=hd query
#
#               service_code_id=result[:service_code_id]
#               entity_code=result[:entity_code]
#               entity_name=result[:entity_name]
#               entity_alias=result[:entity_alias]
#               benef_list=result[:benef_list]
#
#               is_pay_initiator_whitelisted = EctoFunc.is_pay_initiator_whitelisted?(customer_number, entity_code)
#
#               case EctoFunc.retreive_pay_initiator_info_whitelist(customer_number, entity_code) do
#                 {:ok, pay_initiator_rec} ->
#
#                   case Operations.get_beneficiary_list_val?(entity_code) do
#                     {:ok, benef_list} ->
#                         benef_lookup_up=case benef_list do
#                           "SBL" -> #Strictly beneficiary list
#                             true
#                           "NBL" ->
#                             false
#                           _ ->
#                             false
#                         end
#
#                         rec=%{entity_name: entity_name, entity_alias: entity_alias, entity_code: entity_code, pay_initiator_code: pay_initiator_rec.pay_initiator_code, pay_initiator_mobile_number: pay_initiator_rec.pay_initiator_mobile_number, pay_initiator_name: pay_initiator_rec.pay_initiator_name, beneficiary_lookup_upload: benef_lookup_up}
#
#                         case Operations.get_initiator_default_product(pay_initiator_rec.pay_initiator_code) do
#                           {:ok, default_product_details} ->
#
#                             prod_details=%{product_code: default_product_details.product_code, product_id: default_product_details.product_id, product_name: default_product_details.product_name, product_alias: default_product_details.product_alias, metric_unit_code: default_product_details.metric_unit_code, price_per_unit: default_product_details.price_per_unit, weight_per_unit: default_product_details.weight_per_unit, currency: default_product_details.currency, is_default: default_product_details.is_default}
#
#                             {:ok, %{record: rec, default_product_details: prod_details, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#
#                           {:error, err_msg} ->
#                             {:error, err_msg}
#                         end
#
#                     {:error, reasons} ->
#                       {:error, reasons}
#                   end
#
#                 {:error, c_reason} ->
#                   {:error, c_reason}
#               end
#
#           else
#               {:error, Constant.err_unassigned_service_code()}
#           end
#
#         false ->
#           {:error, Constant.err_shortcode_notfound()}
#       end
#
#     end
#
#
#
#     def accept_pay_initiator_balance_check(pay_initiator_code) do
#         case process_check_pay_initiator_balance(pay_initiator_code) do
#           {:ok, resp} ->
#             {:ok, resp}
#           {:error, err_msg} ->
#             {:error, err_msg}
#         end
#     end
#
#
#     def process_check_pay_initiator_balance(pay_initiator_code) do
#
#       case Operations.get_pay_initiator_balance(pay_initiator_code) do
#         {:ok, initiator_bal} ->
#             {:ok, initiator_bal}
#         {:error, err_msg} ->
#             {:error, err_msg}
#       end
#
#     end
#
#
#     # acme.Processor.process_beneficiary_lookup("00000002","00000024","0548332502")
#     def process_beneficiary_lookup(pay_initiator_code, entity_code, beneficiary_number, nw \\ nil) do
#
#       beneficiary_lookup_upload=case Operations.get_beneficiary_list_val?(entity_code) do
#         {:ok, benef_list} ->
#           IO.inspect benef_list
#
#           case benef_list do
#             "SBL" -> #Strictly beneficiary list
#               case Operations.get_lookup_intiator_beneficiary(pay_initiator_code, entity_code, beneficiary_number) do
#                 {:ok, beneficiary_details} ->
#                     IO.inspect beneficiary_details
#                     {:ok, beneficiary_details}
#                 {:error, err_msg} ->
#                     {:error, err_msg}
#               end
#
#             "NBL" ->
#
#               case process_account_inquiry(beneficiary_number, nw, entity_code) do
#                 {:ok, name_lookup_resp} ->
#                     name=name_lookup_resp["name"]
#                     {:ok, %{beneficiary_code: nil, name: name, entity_code: entity_code, beneficiary_acct_nw: nw, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#                 {:error, err_name_lookup_resp} ->
#                     # {:error, err_name_lookup_resp}
#                     {:ok, %{beneficiary_code: nil, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#               end
#
#             "HBL" ->
#               case Operations.get_lookup_intiator_beneficiary(pay_initiator_code, entity_code, beneficiary_number) do
#                 {:ok, beneficiary_details} ->
#                     IO.inspect beneficiary_details
#                     {:ok, beneficiary_details}
#                 {:error, err_msg} ->
#
#                   if is_nil(nw) do
#                     {:error, Constant.err_missing_beneficiary_accnt()}
#                   else
#                     case process_account_inquiry(beneficiary_number, nw, entity_code) do
#                       {:ok, name_lookup_resp} ->
#                           name=name_lookup_resp["name"]
#                           {:ok, %{beneficiary_code: nil, name: name, entity_code: entity_code, beneficiary_acct_nw: nw, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#                       {:error, err_name_lookup_resp} ->
#                           # {:error, err_name_lookup_resp}
#                           {:ok, %{beneficiary_code: nil, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#                     end
#                   end
#               end
#
#             _ ->
#
#               case process_account_inquiry(beneficiary_number, nw, entity_code) do
#                 {:ok, name_lookup_resp} ->
#                     name=name_lookup_resp["name"]
#                     {:ok, %{beneficiary_code: nil, name: name, entity_code: entity_code, beneficiary_acct_nw: nw, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#                 {:error, err_name_lookup_resp} ->
#                     # {:error, err_name_lookup_resp}
#                     {:ok, %{beneficiary_code: nil, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
#               end
#           end
#
#         {:error, reasons} ->
#           {:error, reasons}
#       end
#
#     end
#
#
#     def process_compute_product_amount(pay_initiator_code, product_code, qty, beneficiary_code \\ nil) do
#       case compute_product_amount(pay_initiator_code, product_code, qty, beneficiary_code) do
#         {:ok, resp} ->
#           {:ok, resp}
#         {:error, err_msg} ->
#           {:error, err_msg}
#       end
#     end
#
#
#     def compute_product_amount(pay_initiator_code, product_code, qty_val, beneficiary_code \\ nil) do
#       case Operations.get_initiator_product_details(pay_initiator_code, product_code) do
#         {:ok, product_details} ->
#
#               {:ok, product_amount}=BaseFunc.convert_to_decimal(product_details.price_per_unit)
#               {:ok, qty}=BaseFunc.convert_to_decimal(qty_val)
#               compute_amount=Decimal.mult(product_amount, qty)
#               IO.puts "compute_amount = #{compute_amount}"
#
#               case charge_info_req(product_code, compute_amount, Constant.activity_seg_merch()) do
#                 {:ok, charge_info} ->
#
#                   {:ok, charge}=BaseFunc.convert_to_decimal(charge_info.fee)
#                   final_vals=case charge_info.fee_type do
#                     "F" ->
#                       computed_charge=Decimal.mult(charge, qty)
#                       total_amount=Decimal.add(compute_amount, computed_charge)
#                       %{computed_charge: computed_charge, total_amount: total_amount}
#                     "P" ->
#                       computed_charge=charge
#                       total_amount=Decimal.add(compute_amount, computed_charge)
#                       %{computed_charge: computed_charge, total_amount: total_amount}
#                   end
#
#                   computed_charge=final_vals.computed_charge
#                   total_amount=final_vals.total_amount
#
#                   str_vals=if !is_nil(beneficiary_code) do
#
#                     {:ok, deductions_details}=Operations.compute_beneficiary_final_amount(compute_amount, beneficiary_code)
#                     beneficiary_amount_payable=deductions_details.total_benenficiary_amount
#                     deductions=deductions_details.deductions
#
#                     {:ok, deductions_details}=Operations.compute_pay_initator_final_amount(total_amount, beneficiary_code)
#                     pay_initiator_amount_payable=deductions_details.total_pay_initiator_amount
#
#                     str=%{beneficiary_amount_payable: beneficiary_amount_payable, pay_initiator_amount_payable: pay_initiator_amount_payable, deductions: deductions }
#                     str
#                   else
#                     str=%{beneficiary_amount_payable: compute_amount, pay_initiator_amount_payable: total_amount, deductions: 0 }
#                     str
#                   end
#
#
#                   case Operations.compute_benef_payout_share(beneficiary_code, str_vals.beneficiary_amount_payable, str_vals.pay_initiator_amount_payable) do
#                     {:ok, share_results} ->
#
#                         benef_payable=share_results.share_amount
#                         benef_balance=share_results.benef_balance
#                         pay_initiator_amount_share=share_results.pay_initiator_amount
#
#                         amount_details=%{product_code: product_code, beneficiary_amount_payable: "#{benef_payable}", pay_initiator_amount_payable: "#{pay_initiator_amount_share}",  deductions: "#{str_vals.deductions}", charge: "#{computed_charge}", total_amount: "#{total_amount}", product_net_amount: "#{compute_amount}", benef_balance: benef_balance}
#                         str=%{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, fee_details: amount_details}
#                         IO.inspect str
#                         {:ok, str}
#
#                     {:error, err_share_results} ->
#                         {:error, err_share_results}
#                   end
#
#                 {:error, charge_error} ->
#                   {:error, charge_error}
#               end
#
#         {:error, err_msg} ->
#             {:error, err_msg}
#       end
#     end
#
#
#
#
#     def charge_info_req(product_code, amount, charged_to) do
#         case Adjustment.compute_product_charge(product_code, amount, charged_to) do
#             {:ok, response}->
#                 str=%{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, fee: response.fee, fee_type: response.fee_type}
#                 IO.inspect str
#                 {:ok, str}
#             {:error, reason}->
#                 {:error, reason}
#         end
#     end
#
#
#
#
#     ###############################################################################################
#    ######################################## Payment Request ######################################
#    def payment_request(params) do
#
#        session_id=params[:session_id]
#        entity_code=params[:entity_code]
#        pay_initiator_code=params[:pay_initiator_code]
#        pay_initiator_number=params[:pay_initiator_number]
#        product_code=params[:product_code]
#        qty=params[:qty]
#        # charge=params[:charge]
#        product_amount=params[:product_amount]
#        # total_amount=params[:total_amount]
#        customer_number=params[:pan]
#        beneficiary_code=params[:beneficiary_code]
#        beneficiary_name=params[:beneficiary_name]
#        recipient_nw=params[:recipient_nw]
#        payment_mode=params[:payment_mode]
#        src=params[:src]
#        trans_type=params[:trans_type]
#
#        {:ok, computed_str}=compute_product_amount(pay_initiator_code, product_code, qty, beneficiary_code)
#        fee_details=computed_str.fee_details
#        {:ok, amt}=BaseFunc.convert_to_decimal(fee_details[:beneficiary_amount_payable])
#        {:ok, pay_initiator_amount}=BaseFunc.convert_to_decimal(fee_details[:pay_initiator_amount_payable])
#        {:ok, deductions}=BaseFunc.convert_to_decimal(fee_details[:deductions])
#        {:ok, charge}=BaseFunc.convert_to_decimal(fee_details[:charge])
#        {:ok, total_amount}=BaseFunc.convert_to_decimal(fee_details[:total_amount])
#        product_net_amount=fee_details[:product_net_amount]
#        benef_balance=fee_details[:benef_balance]
#
#        processing_id=BaseFunc.gen_uniq_id("PR")
#
#        #insert into temp beneficiary_input_repay table
#
#        if !is_nil(beneficiary_code) do
#          {:ok, _response_det}=Operations.process_beneficiary_deductions_temps(processing_id, product_net_amount, beneficiary_code)
#        end
#
#        case Adjustment.validate_pay_initiator_balance_payout(entity_code, pay_initiator_code, total_amount, session_id, trans_type) do
#          {:ok, _validate_resp} ->
#
#            case Operations.get_initiator_product_details(pay_initiator_code, product_code) do
#              {:ok, product_details} ->
#
#                 metric_unit_code=product_details.metric_unit_code
#                 # {:ok, product_weight}=BaseFunc.convert_to_decimal(product_details.weight_per_unit)
#                 product_weight=nil#product_details.weight_per_unit
#                 product_name=product_details.product_name
#                 reference="Sale of #{qty} #{product_name} (#{metric_unit_code})"
#                 IO.puts "\nThe reference is: #{reference}\n"
#
#                 record=acme.Repo.get_by(acme.Schema.EntityWalletConfig, [entity_code: entity_code, active_status: true, del_status: false])
#
#                 if !is_nil(record) do
#                     service_id=record.service_id
#                     secret_key=record.secret_key
#                     client_key=record.client_key
#
#                     case Operations.get_purchase_season(entity_code) do
#                       {:ok, purchase_season} ->
#                           purchase_season_id = purchase_season.purchase_season_id
#                           {:ok, response}=EctoFunc.save_payment_info(session_id, entity_code, pay_initiator_code, customer_number, qty, metric_unit_code, amt, charge, deductions, pay_initiator_amount, beneficiary_code, product_code, trans_type, purchase_season_id, product_weight, payment_mode, beneficiary_name)
#                           payment_info_id=response.id
#
#                           entity_record=acme.Repo.get_by(acme.Schema.EntityInfo, [assigned_code: entity_code, active_status: true, del_status: false])
#                           nickname=if !is_nil(entity_record) do
#                               entity_record.entity_alias
#                           else
#                             Constant.app_nickname()
#                           end
#
#                           nickname=if String.length(nickname) > 20 do
#                               IO.puts "\n===== Length of entity nickname too long. Reducing it to 20 characters... =====\n"
#                               String.slice(nickname, 0, 20)
#                           else
#                               nickname
#                           end
#
#                           reference="#{reference}-#{nickname}"
#                           reference=if String.length(reference) > 24 do
#                               IO.puts "\n===== Length of reference too long. Reducing it to 24 characters... =====\n"
#                               String.slice(reference, 0, 24)
#                           else
#                               reference
#                           end
#
#                           ##amt=Decimal.to_float(amt)
#                           case payment_mode do
#                               "MOM"->
#                                   IO.puts "Mobile money"
#
#                                   EctoFunc.save_payment_request(payment_info_id, processing_id, customer_number, recipient_nw, trans_type, amt, service_id, payment_mode, reference, charge)
#
#                                   str_params=%{amount: amt, reference: reference, service_id: service_id, trans_type: trans_type, payment_mode: payment_mode,
#                                       processing_id: processing_id, customer_number: customer_number, nw: recipient_nw, secret_key: secret_key, client_key: client_key, nickname: nickname}
#
#                                   case Adjustment.decrease_initiator_wallet_temp(entity_code, pay_initiator_code, processing_id, pay_initiator_amount, charge, trans_type, benef_balance) do
#                                     {:ok, wallet_balance_resp} ->
#
#                                       spawn_response=spawn fn ->
#
#                                         case Transaction.send_payment_req(str_params) do
#                                           {:ok, success} ->
#                                             {:ok, success}
#                                           {:error, trans_error} ->
#                                               Adjustment.reverse_decrease_initiator_wallet_temp(entity_code, pay_initiator_code, processing_id, pay_initiator_amount, charge, trans_type)
#                                             {:error, trans_error}
#                                         end
#
#                                       end
#                                       {:ok, Constant.err_payment_req_received()}
#
#                                     {:error, wallet_balance_err} ->
#                                       {:error, wallet_balance_err}
#                                   end
#
#                               # "CSH"->
#                               #     EctoFunc.mark_payment_info(payment_info_id, true)
#                                   {:ok, Constant.err_success_req_received()}
#                               "CRD"->
#                                   IO.puts "card payment"
#                           end
#
#                       {:error, err_purchase_season} ->
#                         {:error, err_purchase_season}
#                     end
#
#                 else
#                     IO.puts "\nNo wallet configuration found for entity\n"
#                 end
#
#              {:error, err_msg} ->
#                  {:error, err_msg}
#            end
#
#          {:error, pay_iniator_bal_err} ->
#             {:error, pay_iniator_bal_err}
#        end
#
#    end
#
#
#
#    # acme.Processor.process_account_inquiry("233541840988", "MTNM", "00000024")
#    def process_account_inquiry(customer_number, nw, entity_code) do
#      case Operations.check_wallet_exist(entity_code) do
#          {:ok, wallet_resp} ->
#              IO.inspect wallet_resp
#
#              client_token="0pZ4UiVI4fcT7oNRn9f/2kMlz4UXxHUaOsurLx66X0Unfj/3AMJVOrpus1l3KtF7P/3XJfLlSnP+ivDfEIkAqg=="
#              secret_key="U55CrCj3XbzgL8G0W6gY4uoqq4Arv1ie9/bVspaaUuq03ZOnkW+/BPtj8Cj8Xa0VpdtZG/C5NU5rpY62E21ZKw=="
#
#              bank_code=case nw do
#                "MTN" ->
#                   "MTNM"
#                "VOD" ->
#                   "VODC"
#                 "AIR" ->
#                   "ATGM"
#                 "TIG" ->
#                   "ATGM"
#              end
#
#              str_params=%{pan: customer_number, bank_code: bank_code, service_id: wallet_resp.service_id, client_token: client_token, secret_token: secret_key}
#
#              case Manor.account_inquiry(str_params) do
#                {:ok, inquiry_reason} ->
#                  {:ok, inquiry_reason}
#                {:error, error_inquiry_reason} ->
#                  {:error, error_inquiry_reason}
#              end
#          {:error, err_response} ->
#              {:error, err_response}
#      end
#    end
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# end
#
#
#
#
# defmodule Util do
#   def typeof(self) do
#     cond do
#       is_float(self)    							-> "float"
#       is_number(self)   							-> "number"
#       is_atom(self)     							-> "atom"
#       is_boolean(self)  							-> "boolean"
#       #is_binary(self)   							-> "binary"
#       is_function(self) 							-> "function"
#       is_list(self)     							-> "list"
#       is_tuple(self)    							-> "tuple"
#       Regex.match?(~r/foo/, self)					-> "alphabet"
#       #String.match?(self, ~r/string[a-zA-Z]+$/) 	-> "alphabet"
#       true              							-> "false"
#     end
#   end
#
#
#
# end
