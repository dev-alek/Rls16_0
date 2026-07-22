/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание записи в таблице bb-list по найденным буферам bar-code и prod-bc
для совместимости со стандартными кассовыми инклюдами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/10/05
Author: Bakhtadze Natalya
Creation date: 02/10/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure asc-gds :
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .

DEFINE parameter buffer loc-goods for {1}.
DEFINE parameter buffer loc-bar-code for ub.bar-code.
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable IBM-good-code as character no-undo .
define variable bar_code as character no-undo .
define buffer buf_prod-bc for ub.prod-bc.



  do
  on error undo, return error
  :
    if loc-prod-bc <> "":U and loc-prod-bc <> ? then do:
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-code = loc-bar-code.b-code
           and  buf_prod-bc.b-str = loc-prod-bc no-error.
      run ex-bbc in this-procedure ( input rs-list-method
                                    ,input rs-status
                                    ,input line-mode
                                    ,input l-empty-scale
                                    ,input loc-prod-bc
                                    ,input no
                                    ,buffer loc-bar-code
                                    ,buffer buf_prod-bc).
    end.
    else do:
      if  (LOOKUP( {&weight}, loc-units.type ) = 0 or v-notcd)
      or loc-goods.unit-base <> loc-bar-code.unit-cli then do:
        if (temp-shop.cd-loc-base and loc-bar-code.unit-cli = loc-goods.unit-base)
        or (temp-shop.cd-loc-alt  and loc-bar-code.unit-cli <> loc-goods.unit-base)
        then
        run ex-bbc in this-procedure ( input rs-list-method
                                      ,input rs-status
                                      ,input line-mode
                                      ,input l-empty-scale
                                      ,input "":U
                                      ,input no
                                      ,buffer loc-bar-code
                                      ,buffer buf_prod-bc).
        if temp-shop.cd-bc-base
        and loc-bar-code.unit-cli = loc-goods.unit-base then do:
          RUN gen-bc( input loc-bar-code.b-code, output bar_code ).
          IBM-good-code  = trim( bar_code ) .
          run ex-bbc in this-procedure ( input rs-list-method
                                        ,input rs-status
                                        ,input line-mode
                                        ,input l-empty-scale
                                        ,input IBM-good-code
                                        ,input yes
                                        ,buffer loc-bar-code
                                        ,buffer buf_prod-bc).
        end.
        if temp-shop.cd-bc-alt
        and loc-bar-code.unit-cli <> loc-goods.unit-base
        then  do:
          RUN gen-bc( input loc-bar-code.b-code, output bar_code ).
          IBM-good-code  = trim( bar_code ) .
          run ex-bbc in this-procedure ( input rs-list-method
                                        ,input rs-status
                                        ,input line-mode
                                        ,input l-empty-scale
                                        ,input IBM-good-code
                                        ,input yes
                                        ,buffer loc-bar-code
                                        ,buffer buf_prod-bc).
        end.
      end.
    end.
  end.

end procedure. /* asc-gds */