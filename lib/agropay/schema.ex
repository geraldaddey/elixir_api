defmodule acme.Schema.ActivityCat do
    use Ecto.Schema

    schema "activity_cat" do
        field :entity_code, :string
        field :assigned_code, :string
        field :activity_cat_desc, :string
        field :comment, :string
        field :user_id, :integer
        field :active_status, :boolean
        field :del_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(activitycat, params \\ %{}) do
        activitycat
        |> Ecto.Changeset.cast(params, [:entity_code, :assigned_code, :activity_cat_desc, :comment, :user_id, :active_status, :del_status, :created_at, :updated_at])
        # |> Ecto.Changeset.validate_required([:assigned_code])
    end
end

defmodule acme.Schema.AssignedFee do
    use Ecto.Schema

    schema "assigned_fees" do
        field :entity_code, :string
        field :product_code, :string
        field :metric_unit_code, :string
        field :fee_type, :string
        field :value, :decimal
        field :threshold_amt, :decimal
        field :cap, :decimal
        field :comment, :string
        field :user_id, :integer
        field :active_status, :boolean
        field :del_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end
end


defmodule acme.Schema.AssignedServiceCode do
	use Ecto.Schema

	schema "assigned_service_code" do
        field :entity_code, :string
        field :service_code, :string
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
end

defmodule acme.Schema.AuthCycle do
	use Ecto.Schema

	schema "auth_cycle" do
        field :entity_code, :string
        field :auth_user_id, :integer
        field :fund_alloc_ref_id, :string
        field :fund_alloc_id, :integer
        field :approval_status, :boolean
        field :reason, :string
        field :approved_at, :utc_datetime
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(authcycle, params \\ %{}) do
        authcycle
        |> Ecto.Changeset.cast(params, [:entity_code, :auth_user_id, :fund_alloc_ref_id, :fund_alloc_id, :approval_status, :reason, :approved_at, :created_at, :updated_at])
        # |> Ecto.Changeset.validate_required([:assigned_code])
    end
end


defmodule acme.Schema.AuthUser do
	use Ecto.Schema

	schema "auth_users" do
        field :entity_code, :string
        field :auth_user_id, :integer
        field :authorizer_config_code, :string
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(authuser, params \\ %{}) do
        authuser
        |> Ecto.Changeset.cast(params, [:entity_code, :auth_user_id, :authorizer_config_code, :comment, :active_status, :del_status, :user_id, :created_at, :updated_at])
    end
end


defmodule acme.Schema.AuthorizerCat do
	use Ecto.Schema

	schema "authorizer_cat" do
        field :entity_code, :string
        field :approver_cat_desc, :string
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(authorizercat, params \\ %{}) do
        authorizercat
        |> Ecto.Changeset.cast(params, [:entity_code, :approver_cat_desc, :comment, :active_status, :del_status, :user_id, :created_at, :updated_at])
    end
end



defmodule acme.Schema.AuthorizeConfig do
	use Ecto.Schema

	schema "authorizer_configs" do
        field :assigned_code, :string
        field :entity_code, :string
        field :trans_type, :string
        field :authorizer_cat_id, :integer
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(authorizerconfig, params \\ %{}) do
        authorizerconfig
        |> Ecto.Changeset.cast(params, [:assigned_code, :entity_code, :trans_type, :authorizer_cat_id, :active_status, :del_status, :user_id, :created_at, :updated_at])
    end
end


defmodule acme.Schema.BeneficiaryAccInfo do
	use Ecto.Schema

	schema "beneficiary_acc_info" do
        field :beneficiary_code, :string
        field :acct_no, :string
        field :nw, :string
        field :acct_type, :string
        field :swift_code, :string
        field :sort_code, :string
        field :is_default, :boolean
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(beneficiaryaccinfo, params \\ %{}) do
        beneficiaryaccinfo
        |> Ecto.Changeset.cast(params, [:beneficiary_code, :acct_no, :nw, :acct_type, :swift_code, :sort_code, :is_default, :comment, :active_status, :del_status, :user_id, :created_at, :updated_at])
    end
end


defmodule acme.Schema.BeneficiaryInfo do
	use Ecto.Schema

	schema "beneficiary_infos" do
        field :assigned_code, :string
        field :last_name, :string
        field :first_name, :string
        field :other_names, :string
        field :id_type, :string
        field :id_no, :string
        field :contact_number, :string
        field :custom_id, :string
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(beneficiaryinfo, params \\ %{}) do
        beneficiaryinfo
        |> Ecto.Changeset.cast(params, [:assigned_code, :last_name, :first_name, :other_names, :id_type, :id_no, :contact_number, :custom_id, :comment, :active_status, :del_status, :user_id, :created_at, :updated_at])
    end
end



defmodule acme.Schema.BeneficiarySociety do
	use Ecto.Schema

	schema "beneficiary_society" do
        field :society_code, :string
        field :beneficiary_code, :string
        field :product_code, :string
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :user_id, :integer
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
	end
    def changeset(beneficiarysociety, params \\ %{}) do
        beneficiarysociety
        |> Ecto.Changeset.cast(params, [:society_code, :beneficiary_code, :product_code, :comment, :active_status, :del_status, :user_id, :created_at, :updated_at])
    end
end



defmodule acme.Schema.PaymentCallback do
	use Ecto.Schema

	schema "callback_status" do
		field :trans_status, :string
		field :trans_id, :string
		field :trans_ref, :string
		field :trans_msg, :string
		field :resp_code, :string
		field :resp_desc, :string
		field :created_at, :utc_datetime
	end
end


defmodule acme.Schema.EntityInfo do
	use Ecto.Schema

	schema "entity_info" do
		field :assigned_code, :string
		field :entity_name, :string
		field :entity_alias, :string
		field :entity_type_code, :string
		field :activity_cat_code, :string
		field :comment, :string
		field :active_status, :boolean
    field :del_status, :boolean
    field :user_id, :integer
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
	end
end


defmodule acme.Schema.EntityExtraInfo do
	use Ecto.Schema

	schema "entity_extra_info" do
		field :entity_code, :string
		field :contact_address, :string
		field :location_address, :string
		field :web_address, :string
		field :contact_email, :string
		field :contact_number, :string
    field :benef_list_lookup, :boolean
    field :benef_list, :string
    field :benef_identifier, :string
		field :comment, :string
		field :active_status, :boolean
    field :del_status, :boolean
    field :user_id, :integer
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
	end
end



defmodule acme.Schema.EntityServiceAccount do
  use Ecto.Schema

  schema "entity_service_acc" do
  	field :entity_code, :string
  	field :gross_bal, :decimal
  	field :net_bal, :decimal
  	field :active_status, :boolean
  	field :del_status, :boolean
  	field :created_at, :utc_datetime
  	field :updated_at, :utc_datetime
  end

  def changeset(serviceaccount, params \\ %{}) do
        serviceaccount
        |> Ecto.Changeset.cast(params, [:entity_code, :gross_bal, :net_bal, :active_status, :del_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:entity_code])
	end
end


defmodule acme.Schema.EntityServiceAccountTrxn do
  use Ecto.Schema

  schema "service_acc_activity" do
    field :temp_id, :integer
  	field :entity_code, :string
  	field :pay_initiator_code, :string
    field :processing_id, :string
    field :trans_type, :string
  	field :gross_bal_bef, :decimal
  	field :gross_bal_aft, :decimal
  	field :net_bal_bef, :decimal
  	field :net_bal_aft, :decimal
  	field :amount, :decimal
  	field :charge, :decimal
    field :benef_balance, :decimal
  	field :created_at, :utc_datetime
  	field :updated_at, :utc_datetime
  end
end




defmodule acme.Schema.EntityServiceAccountTrxnTemp do
  use Ecto.Schema

  schema "service_acc_activity_temps" do
    field :entity_code, :string
  	field :pay_initiator_code, :string
    field :processing_id, :string
    field :trans_type, :string
  	field :gross_bal_bef, :decimal
  	field :gross_bal_aft, :decimal
  	field :net_bal_bef, :decimal
  	field :net_bal_aft, :decimal
  	field :amount, :decimal
  	field :charge, :decimal
    field :benef_balance, :decimal
    field :status, :string
  	field :created_at, :utc_datetime
  	field :updated_at, :utc_datetime
  end

  def changeset(service_acc_activity_temps, params \\ %{}) do
        service_acc_activity_temps
        |> Ecto.Changeset.cast(params, [:entity_code, :pay_initiator_code, :processing_id, :trans_type, :gross_bal_bef, :gross_bal_aft, :net_bal_bef, :net_bal_aft, :amount, :charge, :benef_balance, :status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:processing_id])
	end
end


defmodule acme.Schema.EntityWalletConfig do
	use Ecto.Schema

	schema "entity_wallet_config" do
		field :entity_code, :string
		field :sms_sender_id, :string
		field :service_id, :integer
		field :secret_key, :string
		field :client_key, :string
		field :comment, :string
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
	end
end



defmodule acme.Schema.FundAlloc do
use Ecto.Schema

schema "fund_alloc" do
	field :assigner_entity_code, :string
	field :assignee_entity_code, :string
	field :pay_initiator_code, :string
	field :amount, :decimal
	field :ref_id, :string
	field :trans_type, :string
	field :approval_status, :boolean
	field :approved_at, :utc_datetime
  field :season_id, :integer
	field :comment, :string
	field :user_id, :integer
	field :active_status, :boolean
	field :del_status, :boolean
	field :created_at, :utc_datetime
	field :updated_at, :utc_datetime
end

def changeset(fundalloc, params \\ %{}) do
        fundalloc
        |> Ecto.Changeset.cast(params, [:assigner_entity_code, :assignee_entity_code, :pay_initiator_code, :amount, :ref_id, :trans_type, :approval_status, :approved_at, :season_id, :comment, :user_id, :active_status, :del_status, :created_at, :updated_at])
        # |> Ecto.Changeset.validate_required([:entity_code])
	end
end



defmodule acme.Schema.InitiatorServiceAcc do
use Ecto.Schema

schema "initiator_service_acc" do
	field :initiator_code, :string
	field :gross_bal, :decimal
	field :net_bal, :decimal
	field :active_status, :boolean
	field :del_status, :boolean
	field :created_at, :utc_datetime
	field :updated_at, :utc_datetime
end

def changeset(initiatorserviceacc, params \\ %{}) do
        initiatorserviceacc
        |> Ecto.Changeset.cast(params, [:initiator_code, :gross_bal, :net_bal, :active_status, :del_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:initiator_code])
	end
end



defmodule acme.Schema.MetricUnit do
	use Ecto.Schema

	schema "metric_unit" do
		field :assigned_code, :string
		field :unit_desc, :string
		field :comment, :string
		field :user_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
	end
end


defmodule acme.Schema.PayInitiatorInfo do
	use Ecto.Schema

	schema "pay_initiator_info" do
		field :assigned_code, :string
		field :entity_code, :string
		field :initiator_id, :integer
		field :mobile_number, :string
		field :user_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
	end
end



defmodule acme.Schema.PaymentInfo do
    use Ecto.Schema

    schema "payment_info" do
        field :session_id, :string
        field :entity_code, :string
        field :initiator_code, :string
        field :pan, :string
        field :product_qty, :integer
        field :metric_unit_code, :string
        field :amount, :decimal
        field :amt_charge, :decimal
        field :pay_initiator_sub_tot, :decimal
        field :deductions, :decimal
        field :beneficiary_code, :string
        field :product_code, :string
        field :trans_type, :string
        field :purchase_season_id, :integer
        field :product_weight, :decimal
        field :payment_mode, :string
        field :comment, :string
        field :beneficiary_name, :string
        field :product_metric_id, :integer
        # field :narration, :string
        field :processed, :boolean
        field :src, :string
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(payment_info, params \\ %{}) do
        payment_info
        |> Ecto.Changeset.cast(params, [:session_id, :entity_code, :initiator_code, :pan, :product_qty, :metric_unit_code, :amt_charge, :pay_initiator_sub_tot, :deductions, :beneficiary_code, :product_code, :trans_type, :purchase_season_id, :product_weight, :payment_mode, :comment, :beneficiary_name, :product_metric_id, :processed, :src, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:pan])
    end
end



defmodule acme.Schema.PaymentRequest do
    use Ecto.Schema

    schema "payment_request" do
        field :payment_info_id, :integer
        field :processing_id, :string
        field :pan, :string
        field :nw, :string
        field :trans_type, :string
        field :amount, :decimal
        field :service_id, :integer
        field :payment_mode, :string
        field :reference, :string
        field :processed, :boolean
        field :charge, :decimal
        field :ticket_number, :string
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(payment_request, params \\ %{}) do
        payment_request
        |> Ecto.Changeset.cast(params, [:payment_info_id, :processing_id, :pan, :nw, :trans_type, :amount, :service_id, :payment_mode, :reference, :processed, :charge, :ticket_number, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:processing_id])
    end
end



