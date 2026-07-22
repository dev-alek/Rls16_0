block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: utl-shpr.p $
$Archive: utl/utl-shpr.p $

Утилита пересчета  переоценок на сменном объекте после обрезания.

Автор: Чернова Светлана Александровна
Дата создания: 08/09/06
Author: Svetlana Chernova
Creation date: 08/09/06

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: utl-shpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/utl-shpr.p $":U .
define variable vss-description as character no-undo init "Утилита пересчета  переоценок на сменном объекте после обрезания.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/waitfram.i }

define variable v-shift-end-fact-order as decimal no-undo . /* номер конца смены                    */
define variable v-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */



for each ub.shop no-lock ,
   first  ub.shift-obj no-lock where
          ub.shift-obj.obj-type = {&shop} and
          ub.shift-obj.obj-code = ub.shop.obj-code :
    run waitfram-show in this-procedure ( " Пересчет переоценок по сменам маг " + string (ub.shift-obj.obj-code) ) .
    run p1 ( input ub.shift-obj.obj-type,
             input ub.shift-obj.obj-code ) .
end.

for each ub.store no-lock ,
   first  ub.shift-obj no-lock where
          ub.shift-obj.obj-type = {&stock} and
          ub.shift-obj.obj-code = ub.store.obj-code :
    run waitfram-show in this-procedure ( " Пересчет переоценок по сменам скл " + string (ub.shift-obj.obj-code) ) .
    run p1 ( input ub.shift-obj.obj-type,
             input ub.shift-obj.obj-code ) .
end.
run waitfram-hide in this-procedure  .
return.



procedure p1 :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
   do
   on error undo, return error return-value
   :
for each ub.price-doc exclusive-lock where
         ub.price-doc.obj-type = p-obj-type and
         ub.price-doc.obj-code = p-obj-code and
         ub.price-doc.status_ = {&act-overvalue} and
         ub.price-doc.shift-num  = ? and
         ub.price-doc.shift-date = ? and
         ub.price-doc.fact-num < 3  :
      assign
            ub.price-doc.shift-num  = ub.price-doc.fact-num
            ub.price-doc.shift-date = ub.price-doc.fact-date
      .
      run factord in this-procedure  (
             input  ub.price-doc.fact-date
            ,input  time
            ,input  ub.price-doc.fact-num
            ,input  ub.price-doc.shift-date
            ,input  ub.price-doc.shift-num
            ,input  true
            ,output ub.price-doc.fact-order
            ,output v-shift-end-fact-order
            ,output v-day-end-fact-order
            ).
   end.
   end.

 end procedure. /* p1 */

