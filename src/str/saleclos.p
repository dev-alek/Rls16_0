block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закрытие продажи - вызывается через diallog.w

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/10/05
Author: Bakhtadze Natalya
Creation date: 03/10/05

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
define input parameter auto-close     as logical no-undo . /*авто закрытие после резервирования*/
define input parameter b-mail-pressed as logical no-undo . /*нажималась ли кнопка ПРИЕМ ЧЕКОВ*/
define input parameter auto-comp      as logical no-undo . /*компенсация расход возврат*/
define input parameter auto-fbr       as logical no-undo . /*растройка производстов при продаже*/
define input parameter one-curs       as logical no-undo . /*чеки по одному курсу*/
define input parameter p-is-catering  as logical no-undo . /*это ресторан*/
define input parameter p-is-tpsi-obj  as logical no-undo . /*это tpsi-obj*/
define input parameter rest-dish      as logical no-undo .
define input parameter rest-ingr      as logical no-undo .
define input parameter rest-tpsi      as logical no-undo .
define input parameter neg-tpsi-weight as logical no-undo .
define input parameter neg-tpsi-qnty   as decimal no-undo .
define input parameter neg-tpsi-oper   as logical no-undo .
define input parameter close-in-rfsl   as integer no-undo .
define input parameter pay-gds-algo    as character no-undo .

*/

define variable v-curr-r-b     as character no-undo .
define variable p-inkas-code   like ub.inkas.inkas-code no-undo .
define variable p-auto         as integer no-undo . /*этот параметр указывает на закрытие пачками - например из расписания*/
/* = 0 из интерфейса =1 из salelist.w  =2 из расписания */
define variable auto-close     as logical no-undo . /*авто закрытие после резервирования*/
define variable b-mail-pressed as logical no-undo . /*нажималась ли кнопка ПРИЕМ ЧЕКОВ*/
define variable auto-comp      as logical no-undo . /*компенсация расход возврат*/
define variable auto-fbr       as logical no-undo . /*растройка производстов при продаже*/
define variable one-curs       as logical no-undo . /*чеки по одному курсу*/
define variable p-is-catering  as logical no-undo . /*это ресторан*/
define variable p-is-tpsi-obj  as logical no-undo . /*это tpsi-obj*/
define variable rest-dish      as logical no-undo .
define variable rest-ingr      as logical no-undo .
define variable rest-tpsi      as logical no-undo .
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-qnty   as decimal no-undo .
define variable neg-tpsi-oper   as logical no-undo .
define variable close-in-rfsl as integer no-undo .
define variable pay-gds-algo    as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Закрытие продажи".
{ gbl/objsrv.i }
{ cmp/vssrevis.i "substitute('&1':u,p-inkas-code)" }
{ cmp/trg-def.i }

define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .

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
{ str/inkas-ps.i }
{ str/tpsidoc.i "SHARED" proc }
{ str/saledoc.i }
{ ref/gdsoattr.i }
{ gbl/tpsi-gds.i }
{ str/dtlrestm.i shared }
{ str/dtl-rest.i new }
{ str/lib-farh.i }
{ str/lib-trn.i }
{ str/chksplin.i }
{ gbl/thbjattr.i }
{ utl/gtin.i }

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
define variable ii as integer no-undo . /* пожалуйста, не трогайте ее */
define variable jj as integer no-undo.
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
/*какую единичную запись резервируем расход или возврат или списание или техпролив */
define variable r-or-v as character no-undo.
/*тип товара для резервирования*/
define variable r-office as character no-undo .
/*рзервирование началось с выбора пункта поп-ап меню*/
define variable from-menu as logical initial no.
/*количество резервируемых позиций*/
define variable num_resv as integer no-undo.
/*количество зарезервированных позиций*/
define variable num_resv_res as integer no-undo.


/*есть неучтенные чеки */
define variable not-all-saled-chk as logical initial no .
/*есть неуправильные чеки */
define variable not-all-normal-chk as logical initial no .
/*есть незакрытые продажи */
define variable not-all-inkas-closed as logical no-undo initial no .
define variable note-compense as character no-undo.
define variable compensed     as logical no-undo . /*компенсация была проведена*/
define variable v-is-ptrl as logical no-undo .
define variable log-file-name as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-close-day-period AS LOGICAL no-undo .
define variable v-log-handle as handle no-undo .
define variable v-vid-action      as integer   no-undo .
define variable v-vid-param       as longchar  no-undo .
define variable varoldstatus      like ub.trn-doc.status_ no-undo .
define variable varoldflag        like ub.trn-doc.flag_ no-undo .
define variable varobj-shift-date as date      no-undo .
define variable varobj-shift-num  as integer   no-undo .
define variable varobj-shift-name as character no-undo .
define variable v-mess            as character no-undo .
define variable v-gas-income-created as character no-undo .
define variable v-gas-compensed as logical no-undo .
define variable v-gas-cli-type as character no-undo .
define variable v-gas-cli-code as integer no-undo .
define variable v-new_doc-code as character no-undo .
define variable v-root-node as integer no-undo .
{ str/initiator.i }


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_inkas for ub.inkas.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_spis-doc for ub.trn-doc.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer locked_inkas for ub.inkas.
define buffer locked_trn-doc for ub.trn-doc.
define buffer buf_prt-obj for ub.prt-obj.
define buffer bf_clients for ub.clients.
define buffer buf-new_trn-doc for ub.trn-doc.

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
                    "substitute('!!!В процессе закрытия продажи произошли ошибки!!!')"  ~
                    "'saleclos.log'" ~}   ~
                    return "error":U. ~
                 end


if num-entries(p-parameter, {&delim-par}) <> 18
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 18"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  assign
  v-curr-r-b          = entry(1, p-parameter, {&delim-par})
  p-inkas-code        = entry(2, p-parameter, {&delim-par})
  p-auto              = integer(entry(3, p-parameter, {&delim-par}))
  auto-close          = logical(entry(4, p-parameter, {&delim-par}))
  b-mail-pressed      = logical(entry(5, p-parameter, {&delim-par}))
  auto-comp           = logical(entry(6, p-parameter, {&delim-par}))
  auto-fbr            = logical(entry(7, p-parameter, {&delim-par}))
  one-curs            = logical(entry(8, p-parameter, {&delim-par}))
  p-is-catering       = logical(entry(9, p-parameter, {&delim-par}))
  p-is-tpsi-obj       = logical(entry(10, p-parameter, {&delim-par}))
  rest-dish           = logical(entry(11, p-parameter, {&delim-par}))
  rest-ingr           = logical(entry(12, p-parameter, {&delim-par}))
  rest-tpsi           = logical(entry(13, p-parameter, {&delim-par}))
  neg-tpsi-weight     = logical(entry(14, p-parameter, {&delim-par}))
  neg-tpsi-qnty       = decimal(entry(15, p-parameter, {&delim-par}))
  neg-tpsi-oper       = logical(entry(16, p-parameter, {&delim-par}))
  close-in-rfsl       = integer(entry(17, p-parameter, {&delim-par}))
  pay-gds-algo        = entry(18, p-parameter, {&delim-par})
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.

if p-auto = 0 then do:
  log-file-name = 'saleclos.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.

