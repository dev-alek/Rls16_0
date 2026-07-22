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

Список автозаказов

Автор: Мазуров Виталий Александрович
Дата создания: 08/03/11
Author: Mazurov Vitaliy
Creation date: 08/03/11

------------------------------------------------------------------------*/
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список автозаказов ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

{ cus/df-zakaz.i new }
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new  }
/*{ rep/repfrm.i def   }*/

define variable v-select-obj-name  as character no-undo .
define variable v-select-obj-type  as character no-undo .
define variable v-select-obj-code  as integer   no-undo .
define variable v-select-contract  as integer   no-undo .
define variable v-select-host-code as integer   no-undo .
define variable v-select-node-code as character no-undo .
define variable v-flt-obj-name     as character no-undo .
define variable v-flt-obj-type     as character no-undo .
define variable v-flt-obj-code     as integer   no-undo .
define variable p-method           as character no-undo init ''.
define variable v-save-mode        as logical   no-undo .
define variable v-region           as integer   no-undo .
define variable v-ord-type         as character no-undo .

DEFINE TEMP-TABLE tt-dis-some-rule LIKE ub.dis-some-rule .
DEFINE BUFFER buf_dis-some-rule FOR ub.dis-some-rule .
define buffer buf_clients       for ub.clients .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

function get-wdays returns character (input p-wdays as character) :
    define variable v-i     as integer   no-undo .
    define variable v-rez   as character no-undo init "".
    define variable v-wdays as character no-undo extent 7 init ["Пн","Вт","Ср","Чт","Пт","Сб","Вс"].
    do v-i = 1 to num-entries(p-wdays):
        if entry(v-i, p-wdays) = "no" then next .
        if v-rez = "" then v-rez = v-wdays [v-i] .
        else v-rez = v-rez + "," + v-wdays [v-i] .
    end.
    return v-rez .
end function.

function get-node returns character (input p-node as integer) :
    define buffer buf_gds-grp for ub.gds-grp .
    find first buf_gds-grp no-lock
    where buf_gds-grp.node-code = p-node no-error .
    if avail buf_gds-grp then return buf_gds-grp.node-name .
    else return "Группа не найдена" .
end function.

 /*ставить ли защиту на глубину рекурсии?*/
function get-gds-grp-lst returns character (input p-recid as character) :
    define buffer buf_gds-grp for ub.gds-grp .
    define buffer src_gds-grp for ub.gds-grp .
    define variable v-rez as character no-undo init "" .

    find first buf_gds-grp where string(recid(buf_gds-grp)) = p-recid no-lock no-error.
    if avail buf_gds-grp then do:
        if buf_gds-grp.is-term = yes then do:
            v-rez = string(buf_gds-grp.node-code) .
        end.
        else do:
            for each src_gds-grp no-lock
            where src_gds-grp.upper-code = buf_gds-grp.node-code
            :
                v-rez = ( if v-rez = "" then get-gds-grp-lst( string(recid(src_gds-grp)) ) else v-rez + "," + get-gds-grp-lst( string(recid(src_gds-grp)) ) ).
            end.
        end.
    end.

    return v-rez .
end function.

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-some

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dis-some-rule

/* Definitions for BROWSE br-dis-some                                   */
&Scoped-define FIELDS-IN-QUERY-br-dis-some tt-dis-some-rule.templ-rl-root tt-dis-some-rule.charkey_three tt-dis-some-rule.nonunique tt-dis-some-rule.key#_one tt-dis-some-rule.key#_two
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-some
&Scoped-define SELF-NAME br-dis-some
&Scoped-define QUERY-STRING-br-dis-some FOR EACH tt-dis-some-rule NO-LOCK
&Scoped-define OPEN-QUERY-br-dis-some OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-some-rule NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-dis-some tt-dis-some-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-some tt-dis-some-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-dis-some}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 ~
r-region cb-zakaz b-contr b-contract b-grp v-from v-to b-method v-wday-1 v-repeat ~
v-wday-2 v-days-do v-wday-3 v-days-fale v-wday-4 v-wday-5 v-wday-6 v-wday-7 ~
v-flag b-add B-lookup b-chg b-del v-contr v-grp v-method v-contr v-grp v-method ~
v-flt-contr b-flt-contr b-flt-clear
&Scoped-Define DISPLAYED-OBJECTS r-region

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить автозаказ".

DEFINE BUTTON b-cancel
     LABEL "&Отменить"
     SIZE 10 BY 1 TOOLTIP "Отменить".

DEFINE BUTTON b-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-method
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить автозаказ".

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить автозаказ".

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр автозаказа".

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE BUTTON b-save
     LABEL "&Сохранить"
     SIZE 10 BY 1 TOOLTIP "Сохранить автозаказ".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-some FOR
      tt-dis-some-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-some
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-some Dialog-Frame _FREEFORM
  QUERY br-dis-some DISPLAY
      tt-dis-some-rule.templ-rl-root         COLUMN-LABEL ""           FORMAT ">>>>>9"
      tt-dis-some-rule.resource_id          COLUMN-LABEL "Контрагент" FORMAT "x(25)"
      get-wdays(entry(4, tt-dis-some-rule.charkey_two, chr(3)))  COLUMN-LABEL "Дни недели" FORMAT "x(18)"
      tt-dis-some-rule.rl-root              COLUMN-LABEL "Повтор"     FORMAT ">>9"
      tt-dis-some-rule.key#_one             COLUMN-LABEL "Дней до"    FORMAT ">>>>9"
      tt-dis-some-rule.key#_two             COLUMN-LABEL "Продажа"    FORMAT ">>>>9"
      /*( if tt-dis-some-rule.discnt-role = "" then "" else "Установлена"  ) COLUMN-LABEL "Группа товара" FORMAT "x(20)"*/
      tt-dis-some-rule.charkey_three        COLUMN-LABEL "Период"     FORMAT "99/99/9999999/99/9999"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.75 BY 17.79.

DEFINE VARIABLE r-region AS INTEGER INITIAL 3
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Глобально", 1,
          "По фирме", 2,
          "По объекту", 3
     SIZE 13 BY 3.25 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 3.75.


DEFINE VARIABLE cb-zakaz AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Тип заказа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Объект-Поставщик", 1,
                     "Объект-Фирма", 2,
                     "Объект-РЦ", 3,
                     "Фирма-Поставщик", 4
     DROP-DOWN-LIST
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE v-days-do AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Кол-во дней до поставки"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE v-days-fale AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кол-во дней продажи"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE v-from AS CHARACTER FORMAT "99/99/9999":U INITIAL "01/01/1990"
     LABEL "Период с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE v-repeat AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "каждую"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE v-to AS CHARACTER FORMAT "99/99/9999":U INITIAL "01/01/1990"
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 9.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 2.5.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49.5 BY 1.5.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49.5 BY 11.25.

DEFINE VARIABLE v-flag AS LOGICAL INITIAL no
     LABEL "флаг автоматической отправки в"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY 1 NO-UNDO.

DEFINE VARIABLE v-l-delnull AS LOGICAL INITIAL no
     LABEL "удалять нулевые позиции"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY 1 NO-UNDO.

DEFINE VARIABLE v-l-addextart AS LOGICAL INITIAL no
     LABEL "добавлять товары только с артикулом"
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-1 AS LOGICAL INITIAL no
     LABEL "Понедельник"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-2 AS LOGICAL INITIAL no
     LABEL "Вторник"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-3 AS LOGICAL INITIAL no
     LABEL "Среда"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-4 AS LOGICAL INITIAL no
     LABEL "Четверг"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-5 AS LOGICAL INITIAL no
     LABEL "Пятница"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-6 AS LOGICAL INITIAL no
     LABEL "Суббота"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-wday-7 AS LOGICAL INITIAL no
     LABEL "Воскресенье"
     VIEW-AS TOGGLE-BOX
     SIZE 14.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-txt1 AS CHARACTER NO-UNDO INIT "неделю" .
DEFINE VARIABLE v-txt2 AS CHARACTER NO-UNDO INIT "Повторять" .
DEFINE VARIABLE v-txt3 AS CHARACTER NO-UNDO INIT "Метод расчета:" .
DEFINE VARIABLE v-txt4 AS CHARACTER NO-UNDO INIT "Группа товаров:" .
DEFINE VARIABLE v-txt5 AS CHARACTER NO-UNDO INIT "Контрагент:" .
DEFINE VARIABLE v-txt6 AS CHARACTER NO-UNDO INIT "системы электронного документооборота" .
DEFINE VARIABLE v-txt7 AS CHARACTER NO-UNDO INIT "Контрагент:" .
DEFINE VARIABLE v-txt8 AS CHARACTER NO-UNDO INIT "Договор:" .
DEFINE VARIABLE v-txt9 AS CHARACTER NO-UNDO INIT "поставщика" .

DEFINE VARIABLE v-contr     AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-contract  AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-grp       AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-method    AS CHARACTER NO-UNDO INIT "" .
DEFINE VARIABLE v-flt-contr AS CHARACTER NO-UNDO INIT "" .

DEFINE VARIABLE c-flt-reg AS INTEGER INITIAL 0
     LABEL "Тип заказа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Все", 0,
                     "Глобально", 1,
                     "По фирме", 2,
                     "По объекту", 3
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.

DEFINE BUTTON b-flt-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" TOOLTIP "Выбрать контрагента"
     SIZE 3 BY 1.

DEFINE BUTTON b-flt-clear
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" TOOLTIP "Очистить"
     SIZE 3 BY 1.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2
     b-save AT ROW 1 COL 2 WIDGET-ID 6
     b-cancel AT ROW 1 COL 14 WIDGET-ID 4
     b-add AT ROW 1 COL 23 WIDGET-ID 2
     B-lookup AT ROW 1 COL 33
     b-chg AT ROW 1 COL 43
     b-del AT ROW 1 COL 53
     c-flt-reg AT ROW 1 COL 65
     b-flt-contr  AT ROW 2.13 COL 90
     b-flt-clear  AT ROW 2.13 COL 93
     br-dis-some AT ROW 3.21 COL 1
     r-region AT ROW 5.5 COL 3 NO-LABEL WIDGET-ID 10
     v-from AT ROW 9.5 COL 11.5 COLON-ALIGNED WIDGET-ID 16
     v-to AT ROW 9.5 COL 29 COLON-ALIGNED WIDGET-ID 18
     v-repeat AT ROW 11.75 COL 28 COLON-ALIGNED WIDGET-ID 36
     v-wday-1 AT ROW 11 COL 3 WIDGET-ID 20
     v-wday-2 AT ROW 12 COL 3 WIDGET-ID 22
     v-wday-3 AT ROW 13 COL 3 WIDGET-ID 24
     v-wday-4 AT ROW 14 COL 3 WIDGET-ID 26
     v-wday-5 AT ROW 15 COL 3 WIDGET-ID 28
     v-wday-6 AT ROW 16 COL 3 WIDGET-ID 30
     v-wday-7 AT ROW 17 COL 3 WIDGET-ID 32
     v-flag AT ROW 10 COL 51 WIDGET-ID 42
     v-l-delnull AT ROW 12 COL 51 WIDGET-ID 42
     v-l-addextart AT ROW 13 COL 51 WIDGET-ID 42
     cb-zakaz AT ROW 2.5 COL 55.5 COLON-ALIGNED WIDGET-ID 48
     b-contr  AT ROW 2.5 COL 35 WIDGET-ID 60
     b-contract  AT ROW 3.5 COL 35 WIDGET-ID 60
     b-grp    AT ROW 4.5 COL 87.5 WIDGET-ID 68
     b-method AT ROW 5.75 COL 87.5 WIDGET-ID 70
     v-days-do AT ROW 7.25 COL 69 COLON-ALIGNED WIDGET-ID 56
     v-days-fale AT ROW 8.5 COL 69 COLON-ALIGNED WIDGET-ID 58
     v-txt2 VIEW-AS TEXT SIZE 9    BY 1   AT ROW 11     COL 19.5 NO-LABEL FORMAT "X(9)" WIDGET-ID 34
     v-txt1 VIEW-AS TEXT SIZE 8    BY 1   AT ROW 11.8   COL 34.5 NO-LABEL FORMAT "X(8)" WIDGET-ID 38
     v-txt3 VIEW-AS TEXT SIZE 14.5 BY 1   AT ROW 5.75  COL 56   NO-LABEL FORMAT "X(15)" WIDGET-ID 66
     v-txt4 VIEW-AS TEXT SIZE 15.5 BY 1   AT ROW 4.5     COL 55   NO-LABEL FORMAT "X(16)" WIDGET-ID 64
     v-txt5 VIEW-AS TEXT SIZE 11.5 BY 1   AT ROW 2.5  COL 3   NO-LABEL FORMAT "X(12)" WIDGET-ID 62
     v-txt8 VIEW-AS TEXT SIZE 11.5 BY 1   AT ROW 3.5  COL 3   NO-LABEL FORMAT "X(12)"
     v-txt6 VIEW-AS TEXT SIZE 39.5 BY .75 AT ROW 11 COL 53    NO-LABEL FORMAT "X(40)" WIDGET-ID 44
     v-txt7 VIEW-AS TEXT SIZE 11.5 BY 1 AT ROW 2.13  COL 65 NO-LABEL FORMAT "X(12)"
     v-txt9 VIEW-AS TEXT SIZE 39.5 BY .75 AT ROW 14 COL 53    NO-LABEL FORMAT "X(12)" WIDGET-ID 44
     v-flt-contr VIEW-AS TEXT SIZE 12   BY 1 AT ROW 2.13  COL 77 NO-LABEL FORMAT "X(12)"
     v-contr  VIEW-AS TEXT SIZE 16 BY 1   AT ROW 2.5  COL 15   NO-LABEL FORMAT "X(20)"
     v-contract  VIEW-AS TEXT SIZE 16 BY 1   AT ROW 3.5  COL 15   NO-LABEL FORMAT "X(20)"
     v-grp    VIEW-AS TEXT SIZE 16 BY 1   AT ROW 4.5     COL 71   NO-LABEL FORMAT "X(16)"
     v-method VIEW-AS TEXT SIZE 16 BY 1   AT ROW 5.75  COL 71   NO-LABEL FORMAT "X(16)"
     RECT-1 AT ROW 5.25 COL 2 WIDGET-ID 8
     RECT-3 AT ROW 9.25 COL 2 WIDGET-ID 14
     RECT-4 AT ROW 2.25 COL 2 WIDGET-ID 40
     RECT-5 AT ROW 2.25 COL 44 WIDGET-ID 46
     RECT-6 AT ROW 4 COL 44 WIDGET-ID 50
     SPACE(0.05) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Автозаказы".


/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-some b-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

run show_main_page in this-procedure .

ASSIGN
       v-txt1  :SCREEN-VALUE = "неделю"
       v-txt2  :SCREEN-VALUE = "Повторять"
       v-txt3  :SCREEN-VALUE = "Метод расчета:"
       v-txt4  :SCREEN-VALUE = "Группа товаров:"
       v-txt5  :SCREEN-VALUE = "Контрагент:"
       v-txt6  :SCREEN-VALUE = "системы электронного документооборота"
       v-txt7  :SCREEN-VALUE = "Контрагент:"
       v-txt8  :SCREEN-VALUE = "Договор:"
       v-txt9  :SCREEN-VALUE = "поставщика"
.

/* SETTINGS FOR BROWSE br-dis-some IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-some
/* Query rebuild information for BROWSE br-dis-some
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-some-rule NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-dis-some */
&ANALYZE-RESUME


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Автозаказы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add-chg in this-procedure ( input "add" ) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "chg" ) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable loc#log as logical no-undo.

  if not avail tt-dis-some-rule then return no-apply.
  message
  "Вы уверены, что хотите удалить?"
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.

  find current tt-dis-some-rule exclusive-lock no-error.
  if avail tt-dis-some-rule then do:
      DO TRANSACTION
      on error undo, return no-apply
      :
          find first buf_dis-some-rule exclusive-lock
          where buf_dis-some-rule.templ-rl-root = tt-dis-some-rule.templ-rl-root no-error .
          if avail buf_dis-some-rule then delete buf_dis-some-rule .
      END.
      delete tt-dis-some-rule .
      br-dis-some:refresh() in frame Dialog-Frame no-error .
  end.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "view" ) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-flt-reg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL c-flt-reg Dialog-Frame
ON VALUE-CHANGED OF c-flt-reg IN FRAME Dialog-Frame /* Тип заказа */
DO:
  assign
    c-flt-reg
  .
  run open-br in this-procedure ( c-flt-reg ) .

  br-dis-some:refresh() in frame Dialog-Frame no-error .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-select-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-select-contract Dialog-Frame
ON VALUE-CHANGED OF v-contract IN FRAME Dialog-Frame /* Тип заказа */
DO:

  enable b-contract.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME c-flt-reg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-zakaz Dialog-Frame
ON VALUE-CHANGED OF cb-zakaz IN FRAME Dialog-Frame /* Тип заказа */
DO:
    if cb-zakaz:screen-value = "2" then do:
        find first buf_clients no-lock
        where buf_clients.obj-type = {&cmp} and
              buf_clients.obj-code = v-cntxt-host-code-obj
        no-error.
        if avail buf_clients then do:
            assign
              v-select-host-code = buf_clients.host-code
              v-select-obj-type  = buf_clients.obj-type
              v-select-obj-code  = buf_clients.obj-code
              v-select-obj-name  = buf_clients.obj-name
              v-contr :SCREEN-VALUE IN FRAME Dialog-Frame = v-select-obj-name
            .
            disable b-contr with frame Dialog-Frame .
        end.
    end.
    else do: 
      enable b-contr with frame Dialog-Frame . 
    end.
    if cb-zakaz:screen-value <> "1" or v-select-obj-code = 0  then do:
      assign
        v-contract :SCREEN-VALUE IN FRAME Dialog-Frame = ""
        v-select-contract = 0
      .
      disable b-contract with frame Dialog-Frame .
    end.
    else do:
      enable b-contract with frame Dialog-Frame .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  define variable loc#log as logical no-undo.
  define variable v-recid as recid   no-undo.

  message "Сохранить изменения?" view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if not loc#log then return no-apply.

  assign
    r-region cb-zakaz v-from v-to v-repeat v-flag v-l-addextart v-l-delnull
    v-wday-1 v-wday-2 v-wday-3 v-wday-4 v-wday-5 v-wday-6 v-wday-7
    v-days-do v-days-fale
  .
  assign
    v-region = r-region
  .
  run proc-save in this-procedure no-error.
  if not error-status:error then do:
      v-recid = recid(tt-dis-some-rule) .
      run show_main_page in this-procedure .
      br-dis-some:refresh() in frame Dialog-Frame no-error .
     {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
     reposition br-dis-some to recid v-recid no-error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отменить */
DO:
    run show_main_page in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-method Dialog-Frame
ON CHOOSE OF b-method IN FRAME Dialog-Frame
DO:
  case cb-zakaz:screen-value:
    when "2" then v-ord-type = {&O-F} .
    when "3" then v-ord-type = {&O-R} .
    when "4" then v-ord-type = {&F-P} .
    otherwise v-ord-type = {&O-P} .
  end.
  run cus/ord-m-a.w ( input parparentproc , input "auto-ord":u , input v-ord-type, input-output p-method ) no-error.
  if error-status:error then return no-apply.
  if not p-method = '' then v-method:SCREEN-VALUE = "Установлен" .
  else v-method:SCREEN-VALUE = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-grp Dialog-Frame
ON CHOOSE OF b-grp IN FRAME Dialog-Frame
DO:
  run proc-sel-grp IN THIS-PROCEDURE NO-ERROR .
  if error-status:error then return no-apply.
  if not v-grp = '' then v-grp:SCREEN-VALUE = v-grp .
  else v-grp:SCREEN-VALUE = '' .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-contr Dialog-Frame
ON CHOOSE OF b-contr IN FRAME Dialog-Frame
DO:
  run proc-sel-obj IN THIS-PROCEDURE ("contr") NO-ERROR .
  if error-status:error then return no-apply.
  v-contr:SCREEN-VALUE = v-select-obj-name .
  if v-select-obj-name <> "" and cb-zakaz:screen-value = "1" then do:
    enable b-contract with frame Dialog-Frame .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-contract Dialog-Frame
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo.
  find first buf_contract where buf_contract.contract-code = v-select-contract and buf_contract.host-code = v-cntxt-host-code-obj no-error.
  if available buf_contract
    then assign v-rid-list = string (recid (buf_contract)).
  run str/cont-all.w (
    input   parparentproc  ,
    input   v-cntxt-host-code-obj,
    input   "b-sel"         ,
    input   "firm-curr"     ,
    input   v-select-obj-type,
    input   v-select-obj-code,
    input   ?               ,
    input   ?               ,
    input   "current"       ,
    input   {&income}       ,
    input-output v-rid-list )
  .
  find first buf_contract where recid(buf_contract) = integer(v-rid-list) no-error.
  if not available buf_contract then do: 
    assign
      v-select-contract = 0 
      v-contract:SCREEN-VALUE = ""
    .
  end.
  else do: 
    assign
      v-select-contract = buf_contract.contract-code 
      v-contract:SCREEN-VALUE =  buf_contract.contract-prn-code
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-flt-contr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-flt-contr Dialog-Frame
ON CHOOSE OF b-flt-contr IN FRAME Dialog-Frame
DO:
  run proc-sel-obj IN THIS-PROCEDURE ("flt") NO-ERROR .
  if error-status:error then return no-apply.
  v-flt-contr:SCREEN-VALUE = v-flt-obj-name .
  run open-br in this-procedure ( c-flt-reg ) .

  br-dis-some:refresh() in frame Dialog-Frame no-error .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-flt-clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-flt-clear Dialog-Frame
ON CHOOSE OF b-flt-clear IN FRAME Dialog-Frame
DO:
  assign
    v-flt-contr:SCREEN-VALUE = ""
    v-flt-obj-type           = ""
    v-flt-obj-code           = 0
    v-flt-obj-name           = ""
  .
  run open-br in this-procedure ( c-flt-reg ) .

  br-dis-some:refresh() in frame Dialog-Frame no-error .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-some
&Scoped-define SELF-NAME br-dis-some
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-some Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-dis-some IN FRAME Dialog-Frame
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "view" ) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-some Dialog-Frame
ON RETURN OF br-dis-some IN FRAME Dialog-Frame
DO:
  if not avail tt-dis-some-rule then return no-apply.
  run proc-add-chg in this-procedure ( input "view" ) no-error .
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame

/*
{ gbl/brwrepos.i &line-num=5 }
{ gbl/brwrefre.i }
*/

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }

  RUN enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  assign
    c-flt-reg:SCREEN-VALUE IN FRAME Dialog-Frame = "0"
  .
  assign
    c-flt-reg
  .
  ENABLE b-quit b-add B-lookup b-chg b-del c-flt-reg
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run open-br in this-procedure ( c-flt-reg ) .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
    define input parameter p-add as character no-undo.

    if p-add = "add" then do:
        assign v-save-mode = yes .
        run show_add_page in this-procedure ( v-save-mode ) .
    end.
    else do:
        assign v-save-mode = no .
        run show_add_page in this-procedure ( v-save-mode ) .
    end.
    if p-add = "view" or
       ( v-cntxt-db-num > 0 and r-region < 3 )
    then do:
        DISABLE b-save
        WITH FRAME Dialog-Frame.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
  define variable v-i       as integer   no-undo .
  define variable v-mth     as character no-undo init "".
  define variable v-cmp     as logical   no-undo .
  define variable v-lastrec as integer   no-undo .

  if v-select-obj-type = '' and v-select-obj-code = 0 then do:
       message color input "Не указан поставщик!" view-as alert-box error .
       return error .
  end.
  if v-select-node-code = "" then do:
       message color input "Не указана группа товара!" view-as alert-box error .
       return error .
  end.
  if p-method = '' then do:
       message color input "Не указан метод расчета!" view-as alert-box error .
       return error .
  end.
  /*
  if not ( lookup(cb-zakaz, "1,2,3,4") > 0 and ( v-select-obj-type = {&shop} or v-select-obj-type = {&stock} ) ) OR
     not ( cb-zakaz = "5" and v-select-obj-type = {&cmp} )
  then do:
      message "Тип заказа не соответствует типу поставщика." view-as alert-box error .
      return error .
  end.
  */

  DO TRANSACTION
  on error undo, return error
  :
      /*добавляем, если надо*/
      if v-save-mode then do:
          find last buf_dis-some-rule use-index itempl no-lock no-error .
          if avail buf_dis-some-rule then assign v-lastrec = buf_dis-some-rule.templ-rl-root .
          else assign v-lastrec = 0 .
          create tt-dis-some-rule .
          assign
            tt-dis-some-rule.templ-rl-root = v-lastrec + 1
            tt-dis-some-rule.resource#_id = tt-dis-some-rule.templ-rl-root
          .
      end .
      else do:
          find current tt-dis-some-rule exclusive-lock .
      end.
      /*пишем область действи*/
      case v-region :
        when 1 then do:
           assign
           tt-dis-some-rule.host-code = 0
           tt-dis-some-rule.obj-code  = 0
           tt-dis-some-rule.obj-type  = ""
           .
        end.
        when 2 then do:
           assign
           tt-dis-some-rule.host-code = v-cntxt-host-code-obj
           tt-dis-some-rule.obj-code  = 0
           tt-dis-some-rule.obj-type  = ""
           .
        end.
        when 3 then do:
           assign
           tt-dis-some-rule.host-code = v-cntxt-host-code-obj
           tt-dis-some-rule.obj-code  = v-cntxt-obj-code
           tt-dis-some-rule.obj-type  = v-cntxt-obj-type
           .
        end.
      end.

      assign
        tt-dis-some-rule.charkey_one = p-method               /*строка метода*/
        /*флаг*/ /*группа товаров*//*поставщик*//*дни недели*/
        tt-dis-some-rule.charkey_two = string(v-flag) + chr(3) +
                                       v-select-node-code + chr(3) +
                                       v-select-obj-type + string(v-select-obj-code) + chr(3) +
                                       string(v-wday-1) + "," + string(v-wday-2) + "," + string(v-wday-3) + "," +
                                       string(v-wday-4) + "," + string(v-wday-5) + "," + string(v-wday-6) + "," + string(v-wday-7) + 
                                       chr(3) + string(v-select-contract) + chr(3) + string (v-l-addextart) + chr(3) + string (v-l-delnull)

        tt-dis-some-rule.charkey_three = v-from + "-" + v-to  /*даты с по*/
        tt-dis-some-rule.key#_one = v-days-do                 /*дней до*/
        tt-dis-some-rule.key#_two = v-days-fale               /*дней продажи*/
        /*tt-dis-some-rule.discnt-role = v-select-node-code*/      /*группа товаров*/
        tt-dis-some-rule.classif-type = "auto-ord-" + string(cb-zakaz)
        /*tt-dis-some-rule.nonunique = v-select-obj-type + string(v-select-obj-code)*/ /*поставщик*/
        /*tt-dis-some-rule.pos-type = string(v-wday-1) + "," + string(v-wday-2) + "," + string(v-wday-3) + "," +
                                    string(v-wday-4) + "," + string(v-wday-5) + "," + string(v-wday-6) + "," + string(v-wday-7)*/ /*дни недели*/
        tt-dis-some-rule.rl-root = v-repeat /*повтор*/
        tt-dis-some-rule.resource_id = v-select-obj-name /*наименование поставщика*/
        tt-dis-some-rule.resource#_id = tt-dis-some-rule.templ-rl-root
      .

      /*сохраняем в реальной таблице*/
      find first buf_dis-some-rule exclusive-lock
      where buf_dis-some-rule.templ-rl-root = tt-dis-some-rule.templ-rl-root no-error .
      if not avail buf_dis-some-rule then create buf_dis-some-rule .
      buffer-compare tt-dis-some-rule to buf_dis-some-rule save result in v-cmp .
      if not v-cmp then buffer-copy tt-dis-some-rule to buf_dis-some-rule .
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-obj Dialog-Frame
PROCEDURE proc-sel-obj :
  define input parameter p-sel as character no-undo.
  define variable v-rid-list as character no-undo .

  do
  on error undo, return error return-value
  :
   run ref/cli-all.w ( parparentproc
                      ,"b-sel"
                      ,{&all}
                      , ?
                      , ?
                      , ?
                      , ?
                      , ?
                      ,output v-rid-list ) no-error .

    if v-rid-list = "" then return error.

    find first buf_clients where string(recid(buf_clients)) = v-rid-list no-lock no-error.
    if avail buf_clients then do:
        if p-sel = "contr" then do:
          /*Объект РЦ может быть только объектом*/
          if cb-zakaz:screen-value in frame Dialog-frame = "3" and
             not ( buf_clients.obj-type = {&shop} or buf_clients.obj-type = {&stock} )
          then do:
             message "Тип заказа не соответствует типу поставщика." view-as alert-box error .
             return error .
          end.
          assign
            v-select-host-code = buf_clients.host-code
            v-select-obj-type  = buf_clients.obj-type
            v-select-obj-code  = buf_clients.obj-code
            v-select-obj-name  = buf_clients.obj-name
          .
        end.
        else do:
          assign
            v-flt-obj-type  = buf_clients.obj-type
            v-flt-obj-code  = buf_clients.obj-code
            v-flt-obj-name  = buf_clients.obj-name
          .
        end.
    end.
    else return error.
  end. /*do*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-grp Dialog-Frame
PROCEDURE proc-sel-grp :
  define variable v-rid-list as character no-undo .
  define variable v-i        as integer   no-undo .
  define buffer buf_gds-grp for ub.gds-grp .

  do
  on error undo, return error return-value
  :
  if not v-select-node-code = "" then do:
     do v-i = 1 to num-entries(v-select-node-code):
        find first buf_gds-grp where buf_gds-grp.node-code = int(entry(v-i, v-select-node-code)) no-lock no-error.
        if avail buf_gds-grp then do:
            assign
              v-rid-list = ( if v-rid-list = "" then string(recid(buf_gds-grp)) else v-rid-list + "," + string(recid(buf_gds-grp)) )
            .
        end.
    end.
  end.
  else assign v-rid-list = "" .
  run ref/gds-grp.w (input parparentproc
                    ,input "b-sel,b-mark"
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,input-output v-rid-list) no-error .

    if v-rid-list = "" then return error.

    assign v-select-node-code = "" .
    do v-i = 1 to num-entries(v-rid-list):
        /*получим развернутый лист кодов групп*/
        v-select-node-code = ( if v-select-node-code = "" then get-gds-grp-lst(entry(v-i, v-rid-list)) else v-select-node-code + "," + get-gds-grp-lst(entry(v-i, v-rid-list)) ) .
    end.
    if not v-select-node-code = "" then assign v-grp = "Установлена" .

  end. /*do*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show_main_page Dialog-Frame
PROCEDURE show_main_page :
    ASSIGN
       b-save  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-cancel:HIDDEN IN FRAME Dialog-Frame  = TRUE
       r-region:HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-1  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-3  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-4  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-5  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       RECT-6  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-from  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-to    :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-1:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-repeat:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-2:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-3:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-4:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-5:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-6:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-wday-7:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt1  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt2  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt3  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt4  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt5  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt8  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt9  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-txt6  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       cb-zakaz:HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-contract :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-grp   :HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-method:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-contract :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-grp   :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-method:HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-flag  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-l-addextart :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-l-delnull :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-days-do  :HIDDEN IN FRAME Dialog-Frame  = TRUE
       v-days-fale:HIDDEN IN FRAME Dialog-Frame  = TRUE
       b-quit  :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-add   :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-lookup:HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-chg   :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-del   :HIDDEN IN FRAME Dialog-Frame  = FALSE
       br-dis-some :HIDDEN IN FRAME Dialog-Frame  = FALSE
       c-flt-reg:HIDDEN IN FRAME Dialog-Frame  = FALSE
       v-txt7  :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-flt-contr :HIDDEN IN FRAME Dialog-Frame  = FALSE
       v-flt-contr :HIDDEN IN FRAME Dialog-Frame  = FALSE
       b-flt-clear :HIDDEN IN FRAME Dialog-Frame  = FALSE
    .
    DISABLE b-save b-cancel r-region RECT-1 RECT-3 RECT-4 RECT-5 RECT-6
    WITH FRAME Dialog-Frame.
    ENABLE b-quit b-add B-lookup b-chg b-del br-dis-some c-flt-reg v-txt7 b-flt-contr v-flt-contr b-flt-clear
    WITH FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show_add_page Dialog-Frame
PROCEDURE show_add_page :
define input parameter p-add as logical no-undo.
define variable v-time as integer no-undo .
define variable v-curdt as date no-undo .

assign
   b-save  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-cancel:HIDDEN IN FRAME Dialog-Frame  = FALSE
   r-region:HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-1  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-3  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-4  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-5  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   RECT-6  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-from  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-to    :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-1:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-repeat:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-2:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-3:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-4:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-5:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-6:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-wday-7:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt1  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt2  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt3  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt4  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt5  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt8  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt8  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt8  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt9  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-txt6  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   cb-zakaz:HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-contract :HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-grp   :HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-method:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-contr :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-contract :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-grp   :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-method:HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-flag  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-l-addextart :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-l-delnull :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-days-do  :HIDDEN IN FRAME Dialog-Frame  = FALSE
   v-days-fale:HIDDEN IN FRAME Dialog-Frame  = FALSE
   b-quit  :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-add   :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-lookup:HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-chg   :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-del   :HIDDEN IN FRAME Dialog-Frame  = TRUE
   br-dis-some :HIDDEN IN FRAME Dialog-Frame  = TRUE
   c-flt-reg:HIDDEN IN FRAME Dialog-Frame  = TRUE
   v-txt7  :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-flt-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
   v-flt-contr :HIDDEN IN FRAME Dialog-Frame  = TRUE
   b-flt-clear :HIDDEN IN FRAME Dialog-Frame  = TRUE
.
{ gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-curdt no-error }

if p-add then do:
  ASSIGN
   r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "3"
   v-repeat:SCREEN-VALUE IN FRAME Dialog-Frame = "1"
   cb-zakaz:SCREEN-VALUE IN FRAME Dialog-Frame = "1"
   v-contr :SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-contract :SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-grp   :SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-method:SCREEN-VALUE IN FRAME Dialog-Frame = ""
   v-from  :SCREEN-VALUE IN FRAME Dialog-Frame = string(v-curdt, "99999999")
   v-to    :SCREEN-VALUE IN FRAME Dialog-Frame = string(v-curdt, "99999999")
   v-select-node-code = ""
   v-select-obj-type = ""
   v-select-obj-name = ""
   v-select-obj-code = 0
   p-method = ""
  .
end.
else do:
  find first buf_contract where buf_contract.contract-code = integer(entry(5, tt-dis-some-rule.charkey_two, chr(3) )) and buf_contract.host-code = v-cntxt-host-code-obj no-error.
  assign
    p-method = tt-dis-some-rule.charkey_one
    v-method:SCREEN-VALUE IN FRAME Dialog-Frame = "Установлен"
    v-flag  :SCREEN-VALUE IN FRAME Dialog-Frame = entry(1, tt-dis-some-rule.charkey_two, chr(3) )
    v-l-addextart :SCREEN-VALUE IN FRAME Dialog-Frame = if num-entries (tt-dis-some-rule.charkey_two, chr(3)) < 6 then "no" else entry(6, tt-dis-some-rule.charkey_two, chr(3) )
    v-l-delnull :SCREEN-VALUE IN FRAME Dialog-Frame = if num-entries (tt-dis-some-rule.charkey_two, chr(3)) < 7 then "no" else entry(7, tt-dis-some-rule.charkey_two, chr(3) )
    v-from  :SCREEN-VALUE IN FRAME Dialog-Frame = entry(1, tt-dis-some-rule.charkey_three, "-" )
    v-to    :SCREEN-VALUE IN FRAME Dialog-Frame = entry(2, tt-dis-some-rule.charkey_three, "-" )
    v-days-do  :SCREEN-VALUE IN FRAME Dialog-Frame = string(tt-dis-some-rule.key#_one)
    v-days-fale:SCREEN-VALUE IN FRAME Dialog-Frame = string(tt-dis-some-rule.key#_two)
    v-select-node-code = entry(2, tt-dis-some-rule.charkey_two, chr(3) ) /*tt-dis-some-rule.discnt-role*/
    v-select-contract = if num-entries (tt-dis-some-rule.charkey_two, chr(3)) < 5 then 0 else integer(entry(5, tt-dis-some-rule.charkey_two, chr(3) ))
    v-grp :SCREEN-VALUE IN FRAME Dialog-Frame = ( if v-select-node-code = "" then "" else "Установлена"  )
    cb-zakaz:SCREEN-VALUE IN FRAME Dialog-Frame = entry(3, tt-dis-some-rule.classif-type, "-" )
    v-select-obj-type = substring( entry(3, tt-dis-some-rule.charkey_two, chr(3) ), 1, 3 )
    v-select-obj-code = int(substring( entry(3, tt-dis-some-rule.charkey_two, chr(3) ), 4 ))
    v-select-obj-name = tt-dis-some-rule.resource_id
    v-contr :SCREEN-VALUE IN FRAME Dialog-Frame = v-select-obj-name
    v-contract :SCREEN-VALUE IN FRAME Dialog-Frame = if available buf_contract then buf_contract.contract-prn-code else ""
    v-repeat:SCREEN-VALUE IN FRAME Dialog-Frame = string(tt-dis-some-rule.rl-root)
    v-wday-1:SCREEN-VALUE IN FRAME Dialog-Frame = entry(1, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-2:SCREEN-VALUE IN FRAME Dialog-Frame = entry(2, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-3:SCREEN-VALUE IN FRAME Dialog-Frame = entry(3, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-4:SCREEN-VALUE IN FRAME Dialog-Frame = entry(4, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-5:SCREEN-VALUE IN FRAME Dialog-Frame = entry(5, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-6:SCREEN-VALUE IN FRAME Dialog-Frame = entry(6, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
    v-wday-7:SCREEN-VALUE IN FRAME Dialog-Frame = entry(7, entry(4, tt-dis-some-rule.charkey_two, chr(3)) )
  .
  if tt-dis-some-rule.host-code = 0 then     assign r-region = 1 r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "1" .
  else if tt-dis-some-rule.obj-code = 0 then assign r-region = 2 r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "2" .
       else                                  assign r-region = 3 r-region:SCREEN-VALUE IN FRAME Dialog-Frame = "3" .
end.

if cb-zakaz:screen-value IN FRAME Dialog-Frame = "1" then enable b-contract with frame Dialog-Frame . else disable b-contract with frame Dialog-Frame. 
DISABLE b-quit b-add B-lookup b-chg b-del c-flt-reg v-txt7 b-flt-contr v-flt-contr b-flt-clear
WITH FRAME Dialog-Frame.
ENABLE b-save b-cancel r-region RECT-1 RECT-3 RECT-4 RECT-5 RECT-6 v-from v-to v-wday-1 v-repeat v-wday-2 v-wday-3 v-wday-4
       v-wday-5 v-wday-6 v-wday-7 v-txt1 v-txt2 v-txt3 v-txt4 v-txt5 v-txt8 v-txt6 v-txt9 cb-zakaz b-contr b-grp b-method v-flag v-l-addextart v-l-delnull
       v-days-do v-days-fale v-contr v-contract v-grp v-method
WITH FRAME Dialog-Frame.

/*объект-фирма - отключаем изменение поставщика*/
if cb-zakaz:SCREEN-VALUE IN FRAME Dialog-Frame = "2" then disable b-contr with frame Dialog-Frame .
/*область действия доступна только при добавлении*/
if not p-add then disable r-region with frame Dialog-Frame .
else disable b-contract with frame Dialog-Frame .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-br Dialog-Frame
PROCEDURE open-br :
  define input parameter p-flt-reg as character no-undo.
  define variable v-reg  as character no-undo.

  for each tt-dis-some-rule exclusive-lock:
      delete tt-dis-some-rule.
  end.

  _buf_dis-some-rule:
  for each buf_dis-some-rule no-lock:
      /*if int(p-flt-reg) > 0 and not entry(3, buf_dis-some-rule.classif-type, "-") = p-flt-reg then next _buf_dis-some-rule .*/
      /*определим область действиja*/
      if buf_dis-some-rule.host-code = 0 then assign v-reg = "1" .
      else if buf_dis-some-rule.obj-code = 0 then assign v-reg = "2" .
           else assign v-reg = "3" .
      /*показываем шаблоны только для данного объекта*/
      if v-reg = "2" and not buf_dis-some-rule.host-code = v-cntxt-host-code-obj then next _buf_dis-some-rule .
      if v-reg = "3" and not (buf_dis-some-rule.obj-code = v-cntxt-obj-code and buf_dis-some-rule.obj-code = v-cntxt-obj-code) then next _buf_dis-some-rule .
      /*фильтр по области действия шаблона*/
      if int(p-flt-reg) > 0 and not v-reg = p-flt-reg then next _buf_dis-some-rule .
      /*фильтр по контрагенту (поставщику)*/
      if not v-flt-obj-type = "" and not entry(3, buf_dis-some-rule.charkey_two, chr(3) ) = v-flt-obj-type + string(v-flt-obj-code) then next _buf_dis-some-rule .

      create tt-dis-some-rule .
      buffer-copy buf_dis-some-rule to tt-dis-some-rule .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME