DEFINE TEMP-TABLE tt-wealth NO-UNDO LIKE ub.wealth.
DEFINE TEMP-TABLE tt-wth-gds NO-UNDO LIKE ub.wth-gds.
define input parameter parparentproc as widget-handle no-undo .
define input parameter pwth-code as integer no-undo.
define input parameter par-mode as character no-undo.
define output PARAMETER p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка материальной ценности ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
DEF TEMP-TABLE tt-gds NO-UNDO
    FIELD gds-code LIKE ub.goods.gds-code.
DEF BUFFER LOCKED_wealth FOR ub.wealth.
DEF BUFFER LOCKED_wth-gds FOR ub.wth-gds.
define variable ser-wth  as logical   no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.
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
DEFINE VARIABLE fcurr-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.88 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Опред. кол-ва"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE QUERY BR-wth-gds FOR
      tt-wth-gds,
      ub.goods SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-wealth SCROLLING.
DEFINE BROWSE BR-wth-gds
  QUERY BR-wth-gds NO-LOCK DISPLAY
      ub.goods.artic FORMAT "X(16)":U WIDTH 12
      ub.goods.prod-type FORMAT "X(3)":U
      ub.goods.prod-code FORMAT ">>>>>>>>9":U
      ub.goods.gds-name FORMAT "X(30)":U WIDTH 36.25
    WITH NO-ROW-MARKERS SEPARATORS SIZE 68.5 BY 3.25 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-wealth.wth-name AT ROW 2.42 COL 1.88
          LABEL "Название" FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 41.38 BY 1
     tt-wealth.is-money AT ROW 2.42 COL 55.25
          LABEL "Деньги или денежный эквивалент"
          VIEW-AS TOGGLE-BOX
          SIZE 33.13 BY 1
     tt-wealth.curr-code AT ROW 3.75 COL 10 COLON-ALIGNED
          LABEL "Валюта" FORMAT ">>9"
          VIEW-AS FILL-IN
          SIZE 5.13 BY .96
     tt-wealth.unit-base AT ROW 3.75 COL 42.75 COLON-ALIGNED
          LABEL "Ед.изм"
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     B-unit AT ROW 3.79 COL 51.13
     B-curr AT ROW 3.83 COL 17.75
     FILL-IN-1 AT ROW 5 COL 1.5 NO-LABEL WIDGET-ID 16
     tt-wealth.get-qnty-method AT ROW 5 COL 19 NO-LABEL WIDGET-ID 12
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
          SIZE 72.5 BY 3.5 TOOLTIP "Как определить кол-во МЦ по ее сумме и пр."
     tt-wealth.is-ser AT ROW 8.75 COL 10 COLON-ALIGNED WIDGET-ID 10
          LABEL "Серийная" FORMAT "9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Нет",0,
                     "Да",1
          DROP-DOWN-LIST
          SIZE 7 BY 1
     BR-wth-gds AT ROW 8.75 COL 22.5 WIDGET-ID 100
     b-add AT ROW 12 COL 22.5 WIDGET-ID 4
     b-chg AT ROW 12 COL 32.5 WIDGET-ID 8
     b-del AT ROW 12 COL 42.5 WIDGET-ID 6
     tt-wealth.PS AT ROW 13 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 97.63 BY 1.71
     tt-wealth.wth-code AT ROW 1.08 COL 28.5 COLON-ALIGNED NO-LABEL FORMAT "999999999"
           VIEW-AS TEXT
          SIZE 13 BY 1
          FGCOLOR 4
     fcurr-abbr AT ROW 3.92 COL 20.63 COLON-ALIGNED NO-LABEL
     "Код" VIEW-AS TEXT
          SIZE 6.13 BY 1.08 AT ROW 1 COL 22.88
     SPACE(69.98) SKIP(12.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Материальная ценность"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       BR-wth-gds:HIDDEN  IN FRAME Dialog-Frame                = TRUE.
ASSIGN
       tt-wealth.is-ser:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error .
  if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
    EMPTY TEMP-TABLE tt-gds.
    run str/sel-gds.w (parparentproc, INPUT-OUTPUT table tt-gds ).
    for each tt-gds:
      create tt-wth-gds  .
      assign tt-wth-gds.gds-code = tt-gds.gds-code.
    end.
    OPEN QUERY BR-wth-gds FOR EACH tt-wth-gds       WHERE tt-wth-gds.stts = 0 NO-LOCK,       EACH ub.goods WHERE TRUE        AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION.
    run GdsEnable.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
    IF NOT AVAILABLE tt-wth-gds THEN DO:
        MESSAGE 'Неправильно выбрана строка'
            VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
    END.
    EMPTY TEMP-TABLE tt-gds.
    CREATE tt-gds.
    tt-gds.gds-code = tt-wth-gds.gds-code.
    RELEASE tt-gds.
    run str/sel-gds.w (parparentproc, INPUT-OUTPUT table tt-gds ).
    for FIRST tt-gds:
      assign tt-wth-gds.gds-code = tt-gds.gds-code.
    end.
    OPEN QUERY BR-wth-gds FOR EACH tt-wth-gds       WHERE tt-wth-gds.stts = 0 NO-LOCK,       EACH ub.goods WHERE TRUE        AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION.
    run GdsEnable.
END.
ON CHOOSE OF B-curr IN FRAME Dialog-Frame
DO:
define variable rr as recid no-undo.
    rr = ? .
    run ref/currency.w (input parparentproc, "b-sel", input-output rr ).
    if rr <> ? then do:
        FIND FIRST ub.currency WHERE
             recid( ub.currency ) = rr NO-LOCK .
        DISPLAY
        ub.currency.curr-code @ tt-wealth.curr-code
        ub.currency.curr-abbr @ fcurr-abbr
        with frame Dialog-Frame .
    end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable del-rec as recid no-undo.
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
define buffer buf_wealth for ub.wealth.
if not available tt-wth-gds then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
rep-rec = recid (tt-wth-gds).
glog = no.
FIND FIRST tt-wth-gds WHERE recid (tt-wth-gds) = rep-rec.
if tt-wth-gds.stts <> 0 then do:
    glog = no.
    message
    SUBSTITUTE('Товар с кодом &1 уже удален.~nВосстановить?',tt-wth-gds.gds-code)
    view-as alert-box question buttons Yes-No update glog.
    if not glog then do:
      apply "entry" to br-wth-gds in frame Dialog-Frame.
      return no-apply.
    end.
    assign
    tt-wth-gds.stts = 0
    .
    BR-wth-gds:REFRESH() NO-ERROR.
end.
else do:
      glog = no.
      MESSAGE SUBSTITUTE('Удалить товар с кодом &1 из списка~nВы уверены?',tt-wth-gds.gds-code)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        apply "entry" to BR-wth-gds in frame Dialog-Frame.
        return no-apply.
      end.
      delete   tt-wth-gds.
    OPEN QUERY BR-wth-gds FOR EACH tt-wth-gds       WHERE tt-wth-gds.stts = 0 NO-LOCK,       EACH ub.goods WHERE TRUE        AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION.
    run GdsEnable.
 end.
 apply "entry" to BR-wth-gds in frame Dialog-Frame.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  run ref/cwthhist.w (
                   input        parparentproc
                 , input        ?
                 , input        '':U
                 , input        0
                 , input        "":U
                 , input        "subject":U
                 , input        tt-wealth.wth-code
                 , INPUT        0
                 , input        ?
                 , input        ?
                 , input        ?
                 , input        ?
                 , input        "":U
                 , input        'wealth':U
                 , input        v-cntxt-db-num
                 , input ?
                 , input ?
                 , input-output v-rid-list
                 ) no-error .
if error-status:error then do:
  message return-value skip
          error-status:get-message(1)
  view-as alert-box.
end.
END.
ON CHOOSE OF B-unit IN FRAME Dialog-Frame
DO:
    run ch-units.
    apply "entry" to tt-wealth.unit-base in frame Dialog-Frame.
END.
ON LEAVE OF tt-wealth.curr-code IN FRAME Dialog-Frame
DO:
  assign
  tt-wealth.curr-code.
  if tt-wealth.is-money = yes and tt-wealth.curr-code = ? then do:
    message "Для материальных ценностей - денежных средств или имеющих денежный эквивалент" skip
            "необходимо ввести код валюты"
    view-as alert-box ERROR.
    return no-apply.
  end.
  if tt-wealth.curr-code <> ? then do:
    FIND FIRST ub.currency WHERE
               ub.currency.curr-code = tt-wealth.curr-code NO-LOCK .
    if not avail ub.currency then do:
        message "Не найдена валюта с кодом " tt-wealth.curr-code skip
        view-as alert-box ERROR.
        return no-apply.
    end.
    DISPLAY
    ub.currency.curr-code @ tt-wealth.curr-code
    ub.currency.curr-abbr @ fcurr-abbr
    with frame Dialog-Frame .
  end.
END.
ON VALUE-CHANGED OF tt-wealth.is-money IN FRAME Dialog-Frame
DO:
  assign
  tt-wealth.is-money.
  if tt-wealth.is-money = yes then do:
    ENABLE
    tt-wealth.curr-code
    b-curr
    with frame Dialog-Frame.
    DISABLE
    tt-wealth.unit-base
    b-unit
    tt-wealth.is-ser
    with frame Dialog-Frame.
  end.
  else do:
    display
    ? @ tt-wealth.curr-code
    "" @ fcurr-abbr
    with frame Dialog-Frame.
    DISABLE
    tt-wealth.curr-code
    b-curr
    with frame Dialog-Frame.
    ENABLE
    tt-wealth.unit-base
    b-unit
    tt-wealth.is-ser WHEN ser-wth
    with frame Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF tt-wealth.is-ser IN FRAME Dialog-Frame
DO:
  ASSIGN tt-wealth.is-ser.
  IF tt-wealth.is-ser = 1 THEN DO:
    DISABLE tt-wealth.is-money
            tt-wealth.curr-code
            b-curr
    WITH FRAME Dialog-Frame.
  END.
  ELSE IF tt-wealth.is-ser = 0 THEN DO:
    ENABLE tt-wealth.is-money tt-wealth.curr-code b-curr WITH FRAME Dialog-Frame.
    APPLY "VALUE-CHANGED":U TO tt-wealth.is-money.
  END.
  run gdsEnable.
END.
ON LEAVE OF tt-wealth.unit-base IN FRAME Dialog-Frame
DO:
    if not can-FIND( ub.units where ub.units.unit-name = input frame Dialog-Frame tt-wealth.unit-base )
     then do:
     tt-wealth.unit-base = "?".
     DISPLAY tt-wealth.unit-base WITH FRAME Dialog-Frame.
     run ch-units.
   end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-wth-gds :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 IF lookup(par-mode, 'ДОБАВЛЕНИЕ':U + chr(44) +
                      'ИЗМЕНЕНИЕ':U + chr(44) +
                      'ПРОСМОТР':U) = 0 THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ser-wth'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
    IF not error-status:error then
    assign
    ser-wth = (conf-par = "yes":U).
  RUN Myenable no-error.
  if error-status:error then return error.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE ch-units :
define variable ref-rec as recid no-undo .
   run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? then do:
            apply "entry" to b-unit in frame Dialog-Frame.
            return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ tt-wealth.unit-base with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-wealth SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY FILL-IN-1 fcurr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wealth THEN
    DISPLAY tt-wealth.wth-name tt-wealth.is-money tt-wealth.curr-code
          tt-wealth.unit-base tt-wealth.get-qnty-method tt-wealth.is-ser
          tt-wealth.PS tt-wealth.wth-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-wealth.wth-name tt-wealth.is-money
         tt-wealth.curr-code tt-wealth.unit-base B-unit B-curr FILL-IN-1
         tt-wealth.get-qnty-method b-del tt-wealth.PS tt-wealth.wth-code
         fcurr-abbr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-wth-gds FOR EACH tt-wth-gds       WHERE tt-wth-gds.stts = 0 NO-LOCK,       EACH ub.goods WHERE TRUE        AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE GdsEnable :
IF ser-wth and tt-wealth.is-ser:SCREEN-VALUE IN FRAME Dialog-Frame = '1' AND CAN-FIND(FIRST tt-wth-gds NO-LOCK where tt-wth-gds.stts = 0) THEN DO WITH FRAME Dialog-Frame:
    DISABLE b-add .
    if par-mode = 'ДОБАВЛЕНИЕ':U then ENABLE b-chg b-del BR-wth-gds.
    else disable b-chg b-del BR-wth-gds.
END.
ELSE IF ser-wth and tt-wealth.is-ser:SCREEN-VALUE = '1'  THEN DO WITH FRAME Dialog-Frame:
    ENABLE b-add.
    DISABLE b-chg b-del WITH FRAME Dialog-Frame.
END.
ELSE DISABLE BR-wth-gds b-add b-chg b-del WITH FRAME Dialog-Frame.
apply 'entry':U to   BR-wth-gds in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-list-items as character no-undo.
define variable v-ii as integer no-undo.
  if par-mode = 'ИЗМЕНЕНИЕ':U or par-mode = 'ПРОСМОТР':U then do:
    IF par-mode = 'ИЗМЕНЕНИЕ':U THEN FIND FIRST locked_wealth Exclusive-lock where
                locked_wealth.wth-code = pwth-code NO-ERROR.
    ELSE FIND FIRST locked_wealth NO-LOCK where
                locked_wealth.wth-code = pwth-code NO-ERROR.
    if not avail locked_wealth then do:
        message vss-workfile vss-revision vss-description skip
        "Не найдена материальная ценность с кодом " pwth-code
        view-as alert-box error.
        return error.
    end.
    if locked_wealth.curr-code <> ? then do:
        FIND FIRST ub.currency No-LOCK WHERE
                    ub.currency.curr-code = locked_wealth.curr-code NO-ERROR.
        if not avail ub.currency then do:
           message vss-workfile vss-revision vss-description skip
           "Не найдена валюта с кодом " locked_wealth.curr-code
           "для материальной ценности с кодом " pwth-code
            view-as alert-box error.
            return error.
        end.
    end.
    else if locked_wealth.is-ser = 0 then do:
        FIND FIRST ub.units NO-LOCK WHERE
                   ub.units.unit-name = locked_wealth.unit-base No-ERROR.
        if not avail ub.units then do:
           message vss-workfile vss-revision vss-description skip
           "Не найдена единица измерения " locked_wealth.unit-base
           "для материальной ценности с кодом " pwth-code
            view-as alert-box error.
        end.
    end.
    FOR EACH ub.wth-gds NO-LOCK WHERE ub.wth-gds.wth-code = Locked_wealth.wth-code:
        CREATE tt-wth-gds.
        BUFFER-COPY wth-gds TO tt-wth-gds.
    END.
    IF LOCKED_wealth.is-ser = 1 THEN DO:
        FIND FIRST LOCKED_wth-gds WHERE LOCKED_wth-gds.wth-code = LOCKED_wealth.wth-code EXCLUSIVE-LOCK NO-ERROR.
        if not avail locked_wth-gds then do:
        message vss-workfile vss-revision vss-description skip
        substitute("Не найдена связь МЦ (&1) с товарами",LOCKED_wealth.wth-code )
        view-as alert-box error.
        return error.
    end.
    END.
    CREATE tt-wealth.
    BUFFER-COPY LOCKED_wealth TO tt-wealth.
  end.
IF par-mode = 'ДОБАВЛЕНИЕ':U THEN do:
    CREATE tt-wealth.
    tt-wealth.curr-code = ?.
END.
do v-ii = 1 to num-entries('=sum,=1,=val-qnty':U):
  v-list-items = v-list-items + (if v-ii = 1 then '' else chr(44)) +
                  entry(v-ii, '=Сумма,=1,По номиналу и кол-ву':U) + chr(44) +
                  entry(v-ii, '=sum,=1,=val-qnty':U).
end.
assign
tt-wealth.get-qnty-method:radio-buttons in frame Dialog-Frame = v-list-items
.
if par-mode = 'ДОБАВЛЕНИЕ':U then do:
  assign
  tt-wealth.get-qnty-method = '=sum':U.
end.
DISPLAY
tt-wealth.wth-code
tt-wealth.wth-name
tt-wealth.curr-code
tt-wealth.is-money
tt-wealth.PS
tt-wealth.is-ser
tt-wealth.unit-base WHEN (NOT tt-wealth.is-money )
tt-wealth.get-qnty-method
(if avail currency then currency.curr-abbr else "" ) @ fcurr-abbr
WITH FRAME Dialog-Frame
  .
if not ser-wth then hide tt-wealth.is-ser BR-wth-gds b-add b-chg b-del BR-wth-gds in frame   Dialog-Frame.
else view tt-wealth.is-ser BR-wth-gds b-add b-chg b-del BR-wth-gds in frame   Dialog-Frame.
frame Dialog-Frame:title = frame Dialog-Frame:title + chr(32) + par-mode.
if par-mode = 'ПРОСМОТР':U then
enable b-quit  b-help b-hist WITH FRAME Dialog-Frame .
else do:
  ENABLE
  B-exit
  b-quit
  B-Help
  tt-wealth.is-money when par-mode = 'ДОБАВЛЕНИЕ':U
  b-unit when (par-mode = 'ДОБАВЛЕНИЕ':U OR (NOT tt-wealth.is-money ))
  tt-wealth.unit-base when (par-mode = 'ДОБАВЛЕНИЕ':U OR (NOT tt-wealth.is-money ))
  tt-wealth.wth-name
  tt-wealth.ps
  b-hist WHEN par-mode <> 'ДОБАВЛЕНИЕ':U
  tt-wealth.is-ser WHEN (par-mode = 'ДОБАВЛЕНИЕ':U AND ser-wth)
  tt-wealth.get-qnty-method when par-mode <> 'ПРОСМОТР':U
  WITH FRAME Dialog-Frame.
end.
VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-wth-gds FOR EACH tt-wth-gds       WHERE tt-wth-gds.stts = 0 NO-LOCK,       EACH ub.goods WHERE TRUE        AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION.
  APPLY "entry":U to tt-wealth.wth-name.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEF VAR wg-rec AS RECID NO-UNDO.
IF par-mode = 'ПРОСМОТР':U THEN UNDO, RETURN ERROR.
ASSIGN FRAME Dialog-Frame
tt-wealth.curr-code
tt-wealth.is-money
tt-wealth.is-ser
tt-wealth.unit-base
tt-wealth.wth-name
fcurr-abbr
tt-wealth.get-qnty-method
.
IF tt-wealth.is-ser = 1 AND NOT CAN-FIND(FIRST tt-wth-gds NO-LOCK where tt-wth-gds.stts = 0) THEN DO:
    MESSAGE 'Для серийной МЦ должен быть указан товар!' VIEW-AS ALERT-BOX ERROR.
    APPLY 'entry':U TO b-add.
    RETURN NO-APPLY.
END.
save-block: do transaction  on error undo save-block, return error
on stop undo  save-block, return error
on endkey undo save-block, return error :
  if available locked_wealth then v-rec = recid(locked_wealth).
  run ref/wealth.p ( INPUT par-mode
                      ,INPUT NO
                      ,INPUT-OUTPUT v-rec
                      ,INPUT tt-wealth.wth-code
                      ,INPUT tt-wealth.is-money
                      ,INPUT tt-wealth.is-ser
                      ,INPUT (if tt-wealth.is-money
                              then fcurr-abbr
                              else tt-wealth.unit-base )
                      ,INPUT tt-wealth.curr-code
                      ,INPUT tt-wealth.wth-name
                      ,INPUT tt-wealth.get-qnty-method
                      ,INPUT tt-wealth.ps ) NO-ERROR.
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
    undo save-block, return error.
  end.
  p-rec = v-rec.
  IF tt-wealth.is-ser = 0 THEN LEAVE.
  if par-mode = 'ДОБАВЛЕНИЕ':U then find first locked_wealth where recid(locked_wealth) = v-rec exclusive-lock.
    FIND FIRST tt-wth-gds.
    IF AVAILABLE locked_wth-gds AND LOCKED_wth-gds.gds-code <> tt-wth-gds.gds-code THEN do:
        wg-rec = RECID(locked_wth-gds).
        run ref/wth-gds.p ( INPUT par-mode
                          ,INPUT YES
                          ,INPUT-OUTPUT wg-rec
                          ,INPUT locked_wealth.wth-code
                          ,INPUT tt-wth-gds.gds-code
                          ,INPUT 1 )  NO-ERROR.
        if error-status:error then do:
         MESSAGE error-status:get-message(1) SKIP RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
         undo, return error.
        end.
        wg-rec = ?.
        run ref/wth-gds.p ( INPUT par-mode
                          ,INPUT YES
                          ,INPUT-OUTPUT wg-rec
                          ,INPUT locked_wealth.wth-code
                          ,INPUT tt-wth-gds.gds-code
                          ,INPUT 0 )  NO-ERROR.
        if error-status:error then do:
         MESSAGE error-status:get-message(1) SKIP RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
         undo, return error.
        end.
    END.
    IF NOT AVAILABLE LOCKED_wth-gds THEN DO:
        run ref/wth-gds.p ( INPUT par-mode
                          ,INPUT NO
                          ,INPUT-OUTPUT wg-rec
                          ,INPUT locked_wealth.wth-code
                          ,INPUT tt-wth-gds.gds-code
                          ,INPUT tt-wth-gds.stts ) NO-ERROR.
      if error-status:error then do:
        undo, return error.
      end.
    END.
end.
END PROCEDURE.
