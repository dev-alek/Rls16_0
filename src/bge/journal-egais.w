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

Журнал запросов ЕГАИС

  Author: 
    Автор: Шкляр Елена Львовна
    Дата создания: 15/11/03
    Author: Elena Shklyar
    Creation date: 15/11/03

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
using ibs.th.bge.egais.*.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Журнал запросов ЕГАИС".

define variable th-journal-egais     as handle  no-undo.
define variable bh-journal-egais     as handle  no-undo.
define variable gh-journal-egais     as handle  no-undo.
define variable browse-hdl-journal-egais as handle no-undo.
define variable bcol                  as handle no-undo.
define variable bcol1                 as handle no-undo.
define variable bcol2                 as handle no-undo.
define variable bcol3                 as handle no-undo.
define variable bcol4                 as handle no-undo.
define variable bcol5                 as handle no-undo.
define variable egais                as class EGAIS   no-undo.
define variable journal              as class Journal no-undo.
define variable v-db-num             as integer   no-undo .
define variable v-user-id            as character no-undo .

define variable glog                 as logical   no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-browse-journal-egais}
    
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel RADIO-SET-1 ~

&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_del 
     LABEL "Удалить" 
     tooltip "Удалить из журнала. Дает возможность отправить повторно запрос."
     SIZE 15 BY 1.13.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 1,
"Новые", 2,
"Закрытые", 3
     SIZE 50 BY 1.25 NO-UNDO.
{ gbl/color.i }
{ cmp/library.i  }

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-Journal-egais
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-Journal-egais Dialog-Frame _FREEFORM
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 135 BY 25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_del AT ROW 1 COL 16.63 WIDGET-ID 6
     RADIO-SET-1 AT ROW 1.04 COL 32.88 NO-LABEL WIDGET-ID 2
     BROWSE-Journal-egais AT ROW 3 COL 1 WIDGET-ID 200
     SPACE(0.50) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Журнал запросов ЕГАИС"
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
/* BROWSE-TAB BROWSE-Journal-egais RADIO-SET-1 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-1 .
   RUN enable_UI.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-del Dialog-Frame
ON choose OF Btn_del IN FRAME Dialog-Frame
DO:

  find first ub.esys-all-attr where (table-name + string (key1) + string (key2) + string (key3) + string (key4) + string (key5) + string (key6) +
        string (key7) + string (key8) + attr-code) = bh-journal-egais:buffer-field ('piIndex'):buffer-value () no-error.
  if available (ub.esys-all-attr)
    then delete ub.esys-all-attr. 

  if bh-journal-egais:available
    then bh-journal-egais:buffer-delete ().
  
  BROWSE-Journal-egais:refresh ().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define BROWSE-NAME BROWSE-Journal-egais
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
       def var ii as int no-undo.
      { gbl/getcurus.i
        v-db-num
        v-user-id
        no-error
      }
      
      
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_egais-adm':U
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




      
  egais = new EGAIS(v-db-num, v-user-id).
  journal = new Journal().
  
  egais:EGAISImpl = journal.
  
  bh-journal-egais = egais:GetHndlTable().


    create query gh-journal-egais.
  
  
    gh-journal-egais:SET-BUFFERS (bh-journal-egais ).
    gh-journal-egais:query-prepare ("for each tt_journal-egais").
    gh-journal-egais:QUERY-OPEN.
    BROWSE-Journal-egais:QUERY = gh-journal-egais.


  do ii = 1 to bh-journal-egais:num-fields - 1:
     bcol = browse-journal-egais:add-like-column('tt_journal-egais' + '.' + bh-journal-egais:buffer-field (ii):name, 0, 'FILL-IN').
  end.  
          bcol1 = browse-journal-egais:get-browse-column(1).
          
          bcol2 = browse-journal-egais:get-browse-column(2).
          
          bcol3 = browse-journal-egais:get-browse-column(3).

          bcol4 = browse-journal-egais:get-browse-column(4).
          
          bcol5 = browse-journal-egais:get-browse-column(5).
          
on row-display of browse-journal-egais IN FRAME Dialog-Frame  /* - */
DO:
    if bh-journal-egais:buffer-field ("jou-status"):buffer-value  = "Запрос отправлен" then do:
        bcol1:bgcolor = YELLOW_COLOR.
        bcol2:bgcolor = YELLOW_COLOR.
        bcol3:bgcolor = YELLOW_COLOR.
        bcol4:bgcolor = YELLOW_COLOR.
        bcol:bgcolor  = YELLOW_COLOR .
        bcol5:bgcolor = YELLOW_COLOR .  
    end.
end.    

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
  DISPLAY RADIO-SET-1 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_del RADIO-SET-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  ENABLE BROWSE-journal-egais 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  
   case RADIO-SET-1 :
      when 1  then do:
            gh-journal-egais:SET-BUFFERS (bh-journal-egais).
            gh-journal-egais:query-prepare ("for each tt_journal-egais by tt_journal-egais.jou-time desc").
            gh-journal-egais:QUERY-OPEN.
      end.
      when 2  then do:
            gh-journal-egais:SET-BUFFERS (bh-journal-egais).
            gh-journal-egais:query-prepare ("for each tt_journal-egais where tt_journal-egais.jou-status = 'Запрос отправлен'  by tt_journal-egais.jou-time desc").
            gh-journal-egais:QUERY-OPEN.
      end.
      when 3 then do:
            gh-journal-egais:SET-BUFFERS (bh-journal-egais).
            gh-journal-egais:query-prepare ("for each tt_journal-egais where tt_journal-egais.jou-status = 'Ответ получен'  by tt_journal-egais.jou-time desc").
            gh-journal-egais:QUERY-OPEN.
      end.
    end.
 
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

