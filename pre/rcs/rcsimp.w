define input parameter parparentproc    as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обмен данными с РКС".
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
define stream dirstream.
define stream istream.
define stream ostream.
define variable v-first     as logical   init no        no-undo.
define temp-table temp_file no-undo
    field name as character
    field fullname as character
    field type as character
    index pi is primary unique name type
.
define temp-table temp_dir no-undo like temp_file.
define variable v-selected-object-start     as logical        no-undo.
define variable v-mail-parameters-start     as logical        no-undo.
define variable v-import-record-count       as integer        no-undo.
define variable v-mail-ReportType           as character      no-undo.
define variable v-mail-IDChannel            as character      no-undo.
define variable v-mail-ReportNumber         as character      no-undo.
define variable v-default-gds-grp-node-code as integer        no-undo.
define variable v-default-cli-grp-node-code as integer        no-undo.
define variable v-default-wrkr              as integer        no-undo.
define variable v-default-agnt              as integer        no-undo.
define variable v-default-boss              as integer        no-undo.
define variable v-unit-pieces               as character      no-undo.
define variable v-unit-divisional           as character      no-undo.
define variable v-unit-weight               as character      no-undo.
define variable v-selected-object-name      as character      no-undo.
define variable v-goods-parameter-dif-nam1  as logical  init yes no-undo.
define variable v-goods-parameter-dif-nam2  as logical  init no  no-undo.
define variable v-param-type                as character         no-undo.
define variable v-value-character           as character         no-undo.
define variable v-value-date                as date              no-undo.
define variable v-value-decimal             as decimal           no-undo.
define variable v-value-integer             as INTEGER           no-undo.
define variable v-value-logical             AS LOGICAL           no-undo.
define variable v-tth                       as handle            no-undo.
define temp-table temp_rcs-retail1bill          no-undo like rcs-retail1bill        .
define temp-table temp_rcs-retail1billitem      no-undo like rcs-retail1billitem    .
define temp-table temp_rcs-retail1subject       no-undo like rcs-retail1subject     .
define temp-table temp_rcs-retail1bank          no-undo like rcs-retail1bank        .
define temp-table temp_rcs-retail1attr          no-undo like rcs-retail1attr        .
define temp-table temp_rcs-retail1product       no-undo like rcs-retail1product     .
define temp-table temp_rcs-retail1price         no-undo like rcs-retail1price       .
define temp-table temp_rcs-retail1priceitem     no-undo like rcs-retail1priceitem   .
define temp-table temp_rcs-retail1barcode       no-undo like rcs-retail1barcode     .
define temp-table temp_rcs-retail1convolution   no-undo like rcs-retail1convolution .
define temp-table temp_rcs-retail1delete        no-undo like rcs-retail1delete      .
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure get-shops-type-and-code :
do
on error undo, return error
:
define input parameter p-shops-id           as character    no-undo.
define output parameter p-shops-obj-type    as character    no-undo.
define output parameter p-shops-obj-code    as integer      no-undo.
    define buffer buf_rcs-shops     for rcs-shops.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.id = p-shops-id
    no-error.
    if not available buf_rcs-shops
    then do:
        undo, return error "get-shops-id: Не найден объект."
                + chr(10) + "ID объекта: " + p-shops-id
        .
    end.
    else do:
        assign
            p-shops-obj-type    = buf_rcs-shops.obj-type
            p-shops-obj-code    = buf_rcs-shops.obj-code
        .
    end.
end.
end procedure.
procedure get-destination-id :
do
on error undo, return error
:
define input parameter p-destination-name   as character    no-undo.
define output parameter p-destination-id    as character    no-undo.
    define buffer buf_rcs-destn     for rcs-destn.
    find first buf_rcs-destn no-lock
         where buf_rcs-destn.name = p-destination-name
    no-error.
    if not available buf_rcs-destn
    then do:
        assign
            p-destination-id = ""
        .
    end.
    else do:
        assign
            p-destination-id = buf_rcs-destn.destination_rowid
        .
    end.
end.
end procedure.
define variable vss-include-info2 as character format "X(65)" no-undo
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
define variable vss-include-info3 as character format "X(65)" no-undo
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
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-xmlvalid-error-mode       as character    no-undo.
define variable v-xmlvalid-tag-value        as character    no-undo.
define variable v-xmlvalid-current-level    as integer      no-undo.
define variable v-xmlvalid-in-tag           as logical      no-undo.
define variable v-xmlvalid-read-vartype     as logical      no-undo.
define temp-table temp_xmlvalid-taglist no-undo
    field level-num as integer
    field tag-name  as character
    index lv  is primary unique level-num
.
define temp-table temp_xmlvalid-field-types no-undo
    field field-name as character
    field field-type as character
    index fn is primary unique field-name
.
procedure xmlvalid :
  do
  on error undo, return error
  :
    def input parameter p-handle                as handle   no-undo.
    def input parameter p-buffer-string         as char     no-undo.
    def input parameter p-xmlvalid-error-mode   as char     no-undo.
    assign
        v-xmlvalid-error-mode   = p-xmlvalid-error-mode
    .
    run xmlparse in this-procedure (
              input p-handle
            , input p-buffer-string
            , input "call-all":U
    ).
  end.
end procedure.
procedure cb-xmlparse-tag-start-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = yes
    .
    run cb-xmlparse-procedure-not-found in this-procedure (
          input "tag-start":U
        , input "varType":U
        , input p-param
    ).
end.
end procedure.
procedure cb-xmlparse-tag-end-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = no
    .
    define variable v-vartype-list     as character         no-undo.
    for each temp_xmlvalid-field-types
    :
        if index( "character,integer,decimal,date,logical", temp_xmlvalid-field-types.field-type ) = 0
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен неверно. "
                                                    + "Тэг " + temp_xmlvalid-field-types.field-name
                                                    + " не будет проверен на соответствие типу данных"
                                        ).
            delete temp_xmlvalid-field-types.
        end.
        else do:
                                        assign
                                            v-vartype-list = v-vartype-list + temp_xmlvalid-field-types.field-name
                                            + temp_xmlvalid-field-types.field-type + chr(10)
                                        .
        end.
    end.
    run cb-xmlparse-procedure-not-found in this-procedure (
                                        input "tag-end":U
                                        , input "varType":U
                                        , input p-param
                                                        ).
end.
end procedure.
procedure cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
def input parameter p-tag-type      as char no-undo.
def input parameter p-tag-value     as char no-undo.
def input parameter p-param-value   as char no-undo.
def buffer buf_temp_xmlvalid-taglist for temp_xmlvalid-taglist.
def var v-found    as logical  no-undo.
if p-tag-type = "tag-start"
then do:
    assign
        v-xmlvalid-current-level = v-xmlvalid-current-level + 1
        v-xmlvalid-in-tag        = yes
    .
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
    no-error.
    if not available temp_xmlvalid-taglist
    then do:
        create temp_xmlvalid-taglist.
        assign
            temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
        .
    end.
    assign
        temp_xmlvalid-taglist.tag-name = p-tag-value
        v-xmlvalid-tag-value = ""
    .
    if v-xmlvalid-read-vartype = yes and p-tag-value <> "varType":U
    then do:
        find first temp_xmlvalid-field-types
             where temp_xmlvalid-field-types.field-name = p-tag-value
        no-error.
        if available temp_xmlvalid-field-types
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен повторно"
                                        ).
        end.
        else do:
            create temp_xmlvalid-field-types.
            assign
                temp_xmlvalid-field-types.field-name = p-tag-value
            .
        end.
    end.
end.
if p-tag-type = "tag-end"
then do:
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
           and temp_xmlvalid-taglist.tag-name  = p-tag-value
    no-error.
    if available temp_xmlvalid-taglist
    then do:
        assign
            v-xmlvalid-current-level = v-xmlvalid-current-level - 1
            v-xmlvalid-in-tag        = no
        .
    end.
    else do:
        if v-xmlvalid-error-mode = 'fatal'
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Ошибка: Попытка закрыть не открытый тэг"
                                        ).
        end.
        else do:
            find first temp_xmlvalid-taglist
                 where temp_xmlvalid-taglist.tag-name = p-tag-value
            no-error.
            if not available temp_xmlvalid-taglist
            then do:
                assign
                    v-xmlvalid-tag-value = v-xmlvalid-tag-value + "</" + p-tag-value + ">" + chr(10)
                .
            end.
            else do:
                for each buf_temp_xmlvalid-taglist
                   where buf_temp_xmlvalid-taglist.level-num > temp_xmlvalid-taglist.level-num
                :
                    assign
                        v-xmlvalid-tag-value = "<" + buf_temp_xmlvalid-taglist.tag-name + ">" + chr(10) + v-xmlvalid-tag-value
                        v-xmlvalid-current-level = temp_xmlvalid-taglist.level-num - 1
                    .
                end.
            end.
        end.
    end.
end.
if p-tag-type = "text"
then do:
    if v-xmlvalid-read-vartype = yes
    then do:
        if available temp_xmlvalid-field-types
        then do:
            assign
                temp_xmlvalid-field-types.field-type = v-xmlvalid-tag-value
            .
        end.
    end.
    else do:
        find first temp_xmlvalid-field-types
            where temp_xmlvalid-field-types.field-name = temp_xmlvalid-taglist.tag-name
        no-error.
        if available temp_xmlvalid-field-types
        then do:
        end.
        else do:
        end.
    end.
    assign
        v-xmlvalid-tag-value = v-xmlvalid-tag-value + p-tag-value
    .
end.
run run-cb-xmlvalid-procedure-not-found in this-procedure
                                        (     input this-procedure :handle
                                            , input p-tag-type
                                            , input p-tag-value
                                            , input p-param-value
                                        ).
end.
end procedure.
procedure run-cb-xmlvalid-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle   no-undo.
    def input parameter p-data-type         as char     no-undo.
    def input parameter p-data-value        as char     no-undo.
    def input parameter p-param-value       as char     no-undo.
    if lookup("cb-xmlvalid-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-procedure-not-found in p-handle (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlvalid-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlvalid-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlvalid-procedure-not-found"
                                ).
    end.
end.
end procedure.
procedure run-cb-xmlvalid-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.
    if lookup("cb-xmlvalid-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-error in p-handle  (input p-error-message).
    end.
end.
end procedure.
procedure run-cb-xmlvalid-procedure :
do
on error undo, return error
:
def input parameter p-handle            as handle no-undo.
def input parameter p-procedure-name    as char no-undo.
def var v-data-type     as char no-undo.
def var v-data-value    as char no-undo.
def var v-param-value   as char no-undo.
    if lookup( p-procedure-name, p-handle :internal-entries) > 0
    then do:
        run value(p-procedure-name) in p-handle no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы " + p-procedure-name
                                    ).
        end.
    end.
    else do:
        if substring(p-procedure-name, 1, 20) = "cb-xmlvalid-tag-end-"
        then do:
            assign
                v-data-type     = "tag-end"
                v-data-value    = substring(p-procedure-name, 21)
            .
        end.
        else do:
            if substring(p-procedure-name, 1, 22) = "cb-xmlvalid-tag-start-"
            then do:
                assign
                    v-data-type     = "tag-start"
                    v-data-value    = substring(p-procedure-name, 23)
                .
            end.
            else do:
                assign
                    v-data-type     = "text"
                    v-data-value    = p-procedure-name
                .
            end.
        end.
        run run-cb-xmlvalid-procedure-not-found in this-procedure
                                               (   input p-handle
                                                  , input v-data-type
                                                  , input v-data-value
                                                  , input v-param-value
                                                ).
    end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes5 as character no-undo .
    define variable v-param-type5 as character no-undo .
    define variable v-value-character5 as INTEGER no-undo .
    define variable v-value-date5 as date no-undo .
    define variable v-value-decimal5 as decimal no-undo .
    define variable v-value-integer5 AS integer no-undo .
    define variable v-value-logical5 AS LOGICAL no-undo .
    define variable v-tth5 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character5
        ,output v-value-date5
        ,output v-value-decimal5
        ,output v-value-integer5
        ,output v-value-logical5
        ,output v-param-type5
        ,INPUT-OUTPUT table-handle v-tth5
        ) no-error .
    if error-status :error then do:
      delete object v-tth5.
      v-mes5 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes5.
    end.
    delete object v-tth5.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer5)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess6 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess6
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
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
def var vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info30, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info30 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info30 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info30, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info30
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info30
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define input  parameter dif-pdbc as logical no-undo initial no.
define input  parameter pbc-veto  as logical no-undo.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-config
     LABEL "&Настройки"
     SIZE 10 BY 1.
DEFINE BUTTON bt-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.
DEFINE BUTTON bt-import
     LABEL "&Импорт"
     SIZE 10 BY 1.
DEFINE VARIABLE ed-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 97 BY 15.92 NO-UNDO.
DEFINE VARIABLE fi-dir-exp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-dir-imp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 36.88 BY 1 NO-UNDO.
DEFINE VARIABLE fi-log AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     bt-config AT ROW 1.17 COL 12
     bt-import AT ROW 1.17 COL 40
     bt-export AT ROW 1.17 COL 51
     b-help AT ROW 1.17 COL 89
     fi-dir-imp AT ROW 2.38 COL 13.13 NO-LABEL
     fi-dir-exp AT ROW 2.38 COL 63.5 NO-LABEL
     fi-log AT ROW 3.5 COL 2 NO-LABEL
     ed-log AT ROW 4.67 COL 2 NO-LABEL
     "Импорт из:" VIEW-AS TEXT
          SIZE 10.88 BY 1.08 AT ROW 2.29 COL 2.25
     "Экспорт в:" VIEW-AS TEXT
          SIZE 11.5 BY 1.08 AT ROW 2.29 COL 51.88
     SPACE(36.49) SKIP(17.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обмен данными с РКС".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF bt-config IN FRAME Dialog-Frame
DO:
    run rcs/rcsconf.w (
        input parparentproc
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при изменении параметров обмена данными с системой RCS."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run init-fields in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка присвоения начальных значений полей формы."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF bt-export IN FRAME Dialog-Frame
DO:
    run export-rcs in this-procedure (
          input fi-log :handle
        , input ed-log :handle
        , input fi-dir-exp :screen-value
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF bt-import IN FRAME Dialog-Frame
DO:
    run import-rcs in this-procedure (
          input fi-log :handle
        , input ed-log :handle
        , input fi-dir-imp :screen-value
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка импорта."
        skip return-value
        skip trim( error-status :get-message( 1 ) )
        trim( error-status :get-message( 2 ) )
        trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        run write-to-log-editor(
              input ed-log :handle
            , input 1
            , input substitute( "Ошибка импорта. &1. &2."
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                              )
        ).
        undo, return no-apply .
    end.
END.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
    RUN enable_UI.
    run init-fields in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка вычисления начальных значений для полей формы."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cb-xmlparse-tag-end-mail :
do
on error undo, return error
:
    assign
        v-mail-parameters-start = no
    .
end.
END PROCEDURE.
PROCEDURE cb-xmlparse-tag-start-mail :
do
on error undo, return error
:
    assign
        v-mail-parameters-start = yes
    .
end.
END PROCEDURE.
PROCEDURE cb-xmlparse-tag-start-DESTINATION_ROID :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    define buffer buf_rcs-destn     for rcs-destn.
    find first buf_rcs-destn no-lock
         where buf_rcs-destn.destination_rowid = p-param
           and buf_rcs-destn.status_ = '*'
    no-error.
    if available buf_rcs-destn
    then do:
        assign
            v-selected-object-start = yes
            v-selected-object-name  = buf_rcs-destn.name
        .
    end.
    else do:
        assign
            v-selected-object-start = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE cb-xmlparse-tag-start-ROW :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    if v-selected-object-start = yes
    then do:
        run create-temp-table-record in this-procedure (
              input v-selected-object-name
            , input v-xmlvalid-tag-value
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка создания записи временной таблицы." + chr(10) + return-value.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE cb-xmlvalid-procedure-not-found :
do
on error undo, return error
:
define input parameter p-type       as character    no-undo.
define input parameter p-value      as character    no-undo.
define input parameter p-parameters as character    no-undo.
    case p-type
    :
        when "tag-end"
        then do:
            run fill-temp-table-record in this-procedure (
                  input v-selected-object-name
                , input p-value
                , input v-xmlvalid-tag-value
            ) no-error .
            if error-status :error
            then do:
                undo, return error "Ошибка заполнения временной таблицы." + chr(10) + return-value.
            end.
        end.
        when "tag-start"
        then do:
            if p-value = "DESTINATION_ROID"
            then do:
                assign
                    v-selected-object-start = no
                .
                run cb-xmlparse-tag-start-DESTINATION_ROID in this-procedure ( input p-parameters ).
            end.
        end.
        when "text"
        then do:
        end.
        otherwise do:
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE create-base-record-from-temp-table :
do
on error undo, return error
:
define input parameter p-rcs-name   as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    case p-rcs-name
    :
        when "BILL"
        then do:
            for each temp_rcs-retail1bill
            :
                run import-bill in this-procedure (
                      input temp_rcs-retail1bill.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта товаров." + chr(10) + return-value.
                end.
            end.
        end.
        when "BILL_ITEM"
        then do:
        end.
        when "RETAIL1_SUBJECT"
        then do:
            for each temp_rcs-retail1subject
            :
                run import-subject in this-procedure (
                      input temp_rcs-retail1subject.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта поставщика." + chr(10) + return-value.
                end.
            end.
        end.
        when "RETAIL1_ATTR"
        then do:
            for each temp_rcs-retail1attr
            :
                run import-attr in this-procedure (
                      input temp_rcs-retail1attr.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта справочников (attr)." + chr(10) + return-value.
                end.
            end.
        end.
        when "RETAIL1_PRODUCT"
        then do:
            for each temp_rcs-retail1product
            :
                run import-product in this-procedure (
                      input temp_rcs-retail1product.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта товаров." + chr(10) + return-value.
                end.
            end.
        end.
        when "RETAIL1_PRICE_ITEM"
        then do:
        end.
        when "RETAIL1_PRICE"
        then do:
            for each temp_rcs-retail1price
            :
                run import-price in this-procedure (
                      input temp_rcs-retail1price.price_id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта прайс-листа с ID = " + temp_rcs-retail1price.price_id + chr(10) + return-value.
                end.
            end.
        end.
        when "RETAIL1_BARCODE"
        then do:
            for each temp_rcs-retail1barcode
            :
                run import-barcode in this-procedure (
                      input temp_rcs-retail1barcode.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта бар-кода с ID = " + temp_rcs-retail1barcode.id + chr(10) + return-value.
                end.
            end.
        end.
        when "RETAIL1_DELETE"
        then do:
            for each temp_rcs-retail1delete
            :
                run delete-record in this-procedure (
                      input temp_rcs-retail1delete.name
                    , input temp_rcs-retail1delete.id
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка удаления '" + temp_rcs-retail1delete.name + "'" + " с ID '" + temp_rcs-retail1delete.id + "'" + chr(10) + return-value.
                end.
            end.
        end.
        otherwise do:
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE create-temp-table-record :
do
on error undo, return error
:
define input parameter p-rcs-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.
    case p-rcs-name
    :
        when "BILL"
        then do:
            find first temp_rcs-retail1bill
                 where temp_rcs-retail1bill.id = ""
            no-error .
            if available temp_rcs-retail1bill
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы BILL при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1bill.
                assign
                    temp_rcs-retail1bill.id = ""
                .
            end.
        end.
        when "BILL_ITEM"
        then do:
            find first temp_rcs-retail1billitem
                 where temp_rcs-retail1billitem.bill_id    = ""
                   and temp_rcs-retail1billitem.product_id = ""
            no-error .
            if available temp_rcs-retail1billitem
            then do:
                undo, return error "Неопределенные идентификаторы таблицы BILL_ITEM при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1billitem .
                assign
                    temp_rcs-retail1billitem.bill_id    = ""
                    temp_rcs-retail1billitem.product_id = ""
                .
            end.
        end.
        when "RETAIL1_BANK"
        then do:
            find first temp_rcs-retail1bank
                 where temp_rcs-retail1bank.id = ""
            no-error .
            if available temp_rcs-retail1bank
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_BANK при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1bank.
                assign
                    temp_rcs-retail1bank.id = ""
                    temp_rcs-retail1bank.bank-code = 0
                .
            end.
        end.
        when "RETAIL1_SUBJECT"
        then do:
            find first temp_rcs-retail1subject
                 where temp_rcs-retail1subject.id = ""
            no-error .
            if available temp_rcs-retail1subject
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_SUBJECT при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1subject.
                assign
                    temp_rcs-retail1subject.id = ""
                    temp_rcs-retail1subject.obj-type = ""
                    temp_rcs-retail1subject.obj-code = 0
                .
            end.
        end.
        when "RETAIL1_ATTR"
        then do:
            find first temp_rcs-retail1attr
                 where temp_rcs-retail1attr.id = ""
            no-error .
            if available temp_rcs-retail1attr
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_ATTR при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1attr.
                assign
                    temp_rcs-retail1attr.id = ""
                .
            end.
        end.
        when "RETAIL1_PRODUCT"
        then do:
            find first temp_rcs-retail1product
                 where temp_rcs-retail1product.id = ""
            no-error .
            if available temp_rcs-retail1product
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_PRODUCT при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1product.
                assign
                    temp_rcs-retail1product.id = ""
                    temp_rcs-retail1product.gds-code = 0
                .
            end.
        end.
        when "RETAIL1_PRICE"
        then do:
            find first temp_rcs-retail1price
                 where temp_rcs-retail1price.price_id = ""
            no-error .
            if available temp_rcs-retail1price
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_PRICE при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1price.
                assign
                    temp_rcs-retail1price.price_id = ""
                .
            end.
        end.
        when "RETAIL1_PRICE_ITEM"
        then do:
            find first temp_rcs-retail1priceitem
                 where temp_rcs-retail1priceitem.price_id   = ""
                   and temp_rcs-retail1priceitem.id         = ""
            no-error .
            if available temp_rcs-retail1priceitem
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_PRICE_ITEM при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1priceitem .
                assign
                    temp_rcs-retail1priceitem.price_id   = ""
                    temp_rcs-retail1priceitem.id         = ""
                .
            end.
        end.
        when "RETAIL1_BARCODE"
        then do:
            find first temp_rcs-retail1barcode
                 where temp_rcs-retail1barcode.id = ""
            no-error .
            if available temp_rcs-retail1barcode
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_BARCODE при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1barcode.
                assign
                    temp_rcs-retail1barcode.id = ""
                .
            end.
        end.
        when "RETAIL1_DELETE"
        then do:
            create temp_rcs-retail1delete.
            assign
                temp_rcs-retail1delete.name = ""
                temp_rcs-retail1delete.id = ""
            .
        end.
        when "RETAIL1_CONVOLUTION"
        then do:
            find first temp_rcs-retail1convolution
                 where temp_rcs-retail1convolution.site_id  = ""
                   and temp_rcs-retail1convolution.docdate  = ?
                   and temp_rcs-retail1convolution.tov      = ""
            no-error .
            if available temp_rcs-retail1convolution
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_CONVOLUTION при импорте." + chr(10) + return-value.
            end.
            else do:
                create temp_rcs-retail1convolution.
                assign
                    temp_rcs-retail1convolution.site_id  = ""
                    temp_rcs-retail1convolution.docdate  = ?
                    temp_rcs-retail1convolution.tov      = ""
                .
            end.
        end.
        otherwise do:
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-dir-imp fi-dir-exp fi-log ed-log
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-config bt-import bt-export b-help ed-log
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE export-rcs :
do
on error undo, return error
:
define input parameter p-fi     as handle       no-undo.
define input parameter p-ed     as handle       no-undo.
define input parameter p-dir    as character    no-undo.
define variable v-date-from         as date             no-undo.
define variable v-date-to           as date             no-undo.
define variable v-range             as integer          no-undo.
define variable v-obj-list          as character        no-undo.
define variable v-pay-type-list     as character        no-undo.
define variable v-pay-code          as logical          no-undo.
define variable v-cst               as logical          no-undo.
define variable v-xml-file-name     as character        no-undo.
define variable v-log-file-name     as character        no-undo.
define variable v-counter           as integer          no-undo.
    define variable v-host-code     as integer      no-undo.
    define variable v-doc-type-list as character    no-undo.
    define variable v-cancel        as logical      no-undo.
    define variable v-void-logical  as logical      no-undo.
    run bge/bge-dper.w (
          input parparentproc
        , input 1
        , input "":U
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return.
    end.
    generate-filename:
    do while true
    :
        assign
            v-counter = v-counter + 1
            v-xml-file-name = p-dir + chr(92) + "out" + string( v-counter )
        .
        if search ( v-xml-file-name + ".xml" ) = ?
        then do:
            leave generate-filename.
        end.
    end.
    ASSIGN v-log-file-name = v-xml-file-name + ".log".
    output to value( v-xml-file-name + ".xm1" ) convert target "1251" .
    output close.
    if v-date-from = ? or v-date-to = ? then return error.
    run write-to-log-editor( p-ed, 1, "Экспорт документов"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run write-to-log-editor( p-ed, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) )
                      ).
    if v-pay-code = yes
    then do:
        run write-to-log-editor( p-ed, 1, "С кодами оплаты в документах" ).
    end.
    if v-cst = yes
    then do:
        run write-to-log-editor( p-ed, 1, "Со строкой ГТД в документах" ).
    end.
    process events.
    run rcs/rcs-docs.p (
          input parparentproc
        , input p-dir + chr(92) + 'h'
        , input p-dir + chr(92) + 'b'
        , input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-pay-code
        , input v-cst
        , input p-ed
        , input p-fi
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка экспорта документов"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run write-to-log-editor( p-ed, 1, "Копирование в файл экспорта." ).
    os-append value( p-dir + chr(92) + 'h' + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла шапок документов. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    os-append value( p-dir + chr(92) + 'b' + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла строк документов. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    run write-to-log-editor( p-ed, 1, "Экспорт документов завершен." ).
    run write-to-log-editor( p-ed, 1, "Экспорт свертки"
                                + " за дату " + string(v-date-to, "99.99.99")
                      ).
    run rcs/rcs-day.p (
          input parparentproc
        , input p-dir + chr(92) + 's'
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input p-ed
        , input p-fi
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка экспорта свертки."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run write-to-log-editor( p-ed, 1, "Копирование в файл экспорта." ).
    os-append value( p-dir + chr(92) + 's' + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла свертки. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    run write-to-log-editor( p-ed, 1, "Экспорт свертки завершен." ).
    run write-to-log-editor( p-ed, 1, "Экспорт весовых бар-кодов." ).
    run rcs/rcs-bcod.p (
          input parparentproc
        , input p-dir + chr(92) + 'x'
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input p-ed
        , input p-fi
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка экспорта весовых бар-кодов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run write-to-log-editor( p-ed, 1, "Копирование в файл экспорта." ).
    os-append value( p-dir + chr(92) + 'x' + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла весовых бар-кодов. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    run write-to-log-editor( p-ed, 1, "Экспорт весовых бар-кодов завершен.").
    os-rename value( v-xml-file-name + ".xm1" ) value( v-xml-file-name + ".xml" ).
    if os-error = 999
    then do:
        os-copy value( v-xml-file-name + ".xm1" ) value( v-xml-file-name + ".xml" ).
        if os-error = 0 then do:
            os-delete value( v-xml-file-name + ".xm1" ) .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE fill-temp-table-record :
do
on error undo, return error
:
define input parameter p-rcs-name   as character    no-undo.
define input parameter p-tag-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.
    if v-mail-parameters-start = yes
    then do:
        case p-tag-name
        :
            when "X-ReportType"
            then do:
                assign
                    v-mail-ReportType = p-tag-value
                .
            end.
            when "X-IDChannel"
            then do:
                assign
                    v-mail-IDChannel = p-tag-value
                .
            end.
            when "X-ReportNumber"
            then do:
                assign
                    v-mail-ReportNumber = p-tag-value
                .
            end.
        end case.
    end.
    else do:
        case p-rcs-name
        :
            when "BILL"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1bill      for temp_rcs-retail1bill.
                        define buffer buf_del_temp_rcs-retail1billitem  for temp_rcs-retail1billitem.
                        find first buf_del_temp_rcs-retail1bill
                             where buf_del_temp_rcs-retail1bill.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1bill
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные о приходе с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                   )
                            ).
                            delete buf_del_temp_rcs-retail1bill.
                            for each buf_del_temp_rcs-retail1billitem
                               where buf_del_temp_rcs-retail1billitem.bill_id = p-tag-value
                            :
                                delete buf_del_temp_rcs-retail1billitem.
                            end.
                        end.
                        assign
                            temp_rcs-retail1bill.id = p-tag-value
                        .
                    end.
                    when "DOCNOMER"
                    then do:
                        assign
                            temp_rcs-retail1bill.docnomer = p-tag-value
                        .
                    end.
                    when "DOCDATE"
                    then do:
                        assign
                            temp_rcs-retail1bill.docdate = date( integer( substring( p-tag-value, 5, 2 ) )
                                                                , integer( substring( p-tag-value, 7, 2 ) )
                                                                , integer( substring( p-tag-value, 1, 4 ) ) )
                        .
                    end.
                    when "SUBJECT_ID"
                    then do:
                        assign
                            temp_rcs-retail1bill.subject_id = p-tag-value
                        .
                    end.
                    when "DOC_TYPE_ID"
                    then do:
                        assign
                            temp_rcs-retail1bill.doc_type_id = integer( p-tag-value )
                        .
                    end.
                    when "SITE_ID"
                    then do:
                        assign
                            temp_rcs-retail1bill.site_id = p-tag-value
                        .
                    end.
                    otherwise do:
                    end.
                end case.
            end.
            when "RETAIL1_BANK"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1bank      for temp_rcs-retail1bank.
                        find first buf_del_temp_rcs-retail1bank
                             where buf_del_temp_rcs-retail1bank.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1bank
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные о банке с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                   )
                            ).
                            delete buf_del_temp_rcs-retail1bank.
                        end.
                        assign
                            temp_rcs-retail1bank.id = p-tag-value
                        .
                    end.
                    when "BANK_ADDRESS"
                    then do:
                        assign
                            temp_rcs-retail1bank.bank_address = p-tag-value
                        .
                    end.
                    when "BANK_NAME"
                    then do:
                        assign
                            temp_rcs-retail1bank.bank_name = p-tag-value
                        .
                    end.
                    when "BIC"
                    then do:
                        assign
                            temp_rcs-retail1bank.bic = p-tag-value
                        .
                    end.
                    when "CORRESPONDING_ACCOUNT"
                    then do:
                        assign
                            temp_rcs-retail1bank.corresponding_account = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_SUBJECT"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1subject      for temp_rcs-retail1subject.
                        find first buf_del_temp_rcs-retail1subject
                             where buf_del_temp_rcs-retail1subject.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1subject
                        then do:
                            run write-to-log-editor in this-procedure (
                                    input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные о поставщике с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1subject.
                        end.
                        assign
                            temp_rcs-retail1subject.id = p-tag-value
                        .
                    end.
                    when "CNAME"
                    then do:
                        assign
                            temp_rcs-retail1subject.cname = p-tag-value
                        .
                    end.
                    when "RETAIL_SUBJECT_TYPE"
                    then do:
                        assign
                            temp_rcs-retail1subject.retail_subject_type = p-tag-value
                        .
                    end.
                    when "INN"
                    then do:
                        assign
                            temp_rcs-retail1subject.inn = p-tag-value
                        .
                    end.
                    when "OFFICIAL_ADDRESS"
                    then do:
                        assign
                            temp_rcs-retail1subject.official_address = p-tag-value
                        .
                    end.
                    when "BANK_ID"
                    then do:
                        assign
                            temp_rcs-retail1subject.bank_id = p-tag-value
                        .
                    end.
                    when "BANK_ACCOUNT"
                    then do:
                        assign
                            temp_rcs-retail1subject.bank_account = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_ATTR"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1attr      for temp_rcs-retail1attr.
                        find first buf_del_temp_rcs-retail1attr
                             where buf_del_temp_rcs-retail1attr.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1attr
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные об атрибуте с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                   )
                            ).
                            delete buf_del_temp_rcs-retail1attr.
                        end.
                        assign
                            temp_rcs-retail1attr.id = p-tag-value
                        .
                    end.
                    when "RETAIL_ATTR_TYPE"
                    then do:
                        assign
                            temp_rcs-retail1attr.retail_attr_type = integer( p-tag-value )
                        .
                    end.
                    when "NAME"
                    then do:
                        assign
                            temp_rcs-retail1attr.name = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_PRODUCT"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1product      for temp_rcs-retail1product.
                        find first buf_del_temp_rcs-retail1product
                             where buf_del_temp_rcs-retail1product.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1product
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные о товаре с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1product.
                        end.
                        assign
                            temp_rcs-retail1product.id = p-tag-value
                        .
                    end.
                    when "FULL_NAME"
                    then do:
                        assign
                            temp_rcs-retail1product.full_name = p-tag-value
                        .
                    end.
                    when "SHORT_NAME"
                    then do:
                        assign
                            temp_rcs-retail1product.short_name = p-tag-value
                        .
                    end.
                    when "RETAIL_PACK_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_pack_id = p-tag-value
                        .
                    end.
                    when "RETAIL_MARK_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_mark_id = p-tag-value
                        .
                    end.
                    when "RETAIL_PLACE_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_place_id = p-tag-value
                        .
                    end.
                    when "WEIGHT_FLAG"
                    then do:
                        assign
                            temp_rcs-retail1product.weight_flag = integer( p-tag-value )
                        .
                    end.
                    when "ACTIVE"
                    then do:
                        assign
                            temp_rcs-retail1product.active = p-tag-value
                        .
                    end.
                    when "RETAIL_PRODUCER_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_producer_id = p-tag-value
                        .
                    end.
                    when "RETAIL_LABEL_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_label_id = p-tag-value
                        .
                    end.
                    when "RETAIL_CITY_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_city_id = p-tag-value
                        .
                    end.
                    when "RETAIL_COUNTRY_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_country_id = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_PRICE_ITEM"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.id = p-tag-value
                        .
                    end.
                    when "PRICE_COST"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.price_cost = decimal( p-tag-value )
                        .
                    end.
                    when "PRICE_ID"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.price_id = p-tag-value
                        .
                    end.
                    when "ACTIVE"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.active = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_PRICE"
            then do:
                case p-tag-name
                :
                    when "PRICE_ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1price      for temp_rcs-retail1price.
                        define buffer buf_del_temp_rcs-retail1priceit    for temp_rcs-retail1priceitem.
                        find first buf_del_temp_rcs-retail1price
                             where buf_del_temp_rcs-retail1price.price_id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1price
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные о переоценке с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1price.
                            for each buf_del_temp_rcs-retail1priceit
                               where buf_del_temp_rcs-retail1priceit.price_id = p-tag-value
                            :
                                delete buf_del_temp_rcs-retail1price.
                            end.
                        end.
                        assign
                            temp_rcs-retail1price.price_id = p-tag-value
                        .
                    end.
                    when "DDAT"
                    then do:
                        assign
                            temp_rcs-retail1price.ddat = date( integer( substring( p-tag-value, 5, 2 ) )
                                                            , integer( substring( p-tag-value, 7, 2 ) )
                                                            , integer( substring( p-tag-value, 1, 4 ) ) )
                        .
                    end.
                    when "DOC_TYPE"
                    then do:
                        assign
                            temp_rcs-retail1price.doc_type = p-tag-value
                        .
                    end.
                    when "STAD"
                    then do:
                        assign
                            temp_rcs-retail1price.stad = p-tag-value
                        .
                    end.
                    when "DOC_MODE"
                    then do:
                        assign
                            temp_rcs-retail1price.doc-mode = p-tag-value
                        .
                    end.
                    when "CORR"
                    then do:
                        assign
                            temp_rcs-retail1price.corr = p-tag-value
                        .
                    end.
                    when "SITE_ID"
                    then do:
                        assign
                            temp_rcs-retail1price.site_id = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_BARCODE"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1barcode      for temp_rcs-retail1barcode.
                        find first buf_del_temp_rcs-retail1barcode
                             where buf_del_temp_rcs-retail1barcode.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1barcode
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные о бар-коде с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1barcode.
                        end.
                        assign
                            temp_rcs-retail1barcode.id = p-tag-value
                        .
                    end.
                    when "RETAIL_PRODUCT_ID"
                    then do:
                        assign
                            temp_rcs-retail1barcode.retail_product_id = p-tag-value
                        .
                    end.
                    when "BARCODE"
                    then do:
                        assign
                            temp_rcs-retail1barcode.barcode = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_DELETE"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1delete      for temp_rcs-retail1delete.
                        find first buf_del_temp_rcs-retail1delete
                             where buf_del_temp_rcs-retail1delete.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1delete
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame Dialog-Frame
                                , input 1
                                , input substitute( "Повторные данные об удалении записи с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1delete.
                        end.
                        assign
                            temp_rcs-retail1delete.id = p-tag-value
                        .
                    end.
                    when "NAME"
                    then do:
                        assign
                            temp_rcs-retail1delete.name = p-tag-value
                        .
                    end.
                end case.
            end.
            when "BILL_ITEM"
            then do:
                case p-tag-name
                :
                    when "BILL_ID"
                    then do:
                        assign
                            temp_rcs-retail1billitem.bill_id = p-tag-value
                        .
                    end.
                    when "PRODUCT_ID"
                    then do:
                        assign
                            temp_rcs-retail1billitem.product_id = p-tag-value
                        .
                    end.
                    when "COUNT1"
                    then do:
                        assign
                            temp_rcs-retail1billitem.count1 = decimal( p-tag-value )
                        .
                    end.
                    when "COST1"
                    then do:
                        assign
                            temp_rcs-retail1billitem.cost1 = decimal( p-tag-value )
                        .
                    end.
                end case.
            end.
            otherwise do:
            end.
        end case.
    end.
end.
END PROCEDURE.
PROCEDURE import-rcs :
do
on error undo, return error
:
define input parameter p-fi     as handle       no-undo.
define input parameter p-ed     as handle       no-undo.
define input parameter p-dir    as character    no-undo.
    define variable v-not-first     as logical  init no  no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-filename      as character         no-undo.
    define variable v-par-value     as character         no-undo.
    define variable v-par-type      as character         no-undo.
    define buffer buf_rcs-destn     for rcs-destn.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    run get-default-value in this-procedure (
          input 'группа':U
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана группа по определению для товара." + chr(10) + return-value.
    end.
    assign
        v-default-gds-grp-node-code = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input 'группа-клиентов':U
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана группа по определению для поставщика ." + chr(10) + return-value.
    end.
    assign
        v-default-cli-grp-node-code = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input 'шту':U
        , output v-unit-pieces
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + chr(10) + return-value.
    end.
    run get-default-value in this-procedure (
          input 'дро':U
        , output v-unit-divisional
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для дробного товара." + chr(10) + return-value.
    end.
    run get-default-value in this-procedure (
          input 'вес':U
        , output v-unit-weight
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для весового товара." + chr(10) + return-value.
    end.
    run get-default-value in this-procedure (
          input 'подготовка':U
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + chr(10) + return-value.
    end.
    assign
        v-default-wrkr = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input 'разрешение':U
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + chr(10) + return-value.
    end.
    assign
        v-default-agnt = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input 'отгрузка':U
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + chr(10) + return-value.
    end.
    assign
        v-default-boss = integer( v-par-value )
    .
    for each temp_rcs-retail1bill
    :
        delete temp_rcs-retail1bill.
    end.
    for each temp_rcs-retail1billitem
    :
        delete temp_rcs-retail1billitem.
    end.
    for each temp_rcs-retail1subject
    :
        delete temp_rcs-retail1subject.
    end.
    for each temp_rcs-retail1bank
    :
        delete temp_rcs-retail1bank.
    end.
    for each temp_rcs-retail1attr
    :
        delete temp_rcs-retail1attr.
    end.
    for each temp_rcs-retail1product
    :
        delete temp_rcs-retail1product.
    end.
    for each temp_rcs-retail1price
    :
        delete temp_rcs-retail1price.
    end.
    for each temp_rcs-retail1priceitem
    :
        delete temp_rcs-retail1priceitem.
    end.
    for each temp_rcs-retail1barcode
    :
        delete temp_rcs-retail1barcode.
    end.
    for each temp_rcs-retail1convolution
    :
        delete temp_rcs-retail1convolution.
    end.
    run write-to-log-editor( p-ed, 1, "Импорт из файлов:" ).
    assign
        v-import-record-count   = 0
    .
    input stream dirstream from os-dir( p-dir ).
    read-file:
    repeat
    :
        find first temp_file no-error.
        if not available temp_file
        then do:
            create temp_file.
        end.
        import stream dirstream temp_file.
        if temp_file.type = "F":U
        then do:
            define variable v-new-filename-full     as character         no-undo.
            run write-to-log-editor( p-ed, 4, temp_file.name ).
            process events.
            assign
                v-selected-object-start = no
            .
            run read-file in this-procedure ( input p-fi, input p-ed, input temp_file.fullname ) no-error.
            if error-status :error
            then do:
                undo, return error "import-rcs: Ошибка чтения файла." + chr(10) + return-value.
            end.
            else do:
                run check-and-create-subdir in this-procedure ( input p-dir, input "old" ) no-error.
                if error-status :error
                then do:
                    run write-to-log-editor( p-ed, 4, "Не удалось создать подкаталог OLD. Импортированный файл не будет удален." ).
                    next read-file.
                end.
                run get-or-generate-filename in this-procedure (
                      input p-dir + chr(92) + "old"
                    , input temp_file.name
                    , output v-new-filename-full
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log-editor( p-ed, 4, "Невозможно получить имя файла для переименования. Импортированный файл не будет удален." ).
                    next read-file.
                end.
                os-rename value( temp_file.fullname ) value( v-new-filename-full ).
                if os-error <> 0
                then do:
                    run write-to-log-editor( p-ed, 4, "Невозможно переименовать файл. Импортированный файл не будет удален." ).
                    next read-file.
                end.
            end.
        end.
    end.
    run write-to-log-editor( p-ed, 1, "Чтение файлов завершено." ).
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'dif-nam1':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-goods-parameter-dif-nam1
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'dif-nam2':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-goods-parameter-dif-nam2
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'dif-pdbc':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output dif-pdbc
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'pbc-veto':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output pbc-veto
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    for each buf_rcs-destn no-lock
       where buf_rcs-destn.status_ = '*'
    by buf_rcs-destn.chanel
    :
        run write-to-log-editor( p-ed, 1, buf_rcs-destn.name ).
        run create-base-record-from-temp-table in this-procedure (
            input buf_rcs-destn.name
            , input p-ed
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка создания записи базы данных." + chr(10) + return-value.
        end.
    end.
    if v-import-record-count = 0
    then do:
        run write-to-log-editor( p-ed, 1, "Не было импортировано ни одной записи." ).
    end.
    else do:
        run write-to-log-editor( p-ed, 1, "Количество новых записей: " + string( v-import-record-count ) ).
    end.
    run write-to-log-editor( p-ed, 1, "Импорт завершен." ).
end.
END PROCEDURE.
PROCEDURE import-subject :
do
on error undo, return error
:
define input parameter p-firm-id    as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    define variable v-firm-code     as integer           no-undo.
    define variable v-bank-num      as integer           no-undo.
    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define buffer buf_clients                   for clients.
    define buffer buf_cli-grp                   for cli-grp.
    define buffer buf_firm                      for firm.
    define buffer buf_fin-bank                  for fin-bank.
    define buffer buf_rcs-retail1bank           for rcs-retail1bank.
    define buffer buf_rcs-retail1subject        for rcs-retail1subject.
    define buffer buf_temp_rcs-retail1subject   for temp_rcs-retail1subject.
    define buffer buf_temp_rcs-retail1bank      for temp_rcs-retail1bank.
    define buffer buf_rcs-clients               for rcs-clients.
    find first buf_temp_rcs-retail1subject
         where buf_temp_rcs-retail1subject.id = p-firm-id
    no-error.
    if not available buf_temp_rcs-retail1subject
    then do:
        undo, return error "import-subject: Ошибка поиска во временной таблице." + chr(10) + return-value.
    end.
    find first buf_rcs-retail1subject no-lock
         where buf_rcs-retail1subject.id = p-firm-id
    no-error.
    if available buf_rcs-retail1subject
    then do:
        run write-to-log-editor in this-procedure (
              input p-ed
            , input 1
            , input "Поставщик с ID = " + p-firm-id  + " уже был импортирован."
        ).
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-default-cli-grp-node-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "import-subject: Ошибка поиска группы для поставщика." + chr(10) + return-value.
        end.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        do transaction
        :
            run create-firm in this-procedure (
                  input ""
                , input 0
                , input buf_temp_rcs-retail1subject.official_address
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input 0
                , input buf_temp_rcs-retail1subject.inn
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input 0
                , output v-firm-code
            ) no-error .
            if error-status :error
            then do:
                undo, return error "import-subject: Ошибка создания записи фирмы поставщика." + chr(10) + return-value.
            end.
            run create-clients in this-procedure (
                  input 'орг':U
                , input v-firm-code
                , input buf_temp_rcs-retail1subject.cname
                , input buf_cli-grp.node-code
                , input -1
                , input 0
                , input ""
                , input buf_cli-grp.node-name
                , input 0
                , input no
                , input yes
                , input no
                , input no
                , input no
                , input no
                , input no
                , input 0
            ) no-error .
            if error-status :error
            then do:
                undo, return error "import-subject: Ошибка создания записи поставщика." + chr(10) + return-value.
            end.
            create buf_rcs-retail1subject.
            assign
                buf_rcs-retail1subject.id                   = p-firm-id
                buf_rcs-retail1subject.obj-code             = v-firm-code
                buf_rcs-retail1subject.obj-type             = 'орг':U
                buf_rcs-retail1subject.file-name            = fi-dir-imp :screen-value in frame Dialog-Frame
                buf_rcs-retail1subject.cname                = buf_temp_rcs-retail1subject.cname
                buf_rcs-retail1subject.imp-date             = v-today
                buf_rcs-retail1subject.imp-time             = v-time
                buf_rcs-retail1subject.imp-user             = v-cntxt-userid
                buf_rcs-retail1subject.inn                  = buf_temp_rcs-retail1subject.inn
                buf_rcs-retail1subject.official_address     = buf_temp_rcs-retail1subject.official_address
                buf_rcs-retail1subject.retail_subject_type  = buf_temp_rcs-retail1subject.retail_subject_type
                v-import-record-count                       = v-import-record-count + 1
            .
            create buf_rcs-clients.
            assign
                buf_rcs-clients.id          = p-firm-id
                buf_rcs-clients.obj-type    = 'орг':U
                buf_rcs-clients.obj-code    = v-firm-code
                buf_rcs-clients.name        = buf_temp_rcs-retail1subject.cname
            .
            find first buf_temp_rcs-retail1bank no-lock
                 where buf_temp_rcs-retail1bank.id = buf_temp_rcs-retail1subject.bank_id
            no-error .
            if available buf_temp_rcs-retail1bank
            then do:
                create buf_fin-bank.
                run genscode-generate-num-bank in this-procedure ( output v-bank-num ) no-error .
                if error-status :error
                then do:
                    undo, return error "import-subject: Ошибка генерации уникального кода для банка." + chr(10) + return-value.
                end.
                assign
                    buf_fin-bank.host-code = v-firm-code
                    buf_fin-bank.code-bank = integer( buf_temp_rcs-retail1bank.bic )
                .
                create buf_rcs-retail1bank.
                assign
                    buf_rcs-retail1bank.id                      = buf_temp_rcs-retail1bank.id
                    buf_rcs-retail1bank.bank_address            = buf_temp_rcs-retail1bank.bank_address
                    buf_rcs-retail1bank.bank_name               = buf_temp_rcs-retail1bank.bank_name
                    buf_rcs-retail1bank.corresponding_account   = buf_temp_rcs-retail1bank.corresponding_account
                    buf_rcs-retail1bank.bic                     = buf_temp_rcs-retail1bank.bic
                    buf_rcs-retail1bank.bank-num                = v-bank-num
                    buf_rcs-retail1bank.file-name               = fi-dir-imp :screen-value in frame Dialog-Frame
                    buf_rcs-retail1bank.imp-date                = v-today
                    buf_rcs-retail1bank.imp-time                = v-time
                    buf_rcs-retail1bank.imp-user                = v-cntxt-userid
                .
            end.
            process events.
            assign
                fi-log :screen-value in frame Dialog-Frame = "Импортирован поставщик: "
                                                + buf_temp_rcs-retail1subject.id
                                                + "   " + string( v-firm-code )
                                                + "   " + buf_temp_rcs-retail1subject.cname
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
    define variable v-dir     as character         no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    define variable v-cancel     as logical           no-undo.
    define variable v-param-type                as character                no-undo.
    define variable v-value-character           as character                no-undo.
    define variable v-value-date                as date                     no-undo.
    define variable v-value-decimal             as decimal                  no-undo.
    define variable v-value-integer             as INTEGER                  no-undo.
    define variable v-value-logical             AS LOGICAL                  no-undo.
    define variable v-tth                       as handle                   no-undo.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'rcs-import-directory':u
    no-error .
    if not available buf_usr-flt
    then do:
        run select-dir in this-procedure (
              input 'rcs-import-directory':u
            , output v-dir
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора каталога." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-dir-imp :screen-value in frame Dialog-Frame = v-dir
            .
        end.
    end.
    else do:
        assign
            fi-dir-imp :screen-value in frame Dialog-Frame = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'rcs-export-directory':u
    no-error .
    if not available buf_usr-flt
    then do:
        run select-dir in this-procedure (
              input 'rcs-export-directory':u
            , output v-dir
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора каталога." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-dir-exp :screen-value in frame Dialog-Frame = v-dir
            .
        end.
    end.
    else do:
        assign
            fi-dir-exp :screen-value in frame Dialog-Frame = buf_usr-flt.Naim
        .
    end.
        run adm/shattri.p (
            input "get":U
            ,input  '':U
            ,input  0
            ,input  'gds-ref':U
            ,input  'dif-nam1':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-goods-parameter-dif-nam1
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error.
        delete object v-tth.
        run adm/shattri.p (
            input "get":U
            ,input  '':U
            ,input  0
            ,input  'gds-ref':U
            ,input  'dif-nam2':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-goods-parameter-dif-nam2
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error.
        delete object v-tth.
end.
END PROCEDURE.
PROCEDURE objects-tuning :
do
on error undo, return error
:
    run rcs/rcsimpd.w no-error .
    if error-status :error
    then do:
        undo, return error "objects-tuning: Ошибка настройки объектов rcs." + chr(10) + return-value.
    end.
end.
END PROCEDURE.
PROCEDURE read-file :
do
on error undo, return error
:
define input parameter p-fi     as handle       no-undo.
define input parameter p-ed     as handle       no-undo.
define input parameter p-filename as character    no-undo.
    define variable v-xml-bufer     as character         no-undo.
    define variable v-counter       as integer           no-undo.
    input stream istream from value( p-filename ).
    repeat :
        import stream istream unformatted
            v-xml-bufer
        .
        assign
            v-counter = v-counter + 1
        .
        if v-selected-object-start = yes
            or index( v-xml-bufer, "DESTINATION_ROID" ) <> 0
        then do:
            run xmlvalid in this-procedure (
                input this-procedure :handle
                , input v-xml-bufer
                , input 'fatal':u
            ) no-error .
            if error-status :error
            then do:
                undo, return error "read-file: Ошибка импорта из файла '" + p-filename + "'" + chr(10) + return-value.
            end.
        end.
        if v-counter mod 100 = 0
        then do:
            assign
                p-fi :screen-value  = "Файл: " + p-filename + ". Прочитано строк: " + string( v-counter )
            .
        end.
    end.
    input stream istream close.
end.
END PROCEDURE.
PROCEDURE select-dir :
do
on error undo, return error
:
define input parameter p-impexp-type    as character    no-undo.
define output parameter p-dir           as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-dir-type  as character    no-undo.
    define variable v-can-write as logical      no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    run gbl/dir-sel.p (
                    output p-dir
                  , output v-dir-type
                  , output v-can-write
    ) no-error .
    if error-status :error
    then do:
        assign
            p-cancel = yes
        .
        undo, return error "Ошибка выбора каталога импортируемых файлов." .
    end.
    else do:
        if v-can-write = no
        then do:
            assign
                p-cancel = yes
            .
        end.
        else do:
            find first buf_usr-flt exclusive-lock
                 where buf_usr-flt.user-name    = 'все':U
                   and buf_usr-flt.call-point   = p-impexp-type
            no-error .
            if not available buf_usr-flt
            then do:
                create buf_usr-flt.
                assign
                    buf_usr-flt.user-name    = 'все':U
                    buf_usr-flt.call-point   = p-impexp-type
                .
            end.
            assign
                buf_usr-flt.Naim = p-dir
                p-cancel = no
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE write-to-log-editor :
do
on error undo, return error
:
  def input parameter hedt as handle no-undo.
  def input parameter iloglevel as integer  no-undo.
  def input parameter stowrite  as char     no-undo.
    if valid-handle ( hedt )
    then do:
        hedt :move-to-eof().
        hedt :insert-string( if ( iloglevel = 0
                             or stowrite = "&dline"
                             or stowrite = "&line" )
                             then ""
                             else cur-time-string-sec() + " "
                           ).
        hedt :insert-string( if stowrite = "&line"
                             then fill("-", 80 )
                             else if stowrite = "&dline"
                             then fill("=", 80)
                             else fill(" ", iloglevel) + stowrite).
        hedt :insert-string(chr(10)).
    end.
    output to 'rcsimp.log' append.
    put unformatted
        skip chr(10) cur-time-string-sec() fill(" ", iloglevel) stowrite
    .
    output close.
end.
END PROCEDURE.
PROCEDURE import-attr :
do
on error undo, return error
:
define input parameter p-attr-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define variable v-firm-code     as integer   no-undo.
    define variable v-root-code     as integer   no-undo.
    define buffer buf_temp_rcs-retail1attr  for temp_rcs-retail1attr.
    define buffer buf_rcs-retail1attr       for rcs-retail1attr.
    define buffer buf_rcs-pack              for rcs-pack.
    define buffer buf_rcs-mark              for rcs-mark.
    define buffer buf_rcs-place             for rcs-place.
    define buffer buf_rcs-country           for rcs-country.
    define buffer buf_rcs-clients           for rcs-clients.
    define buffer buf_rcs-city              for rcs-city.
    define buffer buf_country               for country.
    define buffer buf_units                 for units.
    define buffer buf_clients               for clients.
    define buffer buf_cli-grp               for cli-grp.
    define buffer buf_firm                  for firm.
    define buffer buf_gds-grp               for gds-grp.
    find first buf_temp_rcs-retail1attr
         where buf_temp_rcs-retail1attr.id = p-attr-id
    no-error.
    if not available buf_temp_rcs-retail1attr
    then do:
        undo, return error "import-attr: Ошибка поиска во временной таблице." + chr(10) + return-value.
    end.
    find first buf_rcs-retail1attr no-lock
         where buf_rcs-retail1attr.id = p-attr-id
    no-error.
    if available buf_rcs-retail1attr
    then do:
        run write-to-log-editor in this-procedure (
              input p-ed
            , input 1
            , input "Справочник (attr) с идентификатором '" + p-attr-id + "' уже был импортирован."
        ).
    end.
    else do:
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        case buf_temp_rcs-retail1attr.retail_attr_type
        :
            when 1
            then do:
                find first buf_rcs-pack no-lock
                     where buf_rcs-pack.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-pack
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Упаковка с идентификатором '" + p-attr-id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        create buf_rcs-pack.
                        assign
                            buf_rcs-pack.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-pack.name   = buf_temp_rcs-retail1attr.name
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 1
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame Dialog-Frame
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 2
            then do:
                find first buf_rcs-mark no-lock
                     where buf_rcs-mark.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-mark
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Маркировка с идентификатором '" + p-attr-id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        create buf_rcs-mark.
                        assign
                            buf_rcs-mark.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-mark.name   = buf_temp_rcs-retail1attr.name
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 2
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame Dialog-Frame
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 3
            then do:
                find first buf_rcs-place no-lock
                     where buf_rcs-place.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-place
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Упаковка с идентификатором '" + p-attr-id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        run grplib-get-root-code ( output v-root-code ) no-error .
                        if error-status :error
                        then do:
                            undo, return error "import-attr: Ошибка при вычислении кода корневой группы." + chr(10) + return-value.
                        end.
                        find first buf_gds-grp no-lock
                             where buf_gds-grp.upper-code = v-root-code
                               and buf_gds-grp.node-name  = buf_temp_rcs-retail1attr.name
                        no-error.
                        if available buf_gds-grp
                        then do:
                            run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Группа '" + buf_temp_rcs-retail1attr.name + "' уже была импортирована." ).
                        end.
                        else do:
                            create buf_gds-grp.
                            assign
                                buf_gds-grp.node-code   = next-value (s-gds-grp, ub)
                                buf_gds-grp.upper-code  = v-root-code
                                buf_gds-grp.node-name   = buf_temp_rcs-retail1attr.name
                                buf_gds-grp.calc-method = 'Учетная':U
                            .
                            create buf_rcs-place.
                            assign
                                buf_rcs-place.id        = buf_temp_rcs-retail1attr.id
                                buf_rcs-place.name      = buf_temp_rcs-retail1attr.name
                                buf_rcs-place.node-code = buf_gds-grp.node-code
                            .
                            create buf_rcs-retail1attr.
                            assign
                                buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                                buf_rcs-retail1attr.retail_attr_type    = 3
                                buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                                buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame Dialog-Frame
                                buf_rcs-retail1attr.imp-date            = v-today
                                buf_rcs-retail1attr.imp-time            = v-time
                                buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                                v-import-record-count                   = v-import-record-count + 1
                            .
                        end.
                    end.
                end.
            end.
            when 4
            then do:
                find first buf_rcs-country no-lock
                     where buf_rcs-country.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-country
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Страна с идентификатором '" + buf_temp_rcs-retail1attr.id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        find first buf_country no-lock
                             where buf_country.short-name = buf_temp_rcs-retail1attr.name
                        no-error.
                        create buf_rcs-country.
                        assign
                            buf_rcs-country.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-country.name   = buf_temp_rcs-retail1attr.name
                            buf_rcs-country.num-code = ( if available buf_country then buf_country.num-code else 0 )
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 4
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame Dialog-Frame
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 5
            then do:
                find first buf_rcs-clients no-lock
                     where buf_rcs-clients.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-clients
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Производитель с идентификатором '" + p-attr-id + "' уже был импортирован." ).
                end.
                else do:
                    do transaction
                    :
                        find first buf_cli-grp no-lock
                             where buf_cli-grp.node-code = 3
                        no-error.
                        if not available buf_cli-grp
                        then do:
                            undo, return error "import-attr: Ошибка поиска группы для поставщика." + chr(10) + return-value.
                        end.
                        run create-firm in this-procedure (
                              input ""
                            , input 0
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input 0
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input ""
                            , input 0
                            , output v-firm-code
                        ) no-error .
                        if error-status :error
                        then do:
                            undo, return error "import-subject: Ошибка создания записи фирмы поставщика." + chr(10) + return-value.
                        end.
                        run create-clients in this-procedure (
                              input 'орг':U
                            , input v-firm-code
                            , input buf_temp_rcs-retail1attr.name
                            , input buf_cli-grp.node-code
                            , input -1
                            , input 0
                            , input ""
                            , input buf_cli-grp.node-name
                            , input 0
                            , input yes
                            , input no
                            , input no
                            , input no
                            , input no
                            , input no
                            , input no
                            , input 0
                        ) no-error .
                        if error-status :error
                        then do:
                            undo, return error "import-subject: Ошибка создания записи поставщика." + chr(10) + return-value.
                        end.
                        create buf_rcs-clients.
                        assign
                            buf_rcs-clients.id          = buf_temp_rcs-retail1attr.id
                            buf_rcs-clients.name        = buf_temp_rcs-retail1attr.name
                            buf_rcs-clients.obj-type    = 'орг':U
                            buf_rcs-clients.obj-code    = v-firm-code
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 5
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame Dialog-Frame
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 6
            then do:
                find first buf_rcs-city no-lock
                     where buf_rcs-city.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-city
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Город с идентификатором '" + p-attr-id + "' уже был импортирован." ).
                end.
                else do:
                    do transaction
                    :
                        create buf_rcs-city.
                        assign
                            buf_rcs-city.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-city.name   = buf_temp_rcs-retail1attr.name
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 6
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame Dialog-Frame
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
        end case.
    end.
end.
END PROCEDURE.
PROCEDURE import-product :
do
on error undo, return error
:
define input parameter p-product-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    define variable v-today         as date              no-undo.
    define variable v-time          as integer           no-undo.
    define variable v-host-code     as integer           no-undo.
    define variable v-prod-type     as character         no-undo.
    define variable v-prod-code     as integer           no-undo.
    define variable v-recid         as recid             no-undo.
    define variable v-country       as character         no-undo.
    define variable v-gds-code      as integer           no-undo.
    define variable v-grp-code      as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define buffer buf_temp_rcs-retail1product   for temp_rcs-retail1product.
    define buffer buf_temp_rcs-retail1attr      for temp_rcs-retail1attr.
    define buffer buf_rcs-retail1product        for rcs-retail1product.
    define buffer buf_goods                     for goods.
    define buffer buf_rcs-clients               for rcs-clients.
    define buffer buf_gds-prt                   for gds-prt.
    define buffer buf_gds-grp                   for gds-grp.
    define buffer buf_units                     for units.
    define buffer buf_rcs-place                 for rcs-place.
    define buffer buf_rcs-country               for rcs-country.
    define buffer buf_country                   for country.
    find first buf_temp_rcs-retail1product
         where buf_temp_rcs-retail1product.id = p-product-id
    no-error.
    if not available buf_temp_rcs-retail1product
    then do:
        undo, return error "import-product: Ошибка поиска во временной таблице." + chr(10) + return-value.
    end.
    find first buf_rcs-retail1product no-lock
         where buf_rcs-retail1product.id = p-product-id
    no-error.
    if available buf_rcs-retail1product
    then do:
        run write-to-log-editor in this-procedure (
              input p-ed
            , input 1
            , input substitute( "Товар с идентификатором '&1' уже был импортирован. Код товара &2."
                                , p-product-id
                                , buf_rcs-retail1product.gds-code
                              )
        ).
    end.
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    find first buf_rcs-clients no-lock
         where buf_rcs-clients.id = buf_temp_rcs-retail1product.retail_producer_id
    no-error.
    if not available buf_rcs-clients
    then do:
        undo, return error "import-product: Не найден производитель товара с ID "
                            + buf_temp_rcs-retail1product.retail_producer_id
                            + chr(10) + "    ID товара: " + p-product-id
                            + chr(10) + return-value
        .
    end.
    else do:
        assign
            v-prod-type = buf_rcs-clients.obj-type
            v-prod-code = buf_rcs-clients.obj-code
        .
    end.
    find first buf_gds-prt no-lock
         where buf_gds-prt.node-name = '_Пустая шкала':U
    no-error.
    if not available buf_gds-prt
    then do:
        undo, return error "import-product: Не найден код пустой шкалы для товара." + chr(10) + return-value.
    end.
    find first buf_rcs-place no-lock
            where buf_rcs-place.id = buf_temp_rcs-retail1product.retail_place_id
    no-error .
    if not available buf_rcs-place
    then do:
        assign
            v-grp-code = v-default-gds-grp-node-code
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_rcs-place.node-code
        no-error.
        if not available buf_gds-grp
        then do:
            assign
                v-grp-code = v-default-gds-grp-node-code
            .
        end.
        else do:
            assign
                v-grp-code = buf_gds-grp.node-code
            .
        end.
    end.
    find first buf_rcs-country no-lock
         where buf_rcs-country.id = buf_temp_rcs-retail1product.retail_country_id
    no-error .
    if not available buf_rcs-country
    or buf_rcs-country.num-code = 0
    then do:
        assign
            v-country = "XX"
        .
    end.
    else do:
        find first buf_country no-lock
                where buf_country.num-code = buf_rcs-country.num-code
        no-error.
        if not available buf_country
        then do:
            assign
                v-country = "XX"
            .
        end.
        else do:
            assign
                v-country = buf_country.alpha1
            .
        end.
    end.
    case buf_temp_rcs-retail1product.weight_flag :
        when 0
        then do:
            find first buf_units no-lock
                    where buf_units.unit-name = v-unit-pieces
            no-error .
        end.
        when 1
        then do:
            find first buf_units no-lock
                    where buf_units.unit-name = v-unit-divisional
            no-error .
        end.
        when 2
        then do:
            find first buf_units no-lock
                    where buf_units.unit-name = v-unit-weight
            no-error .
        end.
    end case.
    if not available buf_units
    then do:
        undo, return error "import-product: Не найдена единица измерения товара."
                            + chr(10) + "    ID товара: " + p-product-id
                            + chr(10) + return-value
        .
    end.
    if buf_temp_rcs-retail1product.full_name = ""
    then do:
        assign
            v-full-name = "без названия"
        .
    end.
    else do:
        assign
            v-full-name = buf_temp_rcs-retail1product.full_name
        .
    end.
    do transaction
    :
        find first buf_rcs-retail1product exclusive-lock
             where buf_rcs-retail1product.id = p-product-id
        no-error.
        if available buf_rcs-retail1product
        then do:
            run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "Товар с идентификатором '" + p-product-id + "' уже был импортирован." ).
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_rcs-retail1product.gds-code
            no-error.
            if not available buf_goods
            then do:
                run write-to-log-editor in this-procedure ( ed-log :handle in frame Dialog-Frame, 1, "В базе данных не найден импортированный ранее товар с идентификатором '" + p-product-id + "'." ).
                undo, return error vss-description + "В базе данных не найден импортированный ранее товар с идентификатором '" + p-product-id + "'.".
            end.
            assign
                v-recid = recid( buf_goods )
            .
            run rcs/rcsgds.p (
                  input parparentproc
                , input 'ИЗМЕНЕНИЕ':U
                , input no
                , input 0
                , input no
                , input yes
                , input no
                , input yes
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes
                , input 0
                , input ""
                , input buf_goods.prod-type
                , input buf_goods.prod-code
                , input buf_gds-prt.node-code
                , input v-grp-code
                , input v-full-name
                , input ""
                , input v-full-name
                , input v-full-name
                , input replace( replace( v-full-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input v-country
                , input buf_goods.unit-base
                , input buf_goods.unit-base
                , input 0.0
                , input 0.0
                , input 1
                , input 1
                , input 0
                , input 0
                , input 0
                , input 0
                , input 'Группа':U
                , input 0
                , input yes
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input 0
                , input 0
                , input ""
                , input 0.0
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input 0
                , input 0
                , input ""
                , input no
                , input no
                , input no
                , input no
                , input "no"
                , input v-goods-parameter-dif-nam1
                , input v-goods-parameter-dif-nam2
                , input yes
                , input no
                , input-output v-recid
                , output v-gds-code
            ) no-error .
            if error-status :error
            then do:
                message
                  vss-workfile vss-revision vss-description
                  skip "Ошибка изменения товара."
                  skip return-value
                  skip trim(error-status :get-message(1))
                       trim(error-status :get-message(2))
                       trim(error-status :get-message(3))
                       trim(error-status :get-message(4))
                       trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error "Ошибка создания товара в базе данных."
                                    + chr(10) + "ID товара: " + p-product-id
                                    + chr(10) + trim(error-status :get-message(1))
                .
            end.
            assign
                buf_rcs-retail1product.id                   = buf_temp_rcs-retail1product.id
                buf_rcs-retail1product.file-name            = fi-dir-imp :screen-value in frame Dialog-Frame
                buf_rcs-retail1product.full_name            = buf_temp_rcs-retail1product.full_name
                buf_rcs-retail1product.gds-code             = v-gds-code
                buf_rcs-retail1product.imp-date             = v-today
                buf_rcs-retail1product.imp-time             = v-time
                buf_rcs-retail1product.imp-user             = v-cntxt-userid
                buf_rcs-retail1product.retail_city_id       = buf_temp_rcs-retail1product.retail_city_id
                buf_rcs-retail1product.retail_country_id    = buf_temp_rcs-retail1product.retail_country_id
                buf_rcs-retail1product.retail_label_id      = buf_temp_rcs-retail1product.retail_label_id
                buf_rcs-retail1product.retail_mark_id       = buf_temp_rcs-retail1product.retail_mark_id
                buf_rcs-retail1product.retail_pack_id       = buf_temp_rcs-retail1product.retail_pack_id
                buf_rcs-retail1product.retail_place_id      = buf_temp_rcs-retail1product.retail_place_id
                buf_rcs-retail1product.retail_producer_id   = buf_temp_rcs-retail1product.retail_producer_id
                buf_rcs-retail1product.short_name           = buf_temp_rcs-retail1product.short_name
                buf_rcs-retail1product.weight_flag          = buf_temp_rcs-retail1product.weight_flag
                buf_rcs-retail1product.active               = buf_temp_rcs-retail1product.active
            .
            assign
                v-import-record-count                       = v-import-record-count + 1
            .
            assign
                fi-log :screen-value in frame Dialog-Frame = "Изменен товар: "
                                                + buf_temp_rcs-retail1product.id
                                                + "   " + string( v-gds-code )
                                                + "   " + buf_temp_rcs-retail1product.full_name
            .
        end.
        else do:
            run rcs/rcsgds.p (
                  input parparentproc
                , input 'ДОБАВЛЕНИЕ':U
                , input no
                , input 0
                , input no
                , input yes
                , input no
                , input yes
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes
                , input 0
                , input ""
                , input v-prod-type
                , input v-prod-code
                , input buf_gds-prt.node-code
                , input v-grp-code
                , input v-full-name
                , input ""
                , input v-full-name
                , input v-full-name
                , input replace( replace( v-full-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input v-country
                , input buf_units.unit-name
                , input buf_units.unit-name
                , input 0.0
                , input 0.0
                , input 1
                , input 1
                , input 0
                , input 0
                , input 0
                , input 0
                , input 'Группа':U
                , input 0
                , input yes
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input ""
                , input 0
                , input 0
                , input ""
                , input 0.0
                , input 0
                , input 0
                , input ""
                , input ""
                , input ""
                , input 0
                , input 0
                , input ""
                , input no
                , input no
                , input no
                , input no
                , input "no"
                , input v-goods-parameter-dif-nam1
                , input v-goods-parameter-dif-nam2
                , input yes
                , input no
                , input-output v-recid
                , output v-gds-code
            ) no-error .
            if error-status :error
            then do:
                message
                  vss-workfile vss-revision vss-description
                  skip "Ошибка создания карточки товара."
                  skip return-value
                  skip trim(error-status :get-message(1))
                       trim(error-status :get-message(2))
                       trim(error-status :get-message(3))
                       trim(error-status :get-message(4))
                       trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error "Ошибка создания товара в базе данных."
                                    + chr(10) + "ID товара: " + p-product-id
                                    + chr(10) + trim(error-status :get-message(1))
                                    + chr(10) + return-value
                .
            end.
            else do:
                create buf_rcs-retail1product.
                assign
                    buf_rcs-retail1product.id                   = buf_temp_rcs-retail1product.id
                    buf_rcs-retail1product.file-name            = fi-dir-imp :screen-value in frame Dialog-Frame
                    buf_rcs-retail1product.full_name            = buf_temp_rcs-retail1product.full_name
                    buf_rcs-retail1product.gds-code             = v-gds-code
                    buf_rcs-retail1product.imp-date             = v-today
                    buf_rcs-retail1product.imp-time             = v-time
                    buf_rcs-retail1product.imp-user             = v-cntxt-userid
                    buf_rcs-retail1product.retail_city_id       = buf_temp_rcs-retail1product.retail_city_id
                    buf_rcs-retail1product.retail_country_id    = buf_temp_rcs-retail1product.retail_country_id
                    buf_rcs-retail1product.retail_label_id      = buf_temp_rcs-retail1product.retail_label_id
                    buf_rcs-retail1product.retail_mark_id       = buf_temp_rcs-retail1product.retail_mark_id
                    buf_rcs-retail1product.retail_pack_id       = buf_temp_rcs-retail1product.retail_pack_id
                    buf_rcs-retail1product.retail_place_id      = buf_temp_rcs-retail1product.retail_place_id
                    buf_rcs-retail1product.retail_producer_id   = buf_temp_rcs-retail1product.retail_producer_id
                    buf_rcs-retail1product.short_name           = buf_temp_rcs-retail1product.short_name
                    buf_rcs-retail1product.weight_flag          = buf_temp_rcs-retail1product.weight_flag
                    buf_rcs-retail1product.active               = buf_temp_rcs-retail1product.active
                .
                assign
                    v-import-record-count                       = v-import-record-count + 1
                .
                assign
                    fi-log :screen-value in frame Dialog-Frame = "Импортирован товар: "
                                                    + buf_temp_rcs-retail1product.id
                                                    + "   " + string( v-gds-code )
                                                    + "   " + buf_temp_rcs-retail1product.full_name
                .
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE create-firm :
do
on error undo, return error
:
define input parameter p-city            as character    no-undo.
define input parameter p-ind             as integer      no-undo.
define input parameter p-addres1         as character    no-undo.
define input parameter p-addres2         as character    no-undo.
define input parameter p-director        as character    no-undo.
define input parameter p-gen-acct        as character    no-undo.
define input parameter p-phone           as character    no-undo.
define input parameter p-fax             as character    no-undo.
define input parameter p-engl-name       as character    no-undo.
define input parameter p-contact-psn     as character    no-undo.
define input parameter p-tobj-code       as integer      no-undo.
define input parameter p-inn             as character    no-undo.
define input parameter p-okpo            as character    no-undo.
define input parameter p-okonh           as character    no-undo.
define input parameter p-phone1-note     as character    no-undo.
define input parameter p-e-mail          as character    no-undo.
define input parameter p-post-addr1      as character    no-undo.
define input parameter p-post-addr2      as character    no-undo.
define input parameter p-telex           as character    no-undo.
define input parameter p-main-obj-type   as character    no-undo.
define input parameter p-main-obj-code   as integer      no-undo.
define output parameter p-firm-code      as integer      no-undo.
    define buffer buf_firm      for firm.
    run gen-b-code in this-procedure ( input 'fmgb':U, output p-firm-code) no-error .
    if error-status :error
    then do:
        undo, return error "create-firm: Ошибка генерации уникального кода для фирмы поставщика." + chr(10) + return-value.
    end.
    create buf_firm.
    assign
        buf_firm.firm-code      = p-firm-code
        buf_firm.city           = p-city
        buf_firm.ind            = p-ind
        buf_firm.addres1        = p-addres1
        buf_firm.addres2        = p-addres2
        buf_firm.director       = p-director
        buf_firm.gen-acct       = p-gen-acct
        buf_firm.phone          = p-phone
        buf_firm.fax            = p-fax
        buf_firm.engl-name      = p-engl-name
        buf_firm.contact-psn    = p-contact-psn
        buf_firm.tobj-code      = p-tobj-code
        buf_firm.inn            = p-inn
        buf_firm.okpo           = p-okpo
        buf_firm.okonh          = p-okonh
        buf_firm.phone1-note    = p-phone1-note
        buf_firm.e-mail         = p-e-mail
        buf_firm.post-addr1     = p-post-addr1
        buf_firm.post-addr2     = p-post-addr2
        buf_firm.telex          = p-telex
    .
end.
END PROCEDURE.
PROCEDURE create-clients :
do
on error undo, return error
:
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-obj-name  as character    no-undo.
define input parameter p-grp-code  as integer      no-undo.
define input parameter p-db-num    as integer      no-undo.
define input parameter p-stts      as integer      no-undo.
define input parameter p-PS        as character    no-undo.
define input parameter p-grp-name  as character    no-undo.
define input parameter p-num_podr  as integer      no-undo.
define input parameter p-is-prod   as logical      no-undo.
define input parameter p-sup-gds   as logical      no-undo.
define input parameter p-sup-serv  as logical      no-undo.
define input parameter p-buy-gds   as logical      no-undo.
define input parameter p-buy-serv  as logical      no-undo.
define input parameter p-buy-cons  as logical      no-undo.
define input parameter p-sup-cons  as logical      no-undo.
define input parameter p-lim-kr    as decimal      no-undo.
define buffer buf_clients       for clients.
    create buf_clients.
    assign
        buf_clients.obj-type    = p-obj-type
        buf_clients.obj-code    = p-obj-code
        buf_clients.obj-name    = p-obj-name
        buf_clients.grp-code    = p-grp-code
        buf_clients.stts        = p-stts
        buf_clients.PS          = p-PS
        buf_clients.grp-name    = p-grp-name
        buf_clients.num_podr    = p-num_podr
        buf_clients.is-prod     = p-is-prod
        buf_clients.sup-gds     = p-sup-gds
        buf_clients.sup-serv    = p-sup-serv
        buf_clients.buy-gds     = p-buy-gds
        buf_clients.buy-serv    = p-buy-serv
        buf_clients.buy-cons    = p-buy-cons
        buf_clients.sup-cons    = p-sup-cons
        buf_clients.lim-kr      = p-lim-kr
    .
    if p-db-num <> -1
    then do:
        assign
            buf_clients.db-num      = p-db-num
        .
    end.
end.
END PROCEDURE.
PROCEDURE import-bill :
do
on error undo, return error
:
define input parameter p-bill-id    as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    define variable v-today         as date           no-undo.
    define variable v-time          as integer        no-undo.
    define variable v-obj-type      as character      no-undo.
    define variable v-obj-code      as integer        no-undo.
    define variable v-host-code     as integer        no-undo.
    define variable v-host-name     as character      no-undo.
    define variable v-base-code     as integer        no-undo.
    define variable v-down-pay      as integer        no-undo.
    define variable v-doc-code      as character      no-undo.
    define variable v-line-num      as integer        no-undo.
    define variable v-was-moving    as logical        no-undo.
    define variable v-cli-type      as character      no-undo.
    define variable v-cli-code      as integer        no-undo.
    define variable v-cli-name      as character      no-undo.
    define variable v-base-rate     as decimal        no-undo.
    define variable v-base-scale    as integer        no-undo.
    define variable vss-description as character  init "import-bill: "       no-undo.
    define buffer buf_temp_rcs-retail1bill      for temp_rcs-retail1bill.
    define buffer buf_temp_rcs-retail1billitem  for temp_rcs-retail1billitem.
    define buffer buf_rcs-retail1bill           for rcs-retail1bill.
    define buffer buf_rcs-retail1billitem       for rcs-retail1billitem.
    define buffer buf_rcs-retail1product        for rcs-retail1product.
    define buffer buf_rcs-retail1subject        for rcs-retail1subject.
    define buffer buf_pay-type                  for pay-type.
    define buffer buf_trn-doc                   for trn-doc.
    define buffer buf_curr-accnt                for curr-accnt.
    define buffer buf_goods                     for goods.
    define buffer buf_cli-gds                   for cli-gds.
    find first buf_temp_rcs-retail1bill
         where buf_temp_rcs-retail1bill.id = p-bill-id
    no-error.
    if not available buf_temp_rcs-retail1bill
    then do:
        undo, return error vss-description + "Ошибка поиска во временной таблице.".
    end.
    find first buf_rcs-retail1bill no-lock
         where buf_rcs-retail1bill.id = buf_temp_rcs-retail1bill.id
    no-error.
    if available buf_rcs-retail1bill
    then do:
        run write-to-log-editor(
              input p-ed
            , input 1
            , input substitute( "Накладная &1 от &2 уже была импортирована.", buf_rcs-retail1bill.docnomer, buf_rcs-retail1bill.docdate  )
        ).
        undo, return.
    end.
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run get-shops-type-and-code in this-procedure (
          input buf_temp_rcs-retail1bill.site_id
        , output v-obj-type
        , output v-obj-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error vss-description + "Не определен объект для приходной накладной или не найден объект в настройках.".
    end.
    find first buf_pay-type no-lock
         where buf_pay-type.obj-code = v-cntxp-in-pay
    no-error .
    if not available buf_pay-type
    then do:
        undo, return error vss-description + "В настройках текущего объекта указан вид оплаты прихода: " + string( v-cntxp-in-pay ) + ", которого нет в справочнике!".
    end.
    find first buf_rcs-retail1subject no-lock
         where buf_rcs-retail1subject.id = buf_temp_rcs-retail1bill.subject_id
    no-error .
    if not available buf_rcs-retail1subject
    then do:
        undo, return error vss-description + "Не найден поставщик товара для приходной  накладной.".
    end.
    else do:
        assign
            v-cli-type = buf_rcs-retail1subject.obj-type
            v-cli-code = buf_rcs-retail1subject.obj-code
            v-cli-name = buf_rcs-retail1subject.cname
        .
    end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
    find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
          and buf_curr-accnt.exch-date <= v-today
    use-index pi
    no-error.
    assign
        v-base-rate  = buf_curr-accnt.exch-rate
        v-base-scale = buf_curr-accnt.exch-scale
    .
    if not available buf_curr-accnt then do:
        message
            "На дату" today "неизвестен курс базовой валюты."
        .
if session :set-wait-state( "" ) then.
        undo, return error.
    end.
    do transaction
    :
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-today
  )  .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-down-pay
  )  .
        run doc-code in this-procedure (
              input "main"
            , input v-obj-type
            , input v-obj-code
            , input ""
            , output v-doc-code
        ) .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input buf_curr-accnt.exch-rate
,input buf_curr-accnt.exch-scale
,input v-host-code
,input 'орг':U
,input v-host-name
,input v-cntxt-db-num-obj
,input v-cntxt-userid
,input ' '
,input v-doc-code
,input buf_temp_rcs-retail1bill.docdate
,input 'при':U
,input no
,input v-host-code
,input no
,input v-obj-code
,input v-obj-type
,input no
,input v-cntxp-in-pay
,input '@ Импортировано из RCS'
,input no
,input 'без':U
,input 'накл':U
,input 'в т. ч.':U
,input 'ie':U
,input 1
) no-error
.
        if error-status:error
        then do:
            message
                "Ошибка при создании складского документа."
            view-as alert-box error.
if session :set-wait-state( "" ) then.
            undo, return error.
        end.
        find first buf_trn-doc exclusive-lock
             where buf_trn-doc.doc-code = v-doc-code
        .
        assign
            buf_trn-doc.exch-date    = buf_temp_rcs-retail1bill.docdate
            buf_trn-doc.exch-code    = 0
            buf_trn-doc.exch-rate    = 1
            buf_trn-doc.exch-scale   = 1
            buf_trn-doc.base-rate    = v-base-rate
            buf_trn-doc.base-scale   = v-base-scale
            buf_trn-doc.print-rubl   = yes
            buf_trn-doc.wrkr         = v-default-wrkr
            buf_trn-doc.agnt         = v-default-agnt
            buf_trn-doc.boss         = v-default-boss
            buf_trn-doc.ret-supp     = no
            buf_trn-doc.cli-type     = v-cli-type
            buf_trn-doc.cli-code     = v-cli-code
            buf_trn-doc.cli-name     = v-cli-name
            buf_trn-doc.ord-num      = buf_temp_rcs-retail1bill.docnomer
            v-line-num               = 1
        .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input v-doc-code ,
                       input 'nids':U ,
                       input buf_temp_rcs-retail1bill.docnomer )  .
        for each temp_rcs-retail1billitem
           where temp_rcs-retail1billitem.bill_id = p-bill-id
        :
            find first buf_rcs-retail1product no-lock
                 where buf_rcs-retail1product.id = temp_rcs-retail1billitem.product_id
            no-error .
            if not available buf_rcs-retail1product
            then do:
                undo, return error vss-description + "Не найден товар для строки приходной накладной"
                                + chr(10) + "ID товара:    " + temp_rcs-retail1billitem.product_id
                                + chr(10) + "ID накладной: " + temp_rcs-retail1billitem.bill_id
                .
            end.
            else do:
                run rcs/rcscredl.p (
                      input parparentproc
                    , input buf_trn-doc.doc-code
                    , input buf_rcs-retail1product.gds-code
                    , input temp_rcs-retail1billitem.count1
                    , input temp_rcs-retail1billitem.cost1
                    , input v-base-rate
                    , input v-base-scale
                    , input v-line-num
                ) no-error .
                if error-status :error
                then do:
                    undo, return error vss-description + "Ошибка при создании строки документа.".
                end.
                else do:
                    assign
                        v-line-num = v-line-num + 1
                    .
                    create buf_rcs-retail1billitem .
                    assign
                        buf_rcs-retail1billitem.bill_id     = temp_rcs-retail1billitem.bill_id
                        buf_rcs-retail1billitem.cost1       = temp_rcs-retail1billitem.cost1
                        buf_rcs-retail1billitem.count1      = temp_rcs-retail1billitem.count1
                        buf_rcs-retail1billitem.product_id  = temp_rcs-retail1billitem.product_id
                        buf_rcs-retail1billitem.file-name   = fi-dir-imp :screen-value in frame Dialog-Frame
                        buf_rcs-retail1billitem.imp-date    = v-today
                        buf_rcs-retail1billitem.imp-time    = v-time
                        buf_rcs-retail1billitem.imp-user    = v-cntxt-userid
                    .
                end.
            end.
        end.
        create buf_rcs-retail1bill.
        assign
            buf_rcs-retail1bill.id          = buf_temp_rcs-retail1bill.id
            buf_rcs-retail1bill.site_id     = buf_temp_rcs-retail1bill.site_id
            buf_rcs-retail1bill.docnomer    = buf_temp_rcs-retail1bill.docnomer
            buf_rcs-retail1bill.docdate     = buf_temp_rcs-retail1bill.docdate
            buf_rcs-retail1bill.doc_type_id = buf_temp_rcs-retail1bill.doc_type_id
            buf_rcs-retail1bill.subject_id  = buf_temp_rcs-retail1bill.subject_id
            buf_rcs-retail1bill.doc-code    = buf_trn-doc.doc-code
            buf_rcs-retail1bill.obj-type    = v-obj-type
            buf_rcs-retail1bill.obj-code    = v-obj-code
            buf_rcs-retail1bill.file-name   = fi-dir-imp :screen-value in frame Dialog-Frame
            buf_rcs-retail1bill.imp-date    = v-today
            buf_rcs-retail1bill.imp-time    = v-time
            buf_rcs-retail1bill.imp-user    = v-cntxt-userid
        .
        run gbl/calc-trn.p (
              input parparentproc
            , input recid( buf_trn-doc )
        ).
        assign
            buf_trn-doc.tot-cli = buf_trn-doc.tot-calc
        .
    end.
    assign
        v-import-record-count                       = v-import-record-count + 1
    .
    assign
        fi-log :screen-value in frame Dialog-Frame = "Закачан документ: ID = " + temp_rcs-retail1bill.id
                                        + "  DOCNOMER = " + temp_rcs-retail1bill.docnomer
                                        + "  DOCDATE = " + string( temp_rcs-retail1bill.docdate )
                                        + "  SUBJECT = " + temp_rcs-retail1bill.subject_id
    .
    do transaction
    on error undo, return error substitute( "&1. &2. &3", return-value, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
    :
        run str/trn-stat.p (
              input parparentproc
            , input this-procedure
            , input '<закрытие документа>':U
            , input buf_trn-doc.doc-code
            , input no
            , input v-cntxt-db-num-obj
            , input v-cntxp-in-ov
            , input v-cntxp-rsrv-time
            , input v-cntxp-load-time
            , input v-cntxp-holidays
            , input yes
            , output v-was-moving
            , output table gds-list
        ) .
    end.
end.
END PROCEDURE.
PROCEDURE import-price :
do
on error undo, return error
:
define input parameter p-price-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
    define variable v-price-doc-recid   as recid        no-undo.
    define variable v-update            as logical      no-undo.
    define buffer buf_temp_rcs-retail1price     for temp_rcs-retail1price.
    define buffer buf_temp_rcs-retail1priceitem for temp_rcs-retail1priceitem.
    define buffer buf_rcs-retail1priceitem      for rcs-retail1priceitem.
    define buffer buf_rcs-retail1price          for rcs-retail1price.
    define buffer buf_price-doc                 for price-doc.
    find first buf_temp_rcs-retail1price
         where buf_temp_rcs-retail1price.price_id = p-price-id
    no-error.
    if not available buf_temp_rcs-retail1price
    then do:
        undo, return error "import-price: Ошибка поиска во временной таблице." .
    end.
    find first buf_rcs-retail1price no-lock
         where buf_rcs-retail1price.price_id = buf_temp_rcs-retail1price.price_id
    no-error.
    if available buf_rcs-retail1price
    then do:
        run write-to-log-editor(
              input p-ed
            , input 1
            , input substitute( "Переоценка &1 от &2 уже была импортирована.", buf_rcs-retail1price.doc-num, buf_rcs-retail1price.ddat  )
        ).
        undo, return.
    end.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    run get-shops-type-and-code (
          input buf_temp_rcs-retail1price.site_id
        , output v-obj-type
        , output v-obj-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "import-price: Ошибка вычисления кода объекта для документа переоценки." + chr(10) + return-value.
    end.
    do transaction :
        run prcreate-new-price-doc in this-procedure (
              input v-cntxt-db-num
            , input v-obj-type
            , input v-obj-code
            , input ?
            , input ?
            , input ?
            , input ?
            , output v-price-doc-recid
        ) no-error.
        if error-status:error
        then do:
            undo, return error "import-price: Не удалось создать документ переоценки." + chr(10) + return-value.
        end.
        find first buf_price-doc exclusive-lock
             where recid( buf_price-doc ) = v-price-doc-recid
        .
        assign
            buf_price-doc.PS = "@ Импорт RCS"
        .
        for each buf_temp_rcs-retail1priceitem
           where buf_temp_rcs-retail1priceitem.price_id = buf_temp_rcs-retail1price.price_id
        :
            find first rcs-retail1product no-lock
                 where rcs-retail1product.id = buf_temp_rcs-retail1priceitem.id
            no-error .
            if not available rcs-retail1product
            then do:
                undo, return error "create-bill: Не удалось найти товар для строки прайс-листа."
                                + chr(10) + "ID товара: " + buf_temp_rcs-retail1priceitem.id
                .
            end.
            else do:
                run prcreate-new-price-list in this-procedure (
                      input v-price-doc-recid
                    , input rcs-retail1product.gds-code
                    , input buf_temp_rcs-retail1priceitem.price_cost
                    , output v-update
                ) no-error.
                if error-status:error
                then do:
                    undo, return error substitute( "import-price: Не удалось создать строку документа переоценки для товара с кодом: &1", rcs-retail1product.gds-code ) + chr(10) + return-value.
                end.
                create buf_rcs-retail1priceitem.
                assign
                    buf_rcs-retail1priceitem.id         = buf_temp_rcs-retail1priceitem.id
                    buf_rcs-retail1priceitem.price_id   = buf_temp_rcs-retail1priceitem.price_id
                    buf_rcs-retail1priceitem.price_cost = buf_temp_rcs-retail1priceitem.price_cost
                    buf_rcs-retail1priceitem.active     = buf_temp_rcs-retail1priceitem.active
                    buf_rcs-retail1priceitem.file-name  = fi-dir-imp :screen-value in frame Dialog-Frame
                    buf_rcs-retail1priceitem.imp-date   = v-today
                    buf_rcs-retail1priceitem.imp-time   = v-time
                    buf_rcs-retail1priceitem.imp-user   = v-cntxt-userid
                .
            end.
        end.
        create buf_rcs-retail1price.
        assign
            buf_rcs-retail1price.price_id   = buf_temp_rcs-retail1price.price_id
            buf_rcs-retail1price.site_id    = buf_temp_rcs-retail1price.site_id
            buf_rcs-retail1price.ddat       = buf_temp_rcs-retail1price.ddat
            buf_rcs-retail1price.corr       = buf_temp_rcs-retail1price.corr
            buf_rcs-retail1price.stad       = buf_temp_rcs-retail1price.stad
            buf_rcs-retail1price.doc-mode   = buf_temp_rcs-retail1price.doc-mode
            buf_rcs-retail1price.doc_type   = buf_temp_rcs-retail1price.doc_type
            buf_rcs-retail1price.doc-num    = buf_price-doc.doc-num
            buf_rcs-retail1price.obj-type   = buf_price-doc.obj-type
            buf_rcs-retail1price.obj-code   = buf_price-doc.obj-code
            buf_rcs-retail1price.file-name  = fi-dir-imp :screen-value in frame Dialog-Frame
            buf_rcs-retail1price.imp-date   = v-today
            buf_rcs-retail1price.imp-time   = v-time
            buf_rcs-retail1price.imp-user   = v-cntxt-userid
        .
    end.
    assign
        v-import-record-count                       = v-import-record-count + 1
    .
    assign
        fi-log :screen-value in frame Dialog-Frame = "Закачана переоценка: ID = " + buf_rcs-retail1price.price_id
                                        + "  DDAT = " + string( buf_rcs-retail1price.ddat )
                                        + "  DOCNUM = " + string( buf_rcs-retail1price.doc-num )
    .
end.
END PROCEDURE.
PROCEDURE get-default-value :
do
on error undo, return error
:
define input parameter p-value-type as character    no-undo.
define output parameter p-value     as character    no-undo.
define buffer buf_usr-flt   for ubflt.usr-flt.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = p-value-type
    no-error .
    if not available buf_usr-flt
    then do:
        undo, return error "get-default-value: Ошибка получения значения по умолчанию.".
    end.
    else do:
        assign
            p-value = buf_usr-flt.Naim
        .
    end.
end.
END PROCEDURE.
PROCEDURE import-barcode :
do
on error undo, return error
:
define input parameter p-barcode-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    define variable v-unit-name     as character        no-undo.
    define variable v-today         as date             no-undo.
    define variable v-time          as integer          no-undo.
    define variable v-go-next       as logical  init no no-undo.
    define variable l-is-weight as logical no-undo .
    define variable l-is-pgweight as logical no-undo .
    define variable l-is-petrolium as logical no-undo .
    define buffer buf_temp_rcs-retail1barcode   for temp_rcs-retail1barcode.
    define buffer buf_rcs-retail1product        for rcs-retail1product.
    define buffer buf_rcs-retail1barcode        for rcs-retail1barcode.
    define buffer buf_prod-bc                   for prod-bc.
    define buffer buf_goods                     for goods.
    define buffer buf_gds-prt                   for gds-prt.
    find first buf_temp_rcs-retail1barcode
         where buf_temp_rcs-retail1barcode.id = p-barcode-id
    no-error.
    if not available buf_temp_rcs-retail1barcode
    then do:
        undo, return error "import-barcode: Ошибка поиска во временной таблице." .
    end.
    find first buf_rcs-retail1product no-lock
         where buf_rcs-retail1product.id = buf_temp_rcs-retail1barcode.retail_product_id
    no-error.
    if not available buf_rcs-retail1product
    then do:
        undo, return error "import-barcode: Не был закачан товар для привязки бар-кода." .
    end.
    else do:
        find first buf_prod-bc no-lock
             where buf_prod-bc.b-str = buf_temp_rcs-retail1barcode.barcode
        no-error.
        if available buf_prod-bc
        then do:
            run write-to-log-editor( p-ed, 5, "import-barcode: Бар-код с ID '" + p-barcode-id + "' ( barcode = '" + buf_temp_rcs-retail1barcode.barcode + "' ) уже есть в базе данных." ).
            assign
                v-go-next = yes
            .
        end.
        else do:
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_rcs-retail1product.gds-code
            no-error.
            if not available buf_goods
            then do:
                undo, return error "import-barcode: Нет закачанного товара для привязки бар-кода." .
            end.
            else do:
                find first buf_gds-prt no-lock
                     where buf_gds-prt.upper-code = buf_goods.prt-root
                no-error .
                if not available buf_gds-prt
                then do:
                    undo, return error "import-barcode: В карточке товара неверно задан код шкалы."
                                    + chr(10) + "Артикул товара: " + string( buf_goods.artic )
                                    + chr(10) + "Производитель : " + string( buf_goods.prod-type )
                                    + chr(10) + "                " + string( buf_goods.prod-code )
                    .
                end.
                else do:
                    case buf_rcs-retail1product.weight_flag
                    :
                        when 0
                        then do:
                            assign
                                v-unit-name = v-unit-pieces
                            .
                        end.
                        when 1
                        then do:
                            assign
                                v-unit-name = v-unit-divisional
                            .
                        end.
                        when 2
                        then do:
                            assign
                                v-unit-name = v-unit-weight
                            .
                        end.
                        otherwise do:
                            undo, return error "import-barcode: Товар с ID '" + buf_rcs-retail1product.id + "был импортирован с неверным значением единицы измерения".
                        end.
                    end case.
                    if v-unit-name <> buf_goods.unit-base
                    then do:
                        undo, return error "import-barcode: Единица измерения для бар-кода не соответствует импортируемой для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
                    end.
                end.
            end.
        end.
    end.
    if v-go-next = no
    then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_temp_rcs-retail1barcode.barcode
  ,input  buf_goods.unit-base
  ,input  buf_goods.unit-base
  ,input  'weight=request':u
  ,output l-is-weight
  )  .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_temp_rcs-retail1barcode.barcode
  ,input  buf_goods.unit-base
  ,input  buf_goods.unit-base
  ,input  'pgweight=request':u
  ,output l-is-pgweight
  )  .
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_temp_rcs-retail1barcode.barcode
  ,input  buf_goods.unit-base
  ,input  buf_goods.unit-base
  ,input  'petrolium=request':u
  ,output l-is-petrolium
  )  .
        if (l-is-weight
        or l-is-pgweight
        or l-is-petrolium
        ) then do:
          undo, return error "import-barcode: Невоможно импортировать весовой или топливный бар-код для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
        end.
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        do transaction :
          define variable v-b-str as character no-undo .
          define variable rid as recid no-undo .
          v-b-str = buf_temp_rcs-retail1barcode.barcode.
          rid = ?.
          run trg/prod-bc1.p (
                              input  parparentproc
                              ,input yes
                              ,input dif-pdbc
                              ,input pbc-veto
                              ,input no
                              ,input ''
                              ,input ""
                              ,buffer buf_goods
                              ,input buf_rcs-retail1product.gds-code
                              ,input-output v-b-str
                              ,output rid
                              ) no-error.
           if error-status :error then do:
             undo, return error "import-barcode: Ошибка при  импорте бар-кода для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
           end.
           else if rid = ? then do:
             undo, return error "import-barcode: Невоможно импортировать бар-код для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
           end.
            create buf_rcs-retail1barcode.
            assign
                buf_rcs-retail1barcode.id                   = buf_temp_rcs-retail1barcode.id
                buf_rcs-retail1barcode.barcode              = buf_temp_rcs-retail1barcode.barcode
                buf_rcs-retail1barcode.retail_product_id    = buf_temp_rcs-retail1barcode.retail_product_id
                buf_rcs-retail1barcode.b-code               = buf_goods.gds-code
                buf_rcs-retail1barcode.b-str                = buf_temp_rcs-retail1barcode.barcode
                buf_rcs-retail1barcode.file-name            = fi-dir-imp :screen-value in frame Dialog-Frame
                buf_rcs-retail1barcode.imp-date             = v-today
                buf_rcs-retail1barcode.imp-time             = v-time
                buf_rcs-retail1barcode.imp-user             = v-cntxt-userid
            .
        end.
        assign
            v-import-record-count                       = v-import-record-count + 1
        .
        assign
            fi-log :screen-value in frame Dialog-Frame = "Закачан бар-код: ID = " + buf_rcs-retail1barcode.id
                                            + "  BARCODE = " + string( buf_temp_rcs-retail1barcode.barcode )
        .
    end.
end.
END PROCEDURE.
PROCEDURE get-shops-id :
do
on error undo, return error
:
define input parameter p-shops-obj-type as character    no-undo.
define input parameter p-shops-obj-code as integer      no-undo.
define output parameter p-shops-id      as character    no-undo.
    define buffer buf_rcs-shops     for rcs-shops.
    find first buf_rcs-shops no-lock
         where buf_rcs-shops.obj-type = p-shops-obj-type
           and buf_rcs-shops.obj-code = p-shops-obj-code
    no-error.
    if not available buf_rcs-shops
    then do:
        undo, return error "get-shops-id: Не найден ID объекта."
                + chr(10) + "Тип объекта: " + p-shops-obj-type
                + chr(10) + "Код объекта: " + string( p-shops-obj-code )
        .
    end.
    else do:
        assign
            p-shops-id = buf_rcs-shops.id
        .
    end.
end.
END PROCEDURE.
PROCEDURE check-and-create-subdir :
do
on error undo, return error
:
define input parameter p-parent-dir as character    no-undo.
define input parameter p-subdir     as character    no-undo.
    define variable v-dir-exists     as logical init no   no-undo.
    find first temp_dir no-error.
    if not available temp_dir
    then do:
        create temp_dir.
    end.
    input from os-dir( p-parent-dir ).
    search-dir:
    repeat
    :
        import temp_dir.
        if temp_dir.type = "D"
        then do:
            if caps( temp_file.name ) = "OLD"
            then do:
                assign
                    v-dir-exists = yes
                .
                leave search-dir.
            end.
            else do:
                assign
                    v-dir-exists = no
                .
            end.
        end.
    end.
    input close.
    if v-dir-exists = no
    then do:
        os-create-dir value( p-parent-dir + chr(92) + p-subdir ) .
        if os-error <> 0
        then do:
            undo, return error "Ошибка создания подкаталога OLD".
        end.
    end.
end.
END PROCEDURE.
PROCEDURE get-or-generate-filename :
do
on error undo, return error
:
define input parameter p-dir            as character    no-undo.
define input parameter p-filename       as character    no-undo.
define output parameter p-full-filename as character    no-undo.
    define variable v-counter       as integer          no-undo.
    assign
        v-counter = 0
        p-full-filename = p-dir + chr(92) + p-filename
    .
    if search ( p-full-filename ) <> ?
    then do:
        generate-filename:
        do while true
        :
            assign
                v-counter = v-counter + 1
                p-full-filename = p-dir + chr(92) + entry( 1, p-filename, "." )   + string( v-counter )
                                        + ( if num-entries( p-filename, "." ) > 1 then entry( 2, p-filename, "." ) else "." )
            .
            if search ( p-full-filename ) = ?
            then do:
                leave generate-filename.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE delete-record :
do
on error undo, return error
:
define input parameter p-name   as character    no-undo.
define input parameter p-id     as character    no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable vss-description as character init "delete-record: " no-undo.
define buffer buf_bar-code              for bar-code.
define buffer buf_prod-bc               for prod-bc.
define buffer buf_rcs-retail1barcode    for rcs-retail1barcode.
define buffer buf_rcs-retail1delete     for rcs-retail1delete.
case p-name
:
    when "RETAIL1_BARCODE"
    then do:
        find first buf_rcs-retail1barcode no-lock
             where buf_rcs-retail1barcode.id = p-id
        no-error.
        if not available buf_rcs-retail1barcode
        then do:
            undo, return error vss-description + "Попытка удалить не импортированный бар-код.".
        end.
        find first buf_bar-code no-lock
             where buf_bar-code.b-code = buf_rcs-retail1barcode.b-code
        no-error.
        if not available buf_bar-code
        then do:
            undo, return error vss-description + "Не найден основной бар-код товара.".
        end.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        do transaction :
            find first buf_prod-bc exclusive-lock
                 where buf_prod-bc.b-code           = buf_bar-code.b-code
                   and buf_prod-bc.b-str            = buf_rcs-retail1barcode.b-str
            no-error.
            if error-status :error
            then do:
                undo, return error vss-description + "Не найден дополнительный бар-код товара.".
            end.
            delete buf_prod-bc.
            create buf_rcs-retail1delete.
            assign
                buf_rcs-retail1delete.id            = p-id
                buf_rcs-retail1delete.name          = p-name
                buf_rcs-retail1delete.file-name     = fi-dir-imp :screen-value in frame Dialog-Frame
                buf_rcs-retail1delete.imp-date      = v-today
                buf_rcs-retail1delete.imp-time      = v-time
                buf_rcs-retail1delete.imp-user      = v-cntxt-userid
            .
        end.
        assign
            v-import-record-count                       = v-import-record-count + 1
        .
        assign
            fi-log :screen-value in frame Dialog-Frame = "Удален бар-код: ID = " + buf_rcs-retail1delete.id
                                            + "  BARCODE = " + string( buf_rcs-retail1barcode.b-str )
        .
    end.
    otherwise do:
        undo, return error vss-description + "Не определено удаление для заданной записи.".
    end.
end case.
end.
END PROCEDURE.
procedure genscode-generate-num-bank :
do
on error undo, return error
:
define output parameter p-bank-num as integer no-undo.
assign
    p-bank-num = next-value( s-bank, ub )
.
end.
end procedure.
