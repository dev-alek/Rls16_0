block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndgrup.p $
$Archive: str/sndgrup.p $

Пересылка групп товаров на кассу - пускальник

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
define input parameter mode as char no-undo .
/*"U' "D" "R" - справочник*/
define input parameter p-subject as character no-undo .
/*пусто - это группы товаров на кассе group-bo  units gds-prt*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndgrup.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sndgrup.p $":U .
define variable vss-description as character no-undo init "Пересылка различных справочников - пускальник".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ cmp/obj-list.i NEW}

define variable v-message as character no-undo .

CASE p-subject:
  when '':U then do:
    assign
    v-message = substitute("Отсылка групп товаров на кассы магазина &1", i-obj-code)
    .
  end.
  when 'group-BO' then do:
    assign
    v-message = substitute("Отсылка справочника групп товаров IBS TH в информационный киоск")
    .
  end.
  when 'units' then do:
    assign
    v-message = substitute("Отсылка справочника единиц измерения в информационный киоск")
    .
  end.
  when 'gds-prt' then do:
    assign
    v-message = substitute("Отсылка справочника шкал в информационный киоск")
    .
  end.
  when 'country' then do:
    assign
    v-message = substitute("Отсылка справочника стран в информационный киоск")
    .
  end.

END CASE.

 run str/diallog.w (
        input parParentProc
      , input this-procedure
      , input "str/sendgrup.p":U
      , input (string(i-obj-code) + {&delim-par} + mode + {&delim-par} + p-subject)
      , input no /*p-auto-go*/
      , input "":U
      , input v-message
  ) no-error.