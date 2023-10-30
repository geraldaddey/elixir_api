defmodule acme.EctoFunc do
  import Ecto.Query
  alias acme.Constant
  alias Ecto.Multi


    def save_fund_allocation(assigner_entity_code, assignee_entity_code, pay_initiator_code \\ "", amount, ref_id, trans_type, season_id, user_id) do
      res=%acme.Schema.FundAlloc{assigner_entity_code: assigner_entity_code, assignee_entity_code: assignee_entity_code, pay_initiator_code: pay_initiator_code, amount: amount, ref_id: ref_id, trans_type: trans_type, season_id: season_id, user_id: user_id} |> acme.Repo.insert
      res
    end

    def save_approver_record(entity_code, auth_user_id, fund_alloc_id, fund_alloc_ref_id) do
        res=%acme.Schema.AuthCycle{entity_code: entity_code, auth_user_id: auth_user_id, fund_alloc_id: fund_alloc_id, fund_alloc_ref_id: fund_alloc_ref_id} |> acme.Repo.insert
        res
    end

    def save_sms(entity_code, sender_id, message, message_id, phone_number, resp_code, resp_desc, processing_id, recipient_type) do
      res=%acme.Schema.MessageLog{entity_code: entity_code, sender_id: sender_id, message: message, message_id: message_id, phone_number: phone_number, resp_code: resp_code, resp_desc: resp_desc, status: true, processing_id: processing_id, recipient_type: recipient_type} |> acme.Repo.insert
      res
    end

    def mark_auth_cycle_status(fund_alloc_id, auth_user_id, reason \\ "", status) do
      record = acme.Repo.get_by(acme.Schema.AuthCycle, [fund_alloc_id: fund_alloc_id, auth_user_id: auth_user_id])
      changeset = acme.Schema.AuthCycle.changeset(record, %{approval_status: status, reason: reason, approved_at: NaiveDateTime.utc_now, updated_at: NaiveDateTime.utc_now})
      res=acme.Repo.update(changeset)
      res
    end


    def mark_all_auth_cycle_false(fund_alloc_id, reason) do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        query = from(ac in acme.Schema.AuthCycle, where: ac.fund_alloc_id==^fund_alloc_id and is_nil(ac.approval_status))
        res=acme.Repo.update_all(query, set: [ approval_status: false, reason: reason, approved_at: NaiveDateTime.utc_now, updated_at: utc_now])
        res

    end


    def approve_fund_allocation(fund_alloc_id, status) do
      query=from(u in "fund_alloc",
          where: u.id==^fund_alloc_id and u.active_status==true and u.del_status==false,
          select: %{id: u.id, ref_id: u.ref_id},
          limit: 1,
          order_by: [asc: u.created_at]
      )|> acme.Repo.all

      if length(query)==1 do
          result=hd query
          fund_alloc_id=result[:id]

          {:ok, res}=mark_fund_alloc_status(fund_alloc_id, status)
          {:ok, Constant.err_success_fund_approval()}
      else
          {:error, Constant.err_missing_fund_allocation_record()}
      end
    end


    def mark_fund_alloc_status(fund_alloc_id, status) do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        record = acme.Repo.get_by(acme.Schema.FundAlloc, [id: fund_alloc_id, active_status: true, del_status: false])
        changeset = acme.Schema.FundAlloc.changeset(record, %{approval_status: status, approved_at: utc_now, updated_at: utc_now})
        res=acme.Repo.update(changeset)
        res
    end


    def create_entity_service_account(entity_code, gross_bal, net_bal) do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        res=%acme.Schema.EntityServiceAccount{entity_code: entity_code, gross_bal: gross_bal, net_bal: net_bal, created_at: utc_now, updated_at: utc_now} |> acme.Repo.insert
        res
    end


    def create_pay_initiator_service_account(initiator_code, gross_bal, net_bal) do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        res=%acme.Schema.InitiatorServiceAcc{initiator_code: initiator_code, gross_bal: gross_bal, net_bal: net_bal, created_at: utc_now, updated_at: utc_now} |> acme.Repo.insert
        res
    end


    def save_entity_service_account_trxn(temp_id \\ nil, entity_code, pay_initiator_code \\ nil, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft,  amount, charge, trans_type \\ "", benef_balance \\ nil) do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        res=%acme.Schema.EntityServiceAccountTrxn{temp_id: temp_id, entity_code: entity_code, pay_initiator_code: pay_initiator_code, processing_id: processing_id, gross_bal_bef: gross_bal_bef, gross_bal_aft: gross_bal_aft, net_bal_bef: net_bal_bef, net_bal_aft: net_bal_aft, amount: amount, charge: charge, trans_type: trans_type, benef_balance: benef_balance, created_at: utc_now, updated_at: utc_now} |> acme.Repo.insert
        res
    end

    def save_temp_payinitiator_service_account_trxn(entity_code, pay_initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft,  amount, charge, trans_type \\ "", benef_balance \\ nil) do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        res=%acme.Schema.EntityServiceAccountTrxnTemp{entity_code: entity_code, pay_initiator_code: pay_initiator_code, processing_id: processing_id, gross_bal_bef: gross_bal_bef, gross_bal_aft: gross_bal_aft, net_bal_bef: net_bal_bef, net_bal_aft: net_bal_aft, amount: amount, charge: charge, trans_type: trans_type, benef_balance: benef_balance, created_at: utc_now, updated_at: utc_now} |> acme.Repo.insert
        res
    end

    def reverse_temp_payinitiator_service_account_trxn(processing_id) do
      record = acme.Repo.get_by(acme.Schema.EntityServiceAccountTrxnTemp, [processing_id: processing_id])
      res=if !is_nil(record) do
        changeset = acme.Schema.EntityServiceAccountTrxnTemp.changeset(record, %{status: "R", updated_at: NaiveDateTime.utc_now})
        acme.Repo.update(changeset)
      else
        nil
      end
      res
    end

    def update_temp_payinitiator_service_account_trxn(processing_id, status) do
      record = acme.Repo.get_by(acme.Schema.EntityServiceAccountTrxnTemp, [processing_id: processing_id])
      changeset = acme.Schema.EntityServiceAccountTrxnTemp.changeset(record, %{status: status, updated_at: NaiveDateTime.utc_now})
      res=acme.Repo.update(changeset)
      res
    end

    def save_payinitiator_service_account_trxn(entity_code, pay_initiator_code, processing_id, gross_bal_bef, gross_bal_aft, net_bal_bef, net_bal_aft,  amount, charge, trans_type \\ "") do
        utc_now=DateTime.truncate(DateTime.utc_now, :second)
        res=%acme.Schema.EntityServiceAccountTrxn{entity_code: entity_code, pay_initiator_code: pay_initiator_code, processing_id: processing_id, gross_bal_bef: gross_bal_bef, gross_bal_aft: gross_bal_aft, net_bal_bef: net_bal_bef, net_bal_aft: net_bal_aft, amount: amount, charge: charge, trans_type: trans_type, created_at: utc_now, updated_at: utc_now} |> acme.Repo.insert
        res
    end

    def save_beneficiary_input_repays_temp(processing_id, beneficiary_input_id, actual_disburse_amt, deduct_amount, balance_bef, balance_aft) do
      res=%acme.Schema.BenInputRepayTemp{processing_id: processing_id, beneficiary_input_id: beneficiary_input_id, actual_disburse_amt: actual_disburse_amt, amt_deducted: deduct_amount, bal_before: balance_bef, bal_after: balance_aft} |> acme.Repo.insert
      res
    end

    def save_beneficiary_input_repays(temp_id, processing_id, beneficiary_input_id, actual_disburse_amt, deduct_amount, balance_bef, balance_aft) do
      res=%acme.Schema.BenInputRepay{temp_id: temp_id, processing_id: processing_id, beneficiary_input_id: beneficiary_input_id, actual_disburse_amt: actual_disburse_amt, amt_deducted: deduct_amount, bal_before: balance_bef, bal_after: balance_aft} |> acme.Repo.insert
      res
    end

    def mark_beneficiary_input_repays_temp(temp_id, status) do
      record = acme.Repo.get(acme.Schema.BenInputRepayTemp, temp_id)
      changeset = acme.Schema.BenInputRepayTemp.changeset(record, %{used_status: status, updated_at: NaiveDateTime.utc_now})
      res=acme.Repo.update(changeset)
      res
    end

    def mark_beneficiary_input(beneficiary_input_id, status) do
      record = acme.Repo.get(acme.Schema.BeneficiaryInput, beneficiary_input_id)
      changeset = acme.Schema.BeneficiaryInput.changeset(record, %{paid_status: status, updated_at: NaiveDateTime.utc_now})
      res=acme.Repo.update(changeset)
      res
    end

    def save_payment_info(session_id, entity_code, initiator_code, pan, product_qty, metric_unit_code, product_metric_id, amount, amt_charge, deductions, pay_initiator_sub_tot, beneficiary_code, product_code, trans_type, purchase_season_id, product_weight, payment_mode, beneficiary_name) do
      res=%acme.Schema.PaymentInfo{session_id: session_id, entity_code: entity_code, initiator_code: initiator_code, pan: pan, product_qty: product_qty, metric_unit_code: metric_unit_code, product_metric_id: product_metric_id, amount: amount, amt_charge: amt_charge, deductions: deductions, pay_initiator_sub_tot: pay_initiator_sub_tot, beneficiary_code: beneficiary_code, product_code: product_code, trans_type: trans_type, purchase_season_id: purchase_season_id, product_weight: product_weight, payment_mode: payment_mode, beneficiary_name: beneficiary_name} |> acme.Repo.insert
      res
    end

    def save_payment_request(payment_info_id, processing_id, customer_number, recipient_nw, trans_type, amount, service_id, payment_mode, reference, charge, ticket_number) do
      res=%acme.Schema.PaymentRequest{payment_info_id: payment_info_id, processing_id: processing_id, pan: customer_number, nw: recipient_nw, trans_type: trans_type, amount: amount, service_id: service_id, payment_mode: payment_mode, reference: reference, charge: charge, ticket_number: ticket_number} |> acme.Repo.insert
      res
    end

    def save_callback(trans_status, trans_id, trans_ref, sub_trans_status, trans_msg) do
        res=%acme.Schema.PaymentCallback{trans_status: trans_status, trans_id: trans_id, trans_ref: trans_ref, resp_code: sub_trans_status, trans_msg: trans_msg} |> acme.Repo.insert
        res
    end

    def save_duplicate_callback(trans_status, trans_id, trans_ref, trans_msg, sub_trans_status) do
        res=%acme.Schema.DuplicateCallback{trans_status: trans_status, nw_trans_id: trans_id, trans_ref: trans_ref, sub_trans_status: sub_trans_status, trans_msg: trans_msg} |> acme.Repo.insert
        res
    end

    def mark_payment_request(payment_req_id, status) do
        record = acme.Repo.get(acme.Schema.PaymentRequest, payment_req_id)
        changeset = acme.Schema.PaymentRequest.changeset(record, %{processed: status, updated_at: NaiveDateTime.utc_now})
        res=acme.Repo.update(changeset)
        res
    end


    def mark_payment_info(payment_info_id, status) do
        record = acme.Repo.get(acme.Schema.PaymentInfo, payment_info_id)
        changeset = acme.Schema.PaymentInfo.changeset(record, %{processed: status, updated_at: NaiveDateTime.utc_now})
        res=acme.Repo.update(changeset)
        res
    end


    def log_err_resp(entity_code, processing_id, err_msg, trans_type) do
        res=%acme.Schema.ErrLog{entity_code: entity_code, trans_type: trans_type, processing_id: processing_id, err_msg: err_msg} |> acme.Repo.insert
        res
    end





  def entity_info_exists?(entity_code) do

      num_rec=acme.Repo.one(from ei in "entity_info",
      where: ei.assigned_code==^entity_code and ei.active_status==true and ei.del_status==false, select: count(ei.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end

  def auth_cycle_exists?(auth_user_id, fund_alloc_id) do
      num_rec=acme.Repo.one(from ac in "auth_cycle",
      where: ac.auth_user_id==^auth_user_id and ac.fund_alloc_id==^fund_alloc_id, select: count(ac.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end

  def auth_user_pending_approval?(auth_user_id, fund_alloc_id) do
      num_rec=acme.Repo.one(from ac in "auth_cycle",
      where: ac.auth_user_id==^auth_user_id and ac.fund_alloc_id==^fund_alloc_id and is_nil(ac.approval_status), select: count(ac.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def count_pending_auth_cycle(fund_alloc_id) do
      num_rec=acme.Repo.one(from ac in "auth_cycle",
      where: ac.fund_alloc_id==^fund_alloc_id and is_nil(ac.approval_status), select: count(ac.id))
      num_rec
  end


  def service_code_exists?(assigned_service_code) do
      num_rec=acme.Repo.one(from asc in "assigned_service_code",
      where: asc.service_code==^assigned_service_code and asc.active_status==true and asc.del_status==false, select: count(asc.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def entity_service_code_exists?(entity_code) do
      num_rec=acme.Repo.one(from asc in "assigned_service_code",
      where: asc.entity_code==^entity_code and asc.active_status==true and asc.del_status==false, select: count(asc.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def entity_wallet_exists?(entity_code) do
      num_rec=acme.Repo.one(from u in "entity_wallet_config",
      where: u.entity_code==^entity_code and u.active_status==true and u.del_status==false, select: count(u.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def entity_assigned_fee_exists?(entity_code) do
      num_rec=acme.Repo.one(from u in "assigned_fees",
      where: u.entity_code==^entity_code and u.active_status==true and u.del_status==false, select: count(u.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def approver_list_exists?(entity_code, trans_type) do
      num_rec=acme.Repo.one(from au in "auth_users",
      left_join: ac in "authorizer_config", on: au.authorizer_config_code==ac.assigned_code,
      left_join: u in "users", on: au.auth_user_id==u.id,
      where: ac.trans_type==^trans_type and au.entity_code==^entity_code and ac.active_status==true and ac.del_status==false and u.active_status==true and u.del_status==false and au.active_status==true and au.del_status==false,
      select: count(au.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def product_metric_exists?(entity_code) do
      num_rec=acme.Repo.one(from pi2 in "product_info",
      left_join: pm in "product_metric", on: pi2.assigned_code==pm.product_code,
      where: pi2.entity_code==^entity_code and pi2.active_status==true and pi2.del_status==false and pm.active_status==true and pm.del_status==false,
      select: count(pm.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def pay_initiator_exists?(entity_code) do
      num_rec=acme.Repo.one(from pii in "pay_initiator_info",
      where: pii.entity_code==^entity_code and pii.active_status==true and pii.del_status==false, select: count(pii.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def entity_initiator_products_exists?(entity_code) do
      num_rec=acme.Repo.one(from pii in "pay_initiator_info",
      left_join: ip in "initiator_products", on: pii.assigned_code==ip.initiator_code ,
      where: pii.entity_code==^entity_code and pii.active_status==true and pii.del_status==false and ip.is_default==true and ip.active_status==true and ip.del_status==false,
      select: count(ip.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def entity_ben_acct_info_exists?(entity_code) do
    num_rec=acme.Repo.one(from bai in "beneficiary_acc_info",
    left_join: bi in "beneficiary_info", on: bai.beneficiary_code==bi.assigned_code ,
    where: bi.entity_code==^entity_code and bi.active_status==true and bi.del_status==false and bai.is_default==true and bai.active_status==true and bai.del_status==false,
    select: count(bai.id))
    status=if num_rec > 0 do
        true
    else
        false
    end
    status
  end


  def is_pay_initiator_whitelisted?(mobile_number, entity_code) do
      num_rec=acme.Repo.one(from pii in "pay_initiator_info",
      where: pii.mobile_number==^mobile_number and pii.entity_code == ^entity_code and pii.active_status==true and pii.del_status==false, select: count(pii.id))
      status=if num_rec > 0 do
          true
      else
          false
      end
      status
  end


  def retreive_pay_initiator_info_whitelist(mobile_number, entity_code) do

    query=from(pii in "pay_initiator_info",
        left_join: us in "users", on: pii.initiator_id==us.id,
        where: pii.mobile_number==^mobile_number and pii.entity_code == ^entity_code and pii.active_status==true and pii.del_status==false and us.active_status==true and us.del_status==false,
        select: %{pay_initiator_info_id: pii.id, pay_initiator_code: pii.assigned_code, initiator_id: pii.initiator_id, pay_initiator_mobile_number: pii.mobile_number, last_name: us.last_name, first_name: us.first_name, other_names: us.other_names}
    ) |> acme.Repo.all

    if length(query) > 0 do
        result=hd query

        pay_initiator_info_id=result[:pay_initiator_info_id]
        pay_initiator_code=result[:pay_initiator_code]
        initiator_user_id=result[:initiator_id]
        pay_initiator_mobile_number=result[:pay_initiator_mobile_number]
        pay_initiator_name = result[:last_name] <> " " <> result[:first_name]

        pay_initiator_rec=%{pay_initiator_info_id: pay_initiator_info_id, pay_initiator_code: pay_initiator_code, initiator_user_id: initiator_user_id, pay_initiator_mobile_number: pay_initiator_mobile_number, pay_initiator_name: pay_initiator_name}
        {:ok, pay_initiator_rec}

    else
        {:error, Constant.err_payinitiator_record_empty()}
    end

  end



end
