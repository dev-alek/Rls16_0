define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-store-type         as character    no-undo.
define input parameter p-store-code         as integer      no-undo.
define input parameter p-button-list        as character    no-undo.
define input-output parameter p-recid-list  as character    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп блюд".
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
define temp-table temp_fbrglib_grp no-undo
    field sel           as character
    field full-name     as character
    field out-code      as integer
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field name          as character
    field level         as integer
    field mark          as character
    field obj-type      as character
    field obj-code      as integer
    field global-code   as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index nc is unique obj-type obj-code node-code
    index sl obj-type obj-code sel
    index uc obj-type obj-code upper-code
.
define temp-table temp_fbrglib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field obj-type      as character
    field obj-code      as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index lv obj-type obj-code level
    index it obj-type obj-code is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as integer
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure fbrglib-get-sort-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-obj-type
           and buf_fbr-gds-grp.obj-code  = p-obj-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while true
    on error undo, return error "fbrglib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_fbr-gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_fbr-gds-grp.upper-code
        .
        if buf_fbr-gds-grp.upper-code = 1
        then do:
            leave.
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
procedure fbrglib-get-full-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    if p-node-code = 1
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 1
        .
        do while true
        on error undo, return error "fbrglib-get-full-name: Ошибка составления полного имени группы"
        :
            assign
                p-full-name  = buf_fbr-gds-grp.node-name
                            + (if p-full-name <> "" then chr(47) else "")
                            + p-full-name
                v-upper-code = buf_fbr-gds-grp.upper-code
            .
            if buf_fbr-gds-grp.upper-code = 1
            then do:
                leave.
            end.
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-node-code".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure.
procedure fbrglib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-obj-type     as character    no-undo.
define input parameter p-obj-code     as integer      no-undo.
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define variable v-node-name     as character      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run fbrglib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "fbrglib-find-grp-by-full-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_fbrglib_found-grp
    :
        delete temp_fbrglib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            assign
                v-node-name = entry( v-counter, p-search-name, chr(2) )
            .
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type   = p-obj-type
                   and buf_fbr-gds-grp.obj-code   = p-obj-code
                   and buf_fbr-gds-grp.upper-code = v-upper-code
                   and buf_fbr-gds-grp.node-name  = v-node-name
            no-error .
            if not available buf_fbr-gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_fbr-gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_fbr-gds-grp.node-name
                    v-upper-code = buf_fbr-gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name = v-full-name + chr(47)
                        temp_fbrglib_found-grp.sort-name = v-sort-name
                        temp_fbrglib_found-grp.node-code = v-upper-code
                        temp_fbrglib_found-grp.level     = v-counter
                        temp_fbrglib_found-grp.obj-type  = p-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-obj-code
                    .
                end.
            end.
        end.
        else do:
            for each buf_fbr-gds-grp no-lock
               where buf_fbr-gds-grp.obj-type   = p-obj-type
                 and buf_fbr-gds-grp.obj-code   = p-obj-code
                 and buf_fbr-gds-grp.upper-code = v-upper-code
                 and buf_fbr-gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_fbr-gds-grp.node-name
                    temp_fbrglib_found-grp.node-code = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.level     = v-level
                    temp_fbrglib_found-grp.obj-type  = p-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-obj-code
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_fbrglib_found-grp
                :
                    delete temp_fbrglib_found-grp.
                end.
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-full-name
    ).
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
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
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-start-obj-type
             and buf_fbr-gds-grp.obj-code   = p-start-obj-code
             and buf_fbr-gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run fbrglib-is-terminal in this-procedure (
                  input buf_fbr-gds-grp.obj-type
                , input buf_fbr-gds-grp.obj-code
                , input buf_fbr-gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.is-terminal = yes
                    temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_fbr-gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                        temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                        temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                        temp_fbrglib_found-grp.is-terminal = no
                        temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-start-obj-code
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
procedure fbrglib-expand-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-start-name as character    no-undo.
define output parameter p-end-name  as character    no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_fbrglib_found-grp     for temp_fbrglib_found-grp.
    run fbrglib-find-grp-by-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-start-name
        , input no
    ) no-error.
    run fbrglib-get-max-substring in this-procedure (
           input p-obj-type
        ,  input p-obj-code
        ,  input length( p-start-name )
        , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_fbrglib_found-grp
             where temp_fbrglib_found-grp.full-name = p-end-name
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                     no-error.
        if available temp_fbrglib_found-grp
        then do:
            find first buf_temp_fbrglib_found-grp
                 where buf_temp_fbrglib_found-grp.full-name begins p-end-name
                   and recid( buf_temp_fbrglib_found-grp ) <> recid( temp_fbrglib_found-grp )
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
            no-error.
            if not available buf_temp_fbrglib_found-grp
            then do:
                run fbrglib-is-terminal in this-procedure (
                      input p-obj-type
                    , input p-obj-code
                    , input temp_fbrglib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-get-max-substring :
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_fbrglib_found-grp  where
                   temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
        no-error.
        if not available temp_fbrglib_found-grp
        then do:
            undo, return error "fbrglib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_fbrglib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "fbrglib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_fbrglib_found-grp
                where temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_fbrglib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
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
procedure fbrglib-is-terminal :
do
on error undo, return error "Ошибка процедуры fbrglib-is-terminal"
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-obj-type
           and buf_fbr-gds-grp.obj-code   = p-obj-code
           and buf_fbr-gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
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
procedure fbrglib-have-goods :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-node-code          as integer      no-undo.
define output parameter p-have-fbr-gds-obj  as logical      no-undo.
    define buffer buf_fbr-gds-obj         for ub.fbr-gds-obj.
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type     = p-obj-type
           and buf_fbr-gds-obj.obj-code     = p-obj-code
           and buf_fbr-gds-obj.fbr-grp-code = p-node-code
    no-error .
    if available buf_fbr-gds-obj
    then do:
        assign
            p-have-fbr-gds-obj = yes
        .
    end.
    else do:
        assign
            p-have-fbr-gds-obj = no
        .
    end.
end.
end procedure.
procedure fbrglib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    search-grp:
    for each buf_fbr-gds-grp no-lock
        where buf_fbr-gds-grp.obj-type  = p-start-obj-type
          and buf_fbr-gds-grp.obj-code  = p-start-obj-code
          and buf_fbr-gds-grp.node-code > p-start-code
    :
        if index( buf_fbr-gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_fbr-gds-grp.node-code
                v-found      = yes
            .
            run fbrglib-get-full-name in this-procedure (
                  input p-start-obj-type
                , input p-start-obj-code
                , input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "fbrglib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
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
procedure fbrglib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
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
        run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "fbrglib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-delete-grp :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-deleted   as logical      no-undo.
    define variable v-have-goods    as logical        no-undo.
    define variable v-yesno         as logical        no-undo.
    define variable v-upper-code    as integer        no-undo.
    define variable v-root-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj           for ub.fbr-gds-obj.
    define buffer buf_second_fbr-gds-grp    for ub.fbr-gds-grp.
    run fbrglib-get-root-code in this-procedure (
        output v-root-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "Не найден корневой узел." + chr(10) + return-value.
    end.
    if p-node-code = v-root-code
    then do:
        message
            "Корневую группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.upper-code   = p-node-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Не терминальную группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.node-code    = p-node-code
    .
    assign
        v-upper-code = buf_fbr-gds-grp.upper-code
    .
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ).
    if v-have-goods = yes
    then do:
        find first buf_second_fbr-gds-grp no-lock
             where buf_second_fbr-gds-grp.obj-type      = buf_fbr-gds-grp.obj-type
               and buf_second_fbr-gds-grp.obj-code      = buf_fbr-gds-grp.obj-code
               and buf_second_fbr-gds-grp.upper-code    = buf_fbr-gds-grp.upper-code
               and recid( buf_second_fbr-gds-grp )      <> recid( buf_fbr-gds-grp )
        no-error.
        if available buf_second_fbr-gds-grp
        then do:
            message
                "В группе есть товары,"
                skip "которые нельзя перенести в родительскую группу,"
                skip "потому что у родительской группы есть еще одна подгруппа."
                skip(1)
                skip "Перенесите товары в другую группу"
                skip "или удалите все остальные подгруппы родительской группы."
            view-as alert-box error.
            assign
                p-deleted = no
            .
            undo, return.
        end.
        message
            "В группе есть товары."
            skip "После удаления группы"
            skip "все ее товары будут привязаны"
            skip "к ее родительской группе."
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                for each buf_fbr-gds-obj exclusive-lock
                   where buf_fbr-gds-obj.obj-type     = p-obj-type
                     and buf_fbr-gds-obj.obj-code     = p-obj-code
                     and buf_fbr-gds-obj.fbr-grp-code = p-node-code
                on error undo, return error
                :
                    assign
                        buf_fbr-gds-obj.fbr-grp-code = v-upper-code
                    .
                end.
            end.
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error .
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
    else do:
        message
            "Имя группы: " buf_fbr-gds-grp.node-name
            "Код группы: " buf_fbr-gds-grp.node-code
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error.
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-add-grp :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-interface      as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.
define output parameter p-new-node-code as integer      no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-have-goods    as logical  no-undo.
    define variable v-host-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.upper-code = p-node-code
          AND buf_fbr-gds-grp.obj-type   = p-obj-type
          AND buf_fbr-gds-grp.obj-code   = p-obj-code
          AND buf_fbr-gds-grp.node-name  = p-node-name no-error .
    if available buf_fbr-gds-grp then do:
        if p-node-code <> 1 then do:
          find first buf_fbr-gds-grp no-lock where
                    buf_fbr-gds-grp.node-code = p-node-code
                AND buf_fbr-gds-grp.obj-type   = p-obj-type
                AND buf_fbr-gds-grp.obj-code   = p-obj-code  .
        end.
                message
        "Для объекта" p-obj-type p-obj-code
        "уже есть группа блюд" p-node-name "в подгруппе" (if p-node-code = 1 then "БЛЮДА" else buf_Fbr-gds-grp.node-name)
        view-as alert-box error .
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-gds-grp.
        assign
            buf_fbr-gds-grp.node-code   = next-value( s-gds-grp, ub )
            p-new-node-code             = buf_fbr-gds-grp.node-code
            buf_fbr-gds-grp.upper-code  = p-node-code
            buf_fbr-gds-grp.host-code   = v-host-code
            buf_fbr-gds-grp.obj-type    = p-obj-type
            buf_fbr-gds-grp.obj-code    = p-obj-code
            buf_fbr-gds-grp.node-name    = ""
            buf_fbr-gds-grp.out-code    = 0
        .
        if p-interface then do:
          run ref/fbrggrpd.w (
                input parparentproc
              , input 'ИЗМЕНЕНИЕ':U
              , input p-obj-type
              , input p-obj-code
              , input buf_fbr-gds-grp.node-code
              , input buf_fbr-gds-grp.upper-code
              , input buf_fbr-gds-grp.node-name
              , input buf_fbr-gds-grp.out-code
              , output buf_fbr-gds-grp.node-name
              , output buf_fbr-gds-grp.out-code
              , output p-cancel
          ).
          if p-cancel = yes
          then do:
              delete buf_fbr-gds-grp.
              undo, return.
          end.
        end.
        else do:
          find first bf_fbr-gds-grp no-lock
              where bf_fbr-gds-grp.obj-type   = p-obj-type
                and bf_fbr-gds-grp.obj-code   = p-obj-code
                and bf_fbr-gds-grp.out-code   = p-out-code
          no-error.
          assign
          buf_fbr-gds-grp.node-name    = p-node-name
          buf_fbr-gds-grp.global-code  = p-global-code
          buf_fbr-gds-grp.out-code     = (if available bf_fbr-gds-grp then 0 else p-out-code)
          .
        end.
        if v-have-goods = yes
        then do:
            for each buf_fbr-gds-obj exclusive-lock
               where buf_fbr-gds-obj.obj-type      = p-obj-type
                 and buf_fbr-gds-obj.obj-code      = p-obj-code
                 and buf_fbr-gds-obj.fbr-grp-code  = p-node-code
            on error undo, return error
            :
                assign
                    buf_fbr-gds-obj.fbr-grp-code = p-new-node-code
                .
            end.
        end.
    end.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function chkleave returns logical
(input p-widget-enter as handle
,input p-button-list  as character
).
  if  valid-handle(p-widget-enter)
  and can-query(p-widget-enter, "name":u)
  and lookup(p-widget-enter :name, p-button-list) > 0
  then do:
    return false .
  end.
  return true .
end function.
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-fbrggrp-root-code         as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable v-found-grp-num-0             as integer  init 0  no-undo.
define variable v-full-search-string-0        as character        no-undo.
define variable v-full-search-next-0          as logical  init no no-undo.
define variable v-full-search-start-code-0    as integer          no-undo.
define variable v-rubr                        as logical  init no no-undo.
define variable print-option as character no-undo.
define variable fbr-gds-grp-row as integer init 1 no-undo.
define variable v-b-expand-col             as decimal no-undo .
define variable v-b-expand-all-col         as decimal no-undo .
define variable v-b-find-by-full-name-col  as decimal no-undo .
define variable v-b-find-by-substring-col  as decimal no-undo .
define variable v-b-search-col             as decimal no-undo .
define variable v-fi-search-col            as decimal no-undo .
define variable v-rubr-mode                as integer no-undo .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
DEFINE BUFFER buf0_temp_fbrglib_grp FOR temp_fbrglib_grp.
DEFINE MENU MENU-b-print
       MENU-ITEM m_classificator LABEL "Классификатор по объекту"
       MENU-ITEM m_browse       LABEL "Справочник"
       MENU-ITEM m_browse-global LABEL "Рубрикатор"
       MENU-ITEM m_term         LABEL "Содержимое терминальных групп".
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить группу"
     BGCOLOR 8 .
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название и характеристики группы"
     BGCOLOR 8 .
DEFINE BUTTON b-copy
     LABEL "&Копировать"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-copy0
     LABEL "Копи&я->"
     SIZE 9 BY 1 TOOLTIP "Скопировать ~"ветку~" рубрикатора на объект".
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .
DEFINE BUTTON b-expand
     LABEL ">>"
     SIZE 3.5 BY 1.13.
DEFINE BUTTON b-expand-0
     LABEL ">>"
     SIZE 3.5 BY 1.13.
DEFINE BUTTON b-expand-all
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.
DEFINE BUTTON b-expand-all-0
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.
DEFINE BUTTON b-find-by-full-name
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .
DEFINE BUTTON b-find-by-full-name-0
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .
DEFINE BUTTON b-find-by-substring
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .
DEFINE BUTTON b-find-by-substring-0
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .
DEFINE BUTTON B-global
     LABEL "&Рубр-тор"
     SIZE 10 BY 1.
DEFINE BUTTON b-goods
     LABEL "&Товары"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-link
     LABEL "&Связь<-"
     SIZE 9 BY 1 TOOLTIP "Проставить рубрику группе блюд на объекте".
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-move
     LABEL "П&еренести"
     SIZE 10 BY 1 TOOLTIP "Переместить группу"
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать списка групп".
DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .
DEFINE BUTTON b-search-0
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .
DEFINE BUTTON b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-sel-kitchen
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE VARIABLE fi-kitchen-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-kitchen-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 22.13 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-search-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 22.13 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-rubr
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 12 BY 1
     BGCOLOR 9 .
DEFINE QUERY br-global FOR
      buf0_temp_fbrglib_grp SCROLLING.
DEFINE QUERY br-list FOR
      temp_fbrglib_grp SCROLLING.
DEFINE BROWSE br-global
  QUERY br-global DISPLAY
      buf0_temp_fbrglib_grp.sel           format "X(1)" no-label
      buf0_temp_fbrglib_grp.global-code   format ">>>>9"      COLUMN-LABEL "Код"
      buf0_temp_fbrglib_grp.name          format "X(71)"      COLUMN-LABEL "Наименование группы"
      buf0_temp_fbrglib_grp.out-code      format ">>>>9"      COLUMN-LABEL "Код на!кассе"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42 BY 16.67
         FGCOLOR 1
         TITLE FGCOLOR 1 "Группы блюд (Рубрикатор)".
DEFINE BROWSE br-list
  QUERY br-list DISPLAY
      temp_fbrglib_grp.sel           format "X(1)" no-label
      temp_fbrglib_grp.global-code   format ">>>>9"      COLUMN-LABEL "Руб-р"
      temp_fbrglib_grp.name          format "X(71)"      COLUMN-LABEL "Наименование группы"
      temp_fbrglib_grp.out-code      format ">>>>9"      COLUMN-LABEL "Код на!кассе"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56 BY 16.67
         TITLE "Группы блюд для объекта".
DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-chg AT ROW 1 COL 34
     b-del AT ROW 1 COL 44
     b-move AT ROW 1 COL 54
     b-goods AT ROW 1 COL 64
     b-print AT ROW 1 COL 79.38
     b-help AT ROW 1 COL 89.38
     B-global AT ROW 2 COL 12
     b-copy AT ROW 2 COL 24
     fi-kitchen-type AT ROW 2 COL 35.38 COLON-ALIGNED
     fi-kitchen-code AT ROW 2 COL 40.75 COLON-ALIGNED NO-LABEL
     bt-sel-kitchen AT ROW 2 COL 50.13
     B-hist AT ROW 2 COL 79.38
     b-expand-0 AT ROW 3 COL 1
     b-expand-all-0 AT ROW 3 COL 4.5
     fi-search-0 AT ROW 3 COL 12 NO-LABEL
     b-find-by-full-name-0 AT ROW 3 COL 34.38
     b-find-by-substring-0 AT ROW 3 COL 37.38
     b-search-0 AT ROW 3 COL 40.38
     b-expand AT ROW 3 COL 51
     b-expand-all AT ROW 3 COL 54.5
     fi-search AT ROW 3 COL 62 NO-LABEL
     b-find-by-full-name AT ROW 3 COL 84
     b-find-by-substring AT ROW 3 COL 87
     b-search AT ROW 3 COL 90
     B-copy0 AT ROW 4.25 COL 33.5
     B-link AT ROW 4.25 COL 44
     br-global AT ROW 5.25 COL 1
     br-list AT ROW 5.25 COL 44
     RECT-rubr AT ROW 2 COL 11
     SPACE(77.00) SKIP(19.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы блюд".
ASSIGN
       FRAME Dlg-grp:SCROLLABLE       = FALSE
       FRAME Dlg-grp:HIDDEN           = TRUE.
ASSIGN
       B-copy0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       b-expand-0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       b-expand-all-0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       b-find-by-full-name-0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       b-find-by-substring-0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       B-link:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       b-print:POPUP-MENU IN FRAME Dlg-grp       = MENU MENU-b-print:HANDLE.
ASSIGN
       b-search-0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ASSIGN
       br-global:SEPARATOR-FGCOLOR IN FRAME Dlg-grp      = 1.
ASSIGN
       fi-search-0:HIDDEN IN FRAME Dlg-grp           = TRUE.
ON ENDKEY OF FRAME Dlg-grp
DO:
    run gbl/markqwa.p (
          input b-mark:visible
        , input p-recid-list
    ) no-error.
    if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dlg-grp
DO:
  apply "end-error":U to self.
END.
ON CHOOSE OF b-add IN FRAME Dlg-grp
DO:
    run add-grp in this-procedure (
        input temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply.
    end.
END.
ON CHOOSE OF b-chg IN FRAME Dlg-grp
DO:
    run change-grp in this-procedure (
        input temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF b-copy IN FRAME Dlg-grp
DO:
    define variable v-recid-list    as character      no-undo.
    define variable v-is-invalid    as logical        no-undo.
    define variable v-from-obj-type as character      no-undo.
    define variable v-from-obj-code as integer        no-undo.
    define variable v-yesno         as logical        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type = p-store-type
           and buf_fbr-gds-grp.obj-code = p-store-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Список групп блюд не пуст."
            skip(1)
            skip "Копировать группы с другого объекта"
            skip "можно только полностью."
            skip "Для этого список групп блюд текущего объекта"
            skip "должен быть очищен."
        view-as alert-box error
        title "Копирование групп блюд".
        undo, return no-apply.
    end.
    assign
        v-recid-list = ""
    .
    run ref/fbrggrp.w (
          input parparentproc
        , input p-store-type
        , input p-store-code
        , input "buttons-for-objcopy"
        , input-output v-recid-list
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора объекта для копирования групп блюд."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply.
    end.
    if num-entries( v-recid-list ) = 2
    then do:
        assign
            v-from-obj-type = entry( 1, v-recid-list )
            v-from-obj-code = integer( entry( 2, v-recid-list ) )
        .
        if  v-from-obj-type = p-store-type
        and v-from-obj-code = p-store-code
        then do:
            message
                "Для копирования выбран текущий объект."
                skip(1)
                skip "Копирование групп блюд невозможно."
            view-as alert-box error.
            undo, return no-apply.
        end.
        run check-object in this-procedure (
              input v-from-obj-type
            , input v-from-obj-code
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        or ( v-from-obj-type = p-store-type
         and v-from-obj-code = p-store-code )
        then do:
            message
                "Неверно выбран объект для копирования групп блюд."
            view-as alert-box error.
            undo, return no-apply.
        end.
        message
            "Выбран объект для копирования групп блюд."
            skip "Структура групп блюд и привязки"
            skip "товаров к группам блюд будут"
            skip "скопированы с выбранного объекта."
            skip(1)
            skip "Выбранный объект:" v-from-obj-type v-from-obj-code
            skip "Текущий объект:" p-store-type p-store-code
            skip(1)
            skip "Копировать группы блюд?"
        view-as alert-box question
        buttons yes-no
        title "Копирование групп блюд"
        update v-yesno
        .
        if v-yesno = no
        then do:
            message
                "Копирование групп блюд прервано."
            view-as alert-box information.
            undo, return no-apply.
        end.
        run copy-group-list-from-obj in this-procedure (
              input v-from-obj-type
            , input v-from-obj-code
            , input p-store-type
            , input p-store-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка копирования групп блюд с другого объекта."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run UI-on in this-procedure no-error .
    end.
    else do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка передачи параметров для копирования групп."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF B-copy0 IN FRAME Dlg-grp
DO:
  run copy-from-global-grp in this-procedure (
        input temp_fbrglib_grp.node-code
        ,input buf0_temp_fbrglib_grp.node-code
        ,input buf0_temp_fbrglib_grp.global-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply.
    end.
    run UI-on in this-procedure no-error .
END.
ON CHOOSE OF b-del IN FRAME Dlg-grp
DO:
    run delete-grp in this-procedure (
          input temp_fbrglib_grp.node-code
        , input yes
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка удаления группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF b-exit IN FRAME Dlg-grp
DO:
    define variable v-fbr-gds-grp-recid     as recid             no-undo.
    if p-button-list = "buttons-for-objcopy"
    then do:
        assign
            fi-kitchen-type
            fi-kitchen-code
        .
        assign
            p-recid-list = fi-kitchen-type + ",":U + string( fi-kitchen-code )
        .
    end.
    else do:
        run get-current-recid in this-procedure (
            input (if v-rubr-mode = 1 then buf0_temp_fbrglib_grp.node-code else temp_fbrglib_grp.node-code)
            , output v-fbr-gds-grp-recid
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Не найдена группа для восстановления"
            skip "предыдущего состояния справочника групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run gbl/markqwa.p (
            input b-mark:visible
            , input p-recid-list
        ) no-error.
        if error-status:error then return no-apply.
        assign
            fbr-gds-grp-row  = v-fbr-gds-grp-recid
            p-recid-list = ""
        .
        assign
        v-uf-list_ = (if v-uf-list_ = "":U then (chr(4)) else v-uf-list_)
        entry((v-rubr-mode + 1), v-uf-List_,  chr(4)) = (if fbr-gds-grp-row = ?
                                                            then chr(63)
                                                            else string(fbr-gds-grp-row))
        .
        run uf-set in this-procedure(
            input  'fbr-gds-grp-p':U
            ,input v-cntxt-userid
            ,input v-uf-List_
            ,input v-uf-Naim
            ,input v-uf-print-graft
            ,input v-uf-sort-gr
            ,input v-uf-type-price
            ,input v-uf-type-val
        )  no-error .
    end.
    apply "GO" TO FRAME Dlg-grp .
END.
ON CHOOSE OF b-expand IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.node-code = v-fbrggrp-root-code
    then do:
        run collapse-all-on-first-level in THIS-PROCEDURE (INPUT p-store-type, INPUT p-store-code) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка операции с деревом групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    if temp_fbrglib_grp.mark <> "»"
    and temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON CHOOSE OF b-expand-0 IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.node-code = v-fbrggrp-root-code
    then do:
        run collapse-all-on-first-level in THIS-PROCEDURE (INPUT "":U, INPUT 0) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка операции с деревом групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    if buf0_temp_fbrglib_grp.mark <> "»"
    and buf0_temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( INPUT "":U
                                                  , INPUT 0
                                                  , INPUT buf0_temp_fbrglib_grp.mark
                                                  , INPUT buf0_temp_fbrglib_grp.node-code) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON CHOOSE OF b-expand-all IN FRAME Dlg-grp
DO:
    if available temp_fbrglib_grp
    then do:
        run expand-all-from-current in this-procedure (INPUT p-store-type, INPUT p-store-code,
            input temp_fbrglib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка при раскрытии дерева групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF b-expand-all-0 IN FRAME Dlg-grp
DO:
    if available buf0_temp_fbrglib_grp
    then do:
        run expand-all-from-current in this-procedure (INPUT "":U, INPUT 0,
            input buf0_temp_fbrglib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка при раскрытии дерева групп."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    run fbrglib-expand-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.
ON LEAVE OF b-find-by-full-name IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF b-find-by-full-name-0 IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    run fbrglib-expand-name in this-procedure (
          input "":U
        , input 0
        , input fi-search-0 :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search-0 :screen-value
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.
ON LEAVE OF b-find-by-full-name-0 IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF b-find-by-substring IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.
    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
if session :set-wait-state( "compiler" ) then.
    run fbrglib-find-by-substring in this-procedure (
          input p-store-type
        , input p-store-code
        , input v-full-search-start-code
        , input v-full-search-string
        , output v-new-code
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
if session :set-wait-state( "" ) then.
        message return-value.
        undo, return no-apply.
    end.
if session :set-wait-state( "" ) then.
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search :screen-value
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code = v-new-code
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.
ON LEAVE OF b-find-by-substring IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF b-find-by-substring-0 IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.
    if v-full-search-next-0 = no
    then do:
        assign
            v-full-search-string-0     = fi-search-0 :screen-value
            v-full-search-next-0       = yes
            v-full-search-start-code-0 = 0
        .
    end.
if session :set-wait-state( "compiler" ) then.
    run fbrglib-find-by-substring in this-procedure (
          input "":U
        , input 0
        , input v-full-search-start-code-0
        , input v-full-search-string-0
        , output v-new-code
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
if session :set-wait-state( "" ) then.
        message return-value.
        undo, return no-apply.
    end.
if session :set-wait-state( "" ) then.
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string-0 "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search-0 :screen-value
            v-full-search-string-0     = ""
            v-full-search-next-0       = no
            v-full-search-start-code-0 = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code-0 = v-new-code
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.
ON LEAVE OF b-find-by-substring-0 IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF B-global IN FRAME Dlg-grp
DO:
  assign
  v-rubr = NOT v-rubr.
  RUN proc-b-rubr IN THIS-PROCEDURE(v-rubr).
END.
ON CHOOSE OF b-goods IN FRAME Dlg-grp
DO:
    define variable v-cancel    as logical        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    if available temp_fbrglib_grp
    then do:
        run ref/fbrggrpg.w (
              input parparentproc
            , input p-store-type
            , input p-store-code
            , input temp_fbrglib_grp.node-code
            , output v-cancel
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка привязки товаров к группе блюд."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        if v-cancel = yes
        then do:
            undo, return no-apply .
        end.
        run get-first-char in this-procedure (
              input p-store-type
            , input p-store-code
            , input temp_fbrglib_grp.node-code
            , output temp_fbrglib_grp.mark
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка вычисления первого символа для отображения группы"
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type     = p-store-type
               and buf_fbr-gds-grp.obj-code     = p-store-code
               and buf_fbr-gds-grp.node-code    = temp_fbrglib_grp.node-code
        .
        assign
            temp_fbrglib_grp.name = fill( " ", 4 * temp_fbrglib_grp.level )
                                            + temp_fbrglib_grp.mark
                                            + " "
                                            + buf_fbr-gds-grp.node-name
        .
        br-list :refresh().
    end.
END.
ON CHOOSE OF B-hist IN FRAME Dlg-grp
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF AVAILABLE temp_fbrglib_grp THEN DO:
      run ref/cfggrphi.w (
                  input parparentproc
                 ,INPUT '':U
                 ,INPUT 'one'
                 ,INPUT temp_fbrglib_grp.obj-type
                 ,INPUT temp_fbrglib_grp.obj-code
                 ,INPUT temp_fbrglib_grp.node-code
                 ,INPUT '':U
                 ,INPUT NO
                 ,INPUT '':U
                 ,OUTPUT v-rid-list) NO-ERROR.
  END.
END.
ON CHOOSE OF B-link IN FRAME Dlg-grp
DO:
   run link-grp in this-procedure (
        input temp_fbrglib_grp.node-code
        ,input buf0_temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка изменения группы блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF b-mark IN FRAME Dlg-grp
DO:
    run b-mark-press (INPUT p-store-type, INPUT p-store-code,  input temp_fbrglib_grp.node-code ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора в списке групп"
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
ON CHOOSE OF b-move IN FRAME Dlg-grp
DO:
    run select-and-move-item in this-procedure (
        input temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка перемещения группы."
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
ON CHOOSE OF b-print IN FRAME Dlg-grp
DO:
    run print-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка печати."
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
ON CHOOSE OF b-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure ( INPUT p-store-type
                                             , INPUT p-store-code
                                            , input fi-search :screen-value
                                          ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска группы в списке."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
END.
ON LEAVE OF b-search IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF b-search-0 IN FRAME Dlg-grp
DO:
    if fi-search-0 :screen-value = ""
    or fi-search-0 :screen-value = ?
    then do:
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure ( INPUT "":U
                                             , INPUT 0
                                             , input fi-search-0 :screen-value
                                         ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска группы в списке."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply.
    end.
END.
ON LEAVE OF b-search-0 IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF b-sel IN FRAME Dlg-grp
DO:
    define variable v-yesno     as logical     init no      no-undo.
    run fill-output-parameters-on-exit in this-procedure (
         input (IF v-rubr-mode = 1 then "":U else p-store-type)
        ,input (IF v-rubr-mode = 1 then 0    else p-store-code)
        ,input (IF v-rubr-mode = 1
               THEN BUF0_temp_fbrglib_grp.node-code
               ELSE temp_fbrglib_grp.node-code)
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка передачи параметров списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
          skip (1) "Закрыть список групп?"
        view-as alert-box error buttons yes-no update v-yesno.
        if v-yesno = no
        then do:
            undo, return no-apply .
        end.
    end.
    apply "WINDOW-CLOSE" TO FRAME Dlg-grp .
END.
ON + OF br-global IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.mark = "»"
    then do:
        run expand-item in this-procedure ( INPUT "":U, INPUT 0, input buf0_temp_fbrglib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось раскрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON - OF br-global IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.mark = "«"
    then do:
        run collapse-item in this-procedure ( INPUT "":U, INPUT 0, input temp_fbrglib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось закрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON END OF br-global IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure (INPUT "":U, INPUT 0,  output v-row-amount ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при подсчете строк списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    reposition br-global to row v-row-amount.
END.
ON HOME OF br-global IN FRAME Dlg-grp
DO:
    reposition br-global to row 1.
END.
ON MOUSE-SELECT-DBLCLICK OF br-global IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.mark <> "»"
    and buf0_temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( input "":U
                                                   ,input 0
                                                   ,input buf0_temp_fbrglib_grp.mark
                                                   ,input buf0_temp_fbrglib_grp.node-code) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON RETURN OF br-global IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.mark <> "»"
    and buf0_temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( input "":U
                                                   ,input 0
                                                   ,input  buf0_temp_fbrglib_grp.mark
                                                   ,input  buf0_temp_fbrglib_grp.node-code
                                                   ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON VALUE-CHANGED OF br-global IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search-0 :screen-value = right-trim( buf0_temp_fbrglib_grp.full-name, chr(47) )
        .
    end.
END.
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark = "»"
    then do:
        run expand-item in this-procedure (INPUT p-store-type, INPUT p-store-code, input temp_fbrglib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось раскрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON - OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark = "«"
    then do:
        run collapse-item in this-procedure (INPUT p-store-type, INPUT p-store-code,  input temp_fbrglib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось закрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON DELETE-CHARACTER OF br-list IN FRAME Dlg-grp
DO:
    if b-del :sensitive = yes
    and b-del :visible = yes
    then do:
        run delete-grp in this-procedure (
            input temp_fbrglib_grp.node-code
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка удаления группы блюд."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON END OF br-list IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( INPUT p-store-type, INPUT p-store-code, output v-row-amount ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при подсчете строк списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    reposition br-list to row v-row-amount.
END.
ON HOME OF br-list IN FRAME Dlg-grp
DO:
    reposition br-list to row 1.
END.
ON INSERT-MODE OF br-list IN FRAME Dlg-grp
DO:
    if b-add :sensitive = yes
    and b-add :visible = yes
    then do:
        run add-grp in this-procedure (
             input temp_fbrglib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка добавления группы блюд."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark <> "»"
    and temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code)  no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON RETURN OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark <> "»"
    and temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code
                                                   ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON VALUE-CHANGED OF br-global IN FRAME Dlg-grp
DO:
    if buf0_temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search-0 :screen-value = right-trim( buf0_temp_fbrglib_grp.full-name, chr(47) )
        .
    end.
END.
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark = "»"
    then do:
        run expand-item in this-procedure (INPUT p-store-type, INPUT p-store-code, input temp_fbrglib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось раскрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON - OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark = "«"
    then do:
        run collapse-item in this-procedure (INPUT p-store-type, INPUT p-store-code,  input temp_fbrglib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Не удалось закрыть подуровни группы."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
                   trim(error-status :get-message(4))
                   trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON DELETE-CHARACTER OF br-list IN FRAME Dlg-grp
DO:
    if b-del :sensitive = yes
    and b-del :visible = yes
    then do:
        run delete-grp in this-procedure (
            input temp_fbrglib_grp.node-code
            , input yes
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка удаления группы блюд."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.
ON END OF br-list IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( INPUT p-store-type, INPUT p-store-code, output v-row-amount ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при подсчете строк списка групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    reposition br-list to row v-row-amount.
END.
ON HOME OF br-list IN FRAME Dlg-grp
DO:
    reposition br-list to row 1.
END.
ON INSERT-MODE OF br-list IN FRAME Dlg-grp
DO:
    if b-add :sensitive = yes
    and b-add :visible = yes
    then do:
        run add-grp in this-procedure (
             input temp_fbrglib_grp.node-code
        ) no-error .
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка добавления группы блюд."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark <> "»"
    and temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code)  no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON RETURN OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.mark <> "»"
    and temp_fbrglib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure ( INPUT p-store-type
                                                  , INPUT p-store-code
                                                  , INPUT temp_fbrglib_grp.mark
                                                  , INPUT temp_fbrglib_grp.node-code
                                                  ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка операции с деревом групп."
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
ON VALUE-CHANGED OF br-list IN FRAME Dlg-grp
DO:
    if temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_fbrglib_grp.full-name, chr(47) )
        .
    end.
END.
ON CHOOSE OF bt-sel-kitchen IN FRAME Dlg-grp
DO:
    run select-kitchen in this-procedure (
          input fi-kitchen-type
        , input fi-kitchen-code
        , output fi-kitchen-type
        , output fi-kitchen-code
    ).
    display
        fi-kitchen-type
        fi-kitchen-code
    with frame Dlg-grp.
END.
ON LEAVE OF fi-kitchen-code IN FRAME Dlg-grp
DO:
    define variable v-is-invalid    as logical        no-undo.
    if chkleave (
         input last-event :widget-enter
       , input "b-cancel,b-help,b-stop-cycle":u
        )
    then do:
        run check-object in this-procedure (
              input fi-kitchen-type :screen-value
            , input integer( fi-kitchen-code :screen-value )
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        then do:
            message
                "Неверно выбран объект."
            view-as alert-box error.
            undo, return no-apply.
        end.
    end.
END.
ON RETURN OF fi-kitchen-code IN FRAME Dlg-grp
DO:
    run get-obj-type in this-procedure (
          input integer( fi-kitchen-code :screen-value )
        , output fi-kitchen-type
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при определении типа объекта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if fi-kitchen-type = ?
    then do:
        message
            "Объект не найден"
            skip "или не определен тип объекта"
        view-as alert-box error.
        undo, return no-apply.
    end.
    else do:
        display
            fi-kitchen-type
        with frame Dlg-grp .
    end.
    assign
        fi-kitchen-code
    .
    assign
        p-store-type = fi-kitchen-type
        p-store-code = fi-kitchen-code
    .
    run ui-on in this-procedure.
    apply "entry":U to br-list in frame Dlg-grp .
    return no-apply.
END.
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    run fbrglib-expand-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input fi-search :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search :screen-value
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.
ON CTRL-S OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.
    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
if session :set-wait-state( "compiler" ) then.
    run fbrglib-find-by-substring in this-procedure (
          input p-store-type
        , input p-store-code
        , input v-full-search-start-code
        , input v-full-search-string
        , output v-new-code
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
if session :set-wait-state( "" ) then.
        message return-value.
        undo, return no-apply.
    end.
if session :set-wait-state( "" ) then.
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search :screen-value
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code = v-new-code
        .
    end.
    assign
        fi-search :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search :cursor-offset = length( v-new-name ) + 1
    .
END.
ON LEAVE OF fi-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value <> v-full-search-string
    then do:
        assign
            v-full-search-string     = ""
            v-full-search-next       = no
            v-full-search-start-code = 0
        .
    end.
END.
ON RETURN OF fi-search IN FRAME Dlg-grp
DO:
    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure ( INPUT p-store-type
                                              ,INPUT p-store-code
                                              ,input fi-search :screen-value
                                          ) no-error.
    if error-status :error
    then do:
        message
          skip "Группа не найдена."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        undo, return no-apply.
    end.
    apply "ENTRY" to b-search in frame Dlg-grp.
    return no-apply.
END.
ON CTRL-D OF fi-search-0 IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    run fbrglib-expand-name in this-procedure (
          input "":U
        , input 0
        , input fi-search-0 :screen-value
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
        message return-value.
        undo, return no-apply.
    end.
    if v-new-name = ""
    then do:
        message
            "Не найдена группа с полным именем, начинающимся на"
            skip "'" + fi-search-0 :screen-value + "'"
        view-as alert-box information.
        assign
            v-new-name = fi-search-0 :screen-value
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.
ON CTRL-S OF fi-search-0 IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    define variable v-new-code as integer   no-undo.
    if v-full-search-next-0 = no
    then do:
        assign
            v-full-search-string-0     = fi-search-0 :screen-value
            v-full-search-next-0       = yes
            v-full-search-start-code-0 = 0
        .
    end.
if session :set-wait-state( "compiler" ) then.
    run fbrglib-find-by-substring in this-procedure (
          input "":U
        , input 0
        , input v-full-search-start-code-0
        , input v-full-search-string-0
        , output v-new-code
        , output v-new-name
    ) no-error.
    if error-status :error
    then do:
if session :set-wait-state( "" ) then.
        message return-value.
        undo, return no-apply.
    end.
if session :set-wait-state( "" ) then.
    if v-new-code = 0
    then do:
        message
            skip "Не найдена строка '" v-full-search-string-0 "' в имени группы."
        view-as alert-box information
        title "Поиск завершен".
        assign
            v-new-name               = fi-search-0 :screen-value
            v-full-search-string-0     = ""
            v-full-search-next-0       = no
            v-full-search-start-code-0 = 0
        .
    end.
    else do:
        assign
            v-full-search-start-code-0 = v-new-code
        .
    end.
    assign
        fi-search-0 :screen-value  = right-trim( v-new-name, chr(47) )
        fi-search-0 :cursor-offset = length( v-new-name ) + 1
    .
END.
ON LEAVE OF fi-search-0 IN FRAME Dlg-grp
DO:
    if fi-search-0 :screen-value <> v-full-search-string-0
    then do:
        assign
            v-full-search-string-0     = ""
            v-full-search-next-0       = no
            v-full-search-start-code-0 = 0
        .
    end.
END.
ON RETURN OF fi-search-0 IN FRAME Dlg-grp
DO:
    if fi-search-0 :screen-value = ""
    or fi-search-0 :screen-value = ?
    then do:
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
                                               INPUT "":U
                                              ,INPUT 0
                                              ,input fi-search :screen-value
                                            ) no-error.
    if error-status :error
    then do:
        message
          skip "Группа не найдена."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        undo, return no-apply.
    end.
    apply "ENTRY" to b-search-0 in frame Dlg-grp.
    return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_browse
DO:
    assign
        print-option = "browse":U
    .
    run print-grp in this-procedure(
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.
ON CHOOSE OF MENU-ITEM m_browse-global
DO:
    assign
        print-option = "browse-global":U
    .
    run print-grp in this-procedure(
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.
ON CHOOSE OF MENU-ITEM m_classificator
DO:
    assign
        print-option = "classificator":U
    .
    run print-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.
ON CHOOSE OF MENU-ITEM m_term
DO:
    assign
        print-option = "terminal":U
    .
    run print-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input temp_fbrglib_grp.node-code
    ) no-error.
    if error-status:error
    then do:
        assign
            print-option = "":U
        .
        return no-apply.
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dlg-grp:PARENT eq ?
THEN FRAME Dlg-grp:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dlg-grp
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
on choose of b-help in frame Dlg-grp
do:
  apply "help":u to frame Dlg-grp .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dlg-grp:width - 0.3
                fh            = frame Dlg-grp:first-child
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dlg-grp :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dlg-grp :height-chars)
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
    if frame Dlg-grp :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dlg-grp :height-chars)
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
            frame Dlg-grp :height = v-frame-height
          .
          if frame Dlg-grp :scrollable = true
          then do:
            assign
              frame Dlg-grp :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dlg-grp :scrollable = true
          then do:
            assign
              frame Dlg-grp :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dlg-grp :height = v-frame-height
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
      v-frame-height = frame Dlg-grp :height
      v-frame-virtual-height = frame Dlg-grp :virtual-height
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
      v-field-group-handle = frame Dlg-grp :first-child
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
    do with frame Dlg-grp
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dlg-grp :scrollable = true
      then do:
        assign
          frame Dlg-grp :virtual-height = frame Dlg-grp :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dlg-grp :height = frame Dlg-grp :height + p-change-value
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
        frame Dlg-grp :height = frame Dlg-grp :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dlg-grp :scrollable = true
      then do:
        assign
          frame Dlg-grp :virtual-height = frame Dlg-grp :virtual-height + p-change-value
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
          ,input  string(frame Dlg-grp :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dlg-grp :height)
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
    if frame Dlg-grp :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dlg-grp :width
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
    if frame Dlg-grp :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dlg-grp :width
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
            frame Dlg-grp :width = v-frame-width
          .
          if frame Dlg-grp :scrollable = true
          then do:
            assign
              frame Dlg-grp :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dlg-grp :scrollable = true
          then do:
            assign
              frame Dlg-grp :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dlg-grp :width = v-frame-width
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
      v-frame-width = frame Dlg-grp :width
      v-frame-virtual-width = frame Dlg-grp :virtual-width
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
      v-field-group-handle = frame Dlg-grp :first-child
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
    do with frame Dlg-grp
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dlg-grp :scrollable = true
      then do:
        assign
          frame Dlg-grp :virtual-width = frame Dlg-grp :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dlg-grp :width = v-frame-width + p-change-value
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
        frame Dlg-grp :width = frame Dlg-grp :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dlg-grp :scrollable = true
      then do:
        assign
          frame Dlg-grp :virtual-width = frame Dlg-grp :virtual-width + p-change-value
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
          ,input  string(frame Dlg-grp :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dlg-grp :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dlg-grp
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dlg-grp :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dlg-grp :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dlg-grp :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dlg-grp :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dlg-grp
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
      v-row-delta = v-new-row - frame Dlg-grp :height
      v-col-delta = v-new-col - frame Dlg-grp :width
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
            - frame Dlg-grp :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dlg-grp :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dlg-grp :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dlg-grp :height-chars
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
      v-diasize-current-frame-width  = frame Dlg-grp :width
      v-diasize-current-frame-height = frame Dlg-grp :height
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
    do with frame Dlg-grp
    :
      assign
        v-diasize-orig-frame-height = frame Dlg-grp :height
        v-diasize-orig-frame-width  = frame Dlg-grp :width
        v-diasize-browse-handle     = browse br-global :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dlg-grp :first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  v-b-expand-col            =  b-expand:COL IN FRAME Dlg-grp             - 50
  v-b-expand-all-col        =  b-expand-all:COL IN FRAME Dlg-grp         - 50
  v-b-find-by-full-name-col =  b-find-by-full-name:COL IN FRAME Dlg-grp  - 50
  v-b-find-by-substring-col =  b-find-by-substring:COL IN FRAME Dlg-grp  - 50
  v-b-search-col            =  b-search:COL IN FRAME Dlg-grp             - 50
  v-fi-search-col           =  fi-search:COL IN FRAME Dlg-grp            - 50
  .
    run get-report-num in parparentproc (
        output g#report-num
    ).
    run get-quest-print in parparentproc (
        output g#quest-print
    ).
  IF lookup("buttons-for-rubr-only", P-BUTTON-LIST) > 0  THEN do:
    assign
    v-rubr-mode = 1.
    run RUBR-on in this-procedure no-error .
  end.
  ELSE
  run UI-on in this-procedure no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Ошибка при загрузке дерева групп."
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
             trim(error-status :get-message(4))
             trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
  apply "entry" to br-list.
  WAIT-FOR GO OF FRAME Dlg-grp.
END.
RUN disable_UI.
PROCEDURE add-grp :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-node-code    as integer        no-undo.
    define variable v-have-rights       as logical       no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-cancel            as logical        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Добавление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run fbrglib-have-goods in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-have-goods = yes
    then do:
        message "В данной группе есть товары. Добавить в нее подгруппу,"
                "включающую эти товары ?"
        view-as alert-box question
        buttons OK-Cancel
        update v-yesno as logical.
        if v-yesno = no
        then do:
            return.
        end.
    end.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
            AND buf_temp_fbrglib_grp.obj-type = p-store-type
            AND buf_temp_fbrglib_grp.obj-code = p-store-code
    .
    if buf_temp_fbrglib_grp.mark = "»"
    then do:
        run expand-item in this-procedure ( INPUT p-store-type, p-store-code, input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run fbrglib-add-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , INPUT YES
        , INPUT "":U
        , INPUT 0
        , INPUT 0
        , output v-node-code
        , output v-cancel
    ).
    if v-cancel = yes
    then do:
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = v-node-code
    .
    run create-new-line in this-procedure (
          input p-store-type
        , input p-store-code
        , input buf_fbr-gds-grp.node-code
        , input buf_fbr-gds-grp.upper-code
        , input buf_temp_fbrglib_grp.level + 1
        , input buf_fbr-gds-grp.node-name
        , input buf_fbr-gds-grp.out-code
        , input buf_fbr-gds-grp.global-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка добавления строки в список групп.".
    end.
    if buf_temp_fbrglib_grp.level > 0
    then do:
        assign
            buf_temp_fbrglib_grp.mark = "«"
            buf_temp_fbrglib_grp.name = substring( buf_temp_fbrglib_grp.name, 1, buf_temp_fbrglib_grp.level * 4 )
                                + "«"
                                + substring( buf_temp_fbrglib_grp.name, buf_temp_fbrglib_grp.level * 4 + 2 )
        .
    end.
    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.
PROCEDURE add-grp-branch-cycle :
define input parameter p-node-code         as integer      no-undo.
define input parameter p-global-node-code  as integer      no-undo.
define input parameter p-node-name         as character    no-undo.
define input parameter p-out-code          as INTEGER      no-undo.
define input parameter p-global-code       as INTEGER      no-undo.
define input parameter p-level             as INTEGER      no-undo.
DEFINE VARIABLE v-node-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cancel    AS logical NO-UNDO.
DEFINE BUFFER bf0_fbr-gds-grp for ub.fbr-gds-grp.
DEFINE BUFFER buf_fbr-gds-grp for ub.fbr-gds-grp.
run fbrglib-add-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , INPUT no
        , INPUT p-node-name
        , INPUT p-out-code
        , INPUT p-global-code
        , output v-node-code
        , output v-cancel
    ).
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = v-node-code
    .
    run create-new-line in this-procedure (
      input p-store-type
    , input p-store-code
    , input v-node-code
    , input buf_fbr-gds-grp.upper-code
    , input p-level
    , input buf_fbr-gds-grp.node-name
    , input buf_fbr-gds-grp.out-code
    , input buf_fbr-gds-grp.global-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grpbrach-cycle: Ошибка добавления строки в список групп.".
    end.
FOR EACH bf0_fbr-gds-grp NO-LOCK WHERE
        bf0_fbr-gds-grp.obj-type = "":U
    AND bf0_fbr-gds-grp.obj-code = 0
    AND bf0_fbr-gds-grp.upper-code = p-global-node-code:
  RUN add-grp-branch-cycle IN THIS-PROCEDURE(
                                             INPUT v-node-code
                                            ,INPUT bf0_fbr-gds-grp.node-code
                                            ,INPUT bf0_fbr-gds-grp.node-name
                                            ,INPUT bf0_fbr-gds-grp.out-code
                                            ,INPUT bf0_fbr-gds-grp.global-code
                                            ,INPUT p-level + 1
                                            ).
END.
END PROCEDURE.
PROCEDURE b-mark-press :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code as integer      no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer buf_upper_temp_fbrglib_grp for temp_fbrglib_grp.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
           AND buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    no-error .
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "b-mark-press: Ошибка поиска группы".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    if buf_temp_fbrglib_grp.sel = "*"
    or p-node-code = v-fbrggrp-root-code
    then do:
        assign
            buf_temp_fbrglib_grp.sel = ""
        .
    end.
    else do:
        assign
            buf_temp_fbrglib_grp.sel = "*"
        .
        for each buf_upper_temp_fbrglib_grp
            where buf_upper_temp_fbrglib_grp.level < buf_temp_fbrglib_grp.level
                AND buf_temp_fbrglib_grp.obj-type = p-obj-type
                AND buf_temp_fbrglib_grp.obj-code = p-obj-code
              and buf_upper_temp_fbrglib_grp.full-name = substring( buf_temp_fbrglib_grp.full-name, 1
                                                        , length( buf_upper_temp_fbrglib_grp.full-name ) )
        :
            assign
                buf_upper_temp_fbrglib_grp.sel = ""
            .
        end.
        for each buf_upper_temp_fbrglib_grp
            where buf_upper_temp_fbrglib_grp.node-code <> buf_temp_fbrglib_grp.node-code
                AND buf_temp_fbrglib_grp.obj-type = p-obj-type
                AND buf_temp_fbrglib_grp.obj-code = p-obj-code
              and buf_upper_temp_fbrglib_grp.full-name begins buf_temp_fbrglib_grp.full-name + chr(47)
        :
            assign
                buf_upper_temp_fbrglib_grp.sel = ""
            .
        end.
    end.
    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    if v-focused-row > br-list :height - 2
    then do:
        assign
            v-repositioned-row  = v-repositioned-row + 1
        .
    end.
    else do:
        assign
            v-focused-row       = v-focused-row + 1
            v-repositioned-row  = v-repositioned-row + 1
        .
    end.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.
PROCEDURE change-grp :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
    define variable v-fbr-gds-grp-recid     as recid        no-undo.
    define variable v-focused-row           as integer      no-undo.
    define variable v-repositioned-row      as integer      no-undo.
    define variable v-have-rights           as logical      no-undo.
    define variable v-old-full-name         as character    no-undo.
    define variable v-base                  as decimal      no-undo.
    define variable v-node-name             as character    no-undo.
    define variable v-out-code              as integer        no-undo.
    define variable v-cancel                as logical      no-undo.
    define buffer buf_fbr-gds-grp               for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer buf_child_temp_fbrglib_grp for temp_fbrglib_grp.
    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу изменить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    do transaction
    on error undo, return error
    :
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type  = p-store-type
               and buf_fbr-gds-grp.obj-code  = p-store-code
               and buf_fbr-gds-grp.node-code = p-node-code
        .
        run ref/fbrggrpd.w (
              input parparentproc
            , input 'ИЗМЕНЕНИЕ':U
            , input p-store-type
            , input p-store-code
            , input buf_fbr-gds-grp.node-code
            , input buf_fbr-gds-grp.upper-code
            , input buf_fbr-gds-grp.node-name
            , input buf_fbr-gds-grp.out-code
            , output v-node-name
            , output v-out-code
            , output v-cancel
        ).
        if v-cancel = yes
        then do:
            undo, return.
        end.
        assign
            buf_fbr-gds-grp.node-name   = v-node-name
            buf_fbr-gds-grp.out-code    = v-out-code
        .
    end.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
          AND buf_temp_fbrglib_grp.obj-type  = p-store-type
          AND buf_temp_fbrglib_grp.obj-code  = p-store-code
    no-error.
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "change-grp: Ошибка поиска группы в списке.".
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    if buf_temp_fbrglib_grp.level > 0
    then do:
        assign
            buf_temp_fbrglib_grp.name    = substring( buf_temp_fbrglib_grp.name
                                                    , 1
                                                    , buf_temp_fbrglib_grp.level * 4 + 2 )
                                            + buf_fbr-gds-grp.node-name
        .
    end.
    else do:
        assign
            buf_temp_fbrglib_grp.name       = buf_fbr-gds-grp.node-name
        .
    end.
    assign
        v-old-full-name                 = buf_temp_fbrglib_grp.full-name
        buf_temp_fbrglib_grp.out-code   = buf_fbr-gds-grp.out-code
    .
    run fbrglib-get-full-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output buf_temp_fbrglib_grp.full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    run fbrglib-get-sort-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output buf_temp_fbrglib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени группы в списке".
    end.
    if buf_temp_fbrglib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( buf_temp_fbrglib_grp.full-name, chr(47) )
        .
    end.
    for each buf_child_temp_fbrglib_grp
       where buf_child_temp_fbrglib_grp.full-name begins v-old-full-name
         and buf_child_temp_fbrglib_grp.full-name <> v-old-full-name
         and buf_child_temp_fbrglib_grp.level <> buf_temp_fbrglib_grp.level
    :
        run fbrglib-get-full-name in this-procedure (
              input p-store-type
            , input p-store-code
            , input buf_child_temp_fbrglib_grp.node-code
            , output buf_child_temp_fbrglib_grp.full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
        run fbrglib-get-sort-name in this-procedure (
              input p-store-type
            , input p-store-code
            , input buf_child_temp_fbrglib_grp.node-code
            , output buf_child_temp_fbrglib_grp.sort-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка вычисления полного имени группы в списке".
        end.
    end.
    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.
PROCEDURE check-object :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define output parameter p-is-invalid    as logical      no-undo.
    define buffer buf_clients       for ub.clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    then do:
        assign
            p-is-invalid = yes
        .
    end.
    else do:
        assign
            p-is-invalid = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE check-rights-for-change-grp :
do
on error undo, return error
:
define output parameter p-have-rights   as logical      no-undo.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_res-reference_update':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output p-have-rights
    )  .
end.
end.
END PROCEDURE.
PROCEDURE collapse-all-on-first-level :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
do
on error undo, return error
:
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    for each buf_temp_fbrglib_grp no-lock
       where buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
        AND buf_temp_fbrglib_grp.upper-code = v-fbrggrp-root-code
    :
        run collapse-item in this-procedure (
              INPUT p-obj-type
            , INPUT p-obj-code
            , input buf_temp_fbrglib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + chr(10) + "'" + buf_temp_fbrglib_grp.full-name + "'"
                                + chr(10) + return-value.
        end.
    end.
    IF p-obj-type = "":U  AND p-obj-code = 0 THEN DO:
        OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
    END.
    ELSE DO:
        OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    END.
end.
END PROCEDURE.
PROCEDURE collapse-item :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define buffer buf_del_temp_fbrglib_grp   for temp_fbrglib_grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.obj-type   = p-obj-type
           and buf_temp_fbrglib_grp.obj-code   = p-obj-code
           AND buf_temp_fbrglib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error substitute("collapse-item: Неверно передан код группы. Нет группы с кодом &1, объект &2&3"
                                     ,p-node-code
                                     ,p-obj-type
                                     ,p-obj-code
                                     ).
    end.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        assign
            v-focused-row      = br-global :focused-row in frame Dlg-grp.
            v-repositioned-row = current-result-row( "br-global" )
        .
    END.
    ELSE DO:
        assign
            v-focused-row      = br-list :focused-row in frame Dlg-grp.
            v-repositioned-row = current-result-row( "br-list" )
        .
    END.
    for each buf_del_temp_fbrglib_grp
       where buf_del_temp_fbrglib_grp.full-name begins buf_temp_fbrglib_grp.full-name
         and buf_del_temp_fbrglib_grp.full-name <> buf_temp_fbrglib_grp.full-name
         and buf_del_temp_fbrglib_grp.level     <> buf_temp_fbrglib_grp.level
         and buf_del_temp_fbrglib_grp.obj-type   = p-obj-type
          and buf_del_temp_fbrglib_grp.obj-code   = p-obj-code
    :
        delete buf_del_temp_fbrglib_grp.
    end.
    assign
        buf_temp_fbrglib_grp.mark = "»"
        buf_temp_fbrglib_grp.name = replace( buf_temp_fbrglib_grp.name
                                        , "«"
                                        , "»"
                                        )
    .
    if p-refresh = yes
    then do:
      IF p-obj-type = "":U and p-obj-code = 0 THEN DO:
           OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
          br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
          reposition br-global to row v-repositioned-row.
      END.
      ELSE DO:
           OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
          br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
          reposition br-list to row v-repositioned-row.
     END.
    end.
end.
END PROCEDURE.
PROCEDURE copy-from-global-grp :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-global-node-code  as integer      no-undo.
define input parameter p-global-code  as integer      no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-node-code    as integer        no-undo.
    define variable v-have-rights       as logical       no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-cancel            as logical        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer bf0_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Добавление групп(ы) невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run fbrglib-have-goods in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-have-goods = yes
    then do:
        message "В данной группе есть товары. Добавить в нее подгруппу,"
                "включающую эти товары ?"
        view-as alert-box question
        buttons OK-Cancel
        update v-yesno as logical.
        if v-yesno = no
        then do:
            return.
        end.
    end.
    find first bf0_fbr-gds-grp
         where bf0_fbr-gds-grp.node-code = p-global-node-code
            AND bf0_fbr-gds-grp.obj-type = "":U
            AND bf0_fbr-gds-grp.obj-code = 0
    .
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
            AND buf_temp_fbrglib_grp.obj-type = p-store-type
            AND buf_temp_fbrglib_grp.obj-code = p-store-code
    .
    if buf_temp_fbrglib_grp.mark = "»"
    then do:
        run expand-item in this-procedure ( INPUT p-store-type, p-store-code, input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "copy-from-global-grp: Не удается раскрыть группу.".
        end.
    end.
    RUN add-grp-branch-cycle in this-procedure (
          input p-node-code
        , INPUT p-global-node-code
        , INPUT bf0_fbr-gds-grp.node-name
        , INPUT bf0_fbr-gds-grp.out-code
        , INPUT p-global-code
        , INPUT (buf_temp_fbrglib_grp.level + 1)
    ).
   if buf_temp_fbrglib_grp.level > 0
    then do:
        assign
            buf_temp_fbrglib_grp.mark = "«"
            buf_temp_fbrglib_grp.name = substring( buf_temp_fbrglib_grp.name, 1, buf_temp_fbrglib_grp.level * 4 )
                                + "«"
                                + substring( buf_temp_fbrglib_grp.name, buf_temp_fbrglib_grp.level * 4 + 2 )
        .
    end.
    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.
PROCEDURE copy-group-list-from-obj :
define input parameter p-from-obj-type  as character    no-undo.
define input parameter p-from-obj-code  as integer      no-undo.
define input parameter p-to-obj-type    as character    no-undo.
define input parameter p-to-obj-code    as integer      no-undo.
    define variable v-fbr-gds-obj-recid     as recid        no-undo.
    define variable v-grp-counter    as integer        no-undo.
    define buffer buf_from_fbr-gds-grp  for ub.fbr-gds-grp.
    define buffer buf_to_fbr-gds-grp    for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_from_fbr-gds-obj  for ub.fbr-gds-obj.
    define buffer buf_to_fbr-gds-obj    for ub.fbr-gds-obj.
do
for buf_from_fbr-gds-grp
  , buf_to_fbr-gds-grp
  , buf_fbr-gds-grp
  , buf_from_fbr-gds-obj
  , buf_to_fbr-gds-obj
on error undo, return error
:
    find first buf_to_fbr-gds-grp no-lock
         where buf_to_fbr-gds-grp.obj-type = p-to-obj-type
           and buf_to_fbr-gds-grp.obj-code = p-to-obj-code
    no-error.
    if available buf_to_fbr-gds-grp
    then do:
        message
                 "На объекте, куда надо копировать группы,"
            skip "уже есть группы блюд."
            skip(1)
            skip "Копирование невозможно."
        view-as alert-box error.
        undo, return error .
    end.
    for each buf_from_fbr-gds-grp no-lock
       where buf_from_fbr-gds-grp.obj-type = p-from-obj-type
         and buf_from_fbr-gds-grp.obj-code = p-from-obj-code
    on error undo, return error
    :
        create buf_to_fbr-gds-grp.
        buffer-copy
            buf_from_fbr-gds-grp
            except
                buf_from_fbr-gds-grp.obj-type
                buf_from_fbr-gds-grp.obj-code
                buf_from_fbr-gds-grp.node-code
            to buf_to_fbr-gds-grp
        .
        assign
            buf_to_fbr-gds-grp.obj-type     = p-to-obj-type
            buf_to_fbr-gds-grp.obj-code     = p-to-obj-code
            buf_to_fbr-gds-grp.node-code    = buf_from_fbr-gds-grp.node-code
        .
        for each buf_from_fbr-gds-obj no-lock
           where buf_from_fbr-gds-obj.obj-type      = p-from-obj-type
             and buf_from_fbr-gds-obj.obj-code      = p-from-obj-code
             and buf_from_fbr-gds-obj.fbr-grp-code  = buf_from_fbr-gds-grp.node-code
        on error undo, return error
        :
            find first buf_to_fbr-gds-obj exclusive-lock
                 where buf_to_fbr-gds-obj.obj-type = p-to-obj-type
                   and buf_to_fbr-gds-obj.obj-code = p-to-obj-code
                   and buf_to_fbr-gds-obj.gds-code = buf_from_fbr-gds-obj.gds-code
            no-error.
            if not available buf_to_fbr-gds-obj
            then do:
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input 'ДОБАВЛЕНИЕ':U
                    , input no
                    , input buf_from_fbr-gds-obj.gds-code
                    , input p-to-obj-type
                    , input p-to-obj-code
                    , input buf_to_fbr-gds-grp.node-code
                    , input ""
                    , input 0
                    , input no
                    , input no
                    , input no
                    , input no
                    , input no
                    , input no
               ) no-error.
               if error-status :error
               then do:
                   message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка при создании записи товара производства на объекте."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                   view-as alert-box error.
                   undo, return error .
               end.
            end.
            else do:
                assign
                    v-fbr-gds-obj-recid = recid( buf_to_fbr-gds-obj )
                .
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input 'ИЗМЕНЕНИЕ':U
                    , input no
                    , input buf_to_fbr-gds-obj.gds-code
                    , input buf_to_fbr-gds-obj.obj-type
                    , input buf_to_fbr-gds-obj.obj-code
                    , input buf_from_fbr-gds-grp.node-code
                    , input buf_to_fbr-gds-obj.obj-type
                    , input buf_to_fbr-gds-obj.obj-code
                    , input buf_to_fbr-gds-obj.is-cd
                    , input buf_to_fbr-gds-obj.is-menu
                    , input buf_to_fbr-gds-obj.is-modificator
                    , input buf_to_fbr-gds-obj.is-null-price
                    , input buf_to_fbr-gds-obj.is-season
                    , input buf_to_fbr-gds-obj.is-semi-finished
               ) no-error.
               if error-status :error
               then do:
                   message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка при изменении записи товара производства на объекте."
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
end.
END PROCEDURE.
PROCEDURE create-new-line :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-upper-code     as integer      no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.
define variable v-full-name         as character         no-undo.
define variable v-sort-name         as character         no-undo.
define variable v-margins-range     as integer           no-undo.
define variable v-margins-exists    as logical           no-undo.
define variable v-increase-range    as integer          no-undo.
define variable v-increase-exists   as logical          no-undo.
define variable v-min-marg          as decimal           no-undo.
define variable v-max-marg          as decimal           no-undo.
define variable v-increase-pc       as decimal           no-undo.
define variable v-round-method      as character         no-undo .
define variable v-base              as decimal           no-undo .
define variable v-rmethod-range     as integer           no-undo.
define variable v-rmethod-exists    as logical           no-undo.
define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run fbrglib-get-sort-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    create buf_temp_fbrglib_grp.
    assign
        buf_temp_fbrglib_grp.node-code   = p-node-code
        buf_temp_fbrglib_grp.upper-code  = p-upper-code
        buf_temp_fbrglib_grp.level       = p-level
        buf_temp_fbrglib_grp.out-code    = p-out-code
        buf_temp_fbrglib_grp.full-name   = v-full-name
        buf_temp_fbrglib_grp.sort-name   = v-sort-name
        buf_temp_fbrglib_grp.obj-type    = p-obj-type
        buf_temp_fbrglib_grp.obj-code    = p-obj-code
        buf_temp_fbrglib_grp.global-code = p-global-code
    .
    run get-first-char in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output buf_temp_fbrglib_grp.mark
    ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_fbrglib_grp.name = fill( " ", 4 * p-level )
                                        + buf_temp_fbrglib_grp.mark
                                        + " "
                                        + p-node-name
    .
end.
END PROCEDURE.
PROCEDURE delete-grp :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.
    define variable v-deleted           as logical        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp      for temp_fbrglib_grp.
    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу удалить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Удаление группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
        AND buf_temp_fbrglib_grp.obj-type = p-store-type
        AND buf_temp_fbrglib_grp.obj-code = p-store-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    assign
        v-upper-code = buf_temp_fbrglib_grp.upper-code
    .
    run fbrglib-delete-grp in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-deleted
    ) no-error .
    if error-status:error then do:
      message
      "Ошибка при удалении группы блюд"
      error-status:get-message(1) skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
    if p-refresh = yes
    then do:
        if v-upper-code = 1
        then do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.node-code = 1
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "delete-grp: Не найдена корневая группа в БД".
            end.
        end.
        else do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-store-type
                   and buf_fbr-gds-grp.obj-code  = p-store-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "delete-grp: Не найдена группа в БД".
            end.
        end.
        assign
            p-recid-list     = string( recid( buf_fbr-gds-grp ) )
            fbr-gds-grp-row  = recid( buf_fbr-gds-grp )
        .
        assign
        entry(v-rubr-mode + 1, v-uf-List_,  chr(4)) = if fbr-gds-grp-row = ?
                                                            then chr(63)
                                                            else string(fbr-gds-grp-row)
        .
        run uf-set in this-procedure (
             input  'fbr-gds-grp-p':U
            ,input  v-cntxt-userid
            ,input v-uf-List_
            ,input v-uf-Naim
            ,input v-uf-print-graft
            ,input v-uf-sort-gr
            ,input v-uf-type-price
            ,input v-uf-type-val
        )  no-error .
        run UI-on in this-procedure no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка при загрузке дерева групп.".
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dlg-grp.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-kitchen-type fi-kitchen-code fi-search-0 fi-search
      WITH FRAME Dlg-grp.
  ENABLE b-exit RECT-rubr b-mark b-sel b-add b-chg b-del b-move b-goods b-print
         b-help B-global b-copy fi-kitchen-code bt-sel-kitchen B-hist
         b-expand-0 b-expand-all-0 fi-search-0 b-find-by-full-name-0
         b-find-by-substring-0 b-search-0 b-expand b-expand-all fi-search
         b-find-by-full-name b-find-by-substring b-search B-copy0 B-link
         br-global br-list
      WITH FRAME Dlg-grp.
  VIEW FRAME Dlg-grp.
  OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
END PROCEDURE.
PROCEDURE expand-all-from-current :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code as integer      no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.
    for each buf_temp_fbrglib_grp
       where buf_temp_fbrglib_grp.full-name begins v-full-name
        AND buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    :
        run expand-item in this-procedure (INPUT p-obj-type, INPUT p-obj-code,  input buf_temp_fbrglib_grp.node-code, input no ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
    end.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
        br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp .
        reposition br-global to row v-repositioned-row no-error .
    END.
    ELSE DO:
      OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
      br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
     reposition br-list to row v-repositioned-row no-error .
    END.
end.
END PROCEDURE.
PROCEDURE expand-item :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        assign
            v-focused-row      = br-global :focused-row in frame Dlg-grp.
            v-repositioned-row = current-result-row( "br-global" )
        .
    END.
    ELSE DO:
        assign
            v-focused-row      = br-list :focused-row in frame Dlg-grp.
            v-repositioned-row = current-result-row( "br-list" )
        .
    END.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.obj-type = p-obj-type
        AND buf_temp_fbrglib_grp.obj-code = p-obj-code
        AND buf_temp_fbrglib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.
    if buf_temp_fbrglib_grp.mark <> "»"
    then do:
    end.
    else do:
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-obj-type
             and buf_fbr-gds-grp.obj-code   = p-obj-code
             and buf_fbr-gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input buf_fbr-gds-grp.node-code
                , input buf_fbr-gds-grp.upper-code
                , input buf_temp_fbrglib_grp.level + 1
                , input buf_fbr-gds-grp.node-name
                , input buf_fbr-gds-grp.out-code
                , input buf_fbr-gds-grp.global-code
            ) no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "expand-item: Ошибка добавления строки в список групп."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            buf_temp_fbrglib_grp.mark = "«"
            buf_temp_fbrglib_grp.name = replace( buf_temp_fbrglib_grp.name
                                            , "»"
                                            , "«"
                                            )
        .
        if p-refresh = yes
        then do:
           IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
            OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
            if v-focused-row > br-global :height - 2
            then do:
                assign
                    v-focused-row       = br-global :height - 2
                .
            end.
            br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
            reposition br-global to row v-repositioned-row.
           END.
           ELSE DO:
            OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
            if v-focused-row > br-list :height - 2
            then do:
                assign
                    v-focused-row       = br-list :height - 2
                .
            end.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
            reposition br-list to row v-repositioned-row.
           END.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE expand-or-collapse-item :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
DEFINE INPUT PARAMETER p-grp-mark LIKE temp_fbrglib_grp.mark NO-UNDO.
DEFINE INPUT PARAMETER p-node-code LIKE temp_fbrglib_grp.node-code NO-UNDO.
do
on error undo, return error
:
    case p-grp-mark
    :
    when "»"
    then do:
        run expand-item in this-procedure ( INPUT p-obj-type, INPUT p-obj-code, input p-node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when "«"
    then do:
        run collapse-item in this-procedure (INPUT p-obj-type, INPUT p-obj-code, input p-node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы.".
        end.
    end.
    end case.
end.
END PROCEDURE.
PROCEDURE expand-tree-for-grp :
do
on error undo, return error
:
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-node-code              as integer          no-undo.
define output parameter p-focused-row           as integer          no-undo.
define output parameter p-reposition-row        as integer          no-undo.
define output parameter p-reposition-to-recid   as logical init no  no-undo.
define variable v-full-name             as character        no-undo.
define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    run fbrglib-get-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-full-name ) no-error .
    if error-status :error
    then do:
    end.
    else do:
        run fbrglib-find-grp-by-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input right-trim( v-full-name, chr(47) )
            , input yes
        ) no-error .
        if error-status :error
        then do:
        end.
        else do:
            process-initial-grp:
            for each temp_fbrglib_found-grp
            where temp_fbrglib_found-grp.obj-type = p-obj-type
            AND temp_fbrglib_found-grp.obj-code = p-obj-code
            break
            by temp_fbrglib_found-grp.obj-type
            by temp_fbrglib_found-grp.obj-code
            by temp_fbrglib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_fbrglib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( if v-rubr-mode = 0
                                                       then ((br-list :height in frame Dlg-grp / 2 ) + 1)
                                                       else ((br-global :height in frame Dlg-grp / 2 ) + 1))
                    .
                    find first buf_temp_fbrglib_grp
                         where buf_temp_fbrglib_grp.node-code = temp_fbrglib_found-grp.node-code
                          AND buf_temp_fbrglib_grp.obj-type  = temp_fbrglib_found-grp.obj-type
                          AND buf_temp_fbrglib_grp.obj-code  = temp_fbrglib_found-grp.obj-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_fbrglib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_fbrglib_found-grp.obj-type, input temp_fbrglib_found-grp.obj-code,  input temp_fbrglib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_fbrglib_grp
                            where buf_temp_fbrglib_grp.node-code = temp_fbrglib_found-grp.node-code
                              AND buf_temp_fbrglib_grp.obj-type  = temp_fbrglib_found-grp.obj-type
                              AND buf_temp_fbrglib_grp.obj-code  = temp_fbrglib_found-grp.obj-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_fbrglib_grp )
                        p-reposition-to-recid = yes
                    .
                end.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE fill-marg :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-margins-range     as integer  no-undo.
    define variable v-margins-exists    as logical  no-undo.
    define variable v-increase-range     as integer  no-undo.
    define variable v-increase-exists    as logical  no-undo.
    define variable v-min-marg          as decimal  no-undo.
    define variable v-max-marg          as decimal  no-undo.
    define variable v-increase-pc          as decimal  no-undo.
    define variable v-round-method      as character   no-undo .
    define variable v-base              as decimal     no-undo .
    define variable v-rmethod-range     as integer     no-undo.
    define variable v-rmethod-exists    as logical     no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run ref/pr-marg.w (
          input parparentproc
        , input p-node-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-marg: Ошибка при установке диапазона торговых наценок." + chr(10) + return-value.
    end.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
         AND buf_temp_fbrglib_grp.obj-type  = p-store-type
         AND buf_temp_fbrglib_grp.obj-code  = p-store-code
    no-error .
    if error-status :error
    then do:
        undo, return error "fill-marg: Неверно задан код группы.".
    end.
    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.
PROCEDURE fill-output-parameters-on-exit :
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-node-code as integer      no-undo.
    define variable v-selected      as logical  init no  no-undo.
    define variable v-is-terminal   as logical           no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
    run fbrglib-is-terminal in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-is-terminal
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if lookup ( 'терм':U, p-button-list ) <> 0
    and v-is-terminal = no
    then do:
        message "Требуется выбрать группу блюд, в которой нет других групп.".
        apply "entry" to br-list in frame Dlg-grp.
        return no-apply.
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_fbrglib_grp
       where buf_temp_fbrglib_grp.sel = "*"
          AND buf_temp_fbrglib_grp.obj-type =  p-obj-type
          AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    :
        if buf_temp_fbrglib_grp.node-code = v-fbrggrp-root-code
        then do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = ""
                   and buf_fbr-gds-grp.obj-code  = 0
                   and buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
            no-error .
            if error-status :error
            then do:
                undo, return error "fill-output-parameters-on-exit: Не найдена корневая запись групп блюд'".
            end.
        end.
        else do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = buf_temp_fbrglib_grp.node-code
            no-error .
            if error-status :error
            then do:
                undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                    + "'" + buf_temp_fbrglib_grp.full-name + "'".
            end.
        end.
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_fbr-gds-grp ) )
            v-selected   = yes
        .
    end.
    if v-selected = no
    then do:
        if p-node-code = v-fbrggrp-root-code
        then do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = ""
                   and buf_fbr-gds-grp.obj-code  = 0
                   and buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
            no-error .
        end.
        else do:
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = p-node-code
            no-error .
        end.
        if not available buf_fbr-gds-grp
        then do:
            find first buf_temp_fbrglib_grp
                 where buf_temp_fbrglib_grp.node-code = p-node-code
                  AND buf_temp_fbrglib_grp.obj-type  = p-obj-type
                  AND buf_temp_fbrglib_grp.obj-code  = p-obj-code
            no-error .
            if not available buf_temp_fbrglib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_fbrglib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_fbr-gds-grp ) )
        .
    end.
    assign
        fbr-gds-grp-row      = integer( entry( 1, p-recid-list ) )
    .
assign
entry(v-rubr-mode + 1, v-uf-List_,  chr(4)) =  if fbr-gds-grp-row = ?
                                                     then chr(63)
                                                     else string( fbr-gds-grp-row )
.
run uf-set in this-procedure(
      input 'fbr-gds-grp-p':U
    , input v-cntxt-userid
    , input v-uf-List_
    , input v-uf-Naim
    , input v-uf-print-graft
    , input v-uf-sort-gr
    , input v-uf-type-price
    , input v-uf-type-val
)  no-error .
end.
END PROCEDURE.
PROCEDURE find-grp-in-browse :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-search-grp-full-name   as character    no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define variable v-counter           as integer              no-undo.
    define variable v-level             as integer              no-undo.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer bf_temp_fbrglib_grp       for temp_fbrglib_grp.
    DEFINE BUFFER bf_temp_fbrglib_found-grp FOR temp_fbrglib_found-grp.
    IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
        assign
        v-focused-row      = br-global :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-global" )
    .
    END.
    ELSE DO:
        assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    END.
    assign
    v-level = num-entries( right-trim(p-search-grp-full-name, chr(47) ) , chr(47))
    .
    if v-found-grp-num  <> 0
    then do:
        assign
            v-counter = 0
        .
        find first bf_temp_fbrglib_found-grp
            where  bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
            AND bf_temp_fbrglib_found-grp.level = v-level
        no-error .
        if not available bf_temp_fbrglib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next bf_temp_fbrglib_found-grp
                where bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
            AND bf_temp_fbrglib_found-grp.level = v-level
            no-error .
            if not available bf_temp_fbrglib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_fbrglib_grp
                where buf_temp_fbrglib_grp.node-code = bf_temp_fbrglib_found-grp.node-code
                  AND buf_temp_fbrglib_grp.obj-type  = p-obj-type
                  AND buf_temp_fbrglib_grp.obj-code  = p-obj-code
        no-error .
        if not available buf_temp_fbrglib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        IF p-obj-type = "":U AND p-obj-code = 0 THEN DO:
            OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
            br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
        reposition br-global to recid recid( buf_temp_fbrglib_grp ).
        END.
        ELSE DO:
            OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
           br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
           reposition br-list to recid recid( buf_temp_fbrglib_grp ).
        END.
    end.
    else do:
        run fbrglib-find-grp-by-full-name (
              input p-obj-type
            , input p-obj-code
            , input (IF p-obj-type = "":U AND p-obj-code = 0
                     THEN fi-search-0 :screen-value in frame Dlg-grp
                      ELSE fi-search :screen-value in frame Dlg-grp)
            , input yes
        ) no-error.
        if error-status :error
        then do:
            undo, return error "Не удалось найти группу '" +
                (IF p-obj-type = "":U AND p-obj-code = 0
                 THEN fi-search-0 :screen-value in frame Dlg-grp
                    ELSE fi-search :screen-value in frame Dlg-grp) + "'".
        end.
        found-group:
        for each bf_temp_fbrglib_found-grp no-lock
            WHEre bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
        by bf_temp_fbrglib_found-grp.level
        :
            if bf_temp_fbrglib_found-grp.level = v-level
            then do:
                leave.
            end.
            run expand-item in this-procedure ( INPUT p-obj-type, INPUT p-obj-code, input bf_temp_fbrglib_found-grp.node-code, input no ).
        end.
        find first bf_temp_fbrglib_found-grp
            WHEre bf_temp_fbrglib_found-grp.obj-type = p-obj-type
            AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
           AND bf_temp_fbrglib_found-grp.level = v-level
        no-error .
        if not available bf_temp_fbrglib_found-grp
        then do:
            undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
        end.
        find first buf_temp_fbrglib_grp
            WHEre buf_temp_fbrglib_grp.obj-type = p-obj-type
            AND buf_temp_fbrglib_grp.obj-code = p-obj-code
             AND buf_temp_fbrglib_grp.node-code = bf_temp_fbrglib_found-grp.node-code
        no-error .
        if not available buf_temp_fbrglib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        IF p-obj-type = "":U AND p-obj-code = 0  THEN DO:
            OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
            br-global :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
            reposition br-global to recid recid( buf_temp_fbrglib_grp ).
        END.
        ELSE DO:
            OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
            reposition br-list to recid recid( buf_temp_fbrglib_grp ).
        END.
    end.
    find next bf_temp_fbrglib_found-grp
        WHEre bf_temp_fbrglib_found-grp.obj-type = p-obj-type
         AND bf_temp_fbrglib_found-grp.obj-code = p-obj-code
         AND bf_temp_fbrglib_found-grp.level = v-level
    no-error .
    IF p-obj-type = "":U AND p-obj-code = 0  THEN DO:
        if available bf_temp_fbrglib_found-grp
        then do:
               assign
                v-found-grp-num-0  = v-found-grp-num + 1
                b-search-0 :label = "Далее"
            .
        end.
        else do:
            assign
                v-found-grp-num-0  = 0
                b-search-0 :label = "Поиск"
            .
        end.
    END.
    ELSE DO:
        if available bf_temp_fbrglib_found-grp
        then do:
               assign
                v-found-grp-num  = v-found-grp-num + 1
                b-search :label = "Далее"
            .
        end.
        else do:
            assign
                v-found-grp-num  = 0
                b-search :label = "Поиск"
            .
        end.
    END.
end.
END PROCEDURE.
PROCEDURE get-current-recid :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define output parameter p-fbr-gds-grp-recid as recid   no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.node-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-fbr-gds-grp-recid = recid( buf_fbr-gds-grp )
    .
end.
END PROCEDURE.
PROCEDURE get-first-char :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-prefix    as character    no-undo.
define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-goods    as logical      no-undo.
define buffer buf_fbr-gds-grp               for ub.fbr-gds-grp.
define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
run fbrglib-is-terminal in this-procedure (
      input p-obj-type
    , input p-obj-code
    , input p-node-code
    , output v-is-terminal
) no-error .
if error-status :error
then do:
    undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
end.
if v-is-terminal = yes
then do:
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
    end.
    if v-have-goods = yes
    then do:
        assign
            p-prefix = "•"
        .
    end.
    else do:
        assign
            p-prefix = " "
        .
    end.
end.
else do:
    find first buf_temp_fbrglib_grp no-lock
         where buf_temp_fbrglib_grp.upper-code = p-node-code
         AND buf_temp_fbrglib_grp.obj-type  = p-obj-type
         AND buf_temp_fbrglib_grp.obj-code  = p-obj-code
    no-error.
    if available buf_temp_fbrglib_grp
    then do:
        assign
            p-prefix = "«"
        .
    end.
    else do:
        assign
            p-prefix = "»"
        .
    end.
end.
end.
END PROCEDURE.
PROCEDURE get-obj-type :
do
on error undo, return error
:
define input parameter p-obj-code   as integer      no-undo.
define output parameter p-obj-type  as character    no-undo.
    define buffer buf_shop_clients      for ub.clients.
    define buffer buf_stock_clients     for ub.clients.
    find first buf_shop_clients no-lock
         where buf_shop_clients.obj-type = 'маг':U
           and buf_shop_clients.obj-code = p-obj-code
    no-error.
    find first buf_stock_clients no-lock
         where buf_stock_clients.obj-type = 'скл':U
           and buf_stock_clients.obj-code = p-obj-code
    no-error.
    if available buf_shop_clients
    then do:
        if available buf_stock_clients
        then do:
            run str/fbrplnds.w (
                  input "Выберите тип объекта:"
                , output p-obj-type
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка определения типа объекта."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                assign
                    p-obj-type = ?
                .
                undo, return error .
            end.
        end.
        else do:
            assign
                p-obj-type = buf_shop_clients.obj-type
            .
        end.
    end.
    else do:
        if available buf_stock_clients
        then do:
            assign
                p-obj-type = buf_stock_clients.obj-type
            .
        end.
        else do:
            assign
                p-obj-type = ?
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE get-row-amount :
do
on error undo, return error
:
define INPUT  parameter p-obj-type as character      no-undo.
define INPUT  parameter p-obj-code as integer      no-undo.
define output parameter p-row-amount as integer      no-undo.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    for each buf_temp_fbrglib_grp WHERE
           buf_temp_fbrglib_grp.obj-type = p-obj-type
       AND buf_temp_fbrglib_grp.obj-code = p-obj-code
    :
        assign
            p-row-amount = p-row-amount + 1
        .
    end.
end.
END PROCEDURE.
PROCEDURE link-grp :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-global-node-code  as integer      no-undo.
    define variable v-fbr-gds-grp-recid     as recid        no-undo.
    define variable v-focused-row           as integer      no-undo.
    define variable v-repositioned-row      as integer      no-undo.
    define variable v-have-rights           as logical      no-undo.
    define variable v-base                  as decimal      no-undo.
    define variable v-node-name             as character    no-undo.
    define variable v-out-code              as integer        no-undo.
    define variable v-cancel                as logical      no-undo.
    define buffer buf_fbr-gds-grp               for ub.fbr-gds-grp.
    define buffer bf0_fbr-gds-grp               for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp       for temp_fbrglib_grp.
    define buffer buf_child_temp_fbrglib_grp for temp_fbrglib_grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.
    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу изменить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    run check-rights-for-change-grp in this-procedure (
        output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп блюд."
          skip "Изменение группы невозможно."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    do transaction
    on error undo, return error
    :
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type  = p-store-type
               and buf_fbr-gds-grp.obj-code  = p-store-code
               and buf_fbr-gds-grp.node-code = p-node-code
        .
        find first bf0_fbr-gds-grp NO-LOCK
             where bf0_fbr-gds-grp.obj-type  = "":U
               and bf0_fbr-gds-grp.obj-code  = 0
               and bf0_fbr-gds-grp.node-code = p-global-node-code
        .
        find first bf_fbr-gds-grp no-lock
            where bf_fbr-gds-grp.obj-type   = p-store-type
              and bf_fbr-gds-grp.obj-code   = p-store-code
              and bf_fbr-gds-grp.out-code   = bf0_fbr-gds-grp.out-code
        no-error.
        assign
        buf_fbr-gds-grp.global-code   = bf0_fbr-gds-grp.global-code
        buf_fbr-gds-grp.out-code      = (if available bf_fbr-gds-grp then 0 else bf0_fbr-gds-grp.out-code)
.
    end.
    find first buf_temp_fbrglib_grp
         where buf_temp_fbrglib_grp.node-code = p-node-code
    no-error.
    if not available buf_temp_fbrglib_grp
    then do:
        undo, return error "change-grp: Ошибка поиска группы в списке.".
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Неверный выбор группы.".
    end.
    assign
    buf_temp_fbrglib_grp.global-code   = buf_fbr-gds-grp.global-code
    buf_temp_fbrglib_grp.out-code   = buf_fbr-gds-grp.out-code
    .
    OPEN QUERY br-list FOR EACH temp_fbrglib_grp NO-LOCK where     temp_fbrglib_grp.obj-type = p-store-type  AND temp_fbrglib_grp.obj-code = p-store-code     by temp_fbrglib_grp.sort-name.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
end.
END PROCEDURE.
PROCEDURE move-item :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define input parameter p-upper-code as integer      no-undo.
    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-goods        as logical      no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp     for ub.fbr-gds-grp.
    define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
if session :set-wait-state( "compiler" ) then.
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-upper-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
    end.
    if v-have-goods = yes
    then do:
            message
                "В эту группу переместить нельзя, т.к. в одной группе"
                skip "не могут быть одновременно подгруппы и товары.".
            apply "entry" to br-list in frame Dlg-grp.
            return no-apply.
    end.
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени группы".
    end.
    if v-upper-full-name begins v-node-full-name
    then do:
        message
            "Группу нельзя переместить в ее собственную подгруппу."
        view-as alert-box.
        undo, return.
    end.
    do transaction
    on error undo, return error "move-item: Ошибка перемещения группы.".
        find first buf_fbr-gds-grp exclusive-lock
             where buf_fbr-gds-grp.obj-type     = p-obj-type
               and buf_fbr-gds-grp.obj-code     = p-obj-code
               and buf_fbr-gds-grp.node-code    = p-node-code
        no-error .
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_fbr-gds-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_fbr-gds-grp ) )
        fbr-gds-grp-row  = recid( buf_fbr-gds-grp )
    .
    run UI-on in this-procedure no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка при загрузке дерева групп." + chr(10) + return-value.
    end.
end.
END PROCEDURE.
PROCEDURE print-browse :
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable Line as character no-undo.
define variable date_string as character no-undo.
define buffer buf_temp_fbrglib_grp for temp_fbrglib_grp.
DEFINE FRAME brFrame
buf_temp_fbrglib_grp.global-code   format ">>>>9"      COLUMN-LABEL "Руб-р"
buf_temp_fbrglib_grp.name          format "X(71)"      column-label "Наименование группы"
buf_temp_fbrglib_grp.out-code      format ">>>>9"      COLUMN-LABEL "Код на!кассе"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 85 PAGE-NUMBER(PrnLibStream) AT 95 FORMAT ">>9" SKIP
Line format "X(150)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 150).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( if p-obj-type = "":U and p-obj-code = 0
            then br-global:title in frame Dlg-grp
            else br-list:title  )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(150)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").
FOR EACH buf_temp_fbrglib_grp where
        buf_temp_fbrglib_grp.obj-type = p-obj-type
    and buf_temp_fbrglib_grp.obj-code = p-obj-code :
  DISPLAY stream PrnLibStream
  buf_temp_fbrglib_grp.global-code
  buf_temp_fbrglib_grp.name
  buf_temp_fbrglib_grp.out-code
  with frame BrFrame.
  DOwn stream PrnLibStream
  with frame BrFrame.
END.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME BrFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE print-grp :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    if print-option = "":U
    then do:
        run gbl/pop-up.p (
            input b-print:handle in frame Dlg-grp
            , input no
        ) no-error.
        if error-status:error
        then do:
            assign
                print-option = "":U
            .
            return no-apply.
        end.
    end.
    if p-node-code = 1
    then do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = ""
               and buf_fbr-gds-grp.obj-code  = 0
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "Ошибка определения корневой группы.".
        end.
    end.
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "Неверно выбрана группа.".
        end.
    end.
    CASE print-option:
      when "browse":U then do:
        run print-browse in this-procedure (p-store-type, p-store-code)
        no-error.
      end.
      when "browse-global":U then do:
        run print-browse in this-procedure ("":U, 0)
        no-error.
      end.
      otherwise do:
        run rep/r-gdsggr.p (
              input parparentproc
            , input p-obj-type
            , input p-obj-code
            , input recid( buf_fbr-gds-grp )
            , input print-option
        ) no-error .
      end.
    END CASE.
    if error-status :error
    then do:
        assign
            print-option = "":U
        .
        undo, return error "Ошибка печати групп блюд.".
    end.
    apply "entry" to br-list in frame Dlg-grp.
end.
END PROCEDURE.
PROCEDURE proc-b-rubr :
DEFINE INPUT PARAMETER p-rubr AS LOGICAL NO-UNDO.
define buffer buf_clients for ub.clients.
find first buf_clients no-lock
     where buf_clients.obj-type = p-store-type
       and buf_clients.obj-code = p-store-code
.
CASE p-rubr:
    WHEN YES THEN DO:
        ASSIGN
       br-list:WIDTH IN FRAME Dlg-grp = 56
       b-expand:COL IN FRAME Dlg-grp            = v-b-expand-COL + 50
       b-expand-all:COL IN FRAME Dlg-grp        = v-b-expand-all-COL + 50
       b-find-by-full-name:COL IN FRAME Dlg-grp = v-b-find-by-full-name-COL + 50
       b-find-by-substring:COL IN FRAME Dlg-grp = v-b-find-by-substring-COL + 50
       br-list:COL IN FRAME Dlg-grp             = 44
       b-search:COL IN FRAME Dlg-grp            = v-b-search-COL + 50
       fi-search:COL IN FRAME Dlg-grp           = v-fi-search-COL + 50
       .
       DISPLAY
       b-copy0
       b-link
       b-expand-0
       b-expand-all-0
       b-find-by-full-name-0
       b-find-by-substring-0
       br-global
       b-search-0
       fi-search-0
       RECT-rubr
       WITH FRAME Dlg-grp.
       if v-cntxt-db-num <> buf_clients.db-num then do:
        DISABLE
        b-copy0
        b-link
        with frame Dlg-grp .
       end.
       else do:
        ENABLE
        b-copy0
        b-link
        with frame Dlg-grp .
       end.
       APPLY "ENTRY" to br-global.
    END.
    WHEN NO THEN DO:
        HIDE
        b-copy0
        b-link
        b-expand-0
        b-expand-all-0
        b-find-by-full-name-0
        b-find-by-substring-0
        br-global
        b-search-0
        fi-search-0
        RECT-rubr
        IN  FRAME Dlg-grp.
        ASSIGN
       b-expand:COL IN FRAME Dlg-grp            = v-b-expand-COL
       b-expand-all:COL IN FRAME Dlg-grp        = v-b-expand-all-COL
       b-find-by-full-name:COL IN FRAME Dlg-grp = v-b-find-by-full-name-COL
       b-find-by-substring:COL IN FRAME Dlg-grp = v-b-find-by-substring-COL
       br-list:COL IN FRAME Dlg-grp = 1
       b-search:COL IN FRAME Dlg-grp = v-b-search-COL
       fi-search:COL IN FRAME Dlg-grp = v-fi-search-COL
       br-list:WIDTH = 98
       .
       APPLY "ENTRY" to br-list.
    END.
END CASE.
END PROCEDURE.
PROCEDURE rubr-on :
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + chr(10) + return-value.
end.
run uf-get in this-procedure(
     input  'fbr-gds-grp-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error .
if not error-status:error then
assign
v-uf-List_ = if num-entries(v-uf-list_, chr(4)) = 1
              then (v-uf-list_ + chr(4) + chr(63))
              else v-uf-list_
fbr-gds-grp-row =  if (num-entries(v-uf-List_, chr(4)) < 2) or (entry(2, v-uf-List_, chr(4)) =  chr(63))
                   then ?
                   else integer(entry(2, v-uf-LIst_, chr(4)))
.
else do:
  assign
  v-uf-List_ = if num-entries(v-uf-list_, chr(4)) = 1
                then (v-uf-list_ + chr(4) + chr(63))
                else v-uf-list_
  fbr-gds-grp-row =  if (num-entries(v-uf-List_, chr(4)) < 2) or (entry(2, v-uf-List_, chr(4)) =  chr(63))
                    then ?
                    else integer(entry(2, v-uf-LIst_, chr(4)))
  .
end.
assign
    p-recid-list = (if p-recid-list = "":U then string( fbr-gds-grp-row ) else p-recid-list)
.
find first buf_fbr-gds-grp no-lock
     where buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
for each buf_temp_fbrglib_grp
:
    delete buf_temp_fbrglib_grp.
end.
create buf_temp_fbrglib_grp.
assign
    buf_temp_fbrglib_grp.node-code   = buf_fbr-gds-grp.node-code
    buf_temp_fbrglib_grp.upper-code  = buf_fbr-gds-grp.upper-code
    buf_temp_fbrglib_grp.level       = 0
    buf_temp_fbrglib_grp.mark        = ( if v-have-goods = yes then "•" else " " )
    buf_temp_fbrglib_grp.full-name   = chr(4)
    buf_temp_fbrglib_grp.sort-name   = chr(4)
    buf_temp_fbrglib_grp.name        = buf_fbr-gds-grp.node-name
    buf_temp_fbrglib_grp.out-code    = buf_fbr-gds-grp.out-code
.
for each buf_fbr-gds-grp no-lock
    where buf_fbr-gds-grp.obj-type   = "":U
      and buf_fbr-gds-grp.obj-code   = 0
      and buf_fbr-gds-grp.upper-code = v-fbrggrp-root-code
 :
     run create-new-line in this-procedure (
           input buf_fbr-gds-grp.obj-type
         , input buf_fbr-gds-grp.obj-code
         , input buf_fbr-gds-grp.node-code
         , input buf_fbr-gds-grp.upper-code
         , input 1
         , input buf_fbr-gds-grp.node-name
         , input buf_fbr-gds-grp.out-code
         , input buf_fbr-gds-grp.global-code
     ) no-error .
     if error-status :error
     then do:
         message
           vss-workfile vss-revision vss-description
           skip "rubr-on: Ошибка добавления строки в список групп."
           skip return-value
           skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
         view-as alert-box error.
         undo, return error .
     end.
 end.
if p-recid-list <> "" and p-recid-list <> ?
then do:
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_fbr-gds-grp no-lock
         where recid( buf_fbr-gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_fbr-gds-grp
    then do:
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
              input buf_fbr-gds-grp.obj-type
            , input buf_fbr-gds-grp.obj-code
            , input buf_fbr-gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "rubr-on: Не удалось раскрыть дерево групп." + chr(10) + return-value.
        end.
    end.
end.
ASSIGN
b-print:MENU-MOUSE in frame Dlg-grp =  1
br-global:width = 98
.
DISPLAY fi-search-0
WITH FRAME Dlg-grp .
ENABLE
b-exit
b-sel WHEN LOOKUP("b-sel", p-button-list) > 0
b-help
b-expand-0
b-expand-all-0
fi-search-0
b-find-by-full-name-0
b-find-by-substring-0
b-search-0
br-global
WITH FRAME Dlg-grp .
VIEW FRAME Dlg-grp .
hide
fi-kitchen-type
fi-kitchen-code
b-mark
b-add b-chg b-del b-move b-goods b-print
B-global b-copy fi-kitchen-code bt-sel-kitchen
b-expand b-expand-all fi-search b-find-by-full-name
b-find-by-substring b-search B-copy0 B-link
br-list RECT-rubr
in FRAME Dlg-grp .
OPEN QUERY br-global FOR EACH buf0_temp_fbrglib_grp NO-LOCK  WHERE   buf0_temp_fbrglib_grp.obj-type = "":U AND buf0_temp_fbrglib_grp.obj-code = 0 by buf0_temp_fbrglib_grp.sort-name.
br-global :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
if v-reposition-to-recid = no
then do:
    reposition br-global to row v-reposition-row no-error .
end.
else do:
    reposition br-global to recid v-reposition-row no-error .
end.
end.
END PROCEDURE.
PROCEDURE select-and-move-item :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
    define variable v-upper-code        as integer           no-undo.
    define variable v-upper-recid-list  as character         no-undo.
    define variable v-yesno             as logical           no-undo.
    define variable v-node-full-name    as character         no-undo.
    define variable v-upper-full-name   as character         no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    if p-node-code = v-fbrggrp-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-store-type
           and buf_fbr-gds-grp.obj-code  = p-store-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_fbr-gds-grp ) )
    .
    run ref/fbrggrp.w (
          input parparentproc
        , input p-store-type
        , input p-store-code
        , input "buttons-for-move"
        , input-output v-upper-recid-list
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы для перемещения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    find first buf_fbr-gds-grp no-lock
         where recid( buf_fbr-gds-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run fbrglib-get-full-name in this-procedure (
          input p-store-type
        , input p-store-code
        , input p-node-code
        , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run fbrglib-get-full-name in this-procedure (
          input buf_fbr-gds-grp.obj-type
        , input buf_fbr-gds-grp.obj-code
        , input buf_fbr-gds-grp.node-code
        , output v-upper-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени новой группы".
    end.
    message
        "Переместить группу"
        skip "    '" + v-node-full-name + "'"
        skip "в группу"
        skip "    '" + ( if buf_fbr-gds-grp.node-code = v-fbrggrp-root-code then "Блюда" else v-upper-full-name ) + "'"
    view-as alert-box question
    buttons yes-no
    title "Перемещение группы"
    update v-yesno.
    if v-yesno = no
    then do:
    end.
    else do:
        run move-item in this-procedure (
              input p-store-type
            , input p-store-code
            , input p-node-code
            , input buf_fbr-gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка перемещения группы."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE select-kitchen :
define input parameter p-old-obj-type   as character    no-undo.
define input parameter p-old-obj-code   as integer      no-undo.
define output parameter p-new-obj-type   as character    no-undo.
define output parameter p-new-obj-code   as integer      no-undo.
    define variable v-types as character no-undo .
    define variable v-old-cli-recid    as recid      no-undo.
    define variable v-new-cli-recid    as recid      no-undo.
    define buffer buf_clients       for ub.clients.
do
on error undo, return error
:
    assign
        v-types = 'маг':U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-old-obj-type
           and buf_clients.obj-code = p-old-obj-code
    no-error.
    if available buf_clients
    then do:
        assign
            v-old-cli-recid = recid( buf_clients )
        .
    end.
    else do:
        assign
            v-old-cli-recid = ?
        .
    end.
    run ref/cli-all.w (
          input parparentproc
        , input "b-sel"
        , input v-types
        , input ?
        , input ?
        , input v-old-cli-recid
        , input ?
        , input ?
        , output v-new-cli-recid
    ) .
    find first buf_clients no-lock
         where recid( buf_clients ) = v-new-cli-recid
    no-error.
    if available buf_clients
    then do:
        assign
            p-new-obj-type = buf_clients.obj-type
            p-new-obj-code = buf_clients.obj-code
        .
    end.
    else do:
        assign
            p-new-obj-type = ""
            p-new-obj-code = 0
        .
    end.
end.
END PROCEDURE.
PROCEDURE UI-on :
do
on error undo, return error
:
define variable v-reposition-row        as integer          no-undo.
define variable v-focused-row           as integer          no-undo.
define variable v-reposition-to-recid   as logical init no  no-undo.
define variable v-enable-change-grp     as logical          no-undo.
define variable v-margins-range         as integer          no-undo.
define variable v-margins-exists        as logical          no-undo.
define variable v-increase-range         as integer          no-undo.
define variable v-increase-exists        as logical          no-undo.
define variable v-min-marg              as decimal          no-undo.
define variable v-max-marg              as decimal          no-undo.
define variable v-increase-pc              as decimal          no-undo.
define variable v-have-goods            as logical          no-undo.
define variable v-round-method      as character   no-undo .
define variable v-base                  as decimal no-undo .
define variable v-rmethod-range     as integer     no-undo.
define variable v-rmethod-exists    as logical     no-undo.
define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
define buffer buf_temp_fbrglib_grp   for temp_fbrglib_grp.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_res-reference_update':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output v-enable-change-grp
    )  .
end.
run fbrglib-get-root-code in this-procedure ( output v-fbrggrp-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + chr(10) + return-value.
end.
run uf-get in this-procedure(
     input  'fbr-gds-grp-p':U
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error .
if not error-status:error then
assign
fbr-gds-grp-row =  if entry(1, v-uf-List_, chr(4)) =  chr(63)
                   then ?
                   else integer(entry(1, v-uf-LIst_, chr(4)))
.
assign
    p-recid-list = (if p-recid-list = "":U then string( fbr-gds-grp-row ) else p-recid-list)
.
find first buf_fbr-gds-grp no-lock
     where buf_fbr-gds-grp.node-code = v-fbrggrp-root-code
no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не найдена запись корневого узла."
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
run fbrglib-have-goods in this-procedure (
      input buf_fbr-gds-grp.obj-type
    , input buf_fbr-gds-grp.obj-code
    , input buf_fbr-gds-grp.node-code
    , output v-have-goods
) no-error .
if error-status :error
then do:
    undo, return error "UI-on: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
end.
for each buf_temp_fbrglib_grp
:
    delete buf_temp_fbrglib_grp.
end.
create buf_temp_fbrglib_grp.
assign
    buf_temp_fbrglib_grp.node-code   = buf_fbr-gds-grp.node-code
    buf_temp_fbrglib_grp.upper-code  = buf_fbr-gds-grp.upper-code
    buf_temp_fbrglib_grp.level       = 0
    buf_temp_fbrglib_grp.mark        = ( if v-have-goods = yes then "•" else " " )
    buf_temp_fbrglib_grp.full-name   = chr(4)
    buf_temp_fbrglib_grp.sort-name   = chr(4)
    buf_temp_fbrglib_grp.name        = buf_fbr-gds-grp.node-name
    buf_temp_fbrglib_grp.out-code    = buf_fbr-gds-grp.out-code
.
create buf_temp_fbrglib_grp.
assign
    buf_temp_fbrglib_grp.node-code   = buf_fbr-gds-grp.node-code
    buf_temp_fbrglib_grp.upper-code  = buf_fbr-gds-grp.upper-code
    buf_temp_fbrglib_grp.level       = 0
    buf_temp_fbrglib_grp.mark        = ( if v-have-goods = yes then "•" else " " )
    buf_temp_fbrglib_grp.full-name   = chr(4)
    buf_temp_fbrglib_grp.sort-name   = chr(4)
    buf_temp_fbrglib_grp.name        = buf_fbr-gds-grp.node-name
    buf_temp_fbrglib_grp.out-code    = buf_fbr-gds-grp.out-code
    buf_temp_fbrglib_grp.obj-type    = p-store-type
    buf_temp_fbrglib_grp.obj-code    = p-store-code
.
for each buf_fbr-gds-grp no-lock
    where buf_fbr-gds-grp.obj-type   = "":U
      and buf_fbr-gds-grp.obj-code   = 0
      and buf_fbr-gds-grp.upper-code = v-fbrggrp-root-code
 :
     run create-new-line in this-procedure (
           input buf_fbr-gds-grp.obj-type
         , input buf_fbr-gds-grp.obj-code
         , input buf_fbr-gds-grp.node-code
         , input buf_fbr-gds-grp.upper-code
         , input 1
         , input buf_fbr-gds-grp.node-name
         , input buf_fbr-gds-grp.out-code
         , input buf_fbr-gds-grp.global-code
     ) no-error .
     if error-status :error
     then do:
         message
           vss-workfile vss-revision vss-description
           skip "UI-on: Ошибка добавления строки в список групп."
           skip return-value
           skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
                trim(error-status :get-message(4))
                trim(error-status :get-message(5))
         view-as alert-box error.
         undo, return error .
     end.
 end.
for each buf_fbr-gds-grp no-lock
   where buf_fbr-gds-grp.obj-type   = p-store-type
     and buf_fbr-gds-grp.obj-code   = p-store-code
     and buf_fbr-gds-grp.upper-code = v-fbrggrp-root-code
:
    run create-new-line in this-procedure (
          input buf_fbr-gds-grp.obj-type
        , input buf_fbr-gds-grp.obj-code
        , input buf_fbr-gds-grp.node-code
        , input buf_fbr-gds-grp.upper-code
        , input 1
        , input buf_fbr-gds-grp.node-name
        , input buf_fbr-gds-grp.out-code
        , input buf_fbr-gds-grp.global-code
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "UI-on: Ошибка добавления строки в список групп."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
end.
if p-recid-list <> "" and p-recid-list <> ?
then do:
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_fbr-gds-grp no-lock
         where recid( buf_fbr-gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_fbr-gds-grp
    then do:
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
              input buf_fbr-gds-grp.obj-type
            , input buf_fbr-gds-grp.obj-code
            , input buf_fbr-gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + chr(10) + return-value.
        end.
    end.
end.
ASSIGN
b-print:MENU-MOUSE in frame Dlg-grp =  1.
run enable_UI.
define variable v-current-db-num    as integer        no-undo.
define buffer buf_clients       for ub.clients.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-store-type
       and buf_clients.obj-code = p-store-code
.
assign
    fi-kitchen-type :label = ""
.
hide
        b-sel
        b-mark
        b-add
        b-chg
        b-del
        b-move
        b-goods
        b-copy
        fi-kitchen-type
        fi-kitchen-code
        bt-sel-kitchen
in frame Dlg-grp .
if v-current-db-num = buf_clients.db-num
then do:
    case p-button-list
    :
        when "buttons-for-move"
        then do:
            disable
                b-exit    with frame Dlg-grp
            .
            view
                b-sel    in frame Dlg-grp
            .
        end.
        when "buttons-for-objcopy"
        then do:
            assign
                fi-kitchen-type :label = "Объект"
            .
            view
                fi-kitchen-type
                fi-kitchen-code
                bt-sel-kitchen
            in frame Dlg-grp .
            hide
                b-expand
                b-expand-all
                fi-search
                b-find-by-full-name
                b-find-by-substring
                b-search
            in frame Dlg-grp .
            if fi-kitchen-type <> ""
            and fi-kitchen-code <> 0
            then do:
                assign
                    frame Dlg-grp :title = substitute( "Группы блюд объекта &1 &2", fi-kitchen-type, fi-kitchen-code )
                .
            end.
        end.
        when "buttons-for-admin"
        then do:
            view
                b-add
                b-chg
                b-del
                b-move
                b-goods
                b-copy
            in frame Dlg-grp.
            if v-enable-change-grp = no
            then do:
                disable
                    b-add
                    b-chg
                    b-del
                    b-move
                    b-goods
                    b-copy
                with frame Dlg-grp.
            end.
        end.
        when 'терм':U + ",b-sel"
        or when "b-sel"
        then do:
            view
                b-sel    in frame Dlg-grp
            .
        end.
        when "b-sel,b-mark"
        then do:
            view
                b-sel    in frame Dlg-grp
                b-mark in frame Dlg-grp
            .
        end.
    end case.
end.
else do:
    view
        b-goods
    in frame Dlg-grp.
end.
RUN proc-b-rubr IN THIS-PROCEDURE (v-rubr).
br-global :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row no-error .
end.
else do:
    reposition br-list to recid v-reposition-row no-error .
end.
end.
END PROCEDURE.
