block-level on error undo, throw.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-action   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выполнение различных проверок объекта".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
        and buf_trn-doc.status_ <> 'факт':U
        and buf_trn-doc.status_ <> 'готов':U
        and buf_trn-doc.status_ <> 'запрос':U
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
end procedure.
procedure check-price-doc :
  do
  on error undo, return error
  :
    define buffer buf_price-doc for ub.price-doc .
    find first buf_price-doc no-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
        and buf_price-doc.status_ <> 'акт':U
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
        and buf_ord-doc.status_ <> 'факт':U
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
end procedure.
procedure check-fbr-doc :
  do
  on error undo, return error
  :
    define buffer buf_fbr-doc for ub.fbr-doc .
    find first buf_fbr-doc no-lock
      where buf_fbr-doc.obj-type = p-obj-type
        and buf_fbr-doc.obj-code = p-obj-code
        and buf_fbr-doc.status_ <> 'факт':U
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
end procedure.
procedure check-inkas :
  do
  on error undo, return error return-value
  :
    define buffer buf_inkas for ub.inkas .
    define variable v-fact-status-list as character no-undo .
    define variable ii as integer no-undo .
    v-fact-status-list = (if 'факт':U < 'запрос':U
                          then ('факт':U + chr(44) + 'запрос':U)
                          else ('запрос':U + chr(44) + 'факт':U)).
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
    end.
  end.
end procedure.
procedure check-rvs-doc :
  do
  on error undo, return error
  :
    define buffer buf_rvs-doc for ub.rvs-doc .
    find first buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type = p-obj-type
        and buf_rvs-doc.obj-code = p-obj-code
        and buf_rvs-doc.rvs-type <> 'проверка':U
        and buf_rvs-doc.status_ <> 'факт':U
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
end procedure.
procedure check-shift-obj :
  do
  on error undo, return error
  :
    define buffer buf_shift-obj for ub.shift-obj .
    find first buf_shift-obj no-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.status_ = 'тек':U
      no-error .
    if available buf_shift-obj then do:
      message
        "На объекте существуют не закрытые смены" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure check-wth-doc :
  do
  on error undo, return error
  :
    define buffer buf_wth-doc for ub.wth-doc .
    find first buf_wth-doc no-lock
      where buf_wth-doc.obj-type = p-obj-type
        and buf_wth-doc.obj-code = p-obj-code
        and buf_wth-doc.status_ <> 'факт':U
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
end procedure.
procedure check-icnt-doc :
  do
  on error undo, return error
  :
    define buffer buf_icnt-doc for ub.icnt-doc .
    find first buf_icnt-doc no-lock
      where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
        and buf_icnt-doc.status_ <> 'факт':U
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
end procedure.
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
end procedure.
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
end procedure.
procedure check-cash-desk :
  do
  on error undo, return error
  :
    define buffer buf_cash-desk for ub.cash-desk .
    if p-obj-type <> 'маг':U then return.
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
end procedure.
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
end procedure.
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
end procedure.
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
end procedure.
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
end procedure.
procedure check-stop-list :
  do
  on error undo, return error
  :
    define buffer buf_stop-list for ub.stop-list .
    find first buf_stop-list no-lock
      where buf_stop-list.obj-type = p-obj-type
        and buf_stop-list.obj-code = p-obj-code
        and buf_stop-list.status_ <> 'факт':U
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
end procedure.
