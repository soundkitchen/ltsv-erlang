-module(ltsv_tests).

-include_lib("eunit/include/eunit.hrl").


encode_test() ->
  ?assertEqual(<<"a:A\tb:B\nc:C\td:D">>,
               ltsv:encode([[{<<"a">>, <<"A">>}, {<<"b">>, <<"B">>}], [{<<"c">>, <<"C">>}, {<<"d">>, <<"D">>}]])).

encode_line_test() ->
  ?assertEqual(<<"spam:ham">>, ltsv:encode_line([{<<"spam">>, <<"ham">>}])),
  ?assertEqual(<<"spam:ham\tegg:ni!">>, ltsv:encode_line([{<<"spam">>, <<"ham">>}, {egg, <<"ni!">>}])).

encode_field_test() ->
  ?assertEqual(<<"label:value">>, ltsv:encode_field({<<"label">>, <<"value">>})),
  ?assertEqual(<<"ラベル:バリュー"/utf8>>, ltsv:encode_field({<<"ラベル"/utf8>>, <<"バリュー"/utf8>>})),
  ?assertEqual(<<"label:value">>, ltsv:encode_field({label, value})),
  ?assertEqual(<<"label:1">>, ltsv:encode_field({label, 1})),
  ?assertEqual(<<"label:321">>, ltsv:encode_field({label, 321})),
  ?assertEqual(<<"label:2.50000000000000000000e+00">>, ltsv:encode_field({label, 2.5})),
  ?assertEqual(<<"label:あうあうあ"/utf8>>, ltsv:encode_field({label, "あうあうあ"})).


decode_test() ->
  ?assertEqual([[{<<"a">>, <<"A">>}, {<<"b">>, <<"B">>}], [{<<"c">>, <<"C">>}, {<<"d">>, <<"D">>}]],
               ltsv:decode(<<"a:A\tb:B\nc:C\td:D">>)),
  ?assertEqual([[{<<"a">>, <<"A">>}, {<<"b">>, <<"B">>}], [{<<"c">>, <<"C">>}, {<<"d">>, <<"D">>}]],
               ltsv:decode(<<"a:A\tb:B\nc:C\td:D\n">>)).


decode_line_test() ->
  ?assertEqual([{<<"spam">>, <<"ham">>}], ltsv:decode_line(<<"spam:ham">>)),
  ?assertEqual([{<<"spam">>, <<"ham">>}], ltsv:decode_line(<<"spam:ham\n">>)),
  ?assertEqual([{<<"spam">>, <<"ham">>}, {<<"egg">>, <<"ni!">>}], ltsv:decode_line(<<"spam:ham\tegg:ni!">>)),
  ?assertEqual([{<<"spam">>, <<"ham">>}, {<<"egg">>, <<"ni!">>}], ltsv:decode_line(<<"spam:ham\tegg:ni!\n">>)).


decode_field_test() ->
  ?assertEqual({<<"label">>, <<"value">>}, ltsv:decode_field(<<"label:value">>)),
  ?assertEqual({<<"ラベル"/utf8>>, <<"バリュー"/utf8>>}, ltsv:decode_field(<<"ラベル:バリュー"/utf8>>)).


rstrip_test() ->
  ?assertEqual(<<>>, ltsv:rstrip(<<"">>)),
  ?assertEqual(<<"あ"/utf8>>, ltsv:rstrip(<<"あ"/utf8>>)),
  ?assertEqual(<<"あ"/utf8>>, ltsv:rstrip(<<"あ "/utf8>>)),
  ?assertEqual(<<"あ"/utf8>>, ltsv:rstrip(<<"あ\t"/utf8>>)),
  ?assertEqual(<<"あ"/utf8>>, ltsv:rstrip(<<"あ\r"/utf8>>)),
  ?assertEqual(<<"あ"/utf8>>, ltsv:rstrip(<<"あ\n"/utf8>>)),
  ?assertEqual(<<"あ"/utf8>>, ltsv:rstrip(<<"あ\r\n"/utf8>>)).
