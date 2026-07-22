block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle               no-undo.
define input parameter p-fbrhist-handle     as widget-handle        no-undo.
define input parameter p-goods-recid        as recid                no-undo.
define input parameter p-fbr-doc-recid      as recid                no-undo.
define input parameter p-trn-type           like fbr-line.trn-type  no-undo.
define input parameter p-qnty               like fbr-line.fact-qnty no-undo.
define input parameter p-recipe-recursive   as logical              no-undo.
define input parameter p-recursive-enabled  as logical              no-undo.
define input parameter p-fbr-obj-type       like clients.obj-type   no-undo.
define input parameter p-fbr-obj-code       like clients.obj-code   no-undo.
define input parameter p-ingr-line-exists   as logical              no-undo.
define input parameter p-autofbr            as logical              no-undo.
define input parameter p-have-store         as logical              no-undo.
define output parameter p-new-goods-recid   as recid            no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "добавление любой строки в документ производства по рецепту при заданном товаре".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = 'fbr.log'
    .
    if log-file-name <> "":U
    then do:
        if search( 'fbr.log' ) = ?
        then do:
            output to value( 'fbr.log' ).
            output close.
        end.
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
do
on error undo, return error
:
    define variable ref-list                as character                no-undo.
    define variable r-code                  like recipe.recipe-code     no-undo.
    define variable r-type                  as character                no-undo.
    define variable v-recipe-OK             as logical  init yes        no-undo.
   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-integer   as integer    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .
    define variable par-type                as character                no-undo.
    define variable comp-qnty               like fbr-line.fact-qnty     no-undo.
    define variable v-recipe-list           as character                no-undo.
    define variable v-need-goods            as logical                  no-undo.
    define variable v-need-goods-list       as character                no-undo.
    define variable v-need-goods-qnty-list  as character                no-undo.
    define variable v-cancel                as logical                  no-undo.
    define variable v-goods-recid           as recid        no-undo.
    define variable v-yesno                 as logical      no-undo.
    define variable v-fbr-line-recid        as recid        no-undo.
    define buffer buf_goods             for goods.
    define buffer buf_comp_goods        for goods.
    define buffer buf_recipe            for recipe.
    define buffer buf_selected_recipe   for recipe.
    define buffer buf_recipe-gds        for recipe-gds.
    define buffer buf_fbr-doc           for fbr-doc.
    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    assign
        v-goods-recid = p-goods-recid
    .
    if p-qnty <= 0
    then do:
        run writelog (log-file-name, 0, "&Line").
        run writelog (log-file-name, 0, string(vss-workfile) + ". Передано количество товара <= 0, " + string(p-qnty) + ". Нечего добавлять").
        run writelog (log-file-name, 0, "&Line").
        assign
            p-new-goods-recid = v-goods-recid
        .
        return.
    end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    find first buf_goods no-lock
         where recid (buf_goods) = v-goods-recid
    .
    find first gds-prt no-lock
         where gds-prt.upper-code = buf_goods.prt-root
    .
    run writelog (log-file-name, 0, "&Line").
    run writelog (log-file-name, 1, string( vss-workfile )
                                    + chr(32)                       + string(buf_goods.artic       , "X(17)")
                                    + chr(32)                       + string(buf_goods.gds-name    , "X(30)")
                                    + chr(32) + ". Кол-во: "        + (if p-qnty = ? then "?" else string(p-qnty))
                                    + chr(32) + ". Тип строки: "    + (if p-trn-type = ? then "?" else string(p-trn-type))
                        ).
    if buf_goods.gds-type = 'у':U
    then do:
        message
            "Нельзя добавить услугу."
            skip "Товар:" buf_goods.artic buf_goods.gds-name
        view-as alert-box error.
        run writelog (log-file-name, 0, "Тип товара - Услуга. Добавление невозможно").
        assign
            p-new-goods-recid = v-goods-recid
        .
        undo, return error.
    end.
    if buf_goods.stts <> 0
    then do:
        message
            "Нельзя добавить удаленный товар."
            skip "Товар:" buf_goods.artic buf_goods.gds-name
        view-as alert-box error.
        run writelog (log-file-name, 0, "Товар удален. Добавление невозможно").
        assign
            p-new-goods-recid = v-goods-recid
        .
        undo, return error.
    end.
    if p-recipe-recursive
    then do:
        run writelog (log-file-name, 2, "Работаем в рекурсии").
        if p-trn-type = ?
        then do:
            run writelog (log-file-name, 0, "Не определен тип строки. Добавление невозможно").
            assign
                p-new-goods-recid = v-goods-recid
            .
            undo, return error.
        end.
         run adm/shattri.p ( input "get":U
                           , input  '':u
                           , input  0
                           , input  'fbrattr':U
                           , input  'fbr-frcp':U
                           , output v-value-character
                           , output v-value-date
                           , output v-value-decimal
                           , output v-value-integer
                           , output v-value-logical
                           , output v-param-type
                           , input-output table-handle v-tth
                           ) no-error .
         if error-status :error then do:
            assign
               v-value-logical = FALSE
            .
         end.
        assign
            r-code = ?
            r-type = ?
        .
        comp-recipe:
        for each buf_recipe no-lock
           where buf_recipe.artic     = buf_goods.artic
             and buf_recipe.prod-type = buf_goods.prod-type
             and buf_recipe.prod-code = buf_goods.prod-code
        :
            run writelog (log-file-name, 3, "Рецепт: " + string(buf_recipe.recipe-code) + ", Тип: " + string(buf_recipe.recipe-type)).
            if p-trn-type = 'при':U
            and buf_recipe.recipe-type = 'разделка':U
            then do:
                run writelog (log-file-name, 4, "Разделка для составного не может дать прихода. Ищем следующий рецепт").
                next comp-recipe.
            end.
            if p-trn-type = 'спи':U
            and buf_recipe.recipe-type <> 'разделка':U
            and buf_recipe.recipe-type <> 'комплектация':U
            then do:
                run writelog (log-file-name, 4, "Только разделка или разукомплектация для составного может дать списание. Ищем следующий рецепт").
                next comp-recipe.
            end.
            if r-type = ?
            then do:
                assign
                    r-code = buf_recipe.recipe-code
                    r-type = "recipe"
                .
                run writelog (log-file-name, 4, "Найден первый подходящий рецепт для составного").
                if v-value-logical
                or p-autofbr = yes
                then do:
                    run writelog (log-file-name, 4, "Больше рецепт не ищем: включен параметр fbr-frcp или раскрутка для ресторана.").
                    leave comp-recipe.
                end.
            end.
            else do:
                run writelog (log-file-name, 4, "Найден еще один подходящий рецепт").
                run ref/rcp-all.w (
                      input p-mainmenu-handle
                    , input "b-sel"
                    , input 'все':U
                    , input recid( buf_goods )
                    , input v-cntxt-obj-type
                    , input v-cntxt-obj-code
                    , output v-recipe-list
                ).
                find first buf_selected_recipe no-lock
                        where recid( buf_selected_recipe ) = integer( entry( 1, v-recipe-list ) )
                no-error.
                if not available buf_selected_recipe
                then do:
                    assign
                        r-code = ?
                    .
                end.
                else do:
                    assign
                        r-code = buf_selected_recipe.recipe-code
                        r-type = "recipe"
                    .
                    leave comp-recipe.
                end.
            end.
        end.
        if r-type = ?
        then do:
            search-recipe-gds:
            for each buf_recipe-gds
               where buf_recipe-gds.artic       = buf_goods.artic
                 and buf_recipe-gds.prod-type   = buf_goods.prod-type
                 and buf_recipe-gds.prod-code   = buf_goods.prod-code
             , first buf_recipe no-lock
               where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
            :
                if p-trn-type = 'при':U
                and buf_recipe.recipe-type <> 'разделка':U
                and buf_recipe.recipe-type <> 'комплектация':U
                then do:
                    next search-recipe-gds.
                end.
                if p-trn-type = 'спи':U
                and buf_recipe.recipe-type = 'разделка':U
                then do:
                    next search-recipe-gds.
                end.
                if r-type = ?
                then do:
                    assign
                        r-code = buf_recipe.recipe-code
                        r-type = "recipe-gds"
                    .
                    if v-value-logical
                    then do:
                        leave search-recipe-gds.
                    end.
                end.
                else do:
                    assign
                        r-code = ?
                    .
                end.
            end.
        end.
        if r-code = ?
        then do:
            assign
                v-recipe-OK = no
            .
            assign
                p-new-goods-recid = v-goods-recid
            .
            return.
        end.
        find first buf_recipe no-lock
             where buf_recipe.recipe-code = r-code
        .
    end.
    else do:
        run ref/rcp-all.w (
              input p-mainmenu-handle
            , input "b-add,b-sel"
            , input 'все':U
            , input v-goods-recid
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , output v-recipe-list
        ).
        find first buf_recipe no-lock
             where recid( buf_recipe ) = integer( ref-list )
        no-error.
        if not available buf_recipe
        then do:
            assign
                v-recipe-OK = no
            .
            assign
                p-new-goods-recid = v-goods-recid
            .
            return.
        end.
        if buf_recipe.artic = buf_goods.artic
        and buf_recipe.prod-type = buf_goods.prod-type
        and buf_recipe.prod-code = buf_goods.prod-code
        then do:
            assign
                r-type = "recipe"
            .
        end.
        else do:
            assign
                r-type = "recipe-gds"
            .
        end.
        case buf_recipe.recipe-type
        :
            when 'производство':U
            then do:
                if r-type = "recipe"
                then do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
            end.
            when 'альтернатива':U
            then do:
                if r-type = "recipe"
                then do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
            end.
            when 'разделка':U
            then do:
                if r-type = "recipe-gds"
                then do:
                    assign
                        p-trn-type = 'при':U
                    .
                end.
                else do:
                    assign
                        p-trn-type = 'спи':U
                    .
                end.
            end.
            when 'комплектация':U
            then do:
                assign
                    v-yesno = yes
                .
                message
                    "Выберите тип операции по рецепту комплектации:"
                    skip (2) "YES - комплектация"
                    skip     "NO - разукомплектация"
                view-as alert-box question
                buttons YES-NO
                update v-yesno.
                if v-yesno
                then do:
                    if r-type = "recipe"
                    then do:
                        assign
                            p-trn-type = 'при':U
                        .
                    end.
                    else do:
                        assign
                            p-trn-type = 'спи':U
                        .
                    end.
                end.
                else do:
                    if r-type = "recipe-gds"
                    then do:
                        assign
                            p-trn-type = 'при':U
                        .
                    end.
                    else do:
                        assign
                            p-trn-type = 'спи':U
                        .
                    end.
                end.
            end.
        end case.
    end.
    if r-type = "recipe-gds"
    then do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.artic         = buf_goods.artic
               and buf_recipe-gds.prod-type     = buf_goods.prod-type
               and buf_recipe-gds.prod-code     = buf_goods.prod-code
               and buf_recipe-gds.recipe-code   = buf_recipe.recipe-code
        .
    end.
    case buf_recipe.recipe-type
    :
      when 'производство':U
      then do:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_manufacturing':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-yesno
    )  .
end.
      end.
      when 'комплектация':U
      then do:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_gathering':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-yesno
    )  .
end.
      end.
      when 'разделка':U
      then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_dressing':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-yesno
    )  .
end.
      end.
      when 'альтернатива':U
      then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_alternative':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-yesno
    )  .
end.
      end.
      when 'топливо':U
      then do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_manufacturing_petrolium-manufacturing':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-yesno
    )  .
end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип рецепта" buf_recipe.recipe-type skip
          "Код рецепта" buf_recipe.recipe-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if not v-yesno
    then do:
        assign
            v-recipe-OK = no
        .
        assign
            p-new-goods-recid = v-goods-recid
        .
        return.
    end.
    do
    on error undo, return error
    on stop undo, return error
    :
        run str/fbr-crln.p (
              input p-mainmenu-handle
            , input p-fbr-doc-recid
            , input v-goods-recid
            , input buf_recipe.recipe-code
            , input p-trn-type
            , input (r-type = "recipe")
            , input p-recipe-recursive
            , input p-fbr-obj-type
            , input p-fbr-obj-code
            , output v-fbr-line-recid
        ).
        find first fbr-line
             where recid( fbr-line ) = v-fbr-line-recid
        .
        if p-qnty = ?
        then do:
            run str/fbr-line.w (
                  input p-fbrhist-handle
                , input 'ИЗМЕНЕНИЕ':U
                , input fbr-line.doc-code
                , input v-fbr-line-recid
                , input ?
                , output v-cancel
            ).
        end.
        else do:
            assign
                fbr-line.fact-qnty = fbr-line.fact-qnty + p-qnty
            .
        end.
        if r-type = "recipe-gds"
        then do:
            find first buf_comp_goods no-lock
                 where buf_comp_goods.artic     = buf_recipe.artic
                   and buf_comp_goods.prod-type = buf_recipe.prod-type
                   and buf_comp_goods.prod-code = buf_recipe.prod-code
            .
            assign
                v-goods-recid = recid( buf_comp_goods )
            .
            if buf_recipe.recipe-type = 'альтернатива':U
            then do:
                assign
                    comp-qnty = fbr-line.fact-qnty * buf_recipe-gds.brutto-qnty
                .
            end.
            else do:
                assign
                    comp-qnty = fbr-line.fact-qnty / buf_recipe-gds.brutto-qnty * buf_recipe.qnty
                .
            end.
            run str/fbr-crln.p (
                  input p-mainmenu-handle
                , input p-fbr-doc-recid
                , input v-goods-recid
                , input buf_recipe.recipe-code
                , input (if p-trn-type = 'спи':U then 'при':U else 'спи':U)
                , input yes
                , input p-recipe-recursive
                , input p-fbr-obj-type
                , input p-fbr-obj-code
                , output v-fbr-line-recid
            ).
            find first fbr-line
                 where recid( fbr-line ) = v-fbr-line-recid
            .
            assign
                fbr-line.fact-qnty = comp-qnty
                    - ( if p-ingr-line-exists = yes then fbr-line.fact-qnty else 0 )
            .
        end.
        run str/fbr-qnty.p (
              input p-mainmenu-handle
            , input p-fbrhist-handle
            , input p-fbr-doc-recid
            , input recid( fbr-line )
            , input no
            , input "ingr"
            , input p-recursive-enabled
            , input p-fbr-obj-type
            , input p-fbr-obj-code
            , input no
            , input p-autofbr
            , input p-have-store
            , output v-need-goods
            , output v-need-goods-list
            , output v-need-goods-qnty-list
        ).
        assign
            v-goods-recid = recid( buf_goods )
        .
    end.
    assign
        p-new-goods-recid = v-goods-recid
    .
end.
