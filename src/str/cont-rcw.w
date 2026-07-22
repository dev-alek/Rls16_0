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

Карточка договора - реквизиты

Автор: Чернова Светлана Александровна
Дата создания: 03/27/06
Author: Svetlana Chernova
Creation date: 03/27/06

*/

/* ***************************  Definitions  ************************** */
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Карточка договора - реквизиты" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i  }

/* Parameters Definitions ---                                           */
define input  parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-host-code        as integer   no-undo .
define input  parameter p-type             as integer   no-undo .  /* 0-наш, 1-контр, 2-поср, 3-агент */
define input  parameter ref-mode           as character no-undo .   /* {&add-def}, {&update}, {&lookup} */
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-obj-type         as character no-undo .
define input-output parameter p-obj-name     as character no-undo .
define input-output parameter p-code-schet   as integer   no-undo .   /* счет договора */
define input-output parameter p-code-schet-2 as integer   no-undo .   /* текущий счет */
define input-output parameter p-kpp          as character no-undo .
define input-output parameter p-inn          as character no-undo .
define input-output parameter p-addres       as character no-undo .
define input-output parameter p-sign         as character no-undo .
define input-output parameter p-sign-post    as character no-undo .
define input-output parameter p-point-io-code   as integer   no-undo .
define input-output parameter p-db-num as integer   no-undo .

/* Local Variable Definitions ---                                       */
define variable ri-schet    as recid  no-undo .
define variable ri-schet-2  as recid  no-undo .

define variable v-current-db-num as integer   no-undo .
define buffer buf_point-io for ub.point-io .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-OK b-exit b-add B-Help RECT-2 RECT-3 ~
b-bank b-bank-2 sign-post sign point-io-code BUTTON-point-io point-io-name name ~
kpp bank-name bik r-schet c-schet curr r-schet-2 curr-2 bank-name-2
&Scoped-Define DISPLAYED-OBJECTS sign-post sign point-io-code point-io-name ~
name inn kpp addres bank-name bik r-schet c-schet curr r-schet-2 curr-2 ~
bank-name-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "О&бновить"
     SIZE 10 BY 1.

DEFINE BUTTON b-bank
     LABEL "&Счет"
     SIZE 10 BY 1.

DEFINE BUTTON b-bank-2
     LABEL "С&чет"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отмена":L
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.

DEFINE BUTTON BUTTON-point-io
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 2.88 BY 1.

DEFINE VARIABLE addres AS CHARACTER FORMAT "X(100)"
     LABEL "Адрес"
      VIEW-AS TEXT
     SIZE 61.25 BY .79.

DEFINE VARIABLE bank-name AS CHARACTER FORMAT "X(40)"
     LABEL "Банк"
      VIEW-AS TEXT
     SIZE 49.5 BY .79.

DEFINE VARIABLE bank-name-2 AS CHARACTER FORMAT "X(40)"
     LABEL "в банке"
      VIEW-AS TEXT
     SIZE 58 BY .79.

DEFINE VARIABLE bik AS CHARACTER FORMAT "X(18)"
     LABEL "БИК"
      VIEW-AS TEXT
     SIZE 23 BY .79.

DEFINE VARIABLE c-schet AS CHARACTER FORMAT "X(20)"
     LABEL "Кор.счет"
      VIEW-AS TEXT
     SIZE 29.63 BY .79.

DEFINE VARIABLE curr AS CHARACTER FORMAT "X(20)"
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 15.38 BY .79.

DEFINE VARIABLE curr-2 AS CHARACTER FORMAT "X(20)"
     LABEL "Валюта"
      VIEW-AS TEXT
     SIZE 15.38 BY .79.

DEFINE VARIABLE point-io-name AS CHARACTER FORMAT "X(56)":U
     VIEW-AS FILL-IN
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE inn AS CHARACTER FORMAT "X(15)"
     LABEL ""
      VIEW-AS TEXT
     SIZE 28.25 BY .79.

DEFINE VARIABLE kpp AS CHARACTER FORMAT "X(15)"
     LABEL ""
      VIEW-AS TEXT
     SIZE 28.25 BY .79.

DEFINE VARIABLE name AS CHARACTER FORMAT "X(40)"
     LABEL "Наименование"
      VIEW-AS TEXT
     SIZE 41 BY .79.

DEFINE VARIABLE r-schet AS CHARACTER FORMAT "X(20)"
     LABEL "Рас.счет"
      VIEW-AS TEXT
     SIZE 27.5 BY .79.

DEFINE VARIABLE r-schet-2 AS CHARACTER FORMAT "X(20)"
     LABEL "Р/C"
      VIEW-AS TEXT
     SIZE 24.13 BY .79.

DEFINE VARIABLE sign AS CHARACTER FORMAT "X(20)"
     LABEL "ФИО"
     VIEW-AS FILL-IN
     SIZE 26.5 BY 1.

DEFINE VARIABLE sign-post AS CHARACTER FORMAT "X(20)"
     LABEL "Должность"
     VIEW-AS FILL-IN
     SIZE 24.63 BY 1.

DEFINE VARIABLE point-io-code AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "Пункт отгрузки/доставки"
     VIEW-AS FILL-IN
     SIZE 6.75 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 68.88 BY 3.63.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 69 BY 2.79.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1.04 COL 2
     b-exit AT ROW 1.04 COL 12
     b-add AT ROW 1.04 COL 22.13
     B-Help AT ROW 1.08 COL 60
     b-bank AT ROW 5.79 COL 60
     b-bank-2 AT ROW 9.79 COL 60
     sign-post AT ROW 12.5 COL 10.88 COLON-ALIGNED
     sign AT ROW 12.5 COL 42.5 COLON-ALIGNED
     point-io-code AT ROW 13.88 COL 24.88 COLON-ALIGNED
     BUTTON-point-io AT ROW 13.88 COL 33.38
     point-io-name AT ROW 13.88 COL 34 COLON-ALIGNED NO-LABEL
     name AT ROW 2.08 COL 14 COLON-ALIGNED
     inn AT ROW 3.21 COL 5.5 COLON-ALIGNED
     kpp AT ROW 3.21 COL 40.25 COLON-ALIGNED
     addres AT ROW 4.29 COL 2.38
     bank-name AT ROW 6 COL 7.13 COLON-ALIGNED
     bik AT ROW 7 COL 6.13 COLON-ALIGNED
     r-schet AT ROW 7 COL 40.5 COLON-ALIGNED
     c-schet AT ROW 8 COL 11.5 COLON-ALIGNED
     curr AT ROW 8 COL 52.5 COLON-ALIGNED
     r-schet-2 AT ROW 10 COL 5.25 COLON-ALIGNED
     curr-2 AT ROW 10 COL 41 COLON-ALIGNED
     bank-name-2 AT ROW 11 COL 9.5 COLON-ALIGNED
     "Реквизиты договора" VIEW-AS TEXT
          SIZE 18.25 BY .92 AT ROW 5 COL 26.63
          FGCOLOR 4
     "Текущий счет" VIEW-AS TEXT
          SIZE 12.88 BY .92 AT ROW 9 COL 29.38
          FGCOLOR 4
     RECT-2 AT ROW 5.42 COL 1.88
     RECT-3 AT ROW 9.42 COL 1.75
     SPACE(0.74) SKIP(2.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Реквизиты".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN addres IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       point-io-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN inn IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Реквизиты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Обновить */
DO:
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  if p-obj-type = {&cmp} then do:
    if p-host-code = p-obj-code then do:
      define buffer buf_sysconf for ub.sysconf .
      find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code .
      assign
        sign-post = buf_sysconf.pay-sign-post
        sign      = buf_sysconf.pay-sign
      .
    end.
    find first ub.firm no-lock where ub.firm.firm-code = p-obj-code no-error.
    if available ub.firm then assign    inn = ub.firm.inn    addres = ub.firm.addres1       kpp = ub.firm.kpp .
  end.
  else do:
    find first ub.person no-lock where ub.person.psn-code = p-obj-code no-error.
    if available ub.person then   assign   inn = ub.person.inn   addres = ub.person.address    kpp = ub.person.kpp .
  end.
  assign name = ub.clients.obj-name .
  display name inn addres kpp sign sign-post with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank Dialog-Frame
ON CHOOSE OF b-bank IN FRAME Dialog-Frame /* Счет */
DO:
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  if not available ub.clients then return.
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
  if ri-schet <> ? then assign rid-list = string(ri-schet) .

  run ref/finschts.w (input parParentProc, input p-host-code, input "b-sel,b-add", input "cmp-host", input p-obj-type,
                 input p-obj-code, input 0, input p-host-code, input 0, input-output v-status_, input-output rid-list).

  if rid-list <> "" then do:
    find first ub.fin-schet no-lock where RECID(fin-schet) = int (rid-list) no-error .
    if available ub.fin-schet then do:
      if ub.fin-schet.status_ = {&deleted-status} then message "Вы выбрали удаленный счет!"  view-as alert-box.
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = ub.fin-schet.host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
      assign
        ri-schet   = int (rid-list)
        p-code-schet = ub.fin-schet.code-schet
        bank-name  = ub.fin-bank.short-name
/*        kpp        = ub.fin-bank.kpp*/
        bik        = ub.fin-bank.bik
        c-schet    = ub.fin-schet.c-schet
        r-schet    = ub.fin-schet.r-schet
        curr       = ub.currency.curr-abbr
      .
    end.
  end.
  else assign  ri-schet = ?  p-code-schet = ?  bank-name = ""    bik = ""  c-schet = ""   r-schet = "" curr = "" .
  display bank-name bik c-schet r-schet curr with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bank-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bank-2 Dialog-Frame
ON CHOOSE OF b-bank-2 IN FRAME Dialog-Frame /* Счет */
DO:
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .
  if not available ub.clients then return.
  define variable rid-list as  char no-undo . /* список recid'ов выбранных */
  define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
  if ri-schet-2 <> ? then
  assign rid-list = string(ri-schet-2) .

  run ref/finschts.w (input parParentProc, input p-host-code, input "b-sel,b-add", input "cmp-host", input p-obj-type,
                 input p-obj-code, input 0, input p-host-code, input 0, input-output v-status_, input-output rid-list).

  if rid-list <> "" then do:
    find first ub.fin-schet no-lock where RECID(fin-schet) = int (rid-list) no-error .
    if available ub.fin-schet then do:
      if ub.fin-schet.status_ = {&deleted-status} then message "Вы выбрали удаленный счет!"  view-as alert-box.
      find first ub.fin-bank no-lock where ub.fin-bank.host-code = ub.fin-schet.host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
      find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
      assign
        ri-schet-2   = int (rid-list)
        p-code-schet-2 = ub.fin-schet.code-schet
        bank-name-2  = ub.fin-bank.short-name
        r-schet-2    = ub.fin-schet.r-schet
        curr-2       = ub.currency.curr-abbr
      .
    end.
  end.
  else assign  ri-schet-2 = ?  p-code-schet-2 = ?  bank-name-2 = ""   r-schet-2 = "" curr-2 = ""   .
  display bank-name-2 curr-2  r-schet-2 with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-OK Dialog-Frame
ON CHOOSE OF b-OK IN FRAME Dialog-Frame /* Ввод  */
DO:
  if ref-mode <> {&lookup} and ref-mode <> "history" then do:
    assign inn name addres kpp  sign  sign-post .
    assign
      p-obj-name  = name
      p-kpp       = kpp
      p-inn       = inn
      p-addres    = addres
      p-sign      = sign
      p-sign-post = sign-post
      p-point-io-code = point-io-code
      p-db-num    = v-current-db-num
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-point-io
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-point-io Dialog-Frame
ON CHOOSE OF BUTTON-point-io IN FRAME Dialog-Frame /* 2 */
DO:
  define variable ri-list as character no-undo.
  { gbl/stdbtn.i }

  if available buf_point-io then  assign ri-list = string(recid(buf_point-io)) .

  run ref/point-io.w
        (input  parparentproc
        ,input  "b-add,b-sel"
        ,input  v-current-db-num
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  {&g___object}
        ,input  'all'
        ,input-output ri-list
        ).

  if ri-list <> "":U then do:
    FIND FIRST buf_point-io WHERE recid( buf_point-io ) = integer(entry(1, ri-list)) NO-LOCK .
    assign
      point-io-code = buf_point-io.point-code
      point-io-name = buf_point-io.point-name
    .
  end.
  else do:
    assign
      point-io-code = 0
      point-io-name = ""
    .
  end.
  display point-io-code  point-io-name  with frame {&frame-name} .
  apply "CHOOSE"  to sign-post  IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME point-io-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL point-io-code Dialog-Frame
ON LEAVE OF point-io-code IN FRAME Dialog-Frame /* Пункт отгрузки/доставки */
DO:
  assign point-io-code .
  if point-io-code > 0 then do:
    find first buf_point-io no-lock
      where buf_point-io.point-code = point-io-code
        and buf_point-io.db-num        = v-current-db-num
        and buf_point-io.cli-type      = p-obj-type
       and buf_point-io.cli-code      = p-obj-code
    no-error .
    if available buf_point-io then do:
      assign
        point-io-code = buf_point-io.point-code
        point-io-name = buf_point-io.point-name
      .
      display point-io-code  point-io-name  with frame {&frame-name} .
    end.
    else apply "CHOOSE"  to BUTTON-point-io  IN FRAME Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL point-io-code Dialog-Frame
ON RETURN OF point-io-code IN FRAME Dialog-Frame /* Пункт отгрузки/доставки */
DO:
  assign point-io-code .
  find first buf_point-io no-lock
    where buf_point-io.point-code = point-io-code
      and buf_point-io.db-num  = v-current-db-num
      and buf_point-io.cli-type      = p-obj-type
      and buf_point-io.cli-code      = p-obj-code
  no-error .
  if available buf_point-io then do:
    assign
      point-io-code = buf_point-io.point-code
      point-io-name = buf_point-io.point-name
    .
    display point-io-code  point-io-name  with frame {&frame-name} .
  end.
  else apply "CHOOSE"  to BUTTON-point-io  IN FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }
  { gbl/curdbnum.i v-current-db-num }

  ASSIGN inn :LABEL IN FRAME {&FRAME-NAME} = "{&abbr_inn_allshift}"
         kpp :LABEL IN FRAME {&FRAME-NAME} = "{&abbr_kpp_allshift}".
  RUN enable_UI.

  run go-proc no-error.
  if error-status:error then return no-apply.

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
  DISPLAY sign-post sign point-io-code point-io-name name inn kpp addres bank-name
          bik r-schet c-schet curr r-schet-2 curr-2 bank-name-2
      WITH FRAME Dialog-Frame.
  ENABLE b-OK b-exit b-add B-Help RECT-2 RECT-3 b-bank b-bank-2 sign-post sign
         point-io-code BUTTON-point-io point-io-name name kpp bank-name bik r-schet
         c-schet curr r-schet-2 curr-2 bank-name-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE go-proc Dialog-Frame
PROCEDURE go-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = p-code-schet no-error .
  if available ub.fin-schet then do:
    find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
    find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
    assign
      ri-schet   = recid (fin-schet)
      bank-name  = ub.fin-bank.short-name
      bik        = ub.fin-bank.bik
      name       = p-obj-name
      c-schet    = ub.fin-schet.c-schet
      r-schet    = ub.fin-schet.r-schet
      curr       = ub.currency.curr-abbr
    .
  end.
  else assign  ri-schet = ?  p-code-schet = ?  bank-name = ""    bik = ""  c-schet = ""   r-schet = "" curr = "" .
  display bank-name kpp bik c-schet r-schet curr with frame {&frame-name}.

  find first ub.fin-schet no-lock where ub.fin-schet.host-code = p-host-code and ub.fin-schet.code-schet = p-code-schet-2 no-error .
  if available ub.fin-schet then do:
    find first ub.currency no-lock where ub.currency.curr-code = ub.fin-schet.curr-code .
    find first ub.fin-bank no-lock where ub.fin-bank.host-code = p-host-code and ub.fin-bank.code-bank = ub.fin-schet.code-bank no-error .
    assign
      ri-schet-2   = recid (fin-schet)
      p-code-schet-2 = ub.fin-schet.code-schet
      bank-name-2  = ub.fin-bank.short-name
      r-schet-2    = ub.fin-schet.r-schet
      curr-2       = ub.currency.curr-abbr
    .
  end.
  else assign  ri-schet-2 = ?  p-code-schet-2 = ?  bank-name-2 = ""   r-schet-2 = ""  curr-2 = "" .
  display bank-name-2  r-schet-2  curr-2  with frame {&frame-name}.

  define variable str      as character no-undo .
  find first ub.clients no-lock where ub.clients.obj-type = p-obj-type and ub.clients.obj-code = p-obj-code no-error .

  case p-type :
    when 0 then do:
      assign str = "Реквизиты фирмы "       + p-obj-name + " код " + string(p-obj-code) .
    end.
    when 1 then do:
      assign str = "Реквизиты контрагента " + p-obj-name + " (" + p-obj-type + " " + string(p-obj-code) + ")" .
    end.
    when 2 then do:
      assign str = "Реквизиты посредника "  + p-obj-name + " (" + p-obj-type + " " + string(p-obj-code) + ")" .
    end.
    when 3 then do:
      assign str = "Реквизиты агента "      + p-obj-name + " (" + p-obj-type + " " + string(p-obj-code) + ")" .
    end.
  end.
  ASSIGN frame {&frame-name}:TITLE = str.

  if ref-mode = {&lookup} or ref-mode = "history"  then do:
    disable b-bank b-bank-2 inn addres sign sign-post b-add point-io-code point-io-name BUTTON-point-io with frame {&frame-name}.
    b-OK:label in frame {&frame-name} = "&Выход " .
    b-exit:visible = no .
  end.
  if ref-mode = {&update} then do:
    if ri-schet <> ? then disable b-bank with frame {&frame-name}.
  end.

  if p-point-io-code > 0 then do:
    find first buf_point-io no-lock
      where buf_point-io.point-code = p-point-io-code
        and buf_point-io.db-num     = v-current-db-num
        and buf_point-io.cli-type   = p-obj-type
        and buf_point-io.cli-code   = p-obj-code
    no-error .
  end.
  else do:
    find first buf_point-io no-lock
      where buf_point-io.point-code = p-point-io-code
        and buf_point-io.db-num     = v-current-db-num
        and buf_point-io.cli-type   = p-obj-type
        and buf_point-io.cli-code   = p-obj-code
        and buf_point-io.is-default = yes
    no-error .
  end.

  if available buf_point-io then do:
    assign
      point-io-code = buf_point-io.point-code
      point-io-name = buf_point-io.point-name
    .
    display point-io-code  point-io-name  with frame {&frame-name} .
  end.

  assign
    name      = p-obj-name
    inn       = p-inn
    addres    = p-addres
    sign      = p-sign
    sign-post = p-sign-post
    kpp       = p-kpp
  .
  display {&DISPLAYED-OBJECTS} with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME