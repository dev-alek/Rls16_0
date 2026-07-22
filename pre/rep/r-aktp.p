block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter p-price-celection    as integer          no-undo.
define input parameter p-print-null-qnty    as logical          no-undo.
define input parameter p-sort-by-group      as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-aktp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-aktp.p $":U .
define variable vss-description as character no-undo init "Протокол согласования отпускных цен".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
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
    def var log-file-name as char no-undo.
    assign
        log-file-name = 'r-akt.log'
    .
    if log-file-name <> "":U
    then do:
        if search( 'r-akt.log' ) = ?
        then do:
            output to value( 'r-akt.log' ).
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
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    def var v-price-list-doc-num            like price-list.doc-num     no-undo.
    def var v-price-list-price-sale         like price-list.price-sale  no-undo.
    def var v-price-list-price-sale_old     like price-list.price-sale  no-undo.
    def var v-price-list-road-tax           like price-list.road-tax    no-undo.
    def var v-price-list-excise             like price-list.excise      no-undo.
    def var v-price-list-b-code             like bar-code.b-code        no-undo.
    def var v-gds-obj-last-price            like gds-obj.last-rubl      no-undo.
    def var v-gds-prt-node-code             like gds-prt.node-code      no-undo.
    def var v-gds-prt-node-name             like gds-prt.node-name      no-undo.
    def var v-code-is-main                  as logical                  no-undo.
    def var v-not-main-unit-cli             like bar-code.unit-cli      no-undo.
    def var v-not-main-cli-base-rate        like bar-code.cli-base-rate no-undo.
    def var v-not-main-b-code               like bar-code.cli-base-rate no-undo.
    def var v-taxname                       as char                     no-undo.
    def var v-tax                           as decimal  init 0          no-undo.
    def var v-tax-sum                       as decimal  init 0          no-undo.
    def var v-tax-parts-qnty                as decimal  init 0          no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-single-line       as char    no-undo.
define variable v-line-counter      as integer no-undo.
define variable v-good-line-counter as integer no-undo.
define variable v-price-doc-doc-num          like price-doc.doc-num     no-undo.
define variable v-b-code            as char    no-undo.
define variable v-rb-is-base        as logical      no-undo.
define variable sym1  as char init ":"   no-undo.
define variable sym2  as char init ":"   no-undo.
define variable sym3  as char init ":"   no-undo.
define variable sym4  as char init ":"   no-undo.
define variable sym5  as char init ":"   no-undo.
define variable sym6  as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
def stream Prtcl .
define frame Protocol
        sym1 column-label ":!:" format "X(1)"
        v-good-line-counter column-label "N!п/п" format ">>>9"
        sym2 column-label ":!:" format "X(1)"
        v-b-code column-label "Код! " format "x(10)"
        sym3 column-label ":!:" format "X(1)"
        price-list.artic column-label "Артикул! " format "X(20)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name column-label "Название товара! " format "X(55)"
        sym5 column-label ":!:" format "X(1)"
        units.long-name column-label "Единица!измерения" format "X(10)"
        sym6 column-label ":!:" format "X(1)"
        price-list.price-sale column-label "Цена за единицу!"
            format ">>>,>>>,>>>,>>9.99"
        sym10 column-label ":!:" format "X(1)"
    header
        v-price-doc-doc-num at 70 format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Prtcl ), ">>9" ) ) at 120 format "X(13)" skip
        v-single-line format "X(136)" at 1
    with width 160 down stream-io use-text .
if session :set-wait-state( "compiler" ) then.
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
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
    assign
        v-single-line = fill("-", 136)
        v-line-counter = 1
        v-good-line-counter = 1
    .
    find first price-doc no-lock
        where recid(price-doc) = rec_id .
    if not available price-doc
    then do:
        bell.
        message vss-workfile + '. Порушена табличка price-doc'.
        return error.
    end.
    assign
        v-price-doc-doc-num  = price-doc.doc-num
    .
    output stream Prtcl to value( string( session:temp-directory +
                                "rpt" + string( g#report-num ) ) ) page-size 62 .
    put stream Prtcl space(20)
                "П Р О Т О К О Л   СОГЛАСОВАНИЯ  СВОБОДНЫХ  ОТПУСКНЫХ  ЦЕН"
                format "X(100)" skip(1)
            space(40) string( caps( price-doc.status_ ) + "  N " + v-price-doc-doc-num )
                format "X(60)" skip(1)
    .
    if price-doc.status_ = 'акт':U
    then do:
        put stream Prtcl
            space(100) "Цены введены с " format "X(20)"
            price-doc.doc-date format "99.99.9999"
            skip(1)
        .
    end.
    else do:
        put stream Prtcl
            skip(1)
        .
    end.
    form header
        v-single-line format "X(136)" at 1 skip
        "Продолжение - на следующей странице" at 30 skip
            with frame Bttmframe width 160 page-bottom no-labels no-box .
    view stream Prtcl frame Bttmframe .
    for each price-list no-lock
       where price-list.doc-num = price-doc.doc-num
      , each goods no-lock
       where goods.artic     = price-list.artic
         and goods.prod-type = price-list.prod-type
         and goods.prod-code = price-list.prod-code
    break by price-list.artic with frame Protocol
    :
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            find first bar-code no-lock
                 where bar-code.b-code = price-list.b-code
            .
            if bar-code.unit-cli = goods.unit-base
            then do:
                assign
                    v-code-is-main = yes
                .
            end.
            else do:
                assign
                    v-code-is-main = no
                .
            end.
            if not (v-code-is-main = yes)
            then do:
                assign
                    v-not-main-unit-cli       = bar-code.unit-cli
                    v-not-main-cli-base-rate  = bar-code.cli-base-rate
                    v-not-main-b-code         = bar-code.b-code
                .
            end.
            find first gds-prt no-lock
                 where gds-prt.node-code = bar-code.node-code
            .
            assign
              v-gds-prt-node-name =
              ( if gds-prt.upper-code = goods.prt-root
                then if bar-code.in-code = ''
                    then goods.gds-name
                    else bar-code.in-code + '    ' + bar-code.part-code
                else
                        '    ' + gds-prt.f-name
              )
            .
            run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Определили имя товара со шкалой ( "
                                                + dtm-char(v-gds-prt-node-name)
                                                + " )").
            find first gds-obj no-lock
                 where gds-obj.obj-type  = price-list.obj-type
                   and gds-obj.obj-code  = price-list.obj-code
                   and gds-obj.prod-type = price-list.prod-type
                   and gds-obj.prod-code = price-list.prod-code
                   and gds-obj.artic     = price-list.artic
            no-error.
            if available gds-obj
            then do:
                assign
                    v-gds-obj-last-price = ( if v-rb-is-base = yes then gds-obj.last-base else gds-obj.last-rubl )
                .
                if v-gds-obj-last-price = ?
                then do:
                    assign
                        v-gds-obj-last-price = 0
                    .
                end.
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Нашли товар ( "
                                + string(gds-obj.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Определили цену закупки ( "
                                + dtm-char(string(v-gds-obj-last-price)) + " )"
                                                    ).
            end.
            else do:
                assign
                    v-gds-obj-last-price = 0
                .
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Не нашли товара ( "
                                + string(price-list.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Назначили цену закупки ( 0 )"
                                                    ).
            end.
            find first gds-prt no-lock
                 where gds-prt.upper-code = goods.prt-root
            .
            assign
                v-gds-prt-node-code = gds-prt.node-code
            .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  price-list.obj-type
  ,input  price-list.obj-code
  ,input  price-list.b-code
  ,input  0
  ,input  price-list.fact-order
  ,output v-price-list-doc-num
  ,output v-price-list-price-sale
  ,output v-price-list-road-tax
  ,output v-price-list-excise
  )  .
            if v-price-list-price-sale = ?
            then do:
                assign
                    v-price-list-price-sale = 0
                .
            end.
            if v-price-list-road-tax = ?
            then do:
                assign
                    v-price-list-road-tax = 0
                .
            end.
            assign
                v-price-list-price-sale_old = v-price-list-price-sale
            .
            run writelog in this-procedure (log-file-name, 4,
                                                        "R-AKT.i   Определили продажную цену из прайс-листа ( "
                                                        + dtm-char(string(v-price-list-price-sale)) + " )"
                                                ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  bar-code.node-code
  ,output v-price-list-b-code
  )  .
            find first bar-code no-lock
                 where bar-code.b-code = v-price-list-b-code
            .
            accumulate bar-code.b-code ( count ) .
        if v-code-is-main
        then do:
          find first units no-lock
               where units.unit-name = goods.unit-base
          no-error.
          display stream Prtcl sym1 v-good-line-counter
                          sym2 trim (string ( bar-code.b-code ))        @ v-b-code
                          sym3 price-list.artic
                          sym4  v-gds-prt-node-name   @ goods.gds-name
                          sym5 units.long-name
                          sym6 price-list.price-sale
                          sym10
          .
          if not LAST( price-list.artic )
          then do:
            assign
                v-line-counter = v-line-counter  + 1
                v-good-line-counter = v-good-line-counter  + 1
            .
          end.
        end.
    end.
    hide stream Prtcl frame Bttmframe .
    if line-counter( Prtcl ) + 13 > page-size( Prtcl ) then
        page stream Prtcl .
    put stream Prtcl v-single-line      format "X(136)" skip(1) space(5) "Всего "
                    v-good-line-counter format ">,>>>,>>9" space(2)
                    "наименований"      format "x(13)" skip(1)
    .
    define variable v-user-name as character no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  v-cntxt-userid
  ,output v-user-name
  )  .
    put stream Prtcl skip(1) space(10) "Подписи сторон" format "x(100)" skip(1)
                    space(10) "Генеральный директор        : " format "x(70)" skip(1)
                    space(10) "Планово-экономический отдел : " format "x(70)" skip(1)
                    space(10) "Управляющий  магазином      : " format "x(70)" skip(3)
                    space(20) string( "Исполнитель : " + v-user-name ) format "x(70)" skip
    .
    output stream Prtcl close.
if session :set-wait-state( "" ) then.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
