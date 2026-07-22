DEFINE NEW SHARED BUFFER X_chk-doc FOR ub.chk-doc.
define input parameter parparentproc AS WIDGET-HANDLE no-undo.
define input parameter p-mode as character no-undo .
define input parameter p-rid-list as character no-undo .
define input parameter p-chk-gds-rid-list  as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define parameter buffer t-doc for ub.trn-doc.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Закачка чеков в документ инвентаризации и/или обсчет строк" .
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable cas-shft as logical no-undo init no.
define variable l-shift-on as logical no-undo init no.
define variable conf-attr as char no-undo.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable glog as logical no-undo .
define variable v-rid-list as character no-undo .
define variable is-all as logical no-undo .
define variable v-chk-date as date no-undo .
define variable v-chk-time as integer no-undo .
define variable v-shift-date as date no-undo .
define variable v-shift-num as integer no-undo .
define variable v-shift-name               as character no-undo.
define variable v-shift-name-num           as character no-undo.
define buffer buf_chk-doc for ub.chk-doc.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE E-message AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.13
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE chk-amount AS INTEGER FORMAT "->>>9":U INITIAL 0
     LABEL "ВСЕГО Чеков по инвентар."
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE f-processed AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Просмотрено строк"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE f-processed-ok AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Обработано строк"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 3  NO-UNDO.
DEFINE VARIABLE f-shift-name AS CHARACTER FORMAT "X(3)":U
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-shift-num AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Пор. смены"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE time_ AS CHARACTER FORMAT "x(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 10.3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-get-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все свободные чеки по объекту с заданными условиями", "inc-invr",
"Чеки выборочно", "chk-docs"
     SIZE 70.5 BY 1.77 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 98 BY 1.87
     BGCOLOR 8 FGCOLOR 0 .
DEFINE NEW SHARED QUERY QUERY-chk-doc FOR
      X_chk-doc SCROLLING.
DEFINE FRAME d-chk
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 81
     RS-get-method AT ROW 2.27 COL 7 NO-LABEL
     chk-amount AT ROW 4.97 COL 26 COLON-ALIGNED
     f-processed AT ROW 4.97 COL 51.5 COLON-ALIGNED
     f-processed-ok AT ROW 4.97 COL 83.5 COLON-ALIGNED
     E-message AT ROW 6.6 COL 1 NO-LABEL
     ub.chk-doc.shift-date AT ROW 9 COL 43.5 COLON-ALIGNED FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          BGCOLOR 8 FGCOLOR 4
     f-shift-name AT ROW 9 COL 65.5 COLON-ALIGNED
     f-shift-num AT ROW 9 COL 83 COLON-ALIGNED
     ub.chk-doc.chk-num AT ROW 10.2 COL 8.3 COLON-ALIGNED FORMAT "->>>>>>9"
          VIEW-AS FILL-IN
          SIZE 7.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     time_ AT ROW 10.2 COL 40.5 COLON-ALIGNED
     ub.chk-doc.pay-desk AT ROW 11.43 COL 8.3 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.cashier AT ROW 11.43 COL 22.3 COLON-ALIGNED FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.doc-code AT ROW 11.43 COL 54.4 COLON-ALIGNED
          LABEL "Номер" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 19.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     RECT-1 AT ROW 4.47 COL 1
     SPACE(0.24) SKIP(6.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заполнение и/или обсчет документа инвентаризации по чекам инвентаризации":L.
ASSIGN
       FRAME d-chk:SCROLLABLE       = FALSE.
ASSIGN
       E-message:READ-ONLY IN FRAME d-chk        = TRUE.
ON END-ERROR OF FRAME d-chk
DO:
    apply "choose" to b-quit .
END.
ON CHOOSE OF b-exit IN FRAME d-chk
DO:
  run proc-b-run IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-quit IN FRAME d-chk
DO:
  if p-mode = 'ДОБАВЛЕНИЕ':U
  then return "cancell":U .
  else return '':U.
END.
ON LEAVE OF f-shift-name IN FRAME d-chk
DO:
  run proc-shift-name in this-procedure no-error .
  if error-status:error then do:
    return no-apply.
  end.
  display
  integer(f-shift-name) @ f-shift-num
  with frame d-chk .
END.
ON VALUE-CHANGED OF RS-get-method IN FRAME d-chk
DO:
   run IncProcStart in this-procedure ( input no).
   ASSIGN
   rs-get-method.
   CASE rs-get-method:
     WHEN "chk-docs" THEN DO:
        ASSIGN
        v-rid-list = "":U.
        run str/chk-docs.w (
                         input parparentproc
                        ,INPUT ('b-sel,b-mark':U )
                        ,INPUT "to-inv"
                        ,INPUT ?
                        ,INPUT t-doc.obj-type
                        ,INPUT t-doc.obj-code
                        ,INPUT t-doc.doc-code
                        ,INPUT '':U
                        ,input 0
                        ,INPUT ?
                        ,INPUT ?
                        ,input 0
                        ,output v-rid-list) no-error.
         IF v-rid-list = "":U  THEN DO:
             ASSIGN
             rs-get-method = "inc-invr".
             DISPLAY rs-get-method
             with frame d-chk
             .
             RETURN NO-APPLY.
         END.
       END.
       WHEN "inc-invr":U THEN DO:
           v-rid-list = "":U.
      END.
   END CASE.
END.
ON RETURN OF ub.chk-doc.shift-date IN FRAME d-chk
DO:
  apply "CHOOSE" to b-exit in frame d-chk.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-chk:PARENT eq ?
THEN FRAME d-chk:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-chk
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
on choose of b-help in frame d-chk
do:
  apply "help":u to frame d-chk .
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
                v-frame-width = frame d-chk:width - 0.3
                fh            = frame d-chk:first-child
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
ON WINDOW-CLOSE OF FRAME d-chk APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ДОБАВЛЕНИЕ':U
  then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type4 as character no-undo .
define variable v-value-character4 as character no-undo .
define variable v-value-date4 as date no-undo .
define variable v-value-decimal4 as decimal no-undo .
define variable v-value-integer4 as INTEGER no-undo .
define variable v-tth4 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character4
    ,output v-value-date4
    ,output v-value-decimal4
    ,output v-value-integer4
    ,output cas-shft
    ,output v-param-type4
    ,INPUT-OUTPUT table-handle v-tth4
    )  .
delete object v-tth4.
    .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if l-shift-on and not cas-shft then do:
      message
      "Внимание! На текущем объекте требуется использование смен" skip
      "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
      view-as alert-box ERROR.
      return ERROR.
    end.
  end.
  else do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ДОБАВЛЕНИЕ':U
  then do:
    FIND FIRST ub.shop WHERE ub.shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = t-doc.doc-code exclusive.
    for each buf_Chk-doc no-lock where
            buf_Chk-doc.out-code = t-doc.doc-code:
      assign
      chk-amount = chk-amount + 1
      .
    end.
  end.
  if p-mode = 'ПРОСМОТР':U then do:
    FIND FIRST shop WHERE shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST trn-doc no-lock WHERE trn-doc.doc-code = t-doc.doc-code.
  end.
  if l-shift-on then do:
    run gbl/factdate.p (
                       INPUT        t-doc.obj-type
                      ,INPUT        t-doc.obj-code
                      ,INPUT-OUTPUT v-chk-date
                      ,INPUT-OUTPUT v-chk-time
                      ,INPUT-OUTPUT v-shift-date
                      ,INPUT-OUTPUT v-shift-num
                      ,input-output v-shift-name
                      ,INPUT        YES
                        ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
       message
       error-status:get-message(1) SKIP
       return-value
       view-as alert-box error .
       UNDO MAIN-BLOCK, return error .
    END.
  end.
  else do:
    assign
    v-shift-date = t-doc.doc-date
    v-shift-num = 0
    .
  end.
  if can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = t-doc.doc-code ) then do:
    FIND FIRST ub.chk-doc WHERE ub.chk-doc.out-code = t-doc.doc-code use-index sale
    NO-LOCK .
    assign
    time_ = string( ub.chk-doc.chk-time, "HH:MM" )
    .
  end.
  run Myenable in this-procedure .
  if return-value = "cancell" then return "cancell".
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    run proc-b-run in this-procedure no-error.
    if error-status:error then do:
      message
      substitute("Ошибка при подсчете количеств по строкам чеков инвентаризации&1&2&1&3"
                , chr(10)
                , error-status:error
                , return-value )
      view-as alert-box error .
    end.
  end.
  else do:
    WAIT-FOR GO OF FRAME d-chk focus chk-doc.shift-date .
  end.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-chk.
END PROCEDURE.
PROCEDURE display-chk :
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
DISPLAY
p-chk-amount @ chk-amount
with frame d-chk.
if available X_chk-doc then
DISPLAY
X_chk-doc.cashier @ ub.chk-doc.cashier
X_chk-doc.shift-date @ ub.chk-doc.shift-date
X_chk-doc.chk-num    @ ub.chk-doc.chk-num
string( X_chk-doc.chk-time, "HH:MM" ) @ time_
X_chk-doc.office  @ ub.chk-doc.office
X_chk-doc.doc-code  @ ub.chk-doc.doc-code
X_chk-doc.pay-desk  @ ub.chk-doc.pay-desk
with frame d-chk.
END PROCEDURE.
PROCEDURE display-message :
DEFINE INPUT PARAMETER p-message AS CHARACTER NO-UNDO.
e-message:SCREEN-VALUE IN FRAME d-chk = p-message.
END PROCEDURE.
PROCEDURE display-processed :
DEFINE INPUT PARAMETER p-processed AS INTEGER NO-UNDO.
DISPLAY
p-processed @ f-processed
WITH FRAME d-chk.
END PROCEDURE.
PROCEDURE display-processed-ok :
DEFINE INPUT PARAMETER p-processed-ok AS INTEGER NO-UNDO.
DISPLAY
p-processed-ok @ f-processed-ok
WITH FRAME d-chk.
END PROCEDURE.
PROCEDURE Enable_UI :
  DISPLAY RS-get-method chk-amount f-processed f-processed-ok E-message
          f-shift-name f-shift-num time_
      WITH FRAME d-chk.
  IF AVAILABLE ub.chk-doc THEN
    DISPLAY ub.chk-doc.shift-date ub.chk-doc.chk-num ub.chk-doc.pay-desk
          ub.chk-doc.cashier ub.chk-doc.doc-code
      WITH FRAME d-chk.
  ENABLE b-exit RECT-1 b-quit b-help RS-get-method chk-amount f-processed
         f-processed-ok E-message ub.chk-doc.shift-date f-shift-name
         f-shift-num ub.chk-doc.chk-num time_ ub.chk-doc.pay-desk
         ub.chk-doc.cashier ub.chk-doc.doc-code
      WITH FRAME d-chk.
END PROCEDURE.
PROCEDURE IncProc :
define input parameter p-is-all as logical no-undo .
define variable v-ii     as integer no-undo .
define variable v-ii-ok  as integer no-undo .
define variable v-rc-ii as integer no-undo .
define variable v-rc-max as integer no-undo .
DEFINE VARIABLE v-query-prepare AS CHARACTER NO-UNDO.
define variable v-error-status as logical no-undo .
define variable v-error-status-message as character no-undo .
if rs-get-method = "inc-invr":U
then do:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    ASSIGN
    v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                              "X_chk-doc.obj-type = '&1'":U +
                              " AND X_chk-doc.obj-code = &2":U +
                              " AND X_chk-doc.out-code = ? and X_chk-doc.chk-type = &3", p-obj-type, p-obj-code, integer('11':U)).
    if l-shift-on then do:
      ASSIGN
      v-query-prepare = v-query-prepare +
                      substitute(" AND X_chk-doc.shift-date = &1 AND X_chk-doc.shift-num = &2"
                                , string(v-shift-date, "99/99/9999")
                                , v-shift-num).
    end.
    else do:
      if ub.shop.day-only then do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date = &1", string(v-shift-date, "99/99/9999")).
                          .
      end.
      else do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date <= &1", string(v-shift-date, "99/99/9999")).
      end.
    end.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    ASSIGN
    v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                              "X_chk-doc.out-code = '&1'":U, t-doc.doc-code  ).
  end.
  if rs-get-method = "chk-docs":U then do:
    assign
    v-query-prepare = v-query-prepare + substitute(" AND lookup(string(recid(X_chk-doc)), '&1') > 0 ", v-rid-list)
    .
  end.
  assign
  glog =
  QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare) No-error.
  IF not glog
  THEN DO:
    MESSAGE
    error-status:get-message(1) skip
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  assign
  glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
  IF not glog
  THEN DO:
      MESSAGE
      "Неверно выбран или построен ФИЛЬТР"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(no-LOCK) NO-ERROR.
  IF not glog THEN DO:
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      message
      "Нет чеков, удовлетворяющих условиям закачки в документ" skip
      view-as alert-box WARNING .
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      message
      "Нет чеков, в документе" skip
      view-as alert-box WARNING .
    end.
    RETURN.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
  do while locked (X_chk-doc ) and available X_chk-doc:
    glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
  end.
end.
else do:
  assign
  v-rc-max = num-entries(v-rid-list).
  _v-rc:
  do while v-rc-ii < v-rc-max:
    assign
    v-rc-ii = v-rc-ii + 1
    .
    find first X_chk-doc exclusive-lock where
              recid(X_chk-doc) = integer(entry(v-rc-ii, v-rid-list))  no-wait no-error.
    if locked X_chk-doc or not available X_chk-doc then do:
      next _v-rc.
    end.
    else leave _v-rc.
  end.
  if not available X_chk-doc
  or locked(X_chk-doc) then do:
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      message
      "Ни один из выбранных Вами чеков не может быть сейчас закачан в документ" skip
      "Возможно они заняты другим пользователем"
      view-as alert-box Warning.
    end.
    else do:
      message
      "Ни один из выбранных Вами чеков не может быть сейчас обсчитан" skip
      "Возможно они заняты другим пользователем"
      view-as alert-box Warning.
    end.
    return.
  end.
end.
run str/inc-invr.p (
                    input parparentproc
                  ,input this-procedure:handle
                  ,input p-is-all
                  ,input-output v-ii
                  ,input-output v-ii-ok
                  ,INPUT (IF rs-get-method = "chk-docs":U THEN v-rid-list ELSE "":U)
                  ,input p-chk-gds-rid-list
                  ,INPUT (IF p-mode = 'ДОБАВЛЕНИЕ':U THEN 0 ELSE 1)
                  ,input cas-shft
                  ,input chk-amount
                  ,input ub.shop.day-only
                  ,buffer t-doc
                  ) no-error.
assign
v-error-status = error-status:error
v-error-status-message = error-status:get-message(1)
.
if v-ii-ok <> 0 then do:
end.
if v-ii = 0 AND p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if v-error-status then
  message
  "Произошла ошибка при закачке чеков в инвентаризацию" skip
  v-error-status-message skip
  return-value
  view-as alert-box .
  else
  message
  "Нет чеков, удовлетворяющих условиям закачки в инвентаризацию" skip
  view-as alert-box WARNING .
end.
else do:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    message
    substitute("Просмотрено &1 чеков, успешно закачано в инвентаризацию &2", v-ii, v-ii-ok)
    view-as alert-box WARNING .
  end.
end.
END PROCEDURE.
PROCEDURE IncProcStart :
define input parameter p-run as logical no-undo .
if p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'ДОБАВЛЕНИЕ':U
then return.
define variable v-deleted as logical no-undo .
define variable v-dopi as integer no-undo .
define buffer buf_trn-doc for ub.trn-doc.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  if ub.shop.day-only then do:
    if can-find( first ub.chk-doc where
                     ub.chk-doc.obj-type = p-obj-type
                 and ub.chk-doc.obj-code = p-obj-code
                 and ub.chk-doc.out-code = ?
                 and ub.chk-doc.shift-date < t-doc.doc-date
                 and ub.chk-doc.chk-type = integer('11':U)
                 ) then  do:
      glog = yes.
      message substitute("Имеются чеки инвентаризации за более раннюю дату,&1" +
                         "не включенные ни в один документ.&1" +
                         "Не забудьте создать документ инвентаризации&1" +
                         "и включить в него эти чеки.&1&1" +
                         "Продолжать ?"
                         ,chr(10))
      view-as alert-box question buttons YES-NO update glog.
      if NOT glog then return error .
    end.
  end.
  else do:
    if can-find( first ub.trn-doc where ub.trn-doc.obj-type = p-obj-type and
                                 ub.trn-doc.obj-code = p-obj-code and
                                 ub.trn-doc.status_ = 'факт':U and
                                 ub.trn-doc.doc-date > t-doc.doc-date ) then do:
      glog = yes.
      message substitute("Уже имеется инвентаризация, содержащая чеки,&1"  +
                         "дата которых БОЛЬШЕ указанной Вами.&1"  +
                         "Вы уверены, что в базе появились новые чеки инвентаризации?&1"
                        , chr(10))
        view-as alert-box question buttons YES-NO update glog.
      if NOT glog then  return error .
    end.
  end.
END.
if p-run then
run IncProc in this-procedure ( input is-all).
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
rs-get-method = "inc-invr".
view frame d-chk .
DISPLAY
f-shift-num
f-shift-name
chk-amount
time_
rs-get-method
WITH FRAME d-chk .
IF AVAILABLE ub.chk-doc and p-mode <> 'ПРОСМОТР':U THEN
DISPLAY
ub.chk-doc.shift-date
ub.chk-doc.pay-desk
ub.chk-doc.cashier
ub.chk-doc.chk-num
ub.chk-doc.doc-code
WITH FRAME d-chk.
if p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'ДОБАВЛЕНИЕ':U
then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
ENABLE
RECT-1
b-help
b-exit when (p-mode= 'ИЗМЕНЕНИЕ':U or p-mode = 'ДОБАВЛЕНИЕ':U)
b-quit
rs-get-method when p-mode = 'ДОБАВЛЕНИЕ':U
WITH FRAME d-chk .
if p-mode <> 'ИЗМЕНЕНИЕ':U
and p-mode <> 'ДОБАВЛЕНИЕ':U
then do:
  hide
  b-exit in frame d-chk .
end.
assign
f-shift-num = if cas-shft or p-mode = 'ПРОСМОТР':U then v-shift-num else 0
f-shift-name = if cas-shft or p-mode = 'ПРОСМОТР':U then v-shift-name else '':U
.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
end.
DISPLAY
f-shift-num when (cas-shft or (p-mode = 'ПРОСМОТР':U and v-shift-num <> 0))
f-shift-name when (cas-shft or (p-mode = 'ПРОСМОТР':U and v-shift-name <> '':U))
v-shift-date @ chk-doc.shift-date
with frame d-chk.
DISABLE
chk-amount
WITH frame d-chk.
if p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ДОБАВЛЕНИЕ':U
then do:
  DISABLE
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.doc-code
  time_
  chk-doc.pay-desk
  WITH frame d-chk.
  if not cas-shft then
  HIDE
  f-shift-num
  f-shift-name
  in frame d-chk.
end.
else do:
  HIDE
  rs-get-method
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.doc-code
  time_
  chk-doc.pay-desk
  in frame d-chk.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  if p-rid-list <> '':U then do:
    v-rid-list = p-rid-list.
    assign
    rs-get-method = "chk-docs":U.
  end.
  else do:
    assign
    rs-get-method = "inc-invr":U.
  end.
  DISABLE
  rs-get-method
  b-exit b-quit
  WITH FRAME d-chk.
  HIDE
  b-exit b-quit
  rs-get-method
  IN FRAME d-chk.
end.
END PROCEDURE.
PROCEDURE proc-b-run :
define variable v-num as integer no-undo .
 if t-doc.status_ = 'разрешен':U then do:
  DO  on ERROR
  undo, return no-apply
  on STOP undo, return no-apply  :
      run gbl/d-askw.w (
         input "Вопрос"
        ,input "Выберите режим работы для обработки чеков." + chr(10)
        ,input "|^"
        ,input "Переписать|Прибавить|Спрашивать|Отмена"
        ,input "Переписать количество из чеков для всех товаров|"
            + "Прибавить количество из чеков для всех товаров|"
            + "Cпрашивать для каждого товара|"
            + "Отменить"
        ,input 1
        ,input 4
      ,output v-num
      ).
      case v-num :
        when 1 then do:
          assign is-all = yes.
        end.
        when 2 then do:
          assign is-all = no.
        end.
        when 3 then do:
          assign is-all = ?.
        end.
        otherwise do:
          if p-mode = 'ИЗМЕНЕНИЕ':U then return "cancell".
          return.
        end.
      end case.
    END.
  end.
  run IncProcStart IN THIS-PROCEDURE ( input yes) .
END PROCEDURE.
PROCEDURE proc-shift-name :
define variable v-dopi as integer no-undo .
assign
v-dopi = integer(f-shift-name:screen-value in frame d-chk )
no-error .
if error-status:error
or v-dopi <= 0
or v-dopi > 99 then do:
  message "Неверный номер смены!" view-as alert-box ERROR.
  return no-apply.
end.
END PROCEDURE.
