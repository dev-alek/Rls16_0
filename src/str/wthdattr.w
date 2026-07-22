&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Редактирование атрибутов документа МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/22/08
Author: Polina Gridchina
Creation date: 04/22/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибутов документа МЦ".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/wthcalib.i }
{ cmp/showinf.i  }
{ str/attrlist.i }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo.
define input parameter parbtn as character no-undo.
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo.
define input parameter table for tt-upd-attr .

/* Local Variable Definitions ---                                       */
define variable varrec-id as recid no-undo.
define variable v-no-news as logical   no-undo init false .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-doc-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.wth-doc-attr tt-upd-attr

/* Definitions for BROWSE b-doc-attr                                    */
&Scoped-define FIELDS-IN-QUERY-b-doc-attr tt-upd-attr.label-attr ub.wth-doc-attr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-doc-attr
&Scoped-define SELF-NAME b-doc-attr
&Scoped-define QUERY-STRING-b-doc-attr FOR EACH ub.wth-doc-attr       WHERE ub.wth-doc-attr.doc-code = pardoc-code, ~
             first tt-upd-attr where tt-upd-attr.code = ub.wth-doc-attr.attr-code and                                        tt-upd-attr.output-display = yes  NO-LOCK
&Scoped-define OPEN-QUERY-b-doc-attr OPEN QUERY {&SELF-NAME} FOR EACH ub.wth-doc-attr       WHERE ub.wth-doc-attr.doc-code = pardoc-code, ~
             first tt-upd-attr where tt-upd-attr.code = ub.wth-doc-attr.attr-code and                                        tt-upd-attr.output-display = yes  NO-LOCK .
&Scoped-define TABLES-IN-QUERY-b-doc-attr ub.wth-doc-attr tt-upd-attr
&Scoped-define FIRST-TABLE-IN-QUERY-b-doc-attr ub.wth-doc-attr
&Scoped-define SECOND-TABLE-IN-QUERY-b-doc-attr tt-upd-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-doc-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-doc-attr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-doc-attr FOR
      ub.wth-doc-attr,
      tt-upd-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-doc-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-doc-attr Dialog-Frame _FREEFORM
  QUERY b-doc-attr NO-LOCK DISPLAY
      tt-upd-attr.label-attr COLUMN-LABEL "Код" FORMAT "X(40)"
      ub.wth-doc-attr.attr-value COLUMN-LABEL "Значение" FORMAT "X(60)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 19.29.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11
     b-lkp AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-del AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     b-doc-attr AT ROW 2.46 COL 1.75
     SPACE(0.00) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты документа МЦ"
         DEFAULT-BUTTON b-exit.


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
/* BROWSE-TAB b-doc-attr b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-del IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-lkp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-doc-attr
/* Query rebuild information for BROWSE b-doc-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.wth-doc-attr
      WHERE ub.wth-doc-attr.doc-code = pardoc-code,
      first tt-upd-attr where tt-upd-attr.code = ub.wth-doc-attr.attr-code and
                                       tt-upd-attr.output-display = yes  NO-LOCK .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "doc-attr.doc-code = pardoc-code"
     _Query            is OPENED
*/  /* BROWSE b-doc-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Атрибуты документа МЦ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  assign
    varrec-id = recid(ub.wth-doc-attr).
  run st-attr in this-procedure no-error.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  if varrec-id <> ? then reposition {&browse-name} to recid varrec-id.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable vartemp-char as character  no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable jj as integer no-undo .
DEFINE VARIABLE v-setted as logical no-undo .

if available tt-upd-attr then do:

  if tt-upd-attr.user-can-edit then do:

    do jj = 1 to num-entries(tt-upd-attr.other, {&slash-char}):
    if entry(1, entry(jj, tt-upd-attr.other, {&slash-char}), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, tt-upd-attr.other, {&slash-char}), "=":U))
      .
      end.
    end.


    assign
        vartemp-char = ub.wth-doc-attr.attr-value.
    if v-spr = "":u then do:
      run gbl/d-prompt.w (
         'title=':u + 'Изменение атрибутов документа' + '\':u
        + 'text1=':u + tt-upd-attr.label-attr + '\':u
        + 'format=' + tt-upd-attr.format-attr + '\':u
        + 'type=' + tt-upd-attr.type-attr + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
        + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
        + 'max-chars=70\':u
        + 'readonly=' + 'no':u + '\':u
        , input-output vartemp-char
        ) no-error.
        if error-status:error then do:
            message "Ошибка при изменении атрибута." skip
                    return-value skip
                    error-status:get-message(1) view-as alert-box error.
            return no-apply.
        end.
        if return-value = 'false':u then do:
          return no-apply.
        end.
     end.
     else do:
      run  value(v-spr) in this-procedure (
                                          input parparentproc
                                          ,input {&update}
                                          ,input-output vartemp-char
                                          ,output v-setted) no-error .

      if not v-setted then return.
     end.

     { str/wthatwrt.i
         ub.wth-doc-attr.doc-code
         ub.wth-doc-attr.attr-code
         vartemp-char
         no-error
     }
     if error-status :error then do:
       message "Ошибка при сохранении атрибута." view-as alert-box.
       undo, return no-apply.
     end.
     assign
       varrec-id = recid(ub.wth-doc-attr).
     if not v-no-news  then do:
          { str/wthatoth.i
              ub.wth-doc-attr.doc-code
              ub.wth-doc-attr.attr-code
              vartemp-char
              no-error
          }
          if error-status :error then do:
            message "Ошибка при обработке атрибута." view-as alert-box.
            undo, return no-apply.
          end.
     end.


     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     reposition {&browse-name} to recid varrec-id.
  end.
  else do:
     message "Атрибут " tt-upd-attr.label-attr " не редактируется в данном интерфейсе."
     view-as alert-box.
     return no-apply.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable varg-log  as logical no-undo.
define variable v-deleted as logical no-undo.
define variable vartemp-char as character  no-undo.
do on error undo, return no-apply :
if available tt-upd-attr then do:
  message "Вы хотите удалить атрибут " tt-upd-attr.label-attr " ?" view-as alert-box
  question buttons yes-no update varg-log.
  if varg-log then do:
    { str/wthatdel.i
        ub.wth-doc-attr.doc-code
        ub.wth-doc-attr.attr-code
        v-deleted
        no-error
    }
    if error-status :error then do:
      message "Ошибка при удалении атрибута." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box.
      undo, return no-apply.
    end.
    if not v-no-news  then do:
          { str/wthatoth.i
              ub.wth-doc-attr.doc-code
              ub.wth-doc-attr.attr-code
              vartemp-char
              no-error
          }
          if error-status :error then do:
            message "Ошибка при обработке атрибута." view-as alert-box.
            undo, return no-apply.
          end.
     end.

    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.
end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
define variable vartemp-char as character  no-undo.
DEFINE VARIABLE v-spr as character no-undo .
define variable jj as integer no-undo .
DEFINE VARIABLE v-setted as logical no-undo .

if available tt-upd-attr then do:

    do jj = 1 to num-entries(tt-upd-attr.other, {&slash-char}):
    if entry(1, entry(jj, tt-upd-attr.other, {&slash-char}), "=":U) = "spr":U
    then do:
      assign
      v-spr = string(entry(2, entry(jj, tt-upd-attr.other, {&slash-char}), "=":U))
      .
      end.
    end.

    assign
        vartemp-char = ub.wth-doc-attr.attr-value.
    if v-spr = "":u then do:
        assign
        vartemp-char = ub.wth-doc-attr.attr-value.
        run gbl/d-prompt.w (
              'title=':u + 'Изменение атрибутов документа' + '\':u
            + 'text1=':u + tt-upd-attr.label-attr + '\':u
            + 'format=' + tt-upd-attr.format-attr + '\':u
            + 'type=' + tt-upd-attr.type-attr + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
            + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
            + 'max-chars=70\':u
            + 'readonly=' + 'yes':u + '\':u
            , input-output vartemp-char
            ) no-error.
     end.
     else do:
      run  value(v-spr) in this-procedure (
                                          input parparentproc
                                          ,input {&lookup}
                                          ,input-output vartemp-char
                                          ,output v-setted) no-error .

     end.
end.

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-doc-attr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }

{ gbl/brwrefre.i }
{ gbl/brwrepos.i &line-num=4 }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup ("b-lkp", parbtn) > 0 then do:
    enable b-lkp with frame {&frame-name}.
  end.
/*  if lookup ("b-add", parbtn) > 0 then do:
    enable b-add with frame {&frame-name}.
  end.  */
  if lookup ("b-chg", parbtn) > 0 then do:
    enable b-chg with frame {&frame-name}.
  end.

  if lookup ("b-del", parbtn) > 0 then do:
    enable b-del with frame {&frame-name}.
  end.
  if lookup ("no-news", parbtn) > 0 then do:
     v-no-news = true .
  end.

  RUN enable_UI.
  apply 'entry':u to browse {&browse-name} .
  wait-for go of frame {&frame-name}.
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
  ENABLE b-exit b-help b-doc-attr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE st-attr Dialog-Frame
