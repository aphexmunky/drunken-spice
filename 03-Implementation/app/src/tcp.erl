-module(tcp).

-export([tcp_loop/1, handleTCP_transmission/2]).

tcp_loop(Listener) ->
  {ok, TCPSocket} = gen_tcp:accept(Listener),
  TCPHandler = spawn(app_app, handle_packet, [TCPSocket]),
  TCPHandler ! gen_tcp:recv(TCPSocket, 0),
  tcp_loop(Listener).

handleTCP_transmission(Socket, Packet) ->
	Res = datastore:store(Packet),
	gen_tcp:send(Socket, Res),
	gen_tcp:close(Socket).
