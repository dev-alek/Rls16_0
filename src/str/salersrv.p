block-level on error undo, throw.
/*

$Revision: 220955104cd9, 2417, rls $
$Author: SSlivenko $
$Date: Ср июн 10 21:13:46 2020 +0300 $
$Workfile: salersrv.p $
$Archive: str/salersrv.p $

Резервирование продажи - вызывается через diallog.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/05
Author: Bakhtadze Natalya
Creation date: 03/21/05

*/

define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.

/*p-parameter включает в себ
define input parameter v-curr-r-b     as character no-undo .
define input parameter p-inkas-code   like ub.inkas.inkas-code no-undo .
define input parameter p-auto         as integer no-undo . /*этот параметр указывает на закрытие пачками - например из расписания*/
/* = 0 из интерфейса =1 из salelist.w  =2 из расписания */
define input parameter auto-fbr       as logical no-undo . /*растройка производстов при продаже*/
define input parameter p-is-catering  as logical no-undo . /*это ресторан*/
define input parameter p-is-tpsi-obj  as logical no-undo . /*это tpsi-obj*/
define input parameter rest-dish      as logical no-undo .
define input parameter rest-ingr      as logical no-undo .
define input parameter rest-tpsi      as logical no-undo .
define input parameter neg-tpsi-weight as logical no-undo .
define input parameter neg-tpsi-qnty   as decimal no-undo .
define input parameter neg-tpsi-oper   as logical no-undo .
*/

define variable v-curr-r-b     as character no-undo .
define variable p-inkas-code   like ub.inkas.inkas-code no-undo .
define variable p-auto         as integer no-undo . /*этот параметр указывает на закрытие пачками - например из расписания*/
/* = 0 из интерфейса =1 из salelist.w  =2 из расписания */
define variable auto-fbr       as logical no-undo . /*растройка производстов при продаже*/
define variable p-is-catering  as logical no-undo . /*это ресторан*/
define variable p-is-tpsi-obj  as logical no-undo . /*это tpsi-obj*/
define variable rest-dish      as logical no-undo .
define variable rest-ingr      as logical no-undo .
define variable rest-tpsi      as logical no-undo .
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-qnty   as decimal no-undo .
define variable neg-tpsi-oper   as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision: 220955104cd9, 2417, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salersrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salersrv.p $":U .
define variable vss-description as character no-undo init "Резервирование продажи".
{ gbl/objsrv.i }
{ cmp/vssrevis.i "substitute('&1':u,p-inkas-code)" }
{ cmp/trg-def.i }

define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable log-file-name as character no-undo .

{ cmp/library.i  }
{ str/salttemp.i }
{ ref/gds-attr.i }
{ str/salersrv.i def }
{ str/libbcrcn.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ str/fbrhist.i main }
{ str/libtfarh.i }
{ str/fbrcode.i }
{ str/trdcalib.i }
{ str/lib-def.i }
{ gbl/clntattr.i }
{ str/tpsidoc.i SHARED proc }
{ ref/gdsoattr.i }
{ gbl/tpsi-gds.i }
{ str/dtlrestm.i shared }
{ str/dtl-rest.i new }
{ str/lib-farh.i }
{ str/lib-trn.i }

define variable v-obj-type like ub.inkas.obj-type no-undo .
define variable v-obj-code like ub.inkas.obj-code no-undo .
define variable cre-pay   like ub.cash-pay.cdpay-code no-undo.
define variable v-doc-date as date no-undo .
define variable v-db-num  like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable l-shift-on as logical no-undo .
DEFINE VARIABLE sys-today as date no-undo .
define variable v-back-date as logical no-undo .
define variable force-auto-fbr as logical no-undo .
define variable force-tpsi-obj as logical no-undo .
define variable ii as integer no-undo .
define variable v-notes as character no-undo .
define variable case-num as integer no-undo .
define variable v-fbr-income-doc-code like ub.trn-doc.doc-code no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable glog     as logical no-undo .
define variable b-close-enabled as logical no-undo initial no.
define variable BadTrans as logical no-undo .
/*recid записи с которой надо снять - поставить резервы */
define variable rdoc-line as recid.
/*какую единичную запись резервируем расход или возврат или списание или техпролив*/
define variable r-or-v as character no-undo.
/*тип товара для резервирования*/
define variable r-office as character no-undo .
/*рзервирование началось с выбора пункта поп-ап меню*/
define variable from-menu as logical initial no.
/*количество резервируемых позиций*/
define variable num_resv as integer no-undo.
/*количество зарезервированных позиций*/
define variable num_resv_res as integer no-undo.
define variable v-log-handle as handle no-undo.

/*
/*есть неучтенные чеки с товарами*/
define variable not-all-saled-chk-gds as logical initial no.
/*есть неучтенные чеки с услугами*/
define variable not-all-saled-chk-usl as logical initial no.
/*есть неуправильные чеки */
define variable not-all-normal-chk as logical initial no.
/*есть незакрытые продажи с товаром*/
define variable not-all-inkas-closed-gds as logical no-undo initial no.
/*есть незакрытые продажи с товаром*/
define variable not-all-inkas-closed-usl as logical no-undo initial no.
define variable note-compense as character no-undo.
define variable compensed     as logical no-undo . /*компенсация была проведена*/
*/
define variable auto-close    as logical no-undo init no.


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_inkas for ub.inkas.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer locked_inkas for ub.inkas.
define buffer locked_trn-doc for ub.trn-doc.
define buffer buf_prt-obj for ub.prt-obj.
define buffer tepsi_sale-doc for ub.sale-doc.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-message-laud  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

&glob view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!В процессе резервирования продажи произошли ошибки!!!')"  ~
                    "'salersrv.log'" ~}   ~
                    return "error":U. ~
                 end


if num-entries(p-parameter, {&delim-par}) <> 12
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 12"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  assign
  v-curr-r-b          = entry(1, p-parameter, {&delim-par})
  p-inkas-code        = entry(2, p-parameter, {&delim-par})
  p-auto              = integer(entry(3, p-parameter, {&delim-par}))
  auto-fbr            = logical(entry(4, p-parameter, {&delim-par}))
  p-is-catering       = logical(entry(5, p-parameter, {&delim-par}))
  p-is-tpsi-obj       = logical(entry(6, p-parameter, {&delim-par}))
  rest-dish           = logical(entry(7, p-parameter, {&delim-par}))
  rest-ingr           = logical(entry(8, p-parameter, {&delim-par}))
  rest-tpsi           = logical(entry(9, p-parameter, {&delim-par}))
  neg-tpsi-weight     = logical(entry(10, p-parameter, {&delim-par}))
  neg-tpsi-qnty       = decimal(entry(11, p-parameter, {&delim-par}))
  neg-tpsi-oper       = logical(entry(12, p-parameter, {&delim-par}))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.

if p-auto = 0 then do:
  log-file-name = 'salersrv.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.

{ str/sale-oth.i }
{ str/salersrv.i sale auto }
/*определение процедуры UNRESERV*/
{ str/unressal.i sale }

if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.


run proc-main in this-procedure no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при резервировании продажи &1 &2&3:&4&5 &6"
                         , p-inkas-code
                         , (if v-obj-type <> "":U then v-obj-type else "":U)
                         , (if v-obj-code <> 0 then string(v-obj-code) else "":U)
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  for each dtl-rests:
    delete dtl-rests.
  end.
  {&view-log}.
end.

procedure proc-main :
define variable v-close-enabled as logical no-undo .
define buffer tpsi_sale-doc for ub.sale-doc.

do
on error undo, return error return-value
:

  find first buf_inkas exclusive-lock where
              buf_inkas.inkas-code = p-inkas-code no-error no-wait.
  if NOT available buf_inkas
  and not locked buf_inkas
  then do:
    return error substitute("Не найден отчет о продаже №&1", p-inkas-code).
  end.
  if locked buf_inkas then do:
    if p-auto < 2 then
    return error substitute("Отчет о продаже №&1 занят", p-inkas-code).
    else do:
      return "":U.
    end.
  end.
  assign
  v-obj-type = buf_inkas.obj-type
  v-obj-code = buf_inkas.obj-code
  .
  FIND FIRST buf_trn-doc WHERE
            buf_trn-doc.doc-code = buf_inkas.inkas-code NO-LOCK.

  if (p-auto < 2
  and not (buf_inkas.status_ = {&g___new}
           or
           buf_inkas.status_ = {&doc-froze} ))
  then do:
    return error substitute("Отчет о продаже №&1 имеет статус &2", buf_inkas.inkas-code, buf_inkas.status_).
  end.
  if buf_trn-doc.status_ = {&inquiry} then do:
    return error substitute("Документы по продаже №&1 имеют статус", buf_trn-doc.status_).
  end.

  if p-auto >= 2
  and buf_inkas.status_ <> {&g___new}
  /*and buf_trn-doc.flag_ <> yes*/ /*закоментарено по требю филипповойр*/
  then do:
    return "":U.
  end.
  { gbl/objdbnum.i {&shop}  buf_inkas.obj-code v-db-num }
  if v-db-num <> g#db-num then do:
    return error substitute("Отчет о продаже №&1 относится к магазину БД &2, текущая БД &3"
                            , buf_inkas.inkas-code
                            , v-db-num
                            , g#db-num
                            ).
  end.

  FIND FIRST buf_ret-doc WHERE
            buf_ret-doc.doc-code = buf_trn-doc.out-code NO-LOCK no-error.

  /*найдем код оплаты в кредит*/
  find first buf_sysconf where
           buf_sysconf.host-code = buf_inkas.host-code no-lock.
  if not available buf_sysconf then do:
    return error substitute("Не найдена запись о фирме &1", buf_inkas.host-code).
  end.
  assign
  v-host-code = buf_inkas.host-code.
  /*если p-auto = 0 то у нас все заполнено*/
  if p-auto <> 0 then do:
    if can-find(first tpsi_sale-doc where
                   tpsi_sale-doc.inkas-code = buf_inkas.inkas-code
               and tpsi_sale-doc.tpsidoc = yes)
    then p-is-tpsi-obj = yes.
    if p-is-tpsi-obj then do:
      run tpsi-gds-fill-tpsi-obj-table in this-procedure (input v-db-num) no-error .
      if error-status:error then do:
      undo, return error
        substitute("Ошибки при заполнении врем. таблицы объектов-членов ТПСИ на БД &1:&2&3 &4"
                  , v-db-num
                  , {&new-line}
                  , error-status:get-message(1)
                  , return-value ).
      end.
    end.
    if (p-is-tpsi-obj)
    then do:
&scop my-message "Ждите.. получение информации по резервированию ЧУЖИХ товаров"
{&display-message}.
      run fill-tt-tpsi-table  in this-procedure (
                                                    buf_inkas.inkas-code
                                                  , buf_Inkas.host-code
                                                  , buf_inkas.obj-type
                                                  , buf_Inkas.obj-code).
      run waitfram-hide in this-procedure .
    end.
  end.
  assign
  rdoc-line = ?
  rgds-dtl = ?
  r-or-v = ?
  r-office = ?
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  from-menu = yes
  .
  run b-res-proc in this-procedure (
                                      buffer buf_Inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input no
                                    , input no /*auto-close*/
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input p-is-tpsi-obj
                                    , input rest-tpsi) no-error .
  if error-status:error  or return-value = "error" then do:
    undo, return error  substitute("Ошибка при резервировании товаров продажи:&1&2 &3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value
                                   ).
  end.
  /*если по расписанию и надо перейти к следующей стадии то установим флаг на накладной равен yes*/
  if p-auto = 3 then do:
    RUN button-close in this-procedure (
                                             buffer buf_trn-doc
                                            ,buffer buf_ret-doc
                                            ,input p-is-tpsi-obj
                                            ,input auto-fbr
                                            ,input neg-tpsi-weight
                                            ,input neg-tpsi-qnty
                                            ,input neg-tpsi-oper
                                            ,Output b-close-enabled).
    IF b-close-enabled then do:
      run str/salestat.p (
                        input parparentproc
                        ,input p-inkas-code
                        ,input {&close-doc}
                        ,input {&doc-froze}
                        ,input no
                        ,input yes ) no-error .
      if not error-status:error then do:
        &scop my-message substitute("Продажа &1 помечена как готовая к закрытию", p-inkas-code)
        {&display-message}.
      end.
      else do:
    &scop my-message substitute("!!!Ошибка при переводе статуса продажи:&1&2 &3"  ~
                    , ~{&new-line~}                                               ~
                    , error-status:get-message(1)                                 ~
                    , return-value )
        {&display-message}.
      end.
    end.
  end.
end. /*doe*/

end procedure. /* proc-main */