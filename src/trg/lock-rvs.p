block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокировка и расблокировка товаров по документу сверки

Автор: Перваков Михаил Сергеевич
Дата создания: 11/10/00
Author: Mikhail Pervakov
Creation date: 11/10/00

Параметры:
p-rvs-code  - код документа сверки
p-action    - действие, которое необходимо выполнить
  Возможные значения указаны в файле lockplgd.p
p-no-check-rvs-code - сверка, которая может находится в статусе разрешен,
                      при разблокировке товаров
*/

define input parameter p-rvs-code          as character no-undo .
define input parameter p-action            as character no-undo .
define input parameter p-no-check-rvs-code as character no-undo .
define input parameter p-is-berate         as logical   no-undo .

define variable v-auto as logical no-undo.


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Блокировка и расблокировка товаров по документу сверки":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block :
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first ub.rvs-doc no-lock
    where ub.rvs-doc.rvs-code = p-rvs-code
    no-error .
  if not available ub.rvs-doc then do:
    if p-is-berate = yes then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ сверки" skip
        "Документ сверки" p-rvs-code skip
      view-as alert-box error .
    end.
    undo main-block, return error substitute( '&1: не найден документ сверки "&2"', vss-workfile, p-rvs-code ) .
  end.


    find first  doc-attr where 
        doc-attr.doc-code = rvs-doc.rvs-code and 
        doc-attr.attr-code = "rvs-auto" and 
        doc-attr.attr-value = "Yes" no-lock no-error.
    if available doc-attr then 
    do: 
        v-auto = yes .
    end.
                
    if v-auto <> yes then 
    do: 
        for each ub.rvs-line no-lock
            where ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code
            on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
            :
            if num-entries(ub.rvs-doc.rvs-code, "-") = 3 /* Посекционные сверки (для коммисионного приёма) */
            and (p-action begins "assign-rvs-on=" or p-action begins "check-rvs-on=")
            then do :
              if p-action begins "assign-rvs-on="
              then do :
                for first ub.pl-gds no-lock where ub.pl-gds.obj-type = ub.rvs-line.obj-type
                                              and ub.pl-gds.obj-code = ub.rvs-line.obj-code
                                              and ub.pl-gds.pl-code  = ub.rvs-line.pl-code
                                              and ub.pl-gds.gds-code = ub.rvs-line.gds-code
                                              and ub.pl-gds.rvs-on  <> logical(entry(2, p-action, "="))
                :
                  if p-no-check-rvs-code = ? then p-no-check-rvs-code = "" .
                  p-no-check-rvs-code = p-no-check-rvs-code + "," + ub.rvs-doc.rvs-code .
                  p-no-check-rvs-code = trim(p-no-check-rvs-code, ",") .
                  run trg/lockplgd.p
                      ( input ub.rvs-line.obj-type    /* p-obj-type          */
                      , input ub.rvs-line.obj-code    /* p-obj-code          */
                      , input ub.rvs-line.pl-code     /* p-pl-code           */
                      , input ub.rvs-line.gds-code    /* p-gds-code          */
                      , input p-action                /* p-action            */
                      , input p-no-check-rvs-code     /* p-no-check-rvs-code */
                      , input p-is-berate             /* выводить сообщения  */
                      ) .
                end .
              end .
              if p-action begins "check-rvs-on="
              then do :
                for first ub.pl-gds no-lock where ub.pl-gds.obj-type = ub.rvs-line.obj-type
                                              and ub.pl-gds.obj-code = ub.rvs-line.obj-code
                                              and ub.pl-gds.pl-code  = ub.rvs-line.pl-code
                                              and ub.pl-gds.gds-code = ub.rvs-line.gds-code
                                              and ub.pl-gds.rvs-on   = logical(entry(2, p-action, "="))
                :
                  run trg/lockplgd.p
                      ( input ub.rvs-line.obj-type    /* p-obj-type          */
                      , input ub.rvs-line.obj-code    /* p-obj-code          */
                      , input ub.rvs-line.pl-code     /* p-pl-code           */
                      , input ub.rvs-line.gds-code    /* p-gds-code          */
                      , input p-action                /* p-action            */
                      , input p-no-check-rvs-code     /* p-no-check-rvs-code */
                      , input p-is-berate             /* выводить сообщения  */
                      ) .
                end .
              end .
            end .
            else do :
              run trg/lockplgd.p
                  ( input ub.rvs-line.obj-type    /* p-obj-type          */
                  , input ub.rvs-line.obj-code    /* p-obj-code          */
                  , input ub.rvs-line.pl-code     /* p-pl-code           */
                  , input ub.rvs-line.gds-code    /* p-gds-code          */
                  , input p-action                /* p-action            */
                  , input p-no-check-rvs-code     /* p-no-check-rvs-code */
                  , input p-is-berate             /* выводить сообщения  */
                  ) .
            end .
        end.
    end.
end.