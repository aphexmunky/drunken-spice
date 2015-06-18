-module(keyvalserver_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib ("deps/etest/include/etest.hrl").
-include_lib ("deps/etest_http/include/etest_http.hrl").

%%--------------------------------------------------------------------
%% Function: suite() -> Info
%% Info = [tuple()]
%%--------------------------------------------------------------------
suite() ->
    [{timetrap,{seconds,30}}].

init_per_suite(Config) ->
    os:cmd("../../_rel/app_release/bin/app_release start"),
    timer:sleep(1000),
    Config.

end_per_suite(_Config) ->
    os:cmd("../../_rel/app_release/bin/app_release stop"),
    ok.

all() -> 
    [http_get_nothing_stored_404,
     tcp_nothing_stored_empty_payload,
     udp_nothing_stored_empty_payload,
     http_store_value,
     http_get_hello_value,
     tcp_get_hello_value,
     udp_get_hello_value,
     abitary_datatype_storage,
     abitary_datatype_retrieval
    ].

http_get_nothing_stored_404(_Config) -> 
    Response = ?perform_get("http://localhost:8080/hello"),
    ?assert_status(404, Response),
    ?assert_body("", Response),
    ok.

tcp_nothing_stored_empty_payload(_Config) -> 
    {ok, Sock} = gen_tcp:connect("localhost", 9000, [binary, {active,false},{keepalive,true}]),
    ok = gen_tcp:send(Sock, "hello"),
    {ok, <<0>>} = gen_tcp:recv(Sock, 0),
    gen_tcp:close(Sock),
    ok.

udp_nothing_stored_empty_payload(_Config) -> 
    {ok, Socket} = gen_udp:open(9001, [binary, {active, false}]),
    ok = gen_udp:send(Socket, {127,0,0,1}, 9000, "hello"),
    {ok, {_Address, _Port, <<0>>}} = gen_udp:recv(Socket, 0),
    gen_udp:close(Socket),
    ok.

http_store_value(_Config) ->
    Response = ?perform_post("http://localhost:8080/hello", [], "world"),
    ?assert_status(200, Response),
    ?assert_body("", Response),
    ok.

http_get_hello_value(_Config) ->
    Response = ?perform_get("http://localhost:8080/hello"),
    ?assert_status(200, Response),
    ?assert_body("world", Response),
    ok.

tcp_get_hello_value(_Config) -> 
    {ok, Sock} = gen_tcp:connect("localhost", 9000, [{active,false},{keepalive,true}]),
    ok = gen_tcp:send(Sock, "hello"),
    {ok, "world"} = gen_tcp:recv(Sock, 0),
    gen_tcp:close(Sock),
    ok.

udp_get_hello_value(_Config) -> 
    {ok, Socket} = gen_udp:open(9001, [{active, false}]),
    ok = gen_udp:send(Socket, {127,0,0,1}, 9000, "hello"),
    {ok, {_Address, _Port, "world"}} = gen_udp:recv(Socket, 0),
    gen_udp:close(Socket),
    ok.

abitary_datatype_storage(_Config) ->
    {ok, Sock} = gen_tcp:connect("localhost", 9000, [binary, {active,false},{keepalive,true}]),
    Key = <<"storeMe ">>,
    Value = <<213,45,132,64,76,32,76,0,0,234,32,15>>,
    ok = gen_tcp:send(Sock, [Key, Value]),
    {ok, Value} = gen_tcp:recv(Sock, 0),
    gen_tcp:close(Sock),
    ok.

abitary_datatype_retrieval(_Config) ->
    {ok, Sock} = gen_tcp:connect("localhost", 9000, [binary, {active,false},{keepalive,true}]),
    Key = "storeMe",
    Value = <<213,45,132,64,76,32,76,0,0,234,32,15>>,
    ok = gen_tcp:send(Sock, Key),
    {ok, Value} = gen_tcp:recv(Sock, 0),
    gen_tcp:close(Sock),
    ok.
