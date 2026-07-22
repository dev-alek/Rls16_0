DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE TEMP-TABLE tt-gds-add-charges NO-UNDO LIKE ub.gds-add-charges.
DEFINE TEMP-TABLE tt0-gds-add-charges NO-UNDO LIKE ub.gds-add-charges.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode             as character no-undo.
define input parameter p-gds-code         as integer no-undo.
define input parameter p-update-instantly as logical no-undo .
define output parameter p-updated AS LOGICAL no-undo.
DEFINE INPUT-OUTPUT PARAMETER TABLE  FOR tt0-gds-add-charges.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования Дополнительных расходов".
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Алгоритм включения в учетную цену"
      VIEW-AS TEXT
     SIZE 49 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-gds-add-charges,
      buf_goods SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 88.5
     tt-gds-add-charges.cost-include AT ROW 6.25 COL 8 WIDGET-ID 6
          VIEW-AS TOGGLE-BOX
          SIZE 32.5 BY .83
     tt-gds-add-charges.algoritm AT ROW 8 COL 26.5 COLON-ALIGNED WIDGET-ID 8
          LABEL "Пропорционально"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "сумме приходных цен","1",
                     "количеству(в баз. ед.изм.)","2",
                     "количеству(в пост. ед.изм.)","3",
                     "весу","4"
          DROP-DOWN
          SIZE 32.63 BY 1 TOOLTIP "Как включать дополнительные расходы в учетную цену"
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
          LABEL "Код услуги"
           VIEW-AS TEXT
          SIZE 10 BY .67
     buf_goods.gds-name AT ROW 3.75 COL 24 COLON-ALIGNED
          LABEL "Название доп.расхода"
           VIEW-AS TEXT
          SIZE 71.5 BY 1
          BGCOLOR 3 FGCOLOR 15
     FILL-IN-8 AT ROW 7.25 COL 9.75 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     SPACE(37.75) SKIP(2.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительные расходы".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF tt-gds-add-charges.algoritm IN FRAME Dialog-Frame
DO:
  ASSIGN tt-gds-add-charges.algoritm.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status :error then return no-apply.
END.
ON VALUE-CHANGED OF tt-gds-add-charges.cost-include IN FRAME Dialog-Frame
DO:
  ASSIGN tt-gds-add-charges.cost-include.
  IF tt-gds-add-charges.cost-include = TRUE THEN DO:
      ENABLE tt-gds-add-charges.algoritm WITH FRAME Dialog-Frame.
      DISPLAY FILL-IN-8 tt-gds-add-charges.algoritm WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    HIDE FILL-IN-8 tt-gds-add-charges.algoritm IN FRAME Dialog-Frame.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run init-proc no-error .
  if error-status :error then return error return-value .
  define variable v-user-name as character no-undo .
  run enable_ui.
  if p-mode = 'ПРОСМОТР':U then do:
      assign
        b-quit:label = "&Выход"
        b-quit:col = 1
      .
      disable
          tt-gds-add-charges.algoritm
          tt-gds-add-charges.cost-include  with frame Dialog-Frame.
      hide b-exit in frame Dialog-Frame.
  end.
find first tt-gds-add-charges no-error .
if error-status :error then message error-status :get-message(1) .
enable
  b-exit when p-mode <> 'ПРОСМОТР':U
  b-quit
  b-help
  tt-gds-add-charges.algoritm  when p-mode <> 'ПРОСМОТР':U
  tt-gds-add-charges.cost-include         when p-mode <> 'ПРОСМОТР':U
 with frame dialog-frame.
view frame dialog-frame.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-gds-add-charges.cost-include.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-gds-add-charges NO-LOCK,              EACH buf_goods          OF tt-gds-add-charges NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY FILL-IN-8
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.prod-type buf_goods.prod-code
          buf_goods.gds-code buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-add-charges THEN
    DISPLAY tt-gds-add-charges.cost-include tt-gds-add-charges.algoritm
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-gds-add-charges.cost-include
         tt-gds-add-charges.algoritm buf_goods.artic buf_goods.prod-type
         buf_goods.prod-code buf_goods.gds-code buf_goods.gds-name FILL-IN-8
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
if p-mode = 'ПРОСМОТР':U then
   find first tt0-gds-add-charges no-lock where
              tt0-gds-add-charges.gds-code =  p-gds-code
              no-error .
else
   find first tt0-gds-add-charges exclusive-lock  where
              tt0-gds-add-charges.gds-code =  p-gds-code
              no-error .
  if p-gds-code = 0 then do:
    if not available tt0-gds-add-charges then do:
       create tt0-gds-add-charges .
    end.
  end.
 for each tt-gds-add-charges : delete tt-gds-add-charges. end.
  CREATE tt-gds-add-charges.
  if available tt0-gds-add-charges then
     BUFFER-COPY tt0-gds-add-charges TO tt-gds-add-charges .
  else do:
    if p-mode = 'ПРОСМОТР':U then do:
        if p-gds-code = 0 then p-gds-code = 1.
        run cur-time in this-procedure(output v-date, output v-time).
        assign
          tt-gds-add-charges.algoritm           = ""
          tt-gds-add-charges.cost-include       = false
          tt-gds-add-charges.gds-code           = p-gds-code
        .
    end.
    else do:
    message "Значений нет в БД , будут установлены по умолчанию" view-as alert-box information .
    if p-gds-code = 0 then p-gds-code = 1.
    run cur-time in this-procedure(output v-date, output v-time).
    assign
      tt-gds-add-charges.algoritm           = "1"
      tt-gds-add-charges.cost-include       = true
      tt-gds-add-charges.gds-code           = p-gds-code
    .
    end.
  end.
END PROCEDURE.
PROCEDURE proc-save :
define variable p-recid as recid no-undo.
define variable v-ident as logical no-undo .
if p-update-instantly then do:
    assign frame Dialog-Frame
    tt-gds-add-charges.algoritm
    tt-gds-add-charges.cost-include.
    run ref/adcharg1.p
        (input-output p-recid
        ,input tt-gds-add-charges.gds-code
        ,input tt-gds-add-charges.algoritm
        ,input tt-gds-add-charges.cost-include
        ) no-error .
    if error-status :error then  do:
        message error-status :get-message(1) return-value .
        return error return-value .
    end.
END.
ELSE DO:
   if not available tt0-gds-add-charges then
   create tt0-gds-add-charges.
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      p-updated = yes.
    end.
    else do:
      if available tt0-gds-add-charges then do:
        buffer-compare tt0-gds-add-charges
        to
        tt-gds-add-charges save result in v-ident.
        assign
        p-updated = not v-ident.
      end.
      else do:
        if available tt-gds-add-charges then p-updated = yes.
      end.
    end.
   buffer-copy tt-gds-add-charges
   except gds-code
   to tt0-gds-add-charges
   .
END.
END PROCEDURE.
