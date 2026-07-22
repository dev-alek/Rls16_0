block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: taratax.p $
$Archive: utl/taratax.p $

Изменение названия и типа дорналога на стеклопусуду

Автор: Суслов Алексей Юрьевич
Дата создания: 04/11/06
Author: Alexey Suslov
Creation date: 04/11/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: taratax.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/taratax.p $":U .
define variable vss-description as character no-undo init "Изменение названия и типа дорналога на стеклопусуду".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }


run waitfram-show in this-procedure ("Инициализация налога СТЕКЛОПОСУДА").

run cre-tax (3, "Стеклопосуда", {&absolute}, no, {&bottle}, yes).

run waitfram-hide in this-procedure .

message "Инициализация закончена.".


procedure cre-tax:
def input param taxcode like ub.tax.tax-code no-undo.
def input param l-n as char no-undo.
def input param tp as char no-undo.
def input param tocashdesk as logical no-undo.
def input param unittypes as char no-undo.
def input param individ like ub.tax.individual no-undo.
define variable loc#log as logical no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE vunit-type like ub.units.type no-undo .

  find ub.tax where ub.tax.tax-code = taxcode no-error.
  if available ub.tax then do:
    assign
    ub.tax.tax-type = tp
    ub.tax.tax-name = l-n
    .
    do JJ = 1 TO NUM-ENTRIES(UNITTYPES):
      vUNIt-TYPE = ENTRY(jj, unittypes).
      find first ub.tax-units
        where ub.tax-units.tax-code = taxcode
          and ub.tax-units.type = vunit-type
        no-error .
      if not avail ub.tax-units then do:
        create ub.tax-units.
        assign
        ub.tax-units.tax-code = taxcode
        ub.tax-units.type = unittypes
        .
      end.
    END.
  end.
  else do:
    create ub.tax.
    assign
      ub.tax.tax-code = taxcode
      ub.tax.tax-name = l-n
      ub.tax.tax-type = tp
      ub.tax.to-cashdesk = tocashdesk
      ub.tax.individual = individ
      .
    do JJ = 1 TO NUM-ENTRIES(UNITTYPES):
      vUNIt-TYPE = ENTRY(jj, unittypes).
      find first ub.tax-units where
                ub.tax-units.tax-code = taxcode AND
                ub.tax-units.type = vunit-type
                no-error
                .
      if not avail ub.tax-units then do:
        create ub.tax-units.
        assign
        ub.tax-units.tax-code = taxcode
        ub.tax-units.type = unittypes
        .
      end.
    END.
  end.
end procedure.


ON WRITE OF ub.tax revert.