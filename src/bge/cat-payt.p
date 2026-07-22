block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cat-payt.p $
$Archive: bge/cat-payt.p $

Выгрузка справочника видов оплат

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-rec-amount as integer      no-undo.
define input parameter p-rec-list   as character    no-undo.
define input parameter p-host-code  as integer      no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cat-payt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cat-payt.p $":U .
define variable vss-description as character no-undo init "Выгрузка справочника видов оплат".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bge-xml.i  }

&scop out-file-name "paytype"
&scop version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

do
on error undo, return error
:
    define variable v-xml-file-name     as character            no-undo. /* имя файла вывода */
    define variable v-log-file-name     as character            no-undo. /* имя log-файла */

    define buffer buf_pay-type      for ub.pay-type.

    run bge/bge-head.p (
          input "dict"
        , input {&out-file-name}
        , input "XML - Вывод справочника видов оплат"
        , input no
        , output v-xml-file-name
        , output v-log-file-name
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при создании файла выгрузки."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run bge-xml-write-header in this-procedure (
          input v-xml-file-name
        , input {&out-file-name}
        , input {&version-string}
        , input 0
        , input ?
        , input 0
        , input ?
        , input 0
        , input "":U
        , input "":U
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
    ).
    output stream stmxmlout to value( v-xml-file-name + "xm1" ) convert target "1251" append.
    for each buf_pay-type no-lock
    :
        run write-body in this-procedure (
              input buf_pay-type.obj-code
            , input v-xml-file-name
            , input v-log-file-name
        ) no-error.
        if error-status :error
        then do:
            run wp-XMLWriteLog(
                  input v-log-file-name
                , input 1
                , input substitute(  "*** ERR: *** Ошибка выгрузки вида оплаты с кодом &1. &2. &3.", buf_pay-type.obj-code, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
            ).
        end.
    end.        /* for each buf_dis-card */
    output stream stmxmlout close.
    run xml-bge-write-footer in this-procedure (
        input v-xml-file-name
    ).
end.


/*==========================================================================*/
procedure write-body :
do
on error undo, return error
:
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-log-file-name  as character    no-undo.

    define buffer buf_pay-type      for ub.pay-type.

    find first buf_pay-type no-lock
         where buf_pay-type.obj-code = p-obj-code
    .

run wp-XMLTagOpen( input 2, input {&out-file-name}, input "").
run wp-XMLTagPut( input 3, "payTypeID"      , input string( buf_pay-type.obj-code ), input 0 ).
run wp-XMLTagPut( input 3, "name"           , input string( buf_pay-type.obj-name ), input 0 ).
run wp-XMLTagClose( input 2, input {&out-file-name} ).


end.
end procedure. /* write-body */