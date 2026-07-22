define input-output  parameter p-gen-marg    as character   no-undo .
define input-output  parameter p-gen-marg-parts  as character   no-undo .
define input-output  parameter p-objfirst    as integer     no-undo .
define input-output  parameter p-objsecond   as integer     no-undo .
define input-output  parameter p-pr-nakl     as logical     no-undo .
define input  parameter p-ext-doc-type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры настройки автопереоценки".
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
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE gen-marg AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет           (No-margin)", "No-margin",
"До прихода    (Before-margin)", "Before-margin",
"После прихода (After-margin)", "After-margin"
     SIZE 32.75 BY 2.5 NO-UNDO.
DEFINE VARIABLE gen-marg-parts AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет           (No-margin)", "No-margin",
"После прихода (After-margin)", "After-margin"
     SIZE 32.75 BY 1.5 NO-UNDO.
DEFINE VARIABLE objfirst AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "только по текущему объекту", 0,
"по всей группе распространения", 1
     SIZE 50 BY 1.96 NO-UNDO.
DEFINE VARIABLE objsecond AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "только по текущему объекту", 0,
"по всей группе распространения", 1
     SIZE 50 BY 1.63 NO-UNDO.
DEFINE VARIABLE pr-nakl AS LOGICAL INITIAL no
     LABEL "Назначать продажную цену прямо в документе прихода"
     VIEW-AS TOGGLE-BOX
     SIZE 56 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 56
     gen-marg AT ROW 3 COL 3.38 NO-LABEL WIDGET-ID 2
     gen-marg-parts AT ROW 6.75 COL 3.38 NO-LABEL WIDGET-ID 22
     objfirst AT ROW 9.29 COL 3.38 NO-LABEL WIDGET-ID 10
     objsecond AT ROW 12.88 COL 3.38 NO-LABEL WIDGET-ID 14
     pr-nakl AT ROW 15.92 COL 3.38 WIDGET-ID 20
     "Тип автопереоценки" VIEW-AS TEXT
          SIZE 19 BY .67 AT ROW 2.25 COL 2 WIDGET-ID 6
          FGCOLOR 4
     "Способ формирования автопереоценки по новому товару" VIEW-AS TEXT
          SIZE 52 BY .67 AT ROW 8.54 COL 2 WIDGET-ID 8
          FGCOLOR 4
     "Способ формирования автопереоценки по НЕ новому товару" VIEW-AS TEXT
          SIZE 59 BY .67 AT ROW 12.13 COL 2 WIDGET-ID 18
          FGCOLOR 4
     "Автопереоценка по ПАРТИЯМ " VIEW-AS TEXT
          SIZE 28.5 BY .67 AT ROW 6 COL 2 WIDGET-ID 26
          FGCOLOR 4
     SPACE(36.99) SKIP(12.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-OK IN FRAME Dialog-Frame
DO:
  assign
    gen-marg
    gen-marg-parts
    objfirst
    objsecond
    pr-nakl
    .
  assign
    p-gen-marg       = gen-marg
    p-gen-marg-parts = gen-marg-parts
    p-objfirst       = objfirst
    p-objsecond      = objsecond
    p-pr-nakl        = pr-nakl
    .
END.
ON VALUE-CHANGED OF gen-marg IN FRAME Dialog-Frame
DO:
assign gen-marg .
  if gen-marg <> 'before-margin':U then do:
    hide pr-nakl .
  end.
  else do:
    display pr-nakl with frame Dialog-Frame.
  end.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
   assign
   gen-marg:radio-buttons in frame Dialog-Frame =
   "Нет           (No-margin)" + chr(44) +  'no-margin':U + chr(44) +
   "До прихода    (Before-margin)" + chr(44) +  'before-margin':U + chr(44) +
   "После прихода (After-margin)"  + chr(44) +  'after-margin':U
   .
   assign
   gen-marg-parts:radio-buttons in frame Dialog-Frame =
   "Нет           (No-margin)" + chr(44) + 'no-margin':U + chr(44) +
   "После прихода (After-margin)" + chr(44) + 'after-margin':U
   .
    assign
      gen-marg       = p-gen-marg
      gen-marg-parts = p-gen-marg-parts
      objfirst       = p-objfirst
      objsecond      = p-objsecond
      pr-nakl        = p-pr-nakl
      .
   assign frame Dialog-Frame:title = "Параметры настройки автопереоценки по " +
          entry( lookup( p-ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
          .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY gen-marg gen-marg-parts objfirst objsecond pr-nakl
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help gen-marg gen-marg-parts objfirst objsecond
         pr-nakl
      WITH FRAME Dialog-Frame.
  assign gen-marg.
  if gen-marg <> 'before-margin':U then do:
    hide pr-nakl .
  end.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
