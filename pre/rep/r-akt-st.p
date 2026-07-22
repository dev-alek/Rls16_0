block-level on error undo, throw.
define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id              as recid        no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-akt-st.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-akt-st.p $":U .
def var vss-description as character no-undo init "Печать акта смены типа приобретени ".
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
do
on error undo, return error
:
  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).
  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).
  define variable g#log as logical   no-undo .
  define buffer buf_clients for clients.
  define buffer buf_parts   for parts .
  define buffer buf_trn-doc for trn-doc .
  define buffer buf_goods   for goods .
  def shared var sort-gr      as logical no-undo.
  def shared var sort-name    as logical no-undo.
  def var v-single-line       as char    no-undo.
  def var sym1  as char init ":"   no-undo.
  def var sym2  as char init ":"   no-undo.
  def var sym3  as char init ":"   no-undo.
  def var sym4  as char init ":"   no-undo.
  def var sym5  as char init ":"   no-undo.
  def var sym6  as char init ":"   no-undo.
  def var sym7  as char init ":"   no-undo.
  def var sym8  as char init ":"   no-undo.
  def var sym9  as char init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.
  define variable all-qnty as decimal   no-undo .
  define variable all-sum  as decimal   no-undo .
  define variable s-isp    as character no-undo .
  DEFINE temp-table gds-prop no-undo
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   cli-type         as  char
    field   cli-code         as  integer
    field   part-code        like parts.part-code
    field   in-code          like parts.in-code
    field   gds-code         as  integer
    field   gds-name         as  char
    field   grp-name         as  char
    field   b-code           as  integer
    field   qnty             as  decimal
    field   zen              as  decimal
    field   sum              as  decimal
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
    INDEX pi3              cli-type cli-code
 .
  def var v-doc-num          like trn-doc.doc-code    no-undo.
  def var v-doc-date         like trn-doc.doc-date    no-undo.
  find first buf_trn-doc no-lock  where recid(buf_trn-doc) = rec_id .
  assign
    v-doc-num  = buf_trn-doc.doc-code
    v-doc-date = buf_trn-doc.doc-date
  .
  for each parts-root no-lock where parts-root.doc-code = buf_trn-doc.doc-code :
    create gds-prop .
    find first buf_goods where buf_goods.gds-code = parts-root.gds-code no-lock .
    find first buf_parts no-lock
      where buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.part-code = parts-root.part-code
        and buf_parts.in-code   = parts-root.in-code
        and buf_parts.out-code  = buf_trn-doc.doc-code
        and buf_parts.obj-code  = buf_trn-doc.obj-code
        and buf_parts.obj-type  = buf_trn-doc.obj-type
      no-error .
    if PrintRubl then assign gds-prop.zen = buf_parts.price-rubl .
    else              assign gds-prop.zen = buf_parts.price-base .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output gds-prop.b-code
  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    end.
    assign
      gds-prop.artic     = buf_goods.artic
      gds-prop.prod-type = buf_goods.prod-type
      gds-prop.prod-code = buf_goods.prod-code
      gds-prop.gds-code  = buf_goods.gds-code
      gds-prop.gds-name  = buf_goods.gds-name
      gds-prop.grp-name  = buf_goods.grp-name
      gds-prop.part-code = parts-root.part-code
      gds-prop.in-code   = parts-root.in-code
      gds-prop.cli-type  = buf_parts.supp-type
      gds-prop.cli-code  = buf_parts.supp-code
      gds-prop.qnty      = buf_parts.fact-qnty
      gds-prop.sum       = buf_parts.fact-qnty * gds-prop.zen
    .
  end.
  def stream out-stream .
  define frame f-doc1
        sym1              column-label ":"                       format "X(1)"
        gds-prop.b-code   column-label "Код"                     format ">>>>>>>>>>>>9"
        sym2              column-label ":"                       format "X(1)"
        gds-prop.artic    column-label "Артикул"                 format "X(16)"
        sym3              column-label ":"                       format "X(1)"
        gds-prop.gds-name column-label "Название товара"         format "X(41)"
        sym4              column-label ":"                       format "X(1)"
        gds-prop.qnty     column-label "Количество"              format "->>>>>>>>9.<<"
        sym5              column-label ":"                       format "X(1)"
        gds-prop.zen      column-label "Цена (РУБ)"              format "->>>>>>>9.99"
        sym6              column-label ":"                       format "X(1)"
        gds-prop.sum      column-label "Сумма  (РУБ)"            format "->>>>>>>>>>>9.99"
        sym7              column-label ":"                       format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Акт смены типа приобретения" ) at 50 format "X(30)" v-doc-num format "X(10)" " от " v-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 110 format "X(13)" skip
        v-single-line format "X(128)" at 1
    with width 235 down stream-io use-text .
  define frame f-doc2
        sym1              column-label ":"                         format "X(1)"
        gds-prop.b-code   column-label "Код"                       format ">>>>>>>>>>>>9"
        sym2              column-label ":"                         format "X(1)"
        gds-prop.artic    column-label "Артикул"                   format "X(16)"
        sym3              column-label ":"                         format "X(1)"
        gds-prop.gds-name column-label "Название товара"           format "X(41)"
        sym4              column-label ":"                         format "X(1)"
        gds-prop.qnty     column-label "Количество"                format "->>>>>>>>9.<<"
        sym5              column-label ":"                         format "X(1)"
        gds-prop.zen      column-label "цена (Б.Вал)"              format "->>>>>>>9.99"
        sym6              column-label ":"                         format "X(1)"
        gds-prop.sum      column-label "Сумма (Б.Вал)"             format "->>>>>>>>>>>9.99"
        sym7              column-label ":"                         format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Акт смены типа приобретения" ) at 50 format "X(30)" v-doc-num format "X(10)" " от " v-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 110 format "X(13)" skip
        v-single-line format "X(128)" at 1
    with width 235 down stream-io use-text .
if session :set-wait-state( "compiler" ) then.
  assign   v-single-line = fill("-", 140) .
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
  find first  buf_clients no-lock where buf_clients.obj-type = 'орг':U  and buf_clients.obj-code = buf_trn-doc.host-code .
  put stream out-stream space(50) buf_clients.obj-name format "x(70)" skip(2) .
  put stream out-stream space(25) string( "А К Т  смены типа приобретения  N "
    + v-doc-num + " от " + string(v-doc-date,"99/99/9999") )    format "x(128)"    skip(1)
  .
  form header v-single-line format "X(128)" at 1 skip  "Продолжение - на следующей странице" at 30 skip
  with frame Bottomframe width 235 page-bottom no-labels no-box .
  view stream out-stream frame bottomframe .
  if PrintRubl then form with frame f-doc1 .
  else              form with frame f-doc2 .
  if sort-gr then do:
    if sort-name then do:
      for each gds-prop break by gds-prop.cli-type by gds-prop.cli-code by gds-prop.grp-name by gds-prop.gds-name :
        if  first-of( gds-prop.cli-code) then do:
          run print-prod in this-procedure .
        end.
        if  first-of( gds-prop.grp-name) then do:
          run print-grp in this-procedure .
        end.
        run print-line in this-procedure .
      end.
    end.
    else do:
      for each gds-prop break by gds-prop.cli-type by gds-prop.cli-code by gds-prop.grp-name by gds-prop.artic :
        if  first-of( gds-prop.cli-code) then do:
          run print-prod in this-procedure .
        end.
        if  first-of( gds-prop.grp-name) then do:
          run print-grp in this-procedure .
        end.
        run print-line in this-procedure .
      end.
    end.
  end.
  else do:
    if sort-name then do:
      for each gds-prop break by gds-prop.cli-type by gds-prop.cli-code by gds-prop.gds-name :
        if  first-of( gds-prop.cli-code) then do:
          run print-prod in this-procedure .
        end.
        run print-line in this-procedure .
      end.
    end.
    else do:
      for each gds-prop break by gds-prop.cli-type by gds-prop.cli-code by gds-prop.artic  :
        if  first-of( gds-prop.cli-code) then do:
          run print-prod in this-procedure .
        end.
        run print-line in this-procedure .
      end.
    end.
  end.
  put stream out-stream v-single-line format "X(128)" skip .
  if PrintRubl then do:
    display stream out-stream
      sym1   sym2   sym3   "ИТОГО:" @ gds-prop.gds-name
      sym4   all-qnty               @ gds-prop.qnty
      sym5   sym6   all-sum         @ gds-prop.sum
      sym7
    with frame f-doc1 .
    down stream out-stream with frame f-doc1 .
  end.
  else do:
    display stream out-stream
      sym1   sym2   sym3   "ИТОГО:" @ gds-prop.gds-name
      sym4   all-qnty               @ gds-prop.qnty
      sym5   sym6   all-sum         @ gds-prop.sum
      sym7
    with frame f-doc2 .
    down stream out-stream with frame f-doc2 .
  end.
  hide stream out-stream frame Bottomframe .
  if line-counter( out-stream ) + 6 > page-size( out-stream ) then  page stream out-stream .
  find first  buf_clients no-lock where buf_clients.obj-type = 'чел':U  and buf_clients.obj-code = buf_trn-doc.agnt no-error .
  if available buf_clients then assign s-isp = buf_clients.obj-name .
  else                          assign s-isp = "" .
  put stream out-stream v-single-line format "X(128)" skip(2)
             space(10) "Подписи сторон : "    format "X(60)" skip
             space(10) "Зав. складом/Зав. секцией : _____________________" format "X(70)"  "От поставщика : _____________________" format "X(70)" skip(2)
             space(20) "Исполнитель : " s-isp   skip
            .
  output stream out-stream close.
