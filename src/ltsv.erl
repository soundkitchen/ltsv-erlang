-module(ltsv).

%% public api.
-export([
  encode/1,
  decode/1
]).

-ifdef(TEST).
-export([
  encode_line/1,
  encode_field/1,
  decode_line/1,
  decode_field/1,
  rstrip/1
]).
-endif.

-type label() :: atom() | binary().
-type value() :: term().
-type field() :: {label(), value()}.
-type line() :: [field()].
-type data() :: [line()].


-spec encode(data()) -> binary().

encode(Data) ->
  encode(Data, <<>>).

encode([], Data) ->
  Data;
encode([H|Rest], <<>>) ->
  Line = encode_line(H),
  encode(Rest, Line);
encode([H|Rest], Data) ->
  Line = encode_line(H),
  encode(Rest, <<Data/binary, $\n, Line/binary>>).


-spec encode_line(line()) -> binary().

encode_line(Line) ->
  encode_line(Line, <<>>).

encode_line([], Line) ->
  Line;
encode_line([H|Rest], <<>>) ->
  Field = encode_field(H),
  encode_line(Rest, Field);
encode_line([H|Rest], Line) ->
  Field = encode_field(H),
  encode_line(Rest, <<Line/binary, $\t, Field/binary>>).


-spec encode_field(field()) -> binary().

encode_field({Label, Value}) when is_atom(Label) ->
  encode_field({atom_to_binary(Label, utf8), Value});
encode_field({Label, Value}) when is_atom(Value) ->
  encode_field({Label, atom_to_binary(Value, utf8)});
encode_field({Label, Value}) when is_integer(Value) ->
  encode_field({Label, integer_to_binary(Value)});
encode_field({Label, Value}) when is_float(Value) ->
  encode_field({Label, float_to_binary(Value)});
encode_field({Label, Value}) when is_float(Value) ->
  encode_field({Label, float_to_binary(Value)});
encode_field({Label, Value}) when is_list(Value) ->
  encode_field({Label, unicode:characters_to_binary(Value, utf8)});
encode_field({Label, Value}) when is_binary(Label), is_binary(Value) ->
  <<Label/binary, $:, Value/binary>>.


-spec decode(binary()) -> data().

decode(Data) when is_binary(Data) ->
  Lines = binary:split(Data, <<$\n>>, [global, trim_all]),
  lists:map(fun decode_line/1, Lines).


-spec decode_line(binary()) -> line().

decode_line(Line) when is_binary(Line) ->
  Fields = binary:split(Line, <<$\t>>, [global, trim_all]),
  lists:map(fun decode_field/1, Fields).


-spec decode_field(binary()) -> field().

decode_field(Field) when is_binary(Field) ->
  [Key, Value] = binary:split(Field, <<$:>>),
  {Key, rstrip(Value)}.


rstrip(Bin) when is_binary(Bin) ->
  Size = byte_size(Bin) - 1,
  case Bin of
    <<Rest:Size/binary, C>> when C =:= $\s
                            orelse C =:= $\t
                            orelse C =:= $\r
                            orelse C =:= $\n ->
      rstrip(Rest);
    _ ->
      Bin
  end.

