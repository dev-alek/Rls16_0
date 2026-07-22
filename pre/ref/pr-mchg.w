define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-node-code like ub.gds-grp-obj.node-code no-undo.
define input parameter  p-option as character no-undo.
define input parameter  p-host-code like ub.sysconf.host-code no-undo.
define input parameter  p-obj-type like ub.clients.obj-type no-undo.
define input parameter  p-obj-code like ub.clients.obj-code no-undo.
define output parameter p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Границы торговой наценки на группы товаров".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
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
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-host-name        like ub.clients.obj-name no-undo.
define variable v-full-name        as character  no-undo .
define variable v-old-value        as character  no-undo .
define variable v-value-changed    as logical    no-undo init no.
define variable v-marg-min         as decimal    no-undo .
define variable v-marg-max         as decimal    no-undo .
define variable v-increase-pc      as decimal    no-undo .
define variable v-round-method     as character  no-undo .
define variable v-base             as decimal    no-undo .
define variable v-cli-type         as character  no-undo .
define variable v-cli-code         as integer    no-undo .
define variable v-cli-name         as character  no-undo .
define variable v-notcorr          as character  no-undo .
define variable v-type             as character  no-undo .
define variable v-alc-min-price    as character  no-undo .
define variable v-marg-pr-paraf    as character  no-undo .
define variable v-level-dis-attr   as character  no-undo .
define variable v-no-inc-auto-rep  as character  no-undo .
define variable v-ban-sales-via-cd as character  no-undo .
define variable v-table-menu       as character  no-undo .
define variable v-alchol           as character  no-undo .
define variable v-mark             as character  no-undo .
define variable v-sum-grp          as integer    no-undo .
define variable v-mark-type        as character  no-undo .
define variable ix                 as integer    no-undo .
define temp-table tt-level-dis-attr no-undo
   field attr-code  like global-state-attr.attr-code
   field attr-value like global-state-attr.attr-value
   index pi            attr-value descending
   index pi1 is unique attr-value
   attr-code .
DEFINE TEMP-TABLE tt-goods NO-UNDO LIKE goods
   field emrc as character.
define temp-table tt-emc-price no-undo
   field obj-code as integer
   field obj-type as character
   field gds-name as character
   field gds-code as integer
   field price    as decimal
   .
define temp-table temp_obj-list no-undo
   field host-code like ub.sysconf.host-code
   field obj-type  as character
   field obj-code  as integer
   index pi is primary unique obj-type obj-code
   .
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
FUNCTION func-cli-name RETURNS CHARACTER
  ( p-type as char, p-code as int  )  FORWARD.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Для заказов ОО".
DEFINE BUTTON r-sum-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Группа товаров на кассе".
DEFINE VARIABLE c-mark-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип маркировки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "1","1"
     DROP-DOWN-LIST
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE c-emrc-type      AS CHARACTER FORMAT "X(256)":U
   LABEL "Тип ЕМЦ"
   VIEW-AS COMBO-BOX INNER-LINES 5
   LIST-ITEM-PAIRS "1","1"
   DROP-DOWN-LIST
   SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE fi-notcorr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "Да","yes",
                     "Нет","no",
                     "?","?",
                     " ",""
     DROP-DOWN-LIST
     SIZE 7.5 BY 1 NO-UNDO.
DEFINE VARIABLE n-marg AS CHARACTER INITIAL "Диапазон торговой наценки %"
     VIEW-AS EDITOR
     SIZE 19.63 BY 2.17
     FGCOLOR 5  NO-UNDO.
DEFINE VARIABLE n-marg-pr-paraf AS CHARACTER INITIAL "Наценка к цене внутреннего прихода партии %"
     VIEW-AS EDITOR
     SIZE 17.5 BY 2.5
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE F-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE fi-alc-min-price AS CHARACTER FORMAT "X(255)"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 TOOLTIP "Для алкоголя, %сод.спирта,мин.цена;%сод.спирта,мин.цена"
     FGCOLOR 4 .
DEFINE VARIABLE fi-cli-code AS INTEGER FORMAT ">>>>>" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6 BY 1 TOOLTIP "Для заказов ОО".
DEFINE VARIABLE fi-cli-name AS CHARACTER FORMAT "X(20)"
     VIEW-AS FILL-IN
     SIZE 28 BY 1 TOOLTIP "Для заказов ОО"
     FGCOLOR 4 .
DEFINE VARIABLE fi-cli-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.13 BY 1 TOOLTIP "Для заказов ОО".
DEFINE VARIABLE fi-grp-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 57.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-increase-pc AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.63 BY 1.
DEFINE VARIABLE fi-marg-max AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.63 BY 1.
DEFINE VARIABLE fi-marg-min AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10.63 BY 1.
DEFINE VARIABLE fi-marg-pr-paraf AS DECIMAL FORMAT "->>>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 8 BY 1.
DEFINE VARIABLE fill-sum-grp AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Группа товаров на кассе"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE l-max AS CHARACTER FORMAT "X(256)":U INITIAL "Макс"
      VIEW-AS TEXT
     SIZE 6.5 BY .67 NO-UNDO.
DEFINE VARIABLE l-min AS CHARACTER FORMAT "X(256)":U INITIAL "Мин"
      VIEW-AS TEXT
     SIZE 6.5 BY .67 NO-UNDO.
DEFINE VARIABLE n-alc-min-price AS CHARACTER FORMAT "X(256)":U INITIAL "Правила определения мин.цены алкоголя"
      VIEW-AS TEXT
     SIZE 37.38 BY 1 TOOLTIP "Для алкоголя"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-income-cli AS CHARACTER FORMAT "X(256)":U INITIAL "Внутренний поставщик"
      VIEW-AS TEXT
     SIZE 20.13 BY 1
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-increase-pc AS CHARACTER FORMAT "X(256)":U INITIAL "Торговая наценка %"
      VIEW-AS TEXT
     SIZE 19.75 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-level-dis AS CHARACTER FORMAT "X(256)":U INITIAL "Границы пороговой наценки"
      VIEW-AS TEXT
     SIZE 27 BY .67
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-notcorr AS CHARACTER FORMAT "X(256)":U INITIAL "Запрет на кор-ку рассчитанного заказа"
      VIEW-AS TEXT
     SIZE 37.38 BY 1 TOOLTIP "Для заказов ОП"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-rmethod AS CHARACTER FORMAT "X(256)":U INITIAL "Метод округления"
      VIEW-AS TEXT
     SIZE 16.13 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE IMAGE l-alc-min-price
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1.
DEFINE IMAGE l-income-cli
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1.
DEFINE IMAGE l-increase-pc
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-level-dis
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1 TOOLTIP "Для пороговых наценок".
DEFINE IMAGE l-marg
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-marg-pr-paraf
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE IMAGE l-notcorr
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY 1 TOOLTIP "Для заказов ОП".
DEFINE IMAGE l-rmethod
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.
DEFINE VARIABLE RS-option AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3",
"Item 4", "4"
     SIZE 38.13 BY 3.71 NO-UNDO.
DEFINE VARIABLE S-round-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 20.38 BY 6.04 NO-UNDO.
DEFINE VARIABLE n-alchol AS LOGICAL INITIAL no
     LABEL "По умолчанию алкоголь"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-ban-sales-via-cd AS LOGICAL INITIAL no
     LABEL "Запрет продажи через кассу"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-mark AS LOGICAL INITIAL no
     LABEL "По умолчанию обязательная маркировка"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE n-no-inc-auto-rep AS LOGICAL INITIAL no
     LABEL "Не учитывать в автоматической отчетности"
     VIEW-AS TOGGLE-BOX
     SIZE 45 BY 1
     FGCOLOR 3  NO-UNDO.
DEFINE QUERY br-level-dis FOR
      tt-level-dis-attr SCROLLING.
DEFINE QUERY BR-temp_obj-list FOR
      temp_obj-list SCROLLING.
DEFINE BROWSE br-level-dis
  QUERY br-level-dis NO-LOCK DISPLAY
      tt-level-dis-attr.attr-code COLUMN-LABEL "Интервал" FORMAT "X(15)":U
      tt-level-dis-attr.attr-value COLUMN-LABEL "% Наценки" FORMAT "X(15)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 31.5 BY 4.5 FIT-LAST-COLUMN.
