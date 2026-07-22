block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Discnt_Type          as integer          no-undo.
define input parameter PriceType            as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-nest2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-nest2.p $":U .
define variable vss-description as character no-undo init "Акт несоответствия с округлением".
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable     s1               as      character             no-undo.
define variable     s2               as      character             no-undo.
define variable     s3               as      character             no-undo.
define variable     Isp_name   as      character             no-undo.
define variable     Line            as      character             no-undo.
define variable     upper          as      integer                 no-undo.
define variable     UpSub_Price-Base  like    ub.gds-dtl.price-base  no-undo.
define variable     UpSub_Price-Rubl  like    ub.gds-dtl.price-rubl  no-undo.
define variable     UpSub_Qnty           like    ub.gds-dtl.doc-qnty     no-undo.
define variable     DownSub_Price-Base  like    ub.gds-dtl.price-base  no-undo.
define variable     DownSub_Price-Rubl  like    ub.gds-dtl.price-rubl  no-undo.
define variable     DownSub_Qnty            like    ub.gds-dtl.doc-qnty     no-undo.
define variable     Sub_Price-Base  like    ub.gds-dtl.price-base  no-undo.
define variable     Sub_Price-Rubl   like    ub.gds-dtl.price-rubl  no-undo.
define variable     Sub_Qnty            like    ub.gds-dtl.doc-qnty     no-undo.
define variable     Gds_Name    like    ub.goods.gds-name  no-undo.
define variable     tprice-base     like    ub.gds-dtl.price-base  no-undo.
define variable     tprice-rubl     like    ub.gds-dtl.price-rubl  no-undo.
def buffer Our_Object for ub.clients.
define variable     tsum_base    as decimal     no-undo.
define variable     tsum_rubl    as decimal     no-undo.
define variable     tqnty_    as decimal    no-undo.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-base-code     as integer      no-undo.
DEFINE FRAME x1
        sym1 column-label ":!:" format "X(1)" space(0)
        ub.bar-code.b-code COLUMN-LABEL "Код     ! " format ">>>>>>>>>9"
        ub.goods.artic COLUMN-LABEL "Артикул! " format "X(16)"
        Gds_Name COLUMN-LABEL "Наименование! " format "X(33)"
        tprice-base COLUMN-LABEL "Цена за ед.!(Б.вал.) " format ">>>,>>>,>>9.99"
        ub.gds-dtl.doc-qnty COLUMN-LABEL "Количество  !по док-ту" format "->>>>>>9.<<<"
        ub.gds-dtl.fact-qnty COLUMN-LABEL "Количество   !фактически" format "->>>>>>>9.<<<"
        Sub_Qnty COLUMN-LABEL "Разница кол-во! " format "->>,>>>,>>9.<<"
        Sub_Price-Base COLUMN-LABEL "Разница сумма!(Б.вал.) " format "->>>,>>>,>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) AT 110 format "X(13)" SKIP
        Line no-label format "X(136)" AT 1
    with width 235 down stream-io use-text .
DEFINE FRAME x1-rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        ub.bar-code.b-code COLUMN-LABEL "Код! " format ">>>>>>>>>9"
        ub.goods.artic COLUMN-LABEL "Артикул! " format "X(16)"
        Gds_Name COLUMN-LABEL "Наименование! " format "X(33)"
        tprice-rubl COLUMN-LABEL "Цена за ед.!(РУБ)" format ">>>,>>>,>>9.99"
        ub.gds-dtl.doc-qnty COLUMN-LABEL "Количество  !по док-ту" format "->>>>>>9.<<<"
        ub.gds-dtl.fact-qnty COLUMN-LABEL "Количество   !фактически" format "->>>>>>>9.<<<"
        Sub_Qnty COLUMN-LABEL "Разница кол-во! " format "->>,>>>,>>9.<<"
        Sub_Price-Rubl COLUMN-LABEL "Разница сумма!(РУБ)" format "->>>,>>>,>>9.99" space(0)
        sym2 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER, ">>9") ) AT 110 format "X(13)" SKIP
        Line no-label format "X(136)" AT 1
    with width 235 down stream-io use-text .
DEFINE FRAME x2
    s1 no-label format "X(20)"
    s2 column-label "Дата" format "99/99/9999"
    tqnty_ column-label "Количество" format "->>>>,>>9.<<<"
    tsum_base  column-label "Сумма (Б.вал.)" format "->>,>>>,>>>,>>9.99"
    with  width 235 down stream-io use-text .
DEFINE FRAME x2-rubl
    s1 no-label format "X(20)"
    s2 column-label "Дата" format "99/99/9999"
    tqnty_ column-label "Количество" format "->>>>,>>9.<<<"
    tsum_rubl  column-label "Сумма (РУБ)" format "->>>>>>,>>>,>>9.99"
    with width 235 down stream-io use-text .
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
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
FIND ub.trn-doc WHERE recid( ub.trn-doc ) = rec_id  NO-LOCK .
if NOT ub.trn-doc.print-rubl then
    message "Документ печатать в РУБЛЯХ ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
else
    assign PrintRubl = yes .
Line = fill("-", 140).
FIND ub.clients WHERE ub.clients.obj-type = ub.trn-doc.cli-type and
                                   ub.clients.obj-code = ub.trn-doc.cli-code NO-LOCK .
FIND ub.pay-type WHERE ub.pay-type.obj-code = ub.trn-doc.pay-code NO-LOCK NO-ERROR.
s1 = if available ub.pay-type then ub.pay-type.obj-name else "" .
FIND Our_Object WHERE Our_Object .obj-type = ub.trn-doc.obj-type AND
                                          Our_Object .obj-code = ub.trn-doc.obj-code NO-LOCK .
run rep/get-psn.p ( input trn-doc.boss, output s2 ).
run rep/get-psn.p ( input trn-doc.wrkr, output s3 ).
run rep/get-psn.p ( input trn-doc.agnt, output Isp_name ) .
output   to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
PUT SKIP SPACE(35) "АКТ НЕСООТВЕТСТВИЯ по " format "X(22)".
CASE trn-doc.doc-type :
    WHEN 'при':U then
        PUT "приходной накладной N " format "X(22)".
    WHEN 'рас':U then
        do:
            if  trn-doc.internal then
                PUT "требованию N " format "X(13)".
            else
                PUT "расходной накладной N " format "X(22)".
        end.
    WHEN 'возврат':U then
        PUT "возвратной накладной N " format "X(24)".
    WHEN 'инв':U then do:
      if trn-doc.ext-doc-type = 'vt':U then do:
        PUT "инвентаризационной описи N " format "X(30)".
      end.
      if trn-doc.ext-doc-type = 'vp':U then do:
        PUT "пересортицы N " format "X(18)".
      end.
      if trn-doc.ext-doc-type = 'ap':U then do:
        put "документа коррекции учетных цен N " format "X(34)".
      end.
      if trn-doc.ext-doc-type = 'pc':U then do:
        put "документа смены типа приобретения N " format "x(36)".
      end.
    end.
END CASE.
PUT trn-doc.doc-code + "  от  " + string(day(trn-doc.doc-date)) + chr(47) +
        string(month(trn-doc.doc-date)) + chr(47) +
        string(year(trn-doc.doc-date)) format "X(100)" SKIP(1).
if can-do( 'при,возврат':U , trn-doc.doc-type ) then
    PUT SPACE(10) "От кого : " clients.obj-name format "x(40)" SKIP
            SPACE(10) "Кому    : " Our_Object .obj-type format "x(4)"
            Our_Object .obj-name format "x(40)" SKIP(1).
else
    if can-do( 'инв':U , trn-doc.doc-type ) then
        PUT SPACE(10) "От кого : " Our_Object.obj-name format "x(40)" SKIP
                SPACE(10) "Кому    : " Our_Object.obj-name format "x(40)" SKIP(1).
    else
        PUT SPACE(10) "От кого : " Our_Object.obj-name format "x(40)" SKIP
                SPACE(10) "Кому    : " clients.obj-name format "x(40)" SKIP(1).
PUT SPACE(10) "Торговый представитель : " + s2 format "X(60)" space(5)
        "Кладовщик              : " + s3 format "X(60)" SKIP
        SPACE(10) "Исполнитель            : " + Isp_name format "X(60)" space(5)
        "Вид оплаты             : " + s1 format "X(60)" SKIP .
PUT SPACE(75)
        "Курс                   : " + string( trn-doc.base-rate / trn-doc.base-scale, ">>>,>>9.9999" )
        format "X(60)" SKIP(1) .
if can-do( "Учетные", PriceType ) then
    PUT SPACE(40) "Указаны  У Ч Е Т Н Ы Е  цены." format "X(60)" SKIP .
else
    PUT SPACE(40) "Указаны  П Р О Д А Ж Н Ы Е  цены." format "X(60)" SKIP .
if PrintRubl then FORM with frame x1-rubl .
else FORM with frame x1 .
FORM HEADER
        Line format "X(136)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width 160 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW FRAME BottomFrame .
if session :set-wait-state( "compiler" ) then.
FOR EACH ub.doc-line where ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK ,
        EACH ub.goods WHERE ub.goods.prod-type = ub.doc-line.prod-type AND
                                      ub.goods.prod-code = ub.doc-line.prod-code AND
                                      ub.goods.artic = ub.doc-line.artic NO-LOCK ,
        EACH ub.gds-dtl where ub.gds-dtl.prod-type = ub.doc-line.prod-type
                            and ub.gds-dtl.prod-code = ub.doc-line.prod-code
                            and ub.gds-dtl.artic = ub.doc-line.artic
                            and ub.gds-dtl.doc-code = ub.doc-line.doc-code NO-LOCK
                            BREAK BY ub.doc-line.artic :
    assign
        tprice-base = ( if can-do( "Учетные", PriceType )
                                then round(ub.doc-line.price-base, 2)    else round(ub.gds-dtl.price-base, 2) )
        tprice-rubl = ( if can-do( "Учетные", PriceType )
                              then round(ub.doc-line.price-rubl, 2)   else round(ub.gds-dtl.price-rubl, 2) )
        .
    ACCUMULATE
                    doc-line.artic ( COUNT )
                    gds-dtl.fact-qnty ( TOTAL )
                    gds-dtl.doc-qnty ( TOTAL )
                    ( gds-dtl.fact-qnty - gds-dtl.doc-qnty ) ( TOTAL )
                    ( gds-dtl.fact-qnty - gds-dtl.doc-qnty ) * tprice-base ( TOTAL )
                    ( gds-dtl.fact-qnty - gds-dtl.doc-qnty ) * tprice-rubl ( TOTAL )
                    gds-dtl.doc-qnty * tprice-base ( TOTAL )
                    gds-dtl.fact-qnty * tprice-base ( TOTAL )
                    gds-dtl.doc-qnty * tprice-rubl ( TOTAL )
                    gds-dtl.fact-qnty * tprice-rubl ( TOTAL )
                    gds-dtl.doc-qnty * ( tprice-base - round(gds-dtl.discnt-base, 2) ) ( TOTAL )
                    gds-dtl.fact-qnty * ( tprice-base - round(gds-dtl.discnt-base, 2) ) ( TOTAL )
                    gds-dtl.doc-qnty * ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) ) ( TOTAL )
                    gds-dtl.fact-qnty * ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) ) ( TOTAL ) .
    if ( NOT trn-doc.doc-type = 'инв':U AND ( gds-dtl.doc-qnty <> gds-dtl.fact-qnty ) ) OR
       ( trn-doc.doc-type = 'инв':U AND
            gds-dtl.doc-qnty <> 0 AND gds-dtl.doc-qnty <> ? )    then
        do:
            assign
                upper = gds-dtl.prt-code
                Gds_Name = goods.gds-name
                Sub_Qnty = ( if trn-doc.doc-type = 'инв':U
                                      then gds-dtl.doc-qnty
                                      else ( gds-dtl.doc-qnty - gds-dtl.fact-qnty ) )
                .
            if trn-doc.doc-type = 'инв':U  then
                do:
                    assign
                        Sub_Price-Base = Sub_Qnty * tprice-base
                        Sub_Price-Rubl = Sub_Qnty * tprice-rubl .
                    if Sub_Qnty > 0 then
                        assign
                            UpSub_Qnty = Sub_Qnty
                            UpSub_Price-Base = Sub_Price-Base
                            UpSub_Price-Rubl = Sub_Price-Rubl
                            DownSub_Qnty = 0
                            DownSub_Price-Base = 0
                            DownSub_Price-Rubl = 0 .
                    else
                        assign
                            UpSub_Qnty = 0
                            UpSub_Price-Base = 0
                            UpSub_Price-Rubl = 0
                            DownSub_Qnty = Sub_Qnty
                            DownSub_Price-Base = Sub_Price-Base
                            DownSub_Price-Rubl = Sub_Price-Rubl .
                end.
            else
                do:
                    assign
                        Sub_Price-Base = ( if Discnt_Type = 1
                                                        then Sub_Qnty * ( tprice-base - round(gds-dtl.discnt-base, 2) )
                                                        else Sub_Qnty * tprice-base )
                        Sub_Price-Rubl = ( if Discnt_Type = 1
                                                       then Sub_Qnty * ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) )
                                                       else Sub_Qnty * tprice-rubl ) .
                    if gds-dtl.doc-qnty > gds-dtl.fact-qnty then
                        assign
                            UpSub_Qnty = 0
                            UpSub_Price-Base = 0
                            UpSub_Price-Rubl = 0
                            DownSub_Qnty = Sub_Qnty
                            DownSub_Price-Base = Sub_Price-Base
                            DownSub_Price-Rubl = Sub_Price-Rubl .
                    else
                        assign
                            UpSub_Qnty = - Sub_Qnty
                            UpSub_Price-Base = - Sub_Price-Base
                            UpSub_Price-Rubl = - Sub_Price-Rubl
                            DownSub_Qnty = 0
                            DownSub_Price-Base = 0
                            DownSub_Price-Rubl = 0 .
                end.
            ACCUMULATE
                Sub_Qnty (TOTAL)
                Sub_Price-Base (TOTAL)
                Sub_Price-Rubl (TOTAL)
                UpSub_Qnty (TOTAL)
                UpSub_Price-Base (TOTAL)
                UpSub_Price-Rubl (TOTAL)
                DownSub_Qnty (TOTAL)
                DownSub_Price-Base (TOTAL)
                DownSub_Price-Rubl (TOTAL) .
            FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code AND
                                                  ub.bar-code.unit-cli = ub.goods.unit-base AND
                                                  ub.bar-code.node-code = ub.gds-dtl.prt-code AND
                                                  ub.bar-code.part-code = "" AND
                                                  ub.bar-code.in-code = "" NO-LOCK .
            REPEAT :
                FIND ub.gds-prt where ub.gds-prt.node-code = upper AND
                                                NOT ub.gds-prt.root NO-LOCK NO-ERROR .
                if not available ub.gds-prt then
                    leave.
                assign
                    Gds_Name = Gds_Name + chr(47) + ub.gds-prt.node-name
                    upper = ub.gds-prt.upper-code .
            END.
            if PrintRubl then
                do:
                    DISPLAY sym1 bar-code.b-code
                                    goods.artic
                                    Gds_Name
                                    ( if Discnt_Type = 1
                                      then ( tprice-rubl - round(gds-dtl.discnt-rubl, 2) )
                                      else tprice-rubl ) @ tprice-rubl
                                    ( if trn-doc.doc-type = 'инв':U
                                      then ( gds-dtl.fact-qnty - gds-dtl.doc-qnty )
                                      else gds-dtl.doc-qnty ) @ gds-dtl.doc-qnty
                                    gds-dtl.fact-qnty       when gds-dtl.fact-qnty  <> 0
                                    Sub_Qnty
                                    Sub_Price-Rubl
                                    sym2    with frame x1-rubl.
                    DOWN 1 with frame x1-rubl.
                end .
            else
                do:
                    DISPLAY sym1 bar-code.b-code
                                    goods.artic
                                    Gds_Name
                                    ( if Discnt_Type = 1
                                      then ( tprice-base - round(gds-dtl.discnt-base, 2) )
                                      else tprice-base ) @ tprice-base
                                    ( if trn-doc.doc-type = 'инв':U
                                      then ( gds-dtl.fact-qnty - gds-dtl.doc-qnty )
                                      else gds-dtl.doc-qnty ) @ gds-dtl.doc-qnty
                                    gds-dtl.fact-qnty       when gds-dtl.fact-qnty  <> 0
                                    Sub_Qnty
                                    Sub_Price-Base
                                    sym2    with frame x1.
                    DOWN 1 with frame x1 .
                end .
        end .
    if last( doc-line.artic ) then
        do:
            PUT Line format "X(136)" SKIP.
            if PrintRubl then
                do:
                    DISPLAY "ИТОГО" @ Gds_Name
                                    ACCUM TOTAL Sub_Qnty @ Sub_Qnty
                                    ACCUM TOTAL Sub_Price-Rubl @ Sub_Price-Rubl
                                    with frame x1-rubl.
                    UNDERLINE Gds_Name Sub_Qnty Sub_Price-Rubl with frame x1-rubl.
                    DOWN 2 with frame x1-rubl.
                end .
            else
                do:
                    DISPLAY "ИТОГО" @ Gds_Name
                                    ACCUM TOTAL Sub_Qnty @ Sub_Qnty
                                    ACCUM TOTAL Sub_Price-Base @ Sub_Price-Base
                                    with frame x1 .
                    UNDERLINE Gds_Name Sub_Qnty Sub_Price-Base with frame x1 .
                    DOWN 2 with frame x1 .
                end .
        end.
