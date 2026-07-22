/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Утилита для BTS-2205.

Автор: Ростовцев А.М.
Дата создания: 13.01.2026
Author: 
Creation date: 

*/

define variable v-fact-date  as date no-undo init 01/01/2026.
define variable v-fact-order as decimal no-undo .

define buffer tax-rate-gds      for ub.tax-rate-gds.
define buffer buf_tax-rate-gds  for ub.tax-rate-gds.
define buffer last_tax-rate-gds for ub.tax-rate-gds.
define buffer curr_tax-rate-gds for ub.tax-rate-gds.
define buffer tax-rate-gds-grp  for ub.tax-rate-gds-grp.
define buffer sys-ctrl          for ub.sys-ctrl.
define buffer buf_code          for ub.code.

on delete of ub.tax-rate-gds override do: end.

&scop nds22 11

find first sys-ctrl no-lock.

run factord-end-day in this-procedure (
    input v-fact-date
   ,output v-fact-order).

for each tax-rate-gds no-lock where
         tax-rate-gds.tax-code  = 1
     and tax-rate-gds.rate-code = 1
     and tax-rate-gds.fact-order < v-fact-order
     break by tax-rate-gds.gds-code by tax-rate-gds.fact-order
/*     and tax-rate-gds.gds-code  = 142128*/
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

  /* проверим, что это была последняя ставка для товара до мсены на  код НДС 11 */
  if last-of(tax-rate-gds.gds-code) then
  do:
    for last last_tax-rate-gds no-lock where
             last_tax-rate-gds.gds-code  = tax-rate-gds.gds-code
         and last_tax-rate-gds.tax-code   = tax-rate-gds.tax-code
         and last_tax-rate-gds.host-code  = tax-rate-gds.host-code
         and last_tax-rate-gds.obj-type   = tax-rate-gds.obj-type
         and last_tax-rate-gds.obj-code   = tax-rate-gds.obj-code
         and last_tax-rate-gds.fact-order > tax-rate-gds.fact-order
         and last_tax-rate-gds.fact-order < v-fact-order
         and last_tax-rate-gds.rate-code <> 11
    :
      find first buf_tax-rate-gds exclusive-lock where
                 buf_tax-rate-gds.gds-code = tax-rate-gds.gds-code
             and buf_tax-rate-gds.tax-code = tax-rate-gds.tax-code
             and buf_tax-rate-gds.rate-code = 11
             and buf_tax-rate-gds.host-code = tax-rate-gds.host-code
             and buf_tax-rate-gds.obj-type = tax-rate-gds.obj-type
             and buf_tax-rate-gds.obj-code = tax-rate-gds.obj-code
             and buf_tax-rate-gds.fact-order = v-fact-order
      no-error.
      if avail buf_tax-rate-gds then 
      do:
/*&if defined(mode) <> 0 &then    */
/*        delete buf_tax-rate-gds.*/
/*&endif                          */
        for last curr_tax-rate-gds no-lock where
                 curr_tax-rate-gds.gds-code  = tax-rate-gds.gds-code
             and curr_tax-rate-gds.tax-code   = tax-rate-gds.tax-code
             and curr_tax-rate-gds.host-code  = tax-rate-gds.host-code
             and curr_tax-rate-gds.obj-type   = tax-rate-gds.obj-type
             and curr_tax-rate-gds.obj-code   = tax-rate-gds.obj-code
        :
        
          put stream sProt unformatted 
            "result;" string(sys-ctrl.db-num) ";" 
            string(tax-rate-gds.gds-code) ";"
            string(last_tax-rate-gds.rate-code) ";"
            string(curr_tax-rate-gds.rate-code) 
            skip
          .
        end.
      end.
    end.
  end.
end.

/*&if defined(mode) <> 0 &then                                  */
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
/*&endif                                                        */

