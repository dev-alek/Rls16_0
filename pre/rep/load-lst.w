define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter Record-Id            as recid            no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список на отгрузку.".
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
def     buffer  cli-prod        for     clients .
def     buffer  bR-trn-doc   for     trn-doc .
define variable Log-Res1       as      log         no-undo.
define variable Log-Res2       as      log         no-undo.
define variable sym0 as char init ":"   no-undo.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable  Line               as    char   no-undo.
define variable  tb-code          as    char   no-undo.
define variable  rsrv-FactDate  as  date    no-undo .
define variable  ind                            as    int                no-undo.
define variable rootnode_code        as      integer       no-undo.
def stream RepStr .
def stream  i_inp1.
    define variable  InputFileName    as  char    no-undo.
    define variable  text-string            as  char    FORMAT "x(232)" no-undo .
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
DEFINE WORK-TABLE doc-recids no-undo
    field   DocRecid    as  recid
    field   doc-code     like trn-doc.doc-code
    .
def FRAME DocsList
        sym0 column-label ":!:" format "X(1)"
        ind column-label "N!п/п" format ">>9"
        sym1 column-label ":!:" format "X(1)"
        trn-doc.rsrv-date column-label "Дата!отгрузки" format "99/99/9999"
        sym2 column-label ":!:" format "X(1)"
        trn-doc.doc-code column-label "Номер!документа" format "X(11)"
        sym3 column-label ":!:" format "X(1)"
        trn-doc.cli-name column-label "Контрагент! " format "X(60)"
        sym4 column-label ":!:" format "X(1)"
        trn-doc.doc-qnty column-label "Количество! " format "->>,>>>,>>9.999"
        sym5 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 100 PAGE-NUMBER( RepStr ) AT 110 FORMAT ">>9" SKIP
        Line format "X(115)" AT 1
    with width 160 down stream-io NO-BOX.
DEFINE FRAME GoodsList
        sym1 column-label ":!:" format "X(1)"
        ind column-label "N!п/п" format ">>9"
        sym3 column-label ":!:" format "X(1)"
        doc-line.artic column-label "Артикул! " format "X(20)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name column-label "Название товара! " format "X(50)"
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x(10)"
        sym5 column-label ":!:" format "X(1)"
        goods.unit-base column-label "Единица!измерения" format "X(9)"
        sym6 column-label ":!:" format "X(1)"
        doc-line.doc-qnty column-label "Количество!единиц" format ">>>,>>>,>>9.99"
        sym7 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 110 PAGE-NUMBER ( RepStr ) AT 120 FORMAT ">>9" SKIP
        Line format "X(125)" AT 1
    with width 160 down stream-io .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE startdate AS DATE FORMAT "99/99/9999":U
     LABEL "Введите дату отгрузки"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 46.5 BY 6.75.
DEFINE VARIABLE NotPrint-GdsList AS LOGICAL INITIAL no
     LABEL "Не выводить список товаров на отгрузку"
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .75 NO-UNDO.
DEFINE VARIABLE Repeated AS LOGICAL INITIAL no
     LABEL "Повторно в набор"
     VIEW-AS TOGGLE-BOX
     SIZE 18.5 BY 1 NO-UNDO.
DEFINE FRAME DLGOKCAN
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     startdate AT ROW 3.5 COL 25 COLON-ALIGNED
     Repeated AT ROW 5.5 COL 15
     NotPrint-GdsList AT ROW 7.5 COL 4
     RECT-1 AT ROW 2.5 COL 1.5
     SPACE(1.12) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Отправить в набор":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN
DO:
    assign startdate Repeated NotPrint-GdsList .
    FOR EACH doc-recids :
        delete doc-recids .
    END.
    if can-find( first trn-doc WHERE trn-doc.obj-type = v-cntxt-obj-type AND
                                     trn-doc.obj-code = v-cntxt-obj-code AND
                                     trn-doc.rsrv-date = startdate AND
                                     trn-doc.doc-type = 'рас':U AND
                                     trn-doc.status_ = 'разрешен':U AND
                                     trn-doc.flag_ )
                                     OR
       can-find( first trn-doc WHERE recid( trn-doc ) = Record-Id AND ( not trn-doc.flag_ ) ) then
        do:
            RUN main_proc.
            if return-value <> "Bad-Reading"
            then do:
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
        end.
    else
        message "Нет ни одного документа," skip
                        "подготовленного к отгрузке" skip
                        "на текущем объекте" skip
                        "в указанный Вами день."
                        view-as alert-box information buttons ok .
END.
ON VALUE-CHANGED OF NotPrint-GdsList IN FRAME DLGOKCAN
DO:
    assign NotPrint-GdsList .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
assign startdate = v-today .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    RUN enable_UI.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_composition-reprint_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res1
    )  .
end.
    if not Log-Res1
    then do:
        DISABLE Repeated WITH FRAME DLGOKCAN.
    end.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_composition-print_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Res2
    )  .
end.
    if not ( Log-Res1 OR Log-Res2 )
    then do:
            message
                "У Вас недостаточно ПРАВ" skip
                "для выполнения данного действия." skip
                "Обратитесь к администратору" skip
                "системы." view-as alert-box error.
            LEAVE MAIN-BLOCK .
    end.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY startdate Repeated NotPrint-GdsList
      WITH FRAME DLGOKCAN.
  ENABLE Btn_OK Btn_Cancel b-help RECT-1 startdate Repeated NotPrint-GdsList
      WITH FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE main_proc :