END.
if session :set-wait-state( "" ) then.
if PrintRubl then
    REPEAT with FRAME x2-rubl:
        DISPLAY  "По документу" @ s1
            ub.trn-doc.doc-date @ s2
            ( if ub.trn-doc.doc-type = 'инв':U
                  then ( ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) )
                  else ( ACCUM TOTAL ub.gds-dtl.doc-qnty ) ) @ tqnty_
            ( if ub.trn-doc.doc-type = 'инв':U then
                  ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) * tprice-rubl
              else
                  if Discnt_Type = 1
                      then ACCUM TOTAL ub.gds-dtl.doc-qnty * ( tprice-rubl - round(ub.gds-dtl.discnt-rubl, 2) )
                      else ACCUM TOTAL ub.gds-dtl.doc-qnty * tprice-rubl ) @ tsum_rubl .
        down 2.
        DISPLAY "Фактически" @ s1
            ub.trn-doc.fact-date @ s2
            ( ACCUM TOTAL ub.gds-dtl.fact-qnty ) @ tqnty_
            ( if ub.trn-doc.doc-type = 'инв':U then
                  ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-rubl
              else
                  if Discnt_Type = 1
                      then ACCUM TOTAL ub.gds-dtl.fact-qnty * ( tprice-rubl - round(ub.gds-dtl.discnt-rubl, 2) )
                      else ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-rubl ) @ tsum_rubl .
        down 2.
        DISPLAY "Разница" @ s1
                " " @ s2
                ACCUM TOTAL Sub_Qnty @ tqnty_
                ACCUM TOTAL Sub_Price-Rubl @ tsum_rubl .
        down 2.
        DISPLAY  "   в т.ч. недостача" @ s1
                " " @ s2
                ACCUM TOTAL DownSub_Qnty @ tqnty_
                ACCUM TOTAL DownSub_Price-Rubl @ tsum_rubl .
        down 2.
        DISPLAY "          излишки " @ s1
                " " @ s2
                ACCUM TOTAL UpSub_Qnty @ tqnty_
                ACCUM TOTAL UpSub_Price-Rubl @ tsum_rubl .
        down 3.
        LEAVE.
    END .
