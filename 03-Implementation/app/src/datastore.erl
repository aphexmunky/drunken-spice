-module(datastore).

-export([store/1]).

store(KeyVal) ->
  % alphanumeric key, use space as seperator
  ValidKeyRegEx = "^[A-Za-z0-9]+\s",

  case re:run(KeyVal, ValidKeyRegEx, []) of
  	% doesn't match pattern of 'key value' so must be a retrieval request
    nomatch ->
      KeyVal2 = re:replace(KeyVal, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
      case ets:lookup(storage, KeyVal2) of
        [{_, Value}] 	-> Value;
        []             	-> <<0>>
      end;
    % 'key value' so we're going to store the value against this key
    {match, [{_, EndMatch}]} -> 
      Key = string:sub_string(KeyVal, 1, EndMatch - 1),
      Key2 = re:replace(Key, "(^\\s+)|(\\s+$)", "", [global,{return,list}]),
      Value = lists:nthtail(EndMatch, KeyVal),
      ets:insert(storage, {Key2, Value}),
      Value
  end.
