define input-output parameter p-calc-value    as character no-undo .
define input        parameter p-result-format as character no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Калькулятор".
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
    assign
      p-vss-parameters = substitute('&1|&2',p-calc-value,p-result-format)
    .
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
DEFINE VARIABLE cb-operation AS CHARACTER FORMAT "X(256)":U INITIAL "+"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "+","-","*","/"
     DROP-DOWN-LIST
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-operation-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 54 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-operation-description-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Равняется:"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-operand1 AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 54.13 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-operand2 AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 54.13 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-result AS DECIMAL FORMAT "->>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>>,>>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 54.13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     FILL-IN-operand1 AT ROW 3 COL 12.38 COLON-ALIGNED NO-LABEL
     cb-operation AT ROW 4.25 COL 3 COLON-ALIGNED NO-LABEL
     FILL-IN-operand2 AT ROW 5.5 COL 12.5 COLON-ALIGNED NO-LABEL
     FILL-IN-result AT ROW 7.5 COL 12.5 COLON-ALIGNED NO-LABEL
     fi-operation-description AT ROW 4.5 COL 12.5 COLON-ALIGNED NO-LABEL
     fi-operation-description-2 AT ROW 7.75 COL 2.5 NO-LABEL
     SPACE(70.99) SKIP(1.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Калькулятор"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  define variable v-result-value as character no-undo .
  define variable v-calc-value   as decimal   no-undo .
  assign
    v-calc-value   = decimal(FILL-IN-result :screen-value )
    v-result-value = string(v-calc-value
                           ,p-result-format
                           ) no-error
  .
  if index(v-result-value, '?') > 0
  then do:
    message
      "Рассчитанное значение не может быть присвоено" skip
      "Результат" FILL-IN-result :screen-value skip
      "Формат числа" p-result-format skip
      view-as alert-box error .
    return no-apply .
  end.
  if decimal(entry(1,v-result-value, '%':u)) <> v-calc-value
  then do:
    define variable v-ok as logical   no-undo .
    assign
      v-ok = false
    .
    message
      "Рассчитанное значение" FILL-IN-result :screen-value skip
      "Будет округлено до" v-result-value skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true then do:
      return no-apply .
    end.
  end.
  assign
    p-calc-value = v-result-value
  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON RETURN OF cb-operation IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
  apply 'entry':u to fill-in-operand2 .
  return no-apply .
END.
ON VALUE-CHANGED OF cb-operation IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON ANY-PRINTABLE OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON LEAVE OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON RETURN OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
  apply 'entry':u to cb-operation .
  return no-apply .
END.
ON VALUE-CHANGED OF FILL-IN-operand1 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON ANY-PRINTABLE OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON LEAVE OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
ON RETURN OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
  apply 'go':u to frame Dialog-Frame .
  return no-apply .
END.
ON VALUE-CHANGED OF FILL-IN-operand2 IN FRAME Dialog-Frame
DO:
  run make-operation in this-procedure .
END.
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  do with frame Dialog-Frame:
    assign
      fill-in-operand1 :screen-value = string(decimal(p-calc-value)
                                       , fill-in-operand1 :format
                                       )
    .
  end.
  run make-operation in this-procedure .
  apply 'entry':u to fill-in-operand1 in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-operand1 cb-operation FILL-IN-operand2 FILL-IN-result
          fi-operation-description fi-operation-description-2
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help FILL-IN-operand1 cb-operation FILL-IN-operand2
         fi-operation-description fi-operation-description-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE make-operation :
  do with frame Dialog-Frame:
    case cb-operation :screen-value
    :
      when '+':u then do:
        assign
          fill-in-result :screen-value = string(
                                         decimal(fill-in-operand1 :screen-value)
                                         +
                                         decimal(fill-in-operand2 :screen-value)
                                         , fill-in-operand1 :format
                                         )
          fi-operation-description :screen-value = "ПЛЮС"
        .
      end.
      when '-':u then do:
        assign
          fill-in-result :screen-value = string(
                                         decimal(fill-in-operand1 :screen-value)
                                         -
                                         decimal(fill-in-operand2 :screen-value)
                                         , fill-in-operand1 :format
                                         )
          fi-operation-description :screen-value = "МИНУС"
        .
      end.
      when '*':u then do:
        assign
          fill-in-result :screen-value = string(
                                         decimal(fill-in-operand1 :screen-value)
                                         *
                                         decimal(fill-in-operand2 :screen-value)
                                         , fill-in-operand1 :format
                                         )
          fi-operation-description :screen-value = "УМНОЖИТЬ НА"
        .
      end.
      when '/':u then do:
        assign
          fill-in-result :screen-value = string(
                                        decimal(fill-in-operand1 :screen-value)
                                        /
                                        decimal(fill-in-operand2 :screen-value)
                                        , fill-in-operand1 :format
                                        )
          fi-operation-description :screen-value = "РАЗДЕЛИТЬ НА"
        .
      end.
    end case .
  end.
END PROCEDURE.
