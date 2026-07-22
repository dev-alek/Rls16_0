/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Преобразование спецсимволов XML в коды и обратно

Автор: Хныкин Павел Андреевич
Дата создания: 10/25/05
Author: Pavel Khnykin
Creation date: 10/25/05


Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*==========================================================================*/
{&CommentStartNoClass}
method private void xmlchar-test (input  p-in-string          as character,
                                  output p-out-string-enc     as character,
                                  output p-out-string-dec    as character):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
{utl\comment.i} */ 

do
on error undo, return error
:

    {&CommentStartNoClass} 
       xmlchar-encode
    {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
       run xmlchar-encode in this-procedure 
    {utl\comment.i} */ 
    (
          input p-in-string
        , output p-out-string-enc
    ).
    {&CommentStartNoClass}
       xmlchar-decode   
    {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
       run xmlchar-decode in this-procedure 
    {utl\comment.i} */ 
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).

end.
end . /* xmlchar-test */

/*==========================================================================*/
{&CommentStartNoClass}
method private void xmlchar-encode (input  p-in-string          as character,
                                  output p-out-string         as character):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}

procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
{utl\comment.i} */ 
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.        /* when ? */
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.        /* when "?":U */
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.        /* when "&":U */
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.        /* when ">":U */
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.        /* when "<":U */
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.        /* when "'":U */
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.        /* when '"':U */
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(1) */
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(2) */
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(3) */
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(4) */
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(5) */
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(6) */
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(7) */
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(8) */
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(9) */
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.        /* when chr(29) */
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.        /* when chr(10) */
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.        /* when chr(13) */
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.        /* otherwise */
                end case.       /* case v-current-char */
            end.        /* v-position = 1 to length( p-in-string ) */
        end.        /* otherwise */
    end case.       /* case p-in-string */
end.
end . /* xmlchar-encode */
/*==========================================================================*/
{&CommentStartNoClass}
method private character  xmlchar-encode-1c (input  p-in-string          as character):
define variable p-out-string as character no-undo.
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}

procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
{utl\comment.i} */ 
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.        /* when ? */
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .      
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(1) */
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(2) */
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(3) */
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(4) */
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(5) */
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(6) */
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(7) */
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(8) */
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(9) */
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(29) */
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(10) */
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.        /* when chr(13) */
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.        /* otherwise */
                end case.       /* case v-current-char */
            end.        /* v-position = 1 to length( p-in-string ) */
        end.        /* otherwise */
    end case.       /* case p-in-string */
end.
{&CommentStartNoClass}
return p-out-string.
{utl\comment.i} */
end . /* xmlchar-encode */

/*==========================================================================*/
{&CommentStartNoClass}
method private void xmlchar-decode (input  p-in-string          as character,
                                  output p-out-string         as character):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}

procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
{utl\comment.i} */ 
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.        /* if v-last-position = 0 */
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    {&CommentStartNoClass}
                    xmlchar-read-integer
                    {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
                    run xmlchar-read-integer in this-procedure 
                    {utl\comment.i} */ 
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.        /* if substring( p-in-string, v-position + 1, 1 ) = "#":U */
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.        /* when "lt;":U */
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.        /* when "gt;":U */
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.        /* if substring( p-in-string, v-position + 1, 4 ) = "amp;":U */
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.        /* when "quot;":U */
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.        /* when "apos;":U */
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.        /* otherwise */
                            end case.       /* case substring( p-in-string, v-position + 1, 5 ) */
                        end.        /* NOT ( if substring( p-in-string, v-position + 1, 4 ) = "amp;":U ) */
                    end.        /* otherwise */
                end case.       /* case substring( p-in-string, v-position + 1, 3 ) */
            end.        /* NOT ( if substring( p-in-string, v-position + 1, 1 ) = "#":U ) */
        end.        /* NOT ( if v-last-position = 0 ) */
    end.
end.
end . /* xmlchar-encode */

/*==========================================================================*/
{&CommentStartNoClass}
method private void xmlchar-read-integer (input  p-input-string       as character,
                                          output p-output-integer     as integer,
                                          output p-success            as logical):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}

procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
{utl\comment.i} */ 
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end. /* read-integer */



/* $Workfile$ e n d */