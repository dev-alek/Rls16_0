define input parameter is-full as logical.
define output parameter parrid as recid initial ? no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр справочника кодов ТНВЭД СНГ".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
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
     LABEL "&Выход ":L
     SIZE 9 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 9 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9 BY 1.
DEFINE QUERY br-tnved FOR TT-tnved SCROLLING.
DEFINE VARIABLE varEmptyString AS CHAR INITIAL "______ " NO-UNDO.
DEFINE VARIABLE loc-tnv AS CHAR FORMAT "X(9)" NO-UNDO.
DEFINE BROWSE br-tnved QUERY br-tnved NO-LOCK DISPLAY
SUBSTRING(varEmptyString, 1, 10 - LENGTH(TT-tnved.tnved)) +
TT-tnved.tnved @ TT-tnved.tnved TT-tnved.f-name FORMAT 'X(255)'
WITH SIZE 96 BY 19 separators.
DEFINE FRAME frame-tnved
b-exit  AT ROW 1 COL 1
b-sel   AT ROW 1 COL 11
b-help  AT ROW 1 COL 21
br-tnved AT ROW 2 COL 1
loc-tnv NO-LABEL AT ROW 21.5 COL 1
WITH KEEP-TAB-ORDER VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE
SIZE 98 BY 23 TITLE "СПРАВОЧНИК ТНВЭД".
ASSIGN FRAME frame-tnved:SCROLLABLE       = FALSE.
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame frame-tnved anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame frame-tnved. END.
  return no-apply.
end.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame frame-tnved anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame frame-tnved. END.
  return no-apply.
end.
on choose of b-sel in frame frame-tnved do:
   if not available TT-tnved then do:   message "Неправильно выбран код ТНВЭД.".   return no-apply. end.
   parrid = recid (TT-tnved).
end.
on choose of b-exit in frame frame-tnved do:
   parrid = ?.
end.
ON MOUSE-SELECT-DBLCLICK, return of browse br-tnved DO:
   APPLY "choose" to b-sel in FRAME frame-tnved.
   RETURN NO-APPLY.
END.
on any-printable of browse br-tnved do:
 find first TT-tnved where TT-tnved.tnved begins (loc-tnv + last-event:label) no-lock no-error.
 if available TT-tnved then do:
    loc-tnv = loc-tnv + last-event:label.
    disp loc-tnv with frame frame-tnved.
    reposition br-tnved to recid RECID(TT-tnved) no-error.
  end.
end.
on backspace of browse br-tnved do:
    loc-tnv = substr (loc-tnv, 1, length (loc-tnv) - 1).
    find first TT-tnved where TT-tnved.tnved begins loc-tnv no-lock.
    disp loc-tnv with frame frame-tnved.
    if available TT-tnved then reposition br-tnved to recid RECID(TT-tnved) no-error.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME frame-tnved:PARENT eq ?
THEN FRAME frame-tnved:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME frame-tnved APPLY "END-ERROR":U TO SELF.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame frame-tnved
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
on choose of b-help in frame frame-tnved
do:
  apply "help":u to frame frame-tnved .
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
                v-frame-width = frame frame-tnved:width - 0.3
                fh            = frame frame-tnved:first-child
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
run ui-on in this-procedure .
wait-for go of frame frame-tnved focus br-tnved.
run disable_ui in this-procedure .
PROCEDURE disable_UI :
  DISABLE ALL WITH FRAME frame-tnved.
  HIDE FRAME frame-tnved.
END PROCEDURE.
PROCEDURE UI-on :
   OPEN QUERY br-tnved   FOR EACH TT-tnved    WHERE NOT is-full OR LENGTH(TRIM(TT-tnved.tnved)) = 10   NO-LOCK.
   ENABLE ALL WITH FRAME frame-tnved.
   DISABLE loc-tnv WITH FRAME frame-tnved.
END PROCEDURE.
