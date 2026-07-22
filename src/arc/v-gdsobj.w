&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE TT-gds-obj NO-UNDO LIKE ub.gds-obj.
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр текущих остатков по объекту

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
no_app_help.i
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
define variable vss-description as character no-undo init "Просмотр текущих остатков по объекту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define shared variable varparentproc as widget-handle no-undo.

define variable varqnty as integer no-undo.
define variable g-log as logical no-undo.

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
&Scoped-Define ENABLED-FIELDS TT-gds-obj.fact-base TT-gds-obj.fact-rubl
&Scoped-define ENABLED-TABLES TT-gds-obj
&Scoped-define FIRST-ENABLED-TABLE TT-gds-obj
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 FILL-IN-1 FILL-IN-2
&Scoped-Define DISPLAYED-FIELDS TT-gds-obj.fact-qnty TT-gds-obj.price-sale ~
TT-gds-obj.fact-cli-qnty TT-gds-obj.free-qnty TT-gds-obj.fact-sale ~
TT-gds-obj.avrg-qnty TT-gds-obj.fact-base TT-gds-obj.fact-rubl
&Scoped-define DISPLAYED-TABLES TT-gds-obj
&Scoped-define FIRST-DISPLAYED-TABLE TT-gds-obj
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 FILL-IN-2

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
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL " БАЗОВАЯ ВАЛЮТА"
      VIEW-AS TEXT
     SIZE 16.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL " abbr_rubli_allshift"
      VIEW-AS TEXT
     SIZE 7 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.3 BY 5.03.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.3 BY 5.03.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79.4 BY 2.07.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     TT-gds-obj.fact-qnty AT ROW 1.53 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.price-sale AT ROW 2.43 COL 55.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 22.9 BY 1
     TT-gds-obj.fact-cli-qnty AT ROW 2.8 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.free-qnty AT ROW 3.93 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.fact-sale AT ROW 4 COL 55.6 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     TT-gds-obj.avrg-qnty AT ROW 5.13 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.fact-base AT ROW 7.53 COL 23.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 22.9 BY 1
     TT-gds-obj.fact-rubl AT ROW 7.53 COL 52.1 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     FILL-IN-1 AT ROW 6.5 COL 24 COLON-ALIGNED NO-LABEL
     FILL-IN-2 AT ROW 6.5 COL 52.5 COLON-ALIGNED NO-LABEL
     "Положительные партии" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 5.13 COL 2.8
     "Факт.кол-во" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 1.67 COL 2.8
     "Сумма в прод.ценах" VIEW-AS TEXT
          SIZE 18.1 BY .93 AT ROW 4.03 COL 38.9
     "Сумма в учетных ценах" VIEW-AS TEXT
          SIZE 21.9 BY .93 AT ROW 7.53 COL 2.5
     "Продажная цена" VIEW-AS TEXT
          SIZE 17.9 BY .93 AT ROW 2.43 COL 39.1
     "Факт.кол-во(ед.пост.)" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 2.8 COL 2.8
     "Свободно" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 4 COL 2.8
     RECT-1 AT ROW 1.2 COL 1.1
     RECT-2 AT ROW 1.2 COL 37.9
     RECT-3 AT ROW 6.93 COL 1.6
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
   Temp-Tables and Buffers:
      TABLE: tt-clients T "NEW GLOBAL SHARED" NO-UNDO ub clients
      TABLE: TT-gds-obj T "?" NO-UNDO ub gds-obj
      TABLE: tt-goods T "NEW GLOBAL SHARED" NO-UNDO ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 8
         WIDTH              = 80.6.
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

/* SETTINGS FOR FILL-IN TT-gds-obj.avrg-qnty IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TT-gds-obj.fact-cli-qnty IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TT-gds-obj.fact-qnty IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TT-gds-obj.fact-sale IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TT-gds-obj.free-qnty IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TT-gds-obj.price-sale IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */

{ gbl/getcntxt.i get " " varparentproc }

assign
  FILL-IN-2 = " {&abbr_rubli_allshift}"
.

display
  fill-in-1
  fill-in-2
  with frame {&frame-name} .

{ gbl/personly.i }
  for each tt-gds-obj:
      delete tt-gds-obj.
  end.
  assign varqnty = 0.
  for each tt-goods,
      each tt-clients:
      assign varqnty = varqnty + 1.
      find first ub.gds-obj where ub.gds-obj.obj-type  = tt-clients.obj-type and
                                  ub.gds-obj.obj-code  = tt-clients.obj-code and
                                  ub.gds-obj.artic     = tt-goods.artic      and
                                  ub.gds-obj.prod-type = tt-goods.prod-type  and
                                  ub.gds-obj.prod-code = tt-goods.prod-code  no-lock no-error.
      if available ub.gds-obj then do:
         find first tt-gds-obj no-lock no-error.
         if not available tt-gds-obj then do:
            create tt-gds-obj.
            buffer-copy gds-obj to tt-gds-obj.
         end.
         else do:
             assign
             tt-gds-obj.fact-qnty     = tt-gds-obj.fact-qnty     + ub.gds-obj.fact-qnty
             tt-gds-obj.fact-cli-qnty = tt-gds-obj.fact-cli-qnty + ub.gds-obj.fact-cli-qnty
             tt-gds-obj.free-qnty     = tt-gds-obj.free-qnty     + ub.gds-obj.free-qnty
             tt-gds-obj.avrg-qnty     = tt-gds-obj.avrg-qnty     + ub.gds-obj.avrg-qnty
             tt-gds-obj.fact-sale     = tt-gds-obj.fact-sale     + ub.gds-obj.fact-sale
             tt-gds-obj.fact-base     = tt-gds-obj.fact-base     + ub.gds-obj.fact-base
             tt-gds-obj.fact-rubl     = tt-gds-obj.fact-rubl     + ub.gds-obj.fact-rubl.
         end.
      end.
  end.
  /*Если работаем по нескольким товарам или объектам, то цены не имеют значение*/
  if varqnty > 1
  then do:
    assign tt-gds-obj.price-sale = ?.
  end.
  if available tt-gds-obj
  then do:
    display tt-gds-obj.fact-qnty tt-gds-obj.fact-cli-qnty tt-gds-obj.free-qnty tt-gds-obj.avrg-qnty
            tt-gds-obj.fact-sale
            tt-gds-obj.price-sale
            with frame {&frame-name}.
    define variable v-chk-act-host-code as integer   no-undo .
    { gbl/hostcode.i
      tt-gds-obj.obj-type
      tt-gds-obj.obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-chk-act-host-code
      tt-gds-obj.obj-type
      tt-gds-obj.obj-code
      0
      0
      0
      false
      g-log
    }

    if g-log then display tt-gds-obj.fact-base tt-gds-obj.fact-rubl
                          with frame {&frame-name}.
           else hide tt-gds-obj.fact-base tt-gds-obj.fact-rubl
                     in frame {&frame-name}.
  end.
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