/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работы с планом-меню и счет-заказом.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*==========================================================================*/
procedure fbrpln-create-line :
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-fbr-obj-type   as character    no-undo.
define input parameter p-fbr-obj-code   as integer      no-undo.
define input parameter p-silence        as logical      no-undo.
define input parameter p-qnty           as decimal      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.
do
for buf_fbr-pln
  , buf_fbr-pln-line
  , buf_goods
on error undo, return error
:
    find first buf_fbr-pln no-lock
         where buf_fbr-pln.doc-code = p-doc-code
    .
    if buf_fbr-pln.status_ <> {&g___new}
    then do:
        if p-silence = no
        then do:
            message
                skip "Добавить строки можно только"
                skip "в документ в статусе 'новый'"
            view-as alert-box error.
        end.
        undo, return error .
    end.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if p-recipe-code <> ""
    and p-fbr-obj-type = ""
    and p-fbr-obj-code = 0
    then do:
        if p-silence = no
        then do:
            message
                skip "Не задан объект для производства товара с рецептом."
                skip "Товар: " buf_goods.artic buf_goods.gds-name
                skip(1)
                skip "Товар не может быть включен в план-меню."
            view-as alert-box error.
        end.
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-pln-line.
        assign
            buf_fbr-pln-line.doc-code       = p-doc-code
            buf_fbr-pln-line.gds-code       = p-gds-code
            buf_fbr-pln-line.recipe-code    = p-recipe-code
            buf_fbr-pln-line.obj-type       = buf_fbr-pln.obj-type
            buf_fbr-pln-line.obj-code       = buf_fbr-pln.obj-code
            buf_fbr-pln-line.doc-type       = buf_fbr-pln.doc-type
            buf_fbr-pln-line.fact-qnty      = p-qnty
            buf_fbr-pln-line.artic          = buf_goods.artic
            buf_fbr-pln-line.prod-type      = buf_goods.prod-type
            buf_fbr-pln-line.prod-code      = buf_goods.prod-code
            buf_fbr-pln-line.fbr-obj-type   = p-fbr-obj-type
            buf_fbr-pln-line.fbr-obj-code   = p-fbr-obj-code
            buf_fbr-pln-line.status_        = buf_fbr-pln.status_
        .
    end.        /* do transaction */
end.
end procedure. /* fbrpln-create-line */

/*==========================================================================*/
procedure fbrpln-create-doc :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-doc-type   as character    no-undo.
define input parameter p-db-remote  as logical          no-undo.
define input parameter p-userid     as character        no-undo.
define output parameter p-doc-code  as character    no-undo.

    define variable v-today     as date           no-undo.
    define variable v-time      as integer        no-undo.
    define variable v-host-code as integer        no-undo.
    define variable v-doc-code  as character      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_fbr-pln
on error undo, return error
:

    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    run fbrpln-doc-code (
          input p-obj-type
        , input p-obj-code
        , input p-db-remote
        , output v-doc-code
    ).
    create buf_fbr-pln.
    assign
        buf_fbr-pln.doc-code        = v-doc-code
        buf_fbr-pln.doc-type        = p-doc-type
        buf_fbr-pln.obj-type        = p-obj-type
        buf_fbr-pln.obj-code        = p-obj-code
        buf_fbr-pln.doc-date        = v-today
        buf_fbr-pln.creid           = p-userid
        buf_fbr-pln.PS              = ""
        buf_fbr-pln.fact-date       = ?
        buf_fbr-pln.fact-time       = ?
        buf_fbr-pln.fact-num        = 0
        buf_fbr-pln.fact-order      = 0
        buf_fbr-pln.host-code       = v-host-code
        buf_fbr-pln.status_         = {&g___new}
        buf_fbr-pln.sys-date        = v-today
        buf_fbr-pln.sys-time-int    = v-time
        buf_fbr-pln.sys-time        = string( v-time, "HH:MM:SS" )
        buf_fbr-pln.user-name       = p-userid
    .
    assign
        p-doc-code = buf_fbr-pln.doc-code
    .
end.
end procedure. /* fbrpln-create-doc */


/*==========================================================================*/
procedure fbrpln-create-fbr-doc :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-pln-doc-code   as character        no-undo.
define input parameter p-db-remote      as logical          no-undo.
define input parameter p-userid         as character        no-undo.
define output parameter p-doc-code      as character        no-undo.

    define variable v-today         as date             no-undo.
    define variable v-host-code     as integer          no-undo.
    define variable v-base-code     as integer          no-undo.

    define buffer buf_curr-accnt    for curr-accnt.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_curr-accnt
  , buf_fbr-doc
  , buf_fbr-pln
on error undo, return error
:
    /*
      find first buf_fbr-pln no-lock
           where buf_fbr-pln.doc-code = p-pln-doc-code
    .
    */

    { gbl/curobjdt.i
        p-obj-type
        p-obj-code
        v-today
    }
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    { gbl/basecode.i
        v-host-code
        v-base-code
    }
    find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
          and buf_curr-accnt.exch-date <= v-today
    use-index pi
    no-error.
    if not available buf_curr-accnt
    then do:
        message
            "На дату" v-today "неизвестен курс базовой валюты."
        view-as alert-box error.
        undo, return error.
    end.
    run doc-code in this-procedure (
          input  "main"
        , input  p-obj-type
        , input  p-obj-code
        , input  ?
        , output p-doc-code
    ) no-error.
    if error-status:error
    then do:
        message
            "Ошибка при генерации номера документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
        view-as alert-box error.
        return error.
    end.
    run trg/chkdocnm.p (
          input p-doc-code
        , input "fbr-doc"
        , input "?"
    ) no-error.
    if error-status:error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip "Ошибка при проверке номера для нового документа."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    create buf_fbr-doc.
    assign
        buf_fbr-doc.doc-code  = p-doc-code
        buf_fbr-doc.creid     = p-userid
        buf_fbr-doc.doc-date  = v-today
        buf_fbr-doc.doc-type  = {&manufacturing}
        buf_fbr-doc.host-code = v-host-code
        buf_fbr-doc.obj-type  = p-obj-type
        buf_fbr-doc.obj-code  = p-obj-code
        buf_fbr-doc.PS        = "@"
        buf_fbr-doc.status_   = {&g___new}
        buf_fbr-doc.out-code  = p-pln-doc-code
    .

end.
end procedure. /* fbrpln-create-fbr-doc */

/*==========================================================================*/
procedure fbrpln-doc-code :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-db-remote  as logical      no-undo.
define output parameter p-doc-code  as character    no-undo.
do
on error undo, return error
:
    if p-db-remote = yes
    then do:
        assign
            p-doc-code = trim( string( next-value( s-fbr-doc, {&db-name_schema} ), ">>>>>>>>>9" ) )
                        + "-"
                        + trim( string( p-obj-code, ">>>>9" ) )
                        + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
        .
    end.
    else do:
        assign
            p-doc-code = trim( string( next-value( s-fbr-doc, {&db-name_schema} ) ) ) + "-"
        .
    end.
end.
end procedure. /* fbrpln-doc-code */

/* $Workfile$ e n d */