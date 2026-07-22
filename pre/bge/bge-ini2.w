DEF INPUT  PARAM strB AS CHAR.
DEF OUTPUT PARAM strQuest   AS CHAR INIT "CANCEL".
DEF OUTPUT PARAM strDIR     AS CHAR INIT "".
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Инициализация каталога BGE 2".
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
def var dir-type as char no-undo.
def var can-write as logical no-undo.
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
DEF VAR strParentDir    AS CHARACTER NO-UNDO.
DEF VAR OKpressed       AS LOGICAL INITIAL TRUE NO-UNDO.
DEF VAR intCount        AS INT NO-UNDO.
DEF VAR strForEd2  AS CHAR NO-UNDO.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 10 BY 1 TOOLTIP "Подтверждение выбора каталога"
     BGCOLOR 8 .
DEFINE BUTTON bt_DIR
     LABEL "Каталог"
     SIZE 10 BY 1 TOOLTIP "Выбрать каталог".
DEFINE VARIABLE EDITOR-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 34.75 BY 8.5
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE IMAGE IMAGE-1
     FILENAME "wizdone":U
     SIZE 25.5 BY 8.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     bt_DIR AT ROW 1.25 COL 21.5
     b-help AT ROW 1.25 COL 54
     EDITOR-2 AT ROW 3 COL 29.5 NO-LABEL
     IMAGE-1 AT ROW 3 COL 1
     SPACE(38.62) SKIP(0.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Установка каталога для внешней бухгалтерии"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       EDITOR-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  RUN existDIR (strDir, "frg-acc", OUTPUT okPressed).
  IF NOT okPressed THEN DO.
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  RUN existDIR (strDir + "\frg-acc", "dict", OUTPUT okPressed).
  IF NOT okPressed THEN DO.
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  RUN existDIR (strDir + "\frg-acc", "exp-acc", OUTPUT okPressed).
  IF NOT okPressed THEN DO.
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  RUN existDIR (strDir + "\frg-acc", "global", OUTPUT okPressed).
  IF NOT okPressed THEN DO.
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  ASSIGN
    strQuest = "OK".
END.
ON CHOOSE OF bt_DIR IN FRAME Dialog-Frame
DO:
    IF SESSION:DISPLAY-TYPE = "GUI":U
    THEN do:
        run gbl/dir-sel.p (
                        output strParentDir
                      , output dir-type
                      , output can-write
                            )
        .
        if can-write then OKpressed = true. else OKpressed = false.
    end.
    else do:
        update
            SKIP(2)
            SPACE(2) "Имя родительского каталога =" strParentDir SPACE(2)
            SKIP(2)
        with frame tty-frame
            view-as dialog-box no-labels
            title "Введите имя и нажмите <ENTER>"
        .
        message "Подтверждаете имя родительского каталога?" SKIP
            strParentDir
        view-as alert-box buttons ok-cancel update OKpressed.
    end.
    IF OKpressed = TRUE THEN DO.
            strDIR = strParentDir.
            IF strB = "bge" THEN
            EDITOR-2 = strForEd2 + chr(10) + chr(10) +
                    " Экспорт будет вестись в" + chr(10) +
                    " каталог " + strDIR + "\frg-acc"+ chr(10) +
                    " Подтверждение - кнопка <OK>," + chr(10) +
                    " отказ - кнопка <Отмена>".
            ELSE
            EDITOR-2 = strForEd2 + chr(10) + chr(10) +
                    " Фильтр будет храниться в" + chr(10) +
                    " каталоге " + strDIR + "\frg-acc" + chr(10) +
                    " Подтверждение - кнопка <OK>," + chr(10) +
                    " отказ - кнопка <Отмена>".
            DISPLAY EDITOR-2 WITH FRAME Dialog-Frame.
            ENABLE  btn_OK   WITH FRAME Dialog-Frame.
    END.
    ELSE DO.
        ASSIGN
            EDITOR-2 = strForEd2
            strDIR   = "".
        DISPLAY EDITOR-2 WITH FRAME Dialog-Frame.
        DISABLE btn_OK   WITH FRAME Dialog-Frame.
    END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
ASSIGN
  strForEd2 = IF strB = "bge" THEN
    " Кнопкой <Каталог> выберите" + chr(10) +
    " родительский каталог," + chr(10) +
    " в котором следует создать" + chr(10) +
    " каталог хранения экспортных" + chr(10) +
    " сумм и справочников (frg-acc)."
              ELSE
    " Кнопкой <Каталог> выберите" + chr(10) +
    " родительский каталог," + chr(10) +
    " в котором следует создать" + chr(10) +
    " каталог хранения фильтра для" + chr(10) +
    " документов IBS Trade (frg-acc)."
  FRAME Dialog-Frame:TITLE =  IF strB = "bge" THEN
    "Установка каталога для внешней бухгалтерии"
              ELSE
    "Установка каталога для хранения фильтра"
  EDITOR-2 = strForEd2
.
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
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY EDITOR-2
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel bt_DIR b-help EDITOR-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE existDIR :
DEF INPUT  PARAM strParentDir AS CHAR.
DEF INPUT  PARAM strNameDir   AS CHAR.
DEF OUTPUT PARAM bolDirExist  AS LOG INIT NO NO-UNDO.
DEF VAR strDirMembShortName  AS CHAR NO-UNDO.
DEF VAR strDirMembFullName   AS CHAR NO-UNDO.
DEF VAR strDirMembFlag       AS CHAR NO-UNDO.
DEF VAR intErrorStatus       AS INT INIT 0  NO-UNDO.
DEF VAR bolDirCreated        AS LOG INIT NO NO-UNDO.
DEF VAR strErrorStatus AS CHAR EXTENT 18 INIT [
    "Not owner",
    "No such file or directory",
    "Interrupted system call",
    "I/O error",
    "Bad file number",
    "No more processes",
    "Not enough core memory",
    "Permission denied",
    "Bad address",
    "File exists",
    "No such device",
    "Not a directory",
    "Is a directory",
    "File table overflow",
    "Too many open files",
    "File too large",
    "No space left on device",
    "Directory not empty"
] NO-UNDO.
    INPUT FROM OS-DIR (strParentDir).
    REPEAT.
        IMPORT strDirMembShortName strDirMembFullName strDirMembFLag.
        IF  CAPS(strDirMembShortName) = CAPS(strNameDir) AND
            CAPS(strDirMembFLag) = "D"
        THEN DO. bolDirExist = YES. LEAVE. END.
        ELSE NEXT.
    END.
    INPUT CLOSE.
    IF bolDirExist THEN RETURN.
    OS-CREATE-DIR value(strParentDir + "\" + strNameDir).
    if OS-ERROR > 0 then do:
            MESSAGE " Не могу создать каталог " +
                     strParentDir + "\" + strNameDir
            view-as alert-box title " Ошибка ".
        IF OS-ERROR <> 999 THEN DO.
            ASSIGN
                intErrorStatus = OS-ERROR
                EDITOR-2 = strForEd2 + "~012~012" +
                           " Ошибка создания каталога" + "~012 " +
                           strParentDir + "\" + strNameDir + "~012 " +
                           STRING(intErrorStatus, ">9") + " " +
                           strErrorStatus[intErrorStatus].
            DISPLAY EDITOR-2 WITH FRAME Dialog-Frame.
        END.
        return "ERROR".
    end.
END PROCEDURE.
