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

Отчёт Оборотная ведомость по матценностям (ЗАКЛАДКА №2)

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/06/07
Author: Victor Guntner
Creation date: 09/06/07

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчёт Оборотная ведомость по матценностям (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i   }
{ rep/rep-bt.i    }
{ gbl/twowin.i    }
{ gbl/usr-flt.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.

define variable v-wthob-doc-type-list     as character    no-undo.



define variable loc-ref-list as character no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-7 cb-ob-tal cb-ob-liter cb-ob-rubl ~
bt-doc-type sl-doc-type
&Scoped-Define DISPLAYED-OBJECTS cb-detal cb-ob-tal cb-ob-liter cb-ob-rubl ~
sl-doc-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-doc-type
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.38 BY 16.25.

DEFINE VARIABLE sl-doc-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "< Все >","''"
     SIZE 55 BY 10.13 NO-UNDO.

DEFINE VARIABLE cb-detal AS LOGICAL INITIAL yes
     LABEL "Показывать оборот"
     VIEW-AS TOGGLE-BOX
     SIZE 32.63 BY .79 NO-UNDO.

DEFINE VARIABLE cb-ob-liter AS LOGICAL INITIAL yes
     LABEL "в литрах топлива"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .79 NO-UNDO.

DEFINE VARIABLE cb-ob-rubl AS LOGICAL INITIAL yes
     LABEL "в суммах "
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .79 NO-UNDO.

DEFINE VARIABLE cb-ob-tal AS LOGICAL INITIAL yes
     LABEL "в количестве талонов"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     cb-detal AT ROW 1.75 COL 34.88
     cb-ob-tal AT ROW 3 COL 9.5 WIDGET-ID 4
     cb-ob-liter AT ROW 4 COL 9.5 WIDGET-ID 6
     cb-ob-rubl AT ROW 5 COL 9.5 WIDGET-ID 8
     bt-doc-type AT ROW 6.75 COL 60.88 WIDGET-ID 14
     sl-doc-type AT ROW 6.88 COL 4.88 NO-LABEL WIDGET-ID 16
     "Учитывать только виды документов:" VIEW-AS TEXT
          SIZE 36 BY .67 AT ROW 6 COL 4.5
          FGCOLOR 4
     "Показывать оборот:" VIEW-AS TEXT
          SIZE 21 BY .67 AT ROW 2 COL 4.5 WIDGET-ID 2
          FGCOLOR 4
     RECT-7 AT ROW 1.25 COL 1.5
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
         HEIGHT             = 16.75
         WIDTH              = 73.
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

/* SETTINGS FOR TOGGLE-BOX cb-detal IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       cb-detal:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME bt-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-doc-type s-object
ON CHOOSE OF bt-doc-type IN FRAME F-Main /* Изменить */
DO:
    run select-doc-type in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

    define variable v-void-logical          as logical      no-undo.
    define variable v-void-character        as character    no-undo.
    define variable v-ext-doc-type-list     as character    no-undo.
    define variable v-found                 as logical      no-undo.
do
on error undo, return error
:
    run uf-get (
          input {&uf-wthob}
        , input v-cntxt-userid
        , output v-void-character
        , output v-ext-doc-type-list
        , output cb-ob-liter
        , output cb-ob-rubl
        , output cb-ob-tal
        , output v-void-logical
    ) no-error.
    display
        cb-ob-liter
        cb-ob-rubl
        cb-ob-tal
    with frame {&frame-name} no-error.
    if v-ext-doc-type-list = "":U
    then do:
        assign
            sl-doc-type :list-item-pairs in frame {&frame-name} = "< Все >,''":U
        .
    end.
    else do:
        assign
            sl-doc-type :list-item-pairs in frame {&frame-name} = v-ext-doc-type-list
        .
    end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
    define variable v-begin-date            as date         no-undo.
    define variable v-end-date              as date         no-undo.
    define variable v-begin-shift           as integer      no-undo.
    define variable v-end-shift             as integer      no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-ext-doc-type-list     as character    no-undo.

do
on error undo, return error
:
    assign
        v-begin-date  = x-Date-Start
        v-end-date    = x-Date-End
        v-begin-shift = x-Shift-Start
        v-end-shift   = x-Shift-End
    .
    if sl-doc-type :list-item-pairs in frame {&frame-name} = "< Все >,''":U
    then do:
        assign
            v-ext-doc-type-list = "":U
        .
    end.
    else do:
        do v-counter = 1 to sl-doc-type :num-items
        on error undo, return error
        :
            assign
                v-ext-doc-type-list = substitute( "&1&2&3"
                                , v-ext-doc-type-list
                                , ( if v-ext-doc-type-list = "":U then "":U else ",":U )
                                , entry( v-counter * 2, sl-doc-type :list-item-pairs )
                                )
            .
        end.        /* do */
    end.
assign frame {&frame-name}
    cb-detal
    cb-ob-tal
    cb-ob-liter
    cb-ob-rubl   .

    run uf-set (
          input {&uf-wthob}
        , input  v-cntxt-userid
        , input "":U
        , input sl-doc-type :list-item-pairs
        , input cb-ob-liter
        , input cb-ob-rubl
        , input cb-ob-tal
        , input no
    ) no-error.
    if error-status:error then message error-status:get-message(1) view-as alert-box.
    run rep/r-wthob.p (
          input v-begin-date
        , input v-end-date
        , input v-begin-shift
        , input v-end-shift
        , input x-SelectObject
        , input v-ext-doc-type-list
        , input cb-detal
        , input cb-ob-liter
        , input cb-ob-rubl
        , input cb-ob-tal
    ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
assign frame {&frame-name}
    cb-detal
    cb-ob-tal
    cb-ob-liter
    cb-ob-rubl

.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-doc-type s-object
PROCEDURE select-doc-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define variable v-counter       as integer      no-undo.
    define variable v-label         as character    no-undo.
    define variable v-value         as character    no-undo.
    define variable v-list          as character    no-undo.
    define variable v-changed       as logical    no-undo.
    define variable v-accepted      as logical    no-undo.
    define variable v-list-edt      as character    no-undo.
    define variable v-list-edt-full as character    no-undo.
do
with frame {&frame-name}
on error undo, return error
:
    assign
        v-list-edt  = {&WDEDT_Inc_Ext}
            + ",":U + {&WDEDT_Exp_Ext}
            + ",":U + {&WDEDT_Inc_Int_Put}
            + ",":U + {&WDEDT_Exp_Int_Put}
            + ",":U + {&WDEDT_Ret_Int_Put}
            + ",":U + {&WDEDT_Inc_Int_Free}
            + ",":U + {&WDEDT_Exp_Int_Free}
            + ",":U + {&WDEDT_Ret_Int_Free}
            + ",":U + {&WDEDT_Put_Cash}
            + ",":U + {&WDEDT_Put_Sale}
            + ",":U + {&WDEDT_Put_Cli}
            + ",":U + {&WDEDT_Dst_free}
            + ",":U + {&WDEDT_Dst_Put}
            + ",":U + {&WDEDT_exch}
    .
    assign
        v-list-edt-full  = {&WDEDT_Inc_Ext-full}
                + ",":U + {&WDEDT_Exp_Ext-full}
                + ",":U + {&WDEDT_Inc_Int_Put-full}
                + ",":U + {&WDEDT_Exp_Int_Put-full}
                + ",":U + {&WDEDT_Ret_Int_Put-full}
                + ",":U + {&WDEDT_Inc_Int_Free-full}
                + ",":U + {&WDEDT_Exp_Int_Free-full}
                + ",":U + {&WDEDT_Ret_Int_Free-full}
                + ",":U + {&WDEDT_Put_Cash-full}
                + ",":U + {&WDEDT_Put_Sale-full}
                + ",":U + {&WDEDT_Put_Cli-full}
                + ",":U + {&WDEDT_Dst_free-full}
                + ",":U + {&WDEDT_Dst_Put-full}
                + ",":U + {&WDEDT_exch-full}
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
            , input ( sl-doc-type :lookup( v-value ) <> 0 or sl-doc-type :list-item-pairs = "< Все >,''":U  )
        ).
    end.        /* do */
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор видов документов":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected
        , output v-changed
        , output v-accepted
    ).
    if v-accepted = yes
        and v-changed = yes
    then do:
        assign
            sl-doc-type :list-item-pairs    = "< Все >,''":U
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
                    sl-doc-type :list-item-pairs    = substitute( "&1,&2"
                                        , entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                                        , temp_twowin_itemsSelected.itmExtKey
                                             )
                .
            end.
            else do:
                sl-doc-type :add-last (
                    entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                    , temp_twowin_itemsSelected.itmExtKey
                ).
            end.
        end.
        if v-list = v-list-edt
        then do:
            assign
                sl-doc-type :list-item-pairs = "< Все >,''":U
            .
        end.
    end.
end.
END PROCEDURE. /* select-doc-type */

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
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME