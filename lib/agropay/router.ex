defmodule acme.CORS do
  use Corsica.Router,
      origins: "*",
      allow_credentials: true,
      max_age: 600

  resource "/public/*", origins: "*"
  resource "/*"
end

defmodule acme.Router do

    use Plug.Router
    use Plug.Debugger
    require Logger
    plug Corsica, origins: "*"
    plug(Plug.Logger, log: :debug)
    plug(:match)
    plug(:dispatch)
    alias acme.EctoFunc
    alias acme.BaseFunc
    alias acme.Constant
    alias acme.Processor
    alias acme.Transaction
    alias acme.Operations



    post "/req_entity_bal" do

        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->

                with [_req_url|_] <- get_req_header(conn, "host"),
                         [_user_agent|_] <- get_req_header(conn, "user-agent"),
                         [_remote_ip|_] <- BaseFunc.convert_ip(conn.remote_ip),
                         [_req_path|_] <- conn.request_path,
                         {:ok, entity_code} <- BaseFunc.parse_entity_code(parsed["entity_code"])

                do

                    IO.inspect parsed

                    case Processor.accept_entity_balance_check(entity_code) do
                        {:ok, msg} ->
                            # send a successful response with the message returned by the Processor module
                            send_resp(conn, 200, Poison.encode!(msg))
                        {:error, msg} ->
                            # send an error response with the message returned by the Processor module
                            send_resp(conn, 200, Poison.encode!(msg))
                    end
                end
            {:error, reason} ->
                # print the error reason for debugging purposes
                IO.inspect reason
                # send an error response with a JSON-encoded error message
                conn
                |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                |> halt
        end
    end

    post "/req_entity_allocated_bal" do
        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->
                with [req_url|_] <- get_req_header(conn, "host"),
                    [user_agent|_] <- get_req_header(conn, "user-agent"),
                    remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                    req_path <- conn.request_path,
                    {:ok, entity_code} <- BaseFunc.parse_entity_code(parsed["entity_code"])
                    # {:ok, _} <- EctoFunc.save_incoming_request(remote_ip, req_url, req_path, body, user_agent, customer_number)
                do
                    IO.inspect parsed

                    case Operations.get_entity_balance(entity_code) do
                        {:ok, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                        {:error, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                    end
                else
                    {:error, reason} ->
                        IO.inspect reason
                        conn
                        |> send_resp(200, Poison.encode!(reason))
                        |> halt
                end
            {:error, reason} ->
                IO.inspect reason
                conn
                |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                |> halt
        end
    end

    post "/req_fund_allocation" do
        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->
                with [req_url|_] <- get_req_header(conn, "host"),
                    [user_agent|_] <- get_req_header(conn, "user-agent"),
                    remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                    req_path <- conn.request_path,
                    {:ok, assigner_entity_code} <- BaseFunc.parse_entity_code(parsed["assigner_entity_code"]),
                    {:ok, assignee_entity_code} <- BaseFunc.parse_entity_code(parsed["assignee_entity_code"]),
                    {:ok, trans_type} <- BaseFunc.parse_fund_alloc_trans_type(parsed["trans_type"]),
                    {:ok, purchase_season_id} <- BaseFunc.parse_purchase_season(parsed["purchase_season"]),
                    {:ok, amount} <- BaseFunc.parse_amount(parsed["amount"]),
                    {:ok, user_id} <- BaseFunc.parse_user_id(parsed["user_id"])
                    # {:ok, _} <- EctoFunc.save_incoming_request(remote_ip, req_url, req_path, body, user_agent, customer_number)
                do
                    payment_init=parsed["payment_init"]
                    #"item_data":"amount:0.10~ref_code:471~reference:Men shoes~qty:1;amount:0.10~ref_code:472~reference:Men Slippers Brown~qty:1;"
                    IO.inspect parsed

                    case Processor.accept_funds_allocation_request(assigner_entity_code, assignee_entity_code, amount, trans_type, payment_init, purchase_season_id, user_id) do
                        {:ok, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                        {:error, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                    end
                else
                    {:error, reason} ->
                        IO.inspect reason
                        conn
                        |> send_resp(200, Poison.encode!(reason))
                        |> halt
                end
            {:error, reason} ->
                IO.inspect reason
                conn
                |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                |> halt
        end
    end

    post "/req_approve_funds" do
        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->
                with [req_url|_] <- get_req_header(conn, "host"),
                    [user_agent|_] <- get_req_header(conn, "user-agent"),
                    remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                    req_path <- conn.request_path,
                    {:ok, fund_alloc_id} <- BaseFunc.parse_ref_id(parsed["fund_alloc_id"]),
                    {:ok, approval_status} <- BaseFunc.parse_approval_status(parsed["approval_status"]),
                    {:ok, reason} <- BaseFunc.parse_approval_reason(parsed["reason"], approval_status),
                    {:ok, user_id} <- BaseFunc.parse_user_id(parsed["user_id"])
                    # {:ok, _} <- EctoFunc.save_incoming_request(remote_ip, req_url, req_path, body, user_agent, customer_number)
                do
                    IO.inspect parsed

                    case Processor.accept_fund_approval(fund_alloc_id, approval_status, reason, user_id) do
                        {:ok, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                        {:error, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                    end
                else
                    {:error, reason} ->
                        IO.inspect reason
                        conn
                        |> send_resp(200, Poison.encode!(reason))
                        |> halt
                end
            {:error, reason} ->
                IO.inspect reason
                conn
                |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                |> halt
        end
    end

    get "/req_validate_service_code" do
        parsed = fetch_query_params(conn)
        if Map.has_key?(parsed.query_params, "service_code") && Map.has_key?(parsed.query_params, "customer_number")  do
            {:ok, customer_number}=BaseFunc.parse_phone_number(parsed.query_params["customer_number"], "GH")
            {:ok, service_code}=BaseFunc.parse_short_code_ext(parsed.query_params["service_code"])

            [req_url|_]=get_req_header(conn, "host")
            [user_agent|_]=get_req_header(conn, "user-agent")
            remote_ip=BaseFunc.convert_ip(conn.remote_ip)
            req_path=conn.request_path
            req_body=Poison.encode!(parsed.query_params)

            case Processor.accept_validate_service_code(service_code, customer_number) do
                {:ok, status} ->
                    IO.inspect status
                    send_resp(conn, 200, Poison.encode!(status))
                {:error, status} ->
                    send_resp(conn, 200, Poison.encode!(status))
            end
        else
            halt send_resp(conn, 200, Poison.encode!(Constant.err_missing_cust_no()))
        end
    end

    post "/req_beneficiary_info_inquiry" do
        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->
                with [req_url|_] <- get_req_header(conn, "host"),
                    [user_agent|_] <- get_req_header(conn, "user-agent"),
                    remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                    req_path <- conn.request_path,
                    {:ok, pay_initiator_code} <- BaseFunc.parse_pay_initiator_code(parsed["pay_initiator_code"]),
                    {:ok, entity_code} <- BaseFunc.parse_entity_code(parsed["entity_code"])
                    # {:ok, beneficiary_number} <- BaseFunc.parse_phone_number(parsed["beneficiary_number"], "GH", entity_code)
                    # {:ok, _} <- EctoFunc.save_incoming_request(remote_ip, req_url, req_path, body, user_agent, customer_number)
                do
                    beneficiary_number=parsed["beneficiary_number"]
                    nw=parsed["nw"]
                    IO.inspect parsed

                    # acme.Processor.process_beneficiary_lookup("00000044", "00000029", "AS125H")
                    case Processor.process_beneficiary_lookup(pay_initiator_code, entity_code, beneficiary_number, nw) do
                        {:ok, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                        {:error, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                    end
                else
                    {:error, reason} ->
                        IO.inspect reason
                        conn
                        |> send_resp(200, Poison.encode!(reason))
                        |> halt
                end
            {:error, reason} ->
                IO.inspect reason
                conn
                |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                |> halt
        end
    end

    post "/req_compute_amount" do
        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->
                with [req_url|_] <- get_req_header(conn, "host"),
                    [user_agent|_] <- get_req_header(conn, "user-agent"),
                    remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                    req_path <- conn.request_path,
                    {:ok, pay_initiator_code} <- BaseFunc.parse_pay_initiator_code(parsed["pay_initiator_code"]),
                    {:ok, product_code} <- BaseFunc.parse_product_code(parsed["product_code"]),
                    {:ok, entity_code} <- BaseFunc.parse_entity_code(parsed["entity_code"]),
                    {:ok, beneficiary_code} <- BaseFunc.parse_beneficiary_code(parsed["beneficiary_code"], entity_code),
                    {:ok, qty} <- BaseFunc.parse_qty(parsed["qty"])
                    # {:ok, _} <- EctoFunc.save_incoming_request(remote_ip, req_url, req_path, body, user_agent, customer_number)
                do
                    IO.inspect parsed
                    # acme.Processor.process_compute_product_amount("00000041", "00000032", 3, "00000045")
                    case Processor.process_compute_product_amount(pay_initiator_code, product_code, qty, beneficiary_code) do
                        {:ok, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                        {:error, msg} ->
                            send_resp(conn, 200, Poison.encode!(msg))
                    end
                else
                    {:error, reason} ->
                        IO.inspect reason
                        conn
                        |> send_resp(200, Poison.encode!(reason))
                        |> halt
                end
            {:error, reason} ->
                IO.inspect reason
                conn
                |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                |> halt
        end
    end

    post "/req_process_payment" do
        {:ok, body, conn} = read_body(conn)
        case Poison.decode(body) do
            {:ok, parsed} ->
                with [req_url|_] <- get_req_header(conn, "host"),
                    [user_agent|_] <- get_req_header(conn, "user-agent"),
                    remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                    req_path <- conn.request_path,
                    {:ok, entity_code} <- BaseFunc.parse_entity_code(parsed["entity_code"]),
                    {:ok, pay_initiator_code} <- BaseFunc.parse_pay_initiator_code(parsed["pay_initiator_code"]),
                    {:ok, pay_initiator_number} <- BaseFunc.parse_phone_number(parsed["pay_initiator_number"], "GH"),
                    {:ok, product_code} <- BaseFunc.parse_product_code(parsed["product_code"]),
                    {:ok, qty} <- BaseFunc.parse_qty(parsed["qty"]),
                    defmodule Agropay.Router do
                        use Phoenix.Router

                        import Agropay.Processor
                        import Agropay.Transaction
                        import Agropay.Constant
                        import Agropay.BaseFunc

                        pipeline :api do
                            plug :accepts, ["json"]
                        end

                        scope "/api", Agropay.Router do
                            pipe_through :api

                            post "/req_payment" do
                                {:ok, body, conn} = read_body(conn)
                                case Poison.decode(body) do
                                    {:ok, parsed} ->
                                        with [req_url|_] <- get_req_header(conn, "host"),
                                                 [user_agent|_] <- get_req_header(conn, "user-agent"),
                                                 remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                                                 req_path <- conn.request_path,
                                                 entity_code = parsed["entity_code"],
                                                 pay_initiator_code = parsed["pay_initiator_code"],
                                                 pay_initiator_number = parsed["pay_initiator_number"],
                                                 product_code = parsed["product_code"],
                                                 qty = parsed["qty"],
                                                 {:ok, product_amount} <- BaseFunc.parse_amount(parsed["product_amount"]),
                                                 {:ok, total_amount} <- BaseFunc.parse_amount(parsed["total_amount"]),
                                                 {:ok, charge} <- BaseFunc.parse_charge(parsed["charge"]),
                                                 {:ok, pan} <- BaseFunc.parse_phone_number(parsed["pan"], "GH"),
                                                 {:ok, beneficiary_code} <- BaseFunc.parse_beneficiary_code(parsed["beneficiary_code"], entity_code),
                                                 {:ok, recipient_nw} <- BaseFunc.parse_nw(parsed["recipient_nw"]),
                                                 {:ok, payment_mode} <- BaseFunc.parse_payment_mode(parsed["payment_mode"]),
                                                 {:ok, src} <- BaseFunc.parse_src(parsed["src"]),
                                                 session_id = parsed["session_id"],
                                                 beneficiary_name = parsed["beneficiary_name"],
                                                 trans_type = Constant.str_payout(),
                                                 ticket_number = parsed["ticket_number"]
                                        do
                                            params=%{entity_code: entity_code, pay_initiator_code: pay_initiator_code, pay_initiator_number: pay_initiator_number, product_code: product_code,
                                                             qty: qty, charge: charge, product_amount: product_amount, total_amount: total_amount, pan: pan, beneficiary_code: beneficiary_code, recipient_nw: recipient_nw,
                                                             payment_mode: payment_mode, trans_type: trans_type, beneficiary_name: beneficiary_name, src: src, ticket_number: ticket_number}
                                            case Processor.payment_request(params) do
                                                {:ok, msg} ->
                                                    send_resp(conn, 200, Poison.encode!(msg))
                                                {:error, msg} ->
                                                    send_resp(conn, 200, Poison.encode!(msg))
                                            end
                                        else
                                            {:error, reason} ->
                                                conn
                                                |> send_resp(200, Poison.encode!(reason))
                                                |> halt
                                        end
                                    {:error, reason} ->
                                        conn
                                        |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                                        |> halt
                                end
                            end

                            post "/req_initiator_bal" do
                                {:ok, body, conn} = read_body(conn)
                                case Poison.decode(body) do
                                    {:ok, parsed} ->
                                        with [req_url|_] <- get_req_header(conn, "host"),
                                                 [user_agent|_] <- get_req_header(conn, "user-agent"),
                                                 remote_ip <- BaseFunc.convert_ip(conn.remote_ip),
                                                 req_path <- conn.request_path,
                                                 {:ok, pay_initiator_code} <- BaseFunc.parse_pay_initiator_code(parsed["pay_initiator_code"])
                                        do
                                            case Processor.accept_pay_initiator_balance_check(pay_initiator_code) do
                                                {:ok, msg} ->
                                                    send_resp(conn, 200, Poison.encode!(msg))
                                                {:error, msg} ->
                                                    send_resp(conn, 200, Poison.encode!(msg))
                                            end
                                        else
                                            {:error, reason} ->
                                                conn
                                                |> send_resp(200, Poison.encode!(reason))
                                                |> halt
                                        end
                                    {:error, reason} ->
                                        conn
                                        |> send_resp(200, Poison.encode!(Constant.err_invalid_req_format()))
                                        |> halt
                                end
                            end

                            post "/req_callback_acme" do
                                {:ok, body, conn} = read_body(conn)

                                {:ok, parsed} = Poison.decode(body)

                                trans_status=parsed["trans_status"]
                                resp_desc=parsed["message"]
                                trans_ref=parsed["trans_ref"]
                                trans_id=parsed["trans_id"]
                                case Transaction.payment_callback(trans_status, trans_id, trans_ref, resp_desc) do
                                    {:ok, response} ->
                                        halt send_resp(conn, 200, Poison.encode!(response))
                                    {:error, reason} ->
                                        halt send_resp(conn, 200, Poison.encode!(reason))
                                end
                            end

                            match _ do
                                send_resp(conn, 404, "not found")
                            end
                        end
                    end
