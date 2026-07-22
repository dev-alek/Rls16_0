define input parameter iAreaNumber as integer no-undo.
define temp-table ttObjects no-undo
  field fObjType as integer
  field fObjName as character
.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE viewIndex AS LOGICAL INITIAL no
     LABEL "показать индексы"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .81 NO-UNDO.
DEFINE QUERY br-list FOR
      ttObjects SCROLLING.
DEFINE BROWSE br-list
  QUERY br-list DISPLAY
      (if ttObjects.fObjType = 1 then "table" else "index") format "X(6)"
   column-label "Тип объекта"
 ttObjects.fObjName format "X(25)" column-label "Имя объекта"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.4 BY 10.95 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1.48 COL 3 WIDGET-ID 8
     viewIndex AT ROW 1.48 COL 34 WIDGET-ID 6
     br-list AT ROW 2.91 COL 2.6 WIDGET-ID 200
     SPACE(1.19) SKIP(0.75)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Состав области" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF viewIndex IN FRAME Dialog-Frame
DO:
  assign viewIndex.
 OPEN QUERY br-list FOR EACH ttObjects   where ttObjects.fObjType <= (if viewIndex then 2 else 1).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run getObjects in this-procedure.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY viewIndex
      WITH FRAME Dialog-Frame.
  ENABLE b-quit viewIndex br-list
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-list FOR EACH ttObjects   where ttObjects.fObjType <= (if viewIndex then 2 else 1).
END PROCEDURE.
PROCEDURE getObjects :
define buffer buf_StorageObject for ub._StorageObject.
define buffer buf_file for ub._File.
define buffer buf_index for ub._Index.
define variable vObjName as character no-undo.
for each buf_StorageObject no-lock where
         buf_StorageObject._Area-number = iAreaNumber
:
  vObjName = "".
  case buf_StorageObject._Object-type:
    when 1 then
    do:
      find first buf_file no-lock where
                 buf_file._file-number = buf_StorageObject._Object-number
      no-error.
      if avail buf_file then
        vObjName = buf_file._file-name.
    end.
    when 2 then
    do:
      find first buf_index no-lock where
                 buf_index._idx-num = buf_StorageObject._Object-number
      no-error.
      if avail buf_index then
        vObjName = buf_index._index-name.
    end.
  end case.
  if vObjName <> "" then
  do:
    create ttObjects.
    assign
      ttObjects.fObjType = buf_StorageObject._Object-type
      ttObjects.fObjName = vObjName
    .
  end.
end.
END PROCEDURE.
