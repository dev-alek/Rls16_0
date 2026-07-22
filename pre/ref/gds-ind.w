DEFINE BUFFER buf_goods FOR goods.
DEFINE TEMP-TABLE tt-gds-obj-prop NO-UNDO LIKE gds-obj-prop.
DEFINE TEMP-TABLE tt0-gds-obj-prop NO-UNDO LIKE gds-obj-prop.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-host-code like ub.clients.obj-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
DEFINE INPUT-OUTPUT PARAMETER TABLE  FOR tt0-gds-obj-prop.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования индикаторов ".
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
procedure gds-ind1 :
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code                   like  ub.gds-obj-prop.gds-code no-undo.
define input  parameter p-obj-type                   like  ub.gds-obj-prop.obj-type no-undo.
define input  parameter p-obj-code                   like  ub.gds-obj-prop.obj-code no-undo.
define input  parameter p-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define input  parameter p-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define input  parameter p-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define input  parameter p-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define input  parameter p-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define input  parameter p-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
define buffer bufs_gds-obj-prop for ub.gds-obj-prop.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
run cur-time in this-procedure(output v-date, output v-time).
  find first bufs_gds-obj-prop exclusive-lock where
            bufs_gds-obj-prop.gds-code          = p-gds-code   and
            bufs_gds-obj-prop.obj-type          = p-obj-type   and
            bufs_gds-obj-prop.obj-code          = p-obj-code  no-error .
    if not available bufs_gds-obj-prop then do:
        create bufs_gds-obj-prop.
        assign
            bufs_gds-obj-prop.gds-code           = p-gds-code
            bufs_gds-obj-prop.grop-date-update   = v-date
            bufs_gds-obj-prop.grop-time-update   = v-time
            bufs_gds-obj-prop.grop-db-num-update = v-db-num
            bufs_gds-obj-prop.obj-type           = p-obj-type
            bufs_gds-obj-prop.obj-code           = p-obj-code
        no-error .
        if error-status :error then message "Ошибка при создании записи" error-status :error error-status :get-message(1) .
    end.
if  p-gdop-igt                     <> ? then    bufs_gds-obj-prop.gdop-igt                   = p-gdop-igt.
if  p-gdop-assort-min              <> ? then    bufs_gds-obj-prop.gdop-assort-min            = p-gdop-assort-min.
if  p-gdop-min-stock               <> ? then    bufs_gds-obj-prop.gdop-min-stock             = p-gdop-min-stock  .
if  p-grop-level-always-presence   <> ? then    bufs_gds-obj-prop.grop-level-always-presence = p-grop-level-always-presence.
if  p-grop-max-stock               <> ? then    bufs_gds-obj-prop.grop-max-stock             = p-grop-max-stock           .
if  p-grop-min-order               <> ? then    bufs_gds-obj-prop.grop-min-order             = p-grop-min-order           .
      p-doc-rec = recid(bufs_gds-obj-prop)    .
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Hist
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE F-time AS CHARACTER FORMAT "X(5)":U
     LABEL "Время изменения"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Принадлежность к ассортиментному минимуму(AMin):"
      VIEW-AS TEXT
     SIZE 48.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Индикатор жизнедеятельности товара (ИЖТ):"
      VIEW-AS TEXT
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-gds-obj-prop,
      buf_goods SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Hist AT ROW 1 COL 78.5
     B-Help AT ROW 1 COL 88.5
     tt-gds-obj-prop.gdop-igt AT ROW 5.25 COL 51 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Новинка", "1":U,
"На вывод из ассортимента", "2":U,
"Пусто", "3":U,
"Item 4", "4":U
          SIZE 27.5 BY 3
     tt-gds-obj-prop.gdop-assort-min AT ROW 9 COL 51 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Да", yes,
"Нет", no
          SIZE 11.5 BY 1
     buf_goods.artic AT ROW 2 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 17 BY .67
     buf_goods.prod-type AT ROW 2 COL 41.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 4 BY .67
     buf_goods.prod-code AT ROW 2 COL 46 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-code AT ROW 2.75 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-name AT ROW 3.75 COL 24 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 71.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     FILL-IN-5 AT ROW 5.25 COL 8.5 NO-LABEL
     FILL-IN-4 AT ROW 9 COL 2 NO-LABEL
     tt-gds-obj-prop.grop-date-update AT ROW 11.25 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 9 BY .67
     F-time AT ROW 12.25 COL 75.5 COLON-ALIGNED
     tt-gds-obj-prop.grop-who-update AT ROW 13.25 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 19.5 BY .67
     tt-gds-obj-prop.grop-db-num-update AT ROW 14.25 COL 75.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 5 BY .67
     SPACE(16.00) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Индикаторы товара на объекте".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-Hist IN FRAME Dialog-Frame
DO:
define variable pp-rid-list as character no-undo .
 run ref/cgds-ind.w (
  input  parparentproc ,
  input  tt-gds-obj-prop.gds-code ,
  input  tt-gds-obj-prop.obj-type ,
  input  tt-gds-obj-prop.obj-code ,
  input-output pp-rid-list    ).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   FRAME Dialog-Frame:title = FRAME Dialog-Frame:title + " " + p-obj-type + " " + string( p-obj-code ) .
  run init-proc no-error .
  if error-status :error then return error return-value .
  define variable v-user-name as character no-undo .
  run enable_ui.
  if available tt-gds-obj-prop then do:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  tt-gds-obj-prop.grop-who-update
  ,output v-user-name
  )  .
  end.
  display v-user-name @ tt-gds-obj-prop.grop-who-update with frame Dialog-Frame .
  if p-mode = 'ПРОСМОТР':U then do:
      assign
        b-quit:label = "&Выход"
        b-quit:col = 1
      .
      hide b-exit in frame Dialog-Frame.
  end.
  else do:
 define variable v-log as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_assort-izt_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-log
    )  .
end.
 if not v-log then return no-apply .
  end.
find first tt-gds-obj-prop no-error .
DISPLAY string(tt-gds-obj-prop.grop-time-update,"hh:mm") @ f-time WITH FRAME Dialog-Frame no-error .
if error-status :error then message error-status :get-message(1) .
enable
  b-exit when p-mode <> 'ПРОСМОТР':U
  b-quit
  b-hist when p-mode = 'ПРОСМОТР':U
  b-help
  tt-gds-obj-prop.gdop-assort-min  when p-mode <> 'ПРОСМОТР':U
  tt-gds-obj-prop.gdop-igt         when p-mode <> 'ПРОСМОТР':U
with frame dialog-frame.
view frame dialog-frame.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-gds-obj-prop.gdop-igt.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-gds-obj-prop NO-LOCK,       EACH buf_goods OF tt-gds-obj-prop NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY FILL-IN-5 FILL-IN-4 F-time
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.prod-type buf_goods.prod-code
          buf_goods.gds-code buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-obj-prop THEN
    DISPLAY tt-gds-obj-prop.gdop-igt tt-gds-obj-prop.gdop-assort-min
          tt-gds-obj-prop.grop-date-update tt-gds-obj-prop.grop-who-update
          tt-gds-obj-prop.grop-db-num-update
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help buf_goods.artic buf_goods.prod-type
         buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name FILL-IN-5
         FILL-IN-4 tt-gds-obj-prop.grop-date-update F-time
         tt-gds-obj-prop.grop-who-update tt-gds-obj-prop.grop-db-num-update
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
if p-mode = 'ПРОСМОТР':U then
   find first tt0-gds-obj-prop no-lock where
              tt0-gds-obj-prop.gds-code =  p-gds-code and
              tt0-gds-obj-prop.obj-type =  p-obj-type and
              tt0-gds-obj-prop.obj-code =  p-obj-code no-error .
