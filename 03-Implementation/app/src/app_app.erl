-module(app_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    ets:new(storage, [set, public, named_table]),
	app_sup:start_link().

stop(_State) ->
	ok.
