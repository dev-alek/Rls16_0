block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: s-coeff1.p $
$Archive: ref/s-coeff1.p $

Сохранение изменений сезонных коэффициентов товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/03/05
Author: Bakhtadze Natalya
Creation date: 04/03/05

*/

define input parameter p-mode            as character no-undo .
define input parameter p-gds-code        like ub.s-coeff.gds-code no-undo .
define input parameter p-host-code       like ub.s-coeff.host-code no-undo .
define input parameter p-obj-type        like ub.s-coeff.obj-type no-undo .
define input parameter p-obj-code        like ub.s-coeff.obj-code no-undo .
define temp-table tt0-s-coeff no-undo like ub.s-coeff.
DEFINE INPUT PARAMETER TABLE FOR tt0-s-coeff.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: s-coeff1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/s-coeff1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменеий сезонных коэффициентов товара".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable v-recid as recid no-undo .
define variable v-err-mess as character no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_s-coeff for ub.s-coeff.

_main:
do
on error undo, return error return-value
:
  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods then do:
    undo, return error substitute("&1 &2 &3&4Не найден товар с кодом &5"
                                 , vss-workfile
                                 , vss-revision
                                 , vss-description
                                 , {&new-line}
                                 , p-gds-code).
  end.
  /*обновим s-coeff */
  FOR EACH tt0-s-coeff:
      find FIRST buf_s-coeff WHERE
                buf_s-coeff.gds-code = p-gds-code
            AND buf_s-coeff.host-code = tt0-s-coeff.host-code
            AND buf_s-coeff.obj-type  = tt0-s-coeff.obj-type
            AND buf_s-coeff.obj-code  = tt0-s-coeff.obj-code
            AND buf_s-coeff.s-date  = tt0-s-coeff.s-date  no-error.
    IF not available buf_s-coeff
    or buf_s-coeff.coeff-value <> tt0-s-coeff.coeff-value   THEN DO:
      if available buf_s-coeff then v-recid = recid(buf_s-coeff).
      run ref/scoeff01.p (
                              input-output v-recid
                              ,input (if available buf_s-coeff then {&update} else {&add-def})
                              ,input p-gds-code
                              ,input tt0-s-coeff.host-code
                              ,input tt0-s-coeff.obj-type
                              ,input tt0-s-coeff.obj-code
                              ,input tt0-s-coeff.s-date
                              ,input tt0-s-coeff.coeff-value
                              ) no-error.
      IF ERROR-STATUS:ERROR THEN DO:
        assign
        v-err-mess = substitute("Ошибка при сохранении сезонного коэффициента товара &1 фирма &2 объект &3 дата &4:&5&6 &7"
                                , p-gds-code
                                , tt0-s-coeff.host-code
                                , (tt0-s-coeff.obj-type + string(tt0-s-coeff.obj-code))
                                , (string(day(tt0-s-coeff.s-date)) + {&slash-char} + string(month(tt0-s-coeff.s-date)))
                                , {&new-line}
                                ,error-status:get-message(1)
                                ,return-value).
        undo _main, return error v-err-mess.
      END.
    END.
  END.
  if p-mode <> {&add-def} then do:
    FOR EACH buf_s-coeff where buf_s-coeff.gds-code = p-gds-code:
        FIND FIRST tt0-s-coeff NO-LOCK WHERE
            tt0-s-coeff.gds-code = p-gds-code
        AND tt0-s-coeff.host-code = buf_s-coeff.host-code
        AND tt0-s-coeff.obj-type  = buf_s-coeff.obj-type
        AND tt0-s-coeff.obj-code  = buf_s-coeff.obj-code
        AND tt0-s-coeff.s-date  = buf_s-coeff.s-date  no-error.
      IF NOT AVAILABLE tt0-s-coeff THEN DO:
        if buf_s-coeff.host-code = 0
        AND buf_s-coeff.obj-type = "":U
        AND buf_s-coeff.obj-code = 0
        AND buf_s-coeff.s-date = {&s-coeff-start-date} then next.
        delete buf_s-coeff no-error.
        IF error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении сезонного коэффициента товара &1 фирма &2 объект &3 дата &4:&5&6 &7"
                                  , p-gds-code
                                  , buf_s-coeff.host-code
                                  , (tt0-s-coeff.obj-type + string(tt0-s-coeff.obj-code))
                                  , (string(day(tt0-s-coeff.s-date)) + {&slash-char} + string(month(tt0-s-coeff.s-date)))
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          undo _main, return error v-err-mess.

        END.
      END.
    END.
  end.
end. /*doe*/


