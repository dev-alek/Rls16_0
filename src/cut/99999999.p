block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 99999999.p $
$Archive: cut/99999999.p $

Файл пирога обрезания. Относится к категории 99999999.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Завершающий этап обрезания.

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 99999999.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/99999999.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 1000.".

{ cmp/str-glbl.i }
{ utl/00000001.i }

on WRITE of src.db  override do: end.

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

  define variable v-str as character no-undo .

  assign
    v-str = "":U
  .
  if vartype-cut = 1 then do:
    find first src.db
      where src.db.db-num = 0
      .
    assign
      src.db.db-key     = "":U
      src.db.db-key-enc = "":U
      v-str = "СПН в исходной БД отключены."
    .
  end.

  assign
    v-str = v-str + {&new-line} + "Усечение завершено."
  .
  output stream str-gen close.
  return v-str.

end.