/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка документа инвентаризации счетчиков ТРК (заведение, редактирование, просмотр)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/22/07
Author: Dmitry Ukhanov
Creation date: 08/22/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06
Author1: Alexey Suslov
Creation date1: 03/27/06


*/

define input        parameter parparentproc as widget-handle no-undo .
define input        parameter p-mode        as character     no-undo .
define input-output parameter parrec-id     as recid         no-undo .

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка документа инвентаризации счетчиков ТРК (заведение, редактирование, просмотр)":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/showinf.i }
{ cmp/library.i      }
{ gbl/color.i        }
{ str/libbcrcn.i     }

define variable varlog as logical no-undo .

{ str/doc-code.i      }
{ gbl/waitfram.i      }
{ gbl/getcntxt.i def  }
{ str/lib-rvs.i       }
{ str/rvsttdef.i pump }
{ str/lib-trn.i       }



&scop FRAME-NAME       d-icnt
&scop browse-name      br-line
&scop table-name       i-doc
&scop line-name        ub.icnt-line


define buffer {&table-name} for ub.icnt-doc.
define buffer   cli-buf     for ub.clients.

define variable gds-rec         as   recid               no-undo .
define variable v-curr-obj-type like ub.clients.obj-type no-undo .
define variable v-curr-obj-code like ub.clients.obj-code no-undo .

/* ********************  Preprocessor Definitions  ******************** */
&scop OPEN-QUERY-{&browse-name} OPEN QUERY {&browse-name}                                                 ~
   FOR EACH {&line-name} WHERE {&line-name}.doc-code = {&table-name}.doc-code NO-LOCK,                    ~
             FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = {&line-name}.gds-code NO-LOCK

&scop open-query-{&browse-name}-default {&open-query-{&browse-name}}.

&scop label-clmn_1-br-dtl   'ТРК'
&scop sort-clmn_1-br-dtl    {&line-name}.pump-code
&scop label-clmn_2-br-dtl   'Пис!то!лет'
&scop sort-clmn_2-br-dtl    {&line-name}.nozzle-code
&scop label-clmn_3-br-dtl   'Артикул'
&scop sort-clmn_3-br-dtl    goods.artic
&scop label-clmn_4-br-dtl   'Показания!электронного!счетчика'
&scop sort-clmn_4-br-dtl    {&line-name}.state-el-cnt
&scop label-clmn_5-br-dtl   'Показания!механического!счетчика'
&scop sort-clmn_5-br-dtl    {&line-name}.state-mh-cnt
&scop label-clmn_6-br-dtl   'Разница'
&scop sort-clmn_6-br-dtl    func-delta (buffer {&line-name})
&scop label-clmn_7-br-dtl   'Измерение!электронного!счетчика'
&scop sort-clmn_7-br-dtl    {&line-name}.meas-el-cnt
&scop label-clmn_8-br-dtl   'Название товара'
&scop sort-clmn_8-br-dtl    goods.gds-name
&scop label-clmn_9-br-dtl   'Резервуар'
&scop sort-clmn_9-br-dtl    {&line-name}.pl-code
&scop enabled-clmn          {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl}

/* ***********************  Control Definitions  ********************** */
define variable icnt-line-rec as recid no-undo.
define variable l-g#stat      as   character                  no-undo.
define variable l-g#type      as   character                  no-undo.
define variable l-g#internal  as   logical                    no-undo.
define variable vardelta      like {&table-name}.state-el-cnt no-undo.
define variable vardelta-line like {&line-name}.state-el-cnt  no-undo.
define variable ref-list      as   character                  no-undo.

FUNCTION func-delta RETURN DECIMAL (buffer bf_i-line for ub.icnt-line).
   return (bf_i-line.state-el-cnt - bf_i-line.state-mh-cnt).
END FUNCTION.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 7 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Вых":L
     SIZE 7 BY 1.

DEFINE BUTTON b-notes
     LABEL "При&м":L
     SIZE 7 BY 1.

DEFINE BUTTON b-read
     LABEL "Перечитать данные c ТРК"
     SIZE 24 BY 1.

DEFINE BUTTON r-acc
     IMAGE-UP          FILE "btn-down-arrow"
     IMAGE-DOWN        FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3 BY .88.

DEFINE BUTTON r-agnt     LIKE r-acc.
DEFINE BUTTON r-boss     LIKE r-acc.
DEFINE BUTTON r-wrkr     LIKE r-acc.

DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.


DEFINE QUERY {&browse-name} FOR {&line-name}, ub.goods SCROLLING.

DEFINE BROWSE {&browse-name} QUERY {&browse-name} NO-LOCK DISPLAY
      {&sort-clmn_1-br-dtl}                 COLUMN-LABEL {&label-clmn_1-br-dtl}
      {&sort-clmn_2-br-dtl}                 COLUMN-LABEL {&label-clmn_2-br-dtl}
      {&sort-clmn_3-br-dtl}                 COLUMN-LABEL {&label-clmn_3-br-dtl}
      {&sort-clmn_4-br-dtl}                 COLUMN-LABEL {&label-clmn_4-br-dtl}
      {&sort-clmn_5-br-dtl}                 COLUMN-LABEL {&label-clmn_5-br-dtl} format "->>>,>>>,>>9.999"
      {&sort-clmn_6-br-dtl} @ vardelta-line COLUMN-LABEL {&label-clmn_6-br-dtl}
      {&sort-clmn_7-br-dtl}                 COLUMN-LABEL {&label-clmn_7-br-dtl}
      {&sort-clmn_8-br-dtl}                 COLUMN-LABEL {&label-clmn_8-br-dtl}
      {&sort-clmn_9-br-dtl}                 COLUMN-LABEL {&label-clmn_9-br-dtl}
      ENABLE {&enabled-clmn}
    WITH SIZE 98 BY 12 separators.

/* ************************  Frame Definitions  *********************** */
DEFINE FRAME {&frame-name}
b-exit                            AT ROW 1 COL 1
{&table-name}.obj-code            AT ROW 1.5 COL 16  COLON-ALIGNED LABEL "Объект" VIEW-AS TEXT SIZE 7 BY 1
{&table-name}.obj-type            AT ROW 1.5 COL 23  COLON-ALIGNED NO-LABEL       VIEW-AS TEXT SIZE 7.13 BY 1
ub.clients.obj-name                  AT ROW 1.5 COL 33  COLON-ALIGNED NO-LABEL       VIEW-AS TEXT SIZE 40 BY 1 fgcolor 4
{&table-name}.fact-date           AT ROW 2.5 COL 40  COLON-ALIGNED
{&table-name}.shift-date          AT ROW 2.5 COL 58  COLON-ALIGNED LABEL "Смена"
{&table-name}.shift-num           AT ROW 2.5 COL 70  COLON-ALIGNED LABEL "П"
{&table-name}.shift-name         AT ROW 2.5 COL 80  COLON-ALIGNED LABEL "№"
{&table-name}.agnt                FORMAT "999999999"      AT ROW 5   COL 4.5 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 BY 1
agnt-name                         AT ROW 5   COL 15  COLON-ALIGNED NO-LABEL fgcolor 4
r-agnt                            AT ROW 5   COL 28  NO-LABEL
{&table-name}.wrkr                FORMAT "999999999"      AT ROW 4   COL 4.5 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 BY 1
wrkr-name                         AT ROW 4   COL 15  COLON-ALIGNED NO-LABEL fgcolor 4
r-wrkr                            AT ROW 4   COL 28  NO-LABEL
{&table-name}.boss                FORMAT "999999999"      AT ROW 6   COL 4.5 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 BY 1
boss-name                         AT ROW 6   COL 15  COLON-ALIGNED NO-LABEL fgcolor 4
r-boss                            AT ROW 6   COL 28  NO-LABEL
{&table-name}.state-el-cnt        LABEL "Показания электронных счетчиков" AT ROW 4   COL 75  COLON-ALIGNED VIEW-AS TEXT
{&table-name}.state-mh-cnt        LABEL "Показания механических счетчиков" AT ROW 5   COL 75  COLON-ALIGNED VIEW-AS TEXT
vardelta                          LABEL "Разница" AT ROW 6   COL 75  COLON-ALIGNED VIEW-AS TEXT
{&table-name}.meas-el-cnt         LABEL "Измерения электронных счетчиков" AT ROW 7   COL 75  COLON-ALIGNED VIEW-AS TEXT
{&browse-name} AT ROW 8 COL 1
b-read   AT ROW 20 COL 4
b-notes  AT ROW 20 COL 28
b-help   AT ROW 20 COL 35
SPACE(0) SKIP(0)
WITH VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE KEEP-TAB-ORDER.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
  FRAME {&frame-name}:SCROLLABLE                           = FALSE
  {&browse-name}:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 3.

/* ************************  Control Triggers  ************************ */
{ gbl/mv-clmn.i
 &ext-col      = 9
 &frame-name   = "{&frame-name}"
 &browse-name  = "{&browse-name}"
 &table-name   = "{&line-name}"
 &start-column = 4
}

{ gbl/f2.i {&browse-name} " " " " parparentproc }


on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
end.

ON choose OF b-notes IN FRAME {&frame-name}
DO:
define variable v-notes as character no-undo .
v-notes = {&table-name}.PS.
run gbl/notes.w ( input p-mode, input-output v-notes ).
if {&table-name}.PS <> v-notes then do:
  do on stop undo, return no-apply:
    find {&table-name} where recid ({&table-name}) = parrec-id exclusive.
    {&table-name}.PS = v-notes.
  end.
end.
END.

ON CHOOSE OF b-exit IN FRAME {&frame-name} /* Вых */
DO:
if p-mode = {&update}  OR
   p-mode = {&add-def} then do:
  if not can-find (first {&line-name} where {&line-name}.doc-code = {&table-name}.doc-code no-lock) then do:
    varlog = yes.
    message "В документе нет строк, поэтому он удаляется." view-as alert-box
      question buttons OK-Cancel update varlog.
    if varlog then do:
      delete {&table-name}.
      assign parrec-id = ?.
      return.
    end.
    else return no-apply.
  end.
  assign {&table-name}.wrkr {&table-name}.agnt {&table-name}.boss.
end.
END.

ON MOUSE-SELECT-DBLCLICK, return OF {&table-name}.agnt IN FRAME {&frame-name} /* Эксп */
DO:
  RUN local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to {&table-name}.boss in frame {&frame-name}.
  return no-apply.
END.

ON MOUSE-SELECT-DBLCLICK, return OF {&table-name}.boss IN FRAME {&frame-name} /* Нач */
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

ON MOUSE-SELECT-DBLCLICK, return OF {&table-name}.wrkr IN FRAME {&frame-name} /* Исп */
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to {&table-name}.agnt in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF r-agnt IN FRAME {&frame-name} /* agent */
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to {&table-name}.boss in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF r-boss IN FRAME {&frame-name} /* boss */
DO:
   RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF r-wrkr IN FRAME {&frame-name} /* worker */
DO:
  RUN local-psn-chk ("wrkr", "button").
  apply "entry" to {&table-name}.agnt in frame {&frame-name}.
  return no-apply.
END.

ON leave OF {&table-name}.agnt IN FRAME {&frame-name} /* agent */
DO:
   RUN local-psn-chk ("agnt", "leave").
END.

ON leave OF {&table-name}.boss IN FRAME {&frame-name} /* boss */
DO:
   RUN local-psn-chk ("boss", "leave").
END.

ON leave OF {&table-name}.wrkr IN FRAME {&frame-name} /* worker */
DO:
   RUN local-psn-chk ("wrkr", "leave").
END.
ON CHOOSE OF b-read IN FRAME {&frame-name}
DO:
   { gbl/stdbtn.i }
   RUN read-pump NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      { str/errmes.i "Ошибка при чтении счетчиков ТРК"}
   END.
   RUN UI-on.
END.

ON LEAVE OF {&line-name}.state-mh-cnt IN BROWSE {&browse-name} DO:
if {&line-name}.state-mh-cnt <> DECIMAL({&line-name}.state-mh-cnt:SCREEN-VALUE IN BROWSE {&BROWSE-NAME}) then do transaction:
   find current {&line-name} exclusive-lock.
   ASSIGN {&line-name}.state-mh-cnt = DECIMAL({&line-name}.state-mh-cnt:SCREEN-VALUE IN BROWSE {&BROWSE-NAME}).
   DISPLAY func-delta (buffer {&line-name}) @ vardelta-line with browse {&browse-name}.
   RUN recalc-icnt.
end.
RUN display-value.
END.

ON LEAVE OF {&line-name}.state-el-cnt IN BROWSE {&browse-name} DO:
if {&line-name}.state-el-cnt <> DECIMAL({&line-name}.state-el-cnt:SCREEN-VALUE IN BROWSE {&BROWSE-NAME}) then do transaction:
  find current {&line-name} exclusive-lock.
  ASSIGN {&line-name}.state-el-cnt = DECIMAL({&line-name}.state-el-cnt:SCREEN-VALUE IN BROWSE {&BROWSE-NAME}).
  DISPLAY func-delta (buffer {&line-name}) @ vardelta-line with browse {&browse-name}.
  RUN recalc-icnt.
end.
RUN display-value.
END.

{ gbl/srt-clmn.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "{&line-name}"
&ext-col = 9
&start-column  = 4
&label-clmn_1  = "{&label-clmn_1-br-dtl}"
&sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
&label-clmn_2  = "{&label-clmn_2-br-dtl}"
&sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
&label-clmn_3  = "{&label-clmn_3-br-dtl}"
&sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
&label-clmn_4  = "{&label-clmn_4-br-dtl}"
&sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
&label-clmn_5  = "{&label-clmn_5-br-dtl}"
&sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
&label-clmn_6  = "{&label-clmn_6-br-dtl}"
&sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
&label-clmn_7  = "{&label-clmn_7-br-dtl}"
&sort-clmn_7   = "{&sort-clmn_7-br-dtl}"
&label-clmn_8  = "{&label-clmn_8-br-dtl}"
&sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
&label-clmn_9  = "{&label-clmn_9-br-dtl}"
&sort-clmn_9   = "{&sort-clmn_9-br-dtl}"
&open-query           = "{&OPEN-QUERY-{&browse-name}} BY ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&OPEN-QUERY-{&browse-name}-default}"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }

/* ***************************  Main Block  *************************** */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
   run mode-on no-error.
   if error-status:error then return error.
   if p-mode <> {&lookup} then icnt-line-rec = ?.
   run UI-on.
   WAIT-FOR GO OF FRAME {&FRAME-NAME} focus b-read.
END.
RUN disable_UI.


/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
/* ----------------------------------------------------------------------------------------------------------------------------
  Purpose:     включение пользовательского интерфейса в нужном режиме
--------------------------------------------------------------------------------------------------------------------------------- */
find ub.clients where ub.clients.obj-type = {&table-name}.obj-type and
                   ub.clients.obj-code = {&table-name}.obj-code no-lock.
ASSIGN frame {&frame-name}:title = "(" + substring (clients.obj-name, 1, 35) +
       ") :   ДОКУМЕНТ ИНВЕНТАРИЗАЦИИ СЧЕТЧИКОВ ТРК - " + {&table-name}.status_ + " № " + {&table-name}.doc-code + "      - " + p-mode.
disable all with frame {&frame-name}.
enable b-exit b-help  {&browse-name} b-notes with frame {&frame-name}.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_upd-el-cnt':U
  {&cntxt-object}
  clients.host-code
  clients.obj-type
  clients.obj-code
  0
  0
  0
  false
  varlog
}
if not varlog then do:
    ASSIGN {&sort-clmn_4-br-dtl}:READ-ONLY in browse {&browse-name} = YES.
end.
if p-mode = {&lookup} then do:
   ASSIGN
     {&sort-clmn_4-br-dtl}:READ-ONLY in browse {&browse-name} = YES
     {&sort-clmn_5-br-dtl}:READ-ONLY in browse {&browse-name} = YES.
end.
if {&table-name}.status_ = {&g___new} and
   (p-mode = {&add-def} or
    p-mode = {&update}        ) then do:
      enable {&table-name}.wrkr
             {&table-name}.agnt
             {&table-name}.boss
             r-wrkr r-agnt r-boss
             b-read
             with frame {&frame-name}.
end.

disp {&table-name}.obj-code
     {&table-name}.obj-type
     with frame {&frame-name}.
run display-value.

{ str/psn-chk.i wrkr on {&table-name} }
{ str/psn-chk.i agnt on {&table-name} }
{ str/psn-chk.i boss on {&table-name} }

{&OPEN-QUERY-{&browse-name}-default}
if p-mode = {&lookup} then do:
  if icnt-line-rec <> ? then reposition {&browse-name} to recid icnt-line-rec no-error.
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.
if p-mode = {&update} then do:
    apply "entry" to {&browse-name} in frame {&frame-name}.
end.
if num-results("{&browse-name}") > 0 then do:
   if {&browse-name}:refresh() then.
end.
END PROCEDURE.

PROCEDURE mode-on :
define variable v-today as date      no-undo.

define buffer bf_pump-nozzle    for ub.pump-nozzle.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer bf_pl-gds         for ub.pl-gds.
/* -----------------------------------------------------------
  Purpose:     чтение или создание шапки
-------------------------------------------------------------*/
case p-mode :
  when {&add-def} then do:
    tr:
    do transaction on error undo tr, return error return-value
                   on stop  undo tr, return error return-value
                   on quit  undo tr, return error return-value :
       run waitfram-show in this-procedure ("Создаем документ.").
       create {&table-name}.
       { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-today }
       run doc-code in this-procedure
        (input  "main",
         input  v-curr-obj-type,
         input  v-curr-obj-code,
         input  ?,
         output {&table-name}.doc-code) no-error.
       if error-status:error then do:
         message "Ошибка при генерации номера документа." skip
                 return-value
         view-as alert-box error.
         return error.
       end.
       assign
        {&table-name}.host-code = v-cntxt-host-code-obj
        {&table-name}.obj-type  = v-cntxt-obj-type
        {&table-name}.obj-code  = v-cntxt-obj-code
        {&table-name}.status_   = {&g___new}
        {&table-name}.flag_     = no
        {&table-name}.creid     = v-cntxt-userid
        {&table-name}.PS        = "@"
        {&table-name}.doc-date  = v-today
        parrec-id = recid ({&table-name})
       .
       /*Создаем сразу все строки*/
       for each bf_pump-nozzle where bf_pump-nozzle.obj-type = {&table-name}.obj-type and
                                     bf_pump-nozzle.obj-code = {&table-name}.obj-code and
                                     bf_pump-nozzle.is-meas  = yes                    no-lock
                                     on error undo tr, return error return-value
                                     :

           find first bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = bf_pump-nozzle.obj-type    and
                                              bf_pl-pump-nozzle.obj-code    = bf_pump-nozzle.obj-code    and
                                              bf_pl-pump-nozzle.pump-code   = bf_pump-nozzle.pump-code   and
                                              bf_pl-pump-nozzle.nozzle-code = bf_pump-nozzle.nozzle-code no-lock no-error.
           if available bf_pl-pump-nozzle then do:
              find first bf_pl-gds where bf_pl-gds.obj-type  = bf_pl-pump-nozzle.obj-type and
                                         bf_pl-gds.obj-code  = bf_pl-pump-nozzle.obj-code and
                                         bf_pl-gds.pl-code   = bf_pl-pump-nozzle.pl-code  no-lock no-error.
           end.

           create {&line-name}.
           assign {&line-name}.doc-code     = {&table-name}.doc-code
                  {&line-name}.obj-type     = {&table-name}.obj-type
                  {&line-name}.obj-code     = {&table-name}.obj-code
                  {&line-name}.pump-code    = bf_pump-nozzle.pump-code
                  {&line-name}.nozzle-code  = bf_pump-nozzle.nozzle-code
                  {&line-name}.pl-code      = (if available bf_pl-pump-nozzle then bf_pl-pump-nozzle.pl-code else ?)
                  {&line-name}.gds-code     = (if available bf_pl-gds         then bf_pl-gds.gds-code        else ?)
                  {&line-name}.meas-el-cnt  = ?
                  {&line-name}.state-el-cnt = ?
                  {&line-name}.state-mh-cnt = ?
                  .
       end.
       find first {&line-name} no-error.
       if available {&line-name} then do:
         run waitfram-show in this-procedure ("Считываем данные со счетчиков ТРК.").
         /*Заполняем их показаниями электронных счетчиков*/
         run read-pump no-error.
         if error-status:error then do:
           run waitfram-hide in this-procedure .
           { str/errmes.i "Ошибка при чтении счетчиков ТРК"}
           undo tr, return error.
         END.
         run waitfram-hide in this-procedure .
       end.
    end. /*transaction*/
  end.
  when {&update} then do:
    tr:
    do transaction on error undo tr, return error
                   on stop  undo tr, return error
                   on quit  undo tr, return error :
       find {&table-name} where recid ({&table-name}) = parrec-id no-error.
       if available {&table-name} then do:
         if {&table-name}.status_ = {&fact} then do:
           find {&table-name} where recid ({&table-name}) = parrec-id no-lock.
           message "Документ уже закрыт. Изменение невозможно.".
           undo, return error.
         end.
         find {&table-name} where recid ({&table-name}) = parrec-id exclusive.
       end.
    end. /*transaction*/
  end.
  when {&lookup} then do:
     find {&table-name} where recid ({&table-name}) = parrec-id no-lock no-error.
  end.
end.
if not available {&table-name} then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.

display {&table-name}.fact-date
        {&table-name}.shift-date
        {&table-name}.shift-num
        {&table-name}.shift-name           with frame {&frame-name}.

END PROCEDURE.

PROCEDURE local-psn-chk:
DEFINE INPUT PARAMETER parMan    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER parAction AS CHARACTER NO-UNDO.
IF parMan = "agnt" AND parAction = "ret-mouse" THEN DO:
   { str/psn-chk.i agnt ret-mouse {&table-name} }
END.
IF parMan = "agnt" AND parAction = "button" THEN DO:
   { str/psn-chk.i agnt button {&table-name} }
END.
IF parMan = "agnt" AND parAction = "leave" THEN DO:
   { str/psn-chk.i agnt leave {&table-name} }
END.
IF parMan = "boss" AND parAction = "ret-mouse" THEN DO:
   { str/psn-chk.i boss ret-mouse {&table-name} }
END.
IF parMan = "boss" AND parAction = "button" THEN DO:
   { str/psn-chk.i boss button {&table-name} }
END.
IF parMan = "boss" AND parAction = "leave" THEN DO:
   { str/psn-chk.i boss leave {&table-name} }
END.
IF parMan = "wrkr" AND parAction = "ret-mouse" THEN DO:
   { str/psn-chk.i wrkr ret-mouse {&table-name} }
END.
IF parMan = "wrkr" AND parAction = "button" THEN DO:
   { str/psn-chk.i wrkr button {&table-name} }
END.
IF parMan = "wrkr" AND parAction = "leave" THEN DO:
   { str/psn-chk.i wrkr leave {&table-name} }
END.
END PROCEDURE.

PROCEDURE read-pump:
define buffer bf_icnt-line for ub.icnt-line.
define variable varcur-pump as logical no-undo.
define variable varnum      as integer no-undo.
define variable ptoldfilvalue as character no-undo.
define variable ptoldfiltype  as character no-undo.
/*Заполняем временную таблицу для считывания данных с ТРК*/
for each tt-pump-nozzle:
    delete tt-pump-nozzle.
end.
for each bf_icnt-line where bf_icnt-line.doc-code = {&table-name}.doc-code:
    create tt-pump-nozzle.
    assign tt-pump-nozzle.obj-type    = bf_icnt-line.obj-type
           tt-pump-nozzle.obj-code    = bf_icnt-line.obj-code
           tt-pump-nozzle.pump-code   = bf_icnt-line.pump-code
           tt-pump-nozzle.nozzle-code = bf_icnt-line.nozzle-code
           tt-pump-nozzle.gds-code    = bf_icnt-line.gds-code.
end.

{ gbl/conf-rd.i
  "'ptoldfil':u"
  {&table-name}.host-code
  {&table-name}.obj-type
  {&table-name}.obj-code
  "''"
  "''"
  "''"
  no
  ptoldfilvalue
  ptoldfiltype
  no-error
}
if ptoldfilvalue = "yes":u then do:
  run gbl/d-askw.w ("Выбор источника данных с информацией по ТРК",
                "Будем читать текущие данные с ТРК или возьмем данные из файла?",
                "|^",
                "Текущие данные|Из файлов|Отмена",
                "Запускается программа для обращения к датчикам ТРК|Берутся уже сохраненные данные из файла|Ничего не делаем",
                1,
                3,
                output varnum
                ).
  case varnum:
  when 3 then do:
    undo, return error.
  end.
  when 2 then do:
    assign
      varcur-pump = no.
  end.
  when 1 then do:
    assign
      varcur-pump = yes.
  end.
  end case.
end.
else do:
  assign
    varcur-pump = yes.
end.
{ str/anls-pmp.i
    parparentproc
    {&table-name}.obj-type
    {&table-name}.obj-code
    yes
    tt-pump-nozzle-file
    tt-pump-nozzle
    varcur-pump
    yes
    no
    no-error
}
if error-status :error then do:
   return error return-value.
end.
if return-value <> "":U then do:
  message
    substitute("&1", return-value ) skip
    view-as alert-box information .
end.
do transaction on error undo, return error :
  for each bf_icnt-line where bf_icnt-line.doc-code = {&table-name}.doc-code:
      find first tt-pump-nozzle where tt-pump-nozzle.obj-type    = bf_icnt-line.obj-type    and
                                      tt-pump-nozzle.obj-code    = bf_icnt-line.obj-code    and
                                      tt-pump-nozzle.pump-code   = bf_icnt-line.pump-code   and
                                      tt-pump-nozzle.nozzle-code = bf_icnt-line.nozzle-code.
      assign bf_icnt-line.meas-el-cnt  = tt-pump-nozzle.meas-el-cnt
             bf_icnt-line.state-el-cnt = bf_icnt-line.meas-el-cnt.
  end.
  RUN recalc-icnt.
end.
END PROCEDURE.

PROCEDURE recalc-icnt:
define buffer bf_icnt-line for ub.icnt-line.
for each bf_icnt-line where bf_icnt-line.doc-code = {&table-name}.doc-code:
    accumulate bf_icnt-line.meas-el-cnt  (total)
               bf_icnt-line.state-el-cnt (total)
               bf_icnt-line.state-mh-cnt (total).
end.
assign {&table-name}.meas-el-cnt  = (accum total bf_icnt-line.meas-el-cnt)
       {&table-name}.state-el-cnt = (accum total bf_icnt-line.state-el-cnt)
       {&table-name}.state-mh-cnt = (accum total bf_icnt-line.state-mh-cnt).
END PROCEDURE.

procedure display-value:
display
     {&table-name}.state-el-cnt
     {&table-name}.state-mh-cnt
     {&table-name}.state-el-cnt - {&table-name}.state-mh-cnt @ vardelta
     {&table-name}.meas-el-cnt
     with frame {&frame-name}.
end procedure.