/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура закрытия  фин обязательств

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 02/13/04 3:46

*/

{ trg/factord.i }
procedure proc-close-one-fin-ob :
 do
 on error undo, return error return-value
 :
define input parameter p-recid  as recid no-undo .

define buffer buf_fin-liab-fo   for ub.fin-ob .
define buffer buf_fin-ob-before for ub.fin-ob-before .
define buffer ff_fin-ob-trn     for ub.fin-ob-trn  .
define variable  v-fact-date            as date    no-undo . /* фактическая дата закрытия документа  */
define variable  v-fact-time            as integer no-undo . /* фактическое время закрытия документа */
define variable  v-fact-num             as integer no-undo . /* фактический номер закрытия документа */
define variable  v-shift-date           as date    no-undo . /* дата начала смены для документа      */
define variable  v-shift-num            as integer no-undo . /* порядок смены для документа          */
define variable  v-shift-on             as logical no-undo . /* на объекте включены смены            */
define variable  v-fact-order           as decimal no-undo . /* порядковый номер закрытия документа  */
define variable  v-shift-end-fact-order as decimal no-undo . /* номер конца смены                    */
define variable  v-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */
define variable  var-fo-fact as logical   no-undo .

define variable  par-type         as character no-undo .
define variable  v-value-date     as date   no-undo .
define variable  v-value-decimal  as decimal   no-undo .
define variable  v-value-integer  as integer   no-undo .
define variable  v-value-logical  as logical   no-undo .
define variable v-found           as logical   no-undo .
define variable v-value-character as character no-undo .
define variable v-i as integer   no-undo .
define variable p-recalc     as logical   no-undo .
define variable p-recalc2    as logical   no-undo .
define buffer recalc_fin-ob for ub.fin-ob  .

run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-fin-global} ,
  input   'fo-fact'  ,
  output  v-value-character ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  var-fo-fact  ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
if error-status :error then var-fo-fact = false .
find first buf_fin-liab-fo no-lock where recid(buf_fin-liab-fo) = p-recid  no-error .
release buf_fin-liab-fo no-error .


find first  buf_fin-liab-fo  exclusive-lock  where recid(buf_fin-liab-fo) = p-recid  no-error .
if not available buf_fin-liab-fo then return error .

   if buf_fin-liab-fo.pay-date = ? then do:
      message "Финансовое обязательство : " buf_fin-liab-fo.prn-doc-code  skip
              "не задана дата платежа!"  skip
              "Закрывать ФО ?"
              view-as alert-box question
              buttons yes-no
              update v-ok as log
            .
      if v-ok = false then  return.
   end.

   if buf_fin-liab-fo.status_ = {&fact} then do:
      message "Финансовое обязательство " buf_fin-liab-fo.prn-doc-code  " уже закрыто до ФАКТ".
      return.
   end.

  run cur-time
      ( output v-fact-date
      , output v-fact-time
      ).
  if var-fo-fact = yes then do:
     v-fact-date = 01/01/1900 .
     v-i = 0 .

     for each ff_fin-ob-trn no-lock  where
              ff_fin-ob-trn.doc-code  =  buf_fin-liab-fo.doc-code and
              ff_fin-ob-trn.host-code =  buf_fin-liab-fo.host-code
            :
            v-i = v-i + 1.
           case ff_fin-ob-trn.doc-type  :
           when "spc" then do:
              run cur-time
                  ( output v-fact-date
                  , output v-fact-time
                  ).
           end.

           when "order" then do:
                find first ub.ord-doc   no-lock where ub.ord-doc.doc-code   =  ff_fin-ob-trn.trn-doc-code no-error .
                if available ub.ord-doc then do:
                    if v-fact-date < ub.ord-doc.fact-date then v-fact-date = ub.ord-doc.fact-date.
                end.
           end.
           when "rcv" then do:
              run cur-time
                  ( output v-fact-date
                  , output v-fact-time
                  ).
           end.
           when "add" then do:
              run cur-time
                  ( output v-fact-date
                  , output v-fact-time
                  ).
           end.
           otherwise do:
                find first ub.trn-doc   no-lock where ub.trn-doc.doc-code   =  ff_fin-ob-trn.trn-doc-code no-error .
                if available ub.trn-doc then do:
                    if v-fact-date < ub.trn-doc.fact-date then v-fact-date = ub.trn-doc.fact-date.
                end.
                find first ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code =  ff_fin-ob-trn.trn-doc-code
                                                  and ub.c-trn-doc.is-del = true   no-error .
                if available ub.c-trn-doc then do:
                    if v-fact-date < ub.c-trn-doc.corr-date then v-fact-date = ub.c-trn-doc.corr-date.
                end.
           end.
           end case.
     end.
     if v-i = 0  then do:
          run cur-time
              ( output v-fact-date
              , output v-fact-time
              ).
     end.
  end.
  assign
      v-fact-num   = next-value ( s-fin-ob-fact, {&db-name_schema} )
      v-shift-date = ?
      v-shift-num  = ?
      v-shift-on   = false
  .

   run factord in this-procedure (
       input  v-fact-date
      ,input  v-fact-time
      ,input  v-fact-num
      ,input  v-shift-date
      ,input  v-shift-num
      ,input  v-shift-on
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) .

   assign
    buf_fin-liab-fo.fact-order       =  v-fact-order
    buf_fin-liab-fo.status_          =  {&fin-fact}
    buf_fin-liab-fo.fact-date        =  v-fact-date
    buf_fin-liab-fo.user-db-num-fact =  g#db-num
    buf_fin-liab-fo.user-name-fact   =  g#userid
   .
   /* пересчитаем баланс по договору */
   run str/calc-bal.p (input "finob", input yes, input buf_fin-liab-fo.doc-type, input buf_fin-liab-fo.host-code, input buf_fin-liab-fo.contract-code, input buf_fin-liab-fo.sum-contract, input buf_fin-liab-fo.sum-rubl, input buf_fin-liab-fo.sum-base) .

   /* для генерации счетов-фактур */
   find first ub.contract no-lock
        where ub.contract.contract-code = buf_fin-liab-fo.contract-code and
              ub.contract.host-code     = buf_fin-liab-fo.host-code
              no-error.
   if available ub.contract then do:
     if ( ub.contract.gen-factur = 2 or
          ub.contract.gen-factur = 12 or
          ub.contract.gen-factur = 102 or
          ub.contract.gen-factur = 112) then
       assign
         buf_fin-liab-fo.need-factur = 1
         .
   end.

   for each buf_fin-ob-before  exclusive-lock  where
            buf_fin-ob-before.host-code = buf_fin-liab-fo.host-code and
            buf_fin-ob-before.doc-code  = buf_fin-liab-fo.doc-code and
            buf_fin-ob-before.status_   = {&fin-gen}
            on error undo, return error :
        assign
          buf_fin-ob-before.fact-order       =  v-fact-order
          buf_fin-ob-before.status_          =  {&fin-fact}
          buf_fin-ob-before.fact-date        =  v-fact-date
          buf_fin-ob-before.user-db-num-fact =  g#db-num
          buf_fin-ob-before.user-name-fact   =  g#userid
        .
   end. /* for each */

      /* изменим в архиве */

      { str/taskclco.i
        buf_fin-liab-fo.host-code
        buf_fin-liab-fo.doc-code
        g#userid
        "'close':u"
        yes
        p-recalc
        no-error }
        if error-status :error then do:
          message
            "При обновлении архива обнаружена ошибка " skip
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error "Ошибка расчета архива" .
        end.
        if p-recalc then do:
              for each recalc_fin-ob no-lock where
                       recalc_fin-ob.host-code = buf_fin-liab-fo.host-code  and
                       recalc_fin-ob.status_   = {&fin-fact}  and
                       recalc_fin-ob.fact-order > buf_fin-liab-fo.fact-order
                       break by recalc_fin-ob.fact-order
                  :
                  { str/taskclco.i
                    recalc_fin-ob.host-code
                    recalc_fin-ob.doc-code
                    g#userid
                    "'close':u"
                    yes
                    p-recalc2
                    no-error }
                    if error-status :error then do:
                      message
                      "При персчете архива обнаружена ошибка " skip
                      return-value skip
                      error-status :get-message(1) skip
                      view-as alert-box error .
                      undo, return error "Ошибка расчета архива" .
                    end.
              end.
        end.


 end. /* do */
end procedure. /* proc-close-one */