define buffer b-trn-doc for trn-doc .
if session :set-wait-state( "compiler" ) then.
    Line = fill( "-", 140) .
    output stream RepStr to value( string( session:temp-directory +
                                     "plt" + string( g#report-num ) ) ) page-size 62 .
    FIND clients WHERE clients.obj-type = v-cntxt-obj-type AND
                                       clients.obj-code = v-cntxt-obj-code NO-LOCK .
    FORM HEADER
                Line format "X(115)" AT 1 SKIP
                "Продолжение - на следующей странице" AT 30 SKIP
                with FRAME BottomFrame-1 width 160 PAGE-BOTTOM no-labels no-box.
    VIEW stream RepStr FRAME BottomFrame-1 .
    PUT stream RepStr space(10) CAPS( clients.obj-name ) format "x(100)" SKIP(1) .
    PUT stream RepStr space(30) string( "Список документов на отгрузку за " +
            string( ( if Repeated then rsrv-FactDate else startdate ), "99/99/9999" ) + "." )
            format "x(100)" SKIP(2) .
    FORM with frame DocsList .
    DO FOR b-trn-doc :
        if Repeated then
            FOR EACH b-trn-doc WHERE b-trn-doc.obj-type = v-cntxt-obj-type    AND
                                     b-trn-doc.obj-code  = v-cntxt-obj-code   AND
                                     b-trn-doc.doc-type  = 'рас':U   AND
                                     b-trn-doc.status_   = 'разрешен':U AND
                                     b-trn-doc.rsrv-date = rsrv-FactDate
                                     use-index obj-load
                                     SHARE-LOCK BREAK BY b-trn-doc.doc-code :
                FIND LAST doc-recids NO-ERROR .
                CREATE doc-recids.
                assign
                    doc-recids.DocRecid = recid( b-trn-doc )
                    doc-recids.doc-code = b-trn-doc.doc-code .
                ACCUMULATE b-trn-doc.doc-code ( COUNT )
                                        b-trn-doc.doc-qnty ( TOTAL ) .
                DISPLAY stream RepStr
                    sym0 ( ACCUM COUNT b-trn-doc.doc-code ) @ ind
                    sym1 b-trn-doc.fact-date @ trn-doc.fact-date
                    sym2 b-trn-doc.doc-code @ trn-doc.doc-code
                    sym3 b-trn-doc.cli-name @ trn-doc.cli-name
                    sym4 b-trn-doc.doc-qnty @ trn-doc.doc-qnty
                    sym5 with frame DocsList .
                DOWN stream RepStr 1 with frame DocsList .
            END .
        else
            FOR EACH b-trn-doc WHERE b-trn-doc.obj-type = v-cntxt-obj-type  AND
                                     b-trn-doc.obj-code = v-cntxt-obj-code  AND
                                     b-trn-doc.status_ = 'разрешен':U AND
                                     b-trn-doc.rsrv-date = startdate  AND
                                     b-trn-doc.flag_                  AND
                                     b-trn-doc.doc-type = 'рас':U
                                     SHARE-LOCK BREAK BY b-trn-doc.doc-code :
                FIND LAST doc-recids NO-ERROR .
                CREATE doc-recids.
                assign
                    doc-recids.DocRecid = recid( b-trn-doc )
                    doc-recids.doc-code = b-trn-doc.doc-code .
                ACCUMULATE b-trn-doc.doc-code ( COUNT )
                                        b-trn-doc.doc-qnty ( TOTAL ) .
                DISPLAY stream RepStr
                    sym0 ( ACCUM COUNT b-trn-doc.doc-code ) @ ind
                    sym1 b-trn-doc.fact-date @ trn-doc.fact-date
                    sym2 b-trn-doc.doc-code @ trn-doc.doc-code
                    sym3 b-trn-doc.cli-name @ trn-doc.cli-name
                    sym4 b-trn-doc.doc-qnty @ trn-doc.doc-qnty
                    sym5 with frame DocsList .
                DOWN stream RepStr 1 with frame DocsList .
            END .
        PUT stream RepStr Line format "x(115)" SKIP .
        DISPLAY stream RepStr
                            "ИТОГО" @ trn-doc.doc-code
                            ( ACCUM TOTAL b-trn-doc.doc-qnty ) @ trn-doc.doc-qnty
                            with frame DocsList .
        DOWN stream RepStr 1 with frame DocsList .
        UNDERLINE stream RepStr trn-doc.doc-code trn-doc.doc-qnty with frame DocsList .
        HIDE stream RepStr FRAME BottomFrame-1 .
        output stream RepStr CLOSE .
        FOR EACH doc-recids BREAK BY doc-recids.doc-code :
                FIND b-trn-doc WHERE recid( b-trn-doc ) = doc-recids.DocRecid NO-LOCK .
                ACCUMULATE b-trn-doc.doc-code ( COUNT ) .
                if first( doc-recids.doc-code ) then
                    run rep/r-outret.p ( input p-mainmenu-handle, input doc-recids.DocRecid, input no) .
                else
                    run rep/r-outret.p ( input p-mainmenu-handle, input doc-recids.DocRecid, input no) .
if session :set-wait-state( "" ) then.
        END .
        InputFileName = "plt" .
output     to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 append .
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DO WHILE PrintCopiesCounter <> 0 :
    INPUT stream i_inp1
        FROM value ( string( session:temp-directory + InputFileName + string( g#report-num ) ) ).
    FORM with FRAME x1 .
    REPEAT on endkey undo, leave :
        DO on endkey undo, leave:
            IMPORT stream  i_inp1 UNFORMATTED text-string NO-ERROR.
        END.
        IF ERROR-STATUS:ERROR THEN
            UNDO, LEAVE.
        if integer ( asc ( substring ( text-string, 1, 1 ) ) ) = 12
           and "yes" = "yes" then
            text-string = substring ( text-string, 2 ) .
        DISPLAY text-string no-label with width 235 DOWN FRAME x1 .
        DOWN WITH FRAME x1.
        text-string = "".
    END.
    PrintCopiesCounter = PrintCopiesCounter - 1.
    INPUT stream i_inp1 CLOSE.
END.
PrintCopiesCounter = 1.
        DO WHILE line-counter <= page-size :
            PUT " " SKIP .
        END.
        output CLOSE .
        if NOT NotPrint-GdsList then
            do:
output stream RepStr to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 append .
                PUT stream RepStr space(10) CAPS( clients.obj-name ) format "x(100)" SKIP(1) .
                PUT stream RepStr space(30) string( "Список товаров на отгрузку за " +
                        string( ( if Repeated then rsrv-FactDate else startdate ), "99/99/9999" ) + "." )
                        format "x(100)" SKIP(2) .
                FORM HEADER
                    Line format "X(125)" AT 1 SKIP
                    "Продолжение - на следующей странице" AT 30 SKIP
                    with FRAME BottomFrame-2 width 160 PAGE-BOTTOM no-labels no-box.
                VIEW stream RepStr FRAME BottomFrame-2 .
                ind = 0 .
                FOR EACH doc-recids ,
                        EACH doc-line WHERE doc-line.doc-code = doc-recids.doc-code NO-LOCK
                            BREAK BY string( doc-line.prod-type + string( doc-line.prod-code ) )
                                         BY doc-line.artic
                                         with frame GoodsList :
                    if first-of( string( doc-line.prod-type + string( doc-line.prod-code ) ) ) then
                        do:
                            if NOT first( string( doc-line.prod-type + string( doc-line.prod-code ) ) ) then
                                UNDERLINE stream RepStr doc-line.artic goods.gds-name .
                            FIND cli-prod WHERE cli-prod.obj-type = doc-line.prod-type AND
                                                                cli-prod.obj-code = doc-line.prod-code NO-LOCK .
                            DISPLAY stream RepStr
                                        "Производитель" @ doc-line.artic
                                        cli-prod.obj-name @ goods.gds-name .
                            DOWN stream RepStr 1 .
                            UNDERLINE stream RepStr doc-line.artic goods.gds-name .
                        end.
                    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                                  goods.prod-code = doc-line.prod-code AND
                                                  goods.artic = doc-line.artic NO-LOCK .
                    FIND gds-prt where gds-prt.upper-code = doc-line.prt-root NO-LOCK .
                    rootnode_code = gds-prt.node-code .
                    FIND bar-code WHERE bar-code.gds-code = goods.gds-code AND
                                      bar-code.unit-cli = goods.unit-base AND
                                      bar-code.node-code = rootnode_code AND
                                      bar-code.part-code = "" AND
                                      bar-code.in-code = ""
                                      NO-LOCK NO-ERROR.
                    if not available bar-code then
                        tb-code = "?".
                    else
                        tb-code = trim ( string (bar-code.b-code )) .
                    ACCUMULATE doc-line.doc-qnty ( SUB-TOTAL BY doc-line.artic )
                                            doc-line.doc-qnty ( TOTAL )
                                            doc-line.artic ( COUNT ) .
                    if last-of( doc-line.artic ) then
                        do:
                            ind = ind + 1 .
                            DISPLAY stream RepStr
                                    sym1 ind
                                    sym3 doc-line.artic
                                    sym4 goods.gds-name
                                    sym2 tb-code
                                    sym5 goods.unit-base
    sym6 ( ACCUM SUB-TOTAL BY doc-line.artic doc-line.doc-qnty ) @ doc-line.doc-qnty
                                    sym7 .
                            DOWN stream RepStr 1 .
                        end.
                    if last( string( doc-line.prod-type + string( doc-line.prod-code ) ) ) then
                        do:
                            PUT stream RepStr Line format "x(125)" SKIP .
                            DISPLAY stream RepStr
                                "ИТОГО" @ doc-line.artic
                                ( ACCUM TOTAL doc-line.doc-qnty ) @ doc-line.doc-qnty .
                            DOWN stream RepStr 1 .
                            UNDERLINE stream RepStr doc-line.artic doc-line.doc-qnty .
                        end.
                END .
                HIDE stream RepStr FRAME BottomFrame-2 .
                output stream RepStr CLOSE .
            end.
if session :set-wait-state( "" ) then.
        if NOT Repeated then
            do:
                FOR EACH doc-recids ,
                        EACH b-trn-doc OF doc-recids EXCLUSIVE-LOCK
                            on error undo, return "Bad-Reading" :
                        delete doc-recids .
                END .
            end.
    END.
END PROCEDURE.
