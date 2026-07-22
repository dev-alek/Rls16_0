block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: extartd.p $
$Archive: ref/extartd.p $

Изменение статуса внешнего артикула

Автор: Хныкин Павел Андреевич
Дата создания: 05/04/07
Author: Pavel Khnykin
Creation date: 05/04/07

*/
define input  parameter p-cli-type like ub.ext-artic.cli-type no-undo .
define input  parameter p-cli-code like ub.ext-artic.cli-code no-undo .
define input  parameter p-gds-code like ub.ext-artic.gds-code no-undo .
define input  parameter p-status_  like ub.ext-artic.status_  no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extartd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/extartd.p $":U .
define variable vss-description as character no-undo init "Изменение статуса внешнего артикула".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_ext-artic       for ub.ext-artic.
define buffer ex_ext-artic        for ub.ext-artic.
define buffer buf_goods           for ub.goods.
define buffer buf_ext-artic-attr  for ub.ext-artic-attr.

do on error undo, return error return-value :

  if     p-status_ <> {&current-status}
    and  p-status_ <> {&deleted-status} then do:
    return error "Неверное значение параметра p-status_".
  end.

  find first buf_ext-artic exclusive-lock
    where buf_ext-artic.cli-type = p-cli-type
      and buf_ext-artic.cli-code = p-cli-code
      and buf_ext-artic.gds-code = p-gds-code
  no-wait no-error .
  if not available buf_ext-artic then do:
    if locked buf_ext-artic then do:
      return error "Запись заблокирована".
    end.
    else do:
      return error "Запись не найдена".
    end.
  end.

  if p-status_ = {&current-status} then do:
    find first ex_ext-artic no-lock
      where ex_ext-artic.cli-type  = p-cli-type
        and ex_ext-artic.cli-code  = p-cli-code
        and ex_ext-artic.gds-code <> p-gds-code
        and ex_ext-artic.ext-artic = buf_ext-artic.ext-artic
        and ex_ext-artic.status_   = {&current-status}
    use-index ea-stts /* НЕ ТРОГАТЬ!!! индекс по артикулу вероятнее быстрее чем по поставщику */
    no-error .
    if available ex_ext-artic then do :
      find first buf_goods no-lock
        where buf_goods.gds-code = ex_ext-artic.gds-code
      no-error .
      return error substitute( "У '&1 &2' уже есть товар &3 с внешним артикулом &4"
                            , p-cli-type
                            , p-cli-code
                            , if available buf_goods then substitute( "'&1 &2'" , buf_goods.artic , buf_goods.gds-name ) else ''
                            , buf_ext-artic.ext-artic
                            ).
    end.
  end.

  if p-status_ = {&deleted-status} then do :
    for each buf_ext-artic-attr exclusive-lock
          where buf_ext-artic-attr.cli-type = buf_ext-artic.cli-type
            and buf_ext-artic-attr.cli-code = buf_ext-artic.cli-code
            and buf_ext-artic-attr.gds-code = buf_ext-artic.gds-code
    :
      delete buf_ext-artic-attr.
    end.
  end.

  assign
    buf_ext-artic.status_ = p-status_
  .
end.