DEFINE BROWSE BR-temp_obj-list
  QUERY BR-temp_obj-list DISPLAY
      temp_obj-list.obj-type  + chr(32) + string(temp_obj-list.obj-code)
    WITH NO-LABELS NO-ROW-MARKERS SEPARATORS SIZE 15 BY 9.58
         TITLE "Список объектов".
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 57
     n-no-inc-auto-rep AT ROW 3 COL 65
     n-ban-sales-via-cd AT ROW 4 COL 65
     BR-temp_obj-list AT ROW 4.13 COL 47.63
     RS-option AT ROW 4.17 COL 2 NO-LABEL
     n-alchol AT ROW 6 COL 65
     n-mark AT ROW 7 COL 65
     fill-sum-grp AT ROW 8 COL 88.38 COLON-ALIGNED
     r-sum-grp AT ROW 8 COL 101.13
     fi-increase-pc AT ROW 8.67 COL 31.88 RIGHT-ALIGNED NO-LABEL
     c-mark-type AT ROW 9.33 COL 79 COLON-ALIGNED WIDGET-ID 50
     c-EMRC-type AT ROW 10.5 COL 79 COLON-ALIGNED WIDGET-ID 50
     n-marg AT ROW 10.29 COL 2.13 NO-LABEL
     fi-marg-min AT ROW 10.38 COL 32.13 RIGHT-ALIGNED NO-LABEL
     fi-marg-max AT ROW 11.38 COL 32.13 RIGHT-ALIGNED NO-LABEL
     S-round-method AT ROW 13.08 COL 23.13 NO-LABEL
     F-base AT ROW 15.38 COL 42.63 COLON-ALIGNED NO-LABEL
     fi-cli-type AT ROW 19.42 COL 24.88 RIGHT-ALIGNED NO-LABEL
     fi-cli-code AT ROW 19.42 COL 31.25 RIGHT-ALIGNED NO-LABEL
     r-cli AT ROW 19.42 COL 32.5
     fi-cli-name AT ROW 19.42 COL 62.38 RIGHT-ALIGNED NO-LABEL
     fi-notcorr AT ROW 20.75 COL 36.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     fi-alc-min-price AT ROW 21.75 COL 62.5 RIGHT-ALIGNED NO-LABEL WIDGET-ID 12
     br-level-dis AT ROW 24 COL 1.13 WIDGET-ID 200
     n-marg-pr-paraf AT ROW 24 COL 36.5 NO-LABEL WIDGET-ID 44
     fi-marg-pr-paraf AT ROW 24 COL 62 RIGHT-ALIGNED NO-LABEL
     B-add AT ROW 28.54 COL 2 WIDGET-ID 12
     B-chg AT ROW 28.54 COL 12 WIDGET-ID 14
     B-del AT ROW 28.54 COL 22 WIDGET-ID 16
     fi-grp-name AT ROW 3.08 COL 2 COLON-ALIGNED NO-LABEL
     n-increase-pc AT ROW 8.63 COL 2 NO-LABEL
     l-min AT ROW 10.25 COL 35.5 COLON-ALIGNED NO-LABEL
     l-max AT ROW 11.5 COL 35.5 COLON-ALIGNED NO-LABEL
     n-rmethod AT ROW 13.08 COL 5.88 NO-LABEL
     n-income-cli AT ROW 19.42 COL 1.13 NO-LABEL
     n-notcorr AT ROW 20.63 COL 1.13 NO-LABEL WIDGET-ID 6
     n-alc-min-price AT ROW 21.75 COL 1 NO-LABEL WIDGET-ID 10
     n-level-dis AT ROW 23 COL 1.13 NO-LABEL
     l-income-cli AT ROW 19.42 COL 64
     l-marg AT ROW 10.71 COL 34.75
     l-marg-pr-paraf AT ROW 24 COL 64
     l-rmethod AT ROW 13.17 COL 44.13
     l-increase-pc AT ROW 8.63 COL 34.75
     l-notcorr AT ROW 20.75 COL 46.5 WIDGET-ID 4
     l-alc-min-price AT ROW 21.75 COL 64 WIDGET-ID 16
     l-level-dis AT ROW 23 COL 28 WIDGET-ID 42
     SPACE(79.12) SKIP(5.55)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры на объектах для группы товаров"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       n-marg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       n-marg-pr-paraf:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run proc-b-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO :
 define variable v-pole1 as character no-undo .
 define variable v-pole2 as character no-undo .
  run str/lvldsc.w ( input-output v-pole1 , input-output v-pole2 ) .
  create tt-level-dis-attr.
  assign
    tt-level-dis-attr.attr-code  = v-pole1
    tt-level-dis-attr.attr-value = v-pole2
  no-error
  .
  if error-status :error then do:
    message
      "Пороговая наценка," skip
      "где интервал " v-pole1 skip
      "наценка " v-pole2 "," skip
      "уже есть."
    view-as alert-box error.
    delete tt-level-dis-attr.
  end.
  else do:
    OPEN QUERY br-level-dis FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BR-temp_obj-list FOR EACH temp_obj-list.
  end.
END.
ON RIGHT-MOUSE-CLICK OF br-level-dis IN FRAME Dialog-Frame
DO:
    assign
    n-level-dis:fgcolor = 3
    l-level-dis:visible = true
    .
    for each tt-level-dis-attr.
      delete tt-level-dis-attr.
    end.
    hide
    br-level-dis
    B-add
    B-chg
    B-del
    in frame Dialog-Frame.
    ENABLE l-level-dis
    with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF fi-marg-pr-paraf IN FRAME Dialog-Frame
DO:
    assign
    n-marg-pr-paraf:fgcolor = 15
    l-marg-pr-paraf:visible = true
    v-marg-pr-paraf = '':U
    .
    hide
    fi-marg-pr-paraf
    in frame Dialog-Frame.
    ENABLE l-marg-pr-paraf
    with frame Dialog-Frame.
END.
ON ENTRY OF fi-marg-max IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-marg-max:screen-value
.
END.
ON ENTRY OF fi-alc-min-price IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-alc-min-price :screen-value
.
END.
ON RIGHT-MOUSE-CLICK OF fi-alc-min-price IN FRAME Dialog-Frame
DO:
  assign
    n-alc-min-price:fgcolor = 3
    l-alc-min-price:visible = true
    v-alc-min-price = '':U
    .
    hide
    FI-alc-min-price
    in frame Dialog-Frame.
    ENABLE l-alc-min-price
    with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF fi-alc-min-price IN FRAME Dialog-Frame
DO:
  assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-alc-min-price :screen-value then no else yes )
.
END.
ON ENTRY OF fi-cli-code IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-cli-code:screen-value
.
END.
ON LEAVE OF fi-cli-code IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-cli-code:screen-value then no else yes )
.
 run leave-proc-cli in this-procedure .
END.
ON RIGHT-MOUSE-CLICK OF fi-cli-code IN FRAME Dialog-Frame
DO:
    assign
    n-income-cli:fgcolor = 3
    l-income-cli:visible = true
    v-cli-type = '':U
    v-cli-code = 0
    .
    hide
    FI-cli-type
    FI-cli-code
    fi-cli-name
    r-cli
    in frame Dialog-Frame.
    ENABLE l-income-cli
    with frame Dialog-Frame.
END.
ON ENTRY OF fi-cli-type IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-cli-type :screen-value
.
END.
ON LEAVE OF fi-cli-type IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-cli-type :screen-value then no else yes )
.
END.
ON RIGHT-MOUSE-CLICK OF fi-cli-type IN FRAME Dialog-Frame
DO:
    assign
    n-income-cli:fgcolor = 3
    l-income-cli:visible = true
    v-cli-type = '':U
    v-cli-code = 0
    .
    hide
    FI-cli-type
    FI-cli-code
    r-cli
    fi-cli-name
    in frame Dialog-Frame.
    ENABLE l-income-cli
    with frame Dialog-Frame.
END.
ON ENTRY OF fi-increase-pc IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-marg-max:screen-value
.
END.
ON LEAVE OF fi-increase-pc IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-increase-pc:screen-value then no else yes )
.
END.
ON RIGHT-MOUSE-CLICK OF fi-increase-pc IN FRAME Dialog-Frame
DO:
   if p-option = "global" then return no-apply.
    assign
    n-increase-pc:fgcolor = 15
    l-increase-pc:visible = true
    v-increase-pc = ?
    .
    hide
    fi-increase-pc
    in frame Dialog-Frame.
    ENABLE l-increase-pc
    with frame Dialog-Frame.
END.
ON LEAVE OF fi-marg-max IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-marg-max:screen-value then no else yes )
.
END.
ON RIGHT-MOUSE-CLICK OF fi-marg-max IN FRAME Dialog-Frame
DO:
    assign
    n-MARG:fgcolor = 15
    l-MARG:visible = true
    v-marg-min = ?
    v-marg-max = ?
    .
    hide
    FI-MARG-MIN
    FI-MARG-MAX
    in frame Dialog-Frame.
    ENABLE l-marg
    with frame Dialog-Frame.
END.
ON ENTRY OF fi-marg-min IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-marg-min :screen-value
.
END.
ON LEAVE OF fi-marg-min IN FRAME Dialog-Frame
DO:
assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-marg-min :screen-value then no else yes )
.
END.
ON RIGHT-MOUSE-CLICK OF fi-marg-min IN FRAME Dialog-Frame
DO:
    assign
    n-MARG:fgcolor = 15
    l-MARG:visible = true
    v-marg-min = ?
    v-marg-max = ?
    .
    hide
    FI-MARG-MIN
    FI-MARG-MAX
    in frame Dialog-Frame.
    ENABLE l-marg
    with frame Dialog-Frame.
END.
ON ENTRY OF fi-notcorr IN FRAME Dialog-Frame
DO:
assign
    v-old-value = fi-notcorr :screen-value
.
END.
ON RIGHT-MOUSE-CLICK OF fi-notcorr IN FRAME Dialog-Frame
DO:
  assign
    n-notcorr:fgcolor = 3
    l-notcorr:visible = true
    v-notcorr = '':U
    .
    hide
    FI-notcorr
    in frame Dialog-Frame.
    ENABLE l-notcorr
    with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF fi-notcorr IN FRAME Dialog-Frame
DO:
  assign
    v-value-changed = ( if v-value-changed = no and v-old-value = fi-notcorr :screen-value then no else yes )
.
END.
ON MOUSE-SELECT-CLICK OF l-alc-min-price IN FRAME Dialog-Frame
DO:
  IF l-alc-min-price:visible then do:
    assign
    n-alc-min-price:fgcolor = ?
    l-alc-min-price:visible = false.
    enable
    fi-alc-min-price
    with frame Dialog-Frame.
    display
     fi-alc-min-price
    with frame Dialog-Frame.
    APPLY "ENTRY" TO fi-alc-min-price.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-income-cli IN FRAME Dialog-Frame
DO:
  IF l-income-cli:visible then do:
    assign
    n-income-cli:fgcolor = ?
    l-income-cli:visible = false.
    enable
    fi-cli-type
    fi-cli-code
    r-cli
    with frame Dialog-Frame.
    display
    v-cli-type @ fi-cli-type
    v-cli-code @ fi-cli-code
    v-cli-name @ fi-cli-name
    with frame Dialog-Frame.
    APPLY "ENTRY" TO fi-cli-type.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-increase-pc IN FRAME Dialog-Frame
DO:
  IF l-increase-pc:visible then do:
    assign
    n-increase-pc:fgcolor = ?
    l-increase-pc:visible = false.
    enable fi-increase-pc with frame Dialog-Frame.
    display v-increase-pc @ fi-increase-pc
        with frame Dialog-Frame.
    APPLY "ENTRY" TO fi-increase-pc.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-level-dis IN FRAME Dialog-Frame
DO:
  IF l-level-dis:visible then do:
    assign
    n-level-dis:fgcolor = ?
    l-level-dis:visible = false.
    enable
    br-level-dis
    B-add
    B-chg
    B-del
    with frame Dialog-Frame.
    display
    br-level-dis
    B-add
    B-chg
    B-del
    with frame Dialog-Frame.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-marg IN FRAME Dialog-Frame
DO:
  IF l-marg:visible then do:
    assign
    n-marg:fgcolor = ?
    l-marg:visible = false.
    enable
    fi-marg-min
    fi-marg-max
    with frame Dialog-Frame.
    display
    v-marg-min @ fi-marg-min
    v-marg-max @ fi-marg-max
    with frame Dialog-Frame.
    APPLY "ENTRY" TO fi-MARG-MIN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-marg-pr-paraf IN FRAME Dialog-Frame
DO:
  IF l-marg-pr-paraf:visible then do:
    assign
    n-marg-pr-paraf:fgcolor = ?
    l-marg-pr-paraf:visible = false.
    enable
    fi-marg-pr-paraf
    with frame Dialog-Frame.
    display
    fi-marg-pr-paraf
    v-marg-pr-paraf @ fi-marg-pr-paraf
    with frame Dialog-Frame.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-notcorr IN FRAME Dialog-Frame
DO:
  IF l-notcorr:visible then do:
    assign
    n-notcorr:fgcolor = ?
    l-notcorr:visible = false.
    enable
    fi-notcorr
    with frame Dialog-Frame.
    display
     fi-notcorr
    with frame Dialog-Frame.
    APPLY "ENTRY" TO fi-notcorr.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-rmethod IN FRAME Dialog-Frame
DO:
  IF l-rmethod:visible then do:
    assign
    n-rmethod:fgcolor = ?
    l-rmethod:visible = false.
    enable
    s-round-method
    with frame Dialog-Frame.
    assign
    s-round-method:screen-value = v-round-method.
    APPLY "ENTRY" TO s-round-method.
    APPLY "VALUE-CHANGED" to S-round-method.
  end.
END.
ON VALUE-CHANGED OF n-alchol IN FRAME Dialog-Frame
DO:
  IF n-alchol:checked then do:
      enable n-mark
      with frame Dialog-Frame.
  end.
  else hide
    n-mark  in frame Dialog-Frame
  .
END.
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF r-sum-grp IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE rid-list as character no-undo .
define buffer buf_sum-grp for ub.sum-grp.
    run ref/sum-grps.w ( input parparentproc
                        ,input "b-sel"
                        ,input-output rid-list).
    if rid-list <> "":U then do:
      find first buf_sum-grp no-lock where
                 recid(buf_sum-grp) = integer(entry(1, rid-list)) no-error .
      assign
      v-sum-grp = buf_sum-grp.grp-code
      .
    end.
    else v-sum-grp = 0 .
      fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF S-round-method IN FRAME Dialog-Frame
DO:
   if p-option = "global" then return no-apply.
    assign
    n-rmethod:fgcolor = 15
    l-rmethod:visible = true
    v-round-method = '':U
    .
    hide
    s-round-method
    f-base
    in frame Dialog-Frame.
    ENABLE l-rmethod
    with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF S-round-method IN FRAME Dialog-Frame
DO:
    assign
  S-round-method
  .
  if lookup(S-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0 then do:
    display
    f-base
    with frame Dialog-Frame.
    enable
    f-base
    with frame Dialog-Frame.
  end.
  else do:
    hide
    f-base
    in frame Dialog-Frame.
    disable
    f-base
    with frame Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        v-diasize-browse-handle     = browse br-level-dis :handle
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
on choose of r-cli in frame dialog-frame
do:
   run proc-r-cli in this-procedure no-error .
   if error-status :error then
      return no-apply.
end.
on mouse-select-dblclick of fi-cli-code in frame Dialog-Frame
do:
  apply "CHOOSE" to r-cli in frame Dialog-Frame.
  return no-apply .
end.
on mouse-select-dblclick of fi-cli-type in frame Dialog-Frame
do:
  apply "CHOOSE" to r-cli in frame Dialog-Frame.
  return no-apply .
end.
procedure proc-r-cli :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
 define variable v-recid as recid no-undo .
 define variable old-types as character no-undo .
 define variable v-host-code like ub.sysconf.host-code no-undo .
 define buffer cli#clients for ub.clients.
 define variable v-user-select as logical   no-undo .
 define variable v-obj-type    as character no-undo .
 define variable v-obj-code    as integer   no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
  if v-user-select <> true
  then do:
    return error return-value .
  end.
    find first cli#clients no-lock
      where cli#clients.obj-type = v-obj-type
        and cli#clients.obj-code = v-obj-code
         no-error.
    if avail cli#clients then
        assign
            fi-cli-type = cli#clients.obj-type
            fi-cli-code = cli#clients.obj-code
            fi-cli-name = cli#clients.obj-name
            .
    else
       assign
          fi-cli-type = ""
          fi-cli-name = ""
          fi-cli-code = ?
          .
    display
        fi-cli-type
        fi-cli-name
        fi-cli-code
        with frame Dialog-Frame .
end.
end procedure.
procedure leave-proc-cli :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  def buffer buf_clients for ub.clients.
  assign frame Dialog-Frame
     fi-cli-type
     fi-cli-code
      .
  if fi-cli-code <> ? and fi-cli-code <> 0 and
     fi-cli-type <> ? and fi-cli-type <> ""
      then do:
      find first buf_clients no-lock where
                buf_clients.obj-type =  fi-cli-type  and
                buf_clients.obj-code  = fi-cli-code no-error.
          if error-status :error or not available buf_clients then do:
              message "Неправильно задан "  fi-cli-code:label in frame Dialog-Frame.
                assign
                fi-cli-type = ""
                fi-cli-name = ""
                fi-cli-code = ?
                .
              display
              fi-cli-type
              fi-cli-name
              fi-cli-code
              with frame Dialog-Frame.
              apply "CHOOSE" to r-cli in frame Dialog-Frame .
          end.
          if available buf_clients then do:
                fi-cli-type  = buf_clients.obj-type .
                fi-cli-name  = buf_clients.obj-name .
                fi-cli-code  = buf_clients.obj-code .
          end.
 end.
 else do:
      assign
        fi-cli-type = ""
        fi-cli-name = ""
        fi-cli-code = ?
        .
  end.
 display
  fi-cli-type
  fi-cli-name
  fi-cli-code
  with frame Dialog-Frame.
 end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if NOT (p-mode = 'ДОБАВЛЕНИЕ':U or p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ПРОСМОТР':U) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-mode" p-mode
        view-as alert-box ERROR.
        undo, return error.
    end.
  find first ub.gds-grp where
                ub.gds-grp.node-code = p-node-code no-error.
    if not avail ub.gds-grp then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-node-code" p-node-code
            view-as alert-box ERROR.
            undo, return error.
    end.
    run grplib-get-full-name in this-procedure( input p-node-code,
                                                                        output v-full-name) no-error.
  CASE p-option:
    when 'фирма':U then do:
      find first ub.sysconf no-lock where
                  ub.sysconf.host-code = p-host-code no-error.
    if not avail ub.sysconf then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-host-code" p-host-code
            view-as alert-box ERROR.
            undo, return error.
    end.
        find first ub.clients no-lock where
                  ub.clients.obj-type = 'орг':U
              AND ub.clients.obj-code = p-host-code.
    assign
      v-host-name = replace(ub.clients.obj-name, chr(44), chr(32)).
    end.
    when 'объект':U then do:
        find first ub.clients no-lock where
                  ub.clients.obj-type = p-obj-type
              AND ub.clients.obj-code = p-obj-code no-error.
    if not avail ub.clieNts then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров вызова p-obj-type и/или p-obj-code host-code" p-obj-type p-obj-code
            view-as alert-box ERROR.
            undo, return error.
        end.
    end.
  END CASE.
  RUN FILL-TABLES IN THIS-PROCEDURE NO-ERROR.
  if error-status:error then  do:
    undo, return error.
  end.
  RUN MYenable.
  run proc-load.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE create-attr :
do
on error undo, return error
:
  define input parameter v-min-marg           as decimal                  no-undo .
  define input parameter v-max-marg           as decimal                  no-undo .
  define input parameter v-increase-pc        like ub.gds-grp.increase-pc no-undo .
  define input parameter v-round-method       as character                no-undo .
  define input parameter v-base               as decimal                  no-undo .
  define input parameter v-cli-type           as character                no-undo .
  define input parameter v-cli-code           as integer                  no-undo .
  define input parameter v-notcorr            as character                no-undo .
  define input parameter v-alc-min-price      as character                no-undo .
  define input parameter v-marg-pr-paraf      as character                no-undo .
  define input parameter v-level-dis-attr     as character                no-undo .
  define input parameter v-no-inc-auto-rep    as character                no-undo .
  define input parameter v-ban-sales-via-cd   as character                no-undo .
  define input parameter v-alchol             as character                no-undo .
  define input parameter v-mark               as character                no-undo .
  define input parameter v-sum-grp            as character                no-undo .
  define input parameter v-mark-type          as character                no-undo .
  define input parameter v-emrc-type          as character                no-undo .
  DEFINE VARIABLE v-node-code  like ub.gds-grp.node-code  no-undo .
  DEFINE VARIABLE v-upper-code like ub.gds-grp.upper-code no-undo .
  DEFINE VARIABLE v-delete     as logical                 no-undo .
  DEFINE VARIABLE rid as recid no-undo.
define buffer buf_clients   for ub.clients.
if fi-cli-type:visible in frame  Dialog-Frame  then do:
    if v-cli-type = ""
        then do:
          message "Не верно введен тип поставщика! "  view-as alert-box information .
          return error .
        end.
    if v-cli-code = 0
        then do:
          message "Не верно введен код поставщика! "  view-as alert-box information .
          return error .
        end.
    if not( v-cli-type = 'маг':U or
      v-cli-type = 'скл':U )
        then do:
          message "Не верно введен тип поставщика! Может быть только магазин или склад ! "  v-cli-type view-as alert-box information .
          return error .
        end.
  find first buf_clients no-lock
      where buf_clients.obj-type = v-cli-type
        and buf_clients.obj-code = v-cli-code
  no-error.
  if not available buf_clients
  then do:
    message "Такого " v-cli-type v-cli-code " нет в справочнике клиентов ! "   view-as alert-box information .
    return error .
  end.
end.
  if v-min-marg <> ? and
  v-min-marg > v-max-marg then do:
      message
      "Минимальная наценка не может быть больше максимальной. Наценки не могут быть заданы."
      view-as alert-box error.
      return error.
  end.
  if (v-min-marg = ? ) <> (v-max-marg = ?) then do:
    message
    "Нельзя задать только одну границу диапазона"
    view-as alert-box  error .
    return error .
  end.
  if v-min-marg = ? and v-max-marg = ? and v-increase-pc = ? and
     v-cli-type = "":U and v-cli-code = 0 and
    (v-round-method = "":U or v-round-method = ?) then do:
      message
      "Вы не задали ни торговую наценку, ни диапазон торговых наценок, ни метод округления"
      view-as alert-box error.
      return error.
  end.
  if v-increase-pc = ? and p-option = "global" then do:
    message
    "Нельзя запретить корневое значение торговой наценки"
    view-as alert-box error .
    return error.
  end.
  if lookup(v-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0 and
    v-base = 0 then do:
    message
    "Введите ненулевое значение коэффициента!"
    view-as alert-box error .
    return error.
  end.
  case p-option :
    when "global":U then do:
      assign
      v-node-code = ub.gds-grp.node-code
      v-upper-code = ub.gds-grp.upper-code
      .
      run ref/gdsgrp01.p (
              input 'ИЗМЕНЕНИЕ':U
              ,input no
              ,input no
              ,input no
              ,input-output  v-node-code
              ,input-output  v-upper-code
              ,input gds-grp.node-name
              ,input gds-grp.calc-method
              ,input v-increase-pc
              ,input v-round-method
              ,input v-base
              ,output rid
              ) no-error .
      run grp-obj-write in this-procedure (
            input p-node-code
          , input 0
          , input ""
          , input 0
          , input v-min-marg
          , input v-max-marg
          , input v-increase-pc
          , input gds-grp.calc-method
          , input v-round-method
          , input v-base
          , input v-cli-type
          , input v-cli-code
      ) no-error.
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   0
        ,input   ""
        ,input   0
        ,input   'NotCorrOP':U
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   0
        ,input   ""
        ,input   0
        ,input   'alc-min-price':U
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'marg-pr-paraf':U
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'marg-pr-paraf':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'level-dis':U
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'level-dis':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'no-inc-auto-rep':U
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'no-inc-auto-rep':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'ban-sales-via-cd':U
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'ban-sales-via-cd':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-alchol <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'alchol-grp':U
          ,input   v-alchol
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'alchol-grp':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'mark-grp':U
          ,input   v-mark
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'mark-grp':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-sum-grp <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'sum-grps':U
          ,input   v-sum-grp
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
       end.
       else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'sum-grps':U
          ,output  v-sum-grp
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark-type <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'gg-mark-type':U
          ,input   v-mark-type
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
       end.
       else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'gg-mark-type':U
          ,output  v-mark-type
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
               define buffer buf_goods-attr for ub.goods-attr .
               define buffer buf_goods      for ub.goods .
               define variable v-ask        as character no-undo .
               define variable v-price-emc  as decimal   no-undo .
               define variable v-value-emrc as character no-undo .
               define variable v-type-emrc  as character no-undo .
               define variable v-del        as logical   no-undo .
               define variable choice       as integer   no-undo .
               empty temp-table tt-goods .
               for each buf_goods no-lock where buf_goods.grp-code = p-node-code:
                  run gds-attr-value (
                     input   buf_goods.gds-code
                     ,input   'emrc-type':U
                     ,output   v-value-emrc
                     ,output   v-type-emrc
                     ) no-error .
                  if v-value-emrc <> v-emrc-type then
                  do:
                     create tt-goods .
                     buffer-copy buf_goods to tt-goods .
                     for first ub.Code where ub.Code.parent = "emc" and
                        ub.Code.Code = v-value-emrc no-lock:
                        tt-goods.emrc = ub.Code.CodeName .
                     end.
                  end.
               end.
               if can-find (first tt-goods) then
               do:
                  run ref/emrc-mes.w (input parparentproc,
                     input table tt-goods,
                     output v-ask)  .
               end.
               case v-ask:
                  when "cancel" then
                     do:
                        leave .
                     end.
                  when "true" then
                     do:
                        for each tt-goods:
                           run gds-attr-delete IN THIS-PROCEDURE(
                              input tt-goods.gds-code
                              ,INPUT 'emrc-type':U
                              ,output v-del ) .
                        end.
                     end.
                  when "false" then
                     do:
                     end.
               end case .
               find last ub.Code no-lock where ub.Code.parent = "emc" + chr(4) + v-emrc-type and
                  ub.Code.status_ = 0 and ub.Code.code <= iso-date(today) no-error .
               if available (ub.Code) then
               do:
                  run gbl/d-askw.w (
                     input "Вопрос"
                     ,input  "Проверить цены товара на соответствие ЕМЦ?"
                     ,input "|"
                     ,input "Да|Нет"
                     ,input "Установить ЕМЦ и провести проверку по всем объектам|Установить ЕМЦ без проверки"
                     ,input 1
                     ,input 2
                     ,output choice).
                  if choice = 1 then
                  do:
                     v-price-emc = decimal(ub.Code.CodeValue) .
                     for each buf_clients no-lock where buf_clients.host-code = v-cntxt-host-code-obj and
                        buf_clients.obj-type = 'маг':U:
                        for each buf_goods no-lock where buf_goods.grp-code = p-node-code,
                           last ub.price-all no-lock where ub.price-all.gds-code = buf_goods.gds-code and
                           ub.price-all.obj-code = buf_clients.obj-code and
                           ub.price-all.obj-type = buf_clients.obj-type and
                           ub.price-all.main-indication = 0 and
                           ub.price-all.type-price = 0:
                           if ub.price-all.price-sale < v-price-emc then
                           do:
                              create tt-emc-price .
                              assign
                                 tt-emc-price.gds-name = buf_goods.gds-name
                                 tt-emc-price.gds-code = buf_goods.gds-code
                                 tt-emc-price.price    = ub.price-all.price-sale
                                 tt-emc-price.obj-code = buf_clients.obj-code
                                 tt-emc-price.obj-type = buf_clients.obj-type
                                 .
                           end.
                        end.
                     end.
                     if can-find (first tt-emc-price) then
                     do:
                        run print-list (input v-price-emc,
                           input table tt-emc-price).
                     end.
                     else
                     do:
                        message "Несоответствий товаров по ЕМЦ - не найдено."
                           view-as alert-box.
                     end.
                  end.
               end.
               else
               do:
                  if c-emrc-type <> "" then
                  do:
                     find last ub.Code no-lock where ub.Code.parent = "emc" + chr(4) + v-emrc-type and
                        ub.Code.status_ = 0 and ub.Code.code > iso-date(today) no-error .
                     if available (ub.Code) then
                     do:
                        message "Для выбранного типа ЕМЦ установлено ограничение, которое станет активным только с " ub.Code.misc1
                           view-as alert-box.
                     end.
                     else
                     do:
                        message "Для выбранного типа ЕМЦ не установлено ни одного значения." skip
                           "Для корректной работы добавьте актуальное значение ЕМЦ"
                           view-as alert-box.
                     end.
                  end.
               end.
               if v-emrc-type <> ""
                  then
               do:
                  run ggoattr-write (
                     input   p-node-code
                     ,input   0
                     ,input   ""
                     ,input   0
                     ,input   'emrc-type':U
                     ,input   v-emrc-type
                     ) no-error .
                  if error-status :error then
                  do:
                     undo, return error.
                  end.
               end.
               else
               do:
                  run ggoattr-delete (
                     input   p-node-code
                     ,input   0
                     ,input   ""
                     ,input   0
                     ,input   'emrc-type':U
                     ,output  v-emrc-type
                     ) no-error .
                  if error-status :error then
                  do:
                     undo, return error.
                  end.
               end.
            end.
    when 'фирма':U then do:
      run grp-obj-write in this-procedure (
              input p-node-code
            , input p-host-code
            , input ""
            , input 0
            , input v-min-marg
            , input v-max-marg
            , input v-increase-pc
            , input gds-grp.calc-method
            , input v-round-method
            , input v-base
            , input v-cli-type
            , input v-cli-code
        ) no-error.
      if error-status :error
      then do:
          undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   ""
        ,input   0
        ,input   'NotCorrOP':U
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   ""
        ,input   0
        ,input   'alc-min-price':U
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'marg-pr-paraf':U
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'marg-pr-paraf':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'level-dis':U
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'level-dis':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'no-inc-auto-rep':U
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'no-inc-auto-rep':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'ban-sales-via-cd':U
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   ""
          ,input   0
          ,input   'ban-sales-via-cd':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
            if v-alchol <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'alchol-grp':U
          ,input   v-alchol
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'alchol-grp':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'mark-grp':U
          ,input   v-mark
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'mark-grp':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
    end.
    when 'объект':U then do:
    run grp-obj-write in this-procedure (
            input p-node-code
          , input p-host-code
          , input p-obj-type
          , input p-obj-code
          , input v-min-marg
          , input v-max-marg
          , input v-increase-pc
          , input gds-grp.calc-method
          , input v-round-method
          , input v-base
          , input v-cli-type
          , input v-cli-code
      ) no-error.
      if error-status :error
      then do:
          undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   p-obj-type
        ,input   p-obj-code
        ,input   'NotCorrOP':U
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   p-host-code
        ,input   p-obj-type
        ,input   p-obj-code
        ,input   'alc-min-price':U
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'marg-pr-paraf':U
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'marg-pr-paraf':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'level-dis':U
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'level-dis':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'no-inc-auto-rep':U
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'no-inc-auto-rep':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'ban-sales-via-cd':U
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   p-host-code
          ,input   p-obj-type
          ,input   p-obj-code
          ,input   'ban-sales-via-cd':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
    end.
    when "object-list":U then do:
      for each temp_obj-list:
        run grp-obj-write in this-procedure (
              input p-node-code
            , input temp_obj-list.host-code
            , input temp_obj-list.obj-type
            , input temp_obj-list.obj-code
            , input v-min-marg
            , input v-max-marg
            , input v-increase-pc
            , input gds-grp.calc-method
            , input v-round-method
            , input v-base
            , input v-cli-type
            , input v-cli-code
        ) no-error.
        if error-status :error
          then do:
              undo, return error.
        end.
      run ggoattr-write (
         input   p-node-code
        ,input   temp_obj-list.host-code
        ,input   temp_obj-list.obj-type
        ,input   temp_obj-list.obj-code
        ,input   'NotCorrOP':U
        ,input   v-notcorr
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      run ggoattr-write (
         input   p-node-code
        ,input   temp_obj-list.host-code
        ,input   temp_obj-list.obj-type
        ,input   temp_obj-list.obj-code
        ,input   'alc-min-price':U
        ,input   v-alc-min-price
        ) no-error .
      if error-status :error then do:
        undo, return error.
      end.
      if v-marg-pr-paraf <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'marg-pr-paraf':U
          ,input   v-marg-pr-paraf
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'marg-pr-paraf':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-level-dis-attr <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'level-dis':U
          ,input   v-level-dis-attr
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'level-dis':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-no-inc-auto-rep <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'no-inc-auto-rep':U
          ,input   v-no-inc-auto-rep
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'no-inc-auto-rep':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-ban-sales-via-cd <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'ban-sales-via-cd':U
          ,input   v-ban-sales-via-cd
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   temp_obj-list.host-code
          ,input   temp_obj-list.obj-type
          ,input   temp_obj-list.obj-code
          ,input   'ban-sales-via-cd':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
            if v-alchol <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'alchol-grp':U
          ,input   v-alchol
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'alchol-grp':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      if v-mark <> ""
      then do:
        run ggoattr-write (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'mark-grp':U
          ,input   v-mark
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      else do:
        run ggoattr-delete (
          input   p-node-code
          ,input   0
          ,input   ""
          ,input   0
          ,input   'mark-grp':U
          ,output  v-delete
          ) no-error .
        if error-status :error then do:
          undo, return error.
        end.
      end.
      end.
    end.
  end case.
end.
END PROCEDURE.
PROCEDURE proc-load :
define variable v-list as character no-undo.
define variable vi as integer no-undo.
define variable MarkType as ibs.th.gbl.map.mapstring no-undo.
define variable objType  as ibs.th.gbl.propmap no-undo.
MarkType = ObjSrv:Env:Marking:Types:MapType.
do vi = 1 to MarkType:GetItemByLab(vi):
   objType  = ObjSrv:Env:Marking:Types:CurrProp.
   v-list = v-list + "," + objType:Label_ + "," + objType:NameProp.
end.
v-list = trim(v-list, ",").
c-mark-type:list-item-pairs in frame Dialog-Frame = v-list.
v-list = "".
for each code where Code.parent eq "emc" no-lock:
      v-list = v-list + "," + Code.CodeName + "," + Code.code.
   end.
   v-list = "," + v-list .
   c-emrc-type:list-item-pairs in frame Dialog-Frame = v-list.
   if p-mode = 'ДОБАВЛЕНИЕ':U OR p-mode = 'ИЗМЕНЕНИЕ':U then
   do:
      enable c-mark-type c-emrc-type with frame Dialog-Frame.
   end.
   display c-mark-type c-emrc-type with frame Dialog-Frame.
   c-mark-type:visible in frame Dialog-Frame = p-option eq "global".
   c-emrc-type:visible in frame Dialog-Frame = p-option eq "global".
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-option fi-increase-pc n-marg fi-marg-min fi-marg-max S-round-method
          F-base fi-cli-type fi-cli-code fi-cli-name fi-notcorr fi-alc-min-price
          n-marg-pr-paraf fi-marg-pr-paraf fi-grp-name n-increase-pc l-min l-max n-rmethod
          n-income-cli n-notcorr n-alc-min-price n-level-dis fill-sum-grp r-sum-grp
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help l-income-cli l-marg l-marg-pr-paraf l-rmethod l-increase-pc
         l-notcorr l-alc-min-price l-level-dis BR-temp_obj-list RS-option
         fi-increase-pc fi-marg-min fi-marg-max S-round-method F-base
         fi-cli-type fi-cli-code r-cli fi-cli-name fi-notcorr fi-alc-min-price
         br-level-dis fi-marg-pr-paraf fi-grp-name n-increase-pc l-min l-max n-rmethod
         n-income-cli n-notcorr n-alc-min-price n-level-dis fill-sum-grp r-sum-grp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-level-dis FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BR-temp_obj-list FOR EACH temp_obj-list.
END PROCEDURE.
PROCEDURE fill-tables :
define variable v-obj-list as character no-undo.
define variable  v-host-code like ub.sysconf.host-code no-undo .
CASE p-option:
    when "global":U then do:
    CASE p-mode:
        when 'ИЗМЕНЕНИЕ':U then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = 0
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end.
        when 'ПРОСМОТР':U then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = 0
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end.
        END CASE.
    end.
    when 'фирма':U then do:
    CASE p-mode:
        when 'ДОБАВЛЕНИЕ':U then do:
            find first buf_gds-grp-obj no-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0 no-error.
           if avail buf_gds-grp-obj then do:
            message
            "Уже существует запись параметров группы товаров"
            "для фирмы" v-host-name
            view-as alert-box error.
            undo, return error.
          end.
        end.
        when 'ИЗМЕНЕНИЕ':U then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end.
        when 'ПРОСМОТР':U then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = "":U
                   AND buf_gds-grp-obj.obj-code = 0.
        end.
        END CASE.
    end.
    when 'объект':U then do:
    CASE p-mode:
        when 'ДОБАВЛЕНИЕ':U then do:
            find first buf_gds-grp-obj no-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = p-obj-type
                   AND buf_gds-grp-obj.obj-code = p-obj-code no-error.
           if avail buf_gds-grp-obj then do:
            message
            "Уже существует запись параметров группы товаров"
            "для объекта" p-obj-type p-obj-code
            view-as alert-box error.
            undo, return error.
          end.
        end.
        when 'ИЗМЕНЕНИЕ':U then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = p-obj-type
                   AND buf_gds-grp-obj.obj-code = p-obj-code.
        end.
        when 'ПРОСМОТР':U then do:
                    find first buf_gds-grp-obj exclusive-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = p-host-code
                   AND buf_gds-grp-obj.obj-type = p-obj-type
                   AND buf_gds-grp-obj.obj-code = p-obj-code.
        end.
        END CASE.
    end.
    when "object-list":U then do:
    CASE p-mode:
        when 'ДОБАВЛЕНИЕ':U
        then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
          define variable v-object-available as logical   no-undo .
define variable vss-include-info17 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-object-available
  )  .
          if v-object-available = true
          then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  p-obj-type
  ,input  p-obj-code
  )  .
          end.
          define variable v-user-select as logical   no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-user-select
  )  .
          if v-user-select <> true
          then do:
            message
              "Объект не выбран"
              view-as alert-box information .
            return .
          end.
          define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
          for each temp_obj-list:
              delete temp_obj-list.
          end.
          for each buf_userobjs_temp-user-obj
          on error undo, return error return-value
          :
              CASE buf_userobjs_temp-user-obj.obj-type:
                  when 'маг':U then do:
                      find first ub.shop no-lock where
                                  ub.shop.obj-code = buf_userobjs_temp-user-obj.obj-code.
                      assign
                      v-host-code = ub.shop.host-code.
                  end.
                  when 'скл':U then do:
                              find first ub.store no-lock where
                                  ub.store.obj-code = buf_userobjs_temp-user-obj.obj-code.
                      assign
                      v-host-code = ub.store.host-code.
                  end.
              END CASE.
              create temp_obj-list.
              assign
                  temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                  temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
                    temp_obj-list.host-code = v-host-code
              .
          end.
    llist:
    for each temp_obj-list:
            find first buf_gds-grp-obj no-lock where
                         buf_gds-grp-obj.node-code = p-node-code
                   AND buf_gds-grp-obj.host-code = temp_obj-list.host-code
                   AND buf_gds-grp-obj.obj-type = temp_obj-list.obj-type
                   AND buf_gds-grp-obj.obj-code = temp_obj-list.obj-code no-error.
           if avail buf_gds-grp-obj then do:
            message
            "Уже существует запись параметров группы товаров"
            "для объекта" temp_obj-list.obj-type temp_obj-list.obj-code
            view-as alert-box error.
            delete temp_obj-list.
            NEXT llist.
          end.
          end.
        end.
         END CASE.
    end.
END CASE.
if available buf_gds-grp-obj then do:
    assign
    v-marg-min     = buf_gds-grp-obj.min-increase
    v-marg-max     = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    v-cli-type     = buf_gds-grp-obj.cli-type
    v-cli-code     = buf_gds-grp-obj.cli-code
    .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'NotCorrOP':U
      ,output  v-notcorr
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'alc-min-price':U
      ,output  v-alc-min-price
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'marg-pr-paraf':U
      ,output  v-marg-pr-paraf
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'level-dis':U
      ,output  v-level-dis-attr
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'no-inc-auto-rep':U
      ,output  v-no-inc-auto-rep
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'ban-sales-via-cd':U
      ,output  v-ban-sales-via-cd
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'alchol-grp':U
      ,output  v-alchol
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'mark-grp':U
      ,output  v-mark
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'sum-grps':U
      ,output  v-sum-grp
      ,output  v-type ) no-error .
    run ggoattr-value (
       input   p-node-code
      ,input   buf_gds-grp-obj.host-code
      ,input   buf_gds-grp-obj.obj-type
      ,input   buf_gds-grp-obj.obj-code
      ,input   'gg-mark-type':U
      ,output  c-mark-type
      ,output  v-type ) no-error .
repeat ix = 1 to num-entries (v-level-dis-attr, chr(4)) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
end.
end.
else do:
    assign
    v-marg-min      = 0
    v-marg-max      = 0
    v-increase-pc   = 0
    v-round-method  = "":U
    v-base          = 0
    v-cli-type      = "":U
    v-notcorr       = "":U
    v-cli-code      = 0
    v-alc-min-price = "":U
    v-no-inc-auto-rep = "no"
    v-ban-sales-via-cd = "no"
    v-alchol        = "no"
    v-mark          = "no"
    v-sum-grp       = 0
    .
end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-value as character no-undo.
define variable v-type as character no-undo.
assign
s-round-method:list-items in frame Dialog-Frame = '9-окончание,9-99окончание,Без-дробных,Произвольно,Вверх,Коэффициент,Отключено':U.
f-base = v-base.
APPLY "VALUE-CHANGED" to s-round-method.
CASE p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
            assign
            RS-option:radio-buttons in frame Dialog-Frame =
                                                    "Фирма" + chr(32) + v-host-name + chr(44) + 'фирма':U + chr(44) +
                                                    "Объект" + chr(32) + p-obj-type + string(p-obj-code) + chr(44) + 'объект':U + chr(44) +
                                                    "Список объектов" + chr(44) + "object-list":U.
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
        assign
    RS-option:radio-buttons = "Глобально" + chr(44) + "global":U + chr(44) +
                                            "Фирма" + chr(44) + 'фирма':U + chr(44) +
                                            "Объект" + chr(44) + 'объект':U .
    end.
    when 'ПРОСМОТР':U then do:
        assign
    RS-option:radio-buttons = "Глобально" + chr(44) + "global":U + chr(44) +
                                            "Фирма" + chr(44) + 'фирма':U + chr(44) +
                                            "Объект" + chr(44) + 'объект':U .
    end.
END CASE.
assign
rs-option = p-option.
DISPLAY
n-marg
n-increase-pc
n-rmethod
n-income-cli
RS-option
v-full-name @ fi-grp-name
l-max l-min
n-notcorr
l-notcorr
n-alc-min-price
l-alc-min-price
n-level-dis
l-level-dis
n-marg-pr-paraf
n-no-inc-auto-rep
n-ban-sales-via-cd
WITH FRAME Dialog-Frame.
run Show-hide-lock in this-procedure.
ENABLE
b-quit
b-exit
B-Help
n-no-inc-auto-rep
n-ban-sales-via-cd
 WITH FRAME Dialog-Frame.
if p-option = "object-list":U then do:
    display
    BR-temp_obj-list
    with frame Dialog-Frame.
    enable
    BR-temp_obj-list
    with frame Dialog-Frame.
    OPEN QUERY br-level-dis FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.
end.
else do:
    hide
BR-temp_obj-list
    in frame Dialog-Frame.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-tm'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-value
  ,output v-type
  ) no-error .
v-value = "no".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-value
  ,output v-type
  ) no-error .
if v-value = "yes" then do:
    enable
    n-alchol
    with frame Dialog-Frame.
end.
if v-alchol = "yes" then do:
    enable
    n-mark
    with frame Dialog-Frame.
end.
enable
  fill-sum-grp
  r-sum-grp
  c-mark-type
  with frame Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
    disable
     B-exit
     B-Help
     BR-temp_obj-list
     RS-option
     fi-increase-pc
     n-marg
     fi-marg-min
     fi-marg-max
     S-round-method
     F-base
     fi-cli-type
     fi-cli-code
     r-cli
     fi-cli-name
     fi-notcorr
     fi-alc-min-price
     br-level-dis
     n-marg-pr-paraf
     fi-marg-pr-paraf
     fi-grp-name
     n-increase-pc
     l-min
     l-max
     n-rmethod
     n-no-inc-auto-rep
     n-ban-sales-via-cd
     n-alchol
     n-mark
     fill-sum-grp
     r-sum-grp
     n-income-cli
     n-notcorr
     n-alc-min-price
     n-level-dis
     l-income-cli
     l-marg
     l-marg-pr-paraf
     l-rmethod
     l-increase-pc
     l-notcorr
     c-mark-type
     l-alc-min-price
     l-level-dis
     B-add
     B-chg
     B-del  WITH FRAME Dialog-Frame.
    hide
     l-income-cli
     l-marg
     l-marg-pr-paraf
     l-rmethod
     l-increase-pc
     l-notcorr
     l-alc-min-price
     l-level-dis  in frame Dialog-Frame.
end.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-save :
assign
frame Dialog-Frame
n-no-inc-auto-rep
n-ban-sales-via-cd
n-alchol
n-mark
fill-sum-grp
fi-notcorr
fi-alc-min-price
fi-cli-type fi-cli-code
fi-marg-max fi-marg-min
fi-increase-pc
s-round-method
f-base
fi-marg-pr-paraf
c-mark-type
v-increase-pc  = if fi-increase-pc:sensitive
                 and fi-increase-pc:visible then fi-increase-pc else ?
v-marg-min  = if fi-marg-min:sensitive
              and fi-marg-min:visible then fi-marg-min else ?
v-marg-max  = if fi-marg-max:sensitive
              and fi-marg-max:visible
              then fi-marg-max else ?
v-round-method = if s-round-method:sensitive
                 and s-round-method:visible
                 then s-round-method else "":U
v-base         = if lookup(v-round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U) > 0
                  then f-base
                  else 0
v-cli-type   =  if fi-cli-type:sensitive
                and fi-cli-type:visible
                then fi-cli-type else "":U
v-cli-code   =  if fi-cli-code:sensitive
                and fi-cli-code:visible
                then fi-cli-code else 0
v-notcorr   =  if fi-notcorr:sensitive
                and fi-notcorr:visible
                then fi-notcorr else "":U
.
v-alc-min-price =  if  fi-alc-min-price:sensitive
                   and fi-alc-min-price:visible
                  then fi-alc-min-price else "":U
.
v-marg-pr-paraf =  if  fi-marg-pr-paraf:sensitive
                   and fi-marg-pr-paraf:visible
                  then string (fi-marg-pr-paraf) else "":U
.
if br-level-dis:sensitive and br-level-dis:visible
then do:
  assign
    v-level-dis-attr = ""
  .
  for each tt-level-dis-attr  :
    assign
      v-level-dis-attr = v-level-dis-attr + tt-level-dis-attr.attr-code + chr(44) + tt-level-dis-attr.attr-value + chr(4)
    .
  end.
end.
else do:
  assign
    v-level-dis-attr = ""
  .
end.
run create-attr in this-procedure ( input v-marg-min
                                   ,input v-marg-max
                                   ,input v-increase-pc
                                   ,input v-round-method
                                   ,input v-base
                                   ,input v-cli-type
                                   ,input v-cli-code
                                   ,input v-notcorr
                                   ,input v-alc-min-price
                                   ,input v-marg-pr-paraf
                                   ,input v-level-dis-attr
                                   ,input string(n-no-inc-auto-rep)
                                   ,input string(n-ban-sales-via-cd)
                                   ,input string(n-alchol)
                                   ,input string(n-mark)
                                   ,input fill-sum-grp
                                   ,input c-mark-type
                                   ,input c-emrc-type
                                  ) no-error.
if error-status:error then do:
   message error-status :get-message(1) .
   undo, return error.
end.
END PROCEDURE.
PROCEDURE show-hide-lock :
v-cli-name = func-cli-name (v-cli-type,v-cli-code) .
CASE p-mode:
  when 'ИЗМЕНЕНИЕ':U or when 'ПРОСМОТР':U then do:
    if v-marg-min <> ? and v-marg-max <> ? then do:
      display
      v-marg-min @ fi-marg-min
      v-marg-max @ fi-marg-max
      with frame Dialog-Frame
      .
      ENABLE
      fi-marg-max
      fi-marg-min
      with frame Dialog-Frame
      .
      hide
      l-marg
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-marg-max
      fi-marg-min
      in frame Dialog-Frame
      .
      ENABLE
      l-marg
      with frame Dialog-Frame.
      display
      l-marg
      with frame Dialog-Frame.
    end.
    if v-increase-pc <> ? then do:
      display
      v-increase-pc @ fi-increase-pc
      with frame Dialog-Frame
      .
      ENABLE
      fi-increase-pc
      with frame Dialog-Frame
      .
      assign
      n-increase-pc:fgcolor = ?
      .
      hide
      l-increase-pc
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-increase-pc
      in frame Dialog-Frame
      .
      ENABLE
      l-increase-pc
      with frame Dialog-Frame.
      display
      l-increase-pc
      with frame Dialog-Frame.
    end.
    if v-round-method <> "":U then do:
      assign
      s-round-method:screen-value = v-round-method
      .
      ENABLE
      s-round-method
      with frame Dialog-Frame
      .
      assign
      n-rmethod:fgcolor = ?
      .
      hide
      l-rmethod
      in frame Dialog-Frame
      .
      APPLY "VALUE-CHANGED" to s-round-method.
    end.
    else do:
      APPLY "VALUE-CHANGED" to s-round-method.
      hide
      s-round-method
      in frame Dialog-Frame
      .
      ENABLE
      l-rmethod
      with frame Dialog-Frame.
      display
      l-rmethod
      with frame Dialog-Frame.
    end.
    if v-cli-type <> "" and v-cli-code <> 0 then do:
      display
      v-cli-type @ fi-cli-type
      v-cli-code @ fi-cli-code
      v-cli-name @ fi-cli-name
      with frame Dialog-Frame
      .
      ENABLE
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      with frame Dialog-Frame
      .
      hide
      l-income-cli
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      in frame Dialog-Frame
      .
      ENABLE
      l-income-cli
      with frame Dialog-Frame.
      display
      l-income-cli
      with frame Dialog-Frame.
    end.
    if v-notcorr <> ""  then do:
      fi-notcorr = v-notcorr .
      display
       fi-notcorr
      with frame Dialog-Frame
      .
      ENABLE
      fi-notcorr
      with frame Dialog-Frame
      .
      hide
      l-notcorr
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-notcorr
      in frame Dialog-Frame
      .
      ENABLE
      l-notcorr
      with frame Dialog-Frame.
      display
      l-notcorr
      with frame Dialog-Frame.
    end.
    if v-alc-min-price <> ""  then do:
      fi-alc-min-price = v-alc-min-price .
      display
       fi-alc-min-price
      with frame Dialog-Frame
      .
      ENABLE
      fi-alc-min-price
      with frame Dialog-Frame
      .
      hide
      l-alc-min-price
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-alc-min-price
      in frame Dialog-Frame
      .
      ENABLE
      l-alc-min-price
      with frame Dialog-Frame.
      display
      l-alc-min-price
      with frame Dialog-Frame.
    end.
    if v-marg-pr-paraf <> ""  then do:
      fi-marg-pr-paraf = decimal (v-marg-pr-paraf).
      display
      fi-marg-pr-paraf
      with frame Dialog-Frame
      .
      ENABLE
      fi-marg-pr-paraf
      with frame Dialog-Frame
      .
      hide
      l-marg-pr-paraf
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-marg-pr-paraf
      in frame Dialog-Frame
      .
      ENABLE
      l-marg-pr-paraf
      with frame Dialog-Frame.
      display
      l-marg-pr-paraf
      with frame Dialog-Frame.
    end.
    if can-find (first tt-level-dis-attr) then do:
      OPEN QUERY br-level-dis FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BR-temp_obj-list FOR EACH temp_obj-list.
      display
      br-level-dis
      B-add
      B-chg
      B-del
      with frame Dialog-Frame
      .
      ENABLE
      br-level-dis
      B-add
      B-chg
      B-del
      with frame Dialog-Frame
      .
      hide
      l-level-dis
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      br-level-dis
      B-add
      B-chg
      B-del
      in frame Dialog-Frame
      .
      ENABLE
      l-level-dis
      with frame Dialog-Frame.
      display
      l-level-dis
      with frame Dialog-Frame.
    end.
    n-no-inc-auto-rep = logical(if v-no-inc-auto-rep = "" then "no" else v-no-inc-auto-rep).
    disp n-no-inc-auto-rep with frame Dialog-Frame.
    n-ban-sales-via-cd = logical(if v-ban-sales-via-cd = "" then "no" else v-ban-sales-via-cd).
    disp n-ban-sales-via-cd with frame Dialog-Frame.
    n-alchol = logical(if v-alchol = "" then "no" else v-alchol).
    display n-alchol with frame Dialog-Frame.
    n-mark = logical(if v-mark = "" then "no" else v-mark).
    display n-mark with frame Dialog-Frame.
    fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame Dialog-Frame.
  end.
    when 'ПРОСМОТР':U then do:
    if v-marg-min <> ? and v-marg-max <> ? then do:
      display
      v-marg-min @ fi-marg-min
      v-marg-max @ fi-marg-max
      with frame Dialog-Frame
      .
      ENABLE
      fi-marg-max
      fi-marg-min
      with frame Dialog-Frame
      .
      hide
      l-marg
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-marg-max
      fi-marg-min
      in frame Dialog-Frame
      .
      ENABLE
      l-marg
      with frame Dialog-Frame.
      display
      l-marg
      with frame Dialog-Frame.
    end.
    if v-increase-pc <> ? then do:
      display
      v-increase-pc @ fi-increase-pc
      with frame Dialog-Frame
      .
      ENABLE
      fi-increase-pc
      with frame Dialog-Frame
      .
      assign
      n-increase-pc:fgcolor = ?
      .
      hide
      l-increase-pc
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-increase-pc
      in frame Dialog-Frame
      .
      ENABLE
      l-increase-pc
      with frame Dialog-Frame.
      display
      l-increase-pc
      with frame Dialog-Frame.
    end.
    if v-round-method <> "":U then do:
      assign
      s-round-method:screen-value = v-round-method
      .
      ENABLE
      s-round-method
      with frame Dialog-Frame
      .
      assign
      n-rmethod:fgcolor = ?
      .
      hide
      l-rmethod
      in frame Dialog-Frame
      .
      APPLY "VALUE-CHANGED" to s-round-method.
    end.
    else do:
      APPLY "VALUE-CHANGED" to s-round-method.
      hide
      s-round-method
      in frame Dialog-Frame
      .
      ENABLE
      l-rmethod
      with frame Dialog-Frame.
      display
      l-rmethod
      with frame Dialog-Frame.
    end.
    if v-cli-type <> "" and v-cli-code <> 0 then do:
      display
      v-cli-type @ fi-cli-type
      v-cli-code @ fi-cli-code
      v-cli-name @ fi-cli-name
      with frame Dialog-Frame
      .
      ENABLE
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      with frame Dialog-Frame
      .
      hide
      l-income-cli
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-cli-type
      fi-cli-code
      r-cli
      fi-cli-name
      in frame Dialog-Frame
      .
      ENABLE
      l-income-cli
      with frame Dialog-Frame.
      display
      l-income-cli
      with frame Dialog-Frame.
    end.
    if v-notcorr <> ""  then do:
      fi-notcorr = v-notcorr .
      display
       fi-notcorr
      with frame Dialog-Frame
      .
      ENABLE
      fi-notcorr
      with frame Dialog-Frame
      .
      hide
      l-notcorr
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-notcorr
      in frame Dialog-Frame
      .
      ENABLE
      l-notcorr
      with frame Dialog-Frame.
      display
      l-notcorr
      with frame Dialog-Frame.
    end.
    if v-alc-min-price <> ""  then do:
      fi-alc-min-price = v-alc-min-price .
      display
       fi-alc-min-price
      with frame Dialog-Frame
      .
      ENABLE
      fi-alc-min-price
      with frame Dialog-Frame
      .
      hide
      l-alc-min-price
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-alc-min-price
      in frame Dialog-Frame
      .
      ENABLE
      l-alc-min-price
      with frame Dialog-Frame.
      display
      l-alc-min-price
      with frame Dialog-Frame.
    end.
    if v-marg-pr-paraf <> ""  then do:
      fi-marg-pr-paraf = decimal (v-marg-pr-paraf).
      display
      fi-marg-pr-paraf
      with frame Dialog-Frame
      .
      ENABLE
      fi-marg-pr-paraf
      with frame Dialog-Frame
      .
      hide
      l-marg-pr-paraf
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      fi-marg-pr-paraf
      in frame Dialog-Frame
      .
      ENABLE
      l-marg-pr-paraf
      with frame Dialog-Frame.
      display
      l-marg-pr-paraf
      with frame Dialog-Frame.
    end.
    if can-find (first tt-level-dis-attr) then do:
      OPEN QUERY br-level-dis FOR EACH tt-level-dis-attr NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BR-temp_obj-list FOR EACH temp_obj-list.
      display
      br-level-dis
      B-add
      B-chg
      B-del
      with frame Dialog-Frame
      .
      ENABLE
      br-level-dis
      B-add
      B-chg
      B-del
      with frame Dialog-Frame
      .
      hide
      l-level-dis
      in frame Dialog-Frame
      .
    end.
    else do:
      hide
      br-level-dis
      B-add
      B-chg
      B-del
      in frame Dialog-Frame
      .
      ENABLE
      l-level-dis
      with frame Dialog-Frame.
      display
      l-level-dis
      with frame Dialog-Frame.
    end.
    n-no-inc-auto-rep = logical(if v-no-inc-auto-rep = "" then "no" else v-no-inc-auto-rep).
    disp n-no-inc-auto-rep with frame Dialog-Frame.
    n-ban-sales-via-cd = logical(if v-ban-sales-via-cd = "" then "no" else v-ban-sales-via-cd).
    disp n-ban-sales-via-cd with frame Dialog-Frame.
    n-alchol = logical(if v-alchol = "" then "no" else v-alchol).
    display n-alchol with frame Dialog-Frame.
    n-mark = logical(if v-mark = "" then "no" else v-mark).
    display n-mark with frame Dialog-Frame.
    fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame Dialog-Frame.
  end.
  when 'ДОБАВЛЕНИЕ':U then do:
    hide
    fi-marg-max
    fi-marg-min
    in frame Dialog-Frame
    .
    ENABLE
    l-marg
    with frame Dialog-Frame.
    display
    l-marg
    with frame Dialog-Frame.
    hide
    fi-increase-pc
    in frame Dialog-Frame
    .
    ENABLE
    l-increase-pc
    with frame Dialog-Frame.
    display
    l-increase-pc
    with frame Dialog-Frame.
    hide
    s-round-method
    in frame Dialog-Frame
    .
    ENABLE
    l-rmethod
    with frame Dialog-Frame.
    display
    l-rmethod
    with frame Dialog-Frame.
    hide
    fi-cli-type
    fi-cli-code
    r-cli
    fi-cli-name
    in frame Dialog-Frame
    .
    ENABLE
    l-income-cli
    with frame Dialog-Frame.
    display
    l-income-cli
    with frame Dialog-Frame.
    hide
    fi-notcorr
    in frame Dialog-Frame
    .
    ENABLE
    l-notcorr
    with frame Dialog-Frame.
    display
    l-notcorr
    with frame Dialog-Frame.
    hide
    fi-alc-min-price
    in frame Dialog-Frame
    .
    ENABLE
    l-alc-min-price
    with frame Dialog-Frame.
    display
    l-alc-min-price
    with frame Dialog-Frame.
    hide
    fi-marg-pr-paraf
    in frame Dialog-Frame
    .
    ENABLE
    l-marg-pr-paraf
    with frame Dialog-Frame.
    display
    l-marg-pr-paraf
    with frame Dialog-Frame.
    hide
    br-level-dis
    B-add
    B-chg
    B-del
    in frame Dialog-Frame
    .
    ENABLE
    l-level-dis
    with frame Dialog-Frame.
    display
    l-level-dis
    with frame Dialog-Frame.
    n-no-inc-auto-rep = logical(if v-no-inc-auto-rep = "" then "no" else v-no-inc-auto-rep).
    disp n-no-inc-auto-rep with frame Dialog-Frame.
    n-ban-sales-via-cd = logical(if v-ban-sales-via-cd = "" then "no" else v-ban-sales-via-cd).
    disp n-ban-sales-via-cd with frame Dialog-Frame.
    n-alchol = logical(if v-alchol = "" then "no" else v-alchol).
    display n-alchol with frame Dialog-Frame.
    n-mark = logical(if v-mark = "" then "no" else v-mark).
    display n-mark with frame Dialog-Frame.
    fill-sum-grp = v-sum-grp .
    display fill-sum-grp with frame Dialog-Frame.
  end.
END.
END PROCEDURE.
FUNCTION func-cli-name RETURNS CHARACTER
  ( p-type as char, p-code as int  ) :
define buffer buf_clients   for ub.clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = p-type
           and buf_clients.obj-code = p-code
    no-error.
    if not available buf_clients
    then do:
      RETURN "" .
    end.
    else do:
       RETURN buf_clients.obj-name    .
    end.
END FUNCTION.
