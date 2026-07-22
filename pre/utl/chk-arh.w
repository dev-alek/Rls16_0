define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Жесткое архивирование чеков".
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
define stream exp-stream.
define variable rid-list as character no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
DEFINE BUTTON b-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.8 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE dirname AS CHARACTER FORMAT "X(256)":U INITIAL ".~\"
     LABEL "Каталог для архива"
     VIEW-AS FILL-IN
     SIZE 29.5 BY 1 NO-UNDO.
DEFINE VARIABLE i AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
     LABEL "Обработано"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE i-month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц архивации"
     VIEW-AS FILL-IN
     SIZE 3.1 BY 1 NO-UNDO.
DEFINE VARIABLE i-obj-code AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Код магазина"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE i-year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год архивации"
     VIEW-AS FILL-IN
     SIZE 4.8 BY 1 NO-UNDO.
DEFINE VARIABLE sh-name AS CHARACTER FORMAT "X(50)":U
     VIEW-AS FILL-IN
     SIZE 34.9 BY 1 NO-UNDO.
DEFINE VARIABLE T-del AS LOGICAL INITIAL no
     LABEL "С удалением чеков"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .87 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      ub.chk-doc SCROLLING.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 58 WIDGET-ID 2
     i-obj-code AT ROW 2.33 COL 13 COLON-ALIGNED
     b-obj AT ROW 2.4 COL 28.7
     sh-name AT ROW 2.4 COL 30.1 COLON-ALIGNED NO-LABEL
     i-month AT ROW 3.83 COL 16 COLON-ALIGNED
     i-year AT ROW 3.83 COL 33.5 COLON-ALIGNED
     i AT ROW 3.9 COL 50.6 COLON-ALIGNED
     dirname AT ROW 5.27 COL 19 COLON-ALIGNED
     b-dir AT ROW 5.27 COL 51
     ub.chk-doc.chk-date AT ROW 5.27 COL 59 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 10.9 BY 1
     T-del AT ROW 6.7 COL 2.5
     SPACE(48.89) SKIP(2.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Архивирование чеков"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-dir IN FRAME Dialog-Frame
DO:
    define variable v_os-file   AS CHAR NO-UNDO INIT "":U.
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-DIR v_os-file
        TITLE      "Выберите каталог для архива"
        UPDATE ll_commit.
    IF ll_commit <> YES THEN RETURN NO-APPLY.
    ASSIGN dirname = v_os-file + "\" .
    DISP dirname WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w ( input parparentproc
                     ,input "'ПРОСМОТР':U,b-sel"
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output rid-list) .
  if rid-list = "":U then return no-apply.
  find clients no-lock
    where recid(clients) = integer(rid-list)
    no-error
    .
  assign
    i-obj-code = clients.obj-code
    sh-name = clients.obj-name.
  disp
    i-obj-code
    sh-name
  with frame Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  assign
    i-obj-code
    i-month
    i-year
    dirname
    t-del.
  dirname = right-trim(dirname, "\").
  dirname = dirname + "\".
  find clients where clients.obj-type = 'маг':U and clients.obj-code = i-obj-code no-lock no-error.
  if not available clients then do:
    message "Неправильно задан объект" view-as alert-box error.
    return no-apply.
  end.
  sh-name = clients.obj-name.
  disp sh-name with frame Dialog-Frame.
  if i-month > 12 or i-month = 0 then do:
    message "Неправильно задан месяц архивации" view-as alert-box error.
    return no-apply.
  end.
  if i-year = 0  then do:
    message "Неправильно задан год архивации" view-as alert-box error.
    return no-apply.
  end.
  if (year(today) = i-year and month(today) <= i-month) or year(today) < i-year then do:
    message "Дата архива должна быть меньше текущей!" view-as alert-box error.
    return no-apply.
  end.
  if dirname = "" then dirname = ".\".
  if search( dirname + string(i-month, "99") + string(i-year) + ".txt") <> ? then do:
    message "Уже есть архив за этот месяц Переместите файл в другое место!" view-as alert-box error.
    return no-apply.
  end.
  run chk-out(t-del).
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
PROCEDURE chk-out :
define input parameter p-del as logical no-undo.
  ON DELETE of chk-doc override do: end.
  output stream exp-stream to value( dirname + string(i-month, "99") + string(i-year) + ".txt").
  put stream exp-stream unformatted
  i-obj-code chr(32)
  i-month chr(32)
  i-year chr(32)
  "v1.01"  skip(0).
  for each chk-doc where chk-doc.obj-type = 'маг':U and
                                      chk-doc.obj-code = i-obj-code and
                                      year(chk-doc.chk-date) = i-year and
                                      month(chk-doc.chk-date) = i-month
                                      use-index obj-date exclusive:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
export  stream exp-stream  "chk-doc"
  chk-doc.out-code chk-doc.doc-code
 .
export  stream exp-stream  ub.chk-doc.
      for each chk-gds where chk-gds.doc-code = chk-doc.doc-code exclusive-lock:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
export  stream exp-stream  "chk-gds"
 .
export  stream exp-stream  ub.chk-gds.
          if p-del then delete chk-gds.
      end.
      for each chk-pay where chk-pay.doc-code = chk-doc.doc-code exclusive-lock:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
export  stream exp-stream  "chk-pay"
 .
export  stream exp-stream  ub.chk-pay.
          if p-del then delete chk-pay.
      end.
      for each chk-discnt where chk-discnt.doc-code = chk-doc.doc-code exclusive-lock:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
export  stream exp-stream  "chk-discnt"
 .
export  stream exp-stream  ub.chk-discnt.
          if p-del then delete chk-discnt.
      end.
      for each chk-doc-attr where chk-doc-attr.doc-code = chk-doc.doc-code exclusive-lock:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
export  stream exp-stream  "chk-doc-attr"
 .
export  stream exp-stream  ub.chk-doc-attr.
          if p-del then delete chk-doc-attr.
      end.
     i = i + 1.
     disp i chk-doc.chk-date with frame Dialog-Frame .
     if p-del then delete chk-doc.
  end.
  output stream exp-stream close.
  ON DELETE of chk-doc revert.
  message "Архивация закончена. архив в каталоге " dirname view-as alert-box message.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH ub.chk-doc SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY i-obj-code sh-name i-month i-year i dirname T-del
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.chk-doc THEN
    DISPLAY ub.chk-doc.chk-date
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help i-obj-code b-obj i-month i-year dirname b-dir
         ub.chk-doc.chk-date T-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
