block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на yдаление пред финансового обязательства

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 02/10/04 12:46

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-ob-before.

define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Триггер на yдаление пред финансового обязательства ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-ob-before.before-code, ub.fin-ob-before.host-code) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
/* проверка на наличие таких же фо по накладной */
define buffer other_fin-ob for fin-ob.
define buffer other_fin-ob-before for fin-ob-before.
define buffer other_fin-ob-trn for fin-ob-trn.

define variable v-trn-code as character no-undo .
define variable v-fin-ob as character no-undo .
define variable v-col-fin-ob as integer no-undo .
define variable v-type-pay-orig  as character no-undo .
define variable v-type-pay       as character no-undo .
define variable v-pay as character no-undo .
define variable v-ok as logical no-undo .
define variable v-not-flag as logical no-undo .
define variable v-galki as logical no-undo .

find first contract no-lock where  contract.contract-code = fin-ob-before.contract-code no-error .

v-ok = true .

if lookup ( contract.usl-opl , {&o-postavka} ) > 0
   then
     assign
      v-type-pay-orig = "по поставке"
      v-pay = {&o-postavka}
     .
   else
     assign
        v-type-pay-orig = "по реализации"
        v-pay = {&o-realiz}
     .

for each fin-ob-trn no-lock where fin-ob-trn.doc-code  = fin-ob-before.before-code
    on error undo, return error :
    v-trn-code = fin-ob-trn.trn-doc-code.
    v-fin-ob =  "" .
    v-col-fin-ob =  0 .
        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob-before.before-code ,
            first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + " ФО " + string(other_fin-ob-trn.doc-code) + "," .
            v-col-fin-ob = v-col-fin-ob + 1.
        end. /* for each */

        for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code  = v-trn-code and
                                                other_fin-ob-trn.doc-code      <> fin-ob-before.before-code ,
            first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
              first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                             lookup( contract.usl-opl , v-pay ) > 0
            on error undo, return error :
            v-fin-ob = v-fin-ob + "  ПФО " + string(other_fin-ob-trn.doc-code).
            v-col-fin-ob = v-col-fin-ob + 1.
        end. /* for each */



    if v-col-fin-ob > 0 then
    message "ПредФинОбязательство было создано по накладной  " v-trn-code skip
             "Тип оплаты : " v-type-pay-orig skip
             "По этой же накладной было одновременно создано еще : " v-col-fin-ob   skip
             "Вн. номера : " v-fin-ob                                     skip
             "По накладной ФО и ПФО автоматически генерируются один раз "  skip
             "   по одному типу оплаты (поставке или реализации)       "  skip
             " "                                                          skip  skip
             "( ДА  - удалить ПФО " fin-ob-before.before-code " , "  skip
             "      без возможности повторной автоматической генерации по накладной "  skip
             " НЕТ - не удалять ) "
             view-as alert-box question
             buttons yes-no
             title "Вопрос"
             update v-ok
             .

end. /* for each */

if v-ok = false then   UNDO , RETURN ERROR.

/*-----------------------------------------------------------------------------------------------------------------------*/

    for each fin-ob-tax-before where
        fin-ob-tax-before.before-code  = fin-ob-before.before-code  and
        fin-ob-tax-before.host-code    = fin-ob-before.host-code
        on error undo main-block, return error
        :
          delete  fin-ob-tax-before.
    end.

    for each fin-ob-trn no-lock where
        fin-ob-trn.doc-code  = fin-ob-before.before-code  and
        fin-ob-trn.host-code = fin-ob-before.host-code
        on error undo main-block, return error
        :
        for each trn-doc  exclusive-lock   where
          trn-doc.doc-code = fin-ob-trn.trn-doc-code
            on error undo main-block, return error  :
          /*  проверка - есть ли другие ФО и ПФО по этой накладной */
            v-galki = true .
                for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                        other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                    first other_fin-ob no-lock where other_fin-ob.doc-code  = other_fin-ob-trn.doc-code ,
                      first contract   no-lock where contract.contract-code = other_fin-ob.contract-code and
                                                    lookup( contract.usl-opl , v-pay ) > 0
                      on error undo, return error :
                      /* есть - зачищать галки в накладных нельзя */
                      v-galki = false .
                end. /* for each */

                for each other_fin-ob-trn no-lock where other_fin-ob-trn.trn-doc-code =  fin-ob-trn.trn-doc-code and
                                                        other_fin-ob-trn.doc-code     <>  fin-ob-trn.doc-code ,
                    first other_fin-ob-before no-lock where other_fin-ob-before.before-code  = other_fin-ob-trn.doc-code ,
                      first contract   no-lock where contract.contract-code = other_fin-ob-before.contract-code and
                                                    lookup( contract.usl-opl , v-pay ) > 0
                      on error undo, return error :
                      /* есть - зачищать галки в накладных нельзя */
                      v-galki = false .
                end. /* for each */

                  if v-galki = true  then do:
                      if v-pay = {&o-realiz} then do:
                          assign
                              trn-doc.cr-expfo    = false
                              trn-doc.expfo-date  = 01/01/1990
                          no-error .
                      end.
                      else do:
                          assign
                              trn-doc.cr-incfo    = false
                              trn-doc.incfo-date  = 01/01/1990
                          no-error .
                      end.
                        if error-status :error then
                        message vss-workfile vss-revision vss-description skip
                            "Ошибка корректировки накладной" skip
                            error-status :get-message(1)
                            view-as alert-box information .
                      if trn-doc.cr-expfo = false and
                         trn-doc.cr-incfo = false then do:
                        assign
                          trn-doc.cr-incorexpfo = false.
                      end.
                  end.
        end. /* for each trn-doc */

    end.



    for each fin-ob-trn where
        fin-ob-trn.doc-code  = fin-ob-before.before-code  and
        fin-ob-trn.host-code = fin-ob-before.host-code
        on error undo main-block, return error
        :
          delete  fin-ob-trn.
    end.
    for each fin-gds-part where
        fin-gds-part.fin-ob-code  = fin-ob-before.before-code  and
        fin-gds-part.host-code    = fin-ob-before.host-code
        on error undo main-block, return error
        :
          delete  fin-gds-part.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-ob-before}
        , input ( buffer ub.fin-ob-before:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.