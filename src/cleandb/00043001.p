block-level on error undo, throw.
/*

Чистка УБД. Расходная зона партий

Автор: Ростовцев Александр
Дата создания: 05/11/2025
Author: Aleksandr Rostovtsev
Creation date: 11/05/25
*/

&scop Tables Партии. расходная зона
/*&scop Tables parts   */

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00043000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define buffer trn-doc    for ub.trn-doc .
define buffer parts      for ub.parts .
define buffer buf_parts  for ub.parts .
define buffer free_parts for ub.parts .

on delete of ub.parts         override do: end.

for each parts no-lock where
         parts.out-code  = {&output-code}
     and (parts.fact-date < vardate-actual-docs 
          or parts.fact-date = ?)
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  find first trn-doc no-lock where
             trn-doc.doc-code = parts.in-code
  no-error.
  if not avail trn-doc and 
     not can-find(first free_parts where
                        free_parts.obj-type  = parts.obj-type
                    and free_parts.obj-code  = parts.obj-code
                    and free_parts.artic     = parts.artic
                    and free_parts.prod-type = parts.prod-type
                    and free_parts.prod-code = parts.prod-code
                    and free_parts.in-code   = parts.in-code
                    and free_parts.out-code  = {&free-code}
                    and free_parts.part-code = parts.part-code
                    and free_parts.fact-qnty > 0) then
  do:
    /* удяляем, если уже удален док-т прихода и партия свободной зоны по этой партии уже обнулилась*/
    run cleanTable in this-procedure.
    { cleandb/delmainrec.i parts}
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTable:
  define buffer goods for ub.goods.

  for first goods no-lock where
            goods.artic     =  parts.artic 
        and goods.prod-type =  parts.prod-type 
        and goods.prod-code =  parts.prod-code
  :
    {cleandb/dellinkrec.i
      parts-attr
      "where parts-attr.in-code   = parts.in-code
         and parts-attr.gds-code  = goods.gds-code
         and parts-attr.part-code = parts.part-code"
    }
    {cleandb/dellinkrec.i
      c-parts-attr
      "where c-parts-attr.in-code   = parts.in-code
         and c-parts-attr.gds-code  = goods.gds-code
         and c-parts-attr.part-code = parts.part-code"
    }
  end.
  {cleandb/dellinkrec.i
     c-parts
     "where c-parts.obj-type  = parts.obj-type
        and c-parts.obj-code  = parts.obj-code
        and c-parts.artic     = parts.artic
        and c-parts.prod-type = parts.prod-type
        and c-parts.prod-code = parts.prod-code
        and c-parts.in-code   = parts.in-code
        and c-parts.out-code  = parts.out-code
        and c-parts.part-code = parts.part-code"
  }

end procedure.