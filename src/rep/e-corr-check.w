&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-grp NO-UNDO LIKE gds-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
/*

Автор: Кирюхин Сергей
Дата создания: 03/09/12
Author: SKiryxin
Creation date: 03/09/12

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ gbl/sel-date.i }
{ gbl/godendo.i  }
{ cmp/r-page1.i  }
{ gbl/getcntxt.i def }
{gbl/tmprecid.i }

DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */
define variable parparentproc     as widget-handle    no-undo.

define variable v-corr-osnov  as character no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS cb-check-type v-doc-osnov BUTTON-1 ~
f-date-corr f-num-corr r-shift 
&Scoped-Define DISPLAYED-OBJECTS cb-check-type v-doc-osnov f-date-corr ~
f-num-corr r-shift 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-1 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 2.63 BY 1 TOOLTIP "Выбор фирм".

DEFINE VARIABLE cb-check-type AS CHARACTER FORMAT "X(256)":U 
     LABEL "Тип чека" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","1"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-date-corr AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата документа основания" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f-num-corr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Номер документа основания" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-doc-osnov AS CHARACTER FORMAT "X(256)":U 
     LABEL "Документ основания" 
     VIEW-AS FILL-IN 
     SIZE 26.25 BY 1 TOOLTIP "Для режима все по фирме - здесь должен быть указан список кодов фирм." NO-UNDO.

DEFINE VARIABLE r-shift AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Всем", 0,
"Закрытым", 1,
"Открытым", 2
     SIZE 13.5 BY 3 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     cb-check-type AT ROW 2.42 COL 30 COLON-ALIGNED WIDGET-ID 40
     v-doc-osnov AT ROW 3.71 COL 30 COLON-ALIGNED WIDGET-ID 56
     BUTTON-1 AT ROW 3.75 COL 59 WIDGET-ID 54
     f-date-corr AT ROW 5 COL 30 COLON-ALIGNED WIDGET-ID 44
     f-num-corr AT ROW 6.25 COL 30 COLON-ALIGNED WIDGET-ID 46
     r-shift AT ROW 8 COL 48 NO-LABEL WIDGET-ID 48
     "Выбор по сформированным чекам по сменам:" VIEW-AS TEXT
          SIZE 41.5 BY .75 AT ROW 8.25 COL 4 WIDGET-ID 52
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
   Temp-Tables and Buffers:
      TABLE: tt-grp T "?" NO-UNDO ub gds-grp
   END-TABLES.
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 18.25
         WIDTH              = 73.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 s-object
ON CHOOSE OF BUTTON-1 IN FRAME F-Main
DO:
  def var p-corr-osnov as character no-undo.
  def var rid# as character no-undo .

    run ref/codelayout.p({&select},"","OsnovCorr", "Основание коррекции",output table tmprecid).
    
    for first tmprecid where tmprecid.fTable = "code" no-lock:
      find first ub.Code no-lock where recid (ub.Code) = integer(tmprecid.Frecid) no-error .
      v-doc-osnov = ub.Code.CodeName.
      v-corr-osnov = ub.Code.code .
      display v-doc-osnov with frame {&frame-name} .
      apply "LEAVE":U to v-doc-osnov.
    end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-check-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-check-type s-object
ON VALUE-CHANGED OF cb-check-type IN FRAME F-Main /* Тип чека */
DO:
  assign cb-check-type .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date-corr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date-corr s-object
ON LEAVE OF f-date-corr IN FRAME F-Main /* Дата документа основания */
DO:
  assign f-date-corr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-num-corr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-num-corr s-object
ON LEAVE OF f-num-corr IN FRAME F-Main /* Номер документа основания */
DO:
  assign f-num-corr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-shift s-object
ON VALUE-CHANGED OF r-shift IN FRAME F-Main
DO:
  assign r-shift .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-doc-osnov
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-doc-osnov s-object
ON LEAVE OF v-doc-osnov IN FRAME F-Main /* Документ основания */
DO:
do with frame {&frame-name}:
  ASSIGN
    v-doc-osnov
  .
end. /* do with frame */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
parparentproc = my-handle.
{ gbl/getcntxt.i get }
{ gbl/ed_date.i f-date-corr }

assign
cb-check-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  {&receipt-codes-combo} 
.  
/*end.                                                                                                                                          */
/*else do:                                                                                                                                      */
/*assign                                                                                                                                        */
/*cb-check-type:LIST-ITEM-PAIRS  in frame {&frame-name} =  '{&bef-rcpt-sale-full},{&bef-rcpt-sale},{&bef-rcpt-return-full},{&bef-rcpt-return}':U*/
/*                                                                                                                                              */
/*.                                                                                                                                             */
/*end.                                                                                                                                          */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
  DISPLAY cb-check-type v-doc-osnov f-date-corr f-num-corr r-shift 
      WITH FRAME F-Main.
  ENABLE cb-check-type v-doc-osnov BUTTON-1 f-date-corr f-num-corr r-shift 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
    Purpose:     Override standard ADM method
    Notes:
  ------------------------------------------------------------------------------*/

  do
    on error undo, return error return-value
    :

    run rep/r-corr-check.p
      (input my-handle
      ,input cb-check-type
      ,input v-corr-osnov
      ,input f-date-corr
      ,input f-num-corr
      ,input r-shift
      ) .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
    Purpose:     здесь происходит вызов  значений переменных
    например  Название отчета, может быть еще пример шапки ???
  ------------------------------------------------------------------------------*/
  assign frame {&frame-name} v-doc-osnov .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

