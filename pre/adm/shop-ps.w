DEFINE SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE SHARED TEMP-TABLE tt-shop NO-UNDO LIKE ub.shop.
define input  parameter parparentProc as widget-handle no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-obj-code like ub.shop.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибутов магазина".
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE EndTime AS DECIMAL FORMAT "99.99":U INITIAL 20
     LABEL "Окончание"
     VIEW-AS FILL-IN
     SIZE 6.13 BY .92
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE StartTime AS DECIMAL FORMAT "99.99":U INITIAL 8
     LABEL "Начало"
     VIEW-AS FILL-IN
     SIZE 6.38 BY .92
     BGCOLOR 15  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71 BY 4.21.
DEFINE QUERY Dialog-Frame FOR
      tt-shop,
      tt-clients SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     tt-shop.acct AT ROW 2.46 COL 11.13 COLON-ALIGNED
          LABEL "Бухгалтер"
          VIEW-AS FILL-IN
          SIZE 24.5 BY .92
          BGCOLOR 15
     tt-shop.store-boss AT ROW 2.46 COL 50.25 COLON-ALIGNED
          LABEL "Зав. складом"
          VIEW-AS FILL-IN
          SIZE 23 BY .92
          BGCOLOR 15
     tt-shop.goods-man AT ROW 3.46 COL 11.13 COLON-ALIGNED
          LABEL "Товаровед"
          VIEW-AS FILL-IN
          SIZE 24.5 BY .92
          BGCOLOR 15
     tt-shop.store-man AT ROW 3.46 COL 50.25 COLON-ALIGNED
          LABEL "Кладовщик"
          VIEW-AS FILL-IN
          SIZE 23 BY .92
          BGCOLOR 15
     StartTime AT ROW 6.92 COL 13.5
     EndTime AT ROW 6.92 COL 47.75 COLON-ALIGNED
     tt-clients.PS AT ROW 11 COL 2.88 NO-LABEL
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
          SIZE 71 BY 5.33
          BGCOLOR 15
     "Время работы ( при круглосуточной - указывайте : 00.00 и 00.00 ) :" VIEW-AS TEXT
          SIZE 63.75 BY 1 AT ROW 5.33 COL 6.63
          FGCOLOR 4
     "Примечание :" VIEW-AS TEXT
          SIZE 12.5 BY 1 AT ROW 9.63 COL 31.75
          FGCOLOR 4
     RECT-1 AT ROW 4.58 COL 2.88
     SPACE(4.10) SKIP(7.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Дополнительные сведения о магазине":L
         CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    assign
        tt-clients.PS StartTime EndTime
        tt-shop.acct tt-shop.goods-man tt-shop.store-boss tt-shop.store-man
        .
    assign
    tt-shop.Work-hours = string( StartTime, "99.99" ) + "," + string( EndTime, "99.99" ) .
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    find first tt-shop .
    find first tt-clients .
  end.
  else do:
    find first tt-shop no-lock where
                    tt-shop.obj-code = p-obj-code .
    find first tt-clients no-lock where
                    tt-clients.obj-code = p-obj-code
                ANd tt-clients.obj-type = 'маг':U.
  end.
    run Myenable in this-procedure.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY StartTime EndTime
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.PS
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN
    DISPLAY tt-shop.acct tt-shop.store-boss tt-shop.goods-man tt-shop.store-man
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit b-help RECT-1 tt-shop.acct tt-shop.store-boss
         tt-shop.goods-man tt-shop.store-man StartTime EndTime tt-clients.PS
      WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
    assign
        StartTime = decimal( entry( 1, tt-shop.work-hours ) )
        EndTime = decimal( entry( 2, tt-shop.work-hours ) ) .
DISPLAY EndTime StartTime
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-clients THEN
    DISPLAY tt-clients.PS
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-shop THEN
    DISPLAY tt-shop.store-man tt-shop.acct tt-shop.store-boss tt-shop.goods-man
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 tt-clients.PS B-quit EndTime tt-shop.store-man B-exit
         tt-shop.acct tt-shop.store-boss b-help tt-shop.goods-man StartTime
      WITH FRAME Dialog-Frame.
 if p-mode = 'ПРОСМОТР':U then do:
    assign
    tt-clients.PS:read-only = yes
    b-quit:label = "&Выход".
    DISABLE
    B-exit
    StartTime
    EndTime
    tt-shop.acct
    tt-shop.goods-man
    tt-shop.store-boss
    tt-shop.store-man
    WITH FRAME Dialog-Frame.
    hide
    b-exit in frame Dialog-Frame.
  end.
END PROCEDURE.
