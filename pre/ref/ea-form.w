DEFINE BUFFER buf_goods FOR ub.goods.
define input            parameter parParentProc   as handle               no-undo .
define input            parameter p-mode          as character            no-undo .
define input            parameter p-gds-code      like ub.goods.gds-code  no-undo .
define input-output     parameter p-recid         as recid                no-undo .
define input            parameter p-sel-contractor-recid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка внешний артикул".
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
     LABEL "&Выход"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-rest AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON b-units
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY .88.
DEFINE BUTTON b-units-ord
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY .88.
DEFINE BUTTON b-units-rcv
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-units"
     SIZE 3 BY .88.
DEFINE BUTTON r-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-prod"
     SIZE 3 BY .88.
DEFINE VARIABLE ed-ps AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 80.5 BY 5 NO-UNDO.
DEFINE VARIABLE fi-cli-base-rate LIKE ub.ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-cli-base-rate-ord LIKE ub.ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-cli-base-rate-rcv LIKE ub.ext-artic.cli-base-rate
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-ext-artic LIKE ub.ext-artic.ext-artic
     LABEL "Вн. артикул"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE fi-unit-cli AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE fi-unit-cli-ord AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE fi-unit-cli-rcv AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4 .
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.5 BY 1.83.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.5 BY 1.83.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.5 BY 1.83.
DEFINE QUERY Dialog-Frame FOR
      ub.goods,
      ub.clients,
      buf_goods SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-rest AT ROW 1 COL 11 WIDGET-ID 8
     b-help AT ROW 1 COL 21 WIDGET-ID 6
     buf_goods.artic AT ROW 3.04 COL 9.25 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          FGCOLOR 4
     buf_goods.gds-name AT ROW 4 COL 17 COLON-ALIGNED WIDGET-ID 10
          VIEW-AS FILL-IN
          SIZE 64 BY 1
          FGCOLOR 4
     ub.clients.obj-type AT ROW 5 COL 12 COLON-ALIGNED WIDGET-ID 16
          LABEL "Контрагент"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-code AT ROW 5 COL 15.75 COLON-ALIGNED NO-LABEL WIDGET-ID 12
          VIEW-AS FILL-IN
          SIZE 13 BY 1
          BGCOLOR 3 FGCOLOR 15
     ub.clients.obj-name AT ROW 5 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 14
          VIEW-AS FILL-IN
          SIZE 49 BY 1
          BGCOLOR 3 FGCOLOR 15
     fi-ext-artic AT ROW 6 COL 12 COLON-ALIGNED HELP
          "" WIDGET-ID 26
          LABEL "Вн. артикул"
     fi-unit-cli AT ROW 7.75 COL 46.75 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     b-units AT ROW 7.75 COL 56.25 WIDGET-ID 30
     fi-cli-base-rate AT ROW 7.75 COL 70.75 COLON-ALIGNED HELP
          "" WIDGET-ID 34
     fi-unit-cli-ord AT ROW 9.75 COL 46.75 COLON-ALIGNED NO-LABEL WIDGET-ID 44
     b-units-ord AT ROW 9.75 COL 56.25 WIDGET-ID 40
     fi-cli-base-rate-ord AT ROW 9.75 COL 70.75 COLON-ALIGNED HELP
          "" WIDGET-ID 42
     fi-unit-cli-rcv AT ROW 11.75 COL 46.75 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     b-units-rcv AT ROW 11.75 COL 56.25 WIDGET-ID 50
     fi-cli-base-rate-rcv AT ROW 11.75 COL 70.75 COLON-ALIGNED HELP
          "" WIDGET-ID 52
     ed-ps AT ROW 14.38 COL 1.5 NO-LABEL WIDGET-ID 28
     r-prod AT ROW 5 COL 32 WIDGET-ID 18
     "Единица  измерения поставщика в  поставке:" VIEW-AS TEXT
          SIZE 42.5 BY .67 AT ROW 12 COL 3 WIDGET-ID 58
     "Единица  измерения поставщика в накладной:" VIEW-AS TEXT
          SIZE 43.75 BY .67 AT ROW 8 COL 3 WIDGET-ID 36
     "Примечание" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 13.5 COL 2 WIDGET-ID 20
     "Единица  измерения поставщика в заказе:" VIEW-AS TEXT
          SIZE 42 BY .67 AT ROW 10 COL 3 WIDGET-ID 48
     RECT-1 AT ROW 7.5 COL 1.5 WIDGET-ID 38
     RECT-2 AT ROW 9.5 COL 1.5 WIDGET-ID 46
     RECT-3 AT ROW 11.5 COL 1.5 WIDGET-ID 56
     SPACE(0.87) SKIP(6.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Внешний артикул" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  define buffer buf_goods     for ub.goods.
  define buffer cur_ext-artic for ub.ext-artic.
  define variable v-log       as logical                no-undo .
  define variable v-cli-code           like ub.clients.obj-code          no-undo .
  define variable v-cli-type           like ub.clients.obj-type          no-undo .
  define variable v-ext-artic          like ub.ext-artic.ext-artic          no-undo .
  define variable v-ps                 like ub.ext-artic.ps                 no-undo .
  define variable v-unit-cli           like ub.ext-artic.unit-cli           no-undo .
  define variable v-cli-base-rate      like ub.ext-artic.cli-base-rate      no-undo .
  define variable v-unit-cli-ord       like ub.ext-artic.unit-cli-ord       no-undo .
  define variable v-cli-base-rate-ord  like ub.ext-artic.cli-base-rate-ord  no-undo .
  define variable v-unit-cli-rcv       like ub.ext-artic.unit-cli-rcv       no-undo .
  define variable v-cli-base-rate-rcv  like ub.ext-artic.cli-base-rate-rcv  no-undo .
  if p-mode = 'ПРОСМОТР':U then return.
  run chk-client in this-procedure (output v-log).
  if not v-log then do :
    message
      "Неверный контрагент!"
    view-as alert-box error.
    apply "choose":U to r-prod.
    return no-apply.
  end.
  if fi-ext-artic :screen-value = "" then do:
    message
      "Введите внешний артикул!"
    view-as alert-box error.
    apply "entry":u to fi-ext-artic.
    return no-apply.
  end.
  assign
    v-cli-code  = input frame Dialog-Frame ub.clients.obj-code
    v-cli-type  = input frame Dialog-Frame ub.clients.obj-type
    v-ext-artic = fi-ext-artic :screen-value
    v-ps        = ed-ps :screen-value
    v-unit-cli          = fi-unit-cli :screen-value
    v-cli-base-rate     = input frame Dialog-Frame fi-cli-base-rate
    v-unit-cli-ord      = fi-unit-cli-ord :screen-value
    v-cli-base-rate-ord = input frame Dialog-Frame fi-cli-base-rate-ord
    v-unit-cli-rcv      = fi-unit-cli-rcv :screen-value
    v-cli-base-rate-rcv = input frame Dialog-Frame fi-cli-base-rate-rcv
  .
  run check-exist-artic in this-procedure ( input  v-cli-type
                                          , input  v-cli-code
                                          , input  v-ext-artic
                                          , input  p-recid
                                          , output v-log
                                          ) .
  if v-log then return no-apply.
  run ref/extarts.p ( input p-mode
                   , input v-cli-type
                   , input v-cli-code
                   , input p-gds-code
                   , input v-ext-artic
                   , input v-ps
                   , input v-unit-cli
                   , input v-cli-base-rate
                   , input v-unit-cli-ord
                   , input v-cli-base-rate-ord
                   , input v-unit-cli-rcv
                   , input v-cli-base-rate-rcv
                   ) no-error .
  if error-status :error then do :
    message
      return-value skip
      error-status :get-message(1)
    view-as alert-box error.
    return no-apply.
  end.
  find first cur_ext-artic no-lock
    where cur_ext-artic.cli-type = v-cli-type
      and cur_ext-artic.cli-code = v-cli-code
      and cur_ext-artic.gds-code = p-gds-code
  no-error .
  if not available cur_ext-artic then do :
    message
      "Ошибка при сохранении внешнего артикула!" skip
    view-as alert-box error.
  end.
  else do :
    assign
      p-recid = recid( cur_ext-artic )
    .
  end.
END.
ON choose OF b-units IN FRAME Dialog-Frame
do:
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
  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli  = buf_units.unit-name.
  display fi-unit-cli with frame Dialog-Frame.
  apply "entry":U to fi-cli-base-rate .
end.
ON choose OF b-units-ord IN FRAME Dialog-Frame
do:
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
  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-ord  = buf_units.unit-name.
  display fi-unit-cli-ord with frame Dialog-Frame.
  apply "entry":U to fi-cli-base-rate-ord .
end.
ON choose OF b-units-rcv IN FRAME Dialog-Frame
do:
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
  define buffer buf_units for ub.units.
  define variable ref-rec as recid no-undo.
  run ref/units.w (input parparentproc, input yes, output ref-rec).
  if ref-rec = ? then return no-apply.
  find buf_units where recid (buf_units) = ref-rec no-lock.
  assign fi-unit-cli-rcv  = buf_units.unit-name.
  display fi-unit-cli-rcv with frame Dialog-Frame.
  apply "entry":U to fi-cli-base-rate-rcv .
end.
ON leave OF fi-unit-cli IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli with frame Dialog-Frame.
    apply "choose" to b-units.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli.
end.
ON return OF fi-unit-cli IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate in frame Dialog-Frame.
  return no-apply.
end.
ON leave OF fi-unit-cli-ord IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli-ord no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-ord with frame Dialog-Frame.
    apply "choose" to b-units-ord.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli-ord.
end.
ON return OF fi-unit-cli-ord IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate-ord in frame Dialog-Frame.
  return no-apply.
end.
ON leave OF fi-unit-cli-rcv IN FRAME Dialog-Frame
do:
  find ub.units where ub.units.unit-name = input frame Dialog-Frame fi-unit-cli-rcv no-lock no-error.
  if not available ub.units then do:
    message "Неправильная единица измерения поставщика." view-as alert-box.
    display fi-unit-cli-rcv with frame Dialog-Frame.
    apply "choose" to b-units-rcv.
    return no-apply.
  end.
  assign frame Dialog-Frame fi-unit-cli-rcv.
end.
ON return OF fi-unit-cli-rcv IN FRAME Dialog-Frame
do:
  apply "entry" to fi-cli-base-rate-rcv in frame Dialog-Frame.
  return no-apply.
end.
ON LEAVE OF ub.clients.obj-code IN FRAME Dialog-Frame
DO:
  run proc-choose-client in this-procedure no-error .
  if error-status :error then return no-apply.
END.
ON RETURN OF ub.clients.obj-code IN FRAME Dialog-Frame
DO:
  run proc-choose-client in this-procedure no-error .
  if error-status :error then return no-apply.
  apply "entry":u to fi-ext-artic in frame Dialog-Frame.
  return no-apply.
END.
ON RETURN OF ub.clients.obj-type IN FRAME Dialog-Frame
DO:
  apply "ENTRY" to ub.clients.obj-code in frame Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF r-prod IN FRAME Dialog-Frame
DO:
  define variable v-ref-list as character no-undo .
  run ref/cli-all.w ( parParentProc
                    , "b-add,b-sel"
                    , ?
                    , ?
                    , ?
                    , ?
                    , ?
                    , ?
                    , output v-ref-list
                    ) .
  if v-ref-list = "" then do:
    return no-apply.
  end.
  find ub.clients no-lock
    where recid (ub.clients) = integer(v-ref-list)
  no-error .
  if available ub.clients then do :
    display
      ub.clients.obj-type
      ub.clients.obj-code
      ub.clients.obj-name
    with frame Dialog-Frame.
  end.
  else do:
    message
      "Не найден контрагент!"
    view-as alert-box error.
    return no-apply.
  end.
  apply "entry":U to fi-ext-artic.
END.
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
  RUN my-enable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-exist-artic :
define input  parameter p-cli-type  like ub.ext-artic.cli-type  no-undo .
define input  parameter p-cli-code  like ub.ext-artic.cli-code  no-undo .
define input  parameter p-ext-artic like ub.ext-artic.ext-artic no-undo .
define input  parameter p-recid     as recid                    no-undo .
define output parameter p-exist     as logical                  no-undo .
define buffer ea        for ub.ext-artic.
define buffer buf_goods for ub.goods.
define variable v-del as logical   no-undo .
do
on error undo, return error return-value
:
  find first ea no-lock
    where ea.cli-type  = p-cli-type
      and ea.cli-code  = p-cli-code
      and ea.ext-artic = p-ext-artic
      and ea.status_   <> 'удаленные':U
  no-error .
  if available ea then do:
    if recid( ea ) <> p-recid then do:
      find first buf_goods no-lock
        where buf_goods.gds-code = ea.gds-code
      no-error .
      message
        substitute( "Для данного контрагента уже есть товар &1 &2 с таким внешним артикулом"
                  , buf_goods.artic
                  , buf_goods.gds-name
                  )
      view-as alert-box error .
      assign
        p-exist = yes
      .
    end.
    else do:
      assign
        p-exist = no
      .
    end.
  end.
  else do:
    assign
      p-exist = no
    .
  end.
end.
END PROCEDURE.
PROCEDURE chk-client :
define output parameter p-log as logical   no-undo .
define buffer buf_clients for ub.clients.
  find first ub.clients no-lock
    where ub.clients.obj-type = input frame Dialog-Frame ub.clients.obj-type
      and ub.clients.obj-code = input frame Dialog-Frame ub.clients.obj-code
  no-error.
  if available ub.clients then do :
    assign
      p-log = yes
    .
    display
      ub.clients.obj-name
    with frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.goods SHARE-LOCK,       EACH ub.clients WHERE TRUE  SHARE-LOCK,       EACH buf_goods WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fi-ext-artic fi-unit-cli fi-cli-base-rate fi-unit-cli-ord
          fi-cli-base-rate-ord fi-unit-cli-rcv fi-cli-base-rate-rcv ed-ps
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.clients THEN
    DISPLAY ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-rest b-help buf_goods.artic buf_goods.gds-name RECT-1
         ub.clients.obj-type RECT-2 ub.clients.obj-code RECT-3 fi-ext-artic
         fi-unit-cli b-units fi-cli-base-rate fi-unit-cli-ord b-units-ord
         fi-cli-base-rate-ord fi-unit-cli-rcv b-units-rcv fi-cli-base-rate-rcv
         ed-ps r-prod
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE find-clients :
define input  parameter p-recid as recid     no-undo .
define buffer buf_ext-artic for ub.ext-artic.
do
on error undo, return error return-value
:
  find first buf_ext-artic no-lock
    where recid( buf_ext-artic ) = p-recid
  no-error .
  if available buf_ext-artic then do:
    find first ub.clients
      where ub.clients.obj-type = buf_ext-artic.cli-type
        and ub.clients.obj-code = buf_ext-artic.cli-code
        no-error .
    assign
      fi-ext-artic         = buf_ext-artic.ext-artic
      ed-ps                = buf_ext-artic.ps
      fi-unit-cli          = buf_ext-artic.unit-cli
      fi-cli-base-rate     = buf_ext-artic.cli-base-rate
      fi-unit-cli-ord      = buf_ext-artic.unit-cli-ord
      fi-cli-base-rate-ord = buf_ext-artic.cli-base-rate-ord
      fi-unit-cli-rcv      = buf_ext-artic.unit-cli-rcv
      fi-cli-base-rate-rcv = buf_ext-artic.cli-base-rate-rcv
    .
    display
      ub.clients.obj-type
      ub.clients.obj-code
      ub.clients.obj-name
      fi-ext-artic
      fi-unit-cli
      fi-cli-base-rate
      fi-unit-cli-ord
      fi-cli-base-rate-ord
      fi-unit-cli-rcv
      fi-cli-base-rate-rcv
      ed-ps
    with frame Dialog-Frame.
  end.
end.
END PROCEDURE.
PROCEDURE my-enable :
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
  no-error .
  if not available buf_goods then do:
    message "Не найден товар с кодом: " p-gds-code view-as alert-box error .
    return error substitute( "Не найден товар с кодом: &1" , p-gds-code ).
  end.
  case p-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      frame Dialog-Frame:title = "Д О Б А В Л Е Н И Е   внешний артикул для товара артикул: " + buf_goods.artic + "   " + buf_goods.gds-name.
      b-exit:label = "&Ввод".
      assign
        fi-unit-cli          = buf_goods.unit-cli
        fi-cli-base-rate     = buf_goods.cli-base-rate
        fi-unit-cli-ord      = buf_goods.unit-cli
        fi-cli-base-rate-ord = buf_goods.cli-base-rate
        fi-unit-cli-rcv      = buf_goods.unit-cli
        fi-cli-base-rate-rcv = buf_goods.cli-base-rate
      .
      enable
          r-prod
          ub.clients.obj-type
          ub.clients.obj-code
          fi-ext-artic
          fi-unit-cli
          b-units
          fi-cli-base-rate
          fi-unit-cli-ord
          b-units-ord
          fi-cli-base-rate-ord
          fi-unit-cli-rcv
          b-units-rcv
          fi-cli-base-rate-rcv
          ed-PS
      with frame Dialog-Frame.
      display
        fi-unit-cli
        fi-cli-base-rate
        fi-unit-cli-ord
        fi-cli-base-rate-ord
        fi-unit-cli-rcv
        fi-cli-base-rate-rcv
      with frame Dialog-Frame.
      run set-client-by-recid in this-procedure.
    end.
    when 'ПРОСМОТР':U then do:
      frame Dialog-Frame:title = "П Р О С М О Т Р   внешний артикул для товара артикул: " + buf_goods.artic + "   " + buf_goods.gds-name.
      assign
        ed-PS:read-only = yes
        b-rest:visible  = no
      .
      disable
        r-prod
      with frame Dialog-Frame.
      run find-clients in this-procedure  ( input p-recid ) no-error .
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      frame Dialog-Frame:title = "И З М Е Н Е Н И Е   внешний артикул для товара артикул: " + buf_goods.artic + "   " + buf_goods.gds-name.
      b-exit:label = "&Ввод".
      enable
        fi-ext-artic
        ed-PS
        fi-unit-cli
        b-units
        fi-cli-base-rate
        fi-unit-cli-ord
        b-units-ord
        fi-cli-base-rate-ord
        fi-unit-cli-rcv
        b-units-rcv
        fi-cli-base-rate-rcv
      with frame Dialog-Frame.
      assign
        ub.clients.obj-type :read-only = yes
        ub.clients.obj-code :read-only = yes
        ub.clients.obj-name :read-only = yes
      .
      run find-clients in this-procedure  ( input p-recid ) no-error .
    end.
  end case.
  ENABLE
    b-exit
    b-help
    b-rest when p-mode <> 'ПРОСМОТР':U
    ed-PS
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  display
      buf_goods.artic
      buf_goods.gds-name
  with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-choose-client :
do
on error undo, return error return-value
:
  define variable v-log       as logical   no-undo .
  define variable v-ref-list  as character no-undo .
  run chk-client in this-procedure (output v-log).
  if not v-log then do :
    run ref/cli-all.w ( parParentProc
                      , "b-add,b-sel"
                      , ?
                      , ?
                      , ?
                      , ?
                      , ?
                      , ?
                      , output v-ref-list
                      ) .
    if v-ref-list = "" then do:
      return error.
    end.
    find ub.clients no-lock
      where recid (ub.clients) = integer(v-ref-list)
    no-error .
    if available ub.clients then do :
      display
        ub.clients.obj-type
        ub.clients.obj-code
        ub.clients.obj-name
      with frame Dialog-Frame.
    end.
    else do:
      message
        "Не найден контрагент!"
      view-as alert-box error.
      return error.
    end.
  end.
end.
END PROCEDURE.
procedure set-client-by-recid:
    if p-sel-contractor-recid = 0 then return.
    find first ub.clients no-lock
        where recid(ub.clients) = p-sel-contractor-recid
        no-error.
    if avail ub.clients then
        do:
            display
                ub.clients.obj-code
                ub.clients.obj-name
                ub.clients.obj-type
                with frame Dialog-Frame.
            disable
                r-prod
                ub.clients.obj-code
                ub.clients.obj-name
                ub.clients.obj-type
                with frame Dialog-Frame.
        end.
end.
