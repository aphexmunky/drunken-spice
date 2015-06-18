-module(keyreq_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Type, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
	% extract required data
	{_Method, Req2} = cowboy_req:method(Req),
	{ok, Data, Req3} = cowboy_req:body(Req2),
	{Path, Req4} = cowboy_req:binding(key, Req3),
	% keep the key as a consistent type
	Path2 = binary_to_list(Path),
	{ok, Req5} = key_value_server(_Method, Path2, Data, Req4),
	{ok, Req5, State}.

% insert or retrieve request
key_value_server(<<"GET">>, Path, _Data, Req) ->
	lookup(ets:lookup(storage, Path), Req);
key_value_server(<<"POST">>, Path, Data, Req) ->
	ets:insert(storage, {Path, Data}),
	cowboy_req:reply(200, [{<<"content-type">>, <<"text/plain">>}], <<>>, Req).

% retrieve - key found
lookup([{_, Value}], Req) ->
	cowboy_req:reply(200, [
		{<<"content-type">>, <<"application/octet">>}
	], Value, Req);
% retrieve - key not found
lookup(_, Req) ->
	cowboy_req:reply(404, [], <<>>, Req).

terminate(_Reason, _Req, _State) ->
	ok.