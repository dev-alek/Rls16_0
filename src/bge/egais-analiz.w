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

Список задвоиных записей.

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
define input parameter egaisWB as class WayBill no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision               as character no-undo init "$Revision$":U .
define variable vss-author                 as character no-undo init "$Author$":U .
define variable vss-date                   as character no-undo init "$Date$":U .
define variable vss-workfile               as character no-undo init "$Workfile$":U .
define variable vss-archive                as character no-undo init "$Archive$":U .
define variable vss-description            as character no-undo init "Журнал запросов ЕГАИС".

define variable bh-wb-analiz               as handle    no-undo.
define variable browse-hdl-analiz          as handle    no-undo.
define variable qh-analiz                  as handle    no-undo.
define variable bcol                       as handle    extent no-undo.
define variable v-db-num                   as integer   no-undo .
define variable v-user-id                  as character no-undo .
define variable v-user-select              as character no-undo .
define variable v-select-obj-type          as character no-undo .
define variable v-select-obj-code          as integer   no-undo .
define variable v-obj-uniq-key-rec         as character no-undo .
define variable v-gds-uniq-key-rec         as character no-undo .
define variable v-rid                      as recid     no-undo .
/*define variable v-identity                 as character no-undo .*/
define variable v-uniq-key-rec             as character no-undo .
define variable url_                       as character no-undo .

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
&Scoped-Define ENABLED-OBJECTS Btn_Cancel btn_del 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.15
     BGCOLOR 8 .

DEFINE BUTTON btn_del 
     LABEL "Удалить" 
     SIZE 15 BY 1.15 TOOLTIP "Безвозвратное удаления записи с УТМ".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.26 COL 2
     btn_del AT ROW 1.26 COL 17.75
     SPACE(76.24) SKIP(23.32)
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
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON window-close OF FRAME Dialog-Frame /* Акт на накладную ЕГАИС */
do:
    apply "END-ERROR":U to self.
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_del Dialog-Frame
ON choose OF btn_del IN FRAME Dialog-Frame /* Удалить */
do:

  def var cmd as char no-undo.
    
  if qh-analiz:get-current () = ?
  then do:
    message "Установите курсор на запись, которую хотите удалить." view-as alert-box information.
    return no-apply.
  end.
  
  url_ = bh-wb-analiz:buffer-field ('url_'):buffer-value ().
  
  if not egaisWB:actnEGAISAdm
  then do:
    return no-apply.
  end.
  
  message "Вы уверены что хотите удалить запись " + url_ + "? Также будет помечена как неверная запись в TH, если такая имеется по этой записи." view-as alert-box question buttons yes-no update isChoise as log.
  
  if isChoise
  then do:
    cmd = substitute ("&1  -X DELETE &2", search ("exe/curl.exe"), url_).
    os-command value (cmd).
    do trans:
      for each ub.clob-bind exclusive-lock 
        where ub.clob-bind.uniq-key-rec = bh-wb-analiz:buffer-field ('uniq-key-rec'):buffer-value () 
          and ub.clob-bind.resource-type = bh-wb-analiz:buffer-field ('resource-type'):buffer-value ():
          
          ub.clob-bind.uniq-key-rec = ub.clob-bind.uniq-key-rec + "#отмена".
      
      end.
      bh-wb-analiz:buffer-delete ().
    end.
  end.
  else do:
    return no-apply.
  end.
  
  run refresh-view.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


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

  
  create browse browse-hdl-analiz
    assign 
    title     = ''
    frame     = frame {&FRAME-NAME}:handle
    query     = qh-analiz
    x         = 10
    y         = 42
    width     = 100
    height    = 22
    visible   = true
    read-only = true
    sensitive = true
    separators = true
    column-resizable = true
    .

  bh-wb-analiz = egaisWB:HndlAnaliz.
  create query qh-analiz.
  qh-analiz:set-buffers (bh-wb-analiz).
  qh-analiz:query-prepare ("for each tt-analiz where tt-analiz.isMany by tt-analiz.nnOrder").
  qh-analiz:query-open.

  browse-hdl-analiz:query = qh-analiz.

  do ii = 1 to bh-wb-analiz:num-fields:
    browse-hdl-analiz:add-like-column('tt-analiz' + '.' + bh-wb-analiz:buffer-field (ii):name, 0, 'FILL-IN').
  end.
  { gbl/diasize.i &br-hndl=browse-hdl-analiz }
  run diasize_init in this-procedure .
  run enable_UI.  
  bh-wb-analiz:find-first ("", no-lock) no-error.
  run refresh-view.
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
  ENABLE Btn_Cancel btn_del 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-view Dialog-Frame 
PROCEDURE refresh-view :
  
  display Btn_Cancel with frame Dialog-Frame.
  ENABLE Btn_Cancel btn_del
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  qh-analiz:query-close.
  qh-analiz:query-prepare ("for each tt-analiz where tt-analiz.isMany by tt-analiz.nnOrder").
  qh-analiz:query-open.
  browse-hdl-analiz:refresh ().

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

