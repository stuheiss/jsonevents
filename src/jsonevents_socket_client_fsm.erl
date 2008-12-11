-module(jsonevents_socket_client_fsm).
-behaviour(gen_fsm).
-include("jsonevents.hrl").

-export([
        start/1,
        start_link/1
    ]).

-export([
        hello/2,
        hello/3
    ]).


-export([
        init/1,
        handle_event/3,
        handle_sync_event/4,
        handle_info/3,
        terminate/3,
        code_change/4
    ]).


start(ClientSocket) ->
    gen_fsm:start(?MODULE, [ClientSocket], []).

start_link(ClientSocket) ->
    gen_fsm:start_link(?MODULE, [ClientSocket], []).


hello(_Event, StateData) ->
    {next_state, hello, StateData}.

hello(Event, _From, StateData) ->
    {reply, {illegal, Event}, hello, StateData}.


init([ClientSocket]) ->
    ok = inet:setopts(ClientSocket, [{active, once}]),
    {ok, hello, ClientSocket}.

handle_event(_Event, State, StateData) ->
    {next_state, State, StateData}.

handle_sync_event(Event, _From, State, StateData) ->
    {reply, {illegal, Event}, State, StateData}.

handle_info({tcp, ClientSocket, Binary}, State, ClientSocket=StateData) ->
    ok = gen_tcp:send(ClientSocket, Binary),
    ok = inet:setopts(ClientSocket, [{active, once}]),
    {next_state, State, StateData};

handle_info({tcp_error, ClientSocket, Reason}, _State, ClientSocket=StateData) ->
    {stop, Reason, StateData};

handle_info({tcp_closed, ClientSocket}, _State, ClientSocket=StateData) ->
    {stop, normal, StateData};

handle_info(_Info, State, StateData) ->
    {next_state, State, StateData}.

terminate(_Reason, _State, ClientSocket=_StateData) ->
    gen_tcp:close(ClientSocket),
    ok.

code_change(_OldVsn, State, StateData, _Extra) ->
    {next_state, State, StateData}.
