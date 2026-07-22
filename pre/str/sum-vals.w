define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор диапазонов сумм для почасового отчета по диапазонам сумм продаж ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
DEFINE SHARED temp-table sum-vals no-undo
field sum1   like ub.chk-doc.netto
field sum2   like ub.chk-doc.netto
field num-chk   like ub.inkas.num-chk extent 24
field tot like ub.inkas.num-chk
INDEX pi IS PRIMARY sum1 ASCENDING .
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable sum-step as decimal no-undo.
define variable sum-from as decimal no-undo.
define variable sum-to as decimal no-undo.
define variable sum-current as decimal no-undo.
define variable idec  as decimal no-undo.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON Btn-ALL
     LABEL "ВСЕ"
     SIZE 9.63 BY 1.08.
DEFINE BUTTON BTN-delete-all
     LABEL "ВСЕ"
     SIZE 9.13 BY 1.
DEFINE BUTTON BTN_Delete
     LABEL "Удалить"
     SIZE 9.5 BY 1.25.
DEFINE BUTTON Btn_EXIT
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON BTN_Select
     LABEL "Выбрать"
     SIZE 9.5 BY 1.25.
DEFINE VARIABLE SEL-0 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "0_10","10_20","20_30","30_40","40_50","50_60","60_70","70_80","80_90","90_100","100_150","150_200","200_300","300_400","400_500","500_1000","1000_1500","1500_2000","2000_3000","3000_4000","4000_5000","5000_7500","7500_10000","10000_10000000"
     SIZE 17 BY 7 TOOLTIP "Доступные диапазоны" NO-UNDO.
DEFINE VARIABLE SEL-1 AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 17 BY 7 TOOLTIP "Выбранные диапазоны" NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_EXIT AT ROW 1 COL 1
     B-help AT ROW 1 COL 31
     SEL-0 AT ROW 2.96 COL 2.13 NO-LABEL
     SEL-1 AT ROW 3.04 COL 29.5 NO-LABEL
     BTN_Select AT ROW 10.79 COL 4.5
     BTN_Delete AT ROW 10.79 COL 33
     BTN-delete-all AT ROW 12.25 COL 33.25
     Btn-ALL AT ROW 12.29 COL 4.5
     SPACE(33.86) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выберите диапазоны"
         DEFAULT-BUTTON Btn_EXIT.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn-ALL IN FRAME Dialog-Frame
DO:
define variable i as integer.
define variable sum-1 like ub.chk-doc.netto.
define variable sum-2 like ub.chk-doc.netto.
  do i = 1 to SEL-0:num-items:
      assign
      sum-1 = DEC(ENTRY(1,ENTRY(i,SEL-0:list-items),"_"))
      sum-2 = DEC(ENTRY(2,ENTRY(i,SEL-0:list-items),"_")).
      find first sum-vals where sum-vals.sum1 = sum-1 no-lock no-error.
      if not avail sum-vals then do:
          create sum-vals.
          assign sum1 = sum-1
             sum2 = sum-2.
          SEL-1:ADD-LAST(string(sum-1) + "_" + string(sum-2)).
      end.
  end.
  apply "entry" to sel-0.
END.
ON CHOOSE OF BTN-delete-all IN FRAME Dialog-Frame
DO:
  define variable for_sums as character.
  define variable i as integer.
  define variable j as integer.
  j = SEL-1:num-items.
  do i = 1 to j:
      for_sums = ENTRY(1,Sel-1:LIST-ITEMS).
      SEL-1:DELETE(1).
      FIND FIRST sum-vals where sum1 = DEC(ENTRY(1,for_sums,"_")) NO-ERROR.
      IF AVAILABLE sum-vals then delete sum-vals.
    end.
END.
ON CHOOSE OF BTN_Delete IN FRAME Dialog-Frame
DO:
  define variable for_sums as character.
  assign sel-1.
  for_sums = Sel-1.
  SEL-1:DELETE(for_sums).
  FIND FIRST sum-vals where sum1 = DEC(ENTRY(1,for_sums,"_")) NO-ERROR.
  IF AVAILABLE sum-vals then delete sum-vals.
  APPLY "ENTRY" to sel-1.
  APPLY "CURSOR-UP" to sel-1.
END.
ON CHOOSE OF BTN_Select IN FRAME Dialog-Frame
DO:
  define variable for_sums as char.
  define variable sum-1 like ub.chk-doc.netto.
  define variable sum-2 like ub.chk-doc.netto.
  assign SEl-0.
  assign
  sum-1 = DEC(ENTRY(1,SEL-0,"_"))
  sum-2 = DEC(ENTRY(2,SEl-0,"_")).
  find first sum-vals where sum-vals.sum1 = sum-1 no-lock no-error.
  if available sum-vals then do:
    bell.
    message "Этот диапазон уже выбран" .
    apply "entry" to sel-0.
    return.
  end.
  create sum-vals.
  assign sum1 = sum-1
         sum2 = sum-2.
  SEL-1:ADD-LAST(SEl-0).
  apply "entry" to sel-0.
END.
ON LEFT-MOUSE-DBLCLICK OF SEL-0 IN FRAME Dialog-Frame
DO:
     APPLY "CHOOSE" to Btn_select.
END.
ON DELETE-CHARACTER OF SEL-1 IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE" to BTN_Delete.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'report-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'sumvals':U  then  dops = thbjattr_thbj-attr.property-value-character.
    if thbjattr_thbj-attr.prop-code = 'sum-step':U then  sum-step = thbjattr_thbj-attr.property-value-decimal .
    if thbjattr_thbj-attr.prop-code = 'sum-from':U then  sum-from = thbjattr_thbj-attr.property-value-decimal .
    if thbjattr_thbj-attr.prop-code = 'sum-to':U   then  sum-to = thbjattr_thbj-attr.property-value-decimal .
  end.
  IF dops <> "" and dops <> ? and dops <> "0" then
  sel-0:list-items = dops.
  else do:
    assign
    sum-current = sum-from
    sel-0:list-items = "".
    DO while sum-current < sum-to:
          SEL-0:ADD-LAST(string(sum-current) + "_" + string(sum-current + sum-step)).
        assign
        sum-current = sum-current + sum-step.
    end.
  end.
  RUN enable_UI.
  for each sum-vals no-lock:
    sel-1:add-last(string(sum-vals.sum1) + "_" + string(sum-vals.sum2)).
  end.
  WAIT-FOR CHOOSE OF BTN_exit.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY SEL-0 SEL-1
      WITH FRAME Dialog-Frame.
  ENABLE Btn_EXIT B-help SEL-0 SEL-1 BTN_Select BTN_Delete BTN-delete-all
         Btn-ALL
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
