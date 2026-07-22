block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: shfdincr.p $
$Archive: bge/shfdincr.p $

Инкрементальный экспорт во Внешнюю Бухгалтерию платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/04
Author: Bakhtadze Natalya
Creation date: 12/09/04

*/

define input parameter p-db-num         as integer    no-undo. /* БД, по объктам которой необходим экспорт */
define input parameter p-range          as integer    no-undo. /* Диапазон: 1 - глобально, 2 - по тек. фирме, 3 - список объектов */
define input parameter p-host-code      as integer    no-undo .
define input parameter p-obj-list       as character  no-undo. /* Список объектов для p-range = 3 */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shfdincr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/shfdincr.p $":U .
define variable vss-description as character no-undo init "Инкрементальный экспорт во Внешнюю Бухгалтерию платежей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/temphost.i
  &share-options="new shared"
}
{ bge/bge-xml.i  }

do
on error undo, return error
:

&scop version-string "14.0 " + replace( vss-revision + vss-date, "$", " " )

    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */
    define variable v-out-dir           as character            no-undo.
    define variable v-locked            as logical              no-undo.
    define variable v-log-string        as character            no-undo. /* имя log-файла */
    define variable v-oper-num          as integer              no-undo. /* номер операции*/
    define variable v-fact-order-from   like ub.fin-doc.fact-order no-undo.
    define variable v-fact-order-to     like ub.fin-doc.fact-order no-undo.
    define variable v-docs-exists       as logical              no-undo.
    define variable v-obj-counter       as integer              no-undo.
    define variable v-today             as date                 no-undo.
    define variable v-time              as integer              no-undo.
    define variable v-obj-type          as character            no-undo.
    define variable v-obj-code          as integer              no-undo.
    define variable v-host-code         as integer              no-undo.
    define variable v-host-str          as character            no-undo init "" .

    define buffer buf_temp_fin-doc-code        for temp_fin-doc-code.
    define buffer buf_temp_del-fin-doc-code    for temp_del-fin-doc-code.

    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
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
          input "findoc"
        , input "finDocument"
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
    CASE p-range:
      when 1 then do:
        run init-temphost.
        assign
            v-log-string = " по всем фирмам"
        .
      end.
      when 2 then do:
        for each temp-host:
          delete temp-host.
        end.
        create temp-host.
        assign
        temp-host.host-code = p-host-code
        no-error .
        if error-status:error
        or not can-find(first ub.sysconf no-lock where ub.sysconf.host-code = temp-host.host-code)
        then do:
          run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
              , input 1
              , input substitute("Не найдена фирма &1", p-host-code)
          ).
          undo, return error .
        end.
        assign
            v-log-string = substitute(" по фирме: &1", p-host-code)
        .
      end. /*when 2*/
      when 3 then do:
        for each temp-host:
          delete temp-host.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2  :
          assign
          v-obj-type = entry( (v-obj-counter * 2 ) - 1 , p-obj-list )     .
          v-obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )  .

          create temp-obj.
          assign
          temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
          temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
          no-error .
          { gbl/hostcode.i v-obj-type v-obj-code  v-host-code no-error }
          if error-status :error  then do:
              run wp-XMLWriteLog in this-procedure (
                  input v-log-file-name
                  , input 1
                  , input "Не найдена фирма для объекта" + v-obj-type + string( v-obj-code )
              ).
              undo, return error .
          end.

          if not can-find ( first temp-host where temp-host.host-code = v-host-code) then do:
            v-host-str = v-host-str + "," + string(v-host-code).
            create temp-host.
            assign
              temp-host.host-code = v-host-code
            no-error .
            if error-status :error  then do:
                run wp-XMLWriteLog in this-procedure ( input v-log-file-name
                                                     , input 1
                                                     , input substitute( "Ошибка чтения списка объектов. &1&2&1&3&1&4"
                                                                       , {&new-line}
                                                                       , return-value
                                                                       , trim(error-status :get-message(1))
                                                                       , trim(error-status :get-message(2))
                                                                       )
                                                     ).
                undo, return error return-value . /* --->>>--- */
            end.
          end.
        end.
        assign
        v-log-string = ", по объектам: " + p-obj-list
        .
      end. /*when 3*/
    END CASE.
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
        , input "":U
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input yes
        , input no
    ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка записи шапки файла. Процедура: &1 (v.&2 &3). &4. &5"
                                , vss-workfile
                                , vss-revision
                                , vss-description
                                , return-value
                                , trim( error-status :get-message( 1 ) )
                                )
        ).
        undo, return error.
    end.
    host-of-list:
    for each temp-host
    :
        run export-docs-by-host in this-procedure (
              input temp-host.host-code
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog in this-procedure (
                input v-log-file-name
                , input 1
                , input "Ошибка экспорта платежей по фирме " + string( temp-host.host-code )
            ).
            next host-of-list.
        end.
    end.
    run xml-bge-write-footer in this-procedure ( input v-xml-file-name ).
    for each buf_temp_fin-doc-code
    on error undo, return error
    :
        run bge/setbgefd.p (
              input "fin-doc":U
            , input buf_temp_fin-doc-code.host-code
            , input buf_temp_fin-doc-code.fin-doc-code
            , input 0 /*corr-user-db-num*/
            , input 0 /*chip-num*/
            , input v-today
        ).
    end.        /* for each buf_temp_fin-doc-code */
    for each buf_temp_del-fin-doc-code
    on error undo, return error
    :
        run bge/setbgefd.p (
              input "c-fin-doc":U
            , input buf_temp_del-fin-doc-code.host-code
            , input buf_temp_del-fin-doc-code.fin-doc-code
            , input buf_temp_del-fin-doc-code.corr-user-db-num
            , input buf_temp_del-fin-doc-code.chip-num
            , input v-today
        ).
    end.        /* for each buf_temp_fin-doc-code */
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1 " , replace( v-xml-file-name, "/", "\" ) + "xml" )
    ).
end.

/*==========================================================================*/
procedure export-docs-by-host :
do
on error undo, return error
:
define input parameter p-host-code  as integer      no-undo.

    define variable v-start-date    as date         no-undo.
    define variable v-not-exists    as logical      no-undo.

    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input " > Экспорт платежей по фирме " +  string( p-host-code )
    ).
    run get-start-date in this-procedure (
          input p-host-code
        , output v-start-date
        , output v-not-exists
    ).
    if v-not-exists = yes
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 2
            , input "Нет платежей выгрузки. Невозможно выгрузить данные по платежам."
        ).
        undo, return error .
    end.        /* if v-not-exists = yes  */
    run bge/fdocincr.p (
          input p-range
        , input p-db-num
        , input p-obj-list
        , input p-host-code
        , input v-today
        , input v-start-date
        , input v-xml-file-name
        , input v-log-file-name
        , input this-procedure :handle
        , input ?
        , input ?
    ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка экспорта платежей. &1. &2", return-value, trim(error-status :get-message(1)) )
        ).
    end.
    run wp-XMLWriteLog in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( " < Экспорт платежей по фирме &1 завершен.", p-host-code )
    ).
end.
end procedure. /* export-docs-by-host */

/*==========================================================================*/
procedure get-start-date :
do
on error undo, return error
:
define input parameter p-host-code       as integer      no-undo.
define output parameter p-start-date    as date         no-undo.
define output parameter p-not-exist     as logical      no-undo init yes.

    define buffer buf_fin-doc       for ub.fin-doc.

    find-first-fin-doc:
    for each buf_fin-doc no-lock
       where buf_fin-doc.host-code = p-host-code
    :
        if buf_fin-doc.fact-date <> ?
        then do:
            assign
                p-not-exist     = no
                p-start-date    = buf_fin-doc.fact-date
            .
            leave find-first-fin-doc.
        end.        /* if available buf_fin-doc  */
    end.        /* for each buf_fin-doc no-lock */
end.
end procedure. /* get-start-date */

/*==========================================================================*/
procedure fill-temp-fin-doc-code :
do
on error undo, return error
:
define input parameter p-host-code   as integer    no-undo.
define input parameter p-fin-doc-code   as integer    no-undo.
define input parameter p-corr-user-db-num as integer no-undo .
define input parameter p-chip-num         as integer no-undo .


    define buffer buf_temp_fin-doc-code     for temp_fin-doc-code.

    create buf_temp_fin-doc-code.
    assign
    buf_temp_fin-doc-code.host-code    = p-host-code
    buf_temp_fin-doc-code.fin-doc-code = p-fin-doc-code
    .
end.
end procedure. /* fill-temp-doc-code */

/*==========================================================================*/
procedure fill-temp-del-fin-doc-code :
do
on error undo, return error
:
define input parameter p-host-code   as integer    no-undo.
define input parameter p-fin-doc-code   as integer  no-undo.
define input parameter p-corr-user-db-num as integer no-undo .
define input parameter p-chip-num         as integer no-undo .

define buffer buf_temp_del-fin-doc-code     for temp_del-fin-doc-code.

    create buf_temp_del-fin-doc-code.
    assign
    buf_temp_del-fin-doc-code.host-code        = p-host-code
    buf_temp_del-fin-doc-code.fin-doc-code     = p-fin-doc-code
    buf_temp_del-fin-doc-code.corr-user-db-num = p-corr-user-db-num
    buf_temp_del-fin-doc-code.chip-num         = p-chip-num
    .
end.
end procedure. /* fill-temp-doc-code */