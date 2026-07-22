/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕроверка товара из сезона на пересечение с другим сезоном.

јвтор: ћорозов јлександр —ергеевич
ƒата создани€: 10/08/13
Author: Svetlana Chernova
Creation date: 10/08/13

*/

PROCEDURE chk-gdssea :

define input  parameter p-gds-code as integer no-undo.
define input  parameter p-seaobj as character no-undo.
define input  parameter p-i-date1 as integer no-undo.
define input  parameter p-i-date2 as integer no-undo.
define input  parameter p-rowid as rowid no-undo.  /*провер€емый сезон, нужно только, если сезон создан. если не создан, а предполагаетс€ только создание после проверки то ?*/
define output parameter p-sea-code as integer no-undo. /*сезон, где есть пересечение.*/
define output parameter p-db-num as integer no-undo. /*сезон, где есть пересечение.*/
define output parameter p-ok as logical no-undo init yes.

define buffer buf_season for ub.season.
define buffer buf1_season for ub.season.

define buffer buf1_gds-season for ub.gds-season.

define buffer buf_season-attr for ub.season-attr.
define buffer buf1_season-attr for ub.season-attr.

  for each buf1_season no-lock where ((buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1)
    or (buf1_season.sea-month-1 <= p-i-date2 and buf1_season.sea-month-2 >= p-i-date2)
    or (buf1_season.sea-month-1 <= p-i-date1 and buf1_season.sea-month-2 >= p-i-date1))
    and (rowid (buf1_season) <> p-rowid or p-rowid = ?):
      if can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                            and buf1_season-attr.db-num = buf1_season.db-num
                                            and buf1_season-attr.attr-code = {&seaattr-obj} 
                                            and buf1_season-attr.attr-value = p-seaobj
                                            ) 
        or 
        (not can-find (first buf1_season-attr where buf1_season-attr.sea-code = buf1_season.sea-code
                                              and buf1_season-attr.db-num = buf1_season.db-num
                                              and buf1_season-attr.attr-code = {&seaattr-obj}
                                              )
        and p-seaobj = "")
      then do:
        if can-find (first buf1_gds-season where  buf1_gds-season.sea-code = buf1_season.sea-code 
                                              and buf1_gds-season.db-num = buf1_gds-season.db-num 
                                              and buf1_gds-season.gds-code = p-gds-code)
        then do:
        assign
          p-ok = false
          p-sea-code = buf1_season.sea-code
          p-db-num = buf1_season.db-num.
          leave.
        end.
      end.
  end.
  

END PROCEDURE.