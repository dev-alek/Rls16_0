&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.str.ptrl.*.
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME f-doc-pl


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf-obj_clients FOR ub.clients.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER buf_place FOR ub.place.
DEFINE BUFFER buf_rvs-line FOR ub.rvs-line.
DEFINE TEMP-TABLE loc-t-doc-pl NO-UNDO 
field pl-code as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code like ub.doc-pl.gds-code
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.
DEFINE SHARED TEMP-TABLE tt-doc-pl NO-UNDO 
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS f-doc-pl 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Топливный резервуар по документам (заведение, редактирование)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/17/07
Author: Dmitry Ukhanov
Creation date: 09/17/07

*/

/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc               as   widget-handle              no-undo .
define input  parameter p-mode                      as   character                  no-undo .
define input  parameter p-upd-field                 as   character                  no-undo .
define input  parameter p-upd-units                 as   character                  no-undo .
define input  parameter p-doc-code                  like ub.trn-doc.doc-code        no-undo .
define input  parameter p-gds-code                  like ub.goods.gds-code          no-undo .
define input  parameter p-pl-code                   as   integer                    no-undo .
define input  parameter p-doc-line-unit-cli         like ub.doc-line.unit-cli       no-undo .
define input  parameter p-doc-line-cli-base-rate    like ub.doc-line.cli-base-rate  no-undo .
define input  parameter p-doc-line-doc-density      like ub.doc-line.doc-density    no-undo .
define input  parameter p-doc-line-fact-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-cli-qnty         like ub.doc-line.cli-qnty       no-undo .
define input  parameter p-doc-line-doc-qnty         like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-qnty        like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-doc-cli-qnty     like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-cli-qnty    like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-rest-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
define input  parameter p-doc-line-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Складское место с товарами с указанием количеств":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/showinf.i      }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ ref/gds-attr.i     }
{ str/is-sug.i       }
{ str/placelib.i     }
{ str/valddnst.i def }

&global-define curr-proc-name 'doc-pl':U

define buffer buf_trn-doc       for ub.trn-doc .
define buffer buf-upd_tt-doc-pl for tt-doc-pl .

define variable v-is-ptrl as character no-undo .
define variable v-msg-on  as logical   no-undo .
define variable v-is-add  as logical   no-undo .
define variable rvsinvObj as class rvsinvsub no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-doc-pl

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help 
&Scoped-Define DISPLAYED-FIELDS loc-t-doc-pl.pl-code buf_place.pl-name ~
buf-obj_clients.obj-type buf-obj_clients.obj-code buf-obj_clients.obj-name ~
buf_place.loc1 buf_place.loc2 buf_place.loc3 buf_place.loc4 ~
buf_goods.gds-code buf_goods.gds-name buf_goods.artic buf_goods.prod-type ~
buf_goods.prod-code 
&Scoped-define DISPLAYED-TABLES loc-t-doc-pl buf_place buf-obj_clients ~
buf_goods
&Scoped-define FIRST-DISPLAYED-TABLE loc-t-doc-pl
&Scoped-define SECOND-DISPLAYED-TABLE buf_place
&Scoped-define THIRD-DISPLAYED-TABLE buf-obj_clients
&Scoped-define FOURTH-DISPLAYED-TABLE buf_goods
&Scoped-Define DISPLAYED-OBJECTS f-prod-name f-units-base 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO DEFAULT 
     LABEL "&Ввод " 
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-place 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON b-qnty DEFAULT 
     LABEL "Уст.Кол-ва" 
     SIZE 11 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT 
     LABEL "&Отмена" 
     SIZE 10 BY 1.

DEFINE VARIABLE f-doc-line-cli-doc-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-cli-fact-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-cli-qnty LIKE ub.doc-line.cli-qnty
     LABEL "по ТТН" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-lblpolnebal as character init "Положительный небаланс  :" format "x(30)"
     VIEW-AS FILL-IN 
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-lblotrnebal as character init "Отрицательный небаланс  :" format "x(30)"
     VIEW-AS FILL-IN 
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE f-lblnebal as character init "Небаланс,кг" format "x(13)"
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 
     bgcolor 8
     NO-UNDO.

DEFINE VARIABLE f-polnebal as decimal INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.

DEFINE VARIABLE f-otrnebal as decimal INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 
     fgcolor 4
     NO-UNDO.

DEFINE VARIABLE f-lblmetrerr as character init "Погр.изм.,кг" format "x(14)"
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 
     bgcolor 8
     NO-UNDO.

DEFINE VARIABLE f-polmetrerr as decimal  INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.

DEFINE VARIABLE f-otrmetrerr as decimal  INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 
     fgcolor 4
     NO-UNDO.

DEFINE VARIABLE f-lblwastcli as character init "Масса ЕУ,кг" format "x(14)"
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 
     bgcolor 8
     NO-UNDO.

DEFINE VARIABLE f-wastcli as decimal  INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.

DEFINE VARIABLE f-lblwast-tp as character init "Масса ТП,кг" format "x(14)"
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 
     bgcolor 8
     NO-UNDO.

DEFINE VARIABLE f-wast-tp as decimal  INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.

DEFINE VARIABLE f-lbldiff as character init "Излиш./Недост.,кг" format "x(20)"
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 
     bgcolor 8
     NO-UNDO.

DEFINE VARIABLE f-izlish as decimal  INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 fgcolor 4 NO-UNDO.

DEFINE VARIABLE f-nedos as decimal  INITIAL 0
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 
     fgcolor 4
     NO-UNDO.

DEFINE VARIABLE f-doc-line-cli-rest-af-qnty LIKE ub.inv-line.after-cli-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-doc-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-doc-qnty LIKE ub.doc-line.doc-qnty
     LABEL "Заявлено" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-fact-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-fact-qnty LIKE ub.doc-line.fact-qnty
     LABEL "Фактически" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-rest-af-qnty LIKE ub.doc-line.cli-qnty
     LABEL "Стало" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-line-rest-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-pl-doc-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-pl-fact-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-doc-pl-rest-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-label-density AS CHARACTER FORMAT "x(25)":U INITIAL "Плотность" 
     VIEW-AS FILL-IN 
     SIZE 10.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-prod-name AS CHARACTER FORMAT "x(45)" 
     VIEW-AS FILL-IN 
     SIZE 46.5 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-rvs-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-measure-cli-qnty LIKE ub.rvs-line.measure-cli-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-measure-qnty LIKE ub.rvs-line.measure-qnty
     LABEL "Измерено" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-state-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-state-measure-cli-qnty LIKE ub.rvs-line.state-measure-cli-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-state-measure-qnty LIKE ub.rvs-line.state-measure-qnty
     LABEL "Фактически" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-label AS CHARACTER FORMAT "X(256)":U INITIAL "Итого по строке документа:" 
      VIEW-AS TEXT 
     SIZE 27.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-doc-qnty LIKE ub.doc-pl.cli-doc-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-fact-qnty LIKE ub.doc-pl.cli-fact-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-qnty LIKE ub.doc-pl.cli-qnty
     LABEL "по ТТН" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-cli-rest-af-qnty LIKE ub.doc-pl.cli-rest-af-qnty
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-doc-qnty LIKE ub.doc-pl.doc-qnty
     LABEL "Заявлено" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-fact-qnty LIKE ub.doc-pl.fact-qnty
     LABEL "Фактически" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-rest-af-qnty LIKE ub.doc-pl.rest-af-qnty
     LABEL "Стало" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-doc-pl-rest-density AS DECIMAL FORMAT "->>9.9999999999" INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-units-base LIKE ub.goods.unit-base
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-units-cli LIKE ub.goods.unit-base
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE v-label-rvs AS CHARACTER FORMAT "x(25)":U INITIAL "По сверкам:" 
     VIEW-AS FILL-IN 
     SIZE 26 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97 BY 2.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97 BY 7.

DEFINE RECTANGLE rect-tot
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL   
     SIZE 97 BY 7.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-doc-pl
     b-exit AT ROW 1 COL 2 WIDGET-ID 6
     b-quit AT ROW 1 COL 12 WIDGET-ID 18
     b-qnty AT ROW 1 COL 22 WIDGET-ID 16
     b-help AT ROW 1 COL 89 WIDGET-ID 8
     loc-t-doc-pl.pl-code AT ROW 2.5 COL 16 COLON-ALIGNED WIDGET-ID 68 FORMAT "99999999999"
          LABEL "Место хранения"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     b-place AT ROW 2.5 COL 29.5 WIDGET-ID 14
     buf_place.pl-name AT ROW 2.5 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 70 FORMAT "X(66)"
          VIEW-AS FILL-IN 
          SIZE 66 BY 1
          BGCOLOR 8 
     buf-obj_clients.obj-type AT ROW 3.75 COL 16 COLON-ALIGNED WIDGET-ID 104
          LABEL "Объект"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     buf-obj_clients.obj-code AT ROW 3.75 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 52
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     buf-obj_clients.obj-name AT ROW 3.75 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 56 FORMAT "X(66)"
          VIEW-AS FILL-IN 
          SIZE 66 BY 1
          BGCOLOR 8 
     buf_place.loc1 AT ROW 5 COL 30 COLON-ALIGNED WIDGET-ID 44
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
     buf_place.loc2 AT ROW 5 COL 49 COLON-ALIGNED WIDGET-ID 46
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
     buf_place.loc3 AT ROW 5 COL 68 COLON-ALIGNED WIDGET-ID 48
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
     buf_place.loc4 AT ROW 5 COL 88 COLON-ALIGNED WIDGET-ID 50
          VIEW-AS FILL-IN 
          SIZE 9 BY 1
     buf_goods.gds-code AT ROW 6.75 COL 10 COLON-ALIGNED WIDGET-ID 40 FORMAT "99999999999"
          LABEL "Товар"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     buf_goods.gds-name AT ROW 6.75 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 42 FORMAT "X(74)"
          VIEW-AS FILL-IN 
          SIZE 75.5 BY 1
          BGCOLOR 8 
     buf_goods.artic AT ROW 8 COL 10 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN 
          SIZE 17 BY 1
     buf_goods.prod-type AT ROW 8 COL 34.5 COLON-ALIGNED WIDGET-ID 106
          LABEL "Пр-ль"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     buf_goods.prod-code AT ROW 8 COL 39 COLON-ALIGNED NO-LABEL WIDGET-ID 72
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     f-prod-name AT ROW 8 COL 49.5 COLON-ALIGNED NO-LABEL WIDGET-ID 54
     f-units-base AT ROW 9.5 COL 45 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 168 FORMAT "X(5)"
     f-units-cli AT ROW 9.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 170 FORMAT "X(5)"
     f-label-density AT ROW 9.5 COL 82 NO-LABEL WIDGET-ID 172
     loc-t-doc-pl.cli-qnty AT ROW 10.75 COL 16 COLON-ALIGNED WIDGET-ID 180 FORMAT "->>,>>>,>>9.<<<"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     loc-t-doc-pl.doc-qnty AT ROW 10.75 COL 45 COLON-ALIGNED WIDGET-ID 26
          LABEL "Заявлено"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     loc-t-doc-pl.cli-doc-qnty AT ROW 10.75 COL 61.5 COLON-ALIGNED NO-LABEL WIDGET-ID 20
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     f-doc-pl-doc-density AT ROW 10.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 204
     loc-t-doc-pl.fact-qnty AT ROW 11.75 COL 45 COLON-ALIGNED WIDGET-ID 38
          LABEL "Фактически"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     loc-t-doc-pl.cli-fact-qnty AT ROW 11.75 COL 61.5 COLON-ALIGNED NO-LABEL WIDGET-ID 22
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-doc-pl
     f-doc-pl-fact-density AT ROW 11.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 206
     loc-t-doc-pl.rest-af-qnty AT ROW 12.75 COL 45 COLON-ALIGNED WIDGET-ID 198
          LABEL "Стало"
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     loc-t-doc-pl.cli-rest-af-qnty AT ROW 12.75 COL 61.5 COLON-ALIGNED NO-LABEL WIDGET-ID 196
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
     f-doc-pl-rest-density AT ROW 12.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 208
     v-label-rvs AT ROW 13.75 COL 3 NO-LABEL WIDGET-ID 110
     f-rvs-measure-qnty AT ROW 13.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 34
          LABEL "Измерено"
     f-rvs-measure-cli-qnty AT ROW 13.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 32
     f-rvs-density AT ROW 13.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 176
     f-rvs-state-measure-qnty AT ROW 14.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 36
          LABEL "Фактически"
     f-rvs-state-measure-cli-qnty AT ROW 14.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 108
     f-rvs-state-density AT ROW 14.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 178
     f-tot-doc-pl-rest-af-qnty AT ROW 16.5 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 190
          LABEL "Стало"
     f-tot-doc-pl-cli-rest-af-qnty AT ROW 16.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 76
     f-tot-doc-pl-rest-density AT ROW 16.5 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     f-tot-doc-pl-cli-qnty AT ROW 17.5 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 186
          LABEL "по ТТН" FORMAT "->>,>>>,>>9.<<<"
     f-tot-doc-pl-doc-qnty AT ROW 17.5 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 156
          LABEL "Заявлено"
     f-tot-doc-pl-cli-doc-qnty AT ROW 17.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 152
     f-tot-doc-pl-fact-qnty AT ROW 18.5 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 158
          LABEL "Фактически"
     f-tot-doc-pl-cli-fact-qnty AT ROW 18.5 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 154
     f-doc-line-rest-af-qnty AT ROW 19.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 82
          LABEL "Стало"
     f-doc-line-cli-rest-af-qnty AT ROW 19.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 188
     f-doc-line-rest-density AT ROW 19.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 202
     f-doc-line-cli-qnty AT ROW 20.75 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 144
          LABEL "по ТТН"
     f-doc-line-doc-qnty AT ROW 20.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 148
          LABEL "Заявлено"
     f-doc-line-cli-doc-qnty AT ROW 20.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 140
     f-doc-line-doc-density AT ROW 20.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     f-doc-line-fact-qnty AT ROW 21.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 150
          LABEL "Фактически"
     f-lblpolnebal AT ROW 18.5 COL 1 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblotrnebal AT ROW 19.5 COL 1 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblnebal AT ROW 17.5 COL 27 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-polnebal AT ROW 18.5 COL 27 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-otrnebal AT ROW 19.5 COL 27 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblmetrerr AT ROW 17.5 COL 39 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-polmetrerr AT ROW 18.5 COL 39 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-otrmetrerr AT ROW 19.5 COL 39 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblwastcli AT ROW 17.5 COL 52 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-wastcli AT ROW 19.5 COL 52 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lblwast-tp AT ROW 17.5 COL 64 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-wast-tp AT ROW 19.5 COL 64 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-lbldiff AT ROW 17.5 COL 76 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-izlish AT ROW 18.5 COL 76 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-nedos AT ROW 19.5 COL 76 COLON-ALIGNED HELP
          "" no-label WIDGET-ID 150
     f-doc-line-cli-fact-qnty AT ROW 21.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 142
     f-doc-line-fact-density AT ROW 21.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 30
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME f-doc-pl
     f-tot-doc-label AT ROW 19.75 COL 3 NO-LABEL WIDGET-ID 210
     "Итого по местам хранения:" VIEW-AS TEXT
          SIZE 26 BY .67 AT ROW 16.5 COL 3 WIDGET-ID 174
     "По месту хранения:" VIEW-AS TEXT
          SIZE 19.5 BY .67 AT ROW 9.5 COL 3 WIDGET-ID 166
     RECT-1 AT ROW 6.5 COL 2 WIDGET-ID 78
     RECT-2 AT ROW 9.25 COL 2 WIDGET-ID 80
     rect-tot AT ROW 16.25 COL 2 WIDGET-ID 112
     SPACE(0.87) SKIP(0.80)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf-obj_clients B "?" ? ub clients
      TABLE: buf_goods B "?" ? ub goods
      TABLE: buf_place B "?" ? ub place
      TABLE: loc-t-doc-pl T "?" NO-UNDO ub doc-pl
      TABLE: tt-doc-pl T "SHARED" NO-UNDO ub doc-pl
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX f-doc-pl
   FRAME-NAME                                                           */
ASSIGN 
       FRAME f-doc-pl:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN buf_goods.artic IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf_goods.artic:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR BUTTON b-place IN FRAME f-doc-pl
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-qnty IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       b-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.cli-doc-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       loc-t-doc-pl.cli-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.cli-fact-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       loc-t-doc-pl.cli-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.cli-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE EXP-FORMAT                                      */
ASSIGN 
       loc-t-doc-pl.cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       loc-t-doc-pl.cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.cli-rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       loc-t-doc-pl.cli-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.doc-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       loc-t-doc-pl.doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-doc-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-doc-line-cli-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-fact-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-doc-line-cli-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-doc-line-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-lblpolnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblpolnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-lblotrnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblotrnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-lblnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-polnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-polnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-otrnebal:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-otrnebal:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-lblwastcli:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblwastcli:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-wastcli:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-wastcli:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN 
       f-lblmetrerr:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblmetrerr:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN 
       f-polmetrerr:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-polmetrerr:READ-ONLY IN FRAME f-doc-pl        = TRUE.
ASSIGN 
       f-otrmetrerr:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-otrmetrerr:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-lblwast-tp:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lblwast-tp:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-wast-tp:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-wast-tp:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-lbldiff:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-lbldiff:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-qnty-2 IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-izlish:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-izlish:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.inv-line.after-cli-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-nedos:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-nedos:READ-ONLY IN FRAME f-doc-pl        = TRUE.
/* SETTINGS FOR FILL-IN f-doc-line-cli-rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.inv-line.after-cli-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-doc-line-cli-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-cli-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-doc-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-doc-line-doc-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-doc-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-doc-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.doc-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-doc-line-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-fact-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-doc-line-fact-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-fact-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-fact-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.fact-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-doc-line-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-line.cli-qnty EXP-LABEL EXP-SIZE  */
ASSIGN 
       f-doc-line-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-line-rest-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-doc-line-rest-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-doc-line-rest-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-doc-pl-doc-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-doc-pl-doc-density:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN f-doc-pl-fact-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-doc-pl-fact-density:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN f-doc-pl-rest-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-doc-pl-rest-density:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN f-label-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       f-label-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-label-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-prod-name IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       f-prod-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-rvs-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-rvs-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-rvs-measure-cli-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.rvs-line.measure-cli-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-rvs-measure-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-measure-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-rvs-measure-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.rvs-line.measure-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-rvs-measure-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-measure-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-rvs-state-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-rvs-state-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-state-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-rvs-state-measure-cli-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.rvs-line.state-measure-cli-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-rvs-state-measure-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-state-measure-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-rvs-state-measure-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.rvs-line.state-measure-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-rvs-state-measure-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-rvs-state-measure-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-label IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       f-tot-doc-label:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-label:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-doc-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-doc-qnty EXP-SIZE          */
ASSIGN 
       f-tot-doc-pl-cli-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-fact-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-fact-qnty EXP-SIZE         */
ASSIGN 
       f-tot-doc-pl-cli-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-qnty EXP-LABEL EXP-FORMAT EXP-SIZE */
ASSIGN 
       f-tot-doc-pl-cli-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-cli-rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.cli-rest-af-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-tot-doc-pl-cli-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-cli-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-doc-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.doc-qnty EXP-LABEL EXP-SIZE    */
ASSIGN 
       f-tot-doc-pl-doc-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-doc-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-fact-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.fact-qnty EXP-LABEL EXP-SIZE   */
ASSIGN 
       f-tot-doc-pl-fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-fact-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.doc-pl.rest-af-qnty EXP-LABEL EXP-SIZE */
ASSIGN 
       f-tot-doc-pl-rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-rest-af-qnty:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-tot-doc-pl-rest-density IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       f-tot-doc-pl-rest-density:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-tot-doc-pl-rest-density:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-units-base IN FRAME f-doc-pl
   NO-ENABLE LIKE = ub.goods.unit-base EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN 
       f-units-base:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN f-units-cli IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE LIKE = ub.goods.unit-base EXP-LABEL EXP-FORMAT EXP-HELP EXP-SIZE */
ASSIGN 
       f-units-cli:HIDDEN IN FRAME f-doc-pl           = TRUE
       f-units-cli:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.fact-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       loc-t-doc-pl.fact-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN buf_goods.gds-code IN FRAME f-doc-pl
   NO-ENABLE EXP-LABEL                                                  */
ASSIGN 
       buf_goods.gds-code:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_goods.gds-name IN FRAME f-doc-pl
   NO-ENABLE EXP-FORMAT                                                 */
ASSIGN 
       buf_goods.gds-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_place.loc1 IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf_place.loc1:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_place.loc2 IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf_place.loc2:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_place.loc3 IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf_place.loc3:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_place.loc4 IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf_place.loc4:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf-obj_clients.obj-code IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf-obj_clients.obj-code:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf-obj_clients.obj-name IN FRAME f-doc-pl
   NO-ENABLE EXP-FORMAT                                                 */
ASSIGN 
       buf-obj_clients.obj-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf-obj_clients.obj-type IN FRAME f-doc-pl
   NO-ENABLE EXP-LABEL                                                  */
ASSIGN 
       buf-obj_clients.obj-type:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN loc-t-doc-pl.pl-code IN FRAME f-doc-pl
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN buf_place.pl-name IN FRAME f-doc-pl
   NO-ENABLE EXP-FORMAT                                                 */
ASSIGN 
       buf_place.pl-name:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_goods.prod-code IN FRAME f-doc-pl
   NO-ENABLE                                                            */
ASSIGN 
       buf_goods.prod-code:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR FILL-IN buf_goods.prod-type IN FRAME f-doc-pl
   NO-ENABLE EXP-LABEL                                                  */
ASSIGN 
       buf_goods.prod-type:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME f-doc-pl
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-2 IN FRAME f-doc-pl
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rect-tot IN FRAME f-doc-pl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN loc-t-doc-pl.rest-af-qnty IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       loc-t-doc-pl.rest-af-qnty:HIDDEN IN FRAME f-doc-pl           = TRUE.

/* SETTINGS FOR FILL-IN v-label-rvs IN FRAME f-doc-pl
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       v-label-rvs:HIDDEN IN FRAME f-doc-pl           = TRUE
       v-label-rvs:READ-ONLY IN FRAME f-doc-pl        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX f-doc-pl
/* Query rebuild information for DIALOG-BOX f-doc-pl
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX f-doc-pl */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME f-doc-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-doc-pl f-doc-pl
ON WINDOW-CLOSE OF FRAME f-doc-pl /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit f-doc-pl
ON CHOOSE OF b-exit IN FRAME f-doc-pl /* Ввод  */
DO:
  { gbl/stdbtn.i }

  define variable v-quit as logical   no-undo .

  apply "leave" to loc-t-doc-pl.pl-code in frame {&frame-name}.

  if loc-t-doc-pl.pl-code = ?
    or loc-t-doc-pl.pl-code = 0
  then do:
    message
      "Не указано место хранения." skip
      "Хотите выйти без сохранения?" skip
      view-as alert-box question buttons yes-no update v-quit.
    if v-quit = true then do:
      apply "choose" to b-quit in frame {&frame-name}.
    end.
    return no-apply.
  end.

  if p-upd-field = "rest":U
    or p-upd-field = "rest-fact":U
  then do:
    assign
      loc-t-doc-pl.doc-qnty     = loc-t-doc-pl.fact-qnty
      loc-t-doc-pl.cli-doc-qnty = loc-t-doc-pl.cli-fact-qnty
      loc-t-doc-pl.cli-qnty     = loc-t-doc-pl.cli-doc-qnty
    .
    if f-doc-pl-rest-density :sensitive = true then do:
      if loc-t-doc-pl.rest-af-qnty <> 0.0
        and loc-t-doc-pl.cli-rest-af-qnty <> 0.0
        and absolute( loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty - f-doc-pl-rest-density ) > 0.00001
      then do:
        message
          "Указанная плотность не соответствует расчетной." skip
          substitute( "Расчетная: &1", loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty ) skip
          substitute( "Задана: &1", f-doc-pl-rest-density ) skip
          view-as alert-box error .
        apply "entry" to f-doc-pl-rest-density in frame {&frame-name}.
        return no-apply .
      end.

      if valid-density( f-doc-pl-rest-density, (buf_goods.unit-base = buf_goods.unit-cli)  ) <> true then do:
        message
          "Значение плотности не корректно." skip
          substitute( 'Плотность "стало": &1', f-doc-pl-rest-density ) skip
          view-as alert-box error .
        apply "entry" to f-doc-pl-rest-density in frame {&frame-name}.
        return no-apply .
      end.
    end.
  end.

  if p-upd-field <> "rest":U
    and p-upd-field <> "rest-fact":U
    and p-upd-field <> "fact-doc":U
    and loc-t-doc-pl.cli-doc-qnty = 0.0
    and loc-t-doc-pl.doc-qnty = 0.0
  then do:
    message
      "Указаны нулевые количества, запись будет удалена." skip
      "Хотите продолжить редактирование?" skip
      view-as alert-box question buttons yes-no update v-quit.
    if v-quit = true then do:
      return no-apply.
    end.
    else do:
      if available buf-upd_tt-doc-pl then do:
        delete buf-upd_tt-doc-pl .
      end.
    end.
  end.
  else do:
    if not available buf-upd_tt-doc-pl then do:
      create buf-upd_tt-doc-pl .
    end.
    buffer-copy loc-t-doc-pl to buf-upd_tt-doc-pl .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place f-doc-pl
ON CHOOSE OF b-place IN FRAME f-doc-pl
DO:
  { gbl/stdbtn.i }

  define variable v-rid-list as character no-undo .
  define variable v-pl-code  as integer   no-undo .
  define variable ref-rec    as recid     no-undo .
  define variable v-value    as character no-undo .
  define variable v-value2   as character no-undo .
  define variable v-ok       as logical   no-undo .
  define variable ii         as integer   no-undo .

  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_place for ub.place .
  define buffer buf_place-attr for ub.place-attr .

  run ref/pl-gdss.w
    ( input parparentproc
     ,input "{&Btn_Select}"
     ,input buf-obj_clients.obj-type
     ,input buf-obj_clients.obj-code
     ,input ( if v-is-ptrl = "yes":U then {&petrolium} else {&goods} )
     ,input recid( buf_goods )
     ,input ?
     ,output v-rid-list
    ) no-error .

  assign
    ref-rec = integer( entry( 1, v-rid-list ) ) no-error
  .
  if error-status :error then do:
    assign
      ref-rec = ?
    .
  end.
  find first buf_pl-gds no-lock
    where recid( buf_pl-gds ) = ref-rec
    no-error .
  if available buf_pl-gds then do:
    v-pl-code = buf_pl-gds.pl-code .
    if loc-t-doc-pl.pl-code = v-pl-code then do:
      return no-apply .
    end.
    
    run placelib_get-attr  (
       input {&place-is-main}
      ,input buf_pl-gds.obj-code
      ,input buf_pl-gds.obj-type
      ,input buf_pl-gds.pl-code
      ,output v-value
      ,output v-ok      )
    no-error.
    if v-ok
    and not logical(v-value) /* Не главный сообщающийся резервуар */
    then do :
      run placelib_get-attr  (
         input {&place-com-tanks}
        ,input buf_pl-gds.obj-code
        ,input buf_pl-gds.obj-type
        ,input buf_pl-gds.pl-code
        ,output v-value
        ,output v-ok      )
      no-error.
      if v-ok
      and v-value > ""
      then do ii = 1 to num-entries(v-value) :
        find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
                                       and buf_place.obj-code = buf_pl-gds.obj-code
                                       and buf_place.loc1     = entry(ii, v-value)
                                       and buf_place.status_  = ""
                                       no-error .
        if available buf_place
        then do :
          run placelib_get-attr  (
             input {&place-is-main}
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output v-value2
            ,output v-ok      )
          no-error.
          if v-ok
          and logical(v-value2)
          then do :
            v-pl-code = buf_place.pl-code .
            leave .
          end .
        end .
      end .
    end .
    
    if loc-t-doc-pl.pl-code = v-pl-code then do:
      return no-apply .
    end.

    assign
      loc-t-doc-pl.pl-code :screen-value = string( v-pl-code, loc-t-doc-pl.pl-code :format )
    .
    apply "leave" to loc-t-doc-pl.pl-code in frame {&frame-name} .

  end.

  apply "value-changed" to loc-t-doc-pl.pl-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-qnty f-doc-pl
ON CHOOSE OF b-qnty IN FRAME f-doc-pl /* Уст.Кол-ва */
DO:
  { gbl/stdbtn.i }

  if ( loc-t-doc-pl.cli-doc-qnty :sensitive = true
       and f-doc-line-cli-doc-qnty = f-tot-doc-pl-cli-doc-qnty
     )
     or ( loc-t-doc-pl.doc-qnty :sensitive = true
          and f-doc-line-doc-qnty = f-tot-doc-pl-doc-qnty
        )
     or ( loc-t-doc-pl.cli-fact-qnty :sensitive = true
          and f-doc-line-cli-fact-qnty = f-tot-doc-pl-cli-fact-qnty
        )
     or ( loc-t-doc-pl.fact-qnty :sensitive = true
          and f-doc-line-fact-qnty = f-tot-doc-pl-fact-qnty
        )
  then do:
    message
      "Все количества уже установлены корректно."
      view-as alert-box information.
    return no-apply .
  end.


  if loc-t-doc-pl.cli-doc-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.cli-doc-qnty = loc-t-doc-pl.cli-doc-qnty + f-doc-line-cli-doc-qnty - f-tot-doc-pl-cli-doc-qnty
    .
    display
      loc-t-doc-pl.cli-doc-qnty
      with frame {&frame-name}.

    apply "leave" to loc-t-doc-pl.cli-doc-qnty in frame {&frame-name} .
  end.

  if loc-t-doc-pl.doc-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.doc-qnty = loc-t-doc-pl.doc-qnty + f-doc-line-doc-qnty - f-tot-doc-pl-doc-qnty
    .
    display
      loc-t-doc-pl.doc-qnty
      with frame {&frame-name}.

    apply "leave" to loc-t-doc-pl.doc-qnty in frame {&frame-name} .
  end.

  if loc-t-doc-pl.cli-fact-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-fact-qnty + f-doc-line-cli-fact-qnty - f-tot-doc-pl-cli-fact-qnty
    .
    display
      loc-t-doc-pl.cli-fact-qnty
      with frame {&frame-name}.

    apply "leave" to loc-t-doc-pl.cli-fact-qnty in frame {&frame-name} .
  end.

  if loc-t-doc-pl.fact-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.fact-qnty = loc-t-doc-pl.fact-qnty + f-doc-line-fact-qnty - f-tot-doc-pl-fact-qnty
    .
    display
      loc-t-doc-pl.fact-qnty
      with frame {&frame-name}.

    apply "leave" to loc-t-doc-pl.fact-qnty in frame {&frame-name} .
  end.

  run calc-qnty in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.cli-doc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.cli-doc-qnty f-doc-pl
ON LEAVE OF loc-t-doc-pl.cli-doc-qnty IN FRAME f-doc-pl /* cli-doc-qnty */
or return of {&self-name} in frame {&frame-name}
DO:

  define variable v-chg-qnty     like ub.doc-pl.doc-qnty   no-undo .
  define variable v-new-qnty     like ub.doc-pl.doc-qnty   no-undo .
  define variable v-correct-qnty as decimal   no-undo .

  define buffer buf_tt-doc-pl for tt-doc-pl .

  assign
    loc-t-doc-pl.cli-doc-qnty
  .
  { str/doc-pl.i disp-add-total }

  assign
    v-chg-qnty = loc-t-doc-pl.cli-doc-qnty / f-doc-pl-doc-density
  .
  if v-chg-qnty <> 0 then do:
    if loc-t-doc-pl.pl-code <> 0
      and loc-t-doc-pl.pl-code <> ?
    then do:
      { str/chkqnpl.i
        buf_trn-doc.doc-type
        loc-t-doc-pl.obj-type
        loc-t-doc-pl.obj-code
        loc-t-doc-pl.pl-code
        loc-t-doc-pl.gds-code
        v-msg-on
        v-chg-qnty
        v-new-qnty
      }
    end.
    else do:
      assign
        v-new-qnty = v-chg-qnty
      .
    end.

    assign
      v-correct-qnty = p-doc-line-doc-qnty - v-new-qnty
    .
    for each buf_tt-doc-pl no-lock
      where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
        and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
        and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
        and buf_tt-doc-pl.gds-code = p-gds-code
    on error undo, return no-apply
    :
      if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
        assign
          v-correct-qnty = v-correct-qnty - buf_tt-doc-pl.doc-qnty
        .
      end.
    end.
    if absolute( v-correct-qnty ) > 0.001 then do:
      assign
        v-correct-qnty = 0.0
      .
    end.

    assign
      loc-t-doc-pl.cli-qnty      = v-new-qnty / p-doc-line-cli-base-rate
      loc-t-doc-pl.doc-qnty      = v-new-qnty + v-correct-qnty
      loc-t-doc-pl.cli-doc-qnty  = v-new-qnty * f-doc-pl-doc-density
      loc-t-doc-pl.fact-qnty     = loc-t-doc-pl.doc-qnty
      loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-doc-qnty
    .
  end.
  else do:
    assign
      loc-t-doc-pl.cli-qnty      = 0.0
      loc-t-doc-pl.doc-qnty      = 0.0
      loc-t-doc-pl.fact-qnty     = 0.0
      loc-t-doc-pl.cli-doc-qnty  = 0.0
      loc-t-doc-pl.cli-fact-qnty = 0.0
      .
  end.

  display
    loc-t-doc-pl.cli-qnty      when loc-t-doc-pl.cli-qnty      :visible = true
    loc-t-doc-pl.doc-qnty
    loc-t-doc-pl.cli-doc-qnty  when loc-t-doc-pl.cli-doc-qnty  :visible = true
    loc-t-doc-pl.fact-qnty     when loc-t-doc-pl.fact-qnty     :visible = true
    loc-t-doc-pl.cli-fact-qnty when loc-t-doc-pl.cli-fact-qnty :visible = true
    with frame {&frame-name}.

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.cli-fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.cli-fact-qnty f-doc-pl
ON LEAVE OF loc-t-doc-pl.cli-fact-qnty IN FRAME f-doc-pl /* cli-fact-qnty */
or return of {&self-name} in frame {&frame-name}
DO:

  define variable v-chg-qnty     like ub.doc-pl.fact-qnty no-undo .
  define variable v-new-qnty     like ub.doc-pl.fact-qnty no-undo .
  define variable v-correct-qnty as decimal   no-undo .

  define buffer buf_tt-doc-pl for tt-doc-pl .

  assign
    loc-t-doc-pl.cli-fact-qnty
  .
  { str/doc-pl.i disp-add-total }

  if p-upd-field <> "rest-fact":U then do:
    assign
      v-chg-qnty = loc-t-doc-pl.cli-fact-qnty / f-doc-pl-fact-density
    .

    if v-chg-qnty <> 0 then do:
      { str/chkqnpl.i
        buf_trn-doc.doc-type
        loc-t-doc-pl.obj-type
        loc-t-doc-pl.obj-code
        loc-t-doc-pl.pl-code
        loc-t-doc-pl.gds-code
        v-msg-on
        v-chg-qnty
        v-new-qnty
      }

      assign
        v-correct-qnty = p-doc-line-fact-qnty - v-new-qnty
      .
      for each buf_tt-doc-pl no-lock
        where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
          and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
          and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
          and buf_tt-doc-pl.gds-code = p-gds-code
      on error undo, return no-apply
      :
        if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
          assign
            v-correct-qnty = v-correct-qnty - buf_tt-doc-pl.fact-qnty
          .
        end.
      end.
      if absolute( v-correct-qnty ) > 0.001 then do:
        assign
          v-correct-qnty = 0.0
        .
      end.

      assign
        loc-t-doc-pl.fact-qnty      = v-new-qnty + v-correct-qnty
        loc-t-doc-pl.cli-fact-qnty  = v-new-qnty * f-doc-pl-fact-density
      .
    end.
    else do:
      assign
        loc-t-doc-pl.fact-qnty     = 0.0
        loc-t-doc-pl.cli-fact-qnty = 0.0
        .
    end.
  end.

  run calc-qnty in this-procedure .

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.cli-rest-af-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.cli-rest-af-qnty f-doc-pl
ON LEAVE OF loc-t-doc-pl.cli-rest-af-qnty IN FRAME f-doc-pl /* cli-rest-af-qnty */
or return of {&self-name} in frame {&frame-name}
DO:
  define variable v-chg-qnty     like ub.doc-pl.rest-af-qnty no-undo .
  define variable v-new-qnty     like ub.doc-pl.rest-af-qnty no-undo .

  define buffer buf_tt-doc-pl for tt-doc-pl .

  assign
    loc-t-doc-pl.cli-rest-af-qnty
  .
  { str/doc-pl.i disp-add-total }

  assign
    v-chg-qnty = loc-t-doc-pl.cli-rest-af-qnty / f-doc-pl-rest-density
  .
  if v-chg-qnty <> 0.0 then do:
    { str/chkqnpl.i
      buf_trn-doc.doc-type
      loc-t-doc-pl.obj-type
      loc-t-doc-pl.obj-code
      loc-t-doc-pl.pl-code
      loc-t-doc-pl.gds-code
      v-msg-on
      v-chg-qnty
      v-new-qnty
    }

    assign
      loc-t-doc-pl.rest-af-qnty     = v-new-qnty
      loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.rest-af-qnty * f-doc-pl-rest-density
    .
  end.
  else do:
    assign
      loc-t-doc-pl.rest-af-qnty     = 0.0
      loc-t-doc-pl.cli-rest-af-qnty = 0.0
      .
  end.

  run calc-qnty in this-procedure .

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.doc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.doc-qnty f-doc-pl
ON LEAVE OF loc-t-doc-pl.doc-qnty IN FRAME f-doc-pl /* Заявлено */
or return of {&self-name} in frame {&frame-name}
DO:

  define variable v-chg-qnty      like ub.doc-pl.doc-qnty     no-undo .
  define variable v-new-qnty      like ub.doc-pl.doc-qnty     no-undo .
  define variable v-correct-qnty  as decimal   no-undo .
  define variable v-corr-cli-qnty as decimal   no-undo .

  define buffer buf_tt-doc-pl for tt-doc-pl .

  assign
    loc-t-doc-pl.doc-qnty
  .
  { str/doc-pl.i disp-add-total }

  assign
    v-chg-qnty = loc-t-doc-pl.doc-qnty
  .
  if v-chg-qnty <> 0 then do:
    if loc-t-doc-pl.pl-code <> 0
      and loc-t-doc-pl.pl-code <> ?
    then do:
      { str/chkqnpl.i
        buf_trn-doc.doc-type
        loc-t-doc-pl.obj-type
        loc-t-doc-pl.obj-code
        loc-t-doc-pl.pl-code
        loc-t-doc-pl.gds-code
        v-msg-on
        v-chg-qnty
        v-new-qnty
      }
    end.
    else do:
      assign
        v-new-qnty = v-chg-qnty
      .
    end.

    assign
      v-correct-qnty  = p-doc-line-doc-cli-qnty - v-new-qnty * f-doc-pl-doc-density
      v-corr-cli-qnty = p-doc-line-cli-qnty     - v-new-qnty / p-doc-line-cli-base-rate
    .
    for each buf_tt-doc-pl no-lock
      where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
        and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
        and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
        and buf_tt-doc-pl.gds-code = p-gds-code
    on error undo, return no-apply
    :
      if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
        assign
          v-correct-qnty  = v-correct-qnty  - buf_tt-doc-pl.cli-doc-qnty
          v-corr-cli-qnty = v-corr-cli-qnty - buf_tt-doc-pl.cli-qnty
        .
      end.
    end.
    if absolute( v-corr-cli-qnty ) > 0.001 then do:
      assign
        v-corr-cli-qnty = 0.0
      .
    end.
    if absolute( v-correct-qnty ) > 0.001 then do:
      assign
        v-correct-qnty = 0.0
      .
    end.

    assign
      loc-t-doc-pl.cli-qnty      = v-new-qnty / p-doc-line-cli-base-rate + v-corr-cli-qnty
      loc-t-doc-pl.doc-qnty      = v-new-qnty
      loc-t-doc-pl.cli-doc-qnty  = v-new-qnty * f-doc-pl-doc-density + v-correct-qnty
      loc-t-doc-pl.fact-qnty     = loc-t-doc-pl.doc-qnty
      loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-doc-qnty
      .
  end.
  else do:
    assign
      loc-t-doc-pl.cli-qnty      = 0.0
      loc-t-doc-pl.doc-qnty      = 0.0
      loc-t-doc-pl.fact-qnty     = 0.0
      loc-t-doc-pl.cli-doc-qnty  = 0.0
      loc-t-doc-pl.cli-fact-qnty = 0.0
      .
  end.

  display
    loc-t-doc-pl.cli-qnty      when loc-t-doc-pl.cli-qnty      :visible = true
    loc-t-doc-pl.doc-qnty
    loc-t-doc-pl.cli-doc-qnty  when loc-t-doc-pl.cli-doc-qnty  :visible = true
    loc-t-doc-pl.fact-qnty     when loc-t-doc-pl.fact-qnty     :visible = true
    loc-t-doc-pl.cli-fact-qnty when loc-t-doc-pl.cli-fact-qnty :visible = true
    with frame {&frame-name}.

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-doc-pl-rest-density
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-doc-pl-rest-density f-doc-pl
ON LEAVE OF f-doc-pl-rest-density IN FRAME f-doc-pl
or return of {&self-name} in frame {&frame-name}
DO:

  assign
    f-doc-pl-rest-density
  .
  if loc-t-doc-pl.cli-rest-af-qnty :sensitive = true then do:
    assign
      loc-t-doc-pl.rest-af-qnty = loc-t-doc-pl.cli-rest-af-qnty / f-doc-pl-rest-density
    .
  end.
  else do:
    assign
      loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.rest-af-qnty * f-doc-pl-rest-density
    .
  end.

  run calc-qnty in this-procedure .

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.fact-qnty f-doc-pl
ON LEAVE OF loc-t-doc-pl.fact-qnty IN FRAME f-doc-pl /* Фактически */
or return of {&self-name} in frame {&frame-name}
DO:

  define variable v-chg-qnty     like ub.doc-pl.fact-qnty     no-undo .
  define variable v-new-qnty     like ub.doc-pl.fact-qnty     no-undo .
  define variable v-correct-qnty as decimal   no-undo .

  define buffer buf_tt-doc-pl for tt-doc-pl .

  assign
    loc-t-doc-pl.fact-qnty
  .

  { str/doc-pl.i disp-add-total }

  if p-upd-field <> "rest-fact":U then do:
    assign
      v-chg-qnty = loc-t-doc-pl.fact-qnty
    .
    if v-chg-qnty <> 0 then do:
      { str/chkqnpl.i
        buf_trn-doc.doc-type
        loc-t-doc-pl.obj-type
        loc-t-doc-pl.obj-code
        loc-t-doc-pl.pl-code
        loc-t-doc-pl.gds-code
        v-msg-on
        v-chg-qnty
        v-new-qnty
      }
      assign
        v-correct-qnty = p-doc-line-fact-cli-qnty - v-new-qnty * f-doc-pl-fact-density
      .
      for each buf_tt-doc-pl no-lock
        where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
          and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
          and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
          and buf_tt-doc-pl.gds-code = p-gds-code
      on error undo, return no-apply
      :
        if buf_tt-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
          assign
            v-correct-qnty = v-correct-qnty - buf_tt-doc-pl.cli-fact-qnty
          .
        end.
      end.
      if absolute( v-correct-qnty ) > 0.001 then do:
        assign
          v-correct-qnty = 0.0
        .
      end.

      assign
        loc-t-doc-pl.fact-qnty      = v-new-qnty
        loc-t-doc-pl.cli-fact-qnty  = loc-t-doc-pl.fact-qnty * f-doc-pl-fact-density + v-correct-qnty
      .
    end.
    else do:
      assign
        loc-t-doc-pl.fact-qnty     = 0.0
        loc-t-doc-pl.cli-fact-qnty = 0.0
        .
    end.
  end.

  run calc-qnty in this-procedure .

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.pl-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.pl-code f-doc-pl
ON LEAVE OF loc-t-doc-pl.pl-code IN FRAME f-doc-pl /* Место хранения */
or return of loc-t-doc-pl.pl-code in frame {&frame-name}
DO:

  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf-old_parts  for ub.parts .
  define buffer buf-new_parts  for ub.parts .

/*  if input frame {&frame-name} loc-t-doc-pl.pl-code = ?  */
/*    or input frame {&frame-name} loc-t-doc-pl.pl-code = 0*/
/*  then do:                                               */
/*    message                                              */
/*      "Необходимо указать место хранения!"               */
/*      view-as alert-box information.                     */
/*    return no-apply .                                    */
/*  end.                                                   */

  if input frame {&frame-name} loc-t-doc-pl.pl-code <> loc-t-doc-pl.pl-code then do:
    find first buf_pl-gds no-lock
      where buf_pl-gds.obj-type = buf_trn-doc.obj-type
        and buf_pl-gds.obj-code = buf_trn-doc.obj-code
        and buf_pl-gds.pl-code  = input frame {&frame-name} loc-t-doc-pl.pl-code
        and buf_pl-gds.gds-code = p-gds-code
      no-error .
    if not available buf_pl-gds then do:
      apply "choose" to b-place in frame {&frame-name} .
      return no-apply .
    end.
    else do:
      find first tt-doc-pl no-lock
        where tt-doc-pl.obj-type = buf_trn-doc.obj-type
          and tt-doc-pl.obj-code = buf_trn-doc.obj-code
          and tt-doc-pl.pl-code  = buf_pl-gds.pl-code
          and tt-doc-pl.out-code = buf_trn-doc.doc-code
          and tt-doc-pl.gds-code = buf_pl-gds.gds-code
        no-error .
      if available tt-doc-pl then do:
        if not available buf-upd_tt-doc-pl
          or ( available buf-upd_tt-doc-pl
               and buf-upd_tt-doc-pl.pl-code <> buf_pl-gds.pl-code
             )
        then do:
          assign
            loc-t-doc-pl.pl-code :screen-value = string( loc-t-doc-pl.pl-code, loc-t-doc-pl.pl-code :format )
          .
          message
            substitute( "Строка по месту хранения &1 уже существует.", buf_pl-gds.pl-code ) skip
            view-as alert-box information .
          return no-apply .
        end.
      end.

      if buf_trn-doc.doc-type = {&income} then do:
        for each buf-old_parts
          where buf-old_parts.obj-type  = buf_trn-doc.obj-type
            and buf-old_parts.obj-code  = buf_trn-doc.obj-code
            and buf-old_parts.artic     = buf_goods.artic
            and buf-old_parts.prod-type = buf_goods.prod-type
            and buf-old_parts.prod-code = buf_goods.prod-code
            and buf-old_parts.in-code   = buf_trn-doc.doc-code
            and buf-old_parts.out-code  = buf_trn-doc.doc-code
        on error undo, return no-apply
        :
          if buf-old_parts.pl-code = loc-t-doc-pl.pl-code then do:
            find first buf-new_parts
              where buf-new_parts.obj-type  = buf_trn-doc.obj-type
                and buf-new_parts.obj-code  = buf_trn-doc.obj-code
                and buf-new_parts.artic     = buf_goods.artic
                and buf-new_parts.prod-type = buf_goods.prod-type
                and buf-new_parts.prod-code = buf_goods.prod-code
                and buf-new_parts.in-code   = buf_trn-doc.doc-code
                and buf-new_parts.out-code  = buf_trn-doc.doc-code
                and buf-new_parts.part-code = string( buf_pl-gds.pl-code )
              no-error .
            if available buf-new_parts then do:
              assign
                buf-new_parts.pl-code   = buf-old_parts.pl-code
                buf-new_parts.part-code = buf-old_parts.part-code
              .
            end.
            assign
              buf-old_parts.pl-code   = buf_pl-gds.pl-code
              buf-old_parts.part-code = string( buf_pl-gds.pl-code )
            .
          end.
        end. /* for each buf_parts */
      end.

      assign
        loc-t-doc-pl.pl-code
      .

      if loc-t-doc-pl.cli-doc-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.cli-doc-qnty in frame {&frame-name} .
      end.

      if loc-t-doc-pl.doc-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.doc-qnty in frame {&frame-name} .
      end.

      if loc-t-doc-pl.cli-fact-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.cli-fact-qnty in frame {&frame-name} .
      end.

      if loc-t-doc-pl.fact-qnty :sensitive = true then do:
        apply "leave" to loc-t-doc-pl.fact-qnty in frame {&frame-name} .
      end.

    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.pl-code f-doc-pl
ON VALUE-CHANGED OF loc-t-doc-pl.pl-code IN FRAME f-doc-pl /* Место хранения */
DO:

  assign
    frame {&FRAME-NAME} :title = substitute( 'Место хранения &1 товар &2 документ &3 (объект &4 &5) с кол-вами -- &6'
                                            ,loc-t-doc-pl.pl-code
                                            ,buf_goods.gds-code
                                            ,buf_trn-doc.doc-code
                                            ,buf-obj_clients.obj-type
                                            ,buf-obj_clients.obj-code
                                            ,p-mode
                                            )
  .

  if loc-t-doc-pl.pl-code <> ? then do:
    run get-from-rvs in this-procedure
      ( input  loc-t-doc-pl.out-code
       ,input  loc-t-doc-pl.gds-code
       ,input  loc-t-doc-pl.pl-code
       ,output f-rvs-state-measure-qnty
       ,output f-rvs-measure-qnty
       ,output f-rvs-state-measure-cli-qnty
       ,output f-rvs-measure-cli-qnty
       ,output f-rvs-state-density
       ,output f-rvs-density
       ,output v-label-rvs
      ) no-error .

    if v-is-ptrl = "no":U
      or v-label-rvs = "":U
    then do:
      hide
        v-label-rvs
        f-rvs-density
        f-rvs-measure-qnty
        f-rvs-measure-cli-qnty
        f-rvs-state-density
        f-rvs-state-measure-qnty
        f-rvs-state-measure-cli-qnty
        in frame {&frame-name}
        .
    end.
    else do:
      display
        v-label-rvs
        f-rvs-state-measure-qnty
        f-rvs-measure-qnty
        with frame {&frame-name}.
      if buf_goods.unit-cli = buf_goods.unit-base then do:
        hide
          f-rvs-density
          f-rvs-measure-cli-qnty
          f-rvs-state-density
          f-rvs-state-measure-cli-qnty
          in frame {&frame-name}
          .
      end.
      else do:
        display
          f-rvs-density
          f-rvs-measure-cli-qnty
          f-rvs-state-density
          f-rvs-state-measure-cli-qnty
          with frame {&frame-name}.
      end.
    end.

    find first buf_place no-lock
      where buf_place.obj-type = buf-obj_clients.obj-type
        and buf_place.obj-code = buf-obj_clients.obj-code
        and buf_place.pl-code  = loc-t-doc-pl.pl-code
        and buf_place.status_ <> {&deleted-status}
      no-error .

    if available buf_place then do:
      display
        buf_place.pl-name
        buf_place.loc1
        buf_place.loc2
        buf_place.loc3
        buf_place.loc4
        with frame {&frame-name}.
    end.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-t-doc-pl.rest-af-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-t-doc-pl.rest-af-qnty f-doc-pl
ON LEAVE OF loc-t-doc-pl.rest-af-qnty IN FRAME f-doc-pl /* Стало */
or return of {&self-name} in frame {&frame-name}
DO:

  define variable v-chg-qnty like ub.doc-pl.rest-af-qnty no-undo .
  define variable v-new-qnty like ub.doc-pl.rest-af-qnty no-undo .

  assign
    loc-t-doc-pl.rest-af-qnty
  .

  { str/doc-pl.i disp-add-total }

  assign
    v-chg-qnty = loc-t-doc-pl.rest-af-qnty
  .
  if v-chg-qnty <> 0 then do:
    { str/chkqnpl.i
      buf_trn-doc.doc-type
      loc-t-doc-pl.obj-type
      loc-t-doc-pl.obj-code
      loc-t-doc-pl.pl-code
      loc-t-doc-pl.gds-code
      v-msg-on
      v-chg-qnty
      v-new-qnty
    }

    assign
      loc-t-doc-pl.rest-af-qnty      = v-new-qnty
      loc-t-doc-pl.cli-rest-af-qnty  = loc-t-doc-pl.rest-af-qnty * f-doc-pl-rest-density
    .
  end.
  else do:
    assign
      loc-t-doc-pl.rest-af-qnty     = 0.0
      loc-t-doc-pl.cli-rest-af-qnty = 0.0
      .
  end.

  run calc-qnty in this-procedure .

  { str/doc-pl.i disp-add-total }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK f-doc-pl 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ str/doc-pl.i def }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define buffer buf_clients for ub.clients .
  define buffer buf_rvs-doc for ub.rvs-doc .
  define buffer buf_tt-doc-pl for tt-doc-pl .

  if p-upd-field = "doc":U then do:
    assign
      p-doc-line-fact-cli-qnty = p-doc-line-doc-cli-qnty
      p-doc-line-fact-qnty     = p-doc-line-doc-qnty
    .
  end.

  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
  .
  find first buf-upd_tt-doc-pl
    where buf-upd_tt-doc-pl.obj-type = buf_trn-doc.obj-type
      and buf-upd_tt-doc-pl.obj-code = buf_trn-doc.obj-code
      and buf-upd_tt-doc-pl.pl-code  = p-pl-code
      and buf-upd_tt-doc-pl.out-code = buf_trn-doc.doc-code
      and buf-upd_tt-doc-pl.gds-code = p-gds-code
    no-error .

  if not available buf-upd_tt-doc-pl then do:
    if p-mode = {&lookup} then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Нет записи о редактируемом резервуаре" skip
        view-as alert-box error .
      return error .
    end.
  end.

  { str/doc-pl.i init-tot p-gds-code v-is-ptrl }

  find first buf_clients no-lock
    where buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code
    .
  assign
    f-prod-name = buf_clients.obj-name
  .
  find first buf-obj_clients no-lock
    where buf-obj_clients.obj-type = buf_trn-doc.obj-type
      and buf-obj_clients.obj-code = buf_trn-doc.obj-code
    .

  create loc-t-doc-pl .
  if available buf-upd_tt-doc-pl then do:
    assign
      v-is-add = false
    .
    buffer-copy buf-upd_tt-doc-pl to loc-t-doc-pl .
  end.
  else do:
    assign
      v-is-add                            = true
      loc-t-doc-pl.obj-type               = buf_trn-doc.obj-type
      loc-t-doc-pl.obj-code               = buf_trn-doc.obj-code
      loc-t-doc-pl.out-code               = buf_trn-doc.doc-code
      loc-t-doc-pl.gds-code               = p-gds-code
    .
    if p-pl-code = ?
      or p-pl-code = 0
    then do:
      assign
        loc-t-doc-pl.pl-code = ?
      .
    end.
    else do:
      assign
        loc-t-doc-pl.pl-code = p-pl-code
      .
    end.
    assign
      loc-t-doc-pl.cli-qnty         = p-doc-line-cli-qnty
      loc-t-doc-pl.cli-doc-qnty     = p-doc-line-doc-cli-qnty
      loc-t-doc-pl.doc-qnty         = p-doc-line-doc-qnty
      loc-t-doc-pl.cli-fact-qnty    = p-doc-line-fact-cli-qnty
      loc-t-doc-pl.fact-qnty        = p-doc-line-fact-qnty
      loc-t-doc-pl.rest-af-qnty     = p-doc-line-rest-af-qnty
      loc-t-doc-pl.cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
    .
    for each buf_tt-doc-pl no-lock
      where buf_tt-doc-pl.obj-type = buf_trn-doc.obj-type
        and buf_tt-doc-pl.obj-code = buf_trn-doc.obj-code
        and buf_tt-doc-pl.out-code = buf_trn-doc.doc-code
        and buf_tt-doc-pl.gds-code = p-gds-code
    on error undo, return error return-value
    :
      assign
        loc-t-doc-pl.cli-qnty         = loc-t-doc-pl.cli-qnty         - buf_tt-doc-pl.cli-qnty
        loc-t-doc-pl.cli-doc-qnty     = loc-t-doc-pl.cli-doc-qnty     - buf_tt-doc-pl.cli-doc-qnty
        loc-t-doc-pl.doc-qnty         = loc-t-doc-pl.doc-qnty         - buf_tt-doc-pl.doc-qnty
        loc-t-doc-pl.cli-fact-qnty    = loc-t-doc-pl.cli-fact-qnty    - buf_tt-doc-pl.cli-fact-qnty
        loc-t-doc-pl.fact-qnty        = loc-t-doc-pl.fact-qnty        - buf_tt-doc-pl.fact-qnty
        loc-t-doc-pl.rest-af-qnty     = loc-t-doc-pl.rest-af-qnty     - buf_tt-doc-pl.rest-af-qnty
        loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.cli-rest-af-qnty - buf_tt-doc-pl.cli-rest-af-qnty
      .
    end.
  end.

  assign
    f-doc-pl-doc-density  = p-doc-line-doc-density
    f-doc-pl-fact-density = p-doc-line-fact-density
  .
  if p-upd-field = "rest":U
    or p-upd-field = "rest-fact":U
  then do:
    if loc-t-doc-pl.rest-af-qnty <> 0.0
      and loc-t-doc-pl.cli-rest-af-qnty <> 0.0
    then do:
      assign
        f-doc-pl-rest-density = loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty
      .
    end.
    else do:
      assign
        f-doc-pl-rest-density = p-doc-line-rest-density
      .
    end.
  end.

  RUN enable_UI.

  if v-is-add = true then do:
    { str/doc-pl.i disp-add-total }
  end.
  else do:
    { str/doc-pl.i disp-total }
  end.

  { str/doc-pl.i enable-tot-fld v-is-ptrl }
  if v-is-ptrl = "yes"
  then do:
    rvsinvObj = new rvsinvsub ().
    assign
      rvsinvObj:RvsCode = buf_trn-doc.out-code
      rvsinvObj:ObjCode = loc-t-doc-pl.obj-code
      rvsinvObj:ObjType = loc-t-doc-pl.obj-type
      rvsinvObj:PlCode = loc-t-doc-pl.pl-code
      rvsinvObj:GdsCode = loc-t-doc-pl.gds-code
    .
    if rvsinvObj:RvsInvStrObj:FillSub(rvsinvObj)
    then do:

        assign
          f-tot-doc-pl-rest-af-qnty     :row in frame {&frame-name}   = f-tot-doc-pl-doc-qnty :row in frame {&frame-name} - 1 
          f-tot-doc-pl-rest-af-qnty     :handle :side-label-handle :row in frame {&frame-name} = f-tot-doc-pl-doc-qnty :row in frame {&frame-name} - 1
          f-tot-doc-pl-cli-rest-af-qnty :row in frame {&frame-name}   = f-tot-doc-pl-rest-af-qnty :row in frame {&frame-name}
          f-tot-doc-pl-rest-density     :row in frame {&frame-name}   = f-tot-doc-pl-rest-af-qnty :row in frame {&frame-name}
        .

        assign
          frame {&frame-name} :height-chars = frame {&frame-name} :height-chars + 1
          rect-tot :height-chars in frame {&frame-name} = 4.5
        .
        
        if rvsinvObj:Diff < 0
        then do:
          assign
            f-otrnebal = absolute (rvsinvObj:Diff) 
            f-otrmetrerr = rvsinvObj:MeterErrWast
            f-nedos = rvsinvObj:DeficitOver
            f-wastcli = rvsinvObj:NaturWast
            f-wast-tp = rvsinvObj:TPWast
          .
        end.
        else do:
          assign
            f-polnebal = absolute (rvsinvObj:Diff)
            f-polmetrerr = rvsinvObj:MeterErrWast
            f-izlish = rvsinvObj:DeficitOver
          .
        end.        
        
        display
        f-otrnebal
        f-polnebal
        f-lblnebal
        f-lblpolnebal
        f-lblotrnebal
        f-lblmetrerr
        f-polmetrerr
        f-otrmetrerr
        f-lblwastcli
        f-wastcli
        f-lblwast-tp
        f-wast-tp
        f-lbldiff
        f-izlish
        f-nedos
          with frame {&frame-name}
        .

        

        hide
          f-tot-doc-pl-fact-qnty
          f-tot-doc-pl-cli-fact-qnty
        in frame {&frame-name}
        .

      if rvsinvObj:Diff < 0
      then do:
        f-otrnebal = rvsinvObj:Diff.

      end.
      else do:
      end.
    end.

  end.

  if buf_trn-doc.doc-type = {&income}
    and buf_trn-doc.internal = false
  then do:
    assign
      loc-t-doc-pl.cli-qnty   :label in frame {&frame-name} = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
    .
    display
      loc-t-doc-pl.cli-qnty
      with frame {&frame-name}.
      .
  end.

  case p-upd-field :
    when "rest":U
    or when "rest-fact":U
    then do:
      assign
        loc-t-doc-pl.fact-qnty        :label in frame {&frame-name} = substitute( "Разница" )
        loc-t-doc-pl.rest-af-qnty     :row in frame {&frame-name}   = loc-t-doc-pl.doc-qnty :row in frame {&frame-name}
        loc-t-doc-pl.rest-af-qnty     :handle :side-label-handle :row in frame {&frame-name} = loc-t-doc-pl.rest-af-qnty :row in frame {&frame-name}
        loc-t-doc-pl.cli-rest-af-qnty :row in frame {&frame-name}   = loc-t-doc-pl.rest-af-qnty :row in frame {&frame-name}
        f-doc-pl-rest-density         :row in frame {&frame-name}   = loc-t-doc-pl.rest-af-qnty :row in frame {&frame-name}
      .
      display
        loc-t-doc-pl.fact-qnty
        loc-t-doc-pl.rest-af-qnty
        loc-t-doc-pl.cli-fact-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        loc-t-doc-pl.cli-rest-af-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-rest-density         when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}.
        .
    end.
    when "doc":U then do:
      display
        loc-t-doc-pl.doc-qnty
        loc-t-doc-pl.cli-doc-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-doc-density      when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}
        .
    end.
    when "fact":U then do:
      display
        loc-t-doc-pl.doc-qnty
        loc-t-doc-pl.fact-qnty
        loc-t-doc-pl.cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        loc-t-doc-pl.cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-doc-density       when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-fact-density      when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}
        .
    end.
    when "fact-doc":U then do:
      display
        loc-t-doc-pl.fact-qnty
        loc-t-doc-pl.cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-pl-fact-density      when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame {&frame-name}
        .
    end.
  end case.

  if p-mode = {&lookup}
    or buf_trn-doc.status_ = {&fact}
  then do:
    disable
      all
      with frame {&frame-name}
    .
    enable
      b-quit
      b-help
      with frame {&frame-name}
    .
  end.
  else do:
    if p-mode = {&autoupdate} then do:
      assign
        v-msg-on = true
      .
    end.
    else do:
      assign
        v-msg-on = false
      .
    end.
    find first buf_rvs-doc no-lock
      where buf_rvs-doc.out-code = buf_trn-doc.doc-code
        and ( buf_rvs-doc.rvs-type = {&rvs-before-doc}
              or buf_rvs-doc.rvs-type = {&rvs-after-doc}
            )
      no-error .

    if p-upd-field = "doc":U
      or p-upd-field = "fact":U
      or p-upd-field = "fact-doc":U
    then do:
      enable
        b-qnty
        with frame {&frame-name}.
      if ( ( buf_trn-doc.doc-type = {&income}
            and not available buf_rvs-doc
          )
          or buf_trn-doc.doc-type <> {&income}
        )
      then do:
        enable
          loc-t-doc-pl.pl-code
          b-place
          with frame {&frame-name}.
        if loc-t-doc-pl.pl-code = ? then do:
          apply "choose" to b-place in frame {&frame-name} .
        end.
      end.
    end.

    case p-upd-field :
      when "rest":U then do:
        if buf_goods.unit-base <> buf_goods.unit-cli then do:
          enable
            f-doc-pl-rest-density
            with frame {&frame-name}.
        end.
        if p-upd-units = "cli":U
          and loc-t-doc-pl.cli-rest-af-qnty :visible = true
        then do:
          enable
            loc-t-doc-pl.cli-rest-af-qnty
            with frame {&frame-name}.
        end.
        else do:
          enable
            loc-t-doc-pl.rest-af-qnty
            with frame {&frame-name}.
        end.
      end.
      when "rest-fact":U then do:
        if loc-t-doc-pl.cli-fact-qnty :visible = true then do:
          enable
            loc-t-doc-pl.cli-fact-qnty
            with frame {&frame-name}.
        end.
        if loc-t-doc-pl.fact-qnty :visible = true then do:
          enable
            loc-t-doc-pl.fact-qnty
            with frame {&frame-name}.
        end.
      end.
      when "doc":U then do:
        if p-upd-units = "cli":U
          and loc-t-doc-pl.cli-doc-qnty :visible = true
        then do:
          enable
            loc-t-doc-pl.cli-doc-qnty
            with frame {&frame-name}.
          apply "leave" to loc-t-doc-pl.cli-doc-qnty in frame {&frame-name} .
        end.
        else do:
          enable
            loc-t-doc-pl.doc-qnty
            with frame {&frame-name}.
          apply "leave" to loc-t-doc-pl.doc-qnty in frame {&frame-name} .
        end.
      end.
      when "fact":U
      or when "fact-doc":U
      then do:
        if p-upd-units = "cli":U
          and loc-t-doc-pl.cli-fact-qnty :visible = true
        then do:
          enable
            loc-t-doc-pl.cli-fact-qnty
            with frame {&frame-name}.
          apply "leave" to loc-t-doc-pl.cli-fact-qnty in frame {&frame-name} .
        end.
        else do:
          enable
            loc-t-doc-pl.fact-qnty
            with frame {&frame-name}.
          apply "leave" to loc-t-doc-pl.fact-qnty in frame {&frame-name} .
        end.
      end.
    end case.

    assign
      v-msg-on = true
    .

  end.

  apply "value-changed" to loc-t-doc-pl.pl-code in frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

delete loc-t-doc-pl .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-qnty f-doc-pl 
PROCEDURE calc-qnty :
do
  on error undo, return error return-value
  :
    case p-upd-field :
      when "rest":U then do:
        assign
          loc-t-doc-pl.fact-qnty     = loc-t-doc-pl.rest-af-qnty - loc-t-doc-pl.rest-bf-qnty
          loc-t-doc-pl.cli-fact-qnty = loc-t-doc-pl.cli-rest-af-qnty - loc-t-doc-pl.cli-rest-bf-qnty
        .
      end.
      when "rest-fact":U then do:
        assign
          loc-t-doc-pl.rest-af-qnty     = loc-t-doc-pl.rest-bf-qnty + loc-t-doc-pl.fact-qnty
          loc-t-doc-pl.cli-rest-af-qnty = loc-t-doc-pl.cli-rest-bf-qnty + loc-t-doc-pl.cli-fact-qnty
        .
        if loc-t-doc-pl.rest-af-qnty <> 0.0
          and loc-t-doc-pl.cli-rest-af-qnty <> 0.0
        then do:
          assign
            f-doc-pl-rest-density = loc-t-doc-pl.cli-rest-af-qnty / loc-t-doc-pl.rest-af-qnty
          .
        end.
        else do:
          assign
            f-doc-pl-rest-density = p-doc-line-rest-density
          .
        end.
      end.
    end case.

    display
      loc-t-doc-pl.cli-qnty         when loc-t-doc-pl.cli-qnty :visible = true
      loc-t-doc-pl.doc-qnty         when loc-t-doc-pl.doc-qnty :visible = true
      loc-t-doc-pl.cli-doc-qnty     when loc-t-doc-pl.cli-doc-qnty :visible = true
      loc-t-doc-pl.fact-qnty        when loc-t-doc-pl.fact-qnty :visible = true
      loc-t-doc-pl.cli-fact-qnty    when loc-t-doc-pl.cli-fact-qnty :visible = true
      loc-t-doc-pl.rest-af-qnty     when loc-t-doc-pl.rest-af-qnty :visible = true
      loc-t-doc-pl.cli-rest-af-qnty when loc-t-doc-pl.cli-rest-af-qnty :visible = true
      f-doc-pl-rest-density         when f-doc-pl-rest-density :visible = true
      with frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI f-doc-pl  _DEFAULT-DISABLE
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
  HIDE FRAME f-doc-pl.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI f-doc-pl  _DEFAULT-ENABLE
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
  DISPLAY f-prod-name f-units-base 
      WITH FRAME f-doc-pl.
  IF AVAILABLE buf-obj_clients THEN 
    DISPLAY buf-obj_clients.obj-type buf-obj_clients.obj-code 
          buf-obj_clients.obj-name 
      WITH FRAME f-doc-pl.
  IF AVAILABLE buf_goods THEN 
    DISPLAY buf_goods.gds-code buf_goods.gds-name buf_goods.artic 
          buf_goods.prod-type buf_goods.prod-code 
      WITH FRAME f-doc-pl.
  IF AVAILABLE buf_place THEN 
    DISPLAY buf_place.pl-name buf_place.loc1 buf_place.loc2 buf_place.loc3 
          buf_place.loc4 
      WITH FRAME f-doc-pl.
  IF AVAILABLE loc-t-doc-pl THEN 
    DISPLAY loc-t-doc-pl.pl-code 
      WITH FRAME f-doc-pl.
  ENABLE b-exit b-quit b-help 
      WITH FRAME f-doc-pl.
  {&OPEN-BROWSERS-IN-QUERY-f-doc-pl}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME