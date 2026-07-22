define input parameter p-mainmenu-handle    as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обмен данными с РКС. Конфигурация.".
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
define variable vss-include-info2 as character format "X(65)" no-undo
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-bind
     LABEL "Выгрузка"
     SIZE 10 BY 1 TOOLTIP "Начальная выгрузка данных по товарам, приходным и продажным ценам".
DEFINE BUTTON bt-cli-grp
     LABEL "Группа для поставщи&ков"
     SIZE 30.63 BY 1.
DEFINE BUTTON bt-dir-exp
     LABEL "Каталог &экспорта"
     SIZE 38.25 BY 1.
DEFINE BUTTON bt-dir-imp
     LABEL "&Каталог &импорта"
     SIZE 38.25 BY 1.
DEFINE BUTTON bt-gds-grp
     LABEL "Группа для &товаров"
     SIZE 30.63 BY 1.
DEFINE BUTTON bt-mag
     LABEL "&Магазины"
     SIZE 10 BY 1.
DEFINE BUTTON bt-objects
     LABEL "&Таблицы"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sel-divisional
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-integer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-trn-doc-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-trn-doc-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-trn-doc-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-weight
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE VARIABLE fi-cli-grp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-count AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 61.63 BY 1 NO-UNDO.
DEFINE VARIABLE fi-dir-exp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 61.63 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-dir-imp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 61.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-gds-grp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-trn-doc-agnt AS CHARACTER FORMAT "X(17)":U
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-trn-doc-boss AS CHARACTER FORMAT "X(17)":U
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-trn-doc-wrkr AS CHARACTER FORMAT "X(17)":U
     VIEW-AS FILL-IN
     SIZE 17.13 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-unit-divisional AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-unit-integer AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE VARIABLE fi-unit-weight AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1
     FGCOLOR 9  NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2.5
     b-help AT ROW 1.17 COL 53.13
     bt-objects AT ROW 3 COL 2.5
     bt-mag AT ROW 3 COL 13.38
     bt-bind AT ROW 3 COL 53.13
     fi-count AT ROW 4.42 COL 2.5 NO-LABEL
     bt-dir-imp AT ROW 4.5 COL 2.5
     fi-dir-imp AT ROW 5.5 COL 2.5 NO-LABEL
     bt-dir-exp AT ROW 7 COL 2.5
     fi-dir-exp AT ROW 8 COL 2.5 NO-LABEL
     bt-gds-grp AT ROW 9.54 COL 2.5
     bt-cli-grp AT ROW 9.54 COL 33.5
     fi-gds-grp AT ROW 10.54 COL 2.5 NO-LABEL
     fi-cli-grp AT ROW 10.54 COL 33.5 NO-LABEL
     fi-unit-integer AT ROW 13.17 COL 11.5 COLON-ALIGNED NO-LABEL
     bt-sel-integer AT ROW 13.21 COL 20
     fi-trn-doc-wrkr AT ROW 13.21 COL 40 COLON-ALIGNED NO-LABEL
     bt-sel-trn-doc-wrkr AT ROW 13.25 COL 60.13
     bt-sel-divisional AT ROW 14.13 COL 20
     fi-unit-divisional AT ROW 14.17 COL 11.5 COLON-ALIGNED NO-LABEL
     bt-sel-trn-doc-agnt AT ROW 14.17 COL 60.13
     fi-trn-doc-agnt AT ROW 14.21 COL 40 COLON-ALIGNED NO-LABEL
     fi-unit-weight AT ROW 15.17 COL 11.5 COLON-ALIGNED NO-LABEL
     bt-sel-weight AT ROW 15.17 COL 20
     fi-trn-doc-boss AT ROW 15.21 COL 40 COLON-ALIGNED NO-LABEL
     bt-sel-trn-doc-boss AT ROW 15.21 COL 60.13
     "Исполнитель" VIEW-AS TEXT
          SIZE 14.25 BY .96 AT ROW 14.21 COL 27.13
     "Кладовщик" VIEW-AS TEXT
          SIZE 14 BY .96 AT ROW 13.21 COL 27.13
     "Штучный" VIEW-AS TEXT
          SIZE 8.5 BY .96 AT ROW 13.21 COL 2.63
     "Дробный" VIEW-AS TEXT
          SIZE 8.5 BY .96 AT ROW 14.21 COL 2.63
     "Весовой" VIEW-AS TEXT
          SIZE 8.5 BY .96 AT ROW 15.21 COL 2.63
     "Менеджер" VIEW-AS TEXT
          SIZE 14.38 BY .96 AT ROW 15.21 COL 27.13
     "Приходные накладные" VIEW-AS TEXT
          SIZE 30.63 BY 1.08 AT ROW 11.92 COL 27
     "Единицы измерения" VIEW-AS TEXT
          SIZE 21.75 BY 1.08 AT ROW 11.92 COL 2.63
     SPACE(40.11) SKIP(3.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки обмена данными с РКС".
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
ON CHOOSE OF bt-bind IN FRAME Dialog-Frame
DO:
    message
            "Операция может занять много времени."
            skip "Запустить выгрузку?"
        view-as alert-box question
        buttons yes-no
        title "Начальная выгрузка данных"
        update v-yesno as logical
    .
    if v-yesno = yes
    then do:
        hide bt-dir-imp fi-dir-imp bt-objects bt-mag.
        view
            fi-count
        .
        run rcs/exp-ini.p ( input fi-count :handle ) no-error.
        if error-status :error
        then do:
            message
              vss-workfile vss-revision vss-description
              skip "Ошибка начальной выгрузки данных по товарам."
              skip return-value
              skip trim(error-status :get-message(1))
                   trim(error-status :get-message(2))
                   trim(error-status :get-message(3))
            view-as alert-box error.
            hide fi-count.
            view bt-dir-imp fi-dir-imp bt-objects bt-mag.
            undo, return no-apply .
        end.
        hide fi-count.
        view bt-dir-imp fi-dir-imp bt-objects bt-mag.
    end.
END.
ON CHOOSE OF bt-cli-grp IN FRAME Dialog-Frame
DO:
    define variable v-grp-name   as character         no-undo.
    define variable v-cancel    as logical           no-undo.
    run select-default-cli-grp in this-procedure (
        output v-grp-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы по умолчанию для новых поставщиков."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-cli-grp = v-grp-name
        .
        display
            fi-cli-grp
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF bt-dir-exp IN FRAME Dialog-Frame
DO:
    define variable v-dir-exp   as character         no-undo.
    define variable v-cancel    as logical           no-undo.
    run select-dir in this-procedure (
            input 'rcs-export-directory':u
          , output v-dir-exp
          , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора каталога."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-dir-exp = v-dir-exp
        .
        display
            fi-dir-exp
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF bt-dir-imp IN FRAME Dialog-Frame
DO:
    define variable v-dir-imp   as character         no-undo.
    define variable v-cancel    as logical           no-undo.
    run select-dir in this-procedure (
            input 'rcs-import-directory':u
          , output v-dir-imp
          , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора каталога."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-dir-imp = v-dir-imp
        .
        display
            fi-dir-imp
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF bt-gds-grp IN FRAME Dialog-Frame
DO:
    define variable v-grp-name   as character         no-undo.
    define variable v-cancel    as logical           no-undo.
    run select-default-gds-grp in this-procedure (
        output v-grp-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора группы по умолчанию для новых товаров."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = no
    then do:
        assign
            fi-gds-grp = v-grp-name
        .
        display
            fi-gds-grp
        with frame Dialog-Frame.
    end.
END.
ON CHOOSE OF bt-mag IN FRAME Dialog-Frame
DO:
    run mag-tuning in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора файлов для импорта."
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
ON CHOOSE OF bt-objects IN FRAME Dialog-Frame
DO:
    run objects-tuning in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка выбора таблиц обмена."
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
ON CHOOSE OF bt-sel-divisional IN FRAME Dialog-Frame
DO:
define variable v-unit-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-units in this-procedure (
          input 'дро':U
        , output v-unit-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора единицы измерения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-unit-divisional :screen-value = v-unit-name
            .
        end.
    end.
END.
ON CHOOSE OF bt-sel-integer IN FRAME Dialog-Frame
DO:
define variable v-unit-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-units in this-procedure (
          input 'шту':U
        , output v-unit-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора единицы измерения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-unit-integer :screen-value = v-unit-name
            .
        end.
    end.
END.
ON CHOOSE OF bt-sel-trn-doc-agnt IN FRAME Dialog-Frame
DO:
define variable v-agnt-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-wrkr-agnt-boss in this-procedure (
          input 'разрешение':U
        , output v-agnt-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора исполнителя."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-agnt :screen-value = v-agnt-name
            .
        end.
    end.
END.
ON CHOOSE OF bt-sel-trn-doc-boss IN FRAME Dialog-Frame
DO:
define variable v-boss-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-wrkr-agnt-boss in this-procedure (
          input 'отгрузка':U
        , output v-boss-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора менеджера."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-boss :screen-value = v-boss-name
            .
        end.
    end.
END.
ON CHOOSE OF bt-sel-trn-doc-wrkr IN FRAME Dialog-Frame
DO:
define variable v-wrkr-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-wrkr-agnt-boss in this-procedure (
          input 'подготовка':U
        , output v-wrkr-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора кладовщика."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-wrkr :screen-value = v-wrkr-name
            .
        end.
    end.
END.
ON CHOOSE OF bt-sel-weight IN FRAME Dialog-Frame
DO:
define variable v-unit-name     as character no-undo.
define variable v-cancel        as logical no-undo.
    run select-units in this-procedure (
          input 'вес':U
        , output v-unit-name
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора единицы измерения."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    else do:
        if v-cancel = no
        then do:
            assign
                fi-unit-weight :screen-value = v-unit-name
            .
        end.
    end.
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI.
    run init-fields in this-procedure no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка инициализации полей формы."
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
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-dir-imp fi-dir-exp fi-gds-grp fi-cli-grp fi-unit-integer
          fi-trn-doc-wrkr fi-unit-divisional fi-trn-doc-agnt fi-unit-weight
          fi-trn-doc-boss
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help bt-objects bt-mag bt-bind bt-dir-imp bt-dir-exp
         bt-gds-grp bt-cli-grp bt-sel-integer bt-sel-trn-doc-wrkr
         bt-sel-divisional bt-sel-trn-doc-agnt bt-sel-weight
         bt-sel-trn-doc-boss
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-dir           as character         no-undo.
    define variable v-grp-name      as character         no-undo.
    define variable v-unit-name     as character         no-undo.
    define variable v-person-name   as character         no-undo.
    define variable v-cancel        as logical           no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_gds-grp       for gds-grp.
    define buffer buf_cli-grp       for cli-grp.
    define buffer buf_clients       for clients.
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
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'группа':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-default-gds-grp in this-procedure (
              output v-grp-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора группы товара по умолчанию." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-gds-grp :screen-value in frame Dialog-Frame = v-grp-name
            .
        end.
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_gds-grp
        then do:
            assign
               v-grp-name = ""
            .
        end.
        else do:
            run grplib-get-full-name in this-procedure (
                  input buf_gds-grp.node-code
                , output v-grp-name
            ) no-error .
            if error-status :error
            then do:
                assign
                    v-grp-name = ""
                .
            end.
        end.
        assign
            fi-gds-grp :screen-value in frame Dialog-Frame = v-grp-name
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'группа-клиентов':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-default-cli-grp in this-procedure (
              output v-grp-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора группы для поставщика по умолчанию." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-cli-grp :screen-value in frame Dialog-Frame = v-grp-name
            .
        end.
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_cli-grp
        then do:
            assign
               v-grp-name = ""
            .
        end.
        else do:
            assign
                v-grp-name = buf_cli-grp.node-name
            .
        end.
        assign
            fi-cli-grp :screen-value in frame Dialog-Frame = v-grp-name
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'шту':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-units in this-procedure (
              input 'шту':U
            , output v-unit-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора штучной единицы измерения товара." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-unit-integer :screen-value in frame Dialog-Frame = v-unit-name
            .
        end.
    end.
    else do:
        assign
            fi-unit-integer :screen-value in frame Dialog-Frame = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'дро':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-units in this-procedure (
              input 'дро':U
            , output v-unit-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора дробной единицы измерения товара." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-unit-divisional :screen-value in frame Dialog-Frame = v-unit-name
            .
        end.
    end.
    else do:
        assign
            fi-unit-divisional :screen-value in frame Dialog-Frame = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'вес':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-units in this-procedure (
              input 'вес':U
            , output v-unit-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора весовой единицы измерения товара." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-unit-weight :screen-value in frame Dialog-Frame = v-unit-name
            .
        end.
    end.
    else do:
        assign
            fi-unit-weight :screen-value in frame Dialog-Frame = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'подготовка':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-wrkr-agnt-boss in this-procedure (
              input 'подготовка':U
            , output v-person-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора кладовщика." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-wrkr :screen-value in frame Dialog-Frame = v-person-name
            .
        end.
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'чел':U
               and buf_clients.obj-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_clients
        then do:
            assign
                fi-trn-doc-wrkr :screen-value in frame Dialog-Frame = ""
            .
        end.
        else do:
            assign
                fi-trn-doc-wrkr :screen-value in frame Dialog-Frame = buf_clients.obj-name
            .
        end.
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'разрешение':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-wrkr-agnt-boss in this-procedure (
              input 'разрешение':U
            , output v-person-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора исполнителя." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-agnt :screen-value in frame Dialog-Frame = v-person-name
            .
        end.
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'чел':U
               and buf_clients.obj-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_clients
        then do:
            assign
                fi-trn-doc-agnt :screen-value in frame Dialog-Frame = ""
            .
        end.
        else do:
            assign
                fi-trn-doc-agnt :screen-value in frame Dialog-Frame = buf_clients.obj-name
            .
        end.
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'отгрузка':U
    no-error .
    if not available buf_usr-flt
    then do:
        run select-wrkr-agnt-boss in this-procedure (
              input 'отгрузка':U
            , output v-person-name
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора менеджера." + chr(10) + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-trn-doc-boss :screen-value in frame Dialog-Frame = v-person-name
            .
        end.
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'чел':U
               and buf_clients.obj-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_clients
        then do:
            assign
                fi-trn-doc-boss :screen-value in frame Dialog-Frame = ""
            .
        end.
        else do:
            assign
                fi-trn-doc-boss :screen-value in frame Dialog-Frame = buf_clients.obj-name
            .
        end.
    end.
END PROCEDURE.
PROCEDURE mag-tuning :
do
on error undo, return error
:
    run rcs/rcscnfm.w (
        input p-mainmenu-handle
    ) no-error.
    if error-status :error
    then do:
        undo, return error "objects-tuning: Ошибка настройки объектов rcs." + chr(10) + return-value.
    end.
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
PROCEDURE select-default-cli-grp :
do
on error undo, return error
:
define output parameter p-grp-name       as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-can-write as logical      no-undo.
    define variable v-grp-recid-string      as character no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_cli-grp          for cli-grp.
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'группа-клиентов':U
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = 'все':U
            buf_usr-flt.call-point   = 'группа-клиентов':U
            v-grp-recid-string = ""
        .
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_cli-grp
        then do:
            assign
                v-grp-recid-string = ""
            .
        end.
        else do:
            assign
                v-grp-recid-string = string( recid( buf_cli-grp ) )
            .
        end.
    end.
    run ref/cli-grps.w ( input p-mainmenu-handle, input 'терм':U + ',b-sel', input-output v-grp-recid-string ).
    if v-grp-recid-string = ""
    then do:
        assign
            p-cancel = yes
        .
    end.
    else do:
        find first buf_cli-grp no-lock
             where recid ( buf_cli-grp ) = integer ( v-grp-recid-string )
        no-error .
        if not available buf_cli-grp
        then do:
            assign
                buf_usr-flt.Naim = "0"
                p-grp-name       = ""
            .
        end.
        else do:
            assign
                buf_usr-flt.Naim    = string( buf_cli-grp.node-code )
                p-cancel            = no
            .
            assign
                p-grp-name = buf_cli-grp.node-name
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE select-default-gds-grp :
do
on error undo, return error
:
define output parameter p-grp-name       as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-can-write as logical      no-undo.
    define variable v-grp-recid-string      as character no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_gds-grp       for gds-grp.
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = 'группа':U
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = 'все':U
            buf_usr-flt.call-point   = 'группа':U
            v-grp-recid-string = ""
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = integer( buf_usr-flt.Naim )
        no-error .
        if not available buf_gds-grp
        then do:
            assign
                v-grp-recid-string = ""
            .
        end.
        else do:
            assign
                v-grp-recid-string = string( recid( buf_gds-grp ) )
            .
        end.
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run ref/gds-grp.w (
          input p-mainmenu-handle
        , input 'терм':U + ',b-sel'
        , input v-cntxt-obj-type
        , input v-cntxt-obj-code
        , input-output v-grp-recid-string
    ).
    if v-grp-recid-string = ""
    then do:
        assign
            p-cancel = yes
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where recid ( buf_gds-grp ) = integer ( v-grp-recid-string )
        no-error .
        if not available buf_gds-grp
        then do:
            assign
                buf_usr-flt.Naim = "0"
                p-grp-name       = ""
            .
        end.
        else do:
            assign
                buf_usr-flt.Naim    = string( buf_gds-grp.node-code )
                p-cancel            = no
            .
            run grplib-get-full-name in this-procedure (
                  input buf_gds-grp.node-code
                , output p-grp-name
            ) no-error .
            if error-status :error
            then do:
                assign
                    p-grp-name = ""
                .
            end.
        end.
    end.
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
PROCEDURE select-units :
do
on error undo, return error
:
define input parameter p-unit-type  as character    no-undo.
define output parameter p-unit-name as character    no-undo.
define output parameter p-cancel    as logical      no-undo.
    define variable v-unit-recid     as recid             no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_units         for units.
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = p-unit-type
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = 'все':U
            buf_usr-flt.call-point   = p-unit-type
        .
    end.
    run ref/units.w (
          input p-mainmenu-handle
        , input yes
        , output v-unit-recid
    ) no-error .
    if error-status :error
    then do:
        undo, return error "select-units: Невозможно выбрать единицы измерения." + chr(10) + return-value.
    end.
    if v-unit-recid = ?
    then do:
        assign
            p-cancel    = yes
        .
    end.
    else do:
        find first buf_units no-lock
             where recid ( buf_units ) = v-unit-recid
        no-error .
        if not available buf_units
        then do:
            assign
                p-unit-name = ""
                p-cancel    = no
            .
        end.
        else do:
            assign
                buf_usr-flt.Naim = buf_units.unit-name
                p-unit-name      = buf_units.unit-name
                p-cancel         = no
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE select-wrkr-agnt-boss :
do
on error undo, return error
:
define input parameter p-person  as character    no-undo.
define output parameter p-person-name as character    no-undo.
define output parameter p-cancel    as logical      no-undo.
    define variable v-person-recid-str     as character             no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
    define buffer buf_clients       for clients.
    define buffer buf_person        for person.
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name    = 'все':U
           and buf_usr-flt.call-point   = p-person
    no-error .
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name    = 'все':U
            buf_usr-flt.call-point   = p-person
        .
    end.
    run ref/cli-all.w (
          input p-mainmenu-handle
        , input "b-sel"
        , input 'все':U
        , input 'все':U
        , input 'все':U
        , input ?
        , input ",,,,,,NO,,":u
        , input "":U
        , output v-person-recid-str
    ) no-error .
    if error-status :error
    then do:
        undo, return error "select-wrkr-agnt-boss: Невозможно выбрать клиента." + chr(10) + return-value + ". " + trim(error-status :get-message(1)).
    end.
    if v-person-recid-str = ?
    or v-person-recid-str = ""
    then do:
        assign
            p-cancel    = yes
        .
    end.
    else do:
        find first buf_clients no-lock
             where recid( buf_clients ) = integer( v-person-recid-str )
        no-error .
        if not available buf_clients
        then do:
            assign
                p-person-name = ""
                p-cancel    = no
            .
        end.
        else do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            no-error .
            if not available buf_person
            then do:
                undo, return error "select-wrkr-agnt-boss: Не найдена запись таблицы person." .
            end.
            assign
                buf_usr-flt.Naim = string( buf_person.psn-code )
                p-person-name    = buf_clients.obj-name
                p-cancel         = no
            .
        end.
    end.
end.
END PROCEDURE.
