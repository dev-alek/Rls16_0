DEFINE BUFFER LOCKED_dis-card-mask FOR dis-card-mask.
DEFINE BUFFER locked_dis-card-type FOR dis-card-type.
DEFINE TEMP-TABLE tt-dis-card-mask NO-UNDO LIKE dis-card-mask.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_clients_dctype FOR clients.
DEFINE BUFFER X_curr_clients FOR clients.
DEFINE BUFFER X_sysconf FOR sysconf.
define buffer buf_dis-card-mask-attr  for ub.dis-card-mask-attr .
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-mode           AS CHARACTER             no-undo .
define input parameter p-emitent-host-code like ub.dis-card-mask.emitent-host-code no-undo .
define input parameter p-type           like ub.dis-card-mask.type no-undo .
define input parameter p-mask-num       like ub.dis-card-mask.mask-num no-undo .
define INPUT-OUTPUT parameter p-doc-rec AS recid no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Маска дисконтной карты":U.
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-last-code LIKE ub.dis-card-mask.mask-num NO-UNDO.
DEFINE BUTTON B-card-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-cli-mask
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-mask
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-rank
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE CB-CC-run AS CHARACTER FORMAT "X(256)":U
     LABEL "Алгоритм КЦ"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 46 BY 1 NO-UNDO.
DEFINE VARIABLE f-emitent-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 63.5 BY 1 NO-UNDO.
DEFINE VARIABLE l-rs-cli-mask AS CHARACTER FORMAT "X(256)":U INITIAL "Метод поиска ДК по маске карты"
      VIEW-AS TEXT
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE RS-cli-mask AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Правило из маски", "cli-mask",
"Определенный контрагент", "cli-code",
"Маска и контрагент", "cli-mask-cli-code"
     SIZE 64.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-region AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", 0,
"Фирма", 1,
"Объект", 2
     SIZE 63 BY 1 NO-UNDO.
DEFINE VARIABLE reg-cash AS LOGICAL INITIAL no
     LABEL "Разрешена регистрация на кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 34.5 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-dis-card-mask SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-hist AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.88
     tt-dis-card-mask.type AT ROW 2.58 COL 12 COLON-ALIGNED
          LABEL "Тип карты"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     B-card-type AT ROW 2.58 COL 26.5
     tt-dis-card-mask.mask-num AT ROW 2.58 COL 47.5 COLON-ALIGNED
          LABEL "Номер маски"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-dis-card-mask.use-on AT ROW 2.58 COL 67.5 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Использовать на кассе и в TH", 0,
"Использовать ТОЛЬКО на кассе", 1,
"Использовать ТОЛЬКО в TH", 2
          SIZE 31.5 BY 2.25
     reg-cash AT ROW 4 COL 3 WIDGET-ID 2
     tt-dis-card-mask.emitent-host-code AT ROW 5.25 COL 3
          LABEL "Эмитент карты"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     RS-region AT ROW 6.5 COL 24.88 NO-LABEL
     tt-dis-card-mask.mask AT ROW 8 COL 3
          LABEL "Маска карты"
          VIEW-AS FILL-IN
          SIZE 21.5 BY 1
     B-mask AT ROW 8 COL 38.13
     tt-dis-card-mask.rank AT ROW 8 COL 79 COLON-ALIGNED
          LABEL "Ранг(приоритет при поиске)"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     B-rank AT ROW 8 COL 89
     RS-cli-mask AT ROW 9.71 COL 34.5 NO-LABEL
     tt-dis-card-mask.cli-type AT ROW 12 COL 16.5 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 14 BY 1
     tt-dis-card-mask.cli-code AT ROW 12 COL 29.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     B-cli AT ROW 12 COL 48.5
     tt-dis-card-mask.cli-mask AT ROW 14.25 COL 3
          LABEL "Маска КОРОТКОГО №" FORMAT "X(19)"
          VIEW-AS FILL-IN
          SIZE 21.5 BY 1
     B-cli-mask AT ROW 14.25 COL 44
     CB-CC-run AT ROW 14.25 COL 67 COLON-ALIGNED
     f-emitent-name AT ROW 5.25 COL 24 COLON-ALIGNED NO-LABEL
     l-rs-cli-mask AT ROW 9.71 COL 3 NO-LABEL
     f-cli-name AT ROW 12 COL 50.5 COLON-ALIGNED NO-LABEL
     "Область действия" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 6.5 COL 3
     "Контрагент" VIEW-AS TEXT
          SIZE 13.5 BY 1 AT ROW 12 COL 3
     SPACE(82.74) SKIP(2.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Маска дисконтной карты"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-card-type IN FRAME Dialog-Frame
DO:
  run proc-b-card-type no-error.
    if error-status:error then return no-apply.
  APPLY "LEAVE" to tt-dis-card-mask.emitent-host-code.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
  define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
define buffer buf_clients for ub.clients.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run ref/cli-all.w ( parParentProc
                  ,"b-sel"
                  , tt-dis-card-mask.cli-type
                  , ?
                  , ?
                  , (if available X_clients then recid(X_clients) else ?)
                  , ?
                  , "":U
                  , output ref-list) .
    if ref-list = "" then   do:
      return no-apply.
    end.
    ref-rec = integer( ref-list ).
    FIND FIRST buf_clients WHERE recid (buf_clients) = ref-rec NO-LOCK .
    if NOT (buf_clients.obj-type = 'орг':U
            or
            buf_clients.obj-type = 'чел':U ) then do:
      message
      "Выберите контрагента типа" 'орг':U "или" 'чел':U
      view-as alert-box error .
      return no-apply.
    end.
    find first X_clients no-lock where
              recid(X_clients) = recid(buf_clients).
    assign
    tt-dis-card-mask.cli-type =  buf_clients.obj-type
    tt-dis-card-mask.cli-code = buf_clients.obj-code
    f-cli-name = buf_clients.obj-name
    .
    display
    tt-dis-card-mask.cli-type
    tt-dis-card-mask.cli-code
    f-cli-name
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-cli-mask IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
 DEFINE VARIABLE v-mask AS CHARACTER NO-UNDO.
   run ref/fillques.w (INPUT tt-dis-card-mask.cli-mask
                 ,INPUT "Редактирование правила определения номера ДК по маске карты"
                 ,INPUT "Маска"
                 ,INPUT 19
                 ,INPUT  "?0123456789DC":U
                 ,OUTPUT v-mask
                 ,OUTPUT v-ok) NO-ERROR.
 IF NOT ERROR-STATUS:ERROR AND v-ok THEN DO:
     ASSIGN
     tt-dis-card-mask.cli-mask = v-mask.
     DISPLAY
     tt-dis-card-mask.cli-mask
     WITH FRAME Dialog-Frame.
 END.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
    define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  loc-doc-rec = recid (locked_dis-card-mask).
  .
  run ref/dccmasks.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input "":U
                ,input "one":U
                ,input locked_dis-card-mask.type
                ,input locked_dis-card-mask.host-code
                ,input locked_dis-card-mask.mask-num
                ,input-output v-rid-list
                              )
.
END.
ON CHOOSE OF B-mask IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
 DEFINE VARIABLE v-mask AS CHARACTER NO-UNDO.
  run ref/fillques.w (INPUT tt-dis-card-mask.mask
                 ,INPUT "Редактирование маски карты"
                 ,INPUT "Маска"
                 ,INPUT 19
                 ,INPUT  "?*0123456789":U
                 ,OUTPUT v-mask
                 ,OUTPUT v-ok) NO-ERROR.
 IF NOT ERROR-STATUS:ERROR AND v-ok THEN DO:
     ASSIGN
     tt-dis-card-mask.mask = v-mask.
     DISPLAY
     tt-dis-card-mask.mask
     WITH FRAME Dialog-Frame.
 END.
END.
ON CHOOSE OF B-rank IN FRAME Dialog-Frame
DO:
    define variable v-rid-list as character no-undo .
  run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT p-curr-host-code
                   ,INPUT p-curr-obj-type
                   ,INPUT p-curr-obj-code
                   ,input "b-chg":U
                   ,INPUT 'все':U
                   ,INPUT '':U
                   ,INPUT 0
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
  IF ERROR-STATUS:error  THEN RETURN NO-APPLY.
END.
ON LEAVE OF tt-dis-card-mask.cli-code IN FRAME Dialog-Frame
DO:
  if   input frame Dialog-Frame tt-dis-card-mask.cli-code <> 0 then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
ON VALUE-CHANGED OF tt-dis-card-mask.cli-type IN FRAME Dialog-Frame
DO:
  assign
  tt-dis-card-mask.cli-type.
  if   input frame Dialog-Frame tt-dis-card-mask.cli-code <> 0 then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
ON VALUE-CHANGED OF reg-cash IN FRAME Dialog-Frame
DO:
  assign
  reg-cash
  .
END.
ON VALUE-CHANGED OF RS-cli-mask IN FRAME Dialog-Frame
DO:
  ASSIGN
  RS-cli-mask.
  RUN proc-cli-or-mask IN THIS-PROCEDURE (rs-cli-mask) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
find first X_sysconf no-lock where
            X_sysconf.host-code = p-curr-host-code no-error.
  if not available X_sysconf OR X_sysconf.host-code <> X_curr_clients.host-code then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-host-code"
    p-curr-host-code
    view-as alert-box ERROR.
    return error .
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
IF v-db-num <> 0
AND (p-mode = 'ДОБАВЛЕНИЕ':U
     OR p-mode = 'ИЗМЕНЕНИЕ':U ) THEN DO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-mode" p-mode skip
    "Нельзя редактировать запись МАСКИ ДИСКОНТНОЙ КАРТЫ в УБД"
    view-as alert-box ERROR.
    return error .
END.
for each tt-dis-card-mask:
  delete tt-dis-card-mask.
end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
          find first locked_dis-card-mask EXclusive-lock where
                       recid(locked_dis-card-mask) = p-doc-rec no-wait no-error.
          if locked locked_dis-card-mask then do:
            message
            vss-workfile vss-revision vss-description skip
             "Запись МАСКИ ДИСКОНТНОЙ КАРТЫ занята"
            view-as alert-box error .
            undo, return error.
          end.
    end.
    else do:
      find first locked_dis-card-mask no-lock where
                       recid(locked_dis-card-mask) = p-doc-rec no-error .
      if not avail locked_dis-card-mask then do:
        find first locked_dis-card-mask no-lock where
                   locked_dis-card-mask.mask-num = p-mask-num no-error .
      end.
    end.
    if not available locked_dis-card-mask then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись МАСКИ ДИСКОНТНОЙ КАРТЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-dis-card-mask.
    buffer-copy locked_dis-card-mask to tt-dis-card-mask.
    .
    cb-cc-run = IF tt-dis-card-mask.cc-run > 0
                 THEN STRING(tt-dis-card-mask.cc-run)
                ELSE '':U.
   end.
   else do:
       FIND last locked_dis-card-mask EXCLUSIVE-LOCK USE-INDEX pi NO-ERROR.
       IF AVAILABLE locked_dis-card-mask THEN DO:
           ASSIGN
           v-last-code = locked_dis-card-mask.mask-num
           .
       END.
          create tt-dis-card-mask.
          assign
         tt-dis-card-mask.mask-num = v-last-code + 1
         .
   end.
   IF p-mode <> 'ПРОСМОТР':U THEN DO:
       IF tt-dis-card-mask.obj-code <> 0 AND
           NOT (p-curr-obj-code = tt-dis-card-mask.obj-code
               AND
               p-curr-obj-type = tt-dis-card-mask.obj-type) THEN DO:
        MESSAGE
        "Редактирование маски, привязанной к объекту, разрешено только на этом объекте"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN.
       END.
       IF  tt-dis-card-mask.host-code <> 0
       AND NOT p-curr-host-code = tt-dis-card-mask.host-code
               THEN DO:
        MESSAGE
        "Редактирование маски, приязанной к фирме, разрешено только объекте данной фирмы"
        VIEW-AS ALERT-BOX.
        UNDO, RETURN.
       END.
  END.
IF p-mode <> 'ДОБАВЛЕНИЕ':U
or (p-mode = 'ДОБАВЛЕНИЕ':U and p-type <> "":U)
THEN do:
   IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
       FIND FIRST locked_dis-card-type  EXCLUSIVE-LOCK WHERE
                  locked_dis-card-type.emitent-host-code = locked_dis-card-mask.emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = LOCKED_dis-card-mask.TYPE NO-WAIT NO-ERROR.
   END.
   IF p-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST locked_dis-card-type  no-lock WHERE
                  locked_dis-card-type.emitent-host-code = locked_dis-card-mask.emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = LOCKED_dis-card-mask.TYPE NO-ERROR.
   END.
   if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
      cb-cc-run = (IF locked_dis-card-mask.cc-run > 0
                   THEN string(locked_dis-card-mask.cc-run)
                   ELSE '':U).
   end.
   IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
            FIND FIRST locked_dis-card-type  no-lock WHERE
                  locked_dis-card-type.emitent-host-code = p-emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = p-type no-error .
   END.
   if not available locked_dis-card-type then do:
    message
    "Не определен тип ДК" p-emitent-host-code p-type
    view-as alert-box error .
    UNDO, RETURN error .
   end.
   assign
   tt-dis-card-mask.emitent-host-code = locked_dis-card-type.emitent-host-code
   tt-dis-card-mask.type              = locked_dis-card-type.type
   .
END.
  ASSIGN
  tt-dis-card-mask.mask = entry(1, tt-dis-card-mask.mask)
  tt-dis-card-mask.cli-mask = entry(1, tt-dis-card-mask.cli-mask)
  .
  find first buf_dis-card-mask-attr no-lock where buf_dis-card-mask-attr.mask-num = tt-dis-card-mask.mask-num and buf_dis-card-mask-attr.attr-code = "reg-cash" no-error .
  if available (buf_dis-card-mask-attr) then do:
    if buf_dis-card-mask-attr.attr-value = "yes" then reg-cash:checked = yes .
    else reg-cash:checked = no .
  end.
  else reg-cash:checked = no .
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-cli :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where
              buf_clients.obj-code = input frame Dialog-Frame tt-dis-card-mask.cli-code
         and buf_clients.obj-type = input frame Dialog-Frame tt-dis-card-mask.cli-type no-error.
if not available buf_clients then do:
  if input frame Dialog-Frame tt-dis-card-mask.cli-code <> ?  then
    message "Неправильный код или тип контрагента" VIEW-AS ALERT-BOX ERROR.
  apply "entry" to tt-dis-card-mask.cli-code in frame Dialog-Frame.
  return error.
end.
find first X_clients no-lock where recid(X_clients) = recid(buf_clients).
assign
tt-dis-card-mask.cli-type = buf_clients.obj-type
tt-dis-card-mask.cli-code = buf_clients.obj-code
f-cli-name = buf_clients.obj-name
.
display
tt-dis-card-mask.cli-type
tt-dis-card-mask.cli-code
f-cli-name
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-dis-card-mask SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY reg-cash RS-region RS-cli-mask CB-CC-run f-emitent-name l-rs-cli-mask
          f-cli-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-card-mask THEN
    DISPLAY tt-dis-card-mask.type tt-dis-card-mask.mask-num
          tt-dis-card-mask.use-on tt-dis-card-mask.emitent-host-code
          tt-dis-card-mask.mask tt-dis-card-mask.rank tt-dis-card-mask.cli-type
          tt-dis-card-mask.cli-code tt-dis-card-mask.cli-mask
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help B-card-type tt-dis-card-mask.use-on
         reg-cash RS-region B-mask tt-dis-card-mask.rank B-rank RS-cli-mask
         B-cli-mask CB-CC-run f-emitent-name l-rs-cli-mask f-cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN do:
   IF tt-dis-card-mask.cli-code <> 0 THEN DO:
       FIND FIRST X_clients  NO-LOCK WHERE
                  X_clients.obj-type = tt-dis-card-mask.cli-type
           AND    X_clients.obj-code = tt-dis-card-mask.cli-code.
   END.
   IF tt-dis-card-mask.emitent-host-code <> 0 THEN DO:
      FIND FIRST X_clients_dctype  NO-LOCK WHERE
                      X_clients_dctype.obj-type = 'орг':U
               AND    X_clients_dctype.obj-code = tt-dis-card-mask.emitent-host-code.
   END.
END.
if p-mode = 'ДОБАВЛЕНИЕ':U then  do:
  RS-cli-mask = "cli-code":U .
end.
if tt-dis-card-mask.cli-code > 0 then do:
  if tt-dis-card-mask.cli-mask = '':U then do:
    RS-cli-mask = "cli-code":U .
  end.
  else do:
    RS-cli-mask = "cli-mask-cli-code":U.
  end.
end.
else do:
  RS-cli-mask = "cli-mask":U.
end.
ASSIGN
v-tab-order = "b-exit,b-quit,b-hist,b-help," +
              "b-card-type,mask-num,t-use-on-cd,RS-region,b-mask,rank,b-rank,Rs-cli-mask,cli-type,cli-code,b-cli,b-cli-mask,cb-cc-run"
tt-dis-card-mask.cli-type:RADIO-BUTTONS IN FRAME Dialog-Frame = "Орг" + chr(44) + 'орг':U + chr(44) +
                                                                   "Чел" + chr(44) + 'чел':U
Rs-region:RADIO-BUTTONS IN FRAME Dialog-Frame =
"Глобально" + chr(44) + "0":U + chr(44) +
("Фирма" + chr(32) +
 (IF p-mode = 'ДОБАВЛЕНИЕ':U OR tt-dis-card-mask.host-code = 0
  THEN STRING(p-curr-host-code)
  ELSE STRING(tt-dis-card-mask.host-code))) + chr(44) + "1":U + chr(44) +
("Объект" + chr(32) +
  (IF p-mode = 'ДОБАВЛЕНИЕ':U OR tt-dis-card-mask.obj-code = 0
   THEN (p-curr-obj-type + STRING(p-curr-obj-code))
   ELSE (tt-dis-card-mask.obj-type + STRING(tt-dis-card-mask.obj-code))) + chr(44) + "2":U)
Rs-region = IF tt-dis-card-mask.host-code = 0
            THEN 0
            ELSE ( IF tt-dis-card-mask.obj-code = 0
                   THEN 1
                   ELSE 2
                  )
f-emitent-name = IF p-mode = 'ДОБАВЛЕНИЕ':U
                 THEN "":U
                ELSE (IF tt-dis-card-mask.emitent-host-code = 0
                      THEN "Глобально"
                      ELSE X_clients_dctype.obj-name
                    )
cb-cc-run:LIST-ITEM-PAIRS  in frame Dialog-Frame =  "Не используется" + chr(44) + '0':U + chr(44) +
                                                     "По методу Luhna" + chr(44) + '1':U
.
DISPLAY
RS-region
RS-cli-mask
f-emitent-name
f-cli-name
cb-cc-run
l-rs-cli-mask
WITH FRAME Dialog-Frame.
IF p-mode <> 'ПРОСМОТР':U THEN
ASSIGN
tt-dis-card-mask.mask:BGCOLOR = WHITE_COLOR
tt-dis-card-mask.cli-mask:BGCOLOR = WHITE_COLOR.
.
IF AVAILABLE tt-dis-card-mask THEN
DISPLAY
tt-dis-card-mask.type
tt-dis-card-mask.emitent-host-code
tt-dis-card-mask.mask-num
tt-dis-card-mask.rank
tt-dis-card-mask.mask
tt-dis-card-mask.cli-type
tt-dis-card-mask.cli-code
tt-dis-card-mask.cli-mask
tt-dis-card-mask.use-on
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
B-hist WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
B-card-type WHEN (p-mode <> 'ПРОСМОТР':U and not (p-mode = 'ДОБАВЛЕНИЕ':U and p-type <> "":U))
cb-cc-run WHEN p-mode <> 'ПРОСМОТР':U
b-rank WHEN p-mode <> 'ПРОСМОТР':U
b-mask WHEN p-mode <> 'ПРОСМОТР':U
RS-region WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-card-mask.rank WHEN p-mode <> 'ПРОСМОТР':U
tt-dis-card-mask.use-on WHEN p-mode <> 'ПРОСМОТР':U
RS-cli-mask WHEN p-mode <> 'ПРОСМОТР':U
reg-cash when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide
  b-exit in frame Dialog-Frame.
end.
RUN proc-cli-or-mask IN THIS-PROCEDURE(rs-cli-mask) NO-ERROR.
IF ERROR-STATUS:ERROR  THEN UNDO, RETURN ERROR.
END PROCEDURE.
PROCEDURE proc-b-card-type :
define variable var-rid-str as character no-undo.
define buffer b_clients for ub.clients.
var-rid-str = string(recid(locked_dis-card-type)).
run ref/dc-types.w (
               input parparentproc
              ,input "":U
              ,input "b-sel":U
              ,input 0
              ,input p-curr-host-code
              ,input p-curr-obj-type
              ,input p-curr-obj-code
              ,input-output  var-rid-str) .
if var-rid-str = "" then return no-apply.
find first locked_dis-card-type no-lock where
           recid(locked_dis-card-type) = integer(var-rid-str) No-ERROR.
if not avail locked_dis-card-type then return no-apply.
if locked_dis-card-type.emitent-host-code = 0 then do:
  ASSIGN
  f-emitent-name = "Глобальная"
  tt-dis-card-mask.emitent-host-code = LOCKED_dis-card-type.emitent-host-code
  tt-dis-card-mask.TYPE              = LOCKED_dis-card-type.TYPE
  .
  RELEASE X_clients_dctype.
end.
else do:
   find first b_clients No-LOCK WHERE
              b_clients.obj-type = 'орг':U and
              b_clients.obj-code = locked_dis-card-type.emitent-host-code No-ERROR.
   if not avail b_clients then return no-apply.
   ASSIGN
   f-emitent-name = b_clients.obj-name
   tt-dis-card-mask.emitent-host-code = LOCKED_dis-card-type.emitent-host-code
   tt-dis-card-mask.TYPE              = LOCKED_dis-card-type.TYPE
   .
   FIND FIRST X_clients_dctype NO-LOCK WHERE
             recid(X_clients_dctype) = recid(b_clients).
END.
   display
   tt-dis-card-mask.type
   tt-dis-card-mask.emitent-host-code
   f-emitent-name
   with frame Dialog-Frame
   .
END PROCEDURE.
PROCEDURE proc-cli-or-mask :
DEFINE INPUT PARAMETER p-cli-or-mask AS character NO-UNDO.
CASE p-cli-or-mask:
    WHEN "cli-code":U THEN DO:
        ASSIGN
        tt-dis-card-mask.cli-mask = "":U.
        ASSIGN
        cb-cc-run = '':U
        .
        DISPLAY
        tt-dis-card-mask.cli-mask
        cb-cc-run
        WITH FRAME Dialog-Frame.
        DISABLE
        tt-dis-card-mask.cli-mask
        b-cli-mask
        cb-cc-run
        WITH FRAME Dialog-Frame.
        ENABLE
        b-cli      when p-mode <> 'ПРОСМОТР':U
        tt-dis-card-mask.cli-code when p-mode <> 'ПРОСМОТР':U
        tt-dis-card-mask.cli-type when p-mode <> 'ПРОСМОТР':U
        WITH FRAME Dialog-Frame.
    END.
    WHEN "cli-mask":U THEN DO:
        ASSIGN
        tt-dis-card-mask.cli-code = 0
        f-cli-name = "":U
        .
        DISPLAY
        tt-dis-card-mask.cli-code
        f-cli-name
        WITH FRAME Dialog-Frame.
        DISABLE
        tt-dis-card-mask.cli-type
        tt-dis-card-mask.cli-code
        b-cli
        WITH FRAME Dialog-Frame.
        ENABLE
        b-cli-mask when p-mode <> 'ПРОСМОТР':U
        cb-cc-run  when p-mode <> 'ПРОСМОТР':U
        WITH FRAME Dialog-Frame.
    END.
     WHEN "cli-mask-cli-code":U THEN DO:
        DISPLAY
        tt-dis-card-mask.cli-code
        f-cli-name
        WITH FRAME Dialog-Frame.
        ENABLE
        b-cli-mask when p-mode <> 'ПРОСМОТР':U
        cb-cc-run  when p-mode <> 'ПРОСМОТР':U
        b-cli      when p-mode <> 'ПРОСМОТР':U
        tt-dis-card-mask.cli-code when p-mode <> 'ПРОСМОТР':U
        tt-dis-card-mask.cli-type when p-mode <> 'ПРОСМОТР':U
        WITH FRAME Dialog-Frame.
    END.
END CASE.
END PROCEDURE.
PROCEDURE proc-save :
define variable glog as logical no-undo .
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
assign
frame Dialog-Frame
reg-cash
rs-CLI-MASK
rs-region
cb-cc-run
tt-dis-card-mask.use-on
tt-dis-card-mask.cc-run = INTEGER(cb-cc-run)
tt-dis-card-mask.host-code = (IF rs-region = 0 THEN 0 ELSE p-curr-host-code)
tt-dis-card-mask.obj-type  = (IF rs-region < 2 THEN "":U ELSE p-curr-obj-type)
tt-dis-card-mask.obj-code  = (IF rs-region < 2 THEN 0 ELSE p-curr-obj-code)
tt-dis-card-mask.cli-code
tt-dis-card-mask.cli-code = (IF RS-CLI-MASK = "CLI-CODE":u or RS-CLI-MASK = "cli-mask-cli-code"
                             THEN tt-dis-card-mask.cli-code
                             else 0)
tt-dis-card-mask.cli-type
tt-dis-card-mask.cli-type = (IF RS-CLI-MASK = "CLI-CODE":u or RS-CLI-MASK = "cli-mask-cli-code"
                             THEN tt-dis-card-mask.cli-type
                             else "":U)
tt-dis-card-mask.cli-mask
tt-dis-card-mask.cli-mask  = (IF RS-CLI-MASK = "CLI-MASK":u or RS-CLI-MASK = "cli-mask-cli-code"
                              THEN tt-dis-card-mask.cli-mask
                              ELSE "":U)
tt-dis-card-mask.emitent-host-code
tt-dis-card-mask.mask
tt-dis-card-mask.mask-num
tt-dis-card-mask.rank
tt-dis-card-mask.type
.
if index(tt-dis-card-mask.cli-mask, chr(63)) > 0 then do:
  message
  substitute("Если Вы планируете использовать ДАННУЮ маску для передачи на кассы ДЛИННЫХ номеров карт&1" +
             "или определения КОРОТКИХ номеров карт (номеров, хранящихся в TH) по ДЛИННЫМ номерам при приеме чеков с касс&1" +
             "то карта не должна содержать знаки &2&1" +
             "Все равно сохранить маску?"
             , chr(10)
             , chr(63))
  view-as alert-box WARNING buttons  YES-NO update glog.
  if not glog then undo, return error .
end.
 run ref/dc-mask1.p (
input-output p-doc-rec
,input parparentproc
,input p-mode
,INPUT tt-dis-card-mask.use-on
,input tt-dis-card-mask.cli-code
,input tt-dis-card-mask.cli-mask
,input tt-dis-card-mask.cli-type
,input tt-dis-card-mask.emitent-host-code
,input tt-dis-card-mask.host-code
,input tt-dis-card-mask.mask-num
,input tt-dis-card-mask.mask
,input tt-dis-card-mask.obj-code
,input tt-dis-card-mask.obj-type
,input tt-dis-card-mask.rank
,input tt-dis-card-mask.type
,input tt-dis-card-mask.cc-run
,input reg-cash
)
no-error.
if error-status:error then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END PROCEDURE.
