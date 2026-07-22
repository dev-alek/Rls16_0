block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: contr-part.p $
$Archive: utl/contr-part.p $

Проверка и правка партий на соответствие догора и контрагента

Автор: Чернова Светлана Александровна
Дата создания: 01/12/10
Author: Svetlana Chernova
Creation date: 01/12/10

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: contr-part.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/contr-part.p $":U .
define variable vss-description as character no-undo init "Проверка и правка партий на соответствие догора и контрагента".
{ cmp/vssrevis.i }

define buffer buf_parts for ub.parts  .

for each ub.sysconf no-lock :
  for each ub.parts no-lock where
           ub.parts.host-code = ub.sysconf.host-code and
           ub.parts.contract-code > 0 :
      find first ub.contract no-lock where
           ub.contract.host-code    = ub.parts.host-code and
           ub.contract.contract-code = ub.parts.contract-code no-error .
           if available ub.contract then do:
              if not (  ub.parts.supp-code = ub.contract.cli-code and
                        ub.parts.supp-type = ub.contract.cli-type ) then do:
               find first buf_parts exclusive-lock where recid(buf_parts) = recid(ub.parts) .
                  assign
                        buf_parts.supp-code = ub.contract.cli-code
                        buf_parts.supp-type = ub.contract.cli-type
                  .
                  find first ub.goods no-lock where
                             ub.goods.artic     = ub.parts.artic and
                             ub.goods.prod-type = ub.parts.prod-type and
                             ub.goods.prod-code = ub.parts.prod-code no-error .

                  find first ub.parts-attr exclusive-lock where
                             ub.parts-attr.part-code = ub.parts.part-code and
                             ub.parts-attr.in-code   = ub.parts.in-code   and
                             ub.parts-attr.gds-code  = ub.goods.gds-code  no-error .
                    if available ub.parts-attr then do:
                        if not (  ub.parts-attr.supp-code = ub.contract.cli-code and
                                  ub.parts-attr.supp-type = ub.contract.cli-type ) then do:
                        assign
                            ub.parts-attr.supp-code = ub.contract.cli-code
                            ub.parts-attr.supp-type = ub.contract.cli-type
                         .
                        end.
                    end.
              end.
           end.
  end.
end.