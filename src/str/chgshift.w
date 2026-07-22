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

Запрос на изменение списка чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/24/06
Author: Bakhtadze Natalya
Creation date: 01/24/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define output parameter p-shift-date like ub.chk-doc.shift-date no-undo.
define output parameter p-shift-num like ub.chk-doc.shift-num no-undo.
define output parameter p-shift-name as character no-undo .
define output parameter p-shift-place-from as int no-undo.
define output parameter p-shift-place-to as int no-undo.
define output parameter p-change-fields as character no-undo.
define output parameter p-can-back-shift as logical no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Запрос на изменение даты и или номера смены" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
define variable v-host-code as integer no-undo .
define variable glog as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help l-shift-num l-shift-reservoir ~
l-shift-date l-shift-name n-shift-date n-shift-name n-shift-num n-shift-reservoir
&Scoped-Define DISPLAYED-OBJECTS shift-date shift-name-i shift-num shift-reservoir ~
n-shift-date n-shift-name n-shift-num n-shift-reservoir 

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
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE n-shift-date AS CHARACTER FORMAT "X(256)":U INITIAL "Дата смены (учета):"
      VIEW-AS TEXT
     SIZE 20 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-shift-name AS CHARACTER FORMAT "X(256)":U INITIAL "№ смены"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-shift-num AS CHARACTER FORMAT "X(256)":U INITIAL "Порядок смены"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-shift-reservoir AS CHARACTER FORMAT "X(9)" INITIAL "Резервуар"
      VIEW-AS TEXT
     SIZE 14.4 BY 1
     FGCOLOR 15 NO-UNDO.
     
DEFINE VARIABLE n-shift-reservoir-from AS CHARACTER FORMAT "X(7)" INITIAL "Сменить"
    VIEW-AS TEXT
    SIZE 9 BY 1
    NO-UNDO.
    
DEFINE VARIABLE n-shift-reservoir-to AS CHARACTER FORMAT "X(2)" INITIAL "На"
    VIEW-AS TEXT
    SIZE 9 BY 1
    NO-UNDO.

DEFINE VARIABLE shift-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 12.8 BY 1 NO-UNDO.

DEFINE VARIABLE shift-name AS CHARACTER FORMAT "X(2)":U INITIAL "0"
     VIEW-AS FILL-IN
     SIZE 3.4 BY 1 NO-UNDO.

DEFINE VARIABLE shift-name-i AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.4 BY 1 NO-UNDO.

DEFINE VARIABLE shift-num AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.4 BY 1 NO-UNDO.
     
DEFINE VARIABLE shift-reservoir-from AS CHARACTER FORMAT "X(8)" INITIAL ""
     VIEW-AS COMBO-BOX
     INNER-LINES 5
     LIST-ITEM-PAIRS "def", "1"
     DROP-DOWN-LIST
     SIZE 18 BY 1 NO-UNDO.
     
DEFINE VARIABLE shift-reservoir-to AS CHARACTER FORMAT "X(8)" INITIAL ""
     VIEW-AS COMBO-BOX
     INNER-LINES 5
     LIST-ITEM-PAIRS "def", "1"
     DROP-DOWN-LIST
     SIZE 18 BY 1 NO-UNDO.

DEFINE IMAGE l-shift-date
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-shift-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-shift-num
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.
     
DEFINE IMAGE l-shift-reservoir
    FILENAME "adeicon\lock":U
    SIZE 2.9 BY .93.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 45
     shift-date AT ROW 2.5 COL 27.5 COLON-ALIGNED NO-LABEL
     shift-name AT ROW 3.93 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-name-i AT ROW 3.93 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-num AT ROW 5.93 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-reservoir-from AT ROW 8.07 COL 27.8 COLON-ALIGNED NO-LABEL
     shift-reservoir-to AT ROW 9.07 COL 27.8 COLON-ALIGNED NO-LABEL
     n-shift-date AT ROW 2.53 COL 6.1 NO-LABEL
     n-shift-name AT ROW 4.07 COL 3.6 COLON-ALIGNED NO-LABEL
     n-shift-num AT ROW 6.07 COL 3.6 COLON-ALIGNED NO-LABEL
     n-shift-reservoir AT ROW 8.07 COL 3.6 COLON-ALIGNED NO-LABEL
     n-shift-reservoir-from AT ROW 8.07 COL 18 COLON-ALIGNED NO-LABEL
     n-shift-reservoir-to AT ROW 9.07 COL 18 COLON-ALIGNED NO-LABEL
     l-shift-num AT ROW 6 COL 2.6
     l-shift-date AT ROW 2.53 COL 2.6
     l-shift-name AT ROW 4 COL 2.6
     l-shift-reservoir AT ROW 8 COL 2.6
     SPACE(42.62) SKIP(2.60)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение списка чеков"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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

/* SETTINGS FOR FILL-IN n-shift-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN shift-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN shift-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       shift-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN shift-name-i IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN shift-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение даты и/или номера смены чека */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  assign
  p-shift-date = ?
  p-shift-num = 0
  p-shift-name = ''
  p-change-fields = "":U
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-shift-date Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-shift-date IN FRAME Dialog-Frame
DO:
   IF l-shift-date:visible then do:
    assign
    n-shift-date:fgcolor = ?
    l-shift-date:visible = false.
    enable shift-date with frame {&frame-name}.
    APPLY "ENTRY" TO shift-date.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-shift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-shift-name Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-shift-name IN FRAME Dialog-Frame
DO:
   IF l-shift-name:visible then do:
    assign
    n-shift-name:fgcolor = ?
    l-shift-name:visible = false.
    enable
    shift-name-i
    with frame {&frame-name}.
    APPLY "ENTRY" TO shift-name-i.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME l-shift-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-shift-num Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-shift-num IN FRAME Dialog-Frame
DO:
   IF l-shift-num:visible then do:
    assign
    n-shift-num:fgcolor = ?
    l-shift-num:visible = false.
    enable
    shift-num
    with frame {&frame-name}.
    APPLY "ENTRY" TO shift-num.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME l-shift-reservoir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-shift-reservoir Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-shift-reservoir IN FRAME Dialog-Frame
DO:
   IF l-shift-reservoir:visible then do:
    assign
    n-shift-reservoir:fgcolor = ?
    l-shift-reservoir:visible = false.
    enable
    shift-reservoir-from shift-reservoir-to
    with frame {&frame-name}.
    disp n-shift-reservoir-from n-shift-reservoir-to
    with frame {&frame-name}.
    APPLY "ENTRY" TO shift-reservoir-from.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-date Dialog-Frame
ON RIGHT-MOUSE-CLICK OF shift-date IN FRAME Dialog-Frame
DO:
    assign
    n-shift-date:fgcolor = 15
    shift-date = ?
    l-shift-date:visible = true.
    display shift-date with frame {&frame-name}.
    disable shift-date with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME shift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-name Dialog-Frame
ON RIGHT-MOUSE-CLICK OF shift-name IN FRAME Dialog-Frame
DO:

    assign
    n-shift-name:fgcolor = 15
    shift-name = ?
    l-shift-name:visible = true.
    display shift-name with frame {&frame-name}.
    disable shift-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME shift-name-i
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-name-i Dialog-Frame
ON RIGHT-MOUSE-CLICK OF shift-name-i IN FRAME Dialog-Frame
DO:

    assign
    n-shift-name:fgcolor = 15
    shift-name-i = ?
    l-shift-name:visible = true.
    display shift-name-i with frame {&frame-name}.
    disable shift-name-i with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME shift-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-num Dialog-Frame
ON RIGHT-MOUSE-CLICK OF shift-num IN FRAME Dialog-Frame
DO:

    assign
    n-shift-num:fgcolor = 15
    shift-num = ?
    l-shift-num:visible = true.
    display shift-num with frame {&frame-name}.
    disable shift-num with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME shift-reservoir-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-reservoir-from Dialog-Frame
ON RIGHT-MOUSE-CLICK OF shift-reservoir-from IN FRAME Dialog-Frame
DO:    
    assign
    n-shift-reservoir:fgcolor = 15
    shift-reservoir-from = ""
    shift-reservoir-to = ""
    l-shift-reservoir:visible = true
    n-shift-reservoir-from:VISIBLE = false
    n-shift-reservoir-to:VISIBLE = false.
    display shift-reservoir-from shift-reservoir-to with frame {&frame-name}.
    disable shift-reservoir-from shift-reservoir-to with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME shift-reservoir-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL shift-reservoir-to Dialog-Frame
ON RIGHT-MOUSE-CLICK OF shift-reservoir-to IN FRAME Dialog-Frame
DO:    
    apply "RIGHT-MOUSE-CLICK" to shift-reservoir-from.
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
{ gbl/ed_date.i shift-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN enable_UI.
  RUN fill-lists (p-curr-obj-type, p-curr-obj-code) .
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
  DISPLAY shift-date shift-name-i shift-num shift-reservoir-from shift-reservoir-to
          n-shift-date n-shift-name n-shift-num n-shift-reservoir
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help l-shift-num l-shift-date l-shift-name l-shift-reservoir
         n-shift-date n-shift-name n-shift-num n-shift-reservoir n-shift-reservoir-from
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

function get-res-num returns char(res-id as int):
    def buffer buf_place for ub.place.

    find first buf_place no-lock
        where buf_place.pl-code = res-id
        no-error.
    if avail buf_place then
        return buf_place.loc1.
    else
        return "".
end.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-message as character no-undo.
define variable loc#log as logical no-undo.
define variable varshift-date as date no-undo .
define variable varshift-num as integer no-undo .
define variable varshift-name as character no-undo.
define variable l-shift-on as logical no-undo .
define variable v-value as character no-undo .
assign
frame {&frame-name}
shift-date
shift-num
shift-name-i
shift-reservoir-from
shift-reservoir-to
.
if shift-num > {&max-shift-num} then do:
  message
  "Порядок смены не может быть больше" {&max-shift-num}
  view-as alert-box error.
  return error.
end.
if shift-name-i > 99 then do:
  message
  "Номер смены не может быть больше" 99
  view-as alert-box error.
  return error.
end.
/*надо проверить что дата тек. смены = shift-date и номер смены*/

{ gbl/objat.i
  p-curr-obj-type
  p-curr-obj-code
  "'shift-on=request'"
  l-shift-on
}
if l-shift-on then do:
  /* на объекте включены смены */
  { gbl/curshift.i
    p-curr-obj-type
    p-curr-obj-code
    varshift-date
    varshift-num
    varshift-name
    no-error
  }
  if error-status:error
  or not (varshift-date = shift-date
         and shift-date:sensitive)
  or not (varshift-num = shift-num
          and shift-num:sensitive) then do:
    { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_receipts_change-back-shift':U
      {&cntxt-object}
      v-host-code
      p-curr-obj-type
      p-curr-obj-code
      0
      0
      0
      true
      glog
    }
    
    if not glog then do:
      undo, return error .
    end.

    p-can-back-shift = yes.
  end.
end. /*if l-shift-on then do:*/

assign
p-change-fields = '':U
p-change-fields = IF shift-date:SENSITIVE
                                  then (p-change-fields + {&comma-char} + "shift-date":U)
                                  else p-change-fields
p-change-fields = IF shift-num:SENSITIVE then
                                   (p-change-fields + {&comma-char} + "shift-num":U)
                                   else p-change-fields
p-change-fields = IF shift-name-i:SENSITIVE
                THEN (p-change-fields + {&comma-char} + "shift-name":U)
                else p-change-fields
p-change-fields = if shift-reservoir-from:SENSITIVE
                then (p-change-fields + {&comma-char} + "shift-reservoir-from")
                else p-change-fields
p-change-fields = if shift-reservoir-to:SENSITIVE
                then (p-change-fields + {&comma-char} + "shift-reservoir-to")
                else p-change-fields                
p-shift-date = IF shift-date:SENSITIVE then shift-date else ?
p-shift-num = if shift-num:SENSITIVE then shift-num else 0
p-shift-name = if shift-name-i:SENSITIVE then string(shift-name-i) else ''
p-shift-place-to = if shift-reservoir-to:SENSITIVE then int(shift-reservoir-to) else 0
p-shift-place-from = if shift-reservoir-from:SENSITIVE then int(shift-reservoir-from) else 0
v-message = substitute("ДАТА СМЕНЫ (УЧЕТА)=&1 НОМЕР СМЕНЫ=&2 ПОРЯДОК СМЕНЫ=&3 &4"
                     , (IF shift-date:SENSITIVE
                       then string(shift-date, "99/99/9999")
                       else "")
                     , (IF shift-name-i:SENSITIVE
                       then string(shift-name-i, ">9")
                       else "":U)
                  , (IF shift-num:SENSITIVE
                    then string(shift-num, ">9")
                    else "":U)
                  , ( if shift-reservoir-to:SENSITIVE
                    then "Резеруар (изменить=" + get-res-num(int(shift-reservoir-from)) + " на=" + get-res-num(int(shift-reservoir-to)) + ")"
                    else ""
                    ))
.
message
"Для списка чеков будут проведены следующие изменения" skip
v-message skip(2)
"При проведении изменения будет проводиться проверка на корректность изменений для каждого конкретного чека" skip
"Если изменения нарушают логику чека, то чек изменен не будет" skip(2)
(if  p-can-back-shift = no
 then substitute("ВНИМАНИЕ!!!!&1"  +
                "если сменный режим включен не только на кассах, но и в бэк-офисе,&1" +
                "изменения даты/номера смены можно произвести ТОЛЬКО ПРИ ОТКРЫТОЙ СМЕНЕ&1"  +
                "и дата/номер смены или резервуара чека после изменения должны СОВПАДАТЬ с датой/номером смены в бэк-офисе&1"  +
                "ТАКОЙ ЧЕК ПОПАДЕТ В ОТЧЕТ О ПРОДАЖЕ ТЕКУЩЕЙ СМЕНЫ!&1&1"
                , {&new-line})
else '':U)
"Провести изменения даты/смены или резервуара чеков?"
view-as alert-box question buttons YES-NO update loc#log.
if not loc#log  then return error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-lists Dialog-Frame
procedure fill-lists:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable v-pl-name as character no-undo .
define variable v-pl-code as character no-undo .
define buffer buf_place for ub.place .

    do with frame {&frame-name}:
        shift-reservoir-from:DELETE (1).
        shift-reservoir-to  :DELETE (1).
        
        for each buf_place no-lock
           where buf_place.obj-type = p-obj-type
             and buf_place.obj-code = p-obj-code:
          /* по задаче 4450 (задача отдела сопровождения ПСИ Смоленск от 24/VI-2018 :
               такая избыточная проверка значений нужна, т.к. в Смоленске выдаёт ошибку
               на вызове ADD-LAST(): в БД Смоленска запятая в наименовании резервуара */
          assign
            v-pl-name = substitute(  "&1 &2",  buf_place.loc1,  replace(buf_place.pl-name, ",", " ")  )
            v-pl-code = substitute(  "&1",     buf_place.pl-code)
          .
          if trim(v-pl-name) = "" then v-pl-name = substitute("&1", buf_place.pl-name) .
          if trim(v-pl-name) = "" then v-pl-name = "N Топливо" .
          if trim(v-pl-code) = "" then v-pl-code = "0" .
          shift-reservoir-from:ADD-LAST(v-pl-name, v-pl-code).
          shift-reservoir-to  :ADD-LAST(v-pl-name, v-pl-code).
        end.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
