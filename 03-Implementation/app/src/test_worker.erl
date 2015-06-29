-module(test_worker).
-behaviour(gen_server).

-export([start_link/1]).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

start_link([]) ->
  io:format("in child~n"),
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.

handle_info(_Info, State) ->
  {noreply, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

init([]) ->
  io:format("child init~n"),
  {ok, #state{}}.
