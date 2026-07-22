&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER shar-buf_ord-cons FOR ub.ord-cons.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список совокупных заказов

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

Creation date: 03/13/02 10:16

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Список совокупных заказов   ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ gbl/usrfulnf.i }
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-status       as char no-undo.
define input  parameter list-mode as character no-undo .

define variable p-g#host-name  as character no-undo .
define variable store-type     as character no-undo .
define variable store-code     as integer   no-undo .

define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable doc-rec     as recid no-undo .
define variable line-rec    as recid no-undo . /* - */
define variable gds-rec     as recid no-undo . /* - */
define variable prt-rec     as recid no-undo . /* - */
define variable next-prev   as logical   no-undo .
define variable g#log       as logical   no-undo .


define variable g#type as character no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  v-cntxt-host-code-obj p-g#host-name }


define variable sch-field as char no-undo.
def buffer t-d-b for ub.ord-cons.  /* для поиска по номеру, дате, факт */
def buffer cns-doc for ub.ord-cons.  /* для поиска по номеру, дате, факт */
define new shared variable g#cons-code as character no-undo .
DEFINE  VARIABLE sch-fact AS date NO-UNDO.
define variable loc-doc-rec as recid no-undo .


define variable filter-point as character no-undo init "Совокупные заказы" .
define variable sort-column-name as character no-undo .


define variable old-state like ub.ord-doc.status_ no-undo .
/* scop */

&scop ff-d find current shar-buf_ord-cons no-lock no-error . ~
      if not avail shar-buf_ord-cons then do:                ~
        message                                  ~
        "Документ не выбран ! " view-as  alert-box .~
        return no-apply.                             ~
        end.

&scop send-to-news  ~
  run str/callnews.p ~
    ( input "ord-doc"  ~
    , input (buffer loc_ord-doc:handle) ~
    ) no-error . ~
  if error-status:error then do: ~
    assign loc_ord-doc.flag_ = false  loc_ord-doc.status_ = old-state . ~
    message                                                ~
      vss-workfile vss-revision vss-description skip       ~
      "Ошибка при передаче "                               ~
      (if loc_ord-doc.doc-type  =  {&o-f} then " заявки " else "заказа" )      ~
      " в новости" skip                                    ~
      "Документ" loc_ord-doc.doc-code skip                       ~
      view-as alert-box .                                  ~
      return no-apply.                                     ~
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs
&Scoped-define QUERY-NAME QUERY-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES shar-buf_ord-cons ub.ord-cons

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs ~
IF (shar-buf_ord-cons.status_ = {&fact} or shar-buf_ord-cons.status_ = {&ord-close}) THEN (shar-buf_ord-cons.status_ + string(shar-buf_ord-cons.flag_,"+/-")) ELSE (shar-buf_ord-cons.status_) ~
shar-buf_ord-cons.cons-code shar-buf_ord-cons.doc-date shar-buf_ord-cons.host-code shar-buf_ord-cons.fact-date shar-buf_ord-cons.creid ~
shar-buf_ord-cons.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs
&Scoped-define FIELD-PAIRS-IN-QUERY-br-docs
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY br-docs FOR EACH shar-buf_ord-cons ~
      WHERE shar-buf_ord-cons.host-code = v-cntxt-host-code-obj and ~
(p-status = "all":U  or (shar-buf_ord-cons.status_ = p-status) ) NO-LOCK ~
    BY shar-buf_ord-cons.doc-date DESCENDING ~
       BY shar-buf_ord-cons.cons-code DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-docs shar-buf_ord-cons
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs shar-buf_ord-cons


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.ord-cons SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.ord-cons
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.ord-cons


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-rep b-sch b-za b-zak ~
b-post b-help b-add b-lkp b-chg b-del b-close b-open b-print br-docs ~
EDITOR_PS sch-code sch-date sch-num
&Scoped-Define DISPLAYED-OBJECTS EDITOR_PS sch-code sch-date sch-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-print
       MENU-ITEM m_print_petrol LABEL "Совокупная заявка по нефтепродуктам"
       MENU-ITEM m_print_goods  LABEL "Совокупная заявка по товарам"
       MENU-ITEM m_print_full_goods LABEL "Совокупная заявка по товарам развернутая"
       .



/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1 TOOLTIP "Объединить заявки ОФ в совокупную заявку".

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 12 BY 1.

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 12 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 12 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 12 BY 1.

DEFINE BUTTON b-post
     LABEL "&Поставки":L
     SIZE 12 BY 1 TOOLTIP "Поставки по заказам".

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 12 BY 1 TOOLTIP "Печать документов".

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 12 BY 1.

DEFINE BUTTON b-rep
     LABEL "&Отчеты":L
     SIZE 12 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 12 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 12 BY 1.

DEFINE BUTTON b-za
     LABEL "За&явки":L
     SIZE 12 BY 1 TOOLTIP "Заявки ОФ".

DEFINE BUTTON b-zak
     LABEL "&Заказы":L
     SIZE 12 BY 1 TOOLTIP "Сформированные заказы ФП на основе СЗ".

DEFINE VARIABLE EDITOR_PS AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.92.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)"
     LABEL "&Начало номера"
     VIEW-AS FILL-IN
     SIZE 14.63 BY 1 NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE sch-num AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Найдено"
      VIEW-AS TEXT
     SIZE 3 BY .67
     FGCOLOR 12  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY br-docs FOR
      shar-buf_ord-cons SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.ord-cons SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _STRUCTURED
  QUERY br-docs NO-LOCK DISPLAY
      IF (shar-buf_ord-cons.status_ = {&fact} or shar-buf_ord-cons.status_ = {&ord-close})
THEN (shar-buf_ord-cons.status_ + string(shar-buf_ord-cons.flag_,"+/-"))
ELSE (shar-buf_ord-cons.status_) COLUMN-LABEL "Статус" FORMAT "X(8)"
      shar-buf_ord-cons.cons-code
      shar-buf_ord-cons.doc-date
      shar-buf_ord-cons.host-code
      shar-buf_ord-cons.fact-date
      usrfulnf ( shar-buf_ord-cons.creid) COLUMN-LABEL "Создал" FORMAT "X(12)"
      shar-buf_ord-cons.PS FORMAT "X(250)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.75
     b-sel AT ROW 1 COL 13.75
     b-rep AT ROW 1 COL 25.75
     b-sch AT ROW 1 COL 37.75
     b-za AT ROW 1 COL 49.75
     b-zak AT ROW 1 COL 61.75
     b-post AT ROW 1 COL 73.75
     b-help AT ROW 1 COL 85.75

     b-mark AT ROW 2 COL 1.75
     b-add AT ROW 2 COL 4.75
     b-lkp AT ROW 2 COL 13.75
     b-chg AT ROW 2 COL 25.75
     b-del AT ROW 2 COL 37.75
     b-close AT ROW 2 COL 49.75
     b-open AT ROW 2 COL 61.75
     b-print AT ROW 2 COL 85.88
     br-docs AT ROW 3 COL 1
     EDITOR_PS AT ROW 19 COL 1 NO-LABEL
     sch-code AT ROW 22 COL 15 COLON-ALIGNED
     sch-date AT ROW 22 COL 35.88 COLON-ALIGNED
     sch-num AT ROW 22 COL 57.63 COLON-ALIGNED
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Совокупнные заявки"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: shar-buf_ord-cons B "NEW SHARED" ? ub ub.ord-cons
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-docs b-print Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-print:HANDLE.

ASSIGN
       EDITOR_PS:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _TblList          = "ub.shar-buf_ord-cons"
     _Options          = "NO-LOCK"
     _OrdList          = "ub.shar-buf_ord-cons.doc-date|no,ub.shar-buf_ord-cons.cons-code|no"
     _Where[1]         = "shar-buf_ord-cons.host-code = v-cntxt-host-code-obj and
(p-status = ""all"":U  or (shar-buf_ord-cons.status_ = p-status) )"
     _FldNameList[1]   > "_<CALC>"
"IF (shar-buf_ord-cons.status_ = {&fact} or shar-buf_ord-cons.status_ = {&ord-close})
THEN (shar-buf_ord-cons.status_ + string(shar-buf_ord-cons.flag_,""+/-""))
ELSE (shar-buf_ord-cons.status_)" "Статус" "X(8)" ? ? ? ? ? ? ? no ?
     _FldNameList[2]   = Temp-Tables.shar-buf_ord-cons.cons-code
     _FldNameList[3]   = Temp-Tables.shar-buf_ord-cons.doc-date
     _FldNameList[4]   = Temp-Tables.shar-buf_ord-cons.host-code
     _FldNameList[5]   = Temp-Tables.shar-buf_ord-cons.fact-date
     _FldNameList[6]   = Temp-Tables.shar-buf_ord-cons.creid
     _FldNameList[7]   > Temp-Tables.shar-buf_ord-cons.PS
"shar-buf_ord-cons.PS" ? "X(250)" "character" ? ? ? ? ? ? no ?
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.ord-cons"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK QUERY QUERY-2
/* Query rebuild information for QUERY QUERY-2
     _Design-Parent    is DIALOG-BOX Dialog-Frame @ ( 22.63 , 63.5 )
*/  /* QUERY QUERY-2 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Совокупнные заявки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run cus/g-crord.p (input parParentProc).
  {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
{&ff-d}
  if available shar-buf_ord-cons and (shar-buf_ord-cons.status_ <> {&g___new}
                     and shar-buf_ord-cons.status_ <> {&ord-alloc}
                     and shar-buf_ord-cons.status_ <> {&ord-close}) then do:
     message "Изменять документ в статусе  '" shar-buf_ord-cons.status_ "' нельзя! " view-as alert-box .
     return no-apply.
  end.
  if available shar-buf_ord-cons and (shar-buf_ord-cons.status_ = {&g___new}
                       OR shar-buf_ord-cons.status_ = {&ord-alloc}
                       OR shar-buf_ord-cons.status_ = {&ord-close}
                       ) then do:
      run cus/or-plan.w ( parParentProc , input shar-buf_ord-cons.cons-code , {&update}, list-mode) no-error .
      if error-status :error then do:
        find current shar-buf_ord-cons  no-lock  no-error .
        return no-apply.
      end.

      find current shar-buf_ord-cons  no-lock  no-error .
      if error-status :error then do:
         {&OPEN-QUERY-{&BROWSE-NAME}}
      end.
      else do:
      g#log =  {&BROWSE-NAME}:refresh() .
      end.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закрыть */
DO:
{&ff-d}
if available shar-buf_ord-cons then do:
  doc-rec = recid(shar-buf_ord-cons).
  run cus/consstat.p ( parParentProc , recid(shar-buf_ord-cons)).
  g#log =  {&BROWSE-NAME}:refresh() .
  /* reposition br-docs to recid doc-rec no-error. */
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define buffer loc_ord-doc for ub.ord-doc .
{&ff-d}

  if available shar-buf_ord-cons and shar-buf_ord-cons.status_ <> {&g___new} then do:
     message "Удалять документ в статусе  '" shar-buf_ord-cons.status_ "' нельзя! " view-as alert-box .
     return no-apply.
  end.

    if available shar-buf_ord-cons and shar-buf_ord-cons.status_ = {&g___new} then do:
       find current shar-buf_ord-cons exclusive-lock no-error.
            if avail shar-buf_ord-cons then do:
               message "Удалить совокупную заявку №"  shar-buf_ord-cons.cons-code view-as alert-box
                        question buttons yes-no title "Вопрос" update g#log.
                    if g#log then do:
                        for each loc_ord-doc where loc_ord-doc.cons-code = shar-buf_ord-cons.cons-code  OR
                                 loc_ord-doc.cons-code = shar-buf_ord-cons.cons-code + {&ord-rejection}
                                 exclusive-lock  :
                           assign
                               old-state = loc_ord-doc.status_
                               loc_ord-doc.cons-code = ""
                               loc_ord-doc.status_ = {&ord-accept}
                           .
                           {&send-to-news}
                        end.
                        delete  shar-buf_ord-cons .
                        {&OPEN-QUERY-{&BROWSE-NAME}}
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
 {&ff-d}
    if available shar-buf_ord-cons then do:
      run cus/or-plan.w ( parParentProc , input shar-buf_ord-cons.cons-code  ,input {&lookup} , list-mode) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open Dialog-Frame
ON CHOOSE OF b-open IN FRAME Dialog-Frame /* Открыть */
DO:
{&ff-d}
if available shar-buf_ord-cons then do:
  doc-rec = recid(shar-buf_ord-cons).
  loc-doc-rec = recid(shar-buf_ord-cons).
  g#log =  {&BROWSE-NAME}:refresh() .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-post
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-post Dialog-Frame
ON CHOOSE OF b-post IN FRAME Dialog-Frame /* Поставки */
DO:
define variable v-list as character no-undo .
   {&ff-d}
   run cus/all-rcv.w
      ( parParentProc ,
        v-cntxt-host-code-obj,
        ?                     ,
        ?                     ,
        shar-buf_ord-cons.cons-code ,
        "" ,
        output v-list
        ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
message "ничего нет" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure  no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-za
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-za Dialog-Frame
ON CHOOSE OF b-za IN FRAME Dialog-Frame /* Заявки */
DO:
  DEF VAR p-list as char no-undo.
  {&ff-d}
  if available shar-buf_ord-cons then do:
    run ref/all-zakz.w
    ( input   parParentProc
    , input   {&o-f}
    , input   "all"
    , input   "cons":U
    , input   recid( shar-buf_ord-cons )
    , input   "b-lkp,nob-exec,nob-copy"
    , input   ""
    , output  p-list       ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-zak
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-zak Dialog-Frame
ON CHOOSE OF b-zak IN FRAME Dialog-Frame /* Заказы */
DO:
  DEF VAR p-list as char no-undo.
  {&ff-d}
  if available shar-buf_ord-cons then do:
    run cus/zakz-rcv.w
    ( input   parParentProc
    , input   {&f-p}
    , input   "all"
    , input   "cons":U
    , input   recid( shar-buf_ord-cons )
    , input   "b-lkp,b-chg,b-del,b-close,b-open,nob-exec,nob-copy"
    , input   ""
    , output  p-list
     ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&Scoped-define SELF-NAME br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON ANY-PRINTABLE OF br-docs IN FRAME Dialog-Frame
DO:
  apply "entry" to sch-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
  editor_pS =  shar-buf_ord-cons.PS .
  display  editor_pS with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print_goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print_goods Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print_goods /* Совокупная заявка по товарам */
DO:
{&ff-d}
    run cus/r-cnsgds.p
      ( input parparentproc
      , input recid(shar-buf_ord-cons)
      ) .
END.
ON CHOOSE OF MENU-ITEM m_print_full_goods /* Совокупная заявка по товарам */
DO:
{&ff-d}
    run cus/r-cons2.p
      ( input parparentproc
      , input recid(shar-buf_ord-cons)
      ) .
END.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print_petrol
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print_petrol Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print_petrol /* Совокупная заявка по нефтепродуктам */
DO:
{&ff-d}
 run cus/r-cons.p
   ( input parparentproc
   , recid(shar-buf_ord-cons)
   ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME Dialog-Frame /* Начало номера */
OR  RETURN OF sch-code IN FRAME {&frame-name}
DO:
  if sch-code <> input frame {&frame-name} sch-code or sch-field <> "doc-code" then do:
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
 sch-field = "cons-code".
 assign sch-code = input frame {&frame-name} sch-code.
 find first ub.ord-cons where ub.ord-cons.cons-code  begins sch-code no-error .
        if available ub.ord-cons then doc-rec = recid(ub.ord-cons) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else
      reposition br-docs to recid doc-rec no-error.

return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME Dialog-Frame /* Дата */
OR  RETURN OF sch-date IN FRAME {&frame-name}
DO:
  if sch-date <> input frame {&frame-name} sch-date or sch-field <> "doc-date" then do:
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
 sch-field = "cons-date".
 assign sch-date = input frame {&frame-name} sch-date.
 find first ub.ord-cons where ub.ord-cons.doc-date  = sch-date no-error .
        if available ub.ord-cons then doc-rec = recid(ub.ord-cons) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else
      reposition br-docs to recid doc-rec no-error.

return no-apply.

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
{ gbl/ed_date.i sch-date}
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/brwrefre.i "run enable_UI in this-procedure .  run init-p in this-procedure ." }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_UI in this-procedure .
  run init-p in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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

  DISPLAY EDITOR_PS sch-code sch-date sch-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-mark b-sel b-rep b-sch b-za b-zak b-post b-help b-add b-lkp
         b-chg b-del b-close b-open b-print br-docs EDITOR_PS sch-code sch-date
         sch-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-p Dialog-Frame
PROCEDURE init-p :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
frame {&frame-name}:title =  "Совокупные заявки , Фирма: " + p-g#host-name  +
if p-status = "all" then "" else ", Статус: " + p-status.

If list-mode <> "obj":U  then do:
   if not( p-status = {&g___new}  OR  p-status = "all" )  then disable  b-add b-del b-chg with frame {&frame-name} .
   if ( p-status = {&ord-alloc}
        or  p-status = {&ord-close}
         )  then do:
        enable   b-chg with frame {&frame-name} .
        disable  b-add b-del with frame {&frame-name} .
      end.
   end.
   else do:
      disable b-close b-add b-del b-sel b-mark with frame {&frame-name} .
   end.
ASSIGN B-print:POPUP-MENU IN FRAME {&frame-name} = MENU POPUP-MENU-B-print:HANDLE.
ASSIGN B-print:MENU-MOUSE = 1.


disable b-open with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Совокупные заказы".
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


&scop flt-open-open-query OPEN QUERY br-docs FOR EACH shar-buf_ord-cons

&scop flt-open-dyn_open-query  FOR EACH shar-buf_ord-cons

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name shar-buf_ord-cons


&scop flt-open-open-query-tail
&scop flt-open-query-was-opened  l-query-was-opened
&scop flt-open-sort-column-phrase sort-column-phrase
&scop flt-open-call-point filter-point
&scop flt-open-set-filter-name set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-debug-file

do:

if p-status = 'all' then  do:
frame {&frame-name}:TITLE = title0  .
     { gbl/fltopend.i
        &where-cond = " TRUE "
        &dyn_where-cond = " 'TRUE' "
        &use-ind    = " USE-INDEX pi "
        &by         = "  " }
end.
else do:
frame {&frame-name}:TITLE = title0  .
     { gbl/fltopend.i
        &where-cond = " shar-buf_ord-cons.status_ = p-status "
        &dyn_where-cond =  " substitute(' shar-buf_ord-cons.status_ =  &1&2&1 ' , ~{&double-quote~} , p-status ) "
        &use-ind    = " USE-INDEX pi "
        &by         = "  " }
end.

end.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'ord-cons'
  join-tbl = 'shar-buf_ord-cons'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure ('cons-code', 'Номер', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ('doc-date', 'Дата', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ('fact-date', 'Факт', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

/*'order-status-all*/
run fltfield-add in this-procedure ('status_', 'Статус', 'order-status-all',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure ('PS', 'Комментарий', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ('creid', 'Опер-р', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    /*
 run fltfield-add in this-procedure ('boss', 'Менеджер', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

 run fltfield-add in this-procedure ('agnt', 'Исполнитель', 'cli',
 input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ('wrkr', 'Кладовщик', 'cli',
 input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      */

  Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parParentProc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).

    run OpenBr in this-procedure .
  END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME