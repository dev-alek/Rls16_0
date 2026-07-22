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

Список квитанций по накладным ЕГАИС

  Author: 
    Автор: Морозов Александр Сергеевич
    Дата создания: 15/01/27
    Author: Alexandr Morozov
    Creation date: 15/01/27
    
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

define variable qh-ticket-egais         as handle  no-undo.
define variable qh-ticket-egais-last    as handle  no-undo.
define variable browse-hdl-ticket-egais as handle  no-undo.
define variable bh-ticket-egais         as handle  no-undo.
define variable isRepealWB              as logical no-undo.
define variable wbregIdRepeal           as character no-undo.
define variable bcol                    as handle extent no-undo.
define variable egaisWBAdv              as class WayBill no-undo.
{ibs/th/bge/egais/wb-egais.i}
{ cmp/showinf.i  }
{cmp/str-glbl.i  }
  
define buffer buf_doc-attr for ub.doc-attr.
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK btn_accRepeal btn_rejRepeal cb_status 
&Scoped-Define DISPLAYED-OBJECTS cb_status FILL-IN-1 FILL-IN-3 FILL-IN-2 ~
FILL-IN-4 FILL-IN-5 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn_accRepeal 
     LABEL "Подт. расп." 
     SIZE 15 BY 1.13.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Выход" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON btn_rejRepeal 
     LABEL "Отказ расп." 
     SIZE 15 BY 1.13.

DEFINE VARIABLE cb_status AS CHARACTER FORMAT "X(256)":U 
     LABEL "Статус" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Accepted","Rejected","Распроведена","Отсутствует" 
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 119.25 BY 1
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     btn_accRepeal AT ROW 1.25 COL 17.13 WIDGET-ID 12
     btn_rejRepeal AT ROW 1.25 COL 32.88 WIDGET-ID 14
     cb_status AT ROW 1.25 COL 55.5 COLON-ALIGNED WIDGET-ID 16
     FILL-IN-1 AT ROW 14.71 COL 1.75 NO-LABEL WIDGET-ID 2
     FILL-IN-3 AT ROW 15.71 COL 1.75 NO-LABEL WIDGET-ID 6
     FILL-IN-2 AT ROW 16.71 COL 1.75 NO-LABEL WIDGET-ID 4
     FILL-IN-4 AT ROW 17.71 COL 1.75 NO-LABEL WIDGET-ID 8
     FILL-IN-5 AT ROW 18.71 COL 1.75 NO-LABEL WIDGET-ID 10
     SPACE(0.37) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Квитанция по накладной"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.


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

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-4 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Квитанция по накладной */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_accRepeal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_accRepeal Dialog-Frame
ON CHOOSE OF btn_accRepeal IN FRAME Dialog-Frame /* Подт. расп. */
DO:
  egaisWBAdv:ConfirmRepealWB(wbregIdRepeal, "Accepted").
  if egaisWBAdv:StatusErr
  then do:
    message egaisWBAdv:Msg view-as alert-box error.
    return no-apply.
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_rejRepeal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_rejRepeal Dialog-Frame
ON CHOOSE OF btn_rejRepeal IN FRAME Dialog-Frame /* Отказ расп. */
DO:
  egaisWBAdv:ConfirmRepealWB(wbregIdRepeal, "Rejected").
  if egaisWBAdv:StatusErr
  then do:
    message egaisWBAdv:Msg view-as alert-box error.
    return no-apply.
  end.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb_status
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb_status Dialog-Frame
ON VALUE-CHANGED OF cb_status IN FRAME Dialog-Frame /* Статус */
DO:
  message  substitute ("Вы уверены, что хотите изменить статус накладной с &1 на &2?", bh-wb-egais:buffer-field ("EGAISSts"):buffer-value, cb_status:screen-value) view-as alert-box question buttons yes-no
    title "" update isChoise as logical.
  if isChoise
  then do:
    if egaisWBAdv:ActnEGAISAdm
    then do:
      if bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "расход" or bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "возврат"
      then do:
        find first ub.doc-attr exclusive-lock 
          where ub.doc-attr.doc-code = bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value and ub.doc-attr.attr-code = {&trdcattr-egais} no-error.
        if available (ub.doc-attr)
          then 
        do:
          ub.doc-attr.attr-value = if cb_status:screen-value = "Отсутствует" then "" else cb_status:screen-value.
        end.
        release ub.doc-attr.
      end.
      else do:
        for each ub.clob-bind where ub.clob-bind.resource-type = {&lob-egais-wb} and ub.clob-bind.uniq-key-rec = bh-wb-egais:buffer-field ("uniq-key-rec"):buffer-value:
          if num-entries (ub.clob-bind.descr, {&delim-par}) = 9
          then do:
            ub.clob-bind.descr = ub.clob-bind.descr + {&delim-par}.
          end.
          if num-entries (ub.clob-bind.descr, {&delim-par}) > 9
          then
            assign
              entry (10, ub.clob-bind.descr, {&delim-par}) = if cb_status:screen-value = "Отсутствует" then "" else cb_status:screen-value
            .
        end.
        for each buf_doc-attr no-lock 
          where buf_doc-attr.doc-code = bh-wb-egais:buffer-field ("wbregid"):buffer-value and buf_doc-attr.attr-code = {&trdcattr-negais}:
          find first ub.doc-attr exclusive-lock where ub.doc-attr.doc-code = buf_doc-attr.doc-code and ub.doc-attr.attr-code = {&trdcattr-egais} no-error.
          if available (ub.doc-attr)
            then ub.doc-attr.attr-value = if cb_status:screen-value = "Отсутствует" then "" else cb_status:screen-value.
          release ub.doc-attr.
        end.
      end.
      bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = cb_status:screen-value .
      return.
    end.
    else do:
      message 'Для изменения статуса остутсвует необходимое право "Администрирование запросов в ЕГАИС"' view-as alert-box error title "".
    end.
  end.
  cb_status:screen-value = bh-wb-egais:buffer-field ("EGAISSts"):buffer-value.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

  egaisWBAdv = cast (egais:EGAISImpl, ibs.th.bge.egais.WayBill).

  create query qh-ticket-egais.
  create browse browse-hdl-ticket-egais
    assign 
      title     = 'Связанные документы ЕГАИС'
      frame     = frame {&FRAME-NAME}:handle
      query     = qh-ticket-egais
      x         = 6
      y         = 38
      width     = 119
      height    = 12
      visible   = true
      read-only = true
      sensitive = true
      separators = true
      column-resizable = true
      column-scrolling = true
      triggers:
        on value-changed persistent run local-value-changed.
      end triggers
  .
  if bh-wb-egais = ? then return.
  if bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "расход" or bh-wb-egais:buffer-field ("wb-type"):buffer-value begins "возврат"
  then do:
    bh-ticket-egais = egais:GetHndlTable({&ticket-ras}, bh-wb-egais:buffer-field ("trn-doc-code"):buffer-value).
  end.
  else do:
    bh-ticket-egais = egais:GetHndlTable({&ticket}, bh-wb-egais:buffer-field ("wbregid"):buffer-value).
  end.
  if egais:StatusErr
  then do:
    message egais:Msg view-as alert-box error.
    return.
  end.

  qh-ticket-egais:set-buffers (bh-ticket-egais).
  qh-ticket-egais:query-prepare ("for each tt-ticket").
  qh-ticket-egais:query-open.
  if not bh-ticket-egais = ? 
  then do:
    extent (bcol) = bh-ticket-egais:num-fields.
    do ii = 1 to bh-ticket-egais:num-fields:
      bcol[ii] = browse-hdl-ticket-egais:add-like-column('tt-ticket' + '.' + bh-ticket-egais:buffer-field (ii):name, 0, 'FILL-IN').
      if ii = 6 then bcol[ii]:width = 80.
      if ii = 2 then bcol[ii]:width = 15.
      if ii = 3 then bcol[ii]:width = 15.
    end.
  end.

  isRepealWB = bh-ticket-egais:find-last ("where docType = 'RequestRepealWB'", no-lock) no-error.
  if isRepealWB 
    then wbregIdRepeal = bh-ticket-egais:buffer-field ("regid"):buffer-value.
  if lookup (bh-wb-egais:buffer-field ("EGAISSts"):buffer-value, cb_status:list-items ) = 0 and (bh-wb-egais:buffer-field ("EGAISSts"):buffer-value <> ? and bh-wb-egais:buffer-field ("EGAISSts"):buffer-value <> "")
    then cb_status:list-items = cb_status:list-items + "," + bh-wb-egais:buffer-field ("EGAISSts"):buffer-value.  
  cb_status = if bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = "" or bh-wb-egais:buffer-field ("EGAISSts"):buffer-value = ? then "Отсутствует" else bh-wb-egais:buffer-field ("EGAISSts"):buffer-value.
  RUN enable_UI.
  run hide-disp.
  bh-ticket-egais:find-first ("") no-error.
  run local-value-changed.
  if not egaisWBAdv:ActnEGAISSts
    then cb_status:sensitive = false.
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
  DISPLAY cb_status FILL-IN-1 FILL-IN-3 FILL-IN-2 FILL-IN-4 FILL-IN-5 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK btn_accRepeal btn_rejRepeal cb_status 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-disp Dialog-Frame 
PROCEDURE hide-disp :
do with frame {&frame-name}:
    if isRepealWB 
    then do:
      btn_accRepeal:hidden = false.
      btn_rejRepeal:hidden = false.
    end.
    else do:
      btn_accRepeal:hidden = true.
      btn_rejRepeal:hidden = true.
    end.
  end.
  
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-value-changed Dialog-Frame 
PROCEDURE local-value-changed :
define variable v-str1 as character no-undo.
  define variable v-str2 as character no-undo.
  define variable v-str3 as character no-undo.
  define variable v-str4 as character no-undo.
  define variable v-str5 as character no-undo.
  
  if not bh-ticket-egais:available 
    then return no-apply.
  
  v-str1 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 1, 115).
  v-str2 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 116, 115).
  v-str3 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 231, 115).
  v-str4 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 346, 115).
  v-str5 = substring (bh-ticket-egais:buffer-field ("comment"):buffer-value, 461, 115).
  
  display v-str1 @ fill-in-1 with frame {&frame-name}.
  display v-str2 @ fill-in-3 with frame {&frame-name}.
  display v-str3 @ fill-in-2 with frame {&frame-name}.
  display v-str4 @ fill-in-4 with frame {&frame-name}.
  display v-str5 @ fill-in-5 with frame {&frame-name}.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

