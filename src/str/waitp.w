&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог ожидания удаления или появления файла

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/03/10
Author: Dmitry Ukhanov
Creation date: 03/03/10

Автор1: Перваков Михаил Сергеевич
Дата создания1: 07/24/00

Наличие файла сканируется один раз в секунду.
Происходит существенное снижение загрузки процессора по сравнению с
предыдущим алгоритмом.
Среднее время от момента удаления файла до завершения программы 0.5 секунды.
Худшее время от момента удаления файла до завершения программы 1 секунда.

03/03/2005 NVB
кроме ожидания удаления файла появилась опция ожидания появления файла с заданной маской в заданной директории
параметр fname теперь составной

no_app_help.i
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter fname           as character no-undo .
/*составной параметр - может содержать три entry of {&delim-par}*/
/*одновеременно могут быть заданы - либо первый entry - имя файла  ожидающего удаления*/
/*либо 2 и 3 entry - директория и маска файла ожидающие появления*/
define input parameter mess            as character no-undo .
define input parameter btn-mess-start  as character no-undo .
define input parameter btn-mess-end    as character no-undo .
define input parameter p-waiting       as integer   no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Диалог ожидания удаления или появления файла".
{ cmp/vssrevis.i "substitute('&1|&2':u,fname,p-waiting)" }

{ cmp/str-glbl.i }
{ cmp/showinf.i  }

&if defined(dirstream_s) = 0 &then
&glob dirstream_s
define stream dirstream .
&endif
{ str/waitrddr.i }



define variable v-file-name-del as character no-undo .
define variable v-dir-name as character no-undo .
define variable v-fn-add-mask as character no-undo .
define variable v-elapsed-time as integer no-undo .
define variable v-start-dir-watch-time as int64 no-undo .
define variable v-appear as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS EDITOR-1 FI-ExecTime
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 FI-ExecTime

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "Прервать ожидание"
     SIZE 30 BY 1.5
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 39 BY 4.67
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE FI-ExecTime AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 39 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     EDITOR-1 AT ROW 1.13 COL 2.13 NO-LABEL
     FI-ExecTime AT ROW 6.13 COL 2.13 NO-LABEL
     Btn_Cancel AT ROW 7.79 COL 6.63
     SPACE(5.61) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8
         TITLE BGCOLOR 8 ""
         CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON Btn_Cancel IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN
       Btn_Cancel:HIDDEN IN FRAME DIALOG-1           = TRUE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME DIALOG-1        = TRUE.

/* SETTINGS FOR FILL-IN FI-ExecTime IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

define variable v-exec-time as integer no-undo .

on window-close OF FRAME {&FRAME-NAME} do:
  apply "end-error" to frame {&frame-name}.
end.

on "end-error":U of frame {&frame-name} do:
  if v-exec-time < p-waiting then do:
    return no-apply .
  end.
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  assign
    frame {&frame-name} :title = mess
  .
  assign
  v-file-name-del = entry(1, fname, {&delim-par})
  v-dir-name      = (if num-entries(fname, {&delim-par}) = 3
                     and v-file-name-del = "":U
                     then entry(2, fname, {&delim-par})
                     else "":U)
  v-fn-add-mask = (if num-entries(fname, {&delim-par}) = 3
                   and v-file-name-del = "":U
                   then entry(3, fname, {&delim-par})
                   else "":U)
  v-fn-add-mask = (if v-dir-name <> "":U and v-fn-add-mask = "":U
                   then "*.*"
                   else v-fn-add-mask)
  .
  RUN MyEnable .

  define variable v-start-time as int64   no-undo .
  assign
    v-start-time = etime
  .

  do while true
  :
/*    assign*/
/*      v-exec-time = v-exec-time + 1*/
/*    .*/
    /* делаем более точные оценки прошедшего времени на основании etime */
    assign
      v-exec-time = (etime - v-start-time) / 1000
    .
    assign
      fi-exectime :screen-value = substitute("Время ожидания &1", string(v-exec-time, "HH:MM:SS"))
    .
    if v-exec-time >= p-waiting then do:
      if v-file-name-del  <> ""
      or v-dir-name <> "":u
      then do:
        assign
          Editor-1 :screen-value = btn-mess-end
        .
        display btn_cancel with frame {&frame-name}.
        enable btn_cancel with frame {&frame-name}.
      end.
      if v-file-name-del  = "" then do:
        /*просто выйдем*/
        return . /* --->>>--- */
      end.
    end.
    if v-file-name-del <> "" then do:
      if search(v-file-name-del) = ?
      then do:
        /* файл удален */
        return . /* --->>>--- */
      end.
    end.
    if v-dir-name <> "":U
    and v-exec-time > minimum(p-waiting / 4, 15)
    and (v-start-dir-watch-time = 0
         or
         (etime  - v-start-dir-watch-time) > v-elapsed-time * 10
        )
    then do:
      assign
      v-start-dir-watch-time = etime.
      run proc-read-dir in this-procedure (
                                           input v-dir-name
                                          ,input v-fn-add-mask
                                          ,output v-elapsed-time
                                          ,output v-appear
                                          ) no-error .
      if error-status:error then do:
      end.
      if v-appear then return.
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS Btn_cancel PAUSE 1 .
  end.
END.

RUN disable_UI.

return error . /* --->>>--- */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY EDITOR-1 FI-ExecTime
      WITH FRAME DIALOG-1.
  ENABLE EDITOR-1 FI-ExecTime
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable DIALOG-1
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 Enable Editor-1
 With Frame {&frame-name}.
 DISPLAY
 Editor-1
 FI-ExecTime
/* Btn_Cancel*/
 With Frame {&frame-name}.
 Editor-1:screen-value = btn-mess-start.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME