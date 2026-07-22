block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: exp-pric.p $
$Archive: utl/exp-pric.p $

Экспорт  строк ДНЦ в текстовый файл в формате импорта

Автор: Чернова Светлана Александровна
Дата создания: 11/28/06
Author: Svetlana Chernova
Creation date: 11/28/06

create: Румянцев Юрий Александрович
*/

define input  parameter parparentproc as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-pric.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exp-pric.p $":U .
define variable vss-description as character no-undo init "Экспорт  строк ДНЦ в текстовый файл в формате импорта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }

define stream txt.
define variable g-log        as logical no-undo.
define variable loc-ref-list as character no-undo .
define variable v-dir-name   as character no-undo .
define variable v-type       as character no-undo .
define variable v-can-write  as logical   no-undo .
define variable num-rec      as integer no-undo.
define variable f-name     as character no-undo.
define variable prtroot    as integer   no-undo .
define variable name-item  as character no-undo .
define variable name-scale as character no-undo .
define variable name-bc    as character no-undo .
define variable name-gtd   as character no-undo .
define variable main-bar-code as integer   no-undo .
define variable pp as character no-undo .
define variable pd as character no-undo .

define buffer buf_gds-prt for ub.gds-prt  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_goods for ub.goods  .

g-log = no.
message "Экспорт главных цен в файл, в формате импорта." skip (2)
        "Продолжать ?"
        view-as alert-box question buttons OK-Cancel update g-log.

if not g-log then return.

find first buf_gds-prt where buf_gds-prt.node-name = {&empty-scale} no-lock no-error.
if available  buf_gds-prt then   prtroot = buf_gds-prt.prt-root.
                          else   prtroot = 0.

/******** Куда будем сохранять файлы ******************/
run gbl/dir-sel.p
 ( output v-dir-name
  ,output v-type
  ,output v-can-write
  ).
if NOT v-can-write THEN DO:
    message
      "Путь для сохранения файлов не указан."
      view-as alert-box error.
    return no-apply.
END.

run str/docsprls.w
     ( input parParentProc
     , input "all"
     , input ?
     , input ?
     , input "b-sel,b-mark":U
     , input-output loc-ref-list  ).

if loc-ref-list = "" then do:
    message
      "Документы не выбраны"
      view-as alert-box error.
    return no-apply.
END.

do num-rec = 1 to num-entries(loc-ref-list):
   find buf_price-doc-forming where recid ( buf_price-doc-forming) = integer(entry(num-rec, loc-ref-list)) no-lock.
      f-name = v-dir-name + "\" + trim(string( buf_price-doc-forming.pdf-id)) + "bd" + trim(string( buf_price-doc-forming.pdf-db)) + ".adb".

      output stream txt to value (f-name ).
      for each buf_price-doc-forming-gds no-lock  where
               buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
               buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
               buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
               buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db ,
          first buf_goods no-lock
             where buf_goods.artic     = buf_price-doc-forming-gds.artic
               and buf_goods.prod-type = buf_price-doc-forming-gds.prod-type
               AND buf_goods.prod-code = buf_price-doc-forming-gds.prod-code
               break by buf_goods.gds-code
          :
          if first-of ( buf_goods.gds-code) then do:
              display
                buf_goods.artic
                with frame ff view-as dialog-box
              title ": Экспорт ".
              pause 0.
          pp = "" .
        { gbl/gdsbcode.i buf_goods.gds-code ?  main-bar-code  }
          end.
         if main-bar-code = buf_price-doc-forming-gds.b-code then  pp = trim(string( buf_price-doc-forming-gds.price-sale-doc)) .
          if last-of (buf_goods.gds-code) then do:
              assign
              name-item = "ITEM:"
              name-scale = ""
              name-bc    = string(main-bar-code)
              pd = ""
              .
              put stream txt  unformatted
                  "ITEM:" +
                  buf_goods.artic + ";" +
                  trim(string(buf_goods.prod-code)) + ";;;"+
                  name-bc + ";" +
                  pp + ";;;;" +
                  pd + ";;;;;;" SKIP.
          end.
      END. /* for each buf_price-doc-forming-gds no-lock  */
      output close.
end. /*do num-rec = 1 to num-entries(ref-list): */

message "Экспорт ДНЦ в файл закончен."  view-as alert-box information buttons ok.