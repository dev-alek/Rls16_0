block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00000005.p $
$Archive: cut/00000005.p $

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/18/09
Author: Dmitry Ukhanov
Creation date: 05/18/09

Файл пирога обрезания. Относится к категории 0.
Обработка сикуэнсов

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00000005.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00000005.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 0.".
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop"  , vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer old-sequence for src._sequence .
  define buffer new-sequence for dst._sequence .

  define variable dopi as int64 no-undo .

  { utl/00000001.i }

  for each new-sequence
    ,first old-sequence no-lock
    where old-sequence._seq-name = new-sequence._seq-name
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :

    assign
      dopi = dynamic-current-value( old-sequence._seq-name, "src":U )
    .

    if dopi < new-sequence._Seq-Min then do:
      assign
        dopi = new-sequence._Seq-Min
      .
    end.

    if new-sequence._Seq-Max <> ?
      and dopi > new-sequence._Seq-Max
    then do:
      assign
        dopi = new-sequence._Seq-Max
      .
    end.

    assign
      dynamic-current-value( new-sequence._seq-name, "dst":U ) = dopi
    .

  end.
  output stream str-gen close.
  return "Произведен экспорт счетчиков.".
end.