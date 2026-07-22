&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Импорт групп товаров

Автор: Гридчина Полина Дмитриевна
Дата создания: 07/01/12
Author: Ilia Belousov
Creation date: 07/01/12

Input:

Output:

*/

DEFINE VARIABLE p-install as logical no-undo init false .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Импорт групп товаров ".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define stream sinp .
define stream slog.

/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rs-format f-name r-currency Btn_OK ~
Btn_Cancel
&Scoped-Define DISPLAYED-OBJECTS rs-format f-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON r-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE VARIABLE f-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE rs-format AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Имя группы", 1,
"Имя группы,код группы,код родительской группы", 2
     SIZE 52 BY 2.5 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     rs-format AT ROW 2.21 COL 3.38 NO-LABEL WIDGET-ID 2
     f-name AT ROW 5.04 COL 7.25 COLON-ALIGNED WIDGET-ID 8
     r-currency AT ROW 5.08 COL 51.25 WIDGET-ID 52
     Btn_OK AT ROW 7.21 COL 9
     Btn_Cancel AT ROW 7.25 COL 26.63
     "Выберите формат:" VIEW-AS TEXT
          SIZE 19.5 BY .67 AT ROW 1.25 COL 3.5 WIDGET-ID 6
     SPACE(36.37) SKIP(7.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт групп товаров"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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

ASSIGN
       r-currency:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт групп товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:


define variable v-ok   as logical   no-undo .
DEFINE VARIABLE v-level-name as character no-undo .
DEFINE VARIABLE v-level-num as integer no-undo .
DEFINE VARIABLE v-full-level-name as character no-undo .
DEFINE VARIABLE v-node-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE v-upper-code like ub.gds-grp.upper-code no-undo .
DEFINE VARIABLE v-calc-method like ub.gds-grp.calc-method no-undo .
DEFINE VARIABLE v-increase-pc like ub.gds-grp.increase-pc no-undo .
DEFINE VARIABLE v-print-code  like ub.gds-grp.print-code  no-undo .
DEFINE VARIABLE v-d-pcnt like ub.gds-grp.d-pcnt no-undo .
DEFINE VARIABLE v-new-node-code like ub.gds-grp.node-code no-undo .
DEFINE VARIABLE v-rid as recid no-undo.
DEFINE VARIABLE v-ask as logical no-undo init yes.
DEFINE VARIABLE choice as integer no-undo .

define buffer buf_gds-grp for ub.gds-grp.

do
on error undo, return
:
  assign
    v-ok = false
  .

assign     frame {&frame-name} f-name  rs-format.

f-name = search(f-name).
if f-name = ? then do:
    message "Не указан файл" view-as alert-box.
    return no-apply.
end.

  input stream sinp from value (f-name).

  define variable v-file-format as character no-undo .
  find first ub.sys-ctrl no-lock .
  if ub.sys-ctrl.db-num <> 0 then do:
    if not p-install then do:
      message
      "Утилиту импорта групп товаров можно запускать только в ГБД"
      view-as alert-box error .
    end.
    return .
  end.
  import stream sinp v-file-format .
  if rs-format = 1 and v-file-format <> "GOODS_GRP_1_0"
     or rs-format = 2 and v-file-format <> "GOODS_GRP_2_0" then do:
    input stream sinp close.
    message
      "Неправильный формат файла" skip
      "Первая строка файла" v-file-format skip
      "Файл" f-name skip
      view-as alert-box error .
    undo, return no-apply .
  end.
  run write-to-log in this-procedure({&new-line} + string(today, "99/99/9999") + {&space-char} +
                                     string(time, "HH:MM:SS") + {&space-char} +
                                     g#userid) .
  define variable v-full-name as character no-undo .
  repeat
  :

   if rs-format = 1  then import stream sinp unformatted v-full-name.
   else  import stream sinp delimiter ','  v-full-name  v-node-code    v-upper-code.
    assign
      v-ok = true
    .

    v-full-name = trim(v-full-name,'"').
    if v-ask then
    run gbl/d-askw.w (input "Создание групп товаров",
              input "Группа" + {&new-line} + v-full-name,
              input "|",
              input "Создать|Не создавать|Создать все|Отмена",
              input "Создать группу (если такой еще нет)|Не создавать группу|Перестать спрашивать и по возможности создать все|Прекратить загрузку групп товаров",
              input 1,
              input 4,
              output choice).
   CASE choice:
    when 1 then do:
      assign
      v-ok = yes.
    end.
    when 2 then do:
      assign
      v-ok = no
      .
    end.
    when 3 then do:
      assign
      v-ok = yes
      v-ask = no
      .
    end.
    when 4 then do:
      leave.
    end.
   END CASE.
   if v-ok = true  and rs-format = 1 then do:
      assign
      v-full-name = trim(v-full-name, {&delim-grp})
      v-full-level-name = "":U
      .
      find first buf_gds-grp no-lock where
                 buf_gds-grp.upper-code = 0 no-error .
      assign
      v-node-code = buf_gds-grp.node-code
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      v-print-code  = buf_gds-grp.print-code
      v-d-pcnt = buf_gds-grp.d-pcnt
      .
      /* ??????? ?????? ?? ????????? ??????? ????? v-full-name */
      _cycle:
      do v-level-num = 1 to num-entries(v-full-name, {&delim-grp}):
        assign
        v-level-name =  entry(v-level-num, v-full-name, {&delim-grp})
        v-full-level-name = v-full-level-name + v-level-name + {&delim-grp}
        .
        find first buf_gds-grp no-lock where
                   buf_gds-grp.upper-code = v-node-code
               and buf_gds-grp.node-name = v-level-name no-error .
        if not avail buf_gds-grp then do:
         run ref/gdsgrp01.p (
                         input {&add-def}
                        ,input p-install
                        ,input no /*p-get-node-code*/
                        ,input yes /*p-fill-tax-from-upper*/
                        ,input-output v-new-node-code
                        ,input-output v-node-code
                        ,input v-level-name
                        ,input v-calc-method
                        ,input v-increase-pc
                        ,input v-print-code
                        ,input {&pr-round-off}
                        ,input 0
                        ,output v-rid
                        ) no-error.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + {&space-char} + v-full-level-name) .
            next _cycle.
          end.
          /* ????????? ?????????? ? ????????? ??????? ? ????????? ???? */
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + {&space-char} + v-full-level-name) .
          end.
          else do:
            run write-to-log in this-procedure("new group" + {&space-char} + v-full-level-name) .
          end.
          assign
          v-node-code = v-new-node-code
          .
        end.
        else do:
          run write-to-log in this-procedure("exists group" + {&space-char} + v-full-level-name) .
          assign
          v-node-code = buf_gds-grp.node-code
          v-calc-method = buf_gds-grp.calc-method
          v-increase-pc = buf_gds-grp.increase-pc
          v-print-code  = buf_gds-grp.print-code
          v-d-pcnt = buf_gds-grp.d-pcnt
          .
          next _cycle.
        end.

      end. /*do v-level-num*/
    end. /* v-ok*/
    else if v-ok and rs-format = 2 then do:
      assign
/*      v-node-code = int(entry(2,v-full-name))
      v-upper-code = int(entry(3,v-full-name))
      v-full-name = trim(entry(1,v-full-name), {&delim-grp})  */
      v-full-level-name = "":U
      .
      if num-entries(v-full-name,{&delim-grp}) > 1 then do:
            run write-to-log in this-procedure("Не верно задано имя группы. Следует указывать только имя самой группы, без полного пути" + {&space-char} + v-full-name) .
            next .
      end.
      find first buf_gds-grp no-lock where
                 buf_gds-grp.node-code = v-upper-code no-error .
      if not available buf_gds-grp then do:
            run write-to-log in this-procedure("Не найдена родительская группа с кодом" + {&space-char} + string(v-upper-code)) .
            next .
      end.
      if can-find (first ub.goods where ub.goods.grp-code = buf_gds-grp.node-code no-lock ) then do:
           run write-to-log in this-procedure("Группа с кодом" + {&space-char} + string(v-upper-code) + " содержит товары. Добавление в нее подгрупп запрещено!") .
           next .
      end.
      assign
      /*v-node-code = buf_gds-grp.node-code*/
      v-calc-method = buf_gds-grp.calc-method
      v-increase-pc = buf_gds-grp.increase-pc
      v-print-code  = buf_gds-grp.print-code
      v-d-pcnt = buf_gds-grp.d-pcnt
      .

      find first buf_gds-grp no-lock where
                 buf_gds-grp.node-code = v-node-code no-error .
        if not avail buf_gds-grp then do:
         run ref/gdsgrp01.p (
                         input {&add-def}
                        ,input p-install
                        ,input yes /*p-get-node-code*/
                        ,input yes /*p-fill-tax-from-upper*/
                        ,input-output v-node-code
                        ,input-output v-upper-code
                        ,input v-full-name
                        ,input v-calc-method
                        ,input v-increase-pc
                        ,input v-print-code
                        ,input {&pr-round-off}
                        ,input 0
                        ,output v-rid
                        ) no-error.
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + {&space-char} + v-full-level-name) .
            next .
          end.
          /* ????????? ?????????? ? ????????? ??????? ? ????????? ???? */
          if error-status:error then do:
            run write-to-log in this-procedure("error in creating group" + {&space-char} + v-full-level-name) .
          end.
          else do:
            run write-to-log in this-procedure("new group" + {&space-char} + v-full-level-name) .
          end.
          assign
          v-node-code = v-new-node-code
          .
        end.
        else do:
          run write-to-log in this-procedure("exists group" + {&space-char} + v-full-level-name) .
          assign
          v-node-code = buf_gds-grp.node-code
          v-calc-method = buf_gds-grp.calc-method
          v-increase-pc = buf_gds-grp.increase-pc
          v-print-code  = buf_gds-grp.print-code
          v-d-pcnt = buf_gds-grp.d-pcnt
          .
          next .
        end.

      end. /*do v-level-num*/

    end.
    { gbl/stopwork.i }
  end. /*repeat*/
  input stream sinp close.




message "Импорт завершен".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-currency Dialog-Frame
ON CHOOSE OF r-currency IN FRAME Dialog-Frame
DO:
def var v-ok as log.
      system-dialog get-file f-name
      title "Выберите файл с группами товаров"
      filters "Файлы групп товаров *.ggr" "*.ggr",
                "Все файлы  *.*" "*.*"
      INITIAL-DIR "."
      return-to-start-dir
      must-exist
      /* use-filename */
      update v-ok
      default-extension "ggr".
    if v-ok <> true then do:
      return .
    end.
f-name:screen-value = search(f-name).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
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
  DISPLAY rs-format f-name
      WITH FRAME Dialog-Frame.
  ENABLE rs-format f-name r-currency Btn_OK Btn_Cancel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log Dialog-Frame
PROCEDURE write-to-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter P-MESSAGE as character no-undo .

  do
  on error undo, return error
  :
    output STREAM SLOG TO imp-ggr.log append.
    put STREAM SLOG unformatted
    P-MESSAGE SKIP.
    OUTPUT STREAM SLOG CLOSE.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME