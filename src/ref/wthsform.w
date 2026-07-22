&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-wth-ser NO-UNDO LIKE ub.wth-ser.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог добавлени\изменения серии(маски) МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/10/07
Author: Polina Gridchina
Creation date: 05/10/07

Input:

Output:

*/


/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter pser-code as integer no-undo.
define input parameter pdb-num   as integer no-undo.
define input parameter pwth-code as integer no-undo.
define input parameter ppar-code as integer no-undo.
define input parameter par-mode as character no-undo.
define output PARAMETER p-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог добавлени\изменения серии(маски) МЦ".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }



DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEF BUFFER LOCKED_wealth FOR ub.wealth.
DEF BUFFER LOCKED_wth-ser FOR ub.wth-ser.
DEF BUFFER locked_wth-par FOR ub.wth-par.
DEF BUFFER b-wth-par FOR ub.wth-par.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-wth-ser

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-wth-ser.series ~
tt-wth-ser.wth-code tt-wth-ser.par-code tt-wth-ser.maska tt-wth-ser.authr ~
tt-wth-ser.range-rule tt-wth-ser.range-smb tt-wth-ser.chk-ser ~
tt-wth-ser.ser-rule tt-wth-ser.ser-smb tt-wth-ser.chk-gds ~
tt-wth-ser.gds-rule tt-wth-ser.gds-smb tt-wth-ser.chk-par ~
tt-wth-ser.par-rule tt-wth-ser.par-smb tt-wth-ser.chk-bdt tt-wth-ser.beg-dt ~
tt-wth-ser.beg-yy tt-wth-ser.beg-yy-smb tt-wth-ser.beg-mm tt-wth-ser.beg-dd ~
tt-wth-ser.chk-edt tt-wth-ser.end-dt tt-wth-ser.end-yy ~
tt-wth-ser.end-yy-smb tt-wth-ser.end-mm tt-wth-ser.end-dd tt-wth-ser.PS ~
tt-wth-ser.ser-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-wth-ser.series ~
tt-wth-ser.par-code tt-wth-ser.range-rule tt-wth-ser.range-smb ~
tt-wth-ser.PS tt-wth-ser.ser-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-wth-ser
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-wth-ser
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-wth-ser SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-wth-ser SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-wth-ser
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-wth-ser


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wth-ser.series tt-wth-ser.par-code ~
tt-wth-ser.range-rule tt-wth-ser.range-smb tt-wth-ser.PS ~
tt-wth-ser.ser-code
&Scoped-define ENABLED-TABLES tt-wth-ser
&Scoped-define FIRST-ENABLED-TABLE tt-wth-ser
&Scoped-Define ENABLED-OBJECTS RECT-2 RECT-3 B-exit b-quit B-hist B-Help ~
FILL-wth FILL-par
&Scoped-Define DISPLAYED-FIELDS tt-wth-ser.series tt-wth-ser.wth-code ~
tt-wth-ser.par-code tt-wth-ser.maska tt-wth-ser.authr tt-wth-ser.range-rule ~
tt-wth-ser.range-smb tt-wth-ser.chk-ser tt-wth-ser.ser-rule ~
tt-wth-ser.ser-smb tt-wth-ser.chk-gds tt-wth-ser.gds-rule ~
tt-wth-ser.gds-smb tt-wth-ser.chk-par tt-wth-ser.par-rule ~
tt-wth-ser.par-smb tt-wth-ser.chk-bdt tt-wth-ser.beg-dt tt-wth-ser.beg-yy ~
tt-wth-ser.beg-yy-smb tt-wth-ser.beg-mm tt-wth-ser.beg-dd ~
tt-wth-ser.chk-edt tt-wth-ser.end-dt tt-wth-ser.end-yy ~
tt-wth-ser.end-yy-smb tt-wth-ser.end-mm tt-wth-ser.end-dd tt-wth-ser.PS ~
tt-wth-ser.ser-code
&Scoped-define DISPLAYED-TABLES tt-wth-ser
&Scoped-define FIRST-DISPLAYED-TABLE tt-wth-ser
&Scoped-Define DISPLAYED-OBJECTS FILL-wth FILL-par

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 tt-wth-ser.series tt-wth-ser.wth-code ~
tt-wth-ser.par-code tt-wth-ser.maska tt-wth-ser.gds-rule tt-wth-ser.gds-smb ~
tt-wth-ser.ser-code

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON B-par
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-wth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE FILL-par AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-wth AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 7.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 5.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-wth-ser SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 2
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 8
     B-hist AT ROW 1 COL 61 WIDGET-ID 6
     B-Help AT ROW 1 COL 81 WIDGET-ID 4
     tt-wth-ser.series AT ROW 3.5 COL 13.5 COLON-ALIGNED WIDGET-ID 16
          LABEL "Наименование"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-wth-ser.wth-code AT ROW 4.75 COL 13.5 COLON-ALIGNED WIDGET-ID 18
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-wth AT ROW 4.75 COL 26 WIDGET-ID 32
     tt-wth-ser.par-code AT ROW 4.75 COL 67 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-par AT ROW 4.75 COL 73.5 WIDGET-ID 34
     tt-wth-ser.maska AT ROW 6.5 COL 15.5 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR NO-WORD-WRAP MAX-CHARS 19
          SIZE 20 BY 1 TOOLTIP "Маска"
     tt-wth-ser.authr AT ROW 6.5 COL 42.12 WIDGET-ID 10
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 7 BY 1
     tt-wth-ser.range-rule AT ROW 8.75 COL 20 COLON-ALIGNED WIDGET-ID 72
          LABEL "Диапазон: с симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.range-smb AT ROW 8.75 COL 29 COLON-ALIGNED WIDGET-ID 74
          LABEL "по" FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.chk-ser AT ROW 10 COL 15.12 WIDGET-ID 54
          LABEL "Серия"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.ser-rule AT ROW 10 COL 55 COLON-ALIGNED WIDGET-ID 78 FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.ser-smb AT ROW 10 COL 84 COLON-ALIGNED WIDGET-ID 80
          LABEL "Значение" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1
     tt-wth-ser.chk-gds AT ROW 11.25 COL 10 WIDGET-ID 50
          LABEL "Код товара"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.gds-rule AT ROW 11.25 COL 55 COLON-ALIGNED WIDGET-ID 28 FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.gds-smb AT ROW 11.25 COL 84 COLON-ALIGNED WIDGET-ID 30
          LABEL "Значение" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1
     tt-wth-ser.chk-par AT ROW 12.5 COL 13 WIDGET-ID 52
          LABEL "Номинал"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.par-rule AT ROW 12.5 COL 55 COLON-ALIGNED WIDGET-ID 66 FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.par-smb AT ROW 12.5 COL 84 COLON-ALIGNED WIDGET-ID 68
          LABEL "Значение" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1
     tt-wth-ser.chk-bdt AT ROW 14.75 COL 9 WIDGET-ID 46
          LABEL "Дата начала"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Правило",1,
                     "Нет",0,
                     "Дата",2
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.beg-dt AT ROW 14.75 COL 55 COLON-ALIGNED WIDGET-ID 38
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-wth-ser.beg-yy AT ROW 15.75 COL 55 COLON-ALIGNED WIDGET-ID 42
          LABEL "Год начала с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.beg-yy-smb AT ROW 15.75 COL 87.5 COLON-ALIGNED WIDGET-ID 44
          LABEL "Кол-во симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.beg-mm AT ROW 16.75 COL 55 COLON-ALIGNED WIDGET-ID 40
          LABEL "Месяц начала с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.beg-dd AT ROW 16.75 COL 87.5 COLON-ALIGNED WIDGET-ID 36
          LABEL "День начала с симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.chk-edt AT ROW 18 COL 6.12 WIDGET-ID 48
          LABEL "Дата окончания"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Правило",1,
                     "Нет",0,
                     "Дата",2
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.end-dt AT ROW 18 COL 55 COLON-ALIGNED WIDGET-ID 58
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-wth-ser.end-yy AT ROW 19 COL 55 COLON-ALIGNED WIDGET-ID 62
          LABEL "Год окончания с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.end-yy-smb AT ROW 19 COL 87.5 COLON-ALIGNED WIDGET-ID 64
          LABEL "Кол-во симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.end-mm AT ROW 20 COL 55 COLON-ALIGNED WIDGET-ID 60
          LABEL "Месяц окончания с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.end-dd AT ROW 20 COL 87.5 COLON-ALIGNED WIDGET-ID 56
          LABEL "День окончания с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.PS AT ROW 21.5 COL 1.5 NO-LABEL WIDGET-ID 70
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL
          SIZE 96.5 BY 1.25
     tt-wth-ser.ser-code AT ROW 2.5 COL 13.5 COLON-ALIGNED WIDGET-ID 76
          LABEL "Код" FORMAT "999999999"
           VIEW-AS TEXT
          SIZE 9 BY .67
          FGCOLOR 4
     FILL-wth AT ROW 5 COL 27.5 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     FILL-par AT ROW 5 COL 76.5 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     "Срок годности" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 14 COL 2.5 WIDGET-ID 96
          FGCOLOR 4
     "Структура маски" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 8 COL 2.5 WIDGET-ID 94
          FGCOLOR 4
     "Маска:" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 6.75 COL 8.5 WIDGET-ID 86
     RECT-2 AT ROW 14.25 COL 1.5 WIDGET-ID 90
     RECT-3 AT ROW 8.25 COL 1.5 WIDGET-ID 92
     SPACE(0.37) SKIP(9.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-wth-ser T "?" NO-UNDO ub wth-ser
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX tt-wth-ser.authr IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR BUTTON B-par IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-par:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-wth IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-wth:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wth-ser.beg-dd IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-wth-ser.beg-dt IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.beg-mm IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.beg-yy IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.beg-yy-smb IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR COMBO-BOX tt-wth-ser.chk-bdt IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR COMBO-BOX tt-wth-ser.chk-edt IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR COMBO-BOX tt-wth-ser.chk-gds IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR COMBO-BOX tt-wth-ser.chk-par IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR COMBO-BOX tt-wth-ser.chk-ser IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-wth-ser.end-dd IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.end-dt IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.end-mm IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.end-yy IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-wth-ser.end-yy-smb IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-wth-ser.gds-rule IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN tt-wth-ser.gds-smb IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL EXP-FORMAT                                     */
/* SETTINGS FOR EDITOR tt-wth-ser.maska IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN tt-wth-ser.par-code IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN tt-wth-ser.par-rule IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wth-ser.par-smb IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-wth-ser.range-rule IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wth-ser.range-smb IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wth-ser.ser-code IN FRAME Dialog-Frame
   1 EXP-LABEL EXP-FORMAT                                               */
/* SETTINGS FOR FILL-IN tt-wth-ser.ser-rule IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wth-ser.ser-smb IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-wth-ser.series IN FRAME Dialog-Frame
   1 EXP-LABEL                                                          */
/* SETTINGS FOR FILL-IN tt-wth-ser.wth-code IN FRAME Dialog-Frame
   NO-ENABLE 1 EXP-LABEL                                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-wth-ser"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
    run proc-save in this-procedure no-error .
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.authr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.authr Dialog-Frame
ON VALUE-CHANGED OF tt-wth-ser.authr IN FRAME Dialog-Frame /* Авторизация в Trade House */
DO:
  IF SELF:SCREEN-VALUE = '0' THEN DO: /*Если не авт-я в ТН, то правила для вырезания из штрих-кода номинала и кода товара обязательны для заполнения.(передаются на кассу)*/
    /* Доработать */
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
   define variable v-rid-list  as   character            no-undo .
   define variable v-host-code like ub.sysconf.host-code no-undo .
   run ref/cwthhist.w (
                    input        parparentproc
                  , input        p-curr-host-code
                  , input        p-curr-obj-type
                  , input        p-curr-obj-code
                  , input        "":U          /* bttns */
                  , input        "subject":U       /* p-mode */
                  , input        int(tt-wth-ser.wth-code:screen-value) /*p-wth-code*/
                  , INPUT        0             /*p-par-code*/
                  , input        ?             /* p-host-code */
                  , input        ?             /* p-obj-type*/
                  , input        ?             /* p-obj-code*/
                  , input        ?             /* p-corr-user-db-num */
                  , input        "":U          /* p-corr-user-name */
                  , input        {&table_wth-ser}   /* p-subject */
                  , input        v-cntxt-db-num      /* p-db-num */
                  , input        tt-wth-ser.ser-code
                  , input        tt-wth-ser.db-num
                  , input-output v-rid-list
                  ) no-error .

/*    define variable v-rid-list  as   character            no-undo .*/
/*  define variable v-host-code like ub.sysconf.host-code no-undo .*/


/*  run ref/cwthhist.w (*/
/*                   input        parparentproc*/
/*                 , input        0   /* p-curr-host-code */*/
/*                 , input        '':U    /* p-curr-obj-type  */*/
/*                 , input        0    /* p-curr-obj-code  */*/
/*                 , input        "":U          /* bttns */*/
/*                 , input        "subject":U       /* p-mode */*/
/*                 , input        locked_wealth.wth-code /*p-wth-code*/*/
/*                 , INPUT        0             /*p-par-code*/*/
/*                 , input        ?             /* p-host-code */*/
/*                 , input        ?             /* p-obj-type*/*/
/*                 , input        ?             /* p-obj-code*/*/
/*                 , input        ?             /* p-corr-user-db-num */*/
/*                 , input        "":U          /* p-corr-user-name */*/
/*                 , input        {&table_wth-ser}  /* p-subject */*/
/*                 , input        v-cntxt-db-num      /* p-db-num */*/
/*                 , input-output v-rid-list*/
/*                 ) no-error .*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-par Dialog-Frame
ON CHOOSE OF B-par IN FRAME Dialog-Frame
DO:

  define variable v-rid-list as character no-undo .
  run ref/wthp-ref.w (
                  input parparentproc
                 ,input  "b-sel,b-add"
                 ,input p-curr-host-code
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input ( if int(tt-wth-ser.wth-code:screen-value) > 0 then {&wealth} else '')
                 ,input int(tt-wth-ser.wth-code:screen-value)
                 ,input-output v-rid-list).
        find first locked_wth-par exclusive-LOCK WHERE
              recid(locked_wth-par) = integer(entry(1, v-rid-list)) NO-ERROR.
      if available locked_wth-par then ASSIGN tt-wth-ser.par-code:SCREEN-VALUE = string(LOCKED_wth-par.par-code)
                                              fill-par:SCREEN-VALUE = STRING(LOCKED_wth-par.par-val).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-wth Dialog-Frame
ON CHOOSE OF B-wth IN FRAME Dialog-Frame
DO:

      v-rid-list = ''.
      run ref/wth-ref.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input 'wth-ser':U
                        ,input-output v-rid-list) no-error.
      if v-rid-list = "" then return .
      find first locked_wealth exclusive-LOCK WHERE
              recid(locked_wealth) = integer(entry(1, v-rid-list)) NO-ERROR.
      if available locked_wealth then do:
          ASSIGN tt-wth-ser.wth-code:SCREEN-VALUE = string(LOCKED_wealth.wth-code)
                 fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.
         FIND b-wth-par WHERE b-wth-par.wth-code = LOCKED_wealth.wth-code NO-ERROR. /*  Если номинал для указанной МЦ, то заполняется авт.*/
         IF AVAILABLE b-wth-par THEN do:
             tt-wth-ser.par-code:SCREEN-VALUE = string(b-wth-par.par-code).
             APPLY 'leave':U TO tt-wth-ser.par-code.
         END.
      END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.chk-bdt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.chk-bdt Dialog-Frame
ON VALUE-CHANGED OF tt-wth-ser.chk-bdt IN FRAME Dialog-Frame /* Дата начала */
DO :
  IF SELF:SCREEN-VALUE = '1' THEN DO WITH FRAME {&FRAME-NAME}: /*Правило*/

      ENABLE tt-wth-ser.beg-dd
             tt-wth-ser.beg-mm
             tt-wth-ser.beg-yy
             tt-wth-ser.beg-yy-smb
     .
      DISABLE tt-wth-ser.beg-dt .
      tt-wth-ser.beg-dt:screen-value = "":U.

  END.
  ELSE IF SELF:SCREEN-VALUE = '2' THEN DO WITH FRAME {&FRAME-NAME}:
      DISABLE tt-wth-ser.beg-dd
             tt-wth-ser.beg-mm
             tt-wth-ser.beg-yy
             tt-wth-ser.beg-yy-smb
     .
      ENABLE tt-wth-ser.beg-dt .
      tt-wth-ser.beg-dd:screen-value = "":U.
      tt-wth-ser.beg-mm:screen-value = "":U.
      tt-wth-ser.beg-yy:screen-value = "":U.
      tt-wth-ser.beg-yy-smb:screen-value = "":U.
  END.
  ELSE  do:
  DISABLE    tt-wth-ser.beg-dd
             tt-wth-ser.beg-mm
             tt-wth-ser.beg-yy
             tt-wth-ser.beg-yy-smb
             tt-wth-ser.beg-dt
       WITH FRAME {&FRAME-NAME}.
       tt-wth-ser.beg-dd:screen-value = "":U.
       tt-wth-ser.beg-mm:screen-value = "":U.
       tt-wth-ser.beg-yy:screen-value = "":U.
       tt-wth-ser.beg-yy-smb:screen-value = "":U.
       tt-wth-ser.beg-dt:screen-value = "":U.
  end.
  apply 'tab':U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.chk-edt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.chk-edt Dialog-Frame
ON VALUE-CHANGED OF tt-wth-ser.chk-edt IN FRAME Dialog-Frame /* Дата окончания */
DO:
    IF SELF:SCREEN-VALUE = '1' THEN DO WITH FRAME {&FRAME-NAME}:
      ENABLE tt-wth-ser.end-dd
             tt-wth-ser.end-mm
             tt-wth-ser.end-yy
             tt-wth-ser.end-yy-smb
     .
      DISABLE tt-wth-ser.end-dt .
      tt-wth-ser.end-dt:screen-value = "":U.

  END.
  ELSE IF SELF:SCREEN-VALUE = '2' THEN DO WITH FRAME {&FRAME-NAME}:
      DISABLE tt-wth-ser.end-dd
             tt-wth-ser.end-mm
             tt-wth-ser.end-yy
             tt-wth-ser.end-yy-smb
     .
      ENABLE tt-wth-ser.end-dt .
      tt-wth-ser.end-dd:screen-value = "":U.
      tt-wth-ser.end-mm:screen-value = "":U.
      tt-wth-ser.end-yy:screen-value = "":U.
      tt-wth-ser.end-yy-smb:screen-value = "":U.

  END.
  ELSE  do:
     DISABLE    tt-wth-ser.end-dd
             tt-wth-ser.end-mm
             tt-wth-ser.end-yy
             tt-wth-ser.end-yy-smb
             tt-wth-ser.end-dt
       WITH FRAME {&FRAME-NAME}.
       tt-wth-ser.end-dd:screen-value = "":U.
       tt-wth-ser.end-mm:screen-value = "":U.
       tt-wth-ser.end-yy:screen-value = "":U.
       tt-wth-ser.end-yy-smb:screen-value = "":U.
       tt-wth-ser.end-dt:screen-value = "":U.
  END.
  apply 'tab':U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.chk-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.chk-gds Dialog-Frame
ON VALUE-CHANGED OF tt-wth-ser.chk-gds IN FRAME Dialog-Frame /* Код товара */
DO:
  IF SELF:SCREEN-VALUE = '1' THEN DO:
    ENABLE  tt-wth-ser.gds-smb
            tt-wth-ser.gds-rule
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    DISABLE    tt-wth-ser.gds-smb
                  tt-wth-ser.gds-rule
    WITH FRAME {&FRAME-NAME}.
    tt-wth-ser.gds-smb:screen-value = '':U.
    tt-wth-ser.gds-rule:screen-value = '':U.
  END.
  apply 'tab':U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.chk-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.chk-par Dialog-Frame
ON VALUE-CHANGED OF tt-wth-ser.chk-par IN FRAME Dialog-Frame /* Номинал */
DO:
  IF SELF:SCREEN-VALUE = '1' THEN DO:
    ENABLE  tt-wth-ser.par-smb
            tt-wth-ser.par-rule
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    DISABLE    tt-wth-ser.par-smb
               tt-wth-ser.par-rule
    WITH FRAME {&FRAME-NAME}.
    tt-wth-ser.par-smb:screen-value = '':U.
    tt-wth-ser.par-rule:screen-value = '':U.
  END.
  apply 'tab':U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.chk-ser
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.chk-ser Dialog-Frame
ON VALUE-CHANGED OF tt-wth-ser.chk-ser IN FRAME Dialog-Frame /* Серия */
DO:
  IF SELF:SCREEN-VALUE = '1' THEN do:
    ENABLE  tt-wth-ser.ser-smb
            tt-wth-ser.ser-rule
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE do:
    DISABLE    tt-wth-ser.ser-smb
               tt-wth-ser.ser-rule
       WITH FRAME {&FRAME-NAME}.
    tt-wth-ser.ser-smb:screen-value = '':U.
    tt-wth-ser.ser-rule:screen-value = '':U.
  END.
  apply 'tab':U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.par-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.par-code Dialog-Frame
ON LEAVE OF tt-wth-ser.par-code IN FRAME Dialog-Frame /* Код номинала */
DO:
    IF NOT SELF:MODIFIED THEN RETURN.
      find first locked_wth-par exclusive-LOCK WHERE
              locked_wth-par.par-code = integer(SELF:SCREEN-VALUE)
              AND  locked_wth-par.wth-code = integer(tt-wth-ser.wth-code:SCREEN-VALUE)      NO-ERROR.
      if available locked_wth-par then ASSIGN tt-wth-ser.par-code:SCREEN-VALUE = string(LOCKED_wth-par.par-code)
                                              fill-par:SCREEN-VALUE = STRING(LOCKED_wth-par.par-val).
    SELF:MODIFIED = NO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wth-ser.wth-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wth-ser.wth-code Dialog-Frame
ON LEAVE OF tt-wth-ser.wth-code IN FRAME Dialog-Frame /* Код МЦ */
DO:
  if not self:modified then return.
        find first locked_wealth exclusive-LOCK WHERE
              locked_wealth.wth-code = integer(SELF:SCREEN-VALUE) NO-ERROR.
      if available locked_wealth then do:
          ASSIGN tt-wth-ser.wth-code:SCREEN-VALUE = string(LOCKED_wealth.wth-code)
                 fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.
         FIND b-wth-par WHERE b-wth-par.wth-code = LOCKED_wealth.wth-code NO-ERROR. /*  Если номинал для указанной МЦ, то заполняется авт.*/
         IF AVAILABLE b-wth-par THEN do:
             tt-wth-ser.par-code:SCREEN-VALUE = string(b-wth-par.par-code).
             APPLY 'leave':U TO tt-wth-ser.par-code.
         END.
      END.
      SELF:MODIFIED = NO.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(par-mode, {&add-def} + {&comma-char} +
                      {&UPDATE} + {&comma-char} +
                      {&LOOKUP}) = 0 THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.

  IF par-mode = {&add-def} THEN DO:
    CREATE tt-wth-ser.
      IF pwth-code <> 0  THEN do:
        FIND FIRST LOCKED_wealth EXCLUSIVE-LOCK WHERE
                 LOCKED_wealth.wth-code = pwth-code NO-ERROR.
        IF NOT AVAILABLE LOCKED_wealth THEN DO:
            message vss-workfile vss-revision vss-description skip
            "Не найдена материальная ценность с кодом " pwth-code
            view-as alert-box error.
            return error.
        END.
        tt-wth-ser.wth-code = LOCKED_wealth.wth-code.
          IF ppar-code <> 0  THEN do:
            FIND FIRST LOCKED_wth-par EXCLUSIVE-LOCK WHERE
                     LOCKED_wth-par.wth-code = pwth-code
                AND  LOCKED_wth-par.par-code = ppar-code NO-ERROR.
            IF NOT AVAILABLE LOCKED_wth-par THEN DO:
                message vss-workfile vss-revision vss-description skip
                "Не найдена материальная ценность с кодом " ppar-code
                view-as alert-box error.
                return error.
            END.
            tt-wth-ser.par-code = LOCKED_wth-par.par-code.
          END.

      END.
  END.
  ELSE DO:
     IF par-mode = {&LOOKUP} THEN DO: /*  Серия МЦ   */
       FIND FIRST LOCKED_wth-ser NO-LOCK WHERE
                LOCKED_wth-ser.ser-code = pser-code
           AND  LOCKED_wth-ser.db-num = pdb-num NO-ERROR.

     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-ser exclusive-LOCK WHERE
                LOCKED_wth-ser.ser-code = pser-code
           AND  LOCKED_wth-ser.db-num = pdb-num NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_wth-ser THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    IF par-mode = {&LOOKUP} THEN DO:   /*   МЦ   */
       FIND FIRST LOCKED_wealth NO-LOCK WHERE
                LOCKED_wealth.wth-code = LOCKED_wth-ser.wth-code NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wealth exclusive-LOCK WHERE
                    LOCKED_wealth.wth-code = LOCKED_wth-ser.wth-code NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_wealth THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена МЦ с кодом &1 ",LOCKED_wth-ser.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    IF par-mode = {&LOOKUP} THEN DO:   /*   Номинал МЦ   */
       FIND FIRST LOCKED_wth-par NO-LOCK WHERE
                LOCKED_wth-par.par-code = LOCKED_wth-ser.par-code
           AND  LOCKED_wth-par.wth-code = LOCKED_wth-ser.wth-code          NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-par exclusive-LOCK WHERE
            LOCKED_wth-par.par-code = LOCKED_wth-ser.par-code
            AND  LOCKED_wth-par.wth-code = LOCKED_wth-ser.wth-code            NO-ERROR.

     END.
     IF NOT AVAILABLE LOCKED_wth-par THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с  кодом &2", LOCKED_wth-ser.par-code,  LOCKED_wth-ser.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    CREATE tt-wth-ser.
    BUFFER-COPY LOCKED_wth-ser TO tt-wth-ser.
  END.
   { gbl/getcntxt.i get }
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY FILL-wth FILL-par 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-ser THEN 
    DISPLAY tt-wth-ser.series tt-wth-ser.wth-code tt-wth-ser.par-code 
          tt-wth-ser.maska tt-wth-ser.authr tt-wth-ser.range-rule 
          tt-wth-ser.range-smb tt-wth-ser.chk-ser tt-wth-ser.ser-rule 
          tt-wth-ser.ser-smb tt-wth-ser.chk-gds tt-wth-ser.gds-rule 
          tt-wth-ser.gds-smb tt-wth-ser.chk-par tt-wth-ser.par-rule 
          tt-wth-ser.par-smb tt-wth-ser.chk-bdt tt-wth-ser.beg-dt 
          tt-wth-ser.beg-yy tt-wth-ser.beg-yy-smb tt-wth-ser.beg-mm 
          tt-wth-ser.beg-dd tt-wth-ser.chk-edt tt-wth-ser.end-dt 
          tt-wth-ser.end-yy tt-wth-ser.end-yy-smb tt-wth-ser.end-mm 
          tt-wth-ser.end-dd tt-wth-ser.PS tt-wth-ser.ser-code 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-3 B-exit b-quit B-hist B-Help tt-wth-ser.series 
         tt-wth-ser.par-code tt-wth-ser.range-rule tt-wth-ser.range-smb 
         tt-wth-ser.PS tt-wth-ser.ser-code FILL-wth FILL-par 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

ENABLE
B-exit WHEN par-mode <> {&LOOKUP}
b-quit
B-Help
b-hist WHEN par-mode = {&update} OR par-mode = {&LOOKUP}
WITH FRAME {&frame-name}.
IF par-mode = {&add-def} THEN DO:
    ENABLE
    tt-wth-ser.series
    tt-wth-ser.wth-code when not available locked_wealth
    tt-wth-ser.par-code when not available locked_wth-par
    b-wth when not available locked_wealth
    b-par when not available locked_wth-par
    WITH FRAME {&frame-name}.
    tt-wth-ser.authr = 1.
    tt-wth-ser.chk-ser = 1.
END.
DISPLAY
   {&FIELDS-IN-QUERY-Dialog-Frame}
WITH FRAME {&frame-name}  .
VIEW FRAME {&frame-name}.

IF par-mode = {&add-def} or par-mode = {&update} THEN DO:
    ENABLE
    tt-wth-ser.chk-ser
    tt-wth-ser.chk-par
    tt-wth-ser.chk-gds
    tt-wth-ser.chk-edt
    tt-wth-ser.chk-bdt
    tt-wth-ser.range-smb
    tt-wth-ser.range-rule
    tt-wth-ser.authr
    tt-wth-ser.maska
    tt-wth-ser.PS
    tt-wth-ser.series
 WITH FRAME {&frame-name}.
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-ser .
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-par.
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-gds .
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-edt.
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-bdt.
END.

IF AVAILABLE LOCKED_wealth THEN fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.
IF AVAILABLE LOCKED_wth-par THEN fill-par:SCREEN-VALUE = string(LOCKED_wth-par.par-val).

IF par-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit IN FRAME {&FRAME-NAME}
  .
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
frame {&frame-name}:title = substitute("Серия номинала &1 &4 материальной ценности &2  &3"
                                     ,if available LOCKED_wth-par then string (LOCKED_wth-par.par-val) else ""
                                     ,if available locked_wealth then locked_wealth.wth-name else ""
                                     ,par-mode
                                     ,if available LOCKED_wth-par then LOCKED_wth-par.par-unit else ""
                                      ).
/*IF  par-mode = {&add-def} THEN DO:*/
/*    APPLY 'choose':U TO b-wth.*/
/*END.*/
APPLY 'entry':U TO tt-wth-ser.series.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF par-mode = {&LOOKUP} THEN UNDO, RETURN ERROR.
assign
FRAME {&frame-name} {&FIELDS-IN-QUERY-Dialog-Frame}.
if  par-mode = {&update} then v-rec = recid(locked_wth-ser).
run ref/wth-ser.p ( INPUT par-mode
                    , tt-wth-ser.ser-code
                    , tt-wth-ser.db-num
                    , tt-wth-ser.maska
                    , tt-wth-ser.series
                    , tt-wth-ser.authr
                    , tt-wth-ser.wth-code
                    , tt-wth-ser.par-code
                    , tt-wth-ser.beg-dd
                    , tt-wth-ser.beg-dt
                    , tt-wth-ser.beg-mm
                    , tt-wth-ser.beg-yy-smb
                    , tt-wth-ser.beg-yy
                    , tt-wth-ser.chk-bdt
                    , tt-wth-ser.chk-edt
                    , tt-wth-ser.chk-gds
                    , tt-wth-ser.chk-par
                    , tt-wth-ser.chk-ser
                    , tt-wth-ser.end-dd
                    , tt-wth-ser.end-dt
                    , tt-wth-ser.end-mm
                    , tt-wth-ser.end-yy-smb
                    , tt-wth-ser.end-yy
                    , tt-wth-ser.gds-rule
                    , tt-wth-ser.gds-smb
                    , tt-wth-ser.par-rule
                    , tt-wth-ser.par-smb
                    , tt-wth-ser.PS
                    , tt-wth-ser.qnty
                    , tt-wth-ser.range-rule
                    , tt-wth-ser.range-smb
                    , tt-wth-ser.ser-rule
                    , tt-wth-ser.ser-smb
                    ,INPUT NO /*p-silent*/
                    ,INPUT-OUTPUT v-rec  ) no-error .
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

