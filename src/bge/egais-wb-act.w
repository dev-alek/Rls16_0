&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список актов ЕГАИС

  Author: 
    Автор: Морозов Александр Сергеевич
    Дата создания: 15/11/03
    Author: Alexandr Morozov
    Creation date: 15/11/03
 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.bge.egais.*.
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter egais as class EGAIS no-undo.
define input parameter bh-wb-egais as handle no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision               as character no-undo init "$Revision$":U .
define variable vss-author                 as character no-undo init "$Author$":U .
define variable vss-date                   as character no-undo init "$Date$":U .
define variable vss-workfile               as character no-undo init "$Workfile$":U .
define variable vss-archive                as character no-undo init "$Archive$":U .
define variable vss-description            as character no-undo init "Журнал запросов ЕГАИС".

define variable th-wb-egais                as handle    no-undo.
define variable gh-wb-egais                as handle    no-undo.
define variable bh-wb-gds-EG               as handle    no-undo.
define variable browse-hdl-wb-egais        as handle    no-undo.
define variable th-wb-egais-header         as handle    no-undo.
define variable gh-wb-egais-header         as handle    no-undo.
define variable bh-wb-gds-EG-header        as handle    no-undo.
define variable browse-hdl-wb-egais-header as handle    no-undo.
define variable bcol                       as handle    extent no-undo.
define variable v-db-num                   as integer   no-undo .
define variable v-user-id                  as character no-undo .
define variable v-user-select              as character no-undo .
define variable v-select-obj-type          as character no-undo .
define variable v-select-obj-code          as integer   no-undo .
define variable v-obj-uniq-key-rec         as character no-undo .
define variable v-gds-uniq-key-rec         as character no-undo .
define variable v-ext-sys                  as integer   no-undo .
define variable v-rid                      as recid     no-undo .
/*define variable v-identity                 as character no-undo .*/
define variable v-uniq-key-rec             as character no-undo .

define buffer buf_clients   for ub.clients .
define buffer x_ext-classif for ub.ext-classif.
define buffer buf_goods     for ub.goods .


{cmp/str-glbl.i}
{ gbl/color.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/thbjattr.i }
{ ref/gds-attr.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS  
&Scoped-Define DISPLAYED-OBJECTS  

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
  LABEL "Выход" 
  SIZE 15 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON btn_conn 
  LABEL "Связать" 
  SIZE 15 BY 1.13.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  Btn_Cancel AT ROW 1.25 COL 2
  SPACE(110.00) SKIP(25.28)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Акт на накладную ЕГАИС"
  CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON window-close OF FRAME Dialog-Frame /* Накладная ЕГАИС */
  do:
    apply "END-ERROR":U to self.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
  on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:

  def var ii as int no-undo.

  { gbl/getcurus.i
    v-db-num
    v-user-id
    no-error
  }
  { gbl/getcntxt.i get }

  find first ub.ext-system where ub.ext-system.delivery-method = integer ({&esys-dm-egais}).
  
  assign 
    v-ext-sys = ub.ext-system.esys-id .  
  
  create browse browse-hdl-wb-egais-header
    assign 
    title     = 'Акт ЕГАИС'
    frame     = frame {&FRAME-NAME}:handle
    query     = gh-wb-egais
    x         = 10
    y         = 42
    width     = 119
    height    = 5
    visible   = true
    read-only = true
    sensitive = true
    separators = true
    column-resizable = true
    .
  
  create browse browse-hdl-wb-egais
    assign 
    title     = 'Список товаров ЕГАИС'
    frame     = frame {&FRAME-NAME}:handle
    query     = gh-wb-egais
    x         = 10
    y         = 102
    width     = 119
    height    = 22
    visible   = true
    read-only = true
    sensitive = true
    separators = true
    column-resizable = true
    triggers:
      on mouse-move-dblclick persistent run msdblcl.
      on row-display persistent run proc-row-leave.
    end triggers
    .


  bh-wb-gds-EG-header = egais:GetHndlTable(8, bh-wb-egais:buffer-field ("wbregid"):buffer-value).
  create query gh-wb-egais-header.
  gh-wb-egais-header:set-buffers (bh-wb-gds-EG-header).
  gh-wb-egais-header:query-prepare ("for each tt-wb-act-header").
  gh-wb-egais-header:query-open.

  browse-hdl-wb-egais-header:query = gh-wb-egais-header.

  do ii = 1 to bh-wb-gds-EG-header:num-fields:
    browse-hdl-wb-egais-header:add-like-column('tt-wb-act-header' + '.' + bh-wb-gds-EG-header:buffer-field (ii):name, 0, 'FILL-IN').
  end.
  { gbl/diasize.i &br-hndl=browse-hdl-wb-egais }
  run diasize_init in this-procedure .
  run enable_UI.  
  bh-wb-gds-EG:find-first ("", no-lock) no-error.
  run refresh-view.
  
  v-uniq-key-rec  = bh-wb-egais:buffer-field ("wbregid"):buffer-value.

  bh-wb-gds-EG = egais:GetHndlTable(9, bh-wb-egais:buffer-field ("wbregid"):buffer-value).
  
  if bh-wb-gds-EG <> ? then do: 
    
    create query gh-wb-egais.
    gh-wb-egais:set-buffers (bh-wb-gds-EG).
    gh-wb-egais:query-prepare ("for each tt-wb-act-gds-EG").
    gh-wb-egais:query-open.
  
    browse-hdl-wb-egais:query = gh-wb-egais.
  
    extent (bcol) = bh-wb-gds-EG:num-fields.
    do ii = 1 to bh-wb-gds-EG:num-fields:
      bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-act-gds-EG' + '.' + bh-wb-gds-EG:buffer-field (ii):name, 0, 'FILL-IN').
      if ii = 2 then bcol[ii]:width = 50.
    end.
  end.

  wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

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
  DISPLAY 
    WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-view Dialog-Frame 
PROCEDURE refresh-view :

  display Btn_Cancel with frame Dialog-Frame.
  ENABLE Btn_Cancel
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if bh-wb-gds-EG <> ? 
  then do:
    bh-wb-gds-EG:find-first ().
    if bh-wb-gds-EG:available
      then browse-hdl-wb-egais:refresh ().
  end.
  browse-hdl-wb-egais-header:refresh ().
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-leave Dialog-Frame 
PROCEDURE proc-row-leave :
  
  def var ii as int no-undo.
  
  if bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value = "" or bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value = ? then 
  do:
    do ii = 1 to extent (bcol):  
      if valid-handle (bcol[ii]) 
        then bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME