DEFINE TEMP-TABLE tt_trn-reason NO-UNDO LIKE ub.trn-reason.
define input        parameter parParentProc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-rid         as recid         no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Карточка основания (причины) создания документа":U.
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
DEFINE BUTTON b-attr DEFAULT
     LABEL "&Атрибуты"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод "
     SIZE 10 BY 1.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-history DEFAULT
     LABEL "Истори&я"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE QUERY trn-rsna FOR
      tt_trn-reason SCROLLING.
DEFINE FRAME trn-rsna
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-quit AT ROW 1 COL 11 WIDGET-ID 10
     b-attr AT ROW 1 COL 21 WIDGET-ID 2
     b-history AT ROW 1 COL 80.5 WIDGET-ID 8
     b-help AT ROW 1 COL 90.75 WIDGET-ID 6
     tt_trn-reason.reason-code AT ROW 2.25 COL 21.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 15.5 BY 1
     tt_trn-reason.reason-name AT ROW 3.25 COL 2.5 WIDGET-ID 16
          LABEL "Основание (причина)"
          VIEW-AS FILL-IN
          SIZE 77.25 BY 1
     tt_trn-reason.PS AT ROW 4.25 COL 2.5 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR
          SIZE 98.25 BY 3.42
          BGCOLOR 15 FGCOLOR 4
     SPACE(0.62) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>" WIDGET-ID 100.
ASSIGN
       FRAME trn-rsna:SCROLLABLE       = FALSE
       FRAME trn-rsna:HIDDEN           = TRUE.
ASSIGN
       b-attr:HIDDEN IN FRAME trn-rsna           = TRUE.
ON WINDOW-CLOSE OF FRAME trn-rsna
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-attr IN FRAME trn-rsna
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
  run str/trsnatrs.w ( input parParentProc, input p-mode, input tt_trn-reason.reason-code ).
END.
ON CHOOSE OF b-exit IN FRAME trn-rsna
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
  assign
    tt_trn-reason.reason-code
    tt_trn-reason.reason-name
    tt_trn-reason.PS
  .
  run ref/trn-rsn1.p
    ( input-output p-rid
    , input p-mode
    , input no
    , input tt_trn-reason.reason-code
    , input tt_trn-reason.reason-name
    , input tt_trn-reason.PS
    ) no-error.
  if error-status:error then do:
    if return-value = "":U then do:
      return no-apply.
    end.
    case return-value :
      when "reason-code":U then do:
        apply "entry" to tt_trn-reason.reason-code .
      end.
      when "reason-name":u then do:
        apply "entry" to tt_trn-reason.reason-name .
      end.
      when "ps":u then do:
        apply "entry" to tt_trn-reason.ps .
      end.
    end.
    return no-apply.
  end.
END.
ON CHOOSE OF b-history IN FRAME trn-rsna
DO:
  define variable v-list as character no-undo.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run str/trncrsns.w ( input parParentProc, input "":U, input "one":U, input tt_trn-reason.reason-code, input-output v-list ).
END.
ON CHOOSE OF b-quit IN FRAME trn-rsna
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME trn-rsna:PARENT eq ?
THEN FRAME trn-rsna:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame trn-rsna
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
on choose of b-help in frame trn-rsna
do:
  apply "help":u to frame trn-rsna .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame trn-rsna:width - 0.3
                fh            = frame trn-rsna:first-child
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
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame trn-rsna anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame trn-rsna. END.
  return no-apply.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define buffer buf_trn-reason for ub.trn-reason .
  assign
    frame trn-rsna :title = "Карточка основания (причины) создания документа  -- " + p-mode
    .
  create tt_trn-reason .
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    assign
      tt_trn-reason.reason-code = dynamic-next-value( "s-trn-reason":U, "ub":U )
    .
  end.
  else do:
    case p-mode :
      when 'ИЗМЕНЕНИЕ':U then do:
        find first buf_trn-reason exclusive-lock
          where recid( buf_trn-reason ) = p-rid
          no-error .
      end.
      when 'ПРОСМОТР':U then do:
        find first buf_trn-reason no-lock
          where recid( buf_trn-reason ) = p-rid
          no-error.
      end.
    end case.
    if not available buf_trn-reason then do:
      message
        "Карточка основания (причины) создания документа не найдена!"
        view-as alert-box error.
      undo Main-Block, leave Main-Block.
    end.
    else do:
      buffer-copy buf_trn-reason to tt_trn-reason .
    end.
  end.
  RUN enable_UI.
  case p-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      enable
        tt_trn-reason.reason-code
        with frame trn-rsna.
    end.
    when 'ПРОСМОТР':U then do:
      disable
        all
        with frame trn-rsna.
      enable
        b-quit
        b-history
        with frame trn-rsna.
    end.
  end case.
  WAIT-FOR GO OF FRAME trn-rsna.
END.
for each tt_trn-reason
:
  delete tt_trn-reason.
end.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME trn-rsna.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE tt_trn-reason THEN
    DISPLAY tt_trn-reason.reason-code tt_trn-reason.reason-name tt_trn-reason.PS
      WITH FRAME trn-rsna.
  ENABLE b-exit b-quit b-history b-help tt_trn-reason.reason-name
         tt_trn-reason.PS
      WITH FRAME trn-rsna.
  VIEW FRAME trn-rsna.
END PROCEDURE.
