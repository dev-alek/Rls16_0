define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-format-type        as character        no-undo.
define input parameter p-export-type        as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр документов, экспортированных в каталог".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
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
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
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
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
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
        end.
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
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
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
        end.
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
                    run xmlchar-read-integer in this-procedure
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
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
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
end.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_xmlparse-attrs no-undo
field field-name as character
field attr-code as character
field attr-value as character
index pi is unique primary
field-name attr-code
.
procedure xmlparse :
define input parameter p-handle         as handle           no-undo.
define input parameter p-XML-buffer     as character        no-undo.
define input parameter p-call-mode      as character        no-undo.
    define variable v-procedure-type        as character    no-undo.
    define variable v-procedure-name        as character    no-undo.
    define variable v-temp-string           as character    no-undo.
    define variable v-current-position      as integer      no-undo.
    define variable v-end-position          as integer      no-undo.
    define variable v-text-position         as integer      no-undo.
    define variable v-input-buffer-length   as integer      no-undo.
    define variable v-handle                as handle       no-undo.
    define variable v-call-mode             as character    no-undo.
    define variable v-proc-type             as character    no-undo.
    define variable v-proc-name             as character    no-undo.
    define variable v-decode-string         as character    no-undo.
do
on error undo, return error
:
    if not valid-handle( p-handle )
    then do:
        return.
    end.
    assign
        v-end-position          = 1
        v-current-position      = 1
        v-input-buffer-length   = length( p-XML-buffer )
    .
    do
    while v-end-position < v-input-buffer-length
    :
        assign
            v-current-position = index( p-XML-buffer, "<":U, v-end-position )
        .
        if v-current-position = 0
        then do:
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position )
            .
            run xmlchar-decode in this-procedure (
                  input v-decode-string
                , output v-temp-string
            ).
            assign
                v-handle     = p-handle
                v-call-mode  = p-call-mode
                v-proc-type  = 'text':U
                v-proc-name  = '':U
            .
            run run-callback-procedure in this-procedure (
                  input v-handle
                , input v-call-mode
                , input v-proc-type
                , input v-proc-name
                , input v-temp-string
            ).
            assign
                v-end-position = v-input-buffer-length
            .
        end.
        else do:
            if v-current-position > v-end-position
            then do:
                assign
                    v-decode-string = substring( p-XML-buffer, v-end-position, v-current-position - v-end-position )
                .
                run xmlchar-decode in this-procedure (
                      input v-decode-string
                    , output v-temp-string
                ).
                assign
                    v-end-position = v-current-position
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position + 1, 1 )
            .
            if v-decode-string = "/":U
            then do:
                assign
                    v-procedure-type    = "tag-end":U
                    v-end-position      = v-current-position + 1
                .
            end.
            else do:
                assign
                    v-procedure-type    = "tag-start":U
                    v-end-position      = v-current-position
                .
            end.
            assign
                v-current-position  = index(p-XML-buffer, "/>":U, v-end-position)
            .
            if v-current-position <= v-end-position
            then do:
                assign
                    v-current-position  = index(p-XML-buffer, ">":U, v-end-position)
                .
            end.
            assign
                v-end-position      = v-end-position + 1
            .
            if v-current-position <= v-end-position
            then do:
                run run-cb-xmlparse-error in this-procedure
                                        (   input p-handle
                                        ,   input 'Ошибка: знак < без завершающего > на той же строке'
                                        ).
                assign
                    v-temp-string   = "<":U + substring(p-XML-buffer, v-end-position)
                    v-end-position  = v-input-buffer-length
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            else do:
                assign
                    v-temp-string   = trim( substring(      p-XML-buffer
                                                        ,   v-end-position
                                                        ,   v-current-position - v-end-position
                                          )          )
                    v-text-position = index( v-temp-string, " ":U )
                .
                if v-text-position <> 0
                then do:
                    assign
                        v-procedure-name    =   trim( substring(      v-temp-string
                                                                    ,   1
                                                                    ,   v-text-position
                                                      )          )
                        v-temp-string       =   trim( substring(    v-temp-string
                                                                ,   v-text-position + 1
                                                    )          )
                    .
                end.
                else do:
                    assign
                        v-procedure-name    =   v-temp-string
                        v-temp-string       =   "":U
                    .
                end.
                assign
                    v-end-position      = v-current-position + 1
                .
                assign
                    v-handle          = p-handle
                    v-call-mode       = p-call-mode
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-procedure-type
                    , input v-procedure-name
                    , input v-temp-string
                ).
            end.
        end.
    end.
end.
end procedure.
procedure run-callback-procedure :
define input parameter p-handle             as handle           no-undo.
define input parameter p-call-mode          as character        no-undo.
define input parameter p-procedure-type     as character        no-undo.
define input parameter p-procedure-name     as character        no-undo.
define input parameter p-param-value        as character        no-undo.
    define variable v-data-type         as character            no-undo.
    define variable v-data-value        as character            no-undo.
    define variable v-procedure-name    as character            no-undo.
    define variable v-procedure-exists  as logical      no-undo.
do
on error undo, return error
:
    if p-call-mode = "call-all":U
    or p-call-mode = "call-named":U
    then do:
        case p-procedure-type :
            when "text":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-text":U
                .
            end.
            when "tag-end":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-end-":U + p-procedure-name
                .
            end.
            when "tag-start":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-start-":U + p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-procedure-name = p-procedure-name
                .
            end.
        end case.
        if p-handle :get-signature( v-procedure-name ) = "":U
        then do:
            assign
                v-procedure-exists = no
            .
        end.
        else do:
            assign
                v-procedure-exists = yes
            .
        end.
        if v-procedure-exists = yes
        then do:
            run value(v-procedure-name) in p-handle (input p-param-value) no-error.
            if error-status :error
            then do:
                run run-cb-xmlparse-error in this-procedure (
                    input p-handle
                    , input "Ошибка при вызове программы " + v-procedure-name
                ).
            end.
        end.
    end.
    if ( p-call-mode = "call-all":U
        and v-procedure-exists <> yes )
    or p-call-mode = "call-unnamed":U
    then do:
        case p-procedure-type :
            when 'text':U
            then do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-param-value
                .
            end.
            when 'tag-end':U
            then do:
                assign
                    v-data-type     = 'tag-end':U
                    v-data-value    = p-procedure-name
                .
            end.
            when 'tag-start':U
            then do:
                assign
                    v-data-type     = 'tag-start':U
                    v-data-value    = p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-procedure-name
                .
            end.
        end case.
        run run-cb-xmlparse-procedure-not-found in this-procedure (
              input p-handle
            , input v-data-type
            , input v-data-value
            , input p-param-value
        ).
    end.
end.
end procedure.
procedure run-cb-xmlparse-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.
    if lookup("cb-xmlparse-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-error in p-handle  (input p-error-message).
    end.
end.
end procedure.
procedure run-cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-data-type         as char no-undo.
    def input parameter p-data-value        as char no-undo.
    def input parameter p-param-value       as char no-undo.
    if lookup("cb-xmlparse-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-procedure-not-found in p-handle    (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlparse-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlparse-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlparse-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlparse-procedure-not-found"
                                ).
    end.
end.
end procedure.
procedure cb-xmlparse-attributes :
define input  parameter p-handle            as handle no-undo.
define input  parameter p-field-name        as character no-undo .
define input  parameter p-field-value       as character no-undo .
define variable ii as integer no-undo init 1.
define variable v-input-buffer-length   as integer no-undo.
define variable v-dc as logical no-undo .
define variable v-sc as logical no-undo .
define variable v-eq as logical no-undo .
define variable v-char as character no-undo .
define variable v-code as character no-undo .
define variable v-value as character no-undo .
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if index(p-field-value, '>':U) > 0 then do:
      run run-cb-xmlparse-error in this-procedure
                              (   input p-handle
                              ,   input substitute("Ошибка: тэг &1 содержит другие тэги", p-field-name)
                              ).
    end.
    assign
    p-field-value = trim(p-field-value)
    .
    for each buf_temp_xmlparse-attrs where
            buf_temp_xmlparse-attrs.field-name = p-field-name:
      delete buf_temp_xmlparse-attrs.
    end.
    assign
    v-input-buffer-length = length( p-field-value )
    .
    do while ii <= v-input-buffer-length:
      assign
      v-char = substr(p-field-value, ii, 1)
      ii = ii + 1
      .
      CASE v-char:
        when "=":U then do:
          if v-eq
          and not v-dc
          and not v-sc then do:
            return error.
          end.
          assign
          v-eq = yes
          .
        end.
        when chr(34) then do:
        if v-eq then
        assign
        v-dc = not(v-dc)
        .
        else return error.
        end.
        when chr(39) then do:
        if v-eq then
        assign
        v-sc = not(v-sc)
        .
        else return error.
        end.
        when chr(32) then do:
          if not v-dc
          and not v-sc
          then do:
            assign
            v-sc = no
            v-dc = no
            v-eq = no
            .
            create buf_temp_xmlparse-attrs.
            assign
            buf_temp_xmlparse-attrs.field-name = p-field-name
            buf_temp_xmlparse-attrs.attr-code  = v-code
            buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins chr(34) then chr(34) else chr(39)))
            v-code = "":U
            v-value = "":U
            .
          end.
        end.
      END CASE.
      if not v-eq
      then do:
        if not v-char = chr(32) then
        assign
        v-code = v-code + v-char
        .
      end.
      else do:
        if v-char <> "=":U
        then
        assign
        v-value = v-value + v-char
        .
      end.
    end.
    if v-code <> "":U then do:
      create buf_temp_xmlparse-attrs.
      assign
      buf_temp_xmlparse-attrs.field-name = p-field-name
      buf_temp_xmlparse-attrs.attr-code  = v-code
      buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins chr(34) then chr(34) else chr(39)))
      .
    end.
  end.
end procedure.
FUNCTION cb-xmlparse-get-attr returns character (
      input p-handle        as handle
    , input p-field-name    as character
    , input p-field-value   as character
    , input p-attr-code     as character
    , input p-reparse       as logical
) :
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if p-reparse then do:
      run cb-xmlparse-attributes in this-procedure (
                                                    input p-handle
                                                  , input p-field-name
                                                  , input p-field-value) no-error .
      if error-status:error then return ? .
    end.
    find first buf_temp_xmlparse-attrs no-lock where
              buf_temp_xmlparse-attrs.field-name = p-field-name
          AND buf_temp_xmlparse-attrs.attr-code   = p-attr-code no-error .
    if not avail buf_temp_xmlparse-attrs then return ?.
    return buf_temp_xmlparse-attrs.attr-value.
  end.
end FUNCTION.
FUNCTION cb-xmlparse-get-date returns date (
                                            input p-string as character):
define variable v-date as date.
if index(p-string, "-":U) = 0
or NOT (length(p-string) = 10
        or
        length(p-string) = 19)
then return error.
assign
v-date =  date(
          int( substr( p-string, 6, 2 ) ) ,
          int( substr( p-string, 9, 2 ) ),
          int( substr( p-string, 1, 4 ) )
            )
no-error .
if error-status:error then return error.
return v-date.
END FUNCTION.
FUNCTION cb-xmlparse-get-time returns integer (input p-string as character):
define variable v-time as integer no-undo .
define variable v-shift as integer no-undo .
if index(p-string, ":":U) = 0
or not (
        length(p-string) = 19
        or
        length(p-string) = 8
        )
then return error.
if length(p-string) = 19 then v-shift = 11.
assign
v-time =  int( substr( p-string, v-shift + 1, 2 ) ) * 3600 +
          int( substr( p-string, v-shift + 4, 2 ) ) * 60  +
          int( substr( p-string, v-shift + 7, 2) )
no-error .
if error-status:error then return error.
return v-time.
END FUNCTION.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_xmlview no-undo
    field record-id     as integer
    field filename      as character
    field doc-code      as character
    field ext-doc-type  as character
    field fact-date     as date
    field doc-date      as date
    field doc-sum       as decimal
    field ps            as character
    index pi is primary unique record-id
    index dc doc-code
    index et ext-doc-type
.
define variable v-xmlview-format-type   as character    no-undo.
define variable v-xmlview-export-type   as character    no-undo.
procedure xmlview-clear-temp_xmlview :
    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    for each buf_temp_xmlview
    :
        delete buf_temp_xmlview.
    end.
end.
end procedure.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define stream xmlvdoc-in.
define variable v-xmlvdoc-current-file-row  as integer      no-undo.
define variable v-xmlvdoc-current-rowid     as rowid        no-undo.
define variable v-xmlvdoc-current-id        as integer      no-undo.
define variable v-xmlvdoc-current-tag-path  as character    no-undo.
define variable v-xmlvdoc-tag-list          as character extent 3 init[ "operation":U, "":U, "":U ]  no-undo.
define variable v-xmlvdoc-current-tag       as integer              no-undo.
define variable v-xmlvdoc-current-filename  as character    no-undo.
procedure xmlvdoc-parse-file :
define input parameter p-filename       as character        no-undo.
define input parameter p-full-filename  as character        no-undo.
    define variable v-buffer-string    as character    no-undo.
do
on error undo, return error
:
    assign
        v-xmlvdoc-current-filename  = p-filename
        v-xmlview-export-type       = 'DOC':U
    .
    input stream xmlvdoc-in from value( p-full-filename ).
    repeat
    :
        import stream xmlvdoc-in unformatted
            v-buffer-string
        .
        assign
            v-xmlvdoc-current-file-row = v-xmlvdoc-current-file-row + 1
        .
        run xmlparse in this-procedure (
              input this-procedure
            , input v-buffer-string
            , input "call-named":U
        ).
    end.
