-module(app_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	io:format("Hello, world!~n"),
	Procs = [{'ANewName', {test_worker, start_link, []}, permanent, 1000, worker, [test_worker]}],
	{ok, {{one_for_one, 1, 5}, Procs}}.
