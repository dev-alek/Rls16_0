using ibs.th.gbl.*.

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

Программа печати файла

Автор: Чернова Светлана Александровна
Дата создания: 02/13/08
Author: Svetlana Chernova
Creation date: 02/13/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/27/01

Возвращаются значения:
p-user-action - действия пользователя, какие опции он выбрал и в каком порядке
p-printed     - пользователь вывел файл на принтер или сохранил его в файл

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter  p-message       as character no-undo .
define input parameter  DisabledOptions as integer   no-undo .
define input parameter  p-file-name     as character no-undo .
define input parameter  p-font-number   as integer   no-undo.
define output parameter p-user-action   as character no-undo .
define output parameter p-printed       as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Программа печати файла".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,DisabledOptions,p-file-name,p-user-action,p-printed)" }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ cmp/showinf.i  }

define variable lok             as logical   no-undo .
define variable v-prnfilen-excel-file-exist     as logical      no-undo.

/* Local Variable Definitions ---                                       */
define variable RepFileFullName as character no-undo .
define variable v-report-output as logical   no-undo .
define variable v-excel-printed as logical no-undo .
define variable v-postpone-print as logical no-undo .
define variable p-excel-name as character no-undo .
define variable v-caller as handle no-undo .
define temp-table temp-destination no-undo
field destination-id as character
field destination as character
index pi is unique primary
destination-id.
define stream temp-stream .
{ rep/prnexldl.i }

def stream cfg-stream. /* для чтения *.xslt-cfg файла */
function check-xslt-files returns logical() forward.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Exit IMAGE-1 EDITOR-history b-printer b-pdf ~
b-screen b-file b-other b-excel b-help FILL-IN-1 fi-description 
&Scoped-Define DISPLAYED-OBJECTS EDITOR-history FILL-IN-1 fi-description 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-excel 
     IMAGE-UP FILE "cmp/prnts_excel.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_excel.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_excel.bmp":U
     LABEL " E&xcel" 
     SIZE 10 BY 3.33.

DEFINE BUTTON b-file 
     IMAGE-UP FILE "cmp/prnts_file.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_file.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_file.bmp":U
     LABEL " &Файл" 
     SIZE 10 BY 3.33.

DEFINE BUTTON b-help DEFAULT 
     IMAGE-UP FILE "cmp/prnt_help.bmp":U
     IMAGE-DOWN FILE "cmp/prnt_help.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_help.bmp":U
     LABEL "&Помощь":L 
     SIZE 3 BY 1.08
     BGCOLOR 8 .

DEFINE BUTTON b-other 
     IMAGE-UP FILE "cmp/prnts_zak.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_zak.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_zak.bmp":U
     LABEL "&Заказная" 
     SIZE 10 BY 3.33.

DEFINE BUTTON b-pdf 
     IMAGE-UP FILE "cmp/prnts_pdf.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_pdf.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_pdf.bmp":U
     LABEL "P&DF" 
     SIZE 10 BY 3.33.

DEFINE BUTTON b-printer 
     IMAGE-UP FILE "cmp/prnts_prnt.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_prnt.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_prnt.bmp":U
     LABEL "_ &Принтер" 
     SIZE 10 BY 3.33.

DEFINE BUTTON b-screen 
     IMAGE-UP FILE "cmp/prnts_screen.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_screen.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_screen.bmp":U
     LABEL "_ &Экран" 
     SIZE 10 BY 3.33.

DEFINE BUTTON Exit AUTO-END-KEY 
     IMAGE-UP FILE "cmp/prnts_exit.bmp":U
     IMAGE-DOWN FILE "cmp/prnts_exit.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/prnt_exit.bmp":U
     LABEL "&Выход ":L 
     SIZE 10 BY 3.33.

DEFINE VARIABLE EDITOR-history AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 79.5 BY 4.63
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80.5 BY .67
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Действия по выводу отчёта:" 
      VIEW-AS TEXT 
     SIZE 26 BY .67
     BGCOLOR 15  NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "cmp/mainprint.bmp":U
     STRETCH-TO-FIT
     SIZE 80.5 BY 10.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     Exit AT ROW 1.17 COL 1.25
     EDITOR-history AT ROW 5.79 COL 1.5 NO-LABEL
     b-printer AT ROW 1.17 COL 12.25
     b-pdf AT ROW 1.17 COL 23.25
     b-screen AT ROW 1.17 COL 34.25
     b-file AT ROW 1.17 COL 45.25
     b-other AT ROW 1.17 COL 56.25
     b-excel AT ROW 1.17 COL 67.25
     b-help AT ROW 1.17 COL 78
     FILL-IN-1 AT ROW 4.96 COL 1.5 NO-LABEL
     fi-description AT ROW 10.63 COL 1 NO-LABEL
     IMAGE-1 AT ROW 1 COL 1 WIDGET-ID 14
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS THREE-D  SCROLLABLE 
         TITLE "Вывод отчета".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   FRAME-NAME UNDERLINE L-To-R,COLUMNS                                  */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

