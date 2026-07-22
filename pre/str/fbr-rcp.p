block-level on error undo, throw.
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo.
define input parameter p-fbr-doc-recid  as recid            no-undo.
define input parameter p-silent         as logical          no-undo .
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-autofbr        as logical          no-undo.
define input parameter p-have-store     as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: deb925b3c67c, 1358, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue May 22 14:25:44 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-rcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-rcp.p $":U .
define variable vss-description as character no-undo init "Резервирование и расчет учетных цен товаров рецепта.".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4',p-fbr-doc-recid,p-recipe-code,p-autofbr,p-have-store)
    .
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
    if search('fbr.log') = ?
    then do:
        assign
            log-file-name = ""
        .
    end.
    else do:
        assign
            log-file-name = 'fbr.log'
        .
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
define variable v-fbr-log-file-name as character no-undo init 'fbr-rsrv-errors.txt'.
define variable v-fbr-tt-log-file-name as character no-undo init 'fbr-rsrv-errors-tt.txt'.
define temp-table tt-rsrv-err no-undo
  field artic like ub.goods.artic
  field gds-name like ub.goods.gds-name
  field rsrv-qnty like ub.gds-obj.fact-qnty
  field req-qnty like ub.gds-obj.fact-qnty
.
define stream stm.
    define variable v-unit-type     as character            no-undo.
    define variable v-alt-in-qnty   like ub.fbr-line.fact-qnty no-undo.
    define variable v-value-character as character  no-undo .
    define variable v-value-date      as date       no-undo .
    define variable v-value-integer   as integer    no-undo .
    define variable v-value-logical   as logical    no-undo .
    define variable v-tth             as handle     no-undo .
    define variable v-param-type            as character no-undo .
    define variable v-min-mrgn      as decimal      no-undo.
    define variable v-max-mrgn      as decimal      no-undo.
    define variable v-sum-alternative-qnty              as decimal       no-undo.
    define variable v-sum-write-off-qnty                as decimal       no-undo.
    define variable v-sum-income-qnty                   as decimal       no-undo.
    define variable v-sum-write-off-price-r-b           as decimal       no-undo.
    define variable v-sum-write-off-price-not-r-b       as decimal       no-undo.
    define variable v-sum-vat-write-off-price-r-b       as decimal       no-undo.
    define variable v-sum-vat-write-off-price-notrb     as decimal       no-undo.
    define variable v-count-rsrv-qnty                   as integer       no-undo.
    define variable v-sum-fix-cost-price-r-b            as decimal       no-undo.
    define variable v-sum-vat-fix-cost-price-r-b        as decimal       no-undo.
    define variable v-sum-input-price-sale              as decimal       no-undo.
    define variable v-count-input-fact-qnty             as integer       no-undo.
    define variable v-sum-input-price-r-b               as decimal       no-undo.
    define variable v-sum-vat-input-price-r-b           as decimal       no-undo.
    define variable v-margin                            as decimal       no-undo.
    define variable v-rb-is-base        as logical      no-undo.
    define variable v-not-reserved      as logical      no-undo.
    define buffer buf_zero_fbr-line  for  ub.fbr-line.
    define buffer buf_in_fbr-line   for  ub.fbr-line.
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_goods         for ub.goods.
do
on error undo, return error
:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  'fbrattr':U
                     , input  'fbr-mrgn-max':U
                     , output v-value-character
                     , output v-value-date
                     , output v-max-mrgn
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      assign
         v-max-mrgn = 0
      .
   end.
   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  'fbrattr':U
                     , input  'fbr-mrgn-min':U
                     , output v-value-character
                     , output v-value-date
                     , output v-min-mrgn
                     , output v-value-integer
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      assign
         v-min-mrgn = 0
      .
   end.
    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input "=====*** fbr-rcp.p ***================================================"
    ).
    find first buf_fbr-doc exclusive-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = buf_fbr-doc.doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input substitute( "Документ &1. Рецепт &2"
                            , buf_fbr-doc.doc-code
                            , p-recipe-code )
    ).
if session :set-wait-state( "compiler" ) then.
    run calc-prices in this-procedure (
          input buf_fbr-doc.doc-code
        , input p-recipe-code
        , input v-rb-is-base
        , output v-unit-type
        , output v-sum-alternative-qnty
        , output v-sum-write-off-qnty
        , output v-sum-income-qnty
        , output v-sum-write-off-price-r-b
        , output v-sum-write-off-price-not-r-b
        , output v-sum-vat-write-off-price-r-b
        , output v-sum-vat-write-off-price-notrb
        , output v-count-rsrv-qnty
        , output v-sum-fix-cost-price-r-b
        , output v-sum-vat-fix-cost-price-r-b
        , output v-sum-input-price-sale
        , output v-count-input-fact-qnty
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    run writelog in this-procedure (
          input log-file-name
        , input 3
        , input substitute( "Расчитаны суммы учетных цен:"
                + chr(10) + "                           v-unit-type                      &1"
                + chr(10) + "                           v-sum-alternative-qnty           &2"
                + chr(10) + "                           v-sum-write-off-qnty             &3"
                + chr(10) + "                           v-sum-income-qnty                &4"
                + chr(10) + "                           v-sum-write-off-price-r-b        &5"
                + chr(10) + "                           v-sum-write-off-price-not-r-b    &6"
                + chr(10) + "                           v-sum-vat-write-off-price-r-b    &7"
                + chr(10) + "                           v-sum-vat-write-off-price-notrb  &8"
                + chr(10) + "                           v-count-rsrv-qnty                &9"
                , string( v-unit-type                      )
                , string( v-sum-alternative-qnty           )
                , string( v-sum-write-off-qnty             )
                , string( v-sum-income-qnty                )
                , string( v-sum-write-off-price-r-b        )
                , string( v-sum-write-off-price-not-r-b    )
                , string( v-sum-vat-write-off-price-r-b    )
                , string( v-sum-vat-write-off-price-notrb  )
                , string( v-count-rsrv-qnty                ) )
                + substitute(
                  chr(10) + "                           v-sum-fix-cost-price-r-b         &1"
                + chr(10) + "                           v-sum-vat-fix-cost-price-r-b     &2"
                + chr(10) + "                           v-sum-input-price-sale           &3"
                + chr(10) + "                           v-count-input-fact-qnty          &4"
                , string( v-sum-fix-cost-price-r-b         )
                , string( v-sum-vat-fix-cost-price-r-b     )
                , string( v-sum-input-price-sale           )
                , string( v-count-input-fact-qnty          ) )
    ).
    if v-sum-fix-cost-price-r-b     > v-sum-write-off-price-r-b
    or v-sum-vat-fix-cost-price-r-b > v-sum-vat-write-off-price-r-b
    then do:
        message "Сумма в учетных ценах по фиксированным строкам больше, чем вся сумма списания."
                skip(1) "Сумма приходных строк с фиксированной учетной ценой:"
                            v-sum-fix-cost-price-r-b
                skip    "Cумма списанных товаров в учетных ценах:            "
                            v-sum-write-off-price-r-b
                skip(1) "Сумма НДС приходных строк с фиксированной учетной ценой:"
                            v-sum-vat-fix-cost-price-r-b
                skip    "Cумма НДС списанных товаров в учетных ценах:            "
                            v-sum-vat-write-off-price-r-b
                skip(1) "Рецепт:" p-recipe-code
        view-as alert-box error.
if session :set-wait-state( "" ) then.
        undo, return error.
    end.
    if v-count-input-fact-qnty = 0
    and ( v-sum-fix-cost-price-r-b     <> v-sum-write-off-price-r-b
       or v-sum-vat-fix-cost-price-r-b <> v-sum-vat-write-off-price-r-b )
    then do:
        message     "При всех фиксированных приходных ценах "
            skip    "сумма в учетных ценах по строкам прихода не равна сумме списания."
            skip(2) "Сумма приходных строк в учетных ценах:"
                    v-sum-fix-cost-price-r-b
            skip    "Сумма строк списания в учетных ценах: "
                    v-sum-write-off-price-r-b
            skip(2) "Сумма НДС приходных строк в учетных ценах:"
                    v-sum-vat-fix-cost-price-r-b
            skip    "Сумма НДС строк списания в учетных ценах: "
                    v-sum-vat-write-off-price-r-b
            skip    "Эти суммы должны быть равны, поскольку ВСЕ приходные цены фиксированы!"
            skip(1) "Рецепт:" p-recipe-code
        view-as alert-box error.
if session :set-wait-state( "" ) then.
        undo, return error.
    end.
    if available buf_fbr-recipe
    and buf_fbr-recipe.recipe-type = 'альтернатива':U
    then do:
        run check-alternative in this-procedure (
              input buf_fbr-doc.doc-code
            , input buf_fbr-recipe.recipe-code
            , input buf_fbr-recipe.artic
            , input buf_fbr-recipe.prod-type
            , input buf_fbr-recipe.prod-code
            , input v-alt-in-qnty
            , input v-sum-alternative-qnty
        ) no-error.
      if error-status:error then do:
        undo, return error substitute("Ошибка при проверке товаров для рецепта типа АЛЬТЕРНАТИВА:&1&2&1&3"
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
        ).
      end.
    end.
    if  v-unit-type <> ""
    and v-unit-type <> "units-differ"
    and v-unit-type <> "not-weight"
    and buf_fbr-recipe.recipe-type = 'разделка':U
    then do:
        if abs( v-sum-income-qnty + v-sum-write-off-qnty )  > 0.01
        and ( not available buf_fbr-recipe or buf_fbr-recipe.recipe-type <> 'производство':U )
        then do:
            message     "Для весовых товаров не совпадают количества списанного и оприходованного товара."
                skip(2) "Количество списанного товара:     " ( -1 * v-sum-write-off-qnty )
                skip    "Количество оприходованного товара:" v-sum-income-qnty
                skip(1) "Рецепт: " p-recipe-code
            view-as alert-box error.
if session :set-wait-state( "" ) then.
            undo, return error.
        end.
    end.
    if v-count-rsrv-qnty = 0
    or v-count-input-fact-qnty = 0
    then do:
        message     "Среди израсходованных или произведенных товаров"
            skip    "нет ничего кроме отходов,"
            skip    "либо не заданы ингредиенты в альтернативе."
            skip(1) "Рецепт: " p-recipe-code
                view-as alert-box error.
if session :set-wait-state( "" ) then.
        undo, return error.
    end.
    assign
        v-sum-input-price-r-b       = 0
        v-sum-vat-input-price-r-b   = 0
    .
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input "Расчет сумм для строки. "
    ).
    calc-cost-for-fbr-line:
    for each buf_in_fbr-line exclusive-lock
       where buf_in_fbr-line.doc-code       = buf_fbr-doc.doc-code
         and buf_in_fbr-line.trn-type       = 'при':U
         and buf_in_fbr-line.recipe-code    = p-recipe-code
    on error undo, return error
    :
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input "Строка товара с артикулом " + buf_in_fbr-line.artic
        ).
        if buf_in_fbr-line.rsrv-qnty = ?
        then do:
            assign
                buf_in_fbr-line.price-rubl            = 0
                buf_in_fbr-line.price-base            = 0
                buf_in_fbr-line.price-sum-rubl        = 0
                buf_in_fbr-line.price-sum-base        = 0
                buf_in_fbr-line.price-sum-vat-rubl    = 0
                buf_in_fbr-line.price-sum-vat-base    = 0
            .
            run writelog in this-procedure (
                input log-file-name
                , input 3
                , input "Отходы. Учетная цена 0. "
            ).
        end.
        else do:
            if not buf_in_fbr-line.fix-cost
            then do:
                if v-rb-is-base = yes
                then do:
                assign
                        buf_in_fbr-line.price-base            = if buf_in_fbr-line.price-sale > 0 then ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale           else   ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                        buf_in_fbr-line.price-sum-base        = buf_in_fbr-line.price-base * buf_in_fbr-line.fact-qnty
                        buf_in_fbr-line.price-sum-vat-base    = if buf_in_fbr-line.price-sale > 0 then  ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale
                                                                    * buf_in_fbr-line.fact-qnty      else  ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b ) *  buf_in_fbr-line.fact-qnty
                    .
                    run writelog in this-procedure (
                          input log-file-name
                        , input 3
                        , input substitute( "Цены не фиксированы. В строку записаны суммы в учетных ценах: "
                                + chr(10) + "                           price-sum-base       : &1"
                                + chr(10) + "                           price-sum-vat-base   : &2"
                                , buf_in_fbr-line.price-sum-base
                                , buf_in_fbr-line.price-sum-vat-base  )
                    ).
                end.
                else do:
 assign
                        buf_in_fbr-line.price-rubl            = if buf_in_fbr-line.price-sale > 0 then ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale           else  ( v-sum-write-off-price-r-b - v-sum-fix-cost-price-r-b )
                        buf_in_fbr-line.price-sum-rubl        = buf_in_fbr-line.price-rubl * buf_in_fbr-line.fact-qnty
                        buf_in_fbr-line.price-sum-vat-rubl    = if buf_in_fbr-line.price-sale > 0 then ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b )
                                                                    * buf_in_fbr-line.price-sale
                                                                    / v-sum-input-price-sale
                                                                    * buf_in_fbr-line.fact-qnty     else ( v-sum-vat-write-off-price-r-b - v-sum-vat-fix-cost-price-r-b )  * buf_in_fbr-line.fact-qnty
                                     .
                    run writelog in this-procedure (
                        input log-file-name
                        , input 3
                        , input substitute( "Цены не фиксированы. В строку записаны суммы в учетных ценах: "
                                + chr(10) + "                           price-sum-rubl       : &1"
                                + chr(10) + "                           price-sum-vat-rubl   : &2"
                                , buf_in_fbr-line.price-sum-rubl
                                , buf_in_fbr-line.price-sum-vat-rubl  )
                    ).
                end.
            end.
            assign
                buf_in_fbr-line.rsrv-qnty = buf_in_fbr-line.fact-qnty.
            .
            run writelog in this-procedure (
                input log-file-name
                , input 2
                , input substitute( "Записано зарезервированное количество: &1"
                                    , string( buf_in_fbr-line.rsrv-qnty ) )
            ).
        end.
        assign
            v-sum-input-price-r-b       = v-sum-input-price-r-b
                                            + ( buf_in_fbr-line.fact-qnty
                                                * ( if v-rb-is-base = yes then buf_in_fbr-line.price-base else buf_in_fbr-line.price-rubl ) )
            v-sum-vat-input-price-r-b   = v-sum-vat-input-price-r-b
                                            + ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-vat-base else buf_in_fbr-line.price-sum-vat-rubl )
        .
        run writelog in this-procedure (
            input log-file-name
            , input 1
            , input substitute( "Вычислены суммы по приходу: "
                    + chr(10) + "                           v-sum-input-price-r-b     :  &1"
                    + chr(10) + "                           v-sum-vat-input-price-r-b :  &2"
                    , string( v-sum-input-price-r-b )
                    , string( v-sum-vat-input-price-r-b  )  )
        ).
        if v-min-mrgn = 0
        and v-max-mrgn = 0
        or buf_in_fbr-line.rsrv-qnty = ?
        then do:
            next calc-cost-for-fbr-line.
        end.
        find first buf_goods no-lock
             where buf_goods.artic     = buf_in_fbr-line.artic
               and buf_goods.prod-type = buf_in_fbr-line.prod-type
               and buf_goods.prod-code = buf_in_fbr-line.prod-code
        no-error.
        if error-status :error
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Не найден товар для строки рецепта " p-recipe-code
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        assign
            v-margin = ( buf_in_fbr-line.price-sale * buf_in_fbr-line.fact-qnty
                        - ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-base     else buf_in_fbr-line.price-sum-rubl     )
                        - ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-vat-base else buf_in_fbr-line.price-sum-vat-rubl )
                       ) / ( ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-base     else buf_in_fbr-line.price-sum-rubl     )
                            + ( if v-rb-is-base = yes then buf_in_fbr-line.price-sum-vat-base else buf_in_fbr-line.price-sum-vat-rubl )
                           ) * 100
        .
        if v-margin < v-min-mrgn
        or v-margin > v-max-mrgn
        then do:
            message  "Наценка выходит за значения, определенные параметрами"
                skip "минимальной и максимальной наценок для производства."
                skip(1) "Товар:  " buf_goods.artic buf_goods.gds-name
                skip    "Рецепт: " buf_fbr-recipe.recipe-code
                skip    "Наценка:" v-margin "%"
                skip(1) "В соответствии с настройкой fbr-mrgn "
                skip    "минимальная наценка:  " v-min-mrgn "%"
                skip    "максимальная наценка: " v-max-mrgn "%."
            view-as alert-box warning .
        end.
    end.
    calc-cost-for-fbr-line-not-r-b:
    for each buf_in_fbr-line exclusive-lock
    where buf_in_fbr-line.doc-code       = buf_fbr-doc.doc-code
        and buf_in_fbr-line.trn-type       = 'при':U
        and buf_in_fbr-line.recipe-code    = p-recipe-code
    on error undo, return error
    :
        if buf_in_fbr-line.rsrv-qnty = ?
        then do:
            next calc-cost-for-fbr-line-not-r-b.
        end.
        if v-rb-is-base = yes
        then do:
            assign
                buf_in_fbr-line.price-rubl            = ( if v-sum-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-write-off-price-not-r-b
                                                                        * buf_in_fbr-line.price-base
                                                                        / v-sum-input-price-r-b
                                                            )
                buf_in_fbr-line.price-sum-rubl        = buf_in_fbr-line.price-rubl
                                                                * buf_in_fbr-line.fact-qnty
                buf_in_fbr-line.price-sum-vat-rubl    = ( if v-sum-vat-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-vat-write-off-price-notrb
                                                                        * buf_in_fbr-line.price-sum-vat-base
                                                                        / v-sum-vat-input-price-r-b
                                                            )
            .
        end.
        else do:
            assign
                buf_in_fbr-line.price-base            = ( if v-sum-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-write-off-price-not-r-b
                                                                        * buf_in_fbr-line.price-rubl
                                                                        / v-sum-input-price-r-b
                                                            )
                buf_in_fbr-line.price-sum-base        = buf_in_fbr-line.price-base
                                                                * buf_in_fbr-line.fact-qnty
                buf_in_fbr-line.price-sum-vat-base    = ( if v-sum-vat-input-price-r-b = 0
                                                                then 0
                                                                else v-sum-vat-write-off-price-notrb
                                                                        * buf_in_fbr-line.price-sum-vat-rubl
                                                                        / v-sum-vat-input-price-r-b
                                                            )
            .
        end.
    end.
    assign
        buf_fbr-doc.status_ = 'разрешен':U
    .
if session :set-wait-state( "" ) then.
end.
procedure calc-prices :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code                as character    no-undo.
define input parameter p-recipe-code                     as character    no-undo.
define input parameter p-rb-is-base                      as logical      no-undo.
define output parameter p-unit-type                      as character    no-undo.
define output parameter p-sum-alternative-qnty           as decimal      no-undo.
define output parameter p-sum-write-off-qnty             as decimal      no-undo.
define output parameter p-sum-income-qnty                as decimal      no-undo.
define output parameter p-sum-write-off-price-r-b        as decimal      no-undo.
define output parameter p-sum-write-off-price-not-r-b    as decimal      no-undo.
define output parameter p-sum-vat-write-off-price-r-b    as decimal      no-undo.
define output parameter p-sum-vat-write-off-price-notrb  as decimal      no-undo.
define output parameter p-count-rsrv-qnty                as decimal      no-undo.
define output parameter p-sum-fix-cost-price-r-b         as decimal      no-undo.
define output parameter p-sum-vat-fix-cost-price-r-b     as decimal      no-undo.
define output parameter p-sum-input-price-sale           as decimal      no-undo.
define output parameter p-count-input-fact-qnty          as decimal      no-undo.
    define variable v-count-fix-cost    as integer      no-undo.
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input "calc-prices: Вычисление сумм по строкам списания. "
    ).
    define buffer buf_fbr-recipe        for ub.fbr-recipe.
    define buffer buf_fbr-recipe-gds    for ub.fbr-recipe-gds.
    define buffer buf_fbr-line      for ub.fbr-line.
    define buffer buf_comp_fbr-line for ub.fbr-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_units         for ub.units.
    find first buf_fbr-recipe no-lock
         where buf_fbr-recipe.doc-code    = p-fbr-doc-doc-code
           and buf_fbr-recipe.recipe-code = p-recipe-code
    .
    assign
        p-unit-type                         = ""
        p-sum-alternative-qnty              = 0
        p-sum-write-off-qnty                = 0
        p-sum-income-qnty                   = 0
        p-sum-write-off-price-r-b           = 0
        p-sum-write-off-price-not-r-b       = 0
        p-sum-vat-write-off-price-r-b       = 0
        p-sum-vat-write-off-price-notrb     = 0
        p-count-rsrv-qnty                   = 0
        v-count-fix-cost                    = 0
        p-sum-fix-cost-price-r-b            = 0
        p-sum-vat-fix-cost-price-r-b        = 0
        p-sum-input-price-sale              = 0
        p-count-input-fact-qnty             = 0
    .
    calc-prices-for-each-fbr-line:
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code      = p-fbr-doc-doc-code
         and buf_fbr-line.recipe-code   = p-recipe-code
    on error undo, return error
    :
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "Товар с артикулом &1"
                                , buf_fbr-line.artic )
        ).
        find first buf_goods no-lock
             where buf_goods.artic     = buf_fbr-line.artic
               and buf_goods.prod-type = buf_fbr-line.prod-type
               and buf_goods.prod-code = buf_fbr-line.prod-code
        .
        find first buf_units no-lock
             where buf_units.unit-name = buf_goods.unit-base
        .
        if buf_fbr-line.fact-qnty = ?
        then do:
if session :set-wait-state( "" ) then.
          undo, return error substitute("Не указано количество товара в документе пр-ва &5.&1Рецепт:  &2&1Товар:   &3 &4"
                                        , chr(10)
                                        , buf_fbr-line.recipe-code
                                        , buf_fbr-line.artic
                                        , buf_goods.gds-name
                                        ,p-fbr-doc-doc-code
                                        ).
        end.
        if buf_fbr-recipe.recipe-type <> 'разделка':U
        and ( buf_fbr-recipe.artic <> buf_fbr-line.artic
            or buf_fbr-recipe.prod-type <> buf_fbr-line.prod-type
            or buf_fbr-recipe.prod-code <> buf_fbr-line.prod-code )
        then do:
            find first buf_fbr-recipe-gds no-lock
                 where buf_fbr-recipe-gds.doc-code      = buf_fbr-line.doc-code
                   and buf_fbr-recipe-gds.recipe-code   = buf_fbr-line.recipe-code
                   and buf_fbr-recipe-gds.prod-type     = buf_fbr-line.prod-type
                   and buf_fbr-recipe-gds.prod-code     = buf_fbr-line.prod-code
                   and buf_fbr-recipe-gds.artic         = buf_fbr-line.artic
            no-error.
            if not available buf_fbr-recipe-gds
            then do:
if session :set-wait-state( "" ) then.
                undo, return error substitute("Отсутствует строка рецепта. Расчет невозможен. Измените документ &1.&2" +
                                              "Артикул: &3 &4&2Рецепт: &4"
                                        ,p-fbr-doc-doc-code
                                        , chr(10)
                                        , buf_goods.artic
                                        , buf_goods.gds-name
                                        , buf_fbr-line.recipe-code
                                        ).
            end.
            find first buf_comp_fbr-line
                 where buf_comp_fbr-line.doc-code     = p-fbr-doc-doc-code
                   and buf_comp_fbr-line.recipe-code  = p-recipe-code
                   and buf_comp_fbr-line.is-comp      = yes
            no-error.
            if not available buf_comp_fbr-line
            then do:
                undo, return error substitute("&1 &2 &3&4Не найдена строка составного товара в документе пр-ва &7.&4&5&4&6"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              , error-status:get-message(1)
                                              , return-value
                                              ,p-fbr-doc-doc-code
                                              ).
            end.
            if buf_fbr-recipe.recipe-type = 'альтернатива':U
            then do:
                assign
                    p-sum-alternative-qnty = p-sum-alternative-qnty + ( buf_fbr-line.fact-qnty * buf_fbr-recipe-gds.brutto-qnty )
                .
            end.
            else do:
                if round( buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.brutto-qnty * buf_fbr-recipe.qnty, 3 ) <> round( buf_comp_fbr-line.fact-qnty, 3 )
                then do:
if session :set-wait-state( "" ) then.
                  undo, return error
                  substitute("Не соответствуют рецепту количество ингридиента и количество составного товара&1в док-те пр-ва &7&1" +
                              "Рецепт: &2&1Товар: &3 &4&1Количество ингридиента:       &5&1"  +
                              "Количество составного товара: &6"
                              , chr(10)
                              , buf_fbr-line.recipe-code
                              , buf_goods.artic
                              , buf_goods.gds-name
                              , buf_fbr-line.fact-qnty
                              , buf_comp_fbr-line.fact-qnty
                              , buf_fbr-line.doc-code
                              )
                  .
                end.
            end.
        end.
        if buf_goods.gds-type <> 'у':U
        then do:
            if lookup ( 'вес':U, buf_units.type ) > 0
            then do:
                if p-unit-type = buf_units.unit-name
                or p-unit-type = ""
                then do:
                    assign
                        p-unit-type = buf_units.unit-name
                    .
                    if buf_fbr-line.trn-type = 'спи':U
                    then do:
                        assign
                            p-sum-write-off-qnty = p-sum-write-off-qnty - buf_fbr-line.fact-qnty
                        .
                    end.
                    else do:
                        assign
                            p-sum-income-qnty = p-sum-income-qnty + buf_fbr-line.fact-qnty
                        .
                    end.
                end.
                else do:
                    assign
                        p-unit-type = "units-differ"
                    .
                end.
            end.
            else do:
                assign
                    p-unit-type = "not-weight"
                .
            end.
        end.
        if buf_fbr-line.rsrv-qnty = ?
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 3
                , input "calc-prices: Строка отходов. В сумме не учитывается."
            ).
            next calc-prices-for-each-fbr-line.
        end.
        if buf_fbr-line.trn-type = 'спи':U
        then do:
            run str/fbr-gds.p (
                  INPUT parparentproc
                , input p-fbrhist-handle
                , input p-fbr-doc-recid
                , input yes
                , input recid( buf_goods )
                , input p-autofbr
                , input p-have-store
            ) no-error.
            if error-status :error
            then do:
                if return-value = 'not-reserved' then do:
                  run writelog in this-procedure (
                    input 'fbr-rsrv-errors.txt'
                  , input 0
                  , input substitute("Не зарезервирован товар &1 &2 &3 кол-во &4 рецепт &5",
                      buf_fbr-line.artic,
                      buf_fbr-line.prod-type,
                      buf_fbr-line.prod-code,
                      buf_fbr-line.fact-qnty,
                      buf_fbr-line.recipe-code)
                  ).
                  v-not-reserved = true.
                  next calc-prices-for-each-fbr-line.
                end.
                if error-status :get-message(1) <> ""
                or return-value <> "user-interrupt":U
                then do:
                  if true  then do:
                     run writelog in this-procedure (
                                        input 'fbr-rsrv-errors.txt'
                                      , input 0
                                      , input substitute("&1 &2 &3&4Ошибка при резервировании товара.&4Товар:     &5 &6&4В рецепте: &7&8&9"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,chr(10)
                                                    ,buf_goods.artic
                                                    ,buf_goods.gds-name
                                                    ,p-recipe-code
                                                    ,chr(10)
                                                    ,return-value)
                                                    ).
                     v-not-reserved = true.
                     next calc-prices-for-each-fbr-line.
                  end.
                  else do:
                    message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при резервировании товара."
                    skip "Товар:     " buf_goods.artic "  " buf_goods.gds-name
                    skip "В рецепте: " p-recipe-code
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                    view-as alert-box error.
                end.
                end.
                undo, return error return-value.
            end.
            run writelog in this-procedure (
                  input log-file-name
                , input 0
                , input "calc-prices: =====*** fbr-rcp.p ***=== Возврат после fbr-gds ========"
            ).
            if buf_fbr-line.rsrv-qnty <> buf_fbr-line.fact-qnty
            then do:
if session :set-wait-state( "" ) then.
              undo, return error substitute("Не удалось зарезервировать товар. Рецепт не может быть рассчитан.&1" +
                                            "Товар:     &2 &3&1В рецепте: &4"
                                            , chr(10)
                                            , buf_goods.artic
                                            ,buf_goods.gds-name
                                            ,p-recipe-code).
            end.
            if p-rb-is-base = yes
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input substitute( "calc-prices: Резервирование товара прошло успешно. Количество, цена и сумма НДС в строке товара: "
                                + chr(10) + "                           buf_fbr-line.rsrv-qnty            &1"
                                + chr(10) + "                           buf_fbr-line.price-base           &2"
                                + chr(10) + "                           buf_fbr-line.price-sum-vat-base   &3"
                                , string( buf_fbr-line.rsrv-qnty )
                                , string( buf_fbr-line.price-base   )
                                , string( buf_fbr-line.price-sum-vat-base   ) )
                ).
            end.
            else do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 3
                    , input substitute( "calc-prices: Резервирование товара прошло успешно. Количество, цена и сумма НДС в строке товара: "
                                + chr(10) + "                           buf_fbr-line.rsrv-qnty            &1"
                                + chr(10) + "                           buf_fbr-line.price-rubl           &2"
                                + chr(10) + "                           buf_fbr-line.price-sum-vat-rubl   &3"
                                , string( buf_fbr-line.rsrv-qnty )
                                , string( buf_fbr-line.price-rubl   )
                                , string( buf_fbr-line.price-sum-vat-rubl   ) )
                ).
            end.
            if buf_fbr-line.fact-qnty <> 0
            then do:
                assign
                    p-sum-write-off-price-r-b       = p-sum-write-off-price-r-b
                                                    + ( buf_fbr-line.rsrv-qnty * ( if p-rb-is-base = yes then buf_fbr-line.price-base else buf_fbr-line.price-rubl ) )
                    p-sum-write-off-price-not-r-b   = p-sum-write-off-price-not-r-b
                                                    + ( buf_fbr-line.rsrv-qnty * ( if p-rb-is-base = yes then buf_fbr-line.price-rubl else buf_fbr-line.price-base ) )
                    p-sum-vat-write-off-price-r-b   = p-sum-vat-write-off-price-r-b
                                                    + ( if p-rb-is-base = yes then buf_fbr-line.price-sum-vat-base else buf_fbr-line.price-sum-vat-rubl )
                    p-sum-vat-write-off-price-notrb = p-sum-vat-write-off-price-notrb
                                                    + ( if p-rb-is-base = yes then buf_fbr-line.price-sum-vat-rubl else buf_fbr-line.price-sum-vat-base )
                    p-count-rsrv-qnty = p-count-rsrv-qnty + 1
                .
                run writelog in this-procedure (
                    input log-file-name
                    , input 3
                    , input substitute( "calc-prices: Вычислены суммы списания: "
                            + chr(10) + "                           p-sum-write-off-price-r-b     &1"
                            + chr(10) + "                           p-sum-vat-write-off-price-r-b &2"
                            , string( p-sum-write-off-price-r-b )
                            , string( p-sum-vat-write-off-price-r-b  ) )
                ).
            end.
        end.
        else do:
            if buf_fbr-line.fix-cost
            then do:
                assign
                    p-sum-fix-cost-price-r-b        = p-sum-fix-cost-price-r-b
                            + ( buf_fbr-line.fact-qnty * ( if p-rb-is-base = yes then buf_fbr-line.price-base else buf_fbr-line.price-rubl ) )
                    p-sum-vat-fix-cost-price-r-b    = p-sum-vat-fix-cost-price-r-b
                            + ( if p-rb-is-base = yes then buf_fbr-line.price-sum-vat-base else buf_fbr-line.price-sum-vat-rubl )
                    v-count-fix-cost                = v-count-fix-cost + 1
                .
            end.
            else do:
                assign
                    p-sum-input-price-sale  = p-sum-input-price-sale
                            + ( buf_fbr-line.fact-qnty * buf_fbr-line.price-sale )
                    p-count-input-fact-qnty = p-count-input-fact-qnty + 1
                .
            end.
            assign
                v-alt-in-qnty = buf_fbr-line.fact-qnty
            .
            run writelog in this-procedure (
                input log-file-name
                , input 3
                , input substitute( "calc-prices: Вычислена сумма прихода в продажных ценах: "
                        + chr(10) + "                           p-sum-input-price-sale     &1"
                        ,  string( p-sum-input-price-sale ) )
            ).
        end.
    end.
    if v-not-reserved then
      return error 'not-reserved'.
