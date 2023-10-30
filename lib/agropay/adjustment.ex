defmodule acme.Adjustment do
    import Ecto.Query

    alias acme.Constant
    alias acme.EctoFunc
    alias acme.BaseFunc
    require Decimal


    def adjust_entity_wallet(entity_code, amount, processing_id, trans_type) do
        wallet=acme.Repo.get_by(acme.Schema.EntityServiceAccount, entity_code: entity_code, active_status: true, del_status: false)

        # IO.inspect wallet
        case trans_type do
          "EFA" -> #EFA - Entity Fund Allocation

            utc_now=DateTime.truncate(DateTime.utc_now, :second)
            cust_charge=Decimal.from_float(0.00)#payment_info.charge

            cust_charge=cond do
                Decimal.is_decimal(cust_charge)-> cust_charge
                true-> Decimal.from_float(cust_charge)
            end

            zero_val=Decimal.from_float(0.00)

            actual_amount=Decimal.sub(amount, cust_charge)
            tot_charge=Decimal.from_float(0.00)#Decimal.add(cust_charge, merch_charge)
            gross_amount=amount#Decimal.add(actual_amount, tot_charge)
            net_amount=Decimal.sub(amount, tot_charge)

            if !is_nil(wallet) do
                IO.puts "\nEntity's Wallet exists\n"

                case from(u in "entity_service_acc",
                    where: u.entity_code==^entity_code
                        and u.active_status==true
                        and u.del_status==false,
                    select: %{new_gross: u.gross_bal, new_net: u.net_bal}
                )|> acme.Repo.update_all([inc: [gross_bal: gross_amount, net_bal: net_amount], set: [updated_at: utc_now]])
                do
                    {1, result} ->
                        map_=hd result
                        gross_bal_aft=map_[:new_gross]
                        gross_bal_bef=Decimal.sub(gross_bal_aft, gross_amount)

                        net_bal_aft=map_[:new_net]
                        net_bal_bef=Decimal.sub(net_bal_aft, net_amount)

                        EctoFunc.save_entity_service_account_trxn(nil,entity_code, nil, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, amount, tot_charge, trans_type)
                        IO.puts "\nEntity Code #{entity_code} account updated successfully\n"
                        {:ok, Constant.err_success_req()}
                    {:error, _} ->
                        IO.puts "\nEntity account update failed"
                        {:error, Constant.err_failed_req()}
                end
            else
                IO.puts "\nNo wallet available for Entity\n"
                new_gross_bal=Decimal.add(zero_val, gross_amount)
                new_net_bal=Decimal.add(zero_val, net_amount)

                case EctoFunc.create_entity_service_account(entity_code, new_gross_bal, new_net_bal) do
                    {:ok, _} ->
                        IO.puts "\nEntity code #{entity_code} account created and updated successfully\n"
                        EctoFunc.save_entity_service_account_trxn(nil, entity_code, nil, processing_id, zero_val, new_gross_bal, zero_val, new_net_bal, gross_amount, tot_charge, trans_type)
                        {:ok, Constant.err_success_req()}
                    {:error, _} ->
                        IO.puts "Failure"
                        {:error, Constant.err_failed_req()}
                end
            end


          "EFD" ->
            #   EFD - Entity Fund Debit

              utc_now=DateTime.truncate(DateTime.utc_now, :second)
              debit_amount = amount
              if !is_nil(wallet) do

                  wallet_account_bal = wallet.net_bal
                  balance_compare=Decimal.cmp(wallet_account_bal, debit_amount)
                  tot_charge=Decimal.from_float(0.00)

                  case balance_compare do
                    :lt ->

                      err_msg="Insufficient balance for Entity Code: #{entity_code}"
                      IO.puts err_msg
                      EctoFunc.log_err_resp(entity_code, processing_id, err_msg, trans_type)
                      {:error, Constant.err_insufficient_bal()}

                    _ -> #greater than or equal to

                      IO.puts "deduct Entity's wallet. Entity Code: #{entity_code}"

                      case from(u in "entity_service_acc",
                          where: u.entity_code==^entity_code
                              and u.active_status==true
                              and u.del_status==false,
                          select: %{new_gross: u.gross_bal, new_net: u.net_bal}
                      )|> acme.Repo.update_all([inc: [gross_bal: -Decimal.to_float(debit_amount), net_bal: -Decimal.to_float(debit_amount)], set: [updated_at: utc_now]])
                      do
                          {1, result} ->
                              map_=hd result
                              gross_bal_aft=map_[:new_gross]
                              gross_bal_bef=Decimal.add(gross_bal_aft, debit_amount)

                              net_bal_aft=map_[:new_net]
                              net_bal_bef=Decimal.add(net_bal_aft, debit_amount)

                              EctoFunc.save_entity_service_account_trxn(nil,entity_code, nil, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, debit_amount, tot_charge, trans_type)
                              IO.puts "\nEntity Code #{entity_code} account updated successfully. Entity balances: gross_bal_bef: #{gross_bal_bef}, gross_bal_aft: #{gross_bal_aft}, net_bal_bef: #{net_bal_bef}, net_bal_aft: #{net_bal_aft}\n"
                              {:ok, Constant.err_success_req()}
                          {:error, _} ->
                              IO.puts "\nEntity account update failed"
                              {:error, Constant.err_failed_req()}
                      end
                  end
              else
                  {:error, Constant.err_missing_service_account()}
              end
        end
    end



    def decrease_entity_wallet(entity_code, amount, processing_id, trans_type) do
      wallet=acme.Repo.get_by(acme.Schema.EntityServiceAccount, entity_code: entity_code, active_status: true, del_status: false)
      IO.inspect wallet

      utc_now=DateTime.truncate(DateTime.utc_now, :second)
      {:ok, gross_amount}=BaseFunc.convert_to_decimal(amount)
      net_amount=gross_amount

      if !is_nil(wallet) do
          IO.puts "\nEntity's Wallet exists\n"

          case from(u in "entity_service_acc",
              where: u.entity_code==^entity_code and u.active_status==true and u.del_status==false,
              select: %{new_gross: u.gross_bal, new_net: u.net_bal}
          )|> acme.Repo.update_all([inc: [gross_bal: -Decimal.to_float(gross_amount), net_bal: -Decimal.to_float(gross_amount)], set: [updated_at: utc_now]])
          do
              {1, result} ->
                map_=hd result
                map_=hd result
                gross_bal_aft=map_[:new_gross]
                gross_bal_bef=Decimal.sub(gross_bal_aft, gross_amount)

                net_bal_aft=map_[:new_net]
                net_bal_bef=Decimal.sub(net_bal_aft, net_amount)

                # EctoFunc.save_entity_service_account_trxn(nil,entity_code, nil, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, amount, tot_charge, trans_type)
                # IO.puts "\nEntity Code #{entity_code} account updated successfully\n"
                {:ok, Constant.err_success_req()}
              {:error, _} ->
                  IO.puts "\nEntity Code account update failed"
                  {:error, Constant.err_failed_req()}
          end
      else
          IO.puts "\nNo wallet available for Entity Code\n"
          {:error, Constant.err_failed_req()}
      end
    end



    def adjust_pay_initiator_and_entity_wallet(entity_code, initiator_code, amount, processing_id, trans_type) do
        wallet=acme.Repo.get_by(acme.Schema.InitiatorServiceAcc, initiator_code: initiator_code, active_status: true, del_status: false)

        # IO.inspect wallet
        case trans_type do
          "PIF" -> #Payout Initiator Funding

            utc_now=DateTime.truncate(DateTime.utc_now, :second)
            cust_charge=Decimal.from_float(0.00)#payment_info.charge

            cust_charge=cond do
                Decimal.is_decimal(cust_charge)-> cust_charge
                true-> Decimal.from_float(cust_charge)
            end

            zero_val=Decimal.from_float(0.00)

            actual_amount=Decimal.sub(amount, cust_charge)
            tot_charge=Decimal.from_float(0.00)#Decimal.add(cust_charge, merch_charge)
            gross_amount=amount#Decimal.add(actual_amount, tot_charge)
            net_amount=Decimal.sub(amount, tot_charge)

            # EFD - Entity Fund Debit
            case adjust_entity_wallet(entity_code, amount, processing_id, Constant.entity_fund_debit_type()) do
                {:ok, _resp} ->

                    if !is_nil(wallet) do
                        IO.puts "\nEntity's Wallet exists\n"

                        case from(u in "initiator_service_acc",
                            where: u.initiator_code==^initiator_code
                                and u.active_status==true
                                and u.del_status==false,
                            select: %{new_gross: u.gross_bal, new_net: u.net_bal}
                        )|> acme.Repo.update_all([inc: [gross_bal: gross_amount, net_bal: net_amount], set: [updated_at: utc_now]])
                        do
                            {1, result} ->
                                map_=hd result
                                gross_bal_aft=map_[:new_gross]
                                gross_bal_bef=Decimal.sub(gross_bal_aft, gross_amount)

                                net_bal_aft=map_[:new_net]
                                net_bal_bef=Decimal.sub(net_bal_aft, net_amount)

                                EctoFunc.save_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, amount, tot_charge, trans_type)
                                IO.puts "\ninitiator_code #{initiator_code} account updated successfully\n"
                                {:ok, Constant.err_success_req()}
                            {:error, _} ->
                                IO.puts "\nPay Initator account update failed"
                                {:error, Constant.err_failed_req()}
                        end
                    else
                        IO.puts "\nNo wallet available for Pay Initator\n"
                        new_gross_bal=Decimal.add(zero_val, gross_amount)
                        new_net_bal=Decimal.add(zero_val, net_amount)

                        case EctoFunc.create_pay_initiator_service_account(initiator_code, new_gross_bal, new_net_bal) do
                            {:ok, _} ->
                                IO.puts "\nPay Initator code #{initiator_code} account created and updated successfully\n"
                                EctoFunc.save_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, zero_val, new_gross_bal, zero_val, new_net_bal, gross_amount, tot_charge, trans_type)

                                {:ok, Constant.err_success_req()}
                            {:error, _} ->
                                IO.puts "Failure"

                                {:error, Constant.err_failed_req()}
                        end
                    end

                {:error, reason} ->
                    {:error, reason}
            end




        #   "EFD" ->
              #EFD - Entity Fund Debit

            #   utc_now=DateTime.truncate(DateTime.utc_now, :second)
            #   debit_amount = amount
            #   if !is_nil(wallet) do

            #       wallet_account_bal = wallet.account_bal
            #       balance_compare=Decimal.cmp(wallet_account_bal, debit_amount)

            #       case balance_compare do
            #         :lt ->

            #           err_msg="Insufficient balance for Operator ID: #{operator_user_id}"
            #           IO.puts err_msg
            #           EctoFunc.log_err_resp(institution_code, processing_id, err_msg, trans_type)
            #           {:error, Constant.err_insufficient_bal()}

            #         _ -> #greater than or equal to

            #           IO.puts "deduct Operator's wallet. Operator ID: #{operator_user_id}"

            #           case from(u in "operator_service_account",
            #               where: u.operator_user_id==^operator_user_id
            #                   and u.active_status==true
            #                   and u.del_status==false,
            #               select: %{new_gross: u.account_bal}
            #           )|> acme.Repo.update_all([inc: [account_bal: -Decimal.to_float(debit_amount)], set: [updated_at: utc_now]])
            #           do
            #               {1, result} ->
            #                   map_=hd result
            #                   new_gross_bal=map_[:new_gross]
            #                   balance_bef=Decimal.add(new_gross_bal, debit_amount)

            #                   EctoFunc.save_customer_service_account_trxn(processing_id, balance_bef, new_gross_bal, debit_amount, trans_type)
            #                   IO.puts "\nOperator ID #{operator_user_id} account updated successfully\n"
            #                   {:ok, Constant.err_success_req()}
            #               {:error, _} ->
            #                   IO.puts "\nOperator account update failed"
            #                   {:error, Constant.err_failed_req()}
            #           end

            #       end

            #   else
            #       {:error, Constant.err_missing_service_account()}
            #   end


        end


    end


    # def decrease_initiator_wallet(entity_code, initiator_code, processing_id, amount, charge, trans_type) do
    #   #trans_type=>MTC
    #
    #   wallet=acme.Repo.get_by(acme.Schema.InitiatorServiceAcc, initiator_code: initiator_code, active_status: true, del_status: false)
    #   IO.inspect wallet
    #
    #   utc_now=DateTime.truncate(DateTime.utc_now, :second)
    #   {:ok, tot_charge}=BaseFunc.convert_to_decimal(charge)#Decimal.add(cust_charge, merch_charge)
    #   {:ok, amount}=BaseFunc.convert_to_decimal(amount)
    #   debit_amount=amount#Decimal.add(amount, tot_charge) #net amount + charge
    #
    #   if !is_nil(wallet) do
    #       IO.puts "\nPay Initiator's Wallet exists\n"
    #
    #       case from(u in "initiator_service_acc",
    #           where: u.initiator_code==^initiator_code and u.active_status==true and u.del_status==false,
    #           select: %{new_gross: u.gross_bal, new_net: u.net_bal}
    #       )|> acme.Repo.update_all([inc: [gross_bal: -Decimal.to_float(debit_amount), net_bal: -Decimal.to_float(debit_amount)], set: [updated_at: utc_now]])
    #       do
    #           {1, result} ->
    #             map_=hd result
    #             gross_bal_aft=map_[:new_gross]
    #             gross_bal_bef=Decimal.add(gross_bal_aft, debit_amount)
    #
    #             net_bal_aft=map_[:new_net]
    #             net_bal_bef=Decimal.add(net_bal_aft, debit_amount)
    #             net_amount=Decimal.sub(net_bal_bef, net_bal_aft)
    #
    #             EctoFunc.save_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, debit_amount, tot_charge, trans_type)
    #
    #             resp=%{gross_bal_bef: gross_bal_bef, gross_bal_aft: gross_bal_aft, net_bal_bef: net_bal_bef, net_bal_aft: net_bal_aft, net_amount: net_amount, debit_amount: debit_amount}
    #             IO.inspect resp
    #
    #             IO.puts "\nPay Initiator #{initiator_code} account updated successfully. Net Balance Reduced from #{net_bal_bef} to #{net_bal_aft}\n"
    #             {:ok, resp}
    #
    #           {:error, _} ->
    #               IO.puts "\nPay Initator account update failed"
    #               {:error, Constant.err_failed_req()}
    #       end
    #   else
    #       IO.puts "\nNo wallet available for Pay Initator\n"
    #       # new_gross_bal=Decimal.add(zero_val, gross_amount)
    #       # new_net_bal=Decimal.add(zero_val, net_amount)
    #       #
    #       # case EctoFunc.create_pay_initiator_service_account(initiator_code, new_gross_bal, new_net_bal) do
    #       #     {:ok, _} ->
    #       #         IO.puts "\nPay Initator code #{initiator_code} account created and updated successfully\n"
    #       #         EctoFunc.save_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, zero_val, new_gross_bal, zero_val, new_net_bal, gross_amount, tot_charge, trans_type)
    #       #
    #       #         {:ok, Constant.err_success_req()}
    #       #     {:error, _} ->
    #       #         IO.puts "Failure"
    #       #
    #               {:error, Constant.err_failed_req()}
    #       # end
    #   end
    #
    # end


    def decrease_initiator_wallet_temp(entity_code, initiator_code, processing_id, amount, charge, trans_type, benef_balance) do
      wallet=acme.Repo.get_by(acme.Schema.InitiatorServiceAcc, initiator_code: initiator_code, active_status: true, del_status: false)
      IO.inspect wallet

      utc_now=DateTime.truncate(DateTime.utc_now, :second)
      {:ok, tot_charge}=BaseFunc.convert_to_decimal(charge)#Decimal.add(cust_charge, merch_charge)
      {:ok, amount}=BaseFunc.convert_to_decimal(amount)
      gross_debit_amount=Decimal.sub(amount, tot_charge)#Decimal.add(amount, tot_charge) #net amount + charge
      net_debit_amount=amount
      IO.puts "decrease_initiator_wallet_temp => gross_debit_amount: #{gross_debit_amount}, net_debit_amount: #{net_debit_amount}, tot_charge: #{tot_charge}, amount: #{amount}"

      if !is_nil(wallet) do
          IO.puts "\nPay Initiator's Wallet exists\n"

          case from(u in "initiator_service_acc",
              where: u.initiator_code==^initiator_code and u.active_status==true and u.del_status==false,
              select: %{new_gross: u.gross_bal, new_net: u.net_bal}
          )|> acme.Repo.update_all([inc: [gross_bal: -Decimal.to_float(gross_debit_amount), net_bal: -Decimal.to_float(net_debit_amount)], set: [updated_at: utc_now]])
          do
              {1, result} ->
                map_=hd result
                gross_bal_aft=map_[:new_gross]
                gross_bal_bef=Decimal.add(gross_bal_aft, gross_debit_amount)

                net_bal_aft=map_[:new_net]
                net_bal_bef=Decimal.add(net_bal_aft, net_debit_amount)
                net_amount=Decimal.sub(net_bal_bef, net_bal_aft)

                EctoFunc.save_temp_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, net_debit_amount, tot_charge, trans_type, benef_balance)

                resp=%{gross_bal_bef: gross_bal_bef, gross_bal_aft: gross_bal_aft, net_bal_bef: net_bal_bef, net_bal_aft: net_bal_aft, net_amount: net_amount, debit_amount: net_debit_amount}
                IO.inspect resp

                IO.puts "\nPay Initiator #{initiator_code} account updated successfully. Net Balance Reduced from #{net_bal_bef} to #{net_bal_aft}\n"
                {:ok, resp}

              {:error, _} ->
                  IO.puts "\nPay Initator account update failed"
                  {:error, Constant.err_failed_req()}
          end
      else
          IO.puts "\nNo wallet available for Pay Initator\n"
          {:error, Constant.err_failed_req()}
      end
    end


    def reverse_decrease_initiator_wallet_temp(entity_code, initiator_code, processing_id, amount, charge, trans_type) do
      wallet=acme.Repo.get_by(acme.Schema.InitiatorServiceAcc, initiator_code: initiator_code, active_status: true, del_status: false)
      IO.inspect wallet

      utc_now=DateTime.truncate(DateTime.utc_now, :second)
      {:ok, tot_charge}=BaseFunc.convert_to_decimal(charge)#Decimal.add(cust_charge, merch_charge)
      {:ok, amount}=BaseFunc.convert_to_decimal(amount)
      debit_amount=amount#Decimal.add(amount, tot_charge) #net amount + charge

      if !is_nil(wallet) do
          IO.puts "\nPay Initiator's Wallet exists\n"

          case from(u in "initiator_service_acc",
              where: u.initiator_code==^initiator_code and u.active_status==true and u.del_status==false,
              select: %{new_gross: u.gross_bal, new_net: u.net_bal}
          )|> acme.Repo.update_all([inc: [gross_bal: Decimal.to_float(debit_amount), net_bal: Decimal.to_float(debit_amount)], set: [updated_at: utc_now]])
          do
              {1, result} ->
                map_=hd result
                gross_bal_aft=map_[:new_gross]
                gross_bal_bef=Decimal.add(gross_bal_aft, debit_amount)

                net_bal_aft=map_[:new_net]
                net_bal_bef=Decimal.add(net_bal_aft, debit_amount)
                net_amount=Decimal.sub(net_bal_bef, net_bal_aft)

                EctoFunc.reverse_temp_payinitiator_service_account_trxn(processing_id)

                resp=%{gross_bal_bef: gross_bal_bef, gross_bal_aft: gross_bal_aft, net_bal_bef: net_bal_bef, net_bal_aft: net_bal_aft, net_amount: net_amount, debit_amount: debit_amount}
                IO.inspect resp
                IO.puts "\nPay Initiator #{initiator_code} account reversed successfully. processing_id: #{processing_id}\n"
                {:ok, resp}

              {:error, _} ->
                  IO.puts "\nPay Initator account update failed"
                  {:error, Constant.err_failed_req()}
          end
      else
          IO.puts "\nNo wallet available for Pay Initator\n"
          {:error, Constant.err_failed_req()}
      end
    end


    def decrease_initiator_wallet(processing_id) do
      query=from(saat in "service_acc_activity_temps",
            where: saat.processing_id==^processing_id and is_nil(saat.status),
            order_by: [desc: saat.created_at],
            limit: 1,
            select: %{temp_id: saat.id, entity_code: saat.entity_code, pay_initiator_code: saat.pay_initiator_code, processing_id: saat.processing_id,
             gross_bal_bef: saat.gross_bal_bef, gross_bal_aft: saat.gross_bal_aft, net_bal_bef: saat.net_bal_bef, net_bal_aft: saat.net_bal_aft,
             amount: saat.amount, charge: saat.charge, trans_type: saat.trans_type, benef_balance: saat.benef_balance}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            IO.inspect result
            temp_id = result[:temp_id]
            entity_code = result[:entity_code]
            pay_initiator_code = result[:pay_initiator_code]
            gross_bal_bef = result[:gross_bal_bef]
            gross_bal_aft = result[:gross_bal_aft]
            net_bal_bef = result[:net_bal_bef]
            net_bal_aft = result[:net_bal_aft]
            amount = result[:amount]
            charge = result[:charge]
            trans_type = result[:trans_type]
            benef_balance=result[:benef_balance]

            EctoFunc.save_entity_service_account_trxn(temp_id, entity_code, pay_initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, amount, charge, trans_type, benef_balance)
            status="P" #Processed successfully
            EctoFunc.update_temp_payinitiator_service_account_trxn(processing_id, status)

            {:ok, Constant.err_return_success()}
        else
            IO.puts "service_acc_activity_temps record not found. Processing ID: #{processing_id}"
            {:error, Constant.err_failed_req()}
        end

    end




    def adjust_beneficiary_payout_wallet(entity_code, initiator_code, amount, charge, processing_id, trans_type) do
        wallet=acme.Repo.get_by(acme.Schema.InitiatorServiceAcc, initiator_code: initiator_code, active_status: true, del_status: false)
        IO.inspect wallet
        case trans_type do
          "MTC" -> #Payout to Beneficiary

            utc_now=DateTime.truncate(DateTime.utc_now, :second)
            zero_val=Decimal.from_float(0.00)

            {:ok, tot_charge}=BaseFunc.convert_to_decimal(charge)#Decimal.add(cust_charge, merch_charge)
            gross_amount=amount#Decimal.add(actual_amount, tot_charge)
            net_amount=Decimal.sub(amount, tot_charge)

            if !is_nil(wallet) do
                IO.puts "\Initiator Wallet exists\n"

                case from(u in "initiator_service_acc",
                    where: u.initiator_code==^initiator_code
                        and u.active_status==true
                        and u.del_status==false,
                    select: %{new_gross: u.gross_bal, new_net: u.net_bal}
                )|> acme.Repo.update_all([inc: [gross_bal: gross_amount, net_bal: net_amount], set: [updated_at: utc_now]])
                do
                    {1, result} ->
                        map_=hd result
                        gross_bal_aft=map_[:new_gross]
                        gross_bal_bef=Decimal.sub(gross_bal_aft, gross_amount)

                        net_bal_aft=map_[:new_net]
                        net_bal_bef=Decimal.sub(net_bal_aft, net_amount)

                        EctoFunc.save_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft, amount, tot_charge, trans_type)
                        IO.puts "\ninitiator_code #{initiator_code} account updated successfully\n"
                        {:ok, Constant.err_success_req()}
                    {:error, _} ->
                        IO.puts "\nPay Initator account update failed"
                        {:error, Constant.err_failed_req()}
                end
            else
                IO.puts "\nNo wallet available for Pay Initator\n"
                new_gross_bal=Decimal.add(zero_val, gross_amount)
                new_net_bal=Decimal.add(zero_val, net_amount)

                case EctoFunc.create_pay_initiator_service_account(initiator_code, new_gross_bal, new_net_bal) do
                    {:ok, _} ->
                        IO.puts "\nPay Initator code #{initiator_code} account created and updated successfully\n"
                        EctoFunc.save_payinitiator_service_account_trxn(entity_code, initiator_code, processing_id, zero_val, new_gross_bal, zero_val, new_net_bal, gross_amount, tot_charge, trans_type)
                        {:ok, Constant.err_success_req()}
                    {:error, _} ->
                        IO.puts "Failure"
                        {:error, Constant.err_failed_req()}
                end
            end
        end
    end



    def compute_product_charge(product_code, amount, activity_seg) do
        query=from(u in "assigned_fees",
            where: u.product_code==^product_code and u.active_status==true and u.del_status==false,
            order_by: [desc: u.created_at],
            limit: 1,
            select: %{fee: u.value, flat_percent: u.fee_type, cap: fragment("coalesce(?, 0.00)", u.cap), limit_capped: fragment("coalesce(?, 0.00)", u.threshold_amt)}
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query

            fee=result[:fee]
            flat_percent=result[:flat_percent]
            cap=result[:cap]
            limit_capped=result[:limit_capped]
            charged_to=activity_seg

            fee=cond do
                Decimal.is_decimal(fee)-> fee
                true-> Decimal.from_float(fee)
            end

            cap=cond do
                Decimal.is_decimal(cap)-> cap
                true-> Decimal.from_float(cap)
            end

            limit_capped=cond do
                Decimal.is_decimal(limit_capped)-> limit_capped
                true-> Decimal.from_float(limit_capped)
            end

            amount=cond do
                Decimal.is_decimal(amount)-> amount
                true-> Decimal.from_float(amount)
            end

            IO.puts "\nFee: #{fee}\nCap: #{cap}\nAmount: #{amount}\n"

            zero_val=Decimal.from_float(0.00)
            amount_charged=case activity_seg do
            "M"-> #Fee computation is being invoked at the merchant section of the application
                IO.puts "\n==== Merchant charge computation ====\n"
                if charged_to=="M" do
                    IO.puts "\n==== Charged to merchant ====\n"
                    if Decimal.cmp(limit_capped, zero_val)==:gt do
                        if Decimal.cmp(amount, limit_capped)==:gt || Decimal.cmp(amount, limit_capped)==:eq do
                            cap
                        else
                            case flat_percent do
                                "F"->
                                    fee
                                "P"->
                                    Decimal.mult(Decimal.div(fee, 100), amount)
                            end
                        end
                    else
                        case flat_percent do
                            "F"->
                                fee
                            "P"->
                                Decimal.mult(Decimal.div(fee, 100), amount)
                        end
                    end
                else
                    zero_val
                end
            "C"-> #Fee computation is being invoked at the customer section of the application
                if charged_to=="C" do
                    val=if Decimal.cmp(limit_capped, zero_val)==:gt do
                        if Decimal.cmp(amount, limit_capped)==:gt || Decimal.cmp(amount, limit_capped)==:eq do
                            cap
                        else
                            case flat_percent do
                                "F"->
                                    fee
                                "P"->
                                    calc_perc=Decimal.div(fee, 100)
                                    new_amount=amount |> Decimal.div(Decimal.sub(1, calc_perc))
                                    Decimal.sub(new_amount, amount)
                            end
                        end
                    else
                        case flat_percent do
                            "F"->
                                fee
                            "P"->
                                calc_perc=Decimal.div(fee, 100)
                                new_amount=amount |> Decimal.div(Decimal.sub(1, calc_perc))
                                Decimal.sub(new_amount, amount)
                        end
                    end

                    IO.puts "\n=== Computed charge: #{val} ===\n"
                    IO.puts "\n=== Computing the ceiling for customer charge ===\n"
                    val |> Decimal.to_float()
                    # |> Float.ceil(2)
                    |> Float.round(2)
                else
                    zero_val
                end
            end

            amount_charged=cond do
                Decimal.is_decimal(amount_charged)->
                    Decimal.to_float(amount_charged)
                true->
                    amount_charged
            end

            IO.puts "\nAmount charged is: #{amount_charged}, Decimal.from_float(amount_charged): #{Decimal.from_float(amount_charged)}\n"
            amount_charged=if activity_seg=="C" do
                :erlang.float_to_binary(amount_charged, decimals: 2)
            else
                Decimal.round(Decimal.from_float(amount_charged), 2)
            end
            IO.puts "\n==== Charge: #{amount_charged} ====\n"
            {:ok, %{fee: to_string(amount_charged), fee_type: flat_percent}}
        else
            {:error, Constant.err_no_record_found()}
        end
    end


    def validate_pay_initiator_balance_payout(entity_code, pay_initiator_code, total_amount, reference_id, trans_type) do
      query=from(isa in "initiator_service_acc",
            where: isa.initiator_code==^pay_initiator_code and isa.active_status==true and isa.del_status==false,
            select: %{net_bal: isa.net_bal},
            limit: 1,
            order_by: [desc: isa.created_at]
        )|> acme.Repo.all

        if length(query)==1 do
            result=hd query
            p=%{net_bal: result[:net_bal]}
            pay_iniator_balance=result[:net_bal]

            {:ok, disburse_amount}=BaseFunc.convert_to_decimal(total_amount)
            balance_compare=Decimal.cmp(pay_iniator_balance, disburse_amount)

            case balance_compare do
              :lt ->
                err_msg="Insufficient balance in Pay Initiator account. Initiator: #{pay_initiator_code}, Balance: #{pay_iniator_balance}"
                IO.puts err_msg
                EctoFunc.log_err_resp(entity_code, reference_id, err_msg, trans_type)
                {:error, Constant.err_insufficient_bal()}
              _ ->
                {:ok, p}
            end
        else
            {:error, Constant.err_pay_intiator_account_zero()}
        end
    end


end
