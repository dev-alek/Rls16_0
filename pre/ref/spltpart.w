define input parameter parparentproc as widget-handle no-undo .
define input-output parameter p-line-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Разбиение партий" .
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
DEFINE TEMP-TABLE qnty-table NO-UNDO
FIELD nn as integer
FIELD qnty like ub.parts.qnty FORMAT ">>,>>>,>>9.999"
INDEX PI IS UNIQUE PRIMARY nn
.
def buffer b-qnty-table for qnty-table.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts-qnty no-undo
  field qnty      like ub.parts.qnty
  field fact-qnty like ub.parts.fact-qnty
  field cli-qnty  like ub.parts.cli-qnty
  field pl-code   like ub.parts.pl-code
  field parts-part-code like ub.parts.part-code
  field parts-recid as recid
.
DEFINE BUTTON B-doc
     LABEL "П&Н"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-good
     LABEL "&Товар"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-part
     LABEL "&Партия"
     SIZE 10 BY 1.
DEFINE BUTTON B-split AUTO-GO
     LABEL "&Разбить"
     SIZE 10 BY 1.
DEFINE VARIABLE all-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Введено"
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE all-qnty-cli AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Введено"
      VIEW-AS TEXT
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE for-goods AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 93.1 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE for-in-code AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24.1 BY 1 NO-UNDO.
DEFINE VARIABLE for-max-rate AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0
     LABEL "Макс. кол-во в штуке"
      VIEW-AS TEXT
     SIZE 17 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE for-min-rate AS DECIMAL FORMAT "->>,>>9.999" INITIAL 0
     LABEL "Мин. кол-во в штуке"
      VIEW-AS TEXT
     SIZE 17 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE for-parts AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 35.4 BY 1 NO-UNDO.
DEFINE VARIABLE for-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 18.4 BY 1 NO-UNDO.
DEFINE VARIABLE part-cli-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Кол-во изделий"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE part-qnty AS DECIMAL FORMAT ">>,>>9.999":U INITIAL 0
     LABEL "Вес изделий"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rest-qnty AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0
     LABEL "Осталось"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rest-qnty-cli AS DECIMAL FORMAT "->>,>>9.999":U INITIAL 0
     LABEL "Осталось"
      VIEW-AS TEXT
     SIZE 18 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.1 BY 2.87.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 4.7.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.4 BY 4.7.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.4 BY 3.27.
DEFINE QUERY BR-qnty FOR
      qnty-table SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      ub.goods SCROLLING.
DEFINE BROWSE BR-qnty
  QUERY BR-qnty DISPLAY
      qnty-table.nn column-label "N"
      qnty-table.qnty column-label "Вес"
ENABLE qnty-table.qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 28.5 BY 15.77.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-good AT ROW 1 COL 11
     B-doc AT ROW 1 COL 21
     B-split AT ROW 1 COL 31
     B-part AT ROW 1 COL 41
     B-Help AT ROW 1 COL 95
     for-qnty AT ROW 5.83 COL 2.1 NO-LABEL
     BR-qnty AT ROW 7.03 COL 1.9
     for-goods AT ROW 2.5 COL 2.4 COLON-ALIGNED NO-LABEL
     for-in-code AT ROW 3.93 COL 6.3 COLON-ALIGNED NO-LABEL
     for-parts AT ROW 3.93 COL 54.3 COLON-ALIGNED NO-LABEL
     for-min-rate AT ROW 6.37 COL 78.3 COLON-ALIGNED
     for-max-rate AT ROW 7.57 COL 78.1 COLON-ALIGNED
     part-qnty AT ROW 9.5 COL 42.5 COLON-ALIGNED
     part-cli-qnty AT ROW 9.53 COL 78.1 COLON-ALIGNED
     all-qnty AT ROW 10.87 COL 42.5 COLON-ALIGNED
     all-qnty-cli AT ROW 10.97 COL 78.1 COLON-ALIGNED
     rest-qnty AT ROW 12.3 COL 42.5 COLON-ALIGNED
     rest-qnty-cli AT ROW 12.37 COL 78.1 COLON-ALIGNED
     "ПН:" VIEW-AS TEXT
          SIZE 4.3 BY 1 AT ROW 3.93 COL 3.3
     "Партия:" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 3.93 COL 46.8
     RECT-4 AT ROW 2.2 COL 2.1
     RECT-1 AT ROW 6.07 COL 56.4
     RECT-3 AT ROW 9.27 COL 30.9
     RECT-2 AT ROW 9.27 COL 63.9
     SPACE(0.72) SKIP(9.10)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Разбиение партий"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-part:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-doc IN FRAME Dialog-Frame
DO:
  run str/showdoc.p
    (input parparentproc
    ,input for-in-code
    ,input ub.goods.artic
    ,input ub.goods.prod-type
    ,input ub.goods.prod-code
    ,input true
    ) .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
    p-line-rec = ?.
END.
ON CHOOSE OF B-good IN FRAME Dialog-Frame
DO:
  define variable old-min-rate like ub.goods.min-rate no-undo.
  define variable old-max-rate like ub.goods.max-rate no-undo.
  define variable glog as logical no-undo .
  def buffer b1-qnty for qnty-table.
  assign
  old-min-rate = ub.goods.min-rate
  old-max-rate = ub.goods.max-rate
  .
  FIND FIRST ub.db WHERE ub.db.db-num = v-cntxt-db-num NO-LOCK .
  if not avail db then return no-apply.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  goods.grp-code
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if glog AND NOT goods.stts <> 0 AND db.add-goods AND NOT transaction
  then do:
    run str/showgds.p ( input parparentproc
                       ,input ?
                       ,input goods.gds-code
                       ,input 'ИЗМЕНЕНИЕ':U).
    FIND current goods No-LOCK No-ERROR.
    if old-min-rate <> goods.min-rate OR old-max-rate <> goods.max-rate then do:
        assign
        for-min-rate = goods.min-rate
        for-max-rate = goods.max-rate
        .
        display
        for-min-rate
        for-max-rate
        with frame Dialog-Frame.
        FOR EACh b1-qnty:
            run check-qnty(b1-qnty.qnty, 0, recid(b1-qnty)) no-error.
            if error-status:error then do:
              REPOSITION br-qnty to recid recid(b1-qnty) NO-ERROR.
              glog = br-qnty:select-focused-ROW( ).
              APPLY "ENTRY" to br-qnty.
              return no-apply.
            end.
        end.
    end.
  end.
  else
  run str/showgds.p ( input parparentproc
                     ,input ?
                     ,input goods.gds-code
                     ,input 'ПРОСМОТР':U) no-error.
END.
ON CHOOSE OF B-split IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  glog = no.
  if can-find(first qnty-table) then do:
    message "Вы уверены, что хотите разбить партию " for-parts
            "по ПН " for-in-code " на указанные здесь количества?" skip
            "Общее количество изделий по партии" part-cli-qnty
            "Общий вес изделий по партии" part-qnty SKIP
            "Введено количесто изделий" all-qnty-cli "Общим весом" all-qnty SKIP
            "Осталось" rest-qnty-cli "с весом " rest-qnty
    view-as alert-box QUESTION buttons YES-NO update glog.
    if NOT glog then return no-apply.
    FOR EACH temp-parts-qnty:
        delete temp-parts-qnty.
    END.
    FOR EACH qnty-table:
        create temp-parts-qnty.
        assign
        temp-parts-qnty.cli-qnty = 1
        temp-parts-qnty.qnty = qnty-table.qnty
        temp-parts-qnty.fact-qnty = qnty-table.qnty
        .
    END.
    run trg/partsplt.p (
                   input ub.parts.obj-type,
                   input ub.parts.obj-code,
                   input ub.parts.artic,
                   input ub.parts.prod-type,
                   input ub.parts.prod-code,
                   input ub.parts.in-code,
                   input ub.parts.out-code,
                   input ub.parts.part-code,
                   input table temp-parts-qnty) no-error.
    if error-status:error then do:
        message "Не удалось разбить партию!" skip
           error-status:get-message(1)
           view-as alert-box ERROR.
        return no-apply.
    end.
  end.
  else do:
    message "Вы не ввели количества на которые Вы хотите разбить партию"
    view-as alert-box.
    return no-apply.
  end.
END.
ON DELETE-CHARACTER OF BR-qnty IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  glog = yes.
  if avail qnty-table then do:
    message "Удалить изделие N " qnty-table.nn " с весом "
             qnty-table.qnty
    view-as alert-box question buttons OK-Cancel update glog.
    if glog <> true then return.
    run check-qnty(- qnty-table.qnty, - 1, ?) no-error.
    if error-status:error then return no-apply.
    _MAIN-d:
    DO on error undo _main-d, return no-apply:
        delete qnty-table.
        run update-br no-error.
      IF ERROR-STATUS:ERROR THEN UNDO _main-d, return no-apply.
    end.
  end.
END.
ON RETURN OF BR-qnty IN FRAME Dialog-Frame
DO:
  APPLY "ENTRY" to qnty-table.qnty in browse br-qnty.
END.
ON ROW-LEAVE OF BR-qnty IN FRAME Dialog-Frame
DO:
 define variable new-qnty as decimal no-undo.
   if avail qnty-table then do :
   new-qnty = decimal(qnty-table.qnty:screen-value in browse br-qnty).
   if new-qnty <> qnty-table.qnty then do:
      run check-qnty(new-qnty, 0, recid(qnty-table)) no-error.
      if error-status:error then do:
        display
        qnty-table.qnty
        with browse br-qnty.
        return no-apply.
      end.
      run update-br no-error.
    end.
    end.
END.
ON RETURN OF for-qnty IN FRAME Dialog-Frame
DO:
define variable max-nn as integer no-undo.
  assign
  for-qnty.
  if all-qnty-cli >= part-cli-qnty then do:
    message "Количество введенных изделий уже равно количеству изделий в партии"
    view-as alert-box.
    return no-apply.
  end.
    run check-qnty(for-qnty, 1, ?) no-error.
    if error-status:error then return no-apply.
    FIND LAST qnty-table No-LOCK NO-ERROR.
    IF avail qnty-table then
    max-nn = qnty-table.nn.
    _MAIN:
    DO on error undo _main, return no-apply:
      CREATE qnty-table.
      assign
      qnty-table.nn = max-nn + 1
      qnty-table.qnty = for-qnty.
      run update-br no-error.
      IF ERROR-STATUS:ERROR THEN UNDO _main, return no-apply.
    end.
END.
ON RETURN OF qnty-table.qnty IN BROWSE BR-qnty
DO:
  if avail qnty-table then do:
  run check-qnty(decimal(qnty-table.qnty:screen-value in browse br-qnty), 0, recid(qnty-table)) no-error.
  if error-status:error then return no-apply.
  _Main-l:
  DO ON ERROR UNDO _main-l, return no-apply:
  FIND FIRST b-qnty-table where
            recid(b-qnty-table) = recid(qnty-table) No-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO _main-l, return no-apply.
  assign
  b-qnty-table.qnty = decimal(qnty-table.qnty:screen-value in browse br-qnty).
  run update-br no-error.
  IF ERROR-STATUS:ERROR THEN UNDO _main-l, return no-apply.
  END.
  end.
  APPLY "ENTRY" to for-qnty in frame Dialog-Frame.
  return NO-APPLY.
END.
ON END-ERROR, TAB OF qnty-table.qnty IN BROWSE BR-qnty
DO:
    DISPLAY  qnty-table.qnty with browse br-qnty.
    APPLY "ENTRY" to for-qnty in frame Dialog-Frame.
    return NO-APPLY.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-qnty :handle
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  FIND FIRST parts No-LOCK WHERE recid(parts) = p-line-rec No-ERROR.
  if not avail parts then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена партия" skip
      view-as alert-box error .
    return "error".
  end.
  IF NOT parts.cli-qnty > 1 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Партия состоит из одной единицы товара или уже разбита" skip
      view-as alert-box error .
    return "error".
  end.
  FIND FIRST goods No-LOCK WHERE
             goods.artic = parts.artic AND
             goods.prod-type = parts.prod-type AND
             goods.prod-code = parts.prod-code No-ERROR.
  IF NOT AVAIL goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найден товар " parts.artic parts.prod-type string(parts.prod-code) skip
      view-as alert-box error .
    return "error".
  END.
  assign
  for-parts = parts.part-code
  for-in-code = parts.in-code
  part-cli-qnty = parts.cli-qnty
  part-qnty = parts.fact-qnty
  for-min-rate = goods.min-rate
  for-max-rate = goods.max-rate
  for-goods = goods.artic + " " + goods.prod-type + string(goods.prod-code) + " " +
              goods.gds-name.
  RUN enable_UI.
  APPLY "ENTRY" to for-qnty.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-qnty :
  define input parameter loc-for-qnty as decimal no-undo.
  define input parameter loc-for-qnty-cli as decimal no-undo.
  define input parameter curr-recid as recid no-undo.
  define var loc-all-qnty as decimal no-undo.
  define var loc-all-qnty-cli as decimal no-undo.
  define var loc-rest-qnty as decimal no-undo.
  define var loc-rest-qnty-cli as decimal no-undo.
  if loc-for-qnty = ?
  or loc-for-qnty = 0
  then do:
    message
      "Неверно введен вес изделия" skip
      view-as alert-box error.
    return error.
  end.
  if loc-for-qnty-cli >= 0
  then do:
    if (loc-for-qnty < ub.goods.min-rate)
    then do:
      define variable v-ok as logical   no-undo .
      message
        substitute("Вес изделия &1 меньше, чем минимальный вес, заданный в карточке товара &2"
                  ,loc-for-qnty
                  ,goods.min-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
    if loc-for-qnty > goods.max-rate then do:
      message
        substitute("Вес изделия &1 больше, чем максимальный вес, заданный в карточке товара &2"
                  ,loc-for-qnty
                  ,goods.max-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
  end.
  assign
    loc-all-qnty = 0
    loc-all-qnty-cli = 0
  .
  for each b-qnty-table no-lock
  on error undo, return error return-value
  :
    if recid(b-qnty-table) <> curr-recid then do:
      assign
        loc-all-qnty = loc-all-qnty + b-qnty-table.qnty
        loc-all-qnty-cli = loc-all-qnty-cli + 1
      .
    end.
  end.
  assign
    loc-all-qnty = loc-all-qnty + loc-for-qnty
    loc-all-qnty-cli = loc-all-qnty-cli + (if loc-for-qnty-cli = 0 then 1 else loc-for-qnty-cli)
    loc-rest-qnty = part-qnty - loc-all-qnty
    loc-rest-qnty-cli = part-cli-qnty - loc-all-qnty-cli
  .
  if loc-all-qnty-cli > part-cli-qnty
  then do:
    message
      "Общее введенное количество изделий больше количества изделий в партии" skip
      view-as alert-box error.
    return error.
  end.
  if loc-all-qnty > part-qnty then do:
    message
      "Общий введенный вес больше веса в партии" skip
      view-as alert-box error.
    return error.
  end.
  if  loc-rest-qnty-cli = 1
  and (loc-rest-qnty < goods.min-rate
       or loc-rest-qnty > goods.max-rate
       )
  then do:
    if loc-rest-qnty > goods.max-rate
    then do:
      message
        substitute("Вес одного оставшегося изделия &1 больше, чем максимальный вес, заданный в карточке товара &2"
                  ,loc-rest-qnty
                  ,goods.max-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
    if loc-rest-qnty < goods.min-rate
    then do:
      message
        substitute("Вес одного оставшегося изделия &1 меньше, чем минимальный вес, заданный в карточке товара &2"
                  ,loc-rest-qnty
                  ,goods.min-rate
                  ) skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok <> true
      then do:
        return error.
      end.
    end.
  end.
  if  loc-rest-qnty-cli = 0
  and loc-rest-qnty <> 0
  then do:
    message
      "Общее введенное количество изделий равно количеству изделий в партии" skip
      "но общий введенный вес не равен общему весу изделий в партии" skip
      view-as alert-box ERROR.
    return error.
  end.
 END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY for-qnty for-goods for-in-code for-parts for-min-rate for-max-rate
          part-qnty part-cli-qnty all-qnty all-qnty-cli rest-qnty rest-qnty-cli
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-good B-doc B-split B-Help RECT-4 RECT-1 RECT-3 RECT-2
         for-qnty BR-qnty for-goods for-in-code for-parts for-min-rate
         for-max-rate part-qnty part-cli-qnty all-qnty all-qnty-cli rest-qnty
         rest-qnty-cli
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-qnty FOR EACH qnty-table SHARE-LOCK.
END PROCEDURE.
PROCEDURE update-br :
define variable ii as integer no-undo.
      assign
      ii = 1
      all-qnty = 0
      all-qnty-cli = 0
      .
      for each b-qnty-table use-index pi:
        ASSIGN
        all-qnty = all-qnty + b-qnty-table.qnty
        all-qnty-cli = all-qnty-cli + 1
        .
        if b-qnty-table.nn <> ii then
        assign
        b-qnty-table.nn = ii.
        ii = ii + 1.
      end.
      assign
      rest-qnty = part-qnty - all-qnty
      rest-qnty-cli = part-cli-qnty - all-qnty-cli
      .
      display
      all-qnty
      rest-qnty
      all-qnty-cli
      rest-qnty-cli
      with frame Dialog-Frame.
        OPEN QUERY br-qnty FOR EACH qnty-table SHARE-LOCK.
        DISPLAY br-qnty
        with frame Dialog-Frame.
        APPLY "ENTRY" to for-qnty.
END PROCEDURE.
