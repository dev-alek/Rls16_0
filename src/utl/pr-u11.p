block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pr-u11.p $
$Archive: utl/pr-u11.p $

Проверка переоценок по справочнику товарову которых есть цена но нет переоценок после обрезани

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 12/02/04
*/

{ cmp/str-glbl.i }
{ cmp/library.i  }
define stream out-stream .
output stream out-stream to value ( "pr-u121.txt") .
define stream err-stream .
output stream err-stream to value ( "err-121.txt") .

define variable g#log as logical   no-undo .
define variable g#ok as integer   no-undo  init 0.
define variable v-exist as logical no-undo init false .
define variable bbb as integer   no-undo .
define variable rr as recid     no-undo .
define variable str as character no-undo .

g#log =  session:SET-WAIT-STATE("GENERAL") .
define buffer buf_price-doc for ub.price-doc.
define buffer buf1_price-list for ub.price-list.
define buffer buf2_price-list for ub.price-list.


for each ub.gds-obj no-lock where ub.gds-obj.price-sale  <> 0  break by ub.gds-obj.obj-type by ub.gds-obj.obj-code :

{ gbl/gdsbcode.i ub.gds-obj.gds-code ? bbb no-error }

if bbb = ? or bbb = 0 or error-status :error then do:
     export stream err-stream
          bbb
          ub.gds-obj.artic
          ub.gds-obj.prod-code
          ub.gds-obj.prod-type
          ub.gds-obj.obj-code
          ub.gds-obj.obj-type
          ub.gds-obj.price-sale
          error-status :get-message(1)
          return-value
          skip
          .
     bbb = gds-obj.gds-code .
end.

    find first buf1_price-list exclusive-lock  where
               buf1_price-list.obj-type  = gds-obj.obj-type and
               buf1_price-list.obj-code  = gds-obj.obj-code and
               buf1_price-list.b-code    =  bbb and
               buf1_price-list.price-type =  "" and
               buf1_price-list.fact-order > 1   and
               buf1_price-list.artic     = gds-obj.artic    and
               buf1_price-list.prod-type = gds-obj.prod-type and
               buf1_price-list.prod-code = gds-obj.prod-code no-error .
    if not available buf1_price-list then do:

        g#ok = g#ok + 1.
          export stream out-stream
          bbb
          gds-obj.artic
          gds-obj.prod-code
          gds-obj.prod-type
          gds-obj.obj-code
          gds-obj.obj-type
          gds-obj.price-sale
          skip
          .
    end.

end.

output stream out-stream close.
output stream err-stream close.
g#log =  session:SET-WAIT-STATE("") .

message "ВСЕ готово в  pr-u121.txt" skip g#ok view-as alert-box .