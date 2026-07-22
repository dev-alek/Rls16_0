&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

утилита закачки дисконтных карт и клиентов - интерфейсная часть

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита закачки дисконтных карт и клиентов-интерфейс".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }

{ cmp/library.i }
/*вспомогат*/
define variable dops0 as character no-undo format "X(8)".
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable dopsp as character no-undo format "X(10)".

/*список всех используемых на фирме типов карт*/
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

{ gbl/color.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-firm

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES firm_conf-import person_conf-import

/* Definitions for BROWSE BR-firm                                       */
&Scoped-define FIELDS-IN-QUERY-BR-firm firm_conf-import.field-label firm_conf-import.IS-MANDATORY firm_conf-import.to-import VIEW-AS TOGGLE-BOX
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-firm firm_conf-import.to-import
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-firm firm_conf-import
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-firm firm_conf-import
&Scoped-define SELF-NAME BR-firm
&Scoped-define QUERY-STRING-BR-firm FOR EACH firm_conf-import WHERE firm_conf-import.subject = {&table_firm}
&Scoped-define OPEN-QUERY-BR-firm OPEN QUERY {&SELF-NAME} FOR EACH firm_conf-import WHERE firm_conf-import.subject = {&table_firm}.
&Scoped-define TABLES-IN-QUERY-BR-firm firm_conf-import
&Scoped-define FIRST-TABLE-IN-QUERY-BR-firm firm_conf-import


/* Definitions for BROWSE BR-person                                     */
&Scoped-define FIELDS-IN-QUERY-BR-person person_conf-import.field-label person_conf-import.IS-MANDATORY person_conf-import.to-import VIEW-AS TOGGLE-BOX
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-person person_conf-import.to-import
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-person person_conf-import
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-person person_conf-import
&Scoped-define SELF-NAME BR-person
&Scoped-define QUERY-STRING-BR-person FOR EACH person_conf-import WHERE person_conf-import.subject = {&table_person}
&Scoped-define OPEN-QUERY-BR-person OPEN QUERY {&SELF-NAME} FOR EACH person_conf-import WHERE person_conf-import.subject = {&table_person}.
&Scoped-define TABLES-IN-QUERY-BR-person person_conf-import
&Scoped-define FIRST-TABLE-IN-QUERY-BR-person person_conf-import


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-firm}~
    ~{&OPEN-QUERY-BR-person}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-7 B-quit B-help B-cli-grp ~
file-name B-file b-up-firm b-down-firm b-up-person b-down-person BR-firm ~
BR-person delim EDITOR-1 Rs-uniq-method cli-grp-name
&Scoped-Define DISPLAYED-OBJECTS file-name delim EDITOR-1 Rs-uniq-method ~
cli-grp-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-firm FOR
      firm_conf-import SCROLLING.

DEFINE QUERY BR-person FOR
      person_conf-import SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-firm Dialog-Frame _FREEFORM
  QUERY BR-firm DISPLAY
      firm_conf-import.field-label FORMAT "X(25)" COLUMN-LABEL "Поле"
firm_conf-import.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
firm_conf-import.to-import COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
firm_conf-import.to-import
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 39 BY 18
         TITLE "Поля при импорте клиента типа ОРГАНИЗАЦИЯ" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BR-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-person Dialog-Frame _FREEFORM
  QUERY BR-person DISPLAY
      person_conf-import.field-label COLUMN-LABEL "Поле" FORMAT "X(25)"
person_conf-import.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
person_conf-import.to-import COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
person_conf-import.to-import
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 18
         TITLE "Поля при импорте клиента типа ФИЗ.ЛИЦО" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

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


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-firm b-down-person Dialog-Frame */
/* BROWSE-TAB BR-person BR-firm Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cli-grp-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-firm
/* Query rebuild information for BROWSE BR-firm
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH firm_conf-import WHERE firm_conf-import.subject = {&table_firm}.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-firm */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-person
/* Query rebuild information for BROWSE BR-person
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH person_conf-import WHERE person_conf-import.subject = {&table_person}.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-person */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт клиентов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-grp Dialog-Frame
ON CHOOSE OF B-cli-grp IN FRAME Dialog-Frame
DO:
    define variable rid-list as char no-undo.
    run ref/cli-grps.w ( input parparentproc
                        ,input ({&g#term} + {&comma-char} + "b-sel")
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
        WITH FRAME {&frame-name}.

    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down-firm Dialog-Frame
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
              buf1_conf-import.subject = {&TABLE_firm}
          AND buf1_conf-import.POSITION_ = firm_conf-import.POSITION_.
    FIND FIRST buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_firm}
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
                buf1_conf-import.subject = {&table_firm}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
  {&OPEN-QUERY-br-firm}
  REPOSITION br-firm TO RECID v-rec NO-ERROR.
  apply "entry" TO br-firm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down-person Dialog-Frame
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
              buf1_conf-import.subject = {&TABLE_person}
          AND buf1_conf-import.POSITION_ = person_conf-import.POSITION_.
    FIND FIRST buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_person}
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
                buf1_conf-import.subject = {&table_person}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
  {&OPEN-QUERY-br-person}
  REPOSITION br-person TO RECID v-rec NO-ERROR.
  apply "entry" TO br-person.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
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
                then {&tabulation}
                else mydelimiter
 .
FOR EACH buf_conf-import WHERE
   buf_conf-import.subject = {&table_firm}
AND buf_conf-import.to-import = YES
BY buf_conf-import.subject
BY buf_conf-import.POSITION_

:
   ASSIGN
   firm-pairs = firm-pairs + (IF firm-pairs = '':U THEN '':U ELSE {&slash-char}) + buf_conf-import.field-name.
END.
FOR EACH buf_conf-import WHERE
   buf_conf-import.subject = {&table_person}
AND buf_conf-import.to-import = YES
BY buf_conf-import.subject
BY buf_conf-import.POSITION_
:
  ASSIGN
  person-pairs = person-pairs + (IF person-pairs = '':U THEN '':U ELSE {&slash-char}) + buf_conf-import.field-name.
END.
ASSIGN
firm-pairs = RIGHT-TRIM(firm-pairs, {&slash-char})
person-pairs = RIGHT-TRIM(person-pairs, {&slash-char})
.

run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'utl/incli.p':U
              , input (file-name                        + {&delim-par} +
                 string(cli-grp-code)             + {&delim-par} +
                 mydelimiter                      + {&delim-par} +
                 rs-uniq-method                   + {&delim-par} +
                 firm-pairs                        + {&delim-par} +
                 person-pairs                      )
              , INPUT no /*p-auto-go*/
              , INPUT "&Стоп"
              , INPUT 'Импорт клиентов') .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
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
/*        "excel (*.xlsx)"   "*.xlsx",*/
        
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
    DISP file-name WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up-firm Dialog-Frame
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
              buf1_conf-import.subject = {&TABLE_firm}
          AND buf1_conf-import.POSITION_ = firm_conf-import.POSITION.
    FIND last buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_firm}
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
                buf1_conf-import.subject = {&table_firm}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
{&OPEN-QUERY-br-firm}
  REPOSITION br-firm TO RECID v-rec NO-ERROR.
  apply "entry" TO br-firm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up-person Dialog-Frame
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
              buf1_conf-import.subject = {&TABLE_person}
          AND buf1_conf-import.POSITION_ = person_conf-import.POSITION.
    FIND LAST buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_person}
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
                buf1_conf-import.subject = {&table_person}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
  {&OPEN-QUERY-br-person}
  REPOSITION br-person TO RECID v-rec NO-ERROR.
  apply "entry" TO br-person.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-firm
&Scoped-define SELF-NAME BR-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-firm Dialog-Frame
ON VALUE-CHANGED OF BR-firm IN FRAME Dialog-Frame /* Поля при импорте клиента типа ОРГАНИЗАЦИЯ */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-person
&Scoped-define SELF-NAME BR-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-person Dialog-Frame
ON VALUE-CHANGED OF BR-person IN FRAME Dialog-Frame /* Поля при импорте клиента типа ФИЗ.ЛИЦО */
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-firm
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


ON ROW-DISPLAY OF br-firm IN frame {&frame-name}
DO:
  IF AVAIL firm_conf-import THEN DO:
    RUN set-row-color-firm IN THIS-PROCEDURE ( INPUT firm_conf-import.is-mandatory).
  END.
END.

ON ROW-DISPLAY OF br-person IN frame {&frame-name}
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


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/curdbnum.i v-curr-db-num }
FIND FIRST db WHERE db.db-num = v-curr-db-num NO-LOCK .
if NOT  db.add-clients  OR NOT v-curr-db-num = 0 then do:
    message "Импорт клиентов возможен только в ГБД"  skip
            "и БД, в которых разрешен ввод клиентов"
    view-as alert-box ERROR.
    return.
end.
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN fill-conf-import IN THIS-PROCEDURE.
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI. 

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY file-name delim EDITOR-1 Rs-uniq-method cli-grp-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-7 B-quit B-help B-cli-grp file-name B-file b-up-firm
         b-down-firm b-up-person b-down-person BR-firm BR-person delim EDITOR-1
         Rs-uniq-method cli-grp-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-conf-import Dialog-Frame
PROCEDURE fill-conf-import :
DEFINE VARIABLE v-position-firm AS INTEGER NO-UNDO.
DEFINE VARIABLE v-position-person AS INTEGER NO-UNDO.

&SCOPED-DEFINE create-conf-import  ~
CREATE conf-import.                                               ~
ASSIGN                                                            ~
conf-import.subject = ~{&subject~}                                ~
conf-import.table-name = ~{&table-name~}                          ~
conf-import.field-name = ~{&field-name~}                          ~
conf-import.field-label = ~{&field-label~ }                       ~
conf-import.is-mandatory = ~{&is-mandatory~}                      ~
conf-import.to-import = (IF conf-import.is-mandatory = YES        ~
                         THEN  YES                                ~
                         ELSE NO)                                 ~
conf-import.POSITION_ = (IF conf-import.subject = ~{&table_firm~}  ~
                         THEN v-position-firm + 1                  ~
                         ELSE v-position-person + 1)                   ~
v-position-firm =  (IF conf-import.subject = ~{&TABLE_firm~}  ~
             THEN v-position-firm + 1                                ~
             ELSE v-position-firm)                                   ~
v-position-person =  (IF conf-import.subject = ~{&TABLE_person~}  ~
           THEN v-position-person + 1                                ~
           ELSE v-position-person)



&SCOPED-DEFINE table-name ~{&TAbLE_CLIENTS~}

&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE FIELD-NAME "OBJ-TYPE"
&SCOPED-DEFINE FIELD-LABEL "Тип клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE FIELD-NAME "OBJ-TYPE"
&SCOPED-DEFINE FIELD-LABEL "Тип клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE FIELD-NAME "OBJ-code"
&SCOPED-DEFINE FIELD-LABEL "Код клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE FIELD-NAME "OBJ-code"
&SCOPED-DEFINE FIELD-LABEL "Код клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE FIELD-NAME "OBJ-name"
&SCOPED-DEFINE FIELD-LABEL "Название"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE FIELD-NAME "OBJ-name"
&SCOPED-DEFINE FIELD-LABEL "Название"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.


/*------------------------------------------------------*/

&SCOPED-DEFINE table-name ~{&TAbLE_firm~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE is-mandatory NO

&SCOPED-DEFINE FIELD-NAME "inn"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_inn_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "okpo"
&SCOPED-DEFINE FIELD-LABEL "ОКПО"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "okonh"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_okonh_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "kpp"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_kpp_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone"
&SCOPED-DEFINE FIELD-LABEL "№ телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone-note"
&SCOPED-DEFINE FIELD-LABEL "Примеч. к № телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "fax"
&SCOPED-DEFINE FIELD-LABEL "№ факса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "e-mail"
&SCOPED-DEFINE FIELD-LABEL "E-mail"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "city"
&SCOPED-DEFINE FIELD-LABEL "Город"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "ind"
&SCOPED-DEFINE FIELD-LABEL "Почтовый индекс"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "addres1"
&SCOPED-DEFINE FIELD-LABEL "Юридический адрес 1"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "addres2"
&SCOPED-DEFINE FIELD-LABEL "Юридический адрес 2"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-addr1"
&SCOPED-DEFINE FIELD-LABEL "Почтовый адрес 1"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-addr2"
&SCOPED-DEFINE FIELD-LABEL "Почтовый адрес 2"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "telex"
&SCOPED-DEFINE FIELD-LABEL "Телекс"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "engl-name"
&SCOPED-DEFINE FIELD-LABEL "Английское название"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "director"
&SCOPED-DEFINE FIELD-LABEL "Руководитель"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "contact-psn"
&SCOPED-DEFINE FIELD-LABEL "Контактное лицо"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "is-pboul"
&SCOPED-DEFINE FIELD-LABEL "ПБОЮЛ"
{&create-conf-import}.


&SCOPED-DEFINE FIELD-NAME "tobj-code"
&SCOPED-DEFINE FIELD-LABEL "Код торгового представителя"
{&create-conf-import}.

/*------------------------------------------------------*/
&SCOPED-DEFINE table-name ~{&TAbLE_CLIENTS~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE is-mandatory NO


&SCOPED-DEFINE FIELD-NAME "reg-code"
&SCOPED-DEFINE FIELD-LABEL "Код региона"
{&create-conf-import}.


&SCOPED-DEFINE FIELD-NAME "parus-2-code"
&SCOPED-DEFINE FIELD-LABEL "Код во классиф.ПАРУС-2"
{&create-conf-import}.



/*------------------------------------------------------*/
&SCOPED-DEFINE table-name ~{&TAbLE_PERSON~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE is-mandatory NO

&SCOPED-DEFINE FIELD-NAME "inn"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_inn_allshift}"
{&create-conf-import}.


&SCOPED-DEFINE FIELD-NAME "okpo"
&SCOPED-DEFINE FIELD-LABEL "ОКПО"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "okonh"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_okonh_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "kpp"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_kpp_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone1"
&SCOPED-DEFINE FIELD-LABEL "№ телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone1-note"
&SCOPED-DEFINE FIELD-LABEL "Примеч. к № телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "fax"
&SCOPED-DEFINE FIELD-LABEL "№ факса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "e-mail"
&SCOPED-DEFINE FIELD-LABEL "E-mail"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "city"
&SCOPED-DEFINE FIELD-LABEL "Город"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "ind"
&SCOPED-DEFINE FIELD-LABEL "Почтовый индекс"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "address"
&SCOPED-DEFINE FIELD-LABEL "Почтовый адрес"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "name1"
&SCOPED-DEFINE FIELD-LABEL "Имя"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "name2"
&SCOPED-DEFINE FIELD-LABEL "Отчество"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "passp-ser"
&SCOPED-DEFINE FIELD-LABEL "Серия паспорта"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "passp-num"
&SCOPED-DEFINE FIELD-LABEL "№ паспорта"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "given-by"
&SCOPED-DEFINE FIELD-LABEL "Паспорт выдан"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "position"
&SCOPED-DEFINE FIELD-LABEL "Должность"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "firm-name"
&SCOPED-DEFINE FIELD-LABEL "Организация"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "firm-code"
&SCOPED-DEFINE FIELD-LABEL "Код организации"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-box"
&SCOPED-DEFINE FIELD-LABEL "Абонентский п/я"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "is-pboul"
&SCOPED-DEFINE FIELD-LABEL "ПБОЮЛ"
{&create-conf-import}.


/*------------------------------------------------------*/
&SCOPED-DEFINE TABLE-NAME ~{&TAbLE_CLIENTS~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE is-mandatory NO


&SCOPED-DEFINE FIELD-NAME "reg-code"
&SCOPED-DEFINE FIELD-LABEL "Код региона"
{&create-conf-import}.


&SCOPED-DEFINE FIELD-NAME "parus-2-code"
&SCOPED-DEFINE FIELD-LABEL "Код во классиф.ПАРУС-2"
{&create-conf-import}.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyENable Dialog-Frame
PROCEDURE MyENable :
assign
delim:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "Точка с запятой (;)" + {&comma-char} + ";" + {&comma-char} +
                         "Тильда (~)" + {&comma-char} + "~~" + {&comma-char} +
                          "Табулятор" + {&comma-char} + "~t" + {&comma-char} + "Excel(xls)"  + {&comma-char} + "xls"
.
ASSIGN
firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = YES
person_conf-import.to-import:READ-ONLY IN BROWSE br-person = YES
rs-uniq-method:radio-buttons = "Название" + {&comma-char} + "obj-name" + {&comma-char} +
                               "{&abbr_inn_allshift}" + "+" + "{&abbr_kpp_allshift}" + {&comma-char} + "inn+kpp".
.
DISPLAY
file-name
EDITOR-1
delim
cli-grp-name
rs-uniq-method
WITH FRAME {&frame-name}.
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
WITH FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed" to br-firm.
apply "value-changed" to br-person.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color-firm Dialog-Frame
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color-person Dialog-Frame
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


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
