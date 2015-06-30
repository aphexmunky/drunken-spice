-module(tcp).
-behaviour(gen_server).

-export([start_link/1]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([handleTCP_transmission/2]).

-define(SERVER, ?MODULE).

-record(state, {lsock}).

start_link(LSock) ->
  io:format("in tcp child~n"),
  {ok, _Socket} = gen_tcp:accept(LSock),
  gen_server:start_link({local, ?SERVER}, ?MODULE, [LSock], []).

code_change(_OldVsn, State, _Extra) ->
  io:format("tcp listener code_change~n"),
  {ok, State}.

terminate(_Reason, _State) ->
  io:format("tcp listener terminate~n"),
  ok.

handle_info(_Info, State) ->
  io:format("tcp listener handle_info with ~p and ~p~n", [_Info, State]),
  % {_Module, Socket, Address, Port, Msg} = _Info,
  % handleTCP_transmission(Socket, Address, Port, Msg),
  {noreply, State}.

handle_cast(_Request, State) ->
  io:format("tcp listener handle_cast~n"),
  {noreply, State}.

handle_call(_Request, _From, State) ->
  io:format("tcp listener handle_call~n"),
  {reply, ok, State}.

init(LSock) ->
  io:format("tcp child init - opening socket ~p~n", [LSock]),
  erlang:send_after(0, self(), trigger),
  {ok, #state{lsock = LSock}}.

handleTCP_transmission(Socket, Packet) ->
  Res = storage:store(Packet),
  gen_tcp:send(Socket, Res),
  gen_tcp:close(Socket).

