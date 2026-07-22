block-level on error undo, throw.
define input parameter p-mode   as character        no-undo.
on write of ub.gds-grp     override do: end.
on write of ub.goods       override do: end.
on write of ub.gds-obj     override do: end.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-grp.p $":U .
define variable vss-description as character no-undo init "Инициализация полных имен групп в goods, gds-obj".
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
    define stream out-stream.
    define variable v-goods-counter         as integer      init 0  no-undo.
    define variable v-relations-counter     as integer      init 0  no-undo.
    define variable v-full-grp-name         as character            no-undo.
    define variable v-yesno                 as logical              no-undo.
    define frame a
        v-goods-counter       label "Обработано товаров"
        v-relations-counter   label "Обработано связей"
    with.
    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-grp       for ub.gds-grp.
do
for buf_goods
  , buf_gds-grp
on error undo, return error
:
    assign
        v-yesno = no
    .
    if p-mode = "update":U
    then do:
        message
            "Инициализация полных названий групп во всех товарах."
            skip "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        title "Группы товаров"
        update v-yesno.
    end.
    else do:
        message
            "Тест полных названий групп во всех товарах."
            skip "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        title "Группы товаров"
        update v-yesno.
    end.
    if v-yesno <> yes
    then do:
        return.
    end.
if session :set-wait-state( "compiler" ) then.
    view frame a.
    for each buf_goods no-lock
    on error undo, return error
    :
        run set-full-grp-name in this-procedure (
              input p-mode
            , input buf_goods.gds-code
            , input-output v-goods-counter
            , input-output v-relations-counter
        ) no-error.
        if error-status :error
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления полного имени группы товара. Товар: &2. &3. &4."
                                    , p-mode
                                    , buf_goods.artic
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
        display
            v-goods-counter
            v-relations-counter
        with frame a
        view-as dialog-box.
    end.
    for each buf_gds-grp no-lock
    on error undo, return error
    :
        run set-grp-fields in this-procedure (
              input p-mode
            , input buf_gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка вычисления полей группы."
                skip(1)
                skip "Код группы:" buf_gds-grp.node-code
                skip "Имя группы:" buf_gds-grp.node-name
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                skip(1)
                skip "Будет сделана запись об ошибке в лог."
            view-as alert-box error.
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления полей группы товара. Группа: &2 &3. &4. &5."
                                    , p-mode
                                    , buf_gds-grp.node-code
                                    , buf_gds-grp.node-name
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
    end.
    for each buf_gds-grp no-lock
    by buf_gds-grp.lvl-num descending
    on error undo, return error
    :
        run set-unit-base in this-procedure (
              input p-mode
            , input buf_gds-grp.node-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка установки unit-base для группы."
                skip(1)
                skip "Код группы:" buf_gds-grp.node-code
                skip "Имя группы:" buf_gds-grp.node-name
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
                skip(1)
                skip "Будет сделана запись об ошибке в лог."
            view-as alert-box error.
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: *** Ошибка вычисления unit-base. Группа: &2 &3. &4. &5."
                                    , p-mode
                                    , buf_gds-grp.node-code
                                    , buf_gds-grp.node-name
                                    , return-value
                                    , trim(error-status :get-message(1))
                                )
            ).
        end.
    end.
if session :set-wait-state( "" ) then.
    if p-mode = "update":U
    then do:
        message
            "Инициализация групп товаров завершена."
        view-as alert-box.
    end.
    else do:
        message
            "Тест групп товаров завершен."
            skip(1)
            skip "Результат проверки выведен в файл"
            skip "ini-grp.txt":U
        view-as alert-box.
    end.
end.
procedure set-grp-fields :
define input parameter p-mode       as character        no-undo.
define input parameter p-node-code  as integer          no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-lvl-num       as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_el_gds-grp    for ub.gds-grp.
    define buffer buf_goods         for ub.goods.
do
for buf_gds-grp
  , buf_el_gds-grp
  , buf_goods
on error undo, return error
:
    if p-mode = "update":U
    then do:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        .
    end.
    else do:
        find first buf_gds-grp no-lock
            where buf_gds-grp.node-code = p-node-code
        .
    end.
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ).
    if buf_gds-grp.is-term <> v-is-terminal
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение is-terminal для группы &2 &3: &4|&5"
                                , p-mode
                                , buf_gds-grp.node-code
                                , buf_gds-grp.node-name
                                , buf_gds-grp.is-term
                                , v-is-terminal )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_gds-grp.is-term = v-is-terminal
            .
        end.
    end.
    if buf_gds-grp.is-term = no
    then do:
        find first buf_goods no-lock
             where buf_goods.grp-code = buf_gds-grp.node-code
        no-error.
        if available buf_goods
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "test: Товар привязан к нетерминальной группе. Код товара: &1. Артикул: &2. Группа &3 &4."
                                    , buf_goods.gds-code
                                    , buf_goods.artic
                                    , buf_gds-grp.node-code
                                    , buf_gds-grp.node-name
                                  )
            ).
        end.
    end.
    run grplib-get-lvl-num in this-procedure (
          input p-node-code
        , output v-lvl-num
    ).
    if buf_gds-grp.lvl-num <> v-lvl-num
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение lvl-num для группы &2 &3: &4|&5"
                                , p-mode
                                , buf_gds-grp.node-code
                                , buf_gds-grp.node-name
                                , buf_gds-grp.lvl-num
                                , v-lvl-num )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_gds-grp.lvl-num = v-lvl-num
            .
        end.
    end.
end.
end procedure.
procedure set-unit-base :
define input parameter p-mode       as character        no-undo.
define input parameter p-node-code  as integer          no-undo.
    define variable v-is-first-goods-in-grp     as logical      no-undo.
    define variable v-is-first-lower-grp        as logical      no-undo.
    define variable v-unit-base                 as character    no-undo.
    define variable v-is-terminal               as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_lower_gds-grp for ub.gds-grp.
    define buffer buf_goods         for ub.goods.
do
for buf_gds-grp
  , buf_lower_gds-grp
  , buf_goods
on error undo, return error
:
    assign
        v-unit-base             = ?
        v-is-first-goods-in-grp = yes
        v-is-first-lower-grp    = yes
    .
    if p-mode = "update":U
    then do:
        find first buf_gds-grp exclusive-lock
             where buf_gds-grp.node-code = p-node-code
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = p-node-code
        .
    end.
    run grplib-is-terminal in this-procedure (
          input p-node-code
        , output v-is-terminal
    ).
    if v-is-terminal = yes
    then do:
        loop-by-goods:
        for each buf_goods no-lock
           where buf_goods.grp-code = buf_gds-grp.node-code
        on error undo, return error
        :
            if v-is-first-goods-in-grp = yes
            then do:
                assign
                    v-unit-base             = buf_goods.unit-base
                    v-is-first-goods-in-grp = no
                .
            end.
            else do:
                if buf_goods.unit-base <> v-unit-base
                then do:
                    assign
                        v-unit-base = ?
                    .
                    leave loop-by-goods.
                end.
            end.
        end.
    end.
    else do:
        loop-by-lower-groups:
        for each buf_lower_gds-grp no-lock
           where buf_lower_gds-grp.upper-code = p-node-code
        on error undo, return error
        :
            if v-is-first-lower-grp = yes
            then do:
                assign
                    v-unit-base             = buf_lower_gds-grp.unit-base
                    v-is-first-lower-grp    = no
                .
            end.
            else do:
                if buf_lower_gds-grp.unit-base <> v-unit-base
                then do:
                    assign
                        v-unit-base = ?
                    .
                    leave loop-by-lower-groups.
                end.
            end.
        end.
    end.
    if buf_gds-grp.unit-base <> v-unit-base
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение unit-base для группы &2 &3: &4|&5"
                    , p-mode
                    , buf_gds-grp.node-code
                    , buf_gds-grp.node-name
                    , buf_gds-grp.unit-base
                    , v-unit-base
                    )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_gds-grp.unit-base = v-unit-base
            .
        end.
    end.
end.
end procedure.
procedure write-log :
define input parameter p-tab-position   as integer          no-undo.
define input parameter p-log-text       as character        no-undo.
do
on error undo, return error
:
    output stream out-stream to "ini-grp.txt":U append.
    if p-tab-position <> 0
    then do:
        put stream out-stream unformatted
            cur-time-string-sec()
        .
        put stream out-stream unformatted
            space( p-tab-position * 2 + 1 )
        .
    end.
    put stream out-stream unformatted
        p-log-text
    .
    put stream out-stream unformatted
        chr(10)
    .
    output stream out-stream close.
end.
end procedure.
procedure set-full-grp-name :
define input parameter p-mode                       as character        no-undo.
define input parameter p-gds-code                   as integer          no-undo.
define input-output parameter p-goods-counter       as integer          no-undo.
define input-output parameter p-relations-counter   as integer          no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_el_gds-obj    for ub.gds-obj.
do
for buf_goods
  , buf_gds-obj
  , buf_el_gds-obj
on error undo, return error
:
    assign
        p-goods-counter = p-goods-counter + 1
    .
    if p-mode = "update":U
    then do:
        find first buf_goods exclusive-lock
             where buf_goods.gds-code = p-gds-code
        .
    end.
    else do:
        find first buf_goods no-lock
             where buf_goods.gds-code = p-gds-code
        .
    end.
    run grplib-get-full-name in this-procedure (
          input buf_goods.grp-code
        , output v-full-grp-name
    ).
    if buf_goods.grp-name <> v-full-grp-name
    then do:
        run write-log in this-procedure (
              input 2
            , input substitute( "&1: изменение полного имени группы товара: &2|&3. Товар: &4."
                                , p-mode
                                , buf_goods.grp-name
                                , v-full-grp-name
                                , buf_goods.artic
                              )
        ).
        if p-mode = "update":U
        then do:
            assign
                buf_goods.grp-name = v-full-grp-name
            .
        end.
    end.
    for each buf_gds-obj no-lock
       where buf_gds-obj.artic      = buf_goods.artic
         and buf_gds-obj.prod-type  = buf_goods.prod-type
         and buf_gds-obj.prod-code  = buf_goods.prod-code
    :
        assign
            p-relations-counter     = p-relations-counter + 1
        .
        if buf_gds-obj.grp-name <> v-full-grp-name
        then do:
            run write-log in this-procedure (
                  input 2
                , input substitute( "&1: изменение полного имени группы товара на объекте: &2|&3. Товар: &4. Объект: &5&6"
                                    , p-mode
                                    , buf_gds-obj.grp-name
                                    , v-full-grp-name
                                    , buf_goods.artic
                                    , buf_gds-obj.obj-type
                                    , buf_gds-obj.obj-code
                                  )
            ).
            if p-mode = "update":U
            then do:
                find first buf_el_gds-obj exclusive-lock
                     where recid( buf_el_gds-obj ) = recid( buf_gds-obj )
                .
                assign
                    buf_el_gds-obj.grp-name = v-full-grp-name
                .
            end.
        end.
    end.
end.
end procedure.