end.
end procedure.
procedure cb-xmlparse-tag-start-doc :
define input parameter p-parameters-string  as character        no-undo.
    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
        end.
        when 'flat':U
        then do:
            create buf_temp_xmlview.
            assign
                v-xmlvdoc-current-id        = v-xmlvdoc-current-id + 1
                buf_temp_xmlview.record-id  = v-xmlvdoc-current-id
                v-xmlvdoc-current-tag       = 1
                buf_temp_xmlview.filename   = v-xmlvdoc-current-filename
            .
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-doc :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
        end.
        when 'flat':U
        then do:
            assign
                v-xmlvdoc-current-tag = 0
            .
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-operation :
define input parameter p-parameters-string  as character        no-undo.
    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            create buf_temp_xmlview.
            assign
                v-xmlvdoc-current-id        = v-xmlvdoc-current-id + 1
                buf_temp_xmlview.record-id  = v-xmlvdoc-current-id
                v-xmlvdoc-current-tag       = 1
                buf_temp_xmlview.filename   = v-xmlvdoc-current-filename
            .
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-operation :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            assign
                v-xmlvdoc-current-tag = 0
            .
            if v-xmlvdoc-tag-list[ 2 ] <> "":U
            or v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга операции"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-docID :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "docID":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-docID :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "docID":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-referenceNo :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "referenceNo":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-referenceNo :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга номера документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "referenceNo":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-codeOperation :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-codeOperation :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга кода операции"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "codeOperation":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-dateFact :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-dateFact :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга фактической даты"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "dateFact":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-dateDoc :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-dateDoc :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга даты документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "dateDoc":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-docSum :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "docSum":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 0
            then do:
                assign
                    v-xmlvdoc-tag-list[ 1 ] = "docSum":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-docSum :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга суммы документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "docSum":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 1 ] = "docSum":U
            and v-xmlvdoc-current-tag   = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 1 ] = "":U
                    v-xmlvdoc-current-tag   = 0
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-sumr :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 2
            and v-xmlvdoc-tag-list[ 2 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 3 ] = "sumr":U
                    v-xmlvdoc-current-tag   = 3
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            and v-xmlvdoc-tag-list[ 1 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "sumr":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-sumr :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] = "sumr":U
            and v-xmlvdoc-current-tag   = 3
            and v-xmlvdoc-tag-list[ 2 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 3 ] = "":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-tag-list[ 2 ] = "sumr":U
            and v-xmlvdoc-current-tag   = 2
            and v-xmlvdoc-tag-list[ 1 ] = "docSum":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-start-comment :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "comment":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "comment":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-comment :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга комментария"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-current-tag   = 2
            and v-xmlvdoc-tag-list[ 2 ] = "comment":U
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-text :
define input parameter p-input-string  as character        no-undo.
    define variable v-success    as logical      no-undo.
    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    if v-xmlvdoc-current-tag > 0
    then do:
        case v-xmlvdoc-tag-list[ v-xmlvdoc-current-tag ]
        :
            when "docID":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.doc-code = p-input-string
                    .
                end.
            end.
            when "dateDoc":U
            then do:
                find first buf_temp_xmlview
                    where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    run xmlvdoc-assign-date in this-procedure (
                        input p-input-string
                        , output buf_temp_xmlview.doc-date
                        , output v-success
                    ).
                end.
            end.
            when "dateFact":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    run xmlvdoc-assign-date in this-procedure (
                          input p-input-string
                        , output buf_temp_xmlview.fact-date
                        , output v-success
                    ).
                end.
            end.
            when "codeOperation":U
            then do:
                find first buf_temp_xmlview
                    where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.ext-doc-type = p-input-string
                    .
                end.
            end.
            when "referenceNo":U
            then do:
                find first buf_temp_xmlview
                    where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.doc-code = p-input-string
                    .
                end.
            end.
            when "sumr":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    run xmlvdoc-assign-decimal in this-procedure (
                          input p-input-string
                        , output buf_temp_xmlview.doc-sum
                        , output v-success
                    ).
                end.
            end.
            when "comment":U
            then do:
                find first buf_temp_xmlview
                     where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
                no-error.
                if available buf_temp_xmlview
                then do:
                    assign
                        buf_temp_xmlview.ps = buf_temp_xmlview.ps + p-input-string
                    .
                end.
            end.
        end case.
    end.
end.
end procedure.
procedure xmlvdoc-assign-decimal :
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-decimal    as decimal          no-undo.
define output parameter p-success           as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-decimal = decimal( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-decimal    = 0.0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end procedure.
procedure xmlvdoc-assign-date :
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-date       as date             no-undo.
define output parameter p-success           as logical          no-undo.
do
on error undo, return error
:
    assign
        p-success       = no
        p-output-date   = ?
    .
    if num-entries( p-input-string, ".":U ) = 3
    then do:
        assign
            p-output-date = date(
                      integer( entry( 2, p-input-string, ".":U ) )
                    , integer( entry( 1, p-input-string, ".":U ) )
                    , integer( entry( 3, p-input-string, ".":U ) ) )
        no-error.
        if error-status :error <> yes
        then do:
            assign
                p-success           = yes
            .
        end.
    end.
end.
end procedure.
procedure cb-xmlparse-tag-start-linedoc :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-current-tag = 1
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "linedoc":U
                    v-xmlvdoc-current-tag   = 2
                .
            end.
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure cb-xmlparse-tag-end-linedoc :
define input parameter p-parameters-string  as character        no-undo.
do
on error undo, return error
:
    case v-xmlview-format-type
    :
        when 'tree':U
        then do:
            if v-xmlvdoc-tag-list[ 3 ] <> "":U
            then do:
                run xmlvdoc-error in this-procedure (
                    input substitute( "&2&1&3&1    &4,&1    &5,&1    &6"
                                        , chr(10)
                                        , "При закрытии тэга строки документа"
                                        , "не был закрыт тэг предыдущего уровня. Список открытых тэгов:"
                                        , v-xmlvdoc-tag-list[ 1 ]
                                        , v-xmlvdoc-tag-list[ 2 ]
                                        , v-xmlvdoc-tag-list[ 3 ]
                                    )
                ).
            end.
            if v-xmlvdoc-tag-list[ 2 ] = "linedoc":U
            and v-xmlvdoc-current-tag   = 2
            then do:
                assign
                    v-xmlvdoc-tag-list[ 2 ] = "":U
                    v-xmlvdoc-current-tag   = 1
                .
            end.
        end.
        when 'flat':U
        then do:
        end.
    end case.
end.
end procedure.
procedure xmlvdoc-error :
define input parameter p-error-text     as character        no-undo.
    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    output to value( v-xmlvdoc-current-tag-path + "\xmlvdoc.log" ) append.
        find first buf_temp_xmlview
             where buf_temp_xmlview.record-id = v-xmlvdoc-current-id
        no-error.
        if available buf_temp_xmlview
        then do:
            put unformatted
                substitute( "Запись номер &1. Номер документа &2"
                            , buf_temp_xmlview.record-id
                            , buf_temp_xmlview.doc-code
                          )
            .
            put skip.
        end.
        put unformatted p-error-text.
        put skip.
    output close.
end.
end procedure.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-filelist-total-file-num           as integer      no-undo .
define variable v-filelist-total-dir-num            as integer      no-undo .
define variable v-filelist-main-procedure-handle    as handle       no-undo .
define variable v-filelist-main-procedure-name      as character    no-undo .
define temp-table temp-dirlist no-undo
    field dir-full-name     as character
    field dir-short-name    as character
    field need-process      as logical
    index xpk is primary unique dir-full-name
.
define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  field directory-name   as character
  field full-name        as character
  field dir-short-name   as character
  field need-process     as logical
  index xpk is unique primary full-name
  index xie1 directory-name file-name
  index xie2 directory-name file-name-no-ext
  index xie3 file-name
  index xie4 file-name-no-ext
  index xie5 need-process file-name
  .
define stream dir-list .
procedure filelist-get-file-num :
  define output parameter p-file-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-file-num = v-filelist-total-file-num
    .
  end.
end procedure.
procedure filelist-clear :
  do
  on error undo, return error return-value
  :
    define buffer buf_filelist for temp-filelist .
    assign
      v-filelist-total-file-num = 0
    .
    for each buf_filelist
    on error undo, return error
    :
      delete buf_filelist .
    end.
  end.
end procedure.
procedure filelist-init :
  do
  on error undo, return error
  :
    define input parameter p-dir-name       as character no-undo .
    define input parameter p-filter-ext     as logical   no-undo .
    define input parameter p-ext-list       as character no-undo .
    define input parameter p-dir-short-name as character no-undo .
    define buffer buf_temp-filelist for temp-filelist .
    if p-filter-ext = true
       and p-ext-list = ?
    or (p-filter-ext = false
       and p-ext-list <> ?
       and p-ext-list <> "":U
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "p-filter-ext" p-filter-ext skip
        "p-ext-list"   p-ext-list   skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir-name
    on error undo, return error return-value
    :
      delete buf_temp-filelist .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    define variable v-extension             as character no-undo .
    define variable v-file-name-without-ext as character no-undo .
    repeat
    on error undo, return error
    :
      import stream dir-list v-file v-path v-mask .
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
      end.
      else do:
        next .
      end.
      if num-entries(v-file, '.':u) > 1
      then do:
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        assign
          v-extension = ''
          v-file-name-without-ext = v-file
        .
      end.
      if p-filter-ext = true
      then do:
        if lookup(v-extension, p-ext-list) = 0
        then do:
          next .
        end.
      end.
      create buf_temp-filelist .
      assign
        buf_temp-filelist.file-name        = v-file
        buf_temp-filelist.directory-name   = p-dir-name
        buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
        buf_temp-filelist.file-extension   = v-extension
        buf_temp-filelist.full-name        = p-dir-name + '/':u + v-file
        buf_temp-filelist.dir-short-name   = p-dir-short-name
      .
      assign
        v-filelist-total-file-num = v-filelist-total-file-num + 1
      .
      if v-filelist-main-procedure-handle <> ?
      then do:
        run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle
          (input "file":U
          , input v-filelist-total-file-num
          , input buf_temp-filelist.full-name
          , input buf_temp-filelist.file-name
          ) no-error.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-subdir-init" skip(1)
            skip "Ошибка при вызове процедуры вывода"
            skip "результатов сканирования каталогов."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
    input stream dir-list close .
    return.
  end.
end procedure.
procedure filelist-dirlist-init-by-list :
  do
  on error undo, return error
  :
    define input parameter p-root-dir   as character no-undo .
    define input parameter p-dir-list   as character no-undo .
    define input parameter p-filter-ext as logical   no-undo .
    define input parameter p-ext-list   as character no-undo .
    define variable v-num-appdir as integer   no-undo .
    do v-num-appdir = 1 to num-entries(p-dir-list)
    :
      define variable v-curr-dir  as character no-undo .
      assign
        v-curr-dir = entry(v-num-appdir, p-dir-list)
      .
      run filelist-init in this-procedure
        (input p-root-dir + '/':u + v-curr-dir
        ,input p-filter-ext
        ,input p-ext-list
        ,input v-curr-dir
        ) .
    end.
  end.
end procedure.
procedure filelist-dirlist-clear :
  do
  on error undo, return error
  :
    define buffer buf_temp-dirlist for temp-dirlist .
    assign
        v-filelist-total-dir-num = 0
    .
    for each buf_temp-dirlist
    on error undo, return error
    :
      delete buf_temp-dirlist .
    end.
  end.
end procedure.
procedure filelist-dirlist-subdir-init :
define input parameter p-dir-name   as character no-undo .
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    file-in-directory:
    repeat
    on error undo, return error
    :
        import stream dir-list
            v-file
            v-path
            v-mask
        .
        if  v-mask = ?
        or index( v-mask, 'D':u ) = 0
        or v-file = ".":U
        or v-file = "..":U
        then do:
            next file-in-directory.
        end.
        else do:
            find first buf_temp-dirlist
                 where buf_temp-dirlist.dir-full-name    = v-path
            no-error.
            if not available buf_temp-dirlist
            then do:
                create buf_temp-dirlist .
                assign
                    buf_temp-dirlist.dir-full-name    = v-path
                    buf_temp-dirlist.dir-short-name   = v-file
                    buf_temp-dirlist.need-process     = yes
                .
            end.
            assign
                v-filelist-total-dir-num = v-filelist-total-dir-num + 1
            .
            if v-filelist-main-procedure-handle <> ?
            then do:
                run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle (
                      input "dir":U
                    , input v-filelist-total-dir-num
                    , input buf_temp-dirlist.dir-full-name
                    , input buf_temp-dirlist.dir-short-name
                ) no-error.
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "filelist-dirlist-subdir-init"
                        skip(1)
                        skip "Ошибка при вызове процедуры вывода"
                        skip "результатов сканирования каталогов."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    input stream dir-list close .
end.
end procedure.
procedure filelist-dirlist-init :
define input parameter p-dir-name   as character no-undo .
    define variable v-file  as character no-undo.
    define variable v-path  as character no-undo.
    define variable v-mask  as character no-undo.
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    for each buf_temp-dirlist
       where buf_temp-dirlist.dir-full-name begins file-info :full-pathname
    on error undo, return error return-value
    :
        delete buf_temp-dirlist .
    end.
    create buf_temp-dirlist .
    assign
        buf_temp-dirlist.dir-full-name    = file-info :full-pathname
        buf_temp-dirlist.dir-short-name   = file-info :file-name
        buf_temp-dirlist.need-process     = yes
    .
    do
    while available buf_temp-dirlist
    on error undo, return error
    :
        run filelist-dirlist-subdir-init in this-procedure (
            input buf_temp-dirlist.dir-full-name
        ).
        assign
            buf_temp-dirlist.need-process = no
        .
        find first buf_temp-dirlist
             where buf_temp-dirlist.need-process = yes
        no-error.
    end.
end.
end procedure.
procedure filelist-set-procedure-handle :
define input parameter p-proc-handle    as handle           no-undo.
define input parameter p-proc-name      as character        no-undo.
    define variable v-signature    as character    no-undo.
do
on error undo, return error
:
    if p-proc-handle = ?
    or not valid-handle( p-proc-handle )
    or p-proc-handle :get-signature( p-proc-name ) = ""
    then do:
        assign
            v-filelist-main-procedure-handle = ?
            v-filelist-main-procedure-name   = ""
        .
        undo, return error "filelist-set-procedure-handle: Ошибка передачи handle основной процедуры или имени процедуры обработки результатов сканирования каталогов.".
    end.
    else do:
        assign
            v-signature = p-proc-handle :get-signature( p-proc-name )
        .
        if entry(   1, v-signature )    = "PROCEDURE":U
        and entry( 1, entry(  3, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  3, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  4, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  4, v-signature ), " ":U ) = "INTEGER":U
        and entry( 1, entry(  5, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  5, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  6, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  6, v-signature ), " ":U ) = "CHARACTER":U
        then do:
            assign
                v-filelist-main-procedure-handle = p-proc-handle
                v-filelist-main-procedure-name   = p-proc-name
            .
        end.
        else do:
            assign
                v-filelist-main-procedure-handle = ?
                v-filelist-main-procedure-name   = ""
            .
            undo, return error "filelist-set-procedure-handle: Ошибка задания параметров процедуры обработки результатов сканирования каталогов.".
        end.
    end.
end.
end procedure.
procedure filelist-clear-procedure-handle :
do
on error undo, return error
:
    assign
        v-filelist-main-procedure-handle = ?
        v-filelist-main-procedure-name   = ?
    .
end.
end procedure.
procedure filelist-build-by-dirlist :
    define buffer buf_temp-dirlist      for temp-dirlist.
do
for buf_temp-dirlist
on error undo, return error
:
    for each buf_temp-dirlist
    on error undo, return error
    :
        run filelist-init in this-procedure (
              input buf_temp-dirlist.dir-full-name
            , input no
            , input "":U
            , input buf_temp-dirlist.dir-short-name
        ).
    end.
end.
end procedure.
procedure filelist-check-dir-exists :
define input parameter p-dir-name   as character        no-undo.
define output parameter p-exists    as logical          no-undo.
do
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :file-type <> ?
    and substring( file-info :file-type, 1, 1 ) = "D":U
    then do:
        assign
            p-exists = yes
        .
    end.
    else do:
        assign
            p-exists = no
        .
    end.
end.
end procedure.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable v-bgerddoc-last-record-id    as integer      no-undo.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-search
     LABEL "Найти"
     SIZE 10 BY 1.
DEFINE BUTTON bt-change-cat
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON bt-read
     LABEL "&Чтение"
     SIZE 10 BY 1.
DEFINE VARIABLE fi-catalog AS CHARACTER FORMAT "X(256)":U
     LABEL "Каталог с файлами XML"
     VIEW-AS FILL-IN
     SIZE 63.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-search-string AS CHARACTER FORMAT "X(256)":U
     LABEL "Пои&ск по номеру"
     VIEW-AS FILL-IN
     SIZE 15.75 BY 1 NO-UNDO.
DEFINE QUERY br-table FOR
      temp_xmlview SCROLLING.
DEFINE BROWSE br-table
  QUERY br-table DISPLAY
      temp_xmlview.record-id column-label "N п/п" format ">>>>9"
    temp_xmlview.filename column-label "Файл"  format "X(8)"
    temp_xmlview.doc-code  column-label "Номер док-та"  format "X(14)"
    temp_xmlview.ext-doc-type  column-label "Тип" format "X(3)"
    temp_xmlview.doc-date  column-label "Дата" format "99/99/9999"
    temp_xmlview.fact-date  column-label "Дата факт" format "99/99/9999"
    temp_xmlview.doc-sum  column-label "Сумма " format "->>>,>>>,>>>,>>9.99 "
    temp_xmlview.ps  column-label "Примечание" format "X(60)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.75 BY 18.75.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 2
     bt-read AT ROW 1 COL 12
     b-help AT ROW 1 COL 89.38
     fi-catalog AT ROW 2.17 COL 23 COLON-ALIGNED
     bt-change-cat AT ROW 2.25 COL 89.38
     fi-search-string AT ROW 3.42 COL 16.75 COLON-ALIGNED
     b-search AT ROW 3.42 COL 34.75
     br-table AT ROW 4.67 COL 1.63
     SPACE(0.49) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр выгрузки XML".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF b-search IN FRAME Dialog-Frame
DO:
    define variable v-found             as logical      no-undo.
    define variable v-founded-recid     as recid        no-undo.
    define variable v-focused-row       as integer      no-undo.
    assign
        fi-search-string
    .
    assign
        v-focused-row      = br-table :focused-row in frame Dialog-Frame.
    .
    run search-doc-num in this-procedure (
          input fi-search-string
        , output v-founded-recid
        , output v-found
    ).
    if v-found = yes
    then do:
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame no-error.
        reposition br-table to recid v-founded-recid.
    end.
    else do:
        message
            "Запись не найдена."
        view-as alert-box information.
    end.
END.
ON CHOOSE OF bt-change-cat IN FRAME Dialog-Frame
DO:
    define variable v-full-dir-name     as character    no-undo.
    define variable v-dir-type          as character    no-undo.
    define variable v-can-write         as logical      no-undo.
    run gbl/dir-sel.p (
          output fi-catalog
        , output v-dir-type
        , output v-can-write
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора каталога."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        fi-catalog
    with frame Dialog-Frame.
END.
ON CHOOSE OF bt-read IN FRAME Dialog-Frame
DO:
    define variable v-yesno    as logical      no-undo.
    message
        "Процедура чтения файлов из каталога"
        skip "может занять много времени."
        skip(1)
        skip "Прочитать файлы?"
    view-as alert-box question
    buttons ok-cancel
    update v-yesno.
    if v-yesno = no
    then do:
        undo, return no-apply.
    end.
if session :set-wait-state( "compiler" ) then.
    if fi-catalog :screen-value <> "":U
    then do:
        run read-files in this-procedure (
            input fi-catalog :screen-value
        ).
    end.
    message
        "Чтение файлов каталога завершено."
    view-as alert-box information.
    OPEN QUERY br-table FOR EACH temp_xmlview NO-LOCK.
if session :set-wait-state( "" ) then.
END.
ON LEAVE OF fi-search-string IN FRAME Dialog-Frame
DO:
    assign
        v-bgerddoc-last-record-id = 0
    .
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-table :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-fields in this-procedure .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-file-type :
define input parameter p-filename       as character        no-undo.
define input parameter p-full-filename  as character        no-undo.
define output parameter p-is-this-type  as logical          no-undo.
do
on error undo, return error
:
    case p-export-type
    :
        when "DOC":U
        then do:
            if substring( p-filename, 1, 1 ) = "d":U
            then do:
                assign
                    p-is-this-type = yes
                .
            end.
            else do:
                assign
                    p-is-this-type = no
                .
            end.
        end.
        otherwise do:
            assign
                p-is-this-type = no
            .
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-catalog fi-search-string
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-read b-help bt-change-cat fi-search-string b-search br-table
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-table FOR EACH temp_xmlview NO-LOCK.
END PROCEDURE.
PROCEDURE get-init-catalog :
define output parameter p-catalog   as character        no-undo.
do
on error undo, return error
:
    case p-format-type
    :
        when 'tree':U
        then do:
            case p-export-type
            :
                when 'DOC':U
                then do:
                    get-key-value section "BGE" key "Dirfrg-acc" value p-catalog.
                    if p-catalog = ?
                    then do:
                        message
                        skip "Не найден параметр ini-файла, определяющий каталог экспорта."
                        skip(1)
                        skip "Обратитесь к администратору."
                        view-as alert-box error.
                        undo, return error .
                    end.
                    else do:
                        assign
                            p-catalog = p-catalog + "\":U + "exp-acc":U
                        .
                    end.
                end.
                otherwise do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Не определено чтение файлов выгрузки"
                        skip "с типом экспорта" p-export-type
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end case.
        end.
        when 'flat':U
        then do:
            case p-export-type
            :
                when 'DOC':U
                then do:
                    get-key-value section "BGE" key "outdir" value p-catalog.
                    if p-catalog = ?
                    then do:
                        message
                        skip "Не найден параметр ini-файла, определяющий каталог экспорта."
                        skip(1)
                        skip "Обратитесь к администратору."
                        view-as alert-box error.
                        undo, return error .
                    end.
                end.
                otherwise do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Не определено чтение файлов выгрузки"
                        skip "с типом экспорта" p-export-type
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end case.
        end.
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Неправильно указан формат экспорта."
                skip "Невозможно определить каталог выгрузки."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    assign
        frame Dialog-Frame :title = substitute( "&1. Формат выгрузки: &2. Тип документов: &3"
                                                , frame Dialog-Frame :title
                                                , ( if p-format-type = 'flat':U then "плоский" else "дерево" )
                                                , "складские документы"
                                     )
    .
    assign
        v-xmlview-format-type = p-format-type
        v-xmlview-export-type = p-export-type
    .
    run get-init-catalog in this-procedure (
        output fi-catalog
    ) no-error.
    if error-status :error
    then do:
        message
                 "Не удалось определить каталог выгрузки."
            skip "Выберите каталог для чтения файлов."
        view-as alert-box warning.
        assign
            fi-catalog = "":U
        .
    end.
end.
END PROCEDURE.
PROCEDURE read-files :
define input parameter p-full-path  as character        no-undo.
    define variable v-is-this-type  as logical      no-undo.
    define variable v-short-name    as character    no-undo.
    define buffer buf_temp-filelist     for temp-filelist.
do
for buf_temp-filelist
on error undo, return error
:
    assign
        v-short-name = entry( num-entries( p-full-path, "\":U ), p-full-path, "\":U )
    .
    run filelist-clear in this-procedure .
    run filelist-init in this-procedure (
          input p-full-path
        , input yes
        , input "xml":U
        , input v-short-name
    ).
    filelist-parse:
    for each buf_temp-filelist
    :
        run check-file-type in this-procedure (
              input buf_temp-filelist.file-name
            , input buf_temp-filelist.full-name
            , output v-is-this-type
        ).
        if v-is-this-type = yes
        then do:
            assign
                v-xmlvdoc-current-tag-path = p-full-path
            .
            run xmlvdoc-parse-file in this-procedure (
                  input buf_temp-filelist.file-name-no-ext
                , input buf_temp-filelist.full-name
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка чтения файла" buf_temp-filelist.full-name
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo filelist-parse, next filelist-parse.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE search-doc-num :
define input parameter p-search-string      as character        no-undo.
define output parameter p-founded-recid     as recid            no-undo.
define output parameter p-found             as logical          no-undo.
    define buffer buf_temp_xmlview      for temp_xmlview.
do
on error undo, return error
:
    find first buf_temp_xmlview
         where buf_temp_xmlview.record-id > v-bgerddoc-last-record-id
           and buf_temp_xmlview.doc-code begins p-search-string
    no-error.
    if available buf_temp_xmlview
    then do:
        assign
            p-found                     = yes
            v-bgerddoc-last-record-id   = buf_temp_xmlview.record-id
            p-founded-recid             = recid( buf_temp_xmlview )
        .
    end.
    else do:
        assign
            p-found                     = no
            p-founded-recid             = 0
        .
    end.
end.
END PROCEDURE.
PROCEDURE cb-xmlparse-error :
define input parameter p-error-string   as character        no-undo.
do
on error undo, return error
:
    message
        "Ошибка чтения xml-файла."
        skip p-error-string
    view-as alert-box error.
end.
END PROCEDURE.
