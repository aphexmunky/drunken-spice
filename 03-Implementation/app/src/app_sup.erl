-module(app_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	io:format("starting tcp connection...~n"),
    {ok, LSock} = gen_tcp:listen(8888, [binary, {active, false}]),
	io:format("started tcp connection...~n"),
	Procs = [
		{udp_server, {udp, start_link, []}, permanent, 1000, worker, [udp]},
		{tcp_server, {tcp, start_link, [LSock]}, permanent, 1000, worker, [tcp]}
	],
	{ok, {{one_for_one, 1, 5}, Procs}}.
