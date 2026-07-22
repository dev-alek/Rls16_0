block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: salestat.p $
$Archive: str/salestat.p $

Перевод статусов для продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/17/03
Author: Bakhtadze Natalya
Creation date: 11/17/03

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-inkas-code     like ub.inkas.inkas-code no-undo .
define input parameter p-close-mode     as character no-undo .
define input parameter p-status_        as character no-undo . /*тот что будет*/
define input parameter p-flag_          as logical no-undo . /*тот что будет*/
define input parameter p-silent                       as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salestat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salestat.p $":U .
define variable vss-description as character no-undo init "Перевод статусов для продажи".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/trdcalib.i }

define variable v-pre-status_ as character no-undo .
define variable v-pre-flag_   as logical no-undo .
define variable v-status_ as character no-undo .
define variable v-flag_   as logical   no-undo .
define variable v-ask-message as character no-undo .
define variable v-correct as logical no-undo .
define variable v-mess as character no-undo .

define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.

_main:
do
on error undo, return error return-value
on stop undo, return error return-value
:
  find first buf_inkas exclusive-lock where
            buf_inkas.inkas-code = p-inkas-code .
  find first buf_trn-doc exclusive-lock where
              buf_trn-doc.doc-code = p-inkas-code  .
  /*проверим еще раз!!! salegraf.p*/
  run str/salegraf.p (
                   input  buf_inkas.inkas-code
                  ,input  p-close-mode
                  ,input  buf_inkas.status_
                  ,input  buf_trn-doc.flag_
                  ,output v-status_
                  ,output v-flag_
                  ,output v-ask-message
                  ) no-error.
  if error-status:error
  then do:
    run err-mess ( substitute("Ошибка при проверке возможности открытия/закрытия:&1&2 &3"
                  ,  {&new-line}
                  , error-status:get-message(1)
                  , return-value
                  )
                  , output v-mess).
    undo _main, return error v-mess.
  end.
  if v-status_ <> p-status_
  or v-flag_ <> p-flag_
  then do:
    run err-mess ( substitute("Невозможно открыть/закрыть продажу до запрашиваемого статуса &1&2&3&4"
                  , p-status_
                  , string(p-flag_, "+/-")
                  ,  {&new-line}
                  , return-value
                  )
                  , output v-mess).
    undo _main, return error v-mess.
  end.

  if p-status_ = {&fact} then do:
    run err-mess ( substitute( "Неверный вызов процедуры - для статуса &1",   p-status_), output v-mess).
    undo _main, return error v-mess.
  end.
  if p-close-mode <> {&close-fact} then do:
    /*проверить корректность документа для перевода статуса вверх НЕ НА ФАКТ НЕВОЗМОЖНО ОТСЮДА*/
    /*навесим перевод статусов*/
    assign
    v-pre-status_ = buf_inkas.status_
    v-pre-flag_   = buf_inkas.flag_
    .

    assign
    buf_inkas.status_ = p-status_
    buf_inkas.flag_ = p-flag_
    .
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.order > 0,
    first buf_trn-doc exclusive-lock where
        buf_trn-doc.doc-code = buf_sale-doc.doc-code
    by buf_sale-doc.order
    on error undo _main, return  error return-value
    on stop undo _main, return  error return-value :
      assign
      /*buf_trn-doc.status_ = (if p-status_ = {&g___new} then {&cash-desk} else p-status_)*/
      buf_trn-doc.flag_ = p-flag_
      .
      release buf_trn-doc no-error .
      if error-status:error then do:
        run err-mess (substitute("Ошибка при смене статуса на &1&2&3&4 &5"
                                , p-status_
                                , p-flag_
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                ), output v-mess).
        undo _main, return error v-mess.
      end.
    end.
    release buf_inkas no-error .
    if error-status:error then do:
      run err-mess (substitute("Ошибка при смене статуса на &1&2&3&4 &5"
                              , p-status_
                              , p-flag_
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              ), output v-mess).
      undo _main, return error v-mess.
    end.

  end.
  else do:

  end.
end. /*doe*/


PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-mess2 as character no-undo .
  assign
  p-mess2 = substitute("ПРОДАЖА &1: &2&3&4&5"
                      , buf_inkas.inkas-code
                      , buf_inkas.obj-type
                      , buf_inkas.obj-code
                      , {&new-line}
                      , p-mess
                      ).
 if not p-silent then do:
    message
    p-mess2
    view-as alert-box error .
 end.
END PROCEDURE.