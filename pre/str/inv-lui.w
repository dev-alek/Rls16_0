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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER
     FIELD bar-str   AS CHARACTER
     FIELD bar-code  as CHARACTER
     FIELD rez       as CHARACTER
     FIELD err-msg   as CHARACTER
     FIELD des       as CHARACTER
     INDEX pi IS PRIMARY nm.
DEFINE NEW SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER
     FIELD bar-code       as CHARACTER
     FIELD entity         as character
     FIELD b-c            as INTEGER
     FIELD rate           as DECIMAL
     FIELD TYPE-bc        as CHARACTER
     FIELD wt             as DECIMAL
     FIELD file-qnty      as decimal
     FIELD scn-qnty       as DECIMAL
     FIELD scn-pl         as CHARACTER
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     FIELD f-name         LIKE ub.gds-prt.f-name
     FIELD in-code        LIKE ub.parts.in-code
     FIELD fact-date      LIKE ub.parts.fact-date
     FIELD part-code      LIKE ub.parts.part-code
     FIELD rez            as CHARACTER
     FIELD err-msg        as CHARACTER
     FIELD des            as CHARACTER
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
DEFINE NEW SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD err-msg  as CHARACTER
     FIELD des      as CHARACTER
     FIELD upd-line as logical initial no
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE NEW SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD des      as CHARACTER
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
define new global shared variable g#libbcrcn as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared temp-table bb-list no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table bb-list-hist no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable lns-cnt as integer no-undo.
define variable line-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сравнение результатов сканерных файлов".
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
define input parameter parparentproc    as   handle              no-undo.
define input parameter parcurr-obj-type like ub.clients.obj-type no-undo.
define input parameter parcurr-obj-code like ub.clients.obj-code no-undo.
define stream cur.
define stream log.
define stream ler.
define stream err.
DEFINE BUFFER bf_gds-prt  FOR ub.gds-prt.
DEFINE BUFFER bf_goods    FOR ub.goods.
DEFINE BUFFER bf_bar-code FOR ub.bar-code.
DEFINE TEMP-TABLE tt-result NO-UNDO
FIELD artic LIKE ub.goods.artic
FIELD prod-type LIKE ub.goods.prod-type
FIELD prod-code LIKE ub.goods.prod-code
FIELD node-code  LIKE ub.gds-prt.node-code
FIELD gds-name  LIKE ub.goods.gds-name
FIELD b-code    LIKE ub.bar-code.b-code
FIELD scan-1 AS DECIMAL INITIAL ?
FIELD scan-2 AS DECIMAL INITIAL ?
FIELD diff-1-2 AS DECIMAL INITIAL 0
FIELD scan-3 AS CHARACTER INITIAL "":u
FIELD itog AS DECIMAL INITIAL ?
INDEX pi IS UNIQUE PRIMARY artic prod-type prod-code node-code
INDEX artic artic
INDEX itog itog.
DEFINE VARIABLE varrowid AS ROWID.
DEFINE VARIABLE varsave-result AS LOGICAL INITIAL YES NO-UNDO.
DEFINE VARIABLE varscan-1      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE varscan-2      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE varscan-3      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE BUTTON b-clear-scan-1
     LABEL "Аннул. 1"
     SIZE 10 BY 1.
DEFINE BUTTON b-clear-scan-2
     LABEL "Аннул. 2"
     SIZE 10 BY 1.
DEFINE BUTTON b-clear-scan-3
     LABEL "Аннул. 3"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-export
     LABEL "Выгрузка списка"
     SIZE 16 BY 1.
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Печать разницы"
     SIZE 15 BY 1.
DEFINE BUTTON b-save
     LABEL "Сохранить"
     SIZE 11 BY 1.
DEFINE BUTTON b-scan-1
     LABEL "1-е скан."
     SIZE 10 BY 1.
DEFINE BUTTON b-scan-2
     LABEL "2-е скан."
     SIZE 10 BY 1.
DEFINE BUTTON b-scan-3
     LABEL "3-е скан."
     SIZE 10 BY 1.
DEFINE QUERY b-result FOR
      tt-result SCROLLING.
