block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: nwswthrs.p $
$Archive: str/nwswthrs.p $

Процедура резервирования партий документа при приеме новостей

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/07/07
Author: Polina Gridchina
Creation date: 09/07/07

Input:

Output:

*/
define input parameter p-doc-code as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: nwswthrs.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/nwswthrs.p $":U .
define variable vss-description as character no-undo init "Процедура резервирования партии при приеме новостей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/wthparts.i }
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wth-doc     for ub.wth-doc.
define variable v-rec      as recid        no-undo.
do
on error undo, return error return-value
:
   find first buf_wth-doc exclusive-lock
    where buf_wth-doc.doc-code = p-doc-code
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ МЦ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
  for each buf_wth-parts exclusive-lock where
           buf_wth-parts.out-code = buf_wth-doc.doc-code
             on error undo, return error
  :
    v-rec = ?.
    run wth-parts-rezerv in this-procedure  (
                     input yes
                    ,input buf_wth-parts.fact-rangeFrom
                    ,input buf_wth-parts.fact-RangeTo
                    ,input buf_wth-parts.beg-dt
                    ,input buf_wth-parts.end-dt
                    ,input buf_wth-parts.ser-code
                    ,input buf_wth-parts.db-num
                    ,input buf_wth-parts.price-rubl
                    ,input buf_wth-parts.price-base
                    ,input buf_wth-parts.vat-pc
                    ,input buf_wth-parts.host-code
                    ,input buf_wth-parts.obj-type
                    ,input buf_wth-parts.obj-code
                    ,input buf_wth-parts.w-p-code
                    ,input buf_wth-parts.wth-code
                    ,input buf_wth-parts.par-code
                    ,input buf_wth-parts.in-code
                    ,input buf_wth-parts.out-code
                    ,input buf_wth-parts.cli-type
                    ,input buf_wth-parts.cli-code
                    ,input buf_wth-parts.ext-doc-type
                    ,input buf_wth-parts.gds-code
                    ,input buf_wth-parts.type
                    ,input-output v-rec
                   ) no-error.
    if error-status:error then do:
      if return-value = 'forged' then do:
                message substitute("Не найдена партия МЦ для резервирования &1Код МЦ &2&1Номинал &3&1Серия &4&1Диапазон с &5 по &6&1
                                        ",{&new-line}
                                        ,buf_wth-parts.wth-code
                                        ,buf_wth-parts.par-code
                                        ,buf_wth-parts.ser-code
                                        ,buf_wth-parts.fact-rangeFrom
                                        ,buf_wth-parts.fact-rangeTo)  skip
                         'Партия будет помечена как фальшивая!'
                                        view-as alert-box.
         assign buf_wth-parts.in-code = {&forged}.
      end.
      else do:
        undo, return error  return-value.
      end.
    end.
  end.
end.