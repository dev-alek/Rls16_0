define input parameter parparentproc as handle no-undo.
define input parameter parmode       as char no-undo.
define input-output parameter parcar-num          as character no-undo.
define input-output parameter parautoent-obj-type as character no-undo.
define input-output parameter parautoent-obj-code as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран просмотра дополнительной информации по расходу топлива".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable varlog as logical no-undo.
DEFINE BUTTON b-auto-tank
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-clients"
     SIZE 3 BY .88.
DEFINE BUTTON B-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varautoent-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Автопредприятие"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE varautoent-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43.88 BY 1.04 NO-UNDO.
DEFINE VARIABLE varautoent-obj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varcar-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Гос. N автоцистерны"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1.13 COL 1.88
     b-cancel AT ROW 1.13 COL 12.38
     B-help AT ROW 1.13 COL 22.88
     varautoent-obj-code AT ROW 2.46 COL 16 COLON-ALIGNED
     varautoent-obj-type AT ROW 2.46 COL 27.75 COLON-ALIGNED NO-LABEL
     varautoent-obj-name AT ROW 2.46 COL 36 COLON-ALIGNED NO-LABEL
     b-clients AT ROW 2.58 COL 34.5
     varcar-num AT ROW 3.75 COL 20 COLON-ALIGNED
     b-auto-tank AT ROW 3.79 COL 36.38
     SPACE(42.49) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация по приемке топлива"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-auto-tank IN FRAME Dialog-Frame
DO:
define variable varrec-tank as recid     no-undo.
define variable varrec-meas as recid     no-undo.
assign varrec-tank = ?
       varrec-meas = ?.
run str/auto-tn.w (input parparentproc,
               input "b-sel",
               input "",
               input 0,
               output varrec-tank,
               output varrec-meas) no-error.
if varrec-tank <> ? then do:
  find first auto-tank where recid (auto-tank) = varrec-tank no-lock.
  assign
      varcar-num = auto-tank.auto-num
  .
  display
      varcar-num
  with frame Dialog-Frame.
end.
END.
ON CHOOSE OF b-clients IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec  as recid     no-undo.
   run ref/cli-all.w (parparentproc
                , "b-sel"
                , 'орг':U
                , ?
                , ?
                , ?
                , ?
                , ?
                , output ref-list) .
if ref-list <> "" then do:
  ref-rec = integer (ref-list).
  find clients where recid ( clients ) = ref-rec no-lock.
  disp clients.obj-code @ varautoent-obj-code
       clients.obj-type @ varautoent-obj-type
       clients.obj-name @ varautoent-obj-name with frame Dialog-Frame.
end.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
  frame Dialog-Frame
      varcar-num
      varautoent-obj-type
      varautoent-obj-code
  .
  find clients where clients.obj-type = varautoent-obj-type and
                     clients.obj-code = varautoent-obj-code no-lock no-error.
  if not available clients then do:
     varlog = no.
     message "Не найдено автопредприятие " varautoent-obj-type " " varautoent-obj-code " ." skip
             "Cохраняемся без ссылки на автопредприятие?"
     view-as alert-box question buttons yes-no update varlog.
     if varlog <> yes then return no-apply.
     assign
     varautoent-obj-type = ""
     varautoent-obj-code = ?.
  end.
  assign
      parcar-num          = varcar-num
      parautoent-obj-type = varautoent-obj-type
      parautoent-obj-code = string(varautoent-obj-code)
  no-error.
END.
ON LEAVE OF varautoent-obj-code IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
END.
ON RETURN OF varautoent-obj-code IN FRAME Dialog-Frame
DO:
run disp-obj-name.
apply "entry" to varautoent-obj-code in frame Dialog-Frame.
return no-apply.
END.
ON LEAVE OF varautoent-obj-type IN FRAME Dialog-Frame
DO:
    run disp-obj-name.
END.
ON return OF varautoent-obj-type IN FRAME Dialog-Frame
DO:
  run disp-obj-name.
  apply "entry" to varcar-num in frame Dialog-Frame.
return no-apply.
END.
ON return OF varcar-num IN FRAME Dialog-Frame
DO:
  apply "entry" to b-save in frame Dialog-Frame.
return no-apply.
END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
assign varcar-num = parcar-num.
assign varautoent-obj-type = parautoent-obj-type.
if varautoent-obj-type = "" then assign varautoent-obj-type = 'орг':U.
assign varautoent-obj-code = integer(parautoent-obj-code) no-error.
if error-status:error then
   message "Неверно указан код клиента " parautoent-obj-code " ."
   view-as alert-box error.
else do:
   find clients where clients.obj-type = varautoent-obj-type and
                      clients.obj-code = varautoent-obj-code no-lock no-error.
   if available clients then assign varautoent-obj-name = clients.obj-name.
   else assign varautoent-obj-name = ?.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  display
      varcar-num
      varautoent-obj-type
      varautoent-obj-code
      varautoent-obj-name
  with frame Dialog-Frame.
  if parmode <> 'ИЗМЕНЕНИЕ':U then
  disable
      varcar-num
      varautoent-obj-type
      varautoent-obj-code
  with frame Dialog-Frame.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-obj-name :
  find clients where clients.obj-code = input frame Dialog-Frame varautoent-obj-code and
                     clients.obj-type = input frame Dialog-Frame varautoent-obj-type no-lock no-error.
  if available clients then
  disp clients.obj-name @ varautoent-obj-name with frame Dialog-Frame.
  else do:
      display ? @ varautoent-obj-name with frame Dialog-Frame.
      apply "choose" to b-clients in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varautoent-obj-code varautoent-obj-type varautoent-obj-name varcar-num
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel B-help varautoent-obj-code varautoent-obj-type
         b-clients varcar-num b-auto-tank
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