for each chk-doc no-lock where chk-doc.out-code = p-inkas-code :
  if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next .
  find first chk-gds no-lock where chk-gds.doc-code = chk-doc.doc-code no-error.
  if not available chk-gds
  then do :
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("В чеке &1 нет строк!&2&3&4"
                           , chk-doc.doc-code
                           , {&new-line}
                           , v-esm
                           , return-value
                           )).
    assign
    v-view-log = yes.
    {&view-log}.
  end.
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
  v-mess = substitute("Ошибка при закрытии продажи &1 &2&3:&4&5 &6"
                         , p-inkas-code
                         , (if v-obj-type <> "":U then v-obj-type else "":U)
                         , (if v-obj-code <> 0 then string(v-obj-code) else "":U)
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         ).
  
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input v-mess).
  assign
  v-view-log = yes.
  {&view-log}.
  for each dtl-rests:
    delete dtl-rests.
  end.
  run fbrhist-table-to-base in this-procedure no-error.
  if error-status:error
  then do:
    v-mess = substitute("Ошибка при закрытии продажи &1:&2Ошибка записи истории производства в базу данных.&2&3 &4"
                          , p-inkas-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          ).
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input v-mess).
    assign
    v-view-log = yes.
    {&view-log}.
  end.
  if v-view-log
  and p-auto = 0
  then do:
    message
    "!!!При закрытии продажи произошли ошибки!!!" skip
    "!!!Внимательно прочитайте Log-file!!"
    view-as alert-box error .
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    run gbl/prnfilen.w
      (input  "Ошибки, возникшие при закрытии продажи"
      ,input  0
      ,input  "./saleclos.log":U
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
  
  end.
  
  find first buf_inkas no-lock where
                buf_inkas.inkas-code = p-inkas-code no-error.
  find first buf_trn-doc no-lock where
    buf_trn-doc.doc-code = p-inkas-code no-error.
  find last ub.c-inkas no-lock where ub.c-inkas.inkas-code = buf_inkas.inkas-code and ub.c-inkas.corr-user-db-num = v-db-num no-error.
  
  if available (buf_inkas) and available (ub.c-inkas )
  then do:
    
    find first bf_clients no-lock where bf_clients.obj-type = {&prs} and  bf_clients.obj-code = buf_trn-doc.boss no-error.
    { gbl/curshift.i
    buf_inkas.obj-type
    buf_inkas.obj-code
    varobj-shift-date
    varobj-shift-num
    varobj-shift-name
    no-error
    }
  
    v-vid-action = 57 .
    v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                  "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + {&delim-par} +
                  "SHOP_NUM=" + string(buf_inkas.obj-code) + {&delim-par} +
                  "Contractor=" + buf_trn-doc.cli-name + {&delim-par} +
                  "DocNum=" + string(buf_inkas.inkas-code) + {&delim-par} +
                  "FactDate=" + (if string(buf_inkas.fact-date) = ? then '' else string(buf_inkas.fact-date)) + {&delim-par} +
                  "DocType=" + "Продажа" + {&delim-par} +
                  "SHIFT_NUM_DOC=" + (if string(buf_inkas.shift-num) = ? then '' else string(buf_inkas.shift-num)) + (if string(buf_inkas.shift-date) = ? then '' else string(buf_inkas.shift-date, "99999999")) + {&delim-par} +
                  "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + {&delim-par} +
                  "Status=" + string(buf_inkas.status_) + {&delim-par} +
                  "RESULT=1" + {&delim-par} + 
                  "Description=" + v-mess no-error.
    
    run trg/userlog.p (
          input {&nwsdochs_action_update}
        , input {&table_c-inkas}
        , input ( buffer ub.c-inkas:handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
  
  end.

end.

else do:
  find first buf_inkas no-lock where
                buf_inkas.inkas-code = p-inkas-code no-error.
  find first buf_trn-doc no-lock where
    buf_trn-doc.doc-code = p-inkas-code no-error.
  find last ub.c-inkas no-lock where ub.c-inkas.inkas-code = buf_inkas.inkas-code and ub.c-inkas.corr-user-db-num = v-db-num no-error.
  if available (buf_inkas) and available (ub.c-inkas )
  then do:
    
    find first bf_clients no-lock where bf_clients.obj-type = {&prs} and  bf_clients.obj-code = buf_trn-doc.boss no-error.
    { gbl/curshift.i
    buf_inkas.obj-type
    buf_inkas.obj-code
    varobj-shift-date
    varobj-shift-num
    varobj-shift-name
    no-error
    }
  
    v-vid-action = 57 .
    v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                  "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + {&delim-par} +
                  "SHOP_NUM=" + string(buf_inkas.obj-code) + {&delim-par} +
                  "Contractor=" + buf_trn-doc.cli-name + {&delim-par} +
                  "DocNum=" + string(buf_inkas.inkas-code) + {&delim-par} +
                  "FactDate=" + (if string(buf_inkas.fact-date) = ? then '' else string(buf_inkas.fact-date)) + {&delim-par} +
                  "DocType=" + "Продажа" + {&delim-par} +
                  "SHIFT_NUM_DOC=" + (if string(buf_inkas.shift-num) = ? then '' else string(buf_inkas.shift-num)) + (if string(buf_inkas.shift-date) = ? then '' else string(buf_inkas.shift-date, "99999999")) + {&delim-par} +
                  "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + {&delim-par} +
                  "StatusOld=" + varoldstatus + (if varoldflag then "+" else "-" ) + {&delim-par} +
                  "StatusNew=" + string(buf_inkas.status_) + {&delim-par} +
                  "RESULT=0" + {&delim-par} + 
                  "Description=" no-error.
    
    run trg/userlog.p (
          input {&nwsdochs_action_update}
        , input {&table_c-inkas}
        , input ( buffer ub.c-inkas:handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
  
  end.
end.


procedure proc-main :
define variable v-prichina as character no-undo .
define variable my-mes     as character no-undo .
define variable v-is-neg-rests as logical no-undo .
define variable v-is-inquiry as logical no-undo .
define variable v-shift-date as date no-undo .
define variable v-shift-num as integer no-undo .
define variable v-shift-name as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-found as decimal no-undo.
define variable v-tth as handle no-undo .
define variable v-entry as character no-undo.
define variable v-run-tpsi-line as logical no-undo.

/* для выгрузке смены с изменёнными продажами в 1с */
define variable v-old-shift-obj as handle no-undo  .
define variable v-new-shift-obj as handle no-undo  .

define buffer buf_shift-obj for ub.shift-obj.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer spis_doc-line for ub.doc-line.
define buffer buf_sale-doc for ub.sale-doc.
define buffer spis_sale-doc for ub.sale-doc.
define buffer bf_doc-fbr-gds for ub.doc-fbr-gds .
define buffer out-dtl   for ub.gds-dtl. /* расходный документ */
define buffer ret-dtl   for ub.gds-dtl.

do
on error undo, return error return-value
:

  find first buf_inkas exclusive-lock
       where buf_inkas.inkas-code = p-inkas-code no-error no-wait.
  if locked buf_inkas then do:
    if p-auto < 2 then return error substitute("Отчет о продаже №&1 занят", p-inkas-code).
                  else return "":U.
  end.
  if NOT available buf_inkas then do:
    return error substitute("Не найден отчет о продаже №&1", p-inkas-code).
  end.
  if p-auto = 2 and buf_inkas.status_ <> {&doc-froze} then do:
    return "":U.
  end.
  if p-auto < 2 then do:
    if not (buf_inkas.status_ = {&g___new} or buf_inkas.status_ = {&doc-froze}) then do:
      return error substitute("Отчет о продаже №&1 имеет статус &2", buf_inkas.inkas-code, buf_inkas.status_).
    end.
    { gbl/chk-actg.i
        g#db-num
        g#userid
        {&action-head-code-main}
        'actn_sale_fact':U
        {&cntxt-object}
        buf_inkas.host-code
        buf_inkas.obj-type
        buf_inkas.obj-code
        0
        0
        0
        true
        glog
    }
    if NOT glog then return error.
  end.
  if NOT can-find (first ub.chk-doc where ub.chk-doc.out-code = buf_inkas.inkas-code) then do:
    return error substitute("Отчет о продаже N&1 пуст. Закрытие невозможно.", buf_inkas.inkas-code).
  end.

  { gbl/objdbnum.i {&shop}  buf_inkas.obj-code v-db-num }
  if v-db-num <> g#db-num then do:
    return error substitute("Отчет о продаже №&1 относится к магазину БД &2, текущая БД &3"
                            , buf_inkas.inkas-code
                            , v-db-num
                            , g#db-num
                            ).
  end.

  assign
    varoldstatus = buf_inkas.status_
    varoldflag   = buf_inkas.flag_ 
    v-obj-type = buf_inkas.obj-type
    v-obj-code = buf_inkas.obj-code
  .
  /* @findfirst trn-doc */
  FIND FIRST buf_trn-doc WHERE
            buf_trn-doc.doc-code = buf_inkas.inkas-code NO-LOCK.
  FIND FIRST buf_ret-doc WHERE
            buf_ret-doc.doc-code = buf_trn-doc.out-code NO-LOCK no-error.
   v-is-inquiry = buf_trn-doc.status_ = {&inquiry}.

  /*найдем код оплаты в кредит*/
  find first buf_sysconf where
           buf_sysconf.host-code = buf_inkas.host-code no-lock.
  if not available buf_sysconf then do:
    return error substitute("Не найдена запись о фирме &1", buf_inkas.host-code).
  end.
  assign
  v-host-code = buf_inkas.host-code.
  find first buf_Cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
  { gbl/conf-rd.i
    "'iscredit'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    conf-par
    par-type
    no-error
  }
  if error-status:error
  or not available buf_cash-pay
  or buf_cash-pay.is-credit = no
  or conf-par <> "yes"
  then do:
      assign
      cre-pay = 0
      .
  end.
  else do:
    assign
    cre-pay = buf_sysconf.credit-pay
    .
  end.

  { gbl/conf-rd.i
  "'is-ptrl'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  conf-par
  par-type
  no-error
  }
  if not error-status :error
  and par-type = {&type-log} then do:
     assign
     v-is-ptrl = logical(conf-par)
     no-error
     .
  end.

  
  run fbrhist-read-conf in this-procedure .
  if p-auto < 2 then do:
    if NOT auto-close then do:
      if p-auto = 0 and NOT b-mail-pressed  then do:
        glog = no.
        message
        "В течение данного сеанса работы с продажей вы не докачивали новые чеки!" skip
        "Вы уверены, что хотите закрыть продажу?"
        view-as alert-box WARNING  buttons YES-NO update glog.
        if not glog then return error.
      end.
    end.
    if NOT auto-close
    or p-auto = 1 then do:
      run str/chk-inf.p (
                 input parparentproc
                ,input buf_inkas.host-code
                ,input buf_inkas.obj-type
                ,input buf_inkas.obj-code
                ,input no
                ,input yes
                ,input recid(buf_inkas)
                ,output v-notes
                ,output not-all-saled-chk
                ,output not-all-normal-chk
                ,output not-all-inkas-closed
                 ).
      run gbl/d-askw.w
      (input substitute("Закрытие отчета о продаже&1",
                        ( if g#db-num > 0 then " и отправка его в офис" else "" )
                      )
      /* Заголовок окна */
      ,input v-notes /* Общее сообщение */
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input "Закрыть|Не закрывать" /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input "Закрытый отчет нельзя исправить|" /* список описаний кнопок */
          +  "Проверить документ еще раз"
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 2 /* значение возвращаемое при нажатии escape */
      ,output case-num /* выбор пользователя */
      ).
      if case-num = 2 then do:
        return error.
      end.
    end. /*if not auto-close*/
  end. /*if not p-auto*/
  { gbl/objat.i
    buf_inkas.obj-type
    buf_inkas.obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if not l-shift-on then do:
    run adm/shattri.p (
        input "get":U
        ,input buf_inkas.obj-type
        ,input buf_inkas.obj-code
        ,input  {&attr-autosale}
        ,input  {&attr-autosale_close-day-period} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-close-day-period
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    delete object v-tth no-error.
  end.
  if v-close-day-period then do:
    define variable v-continue as logical no-undo .
    run str/salechpe.p ( input parparentproc
                        ,input p-log-handle
                        ,input p-auto
                        ,input buf_inkas.inkas-code
                        ,output v-continue
                        ) no-error.
    if not v-continue then do:
      return error ''.
    end.
  end.

  /* 02/III-2018 buf_trn-doc уже найден в строке 522 @findfirst trn-doc, также в режиме no-lock, и также без no-error
  FIND FIRST buf_trn-doc WHERE
           buf_trn-doc.doc-code = buf_inkas.inkas-code NO-LOCK .
  */
  glog = no.

  RUN Inv-chk in this-procedure  (
                input buf_inkas.inkas-code
              , input v-curr-r-b
              , buffer buf_inkas
              , buffer buf_trn-doc
              , input ? /*и расход и возврат и списание и техпролив */
              , input ? /*p-office*/
              , input ? /*все строчки?*/) no-error .
  IF error-status:error  then undo, return error return-value .
  run fbrhist-init in this-procedure.
  assign
  BadTrans = no
  compensed = no
  .
  /*если p-auto = 0 то у нас все заполнено*/
  if p-auto <> 0 then do:
    if can-find(first tpsi_sale-doc where
                     tpsi_sale-doc.inkas-code = buf_inkas.inkas-code
                 and tpsi_sale-doc.tpsidoc = yes )
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
    and not v-is-inquiry
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
  f-close:
  DO  on ERROR undo, return error return-value
      on STOP undo, return error return-value :
    if auto-fbr
    then do :
      /* BTS-1129 Перед закрытием продажи проверям, было ли резервирование возвратов */
      /* производимых товаров со снятой галочкой "автопроизводтсво". Для таких строк */
      /* нужно заново снять резервы и перерезервировать с учётом автопроизводства    */
      doc-fbr-gds_ :
      for each bf_doc-fbr-gds no-lock where bf_doc-fbr-gds.out-code = p-inkas-code,
        first buf_goods no-lock where buf_goods.gds-code = bf_doc-fbr-gds.gds-code,
        first out-dtl no-lock where out-dtl.doc-code  = bf_doc-fbr-gds.out-code
                                and out-dtl.artic     = buf_goods.artic
                                and out-dtl.prod-type = buf_goods.prod-type
                                and out-dtl.prod-code = buf_goods.prod-code
      :
        if out-dtl.doc-qnty <> out-dtl.fact-qnty
        then do :
          find first ret-dtl no-lock where ret-dtl.doc-code  = replace(out-dtl.doc-code, "-", "=")
                                       and ret-dtl.artic     = out-dtl.artic
                                       and ret-dtl.prod-type = out-dtl.prod-type
                                       and ret-dtl.prod-code = out-dtl.prod-code
                                       and ret-dtl.prt-code  = out-dtl.prt-code
                                       no-error .
          if available ret-dtl
          and ret-dtl.fact-qnty > 0
          and ret-dtl.fact-qnty = ret-dtl.doc-qnty
          then do :
            find first buf_doc-line no-lock where buf_doc-line.doc-code   = ret-dtl.doc-code
                                              and buf_doc-line.artic      = ret-dtl.artic
                                              and buf_doc-line.prod-type  = ret-dtl.prod-type
                                              and buf_doc-line.prod-code  = ret-dtl.prod-code
                                              no-error .
            if available buf_doc-line
            then do :
              assign
                rdoc-line = recid (buf_doc-line)
                rgds-dtl = recid(ret-dtl)
                r-qnty =  - ret-dtl.fact-qnty
                r-b-code = ?
                r-or-v = {&TDEDT_vozvrat_vnesh_kass}
                r-office = {&gds-goods}
                from-menu = yes
              .
              run b-unres-proc in this-procedure (
                                    buffer buf_inkas
                                  , buffer buf_trn-doc
                                  , buffer buf_ret-doc
                                  , input p-is-tpsi-obj
                                  , input yes) no-error.

              if error-status:error then do:
                undo doc-fbr-gds_, return error.
              end.
            end .
          end .
        end .
      end .
    end .
    
    if auto-comp
    and not v-is-inquiry
    and can-find(first ub.sale-doc where
                      ub.sale-doc.inkas-code = p-inkas-code
                   and ub.sale-doc.doc-kind = {&TDEDT_VOZVRAT_Vnesh_Kass}
                   and ub.sale-doc.chr-office = {&gds-goods}
                   )
    then do: 
        RUN compense in this-procedure ( input p-inkas-code
                                        ,input p-is-tpsi-obj
                                        ,input rest-tpsi) no-error.
       if error-status:error then undo f-close, return error.
       compensed = yes.
    end.
    run set-compensed in p-parent-handle(input compensed) no-error .
    
    run compense-tabak in this-procedure (input p-inkas-code) no-error .
    if error-status:error then undo f-close, return error.
    
    v-gas-income-created = "" .
    
    if buf_trn-doc.ext-doc-type = {&TDEDT_ras_vnesh_kass} then do:

        run thbjattr_value in this-procedure (input v-obj-type
                                             ,input v-obj-code
                                             ,input {&attr-autosale}
                                             ,input {&attr-autosale_sale-add}
                                             ,output v-value-character
                                             ,output v-value-date
                                             ,output v-value-decimal
                                             ,output v-value-integer
                                             ,output v-value-logical
                                             ,output v-param-type
                                             ,output v-found) no-error.
        
        assign
        v-gas-cli-type = ""
        v-gas-cli-code = 0.
                
        jj:
        do jj = 1 to num-entries(v-value-character, ';':U):
            v-entry = entry(jj, v-value-character, ';':U).
            if entry(1, v-entry) = {&sale-add-nat-gas} and integer(entry(3, v-entry)) > 0 then do: /* В контрагенте на природный газ кто-то стоит */
                assign
                v-gas-cli-type = entry(2, v-entry)
                v-gas-cli-code = integer(entry(3, v-entry)).
                leave jj.
            end.
        end. /*do jj*/
        
        if v-gas-cli-code > 0 then do:
            
            for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code:
                
                find first buf_goods where buf_goods.prod-code = buf_doc-line.prod-code
                                       and buf_goods.prod-type = buf_doc-line.prod-type
                                       and buf_goods.artic = buf_doc-line.artic no-lock.
                                        
                /* Проверим, если газ */
                if is-gas(buf_goods.gds-code) then do:
                    
                    find first buf_sale-doc where buf_sale-doc.inkas-code = p-inkas-code.
                    
                    run str/gas-autosl.p (input parparentproc,
                                          input p-log-handle,
                                          input log-file-name,
                                          input p-auto,
                                          input p-inkas-code,
                                          input v-curr-r-b,
                                          input v-gas-cli-type,
                                          input v-gas-cli-code,
                                          output v-new_doc-code,
                                          output v-root-node,
                                          buffer buf_trn-doc,
                                          buffer buf_doc-line,
                                          buffer buf-new_trn-doc).
                    assign   /* Очищаем переменные, чтобы резервирование не воспринималось с компенсацией  */
                    r-qnty = 0
                    r-b-code = ?
                    r-pl-code = ?
                    rgds-dtl = ?.
                    find current buf_trn-doc exclusive-lock .
                    run RSRV-line in this-procedure (input 1,
                                                     input no,
                                                     input no,
                                                     input yes,
                                                     input no,
                                                     input v-new_doc-code,
                                                     input no,
                                                     input no,
                                                     input yes,
                                                     input buf_goods.gds-code,
                                                     input v-root-node,
                                                     output v-run-tpsi-line,
                                                     buffer buf_doc-line,
                                                     buffer buf_trn-doc,
                                                     buffer buf_sale-doc).
                    find current buf_trn-doc no-lock .
                    find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "^") no-error.
                    find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                              and spis_sale-doc.doc-kind =  {&sale-add-tech-refuell}  
                                                              no-error .                               
                    find first spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_doc-line.doc-code, "-", "^")     
                                                              and spis_doc-line.artic     = buf_doc-line.artic
                                                              and spis_doc-line.prod-type = buf_doc-line.prod-type
                                                              and spis_doc-line.prod-code = buf_doc-line.prod-code
                                                              no-error .
                    if available buf_spis-doc
                    and available spis_sale-doc
                    and available spis_doc-line
                    then do :
                      run RSRV-line in this-procedure (input 1,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input no,
                                                       input v-new_doc-code,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input buf_goods.gds-code,
                                                       input v-root-node,
                                                       output v-run-tpsi-line,
                                                       buffer spis_doc-line,
                                                       buffer buf_spis-doc,
                                                       buffer spis_sale-doc).
                                                       
                    end.   
                    find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "`") no-error.
                    find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                              and spis_sale-doc.doc-kind =  {&sale-add-write-off}  
                                                              no-error .                               
                    find first spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_doc-line.doc-code, "-", "`")     
                                                              and spis_doc-line.artic     = buf_doc-line.artic
                                                              and spis_doc-line.prod-type = buf_doc-line.prod-type
                                                              and spis_doc-line.prod-code = buf_doc-line.prod-code
                                                              no-error .
                    if available buf_spis-doc
                    and available spis_sale-doc
                    and available spis_doc-line
                    then do :
                      run RSRV-line in this-procedure (input 1,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input no,
                                                       input v-new_doc-code,
                                                       input no,
                                                       input no,
                                                       input yes,
                                                       input buf_goods.gds-code,
                                                       input v-root-node,
                                                       output v-run-tpsi-line,
                                                       buffer spis_doc-line,
                                                       buffer buf_spis-doc,
                                                       buffer spis_sale-doc).
                                                       
                    end.    
                    v-gas-income-created = v-gas-income-created + "," + string(buf_goods.gds-code) .                              
                end. /*if is-gas(buf_goods.gds-code) */
            
            end. /*  for each buf_doc-line */
            
            for each spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_trn-doc.doc-code, "-", "^") :
              find first buf_goods where buf_goods.prod-code = spis_doc-line.prod-code
                                     and buf_goods.prod-type = spis_doc-line.prod-type
                                     and buf_goods.artic = spis_doc-line.artic no-lock.
                                      
              /* Проверим, если газ */
              if is-gas(buf_goods.gds-code)
              and not can-do(v-gas-income-created, string(buf_goods.gds-code))
              then do:
                find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "^") no-error.
                find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                          and spis_sale-doc.doc-kind =  {&sale-add-tech-refuell}  
                                                          no-error .
                if available buf_spis-doc
                and available spis_sale-doc 
                then do :                                          
                  run str/gas-autosl.p (input parparentproc,
                                        input p-log-handle,
                                        input log-file-name,
                                        input p-auto,
                                        input p-inkas-code,
                                        input v-curr-r-b,
                                        input v-gas-cli-type,
                                        input v-gas-cli-code,
                                        output v-new_doc-code,
                                        output v-root-node,
                                        buffer buf_trn-doc,
                                        buffer spis_doc-line,
                                        buffer buf-new_trn-doc).
                  
                  run RSRV-line in this-procedure (input 1,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input no,
                                                   input v-new_doc-code,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input buf_goods.gds-code,
                                                   input v-root-node,
                                                   output v-run-tpsi-line,
                                                   buffer spis_doc-line,
                                                   buffer buf_spis-doc,
                                                   buffer spis_sale-doc).
                                                   
                  v-gas-income-created = v-gas-income-created + "," + string(buf_goods.gds-code) .
                end.                                   
              end.
            end.
            
            for each spis_doc-line exclusive-lock where spis_doc-line.doc-code  = replace(buf_trn-doc.doc-code, "-", "`") :
              find first buf_goods where buf_goods.prod-code = spis_doc-line.prod-code
                                     and buf_goods.prod-type = spis_doc-line.prod-type
                                     and buf_goods.artic = spis_doc-line.artic no-lock.
                                      
              /* Проверим, если газ */
              if is-gas(buf_goods.gds-code)
              and not can-do(v-gas-income-created, string(buf_goods.gds-code))
              then do:
                find first buf_spis-doc exclusive-lock where buf_spis-doc.doc-code = replace(buf_trn-doc.doc-code, "-", "`") no-error.
                find first spis_sale-doc exclusive-lock where spis_sale-doc.inkas-code = p-inkas-code
                                                          and spis_sale-doc.doc-kind =  {&sale-add-write-off}  
                                                          no-error .
                if available buf_spis-doc
                and available spis_sale-doc 
                then do :                                          
                  run str/gas-autosl.p (input parparentproc,
                                        input p-log-handle,
                                        input log-file-name,
                                        input p-auto,
                                        input p-inkas-code,
                                        input v-curr-r-b,
                                        input v-gas-cli-type,
                                        input v-gas-cli-code,
                                        output v-new_doc-code,
                                        output v-root-node,
                                        buffer buf_trn-doc,
                                        buffer spis_doc-line,
                                        buffer buf-new_trn-doc).
                  
                  run RSRV-line in this-procedure (input 1,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input no,
                                                   input v-new_doc-code,
                                                   input no,
                                                   input no,
                                                   input yes,
                                                   input buf_goods.gds-code,
                                                   input v-root-node,
                                                   output v-run-tpsi-line,
                                                   buffer spis_doc-line,
                                                   buffer buf_spis-doc,
                                                   buffer spis_sale-doc).
                                                   
                  v-gas-income-created = v-gas-income-created + "," + string(buf_goods.gds-code) .
                end.                                   
              end.
            end.
            
        end. /* if v-gas-cli-code > 0 */
            
    end. /* if buf_trn-doc.ext-doc-type */
    
    RUN button-close in this-procedure (
                                             buffer buf_trn-doc
                                            ,buffer buf_ret-doc
                                            ,input p-is-tpsi-obj
                                            ,input auto-fbr
                                            ,input neg-tpsi-weight
                                            ,input neg-tpsi-qnty
                                            ,input neg-tpsi-oper
                                            ,Output b-close-enabled).
    IF NOT b-close-enabled
    and not v-is-inquiry
    then do:
      undo f-close, return error substitute("Не все товары зарезервированы, закрытие невозможно!"
                            ).
    end.
    IF NOT b-close-enabled
    and v-is-inquiry
    then do:
      undo f-close, return error substitute("Некоторые товары зарезервированы, закрытие невозможно!"
                            ).
    end.
    if not v-is-inquiry then do:
      do while ii < 2:
        RUN neg-rests in this-procedure (
                    input yes
                  , input buf_inkas.status_
                  , input buf_inkas.inkas-code
                  , input {&update}
                  , input p-is-catering
                  , input p-is-tpsi-obj
                  , input neg-tpsi-weight
                  , input neg-tpsi-qnty
                  , input neg-tpsi-oper
                  ).
        _dtl-rests:
        for each dtl-rests no-LOCK:
          if NOT dtl-rests.ok
          or (ii = 0 AND dtl-rests.fbr > 0 and auto-fbr)
          or (ii = 0 AND dtl-rests.prop > 0 and p-is-tpsi-obj)
          then do:
            if (not auto-fbr or dtl-rests.fbr = 0)
            AND (not p-is-tpsi-obj or dtl-rests.prop = 0)
            then do:
              assign
              my-mes =  substitute("В результате данной продажи&1" +
                                    "на текущем объекте (&2&3)&1" +
                                    "появятся недопустимые ОТРИЦАТЕЛЬНЫE ОСТАТКИ&1" +
                                    "по товару  с артикулом : &4&1" +
                                    "производителя : &5&1" +
                                    "&6&1" +
                                    (if p-auto = 0 then "Закрытие продажи невозможнo !" else "":U)
                          , {&new-line}
                          , buf_inkas.obj-type
                          , buf_inkas.obj-code
                          , dtl-rests.artic
                          , (trim( dtl-rests.prod-type ) + " " + string(dtl-rests.prod-code))
                          ,  (if dtl-rests.b-code > 0
                            then ("по коду : " + string( dtl-rests.b-code, ">>>>>>>>>9" ))
                            else "")
                          ).

              if p-auto = 0 then do:
                undo f-close,  return error my-mes.
              end.
              else do:
                assign
                v-is-neg-rests = yes.
  &scop my-message my-mes
                {&display-message}.
              end.
            end.
            else do:
              assign
              force-auto-fbr = ( auto-fbr and dtl-rests.fbr > 0)
              force-tpsi-obj = ( p-is-tpsi-obj and dtl-rests.prop > 0)
              .
              /*выходим только в том случае если уже выяснили что надо запускать - автопр-во и/или ТПСИ */
              if (force-auto-fbr and force-tpsi-obj)
              or (force-auto-fbr and not p-is-tpsi-obj)
              or (force-tpsi-obj and not auto-fbr)
              then
              LEAVE _dtl-rests.
            end.
          end.
        end. /*for each dtl-rests no-LOCK:*/
        if p-auto > 0
        and v-is-neg-rests then do:
  &scop my-message "Закрытие продажи невозможно"
                {&display-message}.
          undo f-close,  return error my-mes.
        end.
        if force-tpsi-obj and ii = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Автоматическое перемещение товаров в пределах ТПСИ,&1 необходимых для резервирования в продаже &2"
                              , {&new-line})
                                ).
          run str/tpsisale.p (
                        input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input (string(buf_inkas.host-code) + {&delim-par} +
                                buf_Inkas.obj-type + {&delim-par} +
                                string(buf_inkas.obj-code) + {&delim-par} +
                                buf_inkas.inkas-code + {&delim-par} +
                                log-file-name
                                )
                        ) no-error .
          if error-status:error then do:
            undo f-close, return error  substitute(("Ошибка при попытке перемещения товаров, необходимых для резервирования в продаже &1:&2&3 &4" +
                                    "Закрытие продажи невозможнo !")
                                    , buf_inkas.inkas-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
          end.
          ASSIGN
          FROM-MENU = NO
          .
          run b-res-proc in this-procedure (
                                            buffer buf_inkas
                                          , buffer buf_trn-doc
                                          , buffer buf_ret-doc
                                          , input yes                       /*p-auto-fbr*/
                                          , input auto-close                /*auto-close*/
                                          , input yes                       /*p-rsrv-prop-goods*/
                                          , input rest-dish                 /*p-rest-dish */
                                          , input v-fbr-income-doc-code     /*p-fbr-income-doc-code*/
                                          , input p-is-tpsi-obj             /*p-is-tpsi-obj*/
                                          , input rest-tpsi) no-error.       /*p-rest-tpsi */
          if error-status:error or return-value = "error" then do:
            undo f-close, return error  substitute("Ошибка при попытке резервирования товаров, перемещенных для данной продажи:&1&2 &3" +
                                    "Закрытие продажи невозможнo !"
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                      ).
          end.
          if not force-auto-fbr then
          /*чтобы не считать два раза если вдруг там есть и производство*/
          assign
          ii = ii + 1
          .
        end.
        if force-auto-fbr and ii = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Автоматическое производство товаров, необходимых для резервирования в продаже &1", buf_inkas.inkas-code
                                , {&new-line})
                                ).
          run str/fbrsale.p (
                        input parparentproc
                        ,input this-procedure
                        ,input p-log-handle
                        ,input (buf_inkas.inkas-code + {&delim-par} +
                                (if rest-dish then "yes" else "no") + {&delim-par} +
                                (if rest-ingr then "yes" else "no")
                                )
                      ) no-error .
          if error-status:error then do:
            undo f-close, return error substitute(("Ошибка при попытке производства товаров, необходимых для резервирования в продаже &1:&2&3 &4" +
                                    "Закрытие продажи невозможнo !")
                                    , buf_inkas.inkas-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
          end.
          if not rest-dish then do:
            run fbrcode-get-final-doc in  this-procedure (
                                                          input buf_inkas.inkas-code
                                                          ,output v-fbr-income-doc-code
                                                          ) no-error .
            if error-status:error then do:
              undo f-close, return error substitute("Ошибка при получении кода документа ВН товаров, произведенных для резервирования в продаже:&1&2 &3"
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
            end.
          end.
          ASSIGN
          FROM-MENU = NO
          .
          run b-res-proc in this-procedure (
                                              buffer buf_Inkas
                                            , buffer buf_trn-doc
                                            , buffer buf_ret-doc
                                            , input yes
                                            , input auto-close
                                            , input yes
                                            , input rest-dish
                                            , input v-fbr-income-doc-code
                                            , input p-is-tpsi-obj
                                            , input rest-tpsi) no-error.
          if error-status:error or return-value = "error" then do:
            undo f-close, return error  substitute("Ошибка при попытке резервирования товаров, произведенных для данной продажи&1" +
                                    "Закрытие продажи невозможнo !"
                                    ,{&new-line}).
          end.
          else do:
            run fbr-saledoc-create in this-procedure ( input buf_inkas.inkas-code).
          end.
        end.
        assign
        ii = ii + 1
        .
      end. /*do while ii*/
    end. /*not v-is-inquiry*/
    FIND FIRST locked_inkas WHERE recid( locked_inkas ) = recid( buf_inkas ) .
    FIND FIRST locked_trn-doc WHERE locked_trn-doc.doc-code = buf_inkas.inkas-code .
    assign
    locked_inkas.is-auto-close = (p-auto >= 2)
    locked_inkas.auto-fbr   = force-auto-fbr
    locked_Inkas.rest-dish  = rest-dish
    locked_Inkas.rest-ingr  = rest-ingr
    locked_inkas.auto-tpsi  = force-tpsi-obj
    locked_inkas.rest-tpsi  = rest-tpsi
    locked_Inkas.auto-comp  = auto-comp
    .
    if l-shift-on then do:
      { gbl/curshift.i locked_inkas.obj-type locked_inkas.obj-code v-shift-date v-shift-num v-shift-name no-error }
      /* 02/III-2018 заходим сюда в рамках задачи добавления продажи в закрытую смену задним числом.
                     Смена, в которую добавляем, ТОЧНО НЕ ТЕКУЩАЯ, и она уже закрыта. Возможно, gbl/curshift.i избыточен */
      if error-status:error
      or not (v-shift-date = locked_inkas.shift-date
              and
              v-shift-num = locked_inkas.shift-num) then do:
        /*найдем закрытую смену и проставим ее в факт дату*/
        find first buf_shift-obj no-lock where
                  buf_shift-obj.obj-type = locked_inkas.obj-type
              and buf_shift-obj.obj-code = locked_inkas.obj-code
              and buf_shift-obj.shift-date = locked_inkas.shift-date
              and buf_shift-obj.shift-num = locked_inkas.shift-num no-error.
        if not available buf_shift-obj then do:
            undo f-close, return error  substitute("Не найдена смена с пор.№ &1 от &2 для &3&4&5" +
                                                  "Закрытие продажи невозможнo !"
                                                   ,locked_inkas.shift-num
                                                   ,locked_inkas.shift-date
                                                   ,locked_inkas.obj-type
                                                   ,locked_inkas.obj-code
                                                   ,{&new-line}).
        end.
        if buf_shift-obj.status_ <> {&sht-closed} then do:
            undo f-close, return error  substitute("Смена с пор.№ &1 от &2 для &3&4 имеет статус &5&6" +
                                                  "Закрытие продажи невозможнo !"
                                                   ,locked_inkas.shift-num
                                                   ,locked_inkas.shift-date
                                                   ,locked_inkas.obj-type
                                                   ,locked_inkas.obj-code
                                                   ,locked_inkas.status_
                                                   ,{&new-line}).

        end.
        assign
        v-back-date = yes
        locked_inkas.fact-date = buf_shift-obj.close-date
        v-old-shift-obj = buffer buf_shift-obj:handle
        v-new-shift-obj = v-old-shift-obj
        .
      end.
    end.
    else . /*else if l-shift-on then do:*/
    { gbl/curobjdt.i locked_inkas.obj-type locked_inkas.obj-code sys-today no-error }
   if not v-back-date then do:
    if p-auto > 1 then do:
      assign
      locked_inkas.fact-date = sys-today
      .
    end.
    else do:
        if locked_inkas.doc-date = sys-today then do:
            locked_inkas.fact-date = sys-today.
        end.
        else  do:
          if p-auto < 2 then do:
            assign
            v-doc-date = locked_inkas.doc-date
            .
            if not can-find(first tpsi_sale-doc where
                                tpsi_sale-doc.inkas-code = locked_inkas.inkas-code
                            and tpsi_sale-doc.tpsidoc = yes) then  do:
              run str/sale-fd.w ( input sys-today, input-output v-doc-date, input l-shift-on ) no-error.
              if not error-status:error then do:
                 run str/chk-back.p (
                                      input locked_inkas.inkas-code
                                    , input v-doc-date
                                     ) no-error.
                 if error-status:error then do:
                    undo f-close, return error
                   substitute("НЕЛЬЗЯ закрыть продажу с выбранной датой факт, равной &1&2&3"
                                    , string(v-doc-date, "99/99/9999")
                                    , {&new-line}
                                    , return-value
                                    ).
                 end.
              end.
              if not error-status:error then
              assign
              locked_inkas.fact-date = v-doc-date
              /*inkas.shift-date = v-doc-date*/
              v-back-date = (v-doc-date < sys-today)
              .
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("Дата факт закрытия продажи выбрана равной &1&2"
                                    , string(v-doc-date, "99/99/9999")
                                    , {&new-line})
                                    ).
            end.
            else do:
              assign
              locked_inkas.fact-date = sys-today
              /*inkas.shift-date = sys-today*/
              .
            end.
          end.
          else
          assign
          locked_inkas.fact-date = sys-today
          /*inkas.shift-date = sys-today*/
          .
        end.
      end. /* p-auto < 2*/
    end.
    if p-auto = 0 then run frame-title in p-parent-handle .
    RUN INKAS-CLOSING in this-procedure ( input v-back-date, input v-is-inquiry, buffer locked_inkas) no-error.
    if error-status:error then do:
        run waitfram-hide in this-procedure .
        undo f-close,  return error return-value .
    end.
    /* внутри inkas-closing значение locked_inkas.status_ изменили на {&fact};
       теперь, как только отработает триггер, новую продажу можно выгружать в экспорт */
    glog = no.
    if not v-is-inquiry then do:
      _dtl:
      FOR EACH dtl-rests where
            dtl-rests.prt-code >=0
        and dtl-rests.ok-prop = no ,
        FIRST buf_prt-obj WHERE
            buf_prt-obj.obj-type = buf_inkas.obj-type
        AND buf_prt-obj.obj-code = buf_inkas.obj-code
        AND buf_prt-obj.artic = dtl-rests.artic
        AND buf_prt-obj.prod-type = dtl-rests.prod-type
        AND buf_prt-obj.prod-code = dtl-rests.prod-code
        AND buf_prt-obj.prt-code = dtl-rests.prt-code  NO-LOCK:
          if p-is-tpsi-obj
          and dtl-rests.prop > 0 then do:
            find first dtl-rests-mark where
                      dtl-rests-mark.artic = dtl-rests.artic
                  and dtl-rests-mark.prod-type = dtl-rests.prod-type
                  and dtl-rests-mark.prod-code = dtl-rests.prod-code no-error .
            if available dtl-rests-mark then next _dtl.
          end.
          IF buf_prt-obj.fact-qnty < 0 then do:
            v-prichina =  substitute("В результате данной продажи&1" +
                                  "на текущем объекте (&2&3)&1" +
                                  "появятся недопустимые ОТРИЦАТЕЛЬНЫE ОСТАТКИ&1" +
                                  "по товару  с артикулом : &4&1" +
                                  "производителя : &5&1" +
                                  "&6&1" +
                                  "Закрытие продажи невозможнo !&1" +
                                  "Исправьте эту ситуацию путем выполнения на кассе&1" +
                                  "последовательных возвратов и расходов."
                        , {&new-line}
                        , buf_inkas.obj-type
                        , buf_inkas.obj-code
                        , dtl-rests.artic
                        , (trim( dtl-rests.prod-type ) + " " + string(dtl-rests.prod-code))
                        ,  (if dtl-rests.b-code > 0
                          then ("по коду : " + string( dtl-rests.b-code, ">>>>>>>>>9" ))
                          else "")
                        ).
              BadTrans = TRUE .
          END.
          LEAVE.
        END.
      if BadTrans then do:
          run waitfram-hide in this-procedure .
          UNDO f-close, return error v-prichina.
      end.
  end. /*not v-is-inquiry*/
  if not v-is-inquiry then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Создание накладных МЦ...")
                          ).
    run str/salewth.p (
                    input parparentproc
                    ,buffer buf_Inkas
                    ,buf_trn-doc.cli-type
                    ,buf_trn-doc.cli-code
                    ,buf_trn-doc.doc-code
                    ,(if available buf_ret-doc then buf_ret-doc.doc-code else '':U)
                  ) no-error.
    if error-status:error then do:
      undo f-close, return error return-value .
    end.
    release locked_inkas no-error .
    if error-status:error then do:
      undo f-close, return error return-value .
    end.
    /* триггер на locked_inkas.status_ отработал, однако перед выгрузкой надо дождаться обновления вложенных таблиц */
    if can-find( first ub.chk-doc NO-LOCK WHERE
                    ub.chk-doc.out-code = buf_inkas.inkas-code
                AND ub.chk-doc.d-card <> "" ) then do:
      /*создание и обновление dis-obj dis-host cli-gds обновление по мере необходимости dis-card и cli*/
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подсчет итогов продаж по дисконтным картам...")
                            ).
      run str/saledc.p
        (
        input parparentproc
        ,input this-procedure :handle
        ,input p-log-handle
        ,input {&dct-proc_sale-close}
        ,input ? /*p-emitent-host-code*/
        ,input "" /*p-type*/
        ,input 0 /*p-profile-id*/
        ,input 0 /*p-codex-id*/
        ,input 0 /*p-ruleset-id*/
        ,input g#db-num
        ,input buf_Inkas.inkas-code
        ,input buf_Inkas.doc-date
        ,input buf_Inkas.fact-date
        ,input cre-pay
        ,input 1 /*par-sign*/
        ,input ? /*par-direction*/
        ,input yes /*p-save*/
        ) no-error .
      if error-status:error then do:
        undo f-close, return error return-value .
      end.
    end.
  end. /*if not v-is-inquiry then do:*/
END. /* end_of f-close */

  /* 02/III-2018 При закрытии (is-back-date) или удалении документа продажи ЗАДНИМ ЧИСЛОМ
                 посылать в 1С сообщение в формате закрытия смены.
                 Если сделали новую, то мы посылаем смену со всеми чеками, включая чеки новой продажи.
     p.s. "задним числом" - когда продажу добавляют в закрытую смену и там её закрывают
  */
  if l-shift-on then do:
    /* смена, полученная выше в строке 1060 - именна та, которая нам требуется */
    if v-back-date and v-new-shift-obj <> ? and v-new-shift-obj:available then do :
      /* указатели old и new указывают в одно место, т.к. фактически запись о смене не менялась */
      { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_shift}
      v-old-shift-obj
      v-new-shift-obj
      ''
      ''
      no-error
      }
      if error-status :error then do:
        run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1Ошибка маршрутизации записи в машину правил&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            )).
        v-view-log = yes.
      end.
    end .
  end. /* end_of if_shift_on */

if not v-is-inquiry then do:
  run fbrhist-table-to-base in this-procedure no-error.
  if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Ошибка записи истории производства в базу данных&1&2 &3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            )).
      assign
      v-view-log = yes.
      {&view-log}.
  end.
end.
&scop my-message   substitute("Закрытие продажи &1: Отчет о продаже закрыт успешно.", p-inkas-code)
{&display-message-laud}.
FOR EACH dtl-rests:
  delete dtl-rests.
END.
end. /*doe*/

end procedure. /* proc-main */

procedure compense-tabak :
  define input parameter p-inkas-code as character no-undo .
  
  define variable cv as decimal no-undo.
  define variable unresv as decimal no-undo.
  define variable unresr as decimal no-undo.
  define buffer b-goods for goods.
  define buffer b-gds-dtl for gds-dtl.
  define buffer brw-gds-dtl for gds-dtl.
  define buffer br-gds-dtl for gds-dtl.
  define buffer b-doc-line for doc-line.
  define buffer br-doc-line for doc-line.
  define buffer brw-doc-line for doc-line.
  define buffer b-doc for trn-doc.
  define buffer b-doc-prts for doc-prts.
  define buffer brw-doc-prts for doc-prts.
  define buffer b-doc-pl for doc-pl.
  define buffer brw-doc-pl for doc-pl.
  define buffer b-gds-prt for gds-prt.
  define variable qnty-compense as decimal no-undo.
  define variable qnty-compense-abs as decimal no-undo.
  define variable tsall as decimal no-undo.
  
  define variable v-type as character no-undo .
  define variable v-attr-value as character no-undo .
  
  define variable vCodeIdent as character no-undo .
  
  define buffer buf_marking for ub.marking .
  define buffer buf_gds-prt for ub.gds-prt.
  define buffer buf_doc-prts  for ub.doc-prts.
  define buffer buf_sale-doc for ub.sale-doc.
  define buffer b_marking-chk for ub.marking-chk .
  define buffer br_marking-chk for ub.marking-chk .
  define buffer b_chk-doc for ub.chk-doc .
  define buffer br_chk-doc for ub.chk-doc .
  define buffer b_chk-gds for ub.chk-gds .
  define buffer br_chk-gds for ub.chk-gds .
  
  find first buf_sale-doc NO-lock where
            buf_Sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = {&TDEDT_vozvrat_vnesh_kass} no-error .
  if not available buf_sale-doc then return.
  
  &scop my-message "Проведем компенсацию незарезервированных маркированных товаров"
  {&display-message}.
  
  _docline:
  for each br-doc-line where
         br-doc-line.doc-code = buf_ret-doc.doc-code
  on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
      cv = 0
    .
    FIND FIRST b-doc-line where
               b-doc-line.artic = br-doc-line.artic AND
               b-doc-line.prod-type = br-doc-line.prod-type AND
               b-doc-line.prod-code = br-doc-line.prod-code and 
               b-doc-line.doc-code = buf_trn-doc.doc-code NO-ERROR.
    IF NOT AVAILABLE b-doc-line then NEXT _docline.
    if b-doc-line.doc-qnty = b-doc-line.fact-qnty then next _docline .
    
    find first goods no-lock where goods.artic = br-doc-line.artic
                               and goods.prod-type = br-doc-line.prod-type
                               and goods.prod-code = br-doc-line.prod-code
                               .
    RUN gds-attr-value (
                        INPUT goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-attr-value,
                        OUTPUT v-type
                        ).
    if v-attr-value > ""
    and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(b-doc-line.obj-type, b-doc-line.obj-code):GetIsMarkingForType(v-attr-value)
    then do :
      find first bar-code no-lock where bar-code.gds-code = goods.gds-code
                                    and bar-code.unit-cli = b-doc-line.unit-cli
                                    no-error .
      if available bar-code
      then do :
        for each b_chk-doc no-lock where b_chk-doc.out-code = b-doc-line.doc-code
                                     and b_chk-doc.chk-type = integer ({&rcpt-sale})
                                     : 
          for each b_chk-gds no-lock where b_chk-gds.doc-code = b_chk-doc.doc-code 
                                       and b_chk-gds.b-code = bar-code.b-code
                                       and b_chk-gds.doc-qnty < 0 :
            for each b_marking-chk exclusive-lock where b_marking-chk.doc-code = b_chk-gds.doc-code
                                                     and b_marking-chk.line-num = b_chk-gds.line-num
                                                     and b_marking-chk.sts = 0
                                                     :  
              for first br_marking-chk exclusive-lock where br_marking-chk.mark = b_marking-chk.mark
                                                        and br_marking-chk.doc-code = b_marking-chk.doc-code
                                                        and br_marking-chk.line-num <> b_marking-chk.line-num
                                                        and br_marking-chk.sts = 0,
              first br_chk-gds no-lock where br_chk-gds.doc-code = b_chk-gds.doc-code
                                         and br_chk-gds.line-num = br_marking-chk.line-num
                                         and br_chk-gds.doc-qnty = - b_chk-gds.doc-qnty                                       
                                         :
                assign
                  b_marking-chk.sts = 2  
                  br_marking-chk.sts = 2
                . 
              end .                                         
            end .
          end .                                                                        
        end . /* b_chk-doc */
        for each br_chk-doc no-lock where br_chk-doc.out-code = b-doc-line.doc-code
                                      and br_chk-doc.chk-type = integer ({&rcpt-return})
                                       :
          for each br_chk-gds no-lock where br_chk-gds.doc-code = br_chk-doc.doc-code 
                                        and br_chk-gds.b-code = bar-code.b-code:
            mark_ :                              
            for each br_marking-chk exclusive-lock where br_marking-chk.doc-code = br_chk-gds.doc-code
                                                     and br_marking-chk.line-num = br_chk-gds.line-num
                                                     and br_marking-chk.sts = 0
                                                     :
              for each b_chk-doc no-lock where b_chk-doc.out-code = b-doc-line.doc-code
                                           and b_chk-doc.chk-type = integer ({&rcpt-sale}),
              each b_chk-gds no-lock where b_chk-gds.doc-code = b_chk-doc.doc-code
                                       and b_chk-gds.b-code = bar-code.b-code,
              first b_marking-chk exclusive-lock where b_marking-chk.mark = br_marking-chk.mark
                                                   and b_marking-chk.doc-code = b_chk-gds.doc-code
                                                   and b_marking-chk.line-num = b_chk-gds.line-num
                                                   and b_marking-chk.sts = 0
                                                   and rowid(b_marking-chk) <> rowid(br_marking-chk)  
                                                   :                                                                                          
                assign vCodeIdent = GetCodeIdent(b_marking-chk.mark) .
                find first buf_marking no-lock where buf_marking.mark begins vCodeIdent no-error .
                if not available buf_marking then next .
                assign
                  b_marking-chk.sts = 2  
                  br_marking-chk.sts = 2
                  cv = cv + buf_marking.box-qnty
                .
                next mark_ .
              end .                                         
            end . 
          end . /* br_chk-gds */
        end . /*br_chk-doc */
      end . /*bar-code */
      
      FIND FIRST buf_gds-prt NO-LOCK WHERE
                 buf_gds-prt.upper-code = goods.prt-root NO-ERROR.
      FIND FIRST b-gds-dtl where
                  b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
                  b-gds-dtl.artic = b-doc-line.artic AND
                  b-gds-dtl.prod-type = b-doc-line.prod-type AND
                  b-gds-dtl.prod-code = b-doc-line.prod-code AND
                  b-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
      FIND FIRST br-gds-dtl where
                  br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                  br-gds-dtl.artic = br-doc-line.artic AND
                  br-gds-dtl.prod-type = br-doc-line.prod-type AND
                  br-gds-dtl.prod-code = br-doc-line.prod-code AND
                  br-gds-dtl.prt-code = buf_gds-prt.node-code  No-ERROR.           
      assign
        tsall =  if v-curr-r-b = {&r-b-base}
                 then  (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base)
                       )
                 else   (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl)
                       )
        b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cv
        br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cv
        br-doc-line.fact-qnty = br-doc-line.fact-qnty - cv
        b-doc-line.fact-qnty = b-doc-line.fact-qnty - cv
        qnty-compense = qnty-compense + cv
        qnty-compense-abs = qnty-compense-abs + abs(cv)
      .
      if (v-curr-r-b = {&r-b-base} and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
      OR (v-curr-r-b = {&r-b-rubl} and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
      then do:
      /*если скидки у расхода/возврата не равны то пересчитаем их*/
        if v-curr-r-b = {&r-b-base} then do:
          assign
          br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                    then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                 tsall )  / br-gds-dtl.fact-qnty )
                                    else br-gds-dtl.discnt-base )
          b-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                    then (b-gds-dtl.price-base - ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                                                                 tsall ) / b-gds-dtl.fact-qnty  )
                                    else b-gds-dtl.discnt-base )
          br-gds-dtl.discnt-rubl =  br-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
          b-gds-dtl.discnt-rubl =   b-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
          .
        end.
        else do:
          assign
          br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                    then (br-gds-dtl.price-rubl -
                                                                ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                               tsall )  / br-gds-dtl.fact-qnty
                                                                 )
                                   else br-gds-dtl.discnt-rubl
                                   )
          b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                   then (b-gds-dtl.price-rubl -
                                                             ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                           tsall ) / b-gds-dtl.fact-qnty
                                         )
                                  else b-gds-dtl.discnt-rubl
                                  )
          br-gds-dtl.discnt-base =  br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
          b-gds-dtl.discnt-base =   b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
          .
        end.
      end.
      release b-gds-dtl.
      release br-gds-dtl.
    end . /* */
  end .
  FIND FIRST b-doc where b-doc.doc-code = buf_trn-doc.doc-code No-ERROR.
    assign
      b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense
    .
  FIND FIRST b-doc where b-doc.doc-code = buf_ret-doc.doc-code No-ERROR.
  if available b-doc then do:
    assign
      b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense
    .
  end.
  run waitfram-hide in this-procedure .
  if p-auto = 0 then do:
    run UI-on in p-parent-handle.
    run ui-2 in p-parent-handle.
  end.
end procedure .

PROCEDURE compense:
define input parameter p-inkas-code as character no-undo .
define input parameter p-is-tpsi-obj  as logical no-undo .
define input parameter p-rest-tpsi as logical no-undo .
define variable cv as decimal no-undo.
define variable cvp as decimal no-undo.
define variable cvpl as decimal no-undo.
define variable res-parts as decimal.
define variable res-places as decimal.
define variable unresv as decimal no-undo.
define variable unresr as decimal no-undo.
define buffer b-goods for ub.goods.
define buffer b-gds-dtl for ub.gds-dtl.
define buffer brw-gds-dtl for ub.gds-dtl.
define buffer br-gds-dtl for ub.gds-dtl.
define buffer b-doc-line for ub.doc-line.
define buffer br-doc-line for ub.doc-line.
define buffer brw-doc-line for ub.doc-line.
define buffer b-doc for ub.trn-doc.
define buffer b-doc-prts for ub.doc-prts.
define buffer brw-doc-prts for ub.doc-prts.
define buffer b-doc-pl for ub.doc-pl.
define buffer brw-doc-pl for ub.doc-pl.
define buffer b-gds-prt for ub.gds-prt.
define variable qnty-compense as decimal no-undo.
define variable qnty-compense-abs as decimal no-undo.
define variable tsall as decimal no-undo.
define variable old-doc-line-fact-qnty-r as decimal no-undo.
define variable old-doc-line-fact-qnty-v as decimal no-undo.
define variable old-doc-line-fact-qnty-rw as decimal no-undo.
define variable saled-by-place-r as decimal no-undo.
define variable saled-by-parts-r as decimal no-undo.
define variable saled-by-place-v as decimal no-undo.
define variable saled-by-parts-v as decimal no-undo.
define variable saled-by-place-rw as decimal no-undo.
define variable saled-by-parts-rw as decimal no-undo.
define variable v-retur-write-off-code as character no-undo .
define variable v-type as character no-undo .
define variable v-return-write-off-code like ub.trn-doc.doc-code no-undo .
define variable v-attr-value as character no-undo .
define buffer b-temp-prts for temp-prts.
define buffer b-temp-pl for temp-pl.
define buffer buf_units for ub.units.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_doc-pl  for ub.doc-pl.
define buffer buf_doc-prts  for ub.doc-prts.
define buffer buf_sale-doc for ub.sale-doc.

assign
note-compense = ""
.
/*начнем с возврата*/
find first buf_sale-doc NO-lock where
          buf_Sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.doc-kind = {&TDEDT_vozvrat_vnesh_kass} no-error .
if not available buf_sale-doc then return.

&scop my-message "Проведем компенсацию незарезервированных расходов-возвратов..."
{&display-message}.

/*компенсировать можно только количества за вычетом документа списания*/
find first buf_sale-doc NO-lock where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.doc-kind = {&sale-add-return-write-off} no-error .
if available buf_sale-doc then
v-return-write-off-code = buf_sale-doc.doc-code.

_docline:
for each b-doc-line where
       b-doc-line.doc-code = buf_ret-doc.doc-code
on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
:
    assign
    cv = 0
    cashparts = no
    cashplace = no
    cashfbr   = no
    old-doc-line-fact-qnty-v = b-doc-line.fact-qnty
    .
    FIND FIRST br-doc-line where
               br-doc-line.artic = b-doc-line.artic AND
               br-doc-line.prod-type = b-doc-line.prod-type AND
               br-doc-line.prod-code = b-doc-line.prod-code AND
               br-doc-line.doc-code = buf_trn-doc.doc-code NO-ERROR.
    IF NOT AVAILABLE br-doc-line then NEXT _docline.
    
    find first goods no-lock where goods.artic = br-doc-line.artic
                               and goods.prod-type = br-doc-line.prod-type
                               and goods.prod-code = br-doc-line.prod-code
                               .
    RUN gds-attr-value (
                        INPUT goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-attr-value,
                        OUTPUT v-type
                        ).
    if v-attr-value > ""
    and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(br-doc-line.obj-type, br-doc-line.obj-code):GetIsMarkingForType(v-attr-value)
    then do :
      next _docline .
    end .

    FIND FIRST brw-doc-line where
               brw-doc-line.artic = b-doc-line.artic AND
               brw-doc-line.prod-type = b-doc-line.prod-type AND
               brw-doc-line.prod-code = b-doc-line.prod-code AND
               brw-doc-line.doc-code = v-return-write-off-code NO-ERROR.

    assign
    old-doc-line-fact-qnty-r = br-doc-line.fact-qnty
    old-doc-line-fact-qnty-v = b-doc-line.fact-qnty
    old-doc-line-fact-qnty-rw = (if available brw-doc-line then brw-doc-line.fact-qnty else 0)
    saled-by-place-v = 0
    saled-by-place-r = 0
    saled-by-place-rw = 0
    saled-by-parts-v = 0
    saled-by-parts-r = 0
    saled-by-parts-rw = 0
    .
    find first b-goods where
               b-goods.artic = b-doc-line.artic AND
               b-goods.prod-type = b-doc-line.prod-type AND
               b-goods.prod-code = b-doc-line.prod-code NO-ERROR.
    IF NOT AVAILABLE b-goods then NEXT _docline.
    if is-gas(b-goods.gds-code) then v-gas-compensed = false .
    FIND FIRST buf_units NO-LOCK WHERE
               buf_units.unit-name = b-goods.unit-base No-ERROR.
    IF NOT AVAILABLE buf_units then NEXT _docline.
/*сначала компенсируем по складским местам*/
    /*если есть производсвто то не компенсируем*/
    if can-find(first ub.doc-fbr-gds no-lOCK where
                      ub.doc-fbr-gds.gds-code = b-goods.gds-code AND
                      ub.doc-fbr-gds.out-code = buf_ret-doc.doc-code)
      or
       can-find(first ub.doc-fbr-gds no-lOCK where
                      ub.doc-fbr-gds.gds-code = b-goods.gds-code AND
                      ub.doc-fbr-gds.out-code = buf_trn-doc.doc-code)
                      then do:
      NEXT _docline.
    end.

    if can-find(first ub.doc-pl No-LOCK WHERE
                      ub.doc-pl.gds-code = b-goods.gds-code AND
                      ub.doc-pl.out-code = buf_ret-doc.doc-code) then do:
        FIND FIRST buf_gds-prt NO-LOCK WHERE
                   buf_gds-prt.upper-code = b-goods.prt-root NO-ERROR.
        assign
        cashplace = yes
        cvpl = 0
        .
        for each temp-pl:
          delete temp-pl.
        end.
        for each b-doc-pl NO-LOCK WHERE
                 b-doc-pl.gds-code = b-goods.gds-code AND
                 b-doc-pl.out-code = buf_ret-doc.doc-code:
          saled-by-place-v = saled-by-place-v + b-doc-pl.fact-qnty.
          find first brw-doc-pl no-lock where
                 brw-doc-pl.gds-code = b-goods.gds-code
            AND  brw-doc-pl.pl-code = b-doc-pl.pl-code
            AND brw-doc-pl.out-code = v-return-write-off-code no-error .
          if available brw-doc-pl then do:
            saled-by-place-rw = saled-by-place-rw + brw-doc-pl.fact-qnty.
          end.
          create
          temp-pl.
          assign
          temp-pl.is-out = -1
          temp-pl.pl-code = if b-doc-pl.pl-code <> ?
                                then b-doc-pl.pl-code
                                else -1
          temp-pl.doc-qnty = b-doc-pl.doc-qnty
          temp-pl.fact-qnty = b-doc-pl.fact-qnty - (if available brw-doc-pl
                                                    then brw-doc-pl.fact-qnty
                                                    else 0)
                                                    /*вычтем списание ЦЕЛИКОМ - его компенсировать НЕЛЬЗЯ*/
          .
        end.
        for each buf_doc-pl NO-LOCK WHERE
                 buf_doc-pl.gds-code = b-goods.gds-code AND
                 buf_doc-pl.out-code = buf_trn-doc.doc-code:
                 saled-by-place-r = saled-by-place-r + buf_doc-pl.fact-qnty.
          create
          temp-pl.
          assign
          temp-pl.is-out = 1
          temp-pl.pl-code = if buf_doc-pl.pl-code <> ?
                                then buf_doc-pl.pl-code
                                else -1
          temp-pl.doc-qnty = buf_doc-pl.doc-qnty
          temp-pl.fact-qnty = buf_doc-pl.fact-qnty
          .
        end.
        /*проверим можно ли компенсировать по складским местам*/
        for each b-temp-pl  WHERE
                 b-temp-pl.is-out = -1:
            find first temp-pl WHERE
                       temp-pl.pl-code = b-temp-pl.pl-code AND
                       temp-pl.is-out  = 1 No-ERROR.
            if not available temp-pl or
              (temp-pl.fact-qnty = temp-pl.doc-qnty AND b-temp-pl.fact-qnty = b-temp-pl.doc-qnty) then
            NEXT.
            assign
            res-places = MAXIMUM(b-temp-pl.fact-qnty - b-temp-pl.doc-qnty , temp-pl.fact-qnty - temp-pl.doc-qnty)
            res-places = if b-temp-pl.fact-qnty < res-places then b-temp-pl.fact-qnty else res-places
            res-places = if temp-pl.fact-qnty < res-places then temp-pl.fact-qnty else res-places
            /*сколько резервов надо снять с возврата*/
            unresv = res-places - (b-temp-pl.fact-qnty - b-temp-pl.doc-qnty)
            /*сколько резервов надо снять с расхода*/
            unresr = res-places - (temp-pl.fact-qnty - temp-pl.doc-qnty)
            b-temp-pl.new-fact-qnty = b-temp-pl.fact-qnty - res-places
            temp-pl.new-fact-qnty = temp-pl.fact-qnty - res-places
            cvpl = cvpl + res-places
            .
            FIND FIRST b-gds-dtl where
                        b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
                      b-gds-dtl.artic = b-doc-line.artic AND
                      b-gds-dtl.prod-type = b-doc-line.prod-type AND
                      b-gds-dtl.prod-code = b-doc-line.prod-code AND
                      b-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
            FIND FIRST br-gds-dtl where
                        br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                        br-gds-dtl.artic = br-doc-line.artic AND
                        br-gds-dtl.prod-type = br-doc-line.prod-type AND
                        br-gds-dtl.prod-code = br-doc-line.prod-code AND
                        br-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
            if unresv > 0 or unresr > 0 then do:
                /*сначала надо сравнить цены и скидки*/
                if (v-curr-r-b = {&r-b-base} and  (br-gds-dtl.price-base <> b-gds-dtl.price-base))
                OR (v-curr-r-b = {&r-b-rubl} and  (br-gds-dtl.price-rubl <> b-gds-dtl.price-rubl))
                then NEXT _docline.
                if
                b-gds-dtl.fact-qnty - cvpl = 0 AND
                br-gds-dtl.fact-qnty - cvpl = 0 AND
                ((v-curr-r-b = {&r-b-base} and  b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
                 OR
                 (v-curr-r-b = {&r-b-rubl} and  b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
                )
                 then do:
                /*если предполагается компенсировать ВСЕ кол-ва по расх и возврату а скидки не равны,
                то возникнет висяк! - попытаемся уменьшить компенсируемое количество!
                тогда можно будет поменять скидку на расходе*/
                    if cvpl > 1 then
                    assign
                    cvpl = cvpl - 1
                    unresv = unresv - 1
                    unresr = unresr - 1
                    b-temp-pl.new-fact-qnty = b-temp-pl.new-fact-qnty + 1
                    temp-pl.new-fact-qnty = temp-pl.new-fact-qnty + 1
                    .
                    else NEXT _docline.
                end.
                assign
                rdoc-line = recid (b-doc-line)
                rgds-dtl = recid(b-gds-dtl)
                r-qnty = - unresv
                r-b-code = ?
                r-pl-code = if b-temp-pl.pl-code = - 1 then ? else b-temp-pl.pl-code
                r-or-v = {&TDEDT_vozvrat_vnesh_kass}
                r-office = {&gds-goods}
                from-menu = yes.
                if unresv > 0 then do:
                    run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input  p-is-tpsi-obj
                                    , input yes) no-error.
                    if error-status:error then do:
                      undo _docline, return error.
                    end.
                end.
            end.
            if unresr > 0 then do:
                assign
                rdoc-line = recid (br-doc-line)
                rgds-dtl = recid(br-gds-dtl)
                r-qnty = - unresr
                r-b-code = ?
                r-doc-prts-qnty = ?
                r-pl-code = if temp-pl.pl-code = - 1 then ? else temp-pl.pl-code
                r-or-v = {&TDEDT_ras_vnesh_kass}
                r-office = {&gds-goods}
                from-menu = yes.
                run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input p-is-tpsi-obj
                                    , input yes) no-error.

                if error-status:error then do:
                  undo _docline, return error.
                end.
            end.
        end.
        if cvpl <> 0 then do:
            /*непосредственная компенсация*/
            for each temp-pl,
                first ub.doc-pl where
                      ub.doc-pl.out-code = (if temp-pl.is-out = 1
                                            then br-gds-dtl.doc-code
                                            else b-gds-dtl.doc-code)
                  and ub.doc-pl.gds-code = b-goods.gds-code
                  and ub.doc-pl.pl-code = temp-pl.pl-code
             on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
             on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
             on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
             :
              assign
              ub.doc-pl.cli-fact-qnty = temp-pl.new-fact-qnty * ub.doc-pl.cli-fact-qnty / ub.doc-pl.fact-qnty
              ub.doc-pl.fact-qnty = temp-pl.new-fact-qnty
              .
            end.
            assign
            /*тов суммы до коменсанции*/
            tsall = (if v-curr-r-b = {&r-b-base}
                      then (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                            b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base))
                       else (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                            b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl))
                     )
            b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cvpl
            br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cvpl
            br-doc-line.fact-qnty = br-doc-line.fact-qnty - cvpl
            b-doc-line.fact-qnty = b-doc-line.fact-qnty - cvpl
            qnty-compense = qnty-compense + cvpl
            qnty-compense-abs = qnty-compense-abs + abs(cvpl)
            no-error .
            if (v-curr-r-b = {&r-b-base} and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
            OR (v-curr-r-b = {&r-b-rubl} and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
            then do:


            /*если скидки у расхода/возврата не равны то пересчитаем их*/
            if v-curr-r-b = {&r-b-base}
            then do:
             assign
             br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                       then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                                 tsall )  / br-gds-dtl.fact-qnty
                                            )
                                       else br-gds-dtl.discnt-base
                                       )
             b-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                      then (b-gds-dtl.price-base -  ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                                             tsall ) / b-gds-dtl.fact-qnty
                                           )
                                      else b-gds-dtl.discnt-base
                                      )
             br-gds-dtl.discnt-rubl = br-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
             b-gds-dtl.discnt-rubl = b-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
             .
            end.
            else do:
              assign
              br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                       then (br-gds-dtl.price-rubl -
                                                                    ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                                    tsall )  / br-gds-dtl.fact-qnty
                                            )
                                       else br-gds-dtl.discnt-rubl
                                       )
             b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                      then (b-gds-dtl.price-rubl -
                                                                  ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                                    tsall ) / b-gds-dtl.fact-qnty
                                            )
                                      else b-gds-dtl.discnt-rubl
                                      )
              br-gds-dtl.discnt-base = br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
              b-gds-dtl.discnt-base = b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
            end.
          end.
          release b-gds-dtl.
          release br-gds-dtl.
        end.
    end.
/*потом компенсируем по партиям*/

    if NOT cashplace AND can-find(first ub.doc-prts No-LOCK WHERE
                                        ub.doc-prts.gds-code = b-goods.gds-code AND
                                        ub.doc-prts.out-code = buf_ret-doc.doc-code) then do:
        FIND FIRST buf_gds-prt NO-LOCK WHERE
                 buf_gds-prt.upper-code = b-goods.prt-root NO-ERROR.
        assign
        cashparts = yes
        cvp = 0
        .
        /*проверим можно ли компенсировать по партиям*/
        /*пишем во временную таблицу*/
        for each temp-prts:
          delete temp-prts.
        end.
        for each b-doc-prts NO-LOCK WHERE
                 b-doc-prts.gds-code = b-goods.gds-code AND
                 b-doc-prts.out-code = buf_ret-doc.doc-code:
                 saled-by-parts-v = saled-by-parts-v + b-doc-prts.fact-qnty.
          find first brw-doc-prts no-lock where
                    brw-doc-prts.gds-code = b-goods.gds-code
               AND  brw-doc-prts.out-code = v-return-write-off-code
               AND  brw-doc-prts.b-code = b-doc-prts.b-code no-error .
          if available brw-doc-prts then do:
            saled-by-parts-rw = saled-by-parts-rw + brw-doc-prts.fact-qnty.
          end.
          create
          temp-prts.
          assign
          temp-prts.is-out = -1
          temp-prts.b-code = if b-doc-prts.b-code <> ?
                                then b-doc-prts.b-code
                                else -1
          temp-prts.doc-qnty = b-doc-prts.doc-qnty
          temp-prts.fact-qnty = b-doc-prts.fact-qnty - (if available brw-doc-prts
                                                        then brw-doc-prts.fact-qnty
                                                        else 0)
          temp-prts.rc = string(recid(b-doc-prts))
          temp-prts.twounit = IF lookup({&twounit}, buf_units.type) > 0 AND
                                 lookup({&divisional}, buf_units.type) > 0 then yes
                                 else no
          .
        end.
        for each buf_doc-prts NO-LOCK WHERE
                 buf_doc-prts.gds-code = b-goods.gds-code AND
                 buf_doc-prts.out-code = buf_trn-doc.doc-code:
                 saled-by-parts-r = saled-by-parts-r + buf_doc-prts.fact-qnty.
          create
          temp-prts.
          assign
          temp-prts.is-out = 1
          temp-prts.b-code = if buf_doc-prts.b-code <> ?
                                then buf_doc-prts.b-code
                                else -1
          temp-prts.doc-qnty = buf_doc-prts.doc-qnty
          temp-prts.fact-qnty = buf_doc-prts.fact-qnty
          temp-prts.rc = string(recid(buf_doc-prts))
          temp-prts.twounit = IF lookup({&twounit}, buf_units.type) > 0 AND
                                 lookup({&divisional}, buf_units.type) > 0 then yes
                                 else no
          .
        end.

        FOR EACH b-temp-prts WHERE
                 b-temp-prts.is-out = -1 AND
                 b-temp-prts.compensed = no use-index qnty:
            if b-temp-prts.twounit then do:
              FOR EACH temp-prts WHERE
                       temp-prts.is-out = 1 AND
                       temp-prts.b-code = b-temp-prts.b-code AND
                       temp-prts.fact-qnty = b-temp-prts.fact-qnty AND
                       temp-prts.compensed = no use-index qnty:
                  IF (temp-prts.fact-qnty = temp-prts.doc-qnty AND b-temp-prts.fact-qnty = b-temp-prts.doc-qnty) then
                  NEXT.
                  LEAVE.
              END.
            end.
            ELSE do:
              find first temp-prts WHERE
                         temp-prts.b-code = b-temp-prts.b-code AND
                         temp-prts.is-out = 1 No-ERROR.
            END.
            if not available temp-prts or
              (temp-prts.fact-qnty = temp-prts.doc-qnty AND b-temp-prts.fact-qnty = b-temp-prts.doc-qnty) then
            NEXT.
            assign
            res-parts = MAXIMUM(b-temp-prts.fact-qnty - b-temp-prts.doc-qnty , temp-prts.fact-qnty - temp-prts.doc-qnty)
            res-parts = if b-temp-prts.fact-qnty < res-parts then b-temp-prts.fact-qnty else res-parts
            res-parts = if temp-prts.fact-qnty < res-parts then temp-prts.fact-qnty else res-parts
            /*сколько резервов надо снять с возврата*/
            unresv = res-parts - (b-temp-prts.fact-qnty - b-temp-prts.doc-qnty)
            /*сколько резервов надо снять с расхода*/
            unresr = res-parts - (temp-prts.fact-qnty - temp-prts.doc-qnty)
            b-temp-prts.new-fact-qnty = b-temp-prts.fact-qnty - res-parts
            temp-prts.new-fact-qnty = temp-prts.fact-qnty - res-parts
            cvp = cvp + res-parts
            .
            IF b-temp-prts.twounit and res-parts > 0 then DO:
               /*нужен особенный алгоритм*/
              assign
              temp-prts.compensed = yes
              .
            end.

            FIND FIRST b-gds-dtl where
                        b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
                        b-gds-dtl.artic = b-doc-line.artic AND
                        b-gds-dtl.prod-type = b-doc-line.prod-type AND
                        b-gds-dtl.prod-code = b-doc-line.prod-code AND
                        b-gds-dtl.prt-code = buf_gds-prt.node-code No-ERROR.
            FIND FIRST br-gds-dtl where
                        br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                        br-gds-dtl.artic = br-doc-line.artic AND
                        br-gds-dtl.prod-type = br-doc-line.prod-type AND
                        br-gds-dtl.prod-code = br-doc-line.prod-code AND
                        br-gds-dtl.prt-code = buf_gds-prt.node-code  No-ERROR.

            if unresv > 0 or unresr > 0 then do:
                if
                b-gds-dtl.fact-qnty - cvp = 0 AND
                br-gds-dtl.fact-qnty - cvp = 0 AND
                (
                (v-curr-r-b = {&r-b-base} and  b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
                OR
                (v-curr-r-b = {&r-b-rubl} and  b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
                )
                then do:
                /*если предполагается компенсировать ВСЕ кол-ва по расх и возврату а скидки не равны,
                то возникнет висяк! - попытаемся уменьшить компенсируемое количество!
                тогда можно будет поменять скидку на расходе*/
                    if cvp > 1 AND b-temp-prts.twounit <> yes then
                    assign
                    cvp = cvp - 1
                    unresv = unresv - 1
                    unresr = unresr - 1
                    b-temp-prts.new-fact-qnty = b-temp-prts.new-fact-qnty + 1
                    temp-prts.new-fact-qnty = temp-prts.new-fact-qnty + 1
                    .
                    else do:
                      temp-prts.compensed = no.
                      NEXT _docline.
                    end.
                end.
                assign
                rdoc-line = recid (b-doc-line)
                rgds-dtl = recid(b-gds-dtl)
                r-qnty = - unresv
                r-b-code = if b-temp-prts.b-code = - 1 then ? else b-temp-prts.b-code
                r-doc-prts-qnty = (if lookup({&twounit}, buf_units.type) > 0 AND
                                      lookup({&divisional}, buf_units.type) > 0
                                   then b-temp-prts.fact-qnty
                                   else ?
                                   )
                r-pl-code = ?
                r-or-v = {&TDEDT_vozvrat_vnesh_kass}
                r-office = {&gds-goods}
                from-menu = yes.
                if unresv > 0 then do:
                    run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input p-is-tpsi-obj
                                    , input yes) no-error.
                    if error-status:error then do:
                      undo _docline, return error.
                    end.
                end.
            end.
            if unresr > 0 then do:
                assign
                rdoc-line = recid (br-doc-line)
                rgds-dtl = recid(br-gds-dtl)
                r-qnty = - unresr
                r-b-code = if temp-prts.b-code = - 1 then ? else temp-prts.b-code
                r-doc-prts-qnty = (if lookup({&twounit}, buf_units.type) > 0 AND
                                      lookup({&divisional}, buf_units.type) > 0
                                   then temp-prts.fact-qnty
                                   else ?
                                   )
                r-pl-code = ?
                r-or-v = {&TDEDT_ras_vnesh_kass}
                r-office = {&gds-goods}
                from-menu = yes.
                run b-unres-proc in this-procedure (
                                      buffer buf_inkas
                                    , buffer buf_trn-doc
                                    , buffer buf_ret-doc
                                    , input p-is-tpsi-obj
                                    , input yes) no-error.
                if error-status:error then do:
                  undo _docline, return error.
                end.
            end.
        end. /*for each b-doc-prts*/
        if cvp = 0 then NEXT _docline.
        /*непосредственная компенсация*/
        for each temp-prts,
            first ub.doc-prts where
                  recid(ub.doc-prts) = integer(temp-prts.rc)
        on error  undo _docline, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _docline, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _docline, return error substitute( "&1. endkey", vss-workfile )
        :

          assign
          ub.doc-prts.fact-qnty = temp-prts.new-fact-qnty
          .
        end.
        assign
        /*тов суммы до коменсанции*/
        tsall =  if v-curr-r-b = {&r-b-base}
                 then  (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base)
                       )
                 else   (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                        b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl)
                       )
        b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cvp
        br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cvp
        br-doc-line.fact-qnty = br-doc-line.fact-qnty - cvp
        b-doc-line.fact-qnty = b-doc-line.fact-qnty - cvp
        qnty-compense = qnty-compense + cvp
        qnty-compense-abs = qnty-compense-abs + abs(cvp)
        no-error .
        if (v-curr-r-b = {&r-b-base} and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
        OR (v-curr-r-b = {&r-b-rubl} and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
        then do:
        /*если скидки у расхода/возврата не равны то пересчитаем их*/
          if v-curr-r-b = {&r-b-base} then do:
            assign
            br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                      then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                   tsall )  / br-gds-dtl.fact-qnty )
                                      else br-gds-dtl.discnt-base )
            b-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                      then (b-gds-dtl.price-base - ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                                                                   tsall ) / b-gds-dtl.fact-qnty  )
                                      else b-gds-dtl.discnt-base )
            br-gds-dtl.discnt-rubl =  br-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
            b-gds-dtl.discnt-rubl =   b-gds-dtl.discnt-BASE * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
            .
          end.
          else do:
            assign
            br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                      then (br-gds-dtl.price-rubl -
                                                                  ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                                 tsall )  / br-gds-dtl.fact-qnty
                                                                   )
                                     else br-gds-dtl.discnt-rubl
                                     )
            b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                     then (b-gds-dtl.price-rubl -
                                                               ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                             tsall ) / b-gds-dtl.fact-qnty
                                           )
                                    else b-gds-dtl.discnt-rubl
                                    )
            br-gds-dtl.discnt-base =  br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            b-gds-dtl.discnt-base =   b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            .
          end.
      end.
      release b-gds-dtl.
      release br-gds-dtl.
    end.
    /*компенсировать не по партия и складским местам модно только то количество
    которое продано не по партиям и складским местам  и не по двум ед измерения*/
    IF lookup({&twounit}, buf_units.type) = 0 then do:
      for each b-gds-dtl where
               b-gds-dtl.doc-code = buf_ret-doc.doc-code AND
               b-gds-dtl.artic = b-doc-line.artic AND
               b-gds-dtl.prod-type = b-doc-line.prod-type AND
               b-gds-dtl.prod-code = b-doc-line.prod-code:
          find first br-gds-dtl where
                     br-gds-dtl.doc-code = buf_trn-doc.doc-code AND
                     br-gds-dtl.artic = b-gds-dtl.artic AND
                     br-gds-dtl.prod-type = b-gds-dtl.prod-type AND
                     br-gds-dtl.prod-code = b-gds-dtl.prod-code AND
                     br-gds-dtl.prt-code = b-gds-dtl.prt-code NO-ERROR.
          find first brw-gds-dtl where
                     brw-gds-dtl.doc-code = v-return-write-off-code AND
                     brw-gds-dtl.artic = b-gds-dtl.artic AND
                     brw-gds-dtl.prod-type = b-gds-dtl.prod-type AND
                     brw-gds-dtl.prod-code = b-gds-dtl.prod-code AND
                     brw-gds-dtl.prt-code = b-gds-dtl.prt-code NO-ERROR.
  
          IF AVAILABLE br-gds-dtl then do:
              /*если все зарезервировалось то компенсировать не будем*/
              if b-gds-dtl.doc-qnty = b-gds-dtl.fact-qnty AND br-gds-dtl.doc-qnty = br-gds-dtl.fact-qnty then NEXT _docline.
              /*компенсируем*/
              /*сначала надо сравнить цены и скидки*/
              if (v-curr-r-b = {&r-b-base} and br-gds-dtl.price-base <> b-gds-dtl.price-base)
              OR (v-curr-r-b = {&r-b-rubl} and br-gds-dtl.price-rubl <> b-gds-dtl.price-rubl)
              then NEXT _docline.
              /*сколько на возврате можно скомпенсировать ?*/
              assign
              cv = MAXIMUM(b-gds-dtl.fact-qnty - b-gds-dtl.doc-qnty - (if available brw-gds-dtl then brw-gds-dtl.fact-qnty else 0)
                         , br-gds-dtl.fact-qnty - br-gds-dtl.doc-qnty)
              cv = if b-gds-dtl.fact-qnty < cv then b-gds-dtl.fact-qnty else cv
              cv = if (br-gds-dtl.fact-qnty  - (if available brw-gds-dtl then brw-gds-dtl.fact-qnty else 0)) < cv
                   then br-gds-dtl.fact-qnty
                   else cv
              /*компенсация по gds-dtl не должна затронуть часть проданную по партиям и сладским местам*/
              cv = MINIMUM(cv, old-doc-line-fact-qnty-r - (saled-by-place-r + saled-by-parts-r))
              cv = MINIMUM(cv, old-doc-line-fact-qnty-v - (saled-by-place-v + saled-by-parts-v) -
                               (old-doc-line-fact-qnty-rw - (saled-by-place-rw + saled-by-parts-rw))
                           )
              /*сколько резервов надо снять с возврата*/
              unresv = cv - (b-gds-dtl.fact-qnty - b-gds-dtl.doc-qnty)
              /*сколько резервов надо снять с расхода*/
              unresr = cv - (br-gds-dtl.fact-qnty - br-gds-dtl.doc-qnty)
              .
              if
              b-gds-dtl.fact-qnty - cv = 0 AND
              br-gds-dtl.fact-qnty - cv = 0 AND
              ((v-curr-r-b = {&r-b-base} and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
              OR
               (v-curr-r-b = {&r-b-rubl} and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
              )
               then do:
              /*если предполагается компенсировать ВСЕ кол-ва по расх и возврату а скидки не равны,
              то возникнет висяк! - попытаемся уменьшить компенсируемое количество!
              тогда можно будет поменять скидку на расходе*/
                  if cv > 1 then
                  assign
                  cv = cv - 1
                  unresv = unresv - 1
                  unresr = unresr - 1
                  .
                  else NEXT _docline.
              end.
              if unresv > 0 then do:
                  assign
                  rdoc-line = recid (b-doc-line)
                  rgds-dtl = recid(b-gds-dtl)
                  r-qnty =  - unresv
                  r-b-code = ?
                  r-doc-prts-qnty = ?
                  r-or-v = {&TDEDT_vozvrat_vnesh_kass}
                  r-office = {&gds-goods}
                  from-menu = yes.
                  run b-unres-proc in this-procedure (
                                        buffer buf_inkas
                                      , buffer buf_trn-doc
                                      , buffer buf_ret-doc
                                      , input p-is-tpsi-obj
                                      , input yes) no-error.
                  if error-status:error then do:
                    undo _docline, return error.
                  end.
              end. /*if unresv > 0 */
              if unresr > 0 then do:
                  assign
                  rdoc-line = recid (br-doc-line)
                  rgds-dtl = recid(br-gds-dtl)
                  r-qnty =  - unresr
                  r-b-code = ?
                  r-doc-prts-qnty = ?
                  r-or-v = {&TDEDT_ras_vnesh_kass}
                  r-office = {&gds-goods}
                  from-menu = yes.
                  run b-unres-proc in this-procedure (
                                        buffer buf_inkas
                                      , buffer buf_trn-doc
                                      , buffer buf_ret-doc
                                      , input p-is-tpsi-obj
                                      , input yes) no-error.
                  if error-status:error then do:
                    undo _docline, return error.
                  end.
              end. /*if unresv > 0 */
              /*непосредственная компенсация*/
              assign
              /*тов суммы до коменсанции*/
              tsall = (if v-curr-r-b = {&r-b-base}
                       then (br-gds-dtl.fact-qnty * (br-gds-dtl.price-base - br-gds-dtl.discnt-base) -
                             b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base))
                       else (br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                             b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl))
                       )
              b-gds-dtl.fact-qnty = b-gds-dtl.fact-qnty - cv
              br-gds-dtl.fact-qnty = br-gds-dtl.fact-qnty - cv
              br-doc-line.fact-qnty = br-doc-line.fact-qnty - cv
              b-doc-line.fact-qnty = b-doc-line.fact-qnty - cv
              qnty-compense = qnty-compense + cv
              qnty-compense-abs = qnty-compense-abs + abs(cv)
              .
  
              if (v-curr-r-b = {&r-b-base} and b-gds-dtl.discnt-base <> br-gds-dtl.discnt-base)
              OR (v-curr-r-b = {&r-b-rubl} and b-gds-dtl.discnt-rubl <> br-gds-dtl.discnt-rubl)
                then do:
              /*если скидки у расхода/возврата не равны то пересчитаем их*/
  
  
              if v-curr-r-b = {&r-b-base} then do:
                assign
                br-gds-dtl.discnt-base = (if br-gds-dtl.fact-qnty <> 0
                                          then (br-gds-dtl.price-base - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-base - b-gds-dtl.discnt-base) +
                                                                         tsall )  / br-gds-dtl.fact-qnty )
                                          else br-gds-dtl.discnt-base )
                br-gds-dtl.discnt-rubl = br-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale )
                b-gds-dtl.discnt-rubl =  b-gds-dtl.discnt-base * (buf_trn-doc.base-rate / buf_trn-doc.base-scale)
                .
              end.
              else do:
                assign
                br-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty <> 0
                                          then (br-gds-dtl.price-rubl - ( b-gds-dtl.fact-qnty * (b-gds-dtl.price-rubl - b-gds-dtl.discnt-rubl) +
                                                                        tsall )  / br-gds-dtl.fact-qnty )
                                          else br-gds-dtl.discnt-rubl )
                b-gds-dtl.discnt-rubl = (if br-gds-dtl.fact-qnty = 0 and b-gds-dtl.fact-qnty <> 0
                                         then (b-gds-dtl.price-rubl -  ( br-gds-dtl.fact-qnty * (br-gds-dtl.price-rubl - br-gds-dtl.discnt-rubl) -
                                                                        tsall ) / b-gds-dtl.fact-qnty )
                                        else b-gds-dtl.discnt-rubl)
                br-gds-dtl.discnt-base = br-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
                b-gds-dtl.discnt-base =  b-gds-dtl.discnt-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
                .
              end.
            end.
          end.  /*if available br-gds-dtl*/
      end. /*for each b-gds-dtl*/
    end. /*    IF lookup('{&twounit}, buf_units.type) = 0 then*/
    if is-gas(b-goods.gds-code) then v-gas-compensed = true .
end. /*for each b-doc-line*/
FIND FIRST b-doc where b-doc.doc-code = buf_trn-doc.doc-code No-ERROR.
assign
b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense.
FIND FIRST b-doc where b-doc.doc-code = buf_ret-doc.doc-code No-ERROR.
if available b-doc then do:
  assign
  b-doc.fact-qnty = b-doc.fact-qnty - qnty-compense
  .
end.
if qnty-compense-abs <> 0 then
note-compense = chr(10) + "Проведено компенсирование расхода/возврата".
run waitfram-hide in this-procedure .
if p-auto = 0 then do:
  run UI-on in p-parent-handle.
  run ui-2 in p-parent-handle.
end.
END PROCEDURE. /*compense*/

PROCEDURE INKAS-CLOSING:
define input parameter p-back-date as logical no-undo .
define input parameter p-is-inquiry as logical no-undo .
define parameter buffer locked_inkas for ub.inkas.
define variable for-netto as  decimal no-undo.
define variable for-write-off as  decimal no-undo.
define variable ps-where-rus as character no-undo .
define variable v-rec-id as recid no-undo .
/*кол-во строк чеков в продаже-возврате*/
define variable line-out as integer no-undo.
define variable line-ret as integer no-undo.
/*кол-во строк gds-dtl в продаже-возврате*/
define variable dtl-out as integer no-undo.
define variable dtl-ret as integer no-undo.
define variable gds-amount  as integer .
define variable chk-amount  as integer .
define variable nf-gds-amount  as integer .
define variable nf-chk-amount  as integer .
define variable varminus-parts as logical   no-undo .
define variable varminus-parts-type as character no-undo .
define variable v-sale-sum as decimal no-undo .
define variable v-discnt-sum as decimal no-undo .
define variable v-curr-tot-dtl  as integer no-undo .
define variable v-curr-tot-lines as integer no-undo .
define variable v-ps-label as character no-undo .
define variable v-note-compense as character no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-dont-touch as logical no-undo .
define variable v-doc-ii as integer no-undo .
define variable v-chr-office-ii as integer no-undo .
define variable v-docs-sum as character no-undo .
define variable current-netto as decimal no-undo .
define variable current-write-off as decimal no-undo .
define variable varchip-code as integer   no-undo .
define variable varchip-code2 as integer   no-undo .
define variable v-gds-amount as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-attr-value as character no-undo .
define variable v-type as character no-undo .
define variable v-run-tpsi-line as logical no-undo .

define variable v-is-petrol as logical   no-undo .
define variable v-is-pieces as logical   no-undo .
define variable chk-prs  as   logical no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as date no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-tth as handle no-undo .


define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.
define buffer buf_sale-doc for ub.sale-doc.
define buffer locked_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer upd_doc-line for ub.doc-line.
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer buf-in for ub.trn-doc.
define buffer buf_chk-doc for ub.chk-doc .
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_doc-fbr-gds for ub.doc-fbr-gds .


_main:
DO ON ERROR undo _main, return error:
    run get-inkas-ps in this-procedure (
                                        buffer locked_inkas
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output ps-where-rus
                                      ).
  run adm/shattri.p (
      input "get":U
      ,input ''
      ,input 0
      ,input {&attr-nakl-glob}
      ,input {&attr-nakl-glob_chk-prs} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output chk-prs
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  delete object v-tth no-error.
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = locked_inkas.inkas-code
       and buf_sale-doc.order > 0
  by buf_sale-doc.order
  :
&scop sale-doc-kind buf_sale-doc.doc-kind
  &scop my-message substitute("Считаем итоги по док-ту &1 (&2 &3) ...", buf_sale-doc.doc-code, ~{&sale-doc-name~}, buf_sale-doc.chr-office)
  {&display-message}.
    find first locked_trn-doc where
              locked_trn-doc.doc-code = buf_sale-doc.doc-code.
    if chk-prs = yes then do:
      find first buf_clients where buf_clients.obj-type = {&prs}          and
                                  buf_clients.obj-code = locked_trn-doc.boss no-lock no-error.
      if not available buf_clients then do:
        undo _main, return error substitute("Не указан или неправильный менеджер в &1", locked_trn-doc.doc-code).
      end.
      find first buf_clients where buf_clients.obj-type = {&prs}          and
                                  buf_clients.obj-code = locked_trn-doc.agnt no-lock no-error.
      if not available buf_clients then do:
          undo _main, return error substitute("Не указан или неправильный исполнитель в &1", locked_trn-doc.doc-code).
      end.
    end.

    run gbl/calc-trn.p ( input parparentproc, input recid(locked_trn-doc)).
&scop sale-doc-kind buf_sale-doc.doc-kind
    if buf_sale-doc.doc-kind = {&sale-add-tech-refuell} or buf_sale-doc.doc-kind = {&sale-add-vir-res} 
        or buf_sale-doc.doc-kind = 'none' or (/*not p-is-catering and*/ buf_sale-doc.doc-kind = {&sale-add-write-off}) then do:
    end.
    else do:
      if buf_sale-doc.in-inkas then
      assign
      current-netto = if v-curr-r-b = {&r-b-rubl}
                  then locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl
                  else locked_trn-doc.tot-fact - locked_trn-doc.tot-calc
      for-netto = for-netto + current-netto * buf_sale-doc.dir
      v-docs-sum = v-docs-sum + (if v-docs-sum = '':U then '':U else {&new-line}) +
                            substitute("&1 = &2"
                              , {&sale-doc-name}
                              , current-netto
                            ).
            .
      if buf_sale-doc.doc-type = {&write-off} then do:
      assign
      current-write-off = if v-curr-r-b = {&r-b-rubl}
                  then locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl
                  else locked_trn-doc.tot-fact - locked_trn-doc.tot-calc
      for-write-off = for-write-off + current-write-off
      v-docs-sum = v-docs-sum + (if v-docs-sum = '':U then '':U else {&new-line}) +
                            substitute("&1 = &2"
                              , {&sale-doc-name}
                              , current-write-off
                            ).
    end.
    end.
  end. /*ОСНОВНЫЕ ДОКУМЕНТЫ ПОСЧИТАЛИ*/

  if abs(locked_inkas.netto - (for-netto  - (locked_inkas.sub-discnt - for-write-off))) > 0.015
  then do:
    undo _main, return error substitute("Невозможно закрыть продажу&1" +
                            "Несовпадение суммы нетто по продаже и накладным &2&1" +
                            "Сумма выручки по продаже - &3&1" +
                            "Сумма списания - &4&1" +
                           "Суммы по накладным (с учетом направления движения товара) - &5:&1&6"
                          , {&new-line}
                          , abs(locked_inkas.netto - (for-netto - (locked_inkas.sub-discnt - for-write-off)))
                          , locked_inkas.netto
                          , locked_inkas.sub-discnt
                          , (for-netto  - (locked_inkas.sub-discnt - for-write-off))
                          , v-docs-sum
                          ).
  end.

  run cur-time in this-procedure ( output v-today, output v-time).
  locked_inkas.PS = ''.
  _v-doc-ii:
    do v-doc-ii = 1 to num-entries({&sale-all-doc-kinds})
    on error undo _main, return error:
      do v-chr-office-ii = 1 to 2
      on error undo _main, return error:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = locked_inkas.inkas-code
            and  buf_sale-doc.order = v-doc-ii * 100  + (if v-chr-office-ii = 1 then 0 else 5) no-error .
        if available buf_sale-doc  then do:
          find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
          if not (buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass}
                 and
                 buf_sale-doc.chr-office = {&gds-goods}
                 )
          then do:
            if (if v-curr-r-b = {&r-b-base}
              then locked_trn-doc.tot-fact
              else  locked_trn-doc.tot-sale) = 0
            and not can-find(first ub.doc-line no-lock where ub.doc-line.doc-code = locked_trn-doc.doc-code) then do:
              /*убъем*/
              assign
              locked_trn-doc.status_ = {&wayb}.
              run str/del-doc.p (
                  input  parparentproc,
                  input  locked_trn-doc.doc-code,
                  input  g#db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  g#userid,
                  input  '0',
                  input  varchip-code,
                  output varchip-code2)
                  no-error.
              if error-status :error then do:
  &scop sale-doc-kind buf_sale-doc.doc-kind
                undo _main, return error  substitute("Ошибка при удалении ПУСТОГО документа &1 &2 &3 по продаже &4&5&6&5&7" +
                                        "Закрытие продажи невозможнo !"
                                        , {&sale-doc-name}
                                        , buf_sale-doc.chr-office
                                        , buf_sale-doc.doc-code
                                        , p-inkas-code
                                        ,{&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
              end.
              delete buf_sale-doc.
            end.
          end.
        end. /*if available buf_sale-doc*/
        if available buf_sale-doc  then do:
          find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
          if not (buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass}
                  and
                  buf_sale-doc.chr-office = {&gds-goods})
          then do:
            if (if v-curr-r-b = {&r-b-base}
              then locked_trn-doc.tot-fact
              else  locked_trn-doc.tot-sale) = 0
            and not can-find(first doc-line no-lock where doc-line.doc-code = locked_trn-doc.doc-code) then do:
              /*убъем*/
              assign
              locked_trn-doc.status_ = {&wayb}.

              run str/del-doc.p (
                  input  parparentproc,
                  input  locked_trn-doc.doc-code,
                  input  g#db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  g#userid,
                  input  '0',
                  input  varchip-code,
                  output varchip-code2)
                  no-error.
              if error-status :error then do:
  &scop sale-doc-kind buf_sale-doc.doc-kind
                undo _main, return error  substitute("Ошибка при удалении ПУСТОГО документа &1 &2 &3 по продаже &4&5&6&5&7" +
                                        "Закрытие продажи невозможнo !"
                                        , {&sale-doc-name}
                                        , buf_sale-doc.chr-office
                                        , buf_sale-doc.doc-code
                                        , p-inkas-code
                                        ,{&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
              end.
              delete buf_sale-doc.
            end.
          end.
        end. /*if available buf_sale-doc*/
        if not available buf_sale-doc then do:
      &Scop sale-doc-kind entry(v-doc-ii, {&sale-all-doc-kinds})
          assign
          v-curr-tot-dtl = 0
          v-curr-tot-lines = 0
          v-ps-label = {&sale-doc-name}
          v-sale-sum = 0
          v-discnt-sum = 0
          .
        end.
        else do:
          &scop sale-doc-kind buf_sale-doc.doc-kind
          for each buf_doc-line no-lock where
                  buf_Doc-line.doc-code = buf_sale-doc.doc-code
          on error undo _main, return error :
            find first goods no-lock where goods.artic = buf_doc-line.artic
                                       and goods.prod-type = buf_doc-line.prod-type
                                       and goods.prod-code = buf_doc-line.prod-code
                                       .
                                       
            RUN gds-attr-value (
                                INPUT goods.gds-code,
                                INPUT {&attr-mark-type},
                                OUTPUT v-attr-value,
                                OUTPUT v-type
                                ).
            if v-attr-value > ""
            and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(v-attr-value) 
            and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
            and (buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} or buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_Kass})
            then do:
              find first upd_doc-line exclusive-lock where rowid(upd_doc-line) = rowid(buf_doc-line) .
              FIND FIRST gds-prt NO-LOCK WHERE
                        gds-prt.upper-code = goods.prt-root NO-ERROR.
              if buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_Kass}
              then do :
                run RSRV-line in this-procedure (
                      input 1,
                      input no,
                      input no /*p-rsrv-prop-goods*/,
                      input no,
                      input no,
                      input "",
                      input no,
                      input no,
                      input yes, /*резерв*/
                      input goods.gds-code,
                      input (if available gds-prt then gds-prt.node-code else ?),
                      output v-run-tpsi-line,
                      buffer upd_doc-line,
                      buffer buf_trn-doc,
                      buffer buf_sale-doc
                      ) no-error.
              end .
              else do :
                run RSRV-line in this-procedure (
                      input -1,
                      input no,
                      input no /*p-rsrv-prop-goods*/,
                      input no,
                      input no,
                      input "",
                      input no,
                      input no,
                      input yes, /*резерв*/
                      input goods.gds-code,
                      input (if available gds-prt then gds-prt.node-code else ?),
                      output v-run-tpsi-line,
                      buffer upd_doc-line,
                      buffer buf_ret-doc,
                      buffer buf_sale-doc
                      ) no-error.
              end .
              if error-status:error
              then do :
                &scop my-message substitute("&1 (&2) Не все товары зарезервированы... &3 &4&5" ~
                                        , buf_sale-doc.doc-code                           ~
                                        , ~{&sale-doc-name~}                           ~
                                        , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                        )
                {&display-message}.
                undo _main, return error.
              end .  
              release upd_doc-line no-error .    
            end .
            else do :
            if buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass}
            then do :                           
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = buf_Doc-line.doc-code
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end. 
            if buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass}
            then do :                           
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(buf_Doc-line.doc-code, "=", "-")
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end.                                        
            if available buf_doc-fbr-gds
            then do :      
              if buf_doc-fbr-gds.fact-qnty >= 0
              then do :                                
                if buf_doc-line.doc-qnty <> buf_doc-fbr-gds.fact-qnty
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and  buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do:
                  &scop my-message substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end. 
                if buf_doc-line.doc-qnty <> 0
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} then do :
                  &scop my-message substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end.   
              end.
              else do :
                if buf_doc-line.doc-qnty <> abs(buf_doc-fbr-gds.fact-qnty)
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and  buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
                  &scop my-message substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end. 
                if buf_doc-line.doc-qnty <> 0
                and buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty
                and buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do :
                  &scop my-message substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end. 
              end. 
/*              else do :                                                                                                               */
/*                if buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty and  buf_sale-doc.doc-kind <> {&sale-add-return-write-off} then do:*/
/*                  &scop my-message substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5" ~                       */
/*                                          , buf_sale-doc.doc-code                           ~                                         */
/*                                          , ~{&sale-doc-name~}                           ~                                            */
/*                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~                      */
/*                                          )                                                                                           */
/*                  {&display-message}.                                                                                                 */
/*                  undo _main, return error.                                                                                           */
/*                end.                                                                                                                  */
/*              end.                                                                                                                    */
            end .
            else do :                                     
              if buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty and  buf_sale-doc.doc-kind <> {&sale-add-return-write-off} then do:
                &scop my-message substitute("&1 (&2) Не все товары зарезервированы... &3 &4&5" ~
                                        , buf_sale-doc.doc-code                           ~
                                        , ~{&sale-doc-name~}                           ~
                                        , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                        )
                {&display-message}.
                undo _main, return error.
              end.
            end.
            end .
          end.
          for each buf_gds-dtl no-lock where
                  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
          on error undo _main, return error :
            find first goods no-lock where goods.artic = buf_gds-dtl.artic
                                       and goods.prod-type = buf_gds-dtl.prod-type
                                       and goods.prod-code = buf_gds-dtl.prod-code
                                       .
            if buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass}
            then do :                           
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = buf_gds-dtl.doc-code
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end. 
            if buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass}
            then do :                           
              find first buf_doc-fbr-gds no-lock where buf_doc-fbr-gds.out-code = replace(buf_gds-dtl.doc-code, "=", "-")
                                                   and buf_doc-fbr-gds.gds-code = goods.gds-code
                                                   no-error.
            end.                                        
            if available buf_doc-fbr-gds
            then do :     
              if buf_doc-fbr-gds.fact-qnty >= 0
              then do :                               
                if buf_gds-dtl.doc-qnty <> buf_doc-fbr-gds.fact-qnty 
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do:
                  &scop my-message substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end.  
                if buf_gds-dtl.doc-qnty <> 0
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} then do :
                  &scop my-message substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end.
              end.
              else do :
                if buf_gds-dtl.doc-qnty <> abs(buf_doc-fbr-gds.fact-qnty)
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
                  &scop my-message substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end.  
                if buf_gds-dtl.doc-qnty <> 0
                and buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty
                and buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do :
                  &scop my-message substitute("&1 (&2) Возврат в производстве не резервируем! &3 &4&5" ~
                                          , buf_sale-doc.doc-code                           ~
                                          , ~{&sale-doc-name~}                           ~
                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~
                                          )
                  {&display-message}.
                  undo _main, return error.
                end.
              end.      
/*              else do :                                                                                                              */
/*                if buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty  and  buf_sale-doc.doc-kind <> {&sale-add-return-write-off} then do:*/
/*                  &scop my-message substitute("&1 (&2) Не все товары производства зарезервированы... &3 &4&5" ~                      */
/*                                          , buf_sale-doc.doc-code                           ~                                        */
/*                                          , ~{&sale-doc-name~}                           ~                                           */
/*                                          , buf_doc-line.artic, buf_doc-line.prod-type, buf_doc-line.prod-code ~                     */
/*                                          )                                                                                          */
/*                  {&display-message}.                                                                                                */
/*                undo _main, return error.                                                                                            */
/*              end.                                                                                                                   */
            end .
            else do :
              if buf_gds-dtl.doc-qnty <> buf_gds-dtl.fact-qnty  and  buf_sale-doc.doc-kind <> {&sale-add-return-write-off} then do:
                &scop my-message substitute("&1 (&2) Не все товары зарезервированы...  &3 &4&5" ~
                                        , buf_sale-doc.doc-code ~
                                        , ~{&sale-doc-name~} ~
                                        , buf_gds-dtl.artic, buf_gds-dtl.prod-type, buf_gds-dtl.prod-code ~
                                        )
                {&display-message}.
                undo _main, return error.
              end.
            end.
          end.
          &scop my-message substitute("Закрываем &1 (&2 &3) ...", buf_sale-doc.doc-code, ~{&sale-doc-name~}, buf_sale-doc.chr-office)
          {&display-message}.
          find first locked_trn-doc where locked_trn-doc.doc-code = buf_sale-doc.doc-code.
          if not v-dont-touch then
          assign
          v-exch-rate = locked_trn-doc.base-rate / locked_trn-doc.base-scale
          v-dont-touch = yes
          .
        end.
        if p-is-inquiry then do:
          NEXT _v-doc-ii.
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do:
          assign
          v-curr-tot-dtl = dtl-out
          v-curr-tot-lines = line-out
          v-ps-label = substitute("Продажа &1", buf_sale-doc.chr-office)
          v-note-compense = note-compense
          v-sale-sum = (if v-curr-r-b = {&r-b-base}
                        then locked_trn-doc.tot-fact
                        else  locked_trn-doc.tot-sale)
          v-discnt-sum = (if v-curr-r-b = {&r-b-base}
                          then locked_trn-doc.tot-calc
                          else locked_trn-doc.discnt-rubl)
          .
          if buf_sale-doc.chr-office = {&gds-goods} then do:
        &scop my-message "Преобразование товара на ответственном хранении в выкупной..."
        {&display-message}.
            run str/parts-pc.p (
                          input parparentproc
                          ,input buf_sale-doc.doc-code
                          ,integer({&responsible-storage-code})
                          ,integer({&repayment-code})
                          ,input {&fact}
                          ,input locked_inkas.fact-date
                          ,input v-time
                          ,input locked_inkas.shift-date
                          ,input locked_inkas.shift-num
                          ,input locked_inkas.shift-name

                          ) no-error .
            if error-status:error then do:
              undo _Main, return error  substitute("Невозможно закрыть продажу&1" +
                                    "не удается преобразовать товар на ответственном хранении в выкупной:&1&2 &3"
                                  ,  {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
            end.
            define buffer dop_trn-doc for ub.trn-doc.
            find first dop_trn-doc no-lock where
                      dop_trn-doc.out-code = locked_inkas.inkas-code
                  and dop_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code} no-error.
            if available dop_trn-doc then do:
              run saledoc-create  in this-procedure (
                                                      input locked_inkas.inkas-code
                                                      ,input locked_inkas.host-code
                                                      ,input locked_inkas.obj-type
                                                      ,input locked_inkas.obj-code
                                                      ,input {&TDEDT_Chg_Purch_Code} /* p-doc-kind*/
                                                      ,input no /*p-office*/
                                                      ,input no /*p-tpsidoc*/
                                                      ,input '':U /*p-alias-type-type*/
                                                      ,input '':U /*p-price-obj-type*/
                                                      ,input 0 /*p-price-obj-code*/
                                                      ,buffer dop_trn-doc ) no-error .
              if error-status:error then do:
                undo _main, return error substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 в таблицу связанных док-тов по продаже:&1&2 &3"
                                              , {&new-line}
                                              , error-status:get-message(1)
                                              , return-value
                                              , locked_inkas.inkas-code
                                              , {&TDEDT_Chg_Purch_Code}
                                              ).
              end.
            end.  /*if available dop_trn-doc then do:*/
          end. /*if buf_sale-doc.chr-office = {&gds-goods} then do:*/
        end. /*if buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh-kass} then do:*/
        if available buf_sale-doc
        and not (buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass}
                and
                buf_sale-doc.chr-office = {&gds-goods})
        then do:
          if (if v-curr-r-b = {&r-b-base}
            then locked_trn-doc.tot-fact
            else  locked_trn-doc.tot-sale) = 0
          and not can-find(first doc-line no-lock where doc-line.doc-code = locked_trn-doc.doc-code) then do:
            /*убъем*/
            assign
            locked_trn-doc.status_ = {&wayb}.

            run str/del-doc.p (
                input  parparentproc,
                input  locked_trn-doc.doc-code,
                input  g#db-num,
                input  "del-doc.err",
                input  ?,
                input  ?,
                input  g#userid,
                input  '0',
                input  varchip-code,
                output varchip-code2)
                no-error.
            if error-status :error then do:
  &scop sale-doc-kind buf_sale-doc.doc-kind
              undo _main, return error  substitute("Ошибка при удалении ПУСТОГО документа &1 &2 &3 по продаже &4&5&6&5&7" +
                                      "Закрытие продажи невозможнo !"
                                      , {&sale-doc-name}
                                      , buf_sale-doc.chr-office
                                      , buf_sale-doc.doc-code
                                      , p-inkas-code
                                      ,{&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
            end.
            delete buf_sale-doc.
          end.
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = {&TDEDT_vozvrat_vnesh_kass} then do:
          assign
          v-sale-sum = (if v-curr-r-b = {&r-b-base}
                        then locked_trn-doc.tot-fact
                        else  locked_trn-doc.tot-sale)
          v-discnt-sum = (if v-curr-r-b = {&r-b-base}
                          then locked_trn-doc.tot-calc
                          else locked_trn-doc.discnt-rubl)
          v-curr-tot-dtl = dtl-ret
          v-curr-tot-lines = line-ret
          v-ps-label = substitute("Возврат &1", buf_sale-doc.chr-office)
          v-note-compense = note-compense
          .
        end.
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = {&sale-add-return-write-off} then do:
          /*закроем возврат списание */
          /*сначала надо зарезервировать!!!!*/
          ASSIGN
          FROM-MENU = yes
          rdoc-line = ?
          rgds-dtl = ?
          r-or-v = {&sale-add-return-write-off}
          r-office = buf_sale-doc.chr-office
          r-qnty = ?
          r-b-code = ?
          r-pl-code = ?
          r-doc-prts-qnty = ?
          .
          run b-res-proc in this-procedure (
                                              buffer buf_Inkas
                                            , buffer buf_trn-doc
                                            , buffer buf_ret-doc
                                            , input yes
                                            , input auto-close
                                            , input yes
                                            , input rest-dish
                                            , input v-fbr-income-doc-code
                                            , input p-is-tpsi-obj
                                            , input rest-tpsi) no-error.
          if error-status:error or return-value = "error" then do:
            undo _main, return error  substitute("Ошибка при попытке резервирования в акте списания товаров, возвращенных по данной продажи&1" +
                                    "Закрытие продажи невозможнo !"
                                    ,{&new-line}).
          end.
  &scop sale-doc-kind buf_sale-doc.doc-kind
      &scop my-message substitute("Считаем итоги по док-ту &1 (&2 &3) ...", buf_sale-doc.doc-code, buf_sale-doc.chr-office, ~{&sale-doc-name~})
      {&display-message}.
          run gbl/calc-trn.p ( input parparentproc, input recid(locked_trn-doc)).
          assign
          v-ps-label = substitute("Списание по возврату &1", buf_sale-doc.chr-office)
          v-note-compense = '':U
          .
        end. /*if available buf_sale-doc and return-write-off*/
        if available buf_sale-doc then do:
            if buf_sale-doc.doc-kind = {&sale-add-tech-refuell} then do:
          assign
          v-ps-label = "Техпролив"
              v-note-compense = '':U.
            end.
            if buf_sale-doc.doc-kind = {&sale-add-vir-res} then do:
              assign
              v-ps-label = "Перемещение в виртуальный резервуар"
              v-note-compense = '':U.
            end.
        end. /*if available buf_sale-doc*/
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = {&sale-add-write-off} then do:
          assign
          v-ps-label = substitute("Списание &1", buf_sale-doc.chr-office)
          v-note-compense = '':U
          .
        end. /*if available buf_sale-doc and tech-refuell*/

        if available buf_sale-doc then  do:
          assign
          locked_trn-doc.discnt-pc =  ( if locked_trn-doc.print-rubl
                                        then ( locked_trn-doc.discnt-rubl * 100 / locked_trn-doc.tot-sale )
                                        else ( locked_trn-doc.tot-calc * 100 / locked_trn-doc.tot-fact ) ).
          assign
          locked_trn-doc.status_ = {&wayb}.
          assign
          locked_trn-doc.is-back-date = p-back-date
          locked_trn-doc.fact-date = locked_inkas.fact-date
          locked_trn-doc.shift-date = locked_inkas.shift-date
          locked_trn-doc.flag_ = yes
          locked_trn-doc.status_ = {&fact}
          locked_trn-doc.fact-time = v-time
          locked_trn-doc.PS = substitute("&1 &8 за &2 Количество: &3&4" +
                                          "Сумма &5 Скид. &6  Нетто &7&4"
                              ,(if locked_trn-doc.office
                                then "@УСЛУГИ."
                                else "@ТОВАРЫ.")
                              , string( locked_trn-doc.doc-date, "99/99/9999" )
                              , string( locked_trn-doc.fact-qnty , "->>,>>>,>>>,>>9.<<<" )
                              , {&new-line}
                              , string( if v-curr-r-b = {&r-b-rubl}
                                then locked_trn-doc.tot-sale
                                else locked_trn-doc.tot-fact, "->>,>>>,>>>,>>9.99" )
                              , string ( if v-curr-r-b = {&r-b-rubl}
                                then locked_trn-doc.discnt-rubl
                                else locked_trn-doc.tot-calc , "->>,>>>,>>>,>>9.99")
                              ,  string ( if v-curr-r-b = {&r-b-rubl}
                                          then  (locked_trn-doc.tot-sale - locked_trn-doc.discnt-rubl)
                                          else  (locked_trn-doc.tot-fact - locked_trn-doc.tot-calc), "->>,>>>,>>>,>>9.99" )
                              , v-ps-label
                              )
                              + substitute(" товаров &1  признаков &2&3&4"
                                          , buf_sale-doc.tot-lines
                                          , buf_sale-doc.tot-dtl
                                          , {&new-line}
                                          , v-note-compense)
          locked_trn-doc.creid = g#userid
          .
          assign
          locked_inkas.PS = locked_inkas.PS + (if not (buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_Kass}
                                                       and
                                                       buf_sale-doc.chr-office = {&gds-goods})
                                              then {&new-line}
                                              else '':U) +
                            if v-curr-r-b = {&r-b-base}
                            then  substitute( "&1 : сумма пр.цен &2; сумма скидок &3; товаров &4; признаков &5&6"
                                            , v-ps-label
                                            , v-sale-sum /*locked_trn-doc.tot-fact*/
                                            , v-discnt-sum /*locked_trn-doc.tot-calc*/
                                            , buf_sale-doc.tot-lines
                                            , buf_sale-doc.tot-dtl
                                            , {&new-line})
                            else  substitute("&1 : сумма пр.цен &2; сумма скидок &3; товаров &4; признаков &5&6"
                                              , v-ps-label
                                              , v-sale-sum /*locked_trn-doc.tot-sale*/
                                              , v-discnt-sum /*locked_trn-doc.discnt-rubl*/
                                              , buf_sale-doc.tot-lines
                                              , buf_sale-doc.tot-dtl) .

        end. /*if available buf_sale-doc*/
        if v-doc-ii = num-entries({&sale-all-doc-kinds})
        and v-chr-office-ii = 2
        then do:
          assign
          locked_inkas.PS = right-trim(locked_inkas.PS, {&new-line}) + {&new-line} +
                                (IF one-curs
                                then substitute(" чеки по курсу &1", v-exch-rate)
                                else "") +
                                note-compense  +
          (if auto-fbr then ({&new-line} + "Режим автомат.пр-ва.") else "":U) +
          (if rest-dish then ( {&space-char} + "С учетом остатков блюд на объекте РЕСТОРАН.") else "":U) +
          (if rest-ingr then ( {&space-char} + "С учетом остатков ингридиентов на объекте КУХНЯ.") else "":U) +
          (if p-is-tpsi-obj then ({&new-line} + "Режим автомат.резервир. чужих товаров.") else "":U) +
          (if rest-tpsi then ( {&space-char} + "С учетом остатков чужих товаров.") else "":U) +
          (if rest-tpsi then ( {&space-char} + "С учетом остатков чужих товаров.") else "":U) +
          (if neg-tpsi-weight then ( {&space-char} + "Уводить в отрицательные отстатки чужие весовые товары.") else "":U) +
          (if neg-tpsi-qnty > 0 then substitute(" Уводить в отрицательные отстатки чужие товары, если остатки < &1.", neg-tpsi-qnty) else "":U)  +
          (if neg-tpsi-oper then ( {&space-char} + "Уводить в отрицательные отстатки чужие товары с отметкой оператора.") else "":U)
          .
        end.
        if available buf_sale-doc then do:
          assign
          buf_sale-doc.status_ = locked_trn-doc.status_.
          { str/st-fo.i locked_trn-doc.doc-code no-error }
          if error-status:error then do:
            undo _main, return error return-value .
          end.
          assign
          v-rec-id = recid(locked_trn-doc).
          if buf_sale-doc.doc-kind = {&sale-add-write-off} 
          then do:
            _cpa:
            for each buf_cash-pay-attr where buf_cash-pay-attr.attr-code = "dop-doc" no-lock:
              if entry(1, buf_cash-pay-attr.attr-value, ',') = {&sale-add-write-off}
              then do:
                if entry(2, buf_cash-pay-attr.attr-value, ',') = locked_trn-doc.cli-type and integer (entry(3, buf_cash-pay-attr.attr-value, ',')) = locked_trn-doc.cli-code 
                then do:
                  { str/tdat-wrt.i                                    
                     locked_trn-doc.doc-code
                     {&trdcattr-techpass}
                     "yes" 
                  no-error}
                  leave _cpa.
                end.
              end.
            end.
          end.
          if v-is-ptrl = yes then do:
        &scop my-message "           Обработка топливных товаров..."
        {&display-message}.
            for each buf_doc-line
              where buf_doc-line.doc-code = locked_trn-doc.doc-code
            on error undo _main, return error
            :
              { str/is-petrl.i
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                v-is-petrol
                v-is-pieces
                no-error
              }
              if error-status :error then do:
                undo _main, return error return-value.
              end.
              if v-is-petrol = yes
                and v-is-pieces = no
              then do:
                define variable inv-rec as recid no-undo .
                assign
                inv-rec = ?
                .
                { str/corinvln.i
                  buf_doc-line.doc-code
                  buf_doc-line.artic
                  buf_doc-line.prod-type
                  buf_doc-line.prod-code
                  ?
                  ?
                  "buf_doc-line.price-rubl * buf_doc-line.fact-density"
                  "buf_doc-line.price-base * buf_doc-line.fact-density"
                  "buf_doc-line.fact-qnty  * buf_doc-line.fact-density"
                  buf_doc-line.fact-density
                  inv-rec
                  no-error
                }
                if error-status :error
                or inv-rec = ? then do:
                  undo _main, return error return-value.
                end.
              end.
            end.
          end. /* if v-is-ptrl */
          RELEASE locked_trn-doc no-error .
          if error-status:error then do:
               undo _main, return error return-value + error-status:get-message(1) .
          end.
          find first locked_trn-doc where recid(locked_trn-doc) = v-rec-id no-lock.
        end.
        
        if available buf_sale-doc
        and buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
            run adm/shattri.p (
                 input "get":U
                ,input locked_trn-doc.obj-type
                ,input locked_trn-doc.obj-code
                ,input {&attr-nakl_par}
                ,input  "minusprt"
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output varminus-parts
                ,output varminus-parts-type
                ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
               ) no-error .

          if error-status :error  then varminus-parts = false .
          if varminus-parts = yes then do:
      &scop my-message "           Автоматическая коррекция отрицательных партий..."
      {&display-message}.
            run str/deadprts.p ( locked_trn-doc.doc-code, parparentproc) no-error .
            if error-status:error then do:
              undo _main, return error return-value .
            end.
          end. /*if varminus-parts = "yes":u then do:*/
          
          if v-gas-cli-code > 0 then do:
            for each buf_doc-line exclusive-lock where buf_doc-line.doc-code  = replace(locked_trn-doc.doc-code, "-", "=") :
              find first buf_goods where buf_goods.prod-code = buf_doc-line.prod-code
                                     and buf_goods.prod-type = buf_doc-line.prod-type
                                     and buf_goods.artic = buf_doc-line.artic no-lock.
                                      
              /* Проверим, если газ */
              if is-gas(buf_goods.gds-code)
              and not v-gas-compensed
              then do:
                  run str/gas-autort.p (input parparentproc,
                                        input p-log-handle,
                                        input log-file-name,
                                        input p-auto,
                                        input p-inkas-code,
                                        input v-curr-r-b,
                                        input v-gas-cli-type,
                                        input v-gas-cli-code,
                                        output v-new_doc-code,
                                        output v-root-node,
                                        buffer locked_trn-doc,
                                        buffer buf_doc-line,
                                        buffer buf-new_trn-doc)
                                        no-error .
                                                   
              end.
            end.
          end.
        end.
        if available buf_sale-doc
        and (buf_sale-doc.doc-kind = {&sale-add-tech-refuell} or buf_sale-doc.doc-kind = {&sale-add-vir-res}) then do:
          &scop my-message substitute("Создание приходной накладной по Техпроливу в статусе &1...", {&wayb})
          {&display-message}.
          run str/techrfsl.p (input parparentproc
                        ,input p-log-handle
                        ,input log-file-name
                        ,input p-auto
                        ,input v-curr-r-b
                        ,input close-in-rfsl
                        ,input buf_sale-doc.doc-kind
                        ,buffer locked_trn-doc
                        ,buffer buf-in
                        ) no-error .
          if error-status:error then do:
            undo _Main, return error  substitute("Невозможно закрыть продажу&1" +
                                  "не удается создать приходную накладную по Техпроливу в статусе &2&1:&3&1&4"
                                , {&new-line}
                                , {&wayb}
                                , error-status:get-message(1)
                                , return-value
                                ).
          end.
          &scop my-message substitute("Создана приходная накладная по Техпроливу &1 в статусе &2...", buf-in.doc-code, {&wayb})
          {&display-message}.

        end. /*if available buf_sale-doc and tech-refuell*/
        if available locked_trn-doc and  locked_trn-doc.is-back-date and locked_trn-doc.ext-doc-type = {&TDEDT_ras_vnesh_kass}
        and available buf_sale-doc and buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do:
                run str/vtrecalc.p ( input parparentproc
                            , input recid (locked_trn-doc)
                            ) no-error .
          if error-status :error then do:
          end.
        end.

      end. /*do v-chr-office-ii = 1 to 2*/
    END. /*do v-doc-ii*/
    if p-is-inquiry then do:
      /*разобъем чеки*/
      run get-inkas-ps in this-procedure (
                                          buffer locked_inkas
                                        , output chk-amount
                                        , output gds-amount
                                        , output line-out
                                        , output dtl-out
                                        , output line-ret
                                        , output dtl-ret
                                        , output nf-chk-amount
                                        , output nf-gds-amount
                                        , output ps-where-rus
                                        ).
      for each buf_chk-doc  where
              buf_chk-doc.out-code = locked_inkas.inkas-code
      on error  undo _main, return error substitute( "Ошибка при разбивке чека по объектам ТПСИ&2&1&2&3", return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "stop при разбивке чека по объектам ТПСИ&2&1&2&3", return-value, {&new-line}, error-status :get-message (1))
      on endkey undo _main, return error substitute( "endkey при разбивке чека по объектам ТПСИ&2&1&2&3", return-value, {&new-line}, error-status :get-message (1)):
        RUN chksplin in this-procedure ( buffer buf_chk-doc
                                     , input 2 /*оставлять карту в новом чеке*/
                                     , output v-gds-amount) NO-ERROR.
        if error-status:error then do:
  &scop my-message substitute("Ошибка при разбивке чека &1 по объектам:&2" +  ~
                            "&3&2&4&3"                                           ~
                            , buf_chk-doc.doc-code                               ~
                            , ~{&new-line~}                                      ~
                            , error-status:get-message(1)                        ~
                            , return-value )

      {&display-message}.
          UNDO _main,  return "error".
        end.
      if lookup(string(buf_chk-doc.chk-type), {&no-docum-receipt-codes}) = 0
      then
      assign
      chk-amount    = chk-amount    - 1
      gds-amount    = gds-amount    - v-gds-amount
      nf-chk-amount = nf-chk-amount + 1
      nf-gds-amount = nf-gds-amount + v-gds-amount
      .
    end. /*for each buf_chk-doc no-lock where*/
    FOR EACH buf_inkas-pay WHERE
            buf_inkas-pay.inkas-code = locked_inkas.inkas-code
    on error  undo _main, return error substitute( "Ошибка при удалении записи выручки&2&1&2&3", return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "stop при удалении записи выручки&2&1&2&3", return-value, {&new-line}, error-status :get-message (1))
    on endkey undo _main, return error substitute( "endkey при удалении записи выручки&2&1&2&3", return-value, {&new-line}, error-status :get-message (1)):
        delete buf_inkas-pay.
    END .
    FOR EACH buf_inkas-pay-desk WHERE
            buf_inkas-pay-desk.inkas-code = locked_inkas.inkas-code
    on error  undo _main, return error substitute( "Ошибка при удалении записи выручки по кассе&2&1&2&3", return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "stop при удалении записи выручки по кассе&2&1&2&3", return-value, {&new-line}, error-status :get-message (1))
    on endkey undo _main, return error substitute( "endkey при удалении записи выручки по кассе&2&1&2&3", return-value, {&new-line}, error-status :get-message (1)):
      delete buf_inkas-pay-desk.
    END .
    assign
    locked_inkas.PS = set-inkas-ps(input locked_inkas.ps
                          , input chk-amount
                          , input gds-amount
                          , input line-out
                          , input dtl-out
                          , input line-ret
                          , input dtl-ret
                          , input nf-chk-amount
                          , input nf-gds-amount
                          , input ps-where-rus
                          ).
    assign
    locked_inkas.tot-doc = 0
    locked_inkas.netto  = 0
    locked_inkas.discnt = 0
    locked_inkas.sub-discnt = 0
    locked_inkas.qnty = 0
    .
    assign
    locked_inkas.status_ = {&inquiry}
    .
  end. /*v-is-inquiry*/
  else do:
    assign
    locked_inkas.status_ = {&fact} .
      if v-close-day-period then do:
        &scop my-message substitute("Согласно настройкам закрытие продажи ведет к закрытию периода до даты &1...", (locked_inkas.doc-date + 1))
        {&display-message}.
        run thbjattr_write in this-procedure (
                                                input locked_trn-doc.obj-type
                                                ,input locked_trn-doc.obj-code
                                                ,input {&attr-nakl_par}
                                                ,input {&attr-nakl_par_date-close-period}
                                                ,input '' /*p-value-character */
                                                ,input (locked_inkas.doc-date + 1)
                                                ,input 0.0 /*p-value-decimal   */
                                                ,input 0 /*p-value-integer   */
                                                ,input no /*p-value-logical   */
                                              ) .
      end.
  end.
END. /*DO ON ERROR*/
run waitfram-hide in this-procedure .
END PROCEDURE. /*inkas-closing*/