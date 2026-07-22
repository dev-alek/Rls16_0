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

Задания значений смен для поиска

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/14/06
Author: Bakhtadze Natalya
Creation date: 01/14/06

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define  input parameter parParentProc as widget-handle no-undo.
define  input parameter spr           as character     no-undo.
define  input parameter znak          as character     no-undo.
define  input parameter lab_user      as character     no-undo.
define  input parameter fld           as character     no-undo.
define  input parameter lab           as character     no-undo.
define  input parameter type          as character     no-undo.
define output parameter str           as character     no-undo.
define output parameter str_rus       as character     no-undo.


/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Задания значений смен для поиска".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-shar.i }
{ gbl/getcntxt.i def }


define variable join-tbl      as character no-undo .
define variable join_rus      as character no-undo .
define variable vh as handle no-undo .
define variable fh as handle no-undo .
define variable next-fill-in  as logical   no-undo initial no .
define variable name          as character no-undo .
define variable ss            as character no-undo .
define variable s_description as character no-undo .
define variable aa            as character no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable p-mandatory AS logical no-undo .
define variable v-confirm AS logical no-undo .

define buffer buf_shift-obj for ub.shift-obj.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-obj-type f-obj-code ~
f-shift-date f-shift-name f-shift-num B-sht
&Scoped-Define DISPLAYED-OBJECTS f-obj-type f-obj-code f-shift-date ~
f-shift-name f-shift-num

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

DEFINE BUTTON B-sht
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY .88.

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-obj-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-shift-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата смены"
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-shift-name AS CHARACTER FORMAT "X(3)":U
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-shift-num AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Пор. смены"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-obj-type AT ROW 3 COL 13.5 COLON-ALIGNED
     f-obj-code AT ROW 3 COL 20.5 COLON-ALIGNED NO-LABEL
     f-shift-date AT ROW 5 COL 13 COLON-ALIGNED
     f-shift-name AT ROW 5 COL 35 COLON-ALIGNED
     f-shift-num AT ROW 5 COL 51.5 COLON-ALIGNED
     B-sht AT ROW 5 COL 59.5
     SPACE(4.62) SKIP(1.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор смены"
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор смены */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Сохранить */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sht
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sht Dialog-Frame
ON CHOOSE OF B-sht IN FRAME Dialog-Frame /* Btn 1 */
DO:
  v-confirm = NO.
  run proc-sht IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-date Dialog-Frame
ON LEAVE OF f-shift-date IN FRAME Dialog-Frame /* Дата смены */
DO:
    if input frame {&frame-name} f-shift-date <> f-shift-date then do:
    assign
      f-shift-name   = ""
      f-shift-num = 0
      v-confirm = NO.
    display
    f-shift-name
    f-shift-num with frame {&frame-name}.
    apply "entry" to f-shift-name in frame {&frame-name}.
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-date Dialog-Frame
ON RETURN OF f-shift-date IN FRAME Dialog-Frame /* Дата смены */
DO:
  apply "entry" to f-shift-name in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-shift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-name Dialog-Frame
ON LEAVE OF f-shift-name IN FRAME Dialog-Frame /* № смены */
DO:
  IF INPUT FRAME {&frame-name} f-shift-name <> f-shift-name THEN DO:
      v-confirm = NO.
  END.
  run proc-shift-name in this-procedure no-error .
  if error-status:error then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-name Dialog-Frame
ON RETURN OF f-shift-name IN FRAME Dialog-Frame /* № смены */
DO:
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-shift-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-num Dialog-Frame
ON LEAVE OF f-shift-num IN FRAME Dialog-Frame /* Пор. смены */
DO:
    IF INPUT FRAME {&frame-name} f-shift-num <> f-shift-num THEN DO:
        v-confirm = NO.
    END.
  run proc-shift-num IN this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-shift-num Dialog-Frame
ON RETURN OF f-shift-num IN FRAME Dialog-Frame /* Пор. смены */
DO:
    apply "entry" to b-exit in frame {&frame-name}.
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
{ gbl/app_help.i }

{ gbl/hot-key.i  b-Help }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN proc-start IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN ERROR.
  RUN Myenable.
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
  DISPLAY f-obj-type f-obj-code f-shift-date f-shift-name f-shift-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-obj-type f-obj-code f-shift-date f-shift-name
         f-shift-num B-sht
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (IF p-obj-code <> 0
                                                         THEN (p-obj-type + STRING(p-obj-code))
                                                         ELSE '':U)
.
DISPLAY
f-obj-type
f-obj-code
f-shift-date
f-shift-name
f-shift-num
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
f-shift-date WHEN (p-obj-code <> 0)
f-shift-name WHEN (p-obj-code <> 0)
f-shift-num WHEN (p-obj-code <> 0)
B-sht WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
IF f-shift-date:SENSITIVE THEN DO:
    APPLY "ENTRY" TO f-shift-date.
END.
ELSE DO:
   APPLY "ENTRY" TO b-sht.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
if input frame {&frame-name} f-shift-date = ? then do:
  MESSAGE
  "Вы не ввели дату смены"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.

IF NOT p-mandatory
AND v-confirm THEN DO:
END.
ELSE DO:
    IF INPUT FRAME {&frame-name} f-shift-num = 0  THEN
    RUN proc-shift-name IN THIS-PROCEDURE NO-ERROR.
    ELSE
    RUN proc-shift-num IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
END.

if znak = "=" then do:
 assign
   join-tbl = " AND "
   join_rus = " И "
 .
end.
else do:
 assign
   join-tbl = " OR "
   join_rus = " ИЛИ "
 .
end.
assign
 vh = frame {&frame-name} :first-child
.
do while ( vh <> ? ):
  assign fh = vh :first-child.
  _DO:
  do while ( fh <> ? ) :
    if fh :type = 'fill-in'
    then do:
      if p-obj-code > 0 and
      (fh:name = "f-obj-type"
      or
      fh:name = "f-obj-code") then do:
        assign
          fh = fh :next-sibling
        .
        next _do.
      end.
      if next-fill-in then do:
        assign
          str     = str     + (if fh:name <> 'f-shift-name' then join-tbl else '')
          str_rus = str_rus + (if fh:name <> 'f-shift-num' then join_rus else '')
        .
      end.
      assign
        next-fill-in = yes
      .
      assign
      ss            = fh :screen-value
      s_description = fh :screen-value
      aa            = ( if fh :data-type = "character" then '"' else '' )
      .
      if fh :data-type = "date"
      then do:
        define variable v-date as date      no-undo .
        assign
          v-date = date(fh :screen-value)
        .
        if v-date = ?
        then do:
          assign
            ss             = {&question-mark}
            s_description = "НЕ_ЗАДАНА"
          .
        end.
        else do:
          assign
           ss             = 'date(':u + string(month(v-date))
                          + '~~054':u + string(day(v-date))
                          + '~~054':u + string(year(v-date))
                          + ')':u
            s_description = string(v-date, "99/99/9999")
          .
        end.
      end.
      if fh :data-type = "character"
      then do:
        run replace-special-char in this-procedure
          (input  ss
          ,output ss
          ) .
        assign
          s_description = replace(s_description, ',', '~~054')
        .
      end.
      if fh:name = 'f-shift-name' then do:

        assign
          str     = str
          str_rus = str_rus + entry( 2, fh :private-data ) + " " + znak + " " +
                    substitute("&1(&2)"
                               ,f-shift-name:screen-value
                               ,f-shift-num:screen-value).
        .
      END.
      ELSE DO:
        assign
          str     = str     + entry( 1, fh :private-data ) + " " + znak + " " + aa + ss            + aa
          str_rus = str_rus + (if fh:name <> 'f-shift-num'
                               then  (entry( 2, fh :private-data ) + " " + znak + " " + aa + s_description + aa)
                               else '')
        .
      END.
    end.
    assign
      fh = fh :next-sibling
    .
  end.
  assign
    vh = vh :next-sibling
  .
end.
assign
 str     = "(" + str     + ")"
 str_rus = "(" + str_rus + ")"
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-name Dialog-Frame
PROCEDURE proc-shift-name :
define buffer buf_shift-obj   for ub.shift-obj.
define variable v-find-shift as integer initial 0.
define variable v-shift-date like ub.shift-obj.shift-date no-undo.
define variable v-shift-num  like ub.shift-obj.shift-num  no-undo.
define variable glog as logical no-undo .

if input frame {&frame-name} f-shift-date <> ? then do:

for each  buf_shift-obj no-lock  where
         buf_shift-obj.obj-type   = f-obj-type
    AND  buf_shift-obj.obj-code   = f-obj-code
    AND  buf_shift-obj.shift-date = input frame {&frame-name} f-shift-date
    AND  buf_shift-obj.shift-name = input frame {&frame-name} f-shift-name
    on error undo, return error return-value :
  assign
    v-find-shift = v-find-shift + 1
    v-shift-date = buf_shift-obj.shift-date
    v-shift-num  = buf_shift-obj.shift-num.
end.

if v-find-shift = 0
or v-find-shift > 1 then do:
  if v-find-shift = 0 then do:
    message substitute("Не найдена смена: &1&2&3" +
                       "Дата &4 Номер смены &5."
                       ,p-obj-type
                       ,p-obj-code
                       ,{&NEW-LINE}
                       ,input frame {&frame-name} f-shift-date
                       ,input frame {&frame-name} f-shift-name)
    view-as alert-box error.
  end.
  else do:
    message
    SUBSTITUTE("Найдено более одной смены с одним номером в сменном дне.&1" +
              "Объект: &2&3 Дата &4 Номер смены &5."
              ,{&NEW-LINE}
              ,p-obj-type
              ,p-obj-code
              ,input frame {&frame-name} f-shift-date
              ,input frame {&frame-name} f-shift-name)
    view-as alert-box error.
  end.
  if not p-mandatory
  and v-find-shift = 0
  then do:
    message
    "Хотите задать значения даты смены/№ смены, не соответвующие ни одной из имеющихся в БД смен?"
    view-as alert-box question buttons YES-NO update glog.
    if glog then do:
      assign frame {&frame-name}
      f-shift-name.
      v-confirm = YES.
      return.
    end.
  end.
  display
  f-shift-name
  with frame {&frame-name}.
  run proc-sht IN THIS-PROCEDURE no-error.
  if error-status:error then do:
    return error.
  end.
end.
else do:
  assign frame {&frame-name}
  f-shift-name.
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-shift-num Dialog-Frame
PROCEDURE proc-shift-num :
define variable glog as logical no-undo .
define buffer buf_shift-obj   for ub.shift-obj.

if input frame {&frame-name} f-shift-date <> ? then do:
find first buf_shift-obj where
           buf_shift-obj.obj-type   = f-obj-type
       and buf_shift-obj.obj-code   = f-obj-code
       AND buf_shift-obj.shift-date = input frame {&frame-name} f-shift-date
       and buf_shift-obj.shift-num  = input frame {&frame-name} f-shift-num  no-lock no-error.
if not available buf_shift-obj then do:
  message substitute("Не найдена смена: &1&2&3"  +
                     "Дата &4 Порядок смены &5."
                     ,p-obj-type
                     ,p-obj-code
                     , {&NEW-LINE}
                     ,input frame {&frame-name} f-shift-date
                     ,input frame {&frame-name} f-shift-num)
  view-as alert-box error.
  if not p-mandatory then do:
    message
    "Хотите задать значения даты смены/№ смены, не соответвующие ни одной из имеющихся в БД смен?"
    view-as alert-box question buttons YES-NO update glog.
    if glog then do:
      assign frame {&frame-name}
      f-shift-num
      v-confirm = YES
      .
      return.
    end.
  end.
  display
  f-shift-num
  with frame {&frame-name}.
  run proc-sht IN this-procedure no-error.
  if error-status:error then do:
    return error.
  end.
end.
else do:
  assign
  f-shift-date = buf_shift-obj.shift-date
  f-shift-num  = buf_shift-obj.shift-num
  f-shift-name = buf_shift-obj.shift-name.
  display
  f-shift-date
  f-shift-num
  f-shift-name
  with frame {&frame-name}.
end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sht Dialog-Frame
PROCEDURE proc-sht :
define buffer buf_shift-obj   for ub.shift-obj.
define variable v-rid-list as character no-undo.
define variable v-recid    as recid     no-undo.
assign
v-rid-list = "".
run str/sht-all.w (input parparentproc
             , INPUT v-cntxt-obj-type /*p-curr-obj-type*/
             , input v-cntxt-obj-code /*p-curr-obj-code*/
             , input 'b-sel'
             , input (if p-obj-code > 0 then 'obj' else 'all')
             , INPUT (if p-obj-type <> '':U then p-obj-type else v-cntxt-obj-type) /*p-obj-type*/
             , input (if p-obj-code <> 0 then p-obj-code else v-cntxt-obj-code) /*p-obj-code*/
             , input '':u
             , input-output v-rid-list) no-error.
if error-status:error
or v-rid-list = "":u then do:
  return error.
end.
else do:
  assign
  v-recid = integer (entry(1, v-rid-list)).
  find first buf_shift-obj NO-LOCK where
           recid(buf_shift-obj) = v-recid no-error.
  assign
  f-obj-type   = buf_shift-obj.obj-type
  f-obj-code   = buf_shift-obj.obj-code
  f-shift-date = buf_shift-obj.shift-date
  f-shift-num  = buf_shift-obj.shift-num
  f-shift-name    = buf_shift-obj.shift-name.
  display
  f-obj-type
  f-obj-code
  f-shift-date
  f-shift-num
  f-shift-name
  with frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-start Dialog-Frame
PROCEDURE proc-start :
define variable vdopstr as character no-undo .
define variable v-param-list as character no-undo .
define variable ii as integer no-undo .
if num-entries(spr, {&delim-par}) > 1 then do:
assign
vdopstr = spr
spr = entry(1, vdopstr, {&delim-par} )
.
entry(1, vdopstr, {&delim-par} ) = ''.
v-param-list = substring(vdopstr, 2).
end.
IF v-param-list <> '':U THEN DO:
    ASSIGN
    p-obj-type = ENTRY(1, v-param-list, {&delim-par})
    p-obj-code = integer(ENTRY(2, v-param-list, {&delim-par}))
    p-mandatory = LOGICAL(ENTRY(3, v-param-list, {&delim-par}))
    NO-ERROR
    .
    IF ERROR-STATUS:ERROR  THEN DO:
        UNDO, RETURN ERROR.
    END.
  ASSIGN
  f-obj-type = p-obj-type
  f-obj-code = p-obj-code
  .
END.
ASSIGN
f-shift-name:PRIVATE-DATA IN FRAME {&FRAME-NAME} = ",Номер смены".
do ii = 1 to num-entries(fld, '{&delim-flt}'):
  if entry(2, entry(ii, fld, '{&delim-flt}'), '.') = "shift-date" then do:
    assign
    f-shift-date:private-data IN FRAME {&frame-name} = entry(ii, fld, '{&delim-flt}') + {&comma-char} +
                                                       replace(entry(ii, lab, '{&delim-flt}'), "&", '').
  end.
  if entry(2, entry(ii, fld, '{&delim-flt}'), '.') = "shift-num" then do:
    assign
    f-shift-num:private-data IN FRAME {&frame-name} = entry(ii, fld, '{&delim-flt}') + {&comma-char} +
                                                      replace(entry(ii, lab, '{&delim-flt}'), "&", '').
  end.
  if entry(2, entry(ii, fld, '{&delim-flt}'), '.') = "obj-type" then do:
    assign
    f-obj-type:private-data IN FRAME {&frame-name} = entry(ii, fld, '{&delim-flt}') + {&comma-char} +
                                                     replace(entry(ii, lab, '{&delim-flt}'), "&", '').
  end.
  if entry(2, entry(ii, fld, '{&delim-flt}'), '.') = "obj-code" then do:
    assign
    f-obj-code:private-data IN FRAME {&frame-name} = entry(ii, fld, '{&delim-flt}') + {&comma-char} +
                                                     replace(entry(ii, lab, '{&delim-flt}'), "&", '').
  end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE replace-special-char Dialog-Frame
PROCEDURE replace-special-char :
define input  parameter p-in-string    as character no-undo .
  define output parameter p-out-string   as character no-undo .

  define variable v-out-string   as character no-undo .
  define variable v-enclose-char as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-out-string   = p-in-string
      v-enclose-char = '"'
    .
    if index(v-out-string, '"') > 0
    then do:
      /* если в строке была двойная кавычка, */
      /* то она меняется на своё представление через код */
      /* двойная кавычка должна меняться первой */
      assign
        v-out-string = replace(v-out-string, '"', v-enclose-char + ' + chr(' + string(asc('"')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '~~') > 0
    then do:
      /* если в строке была тильда, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, '~~', v-enclose-char + ' + chr(' + string(asc('~~')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, ',') > 0
    then do:
      /* если в строке была запятая, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, ',', v-enclose-char + ' + chr(' + string(asc(',')) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, "'") > 0
    then do:
      /* если в строке была одинарная кавычка, */
      /* то она меняется на своё представление через код */
      assign
        v-out-string = replace(v-out-string, "'", v-enclose-char + ' + chr(' + string(asc("'")) + ') + ' + v-enclose-char)
      .
    end.
    if index(v-out-string, '/') > 0
    then do:
      /* если в строке был символ наклонной черты, */
      /* то он меняется на своё представление через код */
      /* это делается для того, чтобы в строке случайно не возникло символа */
      /* начала комментария */
      assign
        v-out-string = replace(v-out-string, '/', v-enclose-char + ' + chr(' + string(asc('/')) + ') + ' + v-enclose-char)
      .
    end.

    assign
      p-out-string = v-out-string
    .
  end.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME