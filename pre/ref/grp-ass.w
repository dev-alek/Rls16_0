DEFINE BUFFER buf_goods FOR goods.
DEFINE BUFFER buf_Matrix-goods FOR assortment-matrix-goods.
define input parameter parparentproc        as handle           no-undo.
define input parameter p-db-num             as integer   no-undo .
define input parameter p-id                 as integer   no-undo .
define input parameter p-button-list        as character        no-undo.
define input parameter p-current-obj-type   as character        no-undo.
define input parameter p-current-obj-code   as integer          no-undo.
define input-output parameter p-recid-list  as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление деревом групп".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info0 as character format "X(65)" no-undo
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
define variable vss-include-info1 as character format "X(65)" no-undo
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
define new global shared variable g#lib-Matrix  as handle no-undo .
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-attr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-label = "Набор"     p-type = 'L':U      p-format = "yes/no"     p-label = "Набор"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-tooltip = "Набор - не товарные позиции"     p-label = "Набор" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут группы товаров на фирме" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure grp-attr-value :
do
on error undo, return error
:
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define input  parameter p-host-code   as integer    no-undo.
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_gds-grp-attr for ub.gds-grp-attr.
    run grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-code
           and buf_gds-grp-attr.host-code = p-host-code
           and buf_gds-grp-attr.obj-type  = p-obj-type
           and buf_gds-grp-attr.obj-code  = p-obj-code
    no-error .
    if available buf_gds-grp-attr
    then do:
        assign
            p-value = buf_gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
    end.
end.
end procedure.
procedure grp-attr-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-value      like ub.gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    run grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        create buf_gds-grp-attr.
        assign
                buf_gds-grp-attr.node-code  = p-node-code
                buf_gds-grp-attr.attr-code  = p-code
                buf_gds-grp-attr.host-code  = p-host-code
                buf_gds-grp-attr.obj-type   = p-obj-type
                buf_gds-grp-attr.obj-code   = p-obj-code
                buf_gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure grp-attr-delete :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.gds-grp-attr.attr-code  no-undo.
define input parameter p-host-code  as integer                      no-undo.
define input parameter p-obj-type   like ub.clients.obj-type        no-undo.
define input parameter p-obj-code   like ub.clients.obj-code        no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_gds-grp-attr for ub.gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_gds-grp-attr exclusive-lock
         where buf_gds-grp-attr.node-code  = p-node-code
           and buf_gds-grp-attr.attr-code  = p-code
           and buf_gds-grp-attr.host-code  = p-host-code
           and buf_gds-grp-attr.obj-type   = p-obj-type
           and buf_gds-grp-attr.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'gds-grp-nabor':U then do:     assign     p-news = true.   end.
      otherwise do:
        undo, return error "неизвестный атрибут товара на фирме" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure grp-attr-obj-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-attr-code as character    no-undo .
define output parameter p-attr-value     as character   no-undo.
define output parameter p-range     as integer      no-undo.
define output parameter p-exists    as logical      no-undo.
define variable v-host-code as integer      no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-attr      for ub.gds-grp-attr.
find first buf_gds-grp-attr no-lock
     where buf_gds-grp-attr.node-code = p-node-code
       and buf_gds-grp-attr.attr-code = p-attr-code
       and buf_gds-grp-attr.host-code = v-host-code
       and buf_gds-grp-attr.obj-type  = p-obj-type
       and buf_gds-grp-attr.obj-code  = p-obj-code
no-error .
if not available buf_gds-grp-attr
then do:
    find first buf_gds-grp-attr no-lock
         where buf_gds-grp-attr.node-code = p-node-code
           and buf_gds-grp-attr.attr-code = p-attr-code
           and buf_gds-grp-attr.host-code = v-host-code
           and buf_gds-grp-attr.obj-type  = ""
           and buf_gds-grp-attr.obj-code  = 0
    no-error .
    if not available buf_gds-grp-attr
    then do:
        find first buf_gds-grp-attr no-lock
            where buf_gds-grp-attr.node-code = p-node-code
            and buf_gds-grp-attr.attr-code = p-attr-code
            and buf_gds-grp-attr.host-code = 0
            and buf_gds-grp-attr.obj-type  = ""
            and buf_gds-grp-attr.obj-code  = 0
        no-error .
        if not available buf_gds-grp-attr
        then do:
            assign
                p-exists = no
            .
        end.
        else do:
            assign
                p-exists = yes
                p-range  = 1
            .
        end.
    end.
    else do:
        assign
            p-exists = yes
            p-range  = 2
        .
    end.
end.
else do:
    assign
        p-exists = yes
        p-range  = 3
    .
end.
if available buf_gds-grp-attr
then do:
  assign
  p-attr-value = buf_gds-grp-attr.attr-value
  .
end.
end.
end procedure.
procedure ver-gds-grp-nabor :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define output parameter p-nabor as logical   no-undo .
define buffer buf_goods for ub.goods.
p-nabor = false .
find first  buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error .
define variable v-value       as character  no-undo.
define variable v-type        as character  no-undo.
  run grp-attr-value (
     input   buf_goods.grp-code
    ,input   'gds-grp-nabor':U
    ,input   0
    ,input   ""
    ,input   0
    ,output  v-value
    ,output  v-type       ) no-error .
    if error-status :error then return error .
  if v-value = "yes" then p-nabor = true  .
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure correct-message :
define input  parameter p-longchar as longchar no-undo .
define variable v-longchar as longchar no-undo .
define variable v-err-ext  as logical  no-undo .
  do
  on error undo, return error return-value
  :
   run get-long-message in this-procedure  (output v-longchar ).
    v-longchar = v-longchar + p-longchar.
    v-err-ext  = true .
    run set-long-message  in this-procedure  (input v-longchar,  input v-err-ext ).
  end.
end procedure.
define variable v-longchar as longchar no-undo .
define variable v-err-ext as logical   no-undo .
procedure get-long-message  :
define output parameter p-longchar  as longchar no-undo .
  do
  on error undo, return error return-value
  :
     p-longchar = v-longchar .
  end.
end procedure.
procedure set-long-message :
define input  parameter  p-longchar as longchar   no-undo .
define input  parameter  p-err-ext as logical   no-undo .
  do
  on error undo, return error return-value
  :
    v-longchar  =  p-longchar .
    v-err-ext   =  p-err-ext  .
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure assmatat-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-value :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-value in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-write :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define input parameter p-value     like ub.assortment-matrix-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-write in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-exist :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code      like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-exist in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-delete :
  define input  parameter p-asmt-id     like ub.assortment-matrix-attr.asmt-id     no-undo .
  define input  parameter p-db-num     like ub.assortment-matrix-attr.db-num     no-undo .
  define input  parameter p-code     like ub.assortment-matrix-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-delete in g#attr-lib
      (input  p-asmt-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure assmatat-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run assmatat-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE vss-include-info19 AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
FUNCTION indicator-life-gds-n RETURNS CHARACTER ( input p-rec as recid ) FORWARD.
DEFINE VARIABLE v-gl-iProc-Otkl AS DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-lAM-Is-Obj         AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE v-gl-iAM-Gds-All        AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-iAM-Sbl-Gds-All    AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-iAM-Gds-Vyv        AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-lAM-Ref-Shablon    AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE v-gl-dAM-Proc-Otkl      AS DECIMAL NO-UNDO INITIAL 0.
DEFINE VARIABLE v-gl-dAM-Proc-Otkl-Ras  AS DECIMAL NO-UNDO INITIAL 0.
FUNCTION Is-Gds-In-AssMatr RETURN LOGICAL(
   p-Gds-code AS INTEGER,
   p-Asmt-id  AS INTEGER,
   p-Db-num   AS INTEGER):
   DEFINE BUFFER buf_Gds FOR Ub.Assortment-matrix-goods.
   RETURN CAN-FIND(FIRST buf_Gds WHERE
                         buf_Gds.Asmt-id     = p-Asmt-id
                     AND buf_Gds.Db-num      = p-Db-num
                     AND buf_Gds.Gds-code    = p-Gds-code
                     AND buf_Gds.Asmg-status = INTEGER('0':U)
                   NO-LOCK).
END FUNCTION.
PROCEDURE Get-Delta-Gds-2-Matrix:
   DEFINE PARAMETER BUFFER buf_AM-1 FOR ub.Assortment-matrix.
   DEFINE PARAMETER BUFFER buf_AM-2 FOR ub.Assortment-matrix.
   DEFINE OUTPUT PARAMETER iDelta AS INTEGER NO-UNDO INITIAL 0.
   DEFINE BUFFER buf_Gds-1 FOR ub.Assortment-matrix-goods.
   DEFINE BUFFER buf_Gds-2 FOR ub.Assortment-matrix-goods.
   FOR EACH buf_Gds-1 WHERE
            buf_Gds-1.Asmt-id = buf_AM-1.Asmt-id
        AND buf_Gds-1.Db-num  = buf_AM-1.Db-num
        AND buf_Gds-1.Asmg-status = INTEGER('0':U)
       NO-LOCK:
       IF NOT CAN-FIND(FIRST buf_Gds-2 WHERE
                             buf_Gds-2.Asmt-id     = buf_AM-2.Asmt-id
                         AND buf_Gds-2.Db-num      = buf_AM-2.Db-num
                         AND buf_Gds-2.Gds-code    = buf_Gds-1.Gds-code
                         AND buf_Gds-2.Asmg-status = INTEGER('0':U)
                         NO-LOCK) THEN DO:
          ASSIGN
             iDelta = iDelta + 1.
       END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Cntrl-AM-Add-1:
   DEFINE INPUT PARAMETER iDelta  AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER cError AS CHARACTER NO-UNDO INITIAL "".
   IF v-gl-iProc-Otkl = 0      THEN RETURN.
   IF NOT v-gl-lAM-Is-Obj      THEN RETURN.
   IF NOT v-gl-lAM-Ref-Shablon THEN RETURN.
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(iDelta).
   IF iDelta = 0 THEN DO:
      IF v-gl-dAM-Proc-Otkl >= v-gl-iProc-Otkl THEN DO:
         cError = "В данной матрице процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl) + ")" + chr(10) +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl) +  ")." + chr(10) +
                  "Добавление товаров невозможно !".
      END.
   END. ELSE DO:
      IF v-gl-dAM-Proc-Otkl-Ras >= v-gl-iProc-Otkl THEN DO:
         cError = "В данной матрице будущий расчетный процент отклонения товаров от шаблона (=" + STRING(v-gl-dAM-Proc-Otkl-Ras) + ")" + chr(10) +
                  " больше допустимого (=" + STRING( v-gl-iProc-Otkl ) +  ")." + chr(10) +
                  " Добавление товаров невозможно !".
      END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Param-Proc-Otkl:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE OUTPUT PARAMETER  cError    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      cError = PROGRAM-NAME(1) +  ":Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   RUN Get-Gl-Set-Proc-Otkl IN THIS-PROCEDURE(
       buf_AM.obj-type,
       buf_AM.obj-code
       ).
   RUN Get-Gl-Param-AM-All in THIS-PROCEDURE(
       buf_AM.Asmt-id,
       buf_AM.db-num
       ).
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Param-AM-All:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE VARIABLE lIsAmObj    AS LOGICAL    NO-UNDO INITIAL FALSE.
   DEFINE VARIABLE iSh-Asmt-id AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE iSh-Db-num  AS INTEGER    NO-UNDO INITIAL 0.
   DEFINE VARIABLE cSh-Type    AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE cError      AS CHARACTER  NO-UNDO INITIAL "".
   DEFINE VARIABLE dAmt        AS DECIMAL    EXTENT 2  NO-UNDO INITIAL 0.
   DEFINE VARIABLE cMode       AS CHARACTER  NO-UNDO INITIAL "".
   ASSIGN
      v-gl-iAM-Gds-All     = 0
      v-gl-iAM-Sbl-Gds-All = 0
      v-gl-iAM-Gds-Vyv     = 0
      v-gl-dAM-Proc-Otkl   = 0
      v-gl-lAM-Ref-Shablon = FALSE
      .
   RUN Get-Param-AM IN THIS-PROCEDURE (
       p-Asmt-id,
       p-Db-num,
       OUTPUT lIsAmObj,
       OUTPUT iSh-Asmt-id,
       OUTPUT iSh-Db-num,
       OUTPUT cSh-Type,
       OUTPUT cError
       ).
   IF cError <> "" THEN DO:
      MESSAGE
         PROGRAM-NAME(1) ":" SKIP
         "Такого быть не должно !!!" SKIP
         cError SKIP
         VIEW-AS ALERT-BOX INFO BUTTONS OK.
      RETURN.
   END.
   ASSIGN
      cMode                 = (IF lIsAmObj THEN "IL_GDS":U ELSE "")
      v-gl-lAM-Ref-Shablon  = (IF iSh-Asmt-id = 0 THEN FALSE ELSE TRUE)
      .
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       p-Asmt-Id,
       p-Db-num,
       '0':U,
       cMode,
       OUTPUT dAmt
       ).
   ASSIGN
      v-gl-iAM-Gds-All = dAmt[1]
      v-gl-iAM-Gds-Vyv = (IF lIsAmObj THEN dAmt[2] ELSE 0)
      .
    IF NOT v-gl-lAM-Ref-Shablon THEN DO:
       RETURN.
    END.
   RUN Get-Param-AM-Gds IN THIS-PROCEDURE(
       iSh-Asmt-id,
       iSh-Db-num,
       '0':U,
       "",
       OUTPUT dAmt
       ).
   ASSIGN
      v-gl-iAM-Sbl-Gds-All = dAmt[1].
   RUN Calc-Proc-Otkl IN THIS-PROCEDURE(0).
   RETURN.
END PROCEDURE.
PROCEDURE Get-Param-AM-Gds:
   DEFINE INPUT PARAMETER   p-Asmt-Id AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Db-num  AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Stat    AS INTEGER    NO-UNDO.
   DEFINE INPUT PARAMETER   p-Mode    AS CHARACTER  NO-UNDO.
   DEFINE OUTPUT PARAMETER  o-dAmt    AS DECIMAL    EXTENT 2 NO-UNDO INITIAL 0.
   DEFINE BUFFER buf_AM-goods FOR ub.Assortment-matrix-goods.
   FOR EACH buf_AM-goods WHERE
            buf_AM-goods.Asmt-id      = p-Asmt-Id
        AND buf_AM-goods.Db-num       = p-Db-num
        AND buf_AM-goods.asmg-status  = p-Stat
       NO-LOCK:
       ASSIGN
          o-dAmt[1] = o-dAmt[1] + 1.
       IF CAN-DO("IL_GDS":U, p-Mode) THEN DO:
          IF Indicator-life-gds-n(recid(buf_AM-goods)) = 'На вывод из ассортимента':U THEN DO:
             ASSIGN
                o-dAmt[2] = o-dAmt[2] + 1.
          END.
       END.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Param-AM:
   DEFINE INPUT  PARAMETER  p-Asmt-id   AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER  p-Db-num    AS INTEGER   NO-UNDO.
   DEFINE OUTPUT PARAMETER  lIsObj      AS LOGICAL   NO-UNDO INITIAL FALSE.
   DEFINE OUTPUT PARAMETER  o-Asmt-id   AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  o-Db-Num    AS INTEGER   NO-UNDO INITIAL 0.
   DEFINE OUTPUT PARAMETER  v-Type      AS CHARACTER NO-UNDO INITIAL "".
   DEFINE OUTPUT PARAMETER  cError      AS CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-value AS  CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_AM   FOR ub.Assortment-Matrix.
   DEFINE BUFFER buf_AM-2 FOR ub.Assortment-Matrix.
   ASSIGN
      v-gl-lAM-Is-Obj = FALSE.
   FIND FIRST buf_AM WHERE
              buf_AM.asmt-id = p-Asmt-id
          AND buf_AM.db-num  = p-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM THEN DO:
      cError = "Не найдена АМ id=" + STRING(p-Asmt-id) + " db-num=" + STRING(p-Db-num).
      RETURN.
   END.
   IF buf_AM.asmt-type <> 'Объект':U THEN DO:
      RETURN.
   END. ELSE DO:
      ASSIGN
         lIsObj           = TRUE
         v-gl-lAM-Is-Obj  = TRUE
         .
   END.
   run assmatat-value (
       input buf_AM.asmt-id
      ,input buf_AM.db-num
      ,input 'RootShablon':U
      ,output v-value
      ,output v-type
      ) .
   IF v-value = "" OR v-value = ? THEN DO:
      RETURN.
   END.
   ASSIGN
      o-Asmt-id = INTEGER(ENTRY(1, v-value, chr(4)))
      o-Db-num  = INTEGER(ENTRY(2, v-value, chr(4)))
      NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      cError = PROGRAM-NAME(1) + ":" + ERROR-STATUS:GET-MESSAGE(1).
      RETURN.
   END.
   FIND FIRST buf_AM-2 WHERE
              buf_AM-2.asmt-id = o-Asmt-id
          AND buf_AM-2.db-num  = o-Db-num
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_AM-2 THEN DO:
      cError = "Не найден шаблон АМ id=" + STRING(o-Asmt-id) + " db-num=" + STRING(o-Db-num).
      RETURN.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Get-Gl-Set-Proc-Otkl:
   DEFINE INPUT PARAMETER  cObj-type AS CHARACTER NO-UNDO.
   DEFINE INPUT PARAMETER  iObj-code AS INTEGER   NO-UNDO.
   DEFINE VARIABLE v-Character   AS CHARACTER  NO-UNDO .
   DEFINE VARIABLE v-Date        AS DATE       NO-UNDO .
   DEFINE VARIABLE v-Decimal     AS DECIMAL    NO-UNDO .
   DEFINE VARIABLE v-Integer     AS INTEGER    NO-UNDO .
   DEFINE VARIABLE v-Logical     AS LOGICAL    NO-UNDO .
   DEFINE VARIABLE v-Param-Type  AS CHARACTER  NO-UNDO .
   ASSIGN
      v-gl-iProc-Otkl = 0
      .
   EMPTY TEMP-TABLE thbjattr_thbj-attr .
   RUN adm/shattri.p (
           INPUT  "get":U,
           INPUT  cObj-type,
           INPUT  iObj-code,
           INPUT  'Ass-obj':U,
           INPUT  'ass-proc-matr-shabl':U ,
           OUTPUT v-Character,
           OUTPUT v-Date,
           OUTPUT v-Decimal,
           OUTPUT v-Integer,
           OUTPUT v-Logical,
           OUTPUT v-Param-Type,
           INPUT-OUTPUT TABLE thbjattr_thbj-attr
       ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
         v-Integer  = 0
         v-Decimal  = 0.
   END. ELSE DO:
      ASSIGN
         v-gl-iProc-Otkl = v-Integer
         .
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Calc-Proc-Otkl:
   DEFINE INPUT PARAMETER iDeltaGds AS INTEGER NO-UNDO.
   DEFINE VARIABLE iTmp AS INTEGER NO-UNDO INITIAL 0.
   ASSIGN
      v-gl-dAM-Proc-Otkl     = 0
      v-gl-dAM-Proc-Otkl-Ras = 0
      .
   IF NOT v-gl-lAM-Ref-Shablon THEN DO:
      RETURN.
   END.
   IF v-gl-iAM-Sbl-Gds-All = 0 THEN DO:
      ASSIGN
         v-gl-dAM-Proc-Otkl     = 999999
         v-gl-dAM-Proc-Otkl-Ras = 999999
         .
      RETURN.
   END.
   ASSIGN
      iTmp = (v-gl-iAM-Gds-All - v-gl-iAM-Sbl-Gds-All)
      v-gl-dAM-Proc-Otkl     = ROUND(iTmp * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      v-gl-dAM-Proc-Otkl-Ras = ROUND((iTmp + iDeltaGds)  * 100 / v-gl-iAM-Sbl-Gds-All, 2)
      .
   RETURN.
END PROCEDURE.
FUNCTION indicator-life-gds-n RETURNS CHARACTER
( input p-rec as recid ) :
define buffer buf_matrix-goods for ub.assortment-matrix-goods .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-assort-min                  as LOGICAL   NO-UNDO.
DEFINE variable v-indicator-life-gds          as CHARACTER NO-UNDO.
find first buf_matrix-goods no-lock where recid (buf_matrix-goods) = p-rec no-error .
if error-status :error then return '' .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_Matrix-goods.obj-type
  ,input  buf_Matrix-goods.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  return v-indicator-life-gds.
end function.
define temp-table temp_cons no-undo
    field node-code     as integer
    field upper-code    as integer
    field full-name     as character
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
index pi is unique node-code
index uc upper-code
.
define buffer buf_matrix for ub.assortment-matrix .
find first buf_matrix no-lock where
           buf_matrix.asmt-id  = p-id     and
           buf_matrix.db-num   = p-db-num no-error .
if p-button-list <> "buttons-for-move"
then do:
    define new shared temp-table tt-goods no-undo like goods.
    define new shared temp-table tt-clients no-undo like clients.
end.
define variable v-root-code                 as integer          no-undo.
define variable v-found-grp-num             as integer  init 0  no-undo.
define variable v-full-search-string        as character        no-undo.
define variable v-full-search-next          as logical  init no no-undo.
define variable v-full-search-start-code    as integer          no-undo.
define variable v-cli-name                  as character        no-undo.
define variable print-option as character no-undo.
define variable gds-grp-row as integer init 1 no-undo.
define variable v-from-b-gds as logical no-undo .
define variable v-old-recid-list as character no-undo .
define variable v-old-recid as recid no-undo .
define variable v-current-arm-code          as character    no-undo.
define variable v-current-store-type        as character    no-undo.
define variable v-current-store-code        as integer      no-undo.
define variable v-current-host-code         as integer      no-undo.
define variable is-flora     as character no-undo .
define variable par-type     as character no-undo.
define variable v-obj-host-code as integer   no-undo .
define variable p-sts   as integer   no-undo .
define variable p-rid-list                    as character no-undo .
define variable v-gdop-min-stock              as decimal   no-undo .
define variable v-grop-max-stock              as decimal   no-undo .
define variable v-grop-level-always-presence  as decimal   no-undo .
define variable v-grop-min-order              as decimal   no-undo .
define variable v-log as logical   no-undo .
define variable mark-str  as character no-undo.
define variable v-doc-rec as recid no-undo.
define variable filter-point as character no-undo init "Ассортиментная матрица" .
define variable filter-point0 as character no-undo init "Состав_ассортиментной_матрицы" .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable v-type as character no-undo .
define variable p-mark as character no-undo .
define variable p-obj  as character no-undo .
define variable p-time-upd as character no-undo .
define variable p-time-cr  as character no-undo .
define variable p-status as character no-undo .
define variable gds-rec as recid no-undo .
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .
define variable p-name as character no-undo .
v-err-ext = false  .
v-longchar = "" .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
define temp-table tt-gds-list no-undo like goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
define variable varschartic like price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.
define buffer pos_assortment-matrix for ub.assortment-matrix.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-copy
     LABEL "&Копировать из"
     SIZE 14 BY 1 TOOLTIP "Копировать из .... ".
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход"
     BGCOLOR 8 .
DEFINE BUTTON b-expand
     LABEL ">>"
     SIZE 3.5 BY 1.13.
DEFINE BUTTON b-expand-all
     LABEL ">>-->>"
     SIZE 7.5 BY 1.13.
DEFINE BUTTON b-find-by-full-name
     LABEL "+"
     SIZE 3 BY 1 TOOLTIP "Продолжить до полного имени (CTRL-D)"
     BGCOLOR 8 .
DEFINE BUTTON b-find-by-substring
     LABEL "?"
     SIZE 3 BY 1 TOOLTIP "Найти подстроку во всех группах (CTRL-S)"
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 3 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 2.5 BY 1.
DEFINE BUTTON b-recalc
     LABEL "Пе&ресчитать"
     SIZE 13.5 BY 1 TOOLTIP "Пересчитать количество товара по всем уровням"
     BGCOLOR 8 .
DEFINE BUTTON b-search
     LABEL "Поиск"
     SIZE 10 BY 1.04
     BGCOLOR 8 .
DEFINE BUTTON b-verify
     LABEL "Проверить"
     SIZE 13.5 BY 1 TOOLTIP "Проверить ограниечения по уровням групп"
     BGCOLOR 8 .
DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 69.75 BY 1
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-sts AS CHARACTER INITIAL "0"
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Item 1", "0",
"Item 2", "1",
"Item 3", "2"
     SIZE 33.5 BY 1 NO-UNDO.
DEFINE QUERY br-list FOR
      temp_grplib_grp SCROLLING.
DEFINE QUERY BROWSE-am-goods FOR
      buf_Matrix-goods,
      buf_goods SCROLLING.
DEFINE BROWSE br-list
  QUERY br-list DISPLAY
      temp_grplib_grp.name          format "X(63)"       COLUMN-label "Наименование группы! "
      temp_grplib_grp.cli-type                           COLUMN-label "Ограничение!по группе"
      temp_grplib_grp.min-marg                           COLUMN-label "По нижним!уровням"
      temp_grplib_grp.max-marg                           COLUMN-label "Кол-во в группе!без ИЖТ на вывод"
      ENABLE
      temp_grplib_grp.cli-type
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 8.38.
DEFINE BROWSE BROWSE-am-goods
  QUERY BROWSE-am-goods NO-LOCK DISPLAY
      mark-string(recid( buf_Matrix-goods) , p-rid-list) @ p-mark COLUMN-LABEL "*" FORMAT "x(1)":U
      Buf_goods.artic FORMAT "X(16)":U
      STRING ( if Buf_goods.stts <> 0 then substring(Buf_goods.gds-name,1,15) + " <УДАЛЕН>"  else Buf_goods.gds-name ) @ p-name COLUMN-LABEL "Название" FORMAT "X(30)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      STRING (buf_Matrix-goods.asmg-time-update, 'HH:MM' ) FORMAT "x(5)":U
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
       STRING (buf_Matrix-goods.asmg-time-create, 'HH:MM' )  FORMAT "x(5)":U
      v-indicator-life-gds
      v-assort-min COLUMN-LABEL "Acc!Min" FORMAT "*/":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      entry (lookup (STRING(buf_Matrix-goods.asmg-status), '0,1,50,99':U), 'тек,удал,блок,удаление':U) @ p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      Buf_goods.grp-name COLUMN-LABEL "Группа! " FORMAT "x(45)":U
  ENABLE
      Buf_matrix-goods.asmg-db-num-update
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 97 BY 8.25 FIT-LAST-COLUMN.
DEFINE FRAME Dlg-grp
     b-exit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-verify AT ROW 1 COL 66 WIDGET-ID 22
     b-recalc AT ROW 1 COL 79.88 WIDGET-ID 14
     B-print AT ROW 1 COL 94 WIDGET-ID 12
     b-help AT ROW 1 COL 96.5
     b-expand AT ROW 2.08 COL 1.63
     b-expand-all AT ROW 2.08 COL 5.13
     fi-search AT ROW 2.08 COL 13.38 NO-LABEL
     b-find-by-full-name AT ROW 2.08 COL 83.38
     b-find-by-substring AT ROW 2.08 COL 86.38
     b-search AT ROW 2.08 COL 89.38
     br-list AT ROW 3.38 COL 1.88
     B-add AT ROW 12.5 COL 2 WIDGET-ID 2
     B-lookup AT ROW 12.5 COL 12 WIDGET-ID 10
     B-chg AT ROW 12.5 COL 22 WIDGET-ID 4
     B-del AT ROW 12.5 COL 32 WIDGET-ID 8
     B-copy AT ROW 12.5 COL 42.13 WIDGET-ID 6
     RS-sts AT ROW 12.5 COL 65.5 NO-LABEL WIDGET-ID 18
     BROWSE-am-goods AT ROW 13.58 COL 2 WIDGET-ID 100
     FILL-IN-1 AT ROW 12.5 COL 57.5 NO-LABEL WIDGET-ID 16
     SPACE(35.00) SKIP(8.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ассортиментная Матрица по группам товаров".
ASSIGN
       FRAME Dlg-grp:SCROLLABLE       = FALSE
       FRAME Dlg-grp:HIDDEN           = TRUE.
ON ENDKEY OF FRAME Dlg-grp
DO:
    run gbl/markqwa.p (
                           input b-mark:visible
                          , input p-recid-list) no-error.
    if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dlg-grp
DO:
  apply "end-error":U to self.
END.
ON CHOOSE OF B-add IN FRAME Dlg-grp
DO:
  define variable loc#log as logical no-undo.
  define variable loc-doc-rec as recid no-undo .
if  buf_matrix.asmt-status = 1  then do:
    message "Добавлять можно  в  АССОРТИМЕНТНУЮ МАТРИЦУ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
  run save-attr in this-procedure .
  run proc-add in this-procedure (output loc-doc-rec ) no-error  .
  if error-status :error then DO:
     message
  error-status :get-message(1)
  return-value
  view-as alert-box error
  .
     RETURN NO-APPLY.
  END.
  if loc-doc-rec <> ? THEN DO:
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
  END.
  run recalc-add.
  run recalc-marg-ass.
  apply "entry" to BROWSE-am-goods in frame Dlg-grp.
  apply "value-changed" to BROWSE-am-goods in frame Dlg-grp.
END.
ON CHOOSE OF B-chg IN FRAME Dlg-grp
DO:
   define variable loc#log as logical no-undo.
   define variable loc-doc-rec as recid no-undo .
if not available Buf_matrix-goods then return no-apply.
if  Buf_matrix-goods.asmg-status = 1  then do:
    message "Корректировать можно только запись в статусе  ТЕК."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
assign
loc-doc-rec = recid(Buf_matrix-goods).
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
   run ref/gds-mati.w
    (  input parParentProc
      ,input 'ИЗМЕНЕНИЕ':U
      ,input Buf_matrix-goods.asmt-id
      ,input Buf_matrix-goods.db-num
      ,input-output loc-doc-rec
    ) no-error
   .
   if loc-doc-rec <> ? THEN DO:
       OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
       reposition BROWSE-am-goods to recid loc-doc-rec no-error.
       if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
   END.
   apply "entry" to BROWSE-am-goods in frame Dlg-grp.
   apply "value-changed" to BROWSE-am-goods in frame Dlg-grp.
END.
ON CHOOSE OF B-copy IN FRAME Dlg-grp
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if  buf_matrix.asmt-status = 1  then do:
    message "Добавлять можно в АССОРТИМЕНТНУЮ МАТРИЦУ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_add-def':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
 run save-alla in this-procedure  .
  do transaction :
    run proc-copy in this-procedure (output loc-doc-rec ) no-error  .
     if error-status :error then DO:
        message
    error-status :get-message(1)
    return-value .
        RETURN NO-APPLY.
     END.
   end.
  OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
  if loc-doc-rec <> ? THEN DO:
       OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
  END.
  apply "entry" to BROWSE-am-goods in frame Dlg-grp.
  apply "value-changed" to BROWSE-am-goods in frame Dlg-grp.
END.
ON CHOOSE OF B-del IN FRAME Dlg-grp
DO:
run save-attr in this-procedure .
define variable is-many as logical   no-undo .
is-many = false .
if  buf_matrix.asmt-status = 1  then do:
    message "Корректировать и удалять можно  в  АССОРТИМЕНТНОЙ МАТРИЦЕ в статусе тек."
    view-as alert-box information .
    return no-apply.
end.
run ver-db no-error .
if error-status :error then return no-apply .
if num-entries(p-rid-list) > 0 then do:
   message "Удалять выделенные записи ?"
   view-as alert-box question
   Buttons yes-no update v-logq as log.
   if v-logq = false then return .
   is-many = true .
end.
  run proc-b-del in this-procedure ( p-rid-list , is-many ) no-error.
  if error-status:error then return no-apply.
  run recalc-add.
  run recalc-marg-ass.
END.
ON CHOOSE OF b-exit IN FRAME Dlg-grp
DO:
define variable  v-str as character no-undo .
define variable v-i as integer   no-undo .
for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if available temp_cons then do:
        if temp_cons.max-marg <>  temp_grplib_grp.max-marg then do:
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
        end.
        end.
end.
v-str = "".
v-i =0.
for each temp_cons where int(temp_cons.cli-type) < int(temp_cons.min-marg)
 and int(temp_cons.cli-type) <> ?
 and temp_cons.cli-type <> ""
 and int(temp_cons.min-marg) <> ?
:
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + ", должно быть >= " + temp_cons.min-marg + "." + chr(10) .
end.
for each temp_cons where int(temp_cons.cli-type) < int(temp_cons.max-marg)
 and int(temp_cons.cli-type) <> ?
 and temp_cons.cli-type <> ""
 and int(temp_cons.max-marg) <> ?
:
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + ", а товара в группе-" + temp_cons.max-marg + "." + chr(10) .
end.
if v-i <> 0 then do:
    message substitute("Внимание ! Ограничения по Матрице  &1 назначены некорректно !!!", buf_matrix.asmt-name ) view-as alert-box error .
    run gbl/notes.w ('ПРОСМОТР':U,input-output v-str) .
    return no-apply .
end.
find first temp_grplib_grp no-error .
    define variable v-gds-grp-recid     as recid             no-undo.
    run get-current-recid in this-procedure (
          input temp_grplib_grp.node-code
        , output v-gds-grp-recid
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
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run gbl/markqwa.p (
            input b-mark:visible
          , input p-recid-list) no-error.
    if error-status:error then return no-apply.
    assign
        gds-grp-row  = v-gds-grp-recid
        p-recid-list = ""
    .
    assign
    v-uf-List_ = (if gds-grp-row = ? then chr(63) else string(gds-grp-row))
    .
    run uf-set in this-procedure(
        input  'gds-grp-p':U
        ,input  g#userid
        ,input v-uf-List_
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
    )  no-error .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
    run save-alla in this-procedure  .
  end.
  apply "WINDOW-CLOSE" TO FRAME Dlg-grp .
END.
ON CHOOSE OF b-expand IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.node-code = v-root-code
    then do:
        run collapse-all-on-first-level in this-procedure no-error .
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
    if temp_grplib_grp.mark <> "»"
    and temp_grplib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure no-error .
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
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF b-expand-all IN FRAME Dlg-grp
DO:
if session :set-wait-state( "compiler" ) then.
    run expand-all-from-current in this-procedure (
        input temp_grplib_grp.node-code
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
if session :set-wait-state( "" ) then.
        undo, return no-apply .
    end.
if session :set-wait-state( "" ) then.
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF b-find-by-full-name IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    run grplib-expand-name in this-procedure (
          input fi-search :screen-value
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
ON CHOOSE OF b-find-by-substring IN FRAME Dlg-grp
DO:
    define variable v-new-name      as character    no-undo.
    define variable v-new-code      as integer      no-undo.
    define variable v-err-message   as character    no-undo.
    if v-full-search-next = no
    then do:
        assign
            v-full-search-string     = fi-search :screen-value
            v-full-search-next       = yes
            v-full-search-start-code = 0
        .
    end.
    run grplib-analyze-grp-name in this-procedure (
          input v-full-search-string
        , input -1
        , output v-err-message
    ).
    if v-err-message = "":U
    then do:
if session :set-wait-state( "compiler" ) then.
        run grplib-find-by-substring in this-procedure (
            input v-full-search-start-code
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
    end.
    else do:
        message
            v-err-message
            skip(1)
            "Поиск в названиях групп производится по подстроке,"
            skip "введённой в поле названия группы."
        view-as alert-box information.
    end.
END.
ON LEAVE OF b-find-by-substring IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF B-lookup IN FRAME Dlg-grp
DO:
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available Buf_matrix-goods then return no-apply.
assign
loc-doc-rec = recid(Buf_matrix-goods).
   run ref/gds-mati.w
    (  input parParentProc
      ,input 'ПРОСМОТР':U
      ,input Buf_matrix-goods.asmt-id
      ,input Buf_matrix-goods.db-num
      ,input-output loc-doc-rec
      ) no-error   .
   apply "entry" to BROWSE-am-goods in frame Dlg-grp.
END.
ON CHOOSE OF b-mark IN FRAME Dlg-grp
DO:
END.
ON CHOOSE OF B-print IN FRAME Dlg-grp
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
END.
ON CHOOSE OF b-recalc IN FRAME Dlg-grp
DO:
define VARIABLE v-old-grp as integer   no-undo .
define VARIABLE v-new-grp as integer   no-undo .
define VARIABLE v-ok1      as logical    no-undo .
message "Запустить утилиту пересчета ассортимента по каждой группе ? Это займет время."
 view-as alert-box question
       BUTTONS yes-no
      update v-ok as logical.
  if not v-ok then return .
   run utl/uassmgrp.p ( v-old-grp, v-new-grp, p-id , p-db-num, output v-ok1 ) no-error.
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
run recalc-marg-ass.
END.
ON CHOOSE OF b-search IN FRAME Dlg-grp
DO:
    define variable v-found    as logical      no-undo.
    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
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
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
    end.
END.
ON LEAVE OF b-search IN FRAME Dlg-grp
DO:
    assign
        v-found-grp-num  = 0
        b-search :label = "Поиск"
    .
END.
ON CHOOSE OF b-verify IN FRAME Dlg-grp
DO:
message "Запутить утилиту проверки проставленных ограничений по всем уровням ? "
 view-as alert-box question
       BUTTONS yes-no
      update v-ok as logical.
  if not v-ok then return .
define variable v-str as character no-undo .
define variable v-i as integer   no-undo .
v-str = "" .
v-i   = 0  .
for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if not available temp_cons then create temp_cons.
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
end.
  for each temp_cons where
          int(temp_cons.cli-type) < int(temp_cons.min-marg)
      and int(temp_cons.cli-type) <> ?
      and temp_cons.cli-type <> ""
      and int(temp_cons.min-marg) <> ?
      :
        v-i = v-i + 1.
        v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + " должно быть >= " + temp_cons.min-marg + chr(10) .
  end.
for each temp_cons where
        int(temp_cons.cli-type) < int(temp_cons.max-marg)
    and int(temp_cons.cli-type) <> ?
    and temp_cons.cli-type <> ""
    and int(temp_cons.max-marg) <> ?
    :
  v-i = v-i + 1.
  v-str = v-str + trim(temp_cons.full-name) + ": ограничение-" + temp_cons.cli-type + ", а товара в группе - " + temp_cons.max-marg + "." + chr(10) .
end.
   if v-i > 0 then
   run gbl/notes.w ('ПРОСМОТР':U,input-output v-str) .
   else message "Все ОК!" view-as alert-box information .
END.
ON + OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = "»"
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
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
on leave of temp_grplib_grp.cli-type in browse br-list do :
  define variable i as integer   no-undo .
  i = int (int (temp_grplib_grp.cli-type:screen-value in browse br-list ))  no-error .
  if error-status :error then return no-apply .
  if i < 0 then return no-apply .
  if i = 0 and lookup(temp_grplib_grp.cli-type:screen-value in browse br-list , "+,-,*" ) > 0 then return no-apply .
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-grp_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then do:
    temp_grplib_grp.cli-type:read-only in browse br-list = true .
    return no-apply .
 end.
   define variable loc#log as logical   no-undo .
    temp_grplib_grp.cli-type = temp_grplib_grp.cli-type:screen-value in browse br-list .
    if temp_grplib_grp.cli-type <> ? and
       temp_grplib_grp.cli-type <> ""  and
       int(temp_grplib_grp.min-marg) <> 0 and
           temp_grplib_grp.min-marg  <> ? and
           temp_grplib_grp.min-marg  <> "" and
       int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg) then do:
         message substitute(" Ограничение должно быть не меньше ограничения по нижним уровням &1" ,temp_grplib_grp.min-marg ) .
         return no-apply.
       end.
      find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
      assign
          temp_cons.cli-type  = temp_grplib_grp.cli-type
          temp_cons.full-name  = temp_grplib_grp.full-name
      .
    loc#log = BR-list:select-focused-row( ) IN FRAME Dlg-grp.
    loc#log = BR-list:refresh() .
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp-obj-attr exclusive-lock where
            buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U and
            buf_gds-grp-obj-attr.obj-type  = string(p-id) and
            buf_gds-grp-obj-attr.obj-code  = p-db-num and
            buf_gds-grp-obj-attr.host-code = 0 and
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
if not available buf_gds-grp-obj-attr then do:
    create buf_gds-grp-obj-attr.
          assign
            buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U
            buf_gds-grp-obj-attr.obj-type  = string(p-id)
            buf_gds-grp-obj-attr.obj-code  = p-db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            .
 end.
 assign
    buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
    .
run recalc-lim.
end.
on return of temp_grplib_grp.cli-type in browse br-list do :
  define variable loc#log as logical   no-undo .
  define variable i as integer   no-undo .
  i = int (int (temp_grplib_grp.cli-type:screen-value in browse br-list))  no-error .
  if error-status :error then return no-apply .
  if i < 0 then return no-apply .
  if i = 0 and lookup(temp_grplib_grp.cli-type:screen-value in browse br-list , "+,-,*" ) > 0 then return no-apply .
    temp_grplib_grp.cli-type = temp_grplib_grp.cli-type:screen-value in browse br-list .
    if temp_grplib_grp.cli-type <> ? and
       temp_grplib_grp.cli-type <> ""  and
       int(temp_grplib_grp.min-marg) <> 0 and
           temp_grplib_grp.min-marg  <> ? and
           temp_grplib_grp.min-marg  <> "" and
       int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg) then do:
         message substitute(" Ограничение должно быть не меньше ограничения по нижним уровням &1" ,temp_grplib_grp.min-marg ) .
         return no-apply.
       end.
      find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
      assign
          temp_cons.cli-type  = temp_grplib_grp.cli-type
          temp_cons.full-name  = temp_grplib_grp.full-name
      .
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp-obj-attr exclusive-lock where
            buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U and
            buf_gds-grp-obj-attr.obj-type  = string(p-id) and
            buf_gds-grp-obj-attr.obj-code  = p-db-num and
            buf_gds-grp-obj-attr.host-code = 0 and
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
if not available buf_gds-grp-obj-attr then do:
    create buf_gds-grp-obj-attr.
          assign
            buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U
            buf_gds-grp-obj-attr.obj-type  = string(p-id)
            buf_gds-grp-obj-attr.obj-code  = p-db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            .
 end.
 assign
    buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
    .
  run recalc-lim.
    loc#log = BR-list:refresh() IN FRAME Dlg-grp.
    loc#log = BR-list:select-next-row( ) .
end.
ON - OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark = "«"
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
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
ON END OF br-list IN FRAME Dlg-grp
DO:
    define variable v-row-amount     as integer           no-undo.
    run get-row-amount in this-procedure ( output v-row-amount ) no-error.
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
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END.
ON HOME OF br-list IN FRAME Dlg-grp
DO:
    reposition br-list to row 1.
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END.
ON MOUSE-SELECT-DBLCLICK OF br-list IN FRAME Dlg-grp
DO:
 if temp_grplib_grp.mark <> "»"
    and temp_grplib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure no-error .
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
OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END.
ON RETURN OF br-list IN FRAME Dlg-grp
DO:
    if temp_grplib_grp.mark <> "»"
    and temp_grplib_grp.mark <> "«"
    then do:
        return no-apply.
    end.
    run expand-or-collapse-item in this-procedure no-error .
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
ON ROW-DISPLAY OF br-list IN FRAME Dlg-grp
DO:
  if int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.min-marg)
      and int(temp_grplib_grp.cli-type) <> ?
      and temp_grplib_grp.cli-type <> ""
      and int(temp_grplib_grp.min-marg) <> ?
  then do:
    temp_grplib_grp.cli-type:bgcolor in browse  br-list = 12  .
  end.
  else do:
    temp_grplib_grp.cli-type:bgcolor in browse  br-list = ? .
  end.
  if int(temp_grplib_grp.cli-type) < int(temp_grplib_grp.max-marg)
      and int(temp_grplib_grp.cli-type) <> ?
      and temp_grplib_grp.cli-type <> ""
      and int(temp_grplib_grp.max-marg) <> ?
  then do:
    temp_grplib_grp.max-marg:bgcolor in browse  br-list = 11  .
  end.
  else do:
    temp_grplib_grp.max-marg:bgcolor in browse  br-list = ? .
  end.
END.
ON VALUE-CHANGED OF br-list IN FRAME Dlg-grp
DO:
   OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    if temp_grplib_grp.level <> 0
    then do:
        assign
            fi-search :screen-value = right-trim( temp_grplib_grp.full-name, chr(47) )
        .
    end.
    if error-status :error
    then do:
    end.
END.
ON ROW-DISPLAY OF BROWSE-am-goods IN FRAME Dlg-grp
DO:
      if available buf_matrix-goods then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
        case v-indicator-life-gds :
            when 'Новинка':U then do:
              v-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 14 .
            end.
            when 'На вывод из ассортимента':U then do:
              v-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 12 .
            end.
            when 'Нештатный':U then do:
              v-indicator-life-gds:bgcolor  in browse BROWSE-am-goods   = 8 .
            end.
        end case.
        if buf_goods.stts <> 0 then p-name:fgcolor  in browse BROWSE-am-goods   = 12 .
    end.
END.
ON CTRL-D OF fi-search IN FRAME Dlg-grp
DO:
    define variable v-new-name as character no-undo.
    run grplib-expand-name in this-procedure (
        input fi-search :screen-value
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
    run grplib-find-by-substring in this-procedure (
                          input v-full-search-start-code
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
    define variable v-found    as logical      no-undo.
    if fi-search :screen-value = ""
    or fi-search :screen-value = ?
    then do:
        return no-apply.
    end.
    run find-grp-in-browse in this-procedure (
          input fi-search :screen-value
        , output v-found
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка поиска группы."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-found = no
    then do:
        message
          skip "Группа не найдена."
        view-as alert-box information.
    end.
    apply "ENTRY" to b-search in frame Dlg-grp.
    return no-apply.
END.
ON VALUE-CHANGED OF RS-sts IN FRAME Dlg-grp
DO:
  assign rs-sts.
  OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dlg-grp:PARENT eq ?
THEN FRAME Dlg-grp:PARENT = ACTIVE-WINDOW.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-list :handle
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
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse BROWSE-am-goods:handle
  ) .
run diasize_init in this-procedure .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dlg-grp anywhere do:
  run init-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-list in frame Dlg-grp.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
Buf_matrix-goods.asmg-db-num-update:read-only in browse BROWSE-am-goods = true .
v-indicator-life-gds:resizable in browse BROWSE-am-goods = true .
p-name:resizable  in browse BROWSE-am-goods = true .
v-indicator-life-gds:width in browse BROWSE-am-goods = 8 .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME Dlg-grp
    = "Текущие&+" + chr(44) +  '0':U + chr(44) +
      "Все&!" + chr(44) + 'все':U + chr(44) +
      "Удаленные&-" + chr(44) + '1':U
.
rs-sts = '0':U .
display RS-sts WITH FRAME Dlg-grp.
enable  RS-sts WITH FRAME Dlg-grp.
run ver-db1 in this-procedure .
run ver-attr in this-procedure .
frame Dlg-grp:TITLE = frame Dlg-grp:TITLE + " " + buf_matrix.asmt-name .
    if p-current-obj-code = 0
    then do:
       assign
       v-current-store-type = v-cntxt-obj-type
       v-current-store-code = v-cntxt-obj-code
       v-current-host-code = v-cntxt-host-code-obj
       .
    end.
    else do:
        assign
            v-current-store-type = p-current-obj-type
            v-current-store-code = p-current-obj-code
        .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-current-store-type
  ,input  v-current-store-code
  ,output v-current-host-code
  )  .
    end.
    run grplib-get-parameters in this-procedure (
          input v-current-store-type
        , input v-current-store-code
    ) no-error.
    if error-status :error
    then do:
        message
            "Ошибка чтения параметров для списка групп товаров."
            skip (1)
            "Для параметров списка будут приняты значения по умолчанию."
        view-as alert-box warning.
    end.
    run UI-on-0 in this-procedure no-error .
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
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    WAIT-FOR GO OF FRAME Dlg-grp.
END.
RUN disable_UI.
PROCEDURE add-grp :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-have-rights       as logical       no-undo.
    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
    run check-rights-for-change-grp in this-procedure (
        input  p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
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
    run grplib-have-goods in this-procedure (
          input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
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
            apply "entry" to br-list in frame Dlg-grp.
            return no-apply.
        end.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "add-grp: Не найдена группа в browse.".
    end.
    if buf_temp_grplib_grp.mark = "»"
    then do:
        run expand-item in this-procedure ( input p-node-code, input no ) no-error.
        if error-status :error
        then do:
            undo, return error "add-grp: Не удается раскрыть группу.".
        end.
    end.
    run ref/g-grp-f.w (
          input parparentproc
        , input v-current-store-type
        , input v-current-store-code
        , input 'ДОБАВЛЕНИЕ':U
        , input p-node-code
        , input-output v-gds-grp-recid
    ) no-error .
    if v-gds-grp-recid = ?
    then do:
        apply "entry" to br-list in frame Dlg-grp.
        return no-apply.
    end.
    find first buf_gds-grp
         where recid ( buf_gds-grp ) =  v-gds-grp-recid
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "add-grp: Ошибка добавления группы.".
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input buf_temp_grplib_grp.level + 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input buf_temp_grplib_grp.full-name
        , input buf_temp_grplib_grp.sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "add-grp: Ошибка добавления строки в список групп.".
    end.
    if buf_temp_grplib_grp.level > 0
    then do:
        assign
            buf_temp_grplib_grp.mark = "«"
            buf_temp_grplib_grp.name = substring( buf_temp_grplib_grp.name, 1, buf_temp_grplib_grp.level * 4 )
                                + "«"
                                + substring( buf_temp_grplib_grp.name, buf_temp_grplib_grp.level * 4 + 2 )
        .
    end.
    OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE bind-to-scales :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
    define variable v-is-terminal   as logical           no-undo.
    run grplib-is-terminal (  input p-node-code
                            , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при определении типа группы (терм/корн)"
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-is-terminal = no
    then do:
        message
            "Требуется выбрать самую подробную группу товаров,"
            skip "в которой НЕТ других групп."
        view-as alert-box information .
        apply "entry" to br-list in frame Dlg-grp.
        return no-apply.
    end.
    run ref/scal-grp.w (
          input parparentproc
        , input 'b-add'
        , input v-current-store-type
        , input v-current-store-code
        , input ('db':U + chr(44) + 'gds-grp':U)
        , input g#db-num
        , input 0
        , input p-node-code
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value.
    end.
end.
END PROCEDURE.
PROCEDURE calc-down-lim :
define input  parameter p-node-code as integer   no-undo .
define output parameter kk as integer   no-undo .
define variable kk2 as integer   no-undo .
define buffer d_temp_grplib_grp for temp_cons  .
define buffer curr_temp_grplib_grp for temp_cons  .
define variable v-is-terminal as logical   no-undo .
  do
  on error undo, return error return-value
  :
    find first curr_temp_grplib_grp where curr_temp_grplib_grp.node-code =  p-node-code no-error .
    kk = 0 .
    for each d_temp_grplib_grp where
             d_temp_grplib_grp.upper-code = p-node-code :
           if not ( d_temp_grplib_grp.cli-type =  ?  or  trim(d_temp_grplib_grp.cli-type) = "" )
           then do:
                  kk = kk +  int(d_temp_grplib_grp.cli-type).
           end.
           else do:
              run grplib-is-terminal in this-procedure (
                  input d_temp_grplib_grp.node-code
                , output v-is-terminal ) .
                if v-is-terminal = true then kk = ? .
                else do:
                   run calc-down-lim (input d_temp_grplib_grp.node-code , output kk2) .
                   kk = kk + kk2.
                end.
           end.
    end.
  end.
END PROCEDURE.
PROCEDURE check-rights-for-change-grp :
do
on error undo, return error
:
define input  parameter p-node-code     as integer      no-undo.
define output parameter p-have-rights   as logical      no-undo.
    define variable v-enable-change-grp as logical       no-undo.
    if g#db-num <> 0
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Операция определена только в ГБД."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        assign
            p-have-rights = no
        .
    end.
    else do:
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_groups-edit':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  p-node-code
    ,input  0
    ,input  no
    ,output p-have-rights
    )  .
end.
    end.
end.
END PROCEDURE.
PROCEDURE collapse-all-on-first-level :
do
on error undo, return error
:
    define buffer buf_gds-grp       for gds-grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    for each buf_temp_grplib_grp no-lock
       where buf_temp_grplib_grp.upper-code = v-root-code
    :
        run collapse-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось закрыть подуровни группы "
                                + chr(10) + "'" + buf_temp_grplib_grp.full-name + "'"
                                + chr(10) + return-value.
        end.
    end.
    OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE collapse-item :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define buffer buf_del_temp_grplib_grp   for temp_grplib_grp.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "collapse-item: Неверно передан код группы. Нет группы с кодом " + string( p-node-code ).
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    for each buf_del_temp_grplib_grp
       where buf_del_temp_grplib_grp.full-name begins buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.full-name <> buf_temp_grplib_grp.full-name
         and buf_del_temp_grplib_grp.level     <> buf_temp_grplib_grp.level
    :
        delete buf_del_temp_grplib_grp.
    end.
    assign
        buf_temp_grplib_grp.mark = "»"
        buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                        , "«"
                                        , "»"
                                        )
    .
    if p-refresh = yes
    then do:
        OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
        reposition br-list to row v-repositioned-row.
        OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    end.
end.
END PROCEDURE.
PROCEDURE create-new-line :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-upper-code     as integer      no-undo.
define input parameter p-level          as integer      no-undo.
define input parameter p-is-terminal    as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-increase-pc    as decimal      no-undo.
define input parameter p-calc-method    as character    no-undo.
define input parameter p-full-name      as character    no-undo.
define input parameter p-sort-name      as character    no-undo.
define variable v-margins-range     as integer           no-undo.
define variable v-margins-exists    as logical           no-undo.
define variable v-increase-range    as integer           no-undo.
define variable v-increase-exists   as logical           no-undo.
define variable v-min-marg          as decimal           no-undo.
define variable v-max-marg          as decimal           no-undo.
define variable v-increase-pc       as decimal           no-undo.
define variable v-round-method      as character         no-undo .
define variable v-base              as decimal           no-undo .
define variable v-rmethod-range     as integer           no-undo.
define variable v-rmethod-exists    as logical           no-undo.
define variable  v-cli-type          as character no-undo .
define variable  v-cli-code          as integer no-undo .
define variable  v-income-cli-range  as integer no-undo .
define variable  v-income-cli-exists as logical no-undo .
define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    create buf_temp_grplib_grp.
    assign
        buf_temp_grplib_grp.node-code   = p-node-code
        buf_temp_grplib_grp.upper-code  = p-upper-code
        buf_temp_grplib_grp.level       = p-level
        buf_temp_grplib_grp.full-name   = p-full-name + (if p-full-name <> "" then chr(47)         else "") + p-node-name
        buf_temp_grplib_grp.sort-name   = p-sort-name + (if p-full-name <> "" then chr(2)  else "") + p-node-name
        buf_temp_grplib_grp.calc-method = p-calc-method
        buf_temp_grplib_grp.increase-pc = p-increase-pc
      .
    find first temp_cons where temp_cons.node-code = p-node-code no-error .
    if available temp_cons then do:
        assign
          buf_temp_grplib_grp.min-marg = temp_cons.min-marg
          buf_temp_grplib_grp.max-marg = temp_cons.max-marg
          buf_temp_grplib_grp.cli-type = temp_cons.cli-type
        .
    end.
    run get-first-char in this-procedure (
          input p-node-code
        , input p-is-terminal
        , input no
        , output buf_temp_grplib_grp.mark
    ) no-error.
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления первого символа для отображения группы." .
    end.
    assign
        buf_temp_grplib_grp.name = fill( " ", 4 * p-level )
                                        + buf_temp_grplib_grp.mark
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
    define variable v-gds-grp-recid     as recid    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-upper-code        as integer  no-undo.
    define variable v-answer            as logical  no-undo.
    define variable v-is-terminal       as logical  no-undo.
    define variable v-have-goods        as logical  no-undo.
    define variable v-counter           as integer  no-undo.
    define variable v-have-rights       as logical  no-undo.
    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_same_gds-grp      for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
    run check-rights-for-change-grp in this-procedure (
        input p-node-code
        ,output v-have-rights
    ) no-error.
    if error-status :error
    or v-have-rights = no
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Нет прав на изменение справочника групп товаров."
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
    if p-node-code = v-root-code
    then do:
        message
            "Нельзя удалить корневую группу."
        view-as alert-box.
        undo, return.
    end.
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "Неверно выбрана группа." .
    end.
    if buf_temp_grplib_grp.upper-code = v-root-code
    then do:
        assign
            v-counter = v-counter + 1
        .
        count-first-level-grp:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = v-root-code
        :
            assign
                v-counter = v-counter + 1
            .
            if v-counter > 1
            then do:
                leave count-first-level-grp.
            end.
            else do:
                message
                    "Нельзя удалить последнюю группу первого уровня."
                view-as alert-box.
                return error.
            end.
        end.
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if error-status :error
    then do:
        undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
    end.
    assign
        v-upper-code    = buf_gds-grp.upper-code
        v-answer        = no
    .
    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    if v-is-terminal = no
    then do:
        for each buf_gds-grp
        where buf_gds-grp.upper-code = v-upper-code
          and buf_gds-grp.node-code <> p-node-code
        :
            find first buf_same_gds-grp no-lock
                where buf_same_gds-grp.upper-code  = p-node-code
                and buf_same_gds-grp.node-name   = buf_gds-grp.node-name
            no-error.
            if available buf_same_gds-grp
            then do:
                message
                    "Одна из подгрупп удаляемой группы имеет название:" buf_gds-grp.node-name "-" skip
                    "такое же, как одна из соседних к удаляемой групп." skip
                    "После удаления получились бы 2 группы на одном уровне, имеющие одинаковые названия, что запрещено."
                view-as alert-box error.
                return no-apply.
            end.
        end.
        message "Текущая группа будет удалена."
            skip "Ее подгруппы будут перенесены в вышестоящую группу."
            skip (1) "Слить группу с вышестоящей?"
        view-as alert-box question buttons yes-no update v-answer.
    end.
    if v-is-terminal = yes
    then do:
        run grplib-have-goods in this-procedure (
              input p-node-code
            , output v-have-goods
        ) no-error .
        if error-status :error
        then do:
            undo, return error "delete-grp: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
        end.
        if v-have-goods = yes
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-code <> p-node-code
            no-error .
            if available buf_gds-grp
            then do:
                message "В одной группе не могут быть одновременно подгруппы и товары."
                    skip "Эта группа не может быть слита с вышестоящей."
                view-as alert-box error.
                apply "entry" to br-list in frame Dlg-grp.
                return no-apply.
            end.
            message "Текущая группа будет удалена."
                skip "Товары будут перенесены в вышестоящую группу."
                skip (1) "Слить группу с вышестоящей?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
        else do:
            message "Удалить группу ? Вы уверены ?"
            view-as alert-box question buttons yes-no update v-answer.
        end.
    end.
    if not v-answer
    then do:
        apply "entry" to br-list in frame Dlg-grp.
        return no-apply.
    end.
    delete-from-base:
    do
    ON ERROR UNDO delete-from-base, return no-apply
    ON stop UNDO delete-from-base, return no-apply:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        no-error.
        if error-status :error
        then do:
            undo, return error "change-grp: Нет группы БД, соответствующей значению в списке.".
        end.
        delete buf_gds-grp.
    end.
    if p-refresh = yes
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "delete-grp: Не найдена группа в БД".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
            gds-grp-row  = recid( buf_gds-grp )
        .
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
  DISPLAY fi-search RS-sts FILL-IN-1
      WITH FRAME Dlg-grp.
  ENABLE b-exit b-mark b-verify b-recalc B-print b-help b-expand b-expand-all
         fi-search b-find-by-full-name b-find-by-substring b-search br-list
         B-add B-lookup B-chg B-del B-copy RS-sts BROWSE-am-goods FILL-IN-1
      WITH FRAME Dlg-grp.
  VIEW FRAME Dlg-grp.
  OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE expand-all-from-current :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
    define variable v-full-name         as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-grp-counter       as integer      no-undo.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-grplib-no-warning-grp-amount = no
    .
    run expand-item in this-procedure (
          input p-node-code
        , input no
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
    end.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "expand-all-from-current: Ошибка вычисления полного имени группы".
    end.
    assign
        v-grplib-grp-amount-for-load = 1
    .
    load-grp-list:
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.full-name begins v-full-name
    :
        assign
            v-grp-counter = v-grp-counter + 1
        .
        run expand-item in this-procedure (
              input buf_temp_grplib_grp.node-code
            , input no
        ) no-error .
        if error-status :error
        then do:
            undo, return error "expand-all-from-current: Не удалось раскрыть подуровни группы.".
        end.
        if v-grp-counter > 1000
        and v-grplib-grp-amount-for-load <> 0
        then do:
            define variable v-choice    as integer      no-undo.
            run gbl/d-askw.w (
                  input "Большой список групп"
                , input substitute( "В список добавлено более &2 групп&1&1Вы можете добавить следующие &2 групп,&1заполнить весь список&1или остановить создание списка.", chr(10), 1000 )
                , input "|^":U
                , input substitute( "Следующие &1|Заполнить все|Прервать", 1000 )
                , input substitute( "Загрузить список следующих &1 групп|Загрузить список всех групп|Не загружать список полностью", 1000 )
                , input 1
                , input 3
                , output v-choice
            ).
            case v-choice
            :
                when 1
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 1
                        v-grp-counter                   = 0
                    .
                end.
                when 2
                then do:
                    assign
                        v-grplib-grp-amount-for-load    = 0
                    .
                end.
                otherwise do:
                    leave load-grp-list.
                end.
            end case.
        end.
    end.
    OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE expand-item :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-refresh    as logical      no-undo.
    define variable v-focused-row       as integer              no-undo.
    define variable v-repositioned-row  as integer              no-undo.
    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
if session :set-wait-state( "compiler" ) then.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if not available buf_temp_grplib_grp
    then do:
        undo, return error "expand-item: Неверно задан код группы.".
    end.
    if buf_temp_grplib_grp.mark <> "»"
    then do:
    end.
    else do:
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            run create-new-line in this-procedure (
                  input buf_gds-grp.node-code
                , input buf_gds-grp.upper-code
                , input buf_temp_grplib_grp.level + 1
                , input buf_gds-grp.is-term
                , input buf_gds-grp.node-name
                , input buf_gds-grp.increase-pc
                , input buf_gds-grp.calc-method
                , input buf_temp_grplib_grp.full-name
                , input buf_temp_grplib_grp.sort-name
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
if session :set-wait-state( "" ) then.
                undo, return error .
            end.
        end.
        assign
            buf_temp_grplib_grp.mark = "«"
            buf_temp_grplib_grp.name = replace( buf_temp_grplib_grp.name
                                            , "»"
                                            , "«"
                                            )
        .
        if p-refresh = yes
        then do:
            OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
            if v-focused-row > br-list :height - 2
            then do:
                assign
                    v-focused-row       = br-list :height - 2
                .
            end.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
            reposition br-list to row v-repositioned-row.
            OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
        end.
    end.
if session :set-wait-state( "" ) then.
end.
END PROCEDURE.
PROCEDURE expand-or-collapse-item :
do
on error undo, return error
:
    case temp_grplib_grp.mark
    :
    when "»"
    then do:
        run expand-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
        if error-status :error
        then do:
            undo, return error "Не удалось раскрыть подуровни группы.".
        end.
    end.
    when "«"
    then do:
        run collapse-item in this-procedure ( input temp_grplib_grp.node-code, input yes ) no-error .
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
define input parameter p-node-code              as integer          no-undo.
define output parameter p-focused-row           as integer          no-undo.
define output parameter p-reposition-row        as integer          no-undo.
define output parameter p-reposition-to-recid   as logical init no  no-undo.
define variable v-full-name     as character    no-undo.
define variable v-found         as logical      no-undo.
define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    run grplib-get-full-name in this-procedure ( input p-node-code, output v-full-name ) no-error .
    if error-status :error
    then do:
    end.
    else do:
        run grplib-find-grp-by-full-name in this-procedure (
              input right-trim( v-full-name, chr(47) )
            , input yes
            , output v-found
        ) no-error .
        if v-found = no
        then do:
        end.
        else do:
            process-initial-grp:
            for each temp_grplib_found-grp
            break by temp_grplib_found-grp.level
            on error undo, leave process-initial-grp :
                if last ( temp_grplib_found-grp.level )
                then do:
                    assign
                        p-focused-row       = integer( br-list :height in frame Dlg-grp / 2 ) + 1
                    .
                    find first buf_temp_grplib_grp
                         where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                    leave process-initial-grp.
                end.
                else do:
                    run expand-item in this-procedure ( input temp_grplib_found-grp.node-code, input no ) no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    find first buf_temp_grplib_grp
                            where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
                    no-error .
                    if error-status :error
                    then do:
                        leave process-initial-grp.
                    end.
                    assign
                        p-reposition-row = recid( buf_temp_grplib_grp )
                        p-reposition-to-recid = yes
                    .
                end.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE fill-db :
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .
  run ref/dtaxgrpu.p (input parnode-code,
                 input parupper-code,
                 input yes,
                 input v-current-host-code,
                 v-current-store-type,
                 v-current-store-code) no-error.
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
    define variable v-cli-type           as character no-undo .
    define variable v-cli-code           as integer no-undo .
    define variable v-income-cli-range   as integer no-undo .
    define variable v-income-cli-exists  as logical no-undo .
    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
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
    find first buf_temp_grplib_grp
         where buf_temp_grplib_grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "fill-marg: Неверно задан код группы.".
    end.
    OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
    reposition br-list to row v-repositioned-row.
    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE fill-output-parameters-on-exit :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
    define variable v-selected      as logical  init no  no-undo.
    define variable v-is-terminal    as logical           no-undo.
    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
    run grplib-is-terminal in this-procedure ( input p-node-code, output v-is-terminal ) no-error.
    if error-status :error
    then do:
        undo, return error "fill-output-parameters-on-exit: Не удается определить, корневая группа или терминальная." + chr(10) + return-value.
    end.
    if lookup ( 'терм':U, p-button-list ) <> 0 and v-is-terminal = no
    then do:
            message "Требуется выбрать группу товаров, в которой нет других групп.".
            apply "entry" to br-list in frame Dlg-grp.
            undo, return "no-term".
    end.
    assign
        p-recid-list = ""
    .
    for each buf_temp_grplib_grp
       where buf_temp_grplib_grp.sel = "*"
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_grplib_grp.node-code
        no-error .
        if error-status :error
        then do:
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                                + "'" + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = p-recid-list + ( if p-recid-list = "" then "" else "," ) + string( recid( buf_gds-grp ) )
            v-selected = yes
        .
    end.
    if v-selected = no
    then do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = p-node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "fill-output-parameters-on-exit: Неверно выбрана группа с кодом "
                                    + string( p-node-code ).
            end.
            undo, return error "fill-output-parameters-on-exit: Не найдена запись выбранной группы '"
                            + buf_temp_grplib_grp.full-name + "'".
        end.
        assign
            p-recid-list = string( recid( buf_gds-grp ) )
        .
    end.
    assign
        gds-grp-row  = integer( entry( 1, p-recid-list ) )
    .
assign
v-uf-List_ = (if gds-grp-row = ? then chr(63) else string(gds-grp-row))
.
run uf-set in this-procedure(
    input  'gds-grp-p':U
    ,input  g#userid
    ,input v-uf-List_
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .
end.
END PROCEDURE.
PROCEDURE fill-tt :
do
on error undo, return error
:
define input parameter parnode-code like ub.gds-grp.node-code no-undo .
define input parameter parupper-code like ub.gds-grp.node-code no-undo .
run ref/dtaxgrps.p (parnode-code,
               parupper-code,
               v-current-host-code,
               v-current-store-type,
               v-current-store-code) no-error.
end.
END PROCEDURE.
PROCEDURE find-grp-in-browse :
do
on error undo, return error
:
define input parameter p-search-grp-full-name   as character        no-undo.
define output parameter p-found                 as logical          no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-level             as integer      no-undo.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    assign
        v-focused-row      = br-list :focused-row in frame Dlg-grp.
        v-repositioned-row = current-result-row( "br-list" )
    .
    assign
    v-level = num-entries( right-trim(p-search-grp-full-name, chr(47) ) , chr(47))
    .
    if v-found-grp-num  <> 0
    then do:
        assign
            v-counter = 0
        .
        find first temp_grplib_found-grp
             where temp_grplib_found-grp.level = v-level
        no-error .
        if not available temp_grplib_found-grp
        then do:
            undo, return error "Не найдено ни одной группы уровня " + string( v-level ).
        end.
        do v-counter = 1 to v-found-grp-num
        :
            find next temp_grplib_found-grp
                where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Не найдена следующая группа уровня " + string( v-level ).
            end.
        end.
        find first buf_temp_grplib_grp
                where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
        no-error .
        if not available buf_temp_grplib_grp
        then do:
            undo, return error "Найденной группы нет в списке групп".
        end.
        OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
        br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
        reposition br-list to recid recid( buf_temp_grplib_grp ).
        OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
    end.
    else do:
        run grplib-find-grp-by-full-name (
              input fi-search :screen-value in frame Dlg-grp
            , input yes
            , output p-found
        ).
        if p-found = yes
        then do:
            found-group:
            for each temp_grplib_found-grp no-lock
            by temp_grplib_found-grp.level
            :
                if temp_grplib_found-grp.level = v-level
                then do:
                    leave.
                end.
                run expand-item in this-procedure (
                      input temp_grplib_found-grp.node-code
                    , input no
                ).
            end.
            find first temp_grplib_found-grp
                 where temp_grplib_found-grp.level = v-level
            no-error .
            if not available temp_grplib_found-grp
            then do:
                undo, return error "Нет последней найденной группы для уровня " + string( v-level ).
            end.
            find first buf_temp_grplib_grp
                 where buf_temp_grplib_grp.node-code = temp_grplib_found-grp.node-code
            no-error .
            if not available buf_temp_grplib_grp
            then do:
                undo, return error "Найденной группы нет в списке групп".
            end.
            OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.    OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
            br-list :set-repositioned-row(v-focused-row, "ALWAYS") in frame Dlg-grp.
            reposition br-list to recid recid( buf_temp_grplib_grp ).
            OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
        end.
    end.
    find next temp_grplib_found-grp
        where temp_grplib_found-grp.level = v-level
    no-error .
    if available temp_grplib_found-grp
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
end.
END PROCEDURE.
PROCEDURE get-current-recid :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define output parameter p-gds-grp-recid as recid   no-undo.
    define buffer buf_gds-grp       for gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error "get-current-recid: Не найдена группа." .
    end.
    assign
        p-gds-grp-recid = recid( buf_gds-grp )
    .
end.
END PROCEDURE.
PROCEDURE get-first-char :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define input parameter p-terminal       as logical      no-undo.
define input parameter p-calc-terminal  as logical      no-undo.
define output parameter p-prefix        as character    no-undo.
define variable v-name          as character    no-undo.
define variable v-is-terminal   as logical      no-undo.
define variable v-have-goods    as logical      no-undo.
define buffer buf_gds-grp               for gds-grp.
define buffer buf_temp_grplib_grp       for temp_grplib_grp.
if p-calc-terminal = yes
then do:
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ) no-error .
    if error-status :error
    then do:
        undo, return error "get-first-char: Ошибка при определении типа группы (терм/корн).".
    end.
end.
else do:
    assign
        v-is-terminal = p-terminal
    .
end.
if v-is-terminal = yes
then do:
    run grplib-have-goods in this-procedure (
          input p-node-code
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
    find first buf_temp_grplib_grp no-lock
         where buf_temp_grplib_grp.upper-code = p-node-code
    no-error.
    if available buf_temp_grplib_grp
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
PROCEDURE get-row-amount :
do
on error undo, return error
:
define output parameter p-row-amount as integer      no-undo.
    define buffer buf_temp_grplib_grp       for temp_grplib_grp.
    for each buf_temp_grplib_grp
    :
        assign
            p-row-amount = p-row-amount + 1
        .
    end.
end.
END PROCEDURE.
PROCEDURE init-tt :
 define buffer buf_gds-grp-obj-attr  for ub.gds-grp-obj-attr  .
    for each temp_grplib_grp :
        find first buf_gds-grp-obj-attr no-lock  where
                   buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id) and
                   buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
        if not available buf_gds-grp-obj-attr then temp_grplib_grp.cli-type  = "".
        else temp_grplib_grp.cli-type = buf_gds-grp-obj-attr.attr-value .
    end.
END PROCEDURE.
PROCEDURE move-item :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define input parameter p-upper-code as integer      no-undo.
    define variable v-node-full-name    as character    no-undo.
    define variable v-upper-full-name   as character    no-undo.
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-have-goods        as logical      no-undo.
    define buffer buf_gds-grp           for gds-grp.
    define buffer buf_upper_gds-grp     for gds-grp.
    define buffer buf_temp_grplib_grp   for temp_grplib_grp.
if session :set-wait-state( "compiler" ) then.
    run grplib-have-goods in this-procedure (
          input p-upper-code
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
    run grplib-get-full-name in this-procedure (
            input p-node-code
            , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка вычисления полного имени перемещаемой группы".
    end.
    run grplib-get-full-name in this-procedure (
            input p-upper-code
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
        find first buf_gds-grp exclusive-lock
            where buf_gds-grp.node-code = p-node-code
        no-error .
        if not available buf_gds-grp
        then do:
            undo, return error "move-item: Не найдена группа для перемещения.".
        end.
        assign
            buf_gds-grp.upper-code = p-upper-code
        .
    end.
    assign
        p-recid-list = string( recid( buf_gds-grp ) )
        gds-grp-row  = recid( buf_gds-grp )
    .
    run UI-on in this-procedure no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка при загрузке дерева групп." + chr(10) + return-value.
    end.
end.
END PROCEDURE.
PROCEDURE print-browse :
define variable Line as character no-undo.
define variable v-vat-pc as decimal no-undo .
define variable v-slt-pc as decimal no-undo .
define variable date_string as character no-undo.
define buffer buf_temp_grplib_grp for temp_grplib_grp.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.
DEFINE FRAME brFrame
buf_temp_grplib_grp.name          format "X(71)"      column-label " Наименование группы"
buf_temp_grplib_grp.calc-method   format "X(11)"      column-label " Исходная"
buf_temp_grplib_grp.increase-pc   format "->>>>9.99"  column-label " Наценка"
buf_temp_grplib_grp.min-marg      format "X(10)"  column-label " Мин.Нац."
buf_temp_grplib_grp.max-marg      format "X(10)"  column-label " Макс.Нац."
buf_temp_grplib_grp.round-method  format "X(22)"  column-label "Метод округл"
v-vat-pc                          format "99.99"  column-label "НДС"
v-slt-pc                          format "99.99"  column-label "НП"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 85 PAGE-NUMBER(PrnLibStream) AT 95 FORMAT ">>9" SKIP
Line format "X(150)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 150).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
      input parparentproc
    , input 43
    , input yes
    , input no
).
PUT  STREAM PrnLibStream
    SPACE(25) ( frame Dlg-grp:title )
    format "x(90)" SKIP(1)
.
FORM HEADER
Line format "X(150)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME BrFrame  .
run waitfram-show in this-procedure ("Ждите...").
FOR EACH buf_temp_grplib_grp :
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer('1':U) AND
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tax-rate-gds-grp.tax-code
  ,input  buf_tax-rate-gds-grp.rate-code
  ,input  ?
  ,input  v-current-host-code
  ,input  v-current-store-type
  ,input  v-current-store-code
  ,output v-vat-pc
  ) no-error .
  end.
  FIND LAST buf_tax-rate-gds-grp No-LOCK WHERE
            buf_tax-rate-gds-grp.node-code = buf_temp_grplib_grp.node-code AND
            buf_tax-rate-gds-grp.tax-code = integer('2':U) AND
            buf_tax-rate-gds-grp.host-code = 0 AND
            buf_tax-rate-gds-grp.obj-type = "" AND
            buf_tax-rate-gds-grp.obj-code = 0 NO-ERROR.
  if avail buf_tax-rate-gds-grp then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tax-rate-gds-grp.tax-code
  ,input  buf_tax-rate-gds-grp.rate-code
  ,input  ?
  ,input  v-current-host-code
  ,input  v-current-store-type
  ,input  v-current-store-code
  ,output v-slt-pc
  ) no-error .
  end.
  DISPLAY stream PrnLibStream
  buf_temp_grplib_grp.name
  buf_temp_grplib_grp.calc-method
  buf_temp_grplib_grp.increase-pc
  buf_temp_grplib_grp.min-marg
  buf_temp_grplib_grp.max-marg
  buf_temp_grplib_grp.round-method
  v-vat-pc
  v-slt-pc
  with frame BrFrame.
  down stream PrnLibStream
  with frame BrFrame.
END.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME BrFrame.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
      input parparentproc
    , input 8
).
END PROCEDURE.
PROCEDURE proc-add :
define output parameter p-doc-rec as recid no-undo .
define variable v-host-code as integer   no-undo .
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-current-obj-type
  ,input  p-current-obj-code
  ,output v-host-code
  )  .
for each tt-gds-list :
   delete tt-gds-list.
end.
run str/chsgdsls.w
(   parParentProc ,
    input "gds-matr" ,
    input "Ассортиментная матрица " + buf_matrix.asmt-name  , ? , ? ,
    input v-host-code,
    input-output varschartic,
    output ref-list,
    output table tt-gds-list,
    false )
     no-error .
     if error-status :error then do:
     message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error
        .
     end.
RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
    p-Id,
    p-Db-num,
    OUTPUT cError
    ).
if cError <> "" THEN DO:
   RETURN ERROR cError.
END.
DEFINE VARIABLE vss-include-info36 AS CHARACTER FORMAT "x(65)" NO-UNDO INITIAL "@(#)$Workfile$ $Revision$".
FOR EACH tt-gds-list NO-LOCK:
    IF NOT CAN-FIND(FIRST ub.Assortment-matrix-goods WHERE
                          ub.Assortment-matrix-goods.Asmt-id      = buf_matrix.Asmt-id
                      AND ub.Assortment-matrix-goods.Db-num       = buf_matrix.db-num
                      AND ub.Assortment-matrix-goods.gds-code     = tt-gds-list.gds-code
                      AND ub.Assortment-matrix-goods.asmg-status  = INTEGER('0':U)
                      NO-LOCK) THEN DO:
       ASSIGN
          iDelta = iDelta + 1.
    END.
END.
 RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
     iDelta,
     OUTPUT cError
     ).
 if cError <> "" THEN DO:
    RETURN ERROR cError.
 END.
 run waitfram-show in this-procedure  ("Добавление товаров в ассортиментную матрицу ... " ) .
 for each tt-gds-list:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output p-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input buf_matrix.asmt-id
 ,input buf_matrix.db-num
 ,input tt-gds-list.gds-code
 ,input ''
  ) no-error .
        if error-status :error then do:
            message return-value view-as alert-box information .
            run waitfram-hide in this-procedure .
            return.
        end.
 end.
run waitfram-hide in this-procedure .
END PROCEDURE.
PROCEDURE proc-b-del :
define input  parameter p-recid as character no-undo .
define input  parameter p-model as logical   no-undo .
define variable loc#log as logical no-undo.
define variable v-log as logical   no-undo .
define variable v-sts like ub.assortment-matrix-goods.asmg-status no-undo .
define variable loc-doc-rec as recid no-undo.
define variable i as integer   no-undo .
if not available buf_matrix-goods then return error.
do
on error undo, return error
on stop undo, return error
:
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-gds_deletion':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
   assign
    v-sts = ?
    loc-doc-rec = RECID(buf_Matrix-goods)
    .
  if p-model = false then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input recid(buf_Matrix-goods)
 ,input-output v-sts
 ,input true
  ) no-error .
    if error-status:error then do:
       message return-value view-as alert-box information .
       undo, return error.
    end.
  end.
  else do:
      v-err-ext = false  .
      v-longchar = "".
      repeat i = 1 to num-entries(p-recid) :
      find first buf_Matrix-goods no-lock where
           recid(buf_Matrix-goods) = integer(entry(i,p-recid )) no-error .
        if buf_Matrix-goods.asmg-status = 0 then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input entry(i,p-recid)
 ,input-output v-sts
 ,input false
  ) no-error .
              if error-status :error then do:
                 v-err-ext = true .
                 v-longchar = v-longchar  + return-value + chr(10) .
              end.
        end.
      end.
    p-recid = "" .
    p-rid-list = "" .
    if v-err-ext = true  then do:
    define variable v-ok as logical   no-undo .
      run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
          + 'title=При корректировке в Ассортиментные матрицы\':u
          + 'Editor_col=1\':u
          + 'Editor_width=96\':u
          + 'Editor_height=21\':u
          + 'readonly=yes\':u
        ,input-output v-longchar
        ,output v-ok ) no-error .
        v-longchar = "" .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
    end.
  end.
  OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
  REPOSITION BROWSE-am-goods to recid loc-doc-rec No-error.
  if error-status:error then do:                           find first pos_assortment-matrix no-lock where                                   recid(pos_assortment-matrix) = loc-doc-rec no-error .                             message                             "Невозможно позиционироваться на записи AM" skip                            string(if avail pos_assortment-matrix                                     then  substitute("Вн код AM: &1"                                                     , pos_assortment-matrix.asmt-id)                                     else "":U) skip                             "Запись была добавлена (или изменена или удалена) -" skip                             "и теперь не попадает в текущую выборку"                             view-as alert-box WARNING.                           end.
  if available buf_Matrix-goods then do:
    loc#log = BROWSE-am-goods:select-focused-row( ) IN FRAME Dlg-grp.
    loc#log = BROWSE-am-goods:refresh() .
  end.
  apply "ENTRY" to BROWSE-am-goods.
end.
END PROCEDURE.
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      character    no-undo.
define variable Line            as      character    no-undo.
define variable v-time-cr as character no-undo .
define variable v-time-up as character no-undo .
define variable v-st      as character no-undo .
DEFINE FRAME buf_Matrix-list
      Buf_goods.artic FORMAT "X(16)":U
      Buf_goods.gds-name FORMAT "X(30)":U
      Buf_matrix-goods.asmg-who-update COLUMN-LABEL "Кто!изменил" FORMAT "X(8)":U
      Buf_matrix-goods.asmg-date-update COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U
      p-time-upd COLUMN-LABEL "Время" FORMAT "x(5)":U
      Buf_matrix-goods.asmg-db-num-update COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      Buf_matrix-goods.asmg-date-create COLUMN-LABEL "Дата!создания" FORMAT "99/99/99":U
      p-time-cr COLUMN-LABEL "Время" FORMAT "x(5)":U
      Buf_matrix-goods.asmg-who-create COLUMN-LABEL "Кто!создал" FORMAT "X(8)":U
      Buf_matrix-goods.asmg-db-num-create COLUMN-LABEL "БД!соз" FORMAT ">>>>9":U
      p-status COLUMN-LABEL "Статус" FORMAT "x(6)":U
      v-indicator-life-gds COLUMN-LABEL "ИЖТ" FORMAT "x(20)":U
      v-assort-min         column-label "AMin" format "*/ "
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 195).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dlg-grp:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME buf_Matrix-list  .
run waitfram-show in this-procedure ("Ждите...").
v-doc-rec = recid(buf_Matrix-goods).
DO WHILE available buf_Matrix-goods :
  GET prev BROWSE-am-goods.
