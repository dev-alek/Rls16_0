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

Универсальный диалог для ввода данных

Автор: Перваков Михаил Сергеевич
Дата создания: 10/17/97
Author: Mikhail Pervakov
Creation date: 10/17/97

Можно ввести одно поле любого типа.
Диалог настраивается через строку, в которой перечислены

Ниже указан пример вывода в полным списком параметром.
Лишние параметры необходимо удалить.

Есть специальная программа fldfrmt.p для получения формата поля базы данных.
Не следует жестко прописывать формат поля, так как при изменении формата
базы данных придется править его во всех местах вызова .

В случае, если необходимо показать в диалоге показать информацию, котора
может содержать специальные символы, например знак равенства и
символ обратной косой строки, то необходимо вызывать функцию экранировани
специальных символов из файла strcodec.i .
Это правило касается только первого параметра.
Во втором параметре ничего не надо перекодировать.

Например, если в диалоге, необходимо показать номер документа:
  'text1=':u + str-encode("Документ " + ub.trn-doc.doc-code, '', '=\':u) + '\':u

  define variable v-field-format as character no-undo .

  run gbl/fldfrmt.p
    (input  'trn-doc':u
    ,input  'cst-code':u
    ,output v-field-format
    ) .

  define variable passwd as character no-undo.

  run gbl/d-prompt.w (
      'title=':u + "Password Prompter" + '\':u
    + 'text1=':u + "Enter Superuser" + '\':u
    + 'text2=':u + "Password" + '\':u
    + 'format=' + v-field-format + '\':u
    + 'password=yes\':u
    + 'type=char\':u
    + 'boxprog=getfile.p\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=2\':u
    + 'fillin_height=4\':u
    + 'max-chars=70\':u     - максимальное количество символов для редактора
    + 'readonly=yes\':u     - если истина - то данные только выводятся для просмотра
    + 'create_text1=3;1;':u + "New Label:" + '\':u
    ,input-output passwd
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

  display passwd.

Possible types:
    'CHAR'  or {&type-char} - Character
    'INT'   or {&type-int}  - Integer
    'DEC'   or {&type-dec}  - Decimal
    'DATE'  or {&type-date} - Date
    'LOG'   or {&type-log}  - Logical
    'EDIT'                  - Editor

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
&IF DEFINED(UIB_IS_RUNNING)=0 &THEN
DEFINE INPUT        PARAMETER pParameters  AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER pValue       AS CHARACTER NO-UNDO.
&ELSE
define variable pParameters  AS CHARACTER NO-UNDO
INIT 'title=Password Prompter\text1=Enter Superuser\text2=Password\format=x(15)\blank=yes\'.
/*INIT 'title=Password Prompter\text1=Enter Superuser\text2=Password\format=->>>>>9.9<<<<<\type=dec\'. */
define variable pValue       AS CHARACTER NO-UNDO.
&ENDIF

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Универсальный диалог для ввода данных".
{ cmp/vssrevis.i }
{ gbl/color.i    }
{ cmp/str-glbl.i }
{ cmp/strcodec.i }
{ gbl/sel-date.i }
{ cmp/showinf.i  }

define variable lUserPressOK     AS LOGICAL       NO-UNDO INIT False .
define variable sFormat          AS CHARACTER     NO-UNDO .
define variable sType            AS CHARACTER     NO-UNDO .
define variable sBoxProg         AS CHARACTER     NO-UNDO .
define variable lBlank           AS LOGICAL       NO-UNDO .
define variable v-password       as logical   no-undo .
define variable hFillIn          AS WIDGET-HANDLE NO-UNDO .
define variable sFillIn_Row      AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Col      AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Width    AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Height   AS CHARACTER     NO-UNDO INIT ? .
define variable sEditor_MaxChars AS CHARACTER     NO-UNDO INIT ? .
define variable sCreate_Text1    AS CHARACTER     NO-UNDO INIT ? .
define variable v-read-only      AS LOGICAL       NO-UNDO INIT False .

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-help Btn_OK Btn_Cancel

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-date"
     SIZE 3 BY .88.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn-Choose
     LABEL "V"
     SIZE 2.5 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 5.5 BY 1.75
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-Character AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 41.25 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-Date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-Decimal AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 41.25 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-Integer AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 41.25 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.25 BY .58
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-Text-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.25 BY .58
     FONT 4 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4.63 BY .96 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     FILL-IN-Decimal AT ROW 2.96 COL 2 NO-LABEL
     FILL-IN-Character AT ROW 2.96 COL 2 NO-LABEL
     FILL-IN-Integer AT ROW 2.96 COL 2 NO-LABEL
     FILL-IN-Date AT ROW 2.96 COL 2 NO-LABEL
     Btn-Choose AT ROW 2.96 COL 43.5
     b-choose-date AT ROW 3.08 COL 14.38
     EDITOR-1 AT ROW 4.13 COL 2 NO-LABEL
     b-help AT ROW 4.5 COL 45
     Btn_OK AT ROW 4.58 COL 8.5
     Btn_Cancel AT ROW 4.58 COL 28.5
     TOGGLE-1 AT ROW 4.58 COL 40.88
     FILL-IN-Text-1 AT ROW 1.13 COL 2.5 NO-LABEL
     FILL-IN-Text-2 AT ROW 2.04 COL 2.5 NO-LABEL
     SPACE(4.24) SKIP(3.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Prompter"
         CANCEL-BUTTON Btn_Cancel.


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

/* SETTINGS FOR BUTTON b-choose-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-choose-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON Btn-Choose IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       Btn-Choose:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR EDITOR-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       EDITOR-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Character IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Character:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Decimal IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Decimal:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Integer IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Integer:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Text-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-Text-2 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       FILL-IN-Text-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX TOGGLE-1 IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       TOGGLE-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Prompter */
DO:
  IF NOT v-read-only
  THEN DO:
    IF VALID-HANDLE(hFillIn)
    THEN DO:
      define variable v-check-date as date      no-undo .
      if  sType = 'DATE'
      then do:
        assign
          v-check-date = date(hFillIn :SCREEN-VALUE) no-error
        .
        if error-status :error
        then do:
          message
            "Ошибка при вводе даты" skip
            error-status :get-message(1) skip
            view-as alert-box error .
          return no-apply .
        end.
        hFillIn:SCREEN-VALUE = string (date(hFillIn:SCREEN-VALUE), "99/99/9999").
      end.
      ASSIGN
        pValue = hFillIn:SCREEN-VALUE
      .
    END.
  END.
  ASSIGN
    lUserPressOK = True
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Prompter */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-date Dialog-Frame
ON CHOOSE OF b-choose-date IN FRAME Dialog-Frame /* b-choose-date */
DO:
  run sel-date in this-procedure
    (input FILL-IN-Date :handle       /* p-date-handle */
    ,input FRAME {&FRAME-NAME} :TITLE /* p-description */
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-Choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-Choose Dialog-Frame
ON CHOOSE OF Btn-Choose IN FRAME Dialog-Frame /* V */
DO:
  define variable var_id   as char no-undo.
  define variable var_name as char no-undo.

  { gbl/working.i }
  do with frame {&frame-name}
  :
    assign
      var_id = hfillin :screen-value
    .
    run value(sboxprog) (input-output var_id, input-output var_name).
    if var_id <> hfillin :screen-value
    then do:
      assign
        hfillin :screen-value = var_id
      .
    end.
  end.
  { gbl/stopwork.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-Character
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Character Dialog-Frame
ON RETURN OF FILL-IN-Character IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE":U TO Btn_OK.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-Date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Date Dialog-Frame
ON RETURN OF FILL-IN-Date IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE":U TO Btn_OK.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-Decimal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Decimal Dialog-Frame
ON RETURN OF FILL-IN-Decimal IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE":U TO Btn_OK.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-Integer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-IN-Integer Dialog-Frame
ON RETURN OF FILL-IN-Integer IN FRAME Dialog-Frame
DO:
  APPLY "CHOOSE":U TO Btn_OK.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable ind AS INTEGER NO-UNDO.
define variable sElement AS CHARACTER NO-UNDO.
define variable sValue AS CHARACTER NO-UNDO.

DO ind = 1 TO NUM-ENTRIES(pParameters, '\'):
  sElement = ENTRY(ind, pParameters, '\').
  IF NUM-ENTRIES(sElement, '=') = 2
  THEN DO:
    sValue   = ENTRY(2, sElement, '=').
    CASE ENTRY(1, sElement, '='):
      WHEN 'text1'         THEN do: assign FILL-IN-Text-1   = str-decode(sValue, "").             end.
      WHEN 'text2'         THEN do: assign FILL-IN-Text-2   = str-decode(sValue, "").             end.
      WHEN 'format'        THEN do: assign sFormat          = sValue.                             end.
      WHEN 'blank'         THEN do: assign lBlank           = lookup(sValue, 'true,yes':U) > 0.   end.
      WHEN 'password'      THEN do: assign v-password       = lookup(sValue, 'true,yes':U) > 0.   end.
      WHEN 'title'         THEN do: assign FRAME {&FRAME-NAME}:TITLE = sValue.                    end.
      WHEN 'type'          THEN do: assign sType            = sValue.                             end.
      WHEN 'boxprog'       THEN do: assign sBoxProg         = sValue.                             end.
      WHEN 'FillIn_Row'    THEN do: assign sFillIn_Row      = sValue.                             end.
      WHEN 'FillIn_Col'    THEN do: assign sFillIn_Col      = sValue.                             end.
      WHEN 'FillIn_Height' THEN do: assign sFillIn_Height   = sValue.                             end.
      WHEN 'FillIn_Width'  THEN do: assign sFillIn_Width    = sValue.                             end.
      WHEN 'max-chars'     THEN do: assign sEditor_MaxChars = sValue.                             end.
      WHEN 'Create_Text1'  THEN do: assign sCreate_Text1    = sValue.                             end.
      WHEN 'readonly'      THEN do: assign v-read-only      = lookup(sValue, 'yes,true':U) > 0 .  end.
    END CASE.
  END.
END.

define variable hFrameHandle AS WIDGET-HANDLE NO-UNDO.
hFrameHandle = FRAME {&FRAME-NAME}:HANDLE.

define variable hText AS WIDGET-HANDLE NO-UNDO.

DO WITH FRAME {&FRAME-NAME}
:
  IF FILL-IN-Text-1 <> ''
  THEN DO:
    DISPLAY FILL-IN-Text-1.
  END.

  IF FILL-IN-Text-2 <> ''
  THEN DO:
    DISPLAY FILL-IN-Text-2.
  END.
END.

define variable sText1Label AS CHARACTER NO-UNDO.

IF sCreate_Text1 <> ?
AND NUM-ENTRIES(sCreate_Text1, ';') = 3
THEN DO:
  sText1Label = ENTRY(3, sCreate_Text1, ';').
  CREATE TEXT hText
  ASSIGN
    ROW          = INTEGER(ENTRY(1, sCreate_Text1, ';'))
    COLUMN       = INTEGER(ENTRY(2, sCreate_Text1, ';'))
    FORMAT       = 'X(' + STRING(LENGTH(sText1Label)) + ')'
    SCREEN-VALUE = sText1Label
    FRAME        = hFrameHandle
    SENSITIVE    = FALSE
    VISIBLE      = TRUE
  .
END.

define variable sTypeOk as logical   no-undo .

assign
  sTypeOk = false
.

if sType begins 'CHAR'
or sType = {&type-char}
then do:
  assign
    sType = 'CHAR'
    sTypeOk = true
  .
end.
if sType begins 'INT'
or sType = {&type-int}
then do:
  assign
    sType = 'INT'
    sTypeOk = true
  .
end.
if sType begins 'DEC'
or sType = {&type-dec}
then do:
  assign
    sType = 'DEC'
    sTypeOk = true
  .
end.
if sType begins 'DATE'
or sType = {&type-date}
then do:
  assign
    sType = 'DATE'
    sTypeOk = true
  .
end.
if sType begins 'EDIT'
then do:
  assign
    sType = 'EDIT'
    sTypeOk = true
  .
end.
if sType begins 'LOG'
or sType = {&type-log}
then do:
  assign
    sType = 'LOG'
    sTypeOk = true
  .
end.


if sType = ''
then do:
  assign
    sType = 'CHAR'
    sTypeOk = true
  .
end.

IF sTypeOk <> true
THEN DO:
  MESSAGE
    vss-workfile vss-revision vss-description skip
    'Указан неправильный тип данных' SKIP
    'sType' sType SKIP
    'Тип данных принимается за строковый' SKIP
    'Позвоните разработчикам системы' skip
    VIEW-AS ALERT-BOX WARNING.
  assign
    sType = 'CHAR'
  .
END.
IF sType = 'LOG' AND num-entries(sFormat, {&slash-char}) <> 2
then DO:
  MESSAGE
    vss-workfile vss-revision vss-description skip
    'Указан неправильный формат данный' SKIP
    'sFormat' sFormat 'для логического типа данных' SKIP
    'Формат данных принимается за yes/no' SKIP
    'Позвоните разработчикам системы' skip
    VIEW-AS ALERT-BOX WARNING.
  assign
    sFormat = 'yes/no'
  .

END.


RUN setup-editor .
RUN setup-fill-in .
RUN setup-toggle.

if sType = "DATE"
then do:
  { gbl/ed_date.i FILL-IN-Date }
end.




/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  run setup-box-button .

  run setup-cancel-button .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* 07/21/1998 Pervakov Return user choose */
IF lUserPressOK
THEN DO:
  RETURN 'TRUE'.
END.
ELSE DO:
  RETURN 'FALSE'.
END.

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
  ENABLE b-help Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-box-button Dialog-Frame
PROCEDURE setup-box-button :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DO WITH FRAME {&FRAME-NAME}
  :
    IF sBoxProg <> ''
    THEN DO:
      ASSIGN
        Btn-Choose:VISIBLE      = True AND NOT v-read-only
        Btn-Choose:SENSITIVE    = True AND NOT v-read-only
      .
    END.

    if v-read-only
    then do:
      assign
        Btn_OK :LABEL = "&Выход"
      .
    end.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-cancel-button Dialog-Frame
PROCEDURE setup-cancel-button :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}
  :
    if v-read-only = false
    then do:
      assign
        Btn_Cancel :visible   = true
        Btn_Cancel :sensitive = true
      .
    end.
    else do:
      assign
        Btn_Cancel :sensitive = false
        Btn_Cancel :visible   = false
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-editor Dialog-Frame
PROCEDURE setup-editor :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* Customise dialog with EDITOR */
  do with frame {&frame-name}
  :
    IF sType = 'EDIT'
    THEN DO:
      IF FILL-IN-Text-2 = ''
      AND sFillIn_Row = ?
      THEN DO:
        sFillIn_Row = '2'.
        IF FILL-IN-Text-1 = ''
        THEN DO:
          sFillIn_Row = '1.1'.
        END.
      END.
      IF sFillIn_Height = ? THEN
        sFillIn_Height = '10'.
      IF sFillIn_Width = ? THEN
        sFillIn_Width = '50'.

      IF  sEditor_MaxChars <> ?
      AND sEditor_MaxChars <> ''
      AND CAN-SET(EDITOR-1:HANDLE, 'MAX-CHARS')
      THEN DO:
        ASSIGN
          EDITOR-1:MAX-CHARS = INTEGER(sEditor_MaxChars)
        .
      END.
    END.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-fill-in Dialog-Frame
PROCEDURE setup-fill-in :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  DO WITH FRAME {&FRAME-NAME}
  :
    CASE sType:
      WHEN 'CHAR'
      THEN DO:
        ASSIGN
          FILL-IN-Character :VISIBLE      = True
          FILL-IN-Character :SENSITIVE    = True AND NOT v-read-only
          hFillIn = FILL-IN-Character:HANDLE
        .
      END.
      WHEN 'INT'
      THEN DO:
        ASSIGN
          FILL-IN-Integer :VISIBLE      = True
          FILL-IN-Integer :SENSITIVE    = True AND NOT v-read-only
          hFillIn = FILL-IN-Integer :HANDLE
        .
      END.
      WHEN 'DATE'
      THEN DO:
        ASSIGN
          FILL-IN-Date  :visible    = True
          FILL-IN-Date  :sensitive  = True AND NOT v-read-only
          b-choose-date :visible    = True AND NOT v-read-only
          b-choose-date :sensitive  = True AND NOT v-read-only
          hFillIn = FILL-IN-Date :HANDLE
        .
      END.
      WHEN 'DEC'
      THEN DO:
        ASSIGN
          FILL-IN-Decimal:VISIBLE      = True
          FILL-IN-Decimal:SENSITIVE    = True AND NOT v-read-only
          hFillIn = FILL-IN-Decimal :HANDLE
        .
      END.
      WHEN 'EDIT'
      THEN DO:
        ASSIGN
          EDITOR-1:VISIBLE      = True
          EDITOR-1:SENSITIVE    = True
          EDITOR-1:READ-ONLY    = v-read-only
          EDITOR-1:BGCOLOR      = IF v-read-only THEN GRAY_COLOR ELSE WHITE_COLOR
          EDITOR-1:ROW          = 3
          EDITOR-1:COL          = 2
          hFillIn = EDITOR-1:HANDLE
        .
      END.
      WHEN 'LOG'
      THEN DO:
        ASSIGN
          TOGGLE-1:VISIBLE      = True
          TOGGLE-1:SENSITIVE    = True AND NOT v-read-only
          TOGGLE-1:ROW          = 3
          TOGGLE-1:COL          = 2
          hFillIn = TOGGLE-1:HANDLE
        .
      END.
    END CASE.
  END.

  IF VALID-HANDLE(hFillIn)
  THEN DO:
    IF CAN-SET(hFillIn, 'BLANK')
    THEN DO:
      ASSIGN
        hFillIn:BLANK        = lBlank
      .
    END.

    IF CAN-SET(hFillIn, 'PASSWORD-FIELD')
    THEN DO:
      ASSIGN
        hFillIn:PASSWORD-FIELD = v-password
      .
    END.

    IF CAN-SET(hFillIn, 'BLANK')
    THEN DO:
      ASSIGN
        hFillIn:BLANK        = lBlank
      .
    END.

    IF sFormat <> ''
    AND CAN-SET(hFillIn, 'FORMAT')
    THEN DO:
      ASSIGN
        hFillIn:FORMAT       = sFormat
      .
    END.

    IF CAN-SET(hFillIn, 'SCREEN-VALUE')
    THEN DO:
      if sType = 'LOG'
      then do:
        ASSIGN
          hFillIn :SCREEN-VALUE =
            ( if lookup(pvalue
                       , 'yes':U
                       + ',':u + 'true':U
                       + ',':u + entry(1, sFormat, {&slash-char})) > 0
              then "yes"
              else "no"
            )
        .
      end.
      else do:
        ASSIGN
          hFillIn :SCREEN-VALUE = pValue
        .
      end.
    END.

    IF  sFillIn_Row <> ?
    AND sFillIn_Row <> ''
    AND CAN-SET(hFillIn, 'ROW')
    THEN DO:
      ASSIGN
        hFillIn:ROW          = DECIMAL(sFillIn_Row)
      .
      if  sType = 'DATE'
      and NOT v-read-only
      then do:
        ASSIGN
          b-choose-date :ROW          = DECIMAL(sFillIn_Row)
        .
      end.
    END.

    IF  sFillIn_Col  <> ?
    AND sFillIn_Col <> ''
    AND CAN-SET(hFillIn, 'COL')
    THEN DO:
      define variable v-new-col as decimal   no-undo .

      assign
        v-new-col = DECIMAL(sFillIn_Col)
      .
      if v-new-col + hFillIn :width + 1.5 >= frame {&frame-name}:width
      then do:
        assign
          frame {&frame-name}:width = v-new-col + hFillIn :width + 1.5
        .
      end.
      ASSIGN
        hFillIn:COL = v-new-col
      .
      if  sType = 'DATE'
      and NOT v-read-only
      then do:
        assign
          v-new-col = hFillIn:COL + hFillIn:WIDTH + .2
        .
        if v-new-col + b-choose-date :width + 1.5 >= frame {&frame-name}:width
        then do:
          assign
            frame {&frame-name}:width = v-new-col + b-choose-date :width + 1.5
          .
        end.
        ASSIGN
          b-choose-date :COL  = v-new-col
        .
      end.
    END.

    define variable eFillIn_Width AS DECIMAL NO-UNDO.
    eFillIn_Width = DECIMAL(sFillIn_Width).
    IF eFillIn_Width = ? THEN
      eFillIn_Width = hFillIn:WIDTH.

    IF hFillIn:COL + eFillIn_Width + 1.5 >= FRAME {&FRAME-NAME}:WIDTH
    THEN DO:
      ASSIGN
        FRAME {&FRAME-NAME}:WIDTH = hFillIn:COL + eFillIn_Width + 1.5
      .
    END.

    IF  sFillIn_Width  <> ?
    AND sFillIn_Width <> ''
    AND CAN-SET(hFillIn, 'WIDTH')
    THEN DO:
      ASSIGN
        hFillIn:WIDTH        = DECIMAL(sFillIn_Width)
      .
    END.

    /* Center buttons */
    /*
    define variable eHalfWidthDelta AS DECIMAL NO-UNDO.
    eHalfWidthDelta = (FRAME {&FRAME-NAME}:WIDTH - RECT-1:WIDTH - 1.5) / 2 - RECT-1:COL.
    IF eHalfWidthDelta > 0
    THEN DO:
      ASSIGN
        Btn_Cancel:COL             = Btn_Cancel:COL + eHalfWidthDelta
        b-help:COL                 = b-help:COL   + eHalfWidthDelta
        Btn_OK:COL                 = Btn_OK:COL     + eHalfWidthDelta
        RECT-1:COL                 = RECT-1:COL     + eHalfWidthDelta
      .
    END.
    */

    /* Increase height of frame to accomodate FILL-IN */
    define variable eFillIn_Height AS DECIMAL NO-UNDO.
    eFillIn_Height = DECIMAL(sFillIn_Height).
    IF eFillIn_Height = ? THEN
      eFillIn_Height = hFillIn:HEIGHT.

    define variable eHeightDelta AS DECIMAL NO-UNDO.
    assign
      eHeightDelta = hFillIn:ROW + eFillIn_HEIGHT + 2.2 - FRAME {&FRAME-NAME}:HEIGHT
    .

    IF eHeightDelta > 0
    THEN DO:
      ASSIGN
        /* Increase height of frame to accomodate new objects */
        FRAME {&FRAME-NAME}:HEIGHT = FRAME {&FRAME-NAME}:HEIGHT + eHeightDelta

        /* Move buttons to bottom of frame */
        Btn_Cancel:ROW             = Btn_Cancel:ROW + eHeightDelta
        b-help:ROW               = b-help:ROW   + eHeightDelta
        Btn_OK:ROW                 = Btn_OK:ROW     + eHeightDelta
      .

    END.

    IF  sFillIn_Height  <> ?
    AND sFillIn_Height <> ''
    AND CAN-SET(hFillIn, 'HEIGHT')
    THEN DO:
      ASSIGN
        hFillIn:HEIGHT       = DECIMAL(sFillIn_Height)
      .
    END.

    IF hFillIn:MOVE-TO-TOP() THEN .
  END.
  pValue = ''.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-toggle Dialog-Frame
PROCEDURE setup-toggle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  /* Customise dialog with EDITOR */
  do with frame {&frame-name}
  :
    IF sType = 'LOG'
    THEN DO:
      IF FILL-IN-Text-2 = ''
      AND sFillIn_Row = ?
      THEN DO:
        sFillIn_Row = '2'.
        IF FILL-IN-Text-1 = ''
        THEN DO:
          sFillIn_Row = '1.1'.
        END.
      END.
      IF sFillIn_Height = ? THEN
        sFillIn_Height = '10'.
      IF sFillIn_Width = ? THEN
        sFillIn_Width = '50'.
      TOGGLE-1:format = sFormat.

    END.
  end. /* do with frame */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
