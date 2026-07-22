&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание параметров для редактирования сроков годности партий товара

Автор: Чернова Светлана Александровна
Дата создания: 03/21/08
Author: Svetlana Chernova
Creation date: 03/21/08

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
define variable vss-description as character no-undo init "Задание параметров для редактирования сроков годности партий товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ gbl/sel-date.i }
{ gbl/godendo.i  }
{ cmp/r-page1.i  }
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 rs-select fi-last-date ~
fi-last-date-offset b-choose-last-date fi-description
&Scoped-Define DISPLAYED-OBJECTS rs-select fi-last-date fi-last-date-offset ~
fi-description

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".

DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор партий"
      VIEW-AS TEXT
     SIZE 35.13 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-last-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-last-date-offset AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE rs-select AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Дата 'Годен до' не задана", "not-defined",
"Дата 'Годен до' меньше чем", "less-then",
"Все", "all"
     SIZE 29.13 BY 2.67 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 77.38 BY 17.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     rs-select AT ROW 2.92 COL 2.63 NO-LABEL
     fi-last-date AT ROW 3.75 COL 30.88 COLON-ALIGNED NO-LABEL
     fi-last-date-offset AT ROW 3.79 COL 47.25 COLON-ALIGNED NO-LABEL
     b-choose-last-date AT ROW 3.83 COL 45.25
     fi-description AT ROW 1.71 COL 3 NO-LABEL
     RECT-1 AT ROW 1.13 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


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
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 17.75
         WIDTH              = 77.75.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-description IN FRAME F-Main
   ALIGN-L                                                              */
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

&Scoped-define SELF-NAME b-choose-last-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-last-date V-table-Win
ON CHOOSE OF b-choose-last-date IN FRAME F-Main /* b-choose-last-date */
DO:
  run sel-date in this-procedure
    (input fi-last-date :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-last-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-date V-table-Win
ON LEAVE OF fi-last-date IN FRAME F-Main
DO:
  run update-last-date-offset in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-last-date-offset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-date-offset V-table-Win
ON LEAVE OF fi-last-date-offset IN FRAME F-Main
DO:
  define variable v-last-date as date      no-undo .

  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  run godendo-offset-to-date in this-procedure
    (input  v-today                                         /* p-today  */
    ,input  (input frame {&frame-name} fi-last-date-offset) /* p-offset */
    ,output v-last-date                                     /* p-date   */
    ) .
  assign
    fi-last-date     :screen-value = string(v-last-date
                                            ,fi-last-date :format)
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-select V-table-Win
ON VALUE-CHANGED OF rs-select IN FRAME F-Main
DO:
  assign
    rs-select
  .

  if rs-select = "less-then"
  then do:
    assign
      fi-last-date        :visible   = true
      fi-last-date        :sensitive = true
      b-choose-last-date  :visible   = true
      b-choose-last-date  :sensitive = true
      fi-last-date-offset :visible   = true
      fi-last-date-offset :sensitive = true
    .
  end.
  else do:
    assign
      fi-last-date        :sensitive = false
      fi-last-date        :visible   = false
      b-choose-last-date  :sensitive = false
      b-choose-last-date  :visible   = false
      fi-last-date-offset :sensitive = false
      fi-last-date-offset :visible   = false
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get " " my-handle }
{ gbl/personly.i }
{ gbl/ed_date.i fi-last-date }

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout V-table-Win
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  do with frame {&frame-name}
  :
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .

    run cur-time in this-procedure
      (output v-date
      ,output v-time
      ) .

    assign
      rs-select               = "not-defined"
      fi-last-date            = v-date
    .

    display
      rs-select
      fi-last-date
      fi-description
      with frame {&frame-name}
    .

    run update-last-date-offset in this-procedure .
  end. /* do with frame */


  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
  do with frame {&frame-name}
  :
    assign
      fi-last-date        :sensitive = false
      fi-last-date        :visible   = false
      b-choose-last-date  :sensitive = false
      b-choose-last-date  :visible   = false
      fi-last-date-offset :sensitive = false
      fi-last-date-offset :visible   = false
    .
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report V-table-Win
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    run My-var.

    run rep/d-parlas.w
      (input my-handle /* parparentproc */
      ,input v-cntxt-obj-type   /* p-obj-type  */
      ,input v-cntxt-obj-code   /* p-obj-code  */
      ,input rs-select    /* p-select    */
      ,input fi-last-date /* p-last-date */
      ) .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var V-table-Win
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
    assign frame {&frame-name}
        rs-select
        fi-last-date
    .
    define variable v-select-string  as character no-undo.

    case rs-select
    :
      when "not-defined"
      then do:
        assign
          v-select-string = "Партии с незаданным сроком годности"
        .
      end.
      when "less-then"
      then do:
        assign
          v-select-string = "Партии со сроком годности меньше чем " + string(fi-last-date, '99/99/9999':u)
        .
      end.
      when "all"
      then do:
        assign
          v-select-string = "Все партии"
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной rs-select" skip
          "rs-select" rs-select skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    assign
        ReportName      = "Редактирование сроков годности партий товара"
        ReportHeader    = v-select-string
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-last-date-offset V-table-Win
PROCEDURE update-last-date-offset :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do with frame {&frame-name}
  :
    define variable v-last-date-offset as integer   no-undo .

    define variable v-today     as date      no-undo .
    define variable v-time      as integer   no-undo .

    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .

    run godendo-date-to-offset in this-procedure
      (input  v-today                                  /* p-today  */
      ,input  (input frame {&frame-name} fi-last-date) /* p-date   */
      ,output v-last-date-offset                       /* p-offset */
      ) .
    assign
      fi-last-date-offset :screen-value = string(v-last-date-offset
                                                ,fi-last-date-offset :format
                                                )
    .

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME