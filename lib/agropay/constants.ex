defmodule acme.Constant do

    ####################################### JSON Response Messages ###########################################
    ##########################################################################################################

    @err_return_success %{resp_code: "000", resp_desc: "Successful"}
    @err_return_failure %{resp_code: "001", resp_desc: "Failure"}
    @err_no_record_found %{resp_code: "002", resp_desc: "No record found"}
    @err_missing_shortcodeext %{resp_code: "003", resp_desc: "Missing Short Code Extension"}
    @err_invalid_shortcodeext %{resp_code: "004", resp_desc: "Invalid Short Code Extension format"}
    @err_missing_customer_type %{resp_code: "005", resp_desc: "Missing Customer Type"}
    @err_invalid_customer_type %{resp_code: "006", resp_desc: "Invalid Customer Type"}
    @err_alloc_amount_greater %{resp_code: "007", resp_desc: "Sorry, the amount to be allocated cannot be more than the entity's balance."}
    @err_invalid_customer_firstname %{resp_code: "008", resp_desc: "Invalid Customer Type"}
    @err_missing_customer_middlename %{resp_code: "009", resp_desc: "Missing Customer Middle name"}
    @err_invalid_customer_middlename %{resp_code: "010", resp_desc: "Invalid Customer Middle name"}
    @err_missing_customer_lastname %{resp_code: "011", resp_desc: "Missing Customer Last name"}
    @err_invalid_customer_lastname %{resp_code: "012", resp_desc: "Invalid Customer Last name"}
    @err_missing_customer_name %{resp_code: "013", resp_desc: "Missing Customer name"}
    @err_invalid_customer_name %{resp_code: "014", resp_desc: "Invalid Customer name"}
    @err_missing_gender %{resp_code: "015", resp_desc: "Missing Gender"}
    @err_invalid_gender %{resp_code: "016", resp_desc: "Invalid Gender"}
    @err_missing_login_src %{resp_code: "017", resp_desc: "Missing login source in request"}
    @err_incorrect_oldpin_src %{resp_code: "018", resp_desc: "Secret PIN is incorrect"}
    @err_success_changepin %{resp_code: "019", resp_desc: "Your PIN has been changed successfully."}
    @err_success_cust_record_save %{resp_code: "020", resp_desc: "Your account has been created successfully."}
    @err_failure_cust_pin_save %{resp_code: "021", resp_desc: "Pin details could not be created."}
    @err_failure_cust_record_save %{resp_code: "022", resp_desc: "Customer records could not be created."}
    @err_contacts_not_found %{resp_code: "023", resp_desc: "Contact details not found"}
    @err_approver_notice_completed %{resp_code: "024", resp_desc: "All approvers for the provided transaction have been notified successfully."}
    @err_customer_not_registered %{resp_code: "025", resp_desc: "Customer has not registered."}
    @err_customer_not_activated %{resp_code: "026", resp_desc: "Customer info is not activated."}
    @err_customer_pin_empty %{resp_code: "027", resp_desc: "Customer PIN details is empty."}
    @err_customer_defaultpin_notchanged %{resp_code: "028", resp_desc: "Default PIN not changed. Kindly change your PIN now."}
    @err_secretpin_match %{resp_code: "029", resp_desc: "Secret PIN is a match"}
    @err_empty_endpoint_url %{resp_code: "030", resp_desc: "Missing Endpoint URL in request"}
    @err_missing_params %{resp_code: "031", resp_desc: "Missing params in request"}
    @err_missing_countrycode %{resp_code: "032", resp_desc: "Missing Country code in request"}
    @err_missing_email %{resp_code: "033", resp_desc: "Missing Email in request"}
    @err_invalid_email %{resp_code: "034", resp_desc: "Invalid Email in request"}
    @err_missing_landing_url %{resp_code: "035", resp_desc: "Missing Landing URL in request"}
    @err_missing_src %{resp_code: "036", resp_desc: "Missing Source in request"}
    @err_invalid_src %{resp_code: "037", resp_desc: "Invalid Source"}
    @err_shortcode_notfound %{resp_code: "038", resp_desc: "No record found for this service code. Please check the short code and dial again."}
    @err_missing_servicekeys %{resp_code: "039", resp_desc: "Missing Service Keys."}
    @err_undefined_trans_type %{resp_code: "040", resp_desc: "Undefined transaction type in request"}
    @err_missing_trans_type %{resp_code: "041", resp_desc: "Missing transaction type in request"}
    @err_missing_vod_voucher %{resp_code: "042", resp_desc: "Vodafone voucher code not provided"}
    @err_empty_approvers_list %{resp_code: "043", resp_desc: "There are no Approvers under the provided config type."}
    @err_invalid_cust_no %{resp_code: "044", resp_desc: "Invalid customer number"}
    @err_missing_nw %{resp_code: "045", resp_desc: "Transaction network missing in request"}
    @err_missing_payment_class %{resp_code: "046", resp_desc: "Payment classification missing in request"}
    @err_missing_ref_code %{resp_code: "047", resp_desc: "Reference code missing in request"}
    @err_missing_payment_med %{resp_code: "048", resp_desc: "Missing payment medium in request"}
    @err_amount_zero %{resp_code: "049", resp_desc: "Amount cannot be less than zero"}
    @err_success_req_received %{resp_code: "050", resp_desc: "Request successfully received for processing"}
    @err_missing_cust_no %{resp_code: "051", resp_desc: "Missing customer number"}
    @err_missing_customer_id %{resp_code: "052", resp_desc: "Missing Customer ID"}
    @err_invalid_customer_id %{resp_code: "053", resp_desc: "Invalid Customer ID"}
    @err_missing_payment_type %{resp_code: "054", resp_desc: "Missing Payment Type"}
    @err_invalid_payment_type %{resp_code: "055", resp_desc: "Invalid Payment Type"}
    @err_missing_payee %{resp_code: "056", resp_desc: "Missing Payee"}
    @err_unassigned_service_code %{resp_code: "057", resp_desc: "This service code has not been assigned to an institution. Please contact the administrator."}
    @err_missing_session_id %{resp_code: "058", resp_desc: "Missing Session ID in Request"}
    @err_missing_student_name %{resp_code: "059", resp_desc: "Missing Student Name in Request"}
    @err_transaction_statement_sent %{resp_code: "060", resp_desc: "Your Request for Transaction Statement has been received and is being processed. You will receive an email with the transaction statements shortly."}
    @err_payinitiator_record_empty %{resp_code: "061", resp_desc: "Pay Initiator record not found."}
    @err_empty_entity_record %{resp_code: "062", resp_desc: "No record found for the provided entity code"}
    @err_service_charge_empty %{resp_code: "063", resp_desc: "Service Charge is empty."}
    @err_missing_service_account %{resp_code: "064", resp_desc: "We run into a problem with your wallet. Please contact the administrator for assistance."}
    @err_undefined_rem_wallet %{resp_code: "065", resp_desc: "Undefined remote wallet in request"}
    @err_payment_req_received %{resp_code: "066", resp_desc: "Your payment request has been received for processing. You will be notified by SMS when its completed."}
    @err_invalid_service_main_id %{resp_code: "067", resp_desc: "Invalid Service Main ID"}
    @err_missing_lastname %{resp_code: "068", resp_desc: "Missing/Invalid Last name"}
    @err_missing_firstname %{resp_code: "069", resp_desc: "Missing/Invalid First name"}
    @err_missing_beneficiary_accnt %{resp_code: "070", resp_desc: "Beneficiary account cannot be found. Please check the beneficiary's number and enter again."}
    @err_missing_password %{resp_code: "071", resp_desc: "Missing Password"}
    @err_invalid_password %{resp_code: "072", resp_desc: "Invalid Password"}
    @err_qr_reset_success %{resp_code: "073", resp_desc: "Your QR has been reset."}
    @err_trans_statement_success %{resp_code: "074", resp_desc: "Your request has been received for processing. You will receive an email shortly."}
    @err_missing_vehicle_id %{resp_code: "075", resp_desc: "Missing Vehicle Information in request"}
    @err_missing_operator_id %{resp_code: "076", resp_desc: "Missing Operator Information in request"}
    @err_success_pinrest %{resp_code: "077", resp_desc: "PIN reset was successful."}
    @err_success_email_change %{resp_code: "078", resp_desc: "Email change was successful"}
    @err_balance_threshold_empty %{resp_code: "079", resp_desc: "Customer Balance Threshold not set"}
    @err_missing_user_id %{resp_code: "080", resp_desc: "Missing or invalid User ID"}
    @err_missing_entity_code %{resp_code: "081", resp_desc: "Missing or invalid Entity code"}
    @err_missing_pay_initiator_code %{resp_code: "082", resp_desc: "Missing or invalid Pay Initiator details"}
    @err_duplicate_email %{resp_code: "083", resp_desc: "Email address already exists. Please enter a different email address"}
    @err_no_intiator_account %{resp_code: "084", resp_desc: "No pay initiator account record found."}
    @err_pay_intiator_account_zero %{resp_code: "085", resp_desc: "You have zero balance in your account. Please contact your admin for money to be allocated to you."}
    @err_missing_operator_info_id %{resp_code: "086", resp_desc: "Missing Operator Info ID in request"}
    @err_missing_routes_main_id %{resp_code: "087", resp_desc: "Missing Routes ID in request"}
    @err_succ_operator_route_assign %{resp_code: "088", resp_desc: "You have successfully assigned the route to this operator."}
    @err_missing_route_main_id %{resp_code: "089", resp_desc: "Missing Route in request"}
    @err_missing_qty %{resp_code: "090", resp_desc: "Missing quantity in request"}
    @err_success_ticket_sent %{resp_code: "091", resp_desc: "Your ticket has been sent to you successfully."}
    @err_missing_enable_route %{resp_code: "092", resp_desc: "Enable Route is missing in this request"}
    @err_invalid_enable_route %{resp_code: "093", resp_desc: "Enable Route is invalid in this request"}
    @err_qr_not_scanned %{resp_code: "094", resp_desc: "Your Ticket has not yet been scanned."}
    @err_qr_scan_duplicate %{resp_code: "095", resp_desc: "Your Ticket has already been scanned."}
    @err_missing_ticket_trans_type %{resp_code: "096", resp_desc: "Missing Ticket's Transcation Type in request"}
    @err_undefined_ticket_trans_type %{resp_code: "097", resp_desc: "Undefined Ticket transaction type in request"}
    @err_user_aboard %{resp_code: "098", resp_desc: "Ticket verified successfully"}
    @err_invalid_req_format %{resp_code: "099", resp_desc: "Invalid request format"}
    @err_forbidden_ip  %{resp_code: "100", resp_desc: "You are not allowed to use this service"}
    @err_no_auth_header %{resp_code: "101", resp_desc: "No Authorization header information"}
    @err_invalid_token %{resp_code: "102", resp_desc: "Invalid tokens received"}
    @err_invalid_signature %{resp_code: "103", resp_desc: "Invalid signature"}
    @err_duplicate_txn %{resp_code: "104", resp_desc: "Duplicate transaction"}
    @err_invalid_phone %{resp_code: "105", resp_desc: "Invalid phone number"}
    @err_invalid_surname %{resp_code: "106", resp_desc: "Invalid Surname"}
    @err_invalid_othernames %{resp_code: "107", resp_desc: "Invalid Other Names"}
    @err_missing_auth_code %{resp_code: "108", resp_desc: "Auth code not supplied"}
    @err_cashout_req_recieved %{resp_code: "109", resp_desc: "Your cashout request has been received for processing."}
    @err_customer_found %{resp_code: "110", resp_desc: "Customer record exists"}
    @err_auth_code_valid %{resp_code: "111", resp_desc: "Authentication code validated"}
    @err_success_req %{resp_code: "112", resp_desc: "Request successfully completed"}
    @err_failed_req %{resp_code: "113", resp_desc: "Request could not be processed successfully"}
    @err_invalid_auth_code %{resp_code: "114", resp_desc: "Authentication code invalid"}
    @err_trans_id_too_long %{resp_code: "115", resp_desc: "Unique external transaction identifier too long"}
    @err_success_qrscan %{resp_code: "116", resp_desc: "QR Scan was successful"}
    @err_missing_pin %{resp_code: "117", resp_desc: "Missing PIN in request"}
    @err_invalid_pin %{resp_code: "118", resp_desc: "Your PIN is incorrect."}
    @err_missing_username %{resp_code: "119", resp_desc: "Missing username in request"}
    @err_missing_secret_pin %{resp_code: "120", resp_desc: "Missing secret pin"}
    @err_invalid_secret_pin %{resp_code: "120", resp_desc: "Secret pin / Password invalid"}
    @err_unknown_route %{resp_code: "121", resp_desc: "Unknown request route"}
    # @err_missing_src %{resp_code: "122", resp_desc: "Missing src identifier"}
    @err_success_login %{resp_code: "123", resp_desc: "Success login"}
    @err_failed_login %{resp_code: "124", resp_desc: "Invalid username/password. Please try again."}
    @err_insufficient_bal %{resp_code: "125", resp_desc: "Insufficient balance"}
    @err_missing_customer_id %{resp_code: "126", resp_desc: "Missing customer identifier"}
    @err_invalid_customer_id %{resp_code: "127", resp_desc: "Invalid customer identifier"}
    @err_customer_exists %{resp_code: "128", resp_desc: "customer details already exist"}
    @err_invalid_req_amount %{resp_code: "129", resp_desc: "Invalid amount specified in request"}
    @err_missing_amount %{resp_code: "130", resp_desc: "Missing request amount"}
    @err_missing_qty %{resp_code: "131", resp_desc: "Missing request quantity"}
    @err_invalid_qty %{resp_code: "132", resp_desc: "Invalid quantity specified in request"}
    @err_wrong_pin %{resp_code: "133", resp_desc: "Invalid PIN. Please try again."}
    @err_duplicate_operator_info %{resp_code: "134", resp_desc: "This vehicle has already been assigned to the operator."}
    @err_duplicate_operator_assigned_route %{resp_code: "135", resp_desc: "This operator or route already exists"}
    @err_succ_operator_assigned_route %{resp_code: "136", resp_desc: "This record has been created successfully."}
    @err_empty_operator_routes %{resp_code: "137", resp_desc: "Sorry, there's no route available for you."}
    @err_missing_wallet_number %{resp_code: "138", resp_desc: "Missing Wallet number in request"}
    @err_invalid_wallet_no %{resp_code: "139", resp_desc: "Please provide a valid wallet number"}
    @duplicate_username %{resp_code: "140", resp_desc: "Username already taken"}
    @err_succ_reversal %{resp_code: "141", resp_desc: "The reversal was successful."}
    @err_missing_assigned_code %{resp_code: "142", resp_desc: "Assigned code missing in request"}
    @err_missing_request_input %{resp_code: "143", resp_desc: "Missing parameters in request"}
    @err_empty_operator_route_rec %{resp_code: "144", resp_desc: "Operator's route record cannot be found"}
    @err_succ_payout %{resp_code: "145", resp_desc: "Your payout was successful."}
    @err_missing_charge %{resp_code: "146", resp_desc: "Missing transaction charge in request"}
    @err_invalid_req_charge %{resp_code: "147", resp_desc: "Invalid transaction charge"}
    @err_missing_rate %{resp_code: "148", resp_desc: "Rate not set for entity division"}
    @err_invalid_qr_txt %{resp_code: "149", resp_desc: "Invalid QR unique code"}
    @err_missing_qr_txt %{resp_code: "150", resp_desc: "Missing QR unique code"}
    @err_fund_alloc_received %{resp_code: "151", resp_desc: "The funds allocation request has been received for processing."}
    @err_missing_ref_id %{resp_code: "152", resp_desc: "Missing ref ID in request"}
    @err_missing_approval_status %{resp_code: "153", resp_desc: "Missing approval status in request"}
    @err_fund_approved %{resp_code: "154", resp_desc: "This fund has been approved."}
    @err_auth_cycle_not_found %{resp_code: "155", resp_desc: "No record for this authorizer"}
    @err_invalid_payment_data %{resp_code: "156", resp_desc: "Invalid Payment data in request"}
    @err_empty_pending_approval %{resp_code: "157", resp_desc: "There is no pending fund to be approved."}
    @err_duplicate_approval %{resp_code: "158", resp_desc: "This authorizer has already approved this transaction"}
    @err_missing_appr_reason %{resp_code: "159", resp_desc: "Missing approval reason in request"}
    @err_missing_initiator_default_product %{resp_code: "160", resp_desc: "Pay initiator default product not set. Please contact the administrator"}
    @err_missing_product_code %{resp_code: "161", resp_desc: "Missing product details in request"}
    @err_missing_payment_mode %{resp_code: "162", resp_desc: "Missing payment mode in request"}
    @err_missing_pan %{resp_code: "163", resp_desc: "Primary account number required"}
    @err_missing_metric_unit_code %{resp_code: "164", resp_desc: "Metrics record not available for this product. Please contact the amdinistrator."}
    @err_missing_beneficiary_code %{resp_code: "165", resp_desc: "Beneficiary code is required"}
    @err_missing_fund_details %{resp_code: "166", resp_desc: "Fund does not exist"}
    @err_missing_purchase_season_id %{resp_code: "167", resp_desc: "Missing Purchase season in request"}
    @err_success_ben_repays_computed %{resp_code: "168", resp_desc: "Beneficiary repays calculated successfully"}
    @err_success_fund_approval %{resp_code: "169", resp_desc: "This fund allocation has been approved successfully"}
    @err_missing_fund_allocation_record %{resp_code: "170", resp_desc: "Allocation record cannot be found."}
    @err_fund_disapproved %{resp_code: "171", resp_desc: "This fund has been disapproved."}


    #################################################   VALIDATION/CHECKLIST ERROR CODES #######################################################
    @err_val_missing_service_code %{resp_code: "200", resp_desc: "Service code has not been setup for this institution. Plese check and try again."}
    @err_val_missing_wallet_setup %{resp_code: "201", resp_desc: "Entity's wallet has not been set. Plese check and try again."}
    @err_val_missing_assigned_fee_setup %{resp_code: "202", resp_desc: "Entity's fees have not been set. Plese check and try again."}
    @err_val_missing_approver_list_setup %{resp_code: "203", resp_desc: "Entity's approver list has not been setup. Please setup at least one approver and try again."}
    @err_val_product_metric_setup %{resp_code: "204", resp_desc: "Product pricing unavailable for the provided entity. Plese check and try again."}
    @err_val_pay_intiator_setup %{resp_code: "205", resp_desc: "No Pay Initiator has been setup for this entity. Plese check and try again."}
    @err_val_entity_intiator_products_setup %{resp_code: "206", resp_desc: "No intiator product set for this entity. Plese check and try again."}
    @err_setup_validation_passed %{resp_code: "207", resp_desc: "all validations passed"}
    @err_val_entity_ben_acc_info_setup %{resp_code: "208", resp_desc: "No beneficiary account info has been setup for the provided entity"}




    #################################################   VALIDATION/CHECKLIST ERROR CODES #######################################################




    ##############################################################################################################
    ##############################################################################################################
    @app_name "acme"
    @app_nickname "acme Service"
    @operator_assigned_code "OPT"
    @secret_pin_length 4
    @debit_trans_type "DR"
    @trans_ref_prefix "AGP"
    @str_sms_sender_id "acme"
    @client_key "JYAX4rhY3FI3LtzFwKGoVdnAMOkH3a51hAu3TdHv0cYiCTD4AjqqecZTzdgFjRcuDlGSEnhZQ2HC5BobsHLERQ=="#"zMNAbBiwpB+IhcE0LE+pYLunbQ4clfyEjg96vHXZWxCfH9wBpUWFcHPpdO/0obLjkjg1D2Xpd1s+YiBWa6f3bQ=="
    @secret_key "Na+oh2ElZk3fDy3kKQItvXm0L+9vZ5j2cPfTX2/bLpFnDZOOxhINR4ouc0kBinwZSeX/68eHkPvwByMhNx7raw=="#"4hk/az8BJyz7KOMIhP+hGy8+gMnkE3AVronwOdAVJwI/d+3jrzdDxYkF1YUKkoWaQ1Is1imBc+i3MjALDsVSsQ=="
    @service_id "1"#"385"
    @sms_api_key "3Xh9rdDWF4ef1ho7z3dGMOYP24b7pLzN5C8qrF3O80kdgqWh162rUGZOQ4xzhVQMDGFmIB1laXRzzDBzafAjPA=="
    @timeout 80_000
    @header_str ["Content-Type": "application/json"]
    @Manor_base_ip "http://10.136.77.134:8218"
    @Manor_url "http://10.136.77.134:8218/sendRequest"
    @Manor_account_inquiry_url "http://10.136.77.134:7016/accountInquiry"
    @cards_Manor_url "http://10.136.77.134:8316/third_party_request"
    @check_wallet_balance_url "http://10.136.77.134:8218/check_wallet_balance"
    @check_trans_status_Manor_url "http://10.136.77.134:8218/checkTransaction"
    @sms_url "http://10.136.77.134:8218/sendSms"
    @header2 ["Content-Type": "text/xml; charset=UTF-8"]
    @header3 ["Content-Type": "application/xml"]

    @callback_url "http://10.136.77.134:8333/req_callback_acme"
    @cards_callback_url "http://10.136.77.134:8333/req_callback_acme"
    @cards_landing_page_url "https://quodesolutions.com"

    @success_resp_code "000"
    @success_resp_desc "Successful"
    @failure_resp_code "999"
    @failure_resp_desc "Failure"
    @customer_balance_threshold_code "CUST_BAL_THD"

    @developer_email "padmore@quodesolutions.com"

    @developer_mobile_number1 "233541840988"
    @developer_mobile_number2 "233266000350"



    ###### Pre-defined length constants ####
    @exttrid_len 30
    @reference_len 50
    @timestamp_dur 5
    ########################################
    @from_email "acme@quodesolutions.com"
    @from_name "acme"
    @contact_email "support@quodesolutions.com"
    @slogan "acme"
    @team_name "acme Team"
    @support_contact_tel "(+233) 0302 502 257, (+233) 0302 955 701"

    @payment_ref "acme Topup"
    @payment_ref_vip "acme Ticket"
    @ticket_refund_customer_ref "acme Refund"
    @ticket_cashout_ref "acme Cashout"

    def app_name, do: @app_name
    def team_name, do: @team_name
    def app_nickname, do: @app_nickname
    def operator_assigned_code, do: @operator_assigned_code
    def customer_balance_threshold_code, do: @customer_balance_threshold_code
    def secret_pin_length, do: @secret_pin_length
    def debit_trans_type, do: @debit_trans_type
    def client_key, do: @client_key
    def secret_key, do: @secret_key
    def service_id, do: @service_id
    def sms_api_key, do: @sms_api_key
    def header_str, do: @header_str
    def Manor_base_ip, do: @Manor_base_ip
    def Manor_url, do: @Manor_url
    def Manor_account_inquiry_url, do: @Manor_account_inquiry_url
    def check_trans_status_Manor_url, do: @check_trans_status_Manor_url
    def check_wallet_balance_url, do: @check_wallet_balance_url
    def cards_Manor_url, do: @cards_Manor_url
    def sms_url, do: @sms_url
    def header2, do: @header2
    def header3, do: @header3
    def err_missing_user_id, do: @err_missing_user_id
    def err_succ_reversal, do: @err_succ_reversal




    def payment_ref, do: @payment_ref
    def payment_ref_vip, do: @payment_ref_vip
    def ticket_refund_customer_ref, do: @ticket_refund_customer_ref
    def ticket_cashout_ref, do: @ticket_cashout_ref
    def trans_ref_prefix, do: @trans_ref_prefix
    def callback_url, do: @callback_url
    def cards_callback_url, do: @cards_callback_url
    def cards_landing_page_url, do: @cards_landing_page_url
    def developer_email, do: @developer_email
    def developer_mobile_number1, do: @developer_mobile_number1
    def developer_mobile_number2, do: @developer_mobile_number2
    def err_incorrect_oldpin_src, do: @err_incorrect_oldpin_src
    def err_contacts_not_found, do: @err_contacts_not_found
    def err_customer_not_registered, do: @err_customer_not_registered
    def err_customer_not_activated, do: @err_customer_not_activated
    def err_customer_pin_empty, do: @err_customer_pin_empty
    def err_customer_defaultpin_notchanged, do: @err_customer_defaultpin_notchanged
    def err_secretpin_match, do: @err_secretpin_match
    def err_empty_endpoint_url, do: @err_empty_endpoint_url
    def err_missing_params, do: @err_missing_params
    def err_missing_landing_url, do: @err_missing_landing_url

    def err_missing_customer_id, do: @err_missing_customer_id
    def err_invalid_customer_id, do: @err_invalid_customer_id
    def err_missing_payment_type, do: @err_missing_payment_type
    def err_invalid_payment_type, do: @err_invalid_payment_type
    def err_missing_payee, do: @err_missing_payee
    def err_unassigned_service_code, do: @err_unassigned_service_code
    def err_missing_session_id, do: @err_missing_session_id
    def err_missing_student_name, do: @err_missing_student_name
    def err_transaction_statement_sent, do: @err_transaction_statement_sent
    def err_missing_password, do: @err_missing_password
    def err_invalid_password, do: @err_invalid_password
    def err_payinitiator_record_empty, do: @err_payinitiator_record_empty
    def err_empty_entity_record, do: @err_empty_entity_record
    def err_service_charge_empty, do: @err_service_charge_empty
    def err_balance_threshold_empty, do: @err_balance_threshold_empty
    def err_missing_service_account, do: @err_missing_service_account
    def err_success_qrscan, do: @err_success_qrscan
    def err_qr_reset_success, do: @err_qr_reset_success
    def err_trans_statement_success, do: @err_trans_statement_success
    def err_success_pinrest, do: @err_success_pinrest
    def err_success_email_change, do: @err_success_email_change
    def err_invalid_service_main_id, do: @err_invalid_service_main_id
    def err_missing_entity_code, do: @err_missing_entity_code
    def err_missing_pay_initiator_code, do: @err_missing_pay_initiator_code
    def err_duplicate_email, do: @err_duplicate_email
    def err_duplicate_operator_info, do: @err_duplicate_operator_info
    def err_no_intiator_account, do: @err_no_intiator_account
    def err_duplicate_operator_assigned_route, do: @err_duplicate_operator_assigned_route
    def err_succ_operator_assigned_route, do: @err_succ_operator_assigned_route
    def err_missing_route_main_id, do: @err_missing_route_main_id
    def err_missing_qty, do: @err_missing_qty
    def err_success_ticket_sent, do: @err_success_ticket_sent
    def err_missing_enable_route, do: @err_missing_enable_route
    def err_invalid_enable_route, do: @err_invalid_enable_route
    def err_empty_operator_route_rec, do: @err_empty_operator_route_rec
    def err_qr_not_scanned, do: @err_qr_not_scanned
    def err_qr_scan_duplicate, do: @err_qr_scan_duplicate
    def err_missing_ticket_trans_type, do: @err_missing_ticket_trans_type
    def err_undefined_ticket_trans_type, do: @err_undefined_ticket_trans_type
    def err_user_aboard, do: @err_user_aboard
    def err_cashout_req_recieved, do: @err_cashout_req_recieved
    def err_succ_payout, do: @err_succ_payout
    def err_missing_rate, do: @err_missing_rate
    def err_missing_charge, do: @err_missing_charge
    def err_invalid_req_charge, do: @err_invalid_req_charge
    def err_missing_ref_id, do: @err_missing_ref_id
    def err_missing_approval_status, do: @err_missing_approval_status
    def err_fund_approved, do: @err_fund_approved
    def err_auth_cycle_not_found, do: @err_auth_cycle_not_found
    def err_invalid_payment_data, do: @err_invalid_payment_data
    def err_empty_pending_approval, do: @err_empty_pending_approval
    def err_duplicate_approval, do: @err_duplicate_approval
    def err_missing_appr_reason, do: @err_missing_appr_reason
    def err_missing_initiator_default_product, do: @err_missing_initiator_default_product
    def err_missing_product_code, do: @err_missing_product_code
    def err_missing_payment_mode, do: @err_missing_payment_mode
    def err_missing_metric_unit_code, do: @err_missing_metric_unit_code
    def err_missing_beneficiary_code, do: @err_missing_beneficiary_code
    def err_missing_purchase_season_id, do: @err_missing_purchase_season_id
    def err_success_ben_repays_computed, do: @err_success_ben_repays_computed
    def err_success_fund_approval, do: @err_success_fund_approval
    def err_missing_fund_allocation_record, do: @err_missing_fund_allocation_record
    def err_missing_fund_details, do: @err_missing_fund_details
    def err_missing_pan, do: @err_missing_pan

    def err_val_missing_service_code, do: @err_val_missing_service_code
    def err_val_missing_wallet_setup, do: @err_val_missing_wallet_setup
    def err_val_missing_assigned_fee_setup, do: @err_val_missing_assigned_fee_setup
    def err_val_missing_approver_list_setup, do: @err_val_missing_approver_list_setup
    def err_val_product_metric_setup, do: @err_val_product_metric_setup
    def err_val_pay_intiator_setup, do: @err_val_pay_intiator_setup
    def err_val_entity_intiator_products_setup, do: @err_val_entity_intiator_products_setup
    def err_setup_validation_passed, do: @err_setup_validation_passed
    def err_val_entity_ben_acc_info_setup, do: @err_val_entity_ben_acc_info_setup



    #################################### JSON Response Message Functions ##########################################
    ###############################################################################################################
    def err_return_success, do: @err_return_success
    def err_return_failure, do: @err_return_failure
    def err_missing_shortcodeext, do: @err_missing_shortcodeext
    def err_invalid_shortcodeext, do: @err_invalid_shortcodeext
    def err_payment_req_received, do: @err_payment_req_received
    def err_invalid_plan_id, do: @err_invalid_plan_id
    def err_missing_src, do: @err_missing_src
    def err_invalid_src, do: @err_invalid_src
    def err_success_req_received, do: @err_success_req_received
    def err_shortcode_notfound, do: @err_shortcode_notfound
    def err_missing_servicekeys, do: @err_missing_servicekeys
    def err_undefined_trans_type, do: @err_undefined_trans_type
    def err_missing_trans_type, do: @err_missing_trans_type
    def err_missing_vod_voucher, do: @err_missing_vod_voucher
    def err_empty_approvers_list, do: @err_empty_approvers_list
    def err_invalid_cust_no, do: @err_invalid_cust_no
    def err_missing_nw, do: @err_missing_nw
    def err_missing_payment_class, do: @err_missing_payment_class
    def err_missing_ref_code, do: @err_missing_ref_code
    def err_amount_zero, do: @err_amount_zero
    def from_email, do: @from_email
    def from_name, do: @from_name
    def contact_email, do: @contact_email
    def slogan, do: @slogan
    def support_contact_tel, do: @support_contact_tel
    def err_missing_cust_no, do: @err_missing_cust_no
    def err_missing_payment_med, do: @err_missing_payment_med
    def err_missing_email, do: @err_missing_email
    def err_invalid_email, do: @err_invalid_email
    def err_missing_beneficiary_accnt, do: @err_missing_beneficiary_accnt

    def err_undefined_rem_wallet, do: @err_undefined_rem_wallet

    def err_missing_login_src, do: @err_missing_login_src
    def err_invalid_req_format, do: @err_invalid_req_format
    def err_forbidden_ip, do: @err_forbidden_ip
    def err_no_auth_header, do: @err_no_auth_header
    def err_invalid_token, do: @err_invalid_token
    def err_invalid_signature, do: @err_invalid_signature
    def err_duplicate_txn, do: @err_duplicate_txn
    def err_invalid_phone, do: @err_invalid_phone
    def err_invalid_surname, do: @err_invalid_surname
    def err_invalid_othernames, do: @err_invalid_othernames
    def err_missing_auth_code, do: @err_missing_auth_code
    def err_approver_notice_completed, do: @err_approver_notice_completed
    def err_customer_found, do: @err_customer_found
    def err_auth_code_valid, do: @err_auth_code_valid
    def err_success_req, do: @err_success_req
    def err_failed_req, do: @err_failed_req
    def err_invalid_auth_code, do: @err_invalid_auth_code
    def err_trans_id_too_long, do: @err_trans_id_too_long
    def err_no_record_found, do: @err_no_record_found
    def err_missing_pin, do: @err_missing_pin
    def err_invalid_pin, do: @err_invalid_pin
    def err_missing_username, do: @err_missing_username
    def err_missing_secret_pin, do: @err_missing_secret_pin
    def err_invalid_secret_pin, do: @err_invalid_secret_pin
    def err_unknown_route, do: @err_unknown_route
