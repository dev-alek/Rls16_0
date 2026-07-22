block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирование партий МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 06/25/07
Author: Polina Gridchina
Creation date: 06/25/07


*/
define temp-table tres-wth-parts no-undo like ub.wth-parts .
define input parameter table for tres-wth-parts.
define input parameter p-param as logical no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Резервирование партий МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/wthparts.i }
{ gbl/waitfram.i }

define buffer buf_wth-doc   for wth-doc.
define buffer b_wth-parts   for wth-parts.
define variable v-rec  as recid no-undo.
define variable v-i    as integer      no-undo.
MainBlock: do
on error undo, return error return-value
:
for each tres-wth-parts where tres-wth-parts.stts = 0:
  v-rec = ?.
  run wth-parts-rezerv (
                     p-param
                    ,tres-wth-parts.fact-rangeFrom
                    ,tres-wth-parts.fact-RangeTo
                    ,tres-wth-parts.beg-dt
                    ,tres-wth-parts.end-dt
                    ,tres-wth-parts.ser-code
                    ,tres-wth-parts.db-num
                    ,tres-wth-parts.price-rubl
                    ,tres-wth-parts.price-base
                    ,tres-wth-parts.vat-pc
                    ,tres-wth-parts.host-code
                    ,tres-wth-parts.obj-type
                    ,tres-wth-parts.obj-code
                    ,tres-wth-parts.w-p-code
                    ,tres-wth-parts.wth-code
                    ,tres-wth-parts.par-code
                    ,tres-wth-parts.in-code
                    ,tres-wth-parts.out-code
                    ,tres-wth-parts.cli-type
                    ,tres-wth-parts.cli-code
                    ,tres-wth-parts.ext-doc-type
                    ,tres-wth-parts.gds-code
                    ,tres-wth-parts.type
                    ,input-output v-rec
                   ) no-error.
  if error-status:error then do:
      if not g#news then   undo MainBlock, return error  return-value.
    /*  если при приеме новостей и проблема в отсутствии партии для резервирования, то перебираем по одному номеру, чтобы выделить корректные */
      if return-value = 'forged' then do:
        if tres-wth-parts.fact-rangeFrom = tres-wth-parts.fact-rangeTo
        then do:  /*если партия из одного талона сразу кладем в фальш. зону*/
          run CreateForgedParts(input tres-wth-parts.fact-rangeFrom )  no-error.
          if error-status:error then undo MainBlock, return error  return-value.
        end.
        else  do v-i = tres-wth-parts.fact-rangeFrom to tres-wth-parts.fact-rangeTo:
          run waitfram-show in this-procedure ( input substitute("Не удалось зарезервировать партию целиком (документ &2). Резервирование по номеру &1",v-i,tres-wth-parts.out-code) ).
          v-rec = ?.
            run wth-parts-rezerv (
                      p-param
                      ,v-i
                      ,v-i
                      ,tres-wth-parts.beg-dt
                      ,tres-wth-parts.end-dt
                      ,tres-wth-parts.ser-code
                      ,tres-wth-parts.db-num
                      ,tres-wth-parts.price-rubl
                      ,tres-wth-parts.price-base
                      ,tres-wth-parts.vat-pc
                      ,tres-wth-parts.host-code
                      ,tres-wth-parts.obj-type
                      ,tres-wth-parts.obj-code
                      ,tres-wth-parts.w-p-code
                      ,tres-wth-parts.wth-code
                      ,tres-wth-parts.par-code
                      ,tres-wth-parts.in-code
                      ,tres-wth-parts.out-code
                      ,tres-wth-parts.cli-type
                      ,tres-wth-parts.cli-code
                      ,tres-wth-parts.ext-doc-type
                      ,tres-wth-parts.gds-code
                      ,tres-wth-parts.type
                      ,input-output v-rec
                    ) no-error.
          if error-status:error then do:
            if return-value = 'forged':U then do:
                run CreateForgedParts(input v-i ) no-error.
                if error-status:error then undo, return error  return-value + error-status:get-message(1) .
            end.
            else  do:
              run waitfram-hide in this-procedure .
              undo MainBlock, return error  return-value.
            end.
          end.
        end.   /*v-i*/
        run waitfram-hide in this-procedure .
      end.
   end.
end.  /*for each*/
end.   /*MainBlock*/
procedure CreateForgedParts:
define input parameter  p-i as int no-undo.
run str/wthpartp.p  ( INPUT {&add-def},
                  INPUT  tres-wth-parts.obj-type,
                  INPUT  tres-wth-parts.obj-code,
                  INPUT  tres-wth-parts.w-p-code,
                  INPUT  tres-wth-parts.wth-code,
                  INPUT  tres-wth-parts.par-code,
                  INPUT  {&forged},
                  INPUT  tres-wth-parts.out-code,
                  INPUT  tres-wth-parts.ser-code,
                  INPUT  tres-wth-parts.db-num  ,
                  INPUT  p-i ,
                  INPUT  p-i ,
                  INPUT  p-i ,
                  INPUT  p-i ,
                  INPUT  tres-wth-parts.host-code     ,
                  INPUT  tres-wth-parts.contract-code   ,          /* p-contract-code   */
                  INPUT  tres-wth-parts.price-rubl    ,
                  INPUT  tres-wth-parts.price-base    ,
                  INPUT  tres-wth-parts.supp-type,      /* p-supp-type       */
                  INPUT  tres-wth-parts.supp-code,      /*p-supp-code        */
                  INPUT  tres-wth-parts.in-obj-type      ,          /*p-in-obj-type     */
                  INPUT  tres-wth-parts.in-obj-code      ,          /*p-in-obj-code     */
                  INPUT  tres-wth-parts.ext-doc-type,  /*p-ext-doc-type    */
                  INPUT  tres-wth-parts.gds-code,      /*p-gds-code        */
                  INPUT  0           ,          /*p-stts            */
                  INPUT  tres-wth-parts.beg-dt        ,
                  INPUT  tres-wth-parts.end-dt        ,
                  INPUT  tres-wth-parts.vat-pc      ,
                  INPUT  tres-wth-parts.cli-code,                         /*p-cli-code        */
                  INPUT  tres-wth-parts.cli-type,                      /*p-cli-type        */
                  INPUT  tres-wth-parts.out-obj-code,                         /*p-out-obj-code    */
                  INPUT  tres-wth-parts.out-obj-type,                      /*p-out-obj-type    */
                  INPUT  tres-wth-parts.sale-obj-code,                         /*p-sale-obj-code   */
                  INPUT  tres-wth-parts.sale-obj-type,                      /*p-sale-obj-type   */
                  INPUT  tres-wth-parts.doc-code,
                  INPUT  yes,
                  INPUT tres-wth-parts.type,
                  INPUT-OUTPUT v-rec
                  ) no-error.
              if error-status:error then undo, return error return-value + error-status:get-message(1) .

end procedure.