block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sp-count.p $
$Archive: utl/sp-count.p $

утилита для зачистки спецификаций от удаленных товаров (только проверка!!!)

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/15/06
Author: Michael Kochetkov
Creation date: 09/15/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sp-count.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/sp-count.p $":U .
define variable vss-description as character no-undo init "утилита для зачистки спецификаций от удаленных товаров (только проверка!!!)".
{ cmp/vssrevis.i }

define buffer buf_goods for goods.
define buffer buf_contract-specif for contract-specif .
define variable v-user-action                as   character                   no-undo.
define variable v-printed                    as   logical                     no-undo.
define stream str-err.
define variable is-err as logical   no-undo .
assign is-err = no .

output stream str-err to value( "spec-del.err" ) .
for each buf_contract-specif no-lock :
  find first buf_goods no-lock where buf_goods.gds-code = buf_contract-specif.gds-code no-error .
  if not available buf_goods then do:
    put    stream str-err unformatted string( "Договор (вн.№) = " + string(buf_contract-specif.contract-num) + " Товар (вн.№) = " + string( buf_contract-specif.gds-code))  skip.
    assign is-err = yes .
  end.
end.
    output stream str-err close.
  if is-err then message  "Удаленные товары в спецификациях к договору можно посмотреть в файле spec-del.err" view-as alert-box.
  else           message  "Удаленных товаров в спецификациях к договору нет!" view-as alert-box.
