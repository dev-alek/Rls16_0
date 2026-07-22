define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ сверки".
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE parbrutto-cli-qnty-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Вес жидк."
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1.08 NO-UNDO.
DEFINE VARIABLE parlevel-petrol AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень топлива"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE parlevel-petrol-4 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень водоэмульсионной жидкости"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE parlevel-total AS CHARACTER FORMAT "X(256)":U
     LABEL "Общий уровень в танке"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE parlevel-water AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень воды"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE parmeasure-cli-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "Вес топл."
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1.08 NO-UNDO.
DEFINE VARIABLE parmeasure-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "V топлива"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE parsystem-cli-qnty-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Вес топл.(книж.)"
     VIEW-AS FILL-IN
     SIZE 18.88 BY 1.08 NO-UNDO.
DEFINE VARIABLE parsystem-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "V топлива(книж.)"
     VIEW-AS FILL-IN
     SIZE 19.75 BY 1 NO-UNDO.
DEFINE VARIABLE partemp-layer1 AS CHARACTER FORMAT "X(256)":U
     LABEL "T1"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE partemp-layer2 AS CHARACTER FORMAT "X(256)":U
     LABEL "T2"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE partemp-layer3 AS CHARACTER FORMAT "X(256)":U
     LABEL "T3"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE partemperature AS CHARACTER FORMAT "X(256)":U
     LABEL "T"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE varbrutto-qnty AS CHARACTER FORMAT "X(256)":U
     LABEL "V танка"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE vardensity AS CHARACTER FORMAT "X(256)":U
     LABEL "Плотность"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.75 BY 6.13.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.13 BY 6.13.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varbrutto-qnty AT ROW 2.88 COL 9.5 COLON-ALIGNED
     parmeasure-qnty AT ROW 2.92 COL 31.38
     parsystem-qnty AT ROW 2.96 COL 78.13 COLON-ALIGNED
     vardensity AT ROW 4.33 COL 40.5 COLON-ALIGNED
     parbrutto-cli-qnty-2 AT ROW 5.54 COL 10 COLON-ALIGNED
     parmeasure-cli-qnty AT ROW 5.67 COL 40.38 COLON-ALIGNED
     parsystem-cli-qnty-2 AT ROW 5.75 COL 78.88 COLON-ALIGNED
     partemp-layer1 AT ROW 7.67 COL 16.63
     parlevel-petrol AT ROW 7.71 COL 71.13 COLON-ALIGNED
     parlevel-total AT ROW 9.25 COL 71 COLON-ALIGNED
     partemperature AT ROW 9.58 COL 3.13
     partemp-layer2 AT ROW 9.58 COL 16.63
     parlevel-water AT ROW 10.67 COL 70.88 COLON-ALIGNED
     partemp-layer3 AT ROW 11.63 COL 16.88
     parlevel-petrol-4 AT ROW 12.08 COL 70.88 COLON-ALIGNED
     RECT-1 AT ROW 7.17 COL 1.5
     RECT-2 AT ROW 7.21 COL 32.63
     SPACE(0.36) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ сверки".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varbrutto-qnty parmeasure-qnty parsystem-qnty vardensity
          parbrutto-cli-qnty-2 parmeasure-cli-qnty parsystem-cli-qnty-2
          partemp-layer1 parlevel-petrol parlevel-total partemperature
          partemp-layer2 parlevel-water partemp-layer3 parlevel-petrol-4
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 RECT-2 partemp-layer1 partemperature
         partemp-layer2 partemp-layer3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
