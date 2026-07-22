BLOCK-LEVEL ON ERROR UNDO, THROW.
define input parameter p-node-code  like ub.cli-grp.node-code .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление группы клиентов из базы данных".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_cgrplib_grp no-undo
    field sel           as character
    field full-name     as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field d-pcnt        as decimal
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_cgrplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field d-pcnt      as decimal
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_cfound-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field full-name     as character
    field sort-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure cli-grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-sort-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "cli-grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_cli-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-sort-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
procedure cgrplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    find first buf_cli-grp no-lock
        where buf_cli-grp.upper-code = 0
    no-error .
    if not available buf_cli-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_cli-grp.node-code
        .
    end.
end.
end procedure.
procedure cgrplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run cgrplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "cgrplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_cgrplib_found-grp
    :
        delete temp_cgrplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_cli-grp no-lock
                 where buf_cli-grp.upper-code = v-upper-code
                   and buf_cli-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_cli-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "cgrplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else chr(47) )         + buf_cli-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_cli-grp.node-name
                    v-upper-code = buf_cli-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_cgrplib_found-grp.
                    assign
                        temp_cgrplib_found-grp.full-name = v-full-name + chr(47)
                        temp_cgrplib_found-grp.sort-name = v-sort-name
                        temp_cgrplib_found-grp.node-code = v-upper-code
                        temp_cgrplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_cli-grp no-lock
               where buf_cli-grp.upper-code = v-upper-code
                 and buf_cli-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_cgrplib_found-grp.
                assign
                    temp_cgrplib_found-grp.full-name = v-full-name
                                                        + ( if v-full-name = "" then "" else chr(47) )
                                                        + buf_cli-grp.node-name + chr(47)
                    temp_cgrplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_cli-grp.node-name
                    temp_cgrplib_found-grp.node-code = buf_cli-grp.node-code
                    temp_cgrplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_cgrplib_found-grp
                :
                    delete temp_cgrplib_found-grp.
                end.
                return error "cgrplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure cgrplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define variable v-d-pcnt            as decimal       no-undo.
    define buffer buf_cli-grp           for ub.cli-grp.
    create temp_cfound-result-nodelist.
    assign
        temp_cfound-result-nodelist.node-code = p-start-node-code
        temp_cfound-result-nodelist.processed = no
    .
    run cli-grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run cli-grplib-get-sort-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_cfound-result-nodelist
             where temp_cfound-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_cfound-result-nodelist.processed = yes
        .
        for each buf_cli-grp no-lock
           where buf_cli-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run cgrplib-is-terminal in this-procedure (
                  input buf_cli-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_cgrplib_found-grp.
                assign
                    temp_cgrplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_cli-grp.node-name + chr(47)
                    temp_cgrplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_cli-grp.node-name + chr(2)
                    temp_cgrplib_found-grp.node-code   = buf_cli-grp.node-code
                    temp_cgrplib_found-grp.is-terminal = yes
                .
               run cgrplib-get-pcnt-value in this-procedure ( input temp_cgrplib_found-grp.node-code , output v-d-pcnt) no-error .
               if not error-status:error then do:
                 temp_cgrplib_found-grp.d-pcnt = v-d-pcnt.
               end.
               else do:
                 temp_cgrplib_found-grp.d-pcnt = ?.
               end.
            end.
            else do:
                create temp_cfound-result-nodelist.
                assign
                    temp_cfound-result-nodelist.node-code = buf_cli-grp.node-code
                    temp_cfound-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_cli-grp.node-name + chr(47)
                    temp_cfound-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_cli-grp.node-name + chr(2)
                    temp_cfound-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_cgrplib_found-grp.
                    assign
                        temp_cgrplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_cli-grp.node-name + chr(47)
                        temp_cgrplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_cli-grp.node-name + chr(2)
                        temp_cgrplib_found-grp.node-code   = buf_cli-grp.node-code
                        temp_cgrplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_cfound-result-nodelist
             where temp_cfound-result-nodelist.processed = no
        no-error.
        if not available temp_cfound-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_cfound-result-nodelist.node-code
                v-start-full-name = temp_cfound-result-nodelist.full-name
                v-start-sort-name = temp_cfound-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure cgrplib-expand-name :
do
on error undo, return error
:
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_cgrplib_found-grp     for temp_cgrplib_found-grp.
    run cgrplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
    ) no-error.
    run cgrplib-get-max-substring in this-procedure (
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
        find first temp_cgrplib_found-grp
            where temp_cgrplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_cgrplib_found-grp
        then do:
            find first buf_temp_cgrplib_found-grp
                where buf_temp_cgrplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_cgrplib_found-grp ) <> recid( temp_cgrplib_found-grp )
            no-error.
            if not available buf_temp_cgrplib_found-grp
            then do:
                run cgrplib-is-terminal in this-procedure (
                    input temp_cgrplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure cgrplib-get-max-substring :
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
        find first temp_cgrplib_found-grp no-error.
        if not available temp_cgrplib_found-grp
        then do:
            undo, return error "cgrplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_cgrplib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "cgrplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_cgrplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_cgrplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
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
procedure cgrplib-is-terminal :
do
on error undo, return error "Ошибка процедуры cgrplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    find first buf_cli-grp no-lock
        where buf_cli-grp.upper-code = p-node-code
    no-error .
    if not available buf_cli-grp
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
procedure cgrplib-have-clients :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-clients   as logical      no-undo.
    define buffer buf_clients         for ub.clients.
    find first buf_clients no-lock
         where buf_clients.grp-code = p-node-code
    no-error .
    if available buf_clients
    then do:
        assign
            p-have-clients = yes
        .
    end.
    else do:
        assign
            p-have-clients = no
        .
    end.
end.
end procedure.
procedure cgrplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    search-grp:
    for each buf_cli-grp no-lock
        where buf_cli-grp.node-code > p-start-code
    :
        if index( buf_cli-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_cli-grp.node-code
                v-found      = yes
            .
            run cli-grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "cgrplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
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
procedure cgrplib-analyze-grp-name :
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
        run cli-grplib-get-full-name in this-procedure (
              input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "cgrplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
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
procedure cgrplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run cli-grplib-get-full-name in this-procedure (
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
PROCEDURE cgrplib-get-pcnt-value :
DEFINE INPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
DEFINE output PARAMETER p-pcnt-value AS DECIMAL NO-UNDO.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-grp-rule no-lock where
          buf_dis-grp-rule.classif-type = 'cli-grp':U
      and buf_dis-grp-rule.node-code = p-node-code
      and buf_dis-grp-rule.host-code = 0
      and buf_dis-grp-rule.obj-type = '':U
      and buf_dis-grp-rule.obj-code = 0
      and buf_dis-grp-rule.pos-type = '-':U
      and buf_dis-grp-rule.discnt-role = 'cli-grp-pcnt':U no-error.
if available buf_dis-grp-rule then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-grp-rule.rule-num no-error.
  if available buf_dis-rule then do:
    assign
    p-pcnt-value        = buf_dis-rule.discnt-value.
    .
  end.
end.
END PROCEDURE.
define variable v-root-code    as integer no-undo .
define variable v-is-terminal  as logical no-undo.
define variable v-have-clients as logical no-undo .
define buffer      buf_cli-grp for ub.cli-grp .
define buffer     buf2_cli-grp for ub.cli-grp .
define buffer buf_same_cli-grp for ub.cli-grp .
    run cgrplib-get-root-code in this-procedure ( output v-root-code ) no-error .
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Не найден корневой узел",
                   vss-workfile, vss-revision, vss-description, chr(10))
      ) .
    end.
    if p-node-code = v-root-code then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о группе клиентов с кодом [&5] корневая. Нельзя удалить корневую группу",
                   vss-workfile, vss-revision, vss-description, chr(10),
                   p-node-code )
      ) .
    end.
    find first buf_cli-grp exclusive-lock where buf_cli-grp.node-code = p-node-code no-error no-wait .
    if locked(buf_cli-grp) then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о группе клиентов с кодом [&5] занята другим пользователем",
                   vss-workfile, vss-revision, vss-description, chr(10),
                   p-node-code )
      ) .
    end .
    if not available buf_cli-grp then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4Запись о группе клиентов с кодом [&5] отсутствует",
                   vss-workfile, vss-revision, vss-description, chr(10),
                   p-node-code )
      ) .
    end .
    if buf_cli-grp.upper-code = v-root-code then do:
      if can-find (buf2_cli-grp where buf2_cli-grp.upper-code = v-root-code) then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4группа клиентов с кодом [&5] является единственной группой первого уровня.&4Нельзя удалить последнюю группу первого уровня.",
                   vss-workfile, vss-revision, vss-description, chr(10),
                   p-node-code )
        ) .
      end .
    end .
    run cgrplib-is-terminal in this-procedure ( input p-node-code , output v-is-terminal ) no-error .
    if error-status :error then do:
      undo, throw new Progress.Lang.AppError(
        substitute("&1 &2 &3&4&6&4Ошибка определения типа группы (терм/корн) для группы [&5]",
                   vss-workfile, vss-revision, vss-description, chr(10),
                   p-node-code, return-value)
      ) .
    end .
    if v-is-terminal then do:
      run cgrplib-have-clients in this-procedure ( input p-node-code, output v-have-clients ) no-error .
      if error-status :error then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Ошибка определения наличия клиентов в группе [&5]",
                     vss-workfile, vss-revision, vss-description, chr(10),
                     p-node-code )
        ) .
      end.
      if v-have-clients then do:
        if can-find (first buf2_cli-grp
                     where buf2_cli-grp.upper-code = buf_cli-grp.upper-code
                       and buf2_cli-grp.node-code <> p-node-code) then do:
          undo, throw new Progress.Lang.AppError(
            substitute("&1 &2 &3&4Группа [&5] является терминальной и содержит клиентов." +
                       "&4После удаления клиенты группы [&5] будут перенесены на уровень выше, в группу [&6]." +
                       "&4Удаление не допустимо, т.к. группа [&6] содержит другие группы." +
                       "&4В одной группе не могут быть одновременно подгруппы и клиенты." +
                       "&4Группа [&5] не может быть слита с вышестоящей группой [&6].",
                       vss-workfile, vss-revision, vss-description, chr(10),
                       p-node-code, buf_cli-grp.upper-code )
          ) .
        end.
      end.
    end .
    else do:
      for each buf2_cli-grp no-lock
         where buf2_cli-grp.upper-code = buf_cli-grp.upper-code
           and buf2_cli-grp.node-code <> p-node-code :
        find first buf_same_cli-grp no-lock
             where buf_same_cli-grp.upper-code = p-node-code
               and buf_same_cli-grp.node-name  = buf2_cli-grp.node-name no-error .
        if available buf_same_cli-grp then do:
          undo, throw new Progress.Lang.AppError(
            substitute("&1 &2 &3&4Подгруппа [&6] группв [&5] имеет название такое же, как соседняя с удаляемой группой группа [&7]." +
                       "&4После удаления две группы на одном уровне будут иметь одинаковые названия [&8], что запрещено.",
                       vss-workfile, vss-revision, vss-description, chr(10),
                       p-node-code, buf_same_cli-grp.node-code, buf2_cli-grp.node-code, buf2_cli-grp.node-name )
          ) .
        end .
      end .
    end .
    delete buf_cli-grp .
