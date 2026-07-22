DEFINE INPUT PARAMETER parParentProc   AS WIDGET-HANDLE  NO-UNDO .
define input parameter p-host-code     AS INTEGER        no-undo .
define input parameter p-code-bank     as integer        no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и изменение банковского атрибута - счета для инкассации".
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
define buffer buf_fin-bank-attr for ub.fin-bank-attr .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE v-qr-code AS CHARACTER FORMAT "X(256)":U
     LABEL "QR код"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS " ","0",
                     "Сбербанк","1"
     DROP-DOWN-LIST
     SIZE 15.25 BY 1 NO-UNDO.
DEFINE VARIABLE v-bank AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67 NO-UNDO.
DEFINE VARIABLE v-collect-account AS CHARACTER FORMAT "X(256)":U
     LABEL "Дебет"
     VIEW-AS FILL-IN
     SIZE 46.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-credit-account AS CHARACTER FORMAT "X(256)":U
     LABEL "Кредит"
     VIEW-AS FILL-IN
     SIZE 46.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-firm AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60 BY .67 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     v-collect-account AT ROW 5 COL 9 WIDGET-ID 8
     v-credit-account AT ROW 6.5 COL 8 WIDGET-ID 10
     v-qr-code AT ROW 7.96 COL 14.25 COLON-ALIGNED WIDGET-ID 14
     v-firm AT ROW 2.25 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     v-bank AT ROW 3.25 COL 3 NO-LABEL WIDGET-ID 6
     SPACE(1.62) SKIP(5.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки банка-вносителя для инкассации"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    assign
      v-collect-account
      v-firm
      v-bank
      v-credit-account
      v-QR-code
      .
    run save-attr in this-procedure no-error.
    IF ERROR-STATUS:ERROR THEN
    DO:
      MESSAGE RETURN-VALUE SKIP
        ERROR-STATUS:GET-MESSAGE(1)
        VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
    END.
  END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
  DO:
    MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ref\bankcola.w" VIEW-AS ALERT-BOX INFORMATION.
  END.
ON LEAVE OF v-collect-account IN FRAME Dialog-Frame
DO:
    assign v-collect-account .
  END.
ON LEAVE OF v-credit-account IN FRAME Dialog-Frame
DO:
    assign v-credit-account .
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN load-attr IN THIS-PROCEDURE.
  RUN enable_UI.
  APPLY "ENTRY" TO v-collect-account .
  APPLY "ENTRY" TO v-credit-account .
  APPLY "ENTRY" TO v-QR-code .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-collect-account v-credit-account v-qr-code v-firm v-bank
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help v-collect-account v-credit-account v-qr-code
         v-firm v-bank
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE load-attr :
  define buffer buf_fin-bank for ub.fin-bank .
  define buffer buf_clients  for ub.clients .
  DO
    ON ERROR UNDO, RETURN ERROR
    :
    FIND FIRST buf_clients
      WHERE buf_clients.obj-type = 'орг':U
      AND buf_clients.obj-code = p-host-code
      NO-LOCK
      NO-ERROR
      .
    IF NOT AVAILABLE buf_clients
      THEN
    DO:
      RETURN ERROR SUBSTITUTE("Не найдена фирма №&1", p-host-code).
    END.
    FIND FIRST buf_fin-bank
      WHERE buf_fin-bank.host-code = p-host-code
      AND buf_fin-bank.code-bank = p-code-bank
      NO-LOCK
      NO-ERROR
      .
    IF NOT AVAILABLE buf_clients
      THEN
    DO:
      RETURN ERROR SUBSTITUTE ( "Не найден банк &1 для фирмы &2 &3"
        , p-code-bank
        , p-host-code
        , buf_clients.obj-name
        ) .
    END.
    ASSIGN
      v-firm = SUBSTITUTE("Фирма: &1", buf_clients.obj-name)
      v-bank = SUBSTITUTE(" Банк: &1", buf_fin-bank.bank-name)
      .
    FIND FIRST buf_fin-bank-attr
      where buf_fin-bank-attr.host-code  = p-host-code
      and buf_fin-bank-attr.code-bank  = p-code-bank
      and buf_fin-bank-attr.attr-code  = "collect-debt":U
      no-lock
      no-error
      .
    IF AVAILABLE buf_fin-bank-attr
      THEN
    DO:
      assign
        v-collect-account = buf_fin-bank-attr.attr-value
        .
    END.
    FIND FIRST buf_fin-bank-attr
      where buf_fin-bank-attr.host-code  = p-host-code
      and buf_fin-bank-attr.code-bank  = p-code-bank
      and buf_fin-bank-attr.attr-code  = "collect-credit":U
      no-lock
      no-error
      .
    IF AVAILABLE buf_fin-bank-attr
      THEN
    DO:
      assign
        v-credit-account = buf_fin-bank-attr.attr-value
        .
    END.
    FIND FIRST buf_fin-bank-attr
      where buf_fin-bank-attr.host-code  = p-host-code
      and buf_fin-bank-attr.code-bank  = p-code-bank
      and buf_fin-bank-attr.attr-code  = "collect-qrcode":U
      no-lock
      no-error
      .
    IF AVAILABLE buf_fin-bank-attr
      THEN
    DO:
      assign
        v-QR-code = buf_fin-bank-attr.attr-value
        .
    END.
  END.
END PROCEDURE.
PROCEDURE save-attr :
  DO
    ON ERROR UNDO, RETURN ERROR
    :
    if v-collect-account <> "" then
    do:
      FIND first buf_fin-bank-attr EXCLUSIVE-LOCK where
        buf_fin-bank-attr.host-code = p-host-code and
        buf_fin-bank-attr.code-bank = p-code-bank and
        buf_fin-bank-attr.attr-code = "collect-debt":U
        no-error.
      if not available (buf_fin-bank-attr) then
      DO:
        CREATE buf_fin-bank-attr.
        assign
          buf_fin-bank-attr.host-code = p-host-code
          buf_fin-bank-attr.code-bank = p-code-bank
          buf_fin-bank-attr.attr-code = "collect-debt":U
          .
      END.
      ASSIGN
        buf_fin-bank-attr.attr-value = v-collect-account
        .
    end.
    IF v-credit-account <> ""
      THEN
    DO:
      FIND first buf_fin-bank-attr EXCLUSIVE-LOCK where
        buf_fin-bank-attr.host-code = p-host-code and
        buf_fin-bank-attr.code-bank = p-code-bank and
        buf_fin-bank-attr.attr-code = "collect-credit":U
        no-error.
      if not available (buf_fin-bank-attr) then
      DO:
        CREATE buf_fin-bank-attr.
        assign
          buf_fin-bank-attr.host-code = p-host-code
          buf_fin-bank-attr.code-bank = p-code-bank
          buf_fin-bank-attr.attr-code = "collect-credit":U
          .
      END.
      ASSIGN
        buf_fin-bank-attr.attr-value = v-credit-account
        .
    end.
    IF v-QR-code <> ""
      THEN
    DO:
      FIND first buf_fin-bank-attr EXCLUSIVE-LOCK where
        buf_fin-bank-attr.host-code = p-host-code and
        buf_fin-bank-attr.code-bank = p-code-bank and
        buf_fin-bank-attr.attr-code = "collect-qrcode":U
        no-error .
      if not available (buf_fin-bank-attr) then
      do:
        CREATE buf_fin-bank-attr.
        assign
          buf_fin-bank-attr.host-code = p-host-code
          buf_fin-bank-attr.code-bank = p-code-bank
          buf_fin-bank-attr.attr-code = "collect-qrcode":U
          .
      END.
      ASSIGN
        buf_fin-bank-attr.attr-value = v-QR-code
        .
    end.
  END.
END PROCEDURE.