END.
GET next BROWSE-am-goods.
DO WHILE available buf_Matrix-goods :
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  buf_Matrix-goods.gds-code
  ,output v-assort-min
  ,output v-indicator-life-gds
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
  Display STREAM PrnLibStream
    STRING (buf_Matrix-goods.asmg-time-create,'HH:MM') @ p-time-cr
    STRING (buf_Matrix-goods.asmg-time-update,'HH:MM') @ p-time-upd
           entry (lookup (STRING(buf_Matrix-goods.asmg-status), '0,1,50,99':U), 'тек,удал,блок,удаление':U) @ p-status
            Buf_goods.artic
            Buf_goods.gds-name
            Buf_matrix-goods.asmg-who-update
            Buf_matrix-goods.asmg-date-update
            Buf_matrix-goods.asmg-db-num-update
            Buf_matrix-goods.asmg-date-create
            Buf_matrix-goods.asmg-who-create
            Buf_matrix-goods.asmg-db-num-create
            v-indicator-life-gds
            v-assort-min
 with FRAME buf_Matrix-list .
  DOWN STREAM PrnLibStream 1
  with FRAME buf_Matrix-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next BROWSE-am-goods.
END.
UNDERLINE  STREAM PrnLibStream
    p-time-cr
    p-time-upd
    p-status
    Buf_goods.artic
    Buf_goods.gds-name
    Buf_matrix-goods.asmg-who-update
    Buf_matrix-goods.asmg-date-update
    Buf_matrix-goods.asmg-db-num-update
    Buf_matrix-goods.asmg-date-create
    Buf_matrix-goods.asmg-who-create
    Buf_matrix-goods.asmg-db-num-create
    v-indicator-life-gds
    v-assort-min
with FRAME buf_Matrix-list .
DISPLAY STREAM PrnLibStream
"ИТОГО"     @ Buf_goods.artic
accum-count @ Buf_goods.gds-name
with frame buf_Matrix-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME buf_Matrix-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION BROWSE-am-goods to recid v-doc-rec no-error.
APPLY "entry" to BROWSE-am-goods.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
PROCEDURE proc-copy :
define output parameter p-doc-rec as recid no-undo .
define variable  v-rid-list as character no-undo .
define buffer bb_assortment-matrix for assortment-matrix.
define buffer bb_assortment-matrix-goods for assortment-matrix-goods.
define variable v-calc0    as integer   no-undo init 1 .
define variable v-calc     as integer   no-undo init 0 .
define variable v-calc-err as integer   no-undo init 0 .
DEFINE VARIABLE cError as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta as INTEGER   NO-UNDO INITIAL 0.
RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
    p-Id,
    p-Db-num,
    OUTPUT cError
    ).
if cError <> "" THEN DO:
   RETURN ERROR cError.
END.
run ref/assmatr.w ( input parParentProc , input 'b-sel', p-current-obj-type , p-current-obj-code , ? ,  ?, input-output  v-rid-list ).
if v-rid-list <> "" then do:
   find first bb_assortment-matrix no-lock where recid(bb_assortment-matrix) = int(v-rid-list) no-error .
   if available bb_assortment-matrix then do:
      RUN Get-Delta-Gds-2-Matrix in THIS-PROCEDURE(
          BUFFER bb_assortment-matrix,
          BUFFER buf_matrix,
          OUTPUT iDelta
          ).
      RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
          iDelta,
          OUTPUT cError
          ).
      IF cError <> "" THEN DO:
         RETURN ERROR cError.
      END.
      for each  bb_assortment-matrix-goods no-lock where
                bb_assortment-matrix-goods.asmg-status  = 0 and
                bb_assortment-matrix-goods.db-num = bb_assortment-matrix.db-num and
                bb_assortment-matrix-goods.asmt-id = bb_assortment-matrix.asmt-id :
            run waitfram-show in this-procedure  ("Копирование из ассортиментной матрицы " + bb_assortment-matrix.asmt-name + " " + string(v-calc0) ) .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output p-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input buf_matrix.asmt-id
 ,input buf_matrix.db-num
 ,input bb_assortment-matrix-goods.gds-code
 ,input bb_assortment-matrix-goods.asmg-des
  ) no-error .
                    if error-status :error then do:
                       v-calc-err = v-calc-err + 1 .
                       v-err-ext  = true .
                       v-longchar = v-longchar + return-value  + chr(10) .
                    end.
                    else  do:
                      v-calc = v-calc + 1 .
                    end.
                  v-calc0 = v-calc0 + 1 .
      end.
      run waitfram-hide in this-procedure .
      message
      "Скопировано" v-calc "товаров" skip
      "Ошибок"      v-calc-err       skip
      view-as alert-box information .
      if v-err-ext = true  then do:
      define variable v-ok as logical   no-undo .
        run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=При добавлении в Ассортиментные матрицы\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
           v-longchar = "" .
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clear-longmess in g#lib-Matrix
   .
      end.
   end.
