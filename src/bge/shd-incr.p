block-level on error undo, throw.
/*

$Revision: a61e6bb0c7e0, 2871, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: shd-incr.p $
$Archive: bge/shd-incr.p $

Инкрементальный экспорт во Внешнюю Бухгалтерию документов, чеков и справочников

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-db-num         as integer    no-undo.    /* БД, по объктам которой необходим экспорт */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-obj-list       as character  no-undo. /* Список объектов для p-range = 3 */
define input parameter p-need-checks    as logical    no-undo. /* надо ли экспортировать чеки по документам */
define input parameter p-doc-rvs        as logical    no-undo. /* надо ли выгружать сверки до/после слива по топливным приходным накладным */

define variable vss-revision    as character no-undo init "$Revision: a61e6bb0c7e0, 2871, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shd-incr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shd-incr.p $":U .
define variable vss-description as character no-undo init "Инкрементальный экспорт во Внешнюю Бухгалтерию документов, чеков и справочников".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/temphost.i }
{ bge/bge-xml.i  }
{ gbl/waitfram.i }

&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-xml-f-nam-short   as character no-undo.
    define variable v-out-dir           as character            no-undo.
    define variable v-locked            as logical              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-oper-num          as integer              no-undo. /* номер операции*/
    define variable v-fact-order-from   like ub.stk-tot.fact-order no-undo.
    define variable v-fact-order-to     like ub.stk-tot.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-today             as date                 no-undo.
    define variable v-time              as integer              no-undo.
    define variable v-obj-num           as character            no-undo.
    define variable v-obj-list          as character            no-undo.
    define variable v-obj-str           as character            no-undo.

    define buffer buf_temp_doc-code     for temp_doc-code.
    define buffer buf_temp_del-doc-code for temp_del-doc-code.
    define buffer buf_temp_pr-doc-num   for temp_pr-doc-num.
    define buffer buf_temp_ord-doc-code for temp_ord-doc-code.
    define buffer buf_clients-attr for ub.clients-attr.
do
for buf_temp_doc-code
  , buf_temp_del-doc-code
  , buf_temp_pr-doc-num
  , buf_temp_ord-doc-code
on error undo, return error
:
    run cur-time in this-procedure ( output v-today , output v-time ).
    run bge-xml-out-dir in this-procedure ( output v-out-dir
                                          , output v-log-file-name
                                          ).
    run bge-xml-read-config in this-procedure ( input v-today
                                              , input p-db-num
                                              ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "Ошибка чтения параметров экспорта. &1. &2. Для экспорта данных будут приняты параметры по умолчанию."
                                , return-value, trim( error-status :get-message( 1 ) ) )
        ).
    end.
      run xml-bge-filename in this-procedure (
            input "doc"
          , input "document"
          , input yes
          , output v-xml-file-name
          , output v-log-file-name
          , output v-locked
      ).
      if v-locked = yes
      then do:
          run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
              , input 1
              , input "*** Ошибка выгрузки: Файл выгрузки заблокирован другим процессом."
          ).
          undo, return error .
      end.
      run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
          , input 1
          , input substitute( "Начало выгрузки в файл &1", replace( v-xml-file-name, "/", "\" ) + "xm1" )
      ).
      run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
          , input 1
          , input substitute( "................с параметрами: Номер базы: &1.", p-db-num )
      ).
      run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
          , input 1
          , input substitute( "................с параметрами: ... список объектов: &1", p-obj-list )
      ).
      run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
          , input 1
          , input substitute( "................с параметрами: ... надо ли выгружать чеки: &1", p-need-checks )
      ).
      run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
          , input 1
          , input substitute( "................с параметрами: ... надо ли выгружать сверки до/после слива: &1", p-doc-rvs )
      ).
      RUN init-temphost.
      assign
          v-log-string = ", по всем фирмам"
      .
      if p-range <> 3
      then do:
          run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
              , input 1
              , input "Неверно заданы объекты для выгрузки."
          ).
          undo, return error .
      end.
      for each temp-obj
      :
          delete temp-obj.
      end.
      do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
      :
          create temp-obj.
          assign
              temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
              temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
          no-error .
          if error-status :error
          then do:
              run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                  , input 1
                  , input "Ошибка чтения списка объектов."
              ).
              undo, return error .
          end.
          { gbl/hostcode.i temp-obj.obj-type temp-obj.obj-code temp-obj.host-code no-error }
          if error-status :error
          then do:
              run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                  , input 1
                  , input "Не найдена фирма для объекта" + temp-obj.obj-type + string( temp-obj.obj-code )
              ).
              undo, return error .
          end.
      end.
      assign
          v-log-string = ", по объектам: " + p-obj-list
      .
      run bge-xml-write-header in this-procedure (
            input v-xml-file-name
          , input v-xml-file-name + "xml"
          , input {&version-string}
          , input p-db-num
          , input ?
          , input 0
          , input ?
          , input 0
          , input p-obj-list
          , input ""
          , input yes
          , input yes
          , input yes
          , input yes
          , input yes
          , input yes
          , input yes
          , input no
      ).
      object-of-list:
      for each temp-obj
      :   
          run bge/lock-bge-incr.p (input temp-obj.obj-type, input temp-obj.obj-code, buffer buf_clients-attr) no-error.
          if error-status:error then do:
            run wp-XMLWriteLog in this-procedure (
                   input v-log-file-name
                  ,input 1
                  ,input "Ошибка экспорта документов по объекту " + temp-obj.obj-type + string( temp-obj.obj-code ) + ". " + error-status:get-message(1)
              ).
              next object-of-list. /* пойдём дальше по списку объектов */
          end.
          
          run export-docs-by-object in this-procedure (
                input temp-obj.host-code
              , input temp-obj.obj-type
              , input temp-obj.obj-code
          ) no-error.
          if error-status :error
          then do:
              run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                  , input 1
                  , input "Ошибка экспорта документов по объекту " + temp-obj.obj-type + string( temp-obj.obj-code )
              ).
              find current buf_clients-attr no-lock. /* снять блокировку */
              next object-of-list.
          end.
          run cb-fill_bge-xml_clients in this-procedure (
                input temp-obj.obj-type
              , input temp-obj.obj-code
          ).
          find current buf_clients-attr no-lock. /* снять блокировку */
      end.
      if v-bge-xml-bgeflold <> "oracle"
      then do:
        run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
      end.
    if v-bge-xml-bgeflold <> "oracle"
    then do:
        
      v-xml-f-nam-short = replace(v-xml-file-name, "/", "\").
      v-xml-f-nam-short = entry(num-entries(v-xml-f-nam-short, "\"), v-xml-f-nam-short, "\"). /* достанем только имя файла */
      v-xml-f-nam-short = right-trim(v-xml-f-nam-short, ".").
      v-xml-f-nam-short = "_" + v-xml-f-nam-short.
      
      run bge/cat-firm.p (
            input "list":U
          , input 0
          , input table temp_bge-xml_clients
          , v-xml-f-nam-short
      ).
      run bge/cat-good.p (
            input "good-ext,list":U
          , input table temp_bge-xml_goods
          , v-xml-f-nam-short
      ).
      run bge/cat-dcrt.p (
            input "list":U
          , input table temp_bge-xml_dis-card
          , v-xml-f-nam-short
      ).
    end.
    for each buf_temp_doc-code
    on error undo, return error
    :
        run bge/setbgedt.p (
              input {&table_trn-doc}
            , input buf_temp_doc-code.doc-code
            , input v-today
        ).
    end.        /* for each buf_temp_doc-code */
    for each buf_temp_pr-doc-num
    on error undo, return error
    :
        run bge/setbgedt.p ( input {&table_price-doc}
                           , input buf_temp_pr-doc-num.doc-num
                           , input v-today
                           ).
    end.        /* for each buf_temp_pr-doc-num */
    for each buf_temp_del-doc-code
    on error undo, return error
    :
        run bge/setbgedt.p (
              input {&table_c-trn-doc}
            , input buf_temp_del-doc-code.doc-code
            , input v-today
        ).
    end.        /* for each buf_temp_doc-code */
    for each buf_temp_ord-doc-code
    on error undo, return error
    :
      run bge/setbgedt.p ( input {&table_ord-doc}
                        , input buf_temp_ord-doc-code.doc-code
                        , input v-today
                        ) .
    end. /* for each buf_temp-ord-doc-code */
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1 " , replace( v-xml-file-name, "/", "\" ) + "xml" )
    ).
end.

/*==========================================================================*/
procedure export-docs-by-object :
do
on error undo, return error
:
define input parameter p-host-code  as integer      no-undo.
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.

    define variable v-start-date        as date         no-undo.
    define variable v-not-exists        as logical      no-undo.
    define variable v-archive-ok        as logical      no-undo.
    define variable v-comment           as character    no-undo.

    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input " > Экспорт документов по объекту " + p-obj-type + string( p-obj-code )
    ).
/*---S-------- Расчет архивов на объекте ------------------*/
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 2
        , input "Расчет архивов"
    ).
    run bge/bge-ahzs.p (
          input p-obj-type
        , input p-obj-code
        , input yes
        , input yes
        , input no
        , input v-today
        , input v-today
        , output v-archive-ok
        , output v-comment
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка проверки архивов на объекте."
        skip "Тип объекта:" p-obj-type
        skip "Код объекта:" p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-archive-ok = no
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Документы по объекту &1 &2 на дату &3 не будут выгружены. Архивы по объекту в заданном интервале дат не целостные. &4."
                                    , p-obj-type
                                    , p-obj-code
                                    , v-today
                                    , v-comment       )
        ).
        undo, return error .
    end.
/*---E-------- Расчет архивов на объекте ------------------*/
    run get-start-date in this-procedure (
          input p-obj-type
        , input p-obj-code
        , output v-start-date
        , output v-not-exists
    ).
    if v-not-exists = yes
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 2
            , input "Нет архивов или документов для выгрузки. Невозможно выгрузить данные по документам."
        ).
        undo, return error .
    end.        /* if v-not-exists = yes  */
    assign
      v-obj-str = substitute( "Инкрементальная выгрузка по объекту &1 &2"
                            , p-obj-type
                            , p-obj-code
                            )
    .
    run waitfram-show in this-procedure ( input v-obj-str ) .
    run bge/doc-incr.p (
          input p-host-code
        , input v-today
        , input v-start-date
        , input p-obj-type
        , input p-obj-code
        , input yes   /* p-pay-code*/
        , input yes   /* p-cst*/
        , input yes   /* p-parts*/
        , input yes   /* p-chk-pay-code */
        , input yes   /* p-pay-desk     */
        , input yes   /* p-pay-desk-cards     */
        , input p-need-checks
        , input p-doc-rvs
        , input v-xml-file-name
        , input v-log-file-name
        , input this-procedure :handle
        , input ?
        , input ?
        , input ?
        , input ?
    ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка экспорта документов. &1. &2", return-value, trim(error-status :get-message(1)) )
        ).
    end.
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( " < Экспорт документов по объекту &1 &2 завершен.", p-obj-type, p-obj-code )
    ).
    run waitfram-hide in this-procedure .
end.
end procedure. /* export-docs-by-object */

/*==========================================================================*/
procedure get-start-date :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define output parameter p-start-date    as date         no-undo.
define output parameter p-not-exist     as logical      no-undo.

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_ot-tot        for ub.ot-tot.

    find-first-ot-tot:
    for each buf_ot-tot no-lock
       where buf_ot-tot.obj-type = p-obj-type
         and buf_ot-tot.obj-code = p-obj-code
    use-index obj-ot
    :
        find first buf_trn-doc no-lock
             where buf_trn-doc.doc-code = buf_ot-tot.doc-code
        no-error.
        if available buf_trn-doc
        and buf_trn-doc.fact-date <> ?
        then do:
            assign
                p-not-exist     = no
                p-start-date    = buf_trn-doc.fact-date
            .
            leave find-first-ot-tot.
        end.        /* if available buf_trn-doc  */
        else do:
            find first buf_price-doc no-lock
                 where buf_price-doc.doc-num = buf_ot-tot.doc-code
            no-error.
            if available buf_price-doc
            and buf_price-doc.fact-date <> ?
            then do:
                assign
                    p-not-exist     = no
                    p-start-date    = buf_price-doc.fact-date
                .
                leave find-first-ot-tot.
            end.        /* if available buf_trn-doc  */
        end.
    end.        /* for each buf_ot-tot no-lock */
end.
end procedure. /* get-start-date */

/*==========================================================================*/
procedure fill-temp-doc-code :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.

    define buffer buf_temp_doc-code     for temp_doc-code.

    create buf_temp_doc-code.
    assign
        buf_temp_doc-code.doc-code = p-doc-code
    .
end.
end procedure. /* fill-temp-doc-code */

/*==========================================================================*/
procedure fill-temp-del-doc-code :
do
on error undo, return error
:
define input parameter p-doc-code   as character    no-undo.

    define buffer buf_temp_del-doc-code     for temp_del-doc-code.

    create buf_temp_del-doc-code.
    assign
        buf_temp_del-doc-code.doc-code = p-doc-code
    .
end.
end procedure. /* fill-temp-doc-code */

/*==========================================================================*/
procedure fill-temp-pr-doc-num :
define input parameter p-doc-num as character    no-undo.

    define buffer buf_temp_pr-doc-num       for temp_pr-doc-num.
do
for buf_temp_pr-doc-num
on error undo, return error
:

    create buf_temp_pr-doc-num.
    assign
        buf_temp_pr-doc-num.doc-num = p-doc-num
    .
end.
end procedure. /* fill-temp-doc-code */

/*==========================================================================*/
procedure fill-temp-ord-doc-code :
  define input  parameter p-doc-code  as character no-undo .

  define buffer buf_temp_ord-doc-code for temp_ord-doc-code.
do for buf_temp_ord-doc-code
on error undo, return error return-value
:
  find first buf_temp_ord-doc-code
    where buf_temp_ord-doc-code.doc-code = p-doc-code
  no-error .
  if not available buf_temp_ord-doc-code
  then do:
    create buf_temp_ord-doc-code.
    assign
      buf_temp_ord-doc-code.doc-code = p-doc-code
    .
  end.
end.

end procedure. /* fill-temp-ord-doc-code */

/*==========================================================================*/
procedure cb-fill_bge-xml_goods :
define input parameter p-gds-code   as integer          no-undo.

do
on error undo, return error
:
    find first temp_bge-xml_goods
         where temp_bge-xml_goods.gds-code = p-gds-code
    no-error.
    if not available temp_bge-xml_goods
    then do:
        create temp_bge-xml_goods.
        assign
            temp_bge-xml_goods.gds-code = p-gds-code
        .
    end.
end.
end procedure. /* cb-fill_bge-xml_goods */


/*==========================================================================*/
procedure cb-fill_bge-xml_clients :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.

    define buffer buf_temp_bge-xml_clients      for temp_bge-xml_clients.
do
for buf_temp_bge-xml_clients
on error undo, return error
:
    find first buf_temp_bge-xml_clients
         where buf_temp_bge-xml_clients.obj-type = p-obj-type
           and buf_temp_bge-xml_clients.obj-code = p-obj-code
    no-error.
    if not available buf_temp_bge-xml_clients
    then do:
        create buf_temp_bge-xml_clients.
        assign
            buf_temp_bge-xml_clients.obj-type = p-obj-type
            buf_temp_bge-xml_clients.obj-code = p-obj-code
        .
    end.
end.
end procedure. /* cb-fill_bge-xml_goods */

/*==========================================================================*/
procedure cb-fill_bge-xml_dis-card :
define input parameter p-d-card as character        no-undo.

    define buffer buf_temp_bge-xml_dis-card     for temp_bge-xml_dis-card.
do
for buf_temp_bge-xml_dis-card
on error undo, return error
:
    find first buf_temp_bge-xml_dis-card
         where buf_temp_bge-xml_dis-card.d-card = p-d-card
    no-error.
    if not available buf_temp_bge-xml_dis-card
    then do:
        create buf_temp_bge-xml_dis-card.
        assign
            buf_temp_bge-xml_dis-card.d-card = p-d-card
        .
    end.
end.
end procedure. /* cb-fill_bge-xml_goods */