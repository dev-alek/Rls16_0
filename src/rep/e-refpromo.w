&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

По примененным скидкам

Автор: Белова Марина
Дата создания: 31/01/24
Author: Belova Marina
Creation date: 31/01/24

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Срабатывание промо-акции" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }

define variable vSubs as class ibs.th.ref.promo.promoactionsubs no-undo .
define variable v-text-promo  as character no-undo .
define variable ii  as integer no-undo .
define variable v-promo-action as class     ibs.th.ref.promo.promoactionsub       no-undo .

  define variable v-row as character no-undo .
  define variable v-rid-list      as recid     no-undo .
  define variable vI as integer    no-undo .


define temp-table tt-promo like ub.PromoAction .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-3 rect-4 RADIO-SET-1 RADIO-SET-2 ~
editor-promo 
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 RADIO-SET-2 editor-promo 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 r-gop-1 FILL-IN-1 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON r-gop-1 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 4 BY .95 TOOLTIP "Выбор из списка".

DEFINE VARIABLE editor-promo AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
     SIZE 45 BY 3.81
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 33 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 23 BY 1.67 TOOLTIP "Промоакции" NO-UNDO.

DEFINE VARIABLE RADIO-SET-2 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Не прекращено", 2,
"Прекращено", 3
     SIZE 22 BY 2.38 TOOLTIP "Статус условия" NO-UNDO.

DEFINE RECTANGLE rect-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48.8 BY 8.57.

DEFINE RECTANGLE rect-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 27 BY 4.05.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADIO-SET-1 AT ROW 1.95 COL 4 NO-LABEL WIDGET-ID 46
     RADIO-SET-2 AT ROW 2.19 COL 51 NO-LABEL WIDGET-ID 54
     r-gop-1 AT ROW 2.67 COL 21 WIDGET-ID 28
     editor-promo AT ROW 4.57 COL 3 NO-LABEL WIDGET-ID 22
     FILL-IN-1 AT ROW 3.86 COL 3 NO-LABEL WIDGET-ID 36
     "Выбор статуса условия:" VIEW-AS TEXT
          SIZE 24 BY .62 AT ROW 1.24 COL 51 WIDGET-ID 52
          FGCOLOR 4 
     "Выбор промоакций:" VIEW-AS TEXT
          SIZE 24 BY .62 AT ROW 1.24 COL 4 WIDGET-ID 50
          FGCOLOR 4 
     rect-3 AT ROW 1 COL 1
     rect-4 AT ROW 1 COL 50 WIDGET-ID 44
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 76.8 BY 11.57
         BGCOLOR 8 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links: 
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 11.52
         WIDTH              = 76.8.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win 
/* ************************* Included-Libraries *********************** */
{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
ASSIGN 
       editor-promo:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME F-Main
   NO-DISPLAY NO-ENABLE ALIGN-L 2                                       */
/* SETTINGS FOR BUTTON r-gop-1 IN FRAME F-Main
   NO-ENABLE 2                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME r-gop-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gop-1 F-Frame-Win
ON CHOOSE OF r-gop-1 IN FRAME F-Main
DO:
  run ref/promo.p (input my-handle,yes,output vSubs) no-error.
  if not valid-object (vSubs) then return.
          
/*  run ref/promo.p (input my-handle,{&select},output v-row) no-error.*/
/*  if v-row = "" then return.                                        */
                        
  editor-promo = "":U.
  empty temp-table tt-promo.

  v-text-promo = "" .
/*  vI = 0.                                                                      */
/*  do ii = 1 to num-entries (v-row):                                            */
/*    v-rid-list = integer(entry(ii,v-row)) .                                    */
/*    FIND FIRST ub.PromoAction No-LOCK WHERE                                    */
/*      recid(ub.PromoAction) = v-rid-list                                       */
/*      No-ERROR.                                                                */
/*    IF avail ub.PromoAction then                                               */
/*    do:                                                                        */
/*      create tt-promo.                                                         */
/*      buffer-copy ub.PromoAction to tt-promo .                                 */
/*      assign                                                                   */
/*         v-text-promo = v-text-promo + {&new-line} + ub.PromoAction.nameAction.*/
/*      .                                                                        */
/*                                                                               */
/*      assign                                                                   */
/*         v-text-promo = TRIM(v-text-promo, {&new-line})                        */
/*         vI = vI + 1                                                           */
/*      .                                                                        */
/*    end.                                                                       */
/*  end.                                                                         */

  vI = 0.
        DO ii = 1 to vSubs:iCounter:
        vSubs:GetItem(ii).
        v-promo-action = vSubs:promoActionObjCurr .
        FIND FIRST ub.PromoAction No-LOCK WHERE
          ub.PromoAction.id = v-promo-action:ID 
/*          and ub.PromoAction.db-num = v-cntxt-db-num*/
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
/*              EDITOR-3   = v-text-promo*/
vI = vI + 1
              .
          END.
  EDITOR-promo = v-text-promo.
  fill-in-1 = "Выбрано записей " +  string(vI).       
  display
    editor-promo
    fill-in-1
    with frame {&frame-name}
  .
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 F-Frame-Win
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME F-Main
DO:
ASSIGN
      Radio-set-1
      .
    CASE RADIO-SET-1:
      /*выборочно*/
      WHEN 2
      THEN 
        DO:
          enable r-gop-1 with frame {&frame-name}.
          apply "choose" to r-gop-1 in frame {&frame-name}.
        END.

      /*Все*/
      WHEN 1 THEN 
        DO:
          EDITOR-promo = "Все":U.
          fill-in-1 = "".
          EMPTY TEMP-TABLE tt-promo.
          disable r-gop-1 with frame {&frame-name}.
        END.
      OTHERWISE 
      DO:
      END.
    END case.
    DISPLAY
      EDITOR-promo
      fill-in-1
      WITH FRAME {&frame-name}.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-2 F-Frame-Win
ON VALUE-CHANGED OF RADIO-SET-2 IN FRAME F-Main
DO:
   assign RADIO-SET-2.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win 


&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   run dispatch in this-procedure ('initialize':u).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY RADIO-SET-1 RADIO-SET-2 editor-promo 
      WITH FRAME F-Main.
  ENABLE rect-3 rect-4 RADIO-SET-1 RADIO-SET-2 editor-promo 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize F-Frame-Win 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
  /* Code placed here will execute PRIOR to standard behavior. */
  /* Dispatch standard ADM method.                             */
  run dispatch in this-procedure ( input 'initialize':u ) .
  EDITOR-promo = "Все":U.
  EMPTY TEMP-TABLE tt-promo.
  disable r-gop-1 with frame {&frame-name}.
  /* Code placed here will execute AFTER standard behavior.    */
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win 
PROCEDURE My-report :
define variable     det-mode            as integer      no-undo init 0.
    do:
        run rep/r-refpromo.p (input my-handle,
                              input table tt-promo,
                              input RADIO-SET-2).
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var F-Frame-Win 
PROCEDURE my-var :
.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