end.
end procedure.
procedure check-alternative :
do
on error undo, return error
:
    define input parameter p-doc-code       as character    no-undo.
    define input parameter p-recipe-code    as character    no-undo.
    define input parameter p-artic          as character    no-undo.
    define input parameter p-prod-type      as character    no-undo.
    define input parameter p-prod-code      as integer      no-undo.
    define input parameter p-income-qnty    as decimal      no-undo.
    define input parameter p-write-off-qnty as decimal      no-undo.
    define variable v-del-zero             as logical        no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_zero_fbr-line for ub.fbr-line.
    define buffer buf_fbr-line      for ub.fbr-line.
        find first buf_goods no-lock
             where buf_goods.artic     = p-artic
               and buf_goods.prod-type = p-prod-type
               and buf_goods.prod-code = p-prod-code
        .
        if round ( p-income-qnty, 3 ) <> round ( p-write-off-qnty, 3 )
        then do:
if session :set-wait-state( "" ) then.
            undo, return error substitute("Док-нт пр-ва &7&1Количество оприходованного товара не равно количеству списанного.&1" +
                                          "Количество оприходованного товара: &2&1"  +
                                          "Количество списанного товара:     &3&1Товар: &4 &5&1Рецепт: &6"
                                          , chr(10)
                                          , p-income-qnty
                                          ,p-write-off-qnty
                                          ,buf_goods.artic
                                          ,buf_goods.gds-name
                                          ,buf_fbr-recipe.recipe-code
                                          ,p-doc-code
                                          ).
        end.
        for each buf_fbr-line no-lock
           where buf_fbr-line.doc-code     = p-doc-code
             and buf_fbr-line.is-comp      = no
             and buf_fbr-line.recipe-code  = p-recipe-code
             and buf_fbr-line.fact-qnty    = 0
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.artic     = buf_fbr-line.artic
                   and buf_goods.prod-type = buf_fbr-line.prod-type
                   and buf_goods.prod-code = buf_fbr-line.prod-code
            .
            if p-autofbr    = yes
            then do:
                assign
                    v-del-zero = yes
                .
            end.
            else do:
                if v-del-zero = no
                then do:
                   if p-silent then do:
                      v-del-zero = yes.
                   end.
                   else do:
                    message
                            "В сбалансированном рецепте альтернативы"
                        skip "есть строки с количеством 0."
                        skip "Необходимо либо удалить эти строки,"
                        skip "либо продолжить редактирование документа."
                        skip(1) "Рецепт: " p-recipe-code
                        skip(1) "Удалить строки с количеством 0?"
                    view-as alert-box information
                    buttons yes-no
                    title "Нулевые строки в рецепте альтернативы"
                    update v-del-zero .
                    if v-del-zero = no
                    then do:
                        undo, return error.
                    end.
                end.
            end.
            end.
            if v-del-zero = no
            then do:
                undo, return error.
            end.
            else do:
                find first buf_zero_fbr-line exclusive-lock
                     where recid( buf_zero_fbr-line ) = recid( buf_fbr-line )
                .
                delete buf_zero_fbr-line.
            end.
        end.
end.
end procedure.
