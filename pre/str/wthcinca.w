DEFINE BUFFER buf_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE TEMP-TABLE tt-c-wth-line NO-UNDO LIKE ub.c-wth-line.
define input parameter parparentproc as widget-handle no-undo .
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам ()"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!()"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
 .
define input parameter par-mode as character no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-current-w-p-code like ub.c-wth-line.w-p-code no-undo.
define input parameter par-out-w-p-code like ub.c-wth-line.out-code no-undo.
define input-output parameter parline-rec as recid no-undo.
define input parameter pardoc-type like ub.c-wth-doc.doc-type no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Добавление, изменение, просмотр истории строки документа МЦ (не инвентаризация)":U.
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
define variable vardoc-code like ub.c-wth-doc.doc-code no-undo.
define variable varchip-num like ub.c-wth-doc.chip-num no-undo.
define variable varcorr-user-db-num like ub.c-wth-doc.corr-user-db-num no-undo.
define variable lock-line as logical no-undo.
define variable locked-wth as logical no-undo .
DEFINE BUTTON B-dtl
     LABEL "&Номиналы"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-next
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE T-dtl AS LOGICAL INITIAL no
     LABEL "Расшифровка суммы"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY 1 NO-UNDO.
DEFINE QUERY QUERY-lines FOR
      buf_c-wth-line SCROLLING.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-dtl AT ROW 1 COL 11.5
     B-prev AT ROW 1 COL 37
     B-next AT ROW 1 COL 41
     B-Help AT ROW 1 COL 54.9
     T-dtl AT ROW 6.27 COL 1.5
     ub.wealth.wth-name AT ROW 2.77 COL 35 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 32 BY 1
          FGCOLOR 4
     tt-c-wth-line.wth-code AT ROW 3 COL 22.3 COLON-ALIGNED
          LABEL "Материальная ценность"
           VIEW-AS TEXT
          SIZE 12 BY .67
     tt-c-wth-line.doc-sum AT ROW 4.27 COL 22 COLON-ALIGNED
          LABEL "Кол-во движения"
           VIEW-AS TEXT
          SIZE 13.5 BY .67
          FGCOLOR 4
     tt-c-wth-line.sum-gds-rubl AT ROW 4.27 COL 68 COLON-ALIGNED WIDGET-ID 264
          LABEL "Сумма по тов. (abbr_rubl)" FORMAT "->,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 16 BY .67
          FGCOLOR 4
     tt-c-wth-line.fact-sum AT ROW 5.5 COL 22 COLON-ALIGNED
          LABEL "Количество факт"
           VIEW-AS TEXT
          SIZE 13.5 BY .67
          FGCOLOR 4
     tt-c-wth-line.sum-gds-base AT ROW 5.5 COL 68 COLON-ALIGNED WIDGET-ID 262
          LABEL "Сумма по тов. (баз.вал.)" FORMAT "->,>>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 14 BY .67
          FGCOLOR 4
     SPACE(8.74) SKIP(1.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка удаленного документа движения МЦ"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-c-wth-line.sum-gds-base:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       tt-c-wth-line.sum-gds-rubl:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-dtl IN FRAME Dialog-Frame
DO:
  assign
  tt-c-wth-line.doc-sum
  tt-c-wth-line.fact-sum
  tt-c-wth-line.wth-code
  .
  run str/wthcdtlc.w (
                  input parparentproc
                  ,INPUT par-mode
                  ,INPUT parline-rec
                  ,INPUT tt-c-wth-line.doc-code
                  ,INPUT tt-c-wth-line.wth-code
                  ,INPUT tt-c-wth-line.w-p-code
                  ,INPUT tt-c-wth-line.corr-user-db-num
                  ,INPUT tt-c-wth-line.chip-num
                  ,INPUT tt-c-wth-line.doc-sum
                  ,INPUT tt-c-wth-line.fact-sum
                  ,INPUT tt-c-wth-line.bef-sum
                  ,INPUT tt-c-wth-line.aft-sum
                  ,INPUT ub.c-wth-doc.doc-type
                  ,input-output table tt-par-dtl ).
  run control-dtl in this-procedure(output lock-line).
  run lock-proc in this-procedure(input lock-line).
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
  run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
      run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON LEAVE OF tt-c-wth-line.wth-code IN FRAME Dialog-Frame
DO:
  FIND FIRST buf_wealth NO-LOCK WHERE
                   buf_wealth.wth-code = INPUT FRAME Dialog-Frame tt-c-wth-line.wth-code NO-ERROR.
  IF AVAIL buf_wealth THEN DO:
    DISPLAY buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME Dialog-Frame.
  END.
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
  if par-mode <> 'ПРОСМОТР':U then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST ub.c-wth-doc No-LOCK WHERE
               recid(ub.c-wth-doc) = pardoc-rec No-ERROR.
  end.
  IF NOT avail ub.c-wth-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден документ движения МЦ"
    view-as alert-box.
    return error.
  end.
  assign
  vardoc-code = ub.c-wth-doc.doc-code
  varcorr-user-db-num = ub.c-wth-doc.corr-user-db-num
  varchip-num = ub.c-wth-doc.chip-num
  .
  OPEN QUERY QUERY-lines
  FOR EACH buf_c-wth-line WHERE
            buf_c-wth-line.doc-code = vardoc-code
       AND  buf_c-wth-line.corr-user-db-num = varcorr-user-db-num
       AND  buf_c-wth-line.chip-num = varchip-num NO-LOCK INDEXED-REPOSITION.
    if par-mode = 'ПРОСМОТР':U then do:
      get first QUERY-lines.
      repeat while parline-rec <> recid(buf_c-wth-line):
        get next QUERY-lines.
      end.
    end.
    IF error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена строка по документу движения МЦ"
      view-as alert-box.
      return error.
    end.
    run fill-tables in this-procedure.
  RUN Myenable in this-procedure.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE control-dtl :
define output parameter lock-line as logical no-undo.
if not avail tt-c-wth-line then return error.
if can-find(first tt-par-dtl) then dO:
     find first tt-par-dtl No-LOCK  where
                tt-par-dtl.doc-sum > 0 No-ERROR .
     t-dtl:screen-value in frame Dialog-Frame = (if available tt-par-dtl then "yes" else "no").
end.
else do:
       find first ub.c-wth-dtl No-LOCK  where
                    ub.c-wth-dtl.doc-code = tt-c-wth-line.doc-code AND
                    ub.c-wth-dtl.wth-code = tt-c-wth-line.wth-code AND
                    ub.c-wth-dtl.w-p-code = tt-c-wth-line.w-p-code No-ERROR .
     t-dtl:screen-value in frame Dialog-Frame = (if available ub.c-wth-dtl then "yes" else "no").
end.
if t-dtl:screen-value in frame Dialog-Frame = "yes" or
par-mode = 'ПРОСМОТР':U
then lock-line = yes.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-dtl
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-line THEN
    DISPLAY tt-c-wth-line.wth-code tt-c-wth-line.doc-sum
          tt-c-wth-line.sum-gds-rubl tt-c-wth-line.fact-sum
          tt-c-wth-line.sum-gds-base
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.wealth THEN
    DISPLAY ub.wealth.wth-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-dtl B-prev B-next B-Help T-dtl ub.wealth.wth-name
         tt-c-wth-line.wth-code tt-c-wth-line.doc-sum tt-c-wth-line.fact-sum
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
  for each tt-c-wth-line:
    delete tt-c-wth-line.
  end.
for each tt-par-dtl:
    delete tt-par-dtl.
end.
    create tt-c-wth-line.
    buffer-copy buf_c-wth-line to tt-c-wth-line.
    FIND FIRST buf_wealth No-LOCK WHERE
               buf_wealth.wth-code = tt-c-wth-line.wth-code No-error.
    find first ub.c-wth-dtl No-LOCK WHERE
                  ub.c-wth-dtl.wth-code = tt-c-wth-line.wth-code
              AND ub.c-wth-dtl.doc-code = tt-c-wth-line.doc-code
              AND ub.c-wth-dtl.w-p-code = tt-c-wth-line.w-p-code
              AND ub.c-wth-dtl.corr-user-db-num = tt-c-wth-line.corr-user-db-num
              AND ub.c-wth-dtl.chip-num = tt-c-wth-line.chip-num No-ERROR.
END PROCEDURE.
PROCEDURE lock-proc :
DEFINE INPUT PARAMETER lock-line as logical no-undo.
  if lock-line then
  DISABLE
  tt-c-wth-line.wth-code
  with frame Dialog-Frame
  .
END PROCEDURE.
PROCEDURE MyEnable :
assign
tt-c-wth-line.sum-gds-rubl:label in frame Dialog-Frame = "Сумма по тов. (рубл)".
IF AVAILABLE tt-c-wth-line THEN
    DISPLAY
    tt-c-wth-line.wth-code
    tt-c-wth-line.doc-sum
    tt-c-wth-line.fact-sum
  WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_wealth THEN DO:
    DISPLAY
    buf_wealth.wth-name @ ub.wealth.wth-name
    WITH FRAME Dialog-Frame.
    if buf_wealth.is-ser = 1 then do:
      view
      tt-c-wth-line.sum-gds-base
      tt-c-wth-line.sum-gds-rubl
      in frame Dialog-Frame.
      DISPLAY
      tt-c-wth-line.sum-gds-base
      tt-c-wth-line.sum-gds-rubl
      WITH FRAME Dialog-Frame.
    end.
  END.
  ELSE
  DISPLAY
  '':u @ WEALTH.WTH-NAME
  WITH FRAME Dialog-Frame.
CASE par-mode:
    when 'ПРОСМОТР':U  THEN DO:
      IF ub.c-wth-doc.status_ <> 'накл':U THEN DO:
        DISPLAY
        tt-c-wth-line.fact-sum WITH FRAME Dialog-Frame.
      END.
      ENABLE
      B-Next
      B-Prev
      b-quit
      b-dtl when avail ub.c-wth-dtl
      WITH FRAME Dialog-Frame.
      locked-wth = yes.
    END.
  END CASE.
  run control-dtl in this-procedure (output lock-line).
  run lock-proc in this-procedure(input lock-line).
  ENABLE
  b-help
  WITH FRAME Dialog-Frame.
  FRAME Dialog-Frame:TITLE =
      "Удаленный документ № " + c-wth-doc.doc-code + " (" + TRIM(
      ( IF c-wth-doc.doc-type = 'при':U     THEN "ПРИХОД"         ELSE
      ( IF c-wth-doc.doc-type = 'рас':U    THEN "РАСХОД"         ELSE
      ( IF c-wth-doc.doc-type = 'спи':U  THEN "СПИСАНИЕ"       ELSE
      ( IF c-wth-doc.doc-type = 'инв':U  THEN "ИНВЕНТАРИЗАЦИЯ" ELSE c-wth-doc.doc-type ) ) ) ) +
      STRING( c-wth-doc.inter_, "ВНУТ/":U ) + STRING( c-wth-doc.exter_, "ВНЕШ/":U ) ) + ")" +
      "  - " + CAPS( par-mode ) + " матценности".
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-move :
DEFINE INPUT PARAMETER par-action as character No-UNDO.
define variable is-updated as logical no-undo.
define variable loc#log as logical no-undo.
define variable v-line-rec as recid no-undo .
  ASSIGN v-line-rec = RECID( buf_c-wth-line ).
  CASE par-action:
    when "b-next":U then do:
        GET NEXT QUERY-lines NO-LOCK.
    end.
    when "b-prev":U then do:
        GET PREV QUERY-lines NO-LOCK.
    end.
  END CASE.
  IF AVAIL buf_c-wth-line THEN DO:
    ASSIGN v-line-rec = RECID( buf_c-wth-line ).
    run fill-tables in this-procedure.
    run MyEnable in this-procedure.
  END.
  ELSE DO:
    CASE par-action:
        when "b-next":U then do:
            GET PREV QUERY-lines NO-LOCK.
        end.
        when "b-prev":U then do:
            GET NEXT QUERY-lines NO-LOCK.
        end.
    END CASE.
    FIND FIRST buf_c-wth-line NO-LOCK WHERE
                    RECID( buf_c-wth-line ) = v-line-rec NO-ERROR.
    MESSAGE
      "Это" ( IF par-action = "B-Next":U THEN "последняя" ELSE "первая" )
      "строка в документе!"
    VIEW-AS ALERT-BOX INFORMATION.
    RETURN NO-APPLY.
  END.
END PROCEDURE.
