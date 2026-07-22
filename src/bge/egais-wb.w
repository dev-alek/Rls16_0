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

Список накладных ЕГАИС

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
define variable gh-wb-egais-header         as handle    no-undo.
define variable bh-wb-gds-EG-header        as handle    no-undo.
define variable browse-hdl-wb-egais-header as handle    no-undo.
define variable bcol                       as handle    extent no-undo.
define variable bcol-h                     as handle    extent no-undo.
define variable v-db-num                   as integer   no-undo .
define variable v-user-id                  as character no-undo .
define variable v-user-select              as character no-undo .
define variable v-select-obj-type          as character no-undo .
define variable v-select-obj-code          as integer   no-undo .
define variable v-obj-uniq-key-rec         as character no-undo .
define variable v-ext-sys                  as integer   no-undo .
define variable v-rid                      as recid     no-undo .
/*define variable v-identity                 as character no-undo .*/
define variable v-uniq-key-rec             as character no-undo .
define variable glog                       as logical no-undo .
define variable ii                         as integer no-undo .
define variable extGdsObj                  as class ExtGds no-undo .
define variable extGdsValueObj             as class ExtGdsValue no-undo .
define variable v-prod                     as character no-undo .
define variable v-impor                    as character no-undo .

define buffer buf_clients   for ub.clients .
define buffer buf_firm      for ub.firm .
define buffer x_ext-classif for ub.ext-classif.
define buffer buf_goods     for ub.goods .
define buffer buf_clob-bind for ub.clob-bind .

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
&Scoped-Define ENABLED-OBJECTS Btn_Cancel btn_conn F-ship f-cons 
&Scoped-Define DISPLAYED-OBJECTS F-ship f-cons 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 b-choose-ship b-choose-cons 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-cons 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "b-choose-date-pov-plotn" 
  SIZE 3 BY 1.

DEFINE BUTTON b-choose-ship 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "b-choose-ship" 
  SIZE 3 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
  LABEL "Выход" 
  SIZE 15 BY 1.13
  BGCOLOR 8 .

DEFINE BUTTON btn_conn 
  LABEL "Связать" 
  SIZE 15 BY 1.13.

DEFINE VARIABLE f-cons AS CHARACTER FORMAT "X(256)":U 
  LABEL "Объект" 
  VIEW-AS FILL-IN 
  SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE F-ship AS CHARACTER FORMAT "X(256)":U 
  LABEL "Контрагент" 
  VIEW-AS FILL-IN 
  SIZE 14 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  Btn_Cancel AT ROW 1.25 COL 2
  btn_conn AT ROW 1.25 COL 18.5 WIDGET-ID 78
  b-choose-ship AT ROW 1.25 COL 61 WIDGET-ID 76
  F-ship AT ROW 1.29 COL 44.5 COLON-ALIGNED WIDGET-ID 2
  f-cons AT ROW 1.29 COL 72.38 COLON-ALIGNED WIDGET-ID 4
  b-choose-cons AT ROW 1.29 COL 89.5 WIDGET-ID 74
  SPACE(29.00) SKIP(25.28)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Накладная ЕГАИС"
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

/* SETTINGS FOR BUTTON b-choose-cons IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
ASSIGN 
  b-choose-cons:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR BUTTON b-choose-ship IN FRAME Dialog-Frame
   NO-ENABLE 1                                                          */
ASSIGN 
  b-choose-ship:HIDDEN IN FRAME Dialog-Frame = TRUE.

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


&Scoped-define SELF-NAME b-choose-cons
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-cons Dialog-Frame
ON CHOOSE OF b-choose-cons IN FRAME Dialog-Frame /* b-choose-date-pov-plotn */
  DO:
    
    def var v-old-regId as char no-undo init ?.
    
    find first X_ext-classif no-lock  where X_ext-classif.classif-subject = {&table_clients}
      and X_ext-classif.classif-name = {&extclass_clients_esys}
      and X_ext-classif.db-num = 0
      and X_ext-classif.key#_one = v-ext-sys
      and X_eXt-classif.CharKey_Three = bh-wb-gds-EG-header:buffer-field ("regID-cons"):buffer-value
      and X_eXt-classif.CharKey_Two <> ""
      no-error.
    
    if available (X_eXt-classif) 
      then v-old-regId = X_eXt-classif.CharKey_Three.
    
    run gbl/userobjs.w (
      input parparentproc /* parparentproc        */
      , input this-procedure :handle  /* p-callback-handle    */
      , input v-db-num                /* p-db-num             */
      , input v-user-id               /* p-user-id            */
      , input v-cntxt-host-code-obj   /* p-curr-host-code-obj */
      , input v-cntxt-obj-type        /* p-curr-obj-type      */
      , input v-cntxt-obj-code        /* p-curr-obj-code      */
      , input 'b-sel'
      , output v-user-select          /* p-user-select        */
      , output v-select-obj-type      /* p-select-obj-type    */
      , output v-select-obj-code      /* p-select-obj-code    */
      ) no-error.
    find first buf_clients no-lock where buf_clients.obj-type = v-select-obj-type and buf_clients.obj-code = v-select-obj-code no-error.
    if not available (buf_clients) 
      then return no-apply.
    run gen-key-rec in this-procedure   ( input {&table_clients}
      ,input buffer buf_clients:handle
      ,output v-obj-uniq-key-rec).
    find first X_ext-classif no-lock  where X_ext-classif.classif-subject = {&table_clients}
      and X_ext-classif.classif-name = {&extclass_clients_esys}
      and X_ext-classif.db-num = 0
      and X_ext-classif.key#_one = v-ext-sys
      and X_eXt-classif.uniq-key-rec = v-obj-uniq-key-rec
      no-error.
    if v-old-regId = ? then do:
      run ref/extclas1.p ( input {&add-def}
        ,input yes /*p-silent*/
        ,input-output v-rid
        ,input {&table_clients} /*p-classif-subject*/
        ,input {&extclass_clients_esys} /*p-classif-name*/
        ,input 0 /*p-db-num*/
        ,input v-ext-sys  /*p-key#_one*/
        ,input 0 /*p-Key#_Two*/
        ,input 0 /*p-key#_Three*/
        ,input '':U  /*p-CharKey_One */
        ,input buf_clients.obj-type + string (buf_clients.obj-code) /*p-CharKey_two */
        ,input bh-wb-gds-EG-header:buffer-field ("regID-cons"):buffer-value /*p-CharKey_three */
        ,input 0 /*p-nonunique */
        ,input v-obj-uniq-key-rec ) no-error.
      if error-status:error then 
      do:
        message return-value " " error-status:get-message(1) view-as alert-box .
        undo, return no-apply .
      end.
    end.
    else do:
      if not available (x_ext-classif) or v-old-regId <> X_eXt-classif.CharKey_Three
      then do:
        message 'Нельзя выбрать объект с другим кодом ЕГАИС' view-as alert-box.
        return no-apply.
      end.
    end.
    
    do trans:
      find first ub.clob-bind where ub.clob-bind.uniq-key-rec = v-uniq-key-rec and ub.clob-bind.field-name_ = {&lob-egais-wb}.
      entry (9, ub.clob-bind.descr, {&delim-par}) = buf_clients.obj-type + string (buf_clients.obj-code).
      bh-wb-egais:buffer-field ("obj"):buffer-value = buf_clients.obj-type + string (buf_clients.obj-code).
      release ub.clob-bind.
    end.

    delete object browse-hdl-wb-egais-header.
    delete object browse-hdl-wb-egais.
    create query gh-wb-egais-header.
    create browse browse-hdl-wb-egais-header
      assign 
      title     = 'Накладная ЕГАИС'
      frame     = frame {&FRAME-NAME}:handle
      query     = gh-wb-egais-header
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
    
    
    create query gh-wb-egais.
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
  
    egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
    if egais:StatusErr
    then do:
      message egais:Msg view-as alert-box error.
      return no-apply.
    end.
  
    bh-wb-gds-EG-header = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill):HndlHeader.
    bh-wb-gds-EG = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill):HndlLine.
    
    
    gh-wb-egais-header:set-buffers (bh-wb-gds-EG-header).
    gh-wb-egais-header:query-prepare ("for each tt-wb-header").
    gh-wb-egais-header:query-open.
    
    do ii = 1 to bh-wb-gds-EG-header:num-fields:
      bcol-h[ii] = browse-hdl-wb-egais-header:add-like-column('tt-wb-header' + '.' + bh-wb-gds-EG-header:buffer-field (ii):name, 0, 'FILL-IN').
      if ii = 6 then bcol-h[ii]:width = 20.
    end.
    
    gh-wb-egais:set-buffers (bh-wb-gds-EG).
    gh-wb-egais:query-prepare ("for each tt-wb-gds-EG by nn").
    gh-wb-egais:query-open.
  
    do ii = 1 to bh-wb-gds-EG:num-fields:
      bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-gds-EG' + '.' + bh-wb-gds-EG:buffer-field (ii):name, 0, 'FILL-IN').
      if ii = 2 then bcol[ii]:width = 50.
      if ii = 8 then bcol[ii]:width = 20.
    end.
  
    run refresh-view.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-ship
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-ship Dialog-Frame
ON CHOOSE OF b-choose-ship IN FRAME Dialog-Frame /* b-choose-ship */
  DO:

    def var v-rid-list as character no-undo.
  
/*    run ref/cli-all.w (                                                                             */
/*      input parparentproc                                                                           */
/*      ,input "b-sel"                                                                                */
/*      ,input {&all}                                                                                 */
/*      ,input {&all}                                                                                 */
/*      ,input {&current}                                                                             */
/*      ,input ?                                                                                      */
/*      ,input ",,,,,,NO,,"                                                                           */
/*      ,input "lock-cli-type"                                                                        */
/*      ,output v-rid-list ) no-error.                                                                */
/*    if v-rid-list = '':U then return no-apply.                                                      */
/*    find first buf_clients no-lock where                                                            */
/*      recid( buf_clients) = INTEGER( v-rid-list ) no-error.                                         */
/*    if not available buf_clients then                                                               */
/*    do:                                                                                             */
/*      return no-apply.                                                                              */
/*    end.                                                                                            */
/*/*    find first buf_firm where buf_firm.firm-code = buf_clients.obj-code no-error.*/               */
/*                                                                                                    */
/*    run gen-key-rec in this-procedure   ( input {&table_clients}                                    */
/*      ,input buffer buf_clients:handle                                                              */
/*      ,output v-obj-uniq-key-rec).                                                                  */
/*    find first X_ext-classif exclusive-lock  where X_ext-classif.classif-subject = {&table_clients} */
/*      and X_ext-classif.classif-name = {&extclass_clients_esys}                                     */
/*      and X_ext-classif.db-num = 0                                                                  */
/*      and X_ext-classif.key#_one = v-ext-sys                                                        */
/*      and X_eXt-classif.uniq-key-rec = v-obj-uniq-key-rec                                           */
/*      no-error.                                                                                     */
/*    if available X_ext-classif then                                                                 */
/*    do :                                                                                            */
/*      assign                                                                                        */
/*        X_ext-classif.charkey_three = bh-wb-gds-EG-header:buffer-field ("regID-ship"):buffer-value .*/
/*    end.                                                                                            */
/*    else                                                                                            */
/*    do :                                                                                            */
/*      run ref/extclas1.p ( input {&add-def}                                                         */
/*        ,input yes /*p-silent*/                                                                     */
/*        ,input-output v-rid                                                                         */
/*        ,input {&table_clients} /*p-classif-subject*/                                               */
/*        ,input {&extclass_clients_esys} /*p-classif-name*/                                          */
/*        ,input 0 /*p-db-num*/                                                                       */
/*        ,input v-ext-sys  /*p-key#_one*/                                                            */
/*        ,input 0 /*p-Key#_Two*/                                                                     */
/*        ,input 0 /*p-key#_Three*/                                                                   */
/*        ,input '':U  /*p-CharKey_One */                                                             */
/*        ,input '':U /*p-CharKey_two */                                                              */
/*        ,input bh-wb-gds-EG-header:buffer-field ("regID-ship"):buffer-value /*p-CharKey_three */    */
/*        ,input 0 /*p-nonunique */                                                                   */
/*        ,input v-obj-uniq-key-rec ) no-error.                                                       */
/*      if error-status:error then                                                                    */
/*      do:                                                                                           */
/*        message return-value " " error-status:get-message(1) view-as alert-box .                    */
/*        undo, return no-apply .                                                                     */
/*      end.                                                                                          */
/*    end.                                                                                            */
/*    bh-wb-gds-EG-header = egais:GetHndlTable(1, v-uniq-key-rec).                                    */
/*    gh-wb-egais-header:set-buffers (bh-wb-gds-EG-header).                                           */
/*    gh-wb-egais-header:query-prepare ("for each tt-wb-header").                                     */
/*    gh-wb-egais-header:query-open.                                                                  */
/*                                                                                                    */
/*    run refresh-view.                                                                               */

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_conn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_conn Dialog-Frame
ON CHOOSE OF btn_conn IN FRAME Dialog-Frame /* Связать */
  DO:
  
    if bh-wb-gds-EG = ?
      then 
    do:
      message "Не выбран товар" view-as alert-box.
      return no-apply.
    end.
    run msdblcl.
  
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

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

  extGdsObj = new ExtGds(true).

  { gbl/getcurus.i
    v-db-num
    v-user-id
    no-error
  }
  { gbl/getcntxt.i get }

  find first ub.ext-system where ub.ext-system.delivery-method = integer ({&esys-dm-egais}).
  assign 
    v-ext-sys = ub.ext-system.esys-id .  
  
  create query gh-wb-egais-header.
  create browse browse-hdl-wb-egais-header
    assign 
    title     = 'Накладная ЕГАИС'
    frame     = frame {&FRAME-NAME}:handle
    query     = gh-wb-egais-header
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
  
  
  create query gh-wb-egais.
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

  egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
  if egais:StatusErr
  then do:
    message egais:Msg view-as alert-box error.
    return no-apply.
  end.

  bh-wb-gds-EG-header = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill):HndlHeader.
  bh-wb-gds-EG = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill):HndlLine.
  
  
  gh-wb-egais-header:set-buffers (bh-wb-gds-EG-header).
  gh-wb-egais-header:query-prepare ("for each tt-wb-header").
  gh-wb-egais-header:query-open.
  
  extent (bcol-h) = bh-wb-gds-EG-header:num-fields.
  do ii = 1 to bh-wb-gds-EG-header:num-fields:
    bcol-h[ii] = browse-hdl-wb-egais-header:add-like-column('tt-wb-header' + '.' + bh-wb-gds-EG-header:buffer-field (ii):name, 0, 'FILL-IN').
    if ii = 6 then bcol-h[ii]:width = 20.
  end.
  
  gh-wb-egais:set-buffers (bh-wb-gds-EG).
  gh-wb-egais:query-prepare ("for each tt-wb-gds-EG by nn").
  gh-wb-egais:query-open.

  extent (bcol) = bh-wb-gds-EG:num-fields.
  do ii = 1 to bh-wb-gds-EG:num-fields:
    bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-gds-EG' + '.' + bh-wb-gds-EG:buffer-field (ii):name, 0, 'FILL-IN').
    if ii = 2 then bcol[ii]:width = 50.
    if ii = 8 then bcol[ii]:width = 20.
  end.
  

  { gbl/diasize.i &br-hndl=browse-hdl-wb-egais }
  run diasize_init in this-procedure .
  run enable_UI.  
  bh-wb-gds-EG:find-first ("", no-lock) no-error.
  run refresh-view.
  
  v-uniq-key-rec  = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value.
/*  find first ub.clob-bind exclusive-lock where ub.clob-bind.uniq-key-rec = v-uniq-key-rec and ub.clob-bind.field-name_ = {&lob-egais-wb}.*/
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
  DISPLAY F-ship f-cons 
    WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel btn_conn 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE msdblcl Dialog-Frame 
PROCEDURE msdblcl :
  def    var      v-rid-list  as character no-undo.
  define variable par-alcohol as character no-undo .
  define variable par-type    as character no-undo .
  define buffer buf_ext-classif for ub.ext-classif.
  def var nnList as int no-undo.
  def var v-add as logical no-undo.
  def var v-numBnd as int no-undo.
  define variable v-prod-full-name as character no-undo .
  define variable v-import-full-name as character no-undo .
  define variable v-gds-code as int no-undo .
  define variable v-gds-name as character no-undo .
  
  def var glog as  log no-undo.

  if bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value <> "0" then 
  do :
    extGdsObj:OpenQueryExtGds(0, bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value).
    v-numBnd = extGdsObj:NumBundles.

    def var v-alc-code as char no-undo.
    v-alc-code = bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value.
    run bge/egais-goods-mark.w ( 
                                input parparentproc, 
                                input {&update}, 
                                input-output v-alc-code, 
                                input-output v-gds-code, 
                                output v-gds-name, 
                                output v-prod-full-name, 
                                output v-import-full-name )  .  

    /*run ref/gds-ref.p
      ( parparentproc
      ,'b-add,b-sel'
      ,?             /*p-stat */
      ,?             /*p-list  */
      ,?             /*p-cond  */
      ,?             /*p-rec   */
      ,?             /*p-grp   */
      ,?             /*p-cli-type */
      ,?             /*p-cli-code  */
      ,v-cntxt-obj-type    /*p-obj-type  */
      ,v-cntxt-obj-code     /*p-obj-code  */
      ,?             /*p-other     */
      , output v-rid-list) no-error.*/
    if v-gds-code = 0 or v-gds-code = ? 
      then return no-apply. 
    find buf_goods where buf_goods.gds-code = v-gds-code no-lock.
    run gds-attr-value(
      buf_goods.gds-code,
      {&attr-alcohol-prod},
      output par-alcohol,
      output par-type
      ).
    if par-alcohol = "" or par-alcohol = "no" then 
    do :
      message "Выбранный товар не является алкогольной продукцией." view-as alert-box.
      return no-apply.
    end.
    if buf_goods.ms-base <> bh-wb-gds-EG:buffer-field ("ms-base"):buffer-value and (bh-wb-gds-EG:buffer-field ("ms-base"):buffer-value <> 0 and bh-wb-gds-EG:buffer-field ("ms-base"):buffer-value <> ?)
    then do:
      message "У выбранного товара не соответсвует объем" view-as alert-box.
      return no-apply.
    end.
    /*if buf_goods.proof <> bh-wb-gds-EG:buffer-field ("proof"):buffer-value and (bh-wb-gds-EG:buffer-field ("proof"):buffer-value <> 0 and bh-wb-gds-EG:buffer-field ("proof"):buffer-value <> ?)
    then do:
      message "У выбранного товара не соответсвует содержание спирта" view-as alert-box.
      return no-apply.
    end.*/
    find first ub.alc-type-gds 
         where ub.alc-type-gds.gds-code = buf_goods.gds-code
           and ub.alc-type-gds.create-user-db-num = 0 no-lock no-error.
    if not available (ub.alc-type-gds) 
    then do:
      message "У выбранного товара не задана алкогольная группа" view-as alert-box.
      return no-apply.
    end.
    else do:
      find first ub.alc-type where ub.alc-type-gds.alc-type-inner-code = ub.alc-type.alc-type-inner-code no-lock no-error.
      if not available (ub.alc-type) 
      then do:
        message "Не найдена алкогольная группа" view-as alert-box.
        return no-apply.
      end.
      /*if ub.alc-type.alc-type-code <>  bh-wb-gds-EG:buffer-field ("alc-type-code"):buffer-value
      then do:
        message "У выбранного товара не соответсвует алкогольная группа" view-as alert-box.
        return no-apply.
      end.*/
    end.

    
    extGdsValueObj = new ExtGdsValue().
    
    v-prod = bh-wb-gds-EG:buffer-field ("prod-list"):buffer-value.
    v-impor = bh-wb-gds-EG:buffer-field ("importer-list"):buffer-value.
    extGdsValueObj:AlcCode = bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value.
    extGdsValueObj:GdsCode = buf_goods.gds-code.
    extGdsValueObj:CliRegIdProd = entry (1, v-prod, chr(5)).
    extGdsValueObj:INNProd = entry (2, v-prod, chr(5)).
    extGdsValueObj:KPPProd = entry (3, v-prod, chr(5)).
    extGdsValueObj:FullNameProd = entry (4, v-prod, chr(5)).
    extGdsValueObj:CountryProd = entry (5, v-prod, chr(5)).
    extGdsValueObj:DescrProd = entry (6, v-prod, chr(5)).

    extGdsValueObj:CliEgaisTypeProd = entry (7, v-prod, chr(5)).
    extGdsValueObj:RegionProd = entry (8, v-prod, chr(5)).
    
    extGdsValueObj:CliRegIdImpor = entry (1, v-impor, chr(5)).
    extGdsValueObj:INNImpor = entry (2, v-impor, chr(5)).
    extGdsValueObj:KPPImpor = entry (3, v-impor, chr(5)).
    extGdsValueObj:FullNameImpor = entry (4, v-impor, chr(5)).
    extGdsValueObj:CountryImpor = entry (5, v-impor, chr(5)).
    extGdsValueObj:DescrImpor = entry (6, v-impor, chr(5)).

    extGdsValueObj:FullNameGds = bh-wb-gds-EG:buffer-field ("gds-name"):buffer-value.
    
    extGdsObj:OpenQueryExtGds (buf_goods.gds-code, bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value).
    
    if extGdsObj:NumBundles = 0 and bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value <> ? then do:
      message substitute ("Добавить новую связку для - &1?", bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value) view-as alert-box
      question buttons yes-no
      title "" update v-add.
      if not v-add
        then message substitute ("Связка будет удалена &1/&2", bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value, bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value) view-as alert-box
                question buttons ok-cancel title "" update v-ok as log.
        else message substitute ("Будет добавлена новая связка для - &1", bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value) view-as alert-box 
                question buttons ok-cancel title "" update v-ok.

      if not v-ok 
        then undo, return no-apply.
    end.
    
    do trans:
    
    if extGdsObj:NumBundles = 0
    then do:
      

      if not v-add
        then extGdsObj:DeleteExtGds(integer (bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value), bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value).
      if extGdsObj:CreateExtGds(extGdsValueObj)
      then do:

          find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = v-uniq-key-rec and buf_clob-bind.field-name_ = {&lob-egais-ref-b}.
          if not available (buf_clob-bind)
          then do:
            message "По товарам нет справки Б".
            undo, return no-apply.
          end.
          nnList = lookup (bh-wb-gds-EG:buffer-field ("refB"):buffer-value, buf_clob-bind.descr). 
          if nnList > 0 
          then do:
            entry (nnList - 1, buf_clob-bind.descr) = string (buf_goods.gds-code).
          end.
          else do:
            buf_clob-bind.descr = buf_clob-bind.descr + "," +  string (buf_goods.gds-code) + "," + bh-wb-gds-EG:buffer-field ("refB"):buffer-value.
            buf_clob-bind.descr = left-trim (buf_clob-bind.descr, ",").
          end.
          release buf_clob-bind.

      end. 
      else do:
        message "Ошибка добавления записи в справочник: " extGdsObj:ReturnMsg view-as alert-box .
        undo, return no-apply .
      end.

    end.
    else do:

        find first buf_clob-bind exclusive-lock where buf_clob-bind.uniq-key-rec = v-uniq-key-rec and buf_clob-bind.field-name_ = {&lob-egais-ref-b}.
        if not available (buf_clob-bind)
        then do:
          message "По товарам нет справки Б".
          undo, return no-apply.
        end.
        nnList = lookup (bh-wb-gds-EG:buffer-field ("refB"):buffer-value, buf_clob-bind.descr). 
        if nnList > 0 
        then do:
          entry (nnList - 1, buf_clob-bind.descr) = string (buf_goods.gds-code).
        end.
        else do:
          buf_clob-bind.descr = buf_clob-bind.descr + "," +  string (buf_goods.gds-code) + "," + bh-wb-gds-EG:buffer-field ("refB"):buffer-value.
          buf_clob-bind.descr = left-trim (buf_clob-bind.descr, ",").
        end.
        release buf_clob-bind.
    end.
    

    end.
    
  end.                                    
  else 
  do :
    
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_egais-ref':U
      {&cntxt-object}
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      true
      glog
    }
    
    if not glog then  return .
    
    run ref/gds-ref.p
      ( parparentproc
      ,'b-add,b-sel'
      ,?             /*p-stat */
      ,?             /*p-list  */
      ,?             /*p-cond  */
      ,?             /*p-rec   */
      ,?             /*p-grp   */
      ,?             /*p-cli-type */
      ,?             /*p-cli-code  */
      ,v-cntxt-obj-type    /*p-obj-type  */
      ,v-cntxt-obj-code     /*p-obj-code  */
      ,?             /*p-other     */
      , output v-rid-list) no-error.
    if v-rid-list = "" or v-rid-list = ? 
      then return no-apply.
    find buf_goods where recid (buf_goods) = integer (v-rid-list) no-lock. 
    run gds-attr-value(
      buf_goods.gds-code,
      {&attr-alcohol-prod},
      output par-alcohol,
      output par-type
      ).
    if par-alcohol = "" or par-alcohol = "no" then 
    do :
      message "Выбранный товар не является алкогольной продукцией." view-as alert-box.
      return no-apply.
    end.
    if buf_goods.ms-base <> bh-wb-gds-EG:buffer-field ("ms-base"):buffer-value and (bh-wb-gds-EG:buffer-field ("ms-base"):buffer-value <> 0 and bh-wb-gds-EG:buffer-field ("ms-base"):buffer-value <> ?)
    then do:
      message "У выбранного товара не соответсвует объем" view-as alert-box.
      return no-apply.
    end.
    /*if buf_goods.proof <> bh-wb-gds-EG:buffer-field ("proof"):buffer-value and (bh-wb-gds-EG:buffer-field ("proof"):buffer-value <> 0 and bh-wb-gds-EG:buffer-field ("proof"):buffer-value <> ?)
    then do:
      message "У выбранного товара не соответсвует содержание спирта" view-as alert-box.
      return no-apply.
    end.*/
    find first ub.alc-type-gds 
         where ub.alc-type-gds.gds-code = buf_goods.gds-code
           and ub.alc-type-gds.create-user-db-num = 0 no-lock no-error.
    if not available (ub.alc-type-gds) 
    then do:
      message "У выбранного товара не задана алкогольная группа" view-as alert-box.
      return no-apply.
    end.
    else do:
      find first ub.alc-type where ub.alc-type-gds.alc-type-inner-code = ub.alc-type.alc-type-inner-code no-lock no-error.
      if not available (ub.alc-type) 
      then do:
        message "Не найдена алкогольная группа" view-as alert-box.
        return no-apply.
      end.
      /*if ub.alc-type.alc-type-code <>  bh-wb-gds-EG:buffer-field ("alc-type-code"):buffer-value
      then do:
        message "У выбранного товара не соответсвует алкогольная группа" view-as alert-box.
        return no-apply.
      end.*/        
    end.
    
    extGdsValueObj = new ExtGdsValue().
    
    v-prod = bh-wb-gds-EG:buffer-field ("prod-list"):buffer-value.
    v-impor = bh-wb-gds-EG:buffer-field ("importer-list"):buffer-value.
    extGdsValueObj:AlcCode = bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value.
    extGdsValueObj:GdsCode = buf_goods.gds-code.
    extGdsValueObj:CliRegIdProd = entry (1, v-prod, chr(5)).
    extGdsValueObj:INNProd = entry (2, v-prod, chr(5)).
    extGdsValueObj:KPPProd = entry (3, v-prod, chr(5)).
    extGdsValueObj:FullNameProd = entry (4, v-prod, chr(5)).
    extGdsValueObj:CountryProd = entry (5, v-prod, chr(5)).
    extGdsValueObj:DescrProd = entry (6, v-prod, chr(5)).
    
    extGdsValueObj:CliRegIdImpor = entry (1, v-impor, chr(5)).
    extGdsValueObj:INNImpor = entry (2, v-impor, chr(5)).
    extGdsValueObj:KPPImpor = entry (3, v-impor, chr(5)).
    extGdsValueObj:FullNameImpor = entry (4, v-impor, chr(5)).
    extGdsValueObj:CountryImpor = entry (5, v-impor, chr(5)).
    extGdsValueObj:DescrImpor = entry (6, v-impor, chr(5)).

    extGdsValueObj:FullNameGds = bh-wb-gds-EG:buffer-field ("gds-name"):buffer-value.
    
    if not extGdsObj:CreateExtGds(extGdsValueObj) then
    do:
      message "Ошибка добавления записи в справочник: " extGdsObj:ReturnMsg view-as alert-box .
      undo, return no-apply .
    end.
  end.
  
  delete object browse-hdl-wb-egais-header.
  delete object browse-hdl-wb-egais.
  create query gh-wb-egais-header.
  create browse browse-hdl-wb-egais-header
    assign 
    title     = 'Накладная ЕГАИС'
    frame     = frame {&FRAME-NAME}:handle
    query     = gh-wb-egais-header
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
  
  
  create query gh-wb-egais.
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

  egais:GetHndlTable(1, bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value).
  if egais:StatusErr
  then do:
    message egais:Msg view-as alert-box error.
    return no-apply.
  end.

  bh-wb-gds-EG-header = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill):HndlHeader.
  bh-wb-gds-EG = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill):HndlLine.
  
  
  gh-wb-egais-header:set-buffers (bh-wb-gds-EG-header).
  gh-wb-egais-header:query-prepare ("for each tt-wb-header").
  gh-wb-egais-header:query-open.
  
  do ii = 1 to bh-wb-gds-EG-header:num-fields:
    bcol-h[ii] = browse-hdl-wb-egais-header:add-like-column('tt-wb-header' + '.' + bh-wb-gds-EG-header:buffer-field (ii):name, 0, 'FILL-IN').
    if ii = 6 then bcol-h[ii]:width = 20.
  end.
  
  gh-wb-egais:set-buffers (bh-wb-gds-EG).
  gh-wb-egais:query-prepare ("for each tt-wb-gds-EG by nn").
  gh-wb-egais:query-open.

  do ii = 1 to bh-wb-gds-EG:num-fields:
    bcol[ii] = browse-hdl-wb-egais:add-like-column('tt-wb-gds-EG' + '.' + bh-wb-gds-EG:buffer-field (ii):name, 0, 'FILL-IN').
    if ii = 2 then bcol[ii]:width = 50.
    if ii = 8 then bcol[ii]:width = 20.
  end.

  run refresh-view.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-view Dialog-Frame 
PROCEDURE refresh-view :

  f-cons = bh-wb-gds-EG-header:buffer-field ("clientCons"):buffer-value.
  f-ship = bh-wb-gds-EG-header:buffer-field ("client"):buffer-value.
  display Btn_Cancel f-cons F-ship b-choose-cons b-choose-ship btn_conn with frame Dialog-Frame.
  ENABLE Btn_Cancel b-choose-cons btn_conn
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  bh-wb-gds-EG:find-first ().
  if bh-wb-gds-EG-header:buffer-field ("client"):buffer-value <> "" 
    then disable b-choose-ship with frame Dialog-Frame.
/*  if bh-wb-gds-EG-header:buffer-field ("clientCons"):buffer-value <> ""*/
/*    then disable b-choose-cons with frame Dialog-Frame.                */
  browse-hdl-wb-egais:refresh ().
  browse-hdl-wb-egais-header:refresh ().
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-leave Dialog-Frame 
PROCEDURE proc-row-leave :
  
  def var ii as int no-undo.

  do ii = 1 to extent (bcol):  
    if valid-handle (bcol[ii]) and bh-wb-gds-EG:buffer-field ("color-sts"):buffer-value <> ?
      then bcol[ii]:bgcolor = bh-wb-gds-EG:buffer-field ("color-sts"):buffer-value.
  end.
  
  /*if bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value = 0 then 
  do:
    do ii = 1 to extent (bcol):  
      if valid-handle (bcol[ii]) 
        then bcol[ii]:bgcolor = RED_COLOR.
    end.
  end.
  extGdsObj:OpenQueryExtGds(0, bh-wb-gds-EG:buffer-field ("alc-code"):buffer-value ).
  if extGdsObj:NumBundles > 1 then 
  do:
    do ii = 1 to extent (bcol):  
      if valid-handle (bcol[ii]) 
        then bcol[ii]:bgcolor = DARK_GRAY_COLOR.
    end.
  end.
  if bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value <> 0
    then extGdsObj:OpenQueryExtGds(bh-wb-gds-EG:buffer-field ("gds-code"):buffer-value, "" ).
  if extGdsObj:NumBundles > 1 then 
  do:
    do ii = 1 to extent (bcol):  
      if valid-handle (bcol[ii]) 
        then bcol[ii]:bgcolor = DARK_GRAY_COLOR.
    end.
  end.*/
  
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME