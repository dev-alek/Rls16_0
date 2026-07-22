block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrdel.p $
$Archive: str/fbrdel.p $

Удаление документов производства и внутренних перемещений при удалении закрытой продажи

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-sale-code      as character - номер документа продажи

Output:



*/
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-sale-code      as character        no-undo.
define input parameter p-chip-num       like ub.c-trn-doc.chip-num no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrdel.p $":U .
define variable vss-description as character no-undo init "Удаление документов производства и внутренних перемещений при удалении закрытой продажи".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/fbrcode.i  }
{ str/fbrlib.i   }
{ gbl/cur-time.i }



    define variable v-chip-num like ub.c-trn-doc.chip-num no-undo .

    define buffer buf_temp_fbrcode-doc-code        for temp_fbrcode-doc-code.
    define buffer buf_trn-doc                   for trn-doc.

do
for buf_temp_fbrcode-doc-code
  , buf_trn-doc
on error undo, return error
:
    run fbrcode-fill-fbr-by-sale-or-pln in this-procedure (
        input p-sale-code
    ).
/*    for each buf_temp_fbrcode-doc-code*/
/*    by buf_temp_fbrcode-doc-code.order descending*/
/*    on error undo, return error*/
/*    :*/
/*        output to "d:\___fbr.txt" append.*/
/*            put unformatted*/
/*                substitute( "Вид: &2; Номер: &3; Тип: &4; Порядк.номер: &5&1"*/
/*                            , {&new-line}*/
/*                            , buf_temp_fbrcode-doc-code.rec-type*/
/*                            , buf_temp_fbrcode-doc-code.doc-code*/
/*                            , buf_temp_fbrcode-doc-code.doc-type*/
/*                            , buf_temp_fbrcode-doc-code.order*/
/*                          )*/
/*            .*/
/*        output close.*/
/*    end.*/
/*    undo, return error .*/
    for each buf_temp_fbrcode-doc-code
    by buf_temp_fbrcode-doc-code.order descending
    on error undo, return error
    :
        case buf_temp_fbrcode-doc-code.rec-type
        :
            when {&manufacturing}
            then do:
                run fbrlib-delete-fact-fbr-doc in this-procedure (
                    input parparentproc
                   ,input buf_temp_fbrcode-doc-code.doc-code
                   ,input p-chip-num
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка удаления документа производства."
                        skip(1)
                        skip "Номер документа:" buf_temp_fbrcode-doc-code.doc-code
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.        /* when {&manufacturing} */
            when {&shop}
            or when {&stock}
            then do:
                find first buf_trn-doc exclusive-lock
                     where buf_trn-doc.doc-code = buf_temp_fbrcode-doc-code.doc-code
                no-error.
                if available buf_trn-doc
                then do:
                run fbrlib-delete-fact-trn-doc in this-procedure (
                      input parparentproc
                    , input buf_temp_fbrcode-doc-code.doc-code
                    , input buf_temp_fbrcode-doc-code.doc-type
                    , input p-chip-num
                    , output v-chip-num
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip(1)
                        skip "Ошибка удаления складского документа."
                        skip(1)
                        skip "Номер документа:" buf_temp_fbrcode-doc-code.doc-code
                        skip "Тип документа:  " buf_temp_fbrcode-doc-code.doc-type
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
                end.
            end.        /* when {&shop} */
        end case.       /* case buf_temp_fbrcode-doc-code.rec-type */
    end.
end.