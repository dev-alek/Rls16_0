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

Диалог на добавление связки резервуар-ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/28/07
Author: Dmitry Ukhanov
Creation date: 08/28/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05

*/

/* Parameters Definitions ---                                           */
&GLOBAL-DEFINE defined_parparentproc yes
define input parameter parparentproc as widget-handle no-undo .
define input  parameter parobj-type like ub.clients.obj-type no-undo.
define input  parameter parobj-code like ub.clients.obj-code no-undo.
define output parameter parrec-id as recid initial ? no-undo.


def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Диалог на добавление связки резервуар-ТРК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ str/nzpl-spl.i }
{ trg/cplgdspm.i }

/* ***************************  Definitions  ************************** */
{ str/ptrlv.i "def"}
procedure plpumpav:
  define input parameter parobj-type  like ub.clients.obj-type no-undo.
  define input parameter parobj-code  like ub.clients.obj-code no-undo.
  define input parameter parpl-code   like ub.place.pl-code    no-undo.
  define input parameter parpump-code like ub.pump.pump-code   no-undo.

  define buffer bf_clients           for ub.clients.
  define buffer bf_pump              for ub.pump.
  define buffer bf_place             for ub.place.
  define buffer bf_pl-pump           for ub.pl-pump.
  define buffer bf_pl-gds            for ub.pl-gds.
  define buffer bf_goods             for ub.goods.
  define buffer bf_pl-gds-pump       for ub.pl-gds-pump.
  define buffer bf-other_pl-gds-pump for ub.pl-gds-pump.

  define variable varstatus as character no-undo.

  { str/ptrlv.i "ov+"}
  { str/ptrlv.i "ppv+"}
  { str/ptrlv.i "plv+"}
  /*Проверяем то, что нет еще такой записи резервуар-ТРК*/
  find first bf_pl-pump no-lock
    where bf_pl-pump.obj-type   = parobj-type
      and bf_pl-pump.obj-code   = parobj-code
      and bf_pl-pump.pl-code    = parpl-code
      and bf_pl-pump.pump-code  = parpump-code
    no-error.
  if available bf_pl-pump then do:
    return error SUBSTITUTE("Уже есть запись резервуар-ТРК с номером резервуара &1 и номером ТРК &2", parpl-code, parpump-code) {&str-obj}.
  end.
  /*Если есть в резервуаре бензин делаем проверку, что через данную ТРК не течет данный бензин
    и создаем связку с топливом*/
  find first bf_pl-gds no-lock
    where bf_pl-gds.obj-type = parobj-type
      and bf_pl-gds.obj-code = parobj-code
      and bf_pl-gds.pl-code  = parpl-code
    no-error.
  tr:
  do transaction
  on error undo tr, return error return-value
  :
    if available bf_pl-gds then do:
      find first bf_goods no-lock
        where bf_goods.gds-code = bf_pl-gds.gds-code
      .
      assign
        varstatus = {&current-status}
      .
      find first bf-other_pl-gds-pump no-lock
        where bf-other_pl-gds-pump.obj-type  = parobj-type
          and bf-other_pl-gds-pump.obj-code  = parobj-code
          and bf-other_pl-gds-pump.gds-code  = bf_goods.gds-code
          and bf-other_pl-gds-pump.pump-code = parpump-code
          and bf-other_pl-gds-pump.status_   = {&current-status}
        no-error.
      if available bf-other_pl-gds-pump
        and nzpl-spl(bf-other_pl-gds-pump.obj-type, bf-other_pl-gds-pump.obj-code) <> yes
      then do:
        message
          "Через ТРК с номером " parpump-code " уже продается топливо " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name
          " которое связано с резервуаром " bf-other_pl-gds-pump.pl-code "." skip
          "Данная привязка Резервуар-ТРК-Товар получит статус блокированный."
          view-as alert-box information.
        assign
          varstatus = {&blocked-status}
        .
      end.
      create bf_pl-gds-pump.
      assign
        bf_pl-gds-pump.obj-type  = parobj-type
        bf_pl-gds-pump.obj-code  = parobj-code
        bf_pl-gds-pump.pl-code   = parpl-code
        bf_pl-gds-pump.gds-code  = bf_goods.gds-code
        bf_pl-gds-pump.pump-code = parpump-code
        bf_pl-gds-pump.status_   = varstatus
      .
      run cplgdspm in this-procedure
        ( input bf_pl-gds-pump.obj-type
         ,input bf_pl-gds-pump.obj-code
         ,input bf_pl-gds-pump.pl-code
         ,input bf_pl-gds-pump.gds-code
         ,input bf_pl-gds-pump.pump-code
         ,input bf_pl-gds-pump.status_
        ) no-error.
      if error-status:error then do:
        undo tr, return error substitute ("Ошибка при смене статуса записи резервуар-ТРК-пистолет: &1 &2.", return-value, error-status:get-message(1)).
      end.
    end.
    create bf_pl-pump.
    assign
      bf_pl-pump.obj-type   = parobj-type
      bf_pl-pump.obj-code   = parobj-code
      bf_pl-pump.pl-code    = parpl-code
      bf_pl-pump.pump-code  = parpump-code
    .
  end. /*transaction*/
end procedure.
{ str/ptrlv.i "undef"}

/* Local Variable Definitions ---                                       */
define new shared variable list-mode as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-cancel b-help varpl-code b-place ~
varpump-code b-pump
&Scoped-Define DISPLAYED-OBJECTS varpl-code varpump-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON b-pump
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE varpl-code AS INTEGER FORMAT "99999999999":U INITIAL 0
     LABEL "Бар-код резервуара"
     VIEW-AS FILL-IN
     SIZE 10.38 BY 1 NO-UNDO.

DEFINE VARIABLE varpump-code AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Номер ТРК"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varpl-code AT ROW 2.54 COL 2.88
     b-place AT ROW 2.67 COL 34
     varpump-code AT ROW 3.92 COL 20.88 COLON-ALIGNED
     b-pump AT ROW 4 COL 34
     SPACE(1.74) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление  резервуар-ТРК"
         DEFAULT-BUTTON b-save CANCEL-BUTTON b-cancel.


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

/* SETTINGS FOR FILL-IN varpl-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление  резервуар-ТРК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place Dialog-Frame
ON CHOOSE OF b-place IN FRAME Dialog-Frame
DO:
  define variable place-list as character no-undo.
  run ref/pl-list.w (
                 input parparentproc
                ,input "b-sel"
                ,input parobj-type
                ,input parobj-code
                ,input {&g___object}
                ,input-output place-list).
  if place-list = "cancel"
  then do :
    return no-apply .
  end .
  if place-list <> '':U then do:
     FIND FIRST ub.place No-LOCK WHERE recid(ub.place) = integer(entry(1, place-list)) NO-ERROR.
     if available ub.place then display ub.place.pl-code @ varpl-code with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pump
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pump Dialog-Frame
ON CHOOSE OF b-pump IN FRAME Dialog-Frame
DO:
  { str/ptrlv.i "refpump"}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
  assign frame {&frame-name} varpl-code varpump-code .
  run plpumpav in this-procedure
               (input parobj-type,
                input parobj-code,
                input varpl-code,
                input varpump-code) no-error.
  if error-status:error then do:
     { str/errmes.i "Ошибка при создании записи резервуар-ТРК"}
     return no-apply.
  end.
  find first ub.pl-pump where ub.pl-pump.obj-type    = parobj-type  and
                           ub.pl-pump.obj-code    = parobj-code  and
                           ub.pl-pump.pl-code     = varpl-code   and
                           ub.pl-pump.pump-code   = varpump-code
                           no-lock.
  assign parrec-id = recid(ub.pl-pump).
end.

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
  DISPLAY varpl-code varpump-code
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help varpl-code b-place varpump-code b-pump
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME