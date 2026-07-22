/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Толкач пересылки промоакций на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/19/06
Author: Bakhtadze Natalya
Creation date: 02/19/06

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
включает
define input parameter p-pos-type as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter action as char no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Толкач пересылки промоакций на кассу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

define variable p-pos-type    as character no-undo .
define variable p-obj-type    like ub.clients.obj-type no-undo .
define variable p-obj-code    like ub.clients.obj-code no-undo .
define variable action        as char      no-undo .
define variable recid-list    as character no-undo .

define var      choice        as integer   no-undo.
define var      rid-list      as char      no-undo.
define variable glog          as logical   no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define variable vSubs as class ibs.th.ref.promo.promoactionsubs no-undo .

assign
   p-pos-type = entry(1, p-parameter, {&delim-par})
   p-obj-type = entry(2, p-parameter, {&delim-par})
   p-obj-code = integer(entry(3, p-parameter, {&delim-par}))
   action     = entry(4, p-parameter, {&delim-par})
   recid-list = entry(5, p-parameter, {&delim-par})
no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

CASE p-pos-type:
  when {&cd-type-IBM-XML}
  then do:
    FIND FIRST ub.cash-desk NO-LOCK WHERE
              ub.cash-desk.db-num = g#db-num AND
              ub.cash-desk.pos-type = {&cd-type-IBM-XML}

              No-error.
    IF not avail(ub.cash-desk) then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!&1 промоакции реализуются только для POS &2"
                                , (if action = "U" then "Передача" else "Удаление")
                                , {&cd-type-IBM-XML}
                              )
                                              ).
      return.
    end.
    if action = "U"
    then do:
/*      { gbl/chk-actg.i                    */
/*        v-cntxt-db-num                    */
/*        v-cntxt-userid                    */
/*        {&action-head-code-main}          */
/*        'actn_cashdesk-payments_add-def':U*/
/*        {&cntxt-object}                   */
/*        v-host-code                       */
/*        p-obj-type                        */
/*        p-obj-code                        */
/*        0                                 */
/*        0                                 */
/*        0                                 */
/*        true                              */
/*        glog                              */
/*      }                                   */
    end.
    else do:
/*      { gbl/chk-actg.i                     */
/*        v-cntxt-db-num                     */
/*        v-cntxt-userid                     */
/*        {&action-head-code-main}           */
/*        'actn_cashdesk-payments_deletion':U*/
/*        {&cntxt-object}                    */
/*        v-host-code                        */
/*        p-obj-type                         */
/*        p-obj-code                         */
/*        0                                  */
/*        0                                  */
/*        0                                  */
/*        true                               */
/*        glog                               */
/*      }                                    */
    end.


/*    if NOT glog then return .*/
  end. /*ibm*/
END CASE.
if recid-list = "" then do:
run gbl/d-askw.w (input "Выбор промоакций для пересылки",
            input ( (if action = "U"
                      then "Переслать на кассу"
                      else "Удалить из кассы" ) + {&new-line} +
                              "информацию о промоакциях"
                              ),
            input "|",
            input "Все|Выборочно|Отказ от пересылки",
            input "||",
            input 1,
            input 3,
            output choice).
CASE choice:
   when 1 then 
      do:
      end.
   when 2 then 
      do:
         /*Интерфейс с промоакциями*/
    run ref/promo.p (input parparentproc,yes,output vSubs) no-error.
    if not valid-object (vSubs) then return.
      end.
   when 3 then 
      do:
         return.
      end.
END CASE.
end.
else do:
define variable v-promo-stor as class ibs.th.gbl.storage.promoactionstorage no-undo .

def var ii as integer no-undo .
v-promo-stor = new ibs.th.gbl.storage.promoactionstorage().
do ii = 0 to num-entries(recid-list,{&comma-char}):
for each ub.PromoAction no-lock where recid(ub.PromoAction) = integer(entry(ii,recid-list,{&comma-char})):
   v-promo-stor:getpromoactionsubs(input-output vSubs,ub.PromoAction.db-num,ub.PromoAction.id, p-obj-code).
end.  
end.
end.
CASE p-pos-type:
  when  {&cd-type-IBm-XML}
  then do:
    run str/send-promo.p (
                    input parparentproc
                   ,input p-parent-handle
                   ,input p-log-handle
                   ,input p-obj-code
                   ,input action
                   ,input (if not valid-object (vSubs) and recid-list = ""
                           then 0
                           else 1)
                  , input vSubs
                  , input log-file-name
                  , input-output v-view-log
                  ) no-error .
  end.
end CASE.

  finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
