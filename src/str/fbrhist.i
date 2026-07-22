/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение констант и процедур истории производства.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define fbrhist-type-run 'запуск':U
&global-define fbrhist-type-end 'выход':U
&global-define fbrhist-type-create-doc 'соз_док':U
&global-define fbrhist-type-create-line 'соз_стр':U
&global-define fbrhist-type-change-doc 'изм_док':U
&global-define fbrhist-type-change-doc-line 'изм_стр':U
&global-define fbrhist-type-delete-doc 'удл_док':U
&global-define fbrhist-type-delete-doc-line 'удл_стр':U
&global-define fbrhist-type-close-doc 'зак_док':U
&global-define fbrhist-type-close-fact 'зак_фкт':U
&global-define fbrhist-type-open-doc 'отк_док':U
&global-define fbrhist-type-read-ref 'чт_справ':U
&global-define fbrhist-type-add-goods 'доб_тов':U
&global-define fbrhist-type-user-select 'выбор':U
&global-define fbrhist-separator chr(2)
&global-define fbrhist-min-character '':U
&global-define fbrhist-max-character 'z':U
&global-define fbrhist-min-integer -32000
&global-define fbrhist-max-integer  32000
&global-define fbrhist-min-decimal -9999999999.00
&global-define fbrhist-max-decimal  9999999999.00
&global-define fbrhist-min-date 01/01/0001
&global-define fbrhist-max-date 12/31/9999
&global-define fbrhistory 'история_производства'

&if "{1}" = "main" &then

define temp-table temp_fbr-history no-undo like ub.fbr-history .

define variable v-fbrhist-history-level     as integer      no-undo.
define variable v-fbrhist-upper-obj-type    as character    no-undo.
define variable v-fbrhist-upper-obj-code    as integer      no-undo.
define variable v-fbrhist-upper-code        as integer      no-undo.
define variable v-fbrhist-current-obj-type  as character    no-undo.
define variable v-fbrhist-current-obj-code  as integer      no-undo.
define variable v-fbrhist-current-code      as integer      no-undo.
define variable v-fbrhist-saved-obj-type    as character    no-undo.
define variable v-fbrhist-saved-obj-code    as integer      no-undo.
define variable v-fbrhist-saved-code        as integer      no-undo.


/*==========================================================================*/
/*
    Input:
        p-obj-type               - объект
        p-obj-code
        p-hst-type               - тип записи в историю (см. global-define)
        p-hst-level              - уровень детализации записи. Если уровень больше системного (задаётся параметром) - запись не производится.
        p-procedure-name         - имя процедуры, создавшей запись. Удобно заполнить переменную v-fbrhist-procedure-name
        p-procedure-parameters   - список параметров процедуры (пример формата: "p-num-rec:1,p-str:'qwerty',p-log:no,p-dec:6.78"). Удобно заполнить переменную v-fbrhist-procedure-parameters
        p-doc-code               - код документа
        p-doc-type               - тип документа
        p-status_                - статус документа
        p-is-free                - флаг для документа производства
        p-recipe-code            - код рецепта
        p-recipe-type            - тип рецепта
        p-gds-code               - код товара
        p-trn-type               - тип списания для строки документа
        p-qnty                   - количество
        p-PS                     - примечание
        p-is-error               - является записью об ошибке

    Output:

Required:
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }

*/
procedure fbrhist-write :
define input parameter p-userid                 as character        no-undo.
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-hst-type               as character        no-undo.
define input parameter p-hst-level              as integer          no-undo.
define input parameter p-procedure-name         as character        no-undo.
define input parameter p-procedure-parameters   as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-type               as character        no-undo.
define input parameter p-status_                as character        no-undo.
define input parameter p-is-free                as logical          no-undo.
define input parameter p-recipe-code            as character        no-undo.
define input parameter p-recipe-type            as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-trn-type               as character        no-undo.
define input parameter p-qnty                   as decimal          no-undo.
define input parameter p-PS                     as character        no-undo.
define input parameter p-is-error               as logical          no-undo.

    define variable v-today                         as date         no-undo.
    define variable v-obj-date                      as date         no-undo.
    define variable v-time                          as integer      no-undo.
    define variable v-host-code                     as integer      no-undo.
    define variable v-db-num                        as integer      no-undo.

    define buffer buf_temp_fbr-history       for temp_fbr-history.
    define buffer buf_upper_temp_fbr-history for temp_fbr-history.
do
for buf_temp_fbr-history
  , buf_upper_temp_fbr-history
on error undo, return error
:
    if v-fbrhist-history-level = 0
    or v-fbrhist-history-level < p-hst-level
    then do:        /* Запись в историю отключена */
        undo, return .
    end.
    if v-fbrhist-upper-code <> 0
    then do:
        find first buf_upper_temp_fbr-history no-lock
             where buf_upper_temp_fbr-history.obj-type = v-fbrhist-upper-obj-type
               and buf_upper_temp_fbr-history.obj-code = v-fbrhist-upper-obj-code
               and buf_upper_temp_fbr-history.hst-code = v-fbrhist-upper-code
        no-error.
    end.
    { gbl/curobjdt.i
        p-obj-type
        p-obj-code
        v-obj-date
    }
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    { gbl/curdbnum.i
        v-db-num
    }
    create buf_temp_fbr-history.
    assign
        buf_temp_fbr-history.obj-type                = p-obj-type
        buf_temp_fbr-history.obj-code                = p-obj-code
        buf_temp_fbr-history.hst-code                = next-value( s-fbr-num, {&db-name_schema})
        buf_temp_fbr-history.hst-type                = p-hst-type
        buf_temp_fbr-history.hst-level               = p-hst-level
        buf_temp_fbr-history.hst-upper-code          = v-fbrhist-upper-code

        buf_temp_fbr-history.procedure-name          = p-procedure-name
        buf_temp_fbr-history.procedure-parameters    = p-procedure-parameters
        buf_temp_fbr-history.doc-code                = p-doc-code
        buf_temp_fbr-history.doc-type                = p-doc-type
        buf_temp_fbr-history.status_                 = p-status_
        buf_temp_fbr-history.is-free                 = p-is-free
        buf_temp_fbr-history.recipe-code             = p-recipe-code
        buf_temp_fbr-history.recipe-type             = p-recipe-type
        buf_temp_fbr-history.gds-code                = p-gds-code
        buf_temp_fbr-history.trn-type                = p-trn-type
        buf_temp_fbr-history.qnty                    = p-qnty
        buf_temp_fbr-history.PS                      = p-ps
        buf_temp_fbr-history.is-error                = p-is-error

        buf_temp_fbr-history.db-num                  = v-db-num
        buf_temp_fbr-history.user-name               = p-userid
        buf_temp_fbr-history.sys-date                = v-today
        buf_temp_fbr-history.sys-time-int            = v-time
        buf_temp_fbr-history.sys-time                = string( v-time, "HH:MM:SS" )
        buf_temp_fbr-history.obj-date                = v-obj-date
        buf_temp_fbr-history.host-code               = v-host-code
    .
    assign
        v-fbrhist-current-obj-type                   = p-obj-type
        v-fbrhist-current-obj-code                   = p-obj-code
        v-fbrhist-current-code                       = buf_temp_fbr-history.hst-code
    .
    if available buf_upper_temp_fbr-history
    then do:
        assign
            buf_temp_fbr-history.hst-node-path = buf_temp_fbr-history.hst-node-path
                    + {&fbrhist-separator}  + string( buf_temp_fbr-history.obj-type )
                                            + "-":U + string( buf_temp_fbr-history.obj-code )
                                            + "-":U + string( buf_temp_fbr-history.hst-code )
        .
    end.
    else do:
        assign
            buf_temp_fbr-history.hst-node-path = string( buf_temp_fbr-history.obj-type )
                               + "-":U + string( buf_temp_fbr-history.obj-code )
                               + "-":U + string( buf_temp_fbr-history.hst-code )
        .
    end.
end.
end procedure. /* write-history */

/*==========================================================================*/
procedure fbrhist-read-conf :

do
on error undo, return error
:

   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .

   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  {&attr-fbrattr}
                     , input  {&attr-fbrattr_fbrhstlv}
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-fbrhist-history-level
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      /* параметр может быть не задан */
      assign
         v-fbrhist-history-level = 0
      .
   end.

end.
end procedure. /* fbrhist-read-conf */

/*==========================================================================*/
procedure fbrhist-table-to-base :

    define buffer buf_fbr-history       for ub.fbr-history.
    define buffer buf_temp_fbr-history  for temp_fbr-history.
do
for buf_fbr-history
  , buf_temp_fbr-history
on error undo, return error
:
    for each buf_temp_fbr-history
    on error undo, return error
    :
        create buf_fbr-history.
        buffer-copy buf_temp_fbr-history to buf_fbr-history.
    end.        /* for each buf_temp_fbr-history */
end.
end procedure. /* fbrhist-table-to-base */


/*==========================================================================*/
procedure fbrhist-init :

    define buffer buf_temp_fbr-history      for temp_fbr-history.
do
for buf_temp_fbr-history
on error undo, return error
:
    for each buf_temp_fbr-history
    :
        delete buf_temp_fbr-history.
    end.        /* for each buf_temp_fbr-history */
    assign
        v-fbrhist-upper-obj-type    = ""
        v-fbrhist-upper-obj-code    = 0
        v-fbrhist-upper-code        = 0
        v-fbrhist-current-obj-type  = ""
        v-fbrhist-current-obj-code  = 0
        v-fbrhist-current-code      = 0
        v-fbrhist-saved-obj-type    = ""
        v-fbrhist-saved-obj-code    = 0
        v-fbrhist-saved-code        = 0
    .
end.
end procedure. /* fbrhist-init */

/*==========================================================================*/
procedure fbrhist-set-upper-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = v-fbrhist-current-obj-type
        v-fbrhist-upper-obj-code    = v-fbrhist-current-obj-code
        v-fbrhist-upper-code        = v-fbrhist-current-code
    .
end.
end procedure. /* fbrhist-set-upper-code */

/*==========================================================================*/
procedure fbrhist-save-current-code :
do
on error undo, return error
:
    assign
        v-fbrhist-saved-obj-type    = v-fbrhist-current-obj-type
        v-fbrhist-saved-obj-code    = v-fbrhist-current-obj-code
        v-fbrhist-saved-code        = v-fbrhist-current-code
    .
end.
end procedure. /* fbrhist-save-current-code */

/*==========================================================================*/
procedure fbrhist-set-upper-from-saved-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = v-fbrhist-saved-obj-type
        v-fbrhist-upper-obj-code    = v-fbrhist-saved-obj-code
        v-fbrhist-upper-code        = v-fbrhist-saved-code
    .
end.
end procedure. /* fbrhist-set-upper-from-saved-code */

/*==========================================================================*/
procedure fbrhist-set-zero-upper-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = ""
        v-fbrhist-upper-obj-code    = 0
        v-fbrhist-upper-code        = 0
    .
end.
end procedure. /* fbrhist-set-zero-upper-code */

&endif

/* $Workfile$ e n d */