DEFINE BUFFER locked_wealth FOR ub.wealth.
DEFINE BUFFER locked_wth-par FOR ub.wth-par.
DEFINE TEMP-TABLE tt-wth-par NO-UNDO LIKE ub.wth-par.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input param pwth-code like ub.wth-par.wth-code no-undo.
define input param ppar-code like ub.wth-par.par-code no-undo.
define input param par-mode as char no-undo.
define output param p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка номинала материальной ценности ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_units FOR ub.units.
DEFINE BUFFER buf_currency FOR ub.currency.
define buffer buf_wth-gds  for ub.wth-gds.
define buffer buf_goods    for ub.goods.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-unit
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON Bpar-feat
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE Spar-feat AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "Банкнота","Монета"
     SIZE 16.25 BY 1.5 NO-UNDO.
DEFINE VARIABLE Spar-unit AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 15.88 BY 2.04 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-hist AT ROW 1 COL 70
     B-Help AT ROW 1 COL 73
     tt-wth-par.par-val AT ROW 3.83 COL 25.5 COLON-ALIGNED
          LABEL "Номинал"
          VIEW-AS FILL-IN
          SIZE 13.63 BY 1
     tt-wth-par.par-rate AT ROW 5.33 COL 25.5 COLON-ALIGNED
          LABEL "Коэффициент"
          VIEW-AS FILL-IN
          SIZE 13.63 BY 1
     B-unit AT ROW 6.58 COL 44.5
     Spar-unit AT ROW 6.63 COL 27.5 NO-LABEL
     tt-wth-par.par-unit AT ROW 6.63 COL 25.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13.63 BY 1
     tt-wth-par.par-feat AT ROW 8.88 COL 25.5 COLON-ALIGNED
          LABEL "Доп. признак"
          VIEW-AS FILL-IN
          SIZE 15.75 BY 1
     Bpar-feat AT ROW 9.04 COL 44.75
     Spar-feat AT ROW 10.08 COL 27.5 NO-LABEL
     tt-wth-par.wth-code AT ROW 1.08 COL 40.5 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.13 BY 1
          FGCOLOR 4
     locked_wth-par.par-code AT ROW 2.46 COL 40.25 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.5 BY 1
          FGCOLOR 4
     "Код номинала" VIEW-AS TEXT
          SIZE 13.13 BY 1 AT ROW 2.5 COL 28
     "Код МЦ" VIEW-AS TEXT
          SIZE 7.88 BY 1 AT ROW 1.13 COL 28.13
     "Ед. изм.:" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 6.71 COL 15.5
     SPACE(50.49) SKIP(4.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Номинал материальной ценности"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-unit:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Bpar-feat:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-wth-par.par-unit:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Spar-feat:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Spar-unit:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error .
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
    define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  run ref/cwthhist.w (
                   input parparentproc
                 , input ?
                 , input '':U
                 , input 0
                 , input "":U
                 , input "subject":U
                 , input tt-wth-par.wth-code
                 , INPUT tt-wth-par.par-code
                 , input ?
                 , input ?
                 , input ?
                 , input ?
                 , input "":U
                 , input 'wth-par':U
                 , input v-cntxt-db-num
                 , input ?
                 , input ?
                 , input-output v-rid-list
                 ) no-error.
if error-status:error then do:
  message return-value skip
          error-status:get-message(1)
  view-as alert-box.
end.
END.
ON CHOOSE OF B-unit IN FRAME Dialog-Frame
DO:
run ch-units IN THIS-PROCEDURE .
apply "entry" to tt-wth-par.par-unit in frame Dialog-Frame.
END.
ON CHOOSE OF Bpar-feat IN FRAME Dialog-Frame
DO:
  VIEW
  spar-feat
  in frame Dialog-Frame.
  ENABLE
  spar-feat
  with frame Dialog-Frame.
END.
ON LEAVE OF tt-wth-par.par-unit IN FRAME Dialog-Frame
DO:
    if locked_wealth.is-money then do:
        if input frame Dialog-Frame tt-wth-par.par-UNIT <> buf_currency.curr-abbr AND
           input frame Dialog-Frame tt-wth-par.par-UNIT <> buf_currency.part-abbr then do:
           message "Выберите сокр. название валюты или ее дробной части"
           view-as alert-box.
        end.
    end.
    else do:
        if not can-FIND( ub.units where ub.units.unit-name = input frame Dialog-Frame tt-wth-par.par-UNIT )
           then do:
           tt-wth-par.par-unit = "?".
           DISPLAY tt-wth-par.par-unit
           WITH FRAME Dialog-Frame.
           run ch-units IN this-procedure.
        end.
    end.
END.
ON LEAVE OF Spar-feat IN FRAME Dialog-Frame
DO:
    display
  spar-feat:screen-value @ tt-wth-par.par-feat
  with frame Dialog-Frame.
  hide spar-feat
  in frame Dialog-Frame.
END.
ON MOUSE-SELECT-DBLCLICK OF Spar-feat IN FRAME Dialog-Frame
DO:
   display
  spar-feat:screen-value @ tt-wth-par.par-feat
  with frame Dialog-Frame.
  hide spar-feat
  in frame Dialog-Frame.
END.
ON RETURN OF Spar-feat IN FRAME Dialog-Frame
DO:
  display
  spar-feat:screen-value @ tt-wth-par.par-feat
  with frame Dialog-Frame.
  hide spar-feat
  in frame Dialog-Frame.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(par-mode, 'ДОБАВЛЕНИЕ':U + chr(44) +
                      'ИЗМЕНЕНИЕ':U + chr(44) +
                      'ПРОСМОТР':U) = 0 THEN DO:
  message
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
  IF pwth-code = 0  THEN DO:
      run ref/wth-ref.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input 'все':U
                        ,input-output v-rid-list) no-error.
      if v-rid-list = "" then return error.
      find first locked_wealth exclusive-LOCK WHERE
              recid(locked_wealth) = integer(entry(1, v-rid-list)) NO-ERROR.
  END.
  ELSE do:
    FIND FIRST LOCKED_wealth EXCLUSIVE-LOCK WHERE
             LOCKED_wealth.wth-code = pwth-code NO-ERROR.
    IF NOT AVAILABLE LOCKED_wealth THEN DO:
        message vss-workfile vss-revision vss-description skip
        "Не найдена материальная ценность с кодом " pwth-code
        view-as alert-box error.
        return error.
    END.
  END.
  IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    CREATE tt-wth-par.
    assign
    tt-wth-par.wth-code = LOCKED_wealth.wth-code
    .
  END.
  ELSE DO:
     IF par-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST LOCKED_wth-par NO-LOCK WHERE
                LOCKED_wth-par.wth-code = pwth-code
           AND  LOCKED_wth-par.par-code = ppar-code NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-par exclusive-LOCK WHERE
                  LOCKED_wth-par.wth-code = pwth-code
             AND  LOCKED_wth-par.par-code = ppar-code NO-ERROR.
     END.
     IF NOT AVAILABLE LOCKED_wth-par THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    p-rec = recid(Locked_wth-par).
    CREATE tt-wth-par.
    BUFFER-COPY LOCKED_wth-par TO tt-wth-par.
  END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  run Myenable IN THIS-PROCEDURE NO-ERROR.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE ch-units :
define variable ref-rec as recid no-undo .
run ref/units.w ( input parparentproc
                ,input yes
                ,output ref-rec ).
if ref-rec = ? then do:
  apply "entry" to b-unit in frame Dialog-Frame.
  return no-apply.
end.
FIND buf_units WHERE recid (buf_units) = ref-rec NO-LOCK.
DISPLAY
buf_units.unit-name @ tt-wth-par.par-UNIT
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  IF AVAILABLE locked_wth-par THEN
    DISPLAY locked_wth-par.par-code
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-par THEN
    DISPLAY tt-wth-par.par-val tt-wth-par.par-rate tt-wth-par.par-feat
          tt-wth-par.wth-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-wth-par.par-val tt-wth-par.par-rate
         B-unit tt-wth-par.par-feat Bpar-feat tt-wth-par.wth-code
         locked_wth-par.par-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-rid-list as char no-undo.
if locked_wealth.curr-code <> ? then do:
    FIND FIRST buf_currency No-LOCK WHERE
                buf_currency.curr-code = locked_wealth.curr-code NO-ERROR.
    if not avail buf_currency then do:
       message vss-workfile vss-revision vss-description skip
       SUBSTITUTE("Не найдена валюта с кодом &1" +
                   "для материальной ценности с кодом &1"
                  ,locked_wealth.curr-code
                  ,locked_wealth.wth-code)
        view-as alert-box error.
        return error.
    end.
