&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_firm FOR ub.firm.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список организаций по торговому представителю

Автор: Булгаков Андрей Николаевич
Дата создания: 05/18/98
Author: Andrew Bulgakoff
Creation date: 05/18/98


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS   WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code    LIKE ub.clients.obj-code NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список организаций по торговому представителю".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i      }
{ gbl/prn-lib.i      }
{ cmp/r-pril.i       }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE tobj-name LIKE ub.clients.obj-name NO-UNDO.

/* Local Variable Definitions */
DEFINE VARIABLE sort-column-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-doc-rec          AS RECID     NO-UNDO.
DEFINE VARIABLE get-limkrit-all AS DECIMAL   NO-UNDO .
DEFINE VARIABLE get-limkrit-cnt AS INTEGER   NO-UNDO .
define variable filter-point as character no-undo init "rpsn-org".
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_firm FOR ub.firm.

&SCOP label-clmn_1-br-dtl  'Код'
&SCOP form-clmn_1-br-dtl   ">>>>>>>>9":U
&SCOP sort-clmn_1-br-dtl   X_firm.firm-code
&SCOP label-clmn_2-br-dtl  'Название фирмы'
&SCOP form-clmn_2-br-dtl   "x(60)":U
&SCOP sort-clmn_2-br-dtl   get-firm-name( X_firm.firm-code )
&SCOP dyn_sort-clmn_2-br-dtl   substitute('dynamic-function(&1get-firm-name&1, X_firm.firm-code)', ~{&double-quote~})
&SCOP label-clmn_3-br-dtl  'Страна, город'
&SCOP form-clmn_3-br-dtl   "x(40)":U
&SCOP sort-clmn_3-br-dtl   X_firm.city
&SCOP label-clmn_4-br-dtl  'Юридический Адрес'
&SCOP form-clmn_4-br-dtl   "x(100)":U
&SCOP sort-clmn_4-br-dtl   TRIM( X_firm.addres1 ) + ' ':U + TRIM( X_firm.addres2 )
&SCOP label-clmn_5-br-dtl  'Почтовый Адрес'
&SCOP form-clmn_5-br-dtl   "x(100)":U
&SCOP sort-clmn_5-br-dtl   TRIM( X_firm.post-addr1 ) + ' ':U + TRIM( X_firm.post-addr2 )
&SCOP label-clmn_6-br-dtl  'Индекс'
&SCOP form-clmn_6-br-dtl   "999999":U
&SCOP sort-clmn_6-br-dtl   X_firm.ind
&SCOP label-clmn_7-br-dtl  '{&abbr_inn_allshift}'
&SCOP form-clmn_7-br-dtl   "x(15)":U
&SCOP sort-clmn_7-br-dtl   X_firm.inn
&SCOP label-clmn_8-br-dtl  '{&abbr_kpp_allshift}'
&SCOP form-clmn_8-br-dtl   "x(9)":U
&SCOP sort-clmn_8-br-dtl   X_firm.kpp
&SCOP label-clmn_9-br-dtl  '{&abbr_okonh_allshift}'
&SCOP form-clmn_9-br-dtl   "x(100)":U
&SCOP sort-clmn_9-br-dtl   X_firm.okonh
&SCOP label-clmn_10-br-dtl 'ОКПО'
&SCOP form-clmn_10-br-dtl  "x(8)":U
&SCOP sort-clmn_10-br-dtl  X_firm.okpo
&SCOP label-clmn_11-br-dtl 'Руководитель'
&SCOP form-clmn_11-br-dtl  "x(25)":U
&SCOP sort-clmn_11-br-dtl  X_firm.director
&SCOP label-clmn_12-br-dtl 'Главный бухгалтер'
&SCOP form-clmn_12-br-dtl  "x(100)":U
&SCOP sort-clmn_12-br-dtl  X_firm.gen-acct
&SCOP label-clmn_13-br-dtl 'Факс'
&SCOP form-clmn_13-br-dtl  "x(20)":U
&SCOP sort-clmn_13-br-dtl  X_firm.fax
&SCOP label-clmn_14-br-dtl 'Телефон'
&SCOP form-clmn_14-br-dtl  "x(20)":U
&SCOP sort-clmn_14-br-dtl  X_firm.phone
&SCOP label-clmn_15-br-dtl 'Примечание'
&SCOP form-clmn_15-br-dtl  "x(22)":U
&SCOP sort-clmn_15-br-dtl  X_firm.phone1-note
&SCOP label-clmn_16-br-dtl 'Лимит кредита'
&SCOP form-clmn_16-br-dtl  "->>,>>>,>>>,>>>,>>9.99":U
&SCOP sort-clmn_16-br-dtl  get-limkr( X_firm.firm-code )

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-psn-org

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_firm

/* Definitions for BROWSE br-psn-org                                    */
&Scoped-define FIELDS-IN-QUERY-br-psn-org {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} {&sort-clmn_6-br-dtl} {&sort-clmn_7-br-dtl} {&sort-clmn_8-br-dtl} {&sort-clmn_9-br-dtl} {&sort-clmn_10-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_12-br-dtl} {&sort-clmn_13-br-dtl} {&sort-clmn_14-br-dtl} {&sort-clmn_15-br-dtl} {&sort-clmn_16-br-dtl}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-psn-org {&sort-clmn_3-br-dtl}   
&Scoped-define SELF-NAME br-psn-org
&Scoped-define QUERY-STRING-br-psn-org FOR EACH X_firm NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-psn-org OPEN QUERY br-psn-org FOR EACH X_firm NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-psn-org X_firm
&Scoped-define FIRST-TABLE-IN-QUERY-br-psn-org X_firm


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-psn-org}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-lkp b-hist b-print B-Help ~
br-psn-org get-limkr-label 
&Scoped-Define DISPLAYED-OBJECTS get-limkr-label 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-firm-name Dialog-Frame 
FUNCTION get-firm-name RETURNS CHARACTER
  ( INPUT p-firm-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-limkr Dialog-Frame 
FUNCTION get-limkr RETURNS DECIMAL
  ( INPUT p-firm-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE get-limkr-label AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 4 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-psn-org FOR 
      X_firm SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-psn-org
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-psn-org Dialog-Frame _FREEFORM
  QUERY br-psn-org DISPLAY
      {&sort-clmn_1-br-dtl}  COLUMN-LABEL {&label-clmn_1-br-dtl}  FORMAT {&form-clmn_1-br-dtl}
{&sort-clmn_2-br-dtl}  COLUMN-LABEL {&label-clmn_2-br-dtl}  FORMAT {&form-clmn_2-br-dtl}
{&sort-clmn_3-br-dtl}  COLUMN-LABEL {&label-clmn_3-br-dtl}  FORMAT {&form-clmn_3-br-dtl}
{&sort-clmn_4-br-dtl}  COLUMN-LABEL {&label-clmn_4-br-dtl}  FORMAT {&form-clmn_4-br-dtl}
{&sort-clmn_5-br-dtl}  COLUMN-LABEL {&label-clmn_5-br-dtl}  FORMAT {&form-clmn_5-br-dtl}
{&sort-clmn_6-br-dtl}  COLUMN-LABEL {&label-clmn_6-br-dtl}  FORMAT {&form-clmn_6-br-dtl}
{&sort-clmn_7-br-dtl}  COLUMN-LABEL {&label-clmn_7-br-dtl}  FORMAT {&form-clmn_7-br-dtl}
{&sort-clmn_8-br-dtl}  COLUMN-LABEL {&label-clmn_8-br-dtl}  FORMAT {&form-clmn_8-br-dtl}
{&sort-clmn_9-br-dtl}  COLUMN-LABEL {&label-clmn_9-br-dtl}  FORMAT {&form-clmn_9-br-dtl}
{&sort-clmn_10-br-dtl} COLUMN-LABEL {&label-clmn_10-br-dtl} FORMAT {&form-clmn_10-br-dtl}
{&sort-clmn_11-br-dtl} COLUMN-LABEL {&label-clmn_11-br-dtl} FORMAT {&form-clmn_11-br-dtl}
{&sort-clmn_12-br-dtl} COLUMN-LABEL {&label-clmn_12-br-dtl} FORMAT {&form-clmn_12-br-dtl}
{&sort-clmn_13-br-dtl} COLUMN-LABEL {&label-clmn_13-br-dtl} FORMAT {&form-clmn_13-br-dtl}
{&sort-clmn_14-br-dtl} COLUMN-LABEL {&label-clmn_14-br-dtl} FORMAT {&form-clmn_14-br-dtl}
{&sort-clmn_15-br-dtl} COLUMN-LABEL {&label-clmn_15-br-dtl} FORMAT {&form-clmn_15-br-dtl}
{&sort-clmn_16-br-dtl} COLUMN-LABEL {&label-clmn_16-br-dtl} FORMAT {&form-clmn_16-br-dtl}
ENABLE
{&sort-clmn_3-br-dtl}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-lkp AT ROW 1 COL 31 WIDGET-ID 2
     b-hist AT ROW 1 COL 89 WIDGET-ID 4
     b-print AT ROW 1 COL 92 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     br-psn-org AT ROW 3 COL 1 WIDGET-ID 100
     get-limkr-label AT ROW 19.13 COL 1 NO-LABEL WIDGET-ID 10
     SPACE(0.70) SKIP(0.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_firm B "?" ? ub firm
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-psn-org B-Help Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       get-limkr-label:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-psn-org
/* Query rebuild information for BROWSE br-psn-org
     _START_FREEFORM
OPEN QUERY br-psn-org FOR EACH X_firm NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-psn-org */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
  IF NOT AVAILABLE X_firm THEN RETURN NO-APPLY.
  run ref/cclihist.w ( INPUT     parparentproc      /* parparentproc       */
                       ,INPUT        0                  /* p-curr-host-code   */
                       ,INPUT        "":U               /* p-curr-obj-type    */
                       ,INPUT        0                  /* p-curr-obj-code    */
                       ,INPUT        "":U               /* bttns              */
                       ,INPUT        "one":U            /* p-mode             */
                       ,INPUT        {&cmp}             /* p-obj-type         */
                       ,INPUT        X_firm.firm-code /* p-obj-code         */
                       ,INPUT        ?                  /* p-host-code        */
                       ,INPUT        ?                  /* p-corr-user-db-num */
                       ,INPUT        "":U               /* p-corr-user-name   */
                       ,INPUT        "":U               /* p-subject          */
                       ,INPUT        v-cntxt-db-num           /* p-db-num           */
                       ,INPUT-OUTPUT v-rid-list          ) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
IF NOT AVAILABLE X_firm  THEN RETURN NO-APPLY.
run ref/showcli.p ( INPUT        parparentproc
                 ,INPUT        {&cmp}
                 ,INPUT        X_firm.firm-code).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  ASSIGN
  v-doc-rec = RECID( X_firm ) NO-ERROR.
  RUN proc-b-print IN THIS-PROCEDURE.
  REPOSITION br-psn-org TO RECID v-doc-rec NO-ERROR.
  APPLY "ENTRY":U TO br-psn-org IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-psn-org
&Scoped-define SELF-NAME br-psn-org
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-psn-org Dialog-Frame
ON DEFAULT-ACTION OF br-psn-org IN FRAME Dialog-Frame
DO:
    APPLY "CHOOSE":U TO b-lkp IN FRAME {&FRAME-NAME}.
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

{ gbl/mv-clmn.i
    &ext-col      = 16
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "X_firm"
    &start-column = 1              }

{ gbl/srt-clmn.i
    &ext-col              = 16
    &browse-name          = "{&BROWSE-NAME}"
    &frame-name           = "{&FRAME-NAME}"
    &table-name           = "X_firm"
    &start-column         = 1
    &label-clmn_1         = "{&label-clmn_1-br-dtl}"
    &sort-clmn_1          = "{&sort-clmn_1-br-dtl}"
    &label-clmn_2         = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2          = "{&sort-clmn_2-br-dtl}"
    &dyn_sort-clmn_2      = "{&dyn_sort-clmn_2-br-dtl}"
    &label-clmn_3         = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3          = "{&sort-clmn_3-br-dtl}"
    &label-clmn_4         = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4          = "{&sort-clmn_4-br-dtl}"
    &label-clmn_5         = "{&label-clmn_5-br-dtl}"
    &sort-clmn_5          = "{&sort-clmn_5-br-dtl}"
    &label-clmn_6         = "{&label-clmn_6-br-dtl}"
    &sort-clmn_6          = "{&sort-clmn_6-br-dtl}"
    &label-clmn_7         = "{&label-clmn_7-br-dtl}"
    &sort-clmn_7          = "{&sort-clmn_7-br-dtl}"
    &label-clmn_8         = "{&label-clmn_8-br-dtl}"
    &sort-clmn_8          = "{&sort-clmn_8-br-dtl}"
    &label-clmn_9         = "{&label-clmn_9-br-dtl}"
    &sort-clmn_9          = "{&sort-clmn_9-br-dtl}"
    &label-clmn_10        = "{&label-clmn_10-br-dtl}"
    &sort-clmn_10         = "{&sort-clmn_10-br-dtl}"
    &label-clmn_11        = "{&label-clmn_11-br-dtl}"
    &sort-clmn_11         = "{&sort-clmn_11-br-dtl}"
    &label-clmn_12        = "{&label-clmn_12-br-dtl}"
    &sort-clmn_12         = "{&sort-clmn_12-br-dtl}"
    &label-clmn_13        = "{&label-clmn_13-br-dtl}"
    &sort-clmn_13         = "{&sort-clmn_13-br-dtl}"
    &label-clmn_14        = "{&label-clmn_14-br-dtl}"
    &sort-clmn_14         = "{&sort-clmn_14-br-dtl}"
    &label-clmn_15        = "{&label-clmn_15-br-dtl}"
    &sort-clmn_15         = "{&sort-clmn_15-br-dtl}"
    &label-clmn_16        = "{&label-clmn_16-br-dtl}"
    &sort-clmn_16         = "{&sort-clmn_16-br-dtl}"
    &open-query           = "RUN OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U )."
    &open-query-otherwise = "RUN OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U )."
    &sort-column-name     = "sort-column-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"                                                               }


{ gbl/hot-key.i b-lkp  }
{ gbl/hot-key.i b-help  }
{ gbl/hot-key.i b-print }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i GET }
  FIND FIRST buf_clients NO-LOCK WHERE
       buf_clients.obj-type = {&prs} AND
       buf_clients.obj-code = p-obj-code NO-ERROR.
  IF NOT AVAILABLE buf_Clients THEN DO:
    MESSAGE
    "Неверное значение параметра p-obj-code" p-obj-code
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  ASSIGN tobj-name = buf_clients.obj-name.
  run waitfram-show in this-procedure ( "Ждите..." ).
  FOR EACH buf_firm NO-LOCK WHERE buf_firm.tobj-code = p-obj-code :
    FIND FIRST buf_clients NO-LOCK WHERE
         buf_clients.obj-type = {&cmp} AND
         buf_clients.obj-code = buf_firm.firm-code NO-ERROR.
    IF NOT AVAILABLE buf_clients THEN DO:
        NEXT.
    END.
    ASSIGN
    get-limkrit-all = get-limkrit-all + buf_clients.lim-kr
    get-limkrit-cnt = get-limkrit-cnt + 1
    .
  END.
  IF get-limkrit-cnt = 0 THEN DO:
    run waitfram-hide in this-procedure .
    MESSAGE
    substitute('Нет организаций по торговому представителю &1!'
               , tobj-name )
     VIEW-AS ALERT-BOX ERROR.
    UNDO Main-Block, LEAVE Main-Block.
  END.
  ASSIGN get-limkr-label = substitute("Количество фирм по торговому представителю: &1&2" +
                                      "Общий лимит кредита &3"
                                      ,get-limkrit-cnt
                                      ,{&NEW-LINE}
                                      ,get-limkrit-all).
   run waitfram-hide in this-procedure .

  RUN Myenable.
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
  DISPLAY get-limkr-label 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-lkp b-hist b-print B-Help br-psn-org get-limkr-label 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable PRIVATE :
ASSIGN
br-psn-org:NUM-LOCKED-COLUMNS IN FRAME  {&FRAME-NAME}  = 1
{&sort-clmn_3-br-dtl}:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES
FRAME {&FRAME-NAME} :TITLE = substitute('Организации по торговому представителю &1', tobj-name)
.
DISPLAY
get-limkr-label
WITH FRAME {&FRAME-NAME}.
ENABLE
b-quit
b-lkp
b-hist
b-print
B-Help
br-psn-org
get-limkr-label
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U ).
REPOSITION br-psn-org TO ROW 1 NO-ERROR.
APPLY "ENTRY" TO br-psn-org.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
DEFINE INPUT PARAMETER p-open-query     AS LOGICAL   NO-UNDO.
DEFINE INPUT PARAMETER p-find-next      AS LOGICAL   NO-UNDO.
DEFINE INPUT PARAMETER p-find-condition AS CHARACTER NO-UNDO.

DEFINE VARIABLE l-query-was-opened AS LOGICAL   NO-UNDO.
DEFINE VARIABLE sort-column-phrase AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-proc-hand        AS HANDLE    NO-UNDO.

RUN WaitFram-Show IN THIS-PROCEDURE ( INPUT "Ждите..." ).
ASSIGN p-proc-hand = THIS-PROCEDURE :HANDLE.

CASE sort-column-name :
  WHEN "":U THEN DO:
     ASSIGN sort-column-phrase = "":U.
  END.
  OTHERWISE      DO:
    ASSIGN
    sort-column-phrase = "BY " + sort-column-name.
  END.
END CASE. /* sort-column-name */


&SCOP flt-open-open-query         OPEN QUERY br-psn-org FOR EACH X_firm

&SCOP flt-open-dyn_open-query         FOR EACH X_firm

&SCOP flt-open-query-handle  QUERY br-psn-org:handle

&SCOP flt-open-open-query-tail

&SCOP flt-open-query-was-opened   l-query-was-opened

&SCOP flt-open-sort-column-phrase sort-column-phrase

&SCOP flt-open-call-point         filter-point

&SCOP flt-open-set-filter-name

&SCOP flt-open-indexed-reposition INDEXED-REPOSITION

&scop flt-open-table-name X_firm

&SCOP flt-open-query              p-open-query

&SCOP flt-open-search-option      NO-LOCK

&SCOP flt-open-find-next          p-find-next

&SCOP flt-open-find-recid         v-doc-rec

&SCOP flt-open-find-condition     p-find-condition

&SCOP flt-open-find-buffer-name X_firm

&SCOP flt-open-waitfram           yes

DEFINE VARIABLE l-open-query AS LOGICAL NO-UNDO.

{ gbl/fltopend.i
  &where-cond = " X_firm.tobj-code = p-obj-code "
  &dyn_where-cond = " substitute('X_firm.tobj-code = &1', p-obj-code )"
  &use-ind    = "  "
  &by         = "  "
}
IF NOT p-open-query THEN DO:
   REPOSITION br-psn-org TO RECID v-doc-rec NO-ERROR.
END.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-psn-org:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
RUN WaitFram-Hide IN THIS-PROCEDURE.
APPLY "VALUE-CHANGED":U TO br-psn-org IN FRAME {&FRAME-NAME}.
APPLY "ENTRY":U         TO br-psn-org IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
DEFINE VARIABLE sym1 AS CHARACTER NO-UNDO INITIAL ":" COLUMN-LABEL ":!:" FORMAT "x(1)":U.
DEFINE VARIABLE sym2 AS CHARACTER NO-UNDO INITIAL ":" COLUMN-LABEL ":!:" FORMAT "x(1)":U.
DEFINE VARIABLE sym3 AS CHARACTER NO-UNDO INITIAL ":" COLUMN-LABEL ":!:" FORMAT "x(1)":U.
DEFINE VARIABLE sym4 AS CHARACTER NO-UNDO INITIAL ":" COLUMN-LABEL ":!:" FORMAT "x(1)":U.
DEFINE VARIABLE sym5 AS CHARACTER NO-UNDO INITIAL ":" COLUMN-LABEL ":!:" FORMAT "x(1)":U.
DEFINE VARIABLE sym6 AS CHARACTER NO-UNDO INITIAL ":" COLUMN-LABEL ":!:" FORMAT "x(1)":U.
DEFINE VARIABLE Line AS CHARACTER NO-UNDO.
DEFINE VARIABLE accum-count AS INTEGER NO-UNDO.
define variable date_string as character no-undo .
DEFINE BUFFER buf_clients FOR ub.clients.

DEFINE FRAME f-prn
sym1 X_firm.firm-code
sym2 buf_clients.obj-name
sym3 X_firm.addres1
     X_firm.addres2
sym4 X_firm.city
sym5 buf_clients.lim-kr   sym6
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>>9" SKIP
Line format "X({&A4_LS})" AT 1
with width {&DOS_CW_2} down stream-io use-text no-box   .

ASSIGN Line = FILL( "-", 135 ).
run waitfram-show in this-procedure ( input "Ждите...").
RUN prn-lib-open-stream IN THIS-PROCEDURE ( INPUT parparentproc
                                              ,INPUT {&CS_PS}
                                              ,INPUT YES /* Is Stream */
                                              ,INPUT NO   /* Append    */ ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(177)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME f-prn  .
DO WHILE available X_firm :
  GET prev br-psn-org no-lock.
end.
GET next br-psn-org  no-lock.
DO WHILE available X_firm :
  accum-count = accum-count + 1.
  FIND FIRST buf_clients NO-LOCK WHERE
              buf_clients.obj-type = {&cmp}
        AND buf_clients.obj-code = X_firm.firm-code NO-ERROR.
  DISPLAY STREAM
  PrnLibStream
  sym1 X_firm.firm-code
  sym2 buf_clients.obj-name
  sym3 X_firm.addres1
  sym4 X_firm.city
  sym5 buf_clients.lim-kr
  sym6 X_firm.addres2
  WITH FRAME f-prn.
  DOWN
  STREAM PrnLibStream
  WITH FRAME f-prn.
  GET next br-psn-org  no-lock.
END.
UNDERLINE
STREAM PrnLibStream
X_firm.firm-code
buf_clients.obj-name
buf_clients.lim-kr
WITH FRAME f-prn.
DOWN
STREAM PrnLibStream WITH FRAME f-prn.
DISPLAY
STREAM PrnLibStream
get-limkr-label @ ub.clients.obj-name
get-limkrit-all @ ub.clients.lim-kr
WITH FRAME f-prn.
DOWN      STREAM PrnLibStream WITH FRAME f-prn.
PUT    STREAM PrnLibStream Line FORMAT "x({&DOS_CW_2})":U SKIP.
OUTPUT STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
RUN prn-lib-prn-file IN THIS-PROCEDURE ( INPUT parparentproc
                                       , INPUT 0 ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-firm-name Dialog-Frame 
FUNCTION get-firm-name RETURNS CHARACTER
  ( INPUT p-firm-code AS integer ) :
DEFINE BUFFER buf_clients FOR ub.clients.
FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = {&cmp}
      AND buf_clients.obj-code = p-firm-code NO-ERROR.
IF AVAILABLE buf_clients THEN DO:
  RETURN buf_clients.obj-name.
END.
RETURN substitute("!!!ОРГАНИЗАЦИЯ &1 НЕ НАЙДЕНА", p-firm-code).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-limkr Dialog-Frame 
FUNCTION get-limkr RETURNS DECIMAL
  ( INPUT p-firm-code AS integer ) :

DEFINE BUFFER buf_clients FOR ub.clients.

FIND FIRST buf_clients NO-LOCK WHERE
       buf_clients.obj-type = {&cmp} AND
       buf_clients.obj-code = p-firm-code NO-ERROR.
IF AVAILABLE buf_clients THEN RETURN buf_clients.lim-kr.
RETURN 0.00.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

