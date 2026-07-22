&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Утилита копирования чеков с имеющейся закрытой продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Утилита копирования чеков с имеющейся закрытой продажи" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ gbl/waitfram.i }


DEFINE buffer for-doc for ub.chk-doc.
DEFINE buffer for-pay for ub.chk-pay.
DEFINE buffer for-gds for ub.chk-gds.
DEFINE buffer for-discnt for ub.chk-discnt.
DEFINE buffer for-attr for ub.chk-doc-attr.
define variable glog as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help my-inkas Fdate ~
RADIO-SET-1 my-chk-doc
&Scoped-Define DISPLAYED-OBJECTS my-inkas Fdate RADIO-SET-1 my-chk-doc

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE Fdate AS DATE FORMAT "99/99/9999":U
     LABEL "с датой"
     VIEW-AS FILL-IN
     SIZE 13.63 BY .92 NO-UNDO.

DEFINE VARIABLE my-chk-doc AS CHARACTER FORMAT "X(256)":U
     LABEL "Копировать чеки с чека  N"
     VIEW-AS FILL-IN
     SIZE 13.88 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE my-inkas AS CHARACTER FORMAT "X(256)":U
     LABEL "Копировать чеки по продаже N"
     VIEW-AS FILL-IN
     SIZE 13.88 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Продажа", "inkas",
"Чек", "chk-doc"
     SIZE 21.63 BY 1.08 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-Help AT ROW 1 COL 54.88
     my-inkas AT ROW 3.17 COL 31.63 COLON-ALIGNED
     Fdate AT ROW 4.88 COL 31.75 COLON-ALIGNED
     RADIO-SET-1 AT ROW 6.17 COL 7.88 NO-LABEL
     my-chk-doc AT ROW 7.42 COL 31.88 COLON-ALIGNED
     SPACE(17.12) SKIP(3.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита копирования чеков с имеющейся закрытой продажи"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Утилита копирования чеков с имеющейся закрытой продажи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
  RADIO-SET-1
  my-inkas
  my-chk-doc
  fdate.
  if fdate = ? then return no-apply.
  CASE radio-set-1:
    when "inkas" then do:

      FIND FIRST ub.inkas No-LOCK WHERE ub.inkas.inkas-code = my-inkas No-ERROR.
  IF not avail ub.inkas then do:
    message "Не найдена продажа с номером " my-inkas.
    return no-apply.
  end.
  message "Вы действительно хотите скопировать все чеки продажи " my-inkas  skip
          "(полученные чеки будут непривязаны ни к одной продаже и" skip
          string(" лягут с датой " + string(fdate, "99/99/99999") + "на текущий магазин) ?") view-as alert-box QUESTION
          buttons YES-NO update glog.

    end.
    when "chk-doc" then do:
      FIND FIRST ub.chk-doc No-LOCK WHERE ub.chk-doc.doc-code = my-chk-doc No-ERROR.
  IF not avail ub.chk-doc then do:
    message "Не найден чек с номером " my-chk-doc.
    return no-apply.
  end.
  message "Вы действительно хотите скопировать чеки " my-chk-doc  skip
          "(полученный чек будет непривязан ни к одной продаже и" skip
          string(" ляжет с датой " + string(fdate, "99/99/99999") + "на текущий магазин) ?") view-as alert-box QUESTION
          buttons YES-NO update glog.

    end.
  end case.
    if glog then do:
      run waitfram-show in this-procedure ("Ждите ..").
for each chk-doc where
(chk-doc.out-code = my-inkas AND radio-set-1 = "inkas") OR
(chk-doc.doc-code = my-chk-doc AND radio-set-1 = "chk-doc")
no-lock:
    create for-doc.
    buffer-copy chk-doc  except doc-code out-code chk-date shift-date src-shift-date to for-doc
    assign for-doc.cashier =  chk-doc.cashier
                for-doc.doc-code =  string(chk-doc.obj-code) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) )
                for-doc.chk-date        =         fdate
                for-doc.shift-date = chk-doc.shift-date + (fdate - chk-doc.chk-date)
                        for-doc.src-shift-date = chk-doc.src-shift-date + (fdate - chk-doc.chk-date)
                .
   for each ub.chk-pay where ub.chk-pay.doc-code = ub.chk-doc.doc-code no-lock:
    create for-pay.
    buffer-copy ub.chk-pay to for-pay
    assign
    for-pay.chk-date  =   for-doc.chk-date
    for-pay.doc-code  = for-doc.doc-code
    for-pay.out-code = ?
    .
  end.
  for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-LOCK:
    create for-gds.
    buffer-copy ub.chk-gds to for-gds
    assign
    for-gds.chk-date  =   for-doc.chk-date
    for-gds.doc-code  =  for-doc.doc-code
    for-gds.out-code = ?
    .

  end.
  for each ub.chk-discnt where ub.chk-discnt.doc-code = ub.chk-doc.doc-code no-LOCK:
    create for-discnt.
    buffer-copy ub.chk-discnt to for-discnt
    assign
    for-discnt.doc-code  = for-doc.doc-code
    for-discnt.chk-date  =   for-doc.chk-date
    for-discnt.out-code = ?
    .

  end.
  for each ub.chk-doc-attr where ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code no-LOCK:
    create for-attr.
    buffer-copy ub.chk-doc-attr to for-attr
    assign
    for-attr.doc-code  = for-doc.doc-code
    for-attr.out-code = ?
    .
  end.

end.

    end.
    run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-curr-obj-type = {&stock} then do:
    message
    "Данную утилиту можно запускать только на объекте типа МАГАЗИН!"
    view-as alert-box ERROR.
    return.
  end.
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
  DISPLAY my-inkas Fdate RADIO-SET-1 my-chk-doc
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help my-inkas Fdate RADIO-SET-1 my-chk-doc
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME