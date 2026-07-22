block-level on error undo, throw.
/*

Чистка БД. Архив финансовых док-тов.

Автор: Ростовцев Александр
Дата создания: 09/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/09/25

*/

&scop Tables Архив финансовых док-тов
/*&scop Tables arh-fin-doc-an ~*/
/*arh-fin-doc-an-attr ~        */
/*arh-fin-doc-an-nal ~         */
/*arh-fin-doc-an-nal-attr ~    */
/*arh-fin-doc-an-nal-obj ~     */
/*arh-fin-doc-an-nal-obj-attr ~*/
/*arh-fin-doc-an-obj ~         */
/*arh-fin-doc-an-obj-attr ~    */
/*arh-fin-doc-c-s-tax-nal-obj ~*/
/*arh-fin-doc-c-schet-tax-nal ~*/
/*arh-fin-doc-contr-s-nal-obj ~*/
/*arh-fin-doc-contr-s-tax-obj ~*/
/*arh-fin-doc-contr-schet ~    */
/*arh-fin-doc-contr-schet-nal ~*/
/*arh-fin-doc-contr-schet-obj ~*/
/*arh-fin-doc-contr-schet-tax ~*/
/*arh-fin-doc-s-tax-nal-obj ~  */
/*arh-fin-doc-schet ~          */
/*arh-fin-doc-schet-attr ~     */
/*arh-fin-doc-schet-nal ~      */
/*arh-fin-doc-schet-nal-attr ~ */
/*arh-fin-doc-schet-nal-obj ~  */
/*arh-fin-doc-schet-obj ~      */
/*arh-fin-doc-schet-obj-attr ~ */
/*arh-fin-doc-schet-tax ~      */
/*arh-fin-doc-schet-tax-attr ~ */
/*arh-fin-doc-schet-tax-nal ~  */
/*arh-fin-doc-schet-tax-obj ~  */
/*arh-fin-ob-contr ~           */
/*arh-fin-ob-contr-attr ~      */
/*arh-fin-ob-contr-obj ~       */
/*arh-fin-ob-contr-obj-attr    */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 09/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00199000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00199000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ cleandb/defs.i }

define variable var-fact-order-findoc as decimal no-undo.

define buffer arh-fin-doc-an                  for ub.arh-fin-doc-an.
define buffer buf_arh-fin-doc-an              for ub.arh-fin-doc-an.
define buffer arh-fin-doc-an-attr             for ub.arh-fin-doc-an-attr.
define buffer arh-fin-doc-an-nal              for ub.arh-fin-doc-an-nal.
define buffer buf_arh-fin-doc-an-nal          for ub.arh-fin-doc-an-nal.
define buffer arh-fin-doc-an-nal-attr         for ub.arh-fin-doc-an-nal-attr.
define buffer arh-fin-doc-an-nal-obj          for ub.arh-fin-doc-an-nal-obj.
define buffer buf_arh-fin-doc-an-nal-obj      for ub.arh-fin-doc-an-nal-obj.
define buffer arh-fin-doc-an-nal-obj-attr     for ub.arh-fin-doc-an-nal-obj-attr.
define buffer arh-fin-doc-an-obj              for ub.arh-fin-doc-an-obj.
define buffer buf_arh-fin-doc-an-obj          for ub.arh-fin-doc-an-obj.
define buffer arh-fin-doc-an-obj-attr         for ub.arh-fin-doc-an-obj-attr.
define buffer arh-fin-doc-c-s-tax-nal-obj     for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer buf_arh-fin-doc-c-s-tax-nal-obj for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer arh-fin-doc-c-schet-tax-nal     for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer buf_arh-fin-doc-c-schet-tax-nal for ub.arh-fin-doc-c-s-tax-nal-obj.
define buffer arh-fin-doc-contr-s-nal-obj     for ub.arh-fin-doc-contr-s-nal-obj.
define buffer buf_arh-fin-doc-contr-s-nal-obj for ub.arh-fin-doc-contr-s-nal-obj.
define buffer arh-fin-doc-contr-s-tax-obj     for ub.arh-fin-doc-contr-s-tax-obj.
define buffer buf_arh-fin-doc-contr-s-tax-obj for ub.arh-fin-doc-contr-s-tax-obj.
define buffer arh-fin-doc-contr-schet         for ub.arh-fin-doc-contr-schet.
define buffer buf_arh-fin-doc-contr-schet     for ub.arh-fin-doc-contr-schet.
define buffer arh-fin-doc-contr-schet-attr    for ub.arh-fin-doc-contr-schet-attr.
define buffer arh-fin-doc-contr-schet-nal     for ub.arh-fin-doc-contr-schet-nal.
define buffer buf_arh-fin-doc-contr-schet-nal for ub.arh-fin-doc-contr-schet-nal.
define buffer arh-fin-doc-contr-schet-obj     for ub.arh-fin-doc-contr-schet-obj.
define buffer buf_arh-fin-doc-contr-schet-obj for ub.arh-fin-doc-contr-schet-obj.
define buffer arh-fin-doc-contr-schet-tax     for ub.arh-fin-doc-contr-schet-tax.
define buffer buf_arh-fin-doc-contr-schet-tax for ub.arh-fin-doc-contr-schet-tax.
define buffer arh-fin-doc-s-tax-nal-obj       for ub.arh-fin-doc-s-tax-nal-obj.
define buffer buf_arh-fin-doc-s-tax-nal-obj   for ub.arh-fin-doc-s-tax-nal-obj.
define buffer arh-fin-doc-schet               for ub.arh-fin-doc-schet.
define buffer buf_arh-fin-doc-schet           for ub.arh-fin-doc-schet.
define buffer arh-fin-doc-schet-attr          for ub.arh-fin-doc-schet-attr.
define buffer arh-fin-doc-schet-nal           for ub.arh-fin-doc-schet-nal.
define buffer buf_arh-fin-doc-schet-nal       for ub.arh-fin-doc-schet-nal.
define buffer arh-fin-doc-schet-nal-attr      for ub.arh-fin-doc-schet-nal-attr.
define buffer arh-fin-doc-schet-nal-obj       for ub.arh-fin-doc-schet-nal-obj.
define buffer buf_arh-fin-doc-schet-nal-obj   for ub.arh-fin-doc-schet-nal-obj.
define buffer arh-fin-doc-schet-obj           for ub.arh-fin-doc-schet-obj.
define buffer buf_arh-fin-doc-schet-obj       for ub.arh-fin-doc-schet-obj.
define buffer arh-fin-doc-schet-obj-attr      for ub.arh-fin-doc-schet-obj-attr.
define buffer arh-fin-doc-schet-tax           for ub.arh-fin-doc-schet-tax.
define buffer buf_arh-fin-doc-schet-tax       for ub.arh-fin-doc-schet-tax.
define buffer arh-fin-doc-schet-tax-attr      for ub.arh-fin-doc-schet-tax-attr.
define buffer arh-fin-doc-schet-tax-nal       for ub.arh-fin-doc-schet-tax-nal.
define buffer buf_arh-fin-doc-schet-tax-nal   for ub.arh-fin-doc-schet-tax-nal.
define buffer arh-fin-doc-schet-tax-obj       for ub.arh-fin-doc-schet-tax-obj.
define buffer buf_arh-fin-doc-schet-tax-obj   for ub.arh-fin-doc-schet-tax-obj.
define buffer arh-fin-ob-contr                for ub.arh-fin-ob-contr.
define buffer buf_arh-fin-ob-contr            for ub.arh-fin-ob-contr.
define buffer arh-fin-ob-contr-attr           for ub.arh-fin-ob-contr-attr.
define buffer arh-fin-ob-contr-obj            for ub.arh-fin-ob-contr-obj.
define buffer buf_arh-fin-ob-contr-obj        for ub.arh-fin-ob-contr-obj.
define buffer arh-fin-ob-contr-obj-attr       for ub.arh-fin-ob-contr-obj-attr.

on delete of ub.arh-fin-doc-an               override do: end.
on delete of ub.arh-fin-doc-an-attr          override do: end.
on delete of ub.arh-fin-doc-an-nal           override do: end.
on delete of ub.arh-fin-doc-an-nal-attr      override do: end.
on delete of ub.arh-fin-doc-an-nal-obj       override do: end.
on delete of ub.arh-fin-doc-an-nal-obj-attr  override do: end.
on delete of ub.arh-fin-doc-an-obj           override do: end.
on delete of ub.arh-fin-doc-an-obj-attr      override do: end.
on delete of ub.arh-fin-doc-c-s-tax-nal-obj  override do: end.
on delete of ub.arh-fin-doc-c-schet-tax-nal  override do: end.
on delete of ub.arh-fin-doc-contr-s-nal-obj  override do: end.
on delete of ub.arh-fin-doc-contr-s-tax-obj  override do: end.
on delete of ub.arh-fin-doc-contr-schet      override do: end.
on delete of ub.arh-fin-doc-contr-schet-attr override do: end.
on delete of ub.arh-fin-doc-contr-schet-nal  override do: end.
on delete of ub.arh-fin-doc-contr-schet-obj  override do: end.
on delete of ub.arh-fin-doc-contr-schet-tax  override do: end.
on delete of ub.arh-fin-doc-s-tax-nal-obj    override do: end.
on delete of ub.arh-fin-doc-schet            override do: end.
on delete of ub.arh-fin-doc-schet-attr       override do: end.
on delete of ub.arh-fin-doc-schet-nal        override do: end.
on delete of ub.arh-fin-doc-schet-nal-attr   override do: end.
on delete of ub.arh-fin-doc-schet-nal-obj    override do: end.
on delete of ub.arh-fin-doc-schet-obj        override do: end.
on delete of ub.arh-fin-doc-schet-obj-attr   override do: end.
on delete of ub.arh-fin-doc-schet-tax        override do: end.
on delete of ub.arh-fin-doc-schet-tax-attr   override do: end.
on delete of ub.arh-fin-doc-schet-tax-nal    override do: end.
on delete of ub.arh-fin-doc-schet-tax-obj    override do: end.
on delete of ub.arh-fin-ob-contr             override do: end.
on delete of ub.arh-fin-ob-contr-attr        override do: end.
on delete of ub.arh-fin-ob-contr-obj         override do: end.
on delete of ub.arh-fin-ob-contr-obj-attr    override do: end.

run factord-end-day in this-procedure ( vardate-actual-docs - 1, output var-fact-order-findoc).

for each buf_clients no-lock where 
         buf_clients.db-num <> ?
:
for each arh-fin-doc-an no-lock where
         arh-fin-doc-an.host-code  = buf_clients.host-code
     and arh-fin-doc-an.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-attr exclusive-lock where
           arh-fin-doc-an-attr.host-code         = arh-fin-doc-an.host-code  
       and arh-fin-doc-an-attr.cli-type          = arh-fin-doc-an.cli-type
       and arh-fin-doc-an-attr.cli-code          = arh-fin-doc-an.cli-code
       and arh-fin-doc-an-attr.code-schet        = arh-fin-doc-an.code-schet
       and arh-fin-doc-an-attr.fin-ext-doc-type  = arh-fin-doc-an.fin-ext-doc-type
       and arh-fin-doc-an-attr.fin-code-an-uchet = arh-fin-doc-an.fin-code-an-uchet
       and arh-fin-doc-an-attr.fin-code-cel-nazn = arh-fin-doc-an.fin-code-cel-nazn
       and arh-fin-doc-an-attr.fin-code-cor-acc  = arh-fin-doc-an.fin-code-cor-acc
       and arh-fin-doc-an-attr.calc-curr-code    = arh-fin-doc-an.calc-curr-code
       and arh-fin-doc-an-attr.sum-type          = arh-fin-doc-an.sum-type
       and arh-fin-doc-an-attr.fact-order        = arh-fin-doc-an.fact-order
  :  
    delete arh-fin-doc-an-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-an}