defmodule acme.Schema.ProductInfo do
    use Ecto.Schema

    schema "product_info" do
        field :entity_code, :string
        field :assigned_code, :string
        field :product_name, :string
        field :product_alias, :string
        field :comment, :string
        field :user_id, :integer
    		field :active_status, :boolean
    		field :del_status, :boolean
    		field :created_at, :utc_datetime
    		field :updated_at, :utc_datetime
    end
end

defmodule acme.Schema.ProductMetric do
    use Ecto.Schema

    schema "product_metric" do
        field :product_code, :string
        field :metric_unit_code, :string
        field :price_per_unit, :decimal
        field :weight_per_unit, :decimal
        field :currency, :string
        field :comment, :string
        field :user_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
    end
end


defmodule acme.Schema.PurchaseSeason do
    use Ecto.Schema

    schema "purchase_season" do
        field :entity_code, :string
        field :season_desc, :string
        field :season_alias, :decimal
        field :start_date, :utc_datetime
        field :end_date, :utc_datetime
        field :entity_id, :string
        field :comment, :string
        field :user_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
    end
end


defmodule acme.Schema.SocietyMaster do
    use Ecto.Schema

    schema "society_master" do
        field :assigned_code, :string
        field :society_desc, :string
        field :district_id, :integer
        field :comment, :string
        field :user_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
    end
end


defmodule acme.Schema.TransTypeMaster do
    use Ecto.Schema

    schema "trans_type_masters" do
        field :assigned_code, :string
        field :trans_type_desc, :string
        field :user_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
    end
end


defmodule acme.Schema.User do
    use Ecto.Schema

    schema "users" do
        field :email, :string
        field :user_name, :string
        field :last_name, :string
        field :first_name, :string
        field :other_names, :string
        field :contact_number, :string
        field :free_id, :integer
        field :do_master_id, :integer
        field :entity_code, :string
        field :role_id, :integer
        field :creator_id, :integer
		field :active_status, :boolean
		field :del_status, :boolean
		field :created_at, :utc_datetime
		field :updated_at, :utc_datetime
    end
end



defmodule acme.Schema.DuplicateCallback do
	use Ecto.Schema

	schema "duplicate_callback" do
		field :trans_status, :string
		field :nw_trans_id, :string
		field :trans_ref, :string
		field :trans_msg, :string
		field :sub_trans_status, :string
		field :created_at, :utc_datetime
	end
end


defmodule acme.Schema.ErrLog do
    use Ecto.Schema

    schema "err_log" do
        field :entity_code, :string
        field :processing_id, :string
        field :err_msg, :string
        field :trans_type, :string
        field :created_at, :utc_datetime
    end
end



defmodule acme.Schema.GlobalParam do
    use Ecto.Schema

    schema "global_param" do
        field :param_name, :string
        field :param_value, :string
        field :assigned_code, :string
        field :user_id, :integer
        field :act_status, :boolean
        field :del_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end
end



defmodule acme.Schema.MessageLog do
    use Ecto.Schema

    schema "message_log" do
        field :entity_code, :string
        field :processing_id, :string
        field :sender_id, :string
        field :message, :string
        field :message_id, :string
        field :phone_number, :string
        field :recipient_type, :string
        field :resp_code, :string
        field :resp_desc, :string
        field :status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(messagelogs, params \\ %{}) do
        messagelogs
        |> Ecto.Changeset.cast(params, [:entity_code, :processing_id, :sender_id, :message, :message_id, :phone_number, :recipient_type, :resp_code, :resp_desc, :status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:sender_id, :message, :phone_number])
    end
end


defmodule acme.Schema.BeneficiaryInput do
    use Ecto.Schema

    schema "beneficiary_inputs" do
        field :farm_input_id, :integer
        field :beneficiary_code, :string
        field :qty, :integer
        field :repay, :boolean
        field :deduct_amount, :decimal
        field :paid_status, :string
        field :comment, :string
        field :deduct_type, :string
        field :user_id, :integer
    		field :active_status, :boolean
    		field :del_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(beneficiary_inputs, params \\ %{}) do
        beneficiary_inputs
        |> Ecto.Changeset.cast(params, [:farm_input_id, :beneficiary_code, :qty, :repay, :deduct_amount, :paid_status, :comment, :deduct_type, :user_id, :active_status, :del_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:farm_input_id])
    end
end



defmodule acme.Schema.FarmInput do
    use Ecto.Schema

    schema "farm_inputs" do
        field :assigned_code, :string
        field :entity_code, :string
        field :input_desc, :string
        field :metric_unit_code, :string
        field :comment, :string
        field :user_id, :integer
    		field :active_status, :boolean
    		field :del_status, :boolean
    		field :created_at, :utc_datetime
    		field :updated_at, :utc_datetime
    end
end


defmodule acme.Schema.BenInputRepayTemp do
    use Ecto.Schema

    schema "beneficiary_input_repay_temps" do
        field :beneficiary_input_id, :integer
        field :processing_id, :string
        field :actual_disburse_amt, :decimal
        field :amt_deducted, :decimal
        field :bal_before, :decimal
        field :bal_after, :decimal
        field :used_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(beneficiary_input_repay_temps, params \\ %{}) do
        beneficiary_input_repay_temps
        |> Ecto.Changeset.cast(params, [:beneficiary_input_id, :processing_id, :actual_disburse_amt, :amt_deducted, :bal_before, :bal_after, :used_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:processing_id])
    end
end


defmodule acme.Schema.BenInputRepay do
    use Ecto.Schema

    schema "beneficiary_input_repays" do
        field :temp_id, :integer
        field :beneficiary_input_id, :integer
        field :processing_id, :string
        field :actual_disburse_amt, :decimal
        field :amt_deducted, :decimal
        field :bal_before, :decimal
        field :bal_after, :decimal
        field :used_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(beneficiary_input_repay_temps, params \\ %{}) do
        beneficiary_input_repay_temps
        |> Ecto.Changeset.cast(params, [:beneficiary_input_id, :processing_id, :actual_disburse_amt, :amt_deducted, :bal_before, :bal_after, :used_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:processing_id])
    end
end


defmodule acme.Schema.BenefPayoutShare do
    use Ecto.Schema

    schema "benef_payout_shares" do
        field :beneficiary_code, :string
        field :value_type, :string
        field :value, :decimal
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(benef_payout_share, params \\ %{}) do
        benef_payout_share
        |> Ecto.Changeset.cast(params, [:beneficiary_code, :value_type, :value, :comment, :active_status, :del_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:beneficiary_code])
    end
end



defmodule acme.Schema.AccountInquiryReq do
    use Ecto.Schema

    schema "account_inquiry_req" do
        field :entity_code, :string
        field :processing_id, :string
        field :pan, :string
        field :bank_code, :string
        field :service_id, :string
        field :resp_code, :string
        field :resp_desc, :string
        field :response, :string
        field :comment, :string
        field :active_status, :boolean
        field :del_status, :boolean
        field :created_at, :utc_datetime
        field :updated_at, :utc_datetime
    end

    def changeset(account_inquiry_req, params \\ %{}) do
        account_inquiry_req
        |> Ecto.Changeset.cast(params, [:entity_code, :processing_id, :pan, :bank_code, :service_id, :resp_code, :resp_desc, :response, :comment, :active_status, :del_status, :created_at, :updated_at])
        |> Ecto.Changeset.validate_required([:processing_id])
    end
end


defmodule acme.Schema.AlertRecipient do
    use Ecto.Schema

    schema "alert_recipient" do
        field :entity_code, :string
        field :recipient_name, :string
        field :mobile_number, :string
        field :email, :string
        field :trans_type, :string
        field :user_id, :integer
    		field :active_status, :boolean
    		field :del_status, :boolean
    		field :created_at, :utc_datetime
    		field :updated_at, :utc_datetime
    end
end




defmodule acme.Encrypted.Binary do
    use Cloak.Ecto.Binary, vault: acme.Vault
end

defmodule acme.Encrypted.Integer do
    use Cloak.Ecto.Integer, vault: acme.Vault
end

defmodule acme.Hashed.HMAC do
  use Cloak.Ecto.HMAC, otp_app: :acme
end

defmodule acme.Schema.IncomingRequest do
    use Ecto.Schema

    schema "incoming_request_api" do
        field :customer_id, acme.Encrypted.Binary
        field :customer_number, acme.Encrypted.Binary
        #        field :customer_id_hash, Cloak.Fields.SHA256
        field :remote_ip, acme.Encrypted.Binary
        field :req_url, acme.Encrypted.Binary
        field :req_path, acme.Encrypted.Binary
        field :req_body, acme.Encrypted.Binary
        field :user_agent, acme.Encrypted.Binary
        field :user_agent_hash, acme.Encrypted.Binary
        field :latitude, acme.Encrypted.Binary
        field :longitude, acme.Encrypted.Binary
        field :created_at, :utc_datetime
    end
end