if session :set-wait-state( "" ) then.
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
procedure print-grp :
  do
  on error undo, return error return-value
  :
    if PrintRubl then do:
      display stream out-stream  sym1  gds-prop.grp-name @ gds-prop.gds-name  sym7  with frame f-doc1 .
      down stream out-stream with frame f-doc1 .
    end.
    else do:
      display stream out-stream  sym1  gds-prop.grp-name @ gds-prop.gds-name  sym7  with frame f-doc2 .
      down stream out-stream with frame f-doc2 .
    end.
  end.
end procedure.
procedure print-prod :
  do
  on error undo, return error return-value
  :
    find first buf_clients where buf_clients.obj-type = gds-prop.cli-type and buf_clients.obj-code = gds-prop.cli-code no-lock .
    if PrintRubl then do:
      display stream out-stream  sym1 "Поставщик:" @ gds-prop.artic sym2  buf_clients.obj-name @ gds-prop.gds-name  sym7  with frame f-doc1 .
      down stream out-stream with frame f-doc1 .
    end.
    else do:
      display stream out-stream  sym1 "Поставщик:" @ gds-prop.artic sym2    buf_clients.obj-name @ gds-prop.gds-name  sym7  with frame f-doc2 .
      down stream out-stream with frame f-doc2 .
    end.
  end.
end procedure.
procedure print-line :
  do
  on error undo, return error return-value
  :
    assign
      all-qnty = all-qnty + gds-prop.qnty
      all-sum  = all-sum  + gds-prop.sum
    .
    if PrintRubl then do:
      display stream out-stream
        sym1   gds-prop.b-code
        sym2   gds-prop.artic
        sym3   gds-prop.gds-name
        sym4   gds-prop.qnty
        sym5   gds-prop.zen
        sym6   gds-prop.sum
        sym7
      with frame f-doc1 .
      down stream out-stream with frame f-doc1 .
    end.
    else do:
      display stream out-stream
        sym1   gds-prop.b-code
        sym2   gds-prop.artic
        sym3   gds-prop.gds-name
        sym4   gds-prop.qnty
        sym5   gds-prop.zen
        sym6   gds-prop.sum
        sym7
      with frame f-doc2 .
      down stream out-stream with frame f-doc2 .
    end.
  end.
end procedure.