end.
for each arh-fin-doc-an-nal no-lock where
         arh-fin-doc-an-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-an-nal.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-nal-attr exclusive-lock where
           arh-fin-doc-an-nal-attr.host-code         = arh-fin-doc-an-nal.host-code  
       and arh-fin-doc-an-nal-attr.cli-type          = arh-fin-doc-an-nal.cli-type
       and arh-fin-doc-an-nal-attr.cli-code          = arh-fin-doc-an-nal.cli-code
       and arh-fin-doc-an-nal-attr.fin-code-acc      = arh-fin-doc-an-nal.fin-code-acc
       and arh-fin-doc-an-nal-attr.curr-code         = arh-fin-doc-an-nal.curr-code
       and arh-fin-doc-an-nal-attr.fin-ext-doc-type  = arh-fin-doc-an-nal.fin-ext-doc-type
       and arh-fin-doc-an-nal-attr.fin-code-an-uchet = arh-fin-doc-an-nal.fin-code-an-uchet
       and arh-fin-doc-an-nal-attr.fin-code-cel-nazn = arh-fin-doc-an-nal.fin-code-cel-nazn
       and arh-fin-doc-an-nal-attr.fin-code-cor-acc  = arh-fin-doc-an-nal.fin-code-cor-acc
       and arh-fin-doc-an-nal-attr.calc-curr-code    = arh-fin-doc-an-nal.calc-curr-code
       and arh-fin-doc-an-nal-attr.sum-type          = arh-fin-doc-an-nal.sum-type
       and arh-fin-doc-an-nal-attr.fact-order        = arh-fin-doc-an-nal.fact-order
  :  
    delete arh-fin-doc-an-nal-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-an-nal}
end.
for each arh-fin-doc-an-nal-obj no-lock where
         arh-fin-doc-an-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-an-nal-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-nal-obj-attr exclusive-lock where
           arh-fin-doc-an-nal-obj-attr.host-code         = arh-fin-doc-an-nal-obj.host-code  
       and arh-fin-doc-an-nal-obj-attr.obj-type          = arh-fin-doc-an-nal-obj.obj-type
       and arh-fin-doc-an-nal-obj-attr.obj-code          = arh-fin-doc-an-nal-obj.obj-code
       and arh-fin-doc-an-nal-obj-attr.cli-type          = arh-fin-doc-an-nal-obj.cli-type
       and arh-fin-doc-an-nal-obj-attr.cli-code          = arh-fin-doc-an-nal-obj.cli-code
       and arh-fin-doc-an-nal-obj-attr.fin-code-acc      = arh-fin-doc-an-nal-obj.fin-code-acc
       and arh-fin-doc-an-nal-obj-attr.curr-code         = arh-fin-doc-an-nal-obj.curr-code
       and arh-fin-doc-an-nal-obj-attr.fin-ext-doc-type  = arh-fin-doc-an-nal-obj.fin-ext-doc-type
       and arh-fin-doc-an-nal-obj-attr.fin-code-an-uchet = arh-fin-doc-an-nal-obj.fin-code-an-uchet
       and arh-fin-doc-an-nal-obj-attr.fin-code-cel-nazn = arh-fin-doc-an-nal-obj.fin-code-cel-nazn
       and arh-fin-doc-an-nal-obj-attr.fin-code-cor-acc  = arh-fin-doc-an-nal-obj.fin-code-cor-acc
       and arh-fin-doc-an-nal-obj-attr.calc-curr-code    = arh-fin-doc-an-nal-obj.calc-curr-code
       and arh-fin-doc-an-nal-obj-attr.sum-type          = arh-fin-doc-an-nal-obj.sum-type
       and arh-fin-doc-an-nal-obj-attr.fact-order        = arh-fin-doc-an-nal-obj.fact-order
  :  
    delete arh-fin-doc-an-nal-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-an-nal-obj}
end.
for each arh-fin-doc-an-obj no-lock where
         arh-fin-doc-an-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-an-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-an-obj-attr exclusive-lock where
           arh-fin-doc-an-obj-attr.host-code         = arh-fin-doc-an-obj.host-code  
       and arh-fin-doc-an-obj-attr.obj-type          = arh-fin-doc-an-obj.obj-type
       and arh-fin-doc-an-obj-attr.obj-code          = arh-fin-doc-an-obj.obj-code
       and arh-fin-doc-an-obj-attr.cli-type          = arh-fin-doc-an-obj.cli-type
       and arh-fin-doc-an-obj-attr.cli-code          = arh-fin-doc-an-obj.cli-code
       and arh-fin-doc-an-obj-attr.code-schet        = arh-fin-doc-an-obj.code-schet
       and arh-fin-doc-an-obj-attr.fin-ext-doc-type  = arh-fin-doc-an-obj.fin-ext-doc-type
       and arh-fin-doc-an-obj-attr.fin-code-an-uchet = arh-fin-doc-an-obj.fin-code-an-uchet
       and arh-fin-doc-an-obj-attr.fin-code-cel-nazn = arh-fin-doc-an-obj.fin-code-cel-nazn
       and arh-fin-doc-an-obj-attr.fin-code-cor-acc  = arh-fin-doc-an-obj.fin-code-cor-acc
       and arh-fin-doc-an-obj-attr.calc-curr-code    = arh-fin-doc-an-obj.calc-curr-code
       and arh-fin-doc-an-obj-attr.sum-type          = arh-fin-doc-an-obj.sum-type
       and arh-fin-doc-an-obj-attr.fact-order        = arh-fin-doc-an-obj.fact-order
  :  
    delete arh-fin-doc-an-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-an-obj}
