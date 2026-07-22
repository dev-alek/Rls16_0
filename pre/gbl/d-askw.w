define input  parameter p-title               as character no-undo .
define input  parameter p-text                as character no-undo .
define input  parameter p-delimiter           as character no-undo .
define input  parameter p-buttons             as character no-undo .
define input  parameter p-buttons-description as character no-undo .
define input  parameter p-default-button      as integer   no-undo .
define input  parameter p-cancel-button       as integer   no-undo .
define output parameter p-number              as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для задания вопроса и выбора действия".
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
      p-vss-parameters = substitute('&1|&2':u,p-buttons,p-text)
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
define variable mCodeMes    as char no-undo.
if num-entries(p-title,"|") > 1
then
assign
   mCodeMes = entry(2,p-title,"|")
   p-title  = entry(1,p-title,"|")
.
define variable v-buttons    as integer no-undo.
define variable v-need-confirm as logical no-undo extent 5 .
define variable v-first-delimiter  as character no-undo init "|" .
define variable v-second-delimiter as character no-undo init "^" .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_1 AUTO-GO
     LABEL "&1"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_2 AUTO-GO
     LABEL "&2"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_3 AUTO-GO
     LABEL "&3"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_4 AUTO-GO
     LABEL "&4"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_5 AUTO-GO
     LABEL "&5"
     SIZE 15 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE description-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 41 BY 2.29 NO-UNDO.
DEFINE VARIABLE description-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 41 BY 2.29 NO-UNDO.
DEFINE VARIABLE description-3 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 41 BY 2.29 NO-UNDO.
DEFINE VARIABLE description-4 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 41 BY 2.29 NO-UNDO.
DEFINE VARIABLE description-5 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 41 BY 2.29 NO-UNDO.
DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 57.25 BY 4.17
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_1 AT ROW 5.83 COL 3
     Btn_2 AT ROW 8.25 COL 3
     Btn_3 AT ROW 10.67 COL 3
     Btn_4 AT ROW 13.17 COL 3
     Btn_5 AT ROW 16.67 COL 3
     b-help AT ROW 1 COL 60
     EDITOR-1 AT ROW 1.33 COL 3 NO-LABEL
     description-1 AT ROW 5.92 COL 19.25 NO-LABEL
     description-2 AT ROW 8.33 COL 19.25 NO-LABEL
     description-3 AT ROW 10.75 COL 19.25 NO-LABEL
     description-4 AT ROW 13.25 COL 19.25 NO-LABEL
     description-5 AT ROW 16.25 COL 19.25 NO-LABEL
     SPACE(2.99) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Вопрос".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       Btn_1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_3:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_4:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Btn_5:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       description-1:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-2:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-3:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-3:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-4:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-4:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       description-5:HIDDEN IN FRAME Dialog-Frame           = TRUE
       description-5:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  RETURN NO-APPLY .
END.
ON CHOOSE OF Btn_1 IN FRAME Dialog-Frame
DO:
  if v-need-confirm [1] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-1 :visible
       then description-1 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.
  assign
    p-number = 1
  .
END.
ON CHOOSE OF Btn_2 IN FRAME Dialog-Frame
DO:
  if v-need-confirm [2] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-2 :visible
       then description-2 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.
  assign
    p-number = 2
  .
END.
ON CHOOSE OF Btn_3 IN FRAME Dialog-Frame
DO:
  if v-need-confirm [3] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-3 :visible
       then description-3 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.
  assign
    p-number = 3
  .
END.
ON CHOOSE OF Btn_4 IN FRAME Dialog-Frame
DO:
  if v-need-confirm [4] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-4 :visible
       then description-4 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.
  assign
    p-number = 4
  .
END.
ON CHOOSE OF Btn_5 IN FRAME Dialog-Frame
DO:
  if v-need-confirm [5] then do:
    define variable lok as logical no-undo .
    assign
      lok = false
    .
    message
      self :label skip
      "" (if description-5 :visible
       then description-5 :screen-value
       else ""
      ) skip
      "Продолжить?"
      view-as alert-box question buttons yes-no update lok .
    if lok <> true then do:
      return no-apply .
    end.
  end.
  assign
    p-number = 5
  .
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
do with frame Dialog-Frame:
  assign
    frame Dialog-Frame :title = p-title
  .
  if length (p-delimiter) >= 1 then do:
    assign
      v-first-delimiter = substring(p-delimiter, 1, 1)
    .
  end.
  if length (p-delimiter) >= 2 then do:
    assign
      v-second-delimiter = substring(p-delimiter, 2, 1)
    .
  end.
  assign
    v-buttons = num-entries(p-buttons, v-first-delimiter)
    editor-1 = p-text
  .
  if v-buttons > 5 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Количество кнопок больше четырех" skip
      "p-buttons" p-buttons skip
      view-as alert-box .
    undo, return error .
  end.
  if v-buttons <> num-entries(p-buttons-description, v-first-delimiter) then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Количество описаний кнопок не совпадает с количество кнопок" skip
      "Кнопок" v-buttons skip
      "Описаний кнопок" num-entries(p-buttons-description) skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-button-handle             as handle no-undo extent 5 .
  define variable v-button-description-handle as handle no-undo extent 5 .
  assign
    v-button-handle[1]             = Btn_1         :handle
    v-button-handle[2]             = Btn_2         :handle
    v-button-handle[3]             = Btn_3         :handle
    v-button-handle[4]             = Btn_4         :handle
    v-button-handle[5]             = Btn_5         :handle
    v-button-description-handle[1] = description-1 :handle
    v-button-description-handle[2] = description-2 :handle
    v-button-description-handle[3] = description-3 :handle
    v-button-description-handle[4] = description-4 :handle
    v-button-description-handle[5] = description-5 :handle
  .
  define variable v-handle             as handle no-undo .
  define variable v-handle-description as handle no-undo .
  if  p-default-button > 0
  and p-default-button <= v-buttons
  then do:
    assign
      v-handle = v-button-handle[p-default-button]
    .
    assign
      v-handle :default = true
      frame Dialog-Frame :default-button = v-handle
    .
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана кнопка по умолчанию" skip
      "p-default-button" p-default-button skip
      view-as alert-box .
    undo, return error .
  end.
  if  p-cancel-button > 0
  and p-cancel-button <= v-buttons
  then do:
    assign
      v-handle = v-button-handle[p-cancel-button]
    .
    assign
      frame Dialog-Frame :cancel-button = v-handle
    .
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана кнопка выбираемая при нажатии Escape" skip
      "p-cancel-button" p-cancel-button skip
      view-as alert-box .
    undo, return error .
  end.
  if  v-buttons > 1
  and p-cancel-button = p-default-button then do:
    message
      vss-workfile vss-revision vss-description skip
      "Номер кнопки по умолчанию совпадает с номером кнопки выбираемой при нажатии Escape" skip
      "p-default-button" p-default-button skip
      "p-cancel-button"  p-cancel-button  skip
      view-as alert-box .
  end.
  define variable ind as integer no-undo .
  do ind = 1 to v-buttons
  :
    assign
      v-handle             = v-button-handle[ind]
      v-handle-description = v-button-description-handle[ind]
    .
    define variable v-button-text      as character no-undo .
    define variable v-description-text as character no-undo .
    define variable l-sensitive        as logical no-undo .
    define variable l-confirm          as logical no-undo .
    define variable v-btn-text-ind     as integer no-undo .
    assign
      v-button-text      = entry(ind, p-buttons, v-first-delimiter)
      v-description-text = entry(ind, p-buttons-description, v-first-delimiter)
      l-sensitive        = true
      l-confirm          = false
    .
    define variable v-button-attribute as character no-undo .
    do v-btn-text-ind = 2 to num-entries(v-button-text, v-second-delimiter )
    :
      assign
        v-button-attribute = entry(v-btn-text-ind, v-button-text, v-second-delimiter)
      .
      case v-button-attribute :
        when 'disable' then do:
          assign
            l-sensitive = false
          .
        end.
        when 'confirm' then do:
          assign
            l-confirm = true
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный атрибут кнопки" skip
            "Атрибут" v-button-attribute skip
            "Описание кнопки" ind skip
            v-button-text skip
            view-as alert-box error .
        end.
      end case .
    end.
    if num-entries (v-button-text, v-second-delimiter ) >= 1 then do:
      assign
        v-button-text = entry(1, v-button-text, v-second-delimiter)
      .
    end.
    assign
      v-need-confirm [ind] = l-confirm
    .
    assign
      v-handle :label     = v-button-text
      v-handle :visible   = true
      v-handle :sensitive = l-sensitive
    .
    if v-description-text = "" then do:
      assign
        v-handle :width = min(max(v-handle :width
                                 ,length(v-button-text) + 2
                                 )
                             ,frame Dialog-Frame :width - v-handle :column - 1
                             )
      .
    end.
    if v-description-text <> "" then do:
      assign
        v-handle-description :visible      = true
        v-handle-description :sensitive    = true
        v-handle-description :read-only    = true
        v-handle-description :screen-value = v-description-text
      .
    end.
  end.
end.
on cursor-left anywhere do:
  apply "back-tab":u to focus .
end.
on cursor-right anywhere do:
  apply "tab":u to focus .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  def var mAnswer as char no-undo.
  publish "ResponseToQuestion" (output mAnswer ).
  p-number = int (mAnswer) no-error.
  if error-status:error
  then do:
     define variable mbeg as integer no-undo.
     mbeg = index("," + mAnswer   , "," + mcodemes + "=") .
     mAnswer = substring (mAnswer, mbeg + length(mcodemes) + 1).
     mAnswer = entry(1,mAnswer).
     p-number = int (mAnswer) no-error.
     if error-status:error
     then
        block-num:
        do mbeg = 1 to num-entries (mAnswer):
             p-number = int (entry(mbeg, mAnswer)) no-error.
              if not error-status:error
              then
                 leave block-num.
        end.
  end.
  if   p-number eq 0
  then do:
  RUN enable_UI.
  if  p-default-button > 0
  and p-default-button <= v-buttons
  then do:
    assign
      v-handle = v-button-handle[p-default-button]
    .
    apply 'entry':u to v-handle .
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
  end.
END.
RUN disable_UI.
RETURN.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE b-help EDITOR-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