DEFINE BROWSE b-result
  QUERY b-result NO-LOCK DISPLAY
      tt-result.artic FORMAT "X(16)":U
      tt-result.gds-name COLUMN-LABEL "Наимен.!товара":C FORMAT "x(48)"
      tt-result.scan-1 COLUMN-LABEL "Рез-т!1-ого!сканир.":C FORMAT ">>>,>>9.999":U
      tt-result.scan-2 COLUMN-LABEL "Рез-т!2-ого!сканир.":C FORMAT ">>>,>>9.999":U
      tt-result.diff-1-2 COLUMN-LABEL "Разница!между!1 и 2!сканир.":C FORMAT ">>>,>>9.999":U
      fill(" ", 11 - length(tt-result.scan-3)) + tt-result.scan-3 COLUMN-LABEL "Рез-т!3-его!сканир.":C FORMAT "x(11)":U
      tt-result.itog COLUMN-LABEL "Итоги!по!инвентар.":C FORMAT ">>>,>>9.999":U
      tt-result.b-code COLUMN-LABEL "Бар-!код!товара":C FORMAT "999999999":U
      ENABLE tt-result.itog
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.63 EXPANDABLE.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-save AT ROW 1 COL 11
     b-scan-1 AT ROW 1 COL 22
     b-clear-scan-1 AT ROW 1 COL 32
     b-scan-2 AT ROW 1 COL 42
     b-clear-scan-2 AT ROW 1 COL 52
     b-scan-3 AT ROW 1 COL 62
     b-clear-scan-3 AT ROW 1 COL 72
     b-help AT ROW 1 COL 82
     b-print AT ROW 2 COL 1
     b-export AT ROW 2 COL 16
     b-result AT ROW 3 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экран инвентаризации".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.
ON ENDKEY OF FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.
ON return OF FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-clear-scan-1 IN FRAME Dialog-Frame
DO:
    IF varscan-1 <> YES THEN DO:
      MESSAGE "Первое сканирование еще не было сделано." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    IF varscan-3 = YES THEN DO:
      MESSAGE "Есть третье сканирование. Нельзя аннулировать второе." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    FOR EACH tt-result:
       ASSIGN
         tt-result.scan-1 = ?
         tt-result.diff-1-2 = 0
         tt-result.itog = ?.
    END.
    ASSIGN
      varscan-1 = NO.
    RUN open-query IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-clear-scan-2 IN FRAME Dialog-Frame
DO:
  IF varscan-2 <> YES THEN DO:
    MESSAGE "Второе сканирование еще не было сделано." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-3 = YES THEN DO:
    MESSAGE "Есть третье сканирование. Нельзя аннулировать второе." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  FOR EACH tt-result:
     ASSIGN
       tt-result.scan-2 = ?
       tt-result.diff-1-2 = 0
       tt-result.itog = ?.
  END.
  ASSIGN
    varscan-2 = NO.
  RUN open-query IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-clear-scan-3 IN FRAME Dialog-Frame
DO:
  IF varscan-3 = NO THEN DO:
    MESSAGE "Третье сканирование еще не было сделано." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-1 <> YES THEN DO:
    MESSAGE "Критическая ошибка. Не было сделано первое сканирование." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-2 <> YES THEN DO:
    MESSAGE "Критическая ошибка. Не было сделано второе сканирование." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  FOR EACH tt-result :
    ASSIGN
      tt-result.scan-3 = "":u.
    IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
      ASSIGN
        tt-result.itog = tt-result.scan-1.
    END.
    ELSE DO:
      ASSIGN
        tt-result.itog = ?.
    END.
  END.
  ASSIGN
    varscan-3 = NO.
  RUN open-query IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varlog AS LOGICAL INITIAL YES.
  message "Вы действительно хотите выйти из интерфейса сравнения результатов?"
  view-as alert-box QUESTION BUTTONS YES-NO UPDATE varlog.
  if varlog <> yes then do:
    return no-apply.
  end.
  IF varsave-result = NO THEN DO:
    MESSAGE "Вы не сохранили в файл результаты. Хотите сохранить информацию?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE varlog.
    IF varlog = YES THEN DO:
      RUN save-itog IN THIS-PROCEDURE NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
      END.
    END.
  END.
  APPLY "go" TO FRAME Dialog-Frame.
END.
ON CHOOSE OF b-export IN FRAME Dialog-Frame
DO:
  RUN save-diff IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\str\inv-lui.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  run rep/invlui2p.p (parparentproc  , INPUT TABLE tt-result).
END.
ON END-ERROR OF b-result IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.
ON ENDKEY OF b-result IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.
ON GO OF b-result IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.
ON ROW-LEAVE OF b-result IN FRAME Dialog-Frame
DO:
  ASSIGN BROWSE b-result
      tt-result.itog.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  RUN save-itog IN THIS-PROCEDURE.
END.
ON CHOOSE OF b-scan-1 IN FRAME Dialog-Frame
DO:
  IF varscan-3 = YES THEN DO:
    MESSAGE "Третье сканирование должно быть аннулировано, если производиться первое или второе."
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-1 THEN DO:
    MESSAGE "Первое сканирование уже было сделано." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  RUN scan-file (INPUT 1).
  ASSIGN
    varscan-1      = YES.
  IF varscan-2 = YES THEN DO:
    ASSIGN
      varsave-result = NO.
  END.
END.
ON CHOOSE OF b-scan-2 IN FRAME Dialog-Frame
DO:
    IF varscan-3 = YES THEN DO:
      MESSAGE "Третье сканирование должно быть аннулировано, если производиться первое или второе."
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    IF varscan-2 THEN DO:
      MESSAGE "Второе сканирование уже было сделано." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    RUN scan-file (INPUT 2).
    ASSIGN
      varscan-2      = YES.
    IF varscan-1 = YES THEN DO:
      ASSIGN
        varsave-result = NO.
    END.
END.
ON CHOOSE OF b-scan-3 IN FRAME Dialog-Frame
DO:
   IF varscan-1 <> YES OR varscan-2 <> YES THEN DO:
      MESSAGE "Третье сканирование может быть сделано только после первого и второго."
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    RUN scan-file (INPUT 3).
    ASSIGN
        varscan-3 = YES
        varsave-result = NO.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse b-result :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
def var sort-labelb-result   as character no-undo .
def var sort-clmnb-result    as handle    no-undo .
def var cur-clmnb-result     as handle    no-undo .
def var cur-clmn-locb-result as integer   no-undo .
def var re-queryb-result     as logical   initial no no-undo .
on start-search, ctrl-o of b-result in frame Dialog-Frame do:
   run sort-brb-result
     (input (if available tt-result
             then recid(tt-result)
             else ?
            )
     ).
end.
PROCEDURE sort-brb-result :
  define input parameter p-recid as recid no-undo .
  if re-queryb-result = no then do:
    assign
       cur-clmnb-result = b-result:current-column in frame Dialog-Frame
    .
    if sort-clmnb-result <> ? then sort-clmnb-result:column-fgcolor = 0.
    if cur-clmnb-result = sort-clmnb-result then do:
      assign
         sort-labelb-result = ""
         sort-clmnb-result = ?
      .
     end.
     else do:
       assign
         sort-labelb-result = cur-clmnb-result:label
         sort-clmnb-result  = cur-clmnb-result
         sort-clmnb-result:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locb-result = 1
  .
  def var column-handle as handle no-undo .
  column-handle = b-result:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnb-result then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locb-result = cur-clmn-locb-result + 1
    .
  end.
  case sort-labelb-result:
        when 'Артикул'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.artic INDEXED-REPOSITION    . END.
        when 'Наимен.!товара'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.gds-name INDEXED-REPOSITION    . END.
        when 'Рез-т!1-ого!сканир.'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.scan-1 INDEXED-REPOSITION    . END.
        when 'Рез-т!2-ого!сканир.'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.scan-2 INDEXED-REPOSITION    . END.
        when 'Разница!между!1 и 2!сканир.'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.diff-1-2 INDEXED-REPOSITION    . END.
        when 'Рез-т!3-его!сканир.'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.scan-3 INDEXED-REPOSITION    . END.
        when 'Итоги!по!инвентар.'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.itog INDEXED-REPOSITION    . END.
        when 'Бар-!код!товара'  then DO:   OPEN QUERY b-result FOR EACH tt-result NO-LOCK by tt-result.b-code INDEXED-REPOSITION    . END.
    otherwise do:
      OPEN QUERY b-result FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
      if sort-labelb-result <> "" then do:
        assign
          cur-clmnb-result:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locb-result = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition b-result to recid p-recid no-error.
    apply "value-changed" to b-result in frame Dialog-Frame.
  end.
  apply "entry" to b-result in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnb-result:
if cur-clmnb-result = ? then do:
   OPEN QUERY b-result FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
end.
else do:
   assign re-queryb-result = yes.
   run sort-brb-result
     (input (if available tt-result
             then recid(tt-result)
             else ?
            )
     ).
   assign re-queryb-result = no.
end.
end.
  RUN enable_UI.
  ASSIGN
      tt-result.gds-name:resizable in browse b-result = true
      tt-result.gds-name:WIDTH = 10.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-save b-scan-1 b-clear-scan-1 b-scan-2 b-clear-scan-2 b-scan-3
         b-clear-scan-3 b-help b-print b-export b-result
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY b-result FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE open-query :
IF AVAILABLE tt-result THEN DO:
  ASSIGN
    varrowid = ROWID(tt-result).
END.
ELSE DO:
  ASSIGN
    varrowid = ?.
END.
OPEN QUERY b-result FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
IF VARrowid <> ? THEN DO:
  REPOSITION b-result TO ROWID varrowid.
END.
END PROCEDURE.
PROCEDURE save-diff :
DEFINE BUFFER bf-diff_goods    FOR ub.goods.
define buffer bf-diff_bar-code for ub.bar-code.
define buffer bf-diff_prod-bc  for ub.prod-bc.
FOR EACH gds-list :
  DELETE gds-list.
END.
for each bb-list :
  delete bb-list.
end.
FOR EACH tt-result WHERE tt-result.diff-1-2 <> 0 BREAK BY tt-result.artic BY tt-result.prod-type BY tt-result.prod-code:
  FIND FIRST bf-diff_goods WHERE bf-diff_goods.artic     = tt-result.artic     AND
                                 bf-diff_goods.prod-type = tt-result.prod-type AND
                                 bf-diff_goods.prod-code = tt-result.prod-code NO-LOCK.
  find first bf-diff_bar-code where bf-diff_bar-code.b-code = tt-result.b-code no-lock.
  find first bf-diff_prod-bc where bf-diff_prod-bc.b-code = bf-diff_bar-code.b-code NO-LOCK NO-ERROR.
  IF FIRST-OF(tt-result.prod-code) THEN DO:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = bf-diff_goods.prod-type
    and gds-list.prod-code = bf-diff_goods.prod-code
    and gds-list.artic     = bf-diff_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last11 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last11 = gds-list.order-num .
  end.
  else do:
    v-last11 = 0 .
  end.
  create gds-list .
  buffer-copy bf-diff_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last11 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
  END.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first bb-list
  where bb-list.gds-code = bf-diff_bar-code.gds-code
    and bb-list.b-code   = bf-diff_bar-code.b-code
    and bb-list.b-str    = '':u
  no-error .
if available bb-list then do:
  assign
    bb-list.to-del = no
  .
end.
else do:
  define variable v-last12 as integer no-undo .
  find last bb-list use-index oi no-error.
  if available bb-list then do:
    v-last12 = bb-list.order-num .
  end.
  else do:
    v-last12 = 0 .
  end.
  create bb-list .
  buffer-copy bf-diff_goods to bb-list
  assign
    bb-list.to-del = no
    bb-list.order-num = v-last12 + 1
    bb-list.b-code = bf-diff_bar-code.b-code
    bb-list.bc-cli-base-rate = bf-diff_bar-code.cli-base-rate
    bb-list.bc-cr-db-num     = bf-diff_bar-code.cr-db-num
    bb-list.in-code       = bf-diff_bar-code.in-code
    bb-list.node-code     = bf-diff_bar-code.node-code
    bb-list.part-code     = bf-diff_bar-code.part-code
    bb-list.stts_         = bf-diff_bar-code.stts_
    bb-list.bc-unit-cli   = bf-diff_bar-code.unit-cli
    bb-list.b-str         = '':u
    bb-list.f-name        = '':u
    bb-list.loc-ean       = ?
    .
    if available bf-diff_prod-bc
    then
    assign
    bb-list.bc-on-type    = bf-diff_prod-bc.bc-on-type
    bb-list.bc-on         = bf-diff_prod-bc.bc-on
    bb-list.pbc-cr-db-num = bf-diff_prod-bc.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (bb-list)
  .
end.
END.
run str/diallog.w (parparentproc
            , this-procedure
            , 'str/send-tsd.p':U
            , (parcurr-obj-type + chr(4) + string(parcurr-obj-code) + chr(4) + "bar-code")
            , no
            , '':U
            , 'Пересылка товаров на ТСД') no-error .
END PROCEDURE.
PROCEDURE save-itog :
DEFINE VARIABLE varlog AS LOGICAL   NO-UNDO.
DEFINE VARIABLE fname  AS character NO-UNDO.
FIND FIRST tt-result WHERE tt-result.itog = ? NO-ERROR.
IF AVAILABLE tt-result THEN DO:
  MESSAGE "Не определен итог у товара." tt-result.artic tt-result.gds-name tt-result.b-code VIEW-AS ALERT-BOX.
  RETURN ERROR.
END.
SYSTEM-DIALOG GET-FILE Fname
FILTERS "Все файлы"  "*.*"
TITLE "Выберите файл для хранения результата"
USE-FILENAME
UPDATE varlog.
if varlog then do:
  OUTPUT STREAM cur TO VALUE(Fname).
  FOR EACH tt-result:
    PUT STREAM cur UNFORMATTED tt-result.b-c "," tt-result.itog SKIP.
  END.
  assign
    varsave-result = yes.
  OUTPUT STREAM cur CLOSE.
end.
END PROCEDURE.
PROCEDURE scan-file :
DEFINE INPUT PARAMETER parscan AS INTEGER NO-UNDO.
DEFINE VARIABLE scan-txt  AS CHARACTER NO-UNDO.
DEFINE VARIABLE scan-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE varlog    AS LOGICAL   NO-UNDO.
DEFINE VARIABLE varview   AS INTEGER   NO-UNDO.
DEFINE VARIABLE varwork        AS INTEGER   NO-UNDO.
define variable varnoapnd      as logical   no-undo .
define variable vartype        as character no-undo.
define variable varerr         as logical   no-undo.
define variable is-err         as logical   no-undo initial no .
define variable vari           as integer   no-undo.
define variable vartime        as integer   no-undo.
define variable varuser-action as character no-undo.
define variable varprinted     as logical   no-undo.
define buffer bf_bar-code for ub.bar-code.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define frame a
    varview format ">>>>9" label "Просмотрено" space (20) skip
    varwork format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "WorkAbout MS15"         "*.dbs",
               "WorkAbout"              "*.imp",
               "Инвентаризация с кассы" "*.inv",
               "Все файлы"               "*.*"
       update varlog.
if not varlog then return error.
if entry (2, scan-txt, ".") = "log" then do:
  message "Файл с расширением '.log' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "ler" then do:
  message "Файл с расширением '.ler' не может быть обработан. Переименуйте его.".
  return error.
end.
assign
  scan-name = entry (1, scan-txt, ".").
ASSIGN
  frame a:title = "Разбор файла : " + scan-txt.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'noapndsc' then varnoapnd = thbjattr_thbj-attr.property-value-logical  .
end.
if varnoapnd  then do:
  output stream log to value (scan-name + ".log").
  output stream err to value (scan-name + ".err").
  output stream ler to value (scan-name + ".ler").
end.
else do:
  output stream log to value (scan-name + ".log") append.
  output stream err to value (scan-name + ".err") append.
  output stream ler to value (scan-name + ".ler") append.
end.
put stream log unformatted "  " skip.
put stream log unformatted cur-time-string-sec() skip.
put stream ler unformatted "  " skip.
put stream ler unformatted cur-time-string-sec() skip.
view frame a.
input stream cur from value (scan-txt).
for each un-bc on error undo, return error return-value :
    delete un-bc.
end.
for each in-bc on error undo, return error return-value :
    delete in-bc.
end.
for each anlz-bc on error undo, return error return-value :
    delete anlz-bc.
end.
for each main-bc on error undo, return error return-value :
    delete main-bc.
end.
run str/bc-anlz.p (parparentproc, "file", scan-txt, yes, output varerr, output table in-bc) no-error.
if error-status:error then do:
  message "Ошибка при обработке файла сканера." skip
  view-as alert-box error buttons ok.
  return error.
end.
if varerr = yes then is-err = yes.
assign
  vari    = 0.
  vartime = time.
for each in-bc on error undo, return error return-value :
  assign
    vari = vari + 1.
  if in-bc.rez = "err" then do:
    put stream log unformatted in-bc.err-msg skip.
    put stream ler unformatted in-bc.err-msg skip.
    put stream err unformatted in-bc.bar-str skip.
    assign is-err = yes.
  end.
  if in-bc.des <> "" and in-bc.des <> ? then put stream log unformatted in-bc.des.
end.
for each un-bc on error undo, return error return-value :
  assign
    vari = vari + 1.
  if un-bc.rez = "err" then do:
    put stream log unformatted un-bc.err-msg skip.
    put stream ler unformatted un-bc.err-msg skip.
    put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
    assign
      is-err = yes.
  end.
end.
assign
  varview = 0
  varwork = 0
  .
for each main-bc on error undo, return error return-value :
  varview = varview + 1.
  display varview with frame a.
  find first bf_bar-code where bf_bar-code.b-code   = main-bc.b-c           no-lock.
  find first bf_goods    where bf_goods.gds-code    = bf_bar-code.gds-code  no-lock.
  find first bf_gds-prt  where bf_gds-prt.node-code = bf_bar-code.node-code no-lock.
  if bf_gds-prt.is-term <> yes then do:
    put stream log unformatted "Бар-код " bf_bar-code.b-code " не является кодом терминального признака." skip.
    put stream ler unformatted "Бар-код " bf_bar-code.b-code " не является кодом терминального признака." skip.
    put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
    assign is-err = yes.
    next.
  end.
  CASE parscan:
    WHEN 1 THEN DO:
      IF varscan-3 = YES THEN DO:
        RETURN ERROR "Третье сканирование должно быть аннулировано, когда производиться первое".
      END.
      FIND FIRST tt-result WHERE tt-result.artic     = bf_goods.artic       and
                                 tt-result.prod-type = bf_goods.prod-type   and
                                 tt-result.prod-code = bf_goods.prod-code   and
                                 tt-result.node-code = bf_gds-prt.node-code NO-ERROR.
      IF NOT AVAILABLE tt-result THEN DO:
        CREATE tt-result.
        ASSIGN
          tt-result.artic     = bf_goods.artic
          tt-result.prod-type = bf_goods.prod-type
          tt-result.prod-code = bf_goods.prod-code
          tt-result.node-code = bf_gds-prt.node-code
          tt-result.b-code    = main-bc.b-c
          tt-result.gds-name  = (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then bf_goods.gds-name + ' - ' + bf_gds-prt.f-name else bf_goods.gds-name)
         .
        IF varscan-2 = YES THEN DO:
          ASSIGN
            tt-result.scan-2 = 0.
        END.
      END.
      ASSIGN
        tt-result.scan-1 = main-bc.scn-qnty.
      IF varscan-2 = YES THEN DO:
        IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
          ASSIGN
           tt-result.diff-1-2 = 0
           tt-result.itog     = tt-result.scan-1.
        END.
        ELSE DO:
          ASSIGN
            tt-result.diff-1-2 = ABS(tt-result.scan-1 - tt-result.scan-2)
            tt-result.itog     = ?.
        END.
      END.
      ELSE DO:
        ASSIGN
          tt-result.diff-1-2 = 0
          tt-result.itog     = ?.
      END.
    END.
    WHEN 2 THEN DO:
      IF varscan-3 = YES THEN DO:
        RETURN ERROR "Третье сканирование должно быть аннулировано, когда производиться первое".
      END.
      FIND FIRST tt-result WHERE tt-result.artic     = bf_goods.artic       and
                                 tt-result.prod-type = bf_goods.prod-type   and
                                 tt-result.prod-code = bf_goods.prod-code   and
                                 tt-result.node-code = bf_gds-prt.node-code NO-ERROR.
      IF NOT AVAILABLE tt-result THEN DO:
        CREATE tt-result.
        ASSIGN
          tt-result.artic     = bf_goods.artic
          tt-result.prod-type = bf_goods.prod-type
          tt-result.prod-code = bf_goods.prod-code
          tt-result.node-code = bf_gds-prt.node-code
          tt-result.b-code    = main-bc.b-c
          tt-result.gds-name  = (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then bf_goods.gds-name + ' - ' + bf_gds-prt.f-name else bf_goods.gds-name)
        .
        IF varscan-1 = YES THEN DO:
          ASSIGN
            tt-result.scan-1 = 0.
        END.
      END.
      ASSIGN
        tt-result.scan-2 = main-bc.scn-qnty.
      IF varscan-1 = YES THEN DO:
        IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
          ASSIGN
           tt-result.diff-1-2 = 0
           tt-result.itog     = tt-result.scan-1.
        END.
        ELSE DO:
          ASSIGN
            tt-result.diff-1-2 = ABS(tt-result.scan-1 - tt-result.scan-2)
            tt-result.itog     = ?.
        END.
      END.
      ELSE DO:
        ASSIGN
          tt-result.diff-1-2 = 0
          tt-result.itog     = ?.
      END.
    END.
    WHEN 3 THEN DO:
      IF varscan-1 <> YES THEN DO:
        RETURN ERROR "Не было произведено первое сканирование.".
      END.
      IF varscan-2 <> YES THEN DO:
        RETURN ERROR "Не было произведено второе сканирование.".
      END.
      FIND FIRST tt-result WHERE tt-result.artic     = bf_goods.artic       and
                                 tt-result.prod-type = bf_goods.prod-type   and
                                 tt-result.prod-code = bf_goods.prod-code   and
                                 tt-result.node-code = bf_gds-prt.node-code NO-ERROR.
      IF NOT AVAILABLE tt-result THEN DO:
        put stream log unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но товара " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " по этому бар-коду не было в первых двух сканированиях." skip.
        put stream ler unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но товара " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " по этому бар-коду не было в первых двух сканированиях." skip.
        put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
      END.
      ELSE DO:
        IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
          put stream log unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но по этому товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " не было различия в первых двух сканированиях." skip.
          put stream ler unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но по этому товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " не было различия в первых двух сканированиях." skip.
          put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
        END.
        ELSE DO:
          ASSIGN
            tt-result.scan-3 = string(main-bc.scn-qnty)
            tt-result.itog   = main-bc.scn-qnty.
        END.
      END.
    END.
    OTHERWISE DO:
      MESSAGE "Неизвестный номер сканирования: " parscan VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
    END.
  END CASE.
  assign
    varwork = varwork + 1.
    display varwork with frame a.
end.
IF parscan = 1 OR parscan = 2 THEN DO:
  FOR EACH tt-result :
    FIND FIRST main-bc WHERE main-bc.b-c = tt-result.b-c NO-ERROR.
    IF NOT AVAILABLE main-bc THEN DO:
      IF parscan = 1 THEN DO:
        ASSIGN
          tt-result.scan-1 = 0.
      END.
      ELSE DO:
         ASSIGN
           tt-result.scan-2 = 0.
      END.
      IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
        ASSIGN
         tt-result.diff-1-2 = 0
         tt-result.itog     = tt-result.scan-1.
      END.
      ELSE DO:
        ASSIGN
          tt-result.diff-1-2 = ABS(tt-result.scan-1 - tt-result.scan-2)
          tt-result.itog     = ?.
      END.
    END.
  END.
END.
if is-err then do:
  message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
          "Смотрите ler файл."
  view-as alert-box error buttons ok.
  if search (scan-name + ".ler") <> ? then do:
    run gbl/prnfilen.w
      (input  substitute("Ошибки, обнаруженные во время загрузки файла &1", scan-txt)
      ,input  0
      ,input  scan-name + ".ler"
      ,input  7
      ,output varuser-action
      ,output varprinted
      ).
  end.
end.
output stream cur CLOSE.
output stream log CLOSE.
output stream err CLOSE.
output stream ler CLOSE.
RUN open-query IN THIS-PROCEDURE.
END PROCEDURE.
