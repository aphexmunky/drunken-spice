-module(app_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).
-export([udp_loop/1, tcp_loop/1, handle_packet/1]).

start(_Type, _Args) ->
    ets:new(storage, [set, public, named_table]),
    {ok, UDPSocket}   = gen_udp:open(9000, [{active, false}]),
    {ok, TCPListener} = gen_tcp:listen(9000, [{active, false}]),
    spawn(app_app, tcp_loop, [TCPListener]),
    spawn(app_app, udp_loop, [UDPSocket]),

    Dispatch = cowboy_router:compile([
        {'_', [{"/:key", keyreq_handler, []}]}
    ]),
    {ok, _} = cowboy:start_http(keyreq_handler, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    app_sup:start_link().

tcp_loop(Listener) ->
  {ok, TCPSocket} = gen_tcp:accept(Listener),
  TCPHandler = spawn(app_app, handle_packet, [TCPSocket]),
  TCPHandler ! gen_tcp:recv(TCPSocket, 0),
  tcp_loop(Listener).

udp_loop(Socket) ->
  Handler = spawn(app_app, handle_packet, [Socket]),
  Handler ! gen_udp:recv(Socket, 0),
  udp_loop(Socket).

handle_packet(Socket) ->
  receive
    {ok,{Address, Port, Msg}}	-> handleUDP_transmission(Socket, Address, Port, Msg);
    {ok, Packet}				-> handleTCP_transmission(Socket, Packet)
  end,
  handle_packet(Socket).

handleTCP_transmission(Socket, Packet) ->
	Res = store(Packet),
	gen_tcp:send(Socket, Res),
	gen_tcp:close(Socket).

handleUDP_transmission(Socket, Address, Port, Msg) ->
	Res = store(Msg),
	gen_udp:send(Socket, Address, Port, Res).

stop(_State) ->
	cowboy:stop(),
	ok.

store(KeyVal) ->
  % alphanumeric key, use space as seperator
  ValidKeyRegEx = "^[A-Za-z0-9]+\s",

  case re:run(KeyVal, ValidKeyRegEx, []) of
  	% doesn't match pattern of 'key value' so must be a retrieval request
    nomatch ->
      KeyVal2 = re:replace(KeyVal, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
      case ets:lookup(storage, KeyVal2) of
        [{_, Value}] 	-> Value;
        []             	-> <<0>>
      end;
    % 'key value' so we're going to store the value against this key
    {match, [{_, EndMatch}]} -> 
      Key = string:sub_string(KeyVal, 1, EndMatch - 1),
      Key2 = re:replace(Key, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
      Value = lists:nthtail(EndMatch, KeyVal),
      ets:insert(storage, {Key2, Value}),
      Value
  end.
