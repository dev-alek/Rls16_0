&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор шаблона экспорта товаров на ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/03
Author: Bakhtadze Natalya
Creation date: 07/08/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter  bttn        as character no-undo .
define input parameter c-point as character no-undo .
define input parameter tbl     as character no-undo .
define input parameter buf     as character no-undo .
define input parameter fld     as character no-undo .
define input parameter lab     as character no-undo .
define input parameter spr     as character no-undo .
define input parameter p-size  as character no-undo .
define input parameter p-size-min  as character no-undo .
define input parameter p-format as character no-undo .
define input parameter dim     as character no-undo .
define output parameter p-rec as recid no-undo .
define output parameter P-LENGTH as integer no-undo .
define output parameter P-NUM-CLMN as integer no-undo .
define output parameter P-file-name as character no-undo .
define output parameter P-encoding as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор шаблона экспорта товаров на ТСД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ cmp/showinf.i }
{ str/tsdtmpdt.i "shared" }

DEFINE VARIABLE kl AS INTEGER INITIAL 0.
define variable MethodReturn AS LOGICAL.

define variable ID AS RECID.
define variable IDENT AS RECID.

define variable ii as integer no-undo.
define variable rec as recid no-undo.
define variable v-length as integer no-undo.
define variable v-num-clmn as integer no-undo.
define variable v-delim as character no-undo.
define variable v-choose as logical no-undo.
define variable v-file-directory as character no-undo.
define variable v-rec-num as integer no-undo.
DEFINE VARIABLE v-scl-format AS CHARACTER NO-UNDO.
define variable flt-rec as recid no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-doc-rec as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME br-filter

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ubflt.filter t-f

/* Definitions for BROWSE br-filter                                     */
&Scoped-define FIELDS-IN-QUERY-br-filter ubflt.filter.Naim
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-filter
&Scoped-define QUERY-STRING-br-filter FOR EACH ubflt.filter ~
      WHERE ubflt.filter.call-point = c-point NO-LOCK
&Scoped-define OPEN-QUERY-br-filter OPEN QUERY br-filter FOR EACH ubflt.filter ~
      WHERE ubflt.filter.call-point = c-point NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-filter ubflt.filter
&Scoped-define FIRST-TABLE-IN-QUERY-br-filter ubflt.filter


/* Definitions for BROWSE BR-sel-fields                                 */
&Scoped-define FIELDS-IN-QUERY-BR-sel-fields t-f.field-label t-f.field-csize
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sel-fields
&Scoped-define SELF-NAME BR-sel-fields
&Scoped-define QUERY-STRING-BR-sel-fields FOR EACH t-f no-lock by t-f.field-table-order
&Scoped-define OPEN-QUERY-BR-sel-fields OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock by t-f.field-table-order.
&Scoped-define TABLES-IN-QUERY-BR-sel-fields t-f
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sel-fields t-f


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-br-filter}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-Cancel b-OK b-exit b-file b-help ~
Rs-encoding b-codes b-add b-del br-filter BR-sel-fields b-update
&Scoped-Define DISPLAYED-OBJECTS flt-name Rs-encoding f-file-name f-length ~
f-num-clmn f-delim f-ascii f-rec-num f-scl-format

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 8.8 BY 1 TOOLTIP "Добавить новый шаблон".

DEFINE BUTTON b-Cancel AUTO-END-KEY DEFAULT
     LABEL "&Выход "
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .

DEFINE BUTTON b-codes
     LABEL "&Коды":L
     SIZE 9.5 BY 1 TOOLTIP "Выбор типов кодов для экспорта".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 8.8 BY 1 TOOLTIP "Удалить ранее существующий шаблон".

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отменить":L
     SIZE 10 BY 1 TOOLTIP "Отменить действие установок шаблона".

DEFINE BUTTON b-file
     LABEL "&Файл":L
     SIZE 10 BY 1 TOOLTIP "Выбор файла для экспорта".

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-OK AUTO-GO DEFAULT
     LABEL "&Применить":L
     SIZE 10 BY 1 TOOLTIP "Применить установки выбранного шаблона"
     BGCOLOR 8 .

DEFINE BUTTON b-update
     LABEL "&Изменить":L
     SIZE 9 BY 1 TOOLTIP "Изменить установки выбранного шаблона".

DEFINE VARIABLE f-ascii AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.1 BY 1 NO-UNDO.

DEFINE VARIABLE f-delim AS CHARACTER FORMAT "X(1)":U
     VIEW-AS FILL-IN
     SIZE 2 BY 1 NO-UNDO.

DEFINE VARIABLE f-file-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97.9 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE f-length AS CHARACTER FORMAT "X(5)":U
     VIEW-AS FILL-IN
     SIZE 9.1 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-clmn AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.1 BY 1 NO-UNDO.

DEFINE VARIABLE f-rec-num AS CHARACTER FORMAT "X(7)":U
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-scl-format AS CHARACTER FORMAT "X(7)":U
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.

DEFINE VARIABLE flt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97.9 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Rs-encoding AS CHARACTER INITIAL "IBM866"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "DOS", "IBM866",
"WINDOWS", "WINDOWS-1251"
     SIZE 23.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-filter FOR
      ubflt.filter SCROLLING.

DEFINE QUERY BR-sel-fields FOR
      t-f SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-filter DIALOG-1 _STRUCTURED
  QUERY br-filter NO-LOCK DISPLAY
      ubflt.filter.Naim COLUMN-LABEL "Имя шаблона" FORMAT "X(255)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 48.5 BY 12.77.

DEFINE BROWSE BR-sel-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sel-fields DIALOG-1 _FREEFORM
  QUERY BR-sel-fields DISPLAY
      t-f.field-label format "X(30)" column-label "Название поля"
t-f.field-csize format "X(5)" column-label "Длина"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 38.9 BY 12.7.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-Cancel AT ROW 1 COL 1
     b-OK AT ROW 1 COL 11
     b-exit AT ROW 1 COL 21
     b-file AT ROW 1 COL 31
     b-help AT ROW 1 COL 61
     flt-name AT ROW 2.53 COL 1 NO-LABEL
     Rs-encoding AT ROW 3.5 COL 21.5 NO-LABEL
     f-file-name AT ROW 4.53 COL 1 NO-LABEL
     b-codes AT ROW 5.7 COL 90
     f-length AT ROW 5.77 COL 27.1 COLON-ALIGNED NO-LABEL
     f-num-clmn AT ROW 5.77 COL 50.1 COLON-ALIGNED NO-LABEL
     f-delim AT ROW 5.77 COL 70.1 COLON-ALIGNED NO-LABEL
     f-ascii AT ROW 5.77 COL 81.3 COLON-ALIGNED NO-LABEL
     f-rec-num AT ROW 6.87 COL 39 COLON-ALIGNED NO-LABEL
     f-scl-format AT ROW 6.87 COL 89 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     b-add AT ROW 8 COL 50.1
     b-del AT ROW 9 COL 50.1
     br-filter AT ROW 9.07 COL 1
     BR-sel-fields AT ROW 9.07 COL 60.1
     b-update AT ROW 10 COL 50.1
     "Разделитель" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 6 COL 59.1
          BGCOLOR 1 FGCOLOR 15
     "Количество выводимых записей" VIEW-AS TEXT
          SIZE 34.9 BY .67 AT ROW 7.13 COL 3.5
          BGCOLOR 1 FGCOLOR 15
     "Файл" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 3.77 COL 2
          BGCOLOR 1 FGCOLOR 15
     "Список полей" VIEW-AS TEXT
          SIZE 39.3 BY .67 AT ROW 8.03 COL 59.8
          BGCOLOR 1 FGCOLOR 15
     "ASCII" VIEW-AS TEXT
          SIZE 6.1 BY .67 AT ROW 6 COL 75
          BGCOLOR 1 FGCOLOR 15
     "Список шаблонов" VIEW-AS TEXT
          SIZE 48.6 BY .67 AT ROW 8.03 COL 1
          BGCOLOR 1 FGCOLOR 15
     "Длина записи" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 6 COL 14.1
          BGCOLOR 1 FGCOLOR 15
     "Кол-во полей" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 6 COL 39.1
          BGCOLOR 1 FGCOLOR 15
     "Формат весового кода" VIEW-AS TEXT
          SIZE 34.9 BY .67 AT ROW 7.13 COL 55.5 WIDGET-ID 4
          BGCOLOR 1 FGCOLOR 15
     SPACE(9.34) SKIP(14.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Шаблоны выгрузки в файл для ТСД":L
         DEFAULT-BUTTON b-OK CANCEL-BUTTON b-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
/* BROWSE-TAB br-filter b-del DIALOG-1 */
/* BROWSE-TAB BR-sel-fields br-filter DIALOG-1 */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-codes IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-del IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-exit IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-file IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-update IN FRAME DIALOG-1
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN f-ascii IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-delim IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-file-name IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-length IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-num-clmn IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rec-num IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-scl-format IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN flt-name IN FRAME DIALOG-1
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-filter
/* Query rebuild information for BROWSE br-filter
     _TblList          = "ubflt.filter"
     _Options          = "NO-LOCK"
     _Where[1]         = "ubflt.filter.call-point = c-point"
     _FldNameList[1]   > ubflt.filter.Naim
"ubflt.filter.Naim" "Имя шаблона" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-filter */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-sel-fields
/* Query rebuild information for BROWSE BR-sel-fields
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH t-f no-lock by t-f.field-table-order.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-sel-fields */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add DIALOG-1
ON CHOOSE OF b-add IN FRAME DIALOG-1 /* Добавить */
DO:
  Kl = 0.
  run gbl/upd-tsd.w (
                 input parparentproc
                ,input p-obj-type
                ,input p-obj-code
                ,input c-point
                ,input Tbl
                ,input Buf
                ,input Fld
                ,input Lab
                ,input Spr
                ,input p-size
                ,input p-size-min
                ,input p-format,Dim
                ,input Kl
                ,OUTPUT ID
                ,OUTPUT P-LENGTH
                ,OUTPUT P-NUM-CLMN).
  IF ID = ? THEN ID = IDENT.
  RUN enable_UI.
  run proc-buttons in this-procedure .
  REPOSITION br-filter TO RECID flt-rec no-error.
  APPLY "VALUE-CHANGED" TO br-filter.
  apply "entry" to br-filter.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-Cancel DIALOG-1
ON CHOOSE OF b-Cancel IN FRAME DIALOG-1 /* Выход  */
DO:
     flt-rec = ?.
     return  "undo":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-codes DIALOG-1
ON CHOOSE OF b-codes IN FRAME DIALOG-1 /* Коды */
DO:
{ gbl/stdbtn.i }
if not avail ubflt.filter then return no-apply.
run adm/to-cd.w ( {&lookup} ,
INPUT v-host-code,
INPUT p-obj-type,
INPUT p-obj-code,
INPUT ("Типы кодов для вывода в файл ТСД" + {&space-char} + p-obj-type +
string(p-obj-code)),
INPUT-OUTPUT temp-shop.all-prt,
INPUT-OUTPUT temp-shop.cd-bc-alt,
INPUT-OUTPUT temp-shop.cd-bc-base,
INPUT-OUTPUT temp-shop.cd-loc-alt,
INPUT-OUTPUT temp-shop.cd-loc-base,
INPUT-OUTPUT temp-shop.cd-parts-all,
INPUT-OUTPUT temp-shop.cd-parts-not-blank,
INPUT-OUTPUT temp-shop.cd-parts-ser,
INPUT-OUTPUT temp-shop.cd-pb-alt,
INPUT-OUTPUT temp-shop.cd-pb-base,
INPUT-OUTPUT temp-shop.cd-sc-base) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del DIALOG-1
ON CHOOSE OF b-del IN FRAME DIALOG-1 /* Удалить */
do:
do on stop  undo, return:
  if available ubflt.filter then do:
    flt-name = "".
    get prev br-filter.
    if not available ubflt.filter then do:
      get first br-filter.
      get next br-filter.
    end.
    flt-rec = recid(ubflt.filter).
    FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR.
    DELETE ubflt.filter.
    find ubflt.filter where recid(ubflt.filter) = flt-rec no-lock no-error.
    RUN enable_UI.
    run proc-buttons in this-procedure .
    REPOSITION br-filter TO RECID flt-rec no-error.
    APPLY "VALUE-CHANGED" TO br-filter.
    apply "entry" to br-filter.
   END.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DIALOG-1
ON CHOOSE OF b-exit IN FRAME DIALOG-1 /* Отменить */
DO:
   flt-rec = ?.
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = ubflt.filter.call-point
                        no-error.
   if available ubflt.usr-flt then delete ubflt.usr-flt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file DIALOG-1
ON CHOOSE OF b-file IN FRAME DIALOG-1 /* Файл */
DO:
assign
p-file-name = if p-file-name = "":U then "tsd.txt":U else p-file-name
.

run gbl/d-file.p (
 input-output p-file-name
,input-output v-file-directory
,input        "Текстовые файлы"
,input        "*.txt":U
,input        ","
,input        "txt":U
,input        no
,input        yes
,input        yes
,input        "Введите имя файла для экспорта"
,output       v-choose
).


if not v-choose then do:
  return no-apply.
end.
display
p-file-name @ f-file-name
with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK DIALOG-1
ON CHOOSE OF b-OK IN FRAME DIALOG-1 /* Применить */
DO:
ASSIGN
rs-encoding
p-encoding = rs-encoding.
if p-file-name = "":U or f-file-name:screen-value = "":U then do:
    message
    "Введите имя файла для экспорта"
    view-as alert-box.
    return no-apply.
end.
if available ubflt.filter  then do:
   p-rec = recid(ubflt.filter).
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = ubflt.filter.call-point
                        no-error.
   if not available ubflt.usr-flt then create ubflt.usr-flt.
   assign
   ubflt.usr-flt.user-name = v-cntxt-userid
   ubflt.usr-flt.call-point    = ubflt.filter.call-point
   ubflt.usr-flt.naim = ubflt.filter.naim.
   end.
else p-rec = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-update DIALOG-1
ON CHOOSE OF b-update IN FRAME DIALOG-1 /* Изменить */
DO:
  FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR no-wait.
  IF AVAILABLE(ubflt.filter) THEN DO:
   Kl = ubflt.filter.Num-flt.
   run gbl/upd-tsd.w  (
                    input parparentproc
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input c-point
                   ,input Tbl
                   ,input Buf
                   ,input Fld
                   ,input Lab
                   ,input Spr
                   ,input p-size
                   ,input p-size-min
                   ,input p-format
                   ,input Dim
                   ,input Kl
                   ,output ID
                   ,OUTPUT P-LENGTH
                   ,OUTPUT P-NUM-CLMN).
   IF ID = ? THEN ID = IDENT.
   RUN enable_UI.
   run proc-buttons in this-procedure .
   REPOSITION br-filter TO RECID flt-rec no-error.
   APPLY "VALUE-CHANGED" TO br-filter.
   apply "entry" to br-filter.
 END.
   else
     if locked ubflt.filter then
        message 'Шаблон в данный момент корректируется другим пользователем'.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-filter
&Scoped-define SELF-NAME br-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-filter DIALOG-1
ON MOUSE-SELECT-DBLCLICK OF br-filter IN FRAME DIALOG-1
DO:
apply "choose" to  b-ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-filter DIALOG-1
ON RETURN OF br-filter IN FRAME DIALOG-1
DO:
apply "choose" to  b-ok.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-filter DIALOG-1
ON VALUE-CHANGED OF br-filter IN FRAME DIALOG-1
DO:

 IF AVAILABLE(ubflt.filter) THEN DO:
    flt-rec = recid(ubflt.filter).
    flt-name = ubflt.filter.naim.
    Kl = ubflt.filter.Num-flt.

    assign
        v-num-clmn = num-entries(ubflt.filter.fields-sort)
        v-length = 0
        .
    run fill-table in this-procedure.
    IDENT = RECID(ubflt.filter).
    DISPLAY
    flt-name
    string(v-length, ">>>>9") @ f-length
    string(v-num-clmn, ">>9") @ f-num-clmn
    v-delim @ f-delim
    f-ascii
    string(v-rec-num) @ f-rec-num
    v-scl-format @ f-scl-format
    with frame {&frame-name}.

  END.
  ELSE do:
    run fill-table in this-procedure.
    f-ascii = 0.
    display
    "":U @ f-length
    "":U @ f-num-clmn
    "":U @ f-delim
    f-ascii
    "":U @ f-rec-num
    "":U @ f-scl-format
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/brwrepos.i
  &browse-name=br-filter
  &line-num=5
}

{ gbl/brwrefre.i " v-doc-rec = recid(ubflt.filter). ~{&OPEN-QUERY-br-filter~} Reposition br-filter to recid v-doc-rec no-error . ~
               APPLY 'ENTRY' to br-filter. APPLY 'value-changed' TO br-filter. " }

{ gbl/hot-key.i b-add }
&scop b-ok ~{&b-sel~}
&scop b-update ~{&b-chg~}
{ gbl/hot-key.i b-update }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-ok }
&scop b-cancel ~{&b-exit~}
{ gbl/hot-key.i b-cancel }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
on end-error, stop of frame {&frame-name} do:
   return "undo":u.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  assign frame {&frame-name}:title = "Ш А Б Л О Н Ы   В Ы Г Р У З К И   В   Ф А Й Л   Д Л Я   Т С Д   (" + ENTRY(1, c-point, {&delim-par}) + ")".
  RUN enable_UI.
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  run proc-buttons in this-procedure.
  reposition br-filter to recid flt-rec no-error.
  apply "value-changed" to br-filter in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-filter.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY flt-name Rs-encoding f-file-name f-length f-num-clmn f-delim f-ascii
          f-rec-num f-scl-format
      WITH FRAME DIALOG-1.
  ENABLE b-Cancel b-OK b-exit b-file b-help Rs-encoding b-codes b-add b-del
         br-filter BR-sel-fields b-update
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table DIALOG-1
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo.
for each t-f :
    delete t-f.
end.
if available ubflt.filter then do:
  assign
  v-num-clmn = num-entries(ubflt.filter.fields-sort)
  v-length = 0
  f-ascii = int(entry(3, ubflt.filter.fields-sort-rus, {&delim-par}))
  v-delim = chr(int(entry(3, ubflt.filter.fields-sort-rus, {&delim-par})))
  v-rec-num = int(entry(4, ubflt.filter.fields-sort-rus, {&delim-par}))
  v-scl-format = (IF NUM-ENTRIES(ubflt.filter.fields-sort-rus, {&delim-par}) < 5
                  THEN ">>>>9"
                  ELSE entry(5, ubflt.filter.fields-sort-rus, {&delim-par}))
        .
    do ii = 1 to v-num-clmn:
        create t-f.
        assign
        t-f.field-table-order = ii
        t-f.field-name = entry(2, entry(ii,entry(1, ubflt.filter.fields-sort, {&delim-par})), ".":U)
        t-f.field-label = entry(ii,entry(1, ubflt.filter.fields-sort-rus, {&delim-par}))
        t-f.field-size = entry(ii,entry(1, ubflt.filter.where-ysl, {&delim-par}))
        t-f.field-size-min = entry(ii,entry(2, ubflt.filter.where-ysl, {&delim-par}))
        t-f.field-csize = entry(ii,entry(3, ubflt.filter.where-ysl, {&delim-par}))
        t-f.field-format = entry(ii,ubflt.filter.where-ysl-rus, {&delim-par})
        v-length = v-length + integer(t-f.field-csize)
        .
    end.
    find first temp-shop no-error .
    if not avail temp-shop then do:
      create temp-shop.
    end.
    assign
    temp-shop.all-prt              = (lookup("all-prt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
    temp-shop.cd-bc-alt            = (lookup("cd-bc-alt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
    temp-shop.cd-bc-base           = (lookup("cd-bc-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
    temp-shop.cd-loc-alt           = (lookup("cd-loc-alt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
    temp-shop.cd-loc-base          = (lookup("cd-loc-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
    temp-shop.cd-parts-all         = (lookup("cd-parts-all":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par})) > 0)
    temp-shop.cd-parts-not-blank   = (lookup("cd-parts-not-blank":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
    temp-shop.cd-parts-ser         = (lookup("cd-part-ser":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
    temp-shop.cd-pb-alt            = (lookup("cd-pb-alt":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
    temp-shop.cd-pb-base           = (lookup("cd-pb-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
    temp-shop.cd-sc-base           = (lookup("cd-sc-base":U, entry(2, ubflt.filter.fields-sort-rus, {&delim-par}))  > 0)
    .
end.
OPEN QUERY br-sel-fields FOR EACH t-f no-lock by t-f.field-table-order.
APPLY "ENTRY" to br-filter in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-buttons DIALOG-1
PROCEDURE proc-buttons :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if lookup("b-codes", bttn) = 0 then do:
    disable b-codes
    with frame {&frame-name}.
    hide
    b-codes
    in frame {&frame-name} .
  end.
  if lookup(bttn, "b-exit":U) = 0 then do:
    hide
    b-exit
    in frame {&frame-name}.
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME