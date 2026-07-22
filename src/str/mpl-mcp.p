block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mpl-mcp.p $
$Archive: str/mpl-mcp.p $

Методы расчета цены в мн прайслистах

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

{&bef-pr-calc-old}    -  СтараЯ
{&bef-pr-calc-new}    -  НоваЯ
{&bef-pr-calc-obj}    -  Объект
{&bef-pr-calc-wbill}  -  НакладнаЯ
{&bef-pr-calc-ov}     -  Переоценка
{&bef-pr-common}      -  ЕдинаЯ


*/
define temp-table x_obj-group no-undo like ub.clients  .

define input parameter  p-price-type as character no-undo .
define input parameter  table for x_obj-group .
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define input parameter  p-disc       as decimal no-undo .
define input parameter  p-doc-num    as character no-undo .
define input parameter  v-vat-pc     like doc-line.vat-pc     no-undo.
define input parameter  v-slt-pc     like doc-line.slt-pc     no-undo.
define input parameter p-common-price as decimal   no-undo .

define output parameter p-calc-base   as decimal    no-undo .
define output parameter p-calc-rubl   as decimal    no-undo .
define output parameter p-price-base  as decimal    no-undo .
define output parameter p-price-rubl  as decimal    no-undo .
define output parameter p-road-tax-base as decimal  no-undo .
define output parameter p-road-tax-rubl as decimal  no-undo .





define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mpl-mcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/mpl-mcp.p $":U .
define variable vss-description as character no-undo init "Методы расчета цены в мн прайслистах".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/croslist.i     }
{ gbl/clntattr.i     }
{ str/hvrdtax.i      }
{ str/lastincs.i     }

&glob  start-proc  do on error undo  ~
, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):



define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }
    case p-price-type :
        when {&pr-common} then do:
            assign
              p-price-rubl= p-common-price
              .
        end.
    end case.