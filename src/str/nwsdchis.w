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

Программа просмотра истории документов пришедших по новостям

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Перваков Михаил Сергеевич
Дата создания1: 05/14/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Программа просмотра истории документов пришедших по новостям".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }

/* параметры просмотра истории */

define variable v-user-doc-type as character no-undo format "X(12)" label "Тип документа" .

define variable v-filter-date    as logical   no-undo .
define variable v-date-from      as date      no-undo .
define variable v-date-to        as date      no-undo .

define variable v-filter-obj     as logical   no-undo .
define variable v-obj-type       as character no-undo .
define variable v-obj-code       as integer   no-undo .

define variable v-filter-doc     as logical   no-undo .
define variable v-doc-type       as character no-undo .
define variable v-doc-code       as character no-undo .

define variable v-filter-pck-num as logical   no-undo .
define variable v-pck-db-num     as integer   no-undo .
define variable v-pck-pack-num   as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.nws-doc-hist

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 get-table-name(ub.nws-doc-hist.doc-type) @ v-user-doc-type ub.nws-doc-hist.doc-code ub.nws-doc-hist.sys-date ub.nws-doc-hist.sys-time ub.nws-doc-hist.obj-type ub.nws-doc-hist.obj-code ub.nws-doc-hist.old-status_ ub.nws-doc-hist.new-status_ ub.nws-doc-hist.pck-db-num ub.nws-doc-hist.pck-pack-num ub.nws-doc-hist.user-name ub.nws-doc-hist.user-sys-date ub.nws-doc-hist.user-sys-time ub.nws-doc-hist.fact-qnty ub.nws-doc-hist.ord-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH ub.nws-doc-hist NO-LOCK. */ run open-query-nws-doc-hist .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 ub.nws-doc-hist
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 ub.nws-doc-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit RECT-1 b-lkp b-help toggle-date ~
toggle-object-list b-refresh toggle-doc-num toggle-pck-num BROWSE-1
&Scoped-Define DISPLAYED-OBJECTS toggle-date toggle-object-list ~
toggle-doc-num toggle-pck-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-table-name Dialog-Frame
FUNCTION get-table-name RETURNS CHARACTER
  ( p-table-name as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-refresh
     LABEL "Обновить"
     SIZE 10 BY 1.

DEFINE BUTTON btn-select-doc
     LABEL "Выбрать"
     SIZE 10 BY .79.

DEFINE BUTTON btn-select-obj
     LABEL "Выбрать"
     SIZE 10 BY .79.

DEFINE BUTTON btn-select-pck-num
     LABEL "Выбрать"
     SIZE 10 BY .79.

DEFINE VARIABLE cb-doc-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE cb-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-to AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE fi-doc-code AS CHARACTER FORMAT "X(14)":U
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-obj-code AS DECIMAL FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE fi-pck-db-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "БД"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE fi-pck-pack-num AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Пакет"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 80.88 BY 4.38.

DEFINE VARIABLE toggle-date AS LOGICAL INITIAL no
     LABEL "Дата"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

DEFINE VARIABLE toggle-doc-num AS LOGICAL INITIAL no
     LABEL "Номер документа"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

DEFINE VARIABLE toggle-object-list AS LOGICAL INITIAL no
     LABEL "Объект"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

DEFINE VARIABLE toggle-pck-num AS LOGICAL INITIAL no
     LABEL "Пакет новостей"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      ub.nws-doc-hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      get-table-name(ub.nws-doc-hist.doc-type) @ v-user-doc-type
      ub.nws-doc-hist.doc-code COLUMN-LABEL "Документ"
      ub.nws-doc-hist.sys-date COLUMN-LABEL "Дата Пол."
      ub.nws-doc-hist.sys-time COLUMN-LABEL "Время Пол."
      ub.nws-doc-hist.obj-type
      ub.nws-doc-hist.obj-code
      ub.nws-doc-hist.old-status_ COLUMN-LABEL "Старый статус" FORMAT "X(12)"
      ub.nws-doc-hist.new-status_ COLUMN-LABEL "Новый статус" FORMAT "X(12)"
      ub.nws-doc-hist.pck-db-num COLUMN-LABEL "БД"
      ub.nws-doc-hist.pck-pack-num COLUMN-LABEL "Пакет"
      ub.nws-doc-hist.user-name
      ub.nws-doc-hist.user-sys-date COLUMN-LABEL "Дата Изм."
      ub.nws-doc-hist.user-sys-time COLUMN-LABEL "Время Изм."
      ub.nws-doc-hist.fact-qnty
      ub.nws-doc-hist.ord-num COLUMN-LABEL "Номер"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.13 BY 11.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-lkp AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     fi-date-from AT ROW 2.33 COL 45 COLON-ALIGNED
     fi-date-to AT ROW 2.33 COL 64.75 COLON-ALIGNED
     toggle-date AT ROW 2.42 COL 13.13
     fi-obj-code AT ROW 3.25 COL 64.63 COLON-ALIGNED NO-LABEL
     cb-obj-type AT ROW 3.29 COL 45 COLON-ALIGNED NO-LABEL
     toggle-object-list AT ROW 3.42 COL 13.13
     btn-select-obj AT ROW 3.5 COL 35.63
     b-refresh AT ROW 3.88 COL 2.63
     cb-doc-type AT ROW 4.29 COL 45.13 COLON-ALIGNED NO-LABEL
     fi-doc-code AT ROW 4.29 COL 64.63 COLON-ALIGNED NO-LABEL
     toggle-doc-num AT ROW 4.46 COL 13.13
     btn-select-doc AT ROW 4.46 COL 35.63
     toggle-pck-num AT ROW 5.38 COL 13
     fi-pck-db-num AT ROW 5.38 COL 49 COLON-ALIGNED
     fi-pck-pack-num AT ROW 5.38 COL 60.75 COLON-ALIGNED
     btn-select-pck-num AT ROW 5.5 COL 35.5
     BROWSE-1 AT ROW 6.67 COL 1.88
     RECT-1 AT ROW 2.13 COL 2
     SPACE(11.24) SKIP(12.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История документов"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 btn-select-pck-num Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 4.

/* SETTINGS FOR BUTTON btn-select-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       btn-select-doc:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON btn-select-obj IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       btn-select-obj:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON btn-select-pck-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       btn-select-pck-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX cb-doc-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       cb-doc-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX cb-obj-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       cb-obj-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fi-date-from IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-date-from:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fi-date-to IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-date-to:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fi-doc-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-doc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fi-obj-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-obj-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fi-pck-db-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-pck-db-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fi-pck-pack-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       fi-pck-pack-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH ub.nws-doc-hist NO-LOCK. */
run open-query-nws-doc-hist .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История документов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  run show-detail in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  run open-query-nws-doc-hist in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  run show-detail in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-select-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-select-doc Dialog-Frame
ON CHOOSE OF btn-select-doc IN FRAME Dialog-Frame /* Выбрать */
DO:
  run select-doc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-select-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-select-obj Dialog-Frame
ON CHOOSE OF btn-select-obj IN FRAME Dialog-Frame /* Выбрать */
DO:
  run select-obj in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-select-pck-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-select-pck-num Dialog-Frame
ON CHOOSE OF btn-select-pck-num IN FRAME Dialog-Frame /* Выбрать */
DO:
  run select-pck-num in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toggle-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toggle-date Dialog-Frame
ON VALUE-CHANGED OF toggle-date IN FRAME Dialog-Frame /* Дата */
DO:
  if {&self-name} :checked
  then do:
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-date
      ,output v-time
      ) .

    assign
      fi-date-from :visible   = true
      fi-date-to   :visible   = true
      fi-date-from :sensitive = true
      fi-date-to   :sensitive = true
    .
    if input frame {&frame-name} fi-date-from = ?
    then do:
      display
        v-date @ fi-date-from
        with frame {&frame-name} .
    end.
    if input frame {&frame-name} fi-date-to = ?
    then do:
      display
        v-date @ fi-date-to
        with frame {&frame-name} .
    end.
  end.
  else do:
    assign
      fi-date-from :sensitive = false
      fi-date-to   :sensitive = false
      fi-date-from :visible   = false
      fi-date-to   :visible   = false
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toggle-doc-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toggle-doc-num Dialog-Frame
ON VALUE-CHANGED OF toggle-doc-num IN FRAME Dialog-Frame /* Номер документа */
DO:
  if {&self-name} :checked
  then do:
    assign
      btn-select-doc :visible   = true
      cb-doc-type    :visible   = true
      fi-doc-code    :visible   = true
      btn-select-doc :sensitive = true
      cb-doc-type    :sensitive = true
      fi-doc-code    :sensitive = true
    .
  end.
  else do:
    assign
      btn-select-doc :sensitive = false
      cb-doc-type    :sensitive = false
      fi-doc-code    :sensitive = false
      btn-select-doc :visible   = false
      cb-doc-type    :visible   = false
      fi-doc-code    :visible   = false
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toggle-object-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toggle-object-list Dialog-Frame
ON VALUE-CHANGED OF toggle-object-list IN FRAME Dialog-Frame /* Объект */
DO:
  if {&self-name} :checked
  then do:
    assign
      btn-select-obj :visible   = true
      cb-obj-type    :visible   = true
      fi-obj-code    :visible   = true
      btn-select-obj :sensitive = true
      cb-obj-type    :sensitive = true
      fi-obj-code    :sensitive = true
    .
  end.
  else do:
    assign
      btn-select-obj :sensitive = false
      cb-obj-type    :sensitive = false
      fi-obj-code    :sensitive = false
      btn-select-obj :visible   = false
      cb-obj-type    :visible   = false
      fi-obj-code    :visible   = false
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toggle-pck-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toggle-pck-num Dialog-Frame
ON VALUE-CHANGED OF toggle-pck-num IN FRAME Dialog-Frame /* Пакет новостей */
DO:

  if {&self-name} :checked
  then do:
    assign
      btn-select-pck-num :visible   = true
      fi-pck-db-num      :visible   = true
      fi-pck-pack-num    :visible   = true
      btn-select-pck-num :sensitive = true
      fi-pck-db-num      :sensitive = true
      fi-pck-pack-num    :sensitive = true
    .
  end.
  else do:
    assign
      btn-select-pck-num :sensitive = false
      fi-pck-db-num      :sensitive = false
      fi-pck-pack-num    :sensitive = false
      btn-select-pck-num :visible   = false
      fi-pck-db-num      :visible   = false
      fi-pck-pack-num    :visible   = false
    .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* очистить старую историю */
run trg/nwsdhclr.p .

{ gbl/app_help.i }
{ gbl/ed_date.i fi-date-from }
{ gbl/ed_date.i fi-date-to   }

do with frame {&frame-name}:
  assign
    cb-obj-type :list-items = {&shop} + ',' + {&stock}
  .

  define variable v-doc-type-orig-list as character no-undo .
  define variable v-doc-type-user-list as character no-undo .
  define variable v-ind                as integer   no-undo .
  define variable v-table-name         as character no-undo .
  assign
    v-doc-type-orig-list  = {&table_trn-doc    }
                    + ',' + {&table_price-doc  }
                    + ',' + {&table_wth-doc    }
                    + ',' + {&table_inkas      }
                    + ',' + {&table_fbr-doc    }
                    + ',' + {&table_fbr-pln    }
                    + ',' + {&table_rvs-doc    }
                    + ',' + {&table_icnt-doc   }
                    + ',' + {&table_ord-doc    }
                    + ',' + {&table_ord-doc-rcv}
                    + ',' + {&table_ord-cons   }
    v-doc-type-user-list = ""
  .

  do v-ind = 1 to num-entries(v-doc-type-orig-list)
  :
    { gbl/tblnmusr.i
      entry(v-ind,v-doc-type-orig-list)
      v-table-name
    }
    assign
      v-doc-type-user-list = v-doc-type-user-list
                           + (if v-doc-type-user-list <> "" then ',':u else "")
                           + v-table-name
    .
  end.

  assign
    cb-doc-type :list-items = v-doc-type-user-list
  .


end. /* do with frame */


if browse {&browse-name}:set-repositioned-row(5, "CONDITIONAL" ) then .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY toggle-date toggle-object-list toggle-doc-num toggle-pck-num
      WITH FRAME Dialog-Frame.
  ENABLE b-exit RECT-1 b-lkp b-help toggle-date toggle-object-list b-refresh
         toggle-doc-num toggle-pck-num BROWSE-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query-nws-doc-hist Dialog-Frame
PROCEDURE open-query-nws-doc-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    run validate-filter-options in this-procedure
      no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.

    open query {&browse-name} for each ub.nws-doc-hist no-lock
      where ub.nws-doc-hist.db-num = g#db-num
        and ( v-filter-date = false
              or
              (   ub.nws-doc-hist.fact-date >= v-date-from
              and ub.nws-doc-hist.fact-date <= v-date-to
              )
            )
        and ( v-filter-obj = false
              or
              (   ub.nws-doc-hist.obj-type = v-obj-type
              and ub.nws-doc-hist.obj-code = v-obj-code
              )
            )
        and ( v-filter-doc = false
              or
             (    ub.nws-doc-hist.doc-type = v-doc-type
              and ub.nws-doc-hist.doc-code = v-doc-code
              )
            )
        and ( v-filter-pck-num = false
              or
              (
                  ub.nws-doc-hist.pck-db-num   = v-pck-db-num
              and ub.nws-doc-hist.pck-pack-num = v-pck-pack-num
              )
            )
      .

    get last {&browse-name} .
    define variable v-rowid as rowid     no-undo .

    if available ub.nws-doc-hist
    then do:
      assign
        v-rowid = rowid(ub.nws-doc-hist)
      .
      reposition {&browse-name} to rowid v-rowid .
    end.

    apply 'entry':u to browse {&browse-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-doc Dialog-Frame
PROCEDURE select-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-select-doc-type as character no-undo .
  define variable v-select-doc-code as character no-undo .

  assign
    v-select-doc-type = input frame {&frame-name} cb-doc-type
    v-select-doc-code = input frame {&frame-name} fi-doc-code
  .

  run str/nwhdocsl.w
    (input-output v-select-doc-type
    ,input-output v-select-doc-code
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы nwhdocsl.w" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-select-doc-type <> ""
  and v-select-doc-code <> ""
  then do:
    assign
      cb-doc-type :screen-value = v-select-doc-type
    .
    display
      v-select-doc-code @ fi-doc-code
      with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-obj Dialog-Frame
PROCEDURE select-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .

  assign
    v-select-obj-type = input frame {&frame-name} cb-obj-type
    v-select-obj-code = input frame {&frame-name} fi-obj-code
  .

  run str/nwhobjsl.w
    (input-output v-select-obj-type
    ,input-output v-select-obj-code
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы nwhobjsl.w" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-select-obj-type <> ""
  and v-select-obj-code <> 0
  then do:
    assign
      cb-obj-type :screen-value = v-select-obj-type
    .
    display
      v-select-obj-code @ fi-obj-code
      with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-pck-num Dialog-Frame
PROCEDURE select-pck-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-select-db-num  as integer   no-undo .
  define variable v-select-pck-num as integer   no-undo .

  assign
    v-select-db-num  = input frame {&frame-name} fi-pck-db-num
    v-select-pck-num = input frame {&frame-name} fi-pck-pack-num
  .

  run str/nwhpcksl.w
    (input-output v-select-db-num
    ,input-output v-select-pck-num
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове программы nwhpcksl.w" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  v-select-db-num  <> 0
  and v-select-pck-num <> 0
  then do:
    display
      v-select-db-num  @ fi-pck-db-num
      v-select-pck-num @ fi-pck-pack-num
      with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-detail Dialog-Frame
PROCEDURE show-detail :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if available ub.nws-doc-hist
  then do:
    run str/showtbl.p
      (input parparentproc
      ,input ub.nws-doc-hist.doc-type /* p-doc-table */
      ,input ub.nws-doc-hist.doc-code /* p-doc-code  */
      ,input 0                     /* p-gds-code  */
      ) .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-filter-options Dialog-Frame
PROCEDURE validate-filter-options :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/


  do with frame {&frame-name}:
    assign
      v-filter-date    = input frame {&frame-name} toggle-date
      v-filter-obj     = input frame {&frame-name} toggle-object-list
      v-filter-doc     = input frame {&frame-name} toggle-doc-num
      v-filter-pck-num = input frame {&frame-name} toggle-pck-num
    .

    if v-filter-date = true
    then do:
      assign
        v-date-from = input frame {&frame-name} fi-date-from
        v-date-to   = input frame {&frame-name} fi-date-to
      .
      if v-date-from = ?
      then do:
        message
          "Не задана дата С" skip
          view-as alert-box information .
        apply 'entry':u to fi-date-from .
        undo, return error .
      end.
      if v-date-to = ?
      then do:
        message
          "Не задана дата С" skip
          view-as alert-box information .
        apply 'entry':u to fi-date-to .
        undo, return error .
      end.
      if v-date-from > v-date-to
      then do:
        message
          "Дата 'С' не может быть больше даты 'По'" skip
          view-as alert-box information .
        apply 'entry':u to fi-date-from .
        undo, return error .
      end.
    end.

    if v-filter-obj = true
    then do:
      assign
        v-obj-type = input frame {&frame-name} cb-obj-type
        v-obj-code = input frame {&frame-name} fi-obj-code
      .
      if v-obj-type = ?
      or v-obj-type = ""
      then do:
        message
          "Не задан тип объекта" skip
          view-as alert-box information .
        apply 'entry':u to cb-obj-type .
        undo, return error .
      end.
      if v-obj-code = ?
      or v-obj-code = 0
      then do:
        message
          "Не задан код объекта" skip
          view-as alert-box information .
        apply 'entry':u to fi-obj-code .
        undo, return error .
      end.
    end.

    if v-filter-doc = true
    then do:
      assign
        v-doc-code = input frame {&frame-name} fi-doc-code
      .
      { gbl/tblusrnm.i
        "input frame {&frame-name} cb-doc-type"
        v-doc-type
      }

      if v-doc-type = ?
      or v-doc-type = ""
      then do:
        message
          "Не задан тип документа" skip
          view-as alert-box information .
        apply 'entry':u to cb-doc-type .
        undo, return error .
      end.
      if v-doc-code = ?
      or v-doc-code = ""
      then do:
        message
          "Не задан код документа" skip
          view-as alert-box information .
        apply 'entry':u to fi-doc-code .
        undo, return error .
      end.
    end.

    if v-filter-pck-num = true
    then do:
      assign
        v-pck-db-num   = input frame {&frame-name} fi-pck-db-num
        v-pck-pack-num = input frame {&frame-name} fi-pck-pack-num
      .
      if v-pck-db-num = ?
      then do:
        message
          "Не задана БД" skip
          view-as alert-box information .
        apply 'entry':u to fi-pck-db-num .
        undo, return error .
      end.
      if v-pck-pack-num = ?
      or v-pck-pack-num = 0
      then do:
        message
          "Не задан номер пакета" skip
          view-as alert-box information .
        apply 'entry':u to fi-pck-pack-num .
        undo, return error .
      end.
    end.

  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-table-name Dialog-Frame
FUNCTION get-table-name RETURNS CHARACTER
  ( p-table-name as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable v-user-table-name as character no-undo .
  { gbl/tblnmusr.i
    p-table-name
    v-user-table-name
  }


  RETURN v-user-table-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME