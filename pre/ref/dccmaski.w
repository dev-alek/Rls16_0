DEFINE BUFFER locked_c-dis-card-mask FOR ub.c-dis-card-mask.
DEFINE BUFFER LOCKED_dis-card-mask FOR ub.dis-card-mask.
DEFINE BUFFER locked_dis-card-type FOR ub.dis-card-type.
DEFINE TEMP-TABLE tt-c-dis-card-mask NO-UNDO LIKE ub.c-dis-card-mask.
DEFINE TEMP-TABLE tt-dis-card-mask NO-UNDO LIKE ub.dis-card-mask.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_clients_dctype FOR ub.clients.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode           AS CHARACTER             no-undo .
define input parameter p-mask-num       like ub.c-dis-card-mask.mask-num no-undo .
define input parameter p-chip-num       like ub.c-dis-card-mask.chip-num no-undo .
define input parameter p-corr-user-db-num   like ub.c-dis-card-mask.corr-user-db-num no-undo .
define INPUT-OUTPUT parameter p-doc-rec AS recid no-undo .
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "История маски дисконтной карты":U.
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
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-last-code LIKE ub.c-dis-card-mask.mask-num NO-UNDO.
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
DEFINE VARIABLE CB-CC-run AS CHARACTER FORMAT "X(256)":U
     LABEL "Алгоритм КЦ"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 NO-UNDO.
DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 46.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-emitent-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 50.5 BY .67 NO-UNDO.
DEFINE VARIABLE RS-cli-mask AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Маска КОРОТКОГО №", "cli-mask",
"Определенный контрагент", "cli-code"
     SIZE 51 BY 1.27 NO-UNDO.
DEFINE VARIABLE RS-region AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Глобально", 0,
"Фирма", 1,
"Объект", 2
     SIZE 63 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-c-dis-card-mask SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     tt-c-dis-card-mask.use-on AT ROW 3.27 COL 67.5 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Использовать на кассе и в TH", 0,
"Использовать ТОЛЬКО на кассе", 1,
"Использовать ТОЛЬКО в TH", 2
          SIZE 31.5 BY 2.27
     tt-c-dis-card-mask.type AT ROW 3.77 COL 18 COLON-ALIGNED
          LABEL "Тип карты"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-c-dis-card-mask.mask-num AT ROW 3.77 COL 47.5 COLON-ALIGNED
          LABEL "Номер маски"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-c-dis-card-mask.emitent-host-code AT ROW 5 COL 18 COLON-ALIGNED
          LABEL "Эмитент карты"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     RS-region AT ROW 6.5 COL 20.5 NO-LABEL
     tt-c-dis-card-mask.rank AT ROW 8.5 COL 79 COLON-ALIGNED
          LABEL "Ранг(приоритет при поиске)"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-c-dis-card-mask.mask AT ROW 8.77 COL 14.5 COLON-ALIGNED
          LABEL "Маска карты"
          VIEW-AS FILL-IN
          SIZE 26 BY 1
     RS-cli-mask AT ROW 10.27 COL 43.5 NO-LABEL
     tt-c-dis-card-mask.cli-type AT ROW 12.27 COL 16.5 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U
          SIZE 14 BY 1
     tt-c-dis-card-mask.cli-code AT ROW 12.27 COL 29.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-c-dis-card-mask.cli-mask AT ROW 14.27 COL 19 COLON-ALIGNED
          LABEL "Маска КОРОТКОГО №"
          VIEW-AS FILL-IN
          SIZE 18 BY 1
     CB-CC-run AT ROW 14.27 COL 67 COLON-ALIGNED
     f-emitent-name AT ROW 5.27 COL 37 COLON-ALIGNED NO-LABEL
     f-cli-name AT ROW 12.5 COL 50.5 COLON-ALIGNED NO-LABEL
     "Контрагент" VIEW-AS TEXT
          SIZE 13.5 BY 1.27 AT ROW 12 COL 2
     "Метод поиска контрагента по маске карты" VIEW-AS TEXT
          SIZE 39.5 BY 1.27 AT ROW 10.27 COL 2.5
     "Область действия" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 6.5 COL 2.5
     SPACE(79.24) SKIP(8.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История маски дисконтной карты"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
 if p-mode  <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
for each tt-c-dis-card-mask:
  delete tt-c-dis-card-mask.
end.
  if p-mode = 'ПРОСМОТР':U then do:
    find first locked_c-dis-card-mask no-lock where
                      recid(locked_c-dis-card-mask) = p-doc-rec no-error .
    if not avail locked_c-dis-card-mask then do:
      find first locked_c-dis-card-mask no-lock where
                  locked_c-dis-card-mask.mask-num = p-mask-num
              AND locked_c-dis-card-mask.corr-user-db-num = p-corr-user-db-num
              AND locked_c-dis-card-mask.chip-num = p-chip-num
              no-error .
    end.
    if not available locked_c-dis-card-mask then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ИСТОРИИ МАСКИ ДИСКОНТНОЙ КАРТЫ"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-c-dis-card-mask.
    buffer-copy locked_c-dis-card-mask to tt-c-dis-card-mask.
    if LOCKED_c-dis-card-mask.cc-run > 0 then
    cb-cc-run = string(LOCKED_c-dis-card-mask.cc-run).
    else
    cb-cc-run = '':U
    .
   end.
   IF p-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST locked_dis-card-type  no-lock WHERE
                  locked_dis-card-type.emitent-host-code = locked_c-dis-card-mask.emitent-host-code
            AND   LOCKED_dis-card-type.TYPE = LOCKED_c-dis-card-mask.TYPE NO-ERROR.
  END.
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = locked_c-dis-card-mask.obj-type
       AND X_curr_clients.obj-code = locked_c-dis-card-mask.obj-code no-error.
  find first X_sysconf no-lock where
            X_sysconf.host-code = locked_c-dis-card-mask.host-code no-error.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-c-dis-card-mask SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY RS-region RS-cli-mask CB-CC-run f-emitent-name f-cli-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-dis-card-mask THEN
    DISPLAY tt-c-dis-card-mask.use-on tt-c-dis-card-mask.type
          tt-c-dis-card-mask.mask-num tt-c-dis-card-mask.emitent-host-code
          tt-c-dis-card-mask.rank tt-c-dis-card-mask.mask
          tt-c-dis-card-mask.cli-type tt-c-dis-card-mask.cli-code
          tt-c-dis-card-mask.cli-mask
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-c-dis-card-mask.use-on RS-region
         tt-c-dis-card-mask.rank tt-c-dis-card-mask.mask RS-cli-mask CB-CC-run
         f-emitent-name f-cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
IF tt-c-dis-card-mask.cli-code <> 0 THEN DO:
    FIND FIRST X_clients  NO-LOCK WHERE
              X_clients.obj-type = tt-c-dis-card-mask.cli-type
        AND    X_clients.obj-code = tt-c-dis-card-mask.cli-code.
END.
IF tt-c-dis-card-mask.emitent-host-code <> 0 THEN DO:
  FIND FIRST X_clients_dctype  NO-LOCK WHERE
                  X_clients_dctype.obj-type = 'орг':U
            AND    X_clients_dctype.obj-code = tt-c-dis-card-mask.emitent-host-code.
END.
ASSIGN
v-tab-order = "b-exit,b-quit,b-help"
tt-c-dis-card-mask.cli-type:RADIO-BUTTONS IN FRAME Dialog-Frame = "Орг" + chr(44) + 'орг':U + chr(44) +
                                                                   "Чел" + chr(44) + 'чел':U
RS-cli-mask = IF tt-c-dis-card-mask.cli-code > 0 THEN "cli-code":U ELSE "cli-mask":U
Rs-region:RADIO-BUTTONS IN FRAME Dialog-Frame =
"Глобально" + chr(44) + "0":U + chr(44) +
("Фирма" + chr(32) + STRING(tt-c-dis-card-mask.host-code)) + chr(44) + "1":U + chr(44) +
("Объект" + chr(32) + tt-c-dis-card-mask.obj-type + STRING(tt-c-dis-card-mask.obj-code)) + chr(44) + "2":U
Rs-region = IF tt-c-dis-card-mask.host-code = 0
            THEN 0
            ELSE ( IF tt-c-dis-card-mask.obj-code = 0
                   THEN 1
                   ELSE 2
                  )
f-emitent-name = IF p-mode = 'ДОБАВЛЕНИЕ':U
                 THEN "":U
                ELSE (IF tt-c-dis-card-mask.emitent-host-code = 0
                      THEN "Глобально"
                      ELSE X_clients_dctype.obj-name
                    )
cb-cc-run:LIST-ITEM-PAIRS  in frame Dialog-Frame =  "Не используется" + chr(44) + '0':U + chr(44) +
                                                      "Методу Luhna" + chr(44) + '1':U.
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  .
  hide
  b-exit in frame Dialog-Frame.
end.
DISPLAY
b-quit
b-help
RS-region
RS-cli-mask
f-emitent-name
f-cli-name
WITH FRAME Dialog-Frame .
Enable
b-quit
b-help
with frame Dialog-Frame .
IF AVAILABLE tt-c-dis-card-mask THEN
DISPLAY
tt-c-dis-card-mask.type
tt-c-dis-card-mask.emitent-host-code
tt-c-dis-card-mask.mask-num
tt-c-dis-card-mask.rank
tt-c-dis-card-mask.mask
tt-c-dis-card-mask.cli-type
tt-c-dis-card-mask.cli-code
tt-c-dis-card-mask.cli-mask
tt-c-dis-card-mask.use-on
cb-cc-run
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
END PROCEDURE.
