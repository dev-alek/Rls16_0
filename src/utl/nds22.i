/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита для BTS-2056. Добавление ставки налога "11" на товарах с 01.01.2026 и смена стаки на группах товаров с "1" на "11".

Автор: Ростовцев А.М.
Дата создания: 16.09.2025
Author: 
Creation date: 

*/

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i }

define variable v-fact-date  as date no-undo init 01/01/2026.
define variable v-fact-order as decimal no-undo .

define buffer tax-rate-gds     for ub.tax-rate-gds.
define buffer buf_tax-rate-gds for ub.tax-rate-gds.
define buffer tax-rate-gds-grp for ub.tax-rate-gds-grp.
define buffer sys-ctrl         for ub.sys-ctrl.
define buffer buf_code         for ub.code.

&scop nds22 11

find first sys-ctrl no-lock.

run factord-end-day in this-procedure (
    input v-fact-date
   ,output v-fact-order).

for each tax-rate-gds no-lock where
         tax-rate-gds.tax-code  = 1
     and tax-rate-gds.rate-code = 1
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

  find first buf_tax-rate-gds exclusive-lock where
             buf_tax-rate-gds.gds-code = tax-rate-gds.gds-code
         and buf_tax-rate-gds.tax-code = tax-rate-gds.tax-code
         and buf_tax-rate-gds.host-code = tax-rate-gds.host-code
         and buf_tax-rate-gds.obj-type = tax-rate-gds.obj-type
         and buf_tax-rate-gds.obj-code = tax-rate-gds.obj-code
         and buf_tax-rate-gds.fact-order = v-fact-order
  no-error.
  if not avail buf_tax-rate-gds then
  do:
    create buf_tax-rate-gds.
    buffer-copy tax-rate-gds
      except chip-num corr-time corr-user-db-num corr-user-name corr-date
      to buf_tax-rate-gds
      assign
        buf_tax-rate-gds.fact-date = v-fact-date
        buf_tax-rate-gds.fact-order = v-fact-order
    .
  end.
  if buf_tax-rate-gds.rate-code <> {&nds22} then
    buf_tax-rate-gds.rate-code = {&nds22}.
end.

for each tax-rate-gds-grp exclusive-lock where
         tax-rate-gds-grp.tax-code  = 1
     and tax-rate-gds-grp.rate-code = 1
:
  tax-rate-gds-grp.rate-code = {&nds22}.
end.

/*run str/diallog.w ( this-procedure                            */
/*                  , this-procedure                            */
/*                  , 'str/sendalcd.p':U                        */
/*                  , ('yes' + {&delim-par} +                   */
/*                     'no' + {&delim-par} +                    */
/*                     'no' + {&delim-par} +                    */
/*                     'no' + {&delim-par}  +                   */
/*                     'no' + {&delim-par}                      */
/*                       )                                      */
/*                  , yes /*p-auto-go*/                         */
/*                  , 'Прервать':U                              */
/*                  , 'Отправка информации на кассу') no-error .*/

find first buf_code exclusive-lock where
           buf_code.parent = substitute("RunUtils&1&2",{&delim-par},sys-ctrl.db-num)
       and buf_code.code = "nds22" no-error.
if not avail buf_code then
do:
  find first buf_code no-lock where
             buf_code.parent = "RunUtil"
         and buf_code.code = string(sys-ctrl.db-num) no-error.
  if not avail buf_code then
  do:
    create buf_code.
    assign
      buf_code.parent = "RunUtils"
      buf_code.code   = string(sys-ctrl.db-num)
      buf_code.CodeName = "БД " + string(sys-ctrl.db-num)
      buf_code.export_  = yes
      buf_code.status_  = 0
      buf_code.nwsubd   = yes
    .
  end.
  create buf_code.
  assign
    buf_code.parent = substitute("RunUtils&1&2",{&delim-par},sys-ctrl.db-num)
    buf_code.code   = "nds22"
    buf_code.CodeName = vss-description
    buf_code.export_  = yes
    buf_code.status_  = 0
    buf_code.nwsubd   = yes
  .
end.
buf_code.CodeValue = entry(1,string(datetime(today, mtime)),".").

run utl\proc-msg.p (" Внимание! Проведено изменение ставки НДС у товаров с 20% на 22%. Необходимо передать информацию по налоговым ставкам и товарам на все кассы!") no-error.

