block-level on error undo, throw.
/*

$Revision: 6ae23366fafd, 1264, rls $
$Author: SMMolotkov $
$Date: Mon Mar 19 13:02:46 2018 +0300 $
$Workfile: delfsale.p $
$Archive: str/delfsale.p $

Удаление продажи закрытой на факт

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
define variable parinkas-code like ub.inkas.inkas-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 6ae23366fafd, 1264, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Mar 19 13:02:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: delfsale.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/delfsale.p $":U .
define variable vss-description as character no-undo initial "Удаление продажи закрытой на факт".
{ cmp/vssrevis.i "substitute('&1':u,parinkas-code)" }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ str/lib-def.i  }
{ str/tpsidoc.i " " proc }
{ gbl/cur-time.i }
{ gbl/clntattr.i }
{ gbl/getcntxt.i def }

&glob display-message  if g#news                                                                                      ~
                       then . /*run write-to-log in p-log-handle( input ( fill( ~{&space-char~}, 1) + ~{&my-message~})) .*/  ~
                       else run write-log-and-file in p-log-handle (                                                  ~
                                  input 1                                                                             ~
                                , input log-file-name                                                                 ~
                                , input 1                                                                             ~
                                , input ~{&my-message~})


&glob display-message-laud  if g#news                                                                                      ~
                            then . /*run write-to-log in p-log-handle( input ( fill( ~{&space-char~}, 1) + ~{&my-message~})) .*/  ~
                            else run write-log-and-file in p-log-handle (                                                  ~
                                          input 1                                                                          ~
                                        , input log-file-name                                                              ~
                                        , input 1                                                                          ~
                                        , input ~{&my-message~})


&glob display-count-message if g#news                                                                                      ~
                            then . /*run write-to-screen in p-log-handle( input ( fill(  "-":U, 15) + ~{&my-count-message~})) .*/  ~
                            else run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message   if g#news                                   ~
                           then .                                      ~
                           else run hide-counter in p-log-handle

define variable v-view-log        as logical   no-undo .
define variable v-esm             as character no-undo .
define variable v-input-error     as logical   no-undo .

define variable v-user-action     as character no-undo .
define variable v-printed         as logical   no-undo .
define variable v-deleted         as logical   no-undo .
define variable jj                as integer   no-undo .
define variable cre-pay           like ub.cash-pay.cdpay-code no-undo .
define variable varobj-date       as date      no-undo .
define variable varshift-date     like ub.shift-obj.shift-date no-undo .
define variable varshift-num      like ub.shift-obj.shift-num  no-undo .
define variable varshift-name     as character no-undo.
define variable l-shift-on        as logical   no-undo .
define variable varmin-fact-order as decimal   no-undo .
define variable v-err-mes         as character no-undo .
define variable conf-par          as character no-undo .
define variable par-type          as character no-undo .
define variable varchip-code      as integer   no-undo .
define variable varchip-code2     as integer   no-undo .
define variable wth-ii            as integer   no-undo .
define variable v-can-del-fbr-doc as logical   no-undo.
define variable v-supp-doc-code   as character no-undo initial '0'.
define variable log-file-name     as character no-undo initial 'delfsale.log'.
define variable v-need-saledc     as logical no-undo .

define buffer buf_inkas for ub.inkas .
define buffer buf_obj for ub.clients.
define buffer sale_trn-doc for ub.trn-doc .
define buffer buf_wth-doc for ub.wth-doc .
define buffer buf_cash-pay for ub.cash-pay.
define buffer bf-pri_trn-doc for ub.trn-doc.
define buffer bf_clients for ub.clients.
/*документ смены типа приобретения*/
define buffer supp_trn-doc for ub.trn-doc .
/*документ коррекции отриц партий*/
define buffer neg_trn-doc for ub.trn-doc .
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer locked_trn-doc for ub.trn-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define stream LogStream.


_main:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    { gbl/getcntxt.i get }
  end.
  else do:
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    run get-userid in parparentproc ( output v-cntxt-userid).
  end.
  if search ("del-doc.err") <> ?
  then do:
    os-delete "del-doc.err".
  end.

  assign
  parinkas-code = p-parameter
  .
  find first buf_inkas exclusive-lock
    where buf_inkas.inkas-code = parinkas-code
    no-error .
  if not available buf_inkas
  then do:
&scop   my-message  substitute("&1 &2 &3&4!!!Ошибка задания входных параметров: не найдена продажа &5"  ~
                ,vss-workfile                                                             ~
                ,vss-revision                                                             ~
                ,vss-description                                                          ~
                , ~{&new-line~}                                                           ~
                , parinkas-code)
     {&display-message}.
    undo _main, return error.
  end.

  if buf_inkas.status_ <> {&fact}
  then do:
&scop my-message    substitute("&1 &2 &3&4!!!Ошибка задания входных параметров: продажа &5 статус &6"   ~
                ,vss-workfile                                                             ~
                ,vss-revision                                                             ~
                ,vss-description                                                          ~
                , ~{&new-line~}                                                           ~
                , parinkas-code                                                           ~
                , buf_inkas.status_                                                       ~
                )
    {&display-message}.
    undo _main, return error.
  end.

  find first ub.sys-ctrl no-lock.
  find first buf_obj  no-lock where
             buf_obj.obj-type = buf_inkas.obj-type
        AND  buf_obj.obj-code = buf_inkas.obj-code .
  if ub.sys-ctrl.db-num <> buf_obj.db-num and not g#news
  then do:
&scop my-message   substitute("&1 &2 &3&4Нельзя удалить продажу &5, принадлежащую объекту другой БД &6"  ~
                ,vss-workfile                                                                            ~
                ,vss-revision                                                                            ~
                ,vss-description                                                                         ~
                , ~{&new-line~}                                                                          ~
                , parinkas-code                                                                          ~
                , buf_obj.db-num                                                                         ~
                )
    {&display-message}.
    undo _main, return error.
  end.
  find first ub.sysconf no-lock
    where ub.sysconf.host-code = buf_inkas.host-code
    no-error .
  if not available ub.sysconf
  then do:
&scop my-message  substitute("&1 &2 &3&4Не найдена запись о фирме &5"         ~
                ,vss-workfile                                                 ~
                ,vss-revision                                                 ~
                ,vss-description                                              ~
                , ~{&new-line~}                                               ~
                , buf_inkas.host-code                                         ~
                )
   {&display-message}.
   undo _main, return error.
  end.
  find first buf_Cash-pay no-lock where
           buf_cash-pay.cdpay-code = sysconf.credit-pay no-error.
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
    cre-pay = sysconf.credit-pay
    .
  end.
/* { gbl/curobjdt.i
  01/III-2018 заменено на gbl/objdtget.i: только возвращает дату, без проверок её правильности и без её переустановки
*/
  { gbl/objdtget.i
    buf_inkas.obj-type
    buf_inkas.obj-code
    varobj-date
    no-error
  }
  if error-status :error
  or varobj-date = ?
  then do:
&scop my-message   substitute("Нет текущей даты на объекте продажи &1 &2&3&4&5 &6"  ~
                , buf_inkas.inkas-code                                              ~
                , buf_inkas.obj-type                                                ~
                , buf_inkas.obj-code                                                ~
                , ~{&new-line~}                                                     ~
                , error-status:get-message(1)                                       ~
                , return-value                                                      ~
                )

    {&display-message}.
    undo _main, return error.
  end.

  { gbl/objat.i
    buf_inkas.obj-type
    buf_inkas.obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on
  then do:
    /* на объекте включены смены */
    { gbl/curshift.i
      buf_inkas.obj-type
      buf_inkas.obj-code
      varshift-date
      varshift-num
      varshift-name
      no-error
    }
    if error-status :error
    then do:
&scop my-message   substitute("!!!Ошибка при поиске текущей смены на объекте продажи &1 &2&3&4&5 &6"  ~
                , buf_inkas.inkas-code                                                             ~
                , buf_inkas.obj-type                                                               ~
                , buf_inkas.obj-code                                                               ~
                , ~{&new-line~}                                                                    ~
                , error-status:get-message(1)                                                      ~
                , return-value                                                                     ~
                )
      {&display-message}.
      undo _main, return error.
    end.
  end.
  else do:
    assign
      varshift-date = ?
      varshift-num  = ?
    .
  end.

  /* находим складские документы */
  find first sale_trn-doc exclusive-lock
    where sale_trn-doc.doc-code = parinkas-code
    no-error .
  if not available sale_trn-doc
  then do:
&scop my-message  substitute("&1 &2 &3&4Не найден или занят складской документ расхода через кассу для продажи &5"  ~
                ,vss-workfile                                                                             ~
                ,vss-revision                                                                             ~
                ,vss-description                                                                          ~
                , ~{&new-line~}                                                                           ~
                , buf_inkas.inkas-code                                                                    ~
                )
    {&display-message}.
    undo _main, return error.
  end.
  /*заблокируем*/
  /*must TRANSACTION*/
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = buf_inkas.inkas-code
      and  buf_sale-doc.order > 0,
      first locked_trn-doc exclusive-lock where
          locked_trn-doc.doc-code = buf_sale-doc.doc-code
  on error undo _main, return error
  on stop undo _main, return error :
  end.


  /*найдем цепочку документов по ТПСИ*/
/*номера связанных документов при закрытии ТПСИ - расходные части относящиеся к объектам собственникам товаров*/
/*приходные сами собой удаляться когда мы будем удалять расходные*/
                                                                                                                           /*находим документ автоматической коррекции отриацтельных партий*/
  find first neg_trn-doc exclusive-lock
    where neg_trn-doc.out-code = sale_trn-doc.doc-code
      AND neg_trn-doc.obj-type = sale_trn-doc.obj-type
      AND neg_trn-doc.obj-code = sale_trn-doc.obj-code
      AND neg_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts}
      AND neg_trn-doc.internal = yes
      AND neg_trn-doc.doc-type = {&inventory}
      AND neg_trn-doc.doc-date = sale_trn-doc.doc-date no-error .

  /*находим документ коррекции типа приобретения*/
  find first supp_trn-doc exclusive-lock
    where supp_trn-doc.out-code = sale_trn-doc.doc-code
      AND supp_trn-doc.obj-type = sale_trn-doc.obj-type
      AND supp_trn-doc.obj-code = sale_trn-doc.obj-code
      AND supp_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
      AND supp_trn-doc.internal = no
      AND supp_trn-doc.doc-type = {&inventory}
      AND supp_trn-doc.doc-date = sale_trn-doc.doc-date no-error .

  /* обновляется информация о покупках через дисконтные карты */
  if not g#news
  then do:
    if can-find( first ub.chk-doc NO-LOCK WHERE
                    ub.chk-doc.out-code = buf_inkas.inkas-code
                AND ub.chk-doc.d-card <> "" ) then do:
&scop my-message  substitute("Подсчет итогов продаж по дисконтным картам...")
      {&display-message}.
      run str/saledc.p
        (input parparentproc
        ,input this-procedure:handle
        ,input p-log-handle
        ,input {&dct-proc_sale-delete}
        ,input ? /*p-emitent-host-code*/
        ,input "" /*p-type*/
        ,input 0 /*p-profile-id*/
        ,input 0 /*p-codex-id*/
        ,input 0 /*p-ruleset-id*/
        ,input g#db-num
        ,input buf_inkas.inkas-code
        ,input buf_inkas.doc-date
        ,input buf_inkas.fact-date
        ,input cre-pay
        ,input (-1)  /*par-sign*/
        ,input ? /*par-direction*/
        ,input yes /*p-save*/
        ) no-error .
      if error-status :error
      then do:
  &scop my-message  substitute("&1 &2 &3&4!!!Ошибка при пересчете итогов по дисконтным картам для продажи &5:&4&6 &7" ~
                  ,vss-workfile                                                                                    ~
                  ,vss-revision                                                                                    ~
                  ,vss-description                                                                                 ~
                  , ~{&new-line~}                                                                                  ~
                  , buf_inkas.inkas-code                                                                           ~
                  , error-status:get-message(1)                                                                    ~
                  , return-value                                                                                   ~
                  )
        {&display-message}.
        undo _main, return error.
      end.
    end. /*if can-find( first chk-doc NO-LOCK WHERE*/
    if g#news
    and can-find( first ub.chk-doc NO-LOCK WHERE
                    ub.chk-doc.out-code = buf_inkas.inkas-code
                AND ub.chk-doc.d-card <> "" ) then do:
      assign
      v-need-saledc = yes.
    end.
  end.
  /*отвязываем чеки и*/
  /*создаем копию*/
  /*удаление inkas-pay inkas-pay-desk*/
  { str/del-sale.i
    buf_inkas.inkas-code
    buf_inkas.obj-type
    buf_inkas.obj-code
    jj
    del
    buf_inkas
    recid(buf_inkas)
    varobj-date
    varshift-date
    varshift-num
    varshift-name
    g#userid
    varchip-code
    no-error
  }

  {&hide-count-message}.
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer   no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-auto-fbr as logical no-undo .
  define variable v-inkas-shift-date as date no-undo .
  define variable v-inkas-shift-num as integer no-undo .

  assign
  v-host-code = buf_inkas.host-code
  v-obj-type = buf_inkas.obj-type
  v-obj-code = buf_inkas.obj-code
  v-auto-fbr = buf_inkas.auto-fbr
  v-inkas-shift-date = buf_inkas.shift-date
  v-inkas-shift-num = buf_inkas.shift-num
  .

  /* удаляем продажу */
  delete buf_inkas .
  
  /* 01/III-2018 При закрытии (is-back-date) или удалении документа продажи ЗАДНИМ ЧИСЛОМ
                 посылать в 1С сообщение в формате закрытия смены.
                 Т.е. если продажу удалили, то мы посылаем смену уже без чеков, которые были в этой продаже.
     p.s. "задним числом" - когда закрытую продажу удаляют из закрытой смены
  */
  define variable v-old-shift-obj as handle no-undo  .
  define variable v-new-shift-obj as handle no-undo  .
  define buffer buf_shift-obj for ub.shift-obj .
  if l-shift-on then do:
    /* смена, полученная выше из gbl/curshift.i не подходит, т.к. там текущая смена, а нам
       нужна смена, на которую ссылался удалённый inkas */
    find first buf_shift-obj no-lock
         where buf_shift-obj.obj-type = v-obj-type
           and buf_shift-obj.obj-code = v-obj-code
           and buf_shift-obj.shift-date = v-inkas-shift-date
           and buf_shift-obj.shift-num  = v-inkas-shift-num
           and buf_shift-obj.status_  = {&sht-closed} /* - иначе это не задним числом */
               no-error .
    if available buf_shift-obj then do:
      /* оба указателя указывают в одно место, т.к. фактически запись о смене не менялась */
      assign
        v-old-shift-obj = buffer buf_shift-obj:handle
        v-new-shift-obj = v-old-shift-obj
      .  
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
&scop   my-message  substitute("&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"  ~
            , ~{&new-line~} ~
            , vss-workfile ~
            , return-value ~
            , error-status :get-message ( 1 ) ~
        )
        {&display-message}.
        undo _main, return error.
      end.
    end. /* end_of available_shift-obj */
  end. /* end_of if_shift_on */
  
  if not g#news
  then do:
    /* удаляем документы матценностей */
    for each buf_wth-doc exclusive-lock
      where buf_wth-doc.source-type = {&wthd-cash-desk}
        and buf_wth-doc.source-ref  = parinkas-code
    on error undo _main, return error
    :
      assign
        varmin-fact-order = min(buf_wth-doc.fact-order, varmin-fact-order).
        wth-ii = wth-ii + 1
      .
&scop my-message substitute("Удаление документа МЦ &1, связанного с продажей &2", buf_wth-doc.doc-code, parinkas-code)
  {&display-message}.

      run trg/wthdocdl.p
        (input buf_wth-doc.doc-code
         ,input varchip-code
         ,'':U
         ,output varchip-code2
        ) no-error .
      if error-status :error
      then do:
&scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении документа МЦ &5 для продажи &6:&4&7 &8"  ~
                    ,vss-workfile                                                                    ~
                    ,vss-revision                                                                    ~
                    ,vss-description                                                                 ~
                    , ~{&new-line~}                                                                  ~
                    , parinkas-code                                                           ~
                    , buf_wth-doc.doc-code                                                           ~
                    , error-status:get-message(1)                                                    ~
                    , return-value                                                                   ~
                    )
        {&display-message}.
        undo _main, return error .
      end.
    end. /*for each buf_wth-doc */

    /* пересчет остатков по МЦ производвится в wthdocdl.p*/

    /* удаляем складские документы на активной стороне */
    /* документы необходимо удалять в порядке обратном порядку при закрытии */
&scop my-message substitute("Удаление складских документов, связанных с продажей &1", parinkas-code)
  {&display-message}.


    if available neg_trn-doc
    then do:
&scop my-message substitute("Удаление документа автоматической коррекции отрицательных партий &1", neg_trn-doc.doc-code)
  {&display-message}.
      find first buf_sale-doc where
                buf_sale-doc.inkas-code = parinkas-code
            and buf_sale-doc.storage = {&table_trn-doc}
            and buf_sale-doc.doc-code = neg_trn-doc.doc-code no-error.
      /* удаляем документ автоматической коррекциий отрицательныйх партий */
      run str/del-doc.p (
        input  parparentproc,
        input  neg_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  0,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2Документ автоматической коррекции отрицательных партий &3 не удален:&2"   ~
                            ,parinkas-code                                                                  ~
                            , ~{&new-line~}                                                                   ~
                            ,neg_trn-doc.doc-code)
          {&display-message}.
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
&scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"     ~
                      ,vss-workfile                                                   ~
                      ,vss-revision                                                   ~
                      ,vss-description                                                ~
                      , ~{&new-line~}                                                 ~
                      , neg_trn-doc.doc-code                                         ~
                      , error-status:get-message(1)                                   ~
                      , return-value                                                  ~
                      )
          {&display-message}.
          undo _main, return error.
        end.
      end.
      if available  buf_sale-doc then do:
        delete buf_sale-doc.
      end.
    end.
  _sale-doc:
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = parinkas-code
      and ( buf_sale-doc.order    > 0
         or buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell}
         )
  by buf_sale-doc.order descending
  on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):

&scop sale-doc-kind buf_sale-doc.doc-kind
&scop my-message substitute("Удаление документа &1 &2", ~{&sale-doc-name~}, buf_sale-doc.doc-code)
  {&display-message}.
    /* удаляем документ через кассу */
    define variable v-doc-code as character no-undo .
    define variable v-doc-kind as character no-undo .
    v-doc-code = buf_sale-doc.doc-code.
    v-doc-kind = buf_sale-doc.doc-kind.
    if buf_sale-doc.doc-kind = {&sale-add2-in-tech-refuell} then do:
      find first buf_trn-doc exclusive-lock where
                buf_trn-doc.doc-code = buf_sale-doc.doc-code no-error.
      if available buf_trn-doc then do:
        if buf_trn-doc.status_ <> {&fact} then do:
            &scop my-message  substitute("&1 &2 &3&4!!!До удаления продажи необходимо удалить документ прихода по техпроливу &5"     ~
                      ,vss-workfile                                                   ~
                      ,vss-revision                                                   ~
                      ,vss-description                                                ~
                      , ~{&new-line~}                                                 ~
                      , buf_trn-doc.doc-code                                         ~
                      )
            {&display-message}.
            undo, return error.
          end.
        end.
      else do:
        delete buf_sale-doc.
        next _sale-doc.
      end.
    end.
    delete buf_sale-doc.
    run str/del-doc.p (
      input  parparentproc,
      input  v-doc-code,
      input  g#db-num,
      input  "del-doc.err",
      input  parinkas-code,
      input  ?,
      input  g#userid,
      input  (if available supp_trn-doc then supp_trn-doc.doc-code else '0'),
      input  varchip-code,
      output varchip-code2)
      no-error.
    if error-status :error
    then do:
      if search ("del-doc.err") <> ?
      then do:
&scop sale-doc-kind v-doc-kind
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2&3 &4 не удален:&2"   ~
                            ,parinkas-code                                                               ~
                            , ~{&new-line~}                                                              ~
                            ,~{&sale-doc-name~}                                                          ~
                            ,v-doc-code)
        {&display-message}.

          message substitute("!!!Продажу &1 нельзя удалить&2&3 &4 не удален:&2"   
                            ,parinkas-code                                                               
                            ,{&new-line}                                                             
                            ,{&sale-doc-name}                                                         
                            ,v-doc-code)  
        return-value
        view-as alert-box information . 


        run read-write-log in this-procedure .
        undo _main, return error .
      end.
      else do:
&scop  my-message    substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"            ~
                      ,vss-workfile                                                   ~
                      ,vss-revision                                                   ~
                      ,vss-description                                                ~
                      , ~{&new-line~}                                                 ~
                      , v-doc-code                                    ~
                      , error-status:get-message(1)                                   ~
                      , return-value                                                  ~
                      )
        {&display-message}.
        undo _main, return error.
      end.
    end. /*if error-status :error*/
  end. /*for each buf_sale-doc*/

  /* Удалим sale-doc  с order = 0 */
  for each buf_sale-doc where buf_sale-doc.inkas-code = parinkas-code
                          and buf_sale-doc.order = 0:
      delete buf_sale-doc.
  end.
  

  if available supp_trn-doc
  then do:
      assign
      v-supp-doc-code = supp_trn-doc.doc-code.
&scop my-message substitute("Удаление документа смены типа приобретения &1", supp_trn-doc.doc-code)
  {&display-message}.
      find first buf_sale-doc where
                buf_sale-doc.inkas-code = parinkas-code
            and buf_sale-doc.storage = {&table_trn-doc}
            and buf_sale-doc.doc-code = supp_trn-doc.doc-code no-error.
      /* удаляем документ смены типа приобретения */
      run str/del-doc.p (
        input  parparentproc,
        input  supp_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  0,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2Документ смены типа приобретения &3 не удален:&2"   ~
                            ,parinkas-code                                                                  ~
                            , ~{&new-line~}                                                                   ~
                            ,supp_trn-doc.doc-code)
          {&display-message}.
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
&scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"     ~
                      ,vss-workfile                                                   ~
                      ,vss-revision                                                   ~
                      ,vss-description                                                ~
                      , ~{&new-line~}                                                 ~
                      , supp_trn-doc.doc-code                                         ~
                      , error-status:get-message(1)                                   ~
                      , return-value                                                  ~
                      )
          {&display-message}.
          undo _main, return error.
        end.
      end.
      if available  buf_sale-doc then do:
        delete buf_sale-doc.
      end.
    end.
    /*удаляем длинный хвост документов ТПСИ*/
    for each tpsi_sale-doc where
          tpsi_sale-doc.inkas-code = parinkas-code
      and tpsi_sale-doc.tpsidoc = yes
      and tpsi_sale-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
&scop my-message substitute("Удаление документа межфирменного перемещения ЧУЖИХ ТОВАРОВ &1", tpsi_sale-doc.doc-code)
{&display-message}.

      find first bf_clients where
              bf_clients.obj-type = tpsi_sale-doc.obj-type
          and bf_clients.obj-code = tpsi_sale-doc.obj-code no-lock.
      if bf_clients.db-num <> buf_obj.db-num
      then do:
&scop my-message  substitute("В документе межфирменного перемещения ЧУЖИХ ТОВАРОВ &1 перемещение проводилось с объекта &2, который сейчас принадлежит базе данных &3.&4" + ~
                          " Нельзя удалять межфирменные документы относящиеся к разным базам данных." ~
                            ,tpsi_sale-doc.doc-code                                                   ~
                            ,tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code)                  ~
                            ,bf_clients.db-num                                                         ~
                            , ~{&new-line~})
        {&display-message}.
        undo _main, return error.
      end.
      find first bf-pri_trn-doc where
                bf-pri_trn-doc.out-code = tpsi_sale-doc.doc-code
          and  bf-pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} exclusive-lock.

      run str/del-doc.p (
        input  parparentproc,
        input  bf-pri_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2Документ межфирменного перемещения ЧУЖИХ ТОВАРОВ &3 (приходный) не удален:&2" ~
                          ,parinkas-code                                                                              ~
                          , ~{&new-line~}                                                                               ~
                          ,bf-pri_trn-doc.doc-code)
          {&display-message}.
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
&scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"     ~
                      ,vss-workfile                                                 ~
                      ,vss-revision                                                 ~
                      ,vss-description                                              ~
                      , ~{&new-line~}                                               ~
                      , bf-pri_trn-doc.doc-code                                      ~
                      , error-status:get-message(1)                                 ~
                      , return-value                                                ~
                      )
          {&display-message}.
          undo _main, return error.
        end.
      end. /*if es*/

      run str/del-doc.p (
        input  parparentproc,
        input  tpsi_sale-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2Документ межфирменного перемещения ЧУЖИХ ТОВАРОВ &3 не удален:&2"  ~
                          ,parinkas-code                                                                                 ~
                          , ~{&new-line~}                                                                                  ~
                          ,tpsi_sale-doc.doc-code)
          {&display-message}.
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
&scop my-message   substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"     ~
                      ,vss-workfile                                                  ~
                      ,vss-revision                                                  ~
                      ,vss-description                                               ~
                      , ~{&new-line~}                                                ~
                      , tpsi_sale-doc.doc-code                                       ~
                      , error-status:get-message(1)                                  ~
                      , return-value                                                 ~
                      )
          {&my-message}.
          undo _main, return error.
        end.
      end. /*if es*/
      delete tpsi_sale-doc.
    end. /*for each temp-tpsi*/
    for each tpsi_sale-doc where
            tpsi_sale-doc.inkas-code = parinkas-code
        and tpsi_sale-doc.tpsidoc = yes
        and tpsi_sale-doc.ext-doc-type = {&TDEDT_Ras_Perem}
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :

&scop my-message substitute("Удаление документа внутреннего перемещения ЧУЖИХ ТОВАРОВ &1", tpsi_sale-doc.doc-code)
{&display-message}.
      find first bf_clients where
              bf_clients.obj-type = tpsi_sale-doc.obj-type
          and bf_clients.obj-code = tpsi_sale-doc.obj-code no-lock.
      if bf_clients.db-num <> buf_obj.db-num
      then do:
&scop my-message  substitute("В документе внутреннего перемещения ЧУЖИХ ТОВАРОВ &1 перемещение проводилось с объекта &2, который сейчас принадлежит базе данных &3.&4" + ~
                          " Нельзя удалять внутренние документы относящиеся к разным базам данных."  ~
                            ,tpsi_sale-doc.doc-code                                                  ~
                            ,tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code)                 ~
                            ,bf_clients.db-num                                                       ~
                            , ~{&new-line~})
        {&display-message}.
        undo _main, return error.
      end.
      find first bf-pri_trn-doc where
                bf-pri_trn-doc.out-code = tpsi_sale-doc.doc-code
          and  bf-pri_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} exclusive-lock.
      define buffer dop_sale-doc for ub.sale-doc.
      find first dop_sale-doc where
                dop_sale-doc.inkas-code = parinkas-code
            and dop_sale-doc.storage = {&table_trn-doc}
            and dop_sale-doc.doc-code = bf-pri_trn-doc.doc-code no-error.

      run str/del-doc.p (
        input  parparentproc,
        input  bf-pri_trn-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2Документ внутреннего перемещения ЧУЖИХ ТОВАРОВ &3 (приходный) не удален:&2" ~
                          ,parinkas-code                                                                              ~
                          , ~{&new-line~}                                                                               ~
                          ,bf-pri_trn-doc.doc-code)
          {&display-message}.
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
&scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"     ~
                      ,vss-workfile                                                 ~
                      ,vss-revision                                                 ~
                      ,vss-description                                              ~
                      , ~{&new-line~}                                               ~
                      , bf-pri_trn-doc.doc-code                                      ~
                      , error-status:get-message(1)                                 ~
                      , return-value                                                ~
                      )
          {&display-message}.
          undo _main, return error.
        end.
      end. /*if es*/
      if available dop_sale-doc then delete dop_sale-doc.

      run str/del-doc.p (
        input  parparentproc,
        input  tpsi_sale-doc.doc-code,
        input  g#db-num,
        input  "del-doc.err",
        input  parinkas-code,
        input  ?,
        input  g#userid,
        input  v-supp-doc-code,
        input  varchip-code,
        output varchip-code2)
        no-error.
      if error-status :error
      then do:
        if search ("del-doc.err") <> ?
        then do:
&scop my-message substitute("!!!Продажу &1 нельзя удалить&2Документ внутреннего перемещения ЧУЖИХ ТОВАРОВ &3 (расходный) не удален:&2" ~
                          ,parinkas-code                                                                              ~
                          , ~{&new-line~}                                                                               ~
                          ,tpsi_sale-doc.doc-code)
          {&display-message}.
          run read-write-log in this-procedure .
          undo _main, return error .
        end.
        else do:
&scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении документа &5&4&6&4&7"     ~
                      ,vss-workfile                                                 ~
                      ,vss-revision                                                 ~
                      ,vss-description                                              ~
                      , ~{&new-line~}                                               ~
                      , tpsi_sale-doc.doc-code                                      ~
                      , error-status:get-message(1)                                 ~
                      , return-value                                                ~
                      )
          {&display-message}.
          undo _main, return error.
        end.
      end. /*if es*/
      delete tpsi_sale-doc.
    end. /*for each temp-tpsi*/
    if (v-auto-fbr = yes
    or v-auto-fbr = ? )
    and not g#news
    then do:
      /*удаляем длиный хвост фабричных документов*/
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_manufacturing_del-manuf-fact':U
        {&cntxt-object}
        v-host-code
        v-obj-type
        v-obj-code
        0
        0
        0
        false
        v-can-del-fbr-doc
        no-error
      }
      if error-status :error
      then do:
  &scop my-message substitute("&1 &2 &3&4!!!Ошибка проверки права на удаление документа производства закрытого на факт"  ~
                              ,vss-workfile                                                                           ~
                              ,vss-revision                                                                           ~
                              ,vss-description                                                                        ~
                              ,~{&new-line~}                                                                          ~
                              ,error-status:get-message(1)                                                            ~
                              , return-value                                                                          ~
                              )
              {&display-message}.
              run read-write-log in this-procedure .
          undo _main, return error .
      end.
      if v-can-del-fbr-doc = no
      then do:
  &scop my-message "Нет права на удаление документа производства, закрытого на факт."
        {&display-message}.
        undo _main, return error .
      end.
  &scop my-message substitute("Удаление порожденных документов производства по продаже &1", parinkas-code)
    {&display-message}.

      run str/fbrdel.p (
            input parparentproc
          , input parinkas-code
          , input varchip-code
      ) no-error .
      if error-status:error
      then do:
  &scop my-message  substitute("&1 &2 &3&4!!!Ошибка при удалении порожденных документов производства по продаже &5&4&6&4&7"  ~
                    ,vss-workfile                                                                                         ~
                    ,vss-revision                                                                                         ~
                    ,vss-description                                                                                      ~
                    , ~{&new-line~}                                                                                       ~
                    , parinkas-code                                                                                       ~
                    , error-status:get-message(1)                                                                         ~
                    , return-value                                                                                        ~
                    )
        {&display-message}.
        undo _main, return error.
      end.
    end. /*if v-is-auto-fbr = yes*/
  end.
/*удалим атрибут необходимости расчета ДК - команда cmdp-dc пришла раньше и накладную уже приняли*/
 if g#news
 and g#db-num = 0
 and v-need-saledc
 then do:
    { str/tdat-del.i
        parinkas-code
        ~{&trdcattr-need-saledc~}
        v-deleted
        no-error
      }
  end.
  &scop my-message  substitute("Документ продажи &1 удален", parinkas-code)
  {&display-message}.
end.


procedure hstc-inkas :

define input parameter parrec-inkas   as   recid                   no-undo.
define input parameter parobj-date    as   date                    no-undo.
define input parameter parshift-date  like ub.shift-obj.shift-date no-undo.
define input parameter parshift-num   like ub.shift-obj.shift-num  no-undo.
define input parameter parshift-name  like ub.shift-obj.shift-name  no-undo.
define input parameter paruserid      as   character               no-undo.
define output parameter parchip-code    like ub.c-trn-doc.chip-num   no-undo.

DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .


define buffer hstc_inkas          for ub.inkas.
define buffer hstc_inkas-pay      for ub.inkas-pay.
define buffer hstc_inkas-pay-desk for ub.inkas-pay-desk.
define buffer hstc_inkas-pay-wth  for ub.inkas-pay-wth.
define buffer hstc_sale-doc for ub.sale-doc.
define buffer hstc_c-inkas           for ub.c-inkas.
define buffer hstc_c-inkas-pay      for ub.c-inkas-pay.
define buffer hstc_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer hstc_c-inkas-pay-wth for ub.c-inkas-pay-wth.
define buffer hstc_c-sale-doc for ub.c-sale-doc.

do
on error undo, return error return-value
:
find first hstc_inkas where recid (hstc_inkas) = parrec-inkas.
run cur-time in this-procedure(output v-date, output v-time).
create hstc_c-inkas.
buffer-copy hstc_inkas to hstc_c-inkas.
assign
  parchip-code                 = next-value (s-corr-chip, {&db-name_schema})
  hstc_c-inkas.chip-num        = parchip-code
  hstc_c-inkas.CORR-TIME       = v-time
  hstc_c-inkas.real-corr-date  = v-date
  hstc_c-inkas.corr-date       = parobj-date /*здесь дата объекта*/
  hstc_c-inkas.corr-shift-date = parshift-date
  hstc_c-inkas.corr-shift-num  = parshift-num
  hstc_c-inkas.corr-shift-name  = parshift-name
  hstc_c-inkas.corr-user-name        = paruserid
  hstc_c-inkas.corr-user-db-num   = g#db-num
  .

for each hstc_inkas-pay where
         hstc_inkas-pay.inkas-code = hstc_inkas.inkas-code
on error undo, return error
:
  create hstc_c-inkas-pay.
  buffer-copy hstc_inkas-pay to hstc_c-inkas-pay.
  assign
    hstc_c-inkas-pay.chip-num = hstc_c-inkas.chip-num
    hstc_c-inkas-pay.corr-user-db-num = hstc_c-inkas.corr-user-db-num.
end.
for each hstc_inkas-pay-desk where
         hstc_inkas-pay-desk.inkas-code = hstc_inkas.inkas-code
on error undo, return error
         :
  create hstc_c-inkas-pay-desk.
  buffer-copy hstc_inkas-pay-desk to hstc_c-inkas-pay-desk.
  assign
    hstc_c-inkas-pay-desk.chip-num = hstc_c-inkas.chip-num
    hstc_c-inkas-pay-desk.corr-user-db-num = hstc_c-inkas.corr-user-db-num
    .
end.
for each hstc_inkas-pay-wth where
         hstc_inkas-pay-wth.inkas-code = hstc_inkas.inkas-code
on error undo, return error
         :
  create hstc_c-inkas-pay-wth.
  buffer-copy hstc_inkas-pay-wth to hstc_c-inkas-pay-wth.
  assign
    hstc_c-inkas-pay-wth.chip-num = hstc_c-inkas.chip-num
    hstc_c-inkas-pay-wth.corr-user-db-num = hstc_c-inkas.corr-user-db-num
    .
end.
for each hstc_sale-doc where
         hstc_sale-doc.inkas-code = hstc_inkas.inkas-code
on error undo, return error
:
  create hstc_c-sale-doc.
  buffer-copy hstc_sale-doc to hstc_c-sale-doc.
  assign
  hstc_c-sale-doc.chip-num = hstc_c-inkas.chip-num
  hstc_c-sale-doc.corr-user-db-num = hstc_c-inkas.corr-user-db-num
  hstc_c-inkas.corr-date       = parobj-date /*здесь дата объекта*/
  hstc_c-inkas.corr-shift-date = parshift-date
  hstc_c-inkas.corr-shift-num  = parshift-num
  hstc_c-inkas.corr-shift-name  = parshift-name
  .
end.
end.
end procedure.

procedure read-write-log :
define variable ss as character no-undo .

  do
  on error undo, return error
  :
    if not g#news
    then do:
      input stream LogStream from value("del-doc.err").
      REPEAT:
        import stream LogStream  unformatted ss.
  &scop my-message   ss
        {&display-message}.
      END.
      input stream LogStream close.
    end.
  end.

end procedure. /* read-write-log */