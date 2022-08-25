-module(els_document_symbol_SUITE).

%% CT Callbacks
-export([
    suite/0,
    init_per_suite/1,
    end_per_suite/1,
    init_per_testcase/2,
    end_per_testcase/2,
    all/0
]).

%% Test cases
-export([symbols/1]).

-include("els_lsp.hrl").

%%==============================================================================
%% Includes
%%==============================================================================
-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

%%==============================================================================
%% Types
%%==============================================================================
-type config() :: [{atom(), any()}].

%%==============================================================================
%% CT Callbacks
%%==============================================================================
-spec suite() -> [tuple()].
suite() ->
    [{timetrap, {seconds, 30}}].

-spec all() -> [atom()].
all() ->
    els_test_utils:all(?MODULE).

-spec init_per_suite(config()) -> config().
init_per_suite(Config) ->
    els_test_utils:init_per_suite(Config).

-spec end_per_suite(config()) -> ok.
end_per_suite(Config) ->
    els_test_utils:end_per_suite(Config).

-spec init_per_testcase(atom(), config()) -> config().
init_per_testcase(TestCase, Config) ->
    els_test_utils:init_per_testcase(TestCase, Config).

-spec end_per_testcase(atom(), config()) -> ok.
end_per_testcase(TestCase, Config) ->
    els_test_utils:end_per_testcase(TestCase, Config).

%%==============================================================================
%% Testcases
%%==============================================================================
-spec symbols(config()) -> ok.
symbols(Config) ->
    Uri = ?config(code_navigation_uri, Config),
    #{result := Symbols} = els_client:document_symbol(Uri),
    Expected = lists:append([
        expected_functions(Uri),
        expected_macros(Uri),
        expected_records(Uri),
        expected_types(Uri)
    ]),
    ?assertEqual(length(Expected), length(Symbols)),
    Pairs = lists:zip(lists:sort(Expected), lists:sort(Symbols)),
    [?assertEqual(E, S) || {E, S} <- Pairs],
    ok.

%%==============================================================================
%% Internal Functions
%%==============================================================================
expected_functions(Uri) ->
    [
        #{
            kind => ?SYMBOLKIND_FUNCTION,
            location =>
                #{
                    range =>
                        #{
                            'end' => #{character => ToC, line => ToL},
                            start => #{character => FromC, line => FromL}
                        },
                    uri => Uri
                },
            name => Name
        }
     || {Name, {FromL, FromC}, {ToL, ToC}} <- lists:append([functions()])
    ].

expected_macros(Uri) ->
    [
        #{
            kind => ?SYMBOLKIND_CONSTANT,
            location =>
                #{
                    range =>
                        #{
                            'end' => #{character => ToC, line => ToL},
                            start => #{character => FromC, line => FromL}
                        },
                    uri => Uri
                },
            name => Name
        }
     || {Name, {FromL, FromC}, {ToL, ToC}} <- lists:append([macros()])
    ].

expected_records(Uri) ->
    [
        #{
            kind => ?SYMBOLKIND_STRUCT,
            location =>
                #{
                    range =>
                        #{
                            'end' => #{character => ToC, line => ToL},
                            start => #{character => FromC, line => FromL}
                        },
                    uri => Uri
                },
            name => Name
        }
     || {Name, {FromL, FromC}, {ToL, ToC}} <- lists:append([records()])
    ].

expected_types(Uri) ->
    [
        #{
            kind => ?SYMBOLKIND_TYPE_PARAMETER,
            location =>
                #{
                    range =>
                        #{
                            'end' => #{character => ToC, line => ToL},
                            start => #{character => FromC, line => FromL}
                        },
                    uri => Uri
                },
            name => Name
        }
     || {Name, {FromL, FromC}, {ToL, ToC}} <- lists:append([types()])
    ].

functions() ->
    [
        {<<"function_a/0">>, {20, 0}, {23, -1}},
        {<<"function_b/0">>, {24, 0}, {26, -1}},
        {<<"callback_a/0">>, {27, 0}, {29, -1}},
        {<<"function_c/0">>, {30, 0}, {35, -1}},
        {<<"function_d/0">>, {38, 0}, {40, -1}},
        {<<"function_e/0">>, {41, 0}, {43, -1}},
        {<<"function_f/0">>, {46, 0}, {48, -1}},
        {<<"function_g/1">>, {49, 0}, {53, -1}},
        {<<"function_h/0">>, {55, 0}, {57, -1}},
        {<<"function_i/0">>, {59, 0}, {60, -1}},
        {<<"function_i/0">>, {61, 0}, {62, -1}},
        {<<"function_j/0">>, {66, 0}, {68, -1}},
        {<<"function_k/0">>, {73, 0}, {76, -1}},
        {<<"function_l/2">>, {78, 0}, {81, -1}},
        {<<"function_m/1">>, {83, 0}, {86, -1}},
        {<<"function_n/0">>, {88, 0}, {90, -1}},
        {<<"function_o/0">>, {92, 0}, {94, -1}},
        {<<"PascalCaseFunction/1">>, {97, 0}, {101, -1}},
        {<<"function_p/1">>, {102, 0}, {108, -1}},
        {<<"function_q/0">>, {113, 0}, {116, -1}},
        {<<"macro_b/2">>, {119, 0}, {121, -1}},
        {<<"function_mb/0">>, {122, 0}, {124, -1}},
        {<<"code_navigation/0">>, {125, 0}, {126, -1}},
        {<<"code_navigation/1">>, {127, 0}, {128, -1}},
        {<<"multiple_instances_same_file/0">>, {129, 0}, {130, -1}},
        {<<"code_navigation_extra/3">>, {131, 0}, {132, -1}},
        {<<"multiple_instances_diff_file/0">>, {133, 0}, {134, -1}}
    ].

macros() ->
    [
        {<<"macro_A">>, {44, 8}, {44, 15}},
        {<<"MACRO_B">>, {117, 8}, {117, 15}},
        {<<"MACRO_A">>, {17, 8}, {17, 15}},
        {<<"MACRO_A/1">>, {18, 8}, {18, 15}}
    ].

records() ->
    [
        {<<"record_a">>, {15, 8}, {15, 16}},
        {<<"?MODULE">>, {110, 8}, {110, 15}}
    ].

types() ->
    [{<<"type_a/0">>, {36, 0}, {36, 24}}].