#    def err_missing_src, do: @err_missing_src
    def err_success_login, do: @err_success_login
    def err_failed_login, do: @err_failed_login
    def err_insufficient_bal, do: @err_insufficient_bal
    def err_missing_customer_id, do: @err_missing_customer_id
    def err_invalid_customer_id, do: @err_invalid_customer_id
    def err_customer_exists, do: @err_customer_exists
    def err_invalid_req_amount, do: @err_invalid_req_amount
    def err_missing_amount, do: @err_missing_amount
    def err_missing_qty, do: @err_missing_qty
    def err_invalid_qty, do: @err_invalid_qty
    def err_success_changepin, do: @err_success_changepin
    def err_success_cust_record_save, do: @err_success_cust_record_save
    def err_failure_cust_pin_save, do: @err_failure_cust_pin_save
    def err_failure_cust_record_save, do: @err_failure_cust_record_save
    def err_missing_lastname, do: @err_missing_lastname
    def err_missing_firstname, do: @err_missing_firstname
    def err_wrong_pin, do: @err_wrong_pin
    def err_fund_alloc_received, do: @err_fund_alloc_received
    def err_fund_disapproved, do: @err_fund_disapproved
    # def err_missing_gift_msg, do: @err_missing_gift_msg
    # def err_missing_gift_id, do: @err_missing_gift_id
    # def err_missing_gift_sender, do: @err_missing_gift_sender
    # def err_missing_gift_extra_data, do: @err_missing_gift_extra_data
    ##def missing_username, do: @missing_username
    def err_duplicate_username, do: @duplicate_username
    # def err_missing_driving_school_id, do: @err_missing_driving_school_id
    def err_missing_assigned_code, do: @err_missing_assigned_code
    def err_missing_request_input, do: @err_missing_request_input
    def timeout, do: @timeout
    def success_resp_code, do: @success_resp_code
    def success_resp_desc, do: @success_resp_desc
    def failure_resp_code, do: @failure_resp_code
    def failure_resp_desc, do: @failure_resp_desc
    def err_missing_customer_type, do: @err_missing_customer_type
    def err_invalid_customer_type, do: @err_invalid_customer_type
    def err_alloc_amount_greater, do: @err_alloc_amount_greater
    def err_invalid_customer_firstname, do: @err_invalid_customer_firstname
    def err_missing_customer_middlename, do: @err_missing_customer_middlename
    def err_invalid_customer_middlename, do: @err_invalid_customer_middlename
    def err_missing_customer_lastname, do: @err_missing_customer_lastname
    def err_invalid_customer_lastname, do: @err_invalid_customer_lastname
    def err_missing_customer_name, do: @err_missing_customer_name
    def err_invalid_customer_name, do: @err_invalid_customer_name
    def err_missing_gender, do: @err_missing_gender
    def err_invalid_gender, do: @err_invalid_gender
    def err_missing_countrycode, do: @err_missing_countrycode
    def err_missing_vehicle_id, do: @err_missing_vehicle_id
    def err_missing_operator_id, do: @err_missing_operator_id
    def err_pay_intiator_account_zero, do: @err_pay_intiator_account_zero
    def err_missing_operator_info_id, do: @err_missing_operator_info_id
    def err_missing_routes_main_id, do: @err_missing_routes_main_id
    def err_succ_operator_route_assign, do: @err_succ_operator_route_assign
    def err_empty_operator_routes, do: @err_empty_operator_routes
    def err_missing_wallet_number, do: @err_missing_wallet_number
    def err_invalid_wallet_no, do: @err_invalid_wallet_no
    def err_invalid_qr_txt, do: @err_invalid_qr_txt
    def err_missing_qr_txt, do: @err_missing_qr_txt

    # def err_empty_category_rec, do: @err_empty_category_rec
    # def err_empty_subcategory_rec, do: @err_empty_subcategory_rec
    # def err_empty_nominee_rec, do: @err_empty_nominee_rec
    ###############################################################################################################
    ###############################################################################################################


    ###### Pre-defined length functions ####
    def exttrid_len, do: @exttrid_len
    def reference_len, do: @reference_len
    def timestamp_dur, do: @timestamp_dur
    ########################################



    @str_ctm "CTM"
    @str_blc "BLC"
    @str_tsc "TSC"
    @str_payout "MTC"
    @str_reversal "MTR"
    @payment_mode_momo "MOM"

    @activity_seg_cust "C"
    @activity_seg_merch "M"

    def str_sms_sender_id, do: @str_sms_sender_id
    def str_ctm, do: @str_ctm
    def str_blc, do: @str_blc
    def str_tsc, do: @str_tsc
    def str_payout, do: @str_payout
    def str_reversal, do: @str_reversal
    def payment_mode_momo, do: @payment_mode_momo
    def activity_seg_cust, do: @activity_seg_cust
    def activity_seg_merch, do: @activity_seg_merch

    @nw_tig "TIG"
    @nw_air "AIR"
    @nw_mtn "MTN"
    @nw_vod "VOD"
    @nw_crd "CRD"
    @nw_vis "VIS"
    @nw_mas "MAS"
    @nw_bnk "BNK"

    #Trans Types
    @payment_initiator_type "PIF"  #PIF - Payment Initiator funding
    @entity_fund_alloc_type "EFA"  #EFA - Entity Fund Allocation
    @account_reset_type "ACR"  #ACR - Account reset
    @entity_fund_debit_type "EFD"  #EFD - Entity Fund Debit


    #Authorizer config types
    @payout_initiator_type "PAI"  #PAI - Payout Allocation Initiator (responsibile for assigning funds to payment initiator, who is also called PC)
    @payout_approver_type "PAA"  #PAA - Payout Allocation Approver (responsible for approving funds allocated to the payment initiator)
    @entity_initiator_type "EAI"  #EAI - Entity Allocation Initiator (responsible for assigning funds to entity. e.g. Fund Manager group)
    @entity_approver_type "EAA"  #EAA - Entity Allocation Approver (responsibile for approving funds to entity)


    def payment_initiator_type, do: @payment_initiator_type
    def entity_fund_alloc_type, do: @entity_fund_alloc_type
    def account_reset_type, do: @account_reset_type
    def entity_fund_debit_type, do: @entity_fund_debit_type

    def payout_initiator_type, do: @payout_initiator_type
    def payout_approver_type, do: @payout_approver_type
    def entity_initiator_type, do: @entity_initiator_type
    def entity_approver_type, do: @entity_approver_type

    ########################################



#    def str_sms_sender_id, do: @str_sms_sender_id
#    def str_ctm, do: @str_ctm
#    def str_blc, do: @str_blc
#    def str_tsc, do: @str_tsc

    #######################################

    def nw_tig, do: @nw_tig
    def nw_air, do: @nw_air
    def nw_mtn, do: @nw_mtn
    def nw_vod, do: @nw_vod
    def nw_crd, do: @nw_crd
    def nw_vis, do: @nw_vis
    def nw_mas, do: @nw_mas
    def nw_bnk, do: @nw_bnk

end
