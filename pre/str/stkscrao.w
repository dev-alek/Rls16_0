define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define temp-table tt-usrstko no-undo
field user-name     as   character
field obj-type      like ub.clients.obj-type
field obj-code      like ub.clients.obj-code
field obj-name      like ub.clients.obj-name
field main-obj-type like ub.clients.obj-type
field main-obj-code like ub.clients.obj-code
field main-obj-name like ub.clients.obj-name
field level         as   integer
field host-code     like ub.clients.obj-code
field host-name     like ub.clients.obj-name
field db-num        like ub.db.db-num
index pi is unique primary user-name obj-type obj-code
index level is unique user-name level.
PROCEDURE loadusr-tt :
define input parameter paruser-name as character no-undo.
define buffer bf_clients      for ub.clients.
define buffer bf_main-clients for ub.clients.
define buffer bf_usr-flt      for ubflt.usr-flt.
define buffer bf_shop         for ub.shop.
define buffer bf_store        for ub.store.
define buffer bf_host-clients for ub.clients.
define buffer bf_db           for ub.db.
for each tt-usrstko:
  delete tt-usrstko.
end.
for each bf_usr-flt where bf_usr-flt.user-name  = paruser-name     and
                          bf_usr-flt.call-point begins "stockscr"   :
  create tt-usrstko.
  assign
    tt-usrstko.user-name    = paruser-name
    tt-usrstko.obj-type      = substring(bf_usr-flt.call-point, 9, 3)
    tt-usrstko.obj-code      = integer(substring(bf_usr-flt.call-point, 12))
    tt-usrstko.level         = integer(entry(1, bf_usr-flt.naim))
    tt-usrstko.main-obj-type = substring(bf_usr-flt.list_, 1, 3)
    tt-usrstko.main-obj-code = integer(substring(bf_usr-flt.list_, 4)).
  if tt-usrstko.main-obj-code <> ? then do:
    find first bf_main-clients where bf_main-clients.obj-type = tt-usrstko.main-obj-type and
                                     bf_main-clients.obj-code = tt-usrstko.main-obj-code no-lock.
    assign
      tt-usrstko.main-obj-name = bf_main-clients.obj-name.
  end.
  if tt-usrstko.obj-type = 'маг':U then do:
    find first bf_shop where bf_shop.obj-code = tt-usrstko.obj-code no-lock.
    find first bf_host-clients where bf_host-clients.obj-type = 'орг':U and
                                     bf_host-clients.obj-code =  bf_shop.host-code no-lock.
  end.
  else do:
    find first bf_store where bf_store.obj-code = tt-usrstko.obj-code no-lock.
    find first bf_host-clients where bf_host-clients.obj-type = 'орг':U             and
                                     bf_host-clients.obj-code = bf_store.host-code no-lock.
  end.
  assign
    tt-usrstko.host-code = bf_host-clients.obj-code
    tt-usrstko.host-name = bf_host-clients.obj-name.
  find first bf_clients where bf_clients.obj-type = tt-usrstko.obj-type and
                              bf_clients.obj-code = tt-usrstko.obj-code no-lock.
  find first bf_db where bf_db.db-num = bf_clients.db-num no-lock.
  assign
    tt-usrstko.obj-name = bf_clients.obj-name
    tt-usrstko.db-num   = bf_db.db-num.
end.
END PROCEDURE.
define input parameter paruser-name as character no-undo.
define input parameter parmode as character no-undo.
define output parameter paradd as logical no-undo.
define input-output parameter parobj-type like ub.clients.obj-type no-undo.
define input-output parameter parobj-code like ub.clients.obj-code no-undo.
define input-output parameter table for tt-usrstko.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран добавления объекта для экрана продавца".
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
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mobj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-mobj"
     SIZE 3 BY .88.
DEFINE BUTTON b-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-obj"
     SIZE 3 BY .88.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varmain-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL ?
     LABEL "Гл. объект"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varmain-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 10.13 BY 1 NO-UNDO.
DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1.08 COL 1.63
     b-cancel AT ROW 1.08 COL 12.13
     b-help AT ROW 1.08 COL 22.5
     varobj-code AT ROW 2.5 COL 12 COLON-ALIGNED
     varobj-type AT ROW 2.5 COL 25.25 NO-LABEL
     b-obj AT ROW 2.63 COL 29.5
          varmain-obj-code AT ROW 3.67 COL 12 COLON-ALIGNED
     varmain-obj-type AT ROW 3.67 COL 25.25 NO-LABEL
     b-mobj AT ROW 3.75 COL 29.63
     SPACE(0.36) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Объект в экране остатков"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-mobj IN FRAME Dialog-Frame
DO:
    run str/chshobj.w (input ?,
                   input varmain-obj-type,
                   input varmain-obj-code,
                   output varmain-obj-type,
                   output varmain-obj-code).
   display varmain-obj-type varmain-obj-code with frame Dialog-Frame.
END.
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO:
  run str/chshobj.w (input ?,
                 input varobj-type,
                 input varobj-code,
                 output varobj-type,
                 output varobj-code).
   display varobj-type varobj-code with frame Dialog-Frame.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
define buffer bf_tt-usrstko   for tt-usrstko.
define buffer bf_clients      for ub.clients.
define buffer bf-main_clients for ub.clients.
define buffer bf_usr-flt      for ubflt.usr-flt.
  if parmode = 'ДОБАВЛЕНИЕ':U then do:
    run chk-obj in this-procedure no-error.
    if error-status:error then do:
      message "Ошибка при проверке объекта." view-as alert-box.
      return no-apply.
    end.
  end.
  run chk-main-obj in this-procedure ( input parmode )no-error.
  if error-status:error then do:
    message "Ошибка при проверке главного объекта." view-as alert-box.
    return no-apply.
  end.
  if parmode = 'ДОБАВЛЕНИЕ':U then do:
    create tt-usrstko.
    assign
      tt-usrstko.user-name = paruser-name.
    find last bf_tt-usrstko where bf_tt-usrstko.user-name = paruser-name use-index level no-error.
    if available bf_tt-usrstko then do:
      assign
        tt-usrstko.level = bf_tt-usrstko.level + 1.
     end.
     else do:
       assign tt-usrstko.level = 1.
     end.
     find first bf_clients where bf_clients.obj-type = varobj-type and
                                 bf_clients.obj-code = varobj-code no-lock.
     assign
      tt-usrstko.user-name     = paruser-name
      tt-usrstko.obj-type      = varobj-type
      tt-usrstko.obj-code      = varobj-code
      tt-usrstko.obj-name      = bf_clients.obj-name.
     create bf_usr-flt.
     assign
       bf_usr-flt.user-name  = paruser-name
       bf_usr-flt.call-point = "stockscr" + tt-usrstko.obj-type + string(tt-usrstko.obj-code)
       bf_usr-flt.naim       = string(tt-usrstko.level).
   end.
   else do:
     find first tt-usrstko where tt-usrstko.user-name = paruser-name and
                                 tt-usrstko.obj-type  = varobj-type  and
                                 tt-usrstko.obj-code  = varobj-code  .
     find first bf_usr-flt where bf_usr-flt.user-name  = paruser-name and
                                 bf_usr-flt.call-point = "stockscr" + tt-usrstko.obj-type + string(tt-usrstko.obj-code).
   end.
   if varmain-obj-code <> ? then do:
     find first bf-main_clients where bf-main_clients.obj-type = varmain-obj-type and
                                      bf-main_clients.obj-code = varmain-obj-code no-lock.
   end.
   assign
     tt-usrstko.main-obj-type = varmain-obj-type
     tt-usrstko.main-obj-code = varmain-obj-code
     tt-usrstko.main-obj-name = (if varmain-obj-code <> ? then bf-main_clients.obj-name else "")
     paradd                   = yes
     parobj-type              = tt-usrstko.obj-type
     parobj-code              = tt-usrstko.obj-code.
     bf_usr-flt.list_         = tt-usrstko.main-obj-type         + string(tt-usrstko.main-obj-code).
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
  if parmode = 'ИЗМЕНЕНИЕ':U   then do:
    find first tt-usrstko where tt-usrstko.user-name = paruser-name and
                                tt-usrstko.obj-type = parobj-type and
                                tt-usrstko.obj-code = parobj-code.
    assign
       varobj-type      = tt-usrstko.obj-type
       varobj-code      = tt-usrstko.obj-code
       varmain-obj-type = tt-usrstko.main-obj-type
       varmain-obj-code = tt-usrstko.main-obj-code.
  end.
  RUN enable_UI.
  if parmode = 'ДОБАВЛЕНИЕ':U then do:
    enable varobj-type varobj-code with frame Dialog-Frame.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE chk-main-obj :
define input parameter parmode as character no-undo .
define buffer bf_clients for ub.clients.
define buffer bf_tt-usrstko for tt-usrstko.
assign frame Dialog-Frame varmain-obj-type varmain-obj-code.
if varmain-obj-type = varobj-type and
   varmain-obj-code = varobj-code then do:
  message "Главный объект равен текущему. " view-as alert-box error.
  return error.
end.
if varmain-obj-type <> "" or
   varmain-obj-code <> ? then do:
  find first bf_clients where bf_clients.obj-type = varmain-obj-type and
                                       bf_clients.obj-code = varmain-obj-code no-lock no-error.
  if not available bf_clients then do:
    message "Нет такого главного объекта: " varmain-obj-type " " varmain-obj-code " ." view-as alert-box.
    return error.
  end.
  if varmain-obj-type <> 'маг':U  and
     varmain-obj-type <> 'скл':U then do:
     message "Неверно задан тип главного объекта. Объект должен быть складом или магазином." view-as alert-box.
     return error.
  end.
  if parmode <> 'ДОБАВЛЕНИЕ':U then do:
    find first bf_tt-usrstko where bf_tt-usrstko.user-name = paruser-name and
                                  bf_tt-usrstko.obj-type = varmain-obj-type and
                                  bf_tt-usrstko.obj-code = varmain-obj-code no-error.
    if not available bf_tt-usrstko then do:
      message "Нет записи о главном объекте в настройках данного пользователя. Сначала надо добавить главный объект."
      view-as alert-box.
      return error.
    end.
    if bf_tt-usrstko.main-obj-code <> ? then do:
      message "Нельзя выбирать главный объект который сам является подчиненным." view-as alert-box.
      return error.
    end.
  end.
end.
END PROCEDURE.
PROCEDURE chk-obj :
define buffer bf_clients for ub.clients.
assign frame Dialog-Frame varobj-type varobj-code.
find first bf_clients where bf_clients.obj-type = varobj-type and
                            bf_clients.obj-code = varobj-code no-lock no-error.
if not available bf_clients then do:
  message "Нет такого объекта: " varobj-type " " varobj-code " ." view-as alert-box.
  return error.
end.
find first tt-usrstko where tt-usrstko.obj-type = varobj-type and
                            tt-usrstko.obj-code = varobj-code no-error.
if available tt-usrstko then do:
  message "У Вас уже есть настроеный объект " varobj-type " " varobj-code view-as alert-box error.
  return error.
end.
if varobj-type <> 'маг':U  and
   varobj-type <> 'скл':U then do:
   message "Неверно задан тип объекта. Объект должен быть складом или магазином." view-as alert-box.
   return error.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varobj-code varobj-type varmain-obj-code varmain-obj-type
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help b-obj varmain-obj-code varmain-obj-type b-mobj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
