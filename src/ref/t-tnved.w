/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр справочника кодов ТНВЭД СНГ

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/19/05

is-full - параметр показывающий только нижний уровень дерева
parrid  - вых. параметр, список выбранных recid'ов.
g-rep   - глобальный recid, здесь используется для репозиции на нужную запись
          как при входе в справочник извне

*/

define input parameter is-full as logical.
define output parameter parrid as recid initial ? no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр справочника кодов ТНВЭД СНГ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/t-tnved.i }
{ cmp/showinf.i }


&scop FRAME-NAME     frame-tnved
&scop OPEN-QUERY-br-tnved OPEN QUERY br-tnved~
   FOR EACH TT-tnved ~
   WHERE NOT is-full OR LENGTH(TRIM(TT-tnved.tnved)) = 10   NO-LOCK.
&scop net-proc ~
if not available TT-tnved then do: ~
  message "Неправильно выбран код ТНВЭД.". ~
  return no-apply. ~
end. ~



/* ***********************  Control Definitions  ********************** */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9 BY 1.

DEFINE QUERY br-tnved FOR TT-tnved SCROLLING.
DEFINE VARIABLE varEmptyString AS CHAR INITIAL "______ " NO-UNDO.
DEFINE VARIABLE loc-tnv AS CHAR FORMAT "X(9)" NO-UNDO.
DEFINE BROWSE br-tnved QUERY br-tnved NO-LOCK DISPLAY
SUBSTRING(varEmptyString, 1, 10 - LENGTH(TT-tnved.tnved)) +
TT-tnved.tnved @ TT-tnved.tnved TT-tnved.f-name FORMAT 'X(255)'
WITH SIZE 96 BY 19 separators.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
b-exit  AT ROW 1 COL 1
b-sel   AT ROW 1 COL 11
b-help  AT ROW 1 COL 21
br-tnved AT ROW 2 COL 1
loc-tnv NO-LABEL AT ROW 21.5 COL 1
WITH KEEP-TAB-ORDER VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE
SIZE 98 BY 23 TITLE "СПРАВОЧНИК ТНВЭД".

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME {&frame-name}:SCROLLABLE       = FALSE.

/* ************************  Control Triggers  ************************ */
{ gbl/hot-key.i b-help }
{ gbl/hot-key.i b-sel }
on choose of b-sel in frame {&frame-name} do:
   {&net-proc}
   parrid = recid (TT-tnved).
   /*g-rep = recid (TT-tnved).*/
end.
on choose of b-exit in frame {&frame-name} do:
   parrid = ?.
end.
ON MOUSE-SELECT-DBLCLICK, return of browse br-tnved DO:
   APPLY "choose" to b-sel in FRAME {&frame-name}.
   RETURN NO-APPLY.
END.
on any-printable of browse br-tnved do:
 find first TT-tnved where TT-tnved.tnved begins (loc-tnv + last-event:label) no-lock no-error.
 if available TT-tnved then do:
    loc-tnv = loc-tnv + last-event:label.
    disp loc-tnv with frame {&frame-name}.
    reposition br-tnved to recid RECID(TT-tnved) no-error.
  end.
end.

on backspace of browse br-tnved do:
    loc-tnv = substr (loc-tnv, 1, length (loc-tnv) - 1).
    find first TT-tnved where TT-tnved.tnved begins loc-tnv no-lock.
    disp loc-tnv with frame {&frame-name}.
    if available TT-tnved then reposition br-tnved to recid RECID(TT-tnved) no-error.
end.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
{ gbl/app_help.i }
run ui-on in this-procedure .
wait-for go of frame {&frame-name} focus br-tnved.
run disable_ui in this-procedure .

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  DISABLE ALL WITH FRAME {&frame-name}.
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
   {&OPEN-QUERY-br-tnved}
   ENABLE ALL WITH FRAME {&frame-name}.
   DISABLE loc-tnv WITH FRAME {&frame-name}.
   /*
    if g-rep <> ? then
        do:
            reposition br-tnved to recid g-rep no-error.
            if error-status:error AND num-results( "br-tnved" ) <> 0 then
                do:
                    g#log = br-tnved:select-row( 1 ) .
                    g#log = br-tnved:scroll-to-selected-row( 1 ) .
                end.
        end.
    */
END PROCEDURE.

&UNDEF FRAME-NAME