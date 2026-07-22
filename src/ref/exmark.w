&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник акцизных и специальных марок

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06

*/

define input        parameter parParentProc as widget-handle no-undo.
define input        parameter bttns         as char no-undo .
define input-output parameter p-rid-list    as char no-undo . /* список recid'ов выбранных записей */

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Справочник акцизных и специальных марок".
{ cmp/vssrevis.i      }
{ cmp/str-glbl.i      }
{ cmp/library.i       }
{ cmp/showinf.i       }
{ gbl/waitfram.i      }
{ gbl/getcntxt.i def  }
{ ref/exmrklib.i      }

&scop label-clmn_1  'Код марки'
&scop sort-clmn_1   buf_ex-mark.mark-name
&scop label-clmn_2  'Тип'
&scop sort-clmn_2   exmrklib_get-type-name (buf_ex-mark.mark-type)
&scop label-clmn_3  'Статус'
&scop sort-clmn_3   exmrklib_get-status-name(buf_ex-mark.stts)
&scop label-clmn_4  'БД создания'
&scop sort-clmn_4   buf_ex-mark.db-num
&scop label-clmn_5  'Внутренний код'
&scop sort-clmn_5   buf_ex-mark.mark-code


define variable v-cur-recid      as recid     no-undo.
define variable v-mark-type      as integer   no-undo.
define variable v-stts           as integer   no-undo.
define variable glog             as logical   no-undo.
define variable sort-column-name as character no-undo.
define variable h-query          as handle    no-undo.
define variable f-query          as handle    no-undo.

define buffer buf_ex-mark for ub.ex-mark.
define buffer sch_ex-mark for ub.ex-mark.
define buffer pos_ex-mark for ub.ex-mark.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-exmark

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_ex-mark

/* Definitions for BROWSE br-exmark                                     */
&Scoped-define FIELDS-IN-QUERY-br-exmark {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} {&sort-clmn_4} {&sort-clmn_5}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-exmark
&Scoped-define SELF-NAME br-exmark
&Scoped-define QUERY-STRING-br-exmark FOR EACH buf_ex-mark NO-LOCK
&Scoped-define OPEN-QUERY-br-exmark OPEN QUERY {&SELF-NAME} FOR EACH buf_ex-mark NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-exmark buf_ex-mark
&Scoped-define FIRST-TABLE-IN-QUERY-br-exmark buf_ex-mark


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-exmark}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-add b-upd b-del b-hist b-help ~
RECT-1 r-type r-stts sch-code br-exmark
&Scoped-Define DISPLAYED-OBJECTS r-type r-stts sch-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-stts-by-filter Dialog-Frame
FUNCTION get-stts-by-filter RETURNS INTEGER
  ( input p-filter-stts as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-type-by-filter Dialog-Frame
FUNCTION get-type-by-filter RETURNS INTEGER
  ( input p-filter-type as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-upd
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(40)":U
     LABEL "Поиск"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE r-stts AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие&+", 0,
"Все&!", 2,
"Удаленные&-", 1
     SIZE 36 BY .79 TOOLTIP "Статус записей"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE r-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 0,
"Специальные марки", 1,
"Акцизные марки", 2
     SIZE 46 BY .79 TOOLTIP "Тип справочника"
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 70 BY 2.13.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-exmark FOR
      buf_ex-mark SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-exmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-exmark Dialog-Frame _FREEFORM
  QUERY br-exmark NO-LOCK DISPLAY
      {&sort-clmn_1}  COLUMN-LABEL {&label-clmn_1} FORMAT "X(20)":U
      {&sort-clmn_2}  COLUMN-LABEL {&label-clmn_2} FORMAT "X(12)":U
      {&sort-clmn_3}  COLUMN-LABEL {&label-clmn_3}
      {&sort-clmn_4}  COLUMN-LABEL {&label-clmn_4} FORMAT ">>>>9":U
      {&sort-clmn_5}  COLUMN-LABEL {&label-clmn_5} FORMAT "999999999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 69.5 BY 13.88
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-add AT ROW 1 COL 21
     b-upd AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     b-hist AT ROW 1 COL 51
     b-help AT ROW 1 COL 61
     r-type AT ROW 2.33 COL 9.5 NO-LABEL
     r-stts AT ROW 3.13 COL 9.5 NO-LABEL
     sch-code AT ROW 4.29 COL 7.5 COLON-ALIGNED
     br-exmark AT ROW 5.54 COL 1.5
     "Тип:" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 2.33 COL 2
     "Статус:" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 3.13 COL 2
     RECT-1 AT ROW 2.08 COL 1
     SPACE(0.39) SKIP(15.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Акцизные и специальные марки":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-exmark sch-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

ASSIGN
       br-exmark:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-exmark
/* Query rebuild information for BROWSE br-exmark
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_ex-mark NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-exmark */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable v-new-recid as recid no-undo.
  { gbl/stdbtn.i }

  /* Проверяем права доступа */
  /*run adm/chk-acta.p (yes, {&exmark-reference}, {&update}, yes, output glog).*/
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_exmark-reference_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    glog
  }
  if not glog then return.

  /* Определяем тип марки по установленному фильтру для передачи в процедуру
     обновления/добавления (? - все типы) */
  v-mark-type = get-type-by-filter (r-type).

  do on error undo, return no-apply:
    run ref/exmarki.w (input parParentProc
                      ,input {&add-def}
                      ,input v-mark-type
                      ,input-output v-new-recid
                      ).
    if v-new-recid <> ? then do:
      run OpenBR in this-procedure (yes, no, '':U).
      reposition {&browse-name} to recid v-new-recid no-error.
      if error-status:error then do:
        find first pos_ex-mark no-lock
          where recid(pos_ex-mark) = v-new-recid no-error.
        if available pos_ex-mark then do:
          message "Добавленная запись не попадает в текущую выборку " +
                  "из-за установленного фильтра"
            view-as alert-box warning.
        end.
      end.
      if num-results("br-exmark") > 0 then do:
        {&browse-name}:select-focused-row( ).
      end.
    end.
  end.
/*  apply "entry" to {&browse-name} in frame {&frame-name}.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable v-new-stts as integer no-undo .
  define variable lOK        as logical no-undo .
  { gbl/stdbtn.i }

  if not available buf_ex-mark then
    return no-apply.

  /* Проверяем права доступа */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_exmark-reference_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    glog
  }
  if not glog then return.

  case buf_ex-mark.stts :
    when integer({&current-status-int}) then do:
      message "Удалить текущую запись ?"
        view-as alert-box question buttons yes-no
        update lOK.
    end.
    when integer({&deleted-status-int}) then do:
      message "Запись уже удалена. Восстановить ?"
        view-as alert-box question buttons yes-no
        update lOK.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный статус текущей записи" skip
        "ex-mark.stts =" buf_ex-mark.stts
        view-as alert-box error.
      return no-apply.
    end.
  end case.

  if not lOK then do:
    apply "entry" to {&browse-name} in frame {&frame-name}.
    return no-apply.
  end.

  do on error undo, return no-apply:
    assign
      v-new-stts = if buf_ex-mark.stts = integer({&current-status-int})
                     then integer({&deleted-status-int})
                     else integer({&current-status-int})
    .
    run ref/exmark2.p
      ( input buf_ex-mark.db-num
       ,input buf_ex-mark.mark-code
       ,input v-new-stts
      ) no-error.
    if error-status:error then do:
      message
        (if error-status :get-message(1) <> ''
           then error-status :get-message(1) + '~n':U
           else '':U)
        return-value
        view-as alert-box error .
      undo, return no-apply.
    end.

    /* В зависимости от текущего фильтра либо удаляем запись из брауза,
       либо просто показываем новый статус */
    assign
      v-stts = get-stts-by-filter (r-stts).
    .
    if v-stts = ? then do: /* Все */
      {&browse-name}:refresh( ).
    end.
    else do: /* Текущие или Удаленные */
      {&browse-name}:delete-current-row( ).
      if num-results("br-exmark") > 0 then do:
        {&browse-name}:select-focused-row( ).
      end.
    end.
  end.

  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable lOK as logical no-undo .
  { gbl/stdbtn.i }

  if not available buf_ex-mark then
    return no-apply.

  run proc-b-hist in this-procedure .
  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
  { gbl/stdbtn.i }

  if available buf_ex-mark then do:
    if buf_ex-mark.stts = integer({&deleted-status-int}) then do:
      message "Нельзя выбрать марку в статусе 'Удаленная'"
        view-as alert-box warning.
      return no-apply.
    end.

    p-rid-list = string( recid( buf_ex-mark ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd Dialog-Frame
ON CHOOSE OF b-upd IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-curr-recid as recid no-undo.
  { gbl/stdbtn.i }

  if not available buf_ex-mark then
    return no-apply.

  /* Проверяем права доступа */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_exmark-reference_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    glog
  }
  if not glog then return.

  /* Определяем тип марки по установленному фильтру для передачи в процедуру
     обновления/добавления (? - все типы) */
  v-mark-type = get-type-by-filter (r-type).

  do on error undo, return no-apply:
    v-curr-recid = recid( buf_ex-mark ).
    run ref/exmarki.w (input parParentProc
                      ,input {&update}
                      ,input v-mark-type
                      ,input-output v-curr-recid
                      ).
    {&browse-name}:refresh( ).
  end.
  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-exmark
&Scoped-define SELF-NAME br-exmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-exmark Dialog-Frame
ON RETURN OF br-exmark IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF br-exmark IN FRAME Dialog-Frame
DO:
  if lookup( "b-sel",  bttns ) > 0 then do:
    apply "choose" to b-sel in frame {&frame-name} .
  end.
  else
  if b-upd:sensitive then do:
    apply "CHOOSE":U to b-upd in frame {&frame-name} .
  end.
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-stts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-stts Dialog-Frame
ON VALUE-CHANGED OF r-stts IN FRAME Dialog-Frame
DO:
  assign r-stts.
  run OpenBR in this-procedure (yes, no, '':U).
  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-type Dialog-Frame
ON VALUE-CHANGED OF r-type IN FRAME Dialog-Frame
DO:
  assign r-type.
  run OpenBR in this-procedure (yes, no, '':U).
  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* Поиск */
DO:
  if not available buf_ex-mark then
    return no-apply.

  /* Поиск следующей записи по указанному коду */
  assign sch-code.
  run proc-find in this-procedure (yes, sch-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* Поиск */
DO:
  /* Поиск первой записи по указанному коду */
  assign sch-code.
  run proc-find in this-procedure (no, sch-code).
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

{ gbl/app_help.i &browse-name="br-exmark" }
{ gbl/brwrepos.i &line-num=5 }

{ gbl/brwrefre.i
  "if available buf_ex-mark then~
     v-cur-recid = recid(buf_ex-mark).~
   run OpenBR in this-procedure (yes, no, '':U).~
   reposition {&browse-name} to recid v-cur-recid no-error.~
   apply 'entry' to {&browse-name} in frame {&frame-name}."
}

create query f-query.
create query h-query.
assign
  h-query = {&browse-name}:query in frame {&frame-name}
  {&browse-name}:allow-column-searching in frame {&frame-name} = yes.
.
{ gbl/srt-clmn.i
    &frame-name           = {&frame-name}
    &browse-name          = {&browse-name}
    &table-name           = buf_ex-mark
    &start-column         = 1
    &sort-clmn_2          = "dynamic-function ('exmrklib_get-type-name', buf_ex-mark.mark-type)"
    &sort-clmn_3          = "dynamic-function ('exmrklib_get-status-name' , buf_ex-mark.stts)"
    &open-query           = "run OpenBr in this-procedure (yes, no, '':U)."
    &open-query-otherwise = "run OpenBr in this-procedure (yes, no, '':U)."
    &sort-column-name     = "sort-column-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "no"
}

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get " " parParentProc }
    RUN MyEnable in this-procedure.
    RUN OpenBR in this-procedure (yes, no, '':U).

    if p-rid-list <> "":U and p-rid-list <> ? then do:
      assign
        v-cur-recid = integer(entry (1, p-rid-list))
      .
      find buf_ex-mark no-lock where recid(buf_ex-mark) = v-cur-recid no-error.
      if available buf_ex-mark and
         buf_ex-mark.stts = integer({&current-status-int})
      then do:
        reposition {&browse-name} to recid v-cur-recid no-error.
        if num-results("br-exmark") > 0 then do:
          {&browse-name}:select-focused-row( ).
        end.
      end.
    end.

    apply "entry" to {&browse-name} in frame {&frame-name}.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN my-disable IN THIS-PROCEDURE.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-disable Dialog-Frame
PROCEDURE my-disable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    delete object f-query.
    delete object h-query.
    RUN DISABLE_UI IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    r-stts:radio-buttons in frame {&frame-name} =
               "Текущие&+"   + {&comma-char} + {&current-status-int} + {&comma-char} +
               "Все&!"       + {&comma-char} + "2" + {&comma-char} +
               "Удаленные&-" + {&comma-char} + {&deleted-status-int}
  .
  display r-stts
    with frame {&frame-name}.


  /* Разрешаем редактировать только в офисе */
  ENABLE
      b-exit
      b-add WHEN  (lookup  ( "b-add" , bttns) > 0)
      b-sel WHEN  (lookup  ( "b-sel" , bttns) > 0)
      b-upd WHEN  (lookup  ( "b-add" , bttns) > 0)
      b-del WHEN  (lookup  ( "b-add" , bttns) > 0)
      b-help
      b-hist
      r-type
      r-stts
      sch-code
      br-exmark
    WITH FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBR Dialog-Frame
PROCEDURE OpenBR :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .

  define variable v-query-prefix   as character no-undo.
  define variable v-query-where    as character no-undo.
  define variable v-query-by       as character no-undo.
  define variable v-query-text     as character no-undo.
  define variable v-find-text      as character no-undo.
  define variable l-rec-found      as logical   no-undo.

  /* Определяем тип марки по установленному фильтру (? - все) */
  v-mark-type = get-type-by-filter (r-type).

  /* Определяем статус по установленному фильтру (? - все) */
  v-stts = get-stts-by-filter (r-stts).

  /* Формируем условие выборки */
  assign
    v-query-prefix = "for each buf_ex-mark no-lock":U
    v-query-where = "":U
    v-query-by    = "":U
    v-query-text  = "":U
  .
  if v-mark-type <> ? then do :
    assign
      v-query-where = substitute ("buf_ex-mark.mark-type = &1":U, v-mark-type)
    .
  end.
  if v-stts <> ? then do:
    assign
      v-query-where = (if v-query-where <> "":U then v-query-where + " and ":U else "":U)
                    + substitute ("buf_ex-mark.stts = &1":U, v-stts)
    .
  end.
  if v-query-where <> "":U then do:
    assign
      v-query-where = " where ":U + v-query-where
    .
  end.

  /* Формируем условие сортировки */
  if sort-column-name = "":U or sort-column-name = "{&sort-clmn_1}":U then do:
    assign
      v-query-by = " by {&sort-clmn_1}":U
    .
  end.
  else do:
    assign
      v-query-by = " by ":U + sort-column-name
                 + " by {&sort-clmn_1}":U
    .
  end.

  assign
    v-query-text = v-query-prefix
                 + v-query-where
                 + v-query-by
                 + " indexed-reposition":U
  .

  run waitfram-show in this-procedure ("Подождите...").

  if p-open-query then do:
    if h-query:query-prepare(v-query-text) then do:
      h-query:query-open().
    end.
    else do: /* при ошибке в формировании выборки открываем статическую query */
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .

      open query br-exmark
       for each buf_ex-mark no-lock
           by {&sort-clmn_1} indexed-reposition.
    end.
  end.

  else do: /* поиск */
    /* Для поиска используем тот же текст для формирования динамической query,
       но с дополнительным условием и по другому буферу */
    assign
      l-rec-found = no
      v-find-text = v-query-prefix
                  + v-query-where
                  + (if v-query-where <> "":U then " and ":U else "":U)
                  + p-find-condition
                  + v-query-by
                  + " indexed-reposition":U
      v-find-text = replace (v-find-text, "buf_ex-mark":U, "sch_ex-mark":U)
    .
    f-query:set-buffers(buffer sch_ex-mark:handle).
    if f-query:query-prepare(v-find-text) then do:
      f-query:query-open().
      f-query:get-first().

      if available sch_ex-mark then do: /* query для поиска не пустая */
        /* поиск следующей записи от текущей в браузе */
        if p-find-next and available buf_ex-mark then do:
          if f-query:reposition-to-rowid (rowid(buf_ex-mark)) then do:
            /* встаем курсором query на запись, являющуюся текущей в браузе */
            f-query:get-next().
            /* пытаемся найти следующую запись */
            if f-query:get-next() then do:
              l-rec-found = yes.
            end.
          end.
        end.

        /* поиск первой записи, удовлетворяющей условию */
        else do:
          l-rec-found = yes.
        end.
      end.

      if l-rec-found then do:
        v-cur-recid = recid(sch_ex-mark).
        reposition {&browse-name} to recid v-cur-recid no-error.
        if num-results("br-exmark") > 0 then do:
          {&browse-name}:select-focused-row( ) in frame {&frame-name}.
        end.
      end.
    end. /* if f-query:query-prepare() */
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при формировании запроса для поиска" skip(1)
        v-find-text
        view-as alert-box warning.
    end.
  end.

  run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-hist Dialog-Frame
PROCEDURE proc-b-hist :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run ref/ex-markh.w ( input parparentproc
                     , rowid( buf_ex-mark )
                     ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find Dialog-Frame
PROCEDURE proc-find :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-find-next as logical   no-undo.
  define input parameter p-code      as character no-undo.

  define variable v-find-condition as character no-undo.

  assign
    v-find-condition = substitute (" buf_ex-mark.mark-name begins '&1' ", p-code)
  .
  run OpenBR in this-procedure
    (input no                   /*  p-open-query     */
    ,input p-find-next          /*  p-find-next      */
    ,input v-find-condition     /*  p-find-condition */
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-stts-by-filter Dialog-Frame
FUNCTION get-stts-by-filter RETURNS INTEGER
  ( input p-filter-stts as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable ret    as integer no-undo .

  if p-filter-stts = integer({&current-status-int}) or
     p-filter-stts = integer({&deleted-status-int}) then do:
    assign
      ret = p-filter-stts
    .
  end.
  else do:
    assign
      ret = ?
    .
  end.

  return ret .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-type-by-filter Dialog-Frame
FUNCTION get-type-by-filter RETURNS INTEGER
  ( input p-filter-type as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable ret    as integer no-undo .

  case p-filter-type:
      when 1 then ret = 0. /* Специальные */
      when 2 then ret = 1. /* Акцизные */
      otherwise   ret = ?. /* Все */
  end case.

  return ret .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
