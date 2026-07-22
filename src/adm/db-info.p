block-level on error undo, throw.
/*

$Revision: d3f7ea4aa09e, 3307, rls $
$Author: DRuban $
$Date: 2023/05/19 13:37:07 $
$Workfile: db-info.p $
$Archive: adm/db-info.p $

Информация о текущей базе данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/
define output parameter oDbNum  as integer   no-undo .
define output parameter oDBInfo as character no-undo.


def var vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
def var vss-workfile    as character no-undo init "$Workfile: db-info.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/db-info.p $":U .
def var vss-description as character no-undo init "Информация о текущей базе данных".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error
:
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .

  find first buf_sys-ctrl no-lock.
  assign
    oDbNum = buf_sys-ctrl.db-num
  .
  find first buf_db no-lock
    where buf_db.db-num = buf_sys-ctrl.db-num
    no-error
    .
  if not available buf_db then do:
    oDBInfo = substitute( "Не найдена информация о текущей БД" ).
    return error oDBInfo .
  end.
  else do:
    oDBInfo = substitute( "БД N: &1 (&2, ключ: &3)", buf_db.db-num, buf_db.db-name, buf_db.db-key ).
  end.
end.

/* $Workfile: db-info.p $ end */