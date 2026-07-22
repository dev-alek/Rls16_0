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


DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА ПРИЛОЖЕНИЕ */
DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧУЮ КНИГУ */
DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO. /* ССЫЛКА НА РАБОЧИЙ ЛИСТ */
DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO. /* Максимально пропусков */
define variable parparentproc     as widget-handle    no-undo.
define variable v_os-file         as char             no-undo.
define stream imp.
define stream err.

define variable vSubs as class ibs.th.ref.promo.promoactionsubs no-undo .
define variable v-text-promo  as character no-undo .
define variable ii  as integer no-undo .
define variable v-promo-action as class     ibs.th.ref.promo.promoactionsub       no-undo .

define temp-table tt-promo like ub.PromoAction .

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
&Scoped-Define ENABLED-OBJECTS RECT-7 EDITOR-3 RADIO-SET-3 t-1 
&Scoped-Define DISPLAYED-OBJECTS EDITOR-3 RADIO-SET-3 t-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE EDITOR-3 AS CHARACTER INITIAL "Все" 
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 40.63 BY 3.71 NO-UNDO.

DEFINE VARIABLE RADIO-SET-3 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 15 BY 1.71 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 66.5 BY 4.88.

DEFINE VARIABLE t-1 AS LOGICAL INITIAL no 
     LABEL "Включать возвраты" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     EDITOR-3 AT ROW 2.33 COL 25.13 NO-LABEL WIDGET-ID 12
     RADIO-SET-3 AT ROW 2.54 COL 3.5 NO-LABEL WIDGET-ID 14
     t-1 AT ROW 7 COL 4 WIDGET-ID 36
     "Выбор промоакций:" VIEW-AS TEXT
          SIZE 18.5 BY .67 AT ROW 1.38 COL 5 WIDGET-ID 34
     RECT-7 AT ROW 1.71 COL 2
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
         HEIGHT             = 8.25
         WIDTH              = 69.63.
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

ASSIGN 
       EDITOR-3:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME RADIO-SET-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-3 s-object
ON VALUE-CHANGED OF RADIO-SET-3 IN FRAME F-Main
DO:

    ASSIGN
      Radio-set-3
      .
    CASE RADIO-SET-3:
      /*выборочно*/
      WHEN 2
      THEN 
        DO:
          run ref/promo.p (input parparentproc,yes,output vSubs) no-error.
          if not valid-object (vSubs) then return.
                      
            EDITOR-3 = "":U.
            EMPTY TEMP-TABLE tt-promo.

            v-text-promo = "" .
            
      DO ii = 1 to vSubs:iCounter:
        vSubs:GetItem(ii).
        v-promo-action = vSubs:promoActionObjCurr .
        FIND FIRST ub.PromoAction No-LOCK WHERE
          ub.PromoAction.id = v-promo-action:ID 
          and ub.PromoAction.db-num = v-cntxt-db-num 
          No-ERROR.
        IF avail ub.PromoAction then
        do:
          CREATE tt-promo.
          buffer-copy ub.PromoAction to tt-promo .
              ASSIGN
                v-text-promo = v-text-promo + {&new-line} + ub.PromoAction.nameAction.
              .
            END.
            ASSIGN
              v-text-promo = TRIM(v-text-promo, {&new-line})
              EDITOR-3   = v-text-promo
              .
          END.

        END.

      /*Все*/
      WHEN 1 THEN 
        DO:
          EDITOR-3 = "Все":U.
           EMPTY TEMP-TABLE tt-promo.
          FOR EACH  ub.PromoAction No-LOCK WHERE
          ub.PromoAction.id = v-promo-action:ID 
          and ub.PromoAction.db-num = v-cntxt-db-num 
            :
            CREATE tt-promo.
            buffer-copy ub.PromoAction to tt-promo .
            ASSIGN
              v-text-promo = v-text-promo + {&new-line} + ub.PromoAction.nameAction
              .
          END.
        END.
      OTHERWISE 
      DO:
      END.
    END case.
    DISPLAY
      EDITOR-3
      WITH FRAME {&frame-name}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-1 s-object
ON VALUE-CHANGED OF t-1 IN FRAME F-Main /* Включать возвраты */
DO:
  assign t-1 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
parparentproc = my-handle.
{ gbl/getcntxt.i get }
RUN enable_UI.

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
  DISPLAY EDITOR-3 RADIO-SET-3 t-1 
      WITH FRAME F-Main.
  ENABLE RECT-7 EDITOR-3 RADIO-SET-3 t-1 
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
if RADIO-SET-3 = 1 then do:
  empty temp-table tt-promo .
  FOR EACH  ub.PromoAction No-LOCK:
            CREATE tt-promo.
            buffer-copy ub.PromoAction to tt-promo .
          END.
end.  

    run rep/r-vbbr_viza.p
      (input my-handle 
      ,input table tt-promo 
      ,input t-1
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
  assign frame {&frame-name} RADIO-SET-3 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

