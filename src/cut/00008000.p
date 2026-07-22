block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00008000.p $
$Archive: cut/00008000.p $

Файл пирога обрезания. Относится к категории 8.
Обработка таблиц:
season
season-attr
c-season
gds-season
gds-season-attr
c-gds-season

Автор: Чернова Светлана Александровна
Дата создания: 05/22/09
Author: Svetlana Chernova
Creation date: 05/22/09

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00008000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00008000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 8.".
{ cmp/str-glbl.i }

define buffer old-season          for src.season.
define buffer new-season          for dst.season.
define buffer old-c-season        for src.c-season.
define buffer new-c-season        for dst.c-season.
define buffer old-gds-season      for src.gds-season.
define buffer new-gds-season      for dst.gds-season.
define buffer old-c-gds-season    for src.c-gds-season.
define buffer new-c-gds-season    for dst.c-gds-season.
define buffer old-season-attr     for src.season-attr.
define buffer new-season-attr     for dst.season-attr.
define buffer old-gds-season-attr for src.gds-season-attr.
define buffer new-gds-season-attr for dst.gds-season-attr.

define buffer new-goods           for dst.goods.


do
on error undo, return error
:
  { utl/00000001.i }
  on WRITE of dst.season        override do: end.
  on WRITE of dst.season-attr   override do: end.
  on WRITE of dst.c-season      override do: end.
  on WRITE of dst.gds-season    override do: end.
  on WRITE of dst.gds-season-attr override do: end.
  on WRITE of dst.c-gds-season  override do: end.


  { utl/00000002.i season      }
  { utl/00000002.i season-attr }

  for each old-gds-season no-lock ,
      first new-goods no-lock where new-goods.gds-code = old-gds-season.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      create new-gds-season.
      BUFFER-COPY old-gds-season to new-gds-season.
  end.

  for each old-gds-season-attr no-lock ,
      first new-goods no-lock where new-goods.gds-code = old-gds-season-attr.gds-code
      on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      create new-gds-season-attr.
      BUFFER-COPY old-gds-season-attr to new-gds-season-attr.
  end.

  /* Перенос если нужно истории */
  if varstay-history = true then do:
      /* c-season */
      { utl/00000002.i c-season      }
      for each old-c-gds-season no-lock ,
          first new-goods no-lock where new-goods.gds-code = old-c-gds-season.gds-code
          on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
          :
          create new-c-gds-season.
          BUFFER-COPY old-c-gds-season to new-c-gds-season.
      end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: season gds-season c-season c-gds-season season-attr gds-season-attr . " .
end.