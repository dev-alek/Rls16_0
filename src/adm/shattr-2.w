&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE BUFFER X_shop FOR ub.shop.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "get-chk"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'get-chk'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/gbclcode.i }
{ gbl/cur-time.i }

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define variable v-tth as handle no-undo .
define variable v-t-shft as integer no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-no-get-chk t-cas-curs ~
t-hnum t-cas-shft RS-REJIM l-loc-hour l-loc-min l-loc-sec t-dc-mask ~
t-card-by-mask t-ptrl-check t-annu-check t-z-check t-is-100-discnt ~
r-cashier F-shift l-t-shift
&Scoped-Define DISPLAYED-OBJECTS t-no-get-chk t-cas-curs t-hnum t-cas-shft ~
RS-REJIM RS-v-shft l-loc-hour l-loc-min l-loc-sec T-next E-comments ~
t-dc-mask t-card-by-mask t-ptrl-check t-annu-check t-z-check ~
t-is-100-discnt zero-cashier cashier-psn-code-name F-shift l-t-shift

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 l-loc-hour l-loc-min l-loc-sec

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-cashier
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE E-comments AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 1.93
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE cashier-psn-code-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-shift AS CHARACTER FORMAT "X(256)":U INITIAL "Способ обработки виртуальных смен"
      VIEW-AS TEXT
     SIZE 49.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.3 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение часа"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.3 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение минут"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-loc-sec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.3 BY 1 TOOLTIP "Стрелка вверх, вниз - изменение секунд"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-t-shift AS CHARACTER FORMAT "X(256)":U INITIAL "Время начала пересменки в магазине"
      VIEW-AS TEXT
     SIZE 35 BY .67 NO-UNDO.

DEFINE VARIABLE zero-cashier AS INTEGER FORMAT "99999" INITIAL 0
     LABEL "<НУЛЕВОЙ> кассир"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1.07 NO-UNDO.

DEFINE VARIABLE RS-REJIM AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет вирт. смен", 0,
"Режим 1", 1,
"Режим 2", 2
     SIZE 18 BY 2.77 NO-UNDO.

DEFINE VARIABLE RS-v-shft AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет вирт. смен", 0,
"Запрос оператору", 1,
"Дата учета чека определяется по чекам закрытия кассовых смен", 2
     SIZE 70 BY 3
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-annu-check AS LOGICAL INITIAL no
     LABEL "принимать аннулированные чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-card-by-mask AS LOGICAL INITIAL no
     LABEL "использовать маски ДК при приеме чеков с касс для персонифицированных карт"
     VIEW-AS TOGGLE-BOX
     SIZE 94 BY 1 NO-UNDO.

DEFINE VARIABLE t-cas-curs AS LOGICAL INITIAL no
     LABEL "брать курсы валют в чек из спула, а не из бэк-офиса"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-cas-shft AS LOGICAL INITIAL no
     LABEL "использовать смены на кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-dc-mask AS LOGICAL INITIAL no
     LABEL "использовать маски ДК при приеме чеков с касс для неперсонифицированных карт"
     VIEW-AS TOGGLE-BOX
     SIZE 94 BY 1 NO-UNDO.

DEFINE VARIABLE t-hnum AS LOGICAL INITIAL no
     LABEL "при обработке спулов номер магазина для чеков брать из спулов"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-is-100-discnt AS LOGICAL INITIAL no
     LABEL "принимать чеки со 100% скидкой"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE T-next AS LOGICAL INITIAL no
     LABEL "Сдвиг вперед"
     VIEW-AS TOGGLE-BOX
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-no-get-chk AS LOGICAL INITIAL no
     LABEL "НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-ptrl-check AS LOGICAL INITIAL no
     LABEL "принимать специф.чеки АЗК:сброс,перелив, перевод транз, техпролив"
     VIEW-AS TOGGLE-BOX
     SIZE 70 BY 1 NO-UNDO.

DEFINE VARIABLE t-z-check AS LOGICAL INITIAL no
     LABEL "принимать чеки z-отчета"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-no-get-chk AT ROW 2.13 COL 4
     t-cas-curs AT ROW 3.13 COL 4
     t-hnum AT ROW 4.13 COL 4
     t-cas-shft AT ROW 5.13 COL 4
     RS-REJIM AT ROW 7.37 COL 3 NO-LABEL
     RS-v-shft AT ROW 7.37 COL 23 NO-LABEL
     l-loc-hour AT ROW 10.87 COL 39 COLON-ALIGNED NO-LABEL
     l-loc-min AT ROW 10.87 COL 44 COLON-ALIGNED NO-LABEL
     l-loc-sec AT ROW 10.87 COL 49 COLON-ALIGNED NO-LABEL
     T-next AT ROW 10.87 COL 56.5
     E-comments AT ROW 12.13 COL 1 NO-LABEL
     t-dc-mask AT ROW 14.6 COL 3.5
     t-card-by-mask AT ROW 15.6 COL 3.5
     t-ptrl-check AT ROW 16.6 COL 3.5
     t-annu-check AT ROW 17.6 COL 3.5
     t-z-check AT ROW 17.6 COL 41 WIDGET-ID 12
     t-is-100-discnt AT ROW 18.6 COL 3.5 WIDGET-ID 2
     zero-cashier AT ROW 19.93 COL 18.5 COLON-ALIGNED WIDGET-ID 10
     cashier-psn-code-name AT ROW 20 COL 31.5 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     r-cashier AT ROW 20 COL 60 WIDGET-ID 6
     F-shift AT ROW 6.37 COL 1.5 COLON-ALIGNED NO-LABEL
     l-t-shift AT ROW 11.13 COL 2.5 NO-LABEL
     "(аннулированные заказы РЕСТОРАНА)" VIEW-AS TEXT
          SIZE 34 BY 1 AT ROW 20 COL 63.5 WIDGET-ID 8
          FGCOLOR 4
     SPACE(1.79) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Опции закачки чеков"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cashier-psn-code-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       cashier-psn-code-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR E-comments IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-loc-hour IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       l-loc-hour:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN l-loc-min IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       l-loc-min:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN l-loc-sec IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN
       l-loc-sec:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN l-t-shift IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR RADIO-SET RS-v-shft IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       RS-v-shft:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-next IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       T-next:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN zero-cashier IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       zero-cashier:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Опции закачки чеков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 24 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour Dialog-Frame
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame
DO:
    assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
   if {&SELF-NAME} < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
   RUN set-comments IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min Dialog-Frame
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
RUN set-comments IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-sec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec Dialog-Frame
ON CURSOR-DOWN OF l-loc-sec IN FRAME Dialog-Frame
DO:
  assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} -  1.
  if {&SELF-NAME} < 0 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec Dialog-Frame
ON CURSOR-UP OF l-loc-sec IN FRAME Dialog-Frame
DO:
   assign  frame {&frame-name} {&SELF-NAME} .
  {&SELF-NAME} = {&SELF-NAME} +  1.
  if {&SELF-NAME} > 59 then return no-apply.
  display {&SELF-NAME} with frame {&frame-name}.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-sec Dialog-Frame
ON LEAVE OF l-loc-sec IN FRAME Dialog-Frame
DO:
   assign frame {&frame-name} {&SELF-NAME} .
   if {&SELF-NAME} > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
  assign
  v-t-shft = 3600 * l-loc-hour + 60 * l-loc-min + l-loc-sec.
RUN set-comments IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cashier
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cashier Dialog-Frame
ON CHOOSE OF r-cashier IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cashier-code AS integer NO-UNDO.
DEFINE BUFFER buf_staff FOR ub.staff.
run ref/staffs.w ( input parparentproc
                    , input "b-sel"
                    , input {&role-cashier}
                    , input v-db-num
                    , input 0
                    , output v-rid-list ) .
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_staff no-lock WHERE
      recid( buf_staff ) = integer( v-rid-list )  .
      v-cashier-code = buf_staff.staff-code .
  run get-cashier in this-procedure ( input buf_staff.staff-code).
END.
DISPLAY
zero-cashier
cashier-psn-code-name
WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-REJIM
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-REJIM Dialog-Frame
ON VALUE-CHANGED OF RS-REJIM IN FRAME Dialog-Frame
DO:
  IF p-mode <> {&LOOKUP}  THEN
  ASSIGN
  rs-rejim.
  CASE rs-rejim:
    WHEN 0 THEN DO:
      rs-v-shft = 0.
      HIDE
      rs-v-shft
      IN FRAME {&FRAME-NAME}.
      if v-t-shft = 0 then do:
         hide
        l-t-shift
        l-loc-hour
        l-loc-min
        l-loc-sec
        t-next
        IN FRAME {&FRAME-NAME}.
       end.
    END.
    WHEN 1 THEN DO:
      rs-v-shft = 1.
      DISPLAY
      rs-v-shft
      WITH FRAME {&FRAME-NAME}.
      HIDE
      l-t-shift
      l-loc-hour
      l-loc-min
      l-loc-sec
      t-next
      IN FRAME {&FRAME-NAME}.
    END.
    WHEN 2 THEN DO:
      rs-v-shft = 2.
      t-next = YES.
      DISPLAY
      rs-v-shft
      l-t-shift
      l-loc-hour
      l-loc-min
      l-loc-sec
      t-next
      WITH FRAME {&FRAME-NAME}.
    END.
  END CASE.
  RUN set-comments IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-v-shft
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-v-shft Dialog-Frame
ON VALUE-CHANGED OF RS-v-shft IN FRAME Dialog-Frame
DO:
IF p-mode = {&LOOKUP}  THEN RETURN NO-APPLY.
IF rs-v-shft:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN rs-v-shft.
END.
ELSE DO:
    rs-v-shft = 0.
END.
CASE RS-v-shft:
    WHEN 2 THEN DO:
       DISPLAY
       l-loc-hour
       l-loc-min
       l-loc-sec
       WITH FRAME {&FRAME-NAME}.

    END.
    WHEN 0 OR WHEN 1 THEN DO:

        ASSIGN
        l-loc-hour = 0
        l-loc-min = 0
        l-loc-sec = 0
        .
        hide
        l-loc-hour
        l-loc-min
        l-loc-sec
        l-t-shift
        IN  FRAME {&frame-name}.
    END.
END CASE.
RUN set-comments IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-cas-shft
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-cas-shft Dialog-Frame
ON VALUE-CHANGED OF t-cas-shft IN FRAME Dialog-Frame /* использовать смены на кассе */
DO:
define variable v-old-t-cas-shft as logical no-undo .
  IF p-mode = {&LOOKUP}  THEN RETURN NO-APPLY.
  ASSIGN
  v-old-t-cas-shft = t-cas-shft
  t-cas-shft.
  CASE t-cas-shft:
  WHEN yes THEN DO:
     ENABLE
     RS-rejim
     f-shift
     WITH FRAME {&FRAME-NAME}.
     APPLY "VALUE-CHANGED" TO rs-v-shft.
  END.
  WHEN no THEN DO:
    if v-old-t-cas-shft <> t-cas-shft then do:
      ASSIGN
      RS-rejim = 0
      t-next = NO
      .
      disable
      RS-rejim
      t-next
      WITH FRAME {&FRAME-NAME}.
      HIDE
      t-next
      rs-rejim
      f-shift
      rs-v-shft
      IN FRAME  {&FRAME-NAME}.
    end.
    DISPLAY
    l-t-shift
    l-loc-hour
    l-loc-min
    l-loc-sec
    WITH FRAME {&frame-name}.
    RUN set-comments IN THIS-PROCEDURE.
  END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-next Dialog-Frame
ON VALUE-CHANGED OF T-next IN FRAME Dialog-Frame /* Сдвиг вперед */
DO:
  ASSIGN
  t-next.
  CASE t-next:
      WHEN NO THEN DO:
         IF T-CAS-SHFT THEN DO:
             ASSIGN
             RS-V-SHFT = 1
             .
             DISPLAY
             RS-V-SHFT
             WITH FRAME {&FRAME-NAME}.
             DISABLE
             RS-V-SHFT
             WITH FRAME {&FRAME-NAME}.

         END.
      END.
      WHEN YES  THEN DO:
          ASSIGN
          rs-v-shft = 1
          T-CAS-SHFT = YES
          .
          DISPLAY
          rs-v-shft
          T-CAS-SHFT
          WITH FRAME {&frame-name}.
          DISABLE
          rs-v-shft
          T-CAS-SHFT
          WITH FRAME {&frame-name}.
      END.
  END CASE.
  RUN set-comments IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-no-get-chk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-no-get-chk Dialog-Frame
ON VALUE-CHANGED OF t-no-get-chk IN FRAME Dialog-Frame /* НЕТ ПРИЕМА ЧЕКОВ В МАГАЗИНЕ */
DO:
    ASSIGN
  t-no-get-chk.
  CASE t-no-get-chk:
      WHEN YES  THEN DO:
         rs-rejim = 0.
         APPLY "value-changed" TO t-cas-shft.
         APPLY "value-changed" TO rs-rejim.
         run set-comments in this-procedure .
         DISABLE
         RS-v-shft
         t-annu-check
         t-z-check
         t-card-by-mask
         t-cas-curs
         t-cas-shft
         t-dc-mask
         t-hnum
         T-next
         t-ptrl-check
         t-is-100-discnt
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN NO  THEN DO:
         RUN myenable IN THIS-PROCEDURE.
      END.
  END CASE.
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
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = {&shop} then do:
    FIND FIRST X_shop NO-LOCK WHERE X_shop.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_shop THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i ~{&shop~} p-obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-get-chk}
        and locked_thbj-attr.prop-code = '':U NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-get-chk}
    and   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.

  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.

  RUN Myenable in this-procedure .
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
  DISPLAY t-no-get-chk t-cas-curs t-hnum t-cas-shft RS-REJIM RS-v-shft
          l-loc-hour l-loc-min l-loc-sec T-next E-comments t-dc-mask
          t-card-by-mask t-ptrl-check t-annu-check t-z-check t-is-100-discnt
          zero-cashier cashier-psn-code-name F-shift l-t-shift
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-no-get-chk t-cas-curs t-hnum t-cas-shft
         RS-REJIM l-loc-hour l-loc-min l-loc-sec t-dc-mask t-card-by-mask
         t-ptrl-check t-annu-check t-z-check t-is-100-discnt r-cashier F-shift
         l-t-shift
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dop-time AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-get-chk}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT TABLE-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-get-chk_cas-curs} THEN DO:
    ASSIGN
    t-cas-curs = thbjattr_thbj-attr.property-value-logical
    t-cas-curs:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_hnum} THEN DO:
    ASSIGN
    t-hnum = thbjattr_thbj-attr.property-value-logical
    t-hnum:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_cas-shft} THEN DO:
    ASSIGN
    t-cas-shft = thbjattr_thbj-attr.property-value-logical
    t-cas-shft:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_v-shft} THEN DO:
    ASSIGN
    RS-v-shft = thbjattr_thbj-attr.property-value-integer
    rs-v-shft:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_t-shft} THEN DO:
    ASSIGN
    t-next  = thbjattr_thbj-attr.property-value-integer < 0
    v-t-shft = abs(thbjattr_thbj-attr.property-value-integer)
    v-dop-time = string(v-t-shft, "hh:mm:ss")
    l-loc-hour = integer(SUBSTRING(v-dop-time, 1, 2))
    l-loc-min = integer(SUBSTRING(v-dop-time, 4, 2))
    l-loc-sec = integer(SUBSTRING(v-dop-time, 7, 2))
    .
  END.
  IF v-entry = {&attr-get-chk_dc-mask} THEN DO:
    ASSIGN
    t-dc-mask = thbjattr_thbj-attr.property-value-logical
    t-dc-mask:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_ptrl-check} THEN DO:
    ASSIGN
    t-ptrl-check = thbjattr_thbj-attr.property-value-logical
    t-ptrl-check:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_card-by-mask} THEN DO:
    ASSIGN
    t-card-by-mask = thbjattr_thbj-attr.property-value-logical
    t-card-by-mask:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_annu-check} THEN DO:
    ASSIGN
    t-annu-check = thbjattr_thbj-attr.property-value-logical.
    t-annu-check:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_z-check} THEN DO:
    ASSIGN
    t-z-check = thbjattr_thbj-attr.property-value-logical.
    t-z-check:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_no-get-chk} THEN DO:
    ASSIGN
    t-no-get-chk = thbjattr_thbj-attr.property-value-logical
    t-no-get-chk:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_is-100-discnt} THEN DO:
    ASSIGN
    t-is-100-discnt = thbjattr_thbj-attr.property-value-logical
    t-is-100-discnt:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-get-chk_zero-cashier} THEN DO:
    ASSIGN
    zero-cashier = thbjattr_thbj-attr.property-value-integer
    zero-cashier:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.
assign
rs-rejim = (if t-cas-shft then rs-v-shft else 0).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-cashier Dialog-Frame
PROCEDURE get-cashier :
DEFINE INPUT PARAMETER p-cashier-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-cashier-psn-code AS integer NO-UNDO.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_clients for ub.clients.
run cur-time in this-procedure ( output v-today, output v-time).
   assign
   v-cashier-psn-code = gbclcode-is-this-db-role( INPUT {&role-cashier}
                                                 ,INPUT v-db-num
                                                 ,INPUT p-cashier-code
                                                 ,input v-today
                                                 ) NO-ERROR.
   IF NOT ERROR-STATUS:ERROR THEN DO:
     FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = {&prs}
            AND buf_clients.obj-code = v-cashier-psn-code NO-ERROR.
     IF AVAILABLE buf_clients THEN DO:
         ASSIGN
          cashier-psn-code-name = buf_Clients.obj-name
         zero-cashier = p-cashier-code
         .

     END.
     ELSE DO:
      if p-cashier-code > 0 then do:
      MESSAGE
      "Ошибка при определении кассира"
      VIEW-AS ALERT-BOX.
      end.
     END.
   END.
   ELSE DO:
    if p-cashier-code > 0 then do:
      MESSAGE
      "Ошибка при определении кассира"
      VIEW-AS ALERT-BOX.
    end.
  END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + (if p-obj-type = {&cmp} then " фирма" else " маг") + STRING(p-obj-code)
v-tab-order = "t-no-get-chk,t-cas-curs,t-hnum,t-cas-shft,RS-rejim,l-loc-hour,l-loc-min,l-loc-sec,t-split-check,t-dc-mask,t-card-by-mask,t-ptrl-check,t-annu-check,t-z-check,t-is-100-discnt,r-cashier"
.
RUN get-cashier in this-procedure ( input zero-cashier) .
DISPLAY
t-no-get-chk
rs-rejim
t-cas-curs
t-hnum
t-cas-shft
E-comments
t-dc-mask
t-card-by-mask
t-ptrl-check
t-annu-check
t-z-check
t-is-100-discnt
zero-cashier
cashier-psn-code-name
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
t-no-get-chk WHEN p-mode = {&UPDATE}
t-cas-curs WHEN p-mode = {&UPDATE}
t-hnum WHEN p-mode = {&UPDATE}
t-cas-shft WHEN p-mode = {&UPDATE}
t-dc-mask WHEN p-mode = {&UPDATE}
t-card-by-mask WHEN p-mode = {&UPDATE}
t-ptrl-check WHEN p-mode = {&UPDATE}
t-annu-check WHEN p-mode = {&UPDATE}
t-z-check WHEN p-mode = {&UPDATE}
l-loc-hour WHEN p-mode = {&UPDATE}
l-loc-sec WHEN p-mode = {&UPDATE}
l-loc-min WHEN p-mode = {&UPDATE}
t-next WHEN p-mode = {&UPDATE}
t-is-100-discnt WHEN p-mode = {&UPDATE}
r-cashier WHEN p-mode = {&UPDATE} and p-obj-type = {&shop}
WITH FRAME {&frame-name}.
if rs-rejim = 0 then do:
  HIDE
  rs-v-shft
  in frame {&frame-name} .
end.
if v-t-shft = 0 then do:
  hide
  l-loc-hour
  l-loc-sec
  l-loc-min
  t-next
  in FRAME {&frame-name}.
end.
else do:
  display
  l-loc-hour
  l-loc-sec
  l-loc-min
  t-next
  with FRAME {&frame-name}.
end.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit
  IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  .
END.
APPLY "value-changed" TO t-cas-shft.
APPLY "value-changed" TO rs-rejim.
run set-comments in this-procedure .
IF t-no-get-chk = YES THEN DO:
  APPLY "value-changed" TO t-no-get-chk.
END .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE VARIABLE l-shift-on AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-t-shft AS integer NO-UNDO.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
ASSIGN
FRAME {&FRAME-NAME}
t-no-get-chk
t-cas-curs
t-cas-shft
t-hnum
t-dc-mask
t-ptrl-check
t-card-by-mask
t-annu-check
t-z-check
t-is-100-discnt
zero-cashier
.
IF RS-v-shft:SENSITIVE THEN DO:
    ASSIGN
    rs-v-shft.
END.
IF l-loc-hour:SENSITIVE THEN DO:
    ASSIGN
    l-loc-hour l-loc-min l-loc-sec.
    v-t-shft = (l-loc-hour * 3600 + l-loc-min * 60 + l-loc-sec).

END.

IF p-obj-type = {&shop} THEN DO:
    /*найдем параметр - использовать смены глобально на объекте или нет*/
{ gbl/objat.i
  {&shop}
  p-obj-code
  "'shift-on=request'"
  l-shift-on
}
  if l-shift-on and not t-cas-shft then do:
     message "На текущем объекте требуется использование смен" skip
     "а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо." skip (2)
    view-as alert-box ERROR.
    undo, return ERROR.
  end.
  IF l-shift-on AND v-t-shft <> 0 THEN DO:
      message
      "На текущем объекте требуется использование смен,"
      "а настройка ВРЕМЯ ПЕРЕСМЕНКИ включена - это недопустимо." skip (2)
      view-as alert-box ERROR.
      undo, return ERROR.
  END.
END.

assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:

    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    if wh:sensitive
    or wh:name = "zero-cashier"
    then do:
      assign
      buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-get-chk_t-shft}.
assign
thbjattr_thbj-attr.property-value-integer = (IF t-cas-shft THEN 1 ELSE (-1)) * v-t-shft
.
release thbjattr_thbj-attr.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if v-same = no then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
run adm/shattri.p (
              input "check":U
             , input p-obj-type
             , input p-obj-code
             , input {&attr-get-chk}
             , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output TABLE-handle v-tth
            ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
RUN thbjattr_set-section IN THIS-PROCEDURE (
     input p-obj-type
    ,input p-obj-code
    ,input {&attr-get-chk}
    ,input table thbjattr_thbj-attr
) NO-ERROR.
IF ERROR-STATUS:error THEN do:
  MESSAGE ERROR-STATUS:get-message(1) SKIP
  RETURN-VALUE
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-comments Dialog-Frame
PROCEDURE set-comments :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-t-shft AS INTEGER NO-UNDO.
DEFINE VARIABLE v-str AS character NO-UNDO.
IF l-loc-hour:VISIBLE IN FRAME {&frame-name} THEN DO:
    ASSIGN
    FRAME {&FRAME-NAME}
    l-loc-hour l-loc-min l-loc-sec.
    ASSIGN
    v-t-shft = l-loc-hour * 3600 + l-loc-min * 60 + l-loc-sec.
    IF NOT t-next THEN DO:
       ASSIGN
       v-str = SUBSTITUTE("Чеки, пробитые до &1 будут учитываться ПРЕДЫДУЩИМ днем", STRING(v-t-shft, "hh:mm:ss"))
       .

    END.
    ELSE DO:
       ASSIGN
       v-str = SUBSTITUTE("Чеки, пробитые после &1 будут учитываться СЛЕДУЮЩИМ днем", STRING(v-t-shft, "hh:mm:ss"))
       .
   END.
END.
e-comments:SCREEN-VALUE = v-str.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
