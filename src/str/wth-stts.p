block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-stts.p $
$Archive: str/wth-stts.p $

Изменение статуса (открытие/закрытие) документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions */
define input parameter parparentproc  as widget-handle no-undo .
DEFINE       PARAM BUFFER buf_wth-doc  FOR ub.wth-doc .
DEFINE INPUT PARAMETER    par-mode AS  CHAR NO-UNDO .
DEFINE INPUT PARAMETER    par-talk AS  LOG  NO-UNDO .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define input parameter p-file-name-err    as   char         no-undo.


/* VSS Variables Definitions */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: wth-stts.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: str/wth-stts.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "изменение статуса (открытие/закрытие) документов МЦ":U.

/* Global & Shared Variables & Preprocessors Definitions */
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ trg/factord.i }
{ gbl/waitfram.i }
{ str/wth-lib.i }
{ gbl/cur-time.i }


/* Local Variables Definitions */
DEFINE VARIABLE j_fact-num  LIKE ub.wth-doc.fact-num   NO-UNDO.
DEFINE VARIABLE j_fact-time LIKE ub.wth-doc.fact-time  NO-UNDO.
DEFINE VARIABLE d_fact-date LIKE ub.wth-doc.fact-date  NO-UNDO.
DEFINE VARIABLE d-fact-ord  LIKE ub.wth-doc.fact-order NO-UNDO.
DEFINE VARIABLE d-shift-ord LIKE ub.wth-doc.fact-order NO-UNDO.
DEFINE VARIABLE day-end-ord LIKE ub.wth-doc.fact-order NO-UNDO.
define variable v-obj-date  as date no-undo .
define variable v-obj-shift-date as date no-undo .
define variable v-obj-shift-num as integer no-undo .
define variable v-obj-shift-name as character no-undo .
DEFINE VARIABLE l-shift-on  AS   LOGICAL               NO-UNDO.
DEFINE VARIABLE var-mes as character no-undo .
DEFINE VARIABLE l-need-check-inv as logical no-undo init false .
DEFINE VARIABLE l-fact-close as logical no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
/*есть неучтенные чеки МЦ*/
DEFINE VARIABLE  not-all-doced as logical init no.
/*есть ошибочные чеки МЦ*/
DEFINE VARIABLE not-all-normal as logical init no.
/*есть незакрытые автодокументы МЦ*/
DEFINE VARIABLE  not-all-closed as logical no-undo init no.
DEFINE VARIABLE var-status_ like ub.wth-doc.status_ no-undo .
DEFINE VARIABLE varchk-doc-exist as logical no-undo .
define variable v-rec as recid no-undo .
define variable v-notes as character no-undo .
define variable v-vararh-mode  as integer      no-undo.
define variable v-warning    as logical      no-undo.
define variable v-is-back-date as logical no-undo .
define variable v-recalc-fact-ord as decimal no-undo .
define variable v-wth-doc-code as character no-undo .
define variable v-fact-date as date no-undo .
define variable var-log     as logical no-undo .


{ trg/wthdsum.i def }

/* Buffers Definitions */
define buffer buf_clients   FOR ub.clients.
define buffer buf_wth-line  FOR ub.wth-line.
define buffer buf_wth-dtl   FOR ub.wth-dtl.
define buffer buf_wth-obj   FOR ub.wth-obj.
define buffer buf_wth-parts for ub.wth-parts.
define buffer buf_wealth    for ub.wealth.
define buffer buf_sysconf   FOR ub.sysconf.
define buffer buf_out_wth-doc for ub.wth-doc.

/* ***************************  Main Block  *************************** */

IF NOT AVAIL buf_wth-doc THEN DO:
  var-mes = "Документ движения МЦ не найден!".
  IF par-talk
  then
  MESSAGE var-mes VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR var-mes.
END.
ELSE DO:
  ASSIGN v-rec = RECID( buf_wth-doc ).
END.
assign
v-wth-doc-code = buf_wth-doc.doc-code.
IF buf_wth-doc.status_ = {&fact} THEN DO:
  var-mes = "Документ " + buf_wth-doc.doc-code + " уже закрыт на ФАКТ!".
  IF par-talk
  then
  MESSAGE var-mes VIEW-AS ALERT-BOX ERROR.
  RETURN error var-mes.
END.

/*if buf_wth-doc.auto-fill and
   buf_wth-doc.status_ = {&wayb} AND
   par-mode = "+":U
   then do:
  if par-talk then do:
    loc#log = no.
    message
    "Автодокументы МЦ закрываются сразу на" {&fact} SKIP
    "Продолжать?"
    view-as alert-box WARNING buttons YES-NO  update loc#log.
    if not loc#log then return.
    l-need-check-inv = yes.
  end.
end.   */

run waitfram-show in this-procedure ( Input "Ждите..." ).

if buf_wth-doc.doc-type = {&declaration} then
l-need-check-inv  = no.

if buf_wth-doc.doc-type = {&inventory} and
   buf_wth-doc.status_ = {&wayb} and
   par-mode = "+":U then
   l-need-check-inv  = yes
   .

if buf_wth-doc.doc-type = {&inventory} and
   buf_wth-doc.status_ = {&permitted} and
   par-mode = "+":U then
   l-need-check-inv  = no
   .

if buf_wth-doc.doc-type = {&inventory} and
   buf_wth-doc.status_ = {&permitted} and
   par-mode = "-":U then
   l-need-check-inv  = no
   .

if buf_wth-doc.auto-fill then do:
FIND FIRST buf_sysconf No-LOCK WHERE
           buf_sysconf.host-code = buf_wth-doc.host-code No-ERROR.
if not available buf_sysconf then return error.
if buf_wth-doc.cli-type = buf_sysconf.sale-type AND
   buf_wth-doc.cli-code = buf_sysconf.sale-code then
   varchk-doc-exist = no.
 else varchk-doc-exist = yes.
end.


find first ub.sys-ctrl No-LOCK.

Main-Block:
DO TRANSACTION ON ERROR UNDO Main-Block, RETURN ERROR :
  FIND buf_wth-doc EXCLUSIVE-LOCK WHERE
       RECID( buf_wth-doc ) = v-rec.
l-fact-close = (if (buf_wth-doc.status_ = {&permitted} or buf_wth-doc.auto-fill) and par-mode = "+":U
                then yes
                else no).


if l-fact-close and
   buf_wth-doc.auto-fill = yes and
   varchk-doc-exist then do:
    run str/chk-winf.p (
                input parparentproc
               ,input buf_wth-doc.host-code
               ,input buf_wth-doc.obj-type
               ,input buf_wth-doc.obj-code
               ,INPUT no
               ,INPUT yes
               ,INPUT recid(buf_wth-doc)
               ,output v-notes
               ,output not-all-doced
               ,output not-all-normal
               ,output not-all-closed) no-error.
    if error-status:error  then do:
       run waitfram-hide in this-procedure .
       return error.
    end.
    if par-talk then do:
      message
      v-notes skip
      "Закрытие автодокумента МЦ" +
      ( if ub.sys-ctrl.db-num <> 0 then " и отправка его в офис." else "." ) skip (2)
      "Вы уверены ?" skip (2)
      "Закрытый документ нельзя исправить или удалить." skip
      "Чтобы ПРОВЕРИТЬ ДОКУМЕНТ еще раз, выберите CANCEL."
      view-as alert-box question buttons OK-Cancel update loc#log.
      if NOT loc#log  then do:
          run waitfram-hide in this-procedure .
          return error.
      end.
    end.
 end.


/* Перед закрытием документа на факт заблокируем все wth-obj, чтобы невозможно было создать документ,
основывающийся на числах из данного, но закрытый и отправленый по новостям раньше
Причем блокировку на местах хранения не делаем для уничтожения из зоны клиента */
  run trg/lock-wth.p
    (input buf_wth-doc.doc-code                                                  /* v-wth-doc-doc-code     */
    ,input l-need-check-inv                                                      /* p-check-inv            */
    ,input 0                                                                     /* p-document-fact-order  */
    ,input l-fact-close                                                          /* p-fact-close           */
    ,input false                                                                 /* p-is-news              */
    ) no-error.
  if error-status :error then do:
    run waitfram-hide in this-procedure .
    undo Main-Block, return error .
  end.

  if buf_wth-doc.doc-type <> {&exchange} then do:
    { trg/wthdsum.i check buf_wth-doc.doc-code buf_wth-doc buf_wth-line buf_wth-dtl varchk-doc-exist " " buf_wth-parts }
  end.
  var-status_ = buf_wth-doc.status_.
  if var-status_ = {&wayb} and (buf_wth-doc.auto-fill or not buf_wth-doc.doc-type = {&inventory}) then var-status_ = "auto":U.
  IF par-mode = "+":U THEN DO:
      if var-status_ =  {&wayb} or
         var-status_  = "auto":U THEN DO:
        FOR EACH buf_wth-line NO-LOCK WHERE
                 buf_wth-line.doc-code = buf_wth-doc.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
          FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              RECID( ub.wth-line ) = RECID( buf_wth-line ).

          IF buf_wth-doc.doc-type = {&inventory} THEN DO:
            if buf_wth-doc.auto-fill and
               can-find(first ub.chk-doc No-LOCK WHERE
                              ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                              ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                              ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                              ub.chk-doc.chk-type = integer({&pay-transfer})) then do:

              run wth-lib_cur-stock-place in this-procedure (
                                                               input  buf_wth-doc.obj-type
                                                              ,input  buf_wth-doc.obj-code
                                                              ,input  buf_wth-line.w-p-code
                                                              ,input  buf_wth-line.wth-code
                                                              ,output buf_wth-line.bef-sum
                                                              ) no-error.
              ASSIGN
              Buf_wth-line.aft-sum  = Buf_wth-line.bef-sum + buf_wth-line.fact-sum
              Buf_wth-line.doc-sum  = 0
              buf_wth-line.status_ = {&permitted}
              .
            end.
            else do:
              ASSIGN
              Buf_wth-line.aft-sum  = Buf_wth-line.bef-sum
              Buf_wth-line.doc-sum  = 0
              buf_wth-line.status_ = {&permitted}
              .
            end.
          END.
          ELSE DO:
/*              ASSIGN
              Buf_wth-line.fact-sum = (if buf_wth-doc.doc-type = {&declaration} then 0 else Buf_wth-line.doc-sum)
              buf_wth-line.status_ = {&permitted}
              .  */
          END.
          FOR EACH buf_wth-dtl NO-LOCK WHERE
                  buf_wth-dtl.doc-code = buf_wth-line.doc-code AND
                  buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
                  buf_wth-dtl.w-p-code = buf_wth-line.w-p-code  ON ERROR UNDO Main-Block, RETURN ERROR :
            FIND FIRST ub.wth-dtl EXCLUSIVE-LOCK WHERE
                      RECID( ub.wth-dtl ) = RECID( buf_wth-dtl ).
            IF buf_wth-doc.doc-type = {&inventory} THEN DO:
              ASSIGN
              Buf_wth-dtl.aft-sum  = Buf_wth-dtl.bef-sum
              Buf_wth-dtl.doc-sum  = 0
              .
            END.
            ELSE DO:
/*                ASSIGN
                Buf_wth-dtl.fact-sum = (if buf_wth-doc.doc-type = {&declaration}
                                        then 0
                                        else Buf_wth-dtl.doc-sum)
                . */
            END.
          END. /* buf_wth-dtl */
        END. /* buf_wth-line */
        IF buf_wth-doc.doc-type = {&inventory} THEN DO:
          if buf_wth-doc.auto-fill and
               can-find(first ub.chk-doc No-LOCK WHERE
                              ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                              ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                              ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                              ub.chk-doc.chk-type = integer({&pay-transfer})) then do:
            ASSIGN
            buf_wth-doc.aft-sum = buf_wth-doc.bef-sum + buf_wth-doc.fact-sum
            buf_wth-doc.doc-sum = 0
            .
          end.
          else do:
           ASSIGN
            buf_wth-doc.aft-sum = buf_wth-doc.bef-sum
            buf_wth-doc.doc-sum = 0
            .
          end.
        END.
        else do:
/*          assign
          buf_wth-doc.fact-sum = (if buf_wth-doc.doc-type = {&declaration}
                                  then 0
                                  else buf_wth-doc.doc-sum).  */
        end.
        ASSIGN buf_wth-doc.status_ = {&permitted}.
      END. /* if wayb or auto*/
      /*Закрытие на факт*/
      if var-status_ = {&permitted} or
         var-status_ = "auto":U THEN DO:
        if not buf_wth-doc.status_ = {&permitted} then.
        else do:
        FIND FIRST buf_clients NO-LOCK WHERE
                  buf_clients.obj-type = parobj-type AND
                  buf_clients.obj-code = parobj-code NO-ERROR.
        IF NOT AVAIL buf_clients THEN DO:
          var-mes = "Нет объекта" + parobj-type + string(parobj-code) +  "в справочнике клиентов!".
          IF par-talk THEN DO:
            MESSAGE var-mes
            VIEW-AS ALERT-BOX ERROR.
          END.
          run waitfram-hide in this-procedure .
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        IF buf_wth-doc.obj-type <> parobj-type OR
           buf_wth-doc.obj-code <> parobj-code OR
           buf_clients.db-num <> g#db-num THEN DO:
          var-mes = "Закрыть на ФАКТ можно только на объекте!".
          IF par-talk THEN DO:
            MESSAGE var-mes
            VIEW-AS ALERT-BOX ERROR.
          END.
          run waitfram-hide in this-procedure .
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        FOR EACH buf_wth-line NO-LOCK WHERE
                buf_wth-line.doc-code = buf_wth-doc.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
          FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              RECID( ub.wth-line ) = RECID( buf_wth-line ).
          IF buf_wth-doc.doc-type = {&inventory} THEN DO:
            if buf_wth-doc.auto-fill and
                can-find(first ub.chk-doc No-LOCK WHERE
                                ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                                ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                                ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                                ub.chk-doc.chk-type = integer({&pay-transfer})) then do:
              run wth-lib_cur-stock-place in this-procedure (
                                                               input  buf_wth-doc.obj-type
                                                              ,input  buf_wth-doc.obj-code
                                                              ,input  buf_wth-line.w-p-code
                                                              ,input  buf_wth-line.wth-code
                                                              ,output buf_wth-line.bef-sum
                                                              ) no-error.
              ASSIGN
              Buf_wth-line.aft-sum  = Buf_wth-line.bef-sum + buf_wth-line.fact-sum
              buf_wth-line.status_ = {&fact}
              .
            end.
            else do:
              ASSIGN
              Buf_wth-line.fact-sum  = Buf_wth-line.aft-sum - buf_wth-line.bef-sum
              buf_wth-line.status_ = {&fact}
              .
            end.
          END.
          else do:
            ASSIGN
            buf_wth-line.status_ = {&fact}
            .
          end.
          FOR EACH buf_wth-dtl NO-LOCK WHERE
                  buf_wth-dtl.doc-code = buf_wth-line.doc-code AND
                  buf_wth-dtl.wth-code = buf_wth-line.wth-code AND
                  buf_wth-dtl.w-p-code = buf_wth-line.w-p-code  ON ERROR UNDO Main-Block, RETURN ERROR :
            FIND FIRST ub.wth-dtl EXCLUSIVE-LOCK WHERE
                      RECID( ub.wth-dtl ) = RECID( buf_wth-dtl ).
            IF buf_wth-doc.doc-type = {&inventory} THEN DO:
              ASSIGN
              Buf_wth-dtl.fact-sum  = Buf_wth-dtl.aft-sum - buf_wth-dtl.bef-sum
              .
            END.
          END. /* buf_wth-dtl */
        END. /* buf_wth-line */

        IF buf_wth-doc.doc-type = {&inventory} THEN DO:
          if buf_wth-doc.auto-fill and
              can-find(first ub.chk-doc No-LOCK WHERE
                              ub.chk-doc.obj-type = buf_wth-doc.obj-type AND
                              ub.chk-doc.obj-code = buf_wth-doc.obj-code AND
                              ub.chk-doc.out-code = buf_wth-doc.doc-code AND
                              ub.chk-doc.chk-type = integer({&pay-transfer})) then do:
            ASSIGN
            buf_wth-doc.aft-sum = buf_wth-doc.bef-sum + buf_wth-doc.fact-sum
            .
           end.
           else do:
            ASSIGN
            buf_wth-doc.fact-sum = buf_wth-doc.aft-sum - buf_wth-doc.bef-sum
            .
           end.
        END.
        if buf_wth-doc.doc-type <> {&exchange} then do:
          { trg/wthdsum.i check buf_wth-doc.doc-code buf_wth-doc buf_wth-line buf_wth-dtl varchk-doc-exist "UNDO Main-Block, " buf_wth-parts }
        end.
        { gbl/curobjdt.i buf_wth-doc.obj-type buf_wth-doc.obj-code v-obj-date no-error}
        if error-status:error then do:
          var-mes =
          vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
          "Ошибка при определении даты на объекте" + {&new-line} +
          ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          run waitfram-hide in this-procedure .
          UNDO Main-Block, RETURN ERROR var-mes.
        end.
        if /*Not buf_wth-doc.auto-fill OR  */
          buf_wth-doc.fact-date = ?
        then do:
          d_fact-date = v-obj-date.
        end.
        else do:
          assign
          d_fact-date = buf_wth-doc.fact-date
          .
        end.
        ASSIGN
        j_fact-time = TIME
        j_fact-num  = NEXT-VALUE( s-wth-fact, {&db-name_schema} )
        .
        /*проверка корректности на текущую смену*/

        run gbl/chk-date.p (
                        INPUT buf_wth-doc.obj-type,
                        INPUT buf_wth-doc.obj-code,
                        INPUT d_fact-date,
                        INPUT j_fact-time,
                        INPUT buf_wth-doc.shift-date,
                        INPUT buf_wth-doc.shift-num,
                        INPUT par-talk
                      ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
          "Ошибка при установке дат, времен, смен в документе МЦ!" + {&new-line} +
          "fact-num  " + string(j_fact-num)  + {&new-line} +
          "fact-date " + string(d_fact-date) + {&new-line} +
          "fact-time " + string(j_fact-time, "HH:MM:SS") + {&new-line} +
          "shift-date" + string(buf_wth-doc.shift-date)  + {&new-line} +
          "shift-name" + string(buf_wth-doc.shift-name)  + {&new-line} +
          "shift-num " + string(buf_wth-doc.shift-num)   + {&new-line} +
          ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        run corr-date in this-procedure
            ( input buf_wth-doc.obj-type
            , input buf_wth-doc.obj-code
            , input buf_wth-doc.fact-date
            , input buf_wth-doc.shift-date
            , input buf_wth-doc.shift-num
            , input buf_wth-doc.shift-name
          ) no-error.
        IF ERROR-STATUS:ERROR THEN DO:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
          "Ошибка при проверке корректности дат в документе МЦ!" + {&new-line} +
          "fact-num  " + string(j_fact-num)  + {&new-line} +
          "fact-date " + string(d_fact-date) + {&new-line} +
          "fact-time " + string(j_fact-time, "HH:MM:SS") + {&new-line} +
          "shift-date" + string(buf_wth-doc.shift-date)  + {&new-line} +
          "shift-name" + string(buf_wth-doc.shift-name)  + {&new-line} +
          "shift-num " + string(buf_wth-doc.shift-num)   + {&new-line} +
          ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.

        { gbl/objat.i buf_wth-doc.obj-type buf_wth-doc.obj-code "'shift-on=request'" l-shift-on NO-ERROR }
        IF ERROR-STATUS:ERROR THEN DO:
          run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
          "Ошибка при запуске процедуры objat!" + {&new-line} +
          ERROR-STATUS:GET-MESSAGE( 1 )  +  {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.

        RUN factord IN THIS-PROCEDURE (
                                        INPUT d_fact-date,
                                        INPUT j_fact-time,
                                        INPUT j_fact-num,
                                        INPUT buf_wth-doc.shift-date,
                                        INPUT buf_wth-doc.shift-num,
                                        INPUT l-shift-on,
                                        OUTPUT d-fact-ord,
                                        OUTPUT d-shift-ord,
                                        OUTPUT day-end-ord
                                      ) NO-ERROR.
        IF ERROR-STATUS:ERROR OR
           d-fact-ord = ? OR
           d-fact-ord = 0 THEN DO:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
          "Ошибка при определении фактического номера МЦ!" + {&new-line} +
          "doc-code" + buf_wth-doc.doc-code + {&new-line} +
          "fact-date" + string( d_fact-date) + {&new-line} +
          "fact-time" + string(j_fact-time, "HH:MM:SS")  + {&new-line} +
          "fact-num"  + string(j_fact-num)  + {&new-line} +
          "shift-date" + string( buf_wth-doc.shift-date) + {&new-line} +
          "shift-name" +  string(buf_wth-doc.shift-name) + {&new-line} +
          "shift-num" +  string(buf_wth-doc.shift-num) + {&new-line} +
          "d-fact-order" + string(d-fact-ord) + {&new-line} +
          "d-shift-order" + string(d-shift-ord) + {&new-line} +
          "day-end-order" + string(day-end-ord) + {&new-line} +
          ERROR-STATUS:GET-MESSAGE( 1 )  +  {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
         /*Такой костыль вводится для правильного формирования отчетности на сменных объектах. Документы с партиями на сменном объекте должны закрываться датой смены*/
        if buf_wth-doc.shift-num <> 0 and buf_wth-doc.shift-date <> d_fact-date and  can-find(first buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code no-lock) then do:
           run waitfram-hide in this-procedure .
          var-mes =
          vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +    {&new-line} +
          "Документ перемещения СЕРИЙНЫХ МЦ на сменном объекте должен закрываться с фактической датой равной дате смены!" +  {&new-line} +     {&new-line} +
          "fact-date" + string( d_fact-date) + {&new-line} +
          "fact-time" + string(j_fact-time, "HH:MM:SS")  + {&new-line} +
          "fact-num"  + string(j_fact-num)  + {&new-line} +
          "shift-date" + string( buf_wth-doc.shift-date) + {&new-line} +
          "shift-name" +  string(buf_wth-doc.shift-name) + {&new-line} +
          "shift-num" +  string(buf_wth-doc.shift-num) + {&new-line} +
          ERROR-STATUS:GET-MESSAGE( 1 )  +  {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        end.
        if d_fact-date < v-obj-date
        then do:
          assign
            v-is-back-date = yes.
        end.
        else do:
          if l-shift-on then do:
            { gbl/curshift.i
              buf_wth-doc.obj-type
              buf_wth-doc.obj-code
              v-obj-shift-date
              v-obj-shift-num
              v-obj-shift-name
            }
            if not (buf_wth-doc.shift-date = v-obj-shift-date and
                    buf_wth-doc.shift-num  = v-obj-shift-num  )   then do:
              assign
              v-is-back-date = yes.
            end.
          end.
        end.
        if  v-is-back-date = yes   /* проверка прав на закрытие задним числом */
        then do:
          { gbl/chk-actg.i
            g#db-num
            g#userid
            {&action-head-code-main}
            'actn_wth-doc_create-back-shift':U
            {&cntxt-object}
            buf_wth-doc.host-code
            buf_wth-doc.obj-type
            buf_wth-doc.obj-code
            0
            0
            0
            true
            var-log
          }
          IF var-log <> YES THEN DO:
           UNDO Main-Block, RETURN ERROR .
          END.

        end.

        ASSIGN
        buf_wth-doc.status_    = {&fact}
        buf_wth-doc.fact-date  = d_fact-date
        buf_wth-doc.fact-time  = j_fact-time
        buf_wth-doc.fact-num   = j_fact-num
        buf_wth-doc.fact-order = d-fact-ord
        buf_wth-doc.is-back-date = v-is-back-date
        v-fact-date = d_fact-date
        .
        v-recalc-fact-ord = d-fact-ord - 0.0000000001.
        /*Проверка корректности номеров талонов при закрытии внеш. прихода
        или закрытии задним числом */
        if (buf_wth-doc.ext-doc-type = {&WDEDT_Inc_Ext}
          or buf_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext}
          or buf_wth-doc.ext-doc-type = {&WDEDT_Exch}
          or buf_wth-doc.ext-doc-type = {&WDEDT_Put_Sale}
          or v-is-back-date = yes)
          and (not g#news or (g#news and  g#db-num  = 0)) THEN DO:
          run str/chkwthcl.p ( input buf_wth-doc.doc-code
                              ,input p-file-name-err ) no-error.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes =
            vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
            "Ошибка при проверке корректности партий!" + {&new-line} +
            ERROR-STATUS:GET-MESSAGE( 1 )  +  {&new-line} + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
          end.
          else if return-value = 'warning':U then v-warning = yes.
        end.


        var-mes = vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
          "Ошибка при заполнении остатков и оборотов МЦ!"  + {&new-line} .
        run str/stkotwth.p ( INPUT RECID( buf_wth-doc ),
                             INPUT YES,
                             input yes,
                             input 0 ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
          run waitfram-hide in this-procedure .
          var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
          if par-talk then
          MESSAGE
          var-mes
          VIEW-AS ALERT-BOX ERROR.
          UNDO Main-Block, RETURN ERROR var-mes.
        END.
        var-mes = vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} .
        /*Создание связанных документов*/
        if (buf_wth-doc.obj-type = buf_wth-doc.cli-type and      /*Если внутриобъектный документ*/
           buf_wth-doc.obj-code = buf_wth-doc.cli-code and
           buf_wth-doc.inter_ = yes)
           or lookup(buf_wth-doc.ext-doc-type,{&WDEDT_OutDoc}) > 0
        then do:
       /* message 'Надо породить'.   */
          run str/wth-out.p (buffer buf_wth-doc, buffer buf_out_wth-doc) no-error.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes =
            vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
            "Не удалось создать связанный документ к документу" + {&space-char} + string(buf_wth-doc.doc-code).
            if par-talk then
            message
            var-mes  skip
            return-value
            view-as alert-box error .
            UNDO Main-Block, RETURN ERROR var-mes.
          end.
        end.
        /*Закрываются только внутриобъектные документы*/
        if buf_wth-doc.obj-type = buf_wth-doc.cli-type and
           buf_wth-doc.obj-code = buf_wth-doc.cli-code and
           buf_wth-doc.inter_ = yes then do:
          j_fact-num  = NEXT-VALUE( s-wth-fact, {&db-name_schema} ).
/*          assign
          buf_wth-doc.source-ref    = buf_out_wth-doc.doc-code
          buf_wth-doc.source-type   = {&wthd-wth-doc}
          . */
          RUN factord IN THIS-PROCEDURE (
                                          INPUT d_fact-date,
                                          INPUT j_fact-time,
                                          INPUT j_fact-num,
                                          INPUT buf_wth-doc.shift-date,
                                          INPUT buf_wth-doc.shift-num,
                                          INPUT l-shift-on,
                                          OUTPUT d-fact-ord,
                                          OUTPUT d-shift-ord,
                                          OUTPUT day-end-ord
                                        ) NO-ERROR.
          IF ERROR-STATUS:ERROR
          OR d-fact-ord = ?
          OR d-fact-ord = 0 THEN DO:
            run waitfram-hide in this-procedure .
            var-mes =
            vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&new-line} +
            "Ошибка при определении фактического номера МЦ!" + {&new-line} +
            "doc-code"   + buf_out_wth-doc.doc-code + {&new-line} +
            "fact-date"  + string( d_fact-date) + {&new-line} +
            "fact-time"  + string(j_fact-time, "HH:MM:SS")  + {&new-line} +
            "fact-num"   + string(j_fact-num) + {&new-line} +
            "shift-date" + string( buf_out_wth-doc.shift-date) + {&new-line} +
            "shift-name" +  string(buf_out_wth-doc.shift-name) + {&new-line} +
            "shift-num"  +  string(buf_out_wth-doc.shift-num) + {&new-line} +
            "d-fact-order" + string(d-fact-ord) + {&new-line} +
            "d-shift-order" + string(d-shift-ord) + {&new-line} +
            "day-end-order" + string(day-end-ord) + {&new-line} +
            ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
          END.

          ASSIGN
          buf_out_wth-doc.status_    = {&fact}
          buf_out_wth-doc.fact-date  = d_fact-date
          buf_out_wth-doc.fact-time  = j_fact-time
          buf_out_wth-doc.fact-num   = j_fact-num
          buf_out_wth-doc.fact-order = d-fact-ord
          buf_out_wth-doc.is-back-date = buf_wth-doc.is-back-date
          .
          run str/stkotwth.p ( INPUT RECID( buf_out_wth-doc ),
                               INPUT YES,
                               input yes,
                               input 0 ) NO-ERROR.
          IF ERROR-STATUS:ERROR THEN DO:
            run waitfram-hide in this-procedure .
            var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
          END.

        end.
        release buf_out_wth-doc no-error .
        if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
        end.

        if v-is-back-date then do:
          /* пересчет остатков по МЦ */
                    DEFINE VARIABLE v-today as date no-undo .
          DEFINE VARIABLE v-time as integer no-undo .
          run cur-time in this-procedure ( output v-today, output v-time).
          FOR EACH buf_wth-line NO-LOCK WHERE
          buf_wth-line.doc-code = buf_wth-doc.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
            run str/reclcwtl.p
              (input parobj-type
              ,input parobj-code
              ,input v-recalc-fact-ord
              ,input buf_wth-line.wth-code
              ,input no
              ,input {&c-wth-obj_close}
              ,input v-wth-doc-code
              ,input d_fact-date
              ,input g#db-num
              ,input g#userid
              ,input v-today
              ,input v-time
              ,input string(v-time, "HH:MM:SS")
              ) no-error .
            if error-status :error then do:
              var-mes = substitute("&1 &2 &3&4" +
                                    "Ошибка при пересчете остатков при закрытии док-та МЦ &5 задним числом&4"  +
                                    "&6&4&7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,error-status :get-message(1)
                                    , return-value ).
              if par-talk then
              MESSAGE
              var-mes
              VIEW-AS ALERT-BOX ERROR.
              UNDO Main-Block, RETURN ERROR var-mes.
            end.
          end.
        end.
        release buf_wth-doc no-error.
        if error-status:error then do:
            run waitfram-hide in this-procedure .
            var-mes = var-mes + ERROR-STATUS:GET-MESSAGE( 1 ) + {&new-line} + RETURN-VALUE.
            if par-talk then
            MESSAGE
            var-mes
            VIEW-AS ALERT-BOX ERROR.
            UNDO Main-Block, RETURN ERROR var-mes.
        end.

        end. /*if buf_wth-doc.status_ = permitted*/
      END. /*if var-status_ permitted or auto*/
      if var-status_ =  {&fact} THEN DO:
        run waitfram-hide in this-procedure .
        var-mes  = "Документ закрыт на ФАКТ! ".
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        UNDO Main-Block, RETURN ERROR var-mes.
      END.
  END. /**if par-mode = "+":U*/
  ELSE IF par-mode = "-":U THEN DO:
/*    var-mes = "Открыть документ нельзя!".
        run waitfram-hide in this-procedure .
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        UNDO Main-Block, RETURN ERROR var-mes.   */

    CASE buf_wth-doc.status_:
      when {&fact} then do:
        var-mes = "Нельзя открыть документ в статусе" +  {&space-char} + buf_wth-doc.status_.
        run waitfram-hide in this-procedure .
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        UNDO Main-Block, RETURN ERROR var-mes.

      end.
      when {&permitted} THEN DO:
        ASSIGN
        buf_wth-doc.status_ = {&wayb}.
      END.
      when {&wayb} THEN DO:
        var-mes = "Документ открыт!".
        run waitfram-hide in this-procedure .
        IF par-talk THEN DO:
          MESSAGE var-mes
          VIEW-AS ALERT-BOX ERROR.
        END.
        run waitfram-hide in this-procedure .
        UNDO Main-Block, RETURN ERROR var-mes.
      end.
    END CASE.
  END.
  run waitfram-hide in this-procedure .

END. /* Main-Block */
procedure corr-date:
define input parameter parobj-type    like ub.trn-doc.obj-type   no-undo.
define input parameter parobj-code    like ub.trn-doc.obj-code   no-undo.
define input parameter parfact-date   like ub.trn-doc.fact-date  no-undo.
define input parameter parshift-date  like ub.trn-doc.shift-date no-undo.
define input parameter parshift-num   like ub.trn-doc.shift-num  no-undo.
define input parameter parshift-name  like ub.trn-doc.shift-name no-undo.

define variable l-shift-on as logical no-undo .
define buffer bf_shift-obj for ub.shift-obj.
do on error undo, return error return-value :
{ gbl/objat.i
  parobj-type
  parobj-code
  "'shift-on=request'"
  l-shift-on
}
if l-shift-on = yes
then do:
  find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                bf_shift-obj.obj-code   = parobj-code   and
                                bf_shift-obj.shift-date = parshift-date and
                                bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
  if not available bf_shift-obj
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Нет смены &1 &2 на объекте &3 &4.", parshift-date, parshift-name + string(parshift-num), parobj-type, parobj-code).
  end.
  if bf_shift-obj.status_ <> {&sht-closed}  and
     bf_shift-obj.status_ <> {&sht-current}
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Смена &1 &2 на объекте &3 &4 имеет статус &5. Оформлять документы можно только в смене со статусом &6 или &7.",
                              bf_shift-obj.shift-date,
                              bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                              bf_shift-obj.obj-type,
                              bf_shift-obj.obj-code,
                              bf_shift-obj.status_,
                              {&sht-closed},
                              {&sht-current}).
  end.
  if parfact-date < bf_shift-obj.open-date
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Фактическая дата документа должна быть больше либо равна дате открытия смены. Фактическая дата: &1. Дата открытия смены &2 &3 на объекте &4 &5: &6.",
                             parfact-date,
                             bf_shift-obj.shift-date,
                             bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                             bf_shift-obj.obj-type,
                             bf_shift-obj.obj-code,
                             bf_shift-obj.open-date).
  end.
  if bf_shift-obj.status_ = {&sht-closed}
  then do:
    if parfact-date > bf_shift-obj.close-date
    then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute( "Фактическая дата документа должна быть меньше либо равна дате закрытия смены. Фактическая дата: &1. Дата закрытия смены &2 &3 на объекте &4 &5: &6.",
                               parfact-date,
                               bf_shift-obj.shift-date,
                               bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                               bf_shift-obj.obj-type,
                               bf_shift-obj.obj-code,
                               bf_shift-obj.close-date).
    end.
  end.
end.
end.
end procedure.

if v-warning then return 'warning':U.