PROCEDURE st-attr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable varattr-code like ub.wth-doc-attr.attr-code no-undo.
  define buffer bf_wth-doc-attr for ub.wth-doc-attr.
  define variable vartemp-char as character no-undo.

  define buffer buf_wth-doc-attr for ub.wth-doc-attr .
  define buffer buf_tt-upd-attr for tt-upd-attr .

  do
  transaction on error undo, return error return-value
  :
    /* устанавливаем признаки на атрибутах, которые можно выбрать */
    for each buf_tt-upd-attr
    on error undo, return error return-value
    :
      find first buf_wth-doc-attr no-lock
        where buf_wth-doc-attr.doc-code  = pardoc-code
          and buf_wth-doc-attr.attr-code = buf_tt-upd-attr.code
        no-error .
      if available buf_wth-doc-attr
      then do:
        assign
          buf_tt-upd-attr.can-select = false
        .
      end.
      else do:
        assign
          buf_tt-upd-attr.can-select = true
        .
      end.
    end.

    run str/b-attr.w
      (input table tt-upd-attr
      ,output varattr-code
      ) no-error .
    if error-status :error
    then do:
      if return-value <> ""
      then do:
        message
          "Ошибка при выборе добавляемого атрибута."
          view-as alert-box error.
      end.
      undo, return error.
    end.
    find first tt-upd-attr where tt-upd-attr.code = varattr-code no-error.
    if not available tt-upd-attr then do:
      message "Не верно выбран атрибут для добавления." view-as alert-box error.
      undo, return error.
    end.
    if tt-upd-attr.user-can-edit <> yes then do:
      message "Атрибут нельзя добавить в данном интерфейсе." view-as alert-box.
      undo, return error.
    end.
    find first bf_wth-doc-attr where bf_wth-doc-attr.doc-code   = pardoc-code and
                                bf_wth-doc-attr.attr-code = varattr-code no-lock no-error.
    if available bf_wth-doc-attr then  do:
      message "Атрибут " tt-upd-attr.label-attr " уже есть в документе " pardoc-code " ."
      view-as alert-box error.
      undo, return error.
    end.
    create ub.wth-doc-attr.
    assign
      ub.wth-doc-attr.doc-code   = pardoc-code
      ub.wth-doc-attr.attr-code = varattr-code.
    run gbl/d-prompt.w (
          'title=':u + 'Изменение атрибутов документа' + '\':u
          + 'text1=':u + tt-upd-attr.label-attr + '\':u
          + 'format=' + tt-upd-attr.format-attr + '\':u
          + 'type=' + tt-upd-attr.type-attr + '\':u
          + 'fillin_row=2\':u
          + 'fillin_col=4\':u
          + 'fillin_width=':u  + string(tt-upd-attr.fillin_width) + '\':u
          + 'fillin_height=':u + string(tt-upd-attr.fillin_height) + '\':u
          + 'max-chars=70\':u
          + 'readonly=' + 'no':u + '\':u
          , input-output vartemp-char
          ) no-error.
    if error-status:error then do:
      message "Ошибка при изменении атрибута." skip
              return-value skip
              error-status:get-message(1) view-as alert-box error.
      undo, return error.
    end.
    if return-value = 'false':u then do:
      undo, return error.
    end.
    { str/wthatwrt.i
        ub.wth-doc-attr.doc-code
        ub.wth-doc-attr.attr-code
        vartemp-char
        no-error
    }
    if error-status :error then do:
        message "Ошибка при сохранении атрибута." view-as alert-box.
        undo, return error.
      end.
    assign
      varrec-id = recid(ub.wth-doc-attr).
     if not v-no-news  then do:
          { str/wthatoth.i
              ub.wth-doc-attr.doc-code
              ub.wth-doc-attr.attr-code
              vartemp-char
              no-error
          }
          if error-status :error then do:
            message "Ошибка при обработке атрибута." view-as alert-box.
            undo, return no-apply.
          end.
     end.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
