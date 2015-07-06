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

start_link(Args) ->
  io:format("in tcp child with args: ~p~n", [Args]),
  gen_server:start_link({local, ?SERVER}, ?MODULE, [Args], []).

code_change(_OldVsn, State, _Extra) ->
  io:format("tcp listener code_change~n"),
  {ok, State}.

terminate(_Reason, _State) ->
  io:format("tcp listener terminate with ~p and ~p~n", [_Reason, _State]),
  ok.

handle_info(trigger, State) ->
  io:format("oh... ~p~n", [State]),
  {ok, Socket} = gen_tcp:accept(State#state.lsock),
  inet:setopts(State#state.lsock,[{active,once}]),
  {noreply, #state{lsock = Socket}};
handle_info({_,Socket,Msg}, State) ->
  io:format("tcp listener handle_info with ~p and ~p~n", [[Socket, Msg], State]),
  inet:setopts(State#state.lsock,[{active,once}]),
  {noreply, State};
handle_info(_Info, State) ->
  io:format("unknown message with ~p and ~p~n", [_Info, State]),
  {_,Socket} = _Info,
  gen_tcp:close(Socket),
  inet:setopts(State#state.lsock,[{active,once}]),
  {noreply, State}.

handle_cast(_Request, State) ->
  io:format("tcp listener handle_cast~n"),
  {noreply, State}.

handle_call(_Request, _From, State) ->
  io:format("tcp listener handle_call~n"),
  {reply, ok, State}.

init([_Something]) ->
  io:format("tcp child init - opening socket ~p~n", [_Something]),
  erlang:send_after(0, self(), trigger),
  {ok, #state{lsock = _Something}}.

handleTCP_transmission(Socket, Packet) ->
  Res = storage:store(Packet),
  gen_tcp:send(Socket, Res),
  gen_tcp:close(Socket).

