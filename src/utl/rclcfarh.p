block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rclcfarh.p $
$Archive: utl/rclcfarh.p $

Полный пересчет всех финансовых архивов по всем фирмам

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ str/libofarh.i }
{ str/lib-farh.i }
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parrecalc-fo as   logical              no-undo.
define input parameter parlist-arh  as   character            no-undo.
on delete of arh-fin-doc-an                override do: end.
on delete of arh-fin-doc-an-nal            override do: end.
on delete of arh-fin-doc-an-nal-obj        override do: end.
on delete of arh-fin-doc-an-obj            override do: end.
on delete of arh-fin-doc-c-s-tax-nal-obj   override do: end.
on delete of arh-fin-doc-c-schet-tax-nal   override do: end.
on delete of arh-fin-doc-contr-s-nal-obj   override do: end.
on delete of arh-fin-doc-contr-s-tax-obj   override do: end.
on delete of arh-fin-doc-contr-schet       override do: end.
on delete of arh-fin-doc-contr-schet-nal   override do: end.
on delete of arh-fin-doc-contr-schet-obj   override do: end.
on delete of arh-fin-doc-contr-schet-tax   override do: end.
on delete of arh-fin-doc-s-tax-nal-obj     override do: end.
on delete of arh-fin-doc-schet             override do: end.
on delete of arh-fin-doc-schet-nal         override do: end.
on delete of arh-fin-doc-schet-nal-obj     override do: end.
on delete of arh-fin-doc-schet-obj         override do: end.
on delete of arh-fin-doc-schet-tax         override do: end.
on delete of arh-fin-doc-schet-tax-nal     override do: end.
on delete of arh-fin-doc-schet-tax-obj     override do: end.
on delete of arh-fin-ob-contr              override do: end.
on delete of arh-fin-ob-contr-obj          override do: end.
on write  of arh-fin-doc-an                override do: end.
on write  of arh-fin-doc-an-nal            override do: end.
on write  of arh-fin-doc-an-nal-obj        override do: end.
on write  of arh-fin-doc-an-obj            override do: end.
on write  of arh-fin-doc-c-s-tax-nal-obj   override do: end.
on write  of arh-fin-doc-c-schet-tax-nal   override do: end.
on write  of arh-fin-doc-contr-s-nal-obj   override do: end.
on write  of arh-fin-doc-contr-s-tax-obj   override do: end.
on write  of arh-fin-doc-contr-schet       override do: end.
on write  of arh-fin-doc-contr-schet-nal   override do: end.
on write  of arh-fin-doc-contr-schet-obj   override do: end.
on write  of arh-fin-doc-contr-schet-tax   override do: end.
on write  of arh-fin-doc-s-tax-nal-obj     override do: end.
on write  of arh-fin-doc-schet             override do: end.
on write  of arh-fin-doc-schet-nal         override do: end.
on write  of arh-fin-doc-schet-nal-obj     override do: end.
on write  of arh-fin-doc-schet-obj         override do: end.
on write  of arh-fin-doc-schet-tax         override do: end.
on write  of arh-fin-doc-schet-tax-nal     override do: end.
on write  of arh-fin-doc-schet-tax-obj     override do: end.
on write  of arh-fin-ob-contr              override do: end.
on write  of arh-fin-ob-contr-obj          override do: end.

if parlist-arh = "" then parlist-arh = "all" .
run del-for-one-firm  (input parhost-code, input parlist-arh) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) error-status:get-message(2) view-as alert-box error.
  return error.
end.
run calc-for-one-firm (input parhost-code, input parlist-arh) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) error-status:get-message(2) view-as alert-box error.
  return error.
end.
procedure calc-for-one-firm :
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parlist-arh  as   character            no-undo.
define buffer bf_fin-ob  for ub.fin-ob.
define buffer bf_fin-doc for ub.fin-doc.
define variable p-var as logical   no-undo .

do on error undo, return error return-value :
  if parrecalc-fo then do:
    run waitfram-show in this-procedure (substitute ("Расчитываем финансовые архивы финобязательств по фирме &1", parhost-code)).
    for each bf_fin-ob where bf_fin-ob.host-code = parhost-code and
                             bf_fin-ob.status_   = {&fact}      by bf_fin-ob.host-code by bf_fin-ob.status_ by bf_fin-ob.fact-order on error undo, return error return-value :
      { str/taskclco.i
        parhost-code
        bf_fin-ob.doc-code
        "'Полный пересчет архивов':u"
        "'close':u"
        no
        p-var
        no-error
      }
      if error-status:error then do:
        undo, return error substitute("Ошибка при пересчете архивов по ФО фирма &1 док-т &2:&3&4&3&5"
                                       , bf_fin-ob.host-code
                                       , bf_fin-ob.doc-code
                                       , {&new-line}
                                       , error-status:get-message(1)
                                       , return-value ).

      end.
    end.
  end.
  run waitfram-show in this-procedure (substitute ("Расчитываем финансовые архивы финдокументов по фирме &1", parhost-code)).
  for each bf_fin-doc where bf_fin-doc.host-code = parhost-code and
                            bf_fin-doc.status_   = {&fact}      by bf_fin-doc.host-code by bf_fin-doc.status_ by bf_fin-doc.fact-order on error undo, return error return-value :
    { str/taskclcd.i
      parhost-code
      bf_fin-doc.fin-doc-code
      parlist-arh
      "'Полный пересчет архивов':u"
      "'recalc':u"
      no-error
    }
      if error-status:error then do:
        undo, return error substitute("Ошибка при пересчете архиво по финдок-там фирма &1 вн.№ &2:&3&4&3&5"
                                       , bf_fin-doc.host-code
                                       , bf_fin-doc.fin-doc-code
                                       , {&new-line}
                                       , error-status:get-message(1)
                                       , return-value ).

      end.
  end.
end.
end procedure.

procedure del-for-one-firm :
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parlist-arh  as   character            no-undo.
define buffer bf_arh-fin-doc-an              for ub.arh-fin-doc-an             .
define buffer bf_arh-fin-doc-an-nal          for ub.arh-fin-doc-an-nal         .
define buffer bf_arh-fin-doc-an-nal-obj      for ub.arh-fin-doc-an-nal-obj     .
define buffer bf_arh-fin-doc-an-obj          for ub.arh-fin-doc-an-obj         .
define buffer bf_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer bf_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-schet-tax-nal.
define buffer bf_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer bf_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer bf_arh-fin-doc-contr-schet     for ub.arh-fin-doc-contr-schet    .
define buffer bf_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer bf_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer bf_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer bf_arh-fin-doc-s-tax-nal-obj   for ub.arh-fin-doc-s-tax-nal-obj  .
define buffer bf_arh-fin-doc-schet           for ub.arh-fin-doc-schet          .
define buffer bf_arh-fin-doc-schet-nal       for ub.arh-fin-doc-schet-nal      .
define buffer bf_arh-fin-doc-schet-nal-obj   for ub.arh-fin-doc-schet-nal-obj  .
define buffer bf_arh-fin-doc-schet-obj       for ub.arh-fin-doc-schet-obj      .
define buffer bf_arh-fin-doc-schet-tax       for ub.arh-fin-doc-schet-tax      .
define buffer bf_arh-fin-doc-schet-tax-nal   for ub.arh-fin-doc-schet-tax-nal  .
define buffer bf_arh-fin-doc-schet-tax-obj   for ub.arh-fin-doc-schet-tax-obj  .
define buffer bf_arh-fin-ob-contr            for ub.arh-fin-ob-contr           .
define buffer bf_arh-fin-ob-contr-obj        for ub.arh-fin-ob-contr-obj       .
do on error undo, return error return-value :
run waitfram-show in this-procedure (substitute ("Удаляем финансовые архивы по фирме &1", parhost-code)).
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-an},              parlist-arh) > 0 then do: for each bf_arh-fin-doc-an              where bf_arh-fin-doc-an             .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an             . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-an-nal},          parlist-arh) > 0 then do: for each bf_arh-fin-doc-an-nal          where bf_arh-fin-doc-an-nal         .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an-nal         . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-an-nal-obj},      parlist-arh) > 0 then do: for each bf_arh-fin-doc-an-nal-obj      where bf_arh-fin-doc-an-nal-obj     .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an-nal-obj     . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-an-obj},          parlist-arh) > 0 then do: for each bf_arh-fin-doc-an-obj          where bf_arh-fin-doc-an-obj         .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-an-obj         . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-c-s-tax-nal-obj}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-c-s-tax-nal-obj where bf_arh-fin-doc-c-s-tax-nal-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-c-s-tax-nal-obj. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-c-schet-tax-nal}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-c-schet-tax-nal where bf_arh-fin-doc-c-schet-tax-nal.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-c-schet-tax-nal. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-contr-s-nal-obj}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-s-nal-obj where bf_arh-fin-doc-contr-s-nal-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-s-nal-obj. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-contr-s-tax-obj}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-s-tax-obj where bf_arh-fin-doc-contr-s-tax-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-s-tax-obj. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-contr-schet},     parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet     where bf_arh-fin-doc-contr-schet    .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet    . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-contr-schet-nal}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet-nal where bf_arh-fin-doc-contr-schet-nal.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet-nal. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-contr-schet-obj}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet-obj where bf_arh-fin-doc-contr-schet-obj.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet-obj. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-contr-schet-tax}, parlist-arh) > 0 then do: for each bf_arh-fin-doc-contr-schet-tax where bf_arh-fin-doc-contr-schet-tax.host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-contr-schet-tax. end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-s-tax-nal-obj},   parlist-arh) > 0 then do: for each bf_arh-fin-doc-s-tax-nal-obj   where bf_arh-fin-doc-s-tax-nal-obj  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-s-tax-nal-obj  . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet},           parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet           where bf_arh-fin-doc-schet          .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet          . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet-nal},       parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-nal       where bf_arh-fin-doc-schet-nal      .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-nal      . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet-nal-obj},   parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-nal-obj   where bf_arh-fin-doc-schet-nal-obj  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-nal-obj  . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet-obj},       parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-obj       where bf_arh-fin-doc-schet-obj      .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-obj      . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet-tax},       parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-tax       where bf_arh-fin-doc-schet-tax      .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-tax      . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet-tax-nal},   parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-tax-nal   where bf_arh-fin-doc-schet-tax-nal  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-tax-nal  . end. end.
if parlist-arh = "all":u or lookup ({&table_arh-fin-doc-schet-tax-obj},   parlist-arh) > 0 then do: for each bf_arh-fin-doc-schet-tax-obj   where bf_arh-fin-doc-schet-tax-obj  .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-doc-schet-tax-obj  . end. end.
if parrecalc-fo then do:
  for each bf_arh-fin-ob-contr            where bf_arh-fin-ob-contr           .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-ob-contr           . end.
  for each bf_arh-fin-ob-contr-obj        where bf_arh-fin-ob-contr-obj       .host-code = parhost-code on error undo, return error return-value : delete bf_arh-fin-ob-contr-obj       . end.
end.
end.
end procedure.