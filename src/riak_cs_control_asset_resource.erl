%% @author Christopher Meiklejohn <christopher.meiklejohn@gmail.com>
%% @copyright 2012 Christopher Meiklejohn.

%% @doc Resource to serve static assets.

-module(riak_cs_control_asset_resource).
-author('Christopher Meiklejohn <christopher.meiklejohn@gmail.com>').

-export([init/1, 
         allowed_methods/2, 
         content_types_provided/2,
         resource_exists/2,
         to_resource/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

allowed_methods(ReqData, Context) -> 
    {['HEAD', 'GET'], ReqData, Context}.

content_types_provided(ReqData, Context) -> 
    Path = get_path(ReqData),
    MimeType = webmachine_util:guess_mime(Path),
    {[{MimeType, to_resource}], ReqData, Context}.

resource_exists(ReqData, Context) -> 
    Path = get_path(ReqData),
    case filelib:is_regular(Path) of 
        true -> 
            {true, ReqData, Context};
        _ -> 
            {false, ReqData, Context}
    end.

to_resource(ReqData, Context) -> 
    Path = get_path(ReqData),
    {ok, Source} = file:read_file(Path),
    {Source, ReqData, Context}.

get_path(ReqData) -> 
    {ok, App} = application:get_application(?MODULE),
    filename:join([code:priv_dir(App), 'www'] ++ wrq:path_tokens(ReqData)).
