-module(app_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  	{ok, LSock} = gen_tcp:listen(8888, [binary, {active, true}]),
	Procs = [
		{udp_server, {udp, start_link, []}, permanent, 1000, worker, [udp]},
		{tcp_server, {tcp, start_link, [LSock]}, temporary, 1000, worker, [tcp]}
	],
	{ok, {{one_for_one, 1, 5}, Procs}}.