end.
END PROCEDURE.
PROCEDURE recalc-lim :
define buffer loc_temp_grplib_grp for temp_grplib_grp  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .
for each temp_cons  :
  run calc-down-lim ( input temp_cons.node-code , output temp_cons.min-marg).
  find first loc_temp_grplib_grp where
             loc_temp_grplib_grp.node-code = temp_cons.node-code no-error .
      if available loc_temp_grplib_grp then loc_temp_grplib_grp.min-marg  = temp_cons.min-marg .
end.
find first temp_grplib_grp where recid (temp_grplib_grp)  = v-recid no-error .
OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
reposition BR-list to recid v-recid no-error.
END PROCEDURE.
PROCEDURE recalc-marg-ass :
define variable v-qntyAssgrp as integer  no-undo .
define variable ll as integer   no-undo .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf2_goods for ub.goods  .
define buffer loc_temp_grplib_grp for  temp_grplib_grp .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .
    for each loc_temp_grplib_grp :
      run calc-down-lim   (
          input loc_temp_grplib_grp.node-code ,
          output loc_temp_grplib_grp.min-marg).
        v-qntyAssgrp = 0.
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = 'QntyAssMat':U and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
                   buf1_gds-grp-obj-attr.obj-code  = p-db-num and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = loc_temp_grplib_grp.node-code
        no-error .
        if available buf1_gds-grp-obj-attr then v-qntyAssgrp = int(buf1_gds-grp-obj-attr.attr-value) .
        assign
          loc_temp_grplib_grp.max-marg = string(v-qntyAssgrp)
        .
    end.
