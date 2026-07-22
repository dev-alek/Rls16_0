define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Выбор причины установки РВД" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-type as integer no-undo .
define output parameter p-rvd-reason as character no-undo .
define output parameter p-ITSM-num as character no-undo .
define output parameter p-oper-fio as character no-undo .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_user-account for ub.user-account .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-ITSM-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер заявки в ITSM"
     VIEW-AS FILL-IN
     SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE f-oper-fio AS CHARACTER FORMAT "X(256)":U
     LABEL "ФИО инициатора заявки"
     VIEW-AS FILL-IN
     SIZE 50 BY 1 NO-UNDO.
DEFINE VARIABLE f-inv-fio AS CHARACTER FORMAT "X(256)":U
     LABEL "ФИО сотрудника инвентаризационной комиссии"
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE f-rvd-reason AS character FORMAT "X(64)":U INITIAL ""
     LABEL "Основание/причина разрешения РВД"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE v-reason-name AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 20 BY 1 NO-UNDO.
DEFINE BUTTON r-select-rvd-reason
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-sr-izm"
     SIZE 3 BY .88.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.2 COL 2
     Btn_Cancel AT ROW 1.2 COL 17
     f-rvd-reason AT ROW 3 COL 41 COLON-ALIGNED WIDGET-ID 2
     v-reason-name at row 3 col 60 no-label
     r-select-rvd-reason at row 3 col 80
     f-ITSM-num AT ROW 4.5 COL 25 COLON-ALIGNED WIDGET-ID 4
     f-oper-fio AT ROW 6 COL 25 COLON-ALIGNED WIDGET-ID 6
     f-inv-fio AT ROW 6 COL 4 WIDGET-ID 6
     SPACE(2) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Причины установки РВД"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  p-rvd-reason = ? .
  APPLY "END-ERROR":U TO SELF.
END.
ON choose of Btn_Cancel in FRAME Dialog-Frame
DO:
  p-rvd-reason = ? .
END.
on F2 of frame Dialog-Frame anywhere do:
 return no-apply.
end.
ON choose of Btn_OK in FRAME Dialog-Frame
DO:
  assign
    f-rvd-reason
    f-ITSM-num
    f-oper-fio
    f-inv-fio
  .
  if f-rvd-reason = "" or f-rvd-reason = ?
  then do :
    message 'Не заполнено поле "Основание/причина разрешения РВД". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
    view-as alert-box .
    return no-apply .
  end .
  find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = f-rvd-reason
                                       and buf_ext-classif.classif-subject = 'rvd-reason':U
                                       and buf_ext-classif.classif-name = 'rvd-reason':U
                                       no-error .
  if not available buf_ext-classif
  then do :
    v-reason-name:screen-value = "" .
    message "Не заполнено основание для перехода на РВД" view-as alert-box .
    return no-apply .
  end .
  if trim(f-ITSM-num) = ""
  then do :
    if f-ITSM-num:label = "Номер приказа"
    then do :
      message 'Не заполнено поле "Номер приказа". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
      view-as alert-box .
    end .
    else do :
      message 'Не заполнено поле "Номер заявки в ITSM". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
      view-as alert-box .
    end .
    return no-apply .
  end .
  if f-oper-fio:visible
  and trim(f-oper-fio) = ""
  then do :
    message 'Не заполнено поле "ФИО инициатора заявки". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
    view-as alert-box .
    return no-apply .
  end .
  if f-inv-fio:visible
  and trim(f-inv-fio) = ""
  then do :
    message 'Не заполнено поле "ФИО сотрудника инвентаризационной комиссии". Все поля формы обязательны для заполнения. Для отказа установки разрешения РВД необходимо нажать "Отмена"'
    view-as alert-box .
    return no-apply .
  end .
  assign
    p-rvd-reason  = f-rvd-reason
    p-ITSM-num    = f-ITSM-num
    p-oper-fio    = f-oper-fio
  .
  if f-inv-fio:visible then p-oper-fio = f-inv-fio .
END.
on leave OF f-rvd-reason IN FRAME Dialog-Frame
DO:
  find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = f-rvd-reason:screen-value
                                       and buf_ext-classif.classif-subject = 'rvd-reason':U
                                       and buf_ext-classif.classif-name = 'rvd-reason':U
                                       no-error .
  if not available buf_ext-classif
  then do :
    v-reason-name:screen-value = "" .
  end .
  else do :
    if buf_ext-classif.Key#_Two <> 0
    then do :
      message "Выбранное основание для перехода на РВД предназначено НЕ для РГС!" view-as alert-box .
      f-rvd-reason:screen-value = "0" .
    end .
    else
    if buf_ext-classif.nonuniq = 1
    then do :
      message "Выбранное основание для перехода на РВД удалено!" view-as alert-box .
      f-rvd-reason:screen-value = "0" .
    end .
    else
      v-reason-name:screen-value = buf_ext-classif.CharKey_Two .
  end .
END.
on choose of r-select-rvd-reason IN FRAME Dialog-Frame
do:
  define variable v-rec as character no-undo .
  run ref/rvd-reason.w (input parparentproc,
                        input "b-sel",
                        input 'текущие':U,
                        input p-type,
                        output v-rec ) .
  find first buf_ext-classif no-lock where recid(buf_ext-classif) = integer(v-rec) no-error .
  if not available buf_ext-classif
  then do :
    message "Не заполнено основание для перехода на РВД" view-as alert-box .
    return no-apply .
  end .
  v-reason-name:screen-value = buf_ext-classif.CharKey_Two .
  f-rvd-reason:screen-value = buf_ext-classif.CharKey_One .
end .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  f-inv-fio:visible = false .
  RUN enable_UI.
  if p-type = -1
  then do :
    p-type = 0 .
    f-ITSM-num:label = "Номер приказа" .
    hide f-oper-fio in FRAME Dialog-Frame.
    for first buf_user-account no-lock where buf_user-account.user-id = v-cntxt-userid :
      f-inv-fio = buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name .
    end .
    DISPLAY f-ITSM-num f-inv-fio
      WITH FRAME Dialog-Frame.
    ENABLE f-inv-fio
      WITH FRAME Dialog-Frame.
  end .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-rvd-reason f-ITSM-num f-oper-fio r-select-rvd-reason
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel f-rvd-reason f-ITSM-num f-oper-fio r-select-rvd-reason
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
