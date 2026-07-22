define input parameter p-mainmenu-handle    as widget-handle    no-undo.
define input parameter p-mode               as integer          no-undo.
define input parameter p-impexp-type        as character        no-undo.
define input parameter p-esys-id            as integer          no-undo.
define input parameter p-db-num             as integer          no-undo.
define input parameter p-id                 as integer          no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "OpenXML. Просмотр и редактирование типа данных внешней подсистемы".
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
DEFINE VARIABLE ed-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62 BY 4.25 NO-UNDO.
DEFINE VARIABLE fi-esys-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Внешняя подсистема"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE fi-status AS INTEGER FORMAT "->>9" INITIAL 0
     LABEL "Статус"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE fi-type-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип данных"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE tg-confirmation AS LOGICAL INITIAL no
     LABEL "Подтверждение"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 55
     fi-esys-name AT ROW 2.25 COL 22 COLON-ALIGNED
     fi-type-name AT ROW 3.5 COL 22 COLON-ALIGNED
     tg-confirmation AT ROW 5 COL 23.5
     fi-status AT ROW 6 COL 21.5 COLON-ALIGNED
     ed-des AT ROW 7.5 COL 2 NO-LABEL
     SPACE(1.13) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип данных для внешней системы"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fi-esys-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       fi-type-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    run check-data in this-procedure.
    assign
        tg-confirmation
        fi-status
        ed-des
    .
    run assign-data in this-procedure.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
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
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
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
END.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-exit :sensitive then DO: apply "CHOOSE":U to b-exit in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-data :
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_esys-datatype-imp     for ub.esys-datatype-imp.
do
for buf_esys-datatype-exp
  , buf_esys-datatype-imp
on error undo, return error
:
    case p-impexp-type
    :
        when 'импорт':U
        then do:
            find first buf_esys-datatype-imp exclusive-lock
                 where buf_esys-datatype-imp.esys-id = p-esys-id
                   and buf_esys-datatype-imp.db-num  = p-db-num
                   and buf_esys-datatype-imp.tdi-id  = p-id
            no-error.
            if not available buf_esys-datatype-imp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            assign
                buf_esys-datatype-imp.edi-confirmation = tg-confirmation
                buf_esys-datatype-imp.edi-status       = fi-status
                buf_esys-datatype-imp.edi-des          = ed-des
            .
        end.
        when 'экспорт':U
        then do:
            find first buf_esys-datatype-exp exclusive-lock
                 where buf_esys-datatype-exp.esys-id = p-esys-id
                   and buf_esys-datatype-exp.db-num  = p-db-num
                   and buf_esys-datatype-exp.dte-id  = p-id
            no-error.
            if not available buf_esys-datatype-exp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            assign
                buf_esys-datatype-exp.ede-confirmation  = tg-confirmation
                buf_esys-datatype-exp.ede-status        = fi-status
                buf_esys-datatype-exp.ede-des           = ed-des
            .
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE check-data :
do
on error undo, return error
:
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-esys-name fi-type-name tg-confirmation fi-status ed-des
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-esys-name fi-type-name tg-confirmation
         fi-status ed-des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-fields :
    define buffer buf_esys-datatype-exp     for ub.esys-datatype-exp.
    define buffer buf_esys-datatype-imp     for ub.esys-datatype-imp.
    define buffer buf_ext-system            for ub.ext-system.
    define buffer buf_datatype-exp          for ub.datatype-exp.
    define buffer buf_datatype-imp          for ub.datatype-imp.
do
for buf_esys-datatype-exp
  , buf_esys-datatype-imp
  , buf_ext-system
  , buf_datatype-exp
  , buf_datatype-imp
with frame Dialog-Frame
on error undo, return error
:
    find first buf_ext-system no-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    case p-impexp-type
    :
        when 'импорт':U
        then do:
            assign
                frame Dialog-Frame :title = frame Dialog-Frame :title + " (импорт)"
            .
            find first buf_esys-datatype-imp exclusive-lock
                 where buf_esys-datatype-imp.esys-id = p-esys-id
                   and buf_esys-datatype-imp.db-num  = p-db-num
                   and buf_esys-datatype-imp.tdi-id  = p-id
            no-error.
            if not available buf_esys-datatype-imp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_datatype-imp no-lock
                 where buf_datatype-imp.dti-id = p-id
            .
            assign
                fi-esys-name    = buf_ext-system.esys-name
                fi-type-name    = buf_datatype-imp.dti-name
                tg-confirmation = buf_esys-datatype-imp.edi-confirmation
                fi-status       = buf_esys-datatype-imp.edi-status
                ed-des          = buf_esys-datatype-imp.edi-des
            .
        end.
        when 'экспорт':U
        then do:
            assign
                frame Dialog-Frame :title = frame Dialog-Frame :title + " (экспорт)"
            .
            find first buf_esys-datatype-exp exclusive-lock
                 where buf_esys-datatype-exp.esys-id = p-esys-id
                   and buf_esys-datatype-exp.db-num  = p-db-num
                   and buf_esys-datatype-exp.dte-id  = p-id
            no-error.
            if not available buf_esys-datatype-exp
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Не найден тип данных внешней системы для редактирования."
                view-as alert-box error.
                undo, return error .
            end.
            find first buf_datatype-exp no-lock
                 where buf_datatype-exp.dte-id = p-id
            .
            assign
                fi-esys-name    = buf_ext-system.esys-name
                fi-type-name    = buf_datatype-exp.dte-name
                tg-confirmation = buf_esys-datatype-exp.ede-confirmation
                fi-status       = buf_esys-datatype-exp.ede-status
                ed-des          = buf_esys-datatype-exp.ede-des
            .
        end.
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Неверно задан тип (может быть только импорт или экспорт)."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE ui-disable-all :
do
with frame Dialog-Frame
on error undo, return error
:
    disable
        all
        except
            b-exit
            b-quit
            b-help
    .
end.
END PROCEDURE.
PROCEDURE ui-enable :
do
with frame Dialog-Frame
on error undo, return error
:
    if p-mode = 1
    then do:
        enable
            tg-confirmation
            fi-status
            ed-des
        .
    end.
    if p-mode = 0
    then do:
        hide
            b-quit
        .
        assign
            b-exit :label = "В&ыход"
        .
    end.
end.
END PROCEDURE.
