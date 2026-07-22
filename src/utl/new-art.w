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

Процедура переименования артикула товара

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parParentProc   as   handle             no-undo .
define input parameter p-old-artic     like ub.goods.artic     no-undo .
define input parameter p-old-prod-type like ub.goods.prod-type no-undo .
define input parameter p-old-prod-code like ub.goods.prod-code no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура переименования артикула товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ nws/db-rec.i   }
{ gbl/key-rec.i  }
{ gbl/waitfram.i }

define stream log .

define temp-table temp-goods no-undo
  field artic     like ub.goods.artic
  field prod-type like ub.goods.prod-type
  field prod-code like ub.goods.prod-code
  field new-artic like ub.goods.artic label "Новый артикул" column-label "Новый артикул"
  field gds-code  like ub.goods.gds-code

  index xpk is primary artic prod-type prod-code
.

define variable rid-list as character no-undo.

def buffer new-clients for ub.clients.

define variable v-key-rec      as character no-undo .
define variable v-param        as character no-undo .
define variable v-not-two-commit as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.clients

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.clients SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.clients SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.clients


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK Btn_RenameAll b-help ~
sel-gds new-artic new-prod-code new-prod-type sel-new-prod
&Scoped-Define DISPLAYED-OBJECTS old-artic v-gds-name old-prod-code ~
old-prod-type old-clobjname new-artic new-prod-code new-prod-type ~
new-clobjname

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

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "Переименовать"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_RenameAll
     LABEL "Все Автоматически"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON sel-gds
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 2.63 BY 1.

DEFINE BUTTON sel-new-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY .96.

DEFINE VARIABLE new-artic AS CHARACTER FORMAT "X(16)"
     LABEL "Новый Артикул"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE new-clobjname AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE new-prod-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Новый производитель"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE new-prod-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE old-artic AS CHARACTER FORMAT "X(16)"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE old-clobjname AS CHARACTER FORMAT "X(40)"
     VIEW-AS FILL-IN
     SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE old-prod-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE old-prod-type AS CHARACTER FORMAT "X(3)"
     VIEW-AS FILL-IN
     SIZE 4.25 BY 1 NO-UNDO.

DEFINE VARIABLE v-gds-name LIKE ub.goods.gds-name
     VIEW-AS FILL-IN
     SIZE 43 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.clients SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 11
     Btn_RenameAll AT ROW 1 COL 31
     b-help AT ROW 1 COL 51
     old-artic AT ROW 2.5 COL 22 COLON-ALIGNED
     v-gds-name AT ROW 2.5 COL 41 COLON-ALIGNED NO-LABEL
     old-prod-code AT ROW 3.67 COL 22 COLON-ALIGNED
     old-prod-type AT ROW 3.67 COL 32.25 COLON-ALIGNED NO-LABEL
     old-clobjname AT ROW 3.67 COL 41 COLON-ALIGNED HELP
          "Укажите название объекта учета товаров" NO-LABEL
     sel-gds AT ROW 3.75 COL 39.63
     new-artic AT ROW 4.83 COL 22 COLON-ALIGNED
     new-prod-code AT ROW 6.04 COL 22 COLON-ALIGNED
     new-prod-type AT ROW 6.04 COL 32.25 COLON-ALIGNED NO-LABEL
     new-clobjname AT ROW 6.04 COL 41 COLON-ALIGNED NO-LABEL
     sel-new-prod AT ROW 6.08 COL 39.63
     SPACE(45.36) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение артикула"
         DEFAULT-BUTTON Btn_Cancel CANCEL-BUTTON Btn_Cancel.


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

/* SETTINGS FOR FILL-IN new-clobjname IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN old-artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN old-clobjname IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN old-prod-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN old-prod-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN v-gds-name IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.goods.gds-name EXP-SIZE                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.clients"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение артикула */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Выход  */
DO:
  /*
    message "2" view-as alert-box.
  find goods where goods.artic     = new-artic
               and goods.prod-type = new-prod-type
               and goods.prod-code = new-prod-code
             .
  message "2-" goods.artic skip goods.gds-code view-as alert-box.
  */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Переименовать */
DO:
  assign
    old-artic
    old-prod-type
    old-prod-code
    new-artic
    new-prod-type
    new-prod-code
  .
  run validate-prod in this-procedure
    ( input new-prod-type
     ,input new-prod-code
    ) no-error.
  if error-status :error then do:
    apply "entry" to new-prod-code in frame {&frame-name}.
    return no-apply.
  end.

  run rename-artic in this-procedure
    ( input old-artic
     ,input old-prod-type
     ,input old-prod-code
     ,input new-artic
     ,input new-prod-type
     ,input new-prod-code
    ) no-error .
  if error-status :error then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_RenameAll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_RenameAll Dialog-Frame
ON CHOOSE OF Btn_RenameAll IN FRAME Dialog-Frame /* Все Автоматически */
DO:

  /* находим все товары с неавтоматическим артикулом */
  run process-goods in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME new-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL new-artic Dialog-Frame
ON RETURN OF new-artic IN FRAME Dialog-Frame /* Новый Артикул */
DO:
  APPLY "CHOOSE":U TO btn_Ok IN FRAME {&Frame-Name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME new-prod-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL new-prod-code Dialog-Frame
ON RETURN OF new-prod-code IN FRAME Dialog-Frame /* Новый производитель */
OR LEAVE OF new-prod-code IN FRAME {&frame-name} /* Новый производитель */
OR RETURN OF new-prod-type IN FRAME {&frame-name} /* Новый производитель */
OR LEAVE OF new-prod-type IN FRAME {&frame-name} /* Новый производитель */
DO:
  define buffer buf_clients for ub.clients.
  assign
    new-prod-code
    new-prod-type
  .
  find first buf_clients no-lock
    where buf_clients.obj-type = new-prod-type
      and buf_clients.obj-code = new-prod-code
    no-error
  .
  if available buf_clients then do:
    assign
      new-clobjname:screen-value = buf_clients.obj-name
    .
  end.
  else do:
    assign
      new-clobjname:screen-value = '???'
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME old-prod-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL old-prod-code Dialog-Frame
ON RETURN OF old-prod-code IN FRAME Dialog-Frame /* Производитель */
OR LEAVE OF old-prod-code IN FRAME {&frame-name} /* Новый производитель */
OR RETURN OF old-prod-type IN FRAME {&frame-name} /* Новый производитель */
OR LEAVE OF old-prod-type IN FRAME {&frame-name} /* Новый производитель */
DO:
  define buffer buf_clients for ub.clients.
  assign
    old-prod-code
    old-prod-type
  .
  find first buf_clients no-lock
    where buf_clients.obj-type = old-prod-type
      and buf_clients.obj-code = old-prod-code
    no-error
  .
  if available buf_clients then do:
    assign
      old-clobjname:screen-value = buf_clients.obj-name
    .
  end.
  else do:
    assign
      old-clobjname:screen-value = '???'
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sel-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sel-gds Dialog-Frame
ON CHOOSE OF sel-gds IN FRAME Dialog-Frame /* Button 1 */
DO:
  define buffer buf-sel_goods for ub.goods .
  define buffer buf_clients for ub.clients .

  run ref/gds-ref.p ( input parParentProc
                ,input "{&lookup},b-sel"
                ,input ?               /*p-stat */
                ,input ?               /*p-list  */
                ,input ?               /*p-cond  */
                ,input ?               /*p-rec   */
                ,input ?               /*p-grp   */
                ,input ?               /*p-cli-type */
                ,input ?               /*p-cli-code  */
                ,input ?               /*p-obj-type  */
                ,input ?               /*p-obj-code  */
                ,input ?               /*p-other     */
                ,output rid-list
               ).
  find first buf-sel_goods share-lock
    where recid(buf-sel_goods) = integer(rid-list)
    no-error
    .

  if not available buf-sel_goods then do:
    assign
      v-gds-name   :screen-value = ''
      old-artic    :screen-value = ''
      old-prod-type:screen-value = ''
      old-prod-code:screen-value = ''
      old-clobjname:screen-value = ''
      new-artic    :screen-value = ''
      new-prod-type:screen-value = ''
      new-prod-code:screen-value = ''
      new-clobjname:screen-value = ''
    .
    return .
  end.
  find first buf_clients share-lock
    where buf_clients.obj-type = buf-sel_goods.prod-type
      and buf_clients.obj-code = buf-sel_goods.prod-code
    .
  assign
    v-gds-name    = buf-sel_goods.gds-name
    old-artic     = buf-sel_goods.artic
    old-prod-type = buf-sel_goods.prod-type
    old-prod-code = buf-sel_goods.prod-code
    old-clobjname = buf_clients.obj-name
    new-artic     = buf-sel_goods.artic
    new-prod-type = buf-sel_goods.prod-type
    new-prod-code = buf-sel_goods.prod-code
    new-clobjname = buf_clients.obj-name
  .
  display
    v-gds-name
    old-artic
    old-prod-type
    old-prod-code
    old-clobjname
    new-clobjname
    new-prod-type
    new-prod-code
    new-artic
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sel-new-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sel-new-prod Dialog-Frame
ON CHOOSE OF sel-new-prod IN FRAME Dialog-Frame
DO:

  assign
    rid-list = ""
  .
  run ref/cli-all.w ( parParentProc, "b-sel", {&pro}, {&all}, {&current}, ?, ",,,,,,NO,,,", "news", output rid-list ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при выборе клиента" skip
      view-as alert-box error .
    return no-apply .
  end.

  find new-clients no-lock
    where recid(new-clients) = integer(rid-list)
    no-error .
  if available new-clients then do:
    assign
      new-prod-type = new-clients.obj-type
      new-prod-code = new-clients.obj-code
      new-clobjname = new-clients.obj-name
    .
    disp
      new-prod-type
      new-prod-code
      new-clobjname
      with frame {&frame-name}.
  end.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:

  define buffer buf_db for ub.db .
  define buffer buf-main_goods for ub.goods .

  assign
    v-not-two-commit = true
  .

  if  p-old-artic <> ?
  and p-old-prod-type <> ?
  and p-old-prod-code <> ?
  then do:
    do transaction
    on error undo main-block, return error return-value
    :
      find buf-main_goods exclusive-lock
        where buf-main_goods.artic     = p-old-artic
          and buf-main_goods.prod-type = p-old-prod-type
          and buf-main_goods.prod-code = p-old-prod-code
        no-error
      .
      if not available buf-main_goods
        and g#news = true
      then do:
        return error substitute( "Не найден товар:", p-old-artic, p-old-prod-type, p-old-prod-code ) .
      end.
      else do:
        assign
          old-artic     = p-old-artic
          old-prod-type = p-old-prod-type
          old-prod-code = p-old-prod-code
          new-prod-type = p-old-prod-type
          new-prod-code = p-old-prod-code
        .
      end.
    end.
  end.
  RUN enable_UI.
  if g#news = true then do:
    /* это разбор коллизии на УБД поэтому two-commit не используем */
    assign
      v-not-two-commit = true
    .
    DISABLE sel-gds Btn_RenameAll Btn_Cancel with frame {&frame-name}.
    HIDE sel-gds Btn_RenameAll Btn_Cancel in frame {&frame-name}.
  end.
  else do:
    find first buf_db no-lock
      where buf_db.db-num > 0
/*        and buf_db.db-key <> "" Так нельзя потому что могут возникнуть проблемы при выгрузке УБД */
/*        and buf_db.db-key <> ?*/
      no-error .
    if available buf_db then do:
      assign
        v-not-two-commit = false
      .
    end.
  end.
  if p-old-artic <> ?
    and p-old-prod-type <> ?
    and p-old-prod-code <> ?
  then do:
    DISABLE sel-gds Btn_RenameAll with frame {&frame-name}.
    HIDE sel-gds Btn_RenameAll in frame {&frame-name}.
  end.

  if g#news = true then do:
    WAIT-FOR "CHOOSE" OF Btn_OK IN FRAME {&FRAME-NAME}.
  end.
  else do:
    WAIT-FOR "CHOOSE" OF Btn_Cancel IN FRAME {&FRAME-NAME}.
  end.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY old-artic v-gds-name old-prod-code old-prod-type old-clobjname
          new-artic new-prod-code new-prod-type new-clobjname
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_OK Btn_RenameAll b-help sel-gds new-artic new-prod-code
         new-prod-type sel-new-prod
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-goods Dialog-Frame
PROCEDURE process-goods :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable error-message as character no-undo .

  define variable v-new-artic as character no-undo .
  define variable icount as integer no-undo .
  define variable i-rename-count as integer no-undo init 0 .
  define variable v-bar-code like ub.bar-code.b-code no-undo .

  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf-all_goods for ub.goods .

  define variable lOK as logical no-undo init false .

  message
    "Просмотреть все товары, для определения товаров," skip
    "которые не имеют автоматического артикула?" skip
    view-as alert-box question
    buttons ok-cancel update lOK.
  if lOK <> true then do:
    return .
  end.

  run waitfram-show in this-procedure
    (INPUT "Просмотр товаров ... "
    ).

  for each temp-goods
  :
    delete temp-goods .
  end.

  for each buf-all_goods no-lock
  on error undo, next
  on end-key undo, return
  :

    assign
      icount = icount + 1
    .

    run waitfram-show in this-procedure
      (input "Просмотрено товаров: " + string(icount)
      ).
    process events .

    /* находим внутренний бар-код соответствующий товару */
    { gbl/gdsbcode.i
      buf-all_goods.gds-code
      ?
      v-bar-code
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении бар-кода товара" skip
        substitute( "Код товара: &1", buf-all_goods.gds-code ) skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-new-artic = string(v-bar-code)
    .

    if buf-all_goods.artic <> v-new-artic then do:
      create temp-goods .
      assign
        temp-goods.gds-code   = buf-all_goods.gds-code
        temp-goods.artic      = buf-all_goods.artic
        temp-goods.prod-type  = buf-all_goods.prod-type
        temp-goods.prod-code  = buf-all_goods.prod-code
        temp-goods.new-artic  = v-new-artic
      .
      assign
        i-rename-count = i-rename-count + 1
      .
    end.
  end. /* for each goods */

  run waitfram-hide in this-procedure .

  output stream log to new-art.txt .
  put stream log
    'Старый артикул        Тип произв.       Код произв      Новый артикул'
    skip.

  for each temp-goods
  :
    put stream log
      temp-goods.artic ' '
      temp-goods.prod-type ' '
      temp-goods.prod-code ' '
      temp-goods.new-artic
      skip.
  end.

  output stream log close .

  message
    "Вы действительно хотите переименовать все товары, имеющие неавтоматические артикулы," skip
    "присвоив им автоматические артикулы, равные внутреннему бар-коду?" skip
    "Всего будет переименовано " i-rename-count " товаров из " icount "."
    skip (2)
    "ВНИМАНИЕ!" skip
    "Сделайте архивную копию базы данных перед выполнением данной операции!" skip
    "Пользователи не должны работать с базой данных!" skip
    "Лучше всего данную утилиту запускать в однопользовательском режиме." skip
    "Список товаров подлежащих переименованию можно посмотреть в файле new-art.txt."
    view-as alert-box question
    buttons ok-cancel update lOK.

  if lOK <> true then do:
    return .
  end.

  define variable i-good-count as integer no-undo .
  define variable i-bad-count  as integer no-undo .

  assign
    i-good-count = 0
    i-bad-count  = 0
  .

  for each temp-goods
  :

    if v-not-two-commit = false then do:
      find first buf-all_goods exclusive-lock
        where buf-all_goods.artic     = temp-goods.artic
          and buf-all_goods.prod-type = temp-goods.prod-type
          and buf-all_goods.prod-code = temp-goods.prod-code
        no-error
      .
      if not available buf-all_goods then do:
        message
          substitute( "Товар с артикулом &1 и производителем &2 &3 не найден!", temp-goods.artic, temp-goods.prod-type, temp-goods.prod-code ) skip
          substitute( "Возможно он был уже переименован." ) skip
          view-as alert-box error
        .
        next .
      end.
      run gen-key-rec( input {&table_goods}
                      ,input (buffer buf-all_goods:handle )
                      ,output v-key-rec
                    ) no-error.
      if error-status :error then do:
        assign
          i-bad-count = i-bad-count + 1
        .
      end.
      else do:
        assign
          v-param = substitute( "&1&2&3&2&4&2&5&2&6&2&7&2&8"
                                ,buf-all_goods.gds-code
                                ,{&delim-par}
                                ,temp-goods.artic
                                ,temp-goods.prod-type
                                ,temp-goods.prod-code
                                ,temp-goods.new-artic
                                ,temp-goods.prod-type
                                ,temp-goods.prod-code
                              ).
        run nws/db-rec.p ( input {&ren-art}
                      ,input v-key-rec
                      ,input v-param
                    ) no-error .
        if error-status :error
          or return-value <> "":U
        then do:
          assign
            i-bad-count = i-bad-count + 1
          .
        end.
        else do:
          assign
            i-good-count = i-good-count + 1
          .
        end.
      end.
    end.
    else do:
      run utl/ren-art.p
        (INPUT  temp-goods.gds-code
        ,INPUT  temp-goods.artic
        ,INPUT  temp-goods.prod-type
        ,INPUT  temp-goods.prod-code
        ,INPUT  temp-goods.new-artic
        ,INPUT  temp-goods.prod-type
        ,INPUT  temp-goods.prod-code
        ) no-error.
      if error-status:error
      or return-value <> "" then do:
        assign
          i-bad-count = i-bad-count + 1
        .
      end.
      else do:
        assign
          i-good-count = i-good-count + 1
        .
      end.
    end.
  end. /* for each temp-goods */

  message
    "Переименование артикулов завершено. " SKIP
    "Переименовано артикулов " i-good-count SKIP
    "Непереименовано артикулов (из-за ошибок выполнения) " i-bad-count SKIP
    view-as alert-box .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rename-artic Dialog-Frame
PROCEDURE rename-artic :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-old-artic     like ub.goods.artic     no-undo .
  define input parameter p-old-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-old-prod-code like ub.goods.prod-code no-undo .
  define input parameter p-new-artic     like ub.goods.artic     no-undo .
  define input parameter p-new-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-new-prod-code like ub.goods.prod-code no-undo .

  define buffer buf-rename_goods for ub.goods .

  define variable v-error-message as character no-undo .
  define variable v-bar-code like ub.bar-code.b-code no-undo .
  define variable v-gds-code like ub.goods.gds-code no-undo .

  do transaction
  on error undo, return no-apply
  :
    find first buf-rename_goods exclusive-lock
      where buf-rename_goods.artic     = old-artic
        and buf-rename_goods.prod-type = old-prod-type
        and buf-rename_goods.prod-code = old-prod-code
      no-error
    .
    if not available buf-rename_goods then do:
      message
        substitute( "Товар с артикулом &1 и производителем &2 &3 не найден!", old-artic, old-prod-type, old-prod-code ) skip
        substitute( "Возможно он был уже переименован." ) skip
        view-as alert-box error
      .
      return error .
    end.

    assign
      v-gds-code = buf-rename_goods.gds-code
    .

    { gbl/gdsbcode.i
      v-gds-code
      ?
      v-bar-code
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении бар-кода товара" skip
        "Код товара" skip
        view-as alert-box error .
      undo, return error .
    end.

    if v-not-two-commit = false then do:
      run gen-key-rec( input {&table_goods}
                      ,input (buffer buf-rename_goods:handle )
                      ,output v-key-rec
                    ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при генерации уникального ключа для товара" skip
          substitute( "код &1", v-gds-code ) skip
          return-value
          view-as alert-box error .
        return error .
      end.

      assign
        v-param = substitute( "&1&2&3&2&4&2&5&2&6&2&7&2&8"
                              ,v-gds-code
                              ,{&delim-par}
                              ,p-old-artic
                              ,p-old-prod-type
                              ,p-old-prod-code
                              ,p-new-artic
                              ,p-new-prod-type
                              ,p-new-prod-code
                            ).
      run nws/db-rec.p ( input {&ren-art}
                    ,input v-key-rec
                    ,input v-param
                  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при переименовании артикула и(или) производителя для товара" skip
          substitute( "код &1", v-gds-code ) skip
          return-value skip
          error-status :get-message(1)
          view-as alert-box error .
        return error .
      end.
      if return-value <> "":U then do:
        message
          return-value
          view-as alert-box error .
        return no-apply.
      end.
      message
        "Операция переименования артикула и(или) производителя начата" skip
        "Направлен запрос во все БД" skip
        "После получения положительного ответа артикул и(или) производитель будет переименован"
        view-as alert-box information.
    end.
    else do:
      run utl/ren-art.p
        (input  v-gds-code      /* old-gds-code  */
        ,input  p-old-artic     /* old-artic     */
        ,input  p-old-prod-type /* old-prod-type */
        ,input  p-old-prod-code /* old-prod-code */
        ,input  p-new-artic     /* new-artic     */
        ,input  p-new-prod-type /* new-prod-type */
        ,input  p-new-prod-code /* new-prod-code */
        ) no-error.
      if error-status :error
      or return-value <> "" then do:
        message
          "Артикул не изменен:" skip
          v-error-message skip
          view-as alert-box error.
      end.
      else do:
        message
          "Завершено изменение артикула" skip
          "Старый артикул" p-old-artic p-old-prod-type p-old-prod-code skip
          "Новый артикул" p-new-artic p-new-prod-type p-new-prod-code  skip
          view-as alert-box information .
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validate-prod Dialog-Frame
PROCEDURE validate-prod :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .

  define buffer buf_clients for ub.clients.

  find first buf_clients no-lock
    where buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code
    no-error
  .
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при задании нового производителя!" skip
      view-as alert-box error .
    undo, return error.
  end.

  if buf_clients.obj-type = {&stock}
  or buf_clients.obj-type = {&shop}
  then do:
    message
      "Склад/магазин не может быть производителем !" skip
      "Производитель" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME