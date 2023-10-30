defmodule acme.Operations do
    import Ecto.Query

    alias acme.Constant
    alias acme.Processor
    alias acme.BaseFunc
    alias acme.EctoFunc
    alias acme.Repo
    alias acme.Transaction
    require Decimal



    def check_wallet_exist(entity_code) do

        if !is_nil(entity_code) && String.trim(entity_code) != "" do

            entity_info = acme.Repo.get_by(acme.Schema.EntityInfo, assigned_code: entity_code, active_status: true, del_status: false)

            if !is_nil(entity_info) do
                query=from(ewc in "entity_wallet_config",
                    where: ewc.entity_code==^entity_code
                        and ewc.active_status==true
                        and ewc.del_status==false,
                    order_by: [desc: ewc.created_at],
                    limit: 1,
                    select: %{service_id: ewc.service_id, client_key: ewc.client_key, secret_key: ewc.secret_key, entity_code: ewc.entity_code, sms_sender_id: ewc.sms_sender_id}
                )|> acme.Repo.all

                if length(query)==1 do
                    result=hd query
                    IO.inspect result
                    IO.puts "\nWallet exists. entity_code = #{entity_code}\n"
                    {:ok, result}
                else
                    {:error, reason: "Wallet does not exist"}
                end

            else
                IO.puts "\nentity_code does not exist.\n"
                {:error, reason: "Wallet does not exist"}
            end

        else
            {:error, Constant.err_missing_request_input()}
        end

    end



    def get_entity_info(entity_code) do

      if !is_nil(entity_code) do
          query=from(ei in "entity_info",
              where: ei.assigned_code==^entity_code and ei.active_status==true  and ei.del_status==false,
              order_by: [desc: ei.created_at],
              limit: 1,
              select: %{entity_alias: ei.entity_alias}
          )|> acme.Repo.all

          if length(query)==1 do
              result=hd query
              IO.inspect result

              IO.puts "\Entity Info exists. entity_code = #{entity_code}\n"
              {:ok, result}

          else
              {:error, reason: "Entity does not exist"}
          end

      else
          IO.puts "\nentity_code does not exist.\n"
          {:error, reason: "Wallet does not exist"}
      end

    end






    def get_approvers_list(entity_code, trans_type) do

      case EctoFunc.entity_info_exists?(entity_code) do
        true ->

          query=from(au in "auth_users",
              left_join: ac in "authorizer_config", on: au.authorizer_config_code==ac.assigned_code,
              left_join: u in "users", on: au.auth_user_id==u.id,
              where: ac.trans_type==^trans_type and au.entity_code==^entity_code and ac.active_status==true and ac.del_status==false and u.active_status==true and u.del_status==false and au.active_status==true and au.del_status==false,
              select: %{id: u.id, auth_user_id: au.auth_user_id, trans_type: ac.trans_type, first_name: u.first_name, last_name: u.last_name, contact_number: u.contact_number, email: u.email},
              order_by: [asc: au.created_at]
          ) |> acme.Repo.all

          if length(query) > 0 do
                {:ok, query}
            #   loop_approvers_list(query, [], entity_code)
          else
              {:error, Constant.err_empty_approvers_list()}
          end

        false ->
          {:error, Constant.err_empty_entity_record()}
      end

    end


    def get_pay_initiator_list(fund_alloc_id) do

      query=from(fa in "fund_alloc",
            left_join: pii in "pay_initiator_info", on: fa.pay_initiator_code==pii.assigned_code,
              where: fa.id==^fund_alloc_id and fa.active_status==true and fa.del_status==false and pii.active_status==true and pii.del_status==false,
              select: %{id: fa.id, pay_initiator_code: fa.pay_initiator_code, trans_type: fa.trans_type, amount: fa.amount, mobile_number: pii.mobile_number},
              order_by: [asc: fa.created_at]
          ) |> acme.Repo.all

          if length(query) > 0 do
                {:ok, query}
          else
              {:error, Constant.err_empty_approvers_list()}
          end

    end




    def get_entity_balance(entity_code) do
      query=from(esa in "entity_service_acc",
            where: esa.entity_code==^entity_code and esa.active_status==true and esa.del_status==false,
            order_by: [desc: esa.created_at],
            limit: 1,
            select: %{balance: esa.net_bal}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.inspect result
            balance = result[:balance]
            {:ok, %{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, entity_code: entity_code, balance: "GHS #{balance}", bal: "#{balance}"}}
        else
            balance=0
            {:ok, %{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, entity_code: entity_code, balance: "GHS #{balance}", bal: "#{balance}"}}
        end
    end


    def is_last_approver?(fund_alloc_id) do
        count=EctoFunc.count_pending_auth_cycle(fund_alloc_id)
        status=cond do
            count < 1  -> nil
            count == 1 -> true
            count > 1  -> false
            true       -> false
        end
        IO.puts "pending approvers: #{count}. status: #{status}"
        status
    end


    def get_fund_details(fund_alloc_id) do
      query=from(fa in "fund_alloc",
            where: fa.id==^fund_alloc_id and fa.active_status==true and fa.del_status==false,
            order_by: [desc: fa.created_at],
            limit: 1,
            select: %{amount: fa.amount, ref_id: fa.ref_id, entity_code: fa.assignee_entity_code, trans_type: fa.trans_type, approval_status: fa.approval_status, approved_at: fa.approved_at, created_at: fa.created_at}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.inspect result
            IO.puts "\nFund details exists. fund_alloc_id = #{fund_alloc_id}\n"
            {:ok, result}
        else
            {:error, Constant.err_missing_fund_details()}
        end
    end



    def get_pay_initiator_balance(initiator_code) do
      query=from(isa in "initiator_service_acc",
            where: isa.initiator_code==^initiator_code and isa.active_status==true and isa.del_status==false,
            order_by: [desc: isa.created_at],
            limit: 1,
            select: %{balance: isa.net_bal, gross_balance: isa.gross_bal}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.inspect result
            balance=Decimal.round("#{result[:balance]}", 2)
            {:ok, %{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, pay_initiator_code: initiator_code, balance: "GHS #{balance}", bal: "#{balance}"}}
        else
            balance=0
            {:ok, %{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, pay_initiator_code: initiator_code, balance: "GHS #{balance}", bal: "#{balance}"}}
        end
    end


    def get_entity_benef_identifier(entity_code) do
      query=from(eei in "entity_extra_info",
            where: eei.entity_code==^entity_code and eei.active_status==true and eei.del_status==false,
            order_by: [desc: eei.created_at],
            limit: 1,
            select: %{beneficiary_identifier: eei.benef_identifier}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.inspect result
            {:ok, %{resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc, beneficiary_identifier: result[:beneficiary_identifier]}}
        else
            {:error, Constant.err_no_record_found()}
        end
    end



    def get_lookup_intiator_beneficiary(pay_initiator_code, entity_code, beneficiary_number) do

        case get_entity_benef_identifier(entity_code) do
          {:ok, entity_benef_identifier} ->

            beneficiary_identifier=if !is_nil(entity_benef_identifier.beneficiary_identifier) do
              entity_benef_identifier.beneficiary_identifier
            else
              "M"
            end

            query=case beneficiary_identifier do
              "M" ->
                #mobile number
                {:ok, benef_acct_no}=BaseFunc.parse_phone_number(beneficiary_number, "GH")

                query=from(bai in "beneficiary_acc_info",
                      left_join: bi in "beneficiary_info", on: bi.assigned_code==bai.beneficiary_code,
                      where: bai.acct_no==^benef_acct_no and bi.entity_code==^entity_code and bai.is_default==true and bi.active_status==true and bi.del_status==false and bai.active_status==true and bai.del_status==false,
                      order_by: [desc: bi.created_at],
                      limit: 1,
                      select: %{beneficiary_code: bi.assigned_code, name: fragment("concat(?, ' ', ?)", bi.first_name, bi.last_name), entity_code: bi.entity_code, pan: bai.acct_no, pan_nw: bai.nw, pan_type: bai.acct_type, id_no: bi.id_no, id_type: bi.id_type}
                  )|> acme.Repo.all
                  query

              "C" ->
                #search by custom code
                query=from(bi in "beneficiary_info",
                      # left_join: bi in "beneficiary_info", on: bi.assigned_code==bai.beneficiary_code,
                      where: bi.custom_id==^beneficiary_number and bi.entity_code==^entity_code and bi.active_status==true and bi.del_status==false,
                      order_by: [desc: bi.created_at],
                      limit: 1,
                      select: %{beneficiary_code: bi.assigned_code, name: fragment("concat(?, ' ', ?)", bi.first_name, bi.last_name), entity_code: bi.entity_code, id_no: bi.id_no, id_type: bi.id_type}
                  )|> acme.Repo.all
                  query
            end

            if length(query)==1 do
                result=hd query
                IO.puts "\nBeneficiary details exists. beneficiary_number = #{beneficiary_number}\n"
                {:ok, %{beneficiary_code: result[:beneficiary_code], name: result[:name], entity_code: entity_code, id_no: result[:id_no], id_type: result[:id_type], beneficiary_acct_number: result[:pan], beneficiary_acct_nw: result[:pan_nw], beneficiary_acct_type: result[:pan_type], resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
            else
                {:error, Constant.err_missing_beneficiary_accnt()}
            end

          {:error, error_entity_benef_identifier} ->
            {:error, error_entity_benef_identifier}
        end
    end


    def get_beneficiary_account(beneficiary_code) do

      query=from(bi in "beneficiary_info",
            left_join: bai in "beneficiary_acc_info", on: bi.assigned_code==bai.beneficiary_code,
            where: bi.assigned_code==^beneficiary_code and bi.active_status==true and bi.del_status==false and bai.active_status==true and bai.del_status==false,
            order_by: [desc: bi.created_at],
            limit: 1,
            select: %{beneficiary_code: bi.assigned_code, name: fragment("concat(?, ' ', ?)", bi.first_name, bi.last_name), entity_code: bi.entity_code, pan: bai.acct_no, pan_nw: bai.nw, pan_type: bai.acct_type, id_no: bi.id_no, id_type: bi.id_type}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.puts "\nBeneficiary details exists. beneficiary_code = #{beneficiary_code}\n"
            {:ok, %{beneficiary_code: result[:beneficiary_code], name: result[:name], entity_code: result[:entity_code], id_no: result[:id_no], id_type: result[:id_type], pan: result[:pan], account_nw: result[:pan_nw], account_type: result[:pan_type], resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
        else
            {:error, Constant.err_missing_beneficiary_accnt()}
        end
    end


    def get_initiator_default_product(pay_initiator_code) do

      query=from(ip in "initiator_products",
          left_join: pi2 in "product_info", on: ip.product_code==pi2.assigned_code,
          left_join: pm in "product_metric", on: pi2.assigned_code==pm.product_code,
          where: ip.initiator_code==^pay_initiator_code and ip.is_default==true and ip.active_status==true and ip.del_status==false and pi2.active_status==true and pi2.del_status==false and pm.active_status==true and pm.del_status==false,
          order_by: [desc: ip.created_at],
          limit: 1,
          select: %{product_code: ip.product_code, product_id: pi2.id, product_name: pi2.product_name, product_alias: pi2.product_alias, metric_unit_code: pm.metric_unit_code, price_per_unit: pm.price_per_unit, weight_per_unit: pm.weight_per_unit, currency: pm.currency, is_default: ip.is_default}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.puts "\nPay initiator default product details exists. pay_initiator_code = #{pay_initiator_code}\n"
            {:ok, %{product_code: result[:product_code], product_id: result[:product_id], product_name: result[:product_name], product_alias: result[:product_alias], metric_unit_code: result[:metric_unit_code], price_per_unit: "#{result[:price_per_unit]}", weight_per_unit: "#{result[:weight_per_unit]}", currency: result[:currency], is_default: result[:is_default], resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
        else
            {:error, Constant.err_missing_initiator_default_product()}
        end
    end



    def get_initiator_product_details(pay_initiator_code, product_code) do

      query=from(ip in "initiator_products",
          left_join: pi2 in "product_info", on: ip.product_code==pi2.assigned_code,
          left_join: pm in "product_metric", on: pi2.assigned_code==pm.product_code,
          where: ip.initiator_code==^pay_initiator_code and ip.product_code==^product_code and ip.is_default==true and ip.active_status==true and ip.del_status==false and pi2.active_status==true and pi2.del_status==false and pm.active_status==true and pm.del_status==false,
          order_by: [desc: ip.created_at],
          limit: 1,
          select: %{product_code: ip.product_code, product_id: pi2.id, product_name: pi2.product_name, product_alias: pi2.product_alias, product_metric_id: pm.id, metric_unit_code: pm.metric_unit_code, price_per_unit: pm.price_per_unit, weight_per_unit: pm.weight_per_unit, currency: pm.currency, is_default: ip.is_default}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.puts "\nPay initiator product details exists. pay_initiator_code = #{pay_initiator_code}, product_name = #{result[:product_name]}\n"
            {:ok, %{product_code: result[:product_code], product_id: result[:product_id], product_name: result[:product_name], product_alias: result[:product_alias], product_metric_id: result[:product_metric_id], metric_unit_code: result[:metric_unit_code], price_per_unit: "#{result[:price_per_unit]}", weight_per_unit: "#{result[:weight_per_unit]}", currency: result[:currency], is_default: result[:is_default], resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
        else
            {:error, Constant.err_missing_initiator_default_product()}
        end
    end


    def get_initiator_info(initiator_code) do

      query=from(pii in "pay_initiator_info",
          left_join: u in "users", on: pii.initiator_id==u.id,
          where: pii.assigned_code==^initiator_code and pii.active_status==true and pii.del_status==false and u.active_status==true and u.del_status==false,
          select: %{mobile_number: pii.mobile_number, name: fragment("concat(?, ' ', ?)", u.first_name, u.last_name)},
          limit: 1,
          order_by: [desc: pii.created_at]
      ) |> acme.Repo.all


      if length(query) == 1 do
          IO.puts "\nStarting callback processing...\n"
          result=hd query
          p=%{pay_initiator_mobile_number: result[:mobile_number], pay_initiator_name: result[:name]}
          {:ok, p}
      else
        {:error, Constant.err_failed_req()}
      end
    end


    # def is_beneficiary_lookup_set?(entity_code) do
    #   query=from(eei in "entity_extra_info",
    #         where: eei.entity_code==^entity_code and eei.active_status==true and eei.del_status==false,
    #         order_by: [desc: eei.created_at],
    #         limit: 1,
    #         select: %{benef_list_lookup: eei.benef_list_lookup}
    #     )|> acme.Repo.all
    #
    #     if length(query)==1 do
    #         result=hd query
    #         {:ok, result[:benef_list_lookup]}
    #     else
    #         {:ok, false}
    #     end
    # end



    def get_beneficiary_list_val?(entity_code) do
      query=from(eei in "entity_extra_info",
            where: eei.entity_code==^entity_code and eei.active_status==true and eei.del_status==false,
            order_by: [desc: eei.created_at],
            limit: 1,
            select: %{benef_list: eei.benef_list}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            {:ok, result[:benef_list]}
        else
            {:error, false}
        end
    end






    ############################################################## VALIDATION/CHECKLIST BEFORE FUNDS ALLOCATION #############################################
    ############################################################## VALIDATION/CHECKLIST BEFORE FUNDS ALLOCATION #############################################

    def validate_checklist_alloc(entity_code, initiator_trans_type) do

      case EctoFunc.entity_service_code_exists?(entity_code) do
          true ->
            case EctoFunc.entity_wallet_exists?(entity_code) do
                true ->
                    case EctoFunc.entity_assigned_fee_exists?(entity_code) do
                        true ->
                            approver_trans_type=get_approver_trans_types(initiator_trans_type)
                            case EctoFunc.approver_list_exists?(entity_code, approver_trans_type) do
                                true ->
                                  case EctoFunc.product_metric_exists?(entity_code) do
                                      true ->
                                        case EctoFunc.pay_initiator_exists?(entity_code) do
                                            true ->
                                              case EctoFunc.entity_initiator_products_exists?(entity_code) do
                                                  true ->
                                                      case EctoFunc.entity_ben_acct_info_exists?(entity_code) do
                                                          true ->
                                                            {:ok, Constant.err_setup_validation_passed()}
                                                          _ ->
                                                            {:error, Constant.err_val_entity_ben_acc_info_setup()}
                                                      end
                                                  _ ->
                                                    {:error, Constant.err_val_entity_intiator_products_setup()}
                                              end
                                            _ ->
                                              {:error, Constant.err_val_pay_intiator_setup()}
                                        end
                                      _ ->
                                        {:error, Constant.err_val_product_metric_setup()}
                                  end
                                _ ->
                                  {:error, Constant.err_val_missing_approver_list_setup()}
                            end
                        _ ->
                          {:error, Constant.err_val_missing_assigned_fee_setup()}
                    end
                _ ->
                  {:error, Constant.err_val_missing_wallet_setup()}
            end
          _ ->
          {:error, Constant.err_val_missing_service_code()}
      end

    end



    def get_approver_trans_types(initiator_trans_type) do
      approver_type=case initiator_trans_type do
        "EFA" ->
          Constant.entity_approver_type()
        "PIF" ->
          Constant.payout_approver_type()
      end
      approver_type
    end



    def get_active_farm_inputs(product_amount, beneficiary_code) do

      query=from(bi in "beneficiary_inputs",
          left_join: fi in "farm_inputs", on: bi.farm_input_id==fi.id,
          left_join: ip in "input_pricings", on: bi.farm_input_id==ip.farm_input_id,
          where: bi.beneficiary_code==^beneficiary_code and bi.repay==true and (fragment("paid_status <> 'C'") or is_nil(bi.paid_status)) and bi.active_status==true and bi.del_status==false and ip.active_status==true and ip.del_status==false,
          order_by: [asc: bi.deduct_amount],
          select: %{id: bi.id, farm_input_id: bi.farm_input_id, input_desc: fi.input_desc, product_price: ip.net_price, metric_unit_code: fi.metric_unit_code, beneficiary_code: bi.beneficiary_code, deduct_amount: bi.deduct_amount, qty: bi.qty, paid_status: bi.paid_status}
        )|> acme.Repo.all

      if length(query)>0 do
          loop_active_farm_inputs(query, [], 0, beneficiary_code, product_amount, 0)
      else
          {:ok, %{deduct_amount: 0}}
      end
    end

    def loop_active_farm_inputs([], arr_acc, counter, beneficiary_code, product_amount, sum_deduct_amount) do
      {:ok, %{deduct_amount: sum_deduct_amount}}
    end

    def loop_active_farm_inputs([hd|tl], arr_acc, counter, beneficiary_code, product_amount, sum_deduct_amount) do
        IO.inspect hd
        counter=counter + 1

        {:ok, beneficiary_input_id}=BaseFunc.convert_to_integer(hd[:id])
        {:ok, deduct_amount}=BaseFunc.convert_to_decimal(hd[:deduct_amount])
        {:ok, product_price}=BaseFunc.convert_to_decimal(hd[:product_price])
        {:ok, qty}=BaseFunc.convert_to_decimal(hd[:qty])
        farm_inputs_amount=Decimal.mult(product_price, qty)
        sum_deduct_amount1=Decimal.add(sum_deduct_amount, deduct_amount)
        {:ok, zero_val}=BaseFunc.convert_to_decimal(0)
        {:ok, _gross_amount}=BaseFunc.convert_to_decimal(product_amount)

        temp_new_amount=Decimal.sub(product_amount, sum_deduct_amount1)

        sum_deduct_amount=if Decimal.cmp(temp_new_amount, zero_val)==:gt do
          IO.puts "sum_deduct_amount is valid: sum_deduct_amount=#{sum_deduct_amount}, sum_deduct_amount1=#{sum_deduct_amount1}"
          sum_deduct_amount1
        else
          sum_deduct_amount
        end

        IO.puts "beneficiary_input_id: #{beneficiary_input_id}, sum_deduct_amount: #{sum_deduct_amount}, deduct_amount: #{deduct_amount}, product_amount: #{product_amount}, sum_deduct_amount1: #{sum_deduct_amount1}, temp_new_amount: #{temp_new_amount}, farm_inputs_amount: #{farm_inputs_amount}"

        loop_active_farm_inputs(tl, arr_acc, counter, beneficiary_code, product_amount, sum_deduct_amount)
    end






    def compute_farm_inputs_deductions(product_amount, beneficiary_code) do
      {:ok, farm_inputs}=get_active_farm_inputs(product_amount, beneficiary_code)
      deduct_amount=farm_inputs.deduct_amount
      {:ok, %{deduct_amount: deduct_amount}}
    end


    def compute_beneficiary_final_amount(product_amount, beneficiary_code) do
      {:ok, farm_inputs}=compute_farm_inputs_deductions(product_amount, beneficiary_code)
      deduct_amount=farm_inputs.deduct_amount

      total_benenficiary_amount = Decimal.sub(product_amount, deduct_amount)
      IO.puts "product_amount = #{product_amount}, total_benenficiary_amount = #{total_benenficiary_amount}"
      str_param = %{total_benenficiary_amount: total_benenficiary_amount, deductions: deduct_amount}
      {:ok, str_param}
    end


    def compute_pay_initator_final_amount(gross_amount, beneficiary_code) do
      {:ok, farm_inputs}=compute_farm_inputs_deductions(gross_amount, beneficiary_code)
      deduct_amount=farm_inputs.deduct_amount

      total_pay_initiator_amount = Decimal.sub(gross_amount, deduct_amount)
      IO.puts "deduct_amount = #{deduct_amount}, gross_amount = #{gross_amount}, total_pay_initiator_amount = #{total_pay_initiator_amount}"
      str_param = %{total_pay_initiator_amount: total_pay_initiator_amount, deductions: deduct_amount}
      {:ok, str_param}
    end


    def process_beneficiary_deductions_temps(processing_id, gross_amount, beneficiary_code) do
      query=from(bi in "beneficiary_inputs",
          left_join: fi in "farm_inputs", on: bi.farm_input_id==fi.id,
          left_join: ip in "input_pricings", on: bi.farm_input_id==ip.farm_input_id,
          where: bi.beneficiary_code==^beneficiary_code and bi.repay==true and (fragment("paid_status <> 'C'") or is_nil(bi.paid_status)) and bi.active_status==true and bi.del_status==false and ip.active_status==true and ip.del_status==false,
          order_by: [asc: bi.deduct_amount],
          select: %{id: bi.id, farm_input_id: bi.farm_input_id, input_desc: fi.input_desc, product_price: ip.net_price, metric_unit_code: fi.metric_unit_code, beneficiary_code: bi.beneficiary_code, deduct_amount: bi.deduct_amount, qty: bi.qty, paid_status: bi.paid_status}
        )|> acme.Repo.all

      if length(query)>0 do
          # result=hd query
          balance_bef=gross_amount
          loop_beneficiary_deductions_list(query, [], 0, processing_id, gross_amount, beneficiary_code, balance_bef, 0, 0)
      else
          {:ok, Constant.err_success_ben_repays_computed()}
      end
    end


    def loop_beneficiary_deductions_list([], arr_acc, counter, processing_id, gross_amount, beneficiary_code, _balance_bef, _balance_aft, _sum_deduct_amount) do
      {:ok, Constant.err_success_ben_repays_computed()}
    end

    def loop_beneficiary_deductions_list([hd|tl], arr_acc, counter, processing_id, gross_amount, beneficiary_code, balance_bef, _balance_aft, sum_deduct_amount) do

        counter=counter + 1

        {:ok, beneficiary_input_id}=BaseFunc.convert_to_integer(hd[:id])
        {:ok, deduct_amount}=BaseFunc.convert_to_decimal(hd[:deduct_amount])
        {:ok, product_price}=BaseFunc.convert_to_decimal(hd[:product_price])
        {:ok, qty}=BaseFunc.convert_to_decimal(hd[:qty])
        farm_inputs_amount=Decimal.mult(product_price, qty)
        {:ok, balance_bef}=BaseFunc.convert_to_decimal(balance_bef)
        balance_aft = Decimal.sub(balance_bef, deduct_amount)
        {:ok, gross_amount}=BaseFunc.convert_to_decimal(gross_amount)

        {:ok, total_amt_deducted}=compute_repaid_amounts(beneficiary_input_id)

        sum_deduct_amount1=Decimal.add(sum_deduct_amount, deduct_amount)
        temp_new_amount=Decimal.sub(gross_amount, sum_deduct_amount1)

        IO.puts "counter: #{counter}. => => beneficiary_input_id: #{beneficiary_input_id}, deduct_amount: #{deduct_amount}, farm_inputs_amount: #{farm_inputs_amount}, total_amt_deducted: #{total_amt_deducted}, temp_new_amount: #{temp_new_amount}, sum_deduct_amount1: #{sum_deduct_amount1}, sum_deduct_amount: #{sum_deduct_amount}, balance_bef: #{balance_bef}, balance_aft: #{balance_aft}"
        new_balance_bef=balance_aft

        if Decimal.cmp(balance_aft, 0)==:gt do
          if Decimal.cmp(temp_new_amount, 0)==:gt do
            sum_deduct_amount=sum_deduct_amount1

            if Decimal.cmp(total_amt_deducted, farm_inputs_amount)==:lt do
              inputs_bal_bef=Decimal.sub(farm_inputs_amount, total_amt_deducted)
              # new_deducted_total=Decimal.add(total_amt_deducted, deduct_amount)
              inputs_bal_aft=Decimal.sub(inputs_bal_bef, deduct_amount)
              EctoFunc.save_beneficiary_input_repays_temp(processing_id, beneficiary_input_id, gross_amount, deduct_amount, inputs_bal_bef, inputs_bal_aft)
              # EctoFunc.mark_beneficiary_input(beneficiary_input_id, "I")
            else
              IO.puts "total_amt_deducted(#{total_amt_deducted}) is equal to or greater than farm_inputs_amount(#{farm_inputs_amount})"
            end
          end

        end

        loop_beneficiary_deductions_list(tl, arr_acc, counter, processing_id, gross_amount, beneficiary_code, new_balance_bef, balance_aft, sum_deduct_amount)
    end



    def get_repaid_amounts(beneficiary_input_id) do
      query=from(bir in "beneficiary_input_repays",
          where: bir.beneficiary_input_id==^beneficiary_input_id,
          select: %{amt_deducted: fragment("sum(amt_deducted)")}
        )|> acme.Repo.all

      if length(query)>0 do
          result=hd query
          amt_deducted=if !is_nil(result[:amt_deducted]) do
            result[:amt_deducted]
          else
            0
          end
          {:ok, %{amt_deducted: amt_deducted}}
      else
          {:ok, %{amt_deducted: 0}}
      end
    end


    def compute_repaid_amounts(beneficiary_input_id) do
      {:ok, results}=get_repaid_amounts(beneficiary_input_id)
      {:ok, amt_deducted}=BaseFunc.convert_to_decimal(results.amt_deducted)
      {:ok, amt_deducted}
    end


    # acme.Operations.extract_beneficiary_deductions("2930308156177")
    def extract_beneficiary_deductions(processing_id) do
      query=from(u in "beneficiary_input_repay_temps",
          where: u.processing_id==^processing_id and u.used_status==false,
          select: %{id: u.id, beneficiary_input_id: u.beneficiary_input_id, actual_disburse_amt: u.actual_disburse_amt, amt_deducted: u.amt_deducted, bal_before: u.bal_before, bal_after: u.bal_after, used_status: u.used_status, created_at: u.created_at},
          order_by: [asc: u.created_at]
      )|> acme.Repo.all

      if length(query)>0 do
          loop_beneficiary_deductions_extraction_list(query, [], 0, processing_id)
      else
          {:ok, Constant.err_success_ben_repays_computed()}
      end
    end

    def loop_beneficiary_deductions_extraction_list([], arr_acc, counter, processing_id) do
      {:ok, Constant.err_success_ben_repays_computed()}
    end

    def loop_beneficiary_deductions_extraction_list([hd|tl], arr_acc, counter, processing_id) do
        IO.inspect hd
        counter=counter + 1

        temp_id=hd[:id]
        {:ok, beneficiary_input_id}=BaseFunc.convert_to_integer(hd[:beneficiary_input_id])

        {:ok, response}=EctoFunc.save_beneficiary_input_repays(temp_id, processing_id, beneficiary_input_id, hd[:actual_disburse_amt], hd[:amt_deducted], hd[:bal_before], hd[:bal_after])
        EctoFunc.mark_beneficiary_input_repays_temp(temp_id, true)


        query=from(bi in "beneficiary_inputs",
            left_join: fi in "farm_inputs", on: bi.farm_input_id==fi.id,
            left_join: ip in "input_pricings", on: bi.farm_input_id==ip.farm_input_id,
            where: bi.id==^beneficiary_input_id and bi.repay==true and (fragment("paid_status <> 'C'") or is_nil(bi.paid_status)) and bi.active_status==true and bi.del_status==false and ip.active_status==true and ip.del_status==false,
            order_by: [asc: bi.created_at],
            select: %{id: bi.id, farm_input_id: bi.farm_input_id, input_desc: fi.input_desc, product_price: ip.net_price, metric_unit_code: fi.metric_unit_code, beneficiary_code: bi.beneficiary_code, deduct_amount: bi.deduct_amount, qty: bi.qty, paid_status: bi.paid_status}
          )|> acme.Repo.all

        if length(query)>0 do
            result=hd query

            {:ok, deduct_amount}=BaseFunc.convert_to_decimal(result[:deduct_amount])
            {:ok, product_price}=BaseFunc.convert_to_decimal(result[:product_price])
            {:ok, deduct_amount}=BaseFunc.convert_to_decimal(result[:deduct_amount])
            {:ok, qty}=BaseFunc.convert_to_decimal(result[:qty])
            farm_inputs_amount=Decimal.mult(product_price, qty)

            {:ok, total_amt_deducted}=compute_repaid_amounts(beneficiary_input_id)

            if Decimal.cmp(total_amt_deducted, farm_inputs_amount)==:eq do
              EctoFunc.mark_beneficiary_input(beneficiary_input_id, "C")
            else
              EctoFunc.mark_beneficiary_input(beneficiary_input_id, "I")
            end

        else
            {:ok, Constant.err_success_ben_repays_computed()}
        end


        loop_beneficiary_deductions_extraction_list(tl, arr_acc, counter, processing_id)
    end


    # acme.Operations.send_merchant_alert("00000020", "PIF", "GoldnTree", "Hi rm test, you have a transaction pending you. Tranx: 9935208139187", "9705208168240", 1, "Na+oh2ElZk3fDy3kKQItvXm0L+9vZ5j2cPfTX2/bLpFnDZOOxhINR4ouc0kBinwZSeX/68eHkPvwByMhNx7raw==", "JYAX4rhY3FI3LtzFwKGoVdnAMOkH3a51hAu3TdHv0cYiCTD4AjqqecZTzdgFjRcuDlGSEnhZQ2HC5BobsHLERQ==")
    def send_merchant_alert(entity_code, trans_type, sender_id, msg_body, trans_ref_code, service_id, secret_key, client_key) do
        ############# Merchants who want to receive notification ################
        query=from(p in "alert_recipient",
            where: p.entity_code==^entity_code and p.trans_type==^trans_type
                and p.active_status==true and p.del_status==false
                and p.alerts==true,
            select: %{mobile_number: p.mobile_number}
        )|> acme.Repo.all

        if length(query)>0 do
            loop_merchant_alert_recipients(query, 1, entity_code, sender_id, msg_body, trans_ref_code, service_id, secret_key, client_key)
        end
        #########################################################################
    end

    def loop_merchant_alert_recipients([], _counter, _entity_code, _sender_id, _msg_body, _trans_ref_code, _service_id, _secret_key, _client_key), do: "\n=== Merchant alert recipients list empty ===\n"
    def loop_merchant_alert_recipients([hd|tl], counter, entity_code, sender_id, msg_body, trans_ref_code, service_id, secret_key, client_key) do
        IO.inspect hd
        mobile_number=hd[:mobile_number]

        sms_ref_id="#{trans_ref_code}-#{counter}"

        {:ok, req_response}=BaseFunc.send_sms(entity_code, mobile_number, msg_body, service_id, secret_key, client_key, sender_id, sms_ref_id, "M")

        counter = counter + 1
        loop_merchant_alert_recipients(tl, counter, entity_code, sender_id, msg_body, trans_ref_code, service_id, secret_key, client_key)
    end



    def get_service_keys(service_id) do
      if !is_nil(service_id) do
          query=from(ewc in "entity_wallet_config",
              where: ewc.service_id==^service_id and ewc.active_status==true and ewc.del_status==false,
              order_by: [desc: ewc.created_at],
              limit: 1,
              select: %{service_id: ewc.service_id, client_key: ewc.client_key, secret_key: ewc.secret_key, entity_code: ewc.entity_code, sms_sender_id: ewc.sms_sender_id}
          )|> acme.Repo.all

          if length(query)==1 do
              result=hd query
              IO.puts "\nWallet exists. service_id = #{service_id}\n"
              {:ok, result}

          else
              {:error, reason: "Wallet does not exist"}
          end

      else
          IO.puts "\nentity_code does not exist.\n"
          {:error, reason: "Wallet does not exist"}
      end
    end


    def process_transaction_status_check do
      query=from(pr in "payment_request",
          left_join: pi in "payment_info", on: pr.payment_info_id==pi.id,
          where: (is_nil(pi.processed)),
          # and fragment("created_at < NOW() - interval '24 hours'"),
          select: %{id: pi.id, processing_id: pr.processing_id, service_id: pr.service_id, payment_req_id: pr.id},
          order_by: [asc: pi.created_at]
      )|> acme.Repo.all

      if length(query)>0 do
          loop_transaction_status_list(query, [])
      else
          {:ok, Constant.err_success_ben_repays_computed()}
      end
    end


    def loop_transaction_status_list([], arr_acc) do
      {:ok, Constant.err_return_success()}
    end

    def loop_transaction_status_list([hd|tl], arr_acc) do

        processing_id=hd[:processing_id]
        payment_req_id=hd[:payment_req_id]
        payment_info_id=hd[:id]

        case get_service_keys(hd[:service_id]) do
            {:ok, wallet_resp} ->

              str_params=%{processing_id: processing_id, service_id: wallet_resp.service_id, client_key: wallet_resp.client_key, secret_key: wallet_resp.secret_key}

              case Transaction.trans_status_req(str_params) do
                {:ok, status_check} ->
                  IO.inspect status_check

                  trans_status=status_check["trans_status"]
                  trans_ref=status_check["trans_ref"]
                  trans_id=status_check["trans_id"]
                  trans_msg=status_check["message"]

                  if status_check["resp_code"] && status_check["resp_code"] == "067" do
                    EctoFunc.mark_payment_request(payment_req_id, false)
                    EctoFunc.mark_payment_info(payment_info_id, false)
                  end

                  if trans_status do

                    sub_trans_status=String.slice(trans_status, 0,3)

                    if Enum.member?(["000", "001"], sub_trans_status) do
                        Transaction.payment_callback(trans_status, trans_id, trans_ref, trans_msg)
                    end

                  end

                {:error, err_status_check} ->
                    {:error, err_status_check}
              end

            {:error, err_response} ->
                {:error, err_response}
        end

        loop_transaction_status_list(tl, arr_acc)
    end





    def retrieve_beneficiary_payout_share(beneficiary_code) do

      query=from(bps in "benef_payout_shares",
            left_join: bi in "beneficiary_info", on: bps.beneficiary_code==bi.assigned_code,
            where: bps.beneficiary_code==^beneficiary_code and bps.active_status==true and bps.del_status==false and bi.active_status==true and bi.del_status==false,
            order_by: [desc: bps.created_at],
            limit: 1,
            select: %{value_type: bps.value_type, value: bps.value}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.puts "\benef_payout_share details exists. beneficiary_code = #{beneficiary_code}\n"
            {:ok, %{value_type: result[:value_type], value: result[:value], resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
        else
            {:ok, %{value_type: nil, value: nil, resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
        end
    end



    def compute_benef_payout_share(beneficiary_code, product_amount, computed_charge, total_amount) do
      case retrieve_beneficiary_payout_share(beneficiary_code) do
        {:ok, payout_share} ->

            {:ok, farm_inputs}=get_active_farm_inputs(product_amount, beneficiary_code)
            farm_input_deductions=farm_inputs.deduct_amount

            IO.puts "farm_input_deductions = #{farm_input_deductions}, product_amount: #{product_amount}"

            share_results=if is_nil(payout_share.value) do
              beneficiary_amount=Decimal.sub(product_amount, farm_input_deductions)
              pay_initiator_amount=Decimal.add(beneficiary_amount, computed_charge)

              %{share_amount: beneficiary_amount, benef_balance: 0, pay_initiator_amount: pay_initiator_amount, deductions: farm_input_deductions}
            else

              {:ok, split_value}=BaseFunc.convert_to_decimal(payout_share.value)

              share_results=case payout_share.value_type do
                "F" ->

                  if Decimal.cmp(product_amount, split_value)==:gt do
                    benef_balance1=Decimal.sub(product_amount, split_value)
                    beneficiary_balance = Decimal.sub(benef_balance1, farm_input_deductions)
                    pay_initiator_amount=Decimal.add(split_value, computed_charge)
                    %{share_amount: split_value, benef_balance: beneficiary_balance, pay_initiator_amount: pay_initiator_amount, deductions: farm_input_deductions}
                  else
                      beneficiary_amount=Decimal.sub(product_amount, farm_input_deductions)
                      pay_initiator_amount=Decimal.sub(Decimal.add(beneficiary_amount, computed_charge), farm_input_deductions)
                      %{share_amount: beneficiary_amount, benef_balance: 0, pay_initiator_amount: pay_initiator_amount, deductions: farm_input_deductions}
                  end

                "P" ->
                  percent=Decimal.div(split_value, 100)
                  split_amount=Decimal.mult(percent, product_amount)
                  split_amount=cond do
                      Decimal.is_decimal(split_amount)->
                          Decimal.to_float(split_amount)
                      true->
                          split_amount
                  end

                  IO.puts "\nsplit_amount is: #{split_amount}, Decimal.from_float(split_amount): #{Decimal.from_float(split_amount)}\n"
                  split_amount=Decimal.round(Decimal.from_float(split_amount), 2)

                  beneficiary_balance = Decimal.sub(Decimal.sub(product_amount, split_amount), farm_input_deductions)
                  pay_initiator_amount=Decimal.add(split_amount, computed_charge)

                  IO.puts "In compute_benef_payout_share: beneficiary_code: #{beneficiary_code}, product_amount: #{product_amount}, split_value: #{split_value} (Percentage),
                  split_value: #{split_value}, percent: #{percent}, split_amount: #{split_amount}, beneficiary_balance: #{beneficiary_balance}, pay_initiator_amount: #{pay_initiator_amount}"

                  %{share_amount: split_amount, benef_balance: beneficiary_balance, pay_initiator_amount: pay_initiator_amount, deductions: farm_input_deductions}
              end

            end

            IO.inspect share_results
            {:ok, share_results}

        {:error, err_payout_share} ->
          {:error, err_payout_share}
      end
    end








    ############################################################## VALIDATION/CHECKLIST BEFORE FUNDS ALLOCATION #############################################
    ############################################################## VALIDATION/CHECKLIST BEFORE FUNDS ALLOCATION #############################################



    def get_purchase_season(entity_code) do

      query=from(ps in "purchase_season",
          where: ps.entity_code==^entity_code and ps.active_status==true and ps.del_status==false,
          order_by: [desc: ps.created_at],
          limit: 1,
          select: %{id: ps.id, season_desc: ps.season_desc, season_alias: ps.season_alias}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            {:ok, %{purchase_season_id: result[:id], season_desc: result[:season_desc], season_alias: result[:season_alias], resp_code: Constant.err_return_success.resp_code, resp_desc: Constant.err_return_success.resp_desc}}
        else
            {:error, Constant.err_no_record_found()}
        end
    end

end
