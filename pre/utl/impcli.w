define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита закачки дисконтных карт и клиентов-интерфейс".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable dops0 as character no-undo format "X(8)".
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable dopsp as character no-undo format "X(10)".
define variable cards as char no-undo.
define variable cli-grp-code like cli-grp.node-code no-undo.
define variable globalcard as logical no-undo.
define variable ii as integer no-undo.
define variable dc-type-type as char no-undo.
define variable v-curr-db-num like ub.db.db-num no-undo .
 DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
DEFINE VARIABLE  v-num-mandatory-fields AS INTEGER NO-UNDO.
DEFINE TEMP-TABLE conf-import NO-UNDO
FIELD subject AS CHARACTER
FIELD table-name AS CHARACTER
FIELD field-name AS CHARACTER
FIELD is-mandatory AS LOGICAL
FIELD to-import AS LOGICAL
FIELD field-label AS CHARACTER
FIELD position_ AS INTEGER
INDEX pi IS UNIQUE PRIMARY
subject
position_
.
DEFINE BUFFER firm_conf-import FOR conf-import.
DEFINE BUFFER person_conf-import FOR conf-import.
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
DEFINE BUTTON B-cli-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-down-firm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 4 BY 1.
DEFINE BUTTON b-down-person
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 4 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-up-firm
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4 BY 1.
DEFINE BUTTON b-up-person
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4 BY 1.
DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Необязательные поля следуют в строчке файла импорта за обязательными со строгим соблюдением задаваемой последовательности"
     VIEW-AS EDITOR NO-BOX
     SIZE 20 BY 5.2
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE cli-grp-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 40.8 BY 1 NO-UNDO.
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE Rs-uniq-method AS CHARACTER INITIAL "obj-name"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Название", "obj-name",
"INN+KPP", "inn+kpp"
     SIZE 21 BY 2.4 NO-UNDO.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 21 BY 5.67.
DEFINE VARIABLE delim AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "Точка с запятой(;)","Точка с запятой(;)",
                     "Тильда()","Тильда()",
                     "Табулятор(     )","Табулятор(     )",
                     "Excel", "Excel"
     SIZE 21.8 BY 2.8 NO-UNDO.
DEFINE QUERY BR-firm FOR
      firm_conf-import SCROLLING.
DEFINE QUERY BR-person FOR
      person_conf-import SCROLLING.
DEFINE BROWSE BR-firm
  QUERY BR-firm DISPLAY
      firm_conf-import.field-label FORMAT "X(25)" COLUMN-LABEL "Поле"
firm_conf-import.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
firm_conf-import.to-import COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
firm_conf-import.to-import
    WITH NO-ROW-MARKERS SEPARATORS SIZE 39 BY 18
         TITLE "Поля при импорте клиента типа ОРГАНИЗАЦИЯ" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE BROWSE BR-person
  QUERY BR-person DISPLAY
      person_conf-import.field-label COLUMN-LABEL "Поле" FORMAT "X(25)"
person_conf-import.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
person_conf-import.to-import COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
person_conf-import.to-import
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 18
         TITLE "Поля при импорте клиента типа ФИЗ.ЛИЦО" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 95
     B-cli-grp AT ROW 2.07 COL 94.3
     file-name AT ROW 2.87 COL 2.1 NO-LABEL
     B-file AT ROW 2.93 COL 28
     b-up-firm AT ROW 3.93 COL 31.5 WIDGET-ID 2
     b-down-firm AT ROW 3.93 COL 35.5 WIDGET-ID 6
     b-up-person AT ROW 3.93 COL 65 WIDGET-ID 4
     b-down-person AT ROW 3.93 COL 69 WIDGET-ID 8
     BR-firm AT ROW 5 COL 23.5 WIDGET-ID 200
     BR-person AT ROW 5 COL 63 WIDGET-ID 300
     delim AT ROW 6.8 COL 1.5 NO-LABEL
     EDITOR-1 AT ROW 9.93 COL 2.4 NO-LABEL
     Rs-uniq-method AT ROW 16.47 COL 1.5 NO-LABEL WIDGET-ID 10
     cli-grp-name AT ROW 2.03 COL 53.1 NO-LABEL
     "Файл импорта" VIEW-AS TEXT
          SIZE 19 BY .77 AT ROW 2.07 COL 2
          FGCOLOR 4
     "по умолчанию" VIEW-AS TEXT
          SIZE 19 BY .77 AT ROW 2.93 COL 33.4
          FGCOLOR 4
     "Группа клиента" VIEW-AS TEXT
          SIZE 19 BY .8 AT ROW 2.07 COL 33.5
          FGCOLOR 4
     "колонок" VIEW-AS TEXT
          SIZE 19 BY .97 AT ROW 5.2 COL 2.1
          FGCOLOR 4
     "Символ-разделитель" VIEW-AS TEXT
          SIZE 20 BY .97 AT ROW 4.2 COL 2.1
          FGCOLOR 4
     RECT-7 AT ROW 9.8 COL 1.6
     SPACE(84.49) SKIP(7.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт клиентов"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-cli-grp IN FRAME Dialog-Frame
DO:
    define variable rid-list as char no-undo.
    run ref/cli-grps.w ( input parparentproc
                        ,input ('терм':U + chr(44) + "b-sel")
                        ,input-output rid-list).
    if rid-list <> "" then do:
        FIND FIRST cli-grp NO-LOCK WHERE recid(cli-grp) = integer(rid-list) NO-ERROR.
        IF NOT AVAIL cli-grp then return no-apply.
        assign
        cli-grp-code = cli-grp.node-code
        cli-grp-name = cli-grp.node-name
        .
        DISPLAY
        cli-grp-name
        WITH FRAME Dialog-Frame.
    end.
END.
ON CHOOSE OF b-down-firm IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.
  IF NOT AVAILABLE firm_conf-import  THEN RETURN NO-APPLY.
  DO TRANSACTION:
     v-rec = recid(firm_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = 'firm':U
          AND buf1_conf-import.POSITION_ = firm_conf-import.POSITION_.
    FIND FIRST buf2_conf-import WHERE
             buf2_conf-import.subject = 'firm':U
         AND buf2_conf-import.POSITION_ > firm_conf-import.POSITION_ NO-ERROR.
    IF NOT AVAILABLE buf2_conf-import THEN DO:
        BELL.
        RETURN NO-APPLY.
    END.
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = 'firm':U
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.
  END.
  OPEN QUERY BR-firm FOR EACH firm_conf-import WHERE firm_conf-import.subject = 'firm':U.
  REPOSITION br-firm TO RECID v-rec NO-ERROR.
  apply "entry" TO br-firm.
END.
ON CHOOSE OF b-down-person IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.
  IF NOT AVAILABLE person_conf-import  THEN RETURN NO-APPLY.
  DO TRANSACTION:
     v-rec = recid(person_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = 'person':U
          AND buf1_conf-import.POSITION_ = person_conf-import.POSITION_.
    FIND FIRST buf2_conf-import WHERE
             buf2_conf-import.subject = 'person':U
         AND buf2_conf-import.POSITION_ > person_conf-import.POSITION_ NO-ERROR.
    IF NOT AVAILABLE buf2_conf-import THEN DO:
        BELL.
        RETURN NO-APPLY.
    END.
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = 'person':U
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.
  END.
  OPEN QUERY BR-person FOR EACH person_conf-import WHERE person_conf-import.subject = 'person':U.
  REPOSITION br-person TO RECID v-rec NO-ERROR.
  apply "entry" TO br-person.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable firm-pairs as char no-undo.
define variable person-pairs as char no-undo.
define variable mydelimiter as char no-undo.
DEFINE BUFFER buf_conf-import FOR conf-import.
  assign
  file-name
  delim
  rs-uniq-method
  .
  if search(file-name) = ? then do:
    message "Не выбран файл импорта"
    view-as alert-box ERROR.
    return no-apply.
  end.
  if delim = "" then do:
    message "Не выбран символ-разделитель колонок в файле импорта!"
    view-as alert-box.
    return no-apply.
  end.
  FIND FIRST cli-grp No-LOCK WHERE cli-grp.node-code = cli-grp-code No-ERROR.
  IF NOT avail cli-grp then do:
    message "Не выбрана группа клиентов или группа клиентов неверна!"
    view-as alert-box error.
      return no-APPLY.
  end.
  assign
  mydelimiter = delim
  mydelimiter = if mydelimiter = "~t":U
                then chr(9)
                else mydelimiter
 .
FOR EACH buf_conf-import WHERE
   buf_conf-import.subject = 'firm':U
AND buf_conf-import.to-import = YES
BY buf_conf-import.subject
BY buf_conf-import.POSITION_
:
   ASSIGN
   firm-pairs = firm-pairs + (IF firm-pairs = '':U THEN '':U ELSE chr(47)) + buf_conf-import.field-name.
END.
FOR EACH buf_conf-import WHERE
   buf_conf-import.subject = 'person':U
AND buf_conf-import.to-import = YES
BY buf_conf-import.subject
BY buf_conf-import.POSITION_
:
  ASSIGN
  person-pairs = person-pairs + (IF person-pairs = '':U THEN '':U ELSE chr(47)) + buf_conf-import.field-name.
END.
ASSIGN
firm-pairs = RIGHT-TRIM(firm-pairs, chr(47))
person-pairs = RIGHT-TRIM(person-pairs, chr(47))
.
run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'utl/incli.p':U
              , input (file-name                        + chr(4) +
                 string(cli-grp-code)             + chr(4) +
                 mydelimiter                      + chr(4) +
                 rs-uniq-method                   + chr(4) +
                 firm-pairs                        + chr(4) +
                 person-pairs                      )
              , INPUT no
              , INPUT "&Стоп"
              , INPUT 'Импорт клиентов') .
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
      define variable ff as character no-undo.
    define variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
        " Все текстовые файлы (*.txt) " "*.txt",
        "excel (*.xls , *xlsx)"   "*.xls, *xlsx",
        " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".txt"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF b-up-firm IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.
  IF NOT AVAILABLE firm_conf-import  THEN RETURN NO-APPLY.
  IF firm_conf-import.POSITION_ =  1 THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  DO TRANSACTION:
     v-rec = recid(firm_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = 'firm':U
          AND buf1_conf-import.POSITION_ = firm_conf-import.POSITION.
    FIND last buf2_conf-import WHERE
             buf2_conf-import.subject = 'firm':U
         AND buf2_conf-import.POSITION_ < firm_conf-import.POSITION .
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = 'firm':U
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.
  END.
OPEN QUERY BR-firm FOR EACH firm_conf-import WHERE firm_conf-import.subject = 'firm':U.
  REPOSITION br-firm TO RECID v-rec NO-ERROR.
  apply "entry" TO br-firm.
END.
ON CHOOSE OF b-up-person IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.
  IF NOT AVAILABLE person_conf-import  THEN RETURN NO-APPLY.
  IF person_conf-import.POSITION_ =  1 THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  DO TRANSACTION:
     v-rec = recid(person_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = 'person':U
          AND buf1_conf-import.POSITION_ = person_conf-import.POSITION.
    FIND LAST buf2_conf-import WHERE
             buf2_conf-import.subject = 'person':U
         AND buf2_conf-import.POSITION_ < person_conf-import.POSITION .
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = 'person':U
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.
  END.
  OPEN QUERY BR-person FOR EACH person_conf-import WHERE person_conf-import.subject = 'person':U.
  REPOSITION br-person TO RECID v-rec NO-ERROR.
  apply "entry" TO br-person.
END.
ON VALUE-CHANGED OF BR-firm IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE firm_conf-import
  OR (AVAILABLE firm_conf-import AND firm_conf-import.is-mandatory) = YES THEN DO:
      ASSIGN
      firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = YES.
  END.
  ELSE DO:
      ASSIGN
      firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = NO.
  END.
END.
ON VALUE-CHANGED OF BR-person IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE person_conf-import
  OR (AVAILABLE person_conf-import AND person_conf-import.is-mandatory) = YES THEN DO:
      ASSIGN
      person_conf-import.to-import:READ-ONLY IN BROWSE br-person = YES.
  END.
  ELSE DO:
      ASSIGN
      person_conf-import.to-import:READ-ONLY IN BROWSE br-person = NO.
  END.
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
ON ROW-DISPLAY OF br-firm IN frame Dialog-Frame
DO:
  IF AVAIL firm_conf-import THEN DO:
    RUN set-row-color-firm IN THIS-PROCEDURE ( INPUT firm_conf-import.is-mandatory).
  END.
END.
ON ROW-DISPLAY OF br-person IN frame Dialog-Frame
DO:
  IF AVAIL person_conf-import THEN DO:
    RUN set-row-color-person IN THIS-PROCEDURE (INPUT person_conf-import.is-mandatory).
  END.
END.
ON "leave" OF firm_conf-import.to-import  IN BROWSE br-firm
DO:
   IF firm_conf-import.is-mandatory = YES
   and firm_conf-import.to-import = no
   THEN DO:
    BELL.
    assign
    firm_conf-import.to-import = yes.
    display
    firm_conf-import.to-import
    with browse br-firm.
  END.
END.
ON "leave" OF person_conf-import.to-import  IN BROWSE br-person
DO:
   IF person_conf-import.is-mandatory = YES
   and person_conf-import.to-import = no
   THEN DO:
    BELL.
    assign
    person_conf-import.to-import = yes.
    display
    person_conf-import.to-import
    with browse br-person.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
FIND FIRST db WHERE db.db-num = v-curr-db-num NO-LOCK .
if NOT  db.add-clients  OR NOT v-curr-db-num = 0 then do:
    message "Импорт клиентов возможен только в ГБД"  skip
            "и БД, в которых разрешен ввод клиентов"
    view-as alert-box ERROR.
    return.
end.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-firm :handle
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
  RUN fill-conf-import IN THIS-PROCEDURE.
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY file-name delim EDITOR-1 Rs-uniq-method cli-grp-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-7 B-quit B-help B-cli-grp file-name B-file b-up-firm
         b-down-firm b-up-person b-down-person BR-firm BR-person delim EDITOR-1
         Rs-uniq-method cli-grp-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-firm FOR EACH firm_conf-import WHERE firm_conf-import.subject = 'firm':U.    OPEN QUERY BR-person FOR EACH person_conf-import WHERE person_conf-import.subject = 'person':U.
END PROCEDURE.
PROCEDURE fill-conf-import :
DEFINE VARIABLE v-position-firm AS INTEGER NO-UNDO.
DEFINE VARIABLE v-position-person AS INTEGER NO-UNDO.
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "OBJ-TYPE"                          conf-import.field-label = "Тип клиента"                       conf-import.is-mandatory = YES                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "OBJ-TYPE"                          conf-import.field-label = "Тип клиента"                       conf-import.is-mandatory = YES                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "OBJ-code"                          conf-import.field-label = "Код клиента"                       conf-import.is-mandatory = YES                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "OBJ-code"                          conf-import.field-label = "Код клиента"                       conf-import.is-mandatory = YES                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "OBJ-name"                          conf-import.field-label = "Название"                       conf-import.is-mandatory = YES                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "OBJ-name"                          conf-import.field-label = "Название"                       conf-import.is-mandatory = YES                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "inn"                          conf-import.field-label = "ИНН"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "okpo"                          conf-import.field-label = "ОКПО"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "okonh"                          conf-import.field-label = "ОКОНХ"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "kpp"                          conf-import.field-label = "КПП"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "phone"                          conf-import.field-label = "№ телефона"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "phone-note"                          conf-import.field-label = "Примеч. к № телефона"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "fax"                          conf-import.field-label = "№ факса"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "e-mail"                          conf-import.field-label = "E-mail"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "city"                          conf-import.field-label = "Город"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "ind"                          conf-import.field-label = "Почтовый индекс"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "addres1"                          conf-import.field-label = "Юридический адрес 1"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "addres2"                          conf-import.field-label = "Юридический адрес 2"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "post-addr1"                          conf-import.field-label = "Почтовый адрес 1"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "post-addr2"                          conf-import.field-label = "Почтовый адрес 2"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "telex"                          conf-import.field-label = "Телекс"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "engl-name"                          conf-import.field-label = "Английское название"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "director"                          conf-import.field-label = "Руководитель"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "contact-psn"                          conf-import.field-label = "Контактное лицо"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "is-pboul"                          conf-import.field-label = "ПБОЮЛ"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'firm':U                          conf-import.field-name = "tobj-code"                          conf-import.field-label = "Код торгового представителя"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "reg-code"                          conf-import.field-label = "Код региона"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'firm':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "parus-2-code"                          conf-import.field-label = "Код во классиф.ПАРУС-2"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "inn"                          conf-import.field-label = "ИНН"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "okpo"                          conf-import.field-label = "ОКПО"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "okonh"                          conf-import.field-label = "ОКОНХ"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "kpp"                          conf-import.field-label = "КПП"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "phone1"                          conf-import.field-label = "№ телефона"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "phone1-note"                          conf-import.field-label = "Примеч. к № телефона"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "fax"                          conf-import.field-label = "№ факса"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "e-mail"                          conf-import.field-label = "E-mail"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "city"                          conf-import.field-label = "Город"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "ind"                          conf-import.field-label = "Почтовый индекс"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "address"                          conf-import.field-label = "Почтовый адрес"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "name1"                          conf-import.field-label = "Имя"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "name2"                          conf-import.field-label = "Отчество"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "passp-ser"                          conf-import.field-label = "Серия паспорта"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "passp-num"                          conf-import.field-label = "№ паспорта"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "given-by"                          conf-import.field-label = "Паспорт выдан"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "position"                          conf-import.field-label = "Должность"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "firm-name"                          conf-import.field-label = "Организация"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "firm-code"                          conf-import.field-label = "Код организации"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "post-box"                          conf-import.field-label = "Абонентский п/я"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'person':U                          conf-import.field-name = "is-pboul"                          conf-import.field-label = "ПБОЮЛ"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "reg-code"                          conf-import.field-label = "Код региона"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
CREATE conf-import.                                               ASSIGN                                                            conf-import.subject = 'person':U                                conf-import.table-name = 'clients':U                          conf-import.field-name = "parus-2-code"                          conf-import.field-label = "Код во классиф.ПАРУС-2"                       conf-import.is-mandatory = NO                      conf-import.to-import = (IF conf-import.is-mandatory = YES                                 THEN  YES                                                         ELSE NO)                                 conf-import.POSITION_ = (IF conf-import.subject = 'firm':U                           THEN v-position-firm + 1                                           ELSE v-position-person + 1)                   v-position-firm =  (IF conf-import.subject = 'firm':U               THEN v-position-firm + 1                                             ELSE v-position-firm)                                   v-position-person =  (IF conf-import.subject = 'person':U             THEN v-position-person + 1                                           ELSE v-position-person).
END PROCEDURE.
PROCEDURE MyENable :
assign
delim:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = "Точка с запятой (;)" + chr(44) + ";" + chr(44) +
                         "Тильда (~)" + chr(44) + "~~" + chr(44) +
                          "Табулятор" + chr(44) + "~t" + chr(44) + "Excel(xls)"  + chr(44) + "xls"
.
ASSIGN
firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = YES
person_conf-import.to-import:READ-ONLY IN BROWSE br-person = YES
rs-uniq-method:radio-buttons = "Название" + chr(44) + "obj-name" + chr(44) +
                               "ИНН" + "+" + "КПП" + chr(44) + "inn+kpp".
.
DISPLAY
file-name
EDITOR-1
delim
cli-grp-name
rs-uniq-method
WITH FRAME Dialog-Frame.
ENABLE
b-up-firm
b-down-firm
b-up-person
b-down-person
b-exit
RECT-7
B-quit
B-help
B-cli-grp
file-name
B-file
BR-firm
BR-person
EDITOR-1
delim
cli-grp-name
rs-uniq-method
WITH FRAME Dialog-Frame.
OPEN QUERY BR-firm FOR EACH firm_conf-import WHERE firm_conf-import.subject = 'firm':U.    OPEN QUERY BR-person FOR EACH person_conf-import WHERE person_conf-import.subject = 'person':U.
apply "value-changed" to br-firm.
apply "value-changed" to br-person.
END PROCEDURE.
PROCEDURE set-row-color-firm :
DEFINE INPUT PARAMETER p-is-mandatory AS LOGICAL NO-UNDO.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.
  IF p-is-mandatory = YES THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = GREY_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
ASSIGN
firm_conf-import.field-label:FGCOLOR IN BROWSE br-firm = iFGColor
firm_conf-import.field-label:BGCOLOR IN BROWSE br-firm = iBGColor
.
END PROCEDURE.
PROCEDURE set-row-color-person :
DEFINE INPUT PARAMETER p-is-mandatory AS LOGICAL NO-UNDO.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.
  IF p-is-mandatory = YES THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = GREY_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
ASSIGN
person_conf-import.field-label:FGCOLOR IN BROWSE br-person = iFGColor
person_conf-import.field-label:BGCOLOR IN BROWSE br-person = iBGColor
.
END PROCEDURE.