else
    REPEAT with FRAME x2:
        DISPLAY  "По документу" @ s1
            ub.trn-doc.doc-date @ s2
            ( if ub.trn-doc.doc-type = 'инв':U
                  then ( ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) )
                  else ( ACCUM TOTAL ub.gds-dtl.doc-qnty ) ) @ tqnty_
            ( if ub.trn-doc.doc-type = 'инв':U then
                  ACCUM TOTAL ( ub.gds-dtl.fact-qnty - ub.gds-dtl.doc-qnty ) * tprice-base
              else
                  if Discnt_Type = 1
                      then ACCUM TOTAL ub.gds-dtl.doc-qnty * ( tprice-base - round(ub.gds-dtl.discnt-base, 2) )
                      else ACCUM TOTAL ub.gds-dtl.doc-qnty * tprice-base ) @ tsum_base .
            .
        down 2.
        DISPLAY "Фактически" @ s1
            ub.trn-doc.fact-date @ s2
            ( ACCUM TOTAL ub.gds-dtl.fact-qnty ) @ tqnty_
            ( if ub.trn-doc.doc-type = 'инв':U then
                  ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-base
              else
                  if Discnt_Type = 1
                      then ACCUM TOTAL ub.gds-dtl.fact-qnty * ( tprice-base - round(ub.gds-dtl.discnt-base, 2) )
                      else ACCUM TOTAL ub.gds-dtl.fact-qnty * tprice-base ) @ tsum_base .
        .
        down 2.
        DISPLAY "Разница" @ s1
                " " @ s2
                ACCUM TOTAL Sub_Qnty @ tqnty_
                ACCUM TOTAL Sub_Price-Base @ tsum_base
                .
        down 2.
        DISPLAY "   в т.ч. недостача" @ s1
                " " @ s2
                ACCUM TOTAL DownSub_Qnty @ tqnty_
                ACCUM TOTAL DownSub_Price-Base @ tsum_base
                .
        down 2.
        DISPLAY "          излишки " @ s1
                " " @ s2
                ACCUM TOTAL UpSub_Qnty @ tqnty_
                ACCUM TOTAL UpSub_Price-Base @ tsum_base
                .
        down 3.
        LEAVE.
    END .
HIDE FRAME BottomFrame .
if NOT PrintRubl then
    run rep/wp.p ( input p-mainmenu-handle, input abs( ACCUM TOTAL Sub_Price-Base ), output s1, output s2 ) .
else
    run rep/wp-rub.p ( input abs( ACCUM TOTAL Sub_Price-Rubl ), output s1, output s2 ) .
PUT SPACE(5) "Разница составила     :  " + CAPS(s1) format "X(128)" SKIP(1).
if v-base-code <> 0 and NOT PrintRubl then
        do:
            run rep/wp-rub.p ( input abs( ACCUM TOTAL Sub_Price-Rubl ), output s1, output s2 ) .
            PUT SPACE(5)
                "( Рублевый эквивалент :  " + trim( CAPS(s1) ) + " )" format "X(128)" SKIP(1).
        end.
output CLOSE.
    define variable Log-Res as log no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_waybills-to-file_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output Log-Res
    )  .
end.
    if Log-Res then do:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
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
    else do:
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
