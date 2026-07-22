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

Интервалы сумм

Автор: Чернова Светлана Александровна
Дата создания: 12/02/05
Author: Svetlana Chernova
Creation date: 12/02/05

*/

{ ref/t-l-b.i }
define input  parameter p-mode as character no-undo .
/*может быть 'sums'' только запрос сумм
'calc' только подсчет
'sums-calc' запрос и подсчет */
define input-output parameter p-sum-1 as decimal   no-undo .
define input-output parameter p-sum-2 as decimal   no-undo .
define output parameter table for temp-list-buyer .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Интервалы сумм ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/calctur2.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help v-sum-1 v-sum-2
&Scoped-Define DISPLAYED-OBJECTS v-sum-1 v-sum-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-sum-1 AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "C"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-sum-2 AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "ПО"
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 43.5
     v-sum-1 AT ROW 3.75 COL 12.5 COLON-ALIGNED
     v-sum-2 AT ROW 5 COL 12.5 COLON-ALIGNED
     SPACE(13.74) SKIP(1.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Интервалы сумм"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Интервалы сумм */
DO:
  RUN save-proc no-error .
  if error-status :error then do:
      message
        return-value
        view-as alert-box error
      .
      return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Интервалы сумм */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Cancel Dialog-Frame
ON CHOOSE OF B-Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  p-sum-2 = ? .
  p-sum-1 = ? .
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
  if lookup(p-mode, ('sums' + {&comma-char} +
                    'calc' + {&comma-char} +
                    'sums-calc')) = 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверынй параметр вызова p-mode" p-mode
    view-as alert-box error .
    return error .
  end.
  for each  temp-list-buyer:
     delete temp-list-buyer.
  end.
  if p-mode = 'sums'
  or p-mode = 'sums-calc' then do:
    RUN enable_UI.
    if p-mode = 'sums-calc'   then do:
       RUN proc-calc IN THIS-PROCEDURE NO-ERROR.
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS v-sum-1.
  end.
  if p-mode = 'calc' then do:
    RUN proc-calc IN THIS-PROCEDURE NO-ERROR.
  end.
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
  DISPLAY v-sum-1 v-sum-2
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-Help v-sum-1 v-sum-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-calc Dialog-Frame
PROCEDURE proc-calc :
define variable p-itogo-sum-doc-rubl  as decimal   no-undo . /* суммарный оборот в р у б */
define variable p-itogo-sum-doc-base  as decimal   no-undo . /* суммарный оборот в баз вал */
define variable p-itogo-sum-rash-base as decimal   no-undo . /* суммарный расходный оборот в баз вал */
define variable p-itogo-sum-rash      as decimal   no-undo . /* суммарный расходный оборот в р у б */
define variable p-itogo-sum-vozv-base as decimal   no-undo . /* суммарный возвратный оборот в баз вал */
define variable p-itogo-sum-vozv      as decimal   no-undo . /* суммарный возвратный оборот в р у б */
define variable p-itogo-qnty-doc      as decimal   no-undo . /* всего документов */
define variable p-itogo-qnty-check    as decimal   no-undo . /* всего чеков */

empty temp-table temp-list-buyer.
for each  clients no-lock where clients.turnover-buyer = true :
      run pricing_calc-itogo-buyer (
            input  clients.obj-type            ,
            input  clients.obj-code            ,
            output p-itogo-sum-doc-rubl  ,
            output p-itogo-sum-doc-base  ,
            output p-itogo-sum-rash-base ,
            output p-itogo-sum-rash      ,
            output p-itogo-sum-vozv-base ,
            output p-itogo-sum-vozv      ,
            output p-itogo-qnty-doc      ,
            output p-itogo-qnty-check    ).

      if p-itogo-sum-doc-rubl >= p-sum-1 and p-itogo-sum-doc-rubl <= p-sum-2 and p-sum-2 <> ? then do:
          create temp-list-buyer.
          assign
          temp-list-buyer.obj-type =  clients.obj-type
          temp-list-buyer.obj-code =  clients.obj-code
          .
      end.
      if p-itogo-sum-doc-rubl >= p-sum-1  and p-sum-2 = ? then do:
          create temp-list-buyer.
          assign
          temp-list-buyer.obj-type =  clients.obj-type
          temp-list-buyer.obj-code =  clients.obj-code
          .
      end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
ASSIGN FRAME {&FRAME-NAME}
    v-sum-1
    v-sum-2
    .

if v-sum-2 <> ? then do:
   if  v-sum-2 < v-sum-1 then do:
   return error "Не верно введен интервал сумм!" .
   end.
end.

p-sum-1 =   v-sum-1 .
p-sum-2 =   v-sum-2 .

RUN proc-calc IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME