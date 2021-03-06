%%%-------------------------------------------------------------------
%%% @author dlive
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Dec 2017 11:54 PM
%%%-------------------------------------------------------------------
-module(dubboerl).
-author("dlive").

-include("dubboerl.hrl").
-include("dubbo.hrl").

%% API
-export([init/0,start_consumer/0,start_provider/0]).

init()->
    ok=start_consumer(),
    ok=start_provider(),
    ok.


start_consumer()->
    ConsumerList = application:get_env(dubboerl,consumer,[]),
    ApplicationName = application:get_env(dubboerl,application,<<"defaultApplication">>),
    lists:map(fun({Interface,Option})->
        ConsumerInfo = dubbo_config_util:gen_consumer(ApplicationName,Interface,Option),
        dubbo_zookeeper:register_consumer(ConsumerInfo),
        logger:info("register consumer success ~p",[Interface])
        end,ConsumerList),
    ok.

start_provider()->
    ProviderList = application:get_env(dubboerl,provider,[]),
    ApplicationName = application:get_env(dubboerl,application,<<"defaultApplication">>),
    DubboServerPort = application:get_env(dubboerl,port,?DUBBO_DEFAULT_PORT),
    start_provider_listen(DubboServerPort),
    lists:map(fun({ImplModuleName,BehaviourModuleName,Interface,Option})->
        ok = dubbo_provider_protocol:register_impl_provider(Interface,ImplModuleName,BehaviourModuleName),
        MethodList= apply(BehaviourModuleName,get_method_999_list,[]),
        ProviderInfo = dubbo_config_util:gen_provider(ApplicationName,DubboServerPort,Interface,MethodList,Option),
        dubbo_zookeeper:register_provider(ProviderInfo),
        logger:info("register provider success ~p ~p",[ImplModuleName,Interface])
        end,ProviderList),
    ok.

start_provider_listen(Port)->
    {ok, _} = ranch:start_listener(tcp_reverse,
        ranch_tcp, [{port, Port}], dubbo_provider_protocol, []),
    ok.




