%%% @doc Default rest handler implementation
-module(spts_base_handler).
-author('elbrujohalcon@inaka.net').

-export([ init/3
        , rest_init/2
        , content_types_accepted/2
        , content_types_provided/2
        , resource_exists/2
        ]).

-type state() :: #{}.
-export_type([state/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Cowboy Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec init({atom(), atom()}, cowboy_req:req(), state()) ->
  {upgrade, protocol, cowboy_rest}.
init(_Transport, _Req, _Opts) ->
  {upgrade, protocol, cowboy_rest}.

-spec rest_init(cowboy_req:req(), state()) ->
  {ok, cowboy_req:req(), term()}.
rest_init(Req, _Opts) ->
  Req1 = spts_web_utils:announce_req(Req, []),
  {ok, Req1, #{}}.

-spec content_types_accepted(cowboy_req:req(), state()) ->
  {[{{binary(), binary(), '*'}, atom()}], cowboy_req:req(), state()}.
content_types_accepted(Req, State) ->
  case cowboy_req:method(Req) of
    {<<"POST">>, Req1} ->
      ContentTypes = [{{<<"application">>, <<"json">>, '*'}, handle_post}],
      {ContentTypes, Req1, State};
    {<<"PUT">>, Req1} ->
      ContentTypes = [{{<<"application">>, <<"json">>, '*'}, handle_put}],
      {ContentTypes, Req1, State}
  end.

-spec content_types_provided(cowboy_req:req(), state()) ->
  {[term()], cowboy_req:req(), state()}.
content_types_provided(Req, State) ->
  {[{<<"application/json">>, handle_get}], Req, State}.

-spec resource_exists(cowboy_req:req(), term()) ->
  {boolean(), cowboy_req:req(), term()}.
resource_exists(Req, State) ->
  {Method, Req1} = cowboy_req:method(Req),
  {Method /= <<"POST">>, Req1, State}.