run init-tt.
find first temp_grplib_grp where recid(temp_grplib_grp)  = v-recid no-error .
OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
reposition BR-list to recid v-recid no-error.
OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE save-alla :
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
  for each temp_cons :
        find first buf_gds-grp-obj-attr exclusive-lock where
                   buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id) and
                   buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_cons.node-code no-error .
        if not available buf_gds-grp-obj-attr then create buf_gds-grp-obj-attr.
        assign
            buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U
            buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id)
            buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code  = temp_cons.node-code
            buf_gds-grp-obj-attr.attr-value = temp_cons.cli-type
        .
  end.
  end.
END PROCEDURE.
PROCEDURE save-attr :
define buffer buf_gds-grp-obj-attr  for ub.gds-grp-obj-attr  .
if temp_grplib_grp.cli-type:read-only in browse br-list = false then do:
    if available  temp_grplib_grp then do:
        find first buf_gds-grp-obj-attr exclusive-lock where
                   buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U and
                   buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id) and
                   buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num and
                   buf_gds-grp-obj-attr.host-code = 0 and
                   buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code no-error .
        if not available buf_gds-grp-obj-attr then create buf_gds-grp-obj-attr.
        assign
            buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U
            buf_gds-grp-obj-attr.obj-type  = string(buf_matrix.asmt-id)
            buf_gds-grp-obj-attr.obj-code  = buf_matrix.db-num
            buf_gds-grp-obj-attr.host-code = 0
            buf_gds-grp-obj-attr.node-code = temp_grplib_grp.node-code
            buf_gds-grp-obj-attr.attr-value = temp_grplib_grp.cli-type
        .
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
    define buffer buf_gds-grp       for gds-grp.
    if p-node-code = v-root-code
    then do:
        message
        "Корневую группу переместить невозможно."
        view-as alert-box warning.
        undo, return .
    end.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error .
    if error-status :error
    then do:
        undo, return error "select-and-move-item: Группа не найдена в базе данных.".
    end.
    assign
        v-upper-recid-list = string( recid( buf_gds-grp ) )
    .
    run ref/gds-grp.w (
          input parparentproc
        , input "buttons-for-move"
        , input p-current-obj-type
        , input p-current-obj-code
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
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( 1, v-upper-recid-list ) )
    no-error .
    if error-status :error
    then do:
        undo, return error "Группа не найдена.".
    end.
    run grplib-get-full-name in this-procedure (  input p-node-code
                                                , output v-node-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "Ошибка вычисления полного имени перемещаемой группы.".
    end.
    run grplib-get-full-name in this-procedure (  input buf_gds-grp.node-code
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
        skip "    '" + v-upper-full-name + "'"
    view-as alert-box question
    buttons yes-no
    title "Перемещение группы"
    update v-yesno.
    if v-yesno = no
    then do:
    end.
    else do:
        run move-item in this-procedure ( input p-node-code
                                        , input buf_gds-grp.node-code
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
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.
define buffer buf_gds-grp           for gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_groups-edit':U
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
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + chr(10) + return-value.
end.
if v-from-b-gds then do:
  run uf-get in this-procedure(
      input  'gds-grp-p':U
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  chr(63) then ? else integer(v-uf-LIst_)))
  .
  if v-dop = v-old-recid-list then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  chr(63) then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( gds-grp-row )
  .
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.
end.
else do:
  run uf-get in this-procedure(
      input  'gds-grp-p':U
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  chr(63) then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( gds-grp-row )
  .
end.
find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
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
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then "•" else " " )
    buf_temp_grplib_grp.full-name   = chr(4)
    buf_temp_grplib_grp.sort-name   = chr(4)
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
.
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
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
if  p-recid-list <> "" and p-recid-list <> ?
then do:
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    find first buf_gds-grp no-lock
         where recid( buf_gds-grp ) = integer( entry( num-entries( p-recid-list ), p-recid-list ) )
    no-error .
    if not available buf_gds-grp
    then do:
    end.
    else do:
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
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
run enable_UI.
hide
        b-mark      in frame Dlg-grp
     .
case p-button-list
:
when "buttons-for-move"
then do:
    disable
        b-exit    with frame Dlg-grp
    .
end.
when "buttons-for-admin"
then do:
end.
when 'терм':U + ",b-scales"
then do:
end.
when 'терм':U + ",b-sel" or when "b-sel"
then do:
end.
when "b-sel,b-mark"
then do:
    view
        b-mark in frame Dlg-grp
    .
end.
end case.
if v-current-store-code = 0
or transaction
then do:
end.
br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
run recalc-marg-ass.
if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.
OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE UI-on-0 :
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
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer     no-undo.
define variable v-income-cli-range    as integer  no-undo.
define variable v-income-cli-exists   as logical  no-undo.
define variable v-dop                   as character no-undo .
define variable v-full-name             as character    no-undo.
define variable v-sort-name             as character    no-undo.
define buffer buf_gds-grp           for gds-grp.
define buffer buf_temp_grplib_grp   for temp_grplib_grp.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_groups-edit':U
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
run grplib-get-root-code in this-procedure ( output v-root-code ) no-error.
if error-status :error
then do:
    undo, return error "Не найден корневой узел." + chr(10) + return-value.
end.
if v-from-b-gds then do:
  run uf-get in this-procedure(
      input  'gds-grp-p':U
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  v-dop = string((if v-uf-List_ =  chr(63) then ? else integer(v-uf-LIst_)))
  .
  if v-dop = v-old-recid-list then do:
    assign
    gds-grp-row = v-old-recid
    .
  end.
  else do:
    assign
    gds-grp-row = (if v-uf-List_ =  chr(63) then ? else integer(v-uf-LIst_))
    .
  end.
  assign
      p-recid-list = string( gds-grp-row )
  .
  assign
  v-from-b-gds = no
  v-old-recid-list = "":U.
end.
else do:
  run uf-get in this-procedure(
      input  'gds-grp-p':U
      ,input  g#userid
      ,output v-uf-List_
      ,output v-uf-Naim
      ,output v-uf-print-graft
      ,output v-uf-sort-gr
      ,output v-uf-type-price
      ,output v-uf-type-val
  )  no-error .
  if not error-status:error then
  assign
  gds-grp-row = (if v-uf-List_ =  chr(63) then ? else integer(v-uf-LIst_))
  .
  assign
      p-recid-list = string( gds-grp-row )
  .
end.
find first buf_gds-grp no-lock
     where buf_gds-grp.node-code = v-root-code
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
if buf_gds-grp.is-term = yes
then do:
    run grplib-have-goods in this-procedure (
          input buf_gds-grp.node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        undo, return error "move-item: Ошибка определения наличия товаров в группе." + chr(10) + return-value.
    end.
end.
for each buf_temp_grplib_grp
:
    delete buf_temp_grplib_grp.
end.
create buf_temp_grplib_grp.
assign
    buf_temp_grplib_grp.node-code   = buf_gds-grp.node-code
    buf_temp_grplib_grp.upper-code  = buf_gds-grp.upper-code
    buf_temp_grplib_grp.level       = 0
    buf_temp_grplib_grp.mark        = ( if v-have-goods = yes then "•" else " " )
    buf_temp_grplib_grp.full-name   = chr(4)
    buf_temp_grplib_grp.sort-name   = chr(4)
    buf_temp_grplib_grp.name        = buf_gds-grp.node-name
    buf_temp_grplib_grp.increase-pc = buf_gds-grp.increase-pc
    buf_temp_grplib_grp.calc-method = buf_gds-grp.calc-method
.
for each buf_gds-grp no-lock
   where buf_gds-grp.upper-code = v-root-code
:
    run grplib-get-full-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-full-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run grplib-get-sort-name in this-procedure (
          input buf_gds-grp.node-code
        , output v-sort-name
    ) no-error .
    if error-status :error
    then do:
        undo, return error "create-new-line: Ошибка вычисления полного имени группы." .
    end.
    run create-new-line in this-procedure (
          input buf_gds-grp.node-code
        , input buf_gds-grp.upper-code
        , input 1
        , input buf_gds-grp.is-term
        , input buf_gds-grp.node-name
        , input buf_gds-grp.increase-pc
        , input buf_gds-grp.calc-method
        , input "":U
        , input "":U
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
    assign
        v-reposition-row = 1
        v-focused-row    = 1
    .
    for each buf_gds-grp no-lock
         :
        run expand-tree-for-grp in this-procedure (
            input buf_gds-grp.node-code
            , output v-focused-row
            , output v-reposition-row
            , output v-reposition-to-recid
        ) no-error .
        if error-status :error
        then do:
            undo, return error "UI-on: Не удалось раскрыть дерево групп." + chr(10) + return-value.
        end.
    end.
run enable_UI.
hide
        b-mark      in frame Dlg-grp
     .
case p-button-list
:
when "buttons-for-move"
then do:
    disable
        b-exit    with frame Dlg-grp
    .
end.
when "buttons-for-admin"
then do:
end.
when 'терм':U + ",b-scales"
then do:
end.
when 'терм':U + ",b-sel" or when "b-sel"
then do:
end.
when "b-sel,b-mark"
then do:
    view
        b-mark in frame Dlg-grp
    .
end.
end case.
if v-current-store-code = 0
or transaction
then do:
end.
br-list :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dlg-grp.
run recalc-marg-ass.
if v-reposition-to-recid = no
then do:
    reposition br-list to row v-reposition-row.
end.
else do:
    reposition br-list to recid v-reposition-row.
end.
OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
end.
for each temp_grplib_grp :
    find first temp_cons where temp_cons.node-code = temp_grplib_grp.node-code no-error .
        if not available temp_cons then create temp_cons.
        assign
            temp_cons.full-name  = temp_grplib_grp.full-name
            temp_cons.node-code  = temp_grplib_grp.node-code
            temp_cons.upper-code = temp_grplib_grp.upper-code
            temp_cons.min-marg   = temp_grplib_grp.min-marg
            temp_cons.max-marg   = temp_grplib_grp.max-marg
            temp_cons.cli-type   = temp_grplib_grp.cli-type
        .
end.
run recalc-lim in this-procedure .
END PROCEDURE.
PROCEDURE ver-attr :
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define VARIABLE v-old-grp as integer   no-undo .
define VARIABLE v-new-grp as integer   no-undo .
define VARIABLE v-ok      as logical    no-undo .
find first buf1_gds-grp-obj-attr no-lock where
           buf1_gds-grp-obj-attr.attr-code = 'QntyAssMat':U and
           buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
           buf1_gds-grp-obj-attr.obj-code  = p-db-num and
           buf1_gds-grp-obj-attr.host-code = 0 no-error .
if not available buf1_gds-grp-obj-attr then do:
   run utl/uassmgrp.p ( v-old-grp, v-new-grp, p-id , p-db-num, output v-ok ) no-error.
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
end.
END PROCEDURE.
PROCEDURE ver-db :
if v-cntxt-db-num <> 0 then do:
    if  buf_matrix.asmt-type = 'Шаблон':U  then do:
        if v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
          message
            "Нельзя редактировать ШАБЛОН Ассортиментная матрица созданный в чужой УБД"
            view-as alert-box error.
            return  error.
        end.
    end.
    else do:
        define variable obj-db-num as integer   no-undo .
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,output obj-db-num
  )  .
        if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
          message
            "Нельзя редактировать запись Ассортиментная матрица чужой УБД"
            view-as alert-box error.
            return  error.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE ver-db1 :
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-matr-grp_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then temp_grplib_grp.cli-type:read-only in browse br-list = true .
if v-cntxt-db-num <> 0 then do:
    if  buf_matrix.asmt-type = 'Шаблон':U  then do:
        if v-cntxt-db-num <> buf_matrix.asmt-db-num-create then do:
           temp_grplib_grp.cli-type:read-only in browse br-list = true .
        end.
    end.
    else do:
        define variable obj-db-num as integer   no-undo .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_matrix.obj-type
  ,input  buf_matrix.obj-code
  ,output obj-db-num
  )  .
        if v-cntxt-db-num <> 0 and  v-cntxt-db-num <> obj-db-num  then do:
           temp_grplib_grp.cli-type:read-only in browse br-list = true .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE init-gds-rec :
if available buf_goods then do:
   gds-rec = recid (buf_goods) .
end.
END PROCEDURE.
PROCEDURE recalc-add :
define variable v-qntyAssgrp as integer  no-undo .
define buffer buf2_goods for ub.goods  .
define buffer loc_temp_grplib_grp for temp_cons  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable v-recid as recid no-undo .
v-recid = recid (temp_grplib_grp) .
    for each loc_temp_grplib_grp :
        v-qntyAssgrp = 0.
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = 'QntyAssMat':U and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
                   buf1_gds-grp-obj-attr.obj-code  = p-db-num and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = loc_temp_grplib_grp.node-code
        no-error .
        if available buf1_gds-grp-obj-attr then v-qntyAssgrp = int(buf1_gds-grp-obj-attr.attr-value) .
        assign
          loc_temp_grplib_grp.max-marg = string(v-qntyAssgrp)
        .
    end.
find first temp_grplib_grp where recid(temp_grplib_grp)  = v-recid no-error .
OPEN QUERY br-list FOR EACH temp_grplib_grp NO-LOCK by temp_grplib_grp.sort-name.
reposition BR-list to recid v-recid no-error.
OPEN QUERY BROWSE-am-goods FOR EACH buf_Matrix-goods       WHERE buf_Matrix-goods.asmt-id = p-id and             buf_Matrix-goods.db-num  = p-db-num and             (RS-sts = 'все':U or buf_matrix-goods.asmg-status = int(RS-sts))             NO-LOCK,              FIRST buf_goods OF buf_Matrix-goods       WHERE temp_grplib_grp.level = 0 OR        ( buf_goods.grp-name begins temp_grplib_grp.full-name ) NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
