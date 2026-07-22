&Scoped-define WINDOW-NAME    d-notes
&Scoped-define FRAME-NAME     d-notes
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр примечания.

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

Текст примечания передаётся через двойной callback

*/

define input parameter p-call-handle as handle no-undo .
define input parameter p-title as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Просмотр или редактирование примечания" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 14
      FONT 4
     NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-notes
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 11
     ed-notes AT ROW 2 COL 1 NO-LABEL
     SPACE(0) SKIP(0.77)
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

  RUN UI-on in this-procedure .

  /* в режиме просмотра запрещаем редактирование */
  assign
    ed-notes:read-only = true
  .
  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus ed-notes.
END.

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME d-notes.
END PROCEDURE.

PROCEDURE UI-on :
  frame {&frame-name}:title = p-title.
  display
  ed-notes with frame {&frame-name}.
  ENABLE
  b-exit
  b-help
  ed-notes
  WITH FRAME {&frame-name}.
  run request-add-line in p-call-handle ( input this-procedure:handle).
END PROCEDURE.


procedure add-line :
define input parameter p-line as character no-undo .
define variable glog as logical no-undo .

  do
  on error undo, return error
  :
    glog = ed-notes:INSERT-STRING ( p-line ) in frame {&frame-name} .

  end.

end procedure. /* add-line */

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME