&Scoped-define WINDOW-NAME    d-notes
&Scoped-define FRAME-NAME     d-notes
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр или редактирование примечания.

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

Текст примечания передаётся через input parameter notes

*/

define input parameter mode as character no-undo.
define input-output parameter notes as character no-undo .

def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Просмотр или редактирование примечания" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 8.75 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 8.75 BY 1.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 63.5 BY 6.5
      FONT 4
     NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-notes
     b-exit AT ROW 1.5 COL 3
     b-help AT ROW 1.5 COL 16
     ed-notes AT ROW 3 COL 3 NO-LABEL
     SPACE(2.13) SKIP(0.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE "ПРИМЕЧАНИЕ"
         default-button b-exit.




/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
       FRAME d-notes:SCROLLABLE       = FALSE.

/* ************************  Control Triggers  ************************ */
on return of ed-notes apply "go" to frame {&frame-name}.

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  assign
    ed-notes = notes
  .

  RUN UI-on.

  if mode = {&lookup} then do:
    /* в режиме просмотра запрещаем редактирование */
    assign
      ed-notes:read-only = true
    .
  end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus ed-notes.
  if mode <> {&lookup} then do:
    assign
      notes = input frame {&frame-name} ed-notes
    .
  end.
END.

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME d-notes.
END PROCEDURE.

PROCEDURE UI-on :
  disp ed-notes with frame {&frame-name}.
  ENABLE b-exit b-help ed-notes WITH FRAME d-notes.
END PROCEDURE.

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME