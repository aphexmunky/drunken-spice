-module(udp).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-export([handleUDP_transmission/4]).

-define(SERVER, ?MODULE).

-record(state, {}).

start_link() ->
  io:format("in udp child~n"),
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

code_change(_OldVsn, State, _Extra) ->
  io:format("udp listener code_change~n"),
  {ok, State}.

terminate(_Reason, _State) ->
  io:format("udp listener terminate~n"),
  ok.

handle_info(_Info, State) ->
  io:format("udp listener handle_info with ~p and ~p~n", [_Info, State]),
  {_Module, Socket, Address, Port, Msg} = _Info,
  handleUDP_transmission(Socket, Address, Port, Msg),
  {noreply, State}.

handle_cast(_Request, State) ->
  io:format("udp listener handle_cast~n"),
  {noreply, State}.

handle_call(_Request, _From, State) ->
  io:format("udp listener handle_call~n"),
  {reply, ok, State}.

init([]) ->
  io:format("udp child init - opening socket~n"),
  {ok, _Socket} = gen_udp:open(8888, []),
  {ok, #state{}}.

handleUDP_transmission(Socket, Address, Port, Msg) ->
  Res = storage:store(Msg),
  gen_udp:send(Socket, Address, Port, Res).