end.
else if not locked_wealth.is-ser = 1 then do:
    FIND FIRST buf_units No-LOCK WHERE
                buf_units.unit-name = locked_wealth.unit-base NO-ERROR.
    if not avail buf_units then do:
       message vss-workfile vss-revision vss-description skip
       substitute("Не найдена единица измерения &1" +
                  "для материальной ценности с кодом &1"
                  ,locked_wealth.unit-base
                  ,locked_wealth.wth-code)
        view-as alert-box error.
        return error.
    end.
end.
ENABLE
B-exit WHEN par-mode <> 'ПРОСМОТР':U
b-quit
B-Help
tt-wth-par.par-val when (par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U)
tt-wth-par.par-rate when ((par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U) and locked_wealth.is-ser = 0 )
tt-wth-par.par-feat when (par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U)
b-hist WHEN par-mode <> 'ДОБАВЛЕНИЕ':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if locked_wealth.is-money = yes then do:
    spar-unit:list-items = buf_currency.curr-abbr + chr(44) + buf_currency.part-abbr.
    view spar-unit
    in frame Dialog-Frame.
    ENABLE
    spar-unit when (par-mode = 'ДОБАВЛЕНИЕ':U  OR par-mode = 'ИЗМЕНЕНИЕ':U)
    bpar-feat when (par-mode = 'ДОБАВЛЕНИЕ':U  OR par-mode = 'ИЗМЕНЕНИЕ':U)
    with frame Dialog-Frame.
end.
else do:
    view
    b-unit
    tt-wth-par.par-unit
    in frame Dialog-Frame.
    ENABLE
    b-unit when ((par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U) and locked_wealth.is-ser = 0 )
    tt-wth-par.par-unit when ((par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U) and locked_wealth.is-ser = 0 )
    with frame Dialog-Frame.
end.
if par-mode = 'ИЗМЕНЕНИЕ':U or par-mode = 'ПРОСМОТР':U then do:
    DISPLAY
    tt-wth-par.wth-code
    locked_wth-par.par-code
    tt-wth-par.par-feat
    tt-wth-par.par-rate
    tt-wth-par.par-val
    WITH FRAME Dialog-Frame  .
    if locked_wealth.is-money = yes then do:
        assign
        spar-unit:screen-value = tt-wth-par.par-unit no-error.
    end.
    else do:
        display
        tt-wth-par.par-unit
        WITH FRAME Dialog-Frame  .
    end.
end.
if par-mode = 'ДОБАВЛЕНИЕ':U then do with frame Dialog-Frame :
    DISPLAY
    tt-wth-par.wth-code
    .
    if NOT locked_wealth.is-money then
    DISPLAY
    locked_wealth.unit-base @ tt-wth-par.par-unit
    .
    if locked_wealth.is-ser = 1 then do:
       tt-wth-par.par-rate:screen-value = '1'.
       for first buf_wth-gds no-lock where buf_wth-gds.wth-code = locked_wealth.wth-code,
           first buf_goods   no-lock where buf_goods.gds-code = buf_wth-gds.gds-code:
           display buf_goods.unit-base @ tt-wth-par.par-unit with frame Dialog-Frame.
           disable  tt-wth-par.par-unit
                    b-unit
           with frame Dialog-Frame.
       end.
    end.
end.
IF par-mode = 'ПРОСМОТР':U THEN DO:
  HIDE
  b-exit IN FRAME Dialog-Frame
  .
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
frame Dialog-Frame:title = substitute("&1 &2 &3"
                                     ,frame Dialog-Frame:title
                                     ,locked_wealth.wth-name
                                     ,par-mode).
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF par-mode = 'ПРОСМОТР':U THEN UNDO, RETURN ERROR.
assign
FRAME Dialog-Frame
tt-wth-par.par-feat
tt-wth-par.par-rate
tt-wth-par.par-unit
tt-wth-par.par-val
Spar-feat
Spar-unit
.
if par-mode = 'ИЗМЕНЕНИЕ':U then v-rec = p-rec.
run ref/wth-par1.p ( INPUT par-mode
                    ,INPUT NO
                    ,INPUT-OUTPUT v-rec
                    ,INPUT tt-wth-par.wth-code
                    ,INPUT tt-wth-par.par-code
                    ,INPUT tt-wth-par.par-val
                    ,INPUT tt-wth-par.par-feat
                    ,INPUT tt-wth-par.par-rate
                    ,INPUT (IF tt-wth-par.par-unit:VISIBLE IN FRAME Dialog-Frame
                            THEN tt-wth-par.par-unit
                            ELSE spar-unit)
                     ) NO-ERROR.
if error-status:error then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.
