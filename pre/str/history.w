define input parameter parparentproc as widget-handle no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр истории по таблицам".
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define temp-table ttHistory no-undo
  field fTable as character label "Таблица" format "X(15)"
  field fName  as character label "Наименование объекта" format "X(30)"
  field fProc  as character label "Процедура просмотра"
  field fLabel as character
  field fField as character
  field fType  as character
.
define stream inStr.
define variable mMode as character no-undo.
define variable mIdList as character no-undo.
DEFINE MENU POPUP-MENU-b-view
       MENU-ITEM m_one          LABEL "По одному объекту"
       MENU-ITEM m_all          LABEL "По всем объектам".
DEFINE BUTTON b-exit
     LABEL "Выход"
     SIZE 15 BY 1.14.
DEFINE BUTTON b-view
     LABEL "Просмотр"
     SIZE 15 BY 1.14.
DEFINE QUERY BROWSE-tables FOR
      ttHistory SCROLLING.
DEFINE BROWSE BROWSE-tables
  QUERY BROWSE-tables DISPLAY
      ttHistory.fTable
      ttHistory.fName
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84 BY 15.24 ROW-HEIGHT-CHARS .76 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.48 COL 3 WIDGET-ID 2
     b-view AT ROW 1.48 COL 20 WIDGET-ID 4
     BROWSE-tables AT ROW 3.14 COL 3 WIDGET-ID 200
     SPACE(1.59) SKIP(0.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История изменений"
         CANCEL-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.
ASSIGN
       b-view:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-view:HANDLE.
ASSIGN
   b-view:MENU-MOUSE = 1.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON RETURN OF BROWSE-tables IN FRAME Dialog-Frame
DO:
  apply "choose":U to b-view in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_all
DO:
  if not avail ttHistory then
    return no-apply.
  if ttHistory.fProc = "" then
  do:
    message "В настройках просмотра истории не задана процедура просмотра истории." skip
            "Обратитесь к разработчикам." view-as alert-box.
    return no-apply.
  end.
  if ttHistory.fField = "" then
    run getIdent in this-procedure (ttHistory.fTable).
  mMode = 'все':U.
  run runHistoryProc in this-procedure("", ttHistory.fProc ).
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
  define variable vIdent  as character no-undo.
  if not avail ttHistory then
    return no-apply.
  if ttHistory.fProc = "" then
  do:
    message "В настройках просмотра истории не задана процедура просмотра истории по одному объекту." skip
            "Обратитесь к разработчикам." view-as alert-box.
    return no-apply.
  end.
  if ttHistory.fField = "" then
    run getIdent in this-procedure (ttHistory.fTable).
  run str/histparam.w (ttHistory.fLabel, ttHistory.fType, output vIdent).
  if vIdent = "" then
    return no-apply.
  mMode = "one".
  run runHistoryProc in this-procedure(vIdent, ttHistory.fProc).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run getTables in this-procedure no-error.
  if error-status:error then return.
  find first sys-ctrl no-lock.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-view BROWSE-tables
      WITH FRAME Dialog-Frame.
  OPEN QUERY BROWSE-tables FOR EACH ttHistory by ttHistory.fTable.
END PROCEDURE.
PROCEDURE getIdent :
  define input parameter iTable as character no-undo.
  define buffer buf_ttHistory for ttHistory.
  define buffer buf_file  for ub._File.
  define buffer buf_field for ub._Field.
  define buffer buf_index for ub._Index.
  define buffer buf_index-field for ub._Index-Field.
  define variable vComma as character no-undo.
  find first buf_ttHistory where buf_ttHistory.fTable = iTable.
  for first buf_file no-lock where
          buf_file._file-name = iTable
     ,first buf_index no-lock where
            recid(buf_index) = buf_file._prime-index
     ,each  buf_index-field no-lock where
            buf_index-field._Index-recid = recid(buf_index)
     ,first buf_field no-lock where
            recid(buf_field) = buf_index-field._Field-recid
  :
    assign
      vComma = if buf_ttHistory.fField = "" then "" else ","
      buf_ttHistory.fField = substitute("&1&2&3", buf_ttHistory.fField, vComma, buf_field._Field-name)
      buf_ttHistory.fType  = substitute("&1&2&3", buf_ttHistory.fType, vComma, buf_field._Data-type)
      buf_ttHistory.fLabel  = substitute(
        "&1&2&3", buf_ttHistory.fLabel,
        vComma,
        if buf_field._Label <> "" and buf_field._Label <> ? then buf_field._Label else buf_field._Field-name
      )
    .
  end.
END PROCEDURE.
PROCEDURE getTables :
define variable vTable as character no-undo.
define variable vName  as character no-undo.
define variable vProc  as character no-undo.
if search("cmp\history.txt") = ? then
do:
  message substitute("Не найден файл настроек &1.","cmp\history.txt") view-as alert-box.
  return error.
end.
input stream inStr from value(search("cmp\history.txt")).
READ_FILE:
repeat:
  import stream inStr vTable vName vProc.
  if vTable begins "//" then next READ_FILE.
  create ttHistory.
  assign
    ttHistory.fTable    = vTable
    ttHistory.fName     = vName
    ttHistory.fProc     = vProc
  .
end.
input stream inStr close.
END PROCEDURE.
PROCEDURE runHistoryProc :
  define input parameter pIdent as character no-undo.
  define input parameter pProc  as character no-undo.
  case ttHistory.fType:
    when "character" then do:
      run value(pProc) (
        if pIdent <> "" then pIdent else ?,
        parparentproc,v-cntxt-host-code-obj,v-cntxt-obj-type,v-cntxt-obj-code,'',mMode,?,'','',sys-ctrl.db-num,?,input-output mIdList
      ).
    end.
    when "character,character" then do:
      run value(pProc) (
        if pIdent <> "" then entry(1,pIdent) else ?,
        if pIdent <> "" then entry(2,pIdent) else ?,
        parparentproc,v-cntxt-host-code-obj,v-cntxt-obj-type,v-cntxt-obj-code,'',mMode,?,'','',sys-ctrl.db-num,?,input-output mIdList
      ).
    end.
    when "integer,integer" then do:
      run value(pProc) (
        if pIdent <> "" then int(entry(1,pIdent)) else ?,
        if pIdent <> "" then int(entry(2,pIdent)) else ?,
        parparentproc,v-cntxt-host-code-obj,v-cntxt-obj-type,v-cntxt-obj-code,'',mMode,?,'','',sys-ctrl.db-num,?,input-output mIdList
      ).
    end.
    when "int64" then do:
      run value(pProc) (
        if pIdent <> "" then int64(pIdent) else ?,
        parparentproc,v-cntxt-host-code-obj,v-cntxt-obj-type,v-cntxt-obj-code,'',mMode,?,'','',sys-ctrl.db-num,?,input-output mIdList
      ).
    end.
    when "integer" then do:
      run value(pProc) (
        if pIdent <> "" then int(pIdent) else ?,
        parparentproc,v-cntxt-host-code-obj,v-cntxt-obj-type,v-cntxt-obj-code,'',mMode,?,'','',sys-ctrl.db-num,?,input-output mIdList
      ).
    end.
    otherwise do:
      message
        substitute("Для входных параметров типа &1 необходимо доработать вызов просмотра истории.", ttHistory.fType)
        view-as alert-box.
    end.
  end case.
END PROCEDURE.
