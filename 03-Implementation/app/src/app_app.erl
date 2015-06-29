-module(app_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).
-export([handle_packet/1]).

start(_Type, _Args) ->
    ets:new(storage, [set, public, named_table]),
    {ok, UDPSocket}   = gen_udp:open(9000, [{active, false}]),
    {ok, TCPListener} = gen_tcp:listen(9000, [{active, false}]),
    spawn(tcp, tcp_loop, [TCPListener]),
    spawn(udp, udp_loop, [UDPSocket]),

    Dispatch = cowboy_router:compile([
        {'_', [{"/:key", keyreq_handler, []}]}
    ]),
    {ok, _} = cowboy:start_http(keyreq_handler, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    app_sup:start_link().

handle_packet(Socket) ->
  receive
    {ok,{Address, Port, Msg}}	-> udp:handleUDP_transmission(Socket, Address, Port, Msg);
    {ok, Packet}				-> tcp:handleTCP_transmission(Socket, Packet)
  end,
  handle_packet(Socket).

stop(_State) ->
	cowboy:stop(),
	ok.