end.
for each arh-fin-doc-c-s-tax-nal-obj no-lock where
         arh-fin-doc-c-s-tax-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-c-s-tax-nal-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-c-s-tax-nal-obj}
end.
for each arh-fin-doc-c-schet-tax-nal no-lock where
         arh-fin-doc-c-schet-tax-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-c-schet-tax-nal.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-c-schet-tax-nal}
end.
for each arh-fin-doc-contr-s-nal-obj no-lock where
         arh-fin-doc-contr-s-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-s-nal-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-contr-s-nal-obj}
end.
for each arh-fin-doc-contr-s-tax-obj no-lock where
         arh-fin-doc-contr-s-tax-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-s-tax-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-contr-s-tax-obj}
end.
for each arh-fin-doc-contr-schet no-lock where
         arh-fin-doc-contr-schet.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-contr-schet-attr exclusive-lock where
           arh-fin-doc-contr-schet-attr.host-code         = arh-fin-doc-contr-schet.host-code  
       and arh-fin-doc-contr-schet-attr.contract-code     = arh-fin-doc-contr-schet.contract-code
       and arh-fin-doc-contr-schet-attr.cli-type          = arh-fin-doc-contr-schet.cli-type
       and arh-fin-doc-contr-schet-attr.cli-code          = arh-fin-doc-contr-schet.cli-code
       and arh-fin-doc-contr-schet-attr.code-schet        = arh-fin-doc-contr-schet.code-schet
       and arh-fin-doc-contr-schet-attr.fin-ext-doc-type  = arh-fin-doc-contr-schet.fin-ext-doc-type
       and arh-fin-doc-contr-schet-attr.calc-curr-code    = arh-fin-doc-contr-schet.calc-curr-code
       and arh-fin-doc-contr-schet-attr.sum-type          = arh-fin-doc-contr-schet.sum-type
       and arh-fin-doc-contr-schet-attr.fact-order        = arh-fin-doc-contr-schet.fact-order
  :  
    delete arh-fin-doc-contr-schet-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-contr-schet}
end.
for each arh-fin-doc-contr-schet-nal no-lock where
         arh-fin-doc-contr-schet-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet-nal.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-contr-schet-nal}
end.
for each arh-fin-doc-contr-schet-obj no-lock where
         arh-fin-doc-contr-schet-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-contr-schet-obj}
end.
for each arh-fin-doc-contr-schet-tax no-lock where
         arh-fin-doc-contr-schet-tax.host-code  = buf_clients.host-code
     and arh-fin-doc-contr-schet-tax.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-contr-schet-tax}
end.
for each arh-fin-doc-s-tax-nal-obj no-lock where
         arh-fin-doc-s-tax-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-s-tax-nal-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-s-tax-nal-obj}
end.
for each arh-fin-doc-schet no-lock where
         arh-fin-doc-schet.host-code  = buf_clients.host-code
     and arh-fin-doc-schet.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-attr exclusive-lock where
           arh-fin-doc-schet-attr.host-code         = arh-fin-doc-schet.host-code  
       and arh-fin-doc-schet-attr.cli-type          = arh-fin-doc-schet.cli-type
       and arh-fin-doc-schet-attr.cli-code          = arh-fin-doc-schet.cli-code
       and arh-fin-doc-schet-attr.code-schet        = arh-fin-doc-schet.code-schet
       and arh-fin-doc-schet-attr.fin-ext-doc-type  = arh-fin-doc-schet.fin-ext-doc-type
       and arh-fin-doc-schet-attr.calc-curr-code    = arh-fin-doc-schet.calc-curr-code
       and arh-fin-doc-schet-attr.sum-type          = arh-fin-doc-schet.sum-type
       and arh-fin-doc-schet-attr.fact-order        = arh-fin-doc-schet.fact-order
  :  
    delete arh-fin-doc-schet-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-schet}
