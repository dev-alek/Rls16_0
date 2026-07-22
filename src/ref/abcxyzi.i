/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура для просмотра полей в сопоставлении АВС + XYZ

Автор: Чернова Светлана Александровна
Дата создания: 03/21/07
Author: Svetlana Chernova
Creation date: 03/21/07

{1}  - тип анализа

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE prt-goods-{1} :
define input  parameter p-gds-code as integer   no-undo .
define output parameter v-izt      as character no-undo .
define output parameter v-Acc-mat  as character no-undo .
define output parameter v-Amin     as character no-undo .


define buffer buf2_analysis-gds-obj        for ub.{1}-analysis-gds-obj   .
define buffer buf2_assortment-matrix       for ub.assortment-matrix.
define buffer buf2_assortment-matrix-goods for ub.assortment-matrix-goods.
define buffer buf_analysis-obj             for ub.{1}-analysis-obj.

define variable v-old-izt  as character no-undo .
define variable v-old-amin  as character no-undo .
define variable v-old-acc-mat  as character no-undo .
define variable vt-Amin as character no-undo .
define variable t-izt   as character no-undo .
define variable t-Amin  as character no-undo .
define variable t-asm   as character no-undo .
define variable v-gdop-min-stock                as decimal   no-undo .
define variable v-grop-max-stock                as decimal   no-undo .
define variable v-grop-level-always-presence    as decimal   no-undo .
define variable v-grop-min-order                as decimal   no-undo .
    assign
      v-old-izt  = ""
      v-izt      = ""
      v-Amin     = ""
      v-old-Amin = ""
      v-acc-mat     = ""
      v-old-acc-mat = ""
      .

for each buf_analysis-obj where
         buf_analysis-obj.{1}-id = buf_abcxyz-analysis.{1}-id and
         buf_analysis-obj.db-num = buf_abcxyz-analysis.{1}-db-num
         no-lock,
        each buf2_analysis-gds-obj where
            buf2_analysis-gds-obj.obj-type = buf_analysis-obj.obj-type and
            buf2_analysis-gds-obj.obj-code = buf_analysis-obj.obj-code and
            buf2_analysis-gds-obj.gds-code = p-gds-code and
            buf2_analysis-gds-obj.{1}-id   = buf_abcxyz-analysis.{1}-id and
            buf2_analysis-gds-obj.db-num   = buf_abcxyz-analysis.{1}-db-num
            no-lock break
            by buf2_analysis-gds-obj.gds-code

            :

                find first buf2_assortment-matrix where
                      buf2_assortment-matrix.asmt-status        = 0  and
                      buf2_assortment-matrix.obj-type =  buf_analysis-obj.obj-type and
                      buf2_assortment-matrix.obj-code =  buf_analysis-obj.obj-code
                      no-lock no-error .
                find first buf2_assortment-matrix-goods where
                      buf2_assortment-matrix-goods.asmg-status        = 0  and
                      buf2_assortment-matrix-goods.asmt-id  =  buf2_assortment-matrix.asmt-id and
                      buf2_assortment-matrix-goods.db-num   =  buf2_assortment-matrix.db-num  and
                      buf2_assortment-matrix-goods.gds-code =  buf2_analysis-gds-obj.gds-code
                      no-lock no-error .

                 { gbl/gdsobjpr.i
                 buf_analysis-obj.obj-type
                 buf_analysis-obj.obj-code
                 ?
                 ?
                 ?
                 p-gds-code
                 t-amin
                 t-izt
                  v-gdop-min-stock
                  v-grop-max-stock
                  v-grop-level-always-presence
                  v-grop-min-order

                 }
             if not available buf2_assortment-matrix-goods then t-asm = "0" .
                                                           else t-asm = string(buf2_assortment-matrix-goods.asmt-id).

            if first-of(buf2_analysis-gds-obj.gds-code) then do:
                  assign
                  v-old-izt  =  t-izt
                  v-izt      =  t-izt
                  v-amin     =  t-amin
                  v-old-amin =  t-amin
                  v-acc-mat     =  t-asm
                  v-old-acc-mat =  t-asm
                  .

                  if  v-amin = 'no'  then v-amin = "не входит" .
                                     else v-amin = "входит" .
                  if v-acc-mat = "0" then v-acc-mat = "не входит" .
                                     else v-acc-mat = "входит" .
            end.

        if v-old-izt     <> t-izt            then  v-izt = "разное" .
        if v-old-amin    <> t-amin           then  v-amin = "разное" .
        if v-old-acc-mat <> t-asm            then  v-acc-mat = "разное" .

      assign
        v-old-izt     = t-izt
        v-old-amin    = t-amin
        v-old-acc-mat = t-asm
      .
end.
end procedure.