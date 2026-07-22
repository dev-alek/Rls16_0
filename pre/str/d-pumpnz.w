define input  parameter parparentproc as   handle              no-undo .
define input  parameter parobj-type   like ub.clients.obj-type no-undo.
define input  parameter parobj-code   like ub.clients.obj-code no-undo.
define output parameter parrec-id     as   recid initial ?     no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог на добавление пистолета ТРК".
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
define variable varmes-log as logical no-undo.
define variable varobj-type like ub.clients.obj-type no-undo.
define variable varobj-code like ub.clients.obj-code no-undo.
define variable varbuttons  as   character        no-undo.
define variable varps-upd   as   logical          no-undo.
procedure pumpnzav:
define input parameter parobj-type    like ub.clients.obj-type    no-undo.
define input parameter parobj-code    like ub.clients.obj-code    no-undo.
define input parameter parpump-code   like ub.pump.pump-code      no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code  no-undo.
define input parameter paris-meas     like ub.pump-nozzle.is-meas no-undo.
define input parameter paref-nid      like ub.pump-nozzle.ef-nid no-undo.
define buffer bf_clients     for ub.clients.
define buffer bf_pump        for ub.pump.
define buffer bf_nozzle      for ub.nozzle.
define buffer bf_pump-nozzle for ub.pump-nozzle.
define buffer bf_rvs-doc     for ub.rvs-doc.
define buffer bf_icnt-doc    for ub.icnt-doc.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then
   return error SUBSTITUTE("Нет такого объекта &1 &2 .", parobj-type, parobj-code).
find first bf_pump where bf_pump.obj-type  = parobj-type  and
                         bf_pump.obj-code  = parobj-code  and
                         bf_pump.pump-code = parpump-code no-lock no-error.
if not available bf_pump then
   return error SUBSTITUTE("Нет ТРК с номером &1", parpump-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if not available bf_nozzle then
   return error SUBSTITUTE("Нет пистолета ТРК с номером &1", parnozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
 find first bf_rvs-doc where bf_rvs-doc.obj-type =  parobj-type       and
                             bf_rvs-doc.obj-code =  parobj-code       and
                             bf_rvs-doc.status_  <> 'факт':U           and
                             bf_rvs-doc.rvs-type <> 'перед_док':U and
                             bf_rvs-doc.rvs-type <> 'после_док':U  and
                             bf_rvs-doc.rvs-type <> 'проверка':U       no-lock no-error.
if available bf_rvs-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ сверки &1 .", bf_rvs-doc.rvs-code).
end.
find first bf_icnt-doc where bf_icnt-doc.obj-type  =  parobj-type and
                             bf_icnt-doc.obj-code  =  parobj-code and
                             bf_icnt-doc.status_   <> 'факт':U     no-lock no-error.
if available bf_icnt-doc then do:
   return error SUBSTITUTE("На объекте есть открытый документ инвентаризации счетчиков ТРК &1 .", bf_icnt-doc.doc-code).
end.
find first bf_pump-nozzle where bf_pump-nozzle.obj-type    = parobj-type    and
                                bf_pump-nozzle.obj-code    = parobj-code    and
                                bf_pump-nozzle.pump-code   = parpump-code   and
                                bf_pump-nozzle.nozzle-code = parnozzle-code no-lock no-error.
if available bf_pump-nozzle then
             return error SUBSTITUTE ("Уже есть запись ТРК-пистолет с номером ТРК &1 и номером пистолета &2", parpump-code, parnozzle-code) + SUBSTITUTE(" на объекте &1 &2 .", parobj-type, parobj-code).
create bf_pump-nozzle.
assign bf_pump-nozzle.obj-type    = parobj-type
       bf_pump-nozzle.obj-code    = parobj-code
       bf_pump-nozzle.pump-code   = parpump-code
       bf_pump-nozzle.nozzle-code = parnozzle-code
       bf_pump-nozzle.is-meas     = paris-meas
       bf_pump-nozzle.ef-nid      = paref-nid
       .
end procedure.
define variable is-ef-chr as character no-undo .
define variable var-type as character no-undo .
define variable is-ef as logical no-undo .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-nozzle
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-nozzle"
     SIZE 3 BY .87.
DEFINE BUTTON b-pump
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .87.
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE varef-nid AS CHARACTER FORMAT "X(256)":U
     LABEL "Идентиф. EasyFuel"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE varnozzle-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер пистолета ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE varpump-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.
DEFINE VARIABLE varis-meas AS LOGICAL INITIAL yes
     LABEL "Измеряется"
     VIEW-AS TOGGLE-BOX
     SIZE 23.9 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varpump-code AT ROW 2.63 COL 22.1 COLON-ALIGNED
     b-pump AT ROW 2.67 COL 27.8
     varnozzle-code AT ROW 4.2 COL 3.1
     b-nozzle AT ROW 4.2 COL 27.8
     varis-meas AT ROW 5.57 COL 3.5
     varef-nid AT ROW 6.87 COL 18 COLON-ALIGNED WIDGET-ID 2
     SPACE(4.29) SKIP(0.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление  ТРК-пистолет"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-nozzle IN FRAME Dialog-Frame
DO:
  define variable varrec-id_nozzle as recid initial ? no-undo.
  define buffer bf_nozzle for ub.nozzle.
  run str/nozzlerf.w
    ( input  parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_nozzle
    ).
  if varrec-id_nozzle <> ? then do:
     find first bf_nozzle where recid(bf_nozzle) = varrec-id_nozzle no-lock no-error.
     if available bf_nozzle then do:
        display bf_nozzle.nozzle-code @ varnozzle-code with frame Dialog-Frame.
     end.
  end.
END.
ON CHOOSE OF b-pump IN FRAME Dialog-Frame
DO:
  define variable varrec-id_pump as recid initial ? no-undo.
  define buffer bf_pump for ub.pump.
  run str/pumprf.w
    ( input parparentproc
     ,input  parobj-type
     ,input  parobj-code
     ,output varrec-id_pump
    ).
  if varrec-id_pump <> ? then do:
     find first bf_pump where recid(bf_pump) = varrec-id_pump no-lock no-error.
     if available bf_pump then do:
        display bf_pump.pump-code @ varpump-code with frame Dialog-Frame.
     end.
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
  assign frame Dialog-Frame varpump-code varnozzle-code varis-meas.
  if is-ef then do:
  assign
  varef-nid.
  end.
  run pumpnzav in this-procedure ( input parobj-type
                                   ,input parobj-code
                                   ,input varpump-code
                                   ,input varnozzle-code
                                   ,input varis-meas
                                   ,input varef-nid
                      ) no-error.
  if error-status:error then do:
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при создании записи ТРК-пистолет" skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
     return no-apply.
  end.
  find first ub.pump-nozzle where ub.pump-nozzle.obj-type    = parobj-type    and
                               ub.pump-nozzle.obj-code    = parobj-code    and
                               ub.pump-nozzle.pump-code   = varpump-code   and
                               ub.pump-nozzle.nozzle-code = varnozzle-code no-lock.
  assign parrec-id = recid(ub.pump-nozzle).
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
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-ef-chr
  ,output var-type
  ) no-error .
  if NOT error-status:error
  and logical(is-ef-chr) = yes then do:
    is-ef = YES.
  end.
  RUN enable_UI.
  IF NOT is-ef THEN DO:
    HIDE
    varef-nid IN frame Dialog-Frame.
  END.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varpump-code varnozzle-code varis-meas varef-nid
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help varpump-code b-pump varnozzle-code b-nozzle
         varis-meas varef-nid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
