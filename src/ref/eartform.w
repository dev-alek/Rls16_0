&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_ext-artic FOR ub.ext-artic.
DEFINE BUFFER buf_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник внешних артикулов

Автор: Хныкин Павел Андреевич
Дата создания: 03/22/06
Author: Pavel Khnykin
Creation date: 03/22/06

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник внешних артикулов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i noprocess }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as widget-handle        no-undo .
define input  parameter p-mode        as character            no-undo .
define input  parameter p-gds-code    like ub.goods.gds-code  no-undo .

/* Local Variable Definitions ---                                       */
define variable g-log as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-ext-artic

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_ext-artic buf_clients

/* Definitions for BROWSE br-ext-artic                                  */
&Scoped-define FIELDS-IN-QUERY-br-ext-artic ~
(STRING (buf_ext-artic.cli-code, "999999999")  +  " "  +  TRIM (buf_ext-artic.cli-type)) ~
buf_clients.obj-name buf_ext-artic.ext-artic buf_ext-artic.status_ ~
buf_ext-artic.unit-cli buf_ext-artic.cli-base-rate ~
buf_ext-artic.unit-cli-ord buf_ext-artic.cli-base-rate-ord ~
buf_ext-artic.unit-cli-rcv buf_ext-artic.cli-base-rate-rcv
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-ext-artic
&Scoped-define QUERY-STRING-br-ext-artic FOR EACH buf_ext-artic NO-LOCK, ~
      EACH buf_clients WHERE ub.buf_ext-artic.cli-type = buf_clients.obj-type ~
  AND buf_ext-artic.cli-code = buf_clients.obj-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-ext-artic OPEN QUERY br-ext-artic FOR EACH buf_ext-artic NO-LOCK, ~
      EACH buf_clients WHERE ub.buf_ext-artic.cli-type = buf_clients.obj-type ~
  AND buf_ext-artic.cli-code = buf_clients.obj-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-ext-artic buf_ext-artic buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-ext-artic buf_ext-artic
&Scoped-define SECOND-TABLE-IN-QUERY-br-ext-artic buf_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-ext-artic}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-lkp b-chg b-del b-help ~
rs-stts br-ext-artic
&Scoped-Define DISPLAYED-FIELDS buf_goods.artic buf_goods.gds-name
&Scoped-define DISPLAYED-TABLES buf_goods
&Scoped-define FIRST-DISPLAYED-TABLE buf_goods
&Scoped-Define DISPLAYED-OBJECTS rs-stts

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE VARIABLE rs-stts AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие&+", 2,
"Все&!", 1,
"Неактивные&-", 3
     SIZE 34 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-ext-artic FOR
      buf_ext-artic,
      buf_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-ext-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-ext-artic Dialog-Frame _STRUCTURED
  QUERY br-ext-artic NO-LOCK DISPLAY
      (STRING (buf_ext-artic.cli-code, "999999999")  +  " "  +  TRIM (buf_ext-artic.cli-type)) COLUMN-LABEL "Код/Тип" FORMAT "X(13)":U
      buf_clients.obj-name FORMAT "X(40)":U
      buf_ext-artic.ext-artic FORMAT "X(16)":U
      buf_ext-artic.status_ FORMAT "X(8)":U
      buf_ext-artic.unit-cli COLUMN-LABEL "Ед.изм. пост.!в накладной" FORMAT "X(3)":U
      buf_ext-artic.cli-base-rate COLUMN-LABEL "Коэф. ед. пост.!в накл." FORMAT ">>,>>9.<<<<":U
      buf_ext-artic.unit-cli-ord COLUMN-LABEL "Ед.изм. пост.!в заказе" FORMAT "X(3)":U
      buf_ext-artic.cli-base-rate-ord COLUMN-LABEL "Коэф. ед. пост.!в заказе" FORMAT ">>,>>9.<<<<":U
      buf_ext-artic.unit-cli-rcv COLUMN-LABEL "Ед.изм. пост.!в поставке" FORMAT "X(3)":U
      buf_ext-artic.cli-base-rate-rcv COLUMN-LABEL "Коэф. ед. пост.!в пост." FORMAT ">>,>>9.<<<<":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 88.88 BY 10.25 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-add AT ROW 1 COL 11 WIDGET-ID 12
     b-lkp AT ROW 1 COL 21 WIDGET-ID 14
     b-chg AT ROW 1 COL 31 WIDGET-ID 16
     b-del AT ROW 1 COL 41 WIDGET-ID 18
     b-help AT ROW 1 COL 51 WIDGET-ID 10
     rs-stts AT ROW 2 COL 18.5 NO-LABEL WIDGET-ID 24
     buf_goods.artic AT ROW 3.04 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 20 FORMAT "X(16)"
          VIEW-AS FILL-IN
          SIZE 71.5 BY 1
          FGCOLOR 4
     buf_goods.gds-name AT ROW 4.04 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 22 FORMAT "X(48)"
          VIEW-AS FILL-IN
          SIZE 71.5 BY 1
          FGCOLOR 4
     br-ext-artic AT ROW 5 COL 1 WIDGET-ID 200
     "Статус:" VIEW-AS TEXT
          SIZE 8.5 BY 1 AT ROW 2 COL 10 WIDGET-ID 30
          FGCOLOR 4
     SPACE(71.38) SKIP(12.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Внешний артикул" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_ext-artic B "?" ? ub ext-artic
      TABLE: buf_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-ext-artic gds-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN buf_goods.artic IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN buf_goods.gds-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT EXP-HELP                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-ext-artic
/* Query rebuild information for BROWSE br-ext-artic
     _TblList          = "buf_ext-artic,buf_clients WHERE buf_ext-artic ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _JoinCode[2]      = "buf_ext-artic.cli-type = buf_clients.obj-type
  AND buf_ext-artic.cli-code = buf_clients.obj-code"
     _FldNameList[1]   > "_<CALC>"
"(STRING (buf_ext-artic.cli-code, ""999999999"")  +  "" ""  +  TRIM (buf_ext-artic.cli-type))" "Код/Тип" "X(13)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.buf_clients.obj-name
     _FldNameList[3]   = Temp-Tables.buf_ext-artic.ext-artic
     _FldNameList[4]   = Temp-Tables.buf_ext-artic.status_
     _FldNameList[5]   > Temp-Tables.buf_ext-artic.unit-cli
"buf_ext-artic.unit-cli" "Ед.изм. пост.!в накладной" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > Temp-Tables.buf_ext-artic.cli-base-rate
"buf_ext-artic.cli-base-rate" "Коэф. ед. пост.!в накл." ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.buf_ext-artic.unit-cli-ord
"buf_ext-artic.unit-cli-ord" "Ед.изм. пост.!в заказе" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.buf_ext-artic.cli-base-rate-ord
"buf_ext-artic.cli-base-rate-ord" "Коэф. ед. пост.!в заказе" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > Temp-Tables.buf_ext-artic.unit-cli-rcv
"buf_ext-artic.unit-cli-rcv" "Ед.изм. пост.!в поставке" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > Temp-Tables.buf_ext-artic.cli-base-rate-rcv
"buf_ext-artic.cli-base-rate-rcv" "Коэф. ед. пост.!в пост." ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-ext-artic */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Внешний артикул */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  run proc-b-add in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  { gbl/stdbtn.i }
  run proc-b-chg in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  { gbl/stdbtn.i }
  run proc-b-del in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  { gbl/stdbtn.i }
  run proc-b-lkp in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-ext-artic
&Scoped-define SELF-NAME br-ext-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ext-artic Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-ext-artic IN FRAME Dialog-Frame
DO:
  run proc-br-ext-artic in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ext-artic Dialog-Frame
ON RETURN OF br-ext-artic IN FRAME Dialog-Frame
DO:
  run proc-br-ext-artic in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-ext-artic Dialog-Frame
ON VALUE-CHANGED OF br-ext-artic IN FRAME Dialog-Frame
DO:
  run proc-br-ext-artic-value-change in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-stts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-stts Dialog-Frame
ON VALUE-CHANGED OF rs-stts IN FRAME Dialog-Frame
DO:
  run proc-rs-stts in this-procedure no-error .
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/hot-key.i b-lkp  }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }

{ gbl/app_help.i }
{ gbl/brwrepos.i &line-num=5 }
{ gbl/brwrefre.i "RUN open-br IN THIS-PROCEDURE ( input ? ) ." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  run my-enable in this-procedure .
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
  DISPLAY rs-stts
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_goods THEN
    DISPLAY buf_goods.artic buf_goods.gds-name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-add b-lkp b-chg b-del b-help rs-stts br-ext-artic
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
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
  no-error .
  if error-status :error
  then do:
    message
      substitute("Не найден товар с кодом &1" , p-gds-code)
    view-as alert-box information.
    undo, return error substitute("Не найден товар с кодом &1" , p-gds-code).
  end.
  assign
    rs-stts = 2
  .
  display
    rs-stts
    buf_goods.artic     when available buf_goods
    buf_goods.gds-name  when available buf_goods
  with frame {&frame-name}.
  enable
    b-exit
    b-add   when p-mode <> {&lookup}
    b-lkp
    b-chg   when p-mode <> {&lookup}
    b-del   when p-mode <> {&lookup}
    b-help
    rs-stts
    br-ext-artic
  with frame {&frame-name}.
  view frame {&frame-name}.
  run open-br in this-procedure (input ?).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-br Dialog-Frame
PROCEDURE open-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-recid as recid     no-undo .
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure ("Ждите...").

  case rs-stts:
    when 1
    then do:
      open query br-ext-artic
        for each buf_ext-artic no-lock
          where buf_ext-artic.gds-code = p-gds-code ,
        each buf_clients no-lock
          where buf_clients.obj-type = buf_ext-artic.cli-type
            and buf_clients.obj-code = buf_ext-artic.cli-code
      .
    end.
    when 2
    then do:
      open query br-ext-artic
        for each buf_ext-artic no-lock
          where buf_ext-artic.gds-code  = p-gds-code
            and buf_ext-artic.status_   = {&current-status} ,
        each buf_clients no-lock
          where buf_clients.obj-type = buf_ext-artic.cli-type
            and buf_clients.obj-code = buf_ext-artic.cli-code
      .
    end.
    when 3
    then do:
      open query br-ext-artic
        for each buf_ext-artic no-lock
          where buf_ext-artic.gds-code  = p-gds-code
            and buf_ext-artic.status_   = {&deleted-status} ,
        each buf_clients no-lock
          where buf_clients.obj-type = buf_ext-artic.cli-type
            and buf_clients.obj-code = buf_ext-artic.cli-code
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition br-ext-artic to recid p-recid no-error .
  end.
  apply "value-changed":U to br-ext-artic in frame {&frame-name}.
  run waitfram-hide in this-procedure .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define variable v-recid as recid no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ext-artic_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return error .

  run ref/ea-form.w ( input parParentProc
                    , input {&add-def}
                    , input p-gds-code
                    , input-output v-recid
                    , input 0
                    ) .
  run open-br in this-procedure ( input v-recid ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define variable v-recid as recid    no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ext-artic_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return error .

  if not available buf_ext-artic then return .
  if buf_ext-artic.status_ = {&deleted-status}
  then do:
    message
      substitute("Нельзя редактировать запись в статусе '&1'" , {&deleted-status})
    view-as alert-box information.
    return error.
  end.

  assign
    v-recid = recid( buf_ext-artic )
  .
  run ref/ea-form.w ( input parParentProc
                    , input {&update}
                    , input p-gds-code
                    , input-output v-recid
                    , input 0
                    ) .

  run open-br in this-procedure ( input v-recid ) .

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define buffer del_ext-artic for ub.ext-artic.

  define variable v-recid   as recid      no-undo .
  define variable v-next    as recid      no-undo .
  define variable v-is-del  as logical    no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ext-artic_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    g-log
  }
  if not g-log then  return error .

  if not available buf_ext-artic then return.

  if buf_ext-artic.status_ <> {&deleted-status}
  then do:
    message
      "Удалить запись?"
    view-as alert-box question buttons yes-no update v-is-del.
  end.
  else do:
    message
      "Восстановить запись?"
    view-as alert-box question buttons yes-no update v-is-del.
  end.

  if v-is-del = no then do:
    return .
  end.

  find first del_ext-artic no-lock
    where recid(del_ext-artic) = recid(buf_ext-artic)
  .

  assign
    v-recid = recid(del_ext-artic)
  .

  run ref/extartd.p ( input del_ext-artic.cli-type
                    , input del_ext-artic.cli-code
                    , input del_ext-artic.gds-code
                    , input if del_ext-artic.status_ = {&deleted-status} then {&current-status} else {&deleted-status}
                    ) no-error .
  if error-status :error then do:
    message
      return-value skip
      error-status :get-message(1)
    view-as alert-box error.
    return error.
  end.

  run open-br in this-procedure ( input v-recid ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define variable v-recid as recid    no-undo .

  if not available buf_ext-artic then return .

  assign
    v-recid = recid( buf_ext-artic )
  .
  run ref/ea-form.w ( input parParentProc
                    , input {&lookup}
                    , input p-gds-code
                    , input-output v-recid
                    , input 0
                    ) .
  run open-br in this-procedure ( input v-recid ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-ext-artic Dialog-Frame
PROCEDURE proc-br-ext-artic :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  if b-lkp :sensitive in frame {&frame-name} then do:
    run proc-b-lkp in this-procedure .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-ext-artic-value-change Dialog-Frame
PROCEDURE proc-br-ext-artic-value-change :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  if available(buf_ext-artic)
  then do:
    if buf_ext-artic.status_ = {&deleted-status}
    then do:
      assign
        b-del :label in frame {&frame-name} = "В&осстанов":U
      .
    end.
    else do:
      assign
        b-del :label in frame {&frame-name} = "&Удалить":U
      .
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-rs-stts Dialog-Frame
PROCEDURE proc-rs-stts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  assign frame {&frame-name}
    rs-stts
  .

  define variable v-recid as recid     no-undo .

  if available buf_ext-artic
  then do:
    assign
      v-recid = recid(buf_ext-artic)
    .
  end.

  run open-br in this-procedure ( v-recid ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
