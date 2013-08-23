%%%-------------------------------------------------------------------
%%% @author Niclas Axelsson <burbas@Niclass-MacBook-Pro.local>
%%% @copyright (C) 2012, Niclas Axelsson
%%% @doc
%%%
%%% @end
%%% Created :  7 Jul 2012 by Niclas Axelsson <burbas@Niclass-MacBook-Pro.local>
%%%-------------------------------------------------------------------
-module(bqs_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @spec init(Args) -> {ok, {SupFlags, [ChildSpec]}} |
%%                     ignore |
%%                     {error, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 10,
    MaxSecondsBetweenRestarts = 3600,
    
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    Restart = permanent,
    Shutdown = 2000,
    Type = worker,
    {ok, MapFile} = application:get_env(world_map),
    Map = 
        {bqs_map,
         {bqs_map, start_link, [MapFile]},
         Restart, Shutdown, Type, [bqs_map]},

    MobSup = 
        {bqs_mob_sup,
         {bqs_mob_sup, start_link, []},
         Restart, Shutdown, Type, [bqs_mob_sup]},
    
    EntityHandler = 
        {bqs_entity_handler,
         {bqs_entity_handler, start_link, []},
         Restart, Shutdown, Type, [bqs_entity_handler]},
    
    
    {ok, {SupFlags, [MobSup, EntityHandler, Map]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
