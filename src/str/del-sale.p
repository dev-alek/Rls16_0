block-level on error undo, throw.
/*

$Revision: 18022dc3b171, 1949, rls $
$Author: SSlivenko $
$Date: Fri Jul 26 11:38:58 2019 +0300 $
$Workfile: del-sale.p $
$Archive: str/del-sale.p $

Безусловное/условное удаление незакрытой продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/05
Author: Bakhtadze Natalya
Creation date: 10/03/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
/*p-parameter включает в себ
*/

define variable p-auto as integer no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
DEFINE variable forced as logical NO-UNDO.
/*force = yes безусловное удаление - с принудительным снятием резервов*/
define variable p-inkas-code like ub.inkas.inkas-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: 18022dc3b171, 1949, rls $":u .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":u .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:38:58 2019 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: del-sale.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/del-sale.p $":u .
define variable vss-description as character no-undo init "Безусловное/условное удаление незакрытой продажи" .
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/gds-attr.i }
{ str/salersrv.i def }
{ str/trdcalib.i }
/*определение локальной таблицы для ТПСИ док*/
{ str/lib-def.i }
{ gbl/clntattr.i }
{ str/tpsidoc.i " " proc }
{ gbl/cur-time.i }

define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-input-error as logical no-undo .
define variable v-found as character no-undo .
define variable log-file-name as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer check_sale-doc for ub.sale-doc.
define buffer check_gds-dtl for ub.gds-dtl.


&glob view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!В процессе удаления продажи произошли ошибки!!!')"  ~
                    "'sale-del.log'" ~}   ~
                    undo, return "error":U. ~
                 end


if num-entries(p-parameter, {&delim-par}) <> 5
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 5"
                             , num-entries(p-parameter, {&delim-par})).
  .
end.
else do:
  assign
  p-auto              = integer(entry(1, p-parameter, {&delim-par}))
  p-obj-type          = entry(2, p-parameter, {&delim-par})
  p-obj-code          = integer(entry(3, p-parameter, {&delim-par}))
  forced              = logical(entry(4, p-parameter, {&delim-par}))
  p-inkas-code        = entry(5, p-parameter, {&delim-par})
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.

if p-auto <= 1 then do:
   log-file-name = 'saleclos.log'.
end.
else do:
   log-file-name = 'ext-sale.log'.
end.

define variable ii         as integer no-undo.
define variable const-str as char       init "Отвязано чеков и строк : " format "x(30)" no-undo.
/*оперделение необходимые для совмещения с sale.w по unressal.i */
/*recid записи с которой надо снять - поставить резервы */
define variable rdoc-line as recid.
/*какую единичную запись резервируем расход или возврат*/
define variable r-or-v as character no-undo.
/*количество резервируемых позиций*/
define variable num_resv as int no-undo.
/*количество зарезервированных позиций*/
define variable num_resv_res as int no-undo.
define variable ser-good as logical init no. /*серийный ли товар*/
define variable found-unres as logical init no. /*серийный ли товар*/
define variable v-is-tpsi-obj as logical no-undo .
define variable glog as logical no-undo .
define variable autofbr as logical no-undo .
/*должен быть no потому что нужен только для резервирования*/
define variable v-curr-r-b as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-was-gds-moving             as logical no-undo .
define variable varchip-code                as integer no-undo .
define variable varchip-code2               as integer no-undo .
define variable v-mes                       as character no-undo .

define buffer ink-doc for ub.inkas.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_c-inkas-pay for ub.c-inkas-pay.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.
define buffer buf_c-sale-doc for ub.c-sale-doc.



{ str/unressal.i "del-sale" }
{ str/salersrv.i }



&scop CHECK-RESERV  ~{&display-message~}. ~
    v-found = '':U.                                                                 ~
    for each check_sale-doc where                                                   ~
            check_sale-doc.inkas-code = p-inkas-code:                               ~
      if check_sale-doc.doc-kind = ~{&sale-add-return-write-off~} then next.        ~
      find first check_gds-dtl no-lock where                                        ~
                check_gds-dtl.doc-code = check_sale-doc.doc-code                    ~
          AND   checK_gds-dtl.doc-qnty > 0  no-error .                              ~
      if available check_gds-dtl then do:                                           ~
          v-found = substitute("Документ &1, Товар &2 &3&4"                         ~
                              , check_sale-doc.doc-code                             ~
                              , check_gds-dtl.artic                                 ~
                              , check_gds-dtl.prod-type                             ~
                              , check_gds-dtl.prod-code                             ~
                              ).                                                    ~
          leave.                                                                    ~
      end.                                                                          ~
    end

&scop my-message "Проверка на наличие зарезервированного ЧУЖОГО товара..."
&scop CHECK-RESERV-PROP  ~{&display-message~}. ~
    IF (can-find (first gds-dtl no-lock where ~
                        gds-dtl.doc-code = tpsi_sale-doc.doc-code  AND ~
                        gds-dtl.doc-qnty > 0 USE-INDEX pi) ~
                   ) ~


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


&glob hide-count-message     run hide-counter in p-log-handle

_main:
DO with frame a
ON ERROR   UNDO _main, LEAVE _main
ON END-KEY UNDO _main, LEAVE _main
ON STOP UNDO _main, LEAVE _main :

  FIND FIRST ink-doc WHERE ink-doc.inkas-code = p-inkas-code EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  if NOT available ink-doc then do:
    IF LOCKED ink-doc then do:
&scop my-message substitute("Запись отчета о продаже &1 в настоящий момент занята.&2"  +     ~
                            "Удаление невозможно"                                            ~
                            , p-inkas-code                                                   ~
                            , ~{&new-line~})                                                 ~
       {&display-message-laud}.
    end.
    else do:
&scop my-message substitute("Не найден незaкрытый отчет о продаже с номером ", p-inkas-code)
        {&display-message-laud}.
    end.
    return.
  end.
  if ink-doc.status_ <> {&g___new} then do:
&scop my-message substitute("Отчет о продаже с номером &1 имеет статус &2", p-inkas-code, ink-doc.status_)
      {&display-message-laud}.
    return .
  end.
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  v-host-code = ink-doc.host-code.
&scop my-message "Проверка на наличие зарезервированного товара..."
  {&check-reserv}.
  if v-found <> '':U then do:
    found-unres = yes.
    if NOT FORCED THEN DO:
&scop my-message substitute("В накладных по продаже &1 имеются неснятые резервы&2" +  ~
                             "Удаление невозможно"                                    ~
                             , p-inkas-code                                           ~
                             , ~{&new-line~})
      {&display-message-laud}.
      return "error" .
    end.
  END.
  if p-auto < 2 then do:
    glog = no.
    message "Удалить незакрытую продажу " ink-doc.inkas-code skip
            "Вы уверены!"
    view-as alert-box QUESTION BUTTONS YES-NO update glog.
    if NOT glog then return.
  end.
  if found-unres then do:
      /*начинаем принудительное снятие резерва*/
    RUN PUSK-UNRESERV (v-is-tpsi-obj) no-error.
    if error-status:error then do:
&scop my-message substitute("Ошибка при принудительном удалении резервов по продаже&1:&2&3 &4" +  ~
                             "Удаление невозможно"                                    ~
                             , p-inkas-code                                           ~
                             , ~{&new-line~}                                          ~
                             , error-status:get-message(1)                             ~
                             , return-value)
        {&display-message-laud}.
        v-view-log = yes.
        {&view-log}.
        UNDO _main, return "error".
    end.
&scop my-message "Проверка на наличие зарезервированного товара..."
    v-found = '':U.

    v-found = '':U.
    for each check_sale-doc where
            check_sale-doc.inkas-code = p-inkas-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      if check_sale-doc.doc-kind = {&sale-add-return-write-off} then next.
      IF  can-find (first ub.gds-dtl no-lock where
                        ub.gds-dtl.doc-code = check_sale-doc.doc-code  AND
                        ub.gds-dtl.doc-qnty > 0 USE-INDEX pi) then do:
        v-found = check_sale-doc.doc-code.
        leave.
      end.
    end .


    {&check-reserv}.
    if v-found <> '':U then do:
&scop my-message substitute("В накладных по продаже &1 (&2) ВСЕ ЕЩЕ имеются неснятые резервы&3" +  ~
                             "Удаление невозможно"                                    ~
                             , p-inkas-code                                           ~
                             , v-found                                                ~
                             , ~{&new-line~})
       {&display-message-laud}.
       UNDO _main,  return "error".
    END.
  end.
  /*отвязывание чеков */

  { str/del-sale.i ink-doc.inkas-code ink-doc.obj-type ink-doc.obj-code ii }

/* очистка расходной половины отчета */
  _bts:
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.order > 0
  by buf_sale-doc.order
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)) :
    FIND buf_trn-doc WHERE
         buf_trn-doc.doc-code = buf_sale-doc.doc-code exclusive no-error.
    if not available buf_trn-doc then do:
      FIND buf_trn-doc WHERE
          buf_trn-doc.doc-code = buf_sale-doc.doc-code no-lock no-error.
      if not available buf_trn-doc then do:
        delete buf_sale-doc.
        next _bts.
      end.
    end.
    assign
    buf_trn-doc.doc-date = ink-doc.doc-date.  /* эта дата могла измениться, если чеки за др. день */
&scop sale-doc-kind buf_sale-doc.doc-kind
&scop my-message substitute("Удаление строчек накладной (&1)        ", ~{&sale-doc-name~})
  {&display-message}.

    FOR EACH ub.doc-line WHERE
              ub.doc-line.doc-code = buf_sale-doc.doc-code
    on error undo _main, return error
    substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      ub.doc-line.doc-qnty = 0 .
      FOR EACH ub.gds-dtl WHERE
          ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
          ub.gds-dtl.prod-code = ub.doc-line.prod-code AND
          ub.gds-dtl.artic     = ub.doc-line.artic AND
          ub.gds-dtl.doc-code  = ub.doc-line.doc-code :
        ub.gds-dtl.doc-qnty = 0 .
        if ub.doc-line.doc-qnty <> 0 or ub.gds-dtl.doc-qnty <> 0 then do:
&scop sale-doc-kind buf_sale-doc.doc-kind
&scop my-message substitute("Ошибка обнуления товара/признака в отчете продажи &1 ( &5 ):&2&3 &4"  +  ~
                            "Удаление продажи невозможно."                                                 ~
                            , p-inkas-code                                                                 ~
                            , ~{&new-line~}                                                                ~
                            , error-status:get-message(1)                                                  ~
                            , return-value                                                                 ~
                            , ~{&sale-doc-name~} )
        {&display-message}.
         v-view-log = yes.
          undo _main, return "error".
        end.
        delete ub.gds-dtl.
        ii = ii + 1.
&scop sale-doc-kind buf_sale-doc.doc-kind
&scop my-count-message substitute("Удаление строчек накладной (&2) &1", string(ii, "999999"), ~{&sale-doc-name~})
{&display-count-message}.
      END .
      delete doc-line.
    END.
    for each ub.doc-prts WHERE
          ub.doc-prts.out-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete ub.doc-prts.
    end.
    for each ub.doc-pl WHERE
            ub.doc-pl.out-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
        delete ub.doc-pl.
    end.
    for each ub.doc-fbr-gds WHERE
            ub.doc-fbr-gds.out-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
        delete ub.doc-fbr-gds.
    end.
    for each buf_c-inkas where
            buf_c-inkas.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_c-inkas.
    end.
    for each buf_c-inkas-pay where
            buf_c-inkas-pay.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_c-inkas-pay.
    end.
    for each buf_c-inkas-pay-desk where
            buf_c-inkas-pay-desk.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_c-inkas-pay-desk.
    end.
    for each buf_c-inkas-pay-wth where
            buf_c-inkas-pay-wth.inkas-code = ink-doc.inkas-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_c-inkas-pay-wth.
    end.

  end. /*for each buf_sale-doc*/
  /* Удалим sale-doc  с order = 0 */
  for each buf_sale-doc where buf_sale-doc.inkas-code = p-inkas-code
                          and buf_sale-doc.order = 0:
    delete buf_sale-doc.
  end.
  /*ii = 1  внутренний */
  /* ii = 2 межфирма*/
  /*начинаем закрытие документов перемещения*/
  _tpsi_sale-doc:
  for each tpsi_sale-doc where
          tpsi_sale-doc.inkas-code = ink-doc.inkas-code
      and tpsi_sale-doc.tpsidoc = yes,
      first buf_trn-doc EXCLUSIVE-LOCK where buf_trn-doc.doc-code = tpsi_sale-doc.doc-code
  on error undo, return "error"
  :
    assign
    buf_trn-doc.status_ = {&wayb}
    buf_trn-doc.flag_ = no.
    run str/del-doc.p (
        input  parparentproc,
        input  tpsi_sale-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  ?,
        input  ?,
        input  g#userid,
        input  '0',
        input  varchip-code,
        output varchip-code2)
        no-error.
    if error-status:error then do:
      assign
      v-mes =  substitute("Ошибка при удалении ПУСТОГО расходного документа ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5:&3&6 &7"
                              , tpsi_sale-doc.doc-code
                              , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                              , {&new-line}
                              , ink-doc.inkas-code
                              , (ink-doc.obj-type + string(ink-doc.obj-code))
                              , error-status:get-message(1)
                              , return-value ).
&scop my-message v-mes
      {&display-message}.
      v-view-log = yes.
      {&view-log}.
      UNDO _main, return "error".
    end.
    else do:
      delete tpsi_sale-doc.
    end.
  end. /*for each tpsi_sale-doc*/
  delete ink-doc no-error .
  if error-status:error then do:
&scop my-message substitute("Ошибка при удалении записи документа продажи &1:&2&3 &4" ~
                            , p-inkas-code                                            ~
                            , ~{&new-line~}                                           ~
                            , error-status:get-message(1)                             ~
                            , return-value )
     {&display-message}.
     v-view-log = yes.
     {&view-log}.
     undo _main, return "error" .
  end.
  FOR EACH BUF_sale-doc where
          buf_sale-doc.inkas-code = p-inkas-code
      and buf_sale-doc.order > 0,
      FIRST BUF_TRN-DOC exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
&scop sale-doc-kind buf_sale-doc.doc-kind
&scop my-message substitute("Удаление &1 &2...", ~{&sale-doc-name~}, buf_sale-doc.doc-code)

       {&display-message}.


      if buf_sale-doc.in-inkas = no then do:
        assign
        buf_trn-doc.status_ = {&wayb}.

        run str/del-doc.p (
            input  parparentproc,
            input  buf_sale-doc.doc-code,
            input  g#db-num,
            input  "del-doc.err",
            input  ?,
            input  ?,
            input  g#userid,
            input  '0',
            input  varchip-code,
            output varchip-code2)
            no-error.
       END.
       ELSE DO:
         DELETE BUF_TRN-DOC NO-ERROR.
       END.
      if error-status:error then do:
&scop sale-doc-kind buf_sale-doc.doc-kind
        assign
        v-mes =  substitute("Ошибка при удалении документа &1 &2 для продажи &3:&4&5&4&6"
                                , {&sale-doc-name}
                                , buf_sale-doc.doc-code
                                , p-inkas-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        &scop my-message v-mes
        {&display-message}.
        v-view-log = yes.
        {&view-log}.
        undo _main, return "error" .
      end.
      delete buf_sale-doc.
  END.
  &scop my-message substitute("Продажа &1 удалена", p-inkas-code)
  {&display-message}.
END .


PROCEDURE PUSK-UNRESERV:
define input parameter p-is-tpsi-obj as logical no-undo .
DEFINE var i-err-count as   integer             no-undo .
assign
rdoc-line = - 1
rgds-dtl = ?
r-or-v = ?
r-qnty = ?
r-b-code = ?
r-doc-prts-qnty = ?
r-pl-code = ?
.
if p-auto < 2
then do:
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_sale_fact':U
    {&cntxt-object}
    ink-doc.host-code
    ink-doc.obj-type
    ink-doc.obj-code
    0
    0
    0
    true
    glog
  }
  if NOT glog then return error.
end.
/*не проверяем есть ли чеки - их может не быть а строчки есть - если продажа кривая!!!*/

/*первичное снятие резерва - все равно что руками из продажи*/

RUN UNRESERV in this-procedure ( input p-is-tpsi-obj, buffer ink-doc) no-error.

IF error-status:error then do:
  run del-lines in this-procedure no-error .
  if error-status:error then do:
  &scop my-message substitute("Ошибка при форсированном удалении резервов с продажи &1:&2&3&2&4"  ~
                            , p-inkas-code                                                        ~
                            , ~{&new-line~}                                                       ~
                            , error-status:get-message(1)                                         ~
                            , return-value                                                        ~
                            )
    v-view-log = yes.
    {&display-message}.

    undo, return error.
  end.
end.
END PROCEDURE.




procedure del-lines :

_main:
do
on error undo, return error
:
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.

  for each buf_sale-doc where
           buf_sale-doc.inkas-code = p-inkas-code
       and buf_sale-doc.order > 0
  by buf_sale-doc.order
  on error undo, return error substitute("&1&2&1&3", error-status:get-message(1), {&new-line}, return-value )
  on stop undo, return error substitute("&1&2&1&3", error-status:get-message(1), {&new-line}, return-value )
  :
    if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then next.
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code.
    assign
    buf_trn-doc.status_ = {&wayb}.
&scop sale-doc-kind buf_sale-doc.doc-kind
    &scop my-message substitute("УДАЛЕНИЕ резервов с накладной &1 &2...", ~{&sale-doc-name~}, buf_sale-doc.doc-code)
    {&display-message}.
    for each ub.doc-line where
            ub.doc-line.doc-code = buf_sale-doc.doc-code
    on error undo _main, return error substitute("&1&2&1&3", error-status:get-message(1), {&new-line}, return-value )
    :
      run trg/rsrv-del.p
        (input ub.doc-line.doc-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ) no-error .
      if error-status :error then do:
        {&view-log}.
        undo _main, return error substitute("Ошибка при снятии резервов. Документ &1 Артикул: &2 &3 &4",
                                      doc-line.doc-code,
                                      doc-line.artic,
                                      doc-line.prod-type,
                                      doc-line.prod-code).
      end.
    end.
  end.
end.

end procedure. /* del-lines */