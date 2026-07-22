block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выполнение различных проверок объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 01/19/01
Author: Mikhail Pervakov
Creation date: 01/19/01

p-action
  check-open - проверить отсутствие открытых документов

*/

define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-action   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выполнение различных проверок объекта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block:
do
on error undo main-block, return error
:

  if p-action <> "check-open":u then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "p-action" p-action skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  run check-trn-doc   in this-procedure .

  run check-price-doc in this-procedure .

  run check-ord-doc in this-procedure .

  run check-fbr-doc   in this-procedure .

  run check-inkas     in this-procedure .

  run check-rvs-doc   in this-procedure .

  run check-shift-obj in this-procedure .

  run check-wth-doc   in this-procedure .

  run check-icnt-doc  in this-procedure .

  run check-chk-doc   in this-procedure .

  run check-scales-gds in this-procedure .

  run check-cash-desk  in this-procedure .

  run check-wth-place  in this-procedure .

  run check-fbr-prn    in this-procedure .

  run check-fbr-prn-gds    in this-procedure .

  run check-fbr-prn-grp    in this-procedure .

  run check-stop-list    in this-procedure .

end.


procedure check-trn-doc :

  do
  on error undo, return error
  :
    define buffer buf_trn-doc for ub.trn-doc .

    find first buf_trn-doc no-lock
      where buf_trn-doc.obj-type = p-obj-type
        and buf_trn-doc.obj-code = p-obj-code
        and buf_trn-doc.status_ <> {&fact}
        and buf_trn-doc.status_ <> {&ready}
        and buf_trn-doc.status_ <> {&inquiry}
      no-error .
    if available buf_trn-doc then do:
      message
        "На объекте существуют открытые документы" skip
        "Объект" p-obj-type p-obj-code skip
        "Документ" buf_trn-doc.doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-trn-doc */


procedure check-price-doc :

  do
  on error undo, return error
  :
    define buffer buf_price-doc for ub.price-doc .

    find first buf_price-doc no-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
        and buf_price-doc.status_ <> {&act-overvalue}
      no-error .
    if available buf_price-doc then do:
      message
        "На объекте существуют открытые переоценки" skip
        "Объект" p-obj-type p-obj-code skip
        "Переоценка" buf_price-doc.doc-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.


procedure check-ord-doc :

  do
  on error undo, return error
  :
    define buffer buf_ord-doc for ub.ord-doc .

    find first buf_ord-doc no-lock
      where buf_ord-doc.obj-type = p-obj-type
        and buf_ord-doc.obj-code = p-obj-code
        and buf_ord-doc.status_ <> {&fact}
      no-error .
    if available buf_ord-doc then do:
      message
        "На объекте существуют открытые заказы" skip
        "Объект" p-obj-type p-obj-code skip
        "Заказ" buf_ord-doc.doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.


end procedure. /* check-ord-doc */


procedure check-fbr-doc :

  do
  on error undo, return error
  :
    define buffer buf_fbr-doc for ub.fbr-doc .

    find first buf_fbr-doc no-lock
      where buf_fbr-doc.obj-type = p-obj-type
        and buf_fbr-doc.obj-code = p-obj-code
        and buf_fbr-doc.status_ <> {&fact}
      no-error .
    if available buf_fbr-doc then do:
      message
        "На объекте существуют открытые документы производства" skip
        "Объект" p-obj-type p-obj-code skip
        "Документ производства" buf_fbr-doc.doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-fbr-doc */

procedure check-inkas :

  do
  on error undo, return error return-value
  :
    define buffer buf_inkas for ub.inkas .
    define variable v-fact-status-list as character no-undo .
    define variable ii as integer no-undo .
    v-fact-status-list = (if {&fact} < {&inquiry}
                          then ({&fact} + {&comma-char} + {&inquiry})
                          else ({&inquiry} + {&comma-char} + {&fact})).
    do ii = 0 to num-entries(v-fact-status-list):
      CASE ii:
        when 0 then do:
          find first buf_inkas no-lock
            where buf_inkas.obj-type = p-obj-type
              and buf_inkas.obj-code = p-obj-code
              and buf_inkas.status_ < entry(1, v-fact-status-list) no-error .
        end.
        when num-entries(v-fact-status-list) then do:
          find first buf_inkas no-lock
            where buf_inkas.obj-type = p-obj-type
              and buf_inkas.obj-code = p-obj-code
              and buf_inkas.status_ > entry(num-entries(v-fact-status-list), v-fact-status-list) no-error .
        end.
        otherwise do:
          find first buf_inkas no-lock
            where buf_inkas.obj-type = p-obj-type
              and buf_inkas.obj-code = p-obj-code
              and buf_inkas.status_ > entry(ii, v-fact-status-list)
              and buf_inkas.status_ < entry(ii + 1, v-fact-status-list)
              no-error .
        end.
      END CASE.
      if available buf_inkas then do:
        message
          "На объекте существуют открытые продажа" skip
          "Объект" p-obj-type p-obj-code skip
          "Продажа" buf_inkas.inkas-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end. /*do ii*/
  end.

end procedure. /* check-inkas */

procedure check-rvs-doc :

  do
  on error undo, return error
  :
    define buffer buf_rvs-doc for ub.rvs-doc .

    find first buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type = p-obj-type
        and buf_rvs-doc.obj-code = p-obj-code
        and buf_rvs-doc.rvs-type <> {&test-asi}
        and buf_rvs-doc.status_ <> {&fact}
      no-error .
    if available buf_rvs-doc then do:
      message
        "На объекте существуют открытые документы сверки" skip
        "Объект" p-obj-type p-obj-code skip
        "Документ сверки" buf_rvs-doc.rvs-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-rvs-doc */


procedure check-shift-obj :

  do
  on error undo, return error
  :

    define buffer buf_shift-obj for ub.shift-obj .

    find first buf_shift-obj no-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_ = {&sht-current}
      no-error .
    if available buf_shift-obj then do:
      message
        "На объекте существуют не закрытые смены" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-shift-obj */

procedure check-wth-doc :

  do
  on error undo, return error
  :
    define buffer buf_wth-doc for ub.wth-doc .

    find first buf_wth-doc no-lock
      where buf_wth-doc.obj-type = p-obj-type
        and buf_wth-doc.obj-code = p-obj-code
        and buf_wth-doc.status_ <> {&fact}
      no-error .
    if available buf_wth-doc then do:
      message
        "На объекте существуют открытые документы МЦ" skip
        "Объект" p-obj-type p-obj-code skip
        "Документ МЦ" buf_wth-doc.doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-wth-doc */

procedure check-icnt-doc :

  do
  on error undo, return error
  :
    define buffer buf_icnt-doc for ub.icnt-doc .

    find first buf_icnt-doc no-lock
      where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
        and buf_icnt-doc.status_ <> {&fact}
      no-error .
    if available buf_icnt-doc then do:
      message
        "На объекте существуют открытые документы МЦ" skip
        "Объект" p-obj-type p-obj-code skip
        "Документ МЦ" buf_icnt-doc.doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-icnt-doc */


procedure check-chk-doc :

  do
  on error undo, return error
  :
    define buffer buf_chk-doc for ub.chk-doc .

    find first buf_chk-doc no-lock
      where buf_chk-doc.obj-type = p-obj-type
        and buf_chk-doc.obj-code = p-obj-code
        and buf_chk-doc.out-code = ?
      no-error .
    if available buf_chk-doc then do:
      message
        "На объекте существуют неучтенные чеки" skip
        "Объект" p-obj-type p-obj-code skip
        "Чек"    buf_chk-doc.doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-chk-doc */


procedure check-scales-gds :

  do
  on error undo, return error
  :
    define buffer buf_scales-gds for ub.scales-gds .

    find first buf_scales-gds no-lock
      where buf_scales-gds.obj-type = p-obj-type
        and buf_scales-gds.obj-code = p-obj-code
      no-error .
    if available buf_scales-gds then do:
      message
        "На объекте существуют товары, привязанные к весам" skip
        "Объект" p-obj-type p-obj-code skip
        "Товар"  buf_scales-gds.b-code skip
        "Весы"   buf_scales-gds.scales-num
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-scales-gds */



procedure check-cash-desk :

  do
  on error undo, return error
  :
    define buffer buf_cash-desk for ub.cash-desk .
    if p-obj-type <> {&shop} then return.
    find first buf_cash-desk no-lock
      where buf_cash-desk.obj-code = p-obj-code
      no-error .
    if available buf_cash-desk then do:
      message
        "На объекте существуют кассы" skip
        "Объект" p-obj-type p-obj-code skip
        "Касса"  buf_cash-desk.cash-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-cash-desk */


procedure check-wth-place :

  do
  on error undo, return error
  :
    define buffer buf_wth-place for ub.wth-place .

    find first buf_wth-place no-lock
      where buf_wth-place.obj-type = p-obj-type
      AND buf_wth-place.obj-code = p-obj-code
      AND buf_wth-place.cash-desk <> ?
      AND buf_wth-place.cash-desk <> 0
      no-error .
    if available buf_wth-place then do:
      message
        "На объекте существуют МХ МЦк, привязанные к кассам" skip
        "Объект" p-obj-type p-obj-code skip
        "МХ МЦ"  buf_wth-place.w-p-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-wth-place */


procedure check-fbr-prn :

  do
  on error undo, return error
  :
    define buffer buf_fbr-prn for ub.fbr-prn .

    find first buf_fbr-prn no-lock
      where buf_fbr-prn.fbr-obj-type = p-obj-type
        AND buf_fbr-prn.fbr-obj-code = p-obj-code

      no-error .
    if available buf_fbr-prn then do:
      message
        "На объекте существуют принтера кухни" skip
        "Объект" p-obj-type p-obj-code skip
        "принтер"  buf_fbr-prn.prn-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-fbr-prn */


procedure check-fbr-prn-gds :

  do
  on error undo, return error
  :
    define buffer buf_fbr-prn-gds for ub.fbr-prn-gds .

    find first buf_fbr-prn-gds no-lock
      where buf_fbr-prn-gds.obj-type = p-obj-type
        AND buf_fbr-prn-gds.obj-code = p-obj-code

      no-error .
    if available buf_fbr-prn-gds then do:
      message
        "На объекте существуют товары на принтерах кухни" skip
        "Объект" p-obj-type p-obj-code skip
        "БД" buf_fbr-prn-gds.db-num skip
        "принтер"  buf_fbr-prn-gds.prn-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-fbr-prn */


procedure check-fbr-prn-grp :

  do
  on error undo, return error
  :
    define buffer buf_fbr-prn-grp for ub.fbr-prn-grp .

    find first buf_fbr-prn-grp no-lock
      where buf_fbr-prn-grp.obj-type = p-obj-type
        AND buf_fbr-prn-grp.obj-code = p-obj-code

      no-error .
    if available buf_fbr-prn-grp then do:
      message
        "На объекте существуют группы товаров для принтерах кухни" skip
        "Объект" p-obj-type p-obj-code skip
        "БД" buf_fbr-prn-grp.db-num skip
        "принтер"  buf_fbr-prn-grp.prn-num skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-fbr-prn */


procedure check-stop-list :

  do
  on error undo, return error
  :
    define buffer buf_stop-list for ub.stop-list .

    find first buf_stop-list no-lock
      where buf_stop-list.obj-type = p-obj-type
        and buf_stop-list.obj-code = p-obj-code
        and buf_stop-list.status_ <> {&fact}
      no-error .
    if available buf_stop-list then do:
      message
        "На объекте существуют открытые стоплисты" skip
        "Объект" p-obj-type p-obj-code skip
        "вид стоплиста" buf_stop-list.classif-type skip
        "стоплист" buf_stop-list.stop-list-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* check-stop-list */
