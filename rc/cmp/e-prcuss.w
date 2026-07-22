&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Отчет по прайс-листам (закладка № 2)

Автор: Морозов Александр
Дата создания: 05/31/11
Author: Alexandr Morozov
Creation date: 05/31/11

*/
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет Отчет по прайс-листам (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }

define variable  p-curr-code  as integer    no-undo .
define variable  p-ch-val     as logical    no-undo .
define variable  v-t-recid    as character  no-undo .
define variable  g-s-ref-rec  as character initial "0" no-undo .

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-6 SortType bgrcliset r-gop-2 bglclilist
&Scoped-Define DISPLAYED-OBJECTS SortType bgrcliset bglclilist

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 r-gop-2 r-gop-1 FILL-IN-1

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON r-gop-1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE BUTTON r-gop-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Выбор из списка".

DEFINE VARIABLE bglclilist AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
     SIZE 33.38 BY 2.33
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE bgrcliset AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Группы покупателей", 1,
"Клиенты", 2
     SIZE 22.5 BY 2.25 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименов.", "sort-name":U
     SIZE 14 BY 2.75 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 16.13 BY 7.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType AT ROW 2.83 COL 3.13 NO-LABEL
     bgrcliset AT ROW 3 COL 21 NO-LABEL WIDGET-ID 24
     r-gop-2 AT ROW 3.25 COL 44 WIDGET-ID 20
     r-gop-1 AT ROW 4.25 COL 44 WIDGET-ID 28
     bglclilist AT ROW 6.75 COL 21 NO-LABEL WIDGET-ID 22
     FILL-IN-1 AT ROW 6 COL 19 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     "Сортировка :" VIEW-AS TEXT
          SIZE 11.5 BY .75 AT ROW 1.58 COL 4.63
          FGCOLOR 4
     RECT-6 AT ROW 1.25 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 8.5
         WIDTH              = 55.
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
       bglclilist:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME F-Main
   NO-DISPLAY NO-ENABLE 2                                               */
/* SETTINGS FOR BUTTON r-gop-1 IN FRAME F-Main
   NO-ENABLE 2                                                          */
/* SETTINGS FOR BUTTON r-gop-2 IN FRAME F-Main
   2                                                                    */
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

&Scoped-define SELF-NAME bgrcliset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bgrcliset s-object
ON VALUE-CHANGED OF bgrcliset IN FRAME F-Main
DO:
  Assign
    bgrcliset
  .
  case bgrcliset :
    when 1 then do :
      enable r-gop-2 with frame {&frame-name}.
      disable r-gop-1 with frame {&frame-name}.
    end.
    when 2 then do :
      enable r-gop-1 with frame {&frame-name}.
      disable r-gop-2 with frame {&frame-name}.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-gop-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gop-1 s-object
ON CHOOSE OF r-gop-1 IN FRAME F-Main
DO:
  define variable ix        as integer no-undo.
  define variable s-ref-rec as character no-undo.
  define variable  lns-cnt      as integer    no-undo .
  run ref/cli-all.w ( my-handle, "b-sel,b-mark", ?, ?, ?, ?, ?, ?, output s-ref-rec) .
  if s-ref-rec = "" then return no-apply.
  assign
    bglclilist = " По клиентам":U
  .
  repeat ix = 1 to num-entries (s-ref-rec) :
    for each clients where recid(clients) = int (entry (ix, s-ref-rec) ) no-lock :
/*      if error-status :error then do:*/
/*        return no-apply .*/
/*      end.*/
      assign
        lns-cnt = lns-cnt + 1
      .
      assign
        bglclilist =  bglclilist + {&new-line} + "   " + clients.obj-name
      .
    end.
  end.
  display
    bglclilist
    with frame {&frame-name}
  .
  assign
    FILL-IN-1 = "Выбрано записей " +  string ( lns-cnt )
  .
  display
    FILL-IN-1
    with frame {&frame-name}
  .
  assign
    g-s-ref-rec =  "cli," + s-ref-rec
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-gop-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-gop-2 s-object
ON CHOOSE OF r-gop-2 IN FRAME F-Main
DO:
  define variable ix        as integer no-undo.
  define variable s-ref-rec as character no-undo.
  define variable  lns-cnt      as integer    no-undo .
  run ref/gr-bupr.w (input  my-handle , "b-sel,b-mark", input-output s-ref-rec ).
  if s-ref-rec = "" then return no-apply.
  assign
    bglclilist = " По группам покупателей":U
  .
  repeat ix = 1 to num-entries (s-ref-rec) :
    for buyer-group where recid (buyer-group) = int (entry (ix, s-ref-rec) ) :
      if error-status :error then do:
        return no-apply .
      end.
      assign
        lns-cnt = lns-cnt + 1
      .
      assign
        bglclilist = bglclilist + {&new-line} + "   " + buyer-group.name
      .
    end.
  end.
  display
    bglclilist
    with frame {&frame-name}
  .
  assign
    FILL-IN-1 = "Выбрано записей " +  string ( lns-cnt )
  .
  display
    FILL-IN-1
    with frame {&frame-name}
  .
  assign
    g-s-ref-rec = "bgl," + s-ref-rec
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SortType
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SortType s-object
ON VALUE-CHANGED OF SortType IN FRAME F-Main
DO:
  ASSIGN SortType.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
  define variable v-type as character no-undo .
  define variable v-tmp as character no-undo .
  run rep/r-prcuss.p
      ( g-s-ref-rec,
        p-curr-code,
        'grp-goods',
        sorttype
        ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} /*Classify*/ SortType.
/* { rep/claslabl.i }*/
 { rep/rvarpage.i }
x-date-end = x-date-alone.

if v-radio-schet =      7
    then
    assign
      p-ch-val = true
      p-curr-code   = v-curr-code
      .

    else assign
      p-ch-val = false
      p-curr-code   = ?
    .


END PROCEDURE.
{ rep/varfpage.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME