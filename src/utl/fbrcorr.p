block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbrcorr.p $
$Archive: utl/fbrcorr.p $

Проверка и правка документов производства

Автор: Белоусов Илья Александрович
Дата создания: 05/06/08
Author: Ilia Belousov
Creation date: 05/06/08


Input:
    p-have-correct  as integer
        = 0 - только выводить лог в fbrcorr.txt
        = 1 - корректировать документы

Output:

*/
define input parameter p-have-correct    as character          no-undo.

on write    of fbr-line override do: end.
on delete   of fbr-line override do: end.
on write    of fbr-doc  override do: end.
on delete   of fbr-doc  override do: end.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrcorr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fbrcorr.p $":U .
define variable vss-description as character no-undo init "Проверка и правка документа производства".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }

&scoped-define fbrcorr-delete "delete":U
&scoped-define log-filename "fbrcorr.txt":U
&scoped-define Tabspaces 2
&scoped-define LogLineSize 80

define stream log-stream.

    define variable v-doc-code    as character    no-undo.

    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_fbr-doc
  , buf_fbr-line
on error undo, return error return-value
:
    { gbl/working.i }
    run write-log in this-procedure (
          input 0
        , input "&DLine":U
    ).
    run write-log in this-procedure (
          input 0
        , input ( if p-have-correct = {&fbrcorr-delete} then "Корректировка " else "Проверка " ) + "документов производства."
    ).
    test-fbr-line:
    for each buf_fbr-line exclusive-lock
    on error undo, return error
    :
        assign
            v-doc-code = buf_fbr-line.doc-code
        .
        find first buf_fbr-doc exclusive-lock
             where buf_fbr-doc.doc-code = v-doc-code
        no-error no-wait.
        if not available buf_fbr-doc
        then do:
            if locked buf_fbr-doc
            then do:
                run write-log in this-procedure (
                      input 1
                    , input substitute( "*** Документ производства '&1' заблокирован. Проверка строк невозможна."
                                        , v-doc-code )
                ).
                undo test-fbr-line, next test-fbr-line.
            end.
            else do:
                if p-have-correct = {&fbrcorr-delete}
                then do:
                    delete buf_fbr-line.
                end.
                run write-log in this-procedure (
                      input 1
                    , input substitute( "&1далена строка документа производства '&2'. Не найдена шапка документа."
                                        , ( if p-have-correct = {&fbrcorr-delete} then "У" else "Должна быть у" )
                                        , v-doc-code )
                ).
            end.
        end.
    end.        /* for each buf_fbr-line */
    run test-by-trn-docs in this-procedure .
    { gbl/stopwork.i }
    message
        ( if p-have-correct = {&fbrcorr-delete} then "Корректировка " else "Проверка " ) "документов производства завершена."
        skip "Результат выведен в файл fbrcorr.txt"
        skip "в рабочем каталоге TradeHouse."
    view-as alert-box information
    title ( if p-have-correct = {&fbrcorr-delete} then "Корректировка " else "Проверка " ) + "документов производства".
    run write-log in this-procedure (
          input 0
        , input "&DLine":U
    ).
end.

/*==========================================================================*/
procedure test-by-trn-docs :

    define variable v-have-trn-doc  as logical      no-undo.
    define variable v-doc-code      as character    no-undo.
    define variable v-doc-code-eq   as character    no-undo.
    define variable v-doc-code-as   as character    no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_trn-doc
  , buf_fbr-doc
  , buf_fbr-line
on error undo, return error
:
    test-fbr-doc:
    for each buf_fbr-doc exclusive-lock
    on error undo, return error
    :
        assign
            v-doc-code      = buf_fbr-doc.doc-code
            v-doc-code-eq   = replace( v-doc-code, "-":U, "=":U )
            v-doc-code-as   = replace( v-doc-code, "-":U, "*":U )
            v-have-trn-doc  = yes
        .
        if buf_fbr-doc.status_ = {&fact}
        then do:
            find first buf_trn-doc exclusive-lock
                 where buf_trn-doc.doc-code = v-doc-code
            no-error no-wait.
            if available buf_trn-doc
            then do:
                assign
                    v-have-trn-doc = yes
                .
            end.
            else do:
                if locked buf_trn-doc
                then do:
                    run write-log in this-procedure (
                          input 1
                        , input substitute( "*** Документ списания по производству '&1' заблокирован. Проверка соответствующего документа производства невозможна."
                                            , v-doc-code )
                    ).
                    undo test-fbr-doc, next test-fbr-doc.
                end.
                else do:
                    assign
                        v-have-trn-doc = no
                    .
                end.
            end.
            if v-have-trn-doc = no
            then do:
                find first buf_trn-doc exclusive-lock
                     where buf_trn-doc.doc-code = v-doc-code-eq
                no-error no-wait.
                if available buf_trn-doc
                then do:
                    assign
                        v-have-trn-doc = yes
                    .
                end.
                else do:
                    if locked buf_trn-doc
                    then do:
                        run write-log in this-procedure (
                              input 1
                            , input substitute( "*** Документ прихода по производству '&1' заблокирован. Проверка соответствующего документа производства невозможна."
                                                , v-doc-code )
                        ).
                        undo test-fbr-doc, next test-fbr-doc.
                    end.
                    else do:
                        assign
                            v-have-trn-doc = no
                        .
                    end.
                end.
            end.
            if v-have-trn-doc = no
            then do:
                find first buf_trn-doc exclusive-lock
                     where buf_trn-doc.doc-code = v-doc-code-as
                no-error no-wait.
                if available buf_trn-doc
                then do:
                    assign
                        v-have-trn-doc = yes
                    .
                end.
                else do:
                    if locked buf_trn-doc
                    then do:
                        run write-log in this-procedure (
                              input 1
                            , input substitute( "*** Документ прихода по производству '&1' заблокирован. Проверка соответствующего документа производства невозможна."
                                                , v-doc-code )
                        ).
                        undo test-fbr-doc, next test-fbr-doc.
                    end.
                    else do:
                        assign
                            v-have-trn-doc = no
                        .
                    end.
                end.
            end.
            if v-have-trn-doc = no
            then do:
                run write-log in this-procedure (
                      input 1
                    , input substitute( "&1далён документ производства в статусе 'факт' номер '&2': документ не образует ни одного складского документа."
                                        , ( if p-have-correct = {&fbrcorr-delete} then "У" else "Должен быть у" )
                                        , v-doc-code )
                ).
                if p-have-correct = {&fbrcorr-delete}
                then do:
                    for each buf_fbr-line exclusive-lock
                       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
                    :
                        delete buf_fbr-line.
                    end.
                    delete buf_fbr-doc.
                end.
            end.
        end.
    end.        /* for each buf_fbr-doc */
end.
end procedure. /* test-by-trn-docs */

/*==========================================================================*/
procedure write-log :
define input parameter p-log-level  as integer      no-undo.
define input parameter p-out-string as character    no-undo.

do
on error undo, return error
:
    output stream log-stream to value( {&log-filename} ) append.
    put stream log-stream unformatted
        {&new-line}
    .
    put stream log-stream unformatted
        ( if p-log-level = 0
          or p-out-string = "&DLine":U
          or p-out-string = "&Line":U
          then "":U
          else cur-time-string-sec() + fill( " ":U, p-log-level * {&Tabspaces} ) )
    .
    put stream log-stream unformatted
        ( if p-out-string = "&Line":U
          then fill( "-":U, {&LogLineSize} )
          else if p-out-string = "&DLine":U
               then fill( "=":U, {&LogLineSize} )
               else p-out-string )
    .
    output stream log-stream close.
end.
end procedure. /* write-log */