end.
for each arh-fin-doc-schet-nal no-lock where
         arh-fin-doc-schet-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-nal.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-nal-attr exclusive-lock where
           arh-fin-doc-schet-nal-attr.host-code         = arh-fin-doc-schet-nal.host-code  
       and arh-fin-doc-schet-nal-attr.cli-type          = arh-fin-doc-schet-nal.cli-type
       and arh-fin-doc-schet-nal-attr.cli-code          = arh-fin-doc-schet-nal.cli-code
       and arh-fin-doc-schet-nal-attr.fin-code-acc      = arh-fin-doc-schet-nal.fin-code-acc
       and arh-fin-doc-schet-nal-attr.curr-code         = arh-fin-doc-schet-nal.curr-code
       and arh-fin-doc-schet-nal-attr.fin-ext-doc-type  = arh-fin-doc-schet-nal.fin-ext-doc-type
       and arh-fin-doc-schet-nal-attr.calc-curr-code    = arh-fin-doc-schet-nal.calc-curr-code
       and arh-fin-doc-schet-nal-attr.sum-type          = arh-fin-doc-schet-nal.sum-type
       and arh-fin-doc-schet-nal-attr.fact-order        = arh-fin-doc-schet-nal.fact-order
  :  
    delete arh-fin-doc-schet-nal-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-schet-nal}
end.
for each arh-fin-doc-schet-nal-obj no-lock where
         arh-fin-doc-schet-nal-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-nal-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-schet-nal-obj}
end.
for each arh-fin-doc-schet-obj no-lock where
         arh-fin-doc-schet-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-obj-attr exclusive-lock where
           arh-fin-doc-schet-obj-attr.host-code         = arh-fin-doc-schet-obj.host-code  
       and arh-fin-doc-schet-obj-attr.obj-type          = arh-fin-doc-schet-obj.obj-type
       and arh-fin-doc-schet-obj-attr.obj-code          = arh-fin-doc-schet-obj.obj-code
       and arh-fin-doc-schet-obj-attr.cli-type          = arh-fin-doc-schet-obj.cli-type
       and arh-fin-doc-schet-obj-attr.cli-code          = arh-fin-doc-schet-obj.cli-code
       and arh-fin-doc-schet-obj-attr.code-schet        = arh-fin-doc-schet-obj.code-schet
       and arh-fin-doc-schet-obj-attr.fin-ext-doc-type  = arh-fin-doc-schet-obj.fin-ext-doc-type
       and arh-fin-doc-schet-obj-attr.calc-curr-code    = arh-fin-doc-schet-obj.calc-curr-code
       and arh-fin-doc-schet-obj-attr.sum-type          = arh-fin-doc-schet-obj.sum-type
       and arh-fin-doc-schet-obj-attr.fact-order        = arh-fin-doc-schet-obj.fact-order
  :  
    delete arh-fin-doc-schet-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-schet-obj}
end.
for each arh-fin-doc-schet-tax no-lock where
         arh-fin-doc-schet-tax.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-tax.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-doc-schet-tax-attr exclusive-lock where
           arh-fin-doc-schet-tax-attr.host-code         = arh-fin-doc-schet-tax.host-code  
       and arh-fin-doc-schet-tax-attr.cli-type          = arh-fin-doc-schet-tax.cli-type
       and arh-fin-doc-schet-tax-attr.cli-code          = arh-fin-doc-schet-tax.cli-code
       and arh-fin-doc-schet-tax-attr.code-schet        = arh-fin-doc-schet-tax.code-schet
       and arh-fin-doc-schet-tax-attr.fin-ext-doc-type  = arh-fin-doc-schet-tax.fin-ext-doc-type
       and arh-fin-doc-schet-tax-attr.calc-curr-code    = arh-fin-doc-schet-tax.calc-curr-code
       and arh-fin-doc-schet-tax-attr.VAT-pc            = arh-fin-doc-schet-tax.VAT-pc
       and arh-fin-doc-schet-tax-attr.SLT-pc            = arh-fin-doc-schet-tax.SLT-pc
       and arh-fin-doc-schet-tax-attr.with-vat          = arh-fin-doc-schet-tax.with-vat
       and arh-fin-doc-schet-tax-attr.with-slt          = arh-fin-doc-schet-tax.with-slt
       and arh-fin-doc-schet-tax-attr.sum-type          = arh-fin-doc-schet-tax.sum-type
       and arh-fin-doc-schet-tax-attr.fact-order        = arh-fin-doc-schet-tax.fact-order
  :  
    delete arh-fin-doc-schet-tax-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-doc-schet-tax}
end.
for each arh-fin-doc-schet-tax-nal no-lock where
         arh-fin-doc-schet-tax-nal.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-tax-nal.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-schet-tax-nal}
end.
for each arh-fin-doc-schet-tax-obj no-lock where
         arh-fin-doc-schet-tax-obj.host-code  = buf_clients.host-code
     and arh-fin-doc-schet-tax-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { cleandb/delmainrec.i arh-fin-doc-schet-tax-obj}
end.
for each arh-fin-ob-contr no-lock where
         arh-fin-ob-contr.host-code  = buf_clients.host-code
     and arh-fin-ob-contr.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-ob-contr-attr exclusive-lock where
           arh-fin-ob-contr-attr.host-code         = arh-fin-ob-contr.host-code  
       and arh-fin-ob-contr-attr.contract-code     = arh-fin-ob-contr.contract-code
       and arh-fin-ob-contr-attr.cli-type          = arh-fin-ob-contr.cli-type
       and arh-fin-ob-contr-attr.cli-code          = arh-fin-ob-contr.cli-code
       and arh-fin-ob-contr-attr.fin-ext-doc-type  = arh-fin-ob-contr.fin-ext-doc-type
       and arh-fin-ob-contr-attr.calc-curr-code    = arh-fin-ob-contr.calc-curr-code
       and arh-fin-ob-contr-attr.sum-type          = arh-fin-ob-contr.sum-type
       and arh-fin-ob-contr-attr.fact-order        = arh-fin-ob-contr.fact-order
  :  
    delete arh-fin-ob-contr-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-ob-contr}
end.
for each arh-fin-ob-contr-obj no-lock where
         arh-fin-ob-contr-obj.host-code  = buf_clients.host-code
     and arh-fin-ob-contr-obj.fact-order < var-fact-order-findoc 
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  for each arh-fin-ob-contr-obj-attr exclusive-lock where
           arh-fin-ob-contr-obj-attr.host-code         = arh-fin-ob-contr-obj.host-code  
       and arh-fin-ob-contr-obj-attr.obj-type          = arh-fin-ob-contr-obj.obj-type
       and arh-fin-ob-contr-obj-attr.obj-code          = arh-fin-ob-contr-obj.obj-code
       and arh-fin-ob-contr-obj-attr.contract-code     = arh-fin-ob-contr-obj.contract-code
       and arh-fin-ob-contr-obj-attr.cli-type          = arh-fin-ob-contr-obj.cli-type
       and arh-fin-ob-contr-obj-attr.cli-code          = arh-fin-ob-contr-obj.cli-code
       and arh-fin-ob-contr-obj-attr.fin-ext-doc-type  = arh-fin-ob-contr-obj.fin-ext-doc-type
       and arh-fin-ob-contr-obj-attr.calc-curr-code    = arh-fin-ob-contr-obj.calc-curr-code
       and arh-fin-ob-contr-obj-attr.sum-type          = arh-fin-ob-contr-obj.sum-type
       and arh-fin-ob-contr-obj-attr.fact-order        = arh-fin-ob-contr-obj.fact-order
  :  
    delete arh-fin-ob-contr-obj-attr.
    vDeleted = vDeleted + 1.
  end.
  { cleandb/delmainrec.i arh-fin-ob-contr-obj}
end.
end.  /* for first buf_clients */

{cleandb/setresval.i}
return vResult.
