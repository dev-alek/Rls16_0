&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_cd-clu FOR ub.cd-clu.
DEFINE BUFFER locked_cash-desk FOR ub.cash-desk.
DEFINE BUFFER X_cd-clu FOR ub.cd-clu.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER X_clients FOR ub.clients.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Клиенты на кассе MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
DEFINE INPUT PARAMETER p-mode  AS CHARACTER NO-UNDO.
/*{&all} {&g___OBJECT}*/

DEFINE INPUT PARAMETER p-curr-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-curr-obj-code LIKE ub.clients.obj-code NO-UNDO.
define input parameter p-pos-type as character no-undo .
/*тип POS может быть {&cd-type-maria}*/
define input-output param p-rid-list    as  char no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Клиенты на кассе МАРИЯ".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/color.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ gbl/cd-attr.i }
{ str/cd-mrkt.i }
{ gbl/getcntxt.i def }
{ cmp/dc-list.i dc-list def "new shared" }
&undefine dc-list_i_def
{ cmp/dc-list.i save-list def }
/*нужно для отсылки клиентов в send-cli.p*/
{ str/defc-cli.i "NEW SHARED" }
{ cmp/dcp-list.i dcp-list def "new shared" }
{ gbl/fltopend.i defproc }

define variable filter-point as character no-undo init "mar-cli" .
define variable filter-point0 as character no-undo init "mar-cli" .
define variable filter-label as character no-undo init "Клиенты на кассе МАРИЯ" .
define variable filter-label0 as character no-undo init "Клиенты на кассе МАРИЯ" .

define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-obj-db-num like ub.db.db-num no-undo .
define variable lns-cnt as integer no-undo .
define variable glog as logical no-undo .
define variable SendOption as character no-undo .
define variable v-cd-list-update as character no-undo .
define variable v-cd-list-delete as character no-undo .

/*параметры касс*/
DEFINE VARIABLE v-max-cli AS integer no-undo .
DEFINE VARIABLE v-max-CLU AS integer no-undo .
DEFINE VARIABLE v-tot-cli AS integer no-undo .
DEFINE VARIABLE l-exist-cd AS logical no-undo .
define variable line-rec as recid no-undo .

define buffer pos_cd-clu for ub.cd-clu.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_cd-clu no-lock where ~
                                  recid(pos_cd-clu) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи КЛИЕНТА НА КАССЕ" skip~
                            string(if avail pos_cd-clu ~
                                    then  substitute("CLU: &1, &2&3" ~
                                                    , pos_cd-clu.clu-code  ~
                                                    , pos_cd-clu.cli-type ~
                                                    , pos_cd-clu.cli-code) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

&scop lamp-image ~
do with frame {&frame-name}: ~
  if l-exist-~{&lamp-var~} then  ~
    /* лампочка должна гореть */ ~
    assign ~
      glog = ~{&lamp-var~}-image:load-image ("cmp/l-~{&lamp-var~}.bmp") ~
      ~{&lamp-var~}-image :selectable = yes ~
      ~{&lamp-var~}-image :sensitive = yes ~
      ~{&lamp-var~}-image :tooltip = ~{&lamp-var~}-image :private-data ~
      .  ~
  else do: ~
    assign ~
    glog = ~{&lamp-var~}-image:load-image (?) ~
      ~{&lamp-var~}-image :selectable = no ~
      ~{&lamp-var~}-image :sensitive = no ~
      ~{&lamp-var~}-image :tooltip = '':U ~
    . ~
  end. ~
end.

&SCOPED-DEFINE sort-clmn_2 X_cd-clu.cli-type + string(X_cd-clu.cli-CODE)
&scoped-define label-clmn_2 ' '

&SCOPED-DEFINE dct-client-obj-type X_cd-clu.cli-type
&SCOPED-DEFINE dct-client-obj-code X_cd-clu.cli-code

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-mcli

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_cd-clu X_clients

/* Definitions for BROWSE br-mcli                                       */
&Scoped-define FIELDS-IN-QUERY-br-mcli X_cd-clu.clu-code X_cd-clu.cli-type + string(X_cd-clu.cli-code) X_cd-clu.to-send X_cd-clu.to-DEL X_clients.obj-name {&dct-client-card-no}
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-mcli
&Scoped-define SELF-NAME br-mcli
&Scoped-define QUERY-STRING-br-mcli FOR EACH X_cd-clu NO-LOCK, ~
             FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type     AND X_clients.obj-code = X_cd-clu.cli-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-mcli OPEN QUERY {&SELF-NAME} FOR EACH X_cd-clu NO-LOCK, ~
             FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type     AND X_clients.obj-code = X_cd-clu.cli-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-mcli X_cd-clu X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-mcli X_cd-clu
&Scoped-define SECOND-TABLE-IN-QUERY-br-mcli X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-mcli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-lkp B-chg B-send ~
B-print B-sch B-Help cd-image a-n-c loc-name loc-code br-mcli mark-num ~
f-max-cli f-tot-cli f-max-CLU
&Scoped-Define DISPLAYED-OBJECTS a-n-c loc-name loc-code mark-num f-max-cli ~
f-tot-cli f-max-CLU

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-B-send
       MENU-ITEM m_all          LABEL "Все"
       MENU-ITEM m_changed      LABEL "Измененные"    .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-send
     LABEL "&Послать"
     SIZE 10 BY 1.

DEFINE VARIABLE f-max-cli AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Max кол-во кодов"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-max-CLU AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Max тек CLU"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-tot-cli AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Тек кол-во кодов"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(256)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE cd-image
     FILENAME "adeicon/blank":U
     SIZE 3 BY 1 TOOLTIP "Отправьте клиентов на кассы".

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Код", "b-code",
"&CLU", "CLU"
     SIZE 29.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-mcli FOR
      X_cd-clu,
      X_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-mcli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-mcli Dialog-Frame _FREEFORM
  QUERY br-mcli NO-LOCK DISPLAY
      X_cd-clu.clu-code COLUMN-LABEL "CLU" FORMAT "999":U WIDTH 12
X_cd-clu.cli-type + string(X_cd-clu.cli-code) FORMAT "X(12)":U
X_cd-clu.to-send  COLUMn-LABEL "И" FORMAT "+/":U
X_cd-clu.to-DEL COLUMN-LABEL "У" FORMAT "+/":U
X_clients.obj-name FORMAT "X(50)":U
{&dct-client-card-no} COLUMN-LABEL 'Клиент-Счет' FORMAT "X(11)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.25 BY 17.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 21
     B-lkp AT ROW 1 COL 31
     B-chg AT ROW 1 COL 41
     B-send AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     a-n-c AT ROW 2 COL 2 NO-LABEL
     loc-name AT ROW 2 COL 55 COLON-ALIGNED
     loc-code AT ROW 2 COL 55 COLON-ALIGNED
     br-mcli AT ROW 4.25 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     f-max-cli AT ROW 3 COL 1
     f-tot-cli AT ROW 3 COL 25
     f-max-CLU AT ROW 3 COL 50
     cd-image AT ROW 2.25 COL 92
     SPACE(4.25) SKIP(18.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Клиенты на кассе".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_cd-clu B "?" ? ub cd-clu
      TABLE: locked_cash-desk B "?" ? ub cash-desk
      TABLE: X_cd-clu B "?" ? ub cd-clu
      TABLE: X_cli-obj B "?" ? ub clients
      TABLE: X_clients B "?" ? ub clients
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-mcli loc-code Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-send:HANDLE.

/* SETTINGS FOR FILL-IN f-max-cli IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-max-CLU IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-tot-cli IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-mcli
/* Query rebuild information for BROWSE br-mcli
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_cd-clu NO-LOCK,
      FIRST X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type
    AND X_clients.obj-code = X_cd-clu.cli-code INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", FIRST"
     _JoinCode[2]      = "X_clients.obj-type = X_cd-clu.cli-type
  AND X_clients.obj-code = X_cd-clu.cli-code"
     _Query            is OPENED
*/  /* BROWSE br-mcli */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Клиенты на кассе */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
    case input frame {&frame-name} a-n-c :
    when "b-code" then do:
      enable
      loc-code
      with frame {&frame-name}.
      loc-code:label = "Код".
      display
      loc-code
      with frame {&frame-name}.
      hide
      loc-name
      in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "CLU" then do:
      enable
      loc-code
      with frame {&frame-name}.
      loc-code:label = "CLU (без № маг)".
      display
      loc-code
      with frame {&frame-name}.
      hide
      loc-name
      in frame {&frame-name}.
      apply "entry" to loc-code in frame {&frame-name}.
    end.
    when "obj-type" then do:
      enable
      loc-name
      with frame {&frame-name}.
      loc-name:label = "Доп.БК".
      display
      loc-name
      with frame {&frame-name}.
      hide
      loc-code
      in frame {&frame-name}.
      apply "entry" to loc-name in frame {&frame-name}.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    IF NOT AVAILABLE  X_cd-clu THEN RETURN NO-APPLY.
    run ref/showcli.p
    (input parParentProc
    ,input X_cd-clu.cli-type /* p-obj-type */
    ,input X_cd-clu.cli-code /* p-obj-code */
    ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
  if available X_cd-clu then do:
    { gbl/markstrn.i X_cd-clu p-rid-list }
    loc#log = br-mcli:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-mcli:select-next-row ().
        apply "VALUE-CHANGED" to br-mcli in frame {&frame-name}.
    end.
    if num-entries( p-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( p-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-mcli in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_cd-clu then return no-apply.
  run proc-b-print in this-procedure  no-error.
  if error-status:error then do:
     return no-apply.
  end.
  APPLY "ENTRY" to br-mcli.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available X_cd-clu ) then do:
    if ( p-rid-list = "" ) or b-mark:sensitive = no then
    p-rid-list = string( recid( X_cd-clu ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-send Dialog-Frame
ON CHOOSE OF B-send IN FRAME Dialog-Frame /* Послать */
DO:

if SendOption = "" then
run gbl/pop-up.p (self:handle, yes) no-error.
if SendOption = "" then return no-apply.

v-doc-rec = recid(X_cd-clu).

define variable v-chk-act-host-code as integer   no-undo .
{ gbl/hostcode.i
  p-curr-obj-type
  p-curr-obj-code
  v-chk-act-host-code
}
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_cashdesk-clients_add-def':U
  {&cntxt-object}
  v-chk-act-host-code
  p-curr-obj-type
  p-curr-obj-code
  0
  0
  0
  true
  glog
}

if NOT glog THEN return no-apply.

/*при вызове general-send из интерфейса - спросим на все объекты или текущий -
третий параметр вызова = ""*/
RUN general-send no-error.
if error-status:error then do:
    Sendoption = "".
  return no-apply.
end.
Sendoption = "".
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
run disp-cd in this-procedure .
reposition br-mcli to recid v-doc-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cd-image
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cd-image Dialog-Frame
ON MOUSE-SELECT-CLICK OF cd-image IN FRAME Dialog-Frame
OR selection of cd-image DO:

  /*послать все неотосланное на кассу*/
  run general-send in this-procedure  no-error .
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  run fill-vars in this-procedure no-error .
  run disp-cd in this-procedure no-error.
  reposition br-mcli to recid v-doc-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-code Dialog-Frame
ON CTRL-J OF loc-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure(a-n-c, YES, input frame {&frame-name} loc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-code Dialog-Frame
ON RETURN OF loc-code IN FRAME Dialog-Frame
DO:
  run proc-find-code in this-procedure(a-n-c, no, input frame {&frame-name} loc-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON CTRL-J OF loc-name IN FRAME Dialog-Frame
DO:
  run proc-find-obj-type in this-procedure(a-n-c, YES, input frame {&frame-name} loc-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON RETURN OF loc-name IN FRAME Dialog-Frame
DO:
    run proc-find-obj-type in this-procedure(a-n-c, NO, input frame {&frame-name} loc-name) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_all /* Все */
DO:
    assign
  SendOption = "ALL":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_changed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_changed Dialog-Frame
ON CHOOSE OF MENU-ITEM m_changed /* Измененные */
DO:
    assign
  SendOption = "changed":U.
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-mcli
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_cd-clu.clu-code"
  &label-clmn_2 = "{&label-clmn_2}"
  &sort-clmn_2  = "{&sort-clmn_2}"
  &sort-clmn_3    = "X_clients.obj-name"
  &open-query     = "run OpenBr in this-procedure  ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }




{ gbl/mv-clmn.i
&browse-name = "br-mcli"
&frame-name = "{&frame-name}"
&ext-col = 9
&start-column = 2
&prev-order-column_1 = "'1,2,3,4,5,6,7,8,9'"
&prev-order-column-condition_1 = " true "
}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

    if p-mode <> {&all}
    AND p-mode <> {&g___object} then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return.
 end.

 find first X_cli-obj no-lock where
                X_cli-obj.obj-type = p-curr-obj-type
            and X_cli-obj.obj-code = p-curr-obj-code no-error.
  if not available X_cli-obj then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-curr-obj-type и/или p-curr-obj-code"
        view-as alert-box ERROR.
      return.
  end.
  if p-rid-list <> "" then do:
      FIND FIRST find_cd-clu No-LOCK where
                 recid(find_cd-clu) = integer(entry(1, p-rid-list)) No-ERROR.
      if not avail find_cd-clu then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова p-rid-list" p-rid-list
        view-as alert-box error .
        return error.
      end.
      v-doc-rec = integer(entry(1, p-rid-list)).
    end.
  { gbl/curdbnum.i v-db-num }
  { gbl/objdbnum.i p-curr-obj-type p-curr-obj-code v-obj-db-num }
  if v-obj-db-num <> v-db-num then do:
    message
    "Нельзя работать с клиентами кассы объекта удаленной БД"
    view-as alert-box error .
    undo, return error .
  end.
  do transaction
  on error undo main-block, return error
  :
    FIND FIRST LOCKED_cash-desk EXCLUSIVE-LOCK WHERE
              LOCKED_cash-desk.obj-code = p-curr-obj-code
          AND LOCKED_cash-desk.db-num = v-db-num
          AND LOCKED_cash-desk.pos-type = p-pos-type
          AND (p-pos-type = {&cd-type-maria} or LOCKED_cash-desk.cash-num = 0) NO-WAIT NO-ERROR.
    IF NOT AVAILABLE locked_cash-desk AND NOT LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 не определена касса типа &3 с номером 0 - кассовый менеджер&4" +
                  "Нельзя работать с клиентами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , p-pos-type
                  , {&new-line}
                  )
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    IF LOCKED locked_cash-desk THEN DO:
        MESSAGE
        SUBSTITUTE("На &1&2 в настоящее время занята запись кассы типа &3&4" +
                  "с номером 0 - кассовый менеджер" +
                  "Нельзя работать с клиентами на кассе"
                  , p-curr-obj-type
                  , p-curr-obj-code
                  , p-pos-type
                  , {&NEW-LINE})
      VIEW-AS ALERT-BOX ERROR.
      UNDO main-block, RETURN ERROR.
    END.
    case p-pos-type:
      when {&cd-type-maria} then do:
         assign
         v-cd-list-delete = locked_cash-desk.addr-path
         v-cd-list-update = locked_cash-desk.addr-path
         .
      end.
    END CASE.
  end.
  RUN fill-vars IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN UNDO main-block, RETURN ERROR.
  RUN MyEnable.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
  HIDE mark-num in frame {&frame-name} .
  if p-rid-list <> "":U then
  REPOSITION br-mcli to recid integer(entry(1, p-rid-list)) No-ERROR.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-cd Dialog-Frame
PROCEDURE disp-cd :
/*----------------------------------------------------------
проверка и вывод значения "Требуется отправка на кассы"
----------------------------------------------------------*/
DEFINE VARIABLE v-mes AS CHARACTER NO-UNDO.
define buffer buf_cd-clu for ub.cd-clu .
  l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                    ,input {&cda-maria_operative}
                                    ,input {&cda-maria_operative_to-send}
                                    ,output v-mes).

if l-exist-cd = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.

&scop lamp-var cd
{&lamp-image}

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
  DISPLAY a-n-c loc-name loc-code mark-num f-max-cli f-tot-cli f-max-CLU
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-lkp B-chg B-send B-print B-sch B-Help cd-image
         a-n-c loc-name loc-code br-mcli mark-num f-max-cli f-tot-cli f-max-CLU
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-vars Dialog-Frame
PROCEDURE fill-vars :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-mes as character no-undo .
do
on error undo, return error
:

v-tot-cli = cd-attr_get-attr-int(buffer locked_cash-desk
                                ,input {&cda-maria_operative}
                                ,input {&cda-maria_operative_tot-cli}
                                ,output v-mes).
if v-tot-cli = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
v-max-cli = cd-attr_get-attr-int(buffer locked_cash-desk
                                ,input {&cda-maria_general}
                                ,input {&cda-maria_general_max-cli}
                                ,output v-mes).
if v-max-cli = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
v-max-CLU = cd-attr_get-attr-int(buffer locked_cash-desk
                                ,input {&cda-maria_operative}
                                ,input {&cda-maria_operative_max-clu}
                                ,output v-mes).
if v-max-CLU = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
l-exist-cd = cd-attr_get-attr-log(buffer locked_cash-desk
                                 ,input {&cda-maria_operative}
                                 ,input {&cda-maria_operative_max-clu}
                                 ,output v-mes).
if l-exist-cd  = ? then do:
  message v-mes
  view-as alert-box error .
  undo, return error.
end.
end. /*doe*/
DISPLAY
v-tot-cli @ f-tot-cli
v-max-cli @ f-max-cli
v-max-CLU @ f-max-CLU
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE general-send Dialog-Frame
PROCEDURE general-send :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE err1 as logical init yes.
DEFINE VARIABLE jj as integer no-undo.
define variable v-step as integer no-undo .
define variable glog as logical no-undo .
define variable v-d-card like ub.dis-card.d-card no-undo .
define buffer buf_cd-clu  for ub.cd-clu.
define buffer buf_clients for ub.clients.

/*
коментарим прием с касс
run str/diallog.w (  parparentproc
              , this-procedure
              , 'str/get-chkf.p':U
              , (p-curr-obj-type + {&delim-par} + string(p-curr-obj-code) + {&delim-par} + string(0))
              , yes
              , '':U
              , 'Прием чеков с касс') no-error .
if error-status:error then do:
    return error .
end.
if return-value = "error":U then return error .
*/
message
"Вы уверены что Вы приняли ВСЕ ЧЕКИ С КАССЫ?" skip
"В противном случае при изменении списка клиентов на кассе," skip
"может возникнуть ПЕРЕСОРТИЦА и/или появиться чеки с НЕОПОЗНАННЫМ КЛИЕНТОМ"
view-as alert-box QUESTION buttons YES-NO update glog.
if not glog then return error .

  FOR EACH dc-list :
    delete dc-list .
  END .

do
on error undo, return error
:


_zz:
DO ON STOP UNDO, return error
      ON END-KEY UNDO, return error
      ON ERROR UNDO, LEAVE:
  run waitfram-show in this-procedure ( {&MyWaitMess} ) .
  jj = 0.
  _jj:
  FOR EACH buf_cd-clu WHERE
         buf_cd-clu.obj-type = p-curr-obj-type
     and buf_cd-clu.obj-code = p-curr-obj-code
     and buf_cd-clu.pos-type = {&cd-type-maria}
     and buf_cd-clu.clu-type = '':U ,
      first buf_clients no-lock where
          buf_clients.obj-type = buf_cd-clu.cli-type
      and buf_clients.obj-code = buf_cd-clu.cli-code :
    IF sendoption <> "ALL"
    AND buf_cd-clu.to-DEL = no
    AND  buf_cd-clu.to-send = no THEN NEXT _jj.
&scop dct-client-obj-type buf_cd-clu.cli-type
&scop dct-client-obj-code buf_cd-clu.cli-code
    v-d-card = {&dct-client-card-no}.

    v-d-card = 'C' + string((if buf_cd-clu.cli-type = {&prs} then 0 else 1000000000) + buf_cd-clu.cli-code).
    find first cash-cli no-lock where
              cash-cli.d-card = v-d-card no-error .
    if not available cash-cli then do:
      create cash-cli.
      assign
      cash-cli.d-card = v-d-card
      cash-cli.emitent-host-code = 0 /*для них только глобальные*/
      cash-cli.cli-type = buf_cd-clu.cli-type
      cash-cli.cli-code = buf_cd-clu.cli-code
      cash-cli.obj-name = buf_clients.obj-name
      cash-cli.crf = buf_cd-clu.clu-code
      .
    end.
    jj = jj + 1.
    if ( jj modulo 10 = 0 ) then
    run waitfram-show in this-procedure (substitute("Обработано &1 кодов", jj)).
      /*buf_cd-clu.stato-send = FALSE .*/
  END.
END. /*of transaction*/

  run str/diallog.w (   parparentproc
              , this-procedure
              , 'str/send-cli.p':U
              , (string( p-curr-obj-code) + {&delim-par} +
                 "U":U + {&delim-par} +
                 "no":U + {&delim-par} +
                 "no":U + {&delim-par} +
                 "del-mrkt-cli":U
                 )
              , no /*p-auto-go*/
              , '':U
              , 'Отправка клиентов на кассу') no-error .


  run cd-mrkt_update-marketer-cli in this-procedure (
                                                  input locked_cash-desk.db-num
                                                  ,input locked_cash-desk.obj-code
                                                  ,input locked_cash-desk.pos-type
                                                  ,input locked_cash-desk.cash-num
                                                )  .

end. /*doe*/
run fill-vars in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
ASSIGN b-send:MENU-MOUSE in frame {&frame-name}  = 1.
ASSIGN
cd-image:private-data in frame {&frame-name} = cd-image:TOOLTIP
cd-image:fgcolor in frame {&frame-name} = GRAY_COLOR
cd-image:bgcolor in frame {&frame-name} = GRAY_COLOR
.
DISPLAY
a-n-c
loc-name
loc-code
mark-num
WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttns) > 0
b-sel  WHEN LOOKUP("b-sel", bttns) > 0
B-chg
B-sch
B-print
B-Help
b-send
a-n-c
loc-name
loc-code
br-mcli
mark-num
b-lkp
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
hide
loc-name in frame {&frame-name}.
RUN disp-cd IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = substitute("Клиенты на кассе &1"
                    , p-pos-type).

run waitfram-show in this-procedure ("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-mcli FOR EACH X_cd-clu

&scop flt-open-dyn_open-query FOR EACH X_cd-clu

&scop flt-open-query-handle QUERY br-mcli:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_cd-clu

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_cd-clu



&scop flt-open-open-query-tail , first X_clients NO-LOCK WHERE X_clients.obj-type = X_cd-clu.cli-type ~
and  X_clients.obj-code = X_cd-clu.cli-code



&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .


CASE p-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-label0)
    .
    if p-open-query then do:
      frame {&frame-name}:TITLE = title0.
    end.
  { gbl/fltopend.i
    &where-cond = " X_cd-clu.clu-type = '':U and X_cd-clu.pos-type = {&cd-type-maria} "
    &dyn_where-cond = " substitute('X_cd-clu.clu-type = &1&1 and X_cd-clu.pos-type = &1&2&1 ', ~{&double-quote~}, {&cd-type-maria})"
    &use-ind    = "  "
    &by         = "  "
    }

  END.
  WHEN {&g___object} THEN DO:
    ASSIGN
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1 Один объект", filter-label0)
    .
    if p-open-query then do:
      frame {&frame-name}:TITLE = title0 +
                                    substitute(" &1&2", p-curr-obj-type, p-curr-obj-code).
    end.

    { gbl/fltopend.i
      &where-cond = " ~
        X_cd-clu.obj-type = p-curr-obj-type and X_cd-clu.obj-code = p-curr-obj-code ~
        and X_cd-clu.pos-type = {&cd-type-maria} and X_cd-clu.clu-type = '':U  ~
                    "
      &dyn_where-cond = " substitute(' X_cd-clu.obj-type = &1&2&1 and X_cd-clu.obj-code = &3 ~
        and X_cd-clu.pos-type = &1&4&1 and X_cd-clu.clu-type = &1&1 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, {&cd-type-maria})"
                    "

      &use-ind    = "  "
      &by         = "  "
      }

  END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-mcli to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-mcli:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-mcli in frame {&frame-name}.
APPLY "ENTRY" TO br-mcli.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define variable old-mode as char no-undo.
define variable old-handle as handle no-undo.
define variable old-type as char no-undo.
define variable old-stat as char no-undo.
define variable old-flag as logical no-undo.
define variable old-internal as logical no-undo.
DEFINE VARIABLE v-skip-next as logical no-undo .
DEFINE VARIABLE v-update as logical no-undo .
define variable v-f-name as character no-undo .
define variable l-empty-scale as logical no-undo .
define variable ves-err as integer no-undo .
define variable v-to-send as logical no-undo .
define variable v-mes as character no-undo .
define variable v-restore as logical   no-undo .
define buffer buf_clients for ub.clients.
DEFINE BUFFER buf_cd-clu FOR ub.cd-clu.
define buffer buf_dis-card for ub.dis-card.

FOR EACH dc-list : /* Когда все ОК - цикл не вып-ся ни разу */
    delete dc-list.
END.
FOR EACH save-list:
  delete save-list.
end.
run waitfram-show in this-procedure ( input "ЖДИТЕ.  Заполняется список...").
/*line-mode = {&add-def}.*/

_block:
DO ON error UNDO _block, return error
on stop undo _block, return error:

_cd-clu:
  FOR EACH buf_cd-clu  WHERE
          buf_cd-clu.obj-type = p-curr-obj-type
      and buf_cd-clu.obj-code = p-curr-obj-code
      and buf_cd-clu.pos-type = {&cd-type-maria}
      and buf_cd-clu.clu-type = '':U
  by buf_cd-clu.clu-code:
    IF buf_cd-clu.to-DEL = yes
    and buf_cd-clu.charkey_one = v-cd-list-delete THEN NEXT.
    assign
    buf_cd-clu.to-del = yes
    buf_cd-clu.charkey_one = v-cd-list-delete.

    FIND FIRST buf_clients WHERE
            buf_clients.obj-type = buf_cd-clu.cli-type
        and buf_clients.obj-code = buf_cd-clu.cli-code  NO-LOCK no-error .
    if not available buf_clients then do:
      assign
      buf_cd-clu.to-del = yes
      buf_cd-clu.charkey_one = v-cd-list-delete.
      next _cd-clu.
    end.
&scop dct-client-obj-type buf_clients.obj-type
&scop dct-client-obj-code buf_clients.obj-code
    find first buf_dis-card no-lock where
              buf_dis-card.d-card = {&dct-client-card-no} no-error.
    if not available buf_dis-card then do:
      assign
      buf_cd-clu.to-del = yes
      buf_cd-clu.charkey_one = v-cd-list-delete.
      next _cd-clu.
    end.
    { cmp/dc-list.i dc-list assign " " buf_ }
    { cmp/dc-list.i save-list assign " " buf_ }
    assign
    buf_cd-clu.to-DEL = yes
    buf_cd-clu.charkey_one = v-cd-list-delete
    .

  /* пометка - потенциально лишняя запись */
  end.

run waitfram-hide in this-procedure .
END. /*block*/

run run-dc-list no-error .
if error-status:error then do:
  assign
  v-restore = yes.
end.
if not v-restore then do:
  message
  substitute("Вы действительно хотите изменить список клиентов на кассах &4 на &1&2&3" +
            "в соответствии с данным списком кодов?&3" +
            "(В список будут добавлены ТОЛЬКО карты типа КЛИЕНТ-СЧЕТ)"
            , p-curr-obj-type
            , p-curr-obj-code
            , {&new-line}
            , p-pos-type
            )
  view-as alert-box QUESTION buttons YES-NO update v-update.
end.
if not v-update then do:
  FOR EACH dc-list:
    delete dc-list.
  END.
  FOR EACH buf_cd-clu where
          buf_cd-clu.obj-type = p-curr-obj-type
      and buf_cd-clu.obj-code = p-curr-obj-code
      and buf_cd-clu.pos-type = {&cd-type-maria}
      and buf_cd-clu.clu-type = '':U ,
      FIRST save-list WHERE
            save-list.cli-type = buf_cd-clu.cli-type
        AND save-list.cli-code = buf_cd-clu.cli-code NO-LOCK:
    assign
    buf_cd-clu.to-DEL = no
    buf_cd-clu.charkey_one = '':U
    .
    delete save-list.
  end.
    return .
end. /*if not v-update then do:*/
run waitfram-show in this-procedure ("ЖДИТЕ.  Началось изменение справочника.").
ves-err = 0.
DO ON error UNDO, return error :
_TO-cli:
FOR EACH dc-list:
  ACCUMULATE dc-list.d-card ( count ).
  if ( accum count dc-list.d-card ) modulo 100 = 0 then do:
    run waitfram-show in this-procedure ("ЖДИТЕ.  Обработано строк списка : " +
                                   string ( accum count dc-list.d-card ) ) .
  end.
  FIND FIRST buf_cd-clu WHERE
          buf_cd-clu.obj-type = p-curr-obj-type
      and buf_cd-clu.obj-code = p-curr-obj-code
      and buf_cd-clu.pos-type = {&cd-type-maria}
      and buf_cd-clu.clu-type = '':U
      AND buf_cd-clu.cli-code = dc-list.cli-code
      AND buf_cd-clu.cli-type = dc-list.cli-type  NO-ERROR.
  if available buf_cd-clu then do:
    assign
    buf_cd-clu.to-DEL = no
    buf_cd-clu.charkey_one = "":U
    .    /* отметка, что запись нужна */
  end.
  else do:
    if v-skip-next then do:
      delete dc-list.
    end.
    else do:
      CASE p-pos-type:
        when {&cd-type-maria} then do:
&scoped-define dct-client-obj-type dc-list.cli-type
&scoped-define dct-client-obj-code dc-list.cli-code
          if dc-list.type <> {&dct-client}
          or dc-list.d-card <> {&dct-client-card-no}
          then do:
            ves-err = ves-err + 1.
            next _TO-cli.
          end.

          run cd-mrkt_CLU-marketer(
                                    input no /*p-silence*/
                                  ,buffer locked_cash-desk
                                  ,input dc-list.cli-type
                                  ,input dc-list.cli-code
                                  ) no-error.
          if error-status:error then do:
            if return-value = "max-cli":U then dO:
              assign
              v-skip-next = yes
              ves-err = ves-err + 1.
              NEXT _to-cli.
            end.
            else do:
              ves-err = ves-err + 1.
              next _TO-cli.
            end.
          end. /*if error-status:error then do:*/
          else do:
            delete dc-list.
          end.
        end. /*wehn maria*/
      end CASE.
    end. /*not skip:*/
  end. /*not if available buf_cd-clu then do:*/
END . /*FOR EACH dc-list*/
  /* уничтожение лишних записей */
_mrktr-cli:
FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = p-curr-obj-type
    and buf_cd-clu.obj-code = p-curr-obj-code
    and buf_cd-clu.pos-type = {&cd-type-maria}
    and buf_cd-clu.clu-type = '':U :
  IF buf_cd-clu.charkey_one <> v-cd-list-delete THEN NEXT _mrktr-cli.
  assign
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = v-cd-list-update.
END .
run cd-mrkt_update-marketer-cli in this-procedure (
                                                input locked_cash-desk.db-num
                                                ,input locked_cash-desk.obj-code
                                                ,input locked_cash-desk.pos-type
                                                ,input locked_cash-desk.cash-num
                                              )  no-error .
if error-status:error then do:
  run waitfram-hide in this-procedure .
  undo, return error .
end.

END. /*doe*/
run waitfram-hide in this-procedure .
RUn OpenBR in this-procedure ( input yes, input no, input '':U).
run fill-vars in this-procedure .
run disp-cd in this-procedure .
if ves-err > 0 then
message
SUBSTITUTE("При добавлении клиентов на кассы встретилось &1 кодов,&2" +
            "для которых не удалось создать запись клиента на кассе&2&2" +
            "Эти клиенты на кассы НЕ ДОБАВЛЕНЫ !!!!"
            , ves-err
            ,{&NEW-LINE})
view-as alert-box warning.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      CHARACTER    no-undo.
define variable Line            as      CHARACTER    no-undo.
define variable for-time        as      CHARACTER    no-undo.
define variable v-card-no as character no-undo .

DEFINE FRAME cd-clu-list
X_cd-clu.clu-code COLUMN-LABEL "CLU" FORMAT "999":U
X_cd-clu.cli-type COLUMN-LABEL "Тип!IBS TH" FORMAT "X(3)":U
X_cd-clu.cli-code COLUMN-LABEL "Код!IBS TH" FORMAT "999999999":U
X_cd-clu.to-del COLUMN-LABEL "У" FORMAT "+/":U   /*X_cd-clu.to-DEL*/
X_cd-clu.to-send COLUMN-LABEL "И" FORMAT "+/":U  /*X_cd-clu.to-send*/
X_clients.obj-name  FORMAT "X(50)"
v-card-no  COLUMN-LABEL 'Клиент-Счет' FORMAT "X(11)":U
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 105 PAGE-NUMBER(PrnLibStream) AT 115 FORMAT ">>9" SKIP
Line format "X(130)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 130).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(130)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME cd-clu-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_cd-clu).
DO WHILE available X_cd-clu :
  GET prev br-mcli.
END.
&scop dct-client-obj-type X_clients.obj-type
&scop dct-client-obj-code X_clients.obj-code
GET next br-mcli.
DO WHILE available X_cd-clu :

  Display STREAM PrnLibStream
  X_cd-clu.clu-code
  X_cd-clu.cli-type
  X_cd-clu.cli-code
  X_cd-clu.to-DEL
  X_cd-clu.to-send
  X_clients.obj-name
  {&dct-client-card-no} @ v-card-no
  with FRAME cd-clu-list .
  DOWN STREAM PrnLibStream 1
  with FRAME cd-clu-list  .
  assign
  accum-count = accum-count + 1
  .
  GET next br-mcli.
END.
UNDERLINE  STREAM PrnLibStream
X_cd-clu.clu-code
X_cd-clu.cli-type
X_cd-clu.cli-code
X_cd-clu.to-del
X_cd-clu.to-send
X_clients.obj-name
v-card-no
with FRAME cd-clu-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_cd-clu.clu-code
accum-count @ X_cd-clu.cli-type
with frame cd-clu-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME cd-clu-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-mcli to recid v-doc-rec no-error.
APPLY "entry" to br-mcli.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'cd-clu'
  join-tbl = 'X_cd-clu'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('CLU-code', 'CLU', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('CLI-code', 'Код в TH IBS', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cli-type', 'Тип в TH IBS', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('to-del', 'Статус удаления', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('to-send', 'Статус изменения', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
define input parameter p-a-n-c as character no-undo.
define input parameter p-next as logical no-undo.
define input parameter p-code AS integer no-undo.
DEFINE VARIABLE v-code AS CHARACTER NO-UNDO.
IF input frame {&frame-name} a-n-c = "b-code":U THEN DO:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_cd-clu.cli-code = &1 "
          , p-code)
        ).
END.
IF input frame {&frame-name} a-n-c = "CLU":U THEN DO:
    run OpenBr in this-procedure
        (input false /* p-open-query */
        ,input p-next  /* p-find-next  */
        ,input substitute("and X_cd-clu.clu-code = &1 "
          , p-code)
        ).

END.

apply "entry":u to loc-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-obj-type Dialog-Frame
PROCEDURE proc-find-obj-type :
define input parameter p-a-n-c as character no-undo.
define input parameter p-next as logical no-undo.
define input parameter p-obj-type AS character no-undo.
assign
p-obj-type = replace(p-obj-type, {&double-quote}, "":U)
p-obj-type = replace(p-obj-type, {&single-quote}, {&single-quote} + {&single-quote})
p-obj-type = {&double-quote} + p-obj-type + {&double-quote}
.

run OpenBr in this-procedure
(input false /* p-open-query */
,input p-next  /* p-find-next  */
,input substitute("and X_cd-clu.cli-type = &1 "
  , p-obj-type)
).



apply "entry":u to loc-code in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RUN-dc-list Dialog-Frame
PROCEDURE RUN-dc-list :
define variable v-host-code like ub.sysconf.host-code no-undo .

DO
ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
  run str/dc-list.w (
                INPUT parparentproc
                ,input v-host-code
                ,INPUT p-curr-obj-type
                ,INPUT p-curr-obj-code
                ).
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME