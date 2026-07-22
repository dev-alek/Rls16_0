block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tpsisale.p $
$Archive: str/tpsisale.p $

Закрытие цепочки документов по ТПСИ из продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/04
Author: Bakhtadze Natalya
Creation date: 12/03/04

*/

define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.

/*
p-parameter - это
define input parameter p-inkas-code     like ub.inkas.inkas-code no-undo .
define input parameter p-host-code      like ub.inkas.host-code no-undo .
define input parameter p-obj-type       like ub.inkas.obj-type no-undo .
define input parameter p-obj-type       like ub.inkas.obj-code no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tpsisale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/tpsisale.p $":U .
define variable vss-description as character no-undo init "Закрытие цепочки документов по ТПСИ из продажи".
{ cmp/vssrevis.i }

define variable p-inkas-code     like ub.inkas.inkas-code no-undo .
define variable p-host-code      like ub.inkas.host-code no-undo .
define variable p-obj-type       like ub.inkas.obj-type no-undo .
define variable p-obj-code       like ub.inkas.obj-code no-undo .
define variable log-file-name                as character      no-undo init "saleclos.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable ii                           as integer no-undo .
define variable jj                           as integer no-undo .
define variable v-mes                        as character no-undo .
define variable v-was-gds-moving             as logical no-undo .
define variable varchip-code                as integer no-undo .
define variable varchip-code2               as integer no-undo .
define variable v-sys-today       like ub.trn-doc.fact-date no-undo .
define variable v-today                     as date no-undo .
define variable v-time                      as integer no-undo .
define variable v-close-num                 as integer no-undo .


define buffer buf_expense_trn-doc for ub.trn-doc.
define buffer buf_income_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer buf_sale-doc for ub.sale-doc.

&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При обработке документов произошли ошибки!!!'" ~
                    "'saleclos.txt'" ~}   ~
                    return


{ cmp/trg-def.i }
{ str/lib-trn.i }
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/tpsidoc.i "shared" proc }
{ cmp/gds-list.i temp_gds-list def }
{ gbl/cur-time.i }
{ gbl/clntattr.i }
{ str/saledoc.i }


do
on error undo, return error return-value
:

  assign
  p-host-code = integer(entry(1, p-parameter, {&delim-par}))
  p-obj-type = entry(2, p-parameter, {&delim-par})
  p-obj-code = integer(entry(3, p-parameter, {&delim-par}))
  p-inkas-code = entry(4, p-parameter, {&delim-par})
  log-file-name = entry(5, p-parameter, {&delim-par})
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка входных параметров &1:&2&3&4"
                          , p-parameter
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
    {&view-log}
    error.
  end.
  do ii = 1 to 2 :
    /*ii = 1  внутренний */
    /* ii = 2 межфирма*/
    /*начинаем закрытие документов перемещения*/
    _tpsi_sale-doc:
    for each tpsi_sale-doc no-lock where
             tpsi_sale-doc.inkas-code = p-inkas-code
         and tpsi_sale-doc.tpsidoc = yes
    on error undo, return error
    :
    if ii = 1 and tpsi_sale-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then next _tpsi_sale-doc.
    if ii = 2 and tpsi_sale-doc.ext-doc-type = {&TDEDT_Ras_Perem} then next _tpsi_sale-doc.
    find first buf_doc-line where
                buf_doc-line.doc-code = tpsi_sale-doc.doc-code no-error .
    if not available buf_doc-line then do:
      find first buf_expense_trn-doc exclusive-lock where
                buf_expense_trn-doc.doc-code = tpsi_sale-doc.doc-code  no-error .
      if not available buf_expense_trn-doc then do:
        find first buf_expense_trn-doc no-lock where
                  buf_expense_trn-doc.doc-code = tpsi_sale-doc.doc-code  no-error .
        if not available buf_expense_trn-doc then do:
          next _tpsi_sale-doc.
        end.
        else do:
          assign
          v-mes =  substitute("Ошибка при проверке наличия ПУСТОГО расходного документа ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5:&3&6"
                                  , tpsi_sale-doc.doc-code
                                  , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                  , {&new-line}
                                  , p-inkas-code
                                  , (p-obj-type + string(p-obj-code))
                                  , "не удается заблокировать документ для удаления" ).

          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes ).
          undo,  return error v-mes.
        end.
      end.
      assign
      buf_expense_trn-doc.status_ = {&wayb}
      .
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
                                  , p-inkas-code
                                  , (p-obj-type + string(p-obj-code))
                                  , error-status:get-message(1)
                                  , return-value ).

          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes ).
          undo,  return error v-mes.
        end.
        else do:
          assign
          v-mes =  substitute("ПУСТОЙ расходный документ ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5 удален"
                                  , tpsi_sale-doc.doc-code
                                  , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                  , {&new-line}
                                  , p-inkas-code
                                  , (p-obj-type + string(p-obj-code))
                            ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes ).
        end.
        delete tpsi_sale-doc.
      end. /*if not available buf_doc-line then do:*/
      else do: /*будем закрывать*/
        find first buf_expense_trn-doc where
                buf_expense_trn-doc.doc-code = tpsi_sale-doc.doc-code .
        assign
        buf_expense_trn-doc.status_ = {&wayb}
        buf_expense_trn-doc.flag    = no
        .
        if buf_expense_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        then v-close-num = 3.
        else v-close-num = 3.
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        { gbl/curobjdt.i buf_expense_trn-doc.obj-type buf_expense_trn-doc.obj-code v-sys-today no-error }
        if error-status:error then do:
          assign
          v-mes =  substitute("Ошибка при определении даты факт на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , buf_expense_trn-doc.obj-type
                                        , buf_expense_trn-doc.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).

          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes ).
          undo,  return error v-mes.
        end.
        if buf_expense_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        then
        assign
        buf_expense_trn-doc.fact-date = v-sys-today
        buf_expense_trn-doc.fact-time = v-time
        buf_expense_trn-doc.is-back-date = no
        .
        else
        assign
        buf_expense_trn-doc.fact-date = ?
        buf_expense_trn-doc.fact-time = v-time
        buf_expense_trn-doc.is-back-date = ?
        .
        do jj = 1 to v-close-num :
          run str/trn-stat.p  (
                input parparentproc             /* parparentproc  */
              , input this-procedure
              , input {&close-doc}              /* parmode        */
              , input tpsi_sale-doc.doc-code    /* pardoc-code    */
              , input yes                       /* parcheck-return*/
              , input g#db-num                  /* pardb-num      */
              , input ?                         /* parin-ov       */
              , input 0                         /* parrsrv-time   */
              , input 0                         /* parload-time   */
              , input ""                        /* parholidays    */
              , input no                         /* parmessage     */
              , output v-was-gds-moving         /* parchg-inv     */
              , output table temp_gds-list  /* table for gds-list*/
          ) no-error.
          if error-status:error  then do:
            assign
            v-mes =  substitute("Ошибка при закрытии расходного документа ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5:&3&6 &7"
                                    , tpsi_sale-doc.doc-code
                                    , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                    , {&new-line}
                                    , p-inkas-code
                                    , (p-obj-type + string(p-obj-code))
                                    , error-status:get-message(1)
                                    , return-value ).

            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input v-mes ).
            undo,  return error v-mes.
          end.
          find first buf_expense_trn-doc where
                  buf_expense_trn-doc.doc-code = tpsi_sale-doc.doc-code .
          if buf_expense_trn-doc.status_ = {&fact} then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("Расходный документ ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5 закрыт"
                                  , tpsi_sale-doc.doc-code
                                  , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                  , {&new-line}
                                  , p-inkas-code
                                  , (p-obj-type + string(p-obj-code))
                                 )).
            find first buf_sale-doc where
                      buf_sale-doc.inkas-code = p-inkas-code
                  and buf_sale-doc.doc-code = tpsi_sale-doc.doc-code .
            buffer-copy buf_expense_trn-doc
            except ps
            to buf_sale-doc.
          end.
        end.
        find first buf_income_trn-doc where
                  buf_income_trn-doc.out-code = tpsi_sale-doc.doc-code no-error .
        if not available buf_income_trn-doc then do:
          assign
          v-mes = substitute("Не найден приходный документ на объекте &5, соответствующий расходному документу ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5"
                                , tpsi_sale-doc.doc-code
                                , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                , {&new-line}
                                , p-inkas-code
                                , (p-obj-type + string(p-obj-code))
                             ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes ).
          undo,  return error v-mes.
        end.
        run str/trn-stat.p  (
              input parparentproc             /* parparentproc  */
            , input this-procedure
            , input {&close-doc}              /* parmode        */
            , input buf_income_trn-doc.doc-code    /* pardoc-code    */
            , input yes                       /* parcheck-return*/
            , input g#db-num                  /* pardb-num      */
            , input ?                         /* parin-ov       */
            , input 0                         /* parrsrv-time   */
            , input 0                         /* parload-time   */
            , input ""                        /* parholidays    */
            , input no                         /* parmessage     */
            , output v-was-gds-moving         /* parchg-inv     */
            , output table temp_gds-list  /* table for gds-list*/
        ) no-error.
        if error-status:error  then do:
          assign
          v-mes =  substitute("Ошибка при закрытии приходного документа ЧУЖИХ товаров &1 с объекта &2&3 для продажи &4 &5:&3&6 &7"
                                  , buf_income_trn-doc.doc-code
                                  , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                                  , {&new-line}
                                  , p-inkas-code
                                  , (p-obj-type + string(p-obj-code))
                                  , error-status:get-message(1)
                                  , return-value ).

          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes ).
          undo,  return error v-mes.
        end.
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Приходный документ ЧУЖИХ товаров &1 по объекту &2&3 для продажи &4 &5 закрыт"
                              , buf_income_trn-doc.doc-code
                              , (tpsi_sale-doc.obj-type + string(tpsi_sale-doc.obj-code))
                              , {&new-line}
                              , p-inkas-code
                              , (p-obj-type + string(p-obj-code))
                              )                 ).
        run saledoc-create  in this-procedure (
                                                 input p-inkas-code
                                                ,input p-host-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,input entry(lookup(buf_income_trn-doc.ext-doc-type, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds})                                              /*p-doc-kind*/
                                                ,input buf_income_trn-doc.office
                                                ,input yes /*p-tpsidoc*/
                                                ,input tpsi_sale-doc.alias-type-price /*p-alias-type-price*/
                                                ,input tpsi_sale-doc.price-obj-type /*p-price-obj-type*/
                                                ,input tpsi_sale-doc.price-obj-code /*p-price-obj-type*/
                                                ,buffer buf_income_trn-doc ) no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 в таблицу связанных документов по продажу:&1&2 &3"
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        , p-inkas-code
                                        , entry(lookup(buf_income_trn-doc.ext-doc-type, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds})
                                       )).
          assign
          v-view-log = yes.
          {&view-log}
          error.
        end.
      end.
    end. /*for each tpsi_sale-doc*/
  end. /*do ii = 1 to 2*/
end. /*doe*/