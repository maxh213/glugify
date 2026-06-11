-module(glugify_ffi).
-export([github_clean/1]).

%% Removes every character GitHub strips when turning a heading into an
%% anchor, then turns each remaining space into a hyphen. The kept set
%% mirrors github-slugger's generated regex: Unicode letters (L), marks
%% (M), decimal and letter numbers (Nd, Nl), connector punctuation (Pc),
%% the circled and squared Latin letters that are Alphabetic without
%% being letters (U+24B6-24E9, U+1F130-1F189), plus space and hyphen.
%%
%% The space replacement happens here, at the codepoint level, rather
%% than in Gleam: string:replace/3 is grapheme-aware, so a space carrying
%% a combining mark would not match a lone " " pattern, and the
%% JavaScript target would disagree.
github_clean(Text) ->
    Stripped = re:replace(
        Text,
        <<"[^\\p{L}\\p{M}\\p{Nd}\\p{Nl}\\p{Pc}\\x{24B6}-\\x{24E9}\\x{1F130}-\\x{1F149}\\x{1F150}-\\x{1F169}\\x{1F170}-\\x{1F189} -]"/utf8>>,
        <<"">>,
        [global, unicode, {return, binary}]
    ),
    binary:replace(Stripped, <<" ">>, <<"-">>, [global]).
