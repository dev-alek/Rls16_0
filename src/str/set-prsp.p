block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: set-prsp.p $
$Archive: str/set-prsp.p $

Получение сумм и цен при обязательной продаже товара, исходя из цены партии

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: set-prsp.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/set-prsp.p $":U .
def var vss-description as character no-undo init "Установка специальной цены продаже по партиям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/croslist.i }
define input  parameter pardoc-code          like trn-doc.doc-code      no-undo.
define input  parameter parobj-type          like trn-doc.obj-type      no-undo.
define input  parameter parobj-code          like trn-doc.obj-code      no-undo.
define input  parameter parartic             like doc-line.artic        no-undo.
define input  parameter parprod-type         like doc-line.prod-type    no-undo.
define input  parameter parprod-code         like doc-line.prod-code    no-undo.
define output parameter parsaleparts         as   logical               no-undo.
define output parameter parsp-sum-price-sale like price-list.price-sale no-undo.
define output parameter parsp-sum-road-tax   like price-list.road-tax   no-undo.
define output parameter parsp-sum-excise     like price-list.excise     no-undo.
define output parameter parsp-prc-price-sale like price-list.price-sale no-undo.
define output parameter parsp-prc-road-tax   like price-list.road-tax   no-undo.
define output parameter parsp-prc-excise     like price-list.excise     no-undo.
define variable         vardoc-num           like price-list.doc-num    no-undo.
define variable         varprice-sale        like price-list.price-sale no-undo.
define variable         varroad-tax          like price-list.road-tax   no-undo.
define variable         varexcise            like price-list.excise     no-undo.
define variable         varparts-b-code      like bar-code.b-code       no-undo.
define variable         varfact-qnty         like parts.fact-qnty       no-undo.
find first goods where goods.artic     = parartic     and
                       goods.prod-type = parprod-type and
                       goods.prod-code = parprod-code no-lock.
find first units where units.unit-name = goods.unit-base no-lock.
if cross-list(units.type, {&saleparts}, ",") then do:
   for each parts where parts.out-code  = pardoc-code  and
                        parts.obj-type  = parobj-type  and
                        parts.obj-code  = parobj-code  and
                        parts.artic     = parartic     and
                        parts.prod-type = parprod-type and
                        parts.prod-code = parprod-code no-lock :

       { gbl/partbcod.i parts varparts-b-code no-error}
       if error-status:error then do:
          return error "Не найдена бар-код партии "                    +
                       " Документ "          + string(parts.out-code)  +
                       " Тип объекта "       + string(parts.obj-type)  +
                       " Код объекта "       + string(parts.obj-code)  +
                       " Артикул "           + string(parts.artic)     +
                       " Тип производителя " + string(parts.prod-type) +
                       " Код производителя " + string(parts.prod-code) +
                       " Код партии "        + string(parts.part-code) +
                       " Прих.накл "         + string(parts.in-code)   .
       end.
       { gbl/bcodeprc.i
         parts.obj-type
         parts.obj-code
         varparts-b-code
         0
         0
         vardoc-num
         varprice-sale
         varroad-tax
         varexcise
         no-error
      }
      if varprice-sale = ? then
         return error "Не найдена цена товара на партию "       +
                      " Документ "          + string(parts.out-code)  +
                      " Тип объекта "       + string(parts.obj-type)  +
                      " Код объекта "       + string(parts.obj-code)  +
                      " Артикул "           + string(parts.artic)     +
                      " Тип производителя " + string(parts.prod-type) +
                      " Код производителя " + string(parts.prod-code) +
                      " Бар-код "           + string(varparts-b-code) +
                      " Код партии "        + string(parts.part-code) +
                      " Прих.накл "         + string(parts.in-code).
      assign parsp-sum-price-sale = parsp-sum-price-sale + varprice-sale * parts.fact-qnty
             parsp-sum-road-tax   = parsp-sum-road-tax   + varroad-tax   * parts.fact-qnty
             parsp-sum-excise     = parsp-sum-excise     + varexcise     * parts.fact-qnty
             varfact-qnty         = varfact-qnty         +                 parts.fact-qnty.
   end.
   assign
   parsp-prc-price-sale = parsp-sum-price-sale / varfact-qnty
   parsp-prc-road-tax   = parsp-sum-road-tax   / varfact-qnty
   parsp-prc-excise     = parsp-sum-excise     / varfact-qnty.
end.
else assign parsaleparts = no.