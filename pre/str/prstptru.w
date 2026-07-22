DEFINE PARAMETER BUFFER bf_goods FOR ub.goods.
DEFINE PARAMETER BUFFER bf_place FOR ub.place.
DEFINE INPUT  PARAMETER parcalc-petrol-volume AS LOGICAL   NO-UNDO.
DEFINE INPUT  PARAMETER parmode               AS CHARACTER NO-UNDO.
DEFINE INPUT  PARAMETER parwrite-off          AS LOGICAL   NO-UNDO.
DEFINE INPUT  PARAMETER parfact-l             AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parfact-kg            AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwork-l             AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwork-kg            AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwrite-off-doc-l    AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parwrite-off-doc-kg   AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parincome-doc-l       AS DECIMAL   NO-UNDO.
DEFINE INPUT  PARAMETER parincome-doc-kg      AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER parstate              AS LOGICAL   NO-UNDO.
DEFINE OUTPUT PARAMETER parqnty-l             AS DECIMAL   NO-UNDO.
DEFINE OUTPUT PARAMETER parqnty-kg            AS DECIMAL   NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка значений в топливном товаре в пересортице".
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
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE vardensity AS DECIMAL FORMAT "9.9999999999":U INITIAL 0
     LABEL "Плотность"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varfact-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Факт(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varfree-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Свободно(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varincome-doc-kg AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Оприходовано док(кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varincome-doc-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Оприходовано док(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varwork-kg AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Кол-во(кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varwork-l AS DECIMAL FORMAT ">,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Кол-во(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varwrite-off-doc-kg AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Списано док(кг)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE varwrite-off-doc-l AS DECIMAL FORMAT "->,>>>,>>>,>>9.9999":U INITIAL 0
     LABEL "Списано док(л)"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varfact-l AT ROW 2.5 COL 20 COLON-ALIGNED
     varwork-l AT ROW 4 COL 20 COLON-ALIGNED
     vardensity AT ROW 4 COL 46.5 COLON-ALIGNED
     varwork-kg AT ROW 4 COL 78.5 COLON-ALIGNED
     varwrite-off-doc-l AT ROW 5.5 COL 20 COLON-ALIGNED
     varwrite-off-doc-kg AT ROW 5.5 COL 78.5 COLON-ALIGNED
     varincome-doc-l AT ROW 7 COL 20 COLON-ALIGNED
     varincome-doc-kg AT ROW 7 COL 78.5 COLON-ALIGNED
     varfree-l AT ROW 8.5 COL 20 COLON-ALIGNED
     SPACE(59.87) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  IF parcalc-petrol-volume THEN DO:
    IF varwork-l = 0 OR
       varwork-l = ? THEN DO:
      MESSAGE "У Вас не установлено количество в литрах." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO varwork-l IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
    IF vardensity = 0 OR
       vardensity = ? THEN DO:
      MESSAGE "У Вас не установлена плотность." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO vardensity IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    IF varwork-kg = 0 OR
       varwork-kg = ? THEN DO:
      MESSAGE "У Вас не установлено количество в килограммах." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO varwork-kg IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
    IF vardensity = 0 OR
       vardensity = ? THEN DO:
      MESSAGE "У Вас не установлена плотность." VIEW-AS ALERT-BOX ERROR.
      APPLY "entry" TO vardensity IN FRAME Dialog-Frame.
      RETURN NO-APPLY.
    END.
  END.
  ASSIGN
    parstate   = YES
    parqnty-l  = varwork-l
    parqnty-kg = varwork-kg.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\str\prstptru.w" VIEW-AS ALERT-BOX INFORMATION.
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
END.
ON LEAVE OF vardensity IN FRAME Dialog-Frame
DO:
    if keyfunction(lastkey) <> "end-error" and
       not ( last-event :event-type   = "progress":u and
             last-event :widget-enter = b-cancel :handle ) then do:
     IF INPUT FRAME Dialog-Frame vardensity = 0.00 or
        INPUT FRAME Dialog-Frame vardensity = ?    THEN DO:
        MESSAGE "Вы не установили плотность." VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
     END.
     ASSIGN
       FRAME Dialog-Frame vardensity.
     IF parcalc-petrol-volume THEN DO:
       IF varwork-l <> 0.00 AND
          varwork-l <> ?    THEN DO:
         ASSIGN
           varwork-kg = vardensity * varwork-l.
         DISPLAY varwork-kg WITH FRAME Dialog-Frame.
       END.
     END.
     ELSE DO:
       IF varwork-kg <> 0.00 AND
          varwork-kg <> ?    THEN DO:
         ASSIGN
           varwork-l = varwork-kg / vardensity.
         DISPLAY varwork-l WITH FRAME Dialog-Frame.
       END.
     END.
  END.
END.
ON LEAVE OF varwork-kg IN FRAME Dialog-Frame
DO:
    if keyfunction(lastkey) <> "end-error" and
       not ( last-event :event-type   = "progress":u and
             last-event :widget-enter = b-cancel :handle ) then do:
     IF INPUT FRAME Dialog-Frame varwork-kg = 0.00 or
        INPUT FRAME Dialog-Frame varwork-kg = ?    THEN DO:
        MESSAGE "Вы не установили количество в килограммах." VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
     END.
     ASSIGN
       FRAME Dialog-Frame varwork-kg.
     IF vardensity <> 0.00 AND
        vardensity <> ?    THEN DO:
       ASSIGN
         varwork-l = varwork-l / vardensity.
       DISPLAY varwork-l WITH FRAME Dialog-Frame.
     END.
  END.
END.
ON return OF varwork-kg IN FRAME Dialog-Frame
DO:
  APPLY "ENTRY" TO vardensity IN FRAME Dialog-Frame.
END.
ON LEAVE OF varwork-l IN FRAME Dialog-Frame
DO:
  if keyfunction(lastkey) <> "end-error" and
     not ( last-event :event-type   = "progress":u and
           last-event :widget-enter = b-cancel :handle ) then do:
   IF INPUT FRAME Dialog-Frame varwork-l = 0.00 or
      INPUT FRAME Dialog-Frame varwork-l = ?    THEN DO:
      MESSAGE "Вы не установили количество в литрах." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
   END.
   ASSIGN
     FRAME Dialog-Frame varwork-l.
   IF vardensity <> 0.00 AND
      vardensity <> ?    THEN DO:
     ASSIGN
       varwork-kg = vardensity * varwork-l.
     DISPLAY varwork-kg WITH FRAME Dialog-Frame.
   END.
 END.
END.
ON return OF varwork-l IN FRAME Dialog-Frame
DO:
  APPLY "ENTRY" TO vardensity IN FRAME Dialog-Frame.
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
  assign
    frame Dialog-Frame :title = "Товар:  " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + bf_goods.gds-name + " Складское место: " + string(bf_place.pl-code) + "(" + bf_place.loc1 + ")" + " - " + parmode.
  .
  ASSIGN
    varfact-l           = parfact-l
    varwork-l           = parwork-l
    varwork-kg          = parwork-kg
    varwrite-off-doc-l  = parwrite-off-doc-l
    varwrite-off-doc-kg = parwrite-off-doc-kg
    varincome-doc-l     = parincome-doc-l
    varincome-doc-kg    = parincome-doc-kg
    varfree-l           = varfact-l  + (IF parwrite-off THEN - varwork-l  ELSE varwork-l)  - parwrite-off-doc-l  + parincome-doc-l
  .
  IF varwork-l <> 0 AND
     varwork-l <> ? THEN DO:
    ASSIGN
      vardensity = varwork-kg / varwork-l.
  END.
  RUN enable_UI.
  DISPLAY varfact-l  varwork-l varwork-kg varwrite-off-doc-l varwrite-off-doc-kg varincome-doc-l varincome-doc-kg varfree-l  WITH FRAME Dialog-Frame.
  IF parmode = 'ИЗМЕНЕНИЕ':U THEN DO:
    ENABLE b-save vardensity WITH FRAME Dialog-Frame.
    IF parcalc-petrol-volume = YES THEN DO:
      ENABLE varwork-l WITH FRAME Dialog-Frame.
      WAIT-FOR GO OF FRAME Dialog-Frame FOCUS varwork-l.
    END.
    ELSE DO:
      ENABLE varwork-kg WITH FRAME Dialog-Frame.
      WAIT-FOR GO OF FRAME Dialog-Frame FOCUS varwork-kg.
    END.
  END.
  ELSE DO:
    WAIT-FOR GO OF FRAME Dialog-Frame FOCUS b-cancel.
  END.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varfact-l varwork-l vardensity varwork-kg varwrite-off-doc-l
          varwrite-off-doc-kg varincome-doc-l varincome-doc-kg varfree-l
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
