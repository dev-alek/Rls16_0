&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Введите параметры заказа

Автор: Чернова Светлана Александровна
Дата создания: 06/27/05
Author: Svetlana Chernova
Creation date: 06/27/05

Дата создания:
*/
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define input  parameter parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input  parameter v-recid         as character no-undo . /* список recid по ub.abc-analysis-goods */
define output parameter v-ord-doc-code  as character no-undo .
{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define buffer buf_clients for ub.clients  .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-help RADIO-ord-type v-obj ~
loc_cli-code r-cli v-date-post v-date-1 v-date-2 loc_cli-type loc_cli-name
&Scoped-Define DISPLAYED-OBJECTS RADIO-ord-type v-obj loc_cli-code ~
v-date-post v-date-1 v-date-2 loc_cli-type loc_cli-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-2 loc_cli-code loc_cli-type

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка".

DEFINE VARIABLE v-obj AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1",
                     "Item 2","Item 2"
     DROP-DOWN-LIST
     SIZE 28.5 BY 1 NO-UNDO.

DEFINE VARIABLE loc_cli-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1.

DEFINE VARIABLE loc_cli-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 40 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE loc_cli-type AS CHARACTER FORMAT "X(3)" INITIAL "орг"
      VIEW-AS TEXT
     SIZE 2.88 BY 1.

DEFINE VARIABLE v-date-1 AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-2 AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-post AS DATE FORMAT "99/99/99":U
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-ord-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "ФП", "1",
"ОП", "2"
     SIZE 20.5 BY 2.25 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-help AT ROW 1 COL 50.5
     RADIO-ord-type AT ROW 3 COL 1.5 NO-LABEL
     v-obj AT ROW 4.25 COL 29.5 COLON-ALIGNED WIDGET-ID 2
     loc_cli-code AT ROW 7 COL 1.5 NO-LABEL
     r-cli AT ROW 7 COL 14.63
     v-date-post AT ROW 8.67 COL 20.5 NO-LABEL
     v-date-1 AT ROW 9.75 COL 20.5 NO-LABEL
     v-date-2 AT ROW 9.75 COL 32.5 NO-LABEL
     loc_cli-type AT ROW 7 COL 9.5 COLON-ALIGNED NO-LABEL
     loc_cli-name AT ROW 7 COL 16 COLON-ALIGNED NO-LABEL
     "Поставщик" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 6.25 COL 1.5
          FGCOLOR 4
     "Тип заказа" VIEW-AS TEXT
          SIZE 19 BY .67 AT ROW 2.25 COL 1.5
          FGCOLOR 4
     "На период продаж" VIEW-AS TEXT
          SIZE 17 BY 1 AT ROW 9.75 COL 1.5
          FGCOLOR 4
     "Дата доставки" VIEW-AS TEXT
          SIZE 14 BY 1 AT ROW 8.67 COL 1.5
          FGCOLOR 4
     SPACE(45.12) SKIP(2.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите параметры заказа".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN loc_cli-code IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN loc_cli-type IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN v-date-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-date-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-date-post IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Введите параметры заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:

  ASSIGN loc_cli-code loc_cli-type RADIO-ord-type v-date-1 v-date-2 v-date-post .
  if  loc_cli-code  = ? or
      loc_cli-type  = ? or
      RADIO-ord-type = ? or
      v-date-1       = ? or
      v-date-2       = ? or
      v-date-post    = ? then do:
      message "Не заданы параметры для создания заказа!  "
      view-as alert-box information .
      return no-apply.
  end.

  if v-date-post <= today then do:
     message "Не верно задана дата доставки! Дата должна быть больше  " + string( today ,"99/99/9999")
     view-as alert-box information .
     return no-apply.
  end.

  if v-date-1 > v-date-2 then do:
     message "Не верно задан интервал! "
     view-as alert-box information .
     return no-apply.
  end.

  if v-date-1 <= today then do:
     message "Не верно задано начало интервала! "
     view-as alert-box information .
     return no-apply.
  end.


  run cus/cr-ordop.p
      (   input parParentProc,
          input RADIO-ord-type,
          input loc_cli-code,
          input loc_cli-type,
          input v-date-post,
          input v-date-1 ,
          input v-date-2 ,
          input v-recid,
          OUTPUT v-ord-doc-code
          ).
  RETURN.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  v-ord-doc-code = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc_cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_cli-code Dialog-Frame
ON LEAVE OF loc_cli-code IN FRAME Dialog-Frame
DO:

assign loc_cli-code loc_cli-type.
def buffer b#clients for ub.clients.
 find first b#clients WHERE
    b#clients.obj-code = loc_cli-code   and
    b#clients.obj-type = loc_cli-type
     no-lock no-error.
 if avail b#clients then do:
    Assign
        loc_cli-code = b#clients.obj-code
        loc_cli-type = b#clients.obj-type
        loc_cli-name = b#clients.obj-name
        .

    Display
      loc_cli-code loc_cli-name loc_cli-type
    with frame {&frame-name} .
    Enable
       loc_cli-code
    with frame {&frame-name} .

end.
else   do:
  apply "CHOOSE" to r-cli IN FRAME Dialog-Frame        .
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc_cli-code Dialog-Frame
ON return OF loc_cli-code IN FRAME Dialog-Frame
DO:
/*  run next-focus in this-procedure  (input  {&SELF-NAME}:handle ) .
  return no-apply .
*/

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame /* r-cli */
DO:
define variable rid-list    as  char no-undo . /* список recid'ов выбранных клиентов */
define variable rep-rec2    as recid no-undo .
define buffer   b#clients for ub.clients.

  run ref/cli-all.w ( parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list).
  assign rep-rec2 = integer(rid-list) no-error.
          find first b#clients where recid(b#clients) = rep-rec2 no-lock no-error.
          if avail b#clients then do:
              Assign
                  loc_cli-code = b#clients.obj-code
                  loc_cli-type = b#clients.obj-type
                  loc_cli-name = b#clients.obj-name .
          end.
    display  loc_cli-code loc_cli-name loc_cli-type
    with frame {&frame-name} .
    enable  loc_cli-code  /* loc_cli-type */
    with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-ord-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-ord-type Dialog-Frame
ON VALUE-CHANGED OF RADIO-ord-type IN FRAME Dialog-Frame
DO:
  assign radio-ord-type.

    if radio-ord-type = {&o-p} then do:
       enable v-obj with frame {&frame-name} .
    end.
    else do:  /* ФП */
        v-obj = v-cntxt-obj-type + string(v-cntxt-obj-code) .
        disable v-obj with frame {&frame-name} .
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

 { gbl/app_help.i }
 { gbl/ed_date.i v-date-post }
 { gbl/ed_date.i v-date-1 }
 { gbl/ed_date.i v-date-2 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  /*RADIO-ord-type:radio-buttons = "{&bef-f-p-full},{&bef-f-p},{&bef-o-p-full},{&bef-o-p}" . */
  RADIO-ord-type:radio-buttons = "{&bef-o-p-full},{&bef-o-p}" .
  find first buf_clients no-lock where
             buf_clients.obj-code = v-cntxt-obj-code and
             buf_clients.obj-type = v-cntxt-obj-type
             no-error .
  if available buf_clients then do:
    v-obj:list-item-pairs  = buf_clients.obj-name  + "," + v-cntxt-obj-type + string(v-cntxt-obj-code) .
  end.

  define buffer buf_abc-analysis-goods for ub.abc-analysis-goods  .
  define buffer buf_abc-analysis-obj   for ub.abc-analysis-obj  .
  find first buf_abc-analysis-goods no-lock where recid (buf_abc-analysis-goods) = integer(entry(1, v-recid )) no-error .
   if error-status :error then do:
      message
        error-status :get-message(1) skip
        return-value skip
        "Не выбран ни один товар"
        view-as alert-box error
      .
   end.

  v-obj = v-cntxt-obj-type + string(v-cntxt-obj-code) .
  for each buf_abc-analysis-obj no-lock where
           buf_abc-analysis-obj.abc-id = buf_abc-analysis-goods.abc-id and
           buf_abc-analysis-obj.db-num = buf_abc-analysis-goods.db-num
           :
          if buf_abc-analysis-obj.obj-code = v-cntxt-obj-code and
             buf_abc-analysis-obj.obj-type = v-cntxt-obj-type then next.

            find first buf_clients no-lock where
                      buf_clients.obj-code = buf_abc-analysis-obj.obj-code and
                      buf_clients.obj-type = buf_abc-analysis-obj.obj-type
                      no-error .

            v-obj:list-item-pairs  = v-obj:list-item-pairs  + "," + buf_clients.obj-name  + "," +  buf_abc-analysis-obj.obj-type + string(buf_abc-analysis-obj.obj-code) .
  end.

  hide v-obj in frame {&frame-name} .
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
  DISPLAY RADIO-ord-type v-obj loc_cli-code v-date-post v-date-1 v-date-2
          loc_cli-type loc_cli-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help RADIO-ord-type v-obj loc_cli-code r-cli
         v-date-post v-date-1 v-date-2 loc_cli-type loc_cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME