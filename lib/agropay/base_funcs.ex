defmodule acme.BaseFunc do
    import Ecto.Query

    alias acme.Constant
    alias acme.Manor
    alias acme.EctoFunc
    alias acme.Operations
    # alias acme.Processor
    # alias acme.Function
    # alias acme.Transaction
    alias SendGrid.{Email}


    def parse_payment_med(nil), do: {:error, Constant.err_missing_payment_med()}
    def parse_payment_med(""), do: {:error, Constant.err_missing_payment_med()}
    def parse_payment_med(payment_med) do
        {:ok, payment_med}
    end


    def parse_reference(nil), do: {:error, Constant.err_missing_ref_code()}
    def parse_reference(""), do: {:error, Constant.err_missing_ref_code()}
    def parse_reference(reference) do
        {:ok, reference}
    end

    def parse_payee(nil), do: {:ok, ""}
    def parse_payee(""), do: {:ok, ""}
    def parse_payee(payee) do
        {:ok, payee}
    end

    def parse_session_id(nil), do: {:error, Constant.err_missing_session_id()}
    def parse_session_id(""), do: {:error, Constant.err_missing_session_id()}
    def parse_session_id(session_id) do
        {:ok, session_id}
    end

    def parse_purchase_season(nil), do: {:error, Constant.err_missing_purchase_season_id()}
    def parse_purchase_season(""), do: {:error, Constant.err_missing_purchase_season_id()}
    def parse_purchase_season(purchase_season_id) do
        {:ok, purchase_season_id}
    end


    def parse_entity_code(nil), do: {:error, Constant.err_missing_entity_code()}
    def parse_entity_code(""), do: {:error, Constant.err_missing_entity_code()}
    def parse_entity_code(entity_code) do
        {:ok, entity_code}
    end

    def parse_pay_initiator_code(nil), do: {:error, Constant.err_missing_pay_initiator_code()}
    def parse_pay_initiator_code(""), do: {:error, Constant.err_missing_pay_initiator_code()}
    def parse_pay_initiator_code(pay_initiator_code) do
        {:ok, pay_initiator_code}
    end


    def parse_customer_email(nil, payment_med) do
        case payment_med do
        "MOM"->
            {:ok, ""}
        "CRD"->
            {:error, Constant.err_missing_email()}
        _->
            {:ok, ""}
        end
    end

    def parse_customer_email("", payment_med) do
        case payment_med do
        "MOM"->
            {:ok, ""}
        "CRD"->
            {:error, Constant.err_missing_email()}
        _->
            {:ok, ""}
        end
    end

    def parse_customer_email(email, payment_med) do
        case payment_med do
        "MOM"->
            {:ok, ""}
        "CRD"->
            {:ok, email}
        _->
            {:ok, email}
        end
    end


    def parse_landing_url(nil, payment_med) do
        case payment_med do
        "MOM"->
            {:ok, ""}
        "CRD"->
            {:error, Constant.err_missing_cust_no()}
        _->
            {:ok, ""}
        end
    end

    def parse_landing_url("", payment_med) do
        case payment_med do
        "MOM"->
            {:ok, ""}
        "CRD"->
            {:error, Constant.err_missing_cust_no()}
        _->
            {:ok, ""}
        end
    end

    def parse_landing_url(email, payment_med) do
        case payment_med do
        "MOM"->
            {:ok, ""}
        "CRD"->
            {:ok, email}
        _->
            {:ok, email}
        end
    end

    def parse_landing_url(nil) do
        {:ok, ""}
    end
    def parse_landing_url("") do
        {:ok, ""}
    end
    def parse_landing_url(landing_url) do
        {:ok, landing_url}
    end


    def parse_phone_number(nil, _ctry_code), do: {:error, Constant.err_invalid_phone()}
    def parse_phone_number("", _ctry_code), do: {:error, Constant.err_invalid_phone()}
    def parse_phone_number(phone_number, ctry_code) do
        IO.puts "phone_number: #{phone_number}"
        dial_code="233"

        phone=if String.slice(phone_number, 0,1)=="0" do
            IO.puts "\nPhone number starts with zero\n"

            phone=String.slice(phone_number, 1, String.length(phone_number))
            "#{dial_code}#{phone}"
        else
            IO.puts "\nPhone number does not start with zero\n"
            IO.puts "Country code: #{ctry_code} and dial_code: #{dial_code}"

            if String.slice(phone_number, 0, String.length(dial_code))==dial_code do    ##check whether phone number begins with country code(includes the plus sign)
                str_without_code=String.length(phone_number)-String.length(dial_code)
                IO.puts phone_number
                str=String.slice(phone_number, -(str_without_code), str_without_code)
                "#{dial_code}#{str}"
            else
                trimmed_code=String.slice(dial_code, 1, String.length(dial_code))

                if String.slice(phone_number, 0, String.length(trimmed_code))==trimmed_code do  ##attempt to check whether there's no plus sign infront of the dialing code
                    str_without_code=String.length(phone_number)-String.length(String.slice(dial_code, 1, String.length(dial_code)))
                    str=String.slice(phone_number, -(str_without_code), str_without_code)

                    "#{dial_code}#{str}"
                else
                    "#{dial_code}#{phone_number}"
                end
            end
        end
        IO.puts "Formatted number: #{phone}"
        {:ok, phone}

    end

    def format_mobile_number(nil), do: {:error, Constant.err_invalid_phone()}
    def format_mobile_number(""), do: {:error, Constant.err_invalid_phone()}
    def format_mobile_number(phone_number) do
        {:ok, "#{phone_number}"}
    end

    def format_phone_number(nil), do: {:error, Constant.err_invalid_phone()}
    def format_phone_number(""), do: {:error, Constant.err_invalid_phone()}
    def format_phone_number(phone_number) do
        if formatPhone(phone_number) do
          {:ok, "#{formatPhone(phone_number)}"}
        else
          {:error, Constant.err_invalid_phone()}
        end
    end

    def parse_secret_pin(nil, src) do
      case src do
        "PTL" ->
          {:ok, ""}
        _ ->
          {:error, Constant.err_invalid_secret_pin()}
      end
    end
    def parse_secret_pin("", src) do
      case src do
        "PTL" ->
          {:ok, ""}
        _ ->
          {:error, Constant.err_invalid_secret_pin()}
      end
    end
    def parse_secret_pin(secret_pin, src) do
        msg=case src do
          "PTL" ->
            {:ok, ""}
          _ ->
            msg=if String.length(secret_pin) == Constant.secret_pin_length() do
              {:ok, "#{secret_pin}"}
            else
              {:error, Constant.err_invalid_pin()}
            end
            msg
        end

    end


    def parse_pin(nil), do: {:error, Constant.err_invalid_secret_pin()}
    def parse_pin(""), do: {:error, Constant.err_invalid_secret_pin()}
    def parse_pin(secret_pin), do: {:ok, secret_pin}

    def parse_short_code_ext(nil), do: {:error, Constant.err_missing_shortcodeext()}
    def parse_short_code_ext(""), do: {:error, Constant.err_invalid_shortcodeext()}
    def parse_short_code_ext(short_code_ext), do: {:ok, short_code_ext}

    def parse_customer_id(nil), do: {:error, Constant.err_missing_customer_id()}
    def parse_customer_id(""), do: {:error, Constant.err_invalid_customer_id()}
    def parse_customer_id(customer_id), do: {:ok, customer_id}


    def parse_payment_type(nil), do: {:error, Constant.err_missing_payment_type()}
    def parse_payment_type(""), do: {:error, Constant.err_invalid_payment_type()}
    def parse_payment_type(payment_type), do: {:ok, payment_type}


    def parse_country_code(nil), do: {:error, Constant.err_missing_countrycode()}
    def parse_country_code(""), do: {:error, Constant.err_missing_countrycode()}
    def parse_country_code(ctry_code), do: {:ok, ctry_code}


    def parse_amount(nil), do: {:error, Constant.err_missing_amount()}
    def parse_amount(""), do: {:error, Constant.err_missing_amount()}
    def parse_amount(amount) do
        {:ok, amount}=convert_to_decimal(amount)
    end

    def parse_charge(nil), do: {:error, Constant.err_missing_charge()}
    def parse_charge(""), do: {:error, Constant.err_missing_charge()}
    def parse_charge(charge) do
        {:ok, charge}=convert_to_decimal(charge)
    end


    def parse_pan(""), do: {:error, Constant.err_missing_pan()}
    def parse_pan(nil), do: {:error, Constant.err_missing_pan()}
    def parse_pan(pan) do
      case formatPhone(pan) do
        {:ok, pan_val} ->
          {:ok, "233#{pan_val}"}
        {:error, _err} ->
          {:error, Constant.err_invalid_phone()}
      end
    end


    def parse_payment_mode(""), do: {:error, Constant.err_missing_payment_mode()}
    def parse_payment_mode(nil), do: {:error, Constant.err_missing_payment_mode()}
    def parse_payment_mode(payment_mode) do
        {:ok, payment_mode}
    end


    def parse_metric_unit_code(""), do: {:error, Constant.err_missing_metric_unit_code()}
    def parse_metric_unit_code(nil), do: {:error, Constant.err_missing_metric_unit_code()}
    def parse_metric_unit_code(metric_unit_code) do
        {:ok, metric_unit_code}
    end

    def parse_beneficiary_code("", entity_code) do
      case Operations.get_beneficiary_list_val?(entity_code) do
        {:ok, benef_list} ->
            benef_lookup_up=case benef_list do
              "SBL" -> #Strictly beneficiary list
                {:error, Constant.err_missing_beneficiary_code()}
              "NBL" ->
                {:ok, ""}
              _ ->
                {:ok, ""}
            end
        {:error, reasons} ->
          {:error, reasons}
      end

    end

    def parse_beneficiary_code(nil, entity_code) do
      case Operations.get_beneficiary_list_val?(entity_code) do
        {:ok, benef_list} ->
            benef_lookup_up=case benef_list do
              "SBL" -> #Strictly beneficiary list
                {:error, Constant.err_missing_beneficiary_code()}
              "NBL" ->
                {:ok, ""}
              _ ->
                {:ok, ""}
            end
        {:error, reasons} ->
          {:error, reasons}
      end
    end

    def parse_beneficiary_code(beneficiary_code, entity_code) do
      {:ok, beneficiary_code}
    end





    def parse_approval_reason("", approval_status) do
        case approval_status do
          true->
            {:ok, ""}
          false->
              {:error, Constant.err_missing_appr_reason()}
          _->
              {:ok, ""}
        end

    end

    def parse_approval_reason(nil, approval_status) do
      case approval_status do
        true->
          {:ok, ""}
        false->
            {:error, Constant.err_missing_appr_reason()}
        _->
            {:ok, ""}
      end
    end

    def parse_approval_reason(reason, approval_status) do
        {:ok, reason}
    end




    def parse_src(nil), do: {:error, Constant.err_missing_src()}
    def parse_src(""), do: {:error, Constant.err_invalid_src()}
    def parse_src(src), do: {:ok, src}

    def parse_last_name(nil), do: {:error, Constant.err_missing_lastname()}
    def parse_last_name(""), do: {:error, Constant.err_missing_lastname()}
    def parse_last_name(last_name), do: {:ok, last_name}

    def parse_first_name(nil), do: {:error, Constant.err_missing_firstname()}
    def parse_first_name(""), do: {:error, Constant.err_missing_firstname()}
    def parse_first_name(first_name), do: {:ok, first_name}


    def parse_nw(nil), do: {:error, Constant.err_missing_nw()}
    def parse_nw(""), do: {:error, Constant.err_missing_nw()}
    def parse_nw(nw), do: {:ok, nw}

    def parse_customer_number(nil, nw) do
        if nw==Constant.nw_crd() || nw==Constant.nw_vis() || nw==Constant.nw_mas() do
        {:ok, ""}
        else
        {:error, Constant.err_invalid_cust_no()}
        end
    end

    def parse_customer_number("", nw) do
        if nw==Constant.nw_crd() || nw==Constant.nw_vis() || nw==Constant.nw_mas() do
          {:ok, ""}
        else
          {:error, Constant.err_invalid_cust_no()}
        end
    end

    def parse_customer_number(customer_no, nw) do

        if nw==Constant.nw_crd() || nw==Constant.nw_vis() || nw==Constant.nw_mas() do
          ##{:error, Constant.err_invalid_cust_no()}
          {:ok, ""}
        else
          #{:ok, "233#{BaseFunc.formatPhone(customer_no)}"}
          {:ok, customer_no}
        end
    end

    def parse_trans_type(nil), do: {:error, Constant.err_missing_trans_type()}
    def parse_trans_type(""), do: {:error, Constant.err_missing_trans_type()}
    def parse_trans_type(trans_type) do
        if trans_type=="CTM" do
          {:ok, trans_type}
        else
          {:error, Constant.err_undefined_trans_type()}
        end
    end


    def parse_fund_alloc_trans_type(nil), do: {:error, Constant.err_missing_trans_type()}
    def parse_fund_alloc_trans_type(""), do: {:error, Constant.err_missing_trans_type()}
    def parse_fund_alloc_trans_type(trans_type) do
        {:ok, trans_type}
    end


    def parse_voucher_code(nil, nw) do
        if nw==Constant.nw_vod() do
        {:error, Constant.err_missing_vod_voucher()}
        else
        voucher_code=""
        {:ok, voucher_code}
        end
    end

    def parse_voucher_code("", nw) do
        if nw==Constant.nw_vod() do
        {:error, Constant.err_missing_vod_voucher()}
        else
        voucher_code=""
        {:ok, voucher_code}
        end
    end

    def parse_voucher_code(voucher_code, nw) do
        if nw==Constant.nw_vod() do
        {:ok, voucher_code}
        else
        voucher_code=""
        {:ok, voucher_code}
        end
    end


    def parse_customer_id(nil), do: {:error, Constant.err_invalid_customer_id()}
    def parse_customer_id(""), do: {:error, Constant.err_missing_customer_id()}
    def parse_customer_id(customer_id) do
        {:ok, "#{customer_id}"}
    end

    def parse_customer_type(nil), do: {:error, Constant.err_invalid_customer_type()}
    def parse_customer_type(""), do: {:error, Constant.err_missing_customer_type()}
    def parse_customer_type(customer_type) do
        {:ok, "#{customer_type}"}
    end

    def parse_customer_name(nil), do: {:error, Constant.err_invalid_customer_name()}
    def parse_customer_name(""), do: {:error, Constant.err_missing_customer_name()}
    def parse_customer_name(name) do
        {:ok, "#{name}"}
    end


    def parse_password(nil), do: {:error, Constant.err_invalid_password()}
    def parse_password(""), do: {:error, Constant.err_missing_password()}
    def parse_password(password) do
        {:ok, "#{password}"}
    end


    def parse_email(nil), do: {:error, Constant.err_missing_email()}
    def parse_email(""), do: {:error, Constant.err_missing_email()}
    def parse_email(email) do
        {:ok, "#{email}"}
    end


    def parse_email_exists(nil), do: {:error, Constant.err_missing_email()}
    def parse_email_exists(""), do: {:error, Constant.err_missing_email()}
    def parse_email_exists(email) do

      user_rec=acme.Repo.get_by(acme.Schema.User, [email: email, active_status: true, del_status: false])
      if is_nil(user_rec) do
          {:ok, "#{email}"}
      else
        {:error, Constant.err_duplicate_email()}
      end

    end

    def parse_user(nil), do: {:error, Constant.err_missing_username()}
    def parse_user(""), do: {:error, Constant.err_missing_username()}
    def parse_user(username), do: {:ok, username}

    def parse_user_id(nil), do: {:error, Constant.err_missing_user_id()}
    def parse_user_id(""), do: {:error, Constant.err_missing_user_id()}
    def parse_user_id(user_id) do
      if is_integer(user_id) do
          {:ok, user_id}
      else
        {user_id, ""} = Integer.parse(user_id)
        {:ok, user_id}
      end
    end


    def parse_user_id_optional(nil, src) do
      case src do
        "PTL" ->
          {:error, Constant.err_missing_user_id()}
        _ ->
        {:ok, ""}
      end
    end
    def parse_user_id_optional("", src) do
      case src do
        "PTL" ->
          {:error, Constant.err_missing_user_id()}
        _ ->
        {:ok, ""}
      end
    end
    def parse_user_id_optional(user_id, src) do
      if is_integer(user_id) do
          {:ok, user_id}
      else
        {user_id, ""} = Integer.parse(user_id)
        {:ok, user_id}
      end
    end


    def parse_ref_id(nil), do: {:error, Constant.err_missing_ref_id()}
    def parse_ref_id(""), do: {:error, Constant.err_missing_ref_id()}
    def parse_ref_id(ref_id) do
      {:ok, ref_id}
    end

    def parse_product_code(nil), do: {:error, Constant.err_missing_product_code()}
    def parse_product_code(""), do: {:error, Constant.err_missing_product_code()}
    def parse_product_code(product_code) do
      {:ok, product_code}
    end

    def parse_approval_status(nil), do: {:error, Constant.err_missing_approval_status()}
    def parse_approval_status(""), do: {:error, Constant.err_missing_approval_status()}
    def parse_approval_status(approval_status) do
      {:ok, approval_status}
    end

    def parse_qty(nil), do: {:error, Constant.err_missing_qty()}
    def parse_qty(""), do: {:error, Constant.err_missing_qty()}
    def parse_qty(qty) do
      if is_integer(qty) do
          {:ok, qty}
      else
        {qty, remain} = Integer.parse(qty)
        {:ok, qty}
      end
    end


    def parse_login_src(nil), do: {:error, Constant.err_missing_login_src()}
    def parse_login_src(""), do: {:error, Constant.err_missing_login_src()}
    def parse_login_src(src) do
        {:ok, src}
    end

    def parse_auth_code(nil), do: {:error, Constant.err_missing_auth_code()}
    def parse_auth_code(""), do: {:error, Constant.err_missing_auth_code()}
    def parse_auth_code(auth_code), do: {:ok, auth_code}


    def parse_sms_sender_id(sender_id) do

        sms_sender_id=if is_nil(sender_id) || sender_id=="" do

            val=Constant.str_sms_sender_id()

            if String.length(val) > 9 do
                val |> String.slice(0,9)
            else
                val
            end
        else
            if String.length(sender_id) > 9 do
                IO.puts "\n=== Length of SMS Sender ID is greater than 9 characters. Going ahead to reduce length to 9 ===\n"
                sender_id |> String.slice(0,9)
            else
            sender_id
            end
        end

        {:ok, sms_sender_id}
    end


    #Simple hashing function... not the usual hardcore encrupting though... not 100% safe
    def encrypt_string(str) do
        encrypt_str = str |> Cipher.encrypt
    end

    def decrypt_string(str) do
        decrypt_str = str |> Cipher.decrypt
    end

    def refresh_matview do

        # Ecto.Adapters.SQL.query!(
        #     acme.Repo, "refresh materialized view transaction_report"
        # )
        #
        # Ecto.Adapters.SQL.query!(
        #     acme.Repo, "refresh materialized view customer_topup_report"
        # )
        #
        # Ecto.Adapters.SQL.query!(
        #     acme.Repo, "refresh materialized view customer_scan_report"
        # )
        #
        # Ecto.Adapters.SQL.query!(
        #     acme.Repo, "refresh materialized view operator_scan_report"
        # )
    end


    def convert_to_decimal(val) do
        decimal_value=if is_float(val) do #then its either an integer or float.. ie. 1 or 2.5
            Decimal.from_float(val)
        else
            Decimal.new(val)
        end

        {:ok, decimal_value}
    end

    def convert_to_integer(val) do
      if is_integer(val) do
          {:ok, val}
      else
        {int_val, ""} = Integer.parse(val)
        {:ok, int_val}
      end
    end



    def send_sms(entity_code, recipient_number, message_body, client_id, secret_token, client_token, sender_id, processing_id, recipient_type) do

        spawn_response=spawn fn ->
            process_send_sms(entity_code, recipient_number, message_body, client_id, secret_token, client_token, sender_id, processing_id, recipient_type)
        end

        case spawn_response do
            {:ok, req_response} ->
                {:ok, req_response}
            # {:error, _reason} ->
            #     {:error, Constant.err_failed_req()}
            _ ->
                {:ok, Constant.err_success_req()}
        end

    end


    def process_send_sms(entity_code, recipient_number, message_body, client_id, secret_token, client_token, sender_id, processing_id, recipient_type) do

        endpoint_url=Constant.sms_url()
        datetime=DateTime.utc_now |> NaiveDateTime.to_string
        ts=String.slice(datetime, 0, 19)

        message_id = gen_uniq_id("MI") #gen_2fa_code()
        {:ok, sms_sender_id}=parse_sms_sender_id(sender_id)

        str_params=%{
            sender_id: sms_sender_id,
            recipient_number: recipient_number,
            msg_body: message_body,
            unique_id: message_id,
            trans_type: "SMS",
            msg_type: "T",
            client_id: client_id,
            client_token: client_token,
            secret_token: secret_token,
            sms_sender_id: sms_sender_id,
            service_id: client_id,
        }

        case Manor.process_Manor_req(str_params, secret_token, client_token, endpoint_url) do
            {:ok, response} ->
                # json_payload=Poison.decode!(bal_response)
                # sms_balance = json_payload["sms_bal"]
                EctoFunc.save_sms(entity_code, sms_sender_id, message_body, message_id, recipient_number, "000", "Message successfully received for delivery", processing_id, recipient_type)
                {:ok, Constant.err_return_success()}
            {:error, err_response} ->
                EctoFunc.save_sms(entity_code, sms_sender_id, message_body, message_id, recipient_number, "999", "Failed", processing_id, recipient_type)
                {:error, err_response}
        end

    end





    # def sendemail(params \\ %{}) do
    #   # from_addr=params[:from_addr]
    #   #     to_addr=params[:to_addr]
    #   #     subj=params[:subj]
    #   #     text_body=params[:msg_body]
    #   #     attachment=params[:attachment]
    #   IO.inspect params
    #
    #     attachments=params[:attachment]
    #     # attachments=[%{attachment: "/opt/prodapps/elixir_apps/castvote_elix/temp/qr_CAVT2524706021132"}, %{attachment: "/opt/prodapps/elixir_apps/virtual_pos/temp/qr_4151403085244"}]
    #
    #     Email.build()
    #     |> Email.add_to(params[:to_addr])
    #     |> Email.put_from(params[:from_addr])
    #     |> Email.put_subject(params[:subj])
    #     # |> Email.put_text(params[:msg_body])
    #     |> Email.put_html(params[:msg_body])
    #     |> add_attachments(loop_email_attachment(attachments, []))
    #     |> SendGrid.Mail.send()
    # end


    def sendemail do
        attachments=[%{attachment: "/opt/padmore/elixir_projects/acme/temp/qr_ESH8475502014035.png"}]

        Email.build()
        |> Email.add_to("padmore@quodesolutions.com")
        |> Email.put_from("no-reply@quodesolutions.com")
        |> Email.put_subject("test")
        |> Email.put_text("Hello world...")
        |> add_attachments(loop_email_attachment(attachments, []))
        |> SendGrid.Mail.send()
    end

    # def add_attachments(email, files) do
    #     files
    #     |> Enum.reduce(email, &Email.add_attachment(&2, &1))
    # end
    #
    # def loop_email_attachment([], arr) do
    #     if length(arr) > 0 do
    #         arr
    #     else
    #         nil
    #     end
    # end
    #
    # def loop_email_attachment([hd|tl], arr) do
    #     attachment=hd[:attachment]
    #
    #     data = File.read!(attachment)
    #     encoded = :base64.encode(data)
    #     name=Path.basename(attachment)
    #
    #     str_map=%{content: encoded, filename: "#{name}.png"}
    #     arr=[str_map] ++ arr
    #
    #     loop_email_attachment(tl, arr)
    # end




    def sendemail_pdf(params \\ %{}) do

        template_id = "d-83e9bbec8853460a909871d41e5a1ecb"
        from_email = params[:from_addr]
        from_name = params[:from_name]
        to_email = params[:to_addr]
        header = params[:header]
        name = params[:name]
        body = params[:msg_body]
        team_name = params[:team_name]
        IO.inspect params

        attachments=params[:attachment]

        val=Email.build()
        |> Email.put_template(template_id)
        # |> Email.add_dynamic_template_data("subject", subject)
        |> Email.add_dynamic_template_data("header", header)
        |> Email.add_dynamic_template_data("name", name)
        |> Email.add_dynamic_template_data("body", body)
        |> Email.add_dynamic_template_data("team_name", team_name)
        |> Email.add_to(to_email)
        |> add_attachments_pdf(loop_email_attachment_pdf(attachments, []))
        |> Email.put_from(from_email, from_name)

        # IO.inspect val

        SendGrid.Mail.send(val)

    end


    def add_attachments_pdf(email, files) do
        files
        |> Enum.reduce(email, &Email.add_attachment(&2, &1))
    end

    def loop_email_attachment_pdf([], arr) do
        if length(arr) > 0 do
            arr
        else
            nil
        end
    end

    def loop_email_attachment_pdf([hd|tl], arr) do
        attachment=hd[:attachment]

        data = File.read!(attachment)
        encoded = :base64.encode(data)
        name=Path.basename(attachment)

        str_map=%{content: encoded, filename: "#{name}.pdf"}
        arr=[str_map] ++ arr

        loop_email_attachment_pdf(tl, arr)
    end



    def send_email(email, notif_title, notif_body, _) do

        ##Send an email, if customer has an email address

        spawn_response=spawn fn ->

            IO.puts "\nAttempting to send email to user\n"
            IO.puts email
            if !is_nil(email) do
                acme.Email.send_email(
                    from_addr: Constant.from_email(),
                    to_addr: email,
                    subj: notif_title,
                    msg_body: notif_body
                ) |> acme.Mailer.deliver_now
                {:ok, Constant.err_success_req()}
            end
        end

        case spawn_response do
            {:ok, _} ->
                {:ok, Constant.err_success_req()}
            # {:error, _reason} ->
            #     {:error, Constant.err_failed_req()}
            _ ->
                {:ok, Constant.err_success_req()}
        end

    end


    def add_attachments(email, files) do
        files
        |> Enum.reduce(email, &Email.add_attachment(&2, &1))
    end

    def loop_email_attachment([], arr) do
        if length(arr) > 0 do
            arr
        else
            nil
        end
    end

    def loop_email_attachment([hd|tl], arr) do
        attachment=hd[:attachment]

        data = File.read!(attachment)
        encoded = :base64.encode(data)
        name=Path.basename(attachment)

        str_map=%{content: encoded, filename: "#{name}.png"}
        arr=[str_map] ++ arr

        loop_email_attachment(tl, arr)
    end




    def sendemail_with_attachment(params \\ %{}) do
      IO.inspect params

        attachments=params[:attachment]
        # attachments=[%{attachment: "/opt/prodapps/elixir_apps/castvote_elix/temp/qr_CAVT2524706021132"}, %{attachment: "/opt/prodapps/elixir_apps/virtual_pos/temp/qr_4151403085244"}]

        res=Email.build()
        |> Email.add_to(params[:to_addr])
        |> Email.put_from(params[:from_addr])
        |> Email.put_subject(params[:subj])
        |> Email.put_html(params[:msg_body])
        |> add_attachments(loop_email_attachment(attachments, []))

        IO.inspect SendGrid.Mail.send(res)
    end


    def email_developer(subject, notif_body) do

        email = Constant.developer_email()
        genId = gen_2fa_code()

        txt = "\nHello Engineer, Kindly find below details of the error. \n\n #{notif_body}. \n\n Regards, eBallot"

        if email != "empty" do
            case send_email(email, subject, txt, genId) do
                {:ok, _response} ->
                    {:ok, Constant.err_success_req()}
                {:error, _response} ->
                    {:error, Constant.err_failed_req()}
                _ ->
                    {:ok,  Constant.err_success_req()}
            end
        else
            {:ok,  Constant.err_success_req()}
        end

    end


    # params=%{"email_type": "S", "subject": "UENR Campus Shuttle Account Registion", "header": "Account Registration",
    # "msg_title": "Registration Successful", "entity_name": "University of Energy", "team_name": "EShuttle Team",
    # "salutation": "Hello Clara Mady", "to_email": "padmore@quodesolutions.com",  "msg_body": "Your account on the University of Energy eShuttle System has been created successfully. Find attached your QR code which will be used to board all shuttle in University of Energy.",
    # "support_tel": "(+233) 0302 502 257, (+233) 0302 955 701"}
    # BaseFunc.send_email(params)
    def send_email(params) do

        IO.puts "\n========== Inside send_email routine...==========\n"
        IO.inspect params
        IO.puts "===================================================\n"

        slogan=if !is_nil(params[:slogan]) do
            params[:slogan]
        else
            Constant.slogan()
        end

        from_name=if !is_nil(params[:from_name]) do
            params[:from_name]
        else
            Constant.from_name()
        end

        from_email=if !is_nil(params[:from_email]) do
            params[:from_email]
        else
            Constant.from_email()
        end

        contact_email=if !is_nil(params[:contact_email]) do
            params[:contact_email]
        else
            Constant.contact_email()
        end

        email_type=params[:email_type]
        subject=params[:subject]
        header=params[:header]
        msg_title=params[:msg_title]
        name=params[:name]
        entity_name=params[:entity_name]
        total_amount=params[:total_amount]
        team_name=params[:team_name]
        to_email=params[:to_email]
        salutation=params[:salutation]
        msg_body=params[:msg_body]
        support_tel=params[:support_tel]
        attachments=params[:attachment]

        template_id=case email_type do
            "S"->   #Signup email
                "d-c38b6f2b67494de9a3cb4c0c6d0b96a7"
            "ACT"->   #Account Topup/Payment success email
                "d-12ebb2a46a414b069cf2f2027540568d"
            "SCN"->   #Scan success email
                "d-8d3da896d8d5414b89158b9ac36eb8bb"
            "PR"->   #PIN reset success email
                "d-ebe5878a0c544f6eb147e99dac4c8158"
            "QR"->   #QR Reset
                "d-0ea7af5d5f764bd9b0a98f015e8c677e"
            "STM"->   #Statement email
                "d-5b87c6d5b337465d8bb97bf556cb1d1f"
            # "C"->   #Completed payment email
            #     "d-d8ea910db38b4601910ced19b5d543b7"
            _->
                IO.puts "\nEmail type not defined\nWill decline to send email..."
                nil
        end

        if !is_nil(template_id) do
            IO.puts "\nTemplate ID: #{template_id}\n"

            val=if !is_nil(attachments) do

              val=Email.build()
              |> Email.put_template(template_id)
              |> Email.add_dynamic_template_data("subject", subject)
              |> Email.add_dynamic_template_data("header", header)
              |> Email.add_dynamic_template_data("name", name)
              |> Email.add_dynamic_template_data("team_name", team_name)
              |> Email.add_dynamic_template_data("slogan", slogan)
              |> Email.add_dynamic_template_data("total_amount", total_amount)
              |> Email.add_dynamic_template_data("entity_name", entity_name)
              |> Email.add_dynamic_template_data("msg_title", msg_title)
              |> Email.add_dynamic_template_data("salutation", salutation)
              |> Email.add_dynamic_template_data("msg_title", msg_title)
              |> Email.add_dynamic_template_data("msg_body", msg_body)
              |> Email.add_dynamic_template_data("support_tel", support_tel)
              |> Email.add_dynamic_template_data("slogan", slogan)
              |> Email.add_to(to_email)
              |> Email.put_from(from_email, from_name)
              |> add_attachments(loop_email_attachment(attachments, []))
              val

            else
              val=Email.build()
              |> Email.put_template(template_id)
              |> Email.add_dynamic_template_data("subject", subject)
              |> Email.add_dynamic_template_data("header", header)
              |> Email.add_dynamic_template_data("name", name)
              |> Email.add_dynamic_template_data("team_name", team_name)
              |> Email.add_dynamic_template_data("slogan", slogan)
              |> Email.add_dynamic_template_data("total_amount", total_amount)
              |> Email.add_dynamic_template_data("entity_name", entity_name)
              |> Email.add_dynamic_template_data("msg_title", msg_title)
              |> Email.add_dynamic_template_data("salutation", salutation)
              |> Email.add_dynamic_template_data("msg_title", msg_title)
              |> Email.add_dynamic_template_data("msg_body", msg_body)
              |> Email.add_dynamic_template_data("support_tel", support_tel)
              |> Email.add_dynamic_template_data("slogan", slogan)
              |> Email.add_to(to_email)
              |> Email.put_from(from_email, from_name)
              val
            end

            # IO.inspect val

            SendGrid.Mail.send(val)
        else
            simple_email(params)
        end
    end


    def signup_email(params) do
        subject=params[:subject]
        header=params[:header]
        msg_title=params[:msg_title]
        salutation=params[:salutation]
        msg_body=params[:msg_body]
        support_tel=params[:support_tel]
        team_name=params[:team_name]
        to_email=params[:to_email]
        slogan=params[:slogan]
        from_email="no-reply@quodesolutions.com"

        Email.build()
        |> Email.put_template("d-1bde39091f10491fa4a2679abe93e8f8")
        |> Email.add_dynamic_template_data("subj", subject)
        |> Email.add_dynamic_template_data("header", header)
        |> Email.add_dynamic_template_data("msg_title", msg_title)
        |> Email.add_dynamic_template_data("salutation", salutation)
        |> Email.add_dynamic_template_data("msg_title", msg_title)
        |> Email.add_dynamic_template_data("msg_body", msg_body)
        |> Email.add_dynamic_template_data("support_tel", support_tel)
        |> Email.add_dynamic_template_data("team_name", team_name)
        |> Email.add_dynamic_template_data("slogan", slogan)
        |> Email.add_to(to_email)
        |> Email.put_from(from_email)
        |> SendGrid.Mail.send()


#         {"subj": "UENR Campus Shuttle Account Registion", "header": "Account Registration",
# "msg_title": "Registration Successful",
# "salutation": "Hello Clara Mady",   "msg_body": "Your account on the University of Energy eShuttle System has been created successfully. Find attached your QR code which will be used to board all shuttle in University of Energy.",
# "support_tel": "(+233) 0302 502 257, (+233) 0302 955 701"}
    end


    def simple_email(params) do
        IO.puts "\n=== Inside simple_email routine... ===\n"

        from_addr="no-reply@quodesolutions.com"
        to_addr=params[:to_addr]
        ##from_addr=params[:from_addr]
        subj=params[:subj]
        msg_body=params[:msg_body]

        IO.puts "\n=== from_addr: #{from_addr}\nto_addr: #{to_addr}\nsubj: #{subj}\nmsg_body: #{msg_body} ===\n"
        Email.build()
        |> Email.add_to(to_addr)
        |> Email.put_from(from_addr)
        |> Email.put_subject(subj)
        |> Email.put_text(msg_body)
        |> SendGrid.Mail.send()
    end



    def gen_HMAC(secret_key, text) do
        _hmac = :crypto.mac(:hmac, :sha256, secret_key, text)
                |> Base.encode16
                |> String.downcase
    end


    def gen_uniq_id(tbl) do
        datetime=DateTime.utc_now |> NaiveDateTime.to_string
        ##microsec=String.slice(datetime, 20, 6)
        microsec=String.pad_leading(String.slice(datetime, 23, 3), 3, "0")
        sc=String.slice(datetime, 17, 2)
        mn=String.slice(datetime, 5, 2)

        rval=:crypto.strong_rand_bytes(2)
        <<val1, val2>> = rval
        #IO.puts val1
        randval1= val1 |> Integer.to_string |> String.pad_leading(3, "0")
        randval2= val2 |> Integer.to_string |> String.pad_leading(3, "0")

        randval="#{randval1}#{randval2}"
        genId = "#{microsec}#{sc}#{mn}#{randval}"
        ##genId

        genId="#{genId}"#genId="#{Constant.trans_ref_prefix}#{genId}"

        record=case tbl do
            "FA"-> #Fund Allocation
                acme.Repo.get_by(acme.Schema.FundAlloc, [ref_id: genId])
            "MI"-> #Message ID
                acme.Repo.get_by(acme.Schema.MessageLog, [message_id: genId])
            "PR"->
                acme.Repo.get_by(acme.Schema.PaymentRequest, [processing_id: genId])
            "AI"->
                acme.Repo.get_by(acme.Schema.AccountInquiryReq, [processing_id: genId])
            _->
                nil
        end
        genID=if is_nil(record) do
            genId
        else
            gen_uniq_id(tbl)
        end
        genID
    end







    def gen_2fa_code do
      #reqID=gen_req_id()
        rval=:crypto.strong_rand_bytes(2)
        <<val1, val2>> = rval
        #IO.puts val1
        randval1= val1 |> Integer.to_string |> String.pad_leading(3, "0")
        randval2= val2 |> Integer.to_string |> String.pad_leading(3, "0")

        randval="#{randval1}#{randval2}"
        genId = "#{randval}"
        genId
    end


    def gen_pin do
        rval=:crypto.strong_rand_bytes(2)
        <<val1, val2>> = rval
        #IO.puts val1
        randval1= val1 |> Integer.to_string |> String.pad_leading(4, "0")

        randval=randval1
        genId = "#{randval}"
        genId
    end


    ##defp gen_id_exists?(genId) do
    ##    query=from(u in "payment_request",
    ##        where: u.processing_id==^genId,
    ##        select: u.processing_id) |> Tricklez.Repo.all

    ##    with _x =[_|_] <- query do true else _ -> false end
    ##end


    ##defp gen_2fa_code_exists?(genId) do
    ##    query=from(u in "pre_signup_info",
    ##        where: u.phone_number==^genId,
    ##        select: u.phone_number) |> Tricklez.Repo.all
    ##
    ##    with _x =[_|_] <- query do true else _ -> false end
    ##end


    def duplicate_id_exists?(exttrid) do
        query=from(u in "payment_request",
                  where: u.exttrid==^exttrid,
                  select: u.exttrid) |> acme.Repo.all

        with _x =[_|_] <- query do true else _ -> false end
    end


    @doc """
    ## Examples
        Return nine digits for the valid mobile number.
        An invalid number supplied will return false

        iex> Momo.BaseRoutines.formatPhone(msisdn)
    """
    def formatPhone(msisdn) do
      IO.puts "msisdn: #{msisdn}"
        msisdn2=
          msisdn
          |> String.slice(String.length(msisdn)-9, 9)

        if String.length(msisdn2)==9 do
            {:ok, msisdn2}
        else
            IO.puts "#{msisdn2}"
            {:error, false}
        end
    end


    def convert_ip(ip_tuple) do
        IO.puts "\nAttempting to retrieve remote IP\n"


        t_list=Tuple.to_list(ip_tuple)
        ip=Enum.join(t_list, ".")
        IO.puts "#{ip}\n"
        ip
    end


    def hash_string(str) do
        :crypto.hash(:sha256, str)
    end


    def customer_ip_info(ip) do
        if !is_nil(ip) do
            case GeoIP.lookup(ip) do
                {:ok, response}->
                    city=response.city
                    country_code=response.country_code
                    country_name=response.country_name
                    region_code=response.region_code
                    region_name=response.region_name

                    {:ok, %{country_code: country_code, country_name: country_name, region_code: region_code, region_name: region_name, city: city}}
                {:error, reason}->
                    IO.inspect reason
                    {:error, reason}
            end
        else
            {:error, Constant.err_failed_req()}
        end
    end

    def customer_ip_country_code(ip) do
        if !is_nil(ip) do
            case GeoIP.lookup(ip) do
                {:ok, response}->
                  #                    city=response.city
                    country_code=response.country_code
                    #                    country_name=response.country_name
                    #                    region_code=response.region_code
                    #                    region_name=response.region_name

                    country_code

                # {:ok, %{country_code: country_code, country_name: country_name, region_code: region_code, region_name: region_name, city: city}}
                {:error, reason}->
                    IO.inspect reason
                    {:error, reason}
            end
        else
            {:error, Constant.err_failed_req()}
        end
    end

    def get_currency_rate(ip) do
        if !is_nil(ip) do
            case GeoIP.lookup(ip) do
                {:ok, response}->
                  #                    city=response.city
                    country_code=response.country_code
                    #                    country_name=response.country_name
                    #                    region_code=response.region_code
                    #                    region_name=response.region_name

                    currency=case country_code do
                        "GH" ->
                            "GHS"
                        _ ->
                            "USD"
                    end

                    currency

                # {:ok, %{country_code: country_code, country_name: country_name, region_code: region_code, region_name: region_name, city: city}}
                {:error, reason}->
                    IO.inspect reason
                    {:error, reason}
            end
        else
            {:error, Constant.err_failed_req()}
        end
    end


end








defmodule acme.Email do
    import Bamboo.Email


    def send_email(params \\ %{}) do
        if !is_nil(params) do
            from_addr=params[:from_addr]
            to_addr=params[:to_addr]
            subj=params[:subj]
            text_body=params[:msg_body]


            new_email(
                from: from_addr,
                to: to_addr,
                subject: subj,
                text_body: text_body,
                html_body: text_body
            )
        end
    end


    def send_email_with_attachment(params \\ %{}) do
        if !is_nil(params) do
            from_addr=params[:from_addr]
            to_addr=params[:to_addr]
            subj=params[:subj]
            text_body=params[:msg_body]
            attachment=params[:attachment]

            new_email()
            |> to(to_addr)
            |> from(from_addr)
            |> subject(subj)
            |> text_body(text_body)
            |> html_body(text_body)
            |> put_attachment(attachment)
        end
    end


  #def send_email_with_attachment() do
  #    #content = <<binary-content>>
  #    #File.write("/tmp/myfile.pdf", content )

  #    new_email()
  #        |> to("jerry@quodesolutions.com")
  #        |> from("test@quodesolutions.com")
  #        |> subject("Testing attachment")
  #        |> text_body("Testing an attachment")
  #        |> html_body("Testing an attachment here")
  #        |> put_attachment("/home/jerry/mytmpdir/Zeco_test_upload1.csv")
  #end

end



defmodule acme.GenerateRandChars do
    ##chars = 'CDEFGHJKLMNPQRTUVWXYZ23679'
    chars = '12345678912345678912345678'

    @chars List.to_tuple(chars)

    def generate() do
      0
      |> generate()
      |> IO.iodata_to_binary()
    end

    #def generate(n) when n in [5, 11, 17] do
    #  [?- | generate(n + 1)]
    #end

    def generate(n) when n in [14] do
      [?- | generate(n + 1)]
    end

    def generate(n) when n > 20 do
      []
    end

    def generate(n) do
      [elem(@chars, :rand.uniform(26) - 1) | generate(n + 1)]
    end
end


defmodule acme.Vault do
    use Cloak.Vault, otp_app: :acme
end
