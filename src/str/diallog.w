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

Диалог вывода лога и счетчика

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04


Input:
    p-mainmenu-handle        as widget-handle   - mainmenu handle
    p-parent-handle          as widget-handle   - handle процедуры, вызвавшей diallog.w
    p-procedure-name         as character       - составной параметр - список с разделителями {&delim-par}
                                                 имя файла процедуры
                                                 error-message-option - если 1 не выводится error-messaпу при ошибке выполнения процедуры
                                                 auto-go-option - если 1 при ошибке выполнения процедуры или при возварщении в return-value "error" - нет auto-go
                                                                  если 2 при  возвращении в return-value "return" - БУДЕТ auto-go
                                                 return-value-option - если 1 возвращается return error и return-value при ошибке выполенени
                                                 create-window-option - если 1 возвращается то создается окно - для режима когда нет mainmenu.w

    p-procedure-parameter    as character       - строка параметров, определенная в процедуре
    p-auto-go                as logical         - yes, если после выполнения процедуры окно диалога надо закрыть,
                                                  ? выводится вслучае view-log = yes
                                                    не дожидаясь нажатия кнопки выхода
    p-stop-button-label      as character       - надпись кнопки Выход во время выполнения процедуры.
                                                    Если задано ? или "", надпись остается "В&ыход", и кнопка
                                                    во время выполнения процедуры недоступна
    p-title                  as character       - Название окна диалога

Использование:
    run str/diallog.w (
          input parentproc
        , input "runproc.p"
        , input "proc_rarameter"
        , input no
        , input "&Стоп"
        , input "Title for dialog"
    ).
    В вызываемой процедуре (runproc.p) должны быть определены параметры (и только эти параметры):
        input:
            p-mainmenu-handle   as widget-handle
            p-parent-handle     as widget-handle
            p-log-handle        as handle
            p-parameter-string  as character

    В вызываемой процедуре (runproc.p) можно использовать процедуры:
        run write-counter in p-log-handle (
            input v-counter-string
        ).
        run write-log in p-log-handle (
              input v-tab-position
            , input v-log-string
        ).
        run write-log-and-file in p-log-handle (
              input v-tab-position
            , input log-file-name
            , input v-log-level
            , input v-log-string
        ).
        run set-title in p-log-handle (
            input v-title
        ).
        run hide-counter in p-log-handle.
        run show-counter in p-log-handle.
        run get-counter-value in p-log-handle (
            output v-counter-value
        ).
        run set-counter-value in p-log-handle (
            input v-counter-value
        ).
        run get-stop-state in p-log-handle (
            output v-must-stop
        ).
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle        as widget-handle    no-undo.
define input parameter p-parent-handle          as widget-handle    no-undo.
define input parameter p-procedure-name         as character        no-undo.
define input parameter p-procedure-parameter    as character        no-undo.
define input parameter p-auto-go                as logical          no-undo .
define input parameter p-stop-button-label      as character        no-undo.
define input parameter p-title                  as character        no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог вывода лога и счетчика".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/sys-time.i }
{ str/writelog.i def-proc }
{ str/writelog.i def-proc-extended }

/*переменная считающиая чего-либо 0- которую можно устанавливать и считывать из вызываемой программы*/
define variable v-loc-counter           as integer      no-undo .
define variable v-diallog-stop-pressed  as logical      no-undo.
define variable v-diallog-prog-running  as logical      no-undo.
define variable v-view-log as logical no-undo.
define variable v-return-value as character no-undo .
define variable v-error as logical no-undo .
define variable error-message-option as integer no-undo .
define variable auto-go-option as integer no-undo .
define variable return-value-option as integer no-undo .
define variable create-window-option as integer no-undo .
define variable is-internal-option as logical no-undo .
define variable v-comp-name as character no-undo .
define variable v-default-name-flag as integer no-undo .
define variable mprocevent as logical no-undo init yes.
define stream instream.

define temp-table temp-file-name no-undo
field file-name_       as character
field path-file-name_  as character
field blocked as logical
index pi is unique primary
file-name_.

&scoped-define Tabspaces 4
&scoped-define LogLineSize 80

&Scoped-def WINDOW-NAME w-diallog
DEFINE VARiable {&window-name} AS WIDGET-HANDLE NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help ed-log
&Scoped-Define DISPLAYED-OBJECTS fi-log ed-log

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 96 BY 19.37 NO-UNDO.

DEFINE VARIABLE fi-log AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 96 BY 1
     FGCOLOR 9  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 88.1
     fi-log AT ROW 2.47 COL 2.1 NO-LABEL
     ed-log AT ROW 3.83 COL 2.1 NO-LABEL
     SPACE(0.77) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запуск программы".


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
if not session:batch-mode then 
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ed-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-log IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Запуск программы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    if v-diallog-prog-running = yes
    then do:
        assign
            v-diallog-stop-pressed = yes
        .
    end.
    else do:
        assign
            v-diallog-stop-pressed = no
        .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


assign
v-diallog-prog-running = yes
v-diallog-stop-pressed = no
error-message-option = if num-entries(p-procedure-name, {&delim-par}) > 1
                        then integer(entry(2, p-procedure-name, {&delim-par}))
                        else 0
auto-go-option       =  if num-entries(p-procedure-name, {&delim-par}) > 2
                        then integer(entry(3, p-procedure-name, {&delim-par}))
                        else 0
return-value-option  =  if num-entries(p-procedure-name, {&delim-par}) > 3
                        then integer(entry(4, p-procedure-name, {&delim-par}))
                        else 0
create-window-option =  if num-entries(p-procedure-name, {&delim-par}) > 4
                        then integer(entry(5, p-procedure-name, {&delim-par}))
                        else 0
is-internal-option   =  if num-entries(p-procedure-name, {&delim-par}) > 5
                        then logical(entry(6, p-procedure-name, {&delim-par}))
                        else no
.



/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if create-window-option = 1 then do:
  PAUSE 0 BEFORE-HIDE.
  /*
  IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.*/

end.
else do:
  IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
end.
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable mSilent as logical no-undo.
   
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.      
  mFramHandle = frame {&frame-name}:handle.

  mFrameView = not session:batch-mode or mFramHandle:visible.
  publish "IsAsyncProc" (output mSilent).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError"). 
      log-manager:write-message("mSilent=" + string(mSilent), "frameoxmError"). 
      log-manager:write-message("create-window-option=" + string(create-window-option), "frameoxmError"). 
  end.
/*   mSilent = mSilent or mFrameView.*/
   if mSilent ne true
   then do:
     IF create-window-option = 1 THEN DO:
       CREATE WIDGET-POOL.
       RUN create-window IN THIS-PROCEDURE.
     END.
     else do:
       if mFrameView then 
         RUN enable_UI.
     end.
  end.
  if mFrameView then 
  assign
  frame {&frame-name}:title = p-title
  b-exit :sensitive   = no
  .
  if p-stop-button-label <> ?
  and p-stop-button-label <> ""
  then do:
        assign
            b-exit :label       = p-stop-button-label
            b-exit :sensitive   = yes
        .
  end.
  if is-internal-option then do:
    define variable v-ii as integer no-undo .
    define variable v-entry as character no-undo .
    do v-ii = 1 to num-entries( entry(1, p-procedure-name, {&delim-par})):
      v-entry = entry(v-ii, entry(1, p-procedure-name, {&delim-par})).
      run value ( v-entry) in p-parent-handle (
              input p-mainmenu-handle
            , input p-parent-handle
            , input this-procedure
            , input p-procedure-parameter
        ) no-error.
    end.
  end.
  else do:
  run value ( entry(1, p-procedure-name, {&delim-par}) ) (
          input p-mainmenu-handle
        , input p-parent-handle
        , input this-procedure
        , input p-procedure-parameter
    ) no-error.
  end.
  if error-status :error
  then do:
    assign
    v-error = error-status:error .
    if error-message-option = 0 then do:
      message
      vss-workfile vss-revision vss-description
        skip "Ошибка при выполнении процедуры " entry(1, p-procedure-name, {&delim-par})
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        skip return-value
     view-as alert-box error.
     undo, return error .
   end.
 end.

 assign
 v-return-value  = return-value .
 if not p-auto-go
 and auto-go-option = 2
 and return-value = "return"
 then do:
   p-auto-go = yes.
 end.
 if mFrameView and (not p-auto-go
 or (auto-go-option = 1
        and
        (v-error or return-value = "error":U)
       ))
 then do:
    assign
    b-exit :sensitive       = yes
    b-exit :label           = "В&ыход"
    v-diallog-prog-running  = no
    .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.

  end.
  else if     p-auto-go eq ?
          and v-view-log
          and mFrameView 
  then do:
     assign
        b-exit :sensitive       = yes
        b-exit :label           = "В&ыход"
        v-diallog-prog-running  = no
     .
     WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  end.
  if return-value = "error":U then do:
    if     create-window-option = 1
       and mSilent ne true
    THEN DO:
      RUN delete-window IN THIS-PROCEDURE.
    END.
    if valid-handle(p-parent-handle)
    and  lookup( "set-error":U, p-parent-handle :internal-entries ) > 0 then do:
       run set-error in p-parent-handle ( input yes).
    end.
    return "error":U.
  end.
  if v-error and return-value-option = 1 then do:
    if     create-window-option = 1 
       and mSilent ne true
    THEN DO:
      RUN delete-window IN THIS-PROCEDURE.
    END.
    if valid-handle(p-parent-handle)
    and lookup( "set-error":U, p-parent-handle :internal-entries ) > 0 then do:
      run set-error in p-parent-handle ( input yes).
    end.
    if valid-handle(p-parent-handle)
    and lookup( "set-error-message":U, p-parent-handle :internal-entries ) > 0 then do:
      run set-error-message in p-parent-handle ( input v-return-value).
    end.
     return error v-return-value.
  end.
  if return-value-option = 1 then do:
    if     create-window-option = 1 
       and mSilent ne true    
    THEN DO:
      RUN delete-window IN THIS-PROCEDURE.
    END.
    return return-value .
  end.
END.
for each temp-file-name:
  delete temp-file-name.
end.
if     create-window-option = 1 
   and mSilent ne true
THEN DO:
  RUN delete-window IN THIS-PROCEDURE.
END.
else do:
  RUN disable_UI.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE copyto-log-and-file Dialog-Frame
PROCEDURE copyto-log-and-file :
define input parameter p-source-file as character no-undo.
define input parameter p-tab-position   as integer   no-undo.
define input parameter p-file-name      as character no-undo .
define input parameter p-log-level      as integer   no-undo .
define variable v-str as character no-undo .
if search(p-source-file) = ? then do:
return.
end.
input stream instream from value(p-source-file) .
repeat:
  import stream instream unformatted v-str.
  run write-log-and-file in this-procedure ( input p-tab-position
                                            ,input p-file-name
                                            ,input p-log-level
                                            ,input v-str) no-error.
end.
input stream instream close.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-window Dialog-Frame
PROCEDURE create-window :
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
CREATE WINDOW {&window-name}
ASSIGN
HIDDEN         = YES
TITLE          = ""
COLUMN         = 1
ROW            = 5.79
HEIGHT         = 22.75
WIDTH          = 99.38
MAX-HEIGHT     = 22.75
MAX-WIDTH      = 99.38
MAX-HEIGHT     = 12.95
MAX-WIDTH      = 78.88
VIRTUAL-HEIGHT = 22.75
VIRTUAL-WIDTH  = 99.38
RESIZE         = no
SCROLL-BARS    = no
STATUS-AREA    = no
BGCOLOR        = ?
FGCOLOR        = ?
MESSAGE-AREA   = no
THREE-D        = yes
SENSITIVE      = yes
RESIZE         = yes
KEEP-FRAME-Z-ORDER = yes
.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE({&window-name})
THEN {&window-name}:HIDDEN = no.
ASSIGN
CURRENT-WINDOW                = {&WINDOW-NAME}
THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}
.
VIEW {&window-name}.
view frame {&frame-name} .
DISPLAY
fi-log
ed-log
WITH FRAME {&frame-name} in window {&window-name}.
ENABLE
b-exit
b-help
ed-log
WITH FRAME {&frame-name} in window {&window-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-window Dialog-Frame
PROCEDURE delete-window :
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE({&window-name})
THEN DELETE WIDGET {&window-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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
  if mFrameView then
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY fi-log ed-log
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help ed-log
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-counter-value Dialog-Frame
PROCEDURE get-counter-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-counter     as integer    no-undo.

    assign
    p-counter  = v-loc-counter
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-stop-state Dialog-Frame
PROCEDURE get-stop-state :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-stop-state    as logical      no-undo.
    if v-diallog-prog-running
    then do:
        assign
            p-stop-state = v-diallog-stop-pressed
        .
    end.
    else do:
        assign
            p-stop-state = no
        .
    end.
    assign
        v-diallog-stop-pressed = no
    .
end.
END PROCEDURE. /* get-stop-state */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-title Dialog-Frame
PROCEDURE get-title :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-title     as character    no-undo.

    assign
    p-title = frame {&frame-name}:title
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-view-log Dialog-Frame
PROCEDURE get-view-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-view-log     as logical    no-undo.

    assign
    p-view-log = v-view-log
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-counter Dialog-Frame
PROCEDURE hide-counter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if mFrameView then
    assign
        fi-log :visible in frame {&frame-name} = false
    .
    process events.
end.
END PROCEDURE. /* hide-counter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-counter-value Dialog-Frame
PROCEDURE set-counter-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-counter     as integer    no-undo.

    assign
    v-loc-counter = p-counter
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-title Dialog-Frame
PROCEDURE set-title :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-title     as character    no-undo.

    assign
    frame {&frame-name}:title = p-title
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-view-log Dialog-Frame
PROCEDURE set-view-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-view-log     as logical    no-undo.

    assign
    v-view-log = p-view-log
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-counter Dialog-Frame
PROCEDURE show-counter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if mFrameView then
    assign
        fi-log :visible in frame {&frame-name} = true
    .
    process events.
end.
END PROCEDURE. /* show-counter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-counter Dialog-Frame
PROCEDURE write-counter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.

    if mFrameView then
    assign
        fi-log :screen-value in frame {&frame-name} = p-counter-string
    .
    process events.
end.
END PROCEDURE. /* write-counter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log Dialog-Frame
PROCEDURE write-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.

    ed-log :move-to-eof() in frame {&frame-name} .
    ed-log :insert-string ( ( if p-tab-position = 0
                                or p-log-string = "&DLine"
                                or p-log-string = "&Line"
                                then ""
                                else cur-time-string-sec() + " "
                          ) ) in frame {&frame-name}.
    ed-log :insert-string ( ( if p-log-string = "&Line"
                                then fill( "-", {&LogLineSize} )
                                else if p-log-string = "&DLine" then fill("=", {&LogLineSize})
                                else fill( " ", p-tab-position) + p-log-string
                          ) ) in frame {&frame-name}.
    ed-log :insert-string ( {&new-line} ) in frame {&frame-name}.
    if mprocevent
    then
       process events.

end.
END PROCEDURE. /* write-log */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file Dialog-Frame
PROCEDURE write-log-and-file-noprocevent :
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
   mprocevent = no.
  
   run write-log-and-file( p-tab-position,p-file-name,p-log-level,p-log-string)no-error.
   mprocevent = yes.
END PROCEDURE. /* write-log-and-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file Dialog-Frame
PROCEDURE write-log-and-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.

  define variable v-file-name as character no-undo .
  define variable v-ext       as character no-undo .
  define variable v-ind1 as integer no-undo .
  define variable v-ind2 as integer no-undo .
  define variable v-ind as integer no-undo .
  define variable v-path as character no-undo .
  define variable v-path-file-name as character no-undo .
  define variable v-can-write as logical no-undo .
  define variable v-sys-time-string as character no-undo .
  define variable v-only-dir as logical no-undo .

  define buffer buf_temp-file-name for temp-file-name.

&scop process-error if g#auto then do: ~
                      run gbl/thlogevt.p (input ''                     ~
                                      ,input vss-workfile           ~
                                      ,input vss-revision           ~
                                      ,input vss-description        ~
                                      ,input ~{&my-message~}).      ~
                    end.                                            ~
                    else do: message ~{&my-message~} view-as alert-box error. end. ~
                    create buf_temp-file-name.                      ~
                    assign buf_temp-file-name.file-name_ = v-file-name         ~
                           buf_temp-file-name.blocked = yes

&scop process-error if not g#auto then do: ~
                      message ~{&my-message~} view-as alert-box error.  ~
                    end



  run write-log in this-procedure(
                                  input  p-tab-position
                                 ,input  p-log-string     ) .

  if g#news then do:
    assign
    v-ext = (if num-entries(p-file-name, '.') = 2
             then entry(2, p-file-name, '.')
             else '':U)
    v-file-name = substitute("&1_from_db_&2.&3"
                             ,entry(1, p-file-name, '.')
                             ,g#news-source-db
                             ,v-ext).
  end.
  else do:
    v-file-name = p-file-name.
  end.
  find first buf_temp-file-name where
            buf_temp-file-name.file-name_ = v-file-name no-error .
  if not available buf_temp-file-name then do:
    /*проверим на доступность записи */
    if index(v-file-name, {&slash-char}) > 0
    or index(v-file-name, {&back-slash-char}) > 0 then do:
      assign
      v-ind1 = r-index(v-file-name, {&back-slash-char})
      v-ind2 = r-index(v-file-name, {&slash-char})
      v-ind  = max(v-ind1, v-ind2)
      v-path = substring(v-file-name, 1, v-ind - 1)
      .
      FILE-INFO:FILE-NAME = v-path.
      if file-info:FULL-pathname = ? then do:

&scop my-message  substitute("Вывод в файл &1 невозможен&2Нет такого файла" ~
                            ,v-file-name                                                                          ~
                            ,~{&new-line~})

         {&process-error}.
      end.
      assign
      v-path-file-name = FILE-INFO:FULL-pathname
      v-can-write = index(FILE-INFO:file-type, 'W') > 0.
      if not v-can-write then do:
&scop my-message  substitute("Вывод в файл &1 невозможен&2Отсутствует право на запись в директорию" ~
                            ,v-path-file-name                                                                          ~
                            ,v-path                                                                               ~
                            ,~{&new-line~})

         {&process-error}.
      end.
      if index(FILE-INFO:file-type, 'D') > 0 then do:
        assign
        v-only-dir          = yes
        v-default-name-flag = (if v-default-name-flag = 0 then 1 else v-default-name-flag)
        v-file-name      = entry(1, ENTRY(1, p-procedure-name, {&delim-par}), '.') + '.log'
        v-path-file-name = v-path-file-name + {&back-slash-char} + v-file-name
        .
        v-file-name      = ENTRY(1, p-procedure-name, {&delim-par}).
&scop my-message    substitute("Не задано имя файло лога&1Вывод лога будет осуществляться в файл с именем выполняемой процедуры &2" ~
                                   ,v-file-name                                                                    ~
                                   ,v-path                                                                         ~
                                   ,~{&new-line~})
        {&process-warning}.

      end.
    end. /*задано с путем*/
    else do:
      IF V-FILE-NAME = '':u THEN DO:
        assign
        v-default-name-flag = (if v-default-name-flag = 0 then 1 else v-default-name-flag)
        v-file-name      = entry(1, ENTRY(1, p-procedure-name, {&delim-par}), '.') + '.log'.
        v-file-name      = entry(num-entries(v-file-name,{&back-slash-char}),v-file-name,{&back-slash-char}).
        v-file-name      = entry(num-entries(v-file-name,{&slash-char}),v-file-name,{&slash-char}).
        
&scop my-message    substitute("Не задано имя файло лога&1Вывод лога будет осуществляться в файл с именем выполняемой процедуры &2" ~
                                   ,v-file-name                                                                    ~
                                   ,v-path                                                                         ~
                                   ,~{&new-line~})
        {&process-warning}.

      END.
      /*прокачиваем точку через file-info*/
      FILE-INFO:FILE-NAME = '.'.
      assign
      v-path = FILE-INFO:FULL-pathname
      v-can-write = index(FILE-INFO:file-type, 'W') > 0.
      if not v-can-write then do:
&scop my-message    substitute("Вывод в файл &1 директории &2 невозможен&3Отсутствует право на запись в директорию" ~
                                   ,v-file-name                                                                    ~
                                   ,v-path                                                                         ~
                                   ,~{&new-line~})
        {&process-error}.
      end.
      assign
      v-path-file-name = v-path + {&back-slash-char} + v-file-name.
    end.
    FILE-INFO:FILE-NAME = v-path-file-name.
    assign
    v-can-write = index(FILE-INFO:file-type, 'W') > 0.
    .
    if not v-can-write then do:
&scop my-message  substitute("Вывод в файл &1&3Отсутствует право на запись в файл" ~
                                  ,v-path-file-name                                ~
                                  ,v-path                                          ~
                                  ,~{&new-line~})
      {&process-error}.
    end.
    assign
    v-path-file-name                   = replace(v-path-file-name, {&slash-char}, {&back-slash-char})
    v-file-name                        = entry(num-entries(v-path-file-name, {&back-slash-char}), v-path-file-name, {&back-slash-char})
    .
    if v-default-name-flag >= 2
    and (p-file-name = '':U or v-only-dir) then do:
      find first buf_temp-file-name where
                buf_temp-file-name.file-name_ = v-file-name no-error .
    end.
    else do:
      find first buf_temp-file-name where
                buf_temp-file-name.file-name_ = v-file-name no-error .
      if not available buf_temp-file-name then do :
        create buf_temp-file-name.
        assign
        buf_temp-file-name.file-name_      = v-file-name
        buf_temp-file-name.path-file-name_ = v-path-file-name
        v-default-name-flag = (if v-default-name-flag = 1 then 2 else v-default-name-flag)
        .
        assign
        v-sys-time-string = sys-time_get-sys-str-func() no-error .
        run gbl/compname.p (output v-comp-name) no-error .
        run writelog-extended in this-procedure(
                                        input buf_temp-file-name.path-file-name_
                                        ,input 3
                                        ,input g#userid
                                        ,input substitute("&1 &2", v-sys-time-string, v-comp-name)
                                        ,input 3
                                      ) no-error .
        if error-status:error then do:
      &scop my-message   substitute("Ошибка при выводе в файл:&1&2&1&3", ~{&new-line~}, error-status:get-message(1), return-value )
        {&process-error}.
        end.
      end.
    end.
  end. /*первая попытка записи в файл*/
  if not buf_temp-file-name.blocked then do:
    run writelog-extended in this-procedure(
                                    input buf_temp-file-name.path-file-name
                                    ,input p-log-level
                                    ,input g#userid
                                    ,input p-log-string
                                    ,input 3
                                  ) no-error .
    if error-status:error then do:
  &scop my-message   substitute("Ошибка при выводе в файл:&1&2&1&3", ~{&new-line~}, error-status:get-message(1), return-value )
    {&process-error}.
    end.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME