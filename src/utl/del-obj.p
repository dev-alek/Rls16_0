block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-obj.p $
$Archive: utl/del-obj.p $

Удаление объекта и всех связанных таблиц

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

Необходимо запустить во всех базах данных
Никаких проверок на наличие документов не производитс

TODO - необходимо удалять таблицу config, имеющую привязку к объекту

*/

define input  parameter p-obj-list           as character no-undo .
define input  parameter p-check-rest         as logical   no-undo .
define input  parameter p-pswd-list          as character no-undo .
define input  parameter p-check-string-file  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-obj.p $":U .
define variable vss-description as character no-undo init "Удаление объекта и всех связанных таблиц".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/clntattr.i }
{ cmp/library.i  }
{ trg/doclslib.i }
{ gbl/key-rec.i  }
{ cmp/trg-def.i  }
{ ref/def-hash.i }
{ ref/extclass.i }
define stream slog .

on delete of ub.nws-doc-hist override do: end.

do
on error undo, return error return-value
:
  define variable v-password-check-string as character no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl .

  define variable v-current-action as character no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-start-time     as integer   no-undo .
  define variable v-uniq-key-rec as character no-undo .

  define variable v-ind      as integer   no-undo .
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer   no-undo .
  define variable v-passwd   as character no-undo .

  assign
    v-start-time = time
  .

  def frame show-act
    v-current-action         format "x(50)"      no-label skip
    v-current-time           format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Удаление объекта"
    .
  view frame show-act.

  run log-information in this-procedure
    (input "check-input-parameters"
    ) .

  run check-input-parameters in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заданы входные параметры" skip
      "Пароли " p-pswd-list skip
      view-as alert-box error .
    undo, return error .
  end.

  find first buf_sys-ctrl no-lock .

  if g#news <> true then do:

    if buf_sys-ctrl.db-num <> 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Данная утилита предназначена для работы только в ГБД" ) skip
        view-as alert-box error
      .
      undo, return error .
    end.

    /* не указан пароль */
    /* и задано имя файла для записи параметров */
    if  p-pswd-list = ""
    and p-check-string-file <> "" then do:
      output stream slog to value(p-check-string-file) .
      put stream slog unformatted "":U .
      output stream slog close .
      do v-ind = 1 to num-entries( p-obj-list, {&comma-char} ) by 2
      :
        assign
          v-obj-type = entry( v-ind, p-obj-list, {&comma-char} )
          v-obj-code = integer( entry( v-ind + 1, p-obj-list, {&comma-char} ) )
        .

        run generate-check-string in this-procedure
          ( input v-obj-type
          , input v-obj-code
          , output v-password-check-string
        ) .
        output stream slog to value(p-check-string-file) append.
        put stream slog unformatted v-password-check-string + {&new-line} .
        output stream slog close .
      end.

      message
        "Информация о параметрах запуска сохранена в файле" skip
        "Имя файла" p-check-string-file skip
        "Отправьте файл в службу поддержки пользователей для получения лицензии" skip
        "на запуск программы с указанными параметрами." skip
        "По получению лицензии запустите утилиту еще раз." skip
        view-as alert-box information .
      return .
    end.
    else do:
      define variable v-check-passwd as character no-undo .
      do v-ind = 1 to num-entries( p-obj-list, {&comma-char} ) by 2
      :
        assign
          v-obj-type = entry( v-ind, p-obj-list, {&comma-char} )
          v-obj-code = integer( entry( v-ind + 1, p-obj-list, {&comma-char} ) )
          v-passwd   = entry( integer((v-ind + 1) / 2), p-pswd-list, {&comma-char} )
        .
        run generate-check-string in this-procedure
          ( input v-obj-type
          , input v-obj-code
          , output v-password-check-string
          ) .
        run adm/pswd-enc.p
          (input  v-password-check-string
          ,output v-check-passwd
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке пароля"
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-passwd <> v-check-passwd then do:
          message
            "Неправильный пароль" skip
            "Параметры запуска программы" v-password-check-string skip
            substitute( "Объект &1 &2", v-obj-type, v-obj-code ) skip
            substitute( "Пароль &1", v-passwd ) skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

  do v-ind = 1 to num-entries( p-obj-list, {&comma-char} ) by 2
  :
    assign
      v-obj-type = entry( v-ind, p-obj-list, {&comma-char} )
      v-obj-code = integer( entry( v-ind + 1, p-obj-list, {&comma-char} ) )
      frame show-act:title = substitute( "Удаление объекта &1 &2", v-obj-type, v-obj-code )
    .

    run log-information in this-procedure
      (input substitute( "Удаление объекта &1 &2", v-obj-type, v-obj-code )
      ) .

    run log-information in this-procedure
      (input "check-can-delete"
      ) .

    run check-can-delete in this-procedure
        ( input v-obj-type
        , input v-obj-code
      ) no-error .
    if error-status :error then do:
      message
        "Невозможно произвести удаление объекта" skip
        "Удаление объекта может привести к нарушению работы других объектов" skip
        view-as alert-box error .
      undo, return error .
    end.

    if p-check-rest then do:

      run log-information in this-procedure
        (input "utl/delobjck.p"
        ) .
      run utl/delobjck.p
        (input v-obj-type
        ,input v-obj-code
        ) no-error .
      if error-status :error then do:
        message
          "Невозможно провести удаление объекта" skip
          "На объекте существуют товарные остатки или незакрытые документы" skip
          view-as alert-box error .
        undo, return error .
      end.
    end.


/*        /* delete-clients */   */
/*        {&comma} + "cash-desk"*/
/*        {&comma} + "c-cash-desk"*/
/*        {&comma} + "cash-desk-attr"*/
/*        {&comma} + "c-cash-desk-attr"*/
/*        {&comma} + "cd-clu"*/
/*        {&comma} + "c-cd-clu"*/
/*        {&comma} + "cd-dlu"*/
/*        {&comma} + "c-cd-dlu"*/
/*        {&comma} + "cd-grp"*/
/*        {&comma} + "c-cd-grp"*/
/*        {&comma} + "cd-plu"*/
/*        {&comma} + "c-cd-plu"*/
/*        {&comma} + "cd-doc"*/
/*        {&comma} + "c-cd-doc"*/
/*        {&comma} + "cd-doc-line"*/
/*        {&comma} + "c-cd-doc-line"*/
/*        {&comma} + "cash-pay-attr"*/
/*        {&comma} + "c-cash-pay-attr"*/
/*        {&comma} + "dis-cp-rule"*/
/*        {&comma} + "cash-rest"*/
/*        {&comma} + "clients"*/
/*        {&comma} + "c-clients"*/
/*        {&comma} + "clients-attr"*/
/*        {&comma} + "c-clients-attr"*/
/*        {&comma} + "thbj-attr"*/
/*        {&comma} + "c-thbj-attr"*/
/*        {&comma} + "shop"*/
/*        {&comma} + "c-shop"*/
/*        {&comma} + "store"*/
/*        {&comma} + "c-store"*/
/*        {&comma} + "curr-shop"*/

          /* delete-chk-doc */
/*        {&comma} + "chk-doc"*/
/*                   "chk-gds"*/
/*        {&comma} + "chk-pay"*/
/*        {&comma} + "chk-discnt"*/
/*        {&comma} + "chk-doc-attr"*/
/*        {&comma} + "c-chk-doc"*/
/*        {&comma} + "c-chk-gds"*/
/*        {&comma} + "c-chk-pay"*/
/*        {&comma} + "c-chk-discnt"*/
/*        {&comma} + "c-chk-doc-attr"*/




          /* delete-inkas */
/*        {&comma} + "inkas"*/
/*                   "inkas-pay"*/
/*                   "inkas-pay-desk"*/
/*                   "inkas-pay-wth"*/
/*        {&comma} + "c-inkas"*/
/*                   "c-inkas-pay"*/
/*                   "c-inkas-pay-desk"*/
/*                   "c-inkas-pay-wth"*/


          /* delete-trn-doc */
/*        {&comma} + "trn-doc"*/
/*        {&comma} + "doc-line"*/
/*        {&comma} + "gds-dtl"*/
/*        {&comma} + "doc-pl"*/
/*        {&comma} + "doc-pl-pump"*/
/*                   "gds-pl"*/
/*                   "doc-prts"*/
/*                   "doc-line-attr"*/
/*                   "inv-line"*/
/*                   "doc-fbr-gds"*/
/*                   "c-doc-fbr-gds"*/

        /* delete-fbr-doc */
/*        {&comma} + "fbr-doc"*/
/*                   "fbr-line"*/


        /* delete-fbr-gds-grp */
/*        {&comma} + "fbr-gds-grp"*/
/*        {&comma} + "fbr-gds-grp-attr"*/
/*        {&comma} + "c-fbr-gds-grp-hist"*/
/*        {&comma} + "c-fbr-gds-grp"*/
/*        {&comma} + "c-fbr-gds-grp-attr"*/

        /* delete-fbr-prn */
/*        {&comma} + "fbr-prn"*/
/*        {&comma} + "fbr-prn-grp"*/
/*        {&comma} + "fbr-prn-gds"*/



        /* delete-gds-obj */
/*        {&comma} + "gds-obj"*/
/*        {&comma} + "c-gds-obj"*/
/*        {&comma} + "c-gds-obj-ref"*/
/*        {&comma} + "gds-obj-attr"*/
/*        {&comma} + "c-gds-obj-attr"*/
/*        {&comma} + "prt-obj"*/
/*        {&comma} + "parts"*/
/*        {&comma} + "parts-obj-attr"*/
/*        {&comma} + "c-parts-obj-attr"*/
/*        {&comma} + "fbr-gds-obj"*/
/*        {&comma} + "c-fbr-gds-obj"*/
/*        {&comma} + "varianty-delivery-gds-obj"*/
/*        {&comma} + "c-varianty-delivery-gds-obj"*/
/*        {&comma} + "c-gds-hist"*/
/*        {&comma} + "fbr-prn-gds"*/


        /* delete-icnt-doc */
/*        {&comma} + "icnt-doc"*/
/*        {&comma} + "icnt-line"*/

        /* delete-price-doc */
/*        {&comma} + "price-doc"*/
/*        {&comma} + "price-list"*/

        /* delete-obj-date */
/*        {&comma} + "obj-date"*/

        /* delete-ot-archive */
/*        {&comma} + "ot-line"*/
/*        {&comma} + "ot-supp-line"*/
/*        {&comma} + "ot-supp-tot"*/
/*        {&comma} + "ot-tot"*/

        /* delete-ord-doc */
/*        {&comma} + "ord-doc"*/
/*                   "ord-line"*/
/*                   "ord-dtl"*/
/*                   "ord-doc-rcv"*/
/*                   "ord-line-rcv"*/
/*                   "ord-dtl-rcv"*/

        /* delete-add-doc */
/*        {&comma} + "add-doc"*/
/*                   "add-line"*/
/*                   "add-trn"*/
/*                   "add-trn-attr"*/
/*                   "doc-line-attr"*/


        /* delete-rvs-doc */
/*        {&comma} + "rvs-doc"*/
/*        {&comma} + "rvs-line"*/
/*        {&comma} + "rvs-line-pump"*/

        /* delete-shift-obj */
/*        {&comma} + "shift-obj"*/
/*        {&comma} + "c-sht-hist"*/
/*        {&comma} + "c-shift-obj"*/
/*        {&comma} + "shift-cash"*/
/*        {&comma} + "shift-staff"*/
/*        {&comma} + "c-shift-staff"*/


          /* delete-wth-doc */
/*        {&comma} + "wth-doc"*/
/*        {&comma} + "wth-line"*/
/*                   "wth-dtl"*/
/*        {&comma} + "c-wth-doc"*/
/*        {&comma} + "c-wth-line"*/
/*                   "c-wth-dtl"*/
/*        {&comma} + "wth-obj"*/
/*        {&comma} + "c-wth-obj"*/
/*        {&comma} + "wth-place"*/
/*        {&comma} + "wth-pobj"*/
/*        {&comma} + "c-wth-pobj"*/

          /* delete-place-nozzle-pump */
/*        {&comma} + "place"*/
/*        {&comma} + "c-place"*/
/*        {&comma} + "c-plс-hist"*/
/*        {&comma} + "nozzle"*/
/*        {&comma} + "c-nzl-hist"*/
/*        {&comma} + "c-nozzle"*/
/*        {&comma} + "pump"*/
/*        {&comma} + "c-pump"*/
/*        {&comma} + "c-pmp-hist"*/
/*        {&comma} + "pl-gds"*/
/*        {&comma} + "c-pl-gds-obj"*/
/*        {&comma} + "c-pl-gds"*/
/*        {&comma} + "pl-pump"*/
/*        {&comma} + "c-pl-pump"*/
/*        {&comma} + "pump-nozzle"*/
/*        {&comma} + "c-pump-nozzle"*/
/*        {&comma} + "pl-gds-pump"*/
/*        {&comma} + "c-pl-gds-pump"*/
/*        {&comma} + "pl-pump-nozzle"*/
/*        {&comma} + "c-pl-pump-nozzle"*/

          /* delete-stk-archive */
/*        {&comma} + "stk-line"*/
/*        {&comma} + "stk-supp-line"*/
/*        {&comma} + "aht-stk-line"*/
/*        {&comma} + "stk-supp-tot"*/
/*        {&comma} + "stk-tot"*/
/*        {&comma} + "aht-stk-tot"*/
/*        {&comma} + "aht-stk"*/

          /* delete-tax */
/*        {&comma} + "tax-rate-gds"*/
/*        {&comma} + "tax-rate-gds-grp"*/
/*        {&comma} + "tax-rate-value"*/

          /* delete-dis-card-type */
/*        {&comma} + "dis-card-type"*/
/*        {&comma} + "c-dis-card-type"*/
/*        {&comma} + "dis-card-type-attr"*/
/*        {&comma} + "c-dis-card-type-attr"*/
/*        {&comma} + "dis-card-mask"*/
/*        {&comma} + "c-dis-card-mask"*/

          /* delete-dis-rule */
/*        {&comma} + "dis-rule"*/
/*        {&comma} + "c-dis-rule"*/

          /* delete-dis-obj */
/*        {&comma} + "dis-obj"*/
/*        {&comma} + "c-dis-obj"*/


          /* delete-scales-gds */
/*        {&comma} + "scales-gds"*/

          /* delete-variant-delivery */
/*        {&comma} + "variant-delivery"*/
/*        {&comma} + "c-variant-delivery"*/
/*        {&comma} + "var-deliv-gr-per-val"*/
/*        {&comma} + "c-var-deliv-gr-per-val"*/


          /* delete-gds-grp-obj*/
/*        {&comma} + "gds-grp-obj"*/
/*        {&comma} + "gds-grp-attr"*/
/*        {&comma} + "tax-rate-gds-grp"*/


          /* delete-sum-grp-obj*/
/*        {&comma} + "sum-grp-obj"*/

/*delete-cd-clu*/
/*delete-cd-plu*/
/*delete-cd-dlu*/
/*delete-cd-grp*/
/*delete-cd-doc*/
/*delete-cd-doc-line*/

          /* delete-config */
/*        {&comma} + "config"*/


/*delete-stop-list*/
/*delete-place-io*/
/*
/*        {&comma} + "place-io"*/
/*        {&comma} + "c-place-io"*/
/*        {&comma} + "point-place-rel"*/
/*        {&comma} + "c-point-place-rel"*/
/*        {&comma} + "point-point-rel"*/
/*        {&comma} + "c-point-point-rel"*/
/*        {&comma} + "point-io"*/
/*        {&comma} + "c-point-io"*/

*/



    run log-information in this-procedure
      (input "check-can-delete"
      ) .

    run check-can-delete in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ) .

    run log-information in this-procedure
      (input "delete-batch-process"
      ) .

    run delete-batchprocess in this-procedure
        (input v-obj-type
        ,input v-obj-code
      ) .

    run log-information in this-procedure
      (input "delete-nws-doc-hist"
      ) .

    run delete-nws-doc-hist in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ) .

  run log-information in this-procedure
    (input "delete-gds-obj"
    ) .

  run delete-gds-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-inkas"
    ) .

  run delete-inkas in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-trn-doc"
    ) .

  run delete-trn-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-price-doc"
    ) .

  run delete-price-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-rvs-doc"
    ) .

  run delete-rvs-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-wth-doc"
    ) .

  run delete-wth-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-icnt-doc"
    ) .

  run delete-icnt-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-chk-doc"
    ) .

  run delete-chk-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-recipe"
    ) .

  run delete-recipe in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-fbr-doc"
    ) .

  run delete-fbr-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-fbr-pln"
    ) .

  run delete-fbr-pln in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-fbr-gds-grp"
    ) .

  run delete-fbr-gds-grp in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-fbr-prn"
    ) .

  run delete-fbr-prn in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-obj-date"
    ) .

  run delete-obj-date in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-ord-doc"
    ) .

  run delete-ord-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-add-doc"
    ) .

  run delete-add-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-shift-obj"
    ) .

  run delete-shift-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-nozzle-pump"
    ) .

  run delete-place-nozzle-pump in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-stk-archive"
    ) .

  run delete-stk-archive in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-tax"
    ) .

  run delete-tax in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-dis-obj"
    ) .

  run delete-dis-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-dis-dc-rule"
    ) .

  run delete-dis-dc-rule in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-dis-card-type"
    ) .

  run delete-dis-card-type in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-dis-rule"
    ) .

  run delete-dis-rule in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .



  run log-information in this-procedure
    (input "delete-variant-delivery"
    ) .

  run delete-variant-delivery in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-gds-grp-obj"
    ) .

  run delete-gds-grp-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-sum-grp-obj"
    ) .

  run delete-sum-grp-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-scales-gds"
    ) .

  run delete-scales-gds in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

    run log-information in this-procedure
      (input "delete-assortment-matrix"
      ) .

  run delete-assortment-matrix in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "finish-delete-assortment-matrix"
    ) .

  run delete-gds-obj-prop in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "finish-delete-gds-obj-prop"
    ) .


  run log-information in this-procedure
    (input "delete-config"
    ) .

  run delete-config in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-user-obj"
    ) .

  run delete-user-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-action-post-obj"
    ) .

  run delete-action-post-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-clients"
    ) .

  run delete-clients in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,output v-uniq-key-rec
    ) .

run log-information in this-procedure
    (input "delete-arh-trn-doc-contract"
    ) .

  run delete-arh-trn-doc-contract in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-place-io"
    ) .

  run delete-place-io in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-stop-list"
    ) .

  run delete-stop-list in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-convert-payment"
    ) .

  run convert-payment in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "convert-payment"
    ) .

  run log-information in this-procedure
    (input "delete-ext-classif"
    ) .

  run delete-ext-classif in this-procedure
    (input v-uniq-key-rec
    ,input v-obj-type
    ,input v-obj-code
    ) .

  run log-information in this-procedure
    (input "delete-egais"
    ) .

  run delete-egais in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .

  if g#news <> true then do:
   run log-information in this-procedure
     (input "send command"
     ) .
   run nws/cr-route.p
      ( input {&send-cmd}
       ,input "command":U + {&delim-nws} + "delete-object":U + {&delim-nws} + v-obj-type + {&delim-nws} + string( v-obj-code )
       ,input ?
       ,input "":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при маршрутизации команды на удаление объекта &1 &2.", v-obj-type, v-obj-code ) skip
        return-value skip
        error-status :get-message ( 1 )
        view-as alert-box error
      .
      undo, return error .
    end.
  end.

  run log-information in this-procedure
    (input substitute( "finish-delete-object &1 &2", v-obj-type, v-obj-code )
    ) .
  end.

  hide frame show-act.

end.

procedure log-information :

  define input  parameter p-message as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .

    output stream slog to value('del-obj.log') append .
    export stream slog v-obj-type v-obj-code cur-time-string() p-message .
    output stream slog close .

    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .

    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-current-action = p-message
    .
    display
      v-current-time v-current-action
      with frame show-act .
    process events .

  end.

end procedure. /* log-information */


procedure check-input-parameters :

  define buffer buf_clients  for ub.clients .

  do
  on error undo, return error substitute( "&1 (check-input-parameters). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    define variable v-ind      as integer   no-undo .
    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer   no-undo .

    do v-ind = 1 to num-entries( p-obj-list, {&comma-char} ) by 2
    :
      assign
        v-obj-type = entry( v-ind, p-obj-list, {&comma-char} )
        v-obj-code = integer( entry( v-ind + 1, p-obj-list, {&comma-char} ) )
      .
      find first buf_clients exclusive-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
        no-error .
      if not available buf_clients then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Неизвестный объект" v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.

end procedure. /* check-input-parameters */


procedure delete-route :

  define input parameter p-tbl-name   as character no-undo .
  define input parameter p-tbl-handle as handle    no-undo .

  do
  on error undo, return error
  :

    define buffer buf_route   for ub.route .

    define variable v-key-rec as character no-undo .

    run gen-key-rec ( input  p-tbl-name
                     ,input  p-tbl-handle
                     ,output v-key-rec
                    ) no-error .
    if not error-status :error then do:
      for each buf_route exclusive-lock
        where buf_route.uniq-key-rec = v-key-rec
      on error undo, return error
      :
        delete buf_route .
      end.
    end.

  end.

end procedure. /* delete-route */


procedure delete-gds-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_c-gds-obj      for ub.c-gds-obj .
  define buffer buf_c-gds-obj-ref  for ub.c-gds-obj-ref .
  define buffer buf_gds-obj-attr for ub.gds-obj-attr .
  define buffer buf_c-gds-obj-attr for ub.c-gds-obj-attr .
  define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .
  define buffer buf_c-bar-code-obj-attr for ub.c-bar-code-obj-attr .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_parts        for ub.parts .
  define buffer buf_parts-obj-attr    for ub.parts-obj-attr .
  define buffer buf_c-parts-obj-attr    for ub.c-parts-obj-attr .
  define buffer buf_fbr-gds-obj  for ub.fbr-gds-obj.
  define buffer buf_c-fbr-gds-obj  for ub.c-fbr-gds-obj.
  define buffer buf_varianty-delivery-gds-obj for ub.varianty-delivery-gds-obj.
  define buffer buf_c-varianty-delivery-gds-obj for ub.c-varianty-delivery-gds-obj.
  define buffer buf_c-gds-hist  for ub.c-gds-hist.
  define buffer buf_s-coeff for ub.s-coeff.
  define buffer buf_c-s-coeff for ub.c-s-coeff.
  define buffer buf_fbr-prn-gds for ub.fbr-prn-gds.
  define buffer buf_c-fbr-prn-gds for ub.fbr-prn-gds.
  define buffer buf_fbr-prn-grp for ub.fbr-prn-grp.
  define buffer buf_c-fbr-prn-grp for ub.fbr-prn-grp.
  define buffer buf_dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_c-dis-gds-rule for ub.c-dis-gds-rule .
  define buffer buf_dis-grp-rule for ub.dis-grp-rule .
  define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule .
  define buffer buf_dis-dc-rule for ub.dis-dc-rule .
  define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule .
  define buffer buf_dis-dct-rule for ub.dis-dct-rule .
  define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule .
  define buffer buf_dis-some-rule for ub.dis-some-rule .
  define buffer buf_c-dis-some-rule for ub.c-dis-some-rule .








  on delete of ub.gds-obj-attr override do: end.
  on delete of ub.bar-code-obj-attr override do: end.
  on delete of ub.c-bar-code-obj-attr override do: end.
  on delete of ub.fbr-gds-obj override do: end.
  on delete of ub.c-gds-obj-attr override do: end.
  on delete of ub.c-gds-obj-ref override do: end.
  on delete of ub.c-fbr-gds-obj override do: end.
  on delete of ub.s-coeff override do: end.
  on delete of ub.c-s-coeff override do: end.
  on delete of ub.varianty-delivery-gds-obj override do: end.
  on delete of ub.c-varianty-delivery-gds-obj override do: end.
  on delete of ub.c-gds-hist override do: end.
  on delete of ub.fbr-prn-gds override do: end.
  on delete of ub.c-fbr-prn-gds override do: end.
  on delete of ub.fbr-prn-grp override do: end.
  on delete of ub.c-fbr-prn-grp override do: end.
  on delete of ub.dis-gds-rule override do: end.
  on delete of ub.c-dis-gds-rule override do: end.
  on delete of ub.dis-grp-rule override do: end.
  on delete of ub.c-dis-grp-rule override do: end.
  on delete of ub.dis-dc-rule override do: end.
  on delete of ub.c-dis-dc-rule override do: end.
  on delete of ub.dis-dct-rule override do: end.
  on delete of ub.c-dis-dct-rule override do: end.
  on delete of ub.dis-some-rule override do: end.
  on delete of ub.c-dis-some-rule override do: end.
  on delete of ub.parts-obj-attr override do: end.
  on delete of ub.c-parts-obj-attr override do: end.

  do
  on error undo, return error return-value
  :

    for each buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_gds-obj .
    end.

    for each buf_c-gds-obj exclusive-lock
      where buf_c-gds-obj.obj-type = p-obj-type
        and buf_c-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-gds-obj .
    end.
    for each buf_c-gds-obj-ref exclusive-lock
      where buf_c-gds-obj-ref.obj-type = p-obj-type
        and buf_c-gds-obj-ref.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-gds-obj-ref.
    end.

    for each buf_gds-obj-attr exclusive-lock
      where buf_gds-obj-attr.obj-type = p-obj-type
        and buf_gds-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_gds-obj-attr}
         ,input (buffer buf_gds-obj-attr:handle)
        ) .
      delete buf_gds-obj-attr .
    end.

    for each buf_c-gds-obj-attr exclusive-lock
      where buf_c-gds-obj-attr.obj-type = p-obj-type
        and buf_c-gds-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-gds-obj-attr}
         ,input (buffer buf_c-gds-obj-attr:handle)
        ) .

      delete buf_c-gds-obj-attr .
    end.

    for each buf_bar-code-obj-attr exclusive-lock
      where buf_bar-code-obj-attr.obj-type  = p-obj-type
        and buf_bar-code-obj-attr.obj-code  = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_bar-code-obj-attr}
         ,input (buffer buf_bar-code-obj-attr:handle)
        ) .
      delete buf_bar-code-obj-attr .
    end.

    for each buf_c-bar-code-obj-attr exclusive-lock
      where buf_c-bar-code-obj-attr.obj-type  = p-obj-type
        and buf_c-bar-code-obj-attr.obj-code  = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-bar-code-obj-attr}
         ,input (buffer buf_c-bar-code-obj-attr:handle)
        ) .

      delete buf_c-bar-code-obj-attr .
    end.

    for each buf_prt-obj exclusive-lock
      where buf_prt-obj.obj-type = p-obj-type
        and buf_prt-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_prt-obj}
         ,input (buffer buf_prt-obj:handle)
        ) .
      delete buf_prt-obj .
    end.

    for each buf_parts exclusive-lock
      where buf_parts.obj-type = p-obj-type
        and buf_parts.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_parts .
    end.
    for each buf_parts-obj-attr exclusive-lock
      where buf_parts-obj-attr.obj-type = p-obj-type
        and buf_parts-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_parts-obj-attr .
    end.
    for each buf_c-parts-obj-attr exclusive-lock
      where buf_c-parts-obj-attr.obj-type = p-obj-type
        and buf_c-parts-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-parts-obj-attr .
    end.

    for each buf_fbr-gds-obj exclusive-lock
      where buf_fbr-gds-obj.obj-type = p-obj-type
        and buf_fbr-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_fbr-gds-obj}
         ,input (buffer buf_fbr-gds-obj:handle)
        ) .
      delete buf_fbr-gds-obj .
    end.

    for each buf_c-fbr-gds-obj exclusive-lock
      where buf_c-fbr-gds-obj.obj-type = p-obj-type
        and buf_c-fbr-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-gds-obj}
         ,input (buffer buf_c-fbr-gds-obj:handle)
        ) .
      delete buf_c-fbr-gds-obj .
    end.

    for each buf_s-coeff exclusive-lock
      where buf_s-coeff.obj-type = p-obj-type
        and buf_s-coeff.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-s-coeff exclusive-lock
        where buf_c-s-coeff.gds-code = buf_s-coeff.gds-code
          and buf_c-s-coeff.host-code = buf_s-coeff.host-code
          and buf_c-s-coeff.obj-type = p-obj-type
          and buf_c-s-coeff.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-s-coeff}
          ,input (buffer buf_c-s-coeff:handle)
          ) .
        delete buf_c-s-coeff .
      end.
      run delete-route in this-procedure
        ( input {&table_s-coeff}
         ,input (buffer buf_s-coeff:handle)
        ) .
      delete buf_s-coeff .
    end.

    for each buf_varianty-delivery-gds-obj exclusive-lock
      where buf_varianty-delivery-gds-obj.obj-type = p-obj-type
        and buf_varianty-delivery-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_varianty-delivery-gds-obj}
         ,input (buffer buf_varianty-delivery-gds-obj:handle)
        ) .
      delete buf_varianty-delivery-gds-obj .
    end.

    for each buf_c-varianty-delivery-gds-obj exclusive-lock
      where buf_c-varianty-delivery-gds-obj.obj-type = p-obj-type
        and buf_c-varianty-delivery-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-varianty-delivery-gds-obj}
         ,input (buffer buf_c-varianty-delivery-gds-obj:handle)
        ) .
      delete buf_c-varianty-delivery-gds-obj .
    end.

    for each buf_c-gds-hist exclusive-lock
      where buf_c-gds-hist.obj-type = p-obj-type
        and buf_c-gds-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-gds-hist}
         ,input (buffer buf_c-gds-hist:handle)
        ) .
      delete buf_c-gds-hist .
    end.

    for each buf_fbr-prn-gds exclusive-lock
      where buf_fbr-prn-gds.obj-type = p-obj-type
        and buf_fbr-prn-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_fbr-prn-gds}
         ,input (buffer buf_fbr-prn-gds:handle)
        ) .
      delete buf_fbr-prn-gds .
    end.

    for each buf_c-fbr-prn-gds exclusive-lock
      where buf_c-fbr-prn-gds.obj-type = p-obj-type
        and buf_c-fbr-prn-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-prn-gds}
         ,input (buffer buf_c-fbr-prn-gds:handle)
        ) .
      delete buf_c-fbr-prn-gds .
    end.

    for each buf_fbr-prn-grp exclusive-lock
      where buf_fbr-prn-grp.obj-type = p-obj-type
        and buf_fbr-prn-grp.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_fbr-prn-grp}
         ,input (buffer buf_fbr-prn-grp:handle)
        ) .
      delete buf_fbr-prn-grp .
    end.

    for each buf_c-fbr-prn-grp exclusive-lock
      where buf_c-fbr-prn-grp.obj-type = p-obj-type
        and buf_c-fbr-prn-grp.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-prn-grp}
         ,input (buffer buf_c-fbr-prn-grp:handle)
        ) .
      delete buf_c-fbr-prn-grp .
    end.
    for each buf_dis-gds-rule exclusive-lock
      where buf_dis-gds-rule.obj-type = p-obj-type
        and buf_dis-gds-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_dis-gds-rule}
         ,input (buffer buf_dis-gds-rule:handle)
        ) .
      delete buf_dis-gds-rule .
    end.

    for each buf_c-dis-gds-rule exclusive-lock
      where buf_c-dis-gds-rule.obj-type = p-obj-type
        and buf_c-dis-gds-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-dis-gds-rule}
         ,input (buffer buf_c-dis-gds-rule:handle)
        ) .

      delete buf_c-dis-gds-rule .
    end.
  end.

end procedure. /* delete-gds-obj */


procedure delete-inkas :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define variable v-host-code as integer no-undo .
  define buffer buf_inkas for ub.inkas .
  define buffer buf_inkas-pay for ub.inkas-pay .
  define buffer buf_inkas-pay-desk for ub.inkas-pay-desk .
  define buffer buf_inkas-pay-wth for ub.inkas-pay-wth .
  define buffer buf_sale-doc for ub.sale-doc.
  define buffer buf_c-inkas for ub.c-inkas .
  define buffer buf_c-inkas-pay for ub.c-inkas-pay .
  define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk .
  define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth .
  define buffer buf_c-sale-doc for ub.c-sale-doc.

  define buffer buf_payment for ub.payment .
  define buffer buf_sysconf for ub.sysconf.

  on delete of ub.inkas override do: end.
  on delete of ub.c-inkas override do: end.
  on delete of ub.inkas-pay override do: end.
  on delete of ub.c-inkas-pay override do: end.
  on delete of ub.inkas-pay-desk override do: end.
  on delete of ub.c-inkas-pay-desk override do: end.
  on delete of ub.inkas-pay-wth override do: end.
  on delete of ub.c-inkas-pay-wth override do: end.
  on write of ub.payment override do: end.
  on delete of ub.sale-doc override do: end.
  on delete of ub.c-sale-doc override do: end.



  do
  on error undo, return error return-value
  :

    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = v-host-code.
    for each buf_inkas exclusive-lock
      where buf_inkas.obj-type = p-obj-type
        and buf_inkas.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_sale-doc exclusive-lock
        where buf_sale-doc.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_sale-doc .
      end.
      for each buf_c-sale-doc exclusive-lock
        where buf_c-sale-doc.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-sale-doc .
      end.
      for each buf_inkas-pay exclusive-lock
        where buf_inkas-pay.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_inkas-pay .
      end.
      for each buf_inkas-pay-desk exclusive-lock
        where buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_inkas-pay-desk .
      end.
      for each buf_inkas-pay-wth exclusive-lock
        where buf_inkas-pay-wth.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_inkas-pay-wth .
      end.


      for each buf_payment exclusive-lock
        where buf_payment.source-type = {&pmnt-cash-desk} AND
              buf_payment.source-ref = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = {&bgh-scf-pay}
        buf_payment.pay-code = buf_sysconf.cash-pay
        buf_payment.PS = substitute("!смена типа платежа/кода оплаты после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
      end.

      for each buf_c-inkas exclusive-lock
        where buf_c-inkas.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas .
      end.

      for each buf_c-inkas-pay exclusive-lock
        where buf_c-inkas-pay.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay .
      end.

      for each buf_c-inkas-pay-desk exclusive-lock
        where buf_c-inkas-pay-desk.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-desk .
      end.
      for each buf_c-inkas-pay-wth exclusive-lock
        where buf_c-inkas-pay-wth.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-wth .
      end.


      run delete-route in this-procedure
        ( input {&table_inkas}
         ,input (buffer buf_inkas:handle)
        ) .
      delete buf_inkas .
    end.
    for each buf_c-inkas exclusive-lock
      where buf_c-inkas.obj-type = p-obj-type
        and buf_c-inkas.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-sale-doc exclusive-lock
        where buf_c-sale-doc.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-sale-doc .
      end.

      for each buf_c-inkas-pay exclusive-lock
        where buf_c-inkas-pay.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay .
      end.
      for each buf_c-inkas-pay-desk exclusive-lock
        where buf_c-inkas-pay-desk.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-desk .
      end.
      for each buf_c-inkas-pay-wth exclusive-lock
        where buf_c-inkas-pay-wth.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-wth .
      end.


      for each buf_payment exclusive-lock
        where buf_payment.source-type = {&pmnt-cash-desk} AND
              buf_payment.source-ref = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = {&bgh-scf-pay}
        buf_payment.pay-code = buf_sysconf.cash-pay
        buf_payment.PS = substitute("!смена типа платежа/кода оплаты после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
      end.

      run delete-route in this-procedure
        ( input {&table_c-inkas}
         ,input (buffer buf_c-inkas:handle)
        ) .
      delete buf_c-inkas .
    end.
  end.

end procedure. /* delete-inkas */


procedure delete-trn-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_doc-attr      for ub.doc-attr .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer buf_gds-dtl       for ub.gds-dtl .
  define buffer buf_doc-prts      for ub.doc-prts .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer buf_doc-pl-pump   for ub.doc-pl-pump .
  define buffer buf_doc-line-attr for ub.doc-line-attr .
  define buffer buf_c-trn-doc       for ub.c-trn-doc .
  define buffer buf_c-doc-attr      for ub.c-doc-attr .
  define buffer buf_c-doc-line      for ub.c-doc-line .
  define buffer buf_c-gds-dtl       for ub.c-gds-dtl .
  define buffer buf_c-doc-prts      for ub.c-doc-prts .
  define buffer buf_c-doc-pl        for ub.c-doc-pl .
  define buffer buf_c-doc-pl-pump   for ub.c-doc-pl-pump .
  define buffer buf_c-doc-line-attr for ub.c-doc-line-attr .
  define buffer buf_c-inv-line      for ub.c-inv-line .
  define buffer buf_inv-line      for ub.inv-line .
  define buffer buf_doc-fbr-gds   for ub.doc-fbr-gds .
  define buffer buf_c-doc-fbr-gds for ub.c-doc-fbr-gds .
  define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
  define buffer buf_payment       for ub.payment.
  /* партии удаляются вместе с товаром */
  /* define buffer buf_parts         for ub.parts .*/

  on delete of ub.trn-doc  override do: end.
  on delete of ub.c-trn-doc  override do: end.
  on delete of ub.doc-line override do: end.

  do
  on error undo, return error
  :

    for each buf_trn-doc exclusive-lock
      where buf_trn-doc.obj-type = p-obj-type
        and buf_trn-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_trn-doc}
         ,input (buffer buf_trn-doc:handle)
        ) .

      for each buf_doc-attr exclusive-lock
        where buf_doc-attr.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-attr .
      end.

      for each buf_doc-line exclusive-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-line .
      end.

      for each buf_gds-dtl exclusive-lock
        where buf_gds-dtl.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_gds-dtl .
      end.

      /* удаляем информацию о резервировании партий по строке */
      for each buf_doc-prts exclusive-lock
        where buf_doc-prts.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-prts .
      end.

      /* удаляем информацию о резервировании товара по складским местам */
      for each buf_doc-pl exclusive-lock
        where buf_doc-pl.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-pl.
      end.

      for each buf_doc-pl-pump exclusive-lock
        where buf_doc-pl-pump.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-pl-pump.
      end.

      /* удаляем атрибуты строки документа */
      for each buf_doc-line-attr exclusive-lock
        where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-line-attr .
      end.

      /* удаляем строки, хранящие информацию по инвентаризации */
      for each buf_inv-line exclusive-lock
        where buf_inv-line.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_inv-line .
      end.

      /* удаляем информацию о резервировании товара по подразделениям производства*/
      for each buf_doc-fbr-gds exclusive-lock
        where buf_doc-fbr-gds.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-fbr-gds.
      end.


      for each buf_arh-trn-doc-contract exclusive-lock
        where buf_arh-trn-doc-contract.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_arh-trn-doc-contract.
      end.
      if buf_trn-doc.d-card <> '':U then do:
        for each buf_payment exclusive-lock
          where buf_payment.source-type = {&pmnt-trn-doc} AND
                buf_payment.source-ref = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
          assign
          buf_payment.source-type = {&bgh-scf-pay}
          buf_payment.PS = substitute("!смена типа платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
          .
        end.
      end.


      run delete-ot-archive in this-procedure
        (input buf_trn-doc.doc-code
        ) .

      delete buf_trn-doc .
    end.
    for each buf_c-trn-doc exclusive-lock
      where buf_c-trn-doc.obj-type = p-obj-type
        and buf_c-trn-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-trn-doc}
         ,input (buffer buf_c-trn-doc:handle)
        ) .

      for each buf_c-doc-attr exclusive-lock
        where buf_c-doc-attr.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-attr .
      end.

      for each buf_c-doc-line exclusive-lock
        where buf_c-doc-line.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-line .
      end.

      for each buf_c-gds-dtl exclusive-lock
        where buf_c-gds-dtl.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-gds-dtl .
      end.

      /* удаляем информацию о резервировании партий по строке */
      for each buf_c-doc-prts exclusive-lock
        where buf_c-doc-prts.out-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-prts .
      end.

      /* удаляем информацию о резервировании товара по складским местам */
      for each buf_c-doc-pl exclusive-lock
        where buf_c-doc-pl.out-code = buf_c-trn-doc.doc-code
          and buf_c-doc-pl.obj-code = buf_c-trn-doc.obj-code
          and buf_c-doc-pl.obj-type = buf_c-trn-doc.obj-type
      on error undo, return error
      :
        delete buf_c-doc-pl.
      end.

      for each buf_c-doc-pl-pump exclusive-lock
        where buf_c-doc-pl-pump.out-code = buf_c-trn-doc.doc-code
          and buf_c-doc-pl-pump.obj-code = buf_c-trn-doc.obj-code
          and buf_c-doc-pl-pump.obj-type = buf_c-trn-doc.obj-type
      on error undo, return error
      :
        delete buf_c-doc-pl-pump.
      end.

      /* удаляем атрибуты строки документа */
      for each buf_c-doc-line-attr exclusive-lock
        where buf_c-doc-line-attr.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-line-attr .
      end.

      /* удаляем строки, хранящие информацию по инвентаризации */
      for each buf_c-inv-line exclusive-lock
        where buf_c-inv-line.doc-code = buf_c-trn-doc.doc-code
          and buf_c-inv-line.chip-num = buf_c-trn-doc.chip-num
      on error undo, return error
      :
        delete buf_c-inv-line .
      end.

      /* удаляем информацию о резервировании товара по подразделениям производства*/

      for each buf_c-doc-fbr-gds exclusive-lock
        where buf_c-doc-fbr-gds.out-code = buf_trn-doc.doc-code
          and buf_c-doc-fbr-gds.obj-code = buf_trn-doc.obj-code
          and buf_c-doc-fbr-gds.obj-type = buf_trn-doc.obj-type
      on error undo, return error
      :
        delete buf_c-doc-fbr-gds.
      end.

      if buf_c-trn-doc.d-card <> '':U then do:
        for each buf_payment exclusive-lock
          where buf_payment.source-type = {&pmnt-trn-doc} AND
                buf_payment.source-ref = buf_c-trn-doc.doc-code
        on error undo, return error return-value
        :
          assign
          buf_payment.source-type = {&bgh-scf-pay}
          buf_payment.PS = substitute("!смена типа платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
          .
        end.
      end.
      for each buf_arh-trn-doc-contract exclusive-lock
        where buf_arh-trn-doc-contract.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_arh-trn-doc-contract.
      end.


      run delete-ot-archive in this-procedure
        (input buf_c-trn-doc.doc-code
        ) .

      delete buf_c-trn-doc .
    end.

  end.

end procedure. /* delete-trn-doc */


procedure delete-price-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_price-list for ub.price-list .
  define buffer buf_doc-attr for ub.doc-attr .
  define buffer buf_price-list-attr for ub.price-list-attr .
  define buffer buf_price-all for ub.price-all .
  define buffer buf_c-price-doc for ub.c-price-doc .
  define buffer buf_c-price-list for ub.c-price-list .
  define buffer buf_c-price-list-attr for ub.c-price-list-attr .
  define buffer buf_c-doc-attr for ub.c-doc-attr  .

  on delete of ub.price-doc override do: end.

  do
  on error undo, return error
  :
    for each buf_price-all exclusive-lock
      where buf_price-all.obj-type = p-obj-type
        and buf_price-all.obj-code = p-obj-code
    on error undo, return error
    :
      delete buf_price-all.
    end.

    for each buf_price-doc exclusive-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_price-doc}
         ,input (buffer buf_price-doc:handle)
        ) .

      for each buf_price-list exclusive-lock
        where buf_price-list.doc-num = buf_price-doc.doc-num
      on error undo, return error
      :
        delete buf_price-list .
      end.

      for each buf_price-list-attr exclusive-lock
        where buf_price-list-attr.doc-num = buf_price-doc.doc-num
      on error undo, return error
      :
        delete buf_price-list-attr .
      end.

      for each buf_doc-attr exclusive-lock
        where buf_doc-attr.doc-code = buf_price-doc.doc-num
      on error undo, return error
      :
        delete buf_doc-attr .
      end.

      run delete-ot-archive in this-procedure
        (input buf_price-doc.doc-num
        ) .

      delete buf_price-doc.
    end.

    for each buf_c-price-doc exclusive-lock
      where buf_c-price-doc.obj-type = p-obj-type
        and buf_c-price-doc.obj-code = p-obj-code
    on error undo, return error
    :
      for each buf_c-price-list exclusive-lock
        where buf_c-price-list.doc-num = buf_c-price-doc.doc-num
      on error undo, return error
      :
        delete buf_c-price-list .
      end.

      for each buf_c-price-list-attr exclusive-lock
        where buf_c-price-list-attr.doc-num = buf_c-price-doc.doc-num
      on error undo, return error
      :
        delete buf_c-price-list-attr .
      end.

      for each buf_c-doc-attr exclusive-lock
        where buf_c-doc-attr.doc-code = buf_c-price-doc.doc-num
      on error undo, return error
      :
        delete buf_c-doc-attr .
      end.

      delete buf_c-price-doc.
    end.

  end.

end procedure. /* delete-price-doc */


procedure delete-rvs-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_rvs-doc  for ub.rvs-doc .
  define buffer buf_rvs-line for ub.rvs-line .
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .

  on delete of ub.rvs-doc override do: end.

  do
  on error undo, return error
  :

    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.obj-type = p-obj-type
        and buf_rvs-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_rvs-doc}
         ,input (buffer buf_rvs-doc:handle)
        ) .

      for each buf_rvs-line exclusive-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
      on error undo, return error
      :
        delete buf_rvs-line .
      end.

      for each buf_rvs-line-pump exclusive-lock
        where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
      on error undo, return error
      :
        delete buf_rvs-line-pump .
      end.

      delete buf_rvs-doc .
    end.
  end.

end procedure. /* delete-rvs-doc */


procedure delete-wth-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_wth-doc   for ub.wth-doc .
  define buffer buf_wth-line  for ub.wth-line .
  define buffer buf_wth-dtl   for ub.wth-dtl .
  define buffer buf_wth-obj   for ub.wth-obj .
  define buffer buf_c-wth-obj   for ub.c-wth-obj .
  define buffer buf_wth-place for ub.wth-place .
  define buffer buf_c-wth-place for ub.c-wth-place .
  define buffer buf_wth-pobj  for ub.wth-pobj .
  define buffer buf_c-wth-pobj  for ub.c-wth-pobj .

  define buffer buf_c-wth-doc   for ub.c-wth-doc .
  define buffer buf_c-wth-line  for ub.c-wth-line .
  define buffer buf_c-wth-dtl   for ub.c-wth-dtl .

  on delete of ub.wth-doc   override do: end.
  on delete of ub.wth-place override do: end.
  on delete of ub.c-wth-place override do: end.
  on delete of ub.wth-line  override do: end.
  on delete of ub.wth-dtl   override do: end.

  on delete of ub.c-wth-doc   override do: end.
  on delete of ub.c-wth-line  override do: end.
  on delete of ub.c-wth-dtl   override do: end.


  do
  on error undo, return error
  :
    for each buf_wth-doc exclusive-lock
      where buf_wth-doc.obj-type = p-obj-type
        and buf_wth-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_wth-doc}
         ,input (buffer buf_wth-doc:handle)
        ) .

      for each buf_wth-line exclusive-lock
        where buf_wth-line.doc-code = buf_wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-line .
      end.

      for each buf_wth-dtl exclusive-lock
        where buf_wth-dtl.doc-code = buf_wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-dtl .
      end.

      delete buf_wth-doc .
    end.

    for each buf_c-wth-doc exclusive-lock
      where buf_c-wth-doc.obj-type = p-obj-type
        and buf_c-wth-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-wth-doc}
         ,input (buffer buf_c-wth-doc:handle)
        ) .

      for each buf_wth-line exclusive-lock
        where buf_wth-line.doc-code = buf_c-wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-line .
      end.

      for each buf_wth-dtl exclusive-lock
        where buf_wth-dtl.doc-code = buf_c-wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-dtl .
      end.

      delete buf_c-wth-doc .
    end.

    for each buf_wth-place exclusive-lock
      where buf_wth-place.obj-type = p-obj-type
        and buf_wth-place.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_wth-place}
         ,input (buffer buf_wth-place:handle)
        ) .

      delete buf_wth-place .
    end.

    for each buf_c-wth-place exclusive-lock
      where buf_c-wth-place.obj-type = p-obj-type
        and buf_c-wth-place.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-wth-place}
         ,input (buffer buf_c-wth-place:handle)
        ) .

      delete buf_c-wth-place .
    end.



    for each buf_wth-obj exclusive-lock
      where buf_wth-obj.obj-type = p-obj-type
        and buf_wth-obj.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_wth-obj}
         ,input (buffer buf_wth-obj:handle)
        ) .
      delete buf_wth-obj .
    end.

    for each buf_wth-pobj exclusive-lock
      where buf_wth-pobj.obj-type = p-obj-type
        and buf_wth-pobj.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_wth-pobj}
         ,input (buffer buf_wth-pobj:handle)
        ) .
      delete buf_wth-pobj .
    end.


    for each buf_c-wth-obj exclusive-lock
      where buf_c-wth-obj.obj-type = p-obj-type
        and buf_c-wth-obj.obj-code = p-obj-code
    on error undo, return error
    :
      delete buf_c-wth-obj .
    end.

    for each buf_c-wth-pobj exclusive-lock
      where buf_c-wth-pobj.obj-type = p-obj-type
        and buf_c-wth-pobj.obj-code = p-obj-code
    on error undo, return error
    :
      delete buf_c-wth-pobj .
    end.

  end.

end procedure. /* delete-wth-doc */


procedure delete-icnt-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_icnt-doc for ub.icnt-doc .
  define buffer buf_icnt-line for ub.icnt-line .

  on delete of ub.icnt-doc override do: end.
  on delete of ub.icnt-line override do: end.

  do
  on error undo, return error
  :
    for each buf_icnt-doc exclusive-lock
      where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_icnt-doc}
         ,input (buffer buf_icnt-doc:handle)
        ) .

      for each buf_icnt-line exclusive-lock
        where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
      on error undo, return error
      :
        delete buf_icnt-line .
      end.

      delete buf_icnt-doc .
    end.


  end.

end procedure. /* delete-icnt-doc */


procedure delete-chk-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_chk-doc for ub.chk-doc .
  define buffer buf_chk-gds for ub.chk-gds .
  define buffer buf_chk-pay for ub.chk-pay .
  define buffer buf_chk-discnt for ub.chk-discnt .
  define buffer buf_chk-doc-attr for ub.chk-doc-attr .
  define buffer buf_c-chk-doc for ub.c-chk-doc .
  define buffer buf_c-chk-gds for ub.c-chk-gds .
  define buffer buf_c-chk-pay for ub.c-chk-pay .
  define buffer buf_c-chk-discnt for ub.c-chk-discnt .
  define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr .


  on delete of ub.chk-doc override do: end.

  do
  on error undo, return error
  :
    for each buf_chk-doc exclusive-lock
      where buf_chk-doc.obj-type = p-obj-type
        and buf_chk-doc.obj-code = p-obj-code
    use-index chk-out
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_chk-doc}
         ,input (buffer buf_chk-doc:handle)
        ) .

      for each buf_chk-gds exclusive-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-gds .
      end.
      for each buf_chk-pay exclusive-lock
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-pay .
      end.
      for each buf_chk-discnt exclusive-lock
        where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-discnt .
      end.
      for each buf_chk-doc-attr exclusive-lock
        where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-doc-attr .
      end.

      for each buf_c-chk-gds exclusive-lock
        where buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-gds .
      end.
      for each buf_c-chk-pay exclusive-lock
        where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-pay .
      end.
      for each buf_c-chk-discnt exclusive-lock
        where buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-discnt .
      end.
      for each buf_c-chk-doc-attr exclusive-lock
        where buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-doc-attr .
      end.
      for each buf_c-chk-doc exclusive-lock
        where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-doc .
      end.

      delete buf_chk-doc .
    end.
  end.

end procedure. /* delete-chk-doc */


procedure delete-recipe :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_recipe              for ub.recipe.
  define buffer buf_recipe-gds          for ub.recipe-gds.
  define buffer buf_recipe-develop      for ub.recipe-develop.
  define buffer buf_c-recipe            for ub.c-recipe.
  define buffer buf_c-recipe-gds        for ub.c-recipe-gds.
  define buffer buf_c-recipe-develop    for ub.c-recipe-develop.

  on delete of ub.recipe                override do: end.
  on delete of ub.recipe-gds            override do: end.
  on delete of ub.recipe-develop        override do: end.
  on delete of ub.c-recipe              override do: end.
  on delete of ub.c-recipe-gds          override do: end.
  on delete of ub.c-recipe-develop      override do: end.

  do
  on error undo, return error
  :
    for each buf_recipe exclusive-lock
       where buf_recipe.obj-type = p-obj-type
         and buf_recipe.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_recipe}
         ,input (buffer buf_recipe:handle)
        ) .
      for each buf_recipe-gds exclusive-lock
         where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
      on error undo, return error
      :
        delete buf_recipe-gds .
      end.
      for each buf_recipe-develop exclusive-lock
         where buf_recipe-develop.recipe-code = buf_recipe.recipe-code
      on error undo, return error
      :
        delete buf_recipe-develop .
      end.
      delete buf_recipe .
    end.
    for each buf_c-recipe exclusive-lock
       where buf_c-recipe.obj-type = p-obj-type
         and buf_c-recipe.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-recipe}
         ,input (buffer buf_c-recipe:handle)
        ) .
      for each buf_c-recipe-gds exclusive-lock
         where buf_c-recipe-gds.recipe-code = buf_c-recipe.recipe-code
      on error undo, return error
      :
        delete buf_c-recipe-gds .
      end.
      for each buf_c-recipe-develop exclusive-lock
         where buf_c-recipe-develop.recipe-code = buf_c-recipe.recipe-code
      on error undo, return error
      :
        delete buf_c-recipe-develop .
      end.
      delete buf_c-recipe .
    end.
  end.

end procedure. /* delete-recipe */


procedure delete-fbr-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_fbr-doc     for ub.fbr-doc .
  define buffer buf_fbr-line    for ub.fbr-line .
  define buffer buf_c-fbr-doc   for ub.c-fbr-doc .
  define buffer buf_c-fbr-line  for ub.c-fbr-line .

  on delete of ub.fbr-doc       override do: end.
  on delete of ub.fbr-line      override do: end.
  on delete of ub.c-fbr-doc     override do: end.
  on delete of ub.c-fbr-line    override do: end.

  do
  on error undo, return error
  :
    for each buf_fbr-doc exclusive-lock
       where buf_fbr-doc.obj-type = p-obj-type
         and buf_fbr-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_fbr-doc}
         ,input (buffer buf_fbr-doc:handle)
        ) .
      for each buf_fbr-line exclusive-lock
        where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
      on error undo, return error
      :
        delete buf_fbr-line .
      end.
      delete buf_fbr-doc .
    end.
    for each buf_c-fbr-doc exclusive-lock
       where buf_c-fbr-doc.obj-type = p-obj-type
         and buf_c-fbr-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-doc}
         ,input (buffer buf_c-fbr-doc:handle)
        ) .
      for each buf_c-fbr-line exclusive-lock
         where buf_c-fbr-line.doc-code = buf_c-fbr-doc.doc-code
      on error undo, return error
      :
        delete buf_c-fbr-line .
      end.
      delete buf_c-fbr-doc .
    end.
  end.
end procedure. /* delete-fbr-doc */

procedure delete-fbr-pln :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_fbr-pln             for ub.fbr-pln .
  define buffer buf_fbr-pln-line        for ub.fbr-pln-line .
  define buffer buf_c-fbr-pln           for ub.fbr-pln .
  define buffer buf_c-fbr-pln-line      for ub.fbr-pln-line .

  on delete of ub.fbr-pln           override do: end.
  on delete of ub.fbr-pln-line      override do: end.
  on delete of ub.c-fbr-pln         override do: end.
  on delete of ub.c-fbr-pln-line    override do: end.

  do
  on error undo, return error
  :
    for each buf_fbr-pln exclusive-lock
       where buf_fbr-pln.obj-type = p-obj-type
         and buf_fbr-pln.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_fbr-pln}
         ,input (buffer buf_fbr-pln:handle)
        ) .
      for each buf_fbr-pln-line exclusive-lock
         where buf_fbr-pln-line.doc-code = buf_fbr-pln.doc-code
      on error undo, return error
      :
        delete buf_fbr-pln-line .
      end.
      delete buf_fbr-pln .
    end.
    for each buf_c-fbr-pln exclusive-lock
       where buf_c-fbr-pln.obj-type = p-obj-type
         and buf_c-fbr-pln.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-pln}
         ,input (buffer buf_c-fbr-pln:handle)
        ) .
      for each buf_c-fbr-pln-line exclusive-lock
         where buf_c-fbr-pln-line.doc-code = buf_c-fbr-pln.doc-code
      on error undo, return error
      :
        delete buf_c-fbr-pln-line .
      end.
      delete buf_c-fbr-pln .
    end.
  end.
end procedure. /* delete-fbr-pln */


procedure delete-fbr-gds-grp :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_fbr-gds-grp  for ub.fbr-gds-grp .
  define buffer buf_fbr-gds-grp-attr  for ub.fbr-gds-grp-attr .
  define buffer buf_c-fbr-gds-grp  for ub.c-fbr-gds-grp .
  define buffer buf_c-fbr-gds-grp-attr  for ub.c-fbr-gds-grp-attr .
  define buffer buf_c-fbr-gds-grp-hist  for ub.c-fbr-gds-grp-hist .

  on delete of ub.fbr-gds-grp override do: end.
  on delete of ub.fbr-gds-grp-attr override do: end.
  on delete of ub.c-fbr-gds-grp override do: end.
  on delete of ub.c-fbr-gds-grp-attr override do: end.
  on delete of ub.c-fbr-gds-grp-hist override do: end.


  do
  on error undo, return error
  :
    for each buf_fbr-gds-grp exclusive-lock
      where buf_fbr-gds-grp.obj-type = p-obj-type
        and buf_fbr-gds-grp.obj-code = p-obj-code
    on error undo, return error
    :

      run delete-route in this-procedure
        ( input {&table_fbr-gds-grp}
         ,input (buffer buf_fbr-gds-grp:handle)
        ) .
      delete buf_fbr-gds-grp .
    end.

    for each buf_c-fbr-gds-grp exclusive-lock
      where buf_c-fbr-gds-grp.obj-type = p-obj-type
        and buf_c-fbr-gds-grp.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-gds-grp}
         ,input (buffer buf_c-fbr-gds-grp:handle)
        ) .
      delete buf_c-fbr-gds-grp .
    end.


    for each buf_fbr-gds-grp-attr exclusive-lock
      where buf_fbr-gds-grp-attr.obj-type = p-obj-type
        and buf_fbr-gds-grp-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_fbr-gds-grp-attr}
         ,input (buffer buf_fbr-gds-grp-attr:handle)
        ) .
      delete buf_fbr-gds-grp-attr .
    end.


    for each buf_c-fbr-gds-grp-attr exclusive-lock
      where buf_c-fbr-gds-grp-attr.obj-type = p-obj-type
        and buf_c-fbr-gds-grp-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-fbr-gds-grp-attr}
         ,input (buffer buf_c-fbr-gds-grp-attr:handle)
        ) .
      delete buf_c-fbr-gds-grp-attr .
    end.


    for each buf_c-fbr-gds-grp-hist exclusive-lock
      where buf_c-fbr-gds-grp-hist.obj-type = p-obj-type
        and buf_c-fbr-gds-grp-hist.obj-code = p-obj-code
    on error undo, return error
    :

      run delete-route in this-procedure
        ( input {&table_c-fbr-gds-grp-hist}
         ,input (buffer buf_c-fbr-gds-grp-hist:handle)
        ) .
      delete buf_c-fbr-gds-grp-hist .
    end.

  end.

end procedure. /* delete-fbr-gds-grp */



procedure delete-fbr-prn :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_fbr-prn  for ub.fbr-prn .
  define buffer buf_fbr-prn-grp  for ub.fbr-prn-grp .
  define buffer buf_fbr-prn-gds  for ub.fbr-prn-gds .
  define buffer buf_c-fbr-prn  for ub.fbr-prn .
  define buffer buf_c-fbr-prn-grp  for ub.fbr-prn-grp .
  define buffer buf_c-fbr-prn-gds  for ub.fbr-prn-gds .


  define buffer buf_clients for ub.clients.
  on delete of ub.fbr-prn override do: end.
  on delete of ub.fbr-prn-grp override do: end.
  on delete of ub.fbr-prn-gds override do: end.
  on delete of ub.c-fbr-prn override do: end.
  on delete of ub.c-fbr-prn-grp override do: end.
  on delete of ub.c-fbr-prn-gds override do: end.


  define variable v-db-num like ub.db.db-num no-undo .

  do
  on error undo, return error
  :

    for each buf_fbr-prn exclusive-lock
      where buf_fbr-prn.fbr-obj-type = p-obj-type
        and buf_fbr-prn.fbr-obj-code = p-obj-code
    on error undo, return error
    :

      for each buf_fbr-prn-gds exclusive-lock
        where buf_fbr-prn-gds.db-num = buf_fbr-prn.db-num
         AND  buf_fbr-prn-gds.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
          run delete-route in this-procedure
            ( input {&table_fbr-prn-gds}
            ,input (buffer buf_fbr-prn-gds:handle)
            ) .
          delete buf_fbr-prn-gds .
      end.

      for each buf_fbr-prn-grp exclusive-lock
        where buf_fbr-prn-grp.db-num = buf_fbr-prn.db-num
          AND buf_fbr-prn-grp.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_fbr-prn-grp}
          ,input (buffer buf_fbr-prn-grp:handle)
          ) .
        delete buf_fbr-prn-grp .
      end.

      for each buf_c-fbr-prn exclusive-lock
        where buf_c-fbr-prn.fbr-obj-type = p-obj-type
          and buf_c-fbr-prn.fbr-obj-code = p-obj-code
      on error undo, return error
      :

        run delete-route in this-procedure
          ( input {&table_c-fbr-prn}
          ,input (buffer buf_c-fbr-prn:handle)
          ) .
      end.

      for each buf_c-fbr-prn-grp exclusive-lock
        where buf_c-fbr-prn-grp.db-num = buf_fbr-prn.db-num
          AND buf_c-fbr-prn-grp.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-fbr-prn-grp}
          ,input (buffer buf_c-fbr-prn-grp:handle)
          ) .
        delete buf_c-fbr-prn-grp .
      end.

      for each buf_c-fbr-prn-gds exclusive-lock
        where buf_c-fbr-prn-gds.db-num = buf_fbr-prn.db-num
        AND  buf_c-fbr-prn-gds.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
          run delete-route in this-procedure
            ( input {&table_c-fbr-prn-gds}
            ,input (buffer buf_c-fbr-prn-gds:handle)
            ) .
          delete buf_c-fbr-prn-gds .
      end.

      run delete-route in this-procedure
        ( input {&table_fbr-prn}
        ,input (buffer buf_fbr-prn:handle)
        ) .

      delete buf_fbr-prn .
    end.
  end. /*doe*/

end procedure. /* delete-fbr-prn */


procedure delete-obj-date :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_obj-date for ub.obj-date .

  on delete of ub.obj-date override do: end.

  do
  on error undo, return error return-value
  :

    for each buf_obj-date exclusive-lock
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_obj-date}
         ,input (buffer buf_obj-date:handle)
        ) .
      delete buf_obj-date .
    end.

  end.

end procedure. /* delete-obj-date */


procedure delete-ot-archive :

  define input  parameter p-doc-code as character no-undo .

  define buffer buf_ot-line      for ub.ot-line      .
  define buffer buf_ot-supp-line for ub.ot-supp-line .
  define buffer buf_aht-ot-line  for ub.aht-ot-line  .
  define buffer buf_ot-supp-tot  for ub.ot-supp-tot  .
  define buffer buf_ot-tot       for ub.ot-tot       .
  define buffer buf_aht-ot-tot   for ub.aht-ot-tot   .

  do
  on error undo, return error return-value
  :
    for each buf_ot-line exclusive-lock
      where buf_ot-line.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-line .
    end.

    for each buf_ot-supp-line exclusive-lock
      where buf_ot-supp-line.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-supp-line .
    end.

    for each buf_aht-ot-line exclusive-lock
      where buf_aht-ot-line.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_aht-ot-line .
    end.

    for each buf_ot-supp-tot exclusive-lock
      where buf_ot-supp-tot.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-supp-tot .
    end.

    for each buf_ot-tot exclusive-lock
      where buf_ot-tot.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-tot .
    end.

    for each buf_aht-ot-tot exclusive-lock
      where buf_aht-ot-tot.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_aht-ot-tot .
    end.
  end.

end procedure. /* delete-ot-archive */


procedure delete-ord-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_ord-doc      for ub.ord-doc .
  define buffer buf_ord-line     for ub.ord-line .
  define buffer buf_ord-dtl      for ub.ord-dtl .
  define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv .
  define buffer buf_ord-line-rcv for ub.ord-line-rcv .
  define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv .
  define buffer buf_ord-doc-attr      for ub.ord-doc-attr .
  define buffer buf_ord-line-attr     for ub.ord-line-attr .
  define buffer buf_ord-dtl-attr      for ub.ord-dtl-attr .

  on delete of ub.ord-doc override do: end.

  do
  on error undo, return error return-value
  :
    for each buf_ord-doc exclusive-lock
      where buf_ord-doc.obj-type = p-obj-type
        and buf_ord-doc.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_ord-doc}
         ,input (buffer buf_ord-doc:handle)
        ) .

      for each buf_ord-line exclusive-lock
        where buf_ord-line.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-line .
      end.
      for each buf_ord-line-attr exclusive-lock
        where buf_ord-line-attr.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-line-attr .
      end.

      for each buf_ord-dtl exclusive-lock
        where buf_ord-dtl.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-dtl .
      end.
      for each buf_ord-dtl-attr exclusive-lock
        where buf_ord-dtl-attr.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-dtl-attr .
      end.
      for each buf_ord-doc-attr exclusive-lock
        where buf_ord-doc-attr.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-doc-attr .
      end.


      for each buf_ord-doc-rcv exclusive-lock
        where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-doc-rcv .
      end.

      for each buf_ord-line-rcv exclusive-lock
        where buf_ord-line-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-line-rcv .
      end.

      for each buf_ord-dtl-rcv exclusive-lock
        where buf_ord-dtl-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-dtl-rcv .
      end.

      delete buf_ord-doc .
    end.

  end.

end procedure. /* delete-ord-doc */
procedure delete-add-doc :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_add-doc       for ub.add-doc      .
  define buffer buf_add-line      for ub.add-line     .
  define buffer buf_add-trn       for ub.add-trn      .
  define buffer buf_add-trn-attr  for ub.add-trn-attr .
  define buffer buf_doc-line-attr for ub.doc-line-attr.

  on delete of ub.add-doc override do: end.
  on delete of ub.add-trn override do: end.
  on delete of ub.doc-line-attr override do: end.

  do
  on error undo, return error return-value
  :
    for each buf_add-doc exclusive-lock
      where buf_add-doc.obj-type = p-obj-type
        and buf_add-doc.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_add-doc}
         ,input (buffer buf_add-doc:handle)
        ) .

      for each buf_add-line exclusive-lock
        where buf_add-line.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_add-line .
      end.

      for each buf_doc-line-attr exclusive-lock
        where buf_doc-line-attr.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_doc-line-attr .
      end.
      for each buf_add-trn-attr exclusive-lock
        where buf_add-trn-attr.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_add-trn-attr .
      end.
      for each buf_add-trn exclusive-lock
        where buf_add-trn.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_add-trn .
      end.


      delete buf_add-doc .
    end.

  end.

end procedure. /* delete-ord-doc */

procedure delete-gds-obj-prop :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_gds-obj-prop   for ub.gds-obj-prop .
  define buffer buf_gds-obj-flag   for ub.gds-obj-flag .
  define buffer buf_c-gds-obj-prop for ub.c-gds-obj-prop .

  do
  on error undo, return error return-value
  :
    for each buf_gds-obj-prop exclusive-lock
      where buf_gds-obj-prop.obj-type = p-obj-type
        and buf_gds-obj-prop.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_gds-obj-prop}
         ,input (buffer buf_gds-obj-prop:handle)
        ) .

      delete buf_gds-obj-prop .
    end.

    for each buf_gds-obj-flag exclusive-lock
      where buf_gds-obj-flag.obj-type = p-obj-type
        and buf_gds-obj-flag.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_gds-obj-flag .
    end.

    for each buf_c-gds-obj-prop exclusive-lock
      where buf_c-gds-obj-prop.obj-type = p-obj-type
        and buf_c-gds-obj-prop.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-gds-obj-prop .
    end.

  end.

end procedure. /* delete-gds-obj-prop */

procedure delete-assortment-matrix :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_assortment-matrix for ub.assortment-matrix .
  define buffer buf_c-assortment-matrix for ub.c-assortment-matrix .


  do
  on error undo, return error return-value
  :
    for each buf_assortment-matrix exclusive-lock
      where buf_assortment-matrix.obj-type = p-obj-type
        and buf_assortment-matrix.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_assortment-matrix}
         ,input (buffer buf_assortment-matrix:handle)
        ) .

      delete buf_assortment-matrix .
    end.

    for each buf_c-assortment-matrix exclusive-lock
      where buf_c-assortment-matrix.obj-type = p-obj-type
        and buf_c-assortment-matrix.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-assortment-matrix .
    end.
  end.

end procedure. /* delete-assortment-matrix */




procedure delete-shift-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_shift-obj for ub.shift-obj .
  define buffer buf_c-sht-hist for ub.c-sht-hist .
  define buffer buf_c-shift-obj for ub.c-shift-obj .
  define buffer buf_shift-cash for ub.shift-cash .
  define buffer buf_shift-staff for ub.shift-staff .
  define buffer buf_c-shift-staff for ub.c-shift-staff .

  on delete of ub.shift-obj   override do: end.
  on delete of ub.c-sht-hist  override do: end.
  on delete of ub.c-shift-obj   override do: end.
  on delete of ub.shift-cash  override do: end.
  on delete of ub.shift-staff override do: end.
  on delete of ub.c-shift-staff override do: end.

  do
  on error undo, return error return-value
  :

    for each buf_shift-obj exclusive-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_shift-obj}
         ,input (buffer buf_shift-obj:handle)
        ) .

      delete buf_shift-obj .
    end.

    for each buf_c-sht-hist exclusive-lock
      where buf_c-sht-hist.obj-type = p-obj-type
        and buf_c-sht-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-sht-hist}
         ,input (buffer buf_c-sht-hist:handle)
        ) .

      delete buf_c-sht-hist .
    end.


    for each buf_c-shift-obj exclusive-lock
      where buf_c-shift-obj.obj-type = p-obj-type
        and buf_c-shift-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-shift-obj}
         ,input (buffer buf_c-shift-obj:handle)
        ) .

      delete buf_c-shift-obj .
    end.


    for each buf_shift-cash exclusive-lock
      where buf_shift-cash.obj-type = p-obj-type
        and buf_shift-cash.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_shift-cash .
    end.

    for each buf_shift-staff exclusive-lock
      where buf_shift-staff.obj-type = p-obj-type
        and buf_shift-staff.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_shift-staff}
         ,input (buffer buf_shift-staff:handle)
        ) .

      delete buf_shift-staff.
    end.

    for each buf_c-shift-staff exclusive-lock
      where buf_c-shift-staff.obj-type = p-obj-type
        and buf_c-shift-staff.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-shift-staff}
         ,input (buffer buf_c-shift-staff:handle)
        ) .

      delete buf_c-shift-staff .
    end.

  end.

end procedure. /* delete-shift-obj */


procedure delete-place-nozzle-pump :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_place          for ub.place .
  define buffer buf_c-place        for ub.c-place .
  define buffer buf_c-plc-hist     for ub.c-plc-hist.
  define buffer buf_nozzle         for ub.nozzle .
  define buffer buf_c-nzl-hist     for ub.c-nzl-hist .
  define buffer buf_c-nozzle       for ub.c-nozzle .
  define buffer buf_pump           for ub.pump .
  define buffer buf_c-pmp-hist     for ub.c-pmp-hist .
  define buffer buf_c-pump         for ub.c-pump .
  define buffer buf_pl-gds         for ub.pl-gds .
  define buffer buf_c-pl-gds-obj   for ub.c-pl-gds-obj .
  define buffer buf_c-pl-gds       for ub.pl-gds .
  define buffer buf_pl-pump        for ub.pl-pump .
  define buffer buf_c-pl-pump      for ub.c-pl-pump .
  define buffer buf_pump-nozzle    for ub.pump-nozzle .
  define buffer buf_c-pump-nozzle  for ub.c-pump-nozzle .
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle .
  define buffer buf_c-pl-pump-nozzle for ub.c-pl-pump-nozzle .
  define buffer buf_pl-gds-pump    for ub.pl-gds-pump .
  define buffer buf_c-pl-gds-pump  for ub.c-pl-gds-pump .
  define buffer buf_pl-level       for ub.pl-level .
  define buffer buf_c-pl-level     for ub.c-pl-level .

  on delete of ub.place          override do: end.
  on delete of ub.c-place        override do: end.
  on delete of ub.c-plc-hist     override do: end.
  on delete of ub.nozzle         override do: end.
  on delete of ub.c-nzl-hist     override do: end.
  on delete of ub.c-nozzle       override do: end.
  on delete of ub.pump           override do: end.
  on delete of ub.c-pump         override do: end.
  on delete of ub.c-pmp-hist     override do: end.
  on delete of ub.pl-gds         override do: end.
  on delete of ub.c-pl-gds       override do: end.
  on delete of ub.pl-pump        override do: end.
  on delete of ub.c-pl-pump      override do: end.
  on delete of ub.pump-nozzle    override do: end.
  on delete of ub.c-pump-nozzle  override do: end.
  on delete of ub.pl-pump-nozzle override do: end.
  on delete of ub.c-pl-pump-nozzle override do: end.
  on delete of ub.pl-gds-pump    override do: end.
  on delete of ub.c-pl-gds-pump  override do: end.
  on delete of ub.pl-level       override do: end.
  on delete of ub.c-pl-level     override do: end.

  do
  on error undo, return error return-value
  :

    for each buf_place exclusive-lock
      where buf_place.obj-type = p-obj-type
        and buf_place.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_place}
         ,input (buffer buf_place:handle)
        ) .
      delete buf_place .
    end.

    for each buf_c-place exclusive-lock
      where buf_c-place.obj-type = p-obj-type
        and buf_c-place.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-place}
         ,input (buffer buf_c-place:handle)
        ) .
      delete buf_c-place .
    end.

    for each buf_c-plc-hist exclusive-lock
      where buf_c-plc-hist.obj-type = p-obj-type
        and buf_c-plc-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-plc-hist}
         ,input (buffer buf_c-plc-hist:handle)
        ) .
      delete buf_c-plc-hist .
    end.

    for each buf_nozzle exclusive-lock
      where buf_nozzle.obj-type = p-obj-type
        and buf_nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-nozzle}
         ,input (buffer buf_c-nozzle:handle)
        ) .
      delete buf_nozzle .
    end.

    for each buf_c-nzl-hist exclusive-lock
      where buf_c-nzl-hist.obj-type = p-obj-type
        and buf_c-nzl-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-nzl-hist}
         ,input (buffer buf_c-nzl-hist:handle)
        ) .
      delete buf_c-nzl-hist .
    end.

    for each buf_c-nozzle exclusive-lock
      where buf_c-nozzle.obj-type = p-obj-type
        and buf_c-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-nozzle}
         ,input (buffer buf_c-nozzle:handle)
        ) .
      delete buf_c-nozzle .
    end.


    for each buf_pump exclusive-lock
      where buf_pump.obj-type = p-obj-type
        and buf_pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pump}
         ,input (buffer buf_pump:handle)
        ) .
      delete buf_pump .
    end.

    for each buf_c-pump exclusive-lock
      where buf_c-pump.obj-type = p-obj-type
        and buf_c-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pump}
         ,input (buffer buf_c-pump:handle)
        ) .
      delete buf_c-pump .
    end.

    for each buf_c-pmp-hist exclusive-lock
      where buf_c-pmp-hist.obj-type = p-obj-type
        and buf_c-pmp-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pmp-hist}
         ,input (buffer buf_c-pmp-hist:handle)
        ) .
      delete buf_c-pmp-hist .
    end.

    for each buf_pl-gds exclusive-lock
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pl-gds}
         ,input (buffer buf_pl-gds:handle)
        ) .
      delete buf_pl-gds .
    end.


    for each buf_c-pl-gds-obj exclusive-lock
      where buf_c-pl-gds-obj.obj-type = p-obj-type
        and buf_c-pl-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-pl-gds-obj .
    end.

    for each buf_c-pl-gds exclusive-lock
      where buf_c-pl-gds.obj-type = p-obj-type
        and buf_c-pl-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pl-gds}
         ,input (buffer buf_c-pl-gds:handle)
        ) .
      delete buf_c-pl-gds .
    end.


    for each buf_pl-pump exclusive-lock
      where buf_pl-pump.obj-type = p-obj-type
        and buf_pl-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pl-pump}
         ,input (buffer buf_pl-pump:handle)
        ) .
      delete buf_pl-pump .
    end.

    for each buf_c-pl-pump exclusive-lock
      where buf_c-pl-pump.obj-type = p-obj-type
        and buf_c-pl-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pl-pump}
         ,input (buffer buf_c-pl-pump:handle)
        ) .
      delete buf_c-pl-pump .
    end.


    for each buf_pump-nozzle exclusive-lock
      where buf_pump-nozzle.obj-type = p-obj-type
        and buf_pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pump-nozzle}
         ,input (buffer buf_pump-nozzle:handle)
        ) .
      delete buf_pump-nozzle .
    end.

    for each buf_c-pump-nozzle exclusive-lock
      where buf_c-pump-nozzle.obj-type = p-obj-type
        and buf_c-pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pump-nozzle}
         ,input (buffer buf_c-pump-nozzle:handle)
        ) .
      delete buf_c-pump-nozzle .
    end.


    for each buf_pl-pump-nozzle exclusive-lock
      where buf_pl-pump-nozzle.obj-type = p-obj-type
        and buf_pl-pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pl-pump-nozzle}
         ,input (buffer buf_pl-pump-nozzle:handle)
        ) .
      delete buf_pl-pump-nozzle .
    end.

    for each buf_c-pl-pump-nozzle exclusive-lock
      where buf_c-pl-pump-nozzle.obj-type = p-obj-type
        and buf_c-pl-pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pl-pump-nozzle}
         ,input (buffer buf_c-pl-pump-nozzle:handle)
        ) .

      delete buf_c-pl-pump-nozzle .
    end.

    for each buf_pl-gds-pump exclusive-lock
      where buf_pl-gds-pump.obj-type = p-obj-type
        and buf_pl-gds-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pl-gds-pump}
         ,input (buffer buf_pl-gds-pump:handle)
        ) .
      delete buf_pl-gds-pump .
    end.

    for each buf_c-pl-gds-pump exclusive-lock
      where buf_c-pl-gds-pump.obj-type = p-obj-type
        and buf_c-pl-gds-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pl-gds-pump}
         ,input (buffer buf_c-pl-gds-pump:handle)
        ) .
      delete buf_c-pl-gds-pump .
    end.

    for each buf_pl-level exclusive-lock
      where buf_pl-level.obj-type = p-obj-type
        and buf_pl-level.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_pl-level}
         ,input (buffer buf_pl-level:handle)
        ) .
      delete buf_pl-level .
    end.

    for each buf_c-pl-level exclusive-lock
      where buf_c-pl-level.obj-type = p-obj-type
        and buf_c-pl-level.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-pl-level}
         ,input (buffer buf_c-pl-level:handle)
        ) .
      delete buf_c-pl-level .
    end.

  end.

end procedure. /* delete-place-nozzle-pump */


procedure delete-stk-archive :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_stk-line      for ub.stk-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_aht-stk-line  for ub.aht-stk-line .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-tot       for ub.stk-tot .
  define buffer buf_aht-stk-tot   for ub.aht-stk-tot .
  define buffer buf_aht-stk       for ub.aht-stk .

  do
  on error undo, return error return-value
  :
    for each buf_stk-line exclusive-lock
      where buf_stk-line.obj-type = p-obj-type
        and buf_stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-line .
    end.

    for each buf_stk-supp-line exclusive-lock
      where buf_stk-supp-line.obj-type = p-obj-type
        and buf_stk-supp-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-supp-line .
    end.

    for each buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type = p-obj-type
        and buf_aht-stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_aht-stk-line .
    end.

    for each buf_stk-supp-tot exclusive-lock
      where buf_stk-supp-tot.obj-type = p-obj-type
        and buf_stk-supp-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-supp-tot .
    end.

    for each buf_stk-tot exclusive-lock
      where buf_stk-tot.obj-type = p-obj-type
        and buf_stk-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-tot .
    end.

    for each buf_aht-stk-tot exclusive-lock
      where buf_aht-stk-tot.obj-type = p-obj-type
        and buf_aht-stk-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_aht-stk-tot .
    end.

    for each buf_aht-stk exclusive-lock
      where buf_aht-stk.obj-type = p-obj-type
        and buf_aht-stk.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_aht-stk .
    end.
  end.

end procedure. /* delete-stk-archive */


procedure delete-tax :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_tax-rate-gds     for ub.tax-rate-gds .
  define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
  define buffer buf_tax-rate-value   for ub.tax-rate-value .
  define buffer buf_c-tax-hist       for ub.c-tax-hist.
  define buffer buf_c-gds-hist       for ub.c-gds-hist.

  on delete of ub.c-tax-hist       override do: end.
  on delete of ub.tax-rate-gds     override do: end.
  on delete of ub.tax-rate-gds-grp override do: end.
  on delete of ub.tax-rate-value   override do: end.

  do
  on error undo, return error return-value
  :

    for each buf_tax-rate-gds exclusive-lock
      where buf_tax-rate-gds.obj-type = p-obj-type
        and buf_tax-rate-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
    for each buf_c-gds-hist where
            buf_c-gds-hist.gds-code = buf_tax-rate-gds.rate-code
        AND buf_c-gds-hist.subject   = {&table_tax-rate-gds}
        AND buf_c-gds-hist.host-code = buf_tax-rate-gds.host-code
        AND buf_c-gds-hist.obj-type  = buf_tax-rate-gds.obj-type
        AND buf_c-gds-hist.obj-code  = buf_tax-rate-gds.obj-code
        AND buf_c-gds-hist.tax-code = buf_tax-rate-gds.tax-code

        :
        delete buf_c-gds-hist.
    end.
      delete buf_tax-rate-gds .
    end.

    for each buf_tax-rate-gds-grp exclusive-lock
      where buf_tax-rate-gds-grp.obj-type = p-obj-type
        and buf_tax-rate-gds-grp.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_tax-rate-gds-grp .
    end.

    for each buf_tax-rate-value exclusive-lock
      where buf_tax-rate-value.obj-type = p-obj-type
        and buf_tax-rate-value.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-tax-hist where
              buf_c-tax-hist.tax-code = buf_tax-rate-value.tax-code
          AND buf_c-tax-hist.rate-code = buf_tax-rate-value.rate-code
          AND buf_c-tax-hist.host-code = buf_tax-rate-value.host-code
          AND buf_c-tax-hist.obj-type  = buf_tax-rate-value.obj-type
          AND buf_c-tax-hist.obj-code = buf_tax-rate-value.obj-code :
        delete buf_c-tax-hist.
      end.
      delete buf_tax-rate-value .
    end.

  end.

end procedure. /* delete-tax */


procedure delete-dis-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_dis-obj       for ub.dis-obj .
  define buffer buf_c-dis-obj     for ub.c-dis-obj .
  define buffer buf_dis-host      for ub.dis-host.
  define buffer buf_dis-card      for ub.dis-card.
  define buffer buf_c-dc-hist     for ub.c-dc-hist.

  on delete of ub.dis-obj          override do: end.
  on delete of ub.c-dis-obj        override do: end.
  on write  of ub.dis-host         override do: end.
  on write  of ub.dis-card         override do: end.
  on delete  of ub.c-dc-hist       override do: end.
  on write   of ub.c-dc-hist       override do: end.



  do
  on error undo, return error return-value
  :
    for each buf_dis-obj exclusive-lock
      where buf_dis-obj.obj-type = p-obj-type
        and buf_dis-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-obj
          where buf_c-dis-obj.d-card = buf_dis-obj.d-card
            AND buf_c-dis-obj.obj-type = buf_dis-obj.obj-type
            AND buf_c-dis-obj.obj-code = buf_dis-obj.obj-code:

        run delete-route in this-procedure
          ( input {&table_c-dis-obj}
          ,input (buffer buf_c-dis-obj:handle)
          ) .
      end.
      for each buf_c-dc-hist
          where buf_c-dc-hist.d-card = buf_dis-obj.d-card
            AND buf_c-dc-hist.chip-num = buf_c-dis-obj.chip-num
            AND buf_c-dc-hist.corr-user-db-num = buf_c-dis-obj.corr-user-db-num
            AND buf_c-dc-hist.host-code = buf_dis-obj.host-code
            AND buf_c-dc-hist.obj-type = buf_dis-obj.obj-type
            AND buf_c-dc-hist.obj-code = buf_dis-obj.obj-code:
        if buf_c-dc-hist.subject = {&table_dis-obj}
        and buf_c-dc-hist.source-type = {&pmnt-cash-desk}
        then do:
           assign
           buf_c-dc-hist.subject = {&table_dis-host}
           buf_c-dc-hist.source-type = {&pmnt-trn-doc}
           .
        end.
        else do:
          delete buf_c-dc-hist.
          run delete-route in this-procedure
            ( input {&table_c-dc-hist}
            ,input (buffer buf_c-dc-hist:handle)
            ) .
        end.
      end.
      run delete-route in this-procedure
          ( input {&table_dis-obj}
          ,input (buffer buf_dis-obj:handle)
          ) .
      delete buf_dis-obj .
    end.
  end.

end procedure. /* delete-dis-obj */

procedure delete-dis-dc-rule :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_c-dc-hist     for ub.c-dc-hist.
  define buffer buf_clients for ub.clients.
  define buffer buf_dis-card-property for ub.dis-card-property.
  define buffer buf_c-dis-card-property for ub.c-dis-card-property.
  define buffer buf_dis-dc-rule for ub.dis-dc-rule.
  define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.



  on delete  of ub.c-dc-hist       override do: end.

  on delete  of ub.dis-dc-rule   override do: end.
  on delete  of ub.c-dis-dc-rule override do: end.



  define variable v-host-code like ub.sysconf.host-code no-undo .
  define variable ii as integer no-undo .

  do
  on error undo, return error return-value
  :

    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          AND buf_clients.obj-code = p-obj-code.
    assign
    v-host-code = buf_clients.host-code
    .
    for each buf_dis-card-property exclusive-lock
      where buf_dis-card-property.host-code = v-host-code
        and buf_dis-card-property.obj-type = p-obj-type
        and buf_dis-card-property.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-card-property exclusive-lock
        where  buf_c-dis-card-property.d-card = buf_dis-card-property.d-card
          and buf_c-dis-card-property.dt-code = buf_dis-card-property.dt-code
          and buf_c-dis-card-property.node-code = buf_dis-card-property.node-code
          and buf_c-dis-card-property.host-code = buf_dis-card-property.host-code
          and buf_c-dis-card-property.obj-type = p-obj-type
          and buf_c-dis-card-property.obj-code = p-obj-code:

        run delete-route in this-procedure
          ( input {&table_c-dis-card-property}
          ,input (buffer buf_c-dis-card-property:handle)
          ) .
        delete buf_c-dis-card-property .

      end.
      for each buf_c-dc-hist
        where buf_c-dc-hist.obj-type = p-obj-type
          AND buf_c-dc-hist.obj-code = p-obj-code
          AND buf_c-dc-hist.d-card = buf_c-dis-card-property.d-card
          AND buf_c-dc-hist.subject = {&table_dis-card-property}:

        run delete-route in this-procedure
          ( input {&table_c-dc-hist}
          ,input (buffer buf_c-dc-hist:handle)
          ) .
        delete buf_c-dc-hist.
      end.
      run delete-route in this-procedure
        ( input {&table_dis-card-property}
        ,input (buffer buf_c-dis-card-property:handle)
        ) .

      delete buf_dis-card-property .
    end. /*for each buf_dis-card-property*/
    for each buf_dis-dc-rule exclusive-lock
      where buf_dis-dc-rule.host-code = v-host-code
        and buf_dis-dc-rule.obj-type = p-obj-type
        and buf_dis-dc-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-dc-rule exclusive-lock
        where  buf_c-dis-dc-rule.d-card = buf_dis-dc-rule.d-card
          and buf_c-dis-dc-rule.pos-type = buf_dis-dc-rule.pos-type
          and buf_c-dis-dc-rule.discnt-role = buf_dis-dc-rule.discnt-role
          and buf_c-dis-dc-rule.nonunique = buf_dis-dc-rule.nonunique
          and buf_c-dis-dc-rule.host-code = buf_dis-dc-rule.host-code
          and buf_c-dis-dc-rule.obj-type = p-obj-type
          and buf_c-dis-dc-rule.obj-code = p-obj-code:

        run delete-route in this-procedure
          ( input {&table_c-dis-dc-rule}
          ,input (buffer buf_c-dis-dc-rule:handle)
          ) .
        delete buf_c-dis-dc-rule .

      end.
      for each buf_c-dc-hist
        where buf_c-dc-hist.obj-type = p-obj-type
          AND buf_c-dc-hist.obj-code = p-obj-code
          AND buf_c-dc-hist.d-card = buf_c-dis-dc-rule.d-card
          AND buf_c-dc-hist.subject = {&table_dis-dc-rule}:

        run delete-route in this-procedure
          ( input {&table_c-dc-hist}
          ,input (buffer buf_c-dc-hist:handle)
          ) .
        delete buf_c-dc-hist.
      end.
      run delete-route in this-procedure
        ( input {&table_dis-dc-rule}
        ,input (buffer buf_c-dis-dc-rule:handle)
        ) .

      delete buf_dis-dc-rule .
    end. /*for each buf_dis-dc-rule*/
  end. /*doe*/

end procedure. /* delete-dis-dc-rule */



procedure delete-dis-card-type :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_dis-card-type for ub.dis-card-type .
  define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
  define buffer buf_dis-card-mask for ub.dis-card-mask .
  define buffer buf_dis-dct-rule for ub.dis-dct-rule .
  define buffer buf_c-dis-card-type for ub.c-dis-card-type .
  define buffer buf_c-dis-card-type-attr for ub.c-dis-card-type-attr .
  define buffer buf_c-dis-card-mask for ub.c-dis-card-mask .
  define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule .


  on delete of ub.dis-card-type override do: end.
  on delete of ub.c-dis-card-type override do: end.
  on delete of ub.dis-card-type-attr override do: end.
  on delete of ub.c-dis-card-type-attr override do: end.
  on delete of ub.dis-card-mask override do: end.
  on delete of ub.c-dis-card-mask override do: end.
  on delete of ub.dis-dct-rule override do: end.
  on delete of ub.c-dis-dct-rule override do: end.



  do
  on error undo, return error return-value
  :

    for each buf_dis-card-type exclusive-lock
      where buf_dis-card-type.obj-type = p-obj-type
        and buf_dis-card-type.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-card-type exclusive-lock
        where buf_c-dis-card-type.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-card-type.type = buf_dis-card-type.type
          and buf_c-dis-card-type.host-code = buf_dis-card-type.host-code
          and buf_c-dis-card-type.obj-type = p-obj-type
          and buf_c-dis-card-type.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-dis-card-type}
          ,input (buffer buf_c-dis-card-type:handle)
          ) .
        delete buf_c-dis-card-type .
      end.

      for each buf_dis-card-type-attr exclusive-lock
        where buf_dis-card-type-attr.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_dis-card-type-attr.type = buf_dis-card-type.type
          and buf_dis-card-type-attr.host-code = buf_dis-card-type.host-code
          and buf_dis-card-type-attr.obj-type = p-obj-type
          and buf_dis-card-type-attr.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_dis-card-type-attr}
          ,input (buffer buf_dis-card-type-attr:handle)
          ) .
        delete buf_dis-card-type-attr .
      end.

      for each buf_c-dis-card-type-attr exclusive-lock
        where buf_c-dis-card-type-attr.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-card-type-attr.type = buf_dis-card-type.type
          and buf_c-dis-card-type-attr.host-code = buf_dis-card-type.host-code
          and buf_c-dis-card-type-attr.obj-type = p-obj-type
          and buf_c-dis-card-type-attr.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-dis-card-type-attr}
          ,input (buffer buf_c-dis-card-type-attr:handle)
          ) .
        delete buf_c-dis-card-type-attr .
      end.

      for each buf_dis-card-mask exclusive-lock
        where buf_dis-card-mask.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_dis-card-mask.type = buf_dis-card-type.type
          and buf_dis-card-mask.host-code = buf_dis-card-type.host-code
          and buf_dis-card-mask.obj-type = p-obj-type
          and buf_dis-card-mask.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_dis-card-mask}
          ,input (buffer buf_dis-card-mask:handle)
          ) .
        delete buf_dis-card-mask .
      end.

      for each buf_c-dis-card-mask exclusive-lock
        where buf_c-dis-card-mask.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-card-mask.type = buf_dis-card-type.type
          and buf_c-dis-card-mask.host-code = buf_dis-card-type.host-code
          and buf_c-dis-card-mask.obj-type = p-obj-type
          and buf_c-dis-card-mask.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-dis-card-mask}
          ,input (buffer buf_c-dis-card-mask:handle)
          ) .
        delete buf_c-dis-card-mask .
      end.
      for each buf_dis-dct-rule exclusive-lock
        where buf_dis-dct-rule.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_dis-dct-rule.type = buf_dis-card-type.type
          and buf_dis-dct-rule.host-code = buf_dis-card-type.host-code
          and buf_dis-dct-rule.obj-type = p-obj-type
          and buf_dis-dct-rule.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_dis-dct-rule}
          ,input (buffer buf_dis-dct-rule:handle)
          ) .
        delete buf_dis-dct-rule .
      end.

      for each buf_c-dis-dct-rule exclusive-lock
        where buf_c-dis-dct-rule.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-dct-rule.type = buf_dis-card-type.type
          and buf_c-dis-dct-rule.host-code = buf_dis-card-type.host-code
          and buf_c-dis-dct-rule.obj-type = p-obj-type
          and buf_c-dis-dct-rule.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-dis-dct-rule}
          ,input (buffer buf_c-dis-dct-rule:handle)
          ) .
        delete buf_c-dis-dct-rule .
      end.

      run delete-route in this-procedure
        ( input {&table_dis-card-type}
         ,input (buffer buf_dis-card-type:handle)
        ) .

      delete buf_dis-card-type .
    end.
  end.

end procedure. /* delete-dis-card-type */


procedure delete-dis-rule :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_dis-rule for ub.dis-rule .
  define buffer buf_c-dis-rule for ub.c-dis-rule .
  define buffer buf_clients for ub.clients.

  on delete of ub.dis-rule override do: end.
  on delete of ub.c-dis-rule override do: end.
  define variable v-host-code like ub.sysconf.host-code no-undo .


  do
  on error undo, return error return-value
  :

    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          AND buf_clients.obj-code = p-obj-code.
    assign
    v-host-code = buf_clients.host-code
    .

    for each buf_dis-rule exclusive-lock
      where buf_dis-rule.host-code = v-host-code
        and buf_dis-rule.obj-type = p-obj-type
        and buf_dis-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-rule exclusive-lock
        where buf_c-dis-rule.rule-num = buf_dis-rule.rule-num
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-dis-rule}
          ,input (buffer buf_c-dis-rule:handle)
          ) .
        delete buf_c-dis-rule .
      end.

      run delete-route in this-procedure
        ( input {&table_dis-rule}
         ,input (buffer buf_dis-rule:handle)
        ) .

      delete buf_dis-rule .
    end.
  end.

end procedure. /* delete-dis-rule */







procedure delete-scales-gds :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_scales-gds for ub.scales-gds .
  define buffer buf_c-scales-gds for ub.scales-gds .

  on delete of ub.scales-gds   override do: end.
  on delete of ub.c-scales-gds override do: end.

  do
  on error undo, return error return-value
  :
    for each buf_scales-gds exclusive-lock
      where buf_scales-gds.obj-type = p-obj-type
        and buf_scales-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_scales-gds}
         ,input (buffer buf_scales-gds:handle)
        ) .
      delete buf_scales-gds .
    end.
    for each buf_c-scales-gds exclusive-lock
      where buf_c-scales-gds.obj-type = p-obj-type
        and buf_c-scales-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-scales-gds}
         ,input (buffer buf_c-scales-gds:handle)
        ) .
      delete buf_c-scales-gds .
    end.


  end.

end procedure. /* delete-scales-gds */


procedure delete-variant-delivery :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_variant-delivery for ub.variant-delivery .
  define buffer buf_c-variant-delivery for ub.c-variant-delivery .
  define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val .
  define buffer buf_c-var-deliv-gr-per-val for ub.c-var-deliv-gr-per-val .

  on delete of ub.variant-delivery override do: end.
  on delete of ub.c-variant-delivery override do: end.
  on delete of ub.var-deliv-gr-per-val override do: end.
  on delete of ub.c-var-deliv-gr-per-val override do: end.


  do
  on error undo, return error return-value
  :
    for each buf_variant-delivery exclusive-lock
      where buf_variant-delivery.obj-type = p-obj-type
        and buf_variant-delivery.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-variant-delivery exclusive-lock
        where buf_c-variant-delivery.deliv-type-code = buf_variant-delivery.deliv-type-code
          and buf_c-variant-delivery.deliv-subj-code = buf_variant-delivery.deliv-subj-code
          and buf_c-variant-delivery.obj-type = p-obj-type
          and buf_c-variant-delivery.obj-code = p-obj-code
      on error undo, return error return-value:

        run delete-route in this-procedure
          ( input {&table_c-variant-delivery}
          ,input (buffer buf_c-variant-delivery:handle)
          ) .
        delete buf_c-variant-delivery .

      end.
      run delete-route in this-procedure
        ( input {&table_variant-delivery}
        ,input (buffer buf_variant-delivery:handle)
        ) .
      delete buf_variant-delivery .
    end.

    for each buf_var-deliv-gr-per-val exclusive-lock
      where buf_var-deliv-gr-per-val.obj-type = p-obj-type
        and buf_var-deliv-gr-per-val.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-var-deliv-gr-per-val exclusive-lock
        where buf_c-var-deliv-gr-per-val.deliv-type-code = buf_var-deliv-gr-per-val.deliv-type-code
          and buf_c-var-deliv-gr-per-val.deliv-subj-code = buf_var-deliv-gr-per-val.deliv-subj-code
          and buf_c-var-deliv-gr-per-val.obj-type = p-obj-type
          and buf_c-var-deliv-gr-per-val.obj-code = p-obj-code
      on error undo, return error return-value:

        run delete-route in this-procedure
          ( input {&table_c-var-deliv-gr-per-val}
          ,input (buffer buf_c-var-deliv-gr-per-val:handle)
          ) .
        delete buf_c-var-deliv-gr-per-val .

      end.
      run delete-route in this-procedure
        ( input {&table_var-deliv-gr-per-val}
        ,input (buffer buf_var-deliv-gr-per-val:handle)
        ) .
      delete buf_var-deliv-gr-per-val .
    end.


  end.

end procedure. /* delete-variant-delivery */

procedure delete-gds-grp-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_gds-grp-attr for ub.gds-grp-attr .
  define buffer buf_gds-grp-obj for ub.gds-grp-obj .
  define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
  define buffer buf_c-gds-grp-attr for ub.c-gds-grp-attr .
  define buffer buf_c-gds-grp-obj for ub.c-gds-grp-obj .
  define buffer buf_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp .
  define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.


  on delete of ub.gds-grp-attr override do: end.
  on delete of ub.gds-grp-obj override do: end.
  on delete of ub.tax-rate-gds-grp override do: end.

  on delete of ub.c-gds-grp-attr override do: end.
  on delete of ub.c-gds-grp-obj override do: end.
  on delete of ub.c-tax-rate-gds-grp override do: end.
  on delete of ub.c-gds-grp-hist override do: end.


  do
  on error undo, return error return-value
  :
    for each buf_gds-grp-attr exclusive-lock
      where buf_gds-grp-attr.obj-type = p-obj-type
        and buf_gds-grp-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-gds-grp-attr exclusive-lock
         WHERE buf_c-gds-grp-attr.node-code = buf_gds-grp-attr.node-code
          AND  buf_c-gds-grp-attr.host-code  = buf_gds-grp-attr.host-code
          AND  buf_c-gds-grp-attr.attr-code  = buf_gds-grp-attr.attr-code
          AND  buf_c-gds-grp-attr.obj-type  = buf_gds-grp-attr.obj-type
          AND  buf_c-gds-grp-attr.obj-code  = buf_gds-grp-attr.obj-code,
         first buf_c-gds-grp-hist exclusive-lock
         WHERE buf_c-gds-grp-hist.node-code = buf_gds-grp-attr.node-code
           AND buf_c-gds-grp-hist.corr-user-db-num  = buf_c-gds-grp-attr.corr-user-db-num
           AND buf_c-gds-grp-hist.chip-num  = buf_c-gds-grp-attr.chip-num
           AND buf_c-gds-grp-hist.attr-code  = buf_gds-grp-attr.attr-code
           AND buf_c-gds-grp-hist.host-code  = buf_gds-grp-attr.host-code
           AND buf_c-gds-grp-hist.obj-type  = buf_gds-grp-attr.obj-type
           AND buf_c-gds-grp-hist.obj-code  = buf_gds-grp-attr.obj-code
           AND buf_c-gds-grp-hist.subject   = {&table_gds-grp-attr}
           :
        run delete-route in this-procedure
          ( input {&table_c-gds-grp-attr}
          ,input (buffer buf_c-gds-grp-attr:handle)
          ) .

        run delete-route in this-procedure
          ( input {&table_c-gds-grp-hist}
          ,input (buffer buf_c-gds-grp-hist:handle)
          ) .
      end.
      run delete-route in this-procedure
        ( input {&table_gds-grp-attr}
        ,input (buffer buf_gds-grp-attr:handle)
        ) .
      delete buf_gds-grp-attr .
    end.

    for each buf_gds-grp-obj exclusive-lock
      where buf_gds-grp-obj.obj-type = p-obj-type
        and buf_gds-grp-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-gds-grp-obj exclusive-lock
         WHERE buf_c-gds-grp-obj.node-code = buf_gds-grp-obj.node-code
          AND  buf_c-gds-grp-obj.host-code  = buf_gds-grp-obj.host-code
          AND  buf_c-gds-grp-obj.obj-type  = buf_gds-grp-obj.obj-type
          AND  buf_c-gds-grp-obj.obj-code  = buf_gds-grp-obj.obj-code ,
         first buf_c-gds-grp-hist exclusive-lock
         WHERE buf_c-gds-grp-hist.node-code = buf_gds-grp-obj.node-code
           AND buf_c-gds-grp-hist.corr-user-db-num  = buf_c-gds-grp-obj.corr-user-db-num
           AND buf_c-gds-grp-hist.chip-num  = buf_c-gds-grp-obj.chip-num
           AND buf_c-gds-grp-hist.host-code  = buf_gds-grp-obj.host-code
           AND buf_c-gds-grp-hist.obj-type  = buf_gds-grp-obj.obj-type
           AND buf_c-gds-grp-hist.obj-code  = buf_gds-grp-obj.obj-code
           AND buf_c-gds-grp-hist.subject   = {&table_gds-grp-obj}
           :
        run delete-route in this-procedure
          ( input {&table_c-gds-grp-obj}
          ,input (buffer buf_c-gds-grp-obj:handle)
          ) .
        run delete-route in this-procedure
          ( input {&table_c-gds-grp-hist}
          ,input (buffer buf_c-gds-grp-hist:handle)
          ) .
      end.
      run delete-route in this-procedure
        ( input {&table_gds-grp-obj}
        ,input (buffer buf_gds-grp-obj:handle)
        ) .
      delete buf_gds-grp-obj .
    end.
    /*todo tax-rate-gds-grp*/


  end.

end procedure. /* delete-gds-grp-attr */


procedure delete-sum-grp-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_sum-grp-obj for ub.sum-grp-obj .
  define buffer buf_c-sum-grp-obj for ub.c-sum-grp-obj .
  define buffer buf_dis-grp-rule for ub.dis-grp-rule.
  define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule.

  on delete of ub.sum-grp-obj override do: end.
  on delete of ub.c-sum-grp-obj override do: end.
  on delete of ub.dis-grp-rule override do: end.
  on delete of ub.c-dis-grp-rule override do: end.


  do
  on error undo, return error return-value
  :

    for each buf_sum-grp-obj exclusive-lock
      where buf_sum-grp-obj.obj-type = p-obj-type
        and buf_sum-grp-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_sum-grp-obj}
        ,input (buffer buf_sum-grp-obj:handle)
        ) .
      delete buf_sum-grp-obj .
    end.

    for each buf_c-sum-grp-obj exclusive-lock
      where buf_c-sum-grp-obj.obj-type = p-obj-type
        and buf_c-sum-grp-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-sum-grp-obj}
        ,input (buffer buf_c-sum-grp-obj:handle)
        ) .
      delete buf_c-sum-grp-obj .
    end.

    for each buf_c-dis-grp-rule exclusive-lock
      where buf_c-dis-grp-rule.obj-type = p-obj-type
        and buf_c-dis-grp-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_c-dis-grp-rule}
        ,input (buffer buf_c-dis-grp-rule:handle)
        ) .
      delete buf_c-dis-grp-rule .
    end.
    for each buf_dis-grp-rule exclusive-lock
      where buf_dis-grp-rule.obj-type = p-obj-type
        and buf_dis-grp-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input {&table_dis-grp-rule}
        ,input (buffer buf_dis-grp-rule:handle)
        ) .
      delete buf_dis-grp-rule .
    end.




  end.

end procedure. /* delete-gds-grp-attr */

procedure delete-config :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    on delete of ub.config   override do: end.
    on delete of ub.c-config override do: end.

    define buffer buf_config   for ub.config .
    define buffer buf_c-config for ub.c-config .

    for each buf_config exclusive-lock
      where buf_config.obj-type = p-obj-type
        and buf_config.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-config exclusive-lock
        where buf_c-config.param-code = buf_config.param-code
          and buf_c-config.host-code  = buf_config.host-code
          and buf_c-config.obj-type   = buf_config.obj-type
          and buf_c-config.obj-code   = buf_config.obj-code
          and buf_c-config.beg-date   = buf_config.beg-date
          and buf_c-config.end-date   = buf_config.end-date
          and buf_c-config.db-num     = buf_config.db-num
      on error undo, return error return-value
      :
        delete buf_c-config .
        run delete-route in this-procedure
          ( input {&table_c-config}
          , input (buffer buf_c-config:handle)
          ) .
      end.
      delete buf_config .
      run delete-route in this-procedure
        ( input {&table_config}
        , input (buffer buf_config:handle)
        ) .
    end.

  end.

end procedure. /* delete-config */


procedure delete-user-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_user-obj for ub.user-obj .
  define buffer buf_user-menu-group        for ub.user-menu-group .
  define buffer buf_user-login-action-role for ub.user-login-action-role .

  on delete of ub.user-obj                override do: end.
  on delete of ub.user-menu-group         override do: end.
  on delete of ub.user-login-action-role  override do: end.

  do
  on error undo, return error return-value
  :
    for each buf_user-obj exclusive-lock
      where buf_user-obj.obj-type = p-obj-type
        and buf_user-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_user-obj .
      run delete-route in this-procedure
        ( input {&table_user-obj}
        , input (buffer buf_user-obj:handle)
        ) .
    end.
    for each  buf_user-menu-group
        where buf_user-menu-group.db-num   = ub.user-obj.db-num
          and buf_user-menu-group.user-id  = ub.user-obj.user-id
          and buf_user-menu-group.obj-type = ub.user-obj.obj-type
          and buf_user-menu-group.obj-code = ub.user-obj.obj-code
          and buf_user-menu-group.menu-group-context = {&cntxt-object}
        exclusive-lock
        :
        delete buf_user-menu-group.
      run delete-route in this-procedure
        ( input {&table_user-menu-group}
        , input (buffer buf_user-menu-group:handle)
        ) .
    end.

    for each  buf_user-login-action-role
        where buf_user-login-action-role.db-num  = ub.user-obj.db-num
          and buf_user-login-action-role.user-id = ub.user-obj.user-id
          and buf_user-login-action-role.obj-type = ub.user-obj.obj-type
          and buf_user-login-action-role.obj-code = ub.user-obj.obj-code
          and buf_user-login-action-role.action-role-context = {&cntxt-object}
        exclusive-lock
        :
        delete buf_user-login-action-role.
      run delete-route in this-procedure
        ( input {&table_user-login-action-role}
        , input (buffer buf_user-login-action-role:handle)
        ) .
    end.


  end.

end procedure. /* delete-user-obj */


procedure delete-action-post-obj :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_action-post-obj for ub.action-post-obj .
  on delete of ub.action-post-obj  override do: end.

  do
  on error undo, return error return-value
  :
    for each buf_action-post-obj exclusive-lock
      where buf_action-post-obj.obj-type = p-obj-type
        and buf_action-post-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_action-post-obj .
      run delete-route in this-procedure
        ( input {&table_action-post-obj}
        , input (buffer buf_action-post-obj:handle)
        ) .
    end.

  end.

end procedure. /* delete-action-post-obj */

procedure delete-clients :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-uniq-ky-rec as character no-undo .

  define buffer buf_clients      for ub.clients .
  define buffer buf_c-clients    for ub.c-clients .
  define buffer buf_clients-attr for ub.clients-attr .
  define buffer buf_c-clients-attr for ub.c-clients-attr .
  define buffer buf_thbj-attr for ub.thbj-attr .
  define buffer buf_c-thbj-attr for ub.c-thbj-attr .
  define buffer buf_shop         for ub.shop .
  define buffer buf_c-shop       for ub.c-shop .
  define buffer buf_store        for ub.store .
  define buffer buf_c-store        for ub.c-store .
  define buffer buf_cash-desk    for ub.cash-desk .
  define buffer buf_c-cash-desk  for ub.c-cash-desk .
  define buffer buf_cash-desk-attr    for ub.cash-desk-attr .
  define buffer buf_c-cash-desk-attr  for ub.c-cash-desk-attr .
  define buffer buf_cash-pay-attr    for ub.cash-pay-attr .
  define buffer buf_c-cash-pay-attr  for ub.c-cash-pay-attr .
  define buffer buf_dis-cp-rule for ub.dis-cp-rule.
  define buffer buf_c-dis-cp-rule for ub.c-dis-cp-rule.
  define buffer buf_curr-shop    for ub.curr-shop .
  define buffer buf_c-cli-hist   for ub.c-cli-hist.
  define buffer buf_dis-thbj-rule for ub.dis-thbj-rule .
  define buffer buf_c-dis-thbj-rule for ub.c-dis-thbj-rule .
  define buffer buf_cd-clu for ub.cd-clu.
  define buffer buf_c-cd-clu for ub.c-cd-clu.
  define buffer buf_cd-dlu for ub.cd-dlu.
  define buffer buf_c-cd-dlu for ub.c-cd-dlu.
  define buffer buf_cd-grp for ub.cd-grp.
  define buffer buf_c-cd-grp for ub.c-cd-grp.
  define buffer buf_cd-plu for ub.cd-plu.
  define buffer buf_c-cd-plu for ub.c-cd-plu.
  define buffer buf_cd-doc for ub.cd-doc.
  define buffer buf_c-cd-doc for ub.c-cd-doc.
  define buffer buf_cd-doc-line for ub.cd-doc-line.
  define buffer buf_c-cd-doc-line for ub.c-cd-doc-line.



  on delete of ub.clients       override do: end.
  on delete of ub.c-clients     override do: end.
  on delete of ub.clients-attr  override do: end.
  on delete of ub.c-clients-attr  override do: end.
  on delete of ub.thbj-attr  override do: end.
  on delete of ub.c-thbj-attr  override do: end.
  on delete of ub.shop          override do: end.
  on delete of ub.c-shop          override do: end.
  on delete of ub.store         override do: end.
  on delete of ub.c-store         override do: end.
  on delete of ub.cash-desk     override do: end.
  on delete of ub.c-cash-desk   override do: end.
  on delete of ub.cash-desk-attr     override do: end.
  on delete of ub.c-cash-desk-attr   override do: end.
  on delete of ub.cash-pay-attr     override do: end.
  on delete of ub.c-cash-pay-attr   override do: end.
  on delete of ub.dis-cp-rule     override do: end.
  on delete of ub.dis-cp-rule     override do: end.
  on delete of ub.curr-shop     override do: end.
  on delete of ub.c-cli-hist    override do: end.
  on delete of ub.dis-thbj-rule  override do: end.
  on delete of ub.c-dis-thbj-rule override do: end.
  on delete of ub.cd-clu override do: end.
  on delete of ub.c-cd-clu override do: end.
  on delete of ub.cd-dlu override do: end.
  on delete of ub.c-cd-dlu override do: end.
  on delete of ub.cd-grp override do: end.
  on delete of ub.c-cd-grp override do: end.
  on delete of ub.cd-plu override do: end.
  on delete of ub.c-cd-plu override do: end.
  on delete of ub.cd-doc override do: end.
  on delete of ub.c-cd-doc override do: end.
  on delete of ub.cd-doc-line override do: end.
  on delete of ub.c-cd-doc-line override do: end.


  do
  on error undo, return error
  :
    find first buf_clients exclusive-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      .
    run gen-key-rec in this-procedure ( input {&table_clients}
                                      ,input (buffer buf_clients:handle)
                                      ,output v-uniq-key-rec).

    if buf_clients.obj-type = {&stock} then do:
      find buf_store exclusive-lock
        where buf_store.obj-code = buf_clients.obj-code
        .
      run delete-route in this-procedure
        ( input {&table_store}
         ,input (buffer buf_store:handle)
        ) .
      for each buf_c-store exclusive-lock
          where buf_c-store.obj-code  = buf_clients.obj-code:
        run delete-route in this-procedure
          ( input {&table_store}
          ,input (buffer buf_store:handle)
          ) .
        delete buf_c-store.
      end.
      delete buf_store .
    end.

    if buf_clients.obj-type = {&shop} then do:
      find buf_shop exclusive-lock
        where buf_shop.obj-code = buf_clients.obj-code
        .
      run delete-route in this-procedure
        ( input {&table_shop}
         ,input (buffer buf_shop:handle)
        ) .
      for each buf_c-shop exclusive-lock
          where buf_c-shop.obj-code  = buf_clients.obj-code:
        run delete-route in this-procedure
          ( input {&table_shop}
          ,input (buffer buf_shop:handle)
          ) .
        delete buf_c-shop.
      end.


      for each buf_cash-desk exclusive-lock
        where buf_cash-desk.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cash-desk}
          ,input (buffer buf_cash-desk:handle)
          ) .
        delete buf_cash-desk .
      end.

      for each buf_c-cash-desk exclusive-lock
        where buf_c-cash-desk.db-num   = buf_clients.db-num
          AND buf_c-cash-desk.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cash-desk}
          ,input (buffer buf_c-cash-desk:handle)
          ) .
        delete buf_c-cash-desk .
      end.

      for each buf_cash-desk-attr exclusive-lock
        where buf_cash-desk-attr.db-num   = buf_clients.db-num
          AND buf_cash-desk-attr.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cash-desk-attr}
          ,input (buffer buf_cash-desk-attr:handle)
          ) .
        delete buf_cash-desk-attr .
      end.

      for each buf_c-cash-desk-attr exclusive-lock
        where buf_c-cash-desk-attr.db-num   = buf_clients.db-num
          AND buf_c-cash-desk-attr.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cash-desk-attr}
          ,input (buffer buf_c-cash-desk-attr:handle)
          ) .
        delete buf_c-cash-desk-attr .
      end.

      for each buf_cd-clu exclusive-lock
        where buf_cd-clu.obj-type = {&shop}
          AND buf_cd-clu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cd-clu}
          ,input (buffer buf_cd-clu:handle)
          ) .
        delete buf_cd-clu .
      end.

      for each buf_c-cd-clu exclusive-lock
        where buf_c-cd-clu.obj-type = {&shop}
          AND buf_c-cd-clu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cd-clu}
          ,input (buffer buf_c-cd-clu:handle)
          ) .
        delete buf_c-cd-clu .
      end.

      for each buf_cd-dlu exclusive-lock
        where buf_cd-dlu.obj-type = {&shop}
          AND buf_cd-dlu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cd-dlu}
          ,input (buffer buf_cd-dlu:handle)
          ) .
        delete buf_cd-dlu .
      end.

      for each buf_c-cd-dlu exclusive-lock
        where buf_c-cd-dlu.obj-type = {&shop}
          AND buf_c-cd-dlu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cd-dlu}
          ,input (buffer buf_c-cd-dlu:handle)
          ) .
        delete buf_c-cd-dlu .
      end.

      for each buf_cd-grp exclusive-lock
        where buf_cd-grp.obj-type = {&shop}
          AND buf_cd-grp.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cd-grp}
          ,input (buffer buf_cd-grp:handle)
          ) .
        delete buf_cd-grp .
      end.

      for each buf_c-cd-grp exclusive-lock
        where buf_c-cd-grp.obj-type = {&shop}
          AND buf_c-cd-grp.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cd-grp}
          ,input (buffer buf_c-cd-grp:handle)
          ) .
        delete buf_c-cd-grp .
      end.

      for each buf_cd-plu exclusive-lock
        where buf_cd-plu.obj-type = {&shop}
          AND buf_cd-plu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cd-plu}
          ,input (buffer buf_cd-plu:handle)
          ) .
        delete buf_cd-plu .
      end.

      for each buf_c-cd-plu exclusive-lock
        where buf_c-cd-plu.obj-type = {&shop}
          AND buf_c-cd-plu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cd-plu}
          ,input (buffer buf_c-cd-plu:handle)
          ) .
        delete buf_c-cd-plu .
      end.

      for each buf_cd-doc exclusive-lock
        where buf_cd-doc.obj-type = {&shop}
          AND buf_cd-doc.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cd-doc}
          ,input (buffer buf_cd-doc:handle)
          ) .
        delete buf_cd-doc .
      end.

      for each buf_c-cd-doc exclusive-lock
        where buf_c-cd-doc.obj-type = {&shop}
          AND buf_c-cd-doc.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cd-doc}
          ,input (buffer buf_c-cd-doc:handle)
          ) .
        delete buf_c-cd-doc .
      end.
      for each buf_cd-doc-line exclusive-lock
        where buf_cd-doc-line.obj-type = {&shop}
          AND buf_cd-doc-line.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_cd-doc-line}
          ,input (buffer buf_cd-doc-line:handle)
          ) .
        delete buf_cd-doc-line .
      end.

      for each buf_c-cd-doc-line exclusive-lock
        where buf_c-cd-doc-line.obj-type = {&shop}
          AND buf_c-cd-doc-line.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input {&table_c-cd-doc-line}
          ,input (buffer buf_c-cd-doc-line:handle)
          ) .
        delete buf_c-cd-doc-line .
      end.

      for each buf_cash-pay-attr exclusive-lock
        where buf_cash-pay-attr.obj-code = buf_shop.obj-code
          AND buf_cash-pay-attr.obj-type = {&shop}
      on error undo, return error
      :

        for each buf_c-cash-pay-attr exclusive-lock
          where buf_c-cash-pay-attr.cdpay-code = buf_cash-pay-attr.cdpay-code
            AND buf_c-cash-pay-attr.curr-code = buf_cash-pay-attr.curr-code
            AND buf_c-cash-pay-attr.host-code = buf_cash-pay-attr.host-code
            AND buf_c-cash-pay-attr.obj-type = buf_cash-pay-attr.obj-type
            AND buf_c-cash-pay-attr.obj-code = buf_shop.obj-code
        on error undo, return error
        :
          run delete-route in this-procedure
            ( input {&table_c-cash-pay-attr}
            ,input (buffer buf_c-cash-pay-attr:handle)
            ) .
          delete buf_c-cash-pay-attr .
        end.
        run delete-route in this-procedure
          ( input {&table_cash-pay-attr}
          ,input (buffer buf_cash-pay-attr:handle)
          ) .
        delete buf_cash-pay-attr .
      end.

      for each buf_dis-cp-rule exclusive-lock
        where buf_dis-cp-rule.obj-code = buf_shop.obj-code
          AND buf_dis-cp-rule.obj-type = {&shop}
      on error undo, return error
      :

        for each buf_c-dis-cp-rule exclusive-lock
          where buf_c-dis-cp-rule.cdpay-code = buf_dis-cp-rule.cdpay-code
            AND buf_c-dis-cp-rule.curr-code = buf_dis-cp-rule.curr-code
            AND buf_c-dis-cp-rule.obj-type = buf_dis-cp-rule.obj-type
            AND buf_c-dis-cp-rule.obj-code = buf_shop.obj-code
        on error undo, return error
        :
          run delete-route in this-procedure
            ( input {&table_c-dis-cp-rule}
            ,input (buffer buf_c-dis-cp-rule:handle)
            ) .
          delete buf_c-dis-cp-rule .
        end.
        run delete-route in this-procedure
          ( input {&table_dis-cp-rule}
          ,input (buffer buf_dis-cp-rule:handle)
          ) .
        delete buf_dis-cp-rule .
      end.

      delete buf_shop.
    end.

    for each buf_curr-shop exclusive-lock
      where buf_curr-shop.obj-type = p-obj-type
        and buf_curr-shop.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_curr-shop}
         ,input (buffer buf_curr-shop:handle)
        ) .
      delete buf_curr-shop .
    end.

    for each buf_clients-attr exclusive-lock
      where buf_clients-attr.obj-type = p-obj-type
        and buf_clients-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_clients-attr}
         ,input (buffer buf_clients-attr:handle)
        ) .
      delete buf_clients-attr .
    end.

    for each buf_c-clients-attr exclusive-lock
      where buf_c-clients-attr.obj-type = p-obj-type
        and buf_c-clients-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-clients-attr}
         ,input (buffer buf_c-clients-attr:handle)
        ) .
      delete buf_c-clients-attr .
    end.

    for each buf_thbj-attr exclusive-lock
      where buf_thbj-attr.obj-type = p-obj-type
        and buf_thbj-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_thbj-attr}
         ,input (buffer buf_thbj-attr:handle)
        ) .
      delete buf_thbj-attr .
    end.

    for each buf_c-thbj-attr exclusive-lock
      where buf_c-thbj-attr.obj-type = p-obj-type
        and buf_c-thbj-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-thbj-attr}
         ,input (buffer buf_c-thbj-attr:handle)
        ) .
      delete buf_c-thbj-attr .
    end.

    for each buf_dis-thbj-rule exclusive-lock
      where buf_dis-thbj-rule.obj-type = p-obj-type
        and buf_dis-thbj-rule.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_dis-thbj-rule}
         ,input (buffer buf_dis-thbj-rule:handle)
        ) .
      delete buf_dis-thbj-rule .
    end.

    for each buf_c-dis-thbj-rule exclusive-lock
      where buf_c-dis-thbj-rule.obj-type = p-obj-type
        and buf_c-dis-thbj-rule.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-dis-thbj-rule}
         ,input (buffer buf_c-dis-thbj-rule:handle)
        ) .
      delete buf_c-dis-thbj-rule .
    end.

    for each buf_c-clients exclusive-lock
      where buf_c-clients.obj-type = p-obj-type
        and buf_c-clients.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-clients}
         ,input (buffer buf_c-clients:handle)
        ) .
      delete buf_c-clients .
    end.

    for each buf_c-cli-hist exclusive-lock
      where buf_c-cli-hist.obj-type = p-obj-type
        and buf_c-cli-hist.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input {&table_c-cli-hist}
         ,input (buffer buf_c-cli-hist:handle)
        ) .
      delete buf_c-cli-hist .
    end.

    run delete-route in this-procedure
      ( input {&table_clients}
       ,input (buffer buf_clients:handle)
      ) .
    delete buf_clients .

  end.

end procedure. /* delete-clients */
procedure delete-arh-trn-doc-contract:
  define input parameter p-obj-type like ub.clients.obj-type no-undo.
  define input parameter p-obj-code like ub.clients.obj-code no-undo.
  define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
  on delete of ub.arh-trn-doc-contract override do:
  end.
  for each buf_arh-trn-doc-contract where buf_arh-trn-doc-contract.obj-type = p-obj-type and
                                          buf_arh-trn-doc-contract.obj-code = p-obj-code exclusive-lock on error undo, return error return-value :
    delete buf_arh-trn-doc-contract.
  end.
end.


procedure delete-place-io :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_place-io for ub.place-io .
  define buffer buf_c-place-io for ub.c-place-io .
  define buffer buf_point-place-rel for ub.point-place-rel .
  define buffer buf_c-point-place-rel for ub.c-point-place-rel .
  define buffer buf_point-point-rel for ub.point-point-rel .
  define buffer buf_c-point-point-rel for ub.c-point-point-rel .
  define buffer buf_point-io for ub.point-io .
  define buffer buf_c-point-io for ub.c-point-io .


  on delete of ub.place-io override do: end.
  on delete of ub.c-place-io override do: end.
  on delete of ub.point-place-rel override do: end.
  on delete of ub.c-point-place-rel override do: end.
  on delete of ub.point-point-rel override do: end.
  on delete of ub.c-point-point-rel override do: end.
  on delete of ub.point-io override do: end.
  on delete of ub.c-point-io override do: end.




  do on error undo, return error :
    for each buf_place-io exclusive-lock
      where buf_place-io.obj-type = p-obj-type
        and buf_place-io.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_place-io},input (buffer buf_place-io:handle) ) .
      delete buf_place-io .
    end.
  end.
  do on error undo, return error :
    for each buf_c-place-io exclusive-lock
      where buf_c-place-io.obj-type = p-obj-type
        and buf_c-place-io.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_c-place-io},input (buffer buf_c-place-io:handle) ) .
      delete buf_c-place-io .
    end.
  end.
  do on error undo, return error :
    for each buf_point-place-rel exclusive-lock
      where buf_point-place-rel.obj-type = p-obj-type
        and buf_point-place-rel.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_point-place-rel},input (buffer buf_point-place-rel:handle) ) .
      delete buf_point-place-rel .
    end.
  end.
  do on error undo, return error :
    for each buf_c-point-place-rel exclusive-lock
      where buf_c-point-place-rel.obj-type = p-obj-type
        and buf_c-point-place-rel.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_c-point-place-rel},input (buffer buf_c-point-place-rel:handle) ) .
      delete buf_c-point-place-rel .
    end.
  end.
  do on error undo, return error :
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_point-point-rel exclusive-lock
      where buf_point-point-rel.from-db-num = buf_point-io.db-num
        and buf_point-point-rel.from-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_point-point-rel},input (buffer buf_point-point-rel:handle) ) .
      delete buf_point-point-rel .
    end.
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_point-point-rel exclusive-lock
      where buf_point-point-rel.to-db-num = buf_point-io.db-num
        and buf_point-point-rel.to-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_point-point-rel},input (buffer buf_point-point-rel:handle) ) .
      delete buf_point-point-rel .
    end.
  end.
  do on error undo, return error :
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_c-point-point-rel exclusive-lock
      where buf_c-point-point-rel.from-db-num = buf_point-io.db-num
        and buf_c-point-point-rel.from-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_c-point-point-rel},input (buffer buf_c-point-point-rel:handle) ) .
      delete buf_c-point-point-rel .
    end.
  end.
  do on error undo, return error :
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_c-point-point-rel exclusive-lock
      where buf_c-point-point-rel.to-db-num = buf_point-io.db-num
        and buf_c-point-point-rel.to-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_c-point-point-rel},input (buffer buf_c-point-point-rel:handle) ) .
      delete buf_c-point-point-rel .
    end.
  end.
  do on error undo, return error :
    for each buf_point-io exclusive-lock
      where buf_point-io.cli-type = p-obj-type
        and buf_point-io.cli-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_point-io},input (buffer buf_point-io:handle) ) .
      delete buf_point-io .
    end.
  end.
  do on error undo, return error :
    for each buf_c-point-io exclusive-lock
      where buf_c-point-io.cli-type = p-obj-type
        and buf_c-point-io.cli-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input {&table_c-point-io},input (buffer buf_c-point-io:handle) ) .
      delete buf_c-point-io .
    end.
  end.

end procedure. /* delete-place-io */



procedure delete-batchprocess :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    define buffer calc-arh-lock_batchprocess for ub.batchprocess .

    run gbl/lock-prc.p
      (input {&lock-prc-calc-arh}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по товарам"
      ,input true
      ,buffer calc-arh-lock_batchprocess
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно удалить объект" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input {&lock-prc-calc-supp-arh}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
      ,input true
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по поставщикам" skip
        "Невозможно удалить объект" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    define buffer calc-aht-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input {&lock-prc-calc-aht}
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
      ,input true
      ,buffer calc-aht-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по типам приобретения" skip
        "Невозможно удалить объект" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    run doclslib-clear-doc-list in this-procedure .

    run doclslib-init-trn-doc in this-procedure
      (input p-obj-type  /* p-obj-type */
      ,input p-obj-code  /* p-obj-code */
      ,input ?           /* p-cut-date */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    run doclslib-init-price-doc in this-procedure
      (input p-obj-type /* p-obj-type */
      ,input p-obj-code /* p-obj-code */
      ,input ?          /* p-cut-date */
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры doclslib-init-price-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    run doclslib-clear-batch-process in this-procedure
      (input {&btpr-type-arh}
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clear-batch-process" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    run doclslib-clear-batch-process in this-procedure
      (input {&btpr-type-ahsp}
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clear-batch-process" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.
  end.

end procedure. /* delete-batchprocess */


procedure delete-nws-doc-hist :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_nws-doc-hist for ub.nws-doc-hist .

  do
  on error undo, return error return-value
  :
    for each buf_nws-doc-hist exclusive-lock
      where buf_nws-doc-hist.obj-type = p-obj-type
        and buf_nws-doc-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_nws-doc-hist .
    end.
  end.

end procedure. /* delete-nws-doc-hist */

procedure delete-stop-list :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define variable v-host-code as integer no-undo .
  define buffer buf_stop-list for ub.stop-list .
  define buffer buf_stop-list-line for ub.stop-list-line .
  define buffer buf_c-stop-list for ub.c-stop-list .
  define buffer buf_c-stop-list-line for ub.c-stop-list-line .

  define buffer buf_sysconf for ub.sysconf.

  on delete of ub.stop-list override do: end.
  on delete of ub.c-stop-list override do: end.
  on delete of ub.stop-list-line override do: end.
  on delete of ub.c-stop-list-line override do: end.


  do
  on error undo, return error return-value
  :

    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = v-host-code.
    for each buf_stop-list exclusive-lock
      where buf_stop-list.obj-type = p-obj-type
        and buf_stop-list.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_stop-list-line exclusive-lock
        where buf_stop-list-line.classif-type = buf_stop-list.classif-type
        and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_stop-list-line .
      end.

      for each buf_c-stop-list exclusive-lock
        where buf_c-stop-list.classif-type = buf_stop-list.classif-type
        and buf_c-stop-list.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_c-stop-list .
      end.

      for each buf_c-stop-list-line exclusive-lock
        where buf_c-stop-list-line.classif-type = buf_stop-list.classif-type
        and buf_c-stop-list-line.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_c-stop-list-line .
      end.

      run delete-route in this-procedure
        ( input {&table_stop-list}
         ,input (buffer buf_stop-list:handle)
        ) .
      delete buf_stop-list .
    end.
    for each buf_c-stop-list exclusive-lock
      where buf_c-stop-list.obj-type = p-obj-type
        and buf_c-stop-list.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-stop-list-line exclusive-lock
        where buf_c-stop-list-line.classif-type = buf_stop-list.classif-type
        and buf_c-stop-list-line.stop-list-code = buf_c-stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_c-stop-list-line .
      end.

      run delete-route in this-procedure
        ( input {&table_c-stop-list}
         ,input (buffer buf_c-stop-list:handle)
        ) .
      delete buf_c-stop-list .
    end.
  end.

end procedure. /* delete-stop-list */


procedure convert-payment :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

define variable v-host-code as integer no-undo .
define variable v-obj-type-code as character no-undo .
define buffer buf_payment for ub.payment.
define buffer buf_sysconf for ub.sysconf.
on write of ub.payment override do: end.
  do
  on error undo, return error
  :


    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    v-obj-type-code = substitute('&1&2-', p-obj-type, p-obj-code).
    find first buf_sysconf no-lock where
            buf_sysconf.host-code = v-host-code.
    for each buf_payment where
            buf_payment.host-code = v-host-code
        and buf_payment.source-type = {&pmnt-cash-desk}
        and buf_payment.source-ref begins v-obj-type-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = '':U
        buf_payment.pay-code = buf_sysconf.cash-pay
        buf_payment.PS = substitute("!смена типа/кода платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
    end.
    for each buf_payment where
            buf_payment.host-code = v-host-code
        and buf_payment.source-type = {&pmnt-trn-doc}
        and buf_payment.source-ref begins v-obj-type-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = '':U
        buf_payment.PS = substitute("!смена типа платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
    end.
  end.

end procedure. /* convert-payment */


procedure delete-ext-classif :

  define input  parameter p-uniq-key-rec as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_ext-classif      for ub.ext-classif .
  define buffer buf_c-ext-classif      for ub.c-ext-classif .
  define buffer buf_clients for ub.clients.

  on delete of ub.ext-classif override do: end.
  on delete of ub.c-ext-classif override do: end.
  define variable v-uniq-key-rec as character no-undo .
  define variable v-names as character no-undo .
  define variable v-ii as integer no-undo .

  do
  on error undo, return error return-value
  :
    v-names = {&extclass_clients_esys} .
    do v-ii = 1 to num-entries(v-names):
      for each buf_Ext-classif where
              buf_ext-classif.classif-name = entry(v-ii, v-names)
          and buf_Ext-classif.uniq-key-rec = p-uniq-key-rec
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_ext-classif}
          ,input (buffer buf_ext-classif:handle)
          ) .
        delete buf_ext-classif .
      end.
      for each buf_c-Ext-classif where
              buf_c-ext-classif.classif-name = entry(v-ii, v-names)
          and buf_c-Ext-classif.uniq-key-rec = p-uniq-key-rec
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input {&table_c-ext-classif}
          ,input (buffer buf_c-ext-classif:handle)
          ) .
        delete buf_c-ext-classif .
      end.
    end.
  end.

end procedure. /* delete-ext-classif */


procedure delete-egais :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_egais-clients for ub.egais-clients.

  do
  on error undo, return error return-value
  :
    for each buf_egais-clients exclusive-lock
      where buf_egais-clients.obj-type = p-obj-type
        and buf_egais-clients.obj-code = p-obj-code
    :
      assign
        buf_egais-clients.obj-type = ''
        buf_egais-clients.obj-code = 0
      .
    end.
  end.

end procedure. /* delete-egais */


procedure check-can-delete :

  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_db for ub.db .
    define buffer buf_clients for ub.clients .
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer supp_clients for ub.clients .

    define variable v-return-error as logical   no-undo .

    for each buf_trn-doc no-lock
      where buf_trn-doc.hold-obj-type = p-obj-type
        and buf_trn-doc.hold-obj-code = p-obj-code
        and buf_trn-doc.status_ <> {&fact} 
    on error undo, return error return-value
    :
        assign
          v-return-error = true
        .
        run log-error in this-procedure
          (input substitute("Объект &1 &2, Документ МФ &3"
                  ,buf_trn-doc.obj-type
                  ,buf_trn-doc.obj-code
                  ,buf_trn-doc.doc-code
                  )
          ) .

    end.

    for each buf_db no-lock
    on error undo, return error return-value
    :
      for each buf_clients no-lock
        where buf_clients.db-num = buf_db.db-num
      on error undo, return error return-value
      :
        for each buf_trn-doc no-lock
          where buf_trn-doc.obj-type = buf_clients.obj-type
            and buf_trn-doc.obj-code = buf_clients.obj-code
            and buf_trn-doc.status_ <> {&fact}
        on error undo, return error return-value
        :
          find first supp_clients no-lock
            where supp_clients.obj-type = buf_trn-doc.obj-type
              and supp_clients.obj-code = buf_trn-doc.obj-code
            no-error .
          if not available supp_clients then do:
            assign
              v-return-error = true
            .
            run log-error in this-procedure
              (input substitute("Объект &1 &2. Документ &3. Неизвестный контрагент"
                     ,buf_clients.obj-type
                     ,buf_clients.obj-code
                     ,buf_trn-doc.doc-code
                     )
              ) .
            next .
          end.
          if supp_clients.db-num <> ?
          and supp_clients.obj-type = p-obj-type
          and supp_clients.obj-code = p-obj-code
          then do:
            assign
              v-return-error = true
            .
            run log-error in this-procedure
              (input substitute("Объект &1 &2, Документ &3"
                     ,buf_clients.obj-type
                     ,buf_clients.obj-code
                     ,buf_trn-doc.doc-code
                     )
              ) .
          end.
        end.
      end.
    end.

    if v-return-error = true then do:
      return error .
    end.
  end.

end procedure. /* check-can-delete */


procedure log-error :

  define input  parameter p-message as character no-undo .

  do
  on error undo, return error return-value
  :
    output stream slog to value('del-obj.err') append .
    export stream slog v-obj-type v-obj-code cur-time-string() p-message .
    output stream slog close .
  end.

end procedure. /* log-error */


procedure generate-check-string :

  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define output parameter p-check-string as character no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .

    find first buf_sys-ctrl no-lock .
    find first buf_db no-lock
      where buf_db.db-num = buf_sys-ctrl.db-num .

    assign
      p-check-string =
        substitute('del-obj,&1,&2,&3,&4,&5':u
          ,p-obj-type
          ,p-obj-code
          ,p-check-rest
          ,cur-time-date()
          ,buf_sys-ctrl.db-num
        )
    .
  end.

end procedure. /* generate-check-string */