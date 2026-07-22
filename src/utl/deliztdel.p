block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: deliztdel.p $
$Archive: utl/deliztdel.p $

Проставить статус удален в АМ по товарам ИЖТ на вывод срок ожидания которых прошел

Автор: Чернова Светлана Александровна
Дата создания: 08/03/09
Author: Svetlana Chernova
Creation date: 08/03/09

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: deliztdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/deliztdel.p $":U .
define variable vss-description as character no-undo init "Проставить статус удален в АМ по товарам ИЖТ на вывод срок ожидания которых прошел".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/thbjattr.i }
{ ref/gds-matl.i }

define buffer buf_gds-obj-prop for ub.gds-obj-prop.
define buffer buf_gds-obj-prop-attr  for ub.gds-obj-prop-attr.
define buffer buf_assortment-matrix for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_goods for ub.goods  .

define variable l-exist-iztdel as log no-undo .
define variable v-srok as integer   no-undo .
define variable v-date-corr as date no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-sts as integer   no-undo .
define variable v-log as logical   no-undo .
define variable v-kol as integer   no-undo .

define variable v-user-action                as   character                   no-undo.
define variable v-printed                    as   logical                     no-undo.

define stream str-err.

  do
  on error undo, return error return-value
  :
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
 if not v-log then return no-apply .

  empty temp-table thbjattr_thbj-attr .
  run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input {&attr-ass-obj}
      ,input {&attr-Ass-obj_ass-srokiztdel}
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-srok
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .


   l-exist-iztdel = false   .
   v-kol = 0 .
   if not ( v-srok = 0  or v-srok = ? ) then do:
   for each buf_assortment-matrix no-lock where
            buf_assortment-matrix.asmt-status = 0 and
            buf_assortment-matrix.asmt-type = {&type-assmatr-obj} ,
   each buf_assortment-matrix-goods no-lock where
        buf_assortment-matrix-goods.asmg-status = 0 and
        buf_assortment-matrix-goods.asmt-id = buf_assortment-matrix.asmt-id and
        buf_assortment-matrix-goods.db-num  = buf_assortment-matrix.db-num ,
       first buf_gds-obj-prop no-lock WHERE
             buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code  AND
             buf_gds-obj-prop.gdop-igt = {&ass-izd-del} AND
             buf_gds-obj-prop.obj-code = buf_assortment-matrix.obj-code  AND
             buf_gds-obj-prop.obj-type = buf_assortment-matrix.obj-type  ,
                EACH buf_gds-obj-prop-attr no-lock WHERE
                     buf_gds-obj-prop-attr.gds-code = buf_gds-obj-prop.gds-code AND
                     buf_gds-obj-prop-attr.obj-code = buf_gds-obj-prop.obj-code AND
                     buf_gds-obj-prop-attr.obj-type = buf_gds-obj-prop.obj-type and
                     buf_gds-obj-prop-attr.attr-code = {&gopattr-CorrIztDel}
                     :
            v-date-corr = date(int(substring(buf_gds-obj-prop-attr.attr-value,4,2)) , int(substring(buf_gds-obj-prop-attr.attr-value,1,2)),int(substring(buf_gds-obj-prop-attr.attr-value,7,4))) no-error .
            if v-date-corr = ? then v-date-corr = today .
            if today - v-date-corr >= v-srok then do:
              /* Удаляем из АМ */
              v-sts = ? .
              { ref/gds-mat2.i
                this-procedure
                recid(buf_assortment-matrix-goods)
                v-sts
                false
                no-error }

                v-kol = v-kol + 1.
                find first buf_goods no-lock where
                           buf_goods.gds-code = buf_assortment-matrix-goods.gds-code no-error .

                output stream str-err to value( "autodelAM.txt" ) append.
                put    stream str-err unformatted
                       string(today , "99/99/9999")     {&tabulation}
                       string(time , "hh:mm:ss")        {&tabulation}
                       buf_assortment-matrix.obj-type
                       buf_assortment-matrix.obj-code   {&tabulation}
                       buf_assortment-matrix-goods.gds-code   {&tabulation}
                       string (v-date-corr , "99/99/9999" )   {&tabulation}
                       buf_goods.gds-name  {&tabulation}
                       return-value  {&tabulation}
                       error-status :get-message(1)
                       {&new-line}.
                output stream str-err close.
            end.
    end.
    end.

 end.

if v-kol > 0 then do:
    run gbl/prnfilen.w
      (input  substitute(" Удалены из АМ товары, срок ИЖТ превысил &1 дней" , v-srok)
      ,input  0
      ,input  "autodelAM.txt"
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
end.