else
   find first tt0-gds-obj-prop exclusive-lock  where
              tt0-gds-obj-prop.gds-code =  p-gds-code and
              tt0-gds-obj-prop.obj-type =  p-obj-type and
              tt0-gds-obj-prop.obj-code =  p-obj-code no-error .
 for each tt-gds-obj-prop : delete tt-gds-obj-prop. end.
  CREATE tt-gds-obj-prop.
  if available tt0-gds-obj-prop then
     BUFFER-COPY tt0-gds-obj-prop TO tt-gds-obj-prop .
  else do:
    if p-gds-code = 0 then p-gds-code = 1.
    run cur-time in this-procedure(output v-date, output v-time).
    assign
      tt-gds-obj-prop.gdop-assort-min    = no
      tt-gds-obj-prop.gdop-igt           = 'Пусто':U
      tt-gds-obj-prop.gds-code           = p-gds-code
      tt-gds-obj-prop.grop-date-update   = v-date
      tt-gds-obj-prop.grop-time-update   = v-time
      tt-gds-obj-prop.grop-db-num-update = g#db-num
      tt-gds-obj-prop.grop-who-update    = g#userid
      tt-gds-obj-prop.obj-code           = p-obj-code
      tt-gds-obj-prop.obj-type           = p-obj-type
    .
  end.
if tt-gds-obj-prop.gdop-igt  = '' or tt-gds-obj-prop.gdop-igt  = ? then do:
   tt-gds-obj-prop.gdop-igt  = 'Пусто':U .
end.
  tt-gds-obj-prop.gdop-igt:radio-buttons IN FRAME Dialog-Frame =
    'Новинка':U    + chr(44) +  'Новинка':U  + chr(44) +
    'Основная группа':U    + chr(44) +  'Основная группа':U  + chr(44) +
    'Нештатный':U   + chr(44) +  'Нештатный':U + chr(44) +
    'На вывод из ассортимента':U    + chr(44) +  'На вывод из ассортимента':U  + chr(44) +
    'Пусто':U  + chr(44) +  'Пусто':U .
END PROCEDURE.
PROCEDURE proc-save :
assign frame Dialog-Frame  tt-gds-obj-prop.gdop-assort-min   no-error .
if error-status :error then message error-status :get-message(1)  "gdop-assort-min" .
assign frame Dialog-Frame  tt-gds-obj-prop.gdop-igt  no-error .
if error-status :error then message  error-status :get-message(1) "gdop-igt " .
define variable p-recid as recid no-undo.
define variable v-ident as logical no-undo .
if p-update-instantly then do:
    run gds-ind1
        (input-output p-recid
        ,tt-gds-obj-prop.gds-code
        ,tt-gds-obj-prop.obj-type
        ,tt-gds-obj-prop.obj-code
        ,tt-gds-obj-prop.gdop-igt
        ,tt-gds-obj-prop.gdop-assort-min
        ,tt-gds-obj-prop.gdop-min-stock
        ,tt-gds-obj-prop.grop-level-always-presence
        ,tt-gds-obj-prop.grop-max-stock
        ,tt-gds-obj-prop.grop-min-order
        ) no-error .
    if error-status :error then  do:
    message error-status :get-message(1) return-value .
    return error return-value .
    end.
END.
ELSE DO:
   if not available tt0-gds-obj-prop then
   create tt0-gds-obj-prop.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      p-updated = yes.
    end.
    else do:
      if available tt0-gds-obj-prop then do:
        buffer-compare tt0-gds-obj-prop
        to
        tt-gds-obj-prop save result in v-ident.
        assign
        p-updated = not v-ident.
      end.
      else do:
        if available tt-gds-obj-prop then p-updated = yes.
      end.
    end.
   buffer-copy tt-gds-obj-prop
   except gds-code
   to tt0-gds-obj-prop
   .
END.
END PROCEDURE.
