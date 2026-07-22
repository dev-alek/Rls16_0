define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закачка данных для КАНру ".
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
define variable v_os-file as char no-undo.
DEFINE BUTTON b-exit
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл для импорта"
     VIEW-AS FILL-IN
     SIZE 52.5 BY 1 NO-UNDO.
DEFINE VARIABLE Tumbler AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "В справочник товаров", 1,
          "В ДНЦ", 2
     SIZE 24.5 BY 2 NO-UNDO.
DEFINE FRAME Dialog-Frame
     file-name AT ROW 2.27 COL 1
     B-file AT ROW 2.27 COL 71.5
     Tumbler AT ROW 5 COL 24 NO-LABEL
     b-exit AT ROW 7.5 COL 16
     b-quit AT ROW 7.5 COL 41
     "              Куда будем импортировать данные из файла" VIEW-AS TEXT
          SIZE 73.5 BY 1 AT ROW 3.5 COL 1
          BGCOLOR 8
     "          Укажите файл из которого необходимо произвести импорт" VIEW-AS TEXT
          SIZE 73.5 BY .67 AT ROW 1.27 COL 1
          BGCOLOR 8
     SPACE(0.24) SKIP(7.30)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт из текстового файла (;)"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    assign
        Tumbler.
    if  trim(file-name) = "" then do:
            message "Не задан файл для импорта "
            view-as alert-box ERROR.
            return no-apply.
    end.
    if Tumbler = 1 then do:
          run cus/imp-kan2.w (  input parparentproc
                               ,INPUT v_os-file ) no-error.
    end.
    else do:
          run cus/imp-kan3.p ( input parparentproc
                               ,INPUT v_os-file ) no-error.
    end.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
  define variable ll_commit AS LOG    NO-UNDO INIT NO.
  SYSTEM-DIALOG GET-FILE v_os-file
  TITLE "Выберите файл для импорта"
  FILTERS "Текстовый файл (*.txt)" "*.txt",
          "CSV(MS-DOS) (*.csv)" "*.csv",
          "Все файлы (*.*)"        "*.*"
  MUST-EXIST
  USE-FILENAME
  update ll_commit
  default-extension "txt"
  .
  IF ll_commit <> YES THEN do:
      RETURN NO-APPLY.
  end.
  IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
      BELL.
      MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  ASSIGN
  file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
  DISPlay
  file-name
  WITH FRAME Dialog-Frame.
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY file-name Tumbler
      WITH FRAME Dialog-Frame.
  ENABLE B-file Tumbler b-exit b-quit
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