ASSIGN
       EDITOR-history:READ-ONLY IN FRAME DIALOG-1        = TRUE.

ASSIGN
       Exit:PRIVATE-DATA IN FRAME DIALOG-1     =
                "Exit".

/* SETTINGS FOR FILL-IN fi-description IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR BUTTON i-excel IN FRAME DIALOG-1
   ALIGN-R                                                              */
/* SETTINGS FOR BUTTON i-file IN FRAME DIALOG-1
   ALIGN-R                                                              */
/* SETTINGS FOR BUTTON i-pdf IN FRAME DIALOG-1
   ALIGN-R                                                              */
/* SETTINGS FOR BUTTON i-printer IN FRAME DIALOG-1
   ALIGN-R                                                              */
/* SETTINGS FOR BUTTON i-screen IN FRAME DIALOG-1
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-excel DIALOG-1
ON CHOOSE OF b-excel IN FRAME DIALOG-1 /*  Excel */
DO:    
  define variable v-disable-button as logical   no-undo .
  if session :set-wait-state("compiler") then .
  
  if check-xslt-files() then /* xslt трансформация в xml-excel  */
    do:
       run xslt-transform.
       run disable-excel(true).
    end.
  else if v-postpone-print then do:
     /*запустим через os*/
    run gbl/open_url.p ( input p-excel-name) no-error .
  end. /*  if v-postpone-print then do:*/
  else do:
  if search( p-file-name + ".txl" ) = ?
  then do:
    /* Run Exel file */
    run rep/runexcel.p
        (input p-file-name + ".txt"
        ) no-error .
    if error-status :error
    then do:
        if session :set-wait-state("") then .
        apply 'ENTRY':u to Exit .
        return no-apply .
    end.
  end.      /* if p-file-name = "macroxlt":U  */
  else do:
    run rep/runxlt.p (
        input p-file-name + ".txl"
    ) no-error.
    if error-status :error
    then do:
/*        assign*/
/*            p-printed = no*/
/*        .*/
        os-delete value( p-file-name + ".txl" ).
        run disable-excel in this-procedure (
            input yes
        ).
        if session :set-wait-state("") then .
        run update-history in this-procedure (
            input "Отказ от сохранения отчёта в формате Excel"
        ).
        apply 'ENTRY':u to Exit .
        return no-apply .
    end.
    assign
        v-disable-button = yes
    .
  end.      /* NOT ( if p-file-name = "macroxlt":U  ) */
  if return-value = "disable-button":U
  then do:
    assign
      v-disable-button = true
    .
  end.
  run disable-excel in this-procedure (
    input v-disable-button
  ).

  end. /*else  if v-postpone-print then do:*/
  assign
    v-report-output = true
    p-user-action   = p-user-action + "; " + "excel"
  .

  run update-history in this-procedure
    (input "Отчёт сохранён в формате Excel"
    ) .



  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file DIALOG-1
ON CHOOSE OF b-file IN FRAME DIALOG-1 /*  Файл */
DO:
  if session :set-wait-state("compiler") then .

  /* Output to File */
  assign
    RepFileFullName = "report.txt"
  .
  system-dialog get-file RepFileFullName
      ask-overwrite
      save-as
      create-test-file
      use-filename
      initial-dir '.'
      update lok
      default-extension "txt" .
  if lok = true
  then do:
    /* проверим, что пользователь не выбрал тот же самый файл */
    if RepFileFullName <> p-file-name
    then do:
      define variable v-err-status as integer   no-undo .

      os-copy
        value(p-file-name)
        value(RepFileFullName)
        .
      assign
        v-err-status = os-error
      .
      if v-err-status <> 0
      then do:
        message
          "Не удалось вывести отчет в файл" repfilefullname skip
          "Ошибка" v-err-status skip
          view-as alert-box error .
      end.
      else do:
        message
          "Отчёт выведен в файл"  repfilefullname skip
          view-as alert-box information .
        assign
          p-printed       = true
          v-report-output = true
          p-user-action   = p-user-action + "; " + "файл"
        .
        run update-history in this-procedure
          (input substitute("Отчёт сохранён в файл &1", repfilefullname)
          ) .
      end.
    end.
  end.

  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-other
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-other DIALOG-1
ON CHOOSE OF b-other IN FRAME DIALOG-1 /* Заказная */
DO:
  define variable v-ok as logical   no-undo .
  message
    "Передать отчет заказной программе обработки" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return no-apply .
  end.

  if session :set-wait-state("compiler") then .

  define variable v-extprog-retval as character no-undo .

  /* Run BAT file */
  run gbl/extprog.p
    (input  {&extprog_exec}   /* p-action    */
    ,input  {&extprog_altprn} /* p-prog-name */
    ,input  p-file-name       /* p-param1    */
    ,input  ""                /* p-param2    */
    ,input  ""                /* p-param3    */
    ,output v-extprog-retval  /* p-ret-value */
    ) .
  assign
    v-report-output = true
    p-user-action   = p-user-action + "; " + "заказная"
  .

  run update-history in this-procedure
    (input "Отчёт передан заказной программе обработки"
    ) .

  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pdf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pdf DIALOG-1
ON CHOOSE OF b-pdf IN FRAME DIALOG-1 /* PDF */
DO:
  if session :set-wait-state("compiler") then .

  define variable v-landscape as logical   no-undo .

  if DisabledOptions >= 8
  then do:
    assign
      v-landscape = true
    .
  end.
  else do:
    assign
      v-landscape = false
    .
  end.

  /* Output to File */
  assign
    RepFileFullName = "report.pdf"
  .
  system-dialog get-file RepFileFullName
      ask-overwrite
      save-as
      create-test-file
      use-filename
      initial-dir '.'
      update lok
      default-extension "pdf" .
  if lok = true
  then do:
    if  search(RepFileFullName) <> ""
    and search(RepFileFullName) <> ?
    then do:
      os-delete value(RepFileFullName) .
    end.

    if  search(RepFileFullName) <> ""
    and search(RepFileFullName) <> ?
    then do:
      message
        "Файл существует и его невозможно удалить" skip
        "Невозможно вывести отчет в файл" RepFileFullName skip
        view-as alert-box error .
    end.
    else do:
      define variable v-extprog-retval as character no-undo .

      run gbl/extprog.p
        (input  {&extprog_exec}                    /* p-action    */
        ,input  {&extprog_txt2pdf}                 /* p-prog-name */
        ,input  p-file-name                        /* p-param1    */
        ,input  RepFileFullName                    /* p-param2    */
        ,input  (if v-landscape then "-l" else "") /* p-param3    */
        ,output v-extprog-retval                   /* p-ret-value */
        ) .

      assign
        v-report-output = true
        p-user-action   = p-user-action + "; " + "pdf"
      .
      run update-history in this-procedure
        (input substitute("Отчёт сохранён в формате PDF в файл &1", repfilefullname)
        ) .
    end.
  end.

  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-printer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-printer DIALOG-1
ON CHOOSE OF b-printer IN FRAME DIALOG-1 /* _ Принтер */
DO:
  if session :set-wait-state("compiler") then .
  /* Output to Printer */
  run adecomm/_osprint.p
    (input  ?                                       /* p_Window     */
    ,input  p-file-name                             /* p_PrintFile  */
    ,input  p-font-number                           /* p_FontNumber */
    ,input  (if DisabledOptions >= 8 then 3 else 1) /* p_PrintFlags */
    ,input  0                                       /* p_PageSize   */
    ,input  0                                       /* p_PageCount  */
    ,output lok                                     /* p_Printed    */
    ).
  if lok
  then do:
    assign
      p-printed       = true
      v-report-output = true
      p-user-action   = p-user-action + "; " + "принтер"
    .
    run update-history in this-procedure
      (input "Отчёт распечатан на принтер"
      ) .
  end.

  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-screen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-screen DIALOG-1
ON CHOOSE OF b-screen IN FRAME DIALOG-1 /* _ Экран */
DO:
  if session :set-wait-state("compiler") then .

  /* Output to Screen */
  define variable v-extprog-retval as character no-undo .

  run gbl/extprog.p
    (input  {&extprog_exec}    /* p-action    */
    ,input  {&extprog_rptview} /* p-prog-name */
    ,input  p-file-name        /* p-param1    */
    ,input  ""                 /* p-param2    */
    ,input  ""                 /* p-param3    */
    ,output v-extprog-retval   /* p-ret-value */
    ) .
  assign
    v-report-output = true
    p-user-action   = p-user-action + "; " + "экран"
  .
  if session :set-wait-state("") then .
  apply 'ENTRY':u to Exit .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Exit DIALOG-1
ON CHOOSE OF Exit IN FRAME DIALOG-1 /* Выход  */
DO:
  if search( p-file-name + ".txl" ) <> ?
  and not v-excel-printed
  then do:
    run prnexldl_clear in this-procedure ( input  p-file-name + ".txl"
                                         ) no-error.
  end.
  if search( p-file-name + ".txt" ) <> ?
  and search( p-file-name + ".frm" ) <> ? then do:
    os-delete value( p-file-name + ".txt" ).
    os-delete value( p-file-name + ".frm" ).
  end.
  apply "end-error":u to frame {&frame-name}  .
  return no-apply .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Restore the current-window if it is an icon.                         */
/* Otherwise the dialog box will be hidden                              */
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


on end-error of frame {&frame-name}
do:
  define variable v-ok as logical   no-undo .

  run clear-temp-xslt-files.

  if v-report-output = false
  then do:
    message
      "Отчёт не был просмотрен, сохранён или распечатан" skip
      "Закрыть диалог вывода отчета?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
/*    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK */ :

    assign
      p-printed       = false
      v-report-output = false
    .
    if DisabledOptions >= 30 then do:
      assign
      v-postpone-print = yes
      .
      disabledoptions = disabledoptions - 30.
      for each temp-destination:
        delete temp-destination.
      end.
      v-caller = this-procedure:instantiating-procedure.
      run cb_get-options in v-caller ( input this-procedure:handle).
    end.
    run init-fields in this-procedure .
    if return-value = 'exit' then return .

    apply 'entry':u to b-screen .

    RUN enable_UI.
    run disable-option in this-procedure .

    assign
      fi-description :screen-value = p-message
    .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_get-options Dialog-Frame
PROCEDURE cb_set-options :
DEFINE INPUT PARAMETER p-option AS character NO-UNDO.
define input parameter p-resource as character no-undo .
DEFINE BUFFER buf_temp-destination FOR temp-destination.
find first buf_temp-destination where
         buf_temp-destination.destination = p-option no-error.
if not available buf_temp-destination then do:
  create buf_temp-destination.
  assign
  buf_temp-destination.destination-id = p-option
  buf_temp-destination.destination = p-resource.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-excel DIALOG-1
PROCEDURE disable-excel :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-disable-button as logical   no-undo .


  do with frame {&frame-name}
  on error undo, return error
  :
    if p-disable-button = true
    then do:
      assign
        b-excel :sensitive = false
        v-excel-printed = yes
      .
    end.
    else do:
        if v-prnfilen-excel-file-exist = no
        then do:
            assign
                b-excel :sensitive = false
            .
        end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable-option DIALOG-1
PROCEDURE disable-option :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}
  on error undo, return error
  :
    case disabledoptions :
      when 1 or
      when 9
      then do:
        assign
          b-printer :sensitive = false
        .
      end.
      when 2 or
      when 10
      then do:
        assign
          b-screen :sensitive = false
        .
        apply 'entry':u to b-file .
      end.
      when 3 or
      when 11
      then do:
        assign
          b-printer :sensitive = false
          b-screen  :sensitive = false
        .
        apply 'entry':u to b-file .
      end.
      when 4 or
      when 12
      then do:
        assign
          b-file :sensitive = false
        .
      end.
      when 5 or
      when 13
      then do:
        assign
          b-printer :sensitive = false
          b-file    :sensitive = false
        .
      end.
      when 6 or
      when 14
      then do:
        assign
          b-screen :sensitive = false
          b-file   :sensitive = false
        .
        apply 'entry':u to b-file .
      end.
      when 20
      then do:
        assign
          b-screen  :sensitive = false
          b-file    :sensitive = false
          b-printer :sensitive = false
          b-other   :sensitive = false
          b-pdf     :sensitive = false
        .
        apply 'entry':u to b-excel .
      end.
      when 21
      then do:
          assign
            b-screen  :sensitive = false
            b-excel   :sensitive = false
            b-printer :sensitive = false
          .
          apply 'entry':u to b-file .
      end.
    end case.
    if v-postpone-print
    and p-file-name = '' then do:
      assign
        b-screen  :sensitive = false
        b-file    :sensitive = false
        b-printer :sensitive = false
        b-other   :sensitive = false
        b-pdf     :sensitive = false
      .

    end.
    run disable-excel in this-procedure
      (input false
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY EDITOR-history fi-description FILL-IN-1
      WITH FRAME DIALOG-1.
  ENABLE Exit IMAGE-1 EDITOR-history b-printer b-pdf b-screen b-file b-other 
         b-excel b-help FILL-IN-1 fi-description 
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields DIALOG-1
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:     Инициализация полей и значений переменных
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-filename          as character    no-undo.
    define variable v-filesize          as integer      no-undo.
    define variable v-data-valid        as logical      no-undo.
    define variable v-err-message       as character    no-undo.
do
on error undo, return error
:

if v-postpone-print then do:
  find first temp-destination where
          temp-destination.destination-id =  {&output-type-plain-text} no-error.
  if available temp-destination
  and search (temp-destination.destination) <> ?
  then do:
    assign
    p-file-name = temp-destination.destination
    .
  end.
end.
/* Проверка на пустой файл */

if p-file-name <> '' AND SEARCH(p-file-name) <> ?  then do:
 
INPUT stream temp-stream FROM value(p-file-name).
def var str1 as character no-undo .
def var kol-row as integer init 0 no-undo  .

REPEAT:
    IMPORT stream temp-stream UNFORMATTED str1 no-error .
    kol-row = kol-row + 1 .
    if kol-row >= 2  then DO:
     leave.
    End.
END.

INPUT stream temp-stream CLOSE.

if kol-row = 0 then DO:
    Message "Нет заданий на печать ! " view-as alert-box .
    Return  'exit'.
    End.
end.


    if p-font-number <= 0
    then do:
        assign
            p-font-number = 7
        .
    end.
    assign
        v-prnfilen-excel-file-exist = no
    .
    if v-postpone-print then do:
      find first temp-destination where
             temp-destination.destination-id =  {&output-type-excel} no-error.
      if available temp-destination
      and search (temp-destination.destination) <> ?
      then do:
        assign
            v-prnfilen-excel-file-exist = yes
            p-excel-name = temp-destination.destination
        .
      end.
    end. /*if v-postpone-print then do:*/
    else do:
    if search( p-file-name + ".txt" ) = ?
    then do:
        assign
            v-filename = search( p-file-name + ".txl" )
        .
        if v-filename <> ?
        then do:
            run gbl/filesize.p (
                  input v-filename
                , output v-filesize
            ).
            if v-filesize <> 0
            and v-filesize <> ?
            then do:
                assign
                    v-prnfilen-excel-file-exist = yes
                .
            end.
            else do:
                if v-filesize = 0
                then do:
                    os-delete value( v-filename ).
                end.
            end.
        end.
    end.
    else do:
        assign
            v-prnfilen-excel-file-exist = yes
        .
    end.
    
    /* проверка на xslt файлы, это тоже относиться к excel, но файл создается немного по другому */
    if check-xslt-files() then
        do:
            v-prnfilen-excel-file-exist = true.
        end.
    
    end. /*else if v-postpone-print then do:*/
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-history DIALOG-1
PROCEDURE update-history :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-message as character no-undo .


  define variable lok as logical   no-undo .

  do with frame {&frame-name}
  on error undo, return error
  :
    assign
      lok = EDITOR-history :move-to-eof( )
      lok = EDITOR-history :insert-string( p-message + {&new-line} )
      lok = EDITOR-history :move-to-eof( )
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure xslt-transform:
    def var rnd-file-name as char no-undo.
    run gbl/_tmpfile.p("", ".xls", output rnd-file-name).
    
    def var xslt-path as char no-undo.
    xslt-path = search("exe\xslt.exe").
    os-command silent value(xslt-path + " -config " + p-file-name + ".xslt-cfg").
    
    def var excel as com-handle no-undo.
    create "Excel.Application" excel no-error.
    if not ERROR-STATUS:ERROR then
        do:
            excel:Visible = false.
            excel:DisplayAlerts = false.
            excel:Workbooks:open(p-file-name + ".xslt-res").
            excel:Visible = true.
            excel:ActiveWorkBook:SaveAs(rnd-file-name,-4143, , , , , ).
            release object excel no-error.
            
            if error-status:ERROR then
                message "Не удалось освободить com-component->excel"
                    view-as alert-box.
        end.
    else
        message "Не удалось создать com-component->excel" view-as alert-box.
end.

function check-xslt-files returns logical:
    if search(p-file-name + ".xslt-cfg") = ? then return false.
    
    input stream cfg-stream from value(p-file-name + ".xslt-cfg").
    def var str as char no-undo.
    def var ret-val as logical no-undo initial false.
    repeat:
        import stream cfg-stream unformatted str.
        if str begins "merge_file=" then ret-val = true.
    end.
    output stream cfg-stream close.
    return ret-val.
end.

procedure clear-temp-xslt-files:
  os-delete value(p-file-name + ".xslt-cfg") no-error.
  os-delete value(p-file-name + ".xslt-res") no-error.
  os-delete value(p-file-name + ".xslt-data") no-error.
  os-delete value(p-file-name + ".xslt-merged") no-error.
end.
