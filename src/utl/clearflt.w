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

Интерфейс очистки пользовательских фильтров

Автор: Хныкин Павел Андреевич
Дата создания: 04/25/08
Author: Pavel Khnykin
Creation date: 04/25/08

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Интерфейс очистки пользовательских фильтров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc  as handle no-undo .
/* Local Variable Definitions ---                                       */
define variable v-userid as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-del B-help tg-filters fi-nik ~
b-sel-user tg-usr-flt
&Scoped-Define DISPLAYED-OBJECTS tg-filters fi-nik tg-usr-flt

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-imp-exp
     LABEL "&Имп/Эксп"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-user DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.

DEFINE VARIABLE fi-nik AS CHARACTER FORMAT "X(256)":U
     LABEL "Пользователь"
     VIEW-AS FILL-IN
     SIZE 31 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE tg-filters AS LOGICAL INITIAL no
     LABEL "Фильтры"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

DEFINE VARIABLE tg-usr-flt AS LOGICAL INITIAL no
     LABEL "Настройки"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-imp-exp AT ROW 1 COL 11 WIDGET-ID 6
     b-del AT ROW 1 COL 21 WIDGET-ID 16
     B-help AT ROW 1 COL 51 WIDGET-ID 12
     tg-filters AT ROW 3 COL 2 WIDGET-ID 18
     fi-nik AT ROW 4 COL 28 COLON-ALIGNED WIDGET-ID 22
     b-sel-user at row 4 col 61.5 WIDGET-ID 24
     tg-usr-flt AT ROW 4.17 COL 2 WIDGET-ID 20
     SPACE(53.36) SKIP(1.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Удаление фильтров" WIDGET-ID 100.


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

/* SETTINGS FOR BUTTON b-imp-exp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       fi-nik:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Удаление фильтров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:

  assign
    tg-filters
    tg-usr-flt
  .
  run proc-delete in this-procedure no-error .
  if error-status :error then do:
    message
      "Ошибка при вызове процедуры удаления фильтров." skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
      return-value
    view-as alert-box information.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-imp-exp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-imp-exp Dialog-Frame
ON CHOOSE OF b-imp-exp IN FRAME Dialog-Frame /* Имп/Эксп */
DO:
  run proc-import-export in this-procedure no-error .
  if error-status :error then do:
    message
      "Ошибка при вызове утилиты импорта-экспорта." skip
      error-status :get-message(1) skip
      error-status :get-message(2) skip
      return-value
    view-as alert-box information.
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-user
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-user Dialog-Frame
ON CHOOSE OF b-sel-user IN FRAME Dialog-Frame
DO:
  run proc-sel-user in this-procedure no-error .
  if error-status :error then do:
    assign
      fi-nik = ""
      fi-nik:private-data = ""
    .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-usr-flt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-usr-flt Dialog-Frame
ON VALUE-CHANGED OF tg-usr-flt IN FRAME Dialog-Frame /* Настройки */
DO:
  assign
    tg-usr-flt
  .
  if tg-usr-flt = yes
  then do :
    display
      fi-nik
      b-sel-user
    with frame {&frame-name}.
  end.
  else do:
    hide
      fi-nik
      b-sel-user
    .
    assign
      fi-nik = ""
      fi-nik:private-data = ""
    .
  end.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN my-enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN my-disable.

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
  DISPLAY tg-filters fi-nik tg-usr-flt
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-del B-help tg-filters fi-nik b-sel-user tg-usr-flt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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
  run disable_UI in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  display
    tg-filters
    tg-usr-flt
  with frame {&frame-name}.
  enable
    b-exit
    b-imp-exp
    b-del
    b-help
    b-sel-user
    tg-filters
    tg-usr-flt
  with frame {&frame-name}.
  hide
    fi-nik
    b-sel-user
  .
  view frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-delete Dialog-Frame
PROCEDURE proc-delete :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define buffer buf_filter  for ubflt.filter.
  define buffer buf_usr-flt for ubflt.usr-flt.

  define variable v-i           as integer   no-undo .
  define variable v-j           as integer   no-undo .
  define variable v-log         as logical   no-undo .
  define variable v-user-id     as character no-undo .
  define variable v-old-user-id as character no-undo .
  define variable v-str         as character no-undo .

  if ( tg-filters = no ) and ( tg-usr-flt = no)
  then do:
    return.
  end.

  message
    "Удалить?" skip
    "ВНИМАНИЕ! Предварительно рекомендуется экспортировать фильтры (Имп/Эксп)."
  view-as alert-box question buttons yes-no update v-log.

  if( v-log = no ) then do:
    return.
  end.

  if ( tg-usr-flt = yes ) then do:
    if fi-nik <> "" then do:
      message
        substitute( "Удалить все настройки для пользователя &1 ?" , fi-nik )
      view-as alert-box question buttons yes-no update v-log.
    end.
    else do:
      message
        "Пользователь не выбран. Удалить настройки для ВСЕХ пользователей?":U
      view-as alert-box question buttons yes-no update v-log.
    end.

    if( v-log = no ) then do:
      return.
    end.

  end.
  { gbl/working.i }
  del-block:
  do on error undo del-block, return error return-value
  :
    for each buf_filter exclusive-lock
    :
      assign
        v-i = v-i + 1
      .
      delete buf_filter.
    end.

    if( tg-usr-flt = yes )
    then do:
      if( fi-nik <> "" ) then do:
        assign
          v-str = fi-nik:private-data in frame {&frame-name}
        .
        if num-entries( v-str , {&delim-par} ) > 1
        then do:
          assign
            v-user-id     = entry( 1 , v-str , {&delim-par} )
            v-old-user-id = entry( 2 , v-str , {&delim-par} )
          .
        end.
        for each buf_usr-flt exclusive-lock
          where ( buf_usr-flt.user-name = v-user-id ) or
                ( buf_usr-flt.user-name = v-old-user-id and v-old-user-id <> "" )
        :
          assign
            v-j = v-j + 1
          .
          delete buf_usr-flt.
        end.

      end.
      else do:
        for each buf_usr-flt exclusive-lock
        :
          assign
            v-j = v-j + 1
          .
          delete buf_usr-flt.
        end.
      end.
    end.
  end.
  { gbl/stopwork.i }
  message
    substitute("Фильтров удалено: &1.&2Настроек удалено: &3" , v-i , {&new-line}, v-j )
  view-as alert-box information.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-import-export Dialog-Frame
PROCEDURE proc-import-export :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  run utl/exp-imp.w ( input parparentproc ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-user Dialog-Frame
PROCEDURE proc-sel-user :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define buffer buf_user-account for ub.user-account.

  define variable v-user-nik    as character no-undo .
  define variable v-selected-userid like ub.user-account.user-id        no-undo .
  define variable v-old-userid      like ub.user-account.parent-user-id no-undo .

  { gbl/getcntxt.i get }

  run str/usersel.p ( input parparentproc
                    , input v-cntxt-userid
                    , output v-selected-userid
                    , output v-old-userid
                    ).

  find buf_user-account no-lock
    where buf_user-account.user-id = v-selected-userid
  no-error .
  if available buf_user-account then do:
    assign
      fi-nik = buf_user-account.nik
      fi-nik:private-data in frame {&frame-name} = buf_user-account.user-id + {&delim-par} + v-old-userid
    .
    display
      fi-nik
    with frame {&frame-name}.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME