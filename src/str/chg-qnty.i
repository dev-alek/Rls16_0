/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет фактического количества в документе расхода

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/



&if "{1}" = "fact"
&then
define buffer out-dtl for ub.gds-dtl.
&endif
if available ub.gds-dtl then do:
    prt-rec = recid(ub.gds-dtl).
    if dec(ub.gds-dtl.{1}-qnty:screen-value in browse {&browse-name}) = ?
    &if "{1}" = "doc" &then
       or dec(ub.gds-dtl.{1}-qnty:screen-value in browse {&browse-name}) = 0
    &endif
    then do:
      message "Не указано количество.".
      disp ub.gds-dtl.{1}-qnty with browse {&browse-name}.
      return no-apply.
    end.
    &if "{1}" = "fact"
    &then
    if (can-do ({&income_return}, t-doc.doc-type)
       and t-doc.internal
       and ( ub.gds-prt.upper-code = ub.goods.prt-root /* выключены шкалы на тек. объекте */ or
         can-find (out-dtl where out-dtl.doc-code = t-doc.out-code and
                                              out-dtl.artic = ub.gds-dtl.artic and
                                              out-dtl.prod-type = ub.gds-dtl.prod-type and
                                              out-dtl.prod-code = ub.gds-dtl.prod-code and
                                              out-dtl.prt-code = ub.gds-dtl.prt-code no-lock)) /* включены и на объекте-источнике */
        or not can-do ({&income_return}, t-doc.doc-type)
        or (t-doc.doc-type = {&return} and not t-doc.internal)
        )
        and input browse {&browse-name} ub.gds-dtl.fact-qnty > ub.gds-dtl.doc-qnty then do:
      message "Фактическое количество товара не может быть больше количества по накладной.".
      disp ub.gds-dtl.fact-qnty with browse {&browse-name}.
      return no-apply.
    end.
    &endif
    find ub.units where ub.units.unit-name = ub.goods.unit-base no-lock.
    if lookup({&serial}, ub.units.type) > 0 then do:
       message "В серийном товаре нельзя редактировать количество".
       disp ub.gds-dtl.{1}-qnty with browse {&browse-name}.
       return no-apply.
    end.
    find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                       and ub.doc-line.prod-code = ub.gds-dtl.prod-code
                       and ub.doc-line.prod-type = ub.gds-dtl.prod-type
                       and ub.doc-line.artic         = ub.gds-dtl.artic no-lock no-error.
    find ub.goods where ub.goods.prod-code = ub.gds-dtl.prod-code
               and ub.goods.prod-type = ub.gds-dtl.prod-type
               and ub.goods.artic     = ub.gds-dtl.artic no-lock.
    run str/out-add.p (parparentproc,
                   recid(t-doc),
                   recid(ub.doc-line),
                   recid(ub.gds-dtl),
                   recid(ub.goods),
                   "ch-{1}-qnty",
                   string(input browse {&browse-name} ub.gds-dtl.{1}-qnty)) no-error.
    if error-status:error then return no-apply.
    if query {&browse-name}:GET-BUFFER-HANDLE (1):NAME = "gds-dtl" then
        prt-rec = recid(ub.gds-dtl).
    else
        prt-rec = recid(ub.doc-line).
    run ui-on("line").
    reposition {&browse-name} to recid prt-rec.
end.