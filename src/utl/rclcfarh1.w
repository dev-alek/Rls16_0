&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита пересчёта финансовых архивов.

Автор: Сливенко Сергей Андреевич
Дата создания: 13/03/12
Author: Sergey Slivenko
Creation date: 13/03/12

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита пересчёта финансовых архивов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }
{ gbl/userhsts.i }
{ gbl/userobjs.i }
{ gbl/twowin.i   }
{ gbl/getcntxt.i def }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parParentProc  as widget-handle no-undo.

/* Local Variable Definitions ---                                       */

define variable v-user-select      as logical   no-undo .
define variable v-select-host-code as integer   no-undo .
define variable v-obj-count        as integer   no-undo .
define variable v-sel-type         as logical   no-undo .
define variable v-list             as character no-undo .

define buffer buf_clients for ub.clients.


define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-doc-type x-doc-type x-fin-ob Btn_OK ~
Btn_Cancel 
&Scoped-Define DISPLAYED-OBJECTS x-doc-type x-fin-ob 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-doc-type 
     LABEL "Изменить" 
     SIZE 20 BY .96.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выполнить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE x-doc-type AS CHARACTER 
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL 
     LIST-ITEM-PAIRS "< ВСЕ > "," ''" 
     SIZE 43 BY 6 NO-UNDO.

DEFINE VARIABLE x-fin-ob AS LOGICAL INITIAL no 
     LABEL "Учитывать архивы по фин. обязательствам" 
     VIEW-AS TOGGLE-BOX
     SIZE 43 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-doc-type AT ROW 1.5 COL 26 WIDGET-ID 16
     x-doc-type AT ROW 2.54 COL 3 NO-LABEL WIDGET-ID 12
     x-fin-ob AT ROW 8.92 COL 3.13 WIDGET-ID 18
     Btn_OK AT ROW 10.63 COL 5
     Btn_Cancel AT ROW 10.63 COL 28
     "Типы архивов:" VIEW-AS TEXT
          SIZE 16 BY .63 AT ROW 1.58 COL 3 WIDGET-ID 14
          FGCOLOR 4 
     SPACE(32.24) SKIP(10.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Утилита пересчета фин. архивов"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Утилита пересчета фин. архивов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc-type Dialog-Frame
ON CHOOSE OF b-doc-type IN FRAME Dialog-Frame /* Изменить */
DO:
  { gbl/stdbtn.i }

  run select-doc-type in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

  v-sel-type = true.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выполнить */
DO:
  define variable glog as logical no-undo .
  assign x-fin-ob.

    run utl/rclcfarh.p(
      input v-cntxt-host-code-obj,
      input x-fin-ob,
      input v-list)
    .

  message "Готово!" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/*{ gbl/ed_date.i x-date }*/
{ gbl/getcntxt.i get }


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
  DISPLAY x-doc-type x-fin-ob 
      WITH FRAME Dialog-Frame.
  ENABLE b-doc-type x-doc-type x-fin-ob Btn_OK Btn_Cancel 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-host Dialog-Frame 
PROCEDURE proc-sel-host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    { gbl/uhstsone.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-user-select
      v-select-host-code
    }
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-doc-type Dialog-Frame 
PROCEDURE select-doc-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define variable v-counter       as integer      no-undo.
    define variable v-label         as character    no-undo.
    define variable v-value         as character    no-undo.
    define variable v-changed       as logical    no-undo.
    define variable v-accepted      as logical    no-undo.
    define variable v-list-edt      as character    no-undo.
    define variable v-list-edt-full as character    no-undo.
do
with frame {&frame-name}
on error undo, return error
:
      assign
          v-list-edt  = {&table_arh-fin-doc-an}
              + ",":U + {&table_arh-fin-doc-an-nal}
              + ",":U + {&table_arh-fin-doc-an-nal-obj}
              + ",":U + {&table_arh-fin-doc-an-obj}
              + ",":U + {&table_arh-fin-doc-c-s-tax-nal-obj}
              + ",":U + {&table_arh-fin-doc-c-schet-tax-nal}
              + ",":U + {&table_arh-fin-doc-contr-s-nal-obj}
              + ",":U + {&table_arh-fin-doc-contr-s-tax-obj}
              + ",":U + {&table_arh-fin-doc-contr-schet}
              + ",":U + {&table_arh-fin-doc-contr-schet-nal}
              + ",":U + {&table_arh-fin-doc-contr-schet-obj}
              + ",":U + {&table_arh-fin-doc-contr-schet-tax}
              + ",":U + {&table_arh-fin-doc-s-tax-nal-obj}
              + ",":U + {&table_arh-fin-doc-schet}
              + ",":U + {&table_arh-fin-doc-schet-nal}
              + ",":U + {&table_arh-fin-doc-schet-nal-obj}
              + ",":U + {&table_arh-fin-doc-schet-obj}
              + ",":U + {&table_arh-fin-doc-schet-tax}
              + ",":U + {&table_arh-fin-doc-schet-tax-nal}
              + ",":U + {&table_arh-fin-doc-schet-tax-obj}
      .
      assign
          v-list-edt-full   = {&table_arh-fin-doc-an-full}
                    + ",":U + {&table_arh-fin-doc-an-nal-full}
                    + ",":U + {&table_arh-fin-doc-an-nal-obj-full}
                    + ",":U + {&table_arh-fin-doc-an-obj-full}
                    + ",":U + {&table_arh-fin-doc-c-s-tax-nal-obj-full}
                    + ",":U + {&table_arh-fin-doc-c-schet-tax-nal-full}
                    + ",":U + {&table_arh-fin-doc-contr-s-nal-obj-full}
                    + ",":U + {&table_arh-fin-doc-contr-s-tax-obj-full}
                    + ",":U + {&table_arh-fin-doc-contr-schet-full}
                    + ",":U + {&table_arh-fin-doc-contr-schet-nal-full}
                    + ",":U + {&table_arh-fin-doc-contr-schet-obj-full}
                    + ",":U + {&table_arh-fin-doc-contr-schet-tax-full}
                    + ",":U + {&table_arh-fin-doc-s-tax-nal-obj-full}
                    + ",":U + {&table_arh-fin-doc-schet-full}
                    + ",":U + {&table_arh-fin-doc-schet-nal-full}
                    + ",":U + {&table_arh-fin-doc-schet-nal-obj-full}
                    + ",":U + {&table_arh-fin-doc-schet-obj-full}
                    + ",":U + {&table_arh-fin-doc-schet-tax-full}
                    + ",":U + {&table_arh-fin-doc-schet-tax-nal-full}
                    + ",":U + {&table_arh-fin-doc-schet-tax-obj-full}
      .
    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-edt-full )
    on error undo, return error
    :
        assign
            v-label = entry( v-counter, v-list-edt-full )
            v-value = entry( v-counter, v-list-edt )
        .
        run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Код вида документа: &1", v-value )
            , input ( x-doc-type :lookup( v-value ) <> 0 or x-doc-type :list-item-pairs = "< Все >,''":U  )
        ).
    end.        /* do */
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор типов финансовых архивов":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected
        , output v-changed
        , output v-accepted
    ).
    /*if v-accepted = yes
        and v-changed = yes
    then*/
    do:
        assign
            x-doc-type :list-item-pairs    = "< ВСЕ >,''":U
            v-list                          = "":U
            v-counter = 0
        .
        for each temp_twowin_itemsSelected
        by temp_twowin_itemsSelected.itm-key
        :
            assign
                v-counter = v-counter + 1
                v-list = substitute( "&1&2&3"
                                , v-list
                                , ( if v-list = "":U then "":U else ",":U )
                                , temp_twowin_itemsSelected.itmExtKey
                                )
            .
            if v-counter = 1
            then do:
                assign
                    x-doc-type :list-item-pairs    = substitute( "&1,&2"
                                        , entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                                        , temp_twowin_itemsSelected.itmExtKey
                                             )
                .
            end.
            else do:
                x-doc-type :add-last (
                    entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                    , temp_twowin_itemsSelected.itmExtKey
                ).
            end.
        end.
        if v-list = v-list-edt
        then do:
            assign
                x-doc-type :list-item-pairs = "< ВСЕ >,''":U
            .
        end.
    end.

end.
END PROCEDURE. /* select-doc-type */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

