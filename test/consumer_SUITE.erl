%%%-------------------------------------------------------------------
%%% @author dlive
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. May 2019 17:10
%%%-------------------------------------------------------------------
-module(consumer_SUITE).
-author("dlive").

%% API
-export([]).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include("dubbo_service.hrl").
%%--------------------------------------------------------------------
%% Function: suite() -> Info
%% Info = [tuple()]
%%--------------------------------------------------------------------
suite() ->
  [{timetrap,{seconds,60}}].

%%--------------------------------------------------------------------
%% Function: init_per_suite(Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%%--------------------------------------------------------------------
init_per_suite(Config) ->
  logger:add_handler(testttt,logger_std_h,#{
    level => debug
  }),
  Start = application:ensure_all_started(dubboerl),
%%  dubboerl:init(),
  dubboerl:start_provider(),
  timer:sleep(2000),
  dubboerl:start_consumer(),
  dubbo_service_app:register_type_list(),
  timer:sleep(5000),
  io:format(user,"test case start info ~p~n",[Start]),
  [{appid,1}].

%%--------------------------------------------------------------------
%% Function: end_per_suite(Config0) -> term() | {save_config,Config1}
%% Config0 = Config1 = [tuple()]
%%--------------------------------------------------------------------
end_per_suite(_Config) ->
  ok.

%%--------------------------------------------------------------------
%% Function: init_per_group(GroupName, Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% GroupName = atom()
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%%--------------------------------------------------------------------
init_per_group(_GroupName, Config) ->
  Config.

%%--------------------------------------------------------------------
%% Function: end_per_group(GroupName, Config0) ->
%%               term() | {save_config,Config1}
%% GroupName = atom()
%% Config0 = Config1 = [tuple()]
%%--------------------------------------------------------------------
end_per_group(_GroupName, _Config) ->
  ok.

%%--------------------------------------------------------------------
%% Function: init_per_testcase(TestCase, Config0) ->
%%               Config1 | {skip,Reason} | {skip_and_save,Reason,Config1}
%% TestCase = atom()
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%%--------------------------------------------------------------------
init_per_testcase(_TestCase, Config) ->
  Config.

%%--------------------------------------------------------------------
%% Function: end_per_testcase(TestCase, Config0) ->
%%               term() | {save_config,Config1} | {fail,Reason}
%% TestCase = atom()
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%%--------------------------------------------------------------------
end_per_testcase(_TestCase, _Config) ->
  ok.

%%--------------------------------------------------------------------
%% Function: groups() -> [Group]
%% Group = {GroupName,Properties,GroupsAndTestCases}
%% GroupName = atom()
%% Properties = [parallel | sequence | Shuffle | {RepeatType,N}]
%% GroupsAndTestCases = [Group | {group,GroupName} | TestCase]
%% TestCase = atom()
%% Shuffle = shuffle | {shuffle,{integer(),integer(),integer()}}
%% RepeatType = repeat | repeat_until_all_ok | repeat_until_all_fail |
%%              repeat_until_any_ok | repeat_until_any_fail
%% N = integer() | forever
%%--------------------------------------------------------------------
groups() ->
  [
    {consumer1,[sequence],[lib_type_register,json_sync_invoker,hessian_sync_invoker]}
  ].

%%--------------------------------------------------------------------
%% Function: all() -> GroupsAndTestCases | {skip,Reason}
%% GroupsAndTestCases = [{group,GroupName} | TestCase]
%% GroupName = atom()
%% TestCase = atom()
%% Reason = term()
%%--------------------------------------------------------------------
all() ->
  [{group,consumer1}].

%%--------------------------------------------------------------------
%% Function: TestCase() -> Info
%% Info = [tuple()]
%%--------------------------------------------------------------------
lib_type_register() ->
  [].

%%--------------------------------------------------------------------
%% Function: TestCase(Config0) ->
%%               ok | exit() | {skip,Reason} | {comment,Comment} |
%%               {save_config,Config1} | {skip_and_save,Reason,Config1}
%% Config0 = Config1 = [tuple()]
%% Reason = term()
%% Comment = term()
%%--------------------------------------------------------------------
lib_type_register(_Config) ->
  ok.

json_sync_invoker(_Config)->
  application:set_env(dubboerl,protocol,json),
  R1 = user2:queryUserInfo(#userInfoRequest{username = "name",requestId = "111"},#{sync=> true}),
  io:format(user,"json_sync_invoker result ~p ~n",[R1]),
  R2 = user2:genUserId(),
  io:format(user,"json_sync_invoker result2 ~p ~n",[R2]),
  ok.
hessian_sync_invoker(_Config)->
  application:set_env(dubboerl,protocol,hessian),
  R1 = user2:queryUserInfo(#userInfoRequest{username = "name",requestId = "111"},#{sync=> true}),
  io:format(user,"json_sync_invoker result ~p ~n",[R1]),
  R2 = user2:genUserId(),
  io:format(user,"json_sync_invoker result2 ~p ~n",[R2]),
  ok.