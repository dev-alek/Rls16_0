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

Выбор параметров для выгрузки договоров.

Автор: Хныкин Павел Андреевич
Дата создания: 10/09/07
Author: Pavel Khnykin
Creation date: 10/09/07


Input:
        p-init-doc-type-list as character    - список типов договоров
Output:
    date_exp_from  as date          - Дата с
    date_exp_to    as date          - Дата по
    p-range        as integer       - Диапазон: 1 - глобально, 2 - список фирм
    p-host-list     as character     - для p-range = 2, список ( "орг,3,орг,20,орг,2" )
    p-doc-type-list as character    - список типов договоров
    p-cancel       as logical       - была нажата кнопка Отменить

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc        AS WIDGET-HANDLE        NO-UNDO.
define input parameter p-init-doc-type-list as character            no-undo.
define output parameter date_exp_from       as date      INIT ?     no-undo.
define output parameter date_exp_to         as date      INIT ?     no-undo.
define output parameter p-range             as integer              no-undo.

define output parameter p-obj-list          as character            no-undo.
define output parameter p-doc-type-list     as character            no-undo.
define output parameter p-cancel            as logical   INIT no    no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для выгрузки договоров.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/userhsts.i }
define variable v-obj-list          as character    no-undo.
define variable v-host-name         as character    no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
define variable v-ext-fin-doc-type-list as character extent 4 init
[
        "с поставщиками",                  {&income},
        "с покупателями",                  {&expense}

]                                                           no-undo.

define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    field obj-name as character
    index pi is primary unique obj-type obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 Btn_OK Btn_Cancel b-help ~
date_from date_to rs-1 bt-sel-host ed-doc-type bt-sel-doc-type
&Scoped-Define DISPLAYED-OBJECTS date_from date_to ed-object rs-1 ~
ed-doc-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-doc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON bt-sel-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON Btn_Cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-doc-type AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 35.8 BY 1.83 NO-UNDO.

DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 37.9 BY 6.53
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирмам", 2
     SIZE 13.8 BY 3.27 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.4 BY 7.33.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.3 BY 2.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.27 COL 1.5
     Btn_Cancel AT ROW 1.27 COL 11.5
     b-help AT ROW 1.27 COL 47.5
     date_from AT ROW 3.13 COL 8.3 COLON-ALIGNED
     date_to AT ROW 3.13 COL 25.1 COLON-ALIGNED
     ed-object AT ROW 4.97 COL 18.5 NO-LABEL
     rs-1 AT ROW 5.03 COL 3 NO-LABEL
     bt-sel-host AT ROW 7 COL 15
     ed-doc-type AT ROW 12.13 COL 16.3 NO-LABEL
     bt-sel-doc-type AT ROW 12.17 COL 52.8
     "Типы" VIEW-AS TEXT
          SIZE 12 BY .87 AT ROW 12.2 COL 2.1
     "договоров" VIEW-AS TEXT
          SIZE 12 BY .87 AT ROW 13.07 COL 2.3
     RECT-1 AT ROW 4.43 COL 1.9
     RECT-2 AT ROW 12 COL 1.5
     SPACE(1.44) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Диапазон дат для экспорта".


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

ASSIGN
       ed-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Диапазон дат для экспорта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-doc-type Dialog-Frame
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame /* ... */
DO:

    define variable v-cancel     as logical           no-undo.
    define variable v-oper-num   as integer           no-undo.
    run bge/bgeseltp.w (
          input "contract":U
        , input p-init-doc-type-list
        , output p-doc-type-list
        , output v-cancel
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора типов операций."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = yes
    then do:
        assign
            p-doc-type-list = p-init-doc-type-list
        .
    end.
    else do:
        assign
            p-init-doc-type-list    = p-doc-type-list
        .
        if p-doc-type-list = ''
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = ''
            .
            do v-oper-num = 1 to 2
            :
                if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], p-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + {&new-line}
                    .
                end.
            end.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-host Dialog-Frame
ON CHOOSE OF bt-sel-host IN FRAME Dialog-Frame /* ... */
DO:
    assign
        rs-1 :screen-value  = "2"
    .

    define buffer buf_user-host for ub.user-host .
    define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .

    find first buf_user-host no-lock
      where buf_user-host.db-num    = v-cntxt-db-num
        and buf_user-host.user-id   = v-cntxt-userid
        and buf_user-host.host-code = v-cntxt-host-code-obj
      no-error .
    if available buf_user-host
    then do:
      run userhsts_clear in this-procedure .
      run userhsts_append in this-procedure
        (input v-cntxt-host-code-obj
        ) .
    end.

    define variable v-user-select as logical   no-undo .
    { gbl/uhstsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-user-select
    }
    if v-user-select <> true
    then do:
      return no-apply .
    end.

    run clear-obj-list in this-procedure .

    for each buf_userhsts_temp-user-host
    :
      run fill-obj-list in this-procedure
        (input buf_userhsts_temp-user-host.host-code
        ) no-error .
      if error-status :error
      then do:
        return no-apply.
      end.
    end.

    assign
        v-obj-list = ""
    .
    for each temp_obj-list:
        assign v-obj-list = v-obj-list + (if v-obj-list <> "" then {&new-line} else "" )
                           + temp_obj-list.obj-type + string( temp_obj-list.obj-code ) + {&space-char}
                           + temp_obj-list.obj-name
                                    .
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel = yes
    .
    apply "window-close" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    ASSIGN
        date_from
        date_to
        rs-1
        date_exp_from = date_from
        date_exp_to   = date_to
    .
    if date_from > date_to
    then do:
        message
            "Даты интервала заданы неверно. "
            skip " Нижняя дата интервала должна быть меньше верхней."
            skip(1) "Задайте интервал дат правильно или отмените экспорт."
        view-as alert-box information.
        apply "entry" to date_from.
        undo, return no-apply.
    end.
      case rs-1 :screen-value
      :
      when "1"
      then do:
          assign
              p-range = 1
              p-obj-list = ""
          .
      end.
      when "2"
      then do:
          assign
              p-range = 2
          .
          assign
              p-obj-list = ""
          .
          for each temp_obj-list
          :
              assign
                  p-obj-list = p-obj-list
                          + ( if p-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                          + "," + string( temp_obj-list.obj-code )
              .
          end.
      end.
      end case.
   APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_from Dialog-Frame
ON RETURN OF date_from IN FRAME Dialog-Frame /* Дата с */
DO:
    APPLY "ENTRY" TO date_to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_to Dialog-Frame
ON RETURN OF date_to IN FRAME Dialog-Frame /* по */
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
run object-select in this-procedure no-error .
if error-status :error
then do:
    undo, return no-apply.
end.
assign
    rs-1
.
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
{ gbl/ed_date.i date_from }
{ gbl/ed_date.i date_to   }

run cur-time in this-procedure ( output v-today
                               , output v-time

                               ).
ASSIGN
    date_from = v-today
    date_to   = v-today
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get }

    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-cntxt-host-code-obj
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-cntxt-host-code-obj ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( v-cntxt-host-code-obj )
        .
    end.
  RUN enable_UI.
    assign
        ed-doc-type :screen-value = {&new-line} + "    Все"
    .


   run init-fields in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-obj-list Dialog-Frame
PROCEDURE clear-obj-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp_obj-list for temp_obj-list .

  do
  on error undo, return error return-value
  :
    for each buf_temp_obj-list
    on error undo, return error return-value
    :
      delete buf_temp_obj-list .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY date_from date_to ed-object rs-1 ed-doc-type
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 Btn_OK Btn_Cancel b-help date_from date_to rs-1
         bt-sel-host ed-doc-type bt-sel-doc-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-obj-list Dialog-Frame
PROCEDURE fill-obj-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define input  parameter p-host-code as integer   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_clients for ub.clients.

    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = p-host-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена фирма с кодом" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    create temp_obj-list.
    assign
      temp_obj-list.obj-type = buf_clients.obj-type
      temp_obj-list.obj-code = buf_clients.obj-code
      temp_obj-list.obj-name = buf_clients.obj-name
    .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-cntxt-host-code-obj
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE. /* get-host-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

  define variable v-oper-num     as integer           no-undo.

  define buffer buf_user-host for ub.user-host.

  find first buf_user-host no-lock
    where buf_user-host.db-num    = v-cntxt-db-num
      and buf_user-host.user-id   = v-cntxt-userid
      and buf_user-host.host-code = v-cntxt-host-code-obj
    no-error .
  if available buf_user-host
  then do:
      run clear-obj-list in this-procedure .
      run fill-obj-list in this-procedure
        (input  buf_user-host.host-code
        ) no-error .
  end.

   assign
        p-doc-type-list = p-init-doc-type-list
    .
    assign
        rs-1 :screen-value in frame dialog-frame = "2"
        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-cntxt-host-code-obj ) + " " + v-host-name
    .
    assign
        rs-1
    .
    display rs-1
    with frame {&frame-name}
    .
if p-init-doc-type-list <> ?
    and p-init-doc-type-list <> ''
    then do:
        do v-oper-num = 1 to 2
        :
            if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], p-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + {&new-line}
                .
            end.
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame
PROCEDURE object-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
case rs-1 :screen-value in frame Dialog-frame
:
    when "1"
    then do:
        assign
            ed-object :screen-value = ""
        .
    end.
    when "2"
    then do:
        for each temp_obj-list
        :
            delete temp_obj-list.
        end.
        create temp_obj-list.
        assign
            temp_obj-list.obj-type = {&cmp}
            temp_obj-list.obj-code = v-cntxt-host-code-obj
            ed-object :screen-value = temp_obj-list.obj-type + string(temp_obj-list.obj-code) + {&space-char} + "(":U + v-host-name + ")":U
        .
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME