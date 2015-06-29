-module(udp).

-export([udp_loop/1, handleUDP_transmission/4]).

udp_loop(Socket) ->
  Handler = spawn(app_app, handle_packet, [Socket]),
  Handler ! gen_udp:recv(Socket, 0),
  udp_loop(Socket).

handleUDP_transmission(Socket, Address, Port, Msg) ->
	Res = datastore:store(Msg),
	gen_udp:send(Socket, Address, Port, Res).
