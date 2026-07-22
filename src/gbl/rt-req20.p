block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rt-req20.p $
$Archive: gbl/rt-req20.p $

Обрабока запроса радиотерминала 20. Приемка товара. Список строк документа поставки

Автор: Хныкин Павел Андреевич
Дата создания: 02/01/08
Author: Pavel Khnykin
Creation date: 02/01/08

*/

define input parameter parparentproc    as widget-handle  no-undo .
define input parameter p-directory-out  as character      no-undo .
define input parameter p-file-name      as character      no-undo .
define input parameter p-session-valid  as logical        no-undo .
define input parameter p-error-message  as character      no-undo .
define input parameter p-user-login     as character      no-undo .
define input parameter p-obj-type       as character      no-undo .
define input parameter p-obj-code       as character      no-undo .
define input parameter p-host-code      as character      no-undo .
define input parameter p-cli-type       as character      no-undo .
define input parameter p-cli-code       as character      no-undo .
define input parameter p-doc-code       as character      no-undo .
define input parameter p-doc-type       as character      no-undo .
define input parameter p-doc-status     as character      no-undo .
define input parameter p-doc-line-first as character      no-undo .
define input parameter p-doc-line-last  as character      no-undo .
define input parameter p-direction      as character      no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req20.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req20.p $":U .
define variable vss-description as character no-undo init "Обрабока запроса радиотерминала 20. Приемка товара. Список строк документа поставки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/integerm.i }
{ cmp/library.i  }
{ gbl/rtencode.i }
{ gbl/rt-cnvdc.i }

define stream sout.

define temp-table temp-doc-line-list no-undo
  field temp-order as integer
  field doc-line   as character
  field artic      as character
  field name       as character
  field doc-qnty   as character
  field gds-code   as character
  field unit-base  as character
  index pi is primary unique
    temp-order
.

define variable v-status        as character no-undo .
define variable v-message       as character no-undo .
define variable v-doc-line-01   as character no-undo .
define variable v-artic-01      as character no-undo .
define variable v-name-01       as character no-undo .
define variable v-doc-qnty-01   as character no-undo .
define variable v-gds-code-01   as character no-undo .
define variable v-unit-base-01  as character no-undo .
define variable v-doc-line-02   as character no-undo .
define variable v-artic-02      as character no-undo .
define variable v-name-02       as character no-undo .
define variable v-doc-qnty-02   as character no-undo .
define variable v-gds-code-02   as character no-undo .
define variable v-unit-base-02  as character no-undo .
define variable v-doc-line-03   as character no-undo .
define variable v-artic-03      as character no-undo .
define variable v-name-03       as character no-undo .
define variable v-doc-qnty-03   as character no-undo .
define variable v-gds-code-03   as character no-undo .
define variable v-unit-base-03  as character no-undo .
define variable v-doc-line-04   as character no-undo .
define variable v-artic-04      as character no-undo .
define variable v-name-04       as character no-undo .
define variable v-doc-qnty-04   as character no-undo .
define variable v-gds-code-04   as character no-undo .
define variable v-unit-base-04  as character no-undo .
define variable v-doc-line-05   as character no-undo .
define variable v-artic-05      as character no-undo .
define variable v-name-05       as character no-undo .
define variable v-doc-qnty-05   as character no-undo .
define variable v-gds-code-05   as character no-undo .
define variable v-unit-base-05  as character no-undo .
define variable v-doc-line-06   as character no-undo .
define variable v-artic-06      as character no-undo .
define variable v-name-06       as character no-undo .
define variable v-doc-qnty-06   as character no-undo .
define variable v-gds-code-06   as character no-undo .
define variable v-unit-base-06  as character no-undo .

do on error undo, return error return-value
:
  if p-session-valid = true then do:
    run check-data in this-procedure ( output v-status
                                     , output v-message
                                     , output v-doc-line-01
                                     , output v-artic-01
                                     , output v-name-01
                                     , output v-doc-qnty-01
                                     , output v-gds-code-01
                                     , output v-unit-base-01
                                     , output v-doc-line-02
                                     , output v-artic-02
                                     , output v-name-02
                                     , output v-doc-qnty-02
                                     , output v-gds-code-02
                                     , output v-unit-base-02
                                     , output v-doc-line-03
                                     , output v-artic-03
                                     , output v-name-03
                                     , output v-doc-qnty-03
                                     , output v-gds-code-03
                                     , output v-unit-base-03
                                     , output v-doc-line-04
                                     , output v-artic-04
                                     , output v-name-04
                                     , output v-doc-qnty-04
                                     , output v-gds-code-04
                                     , output v-unit-base-04
                                     , output v-doc-line-05
                                     , output v-artic-05
                                     , output v-name-05
                                     , output v-doc-qnty-05
                                     , output v-gds-code-05
                                     , output v-unit-base-05
                                     , output v-doc-line-06
                                     , output v-artic-06
                                     , output v-name-06
                                     , output v-doc-qnty-06
                                     , output v-gds-code-06
                                     , output v-unit-base-06
                                     ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "ошибка при вызове функции check-data. &1, &2":U
                                   , error-status :get-message(1)
                                   , return-value
                                   ) .
    end.
  end.
  else do:
    assign
      v-status        = '1'
      v-message       = p-error-message
      v-doc-line-01   = '':U
      v-artic-01      = '':U
      v-name-01       = '':U
      v-doc-qnty-01   = '':U
      v-gds-code-01   = '':U
      v-unit-base-01  = '':U
      v-doc-line-02   = '':U
      v-artic-02      = '':U
      v-name-02       = '':U
      v-doc-qnty-02   = '':U
      v-gds-code-02   = '':U
      v-unit-base-02  = '':U
      v-doc-line-03   = '':U
      v-artic-03      = '':U
      v-name-03       = '':U
      v-doc-qnty-03   = '':U
      v-gds-code-03   = '':U
      v-unit-base-03  = '':U
      v-doc-line-04   = '':U
      v-artic-04      = '':U
      v-name-04       = '':U
      v-doc-qnty-04   = '':U
      v-gds-code-04   = '':U
      v-unit-base-04  = '':U
      v-doc-line-05   = '':U
      v-artic-05      = '':U
      v-name-05       = '':U
      v-doc-qnty-05   = '':U
      v-gds-code-05   = '':U
      v-unit-base-05  = '':U
      v-doc-line-06   = '':U
      v-artic-06      = '':U
      v-name-06       = '':U
      v-doc-qnty-06   = '':U
      v-gds-code-06   = '':U
      v-unit-base-06  = '':U
    .
  end.

  define variable v-temp-file-name as character no-undo .

  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .

  put stream sout unformatted substitute('status:&1',       rtencode(v-status)        )
                              + {&new-line} .
  put stream sout unformatted substitute('message:&1',      rtencode(v-message)       )
                              + {&new-line} .
  put stream sout unformatted substitute('doc_line_01:&1',  rtencode(v-doc-line-01)   )
                              + {&new-line} .
  put stream sout unformatted substitute('artic_01:&1',     rtencode(v-artic-01)      )
                              + {&new-line} .
  put stream sout unformatted substitute('name_01:&1',      rtencode(v-name-01)       )
                              + {&new-line} .
  put stream sout unformatted substitute('doc_qnty_01:&1',  rtencode(v-doc-qnty-01)   )
                              + {&new-line} .
  put stream sout unformatted substitute('gds_code_01:&1',  rtencode(v-gds-code-01)   )
                              + {&new-line} .
  put stream sout unformatted substitute('unit_base_01:&1',  rtencode(v-unit-base-01) )
                              + {&new-line} .


  put stream sout unformatted substitute('doc_line_02:&1',  rtencode(v-doc-line-02)   )
                              + {&new-line} .
  put stream sout unformatted substitute('artic_02:&1',     rtencode(v-artic-02)      )
                              + {&new-line} .
  put stream sout unformatted substitute('name_02:&1',      rtencode(v-name-02)       )
                              + {&new-line} .
  put stream sout unformatted substitute('doc_qnty_02:&1',  rtencode(v-doc-qnty-02)   )
                              + {&new-line} .
  put stream sout unformatted substitute('gds_code_02:&1',  rtencode(v-gds-code-02)   )
                              + {&new-line} .
  put stream sout unformatted substitute('unit_base_02:&1',  rtencode(v-unit-base-02) )
                              + {&new-line} .


  put stream sout unformatted substitute('doc_line_03:&1',  rtencode(v-doc-line-03)   )
                              + {&new-line} .
  put stream sout unformatted substitute('artic_03:&1',     rtencode(v-artic-03)      )
                              + {&new-line} .
  put stream sout unformatted substitute('name_03:&1',      rtencode(v-name-03)       )
                              + {&new-line} .
  put stream sout unformatted substitute('doc_qnty_03:&1',  rtencode(v-doc-qnty-03)   )
                              + {&new-line} .
  put stream sout unformatted substitute('gds_code_03:&1',  rtencode(v-gds-code-03)   )
                              + {&new-line} .
  put stream sout unformatted substitute('unit_base_03:&1',  rtencode(v-unit-base-03) )
                              + {&new-line} .


  put stream sout unformatted substitute('doc_line_04:&1',  rtencode(v-doc-line-04)   )
                              + {&new-line} .
  put stream sout unformatted substitute('artic_04:&1',     rtencode(v-artic-04)      )
                              + {&new-line} .
  put stream sout unformatted substitute('name_04:&1',      rtencode(v-name-04)       )
                              + {&new-line} .
  put stream sout unformatted substitute('doc_qnty_04:&1',  rtencode(v-doc-qnty-04)   )
                              + {&new-line} .
  put stream sout unformatted substitute('gds_code_04:&1',  rtencode(v-gds-code-04)   )
                              + {&new-line} .
  put stream sout unformatted substitute('unit_base_04:&1',  rtencode(v-unit-base-04) )
                              + {&new-line} .


  put stream sout unformatted substitute('doc_line_05:&1',  rtencode(v-doc-line-05)   )
                              + {&new-line} .
  put stream sout unformatted substitute('artic_05:&1',     rtencode(v-artic-05)      )
                              + {&new-line} .
  put stream sout unformatted substitute('name_05:&1',      rtencode(v-name-05)       )
                              + {&new-line} .
  put stream sout unformatted substitute('doc_qnty_05:&1',  rtencode(v-doc-qnty-05)   )
                              + {&new-line} .
  put stream sout unformatted substitute('gds_code_05:&1',  rtencode(v-gds-code-05)   )
                              + {&new-line} .
  put stream sout unformatted substitute('unit_base_05:&1',  rtencode(v-unit-base-05) )
                              + {&new-line} .

/*
  !!!!
  Отсылаем только пять строк !
  Сделано по договоренности с ДатаСканом
  !!!!

 */

/*  put stream sout unformatted substitute('doc_line_06:&1',  rtencode(v-doc-line-06)   )*/
/*                              + {&new-line} .*/
/*  put stream sout unformatted substitute('artic_06:&1',     rtencode(v-artic-06)      )*/
/*                              + {&new-line} .*/
/*  put stream sout unformatted substitute('name_06:&1',      rtencode(v-name-06)       )*/
/*                              + {&new-line} .*/
/*  put stream sout unformatted substitute('doc_qnty_06:&1',  rtencode(v-doc-qnty-06)   )*/
/*                              + {&new-line} .*/
/*  put stream sout unformatted substitute('gds_code_06:&1',  rtencode(v-gds-code-06)   )*/
/*                              + {&new-line} .*/
/*  put stream sout unformatted substitute('unit_base_06:&1',  rtencode(v-unit-base-06) )*/
/*                              + {&new-line} .*/

  output stream sout close .

  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.


procedure check-data :

  define output parameter p-status        as character no-undo .
  define output parameter p-message       as character no-undo .
  define output parameter p-doc-line-01   as character no-undo .
  define output parameter p-artic-01      as character no-undo .
  define output parameter p-name-01       as character no-undo .
  define output parameter p-doc-qnty-01   as character no-undo .
  define output parameter p-gds-code-01   as character no-undo .
  define output parameter p-unit-base-01  as character no-undo .
  define output parameter p-doc-line-02   as character no-undo .
  define output parameter p-artic-02      as character no-undo .
  define output parameter p-name-02       as character no-undo .
  define output parameter p-doc-qnty-02   as character no-undo .
  define output parameter p-gds-code-02   as character no-undo .
  define output parameter p-unit-base-02  as character no-undo .
  define output parameter p-doc-line-03   as character no-undo .
  define output parameter p-artic-03      as character no-undo .
  define output parameter p-name-03       as character no-undo .
  define output parameter p-doc-qnty-03   as character no-undo .
  define output parameter p-gds-code-03   as character no-undo .
  define output parameter p-unit-base-03  as character no-undo .
  define output parameter p-doc-line-04   as character no-undo .
  define output parameter p-artic-04      as character no-undo .
  define output parameter p-name-04       as character no-undo .
  define output parameter p-doc-qnty-04   as character no-undo .
  define output parameter p-gds-code-04   as character no-undo .
  define output parameter p-unit-base-04  as character no-undo .
  define output parameter p-doc-line-05   as character no-undo .
  define output parameter p-artic-05      as character no-undo .
  define output parameter p-name-05       as character no-undo .
  define output parameter p-doc-qnty-05   as character no-undo .
  define output parameter p-gds-code-05   as character no-undo .
  define output parameter p-unit-base-05  as character no-undo .
  define output parameter p-doc-line-06   as character no-undo .
  define output parameter p-artic-06      as character no-undo .
  define output parameter p-name-06       as character no-undo .
  define output parameter p-doc-qnty-06   as character no-undo .
  define output parameter p-gds-code-06   as character no-undo .
  define output parameter p-unit-base-06  as character no-undo .

  define buffer buf_clients            for ub.clients .
  define buffer buf_sysconf            for ub.sysconf .
  define buffer buf_sys-ctrl           for ub.sys-ctrl .
  define buffer buf_user-login         for ub.user-login .
  define buffer buf_goods              for ub.goods.
  define buffer buf_trn-doc            for ub.trn-doc.
  define buffer buf_doc-line           for ub.doc-line.
  define buffer buf_ord-doc            for ub.ord-doc .
  define buffer buf_ord-doc-rcv        for ub.ord-doc-rcv.
  define buffer buf_ord-line-rcv       for ub.ord-line-rcv.
  define buffer buf_temp-doc-line-list for temp-doc-line-list.

  define query q_temp-doc-line-list for buf_temp-doc-line-list .

  define variable v-forward-direction as logical   no-undo .
  define variable v-i                 as integer   no-undo .

&scop num-of-lines 5

do
on error undo, return error return-value
:

    find first buf_sys-ctrl no-lock .
    find first buf_user-login no-lock
      where buf_user-login.db-num = buf_sys-ctrl.db-num
        and buf_user-login.status_    = {&uls-normal}
        and buf_user-login.user-login = p-user-login
      no-error .
    if not available buf_user-login
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Неизвестный пользователь &1"
                                    ,p-user-login
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-obj-code      as integer   no-undo .
    define variable v-data-valid    as logical   no-undo .
    define variable v-error-message as character no-undo .

    if p-obj-code = ""
    then do:
      assign
        p-status        = '1':u
        p-message = "Не задан код объекта"
      .
      return . /* --->>>--- */
    end.

    run integerm in this-procedure
      (input  p-obj-code      /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-obj-code      /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .

    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Ошибка преобразования кода объекта &1. &2"
                                    ,p-obj-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Не найден объект &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    if  p-obj-type <> {&shop}
    and p-obj-type <> {&stock}
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Неправильный тип объекта &1 &2"
                                    ,p-obj-type
                                    ,v-obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-host-code as integer   no-undo .

    run integerm in this-procedure
      (input  p-host-code     /* p-string      */
      ,input  false           /* p-allow-sign  */
      ,input  false           /* p-allow-comma */
      ,output v-host-code     /* p-value       */
      ,output v-data-valid    /* p-data-valid  */
      ,output v-error-message /* p-message     */
      ) .
    if v-data-valid <> true
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Ошибка преобразования кода фирмы &1. &2"
                                    ,p-host-code
                                    ,v-error-message
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить, что фирма соответсвует объекту */
    define variable v-obj-host-code as integer   no-undo .

    { gbl/hostcode.i
      buf_clients.obj-type
      buf_clients.obj-code
      v-obj-host-code
    }
    if v-host-code <> v-obj-host-code
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Заданный код фирмы &1 отличается от кода фирмы &2 объекта &3 &4."
                                    ,p-host-code
                                    ,v-obj-host-code
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить что объект доступен пользователю */
    define variable v-object-available as logical   no-undo .

    { gbl/usobjava.i
      buf_sys-ctrl.db-num
      {&action-head-code-main}
      buf_user-login.user-id
      buf_clients.obj-type
      buf_clients.obj-code
      v-object-available
    }
    if v-object-available <> true
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Пользователю не доступен объект &1 &2"
                                    ,buf_clients.obj-type
                                    ,buf_clients.obj-code
                                    )
      .
      return . /* --->>>--- */
    end.

    /* проверить права пользователя на работу с документами */
    define variable v-valid-act   as logical   no-undo .

    { gbl/chk-actg.i
      buf_sys-ctrl.db-num
      buf_user-login.user-id
      {&action-head-code-main}
      'actn_rt-edit-doc_work':U
      {&cntxt-object}
      v-host-code
      buf_clients.obj-type
      buf_clients.obj-code
      0
      0
      0
      false
      v-valid-act
    }
    if v-valid-act <> true
    then do:
      assign
        p-status        = '1'
        p-message = substitute( "&1" , return-value )
      .
      return . /* --->>>--- */
    end.

    define variable v-cli-code as integer   no-undo .

/*    if p-cli-code = "" then do:*/
/*      assign*/
/*        p-status        = '1':u*/
/*        p-message = "Не задан код поставщика"*/
/*      .*/
/*      return . /* --->>>--- */*/
/*    end.*/

/*    run integerm in this-procedure*/
/*      (input  p-cli-code      /* p-string      */*/
/*      ,input  false           /* p-allow-sign  */*/
/*      ,input  false           /* p-allow-comma */*/
/*      ,output v-cli-code      /* p-value       */*/
/*      ,output v-data-valid    /* p-data-valid  */*/
/*      ,output v-error-message /* p-message     */*/
/*      ) .*/
/*    if v-data-valid <> true then do:*/
/*      assign*/
/*        p-status        = '1':u*/
/*        p-message = substitute("Ошибка преобразования кода поставщика &1. &2"*/
/*                                    ,p-obj-code*/
/*                                    ,v-error-message*/
/*                                    )*/
/*      .*/
/*      return . /* --->>>--- */*/
/*    end.*/

/*    find first buf_clients no-lock*/
/*      where buf_clients.obj-type = p-cli-type*/
/*        and buf_clients.obj-code = v-cli-code*/
/*    no-error .*/

/*    if not available buf_clients*/
/*    then do:*/
/*      assign*/
/*        p-status        = '1':u*/
/*        p-message = substitute( "Не найден поставщик &1 &2"*/
/*                                    , p-cli-type*/
/*                                    , p-cli-code*/
/*                                    )*/
/*      .*/
/*      return . /* --->>>--- */*/
/*    end.*/

    if lookup(p-direction, '0,1,2,3') = 0
    then do:
      assign
        p-status        = '1':u
        p-message = substitute("Неизвестная команда позиционирования &1"
                                    ,p-direction
                                    )
      .
      return . /* --->>>--- */
    end.

    define variable v-gds-code-first  as integer   no-undo .

    if p-doc-line-first = ""
    then do:
      assign
        v-gds-code-first = -1
      .
    end.
    else do:
      run integerm in this-procedure
        (input  p-doc-line-first  /* p-string      */
        ,input  false             /* p-allow-sign  */
        ,input  false             /* p-allow-comma */
        ,output v-gds-code-first  /* p-value       */
        ,output v-data-valid      /* p-data-valid  */
        ,output v-error-message   /* p-message     */
        ) .
      if v-data-valid <> true then do:
        assign
          p-status        = '1':u
          p-message = substitute("Ошибка преобразования кода первой строки списка - &1. &2"
                                      ,p-doc-line-first
                                      ,v-error-message
                                      )
        .
        return . /* --->>>--- */
      end.
    end.

    define variable v-gds-code-last   as integer   no-undo .

    if p-doc-line-last = ""
    then do:
      assign
        v-gds-code-last = -1
      .
    end.
    else do:
      run integerm in this-procedure
        (input  p-doc-line-last   /* p-string      */
        ,input  false             /* p-allow-sign  */
        ,input  false             /* p-allow-comma */
        ,output v-gds-code-last  /* p-value       */
        ,output v-data-valid      /* p-data-valid  */
        ,output v-error-message   /* p-message     */
        ) .
      if v-data-valid <> true then do:
        assign
          p-status        = '1':u
          p-message = substitute("Ошибка преобразования кода последней строки списка - &1. &2"
                                      ,p-doc-line-last
                                      ,v-error-message
                                      )
        .
        return . /* --->>>--- */
      end.
    end.

    define variable v-search-doc-code as character no-undo .

    run rt-cnvdc_decode in this-procedure ( input p-doc-code
                                          , output v-search-doc-code
                                          ) .
    case p-doc-type
    :
      when 'ПТ':u
      then do:
/*        /* поставка в статусе поставка */*/
/*        if lookup(p-doc-status, 'поставка':u) = 0*/
/*        then do:*/
/*          assign*/
/*            p-status        = '1':u*/
/*            p-message = substitute("Не известный статус поставки &1"*/
/*                                        ,p-doc-status*/
/*                                        )*/
/*          .*/
/*          return . /* --->>>--- */*/
/*        end.*/

        find first buf_ord-doc-rcv no-lock
          where buf_ord-doc-rcv.rcv-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc-rcv
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ поставки &1"
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code
        no-error .
        if not available buf_ord-doc then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ заказа &1 на основании документа поставки &2"
                                        ,buf_ord-doc-rcv.doc-code
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        define buffer reposition_ord-line-rcv for ub.ord-line-rcv.
        define query q_ord-line-rcv for buf_ord-line-rcv scrolling .

        open query q_ord-line-rcv
          for each buf_ord-line-rcv no-lock
            where buf_ord-line-rcv.doc-code = buf_ord-doc-rcv.doc-code
              and buf_ord-line-rcv.rcv-code = buf_ord-doc-rcv.rcv-code
          by buf_ord-line-rcv.line-num
        .
        case p-direction :
          when '0':U then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-line-rcv .
          end.
          when '1':U then do:
            assign
              v-forward-direction = false
            .

            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-first
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line-rcv no-lock
                where reposition_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
                  and reposition_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
                  and reposition_ord-line-rcv.artic     = buf_goods.artic
                  and reposition_ord-line-rcv.prod-type = buf_goods.prod-type
                  and reposition_ord-line-rcv.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line-rcv
              then do:
                reposition q_ord-line-rcv to rowid rowid(reposition_ord-line-rcv) no-error .
                get next q_ord-line-rcv.
                if not available buf_ord-line-rcv
                then do:
                  get first q_ord-line-rcv .
                end.
                else do:
                  get prev q_ord-line-rcv.
                  if not available buf_ord-line-rcv
                  then do:
                    assign
                      v-forward-direction = true
                    .
                    get first q_ord-line-rcv .
                  end.
                end.
              end.
            end.
          end.
          when '2':U then do:
            assign
              v-forward-direction = true
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-last
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line-rcv no-lock
                where reposition_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
                  and reposition_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
                  and reposition_ord-line-rcv.artic     = buf_goods.artic
                  and reposition_ord-line-rcv.prod-type = buf_goods.prod-type
                  and reposition_ord-line-rcv.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line-rcv
              then do:
                reposition q_ord-line-rcv to rowid rowid(reposition_ord-line-rcv) no-error .
                get next q_ord-line-rcv .
                if not available buf_ord-line-rcv
                then do:
                  get first q_ord-line-rcv .
                end.
                else do:
                  get next q_ord-line-rcv .
                  if not available buf_ord-line-rcv
                  then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_ord-line-rcv .
                  end.
                end.
              end. /* if available reposition_ord-line-rcv */
            end. /* if available buf_goods */
          end.
          when '3':U then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-line-rcv .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return . /* --->>>--- */
          end.
        end case. /* case p-direction */

        if not available buf_ord-line-rcv
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "В документе &1 нет ни одной строки." , v-search-doc-code )
          .
          return . /* --->>>--- */
        end.

        for each buf_temp-doc-line-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-line-list .
        end.

        _scan_cycle:
        do v-i = 1 to {&num-of-lines}
        :
          if available buf_ord-line-rcv
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_ord-line-rcv.artic
                and buf_goods.prod-type = buf_ord-line-rcv.prod-type
                and buf_goods.prod-code = buf_ord-line-rcv.prod-code
            no-error .
            if not available buf_goods
            then do:
              assign
                p-status        = '1':u
                p-message = substitute( 'Не найден товар &1 &2 &3 по строке в документе поставки &4':u
                                            ,buf_ord-line-rcv.artic
                                            ,buf_ord-line-rcv.prod-type
                                            ,buf_ord-line-rcv.prod-code
                                            ,buf_ord-line-rcv.rcv-code
                                            )
              .
              return . /* --->>>--- */
            end.
            create buf_temp-doc-line-list .
            assign
              buf_temp-doc-line-list.temp-order = ( if v-forward-direction = true then v-i else - v-i )
              buf_temp-doc-line-list.doc-line   = string( buf_ord-line-rcv.line-num )
              buf_temp-doc-line-list.artic      = buf_ord-line-rcv.artic
              buf_temp-doc-line-list.name       = buf_goods.gds-name
              buf_temp-doc-line-list.doc-qnty   = string( buf_ord-line-rcv.qnty )
              buf_temp-doc-line-list.gds-code   = string( buf_goods.gds-code    )
              buf_temp-doc-line-list.unit-base  = buf_goods.unit-base
            .
          end. /* if available buf_ord-line-rcv */

          if v-forward-direction = true
          then do:
            get next q_ord-line-rcv .
          end.
          else do:
            get prev q_ord-line-rcv .
          end.

          if not available buf_ord-line-rcv
          then do:
            leave _scan_cycle .
          end.

        end. /* _scan_cycle */

      end. /* when 'ПТ':u */
      when 'ПН':u or
      when 'РН':u
      then do:
/*        if lookup(p-doc-status, 'накл-':u + {&comma-char} + 'накл+':u) = 0*/
/*        then do:*/
/*          assign*/
/*            p-status        = '1':u*/
/*            p-message = substitute("Не известный статус документа внешнего прихода &1"*/
/*                                        ,p-doc-status*/
/*                                        )*/
/*          .*/
/*          return . /* --->>>--- */*/
/*        end.*/

        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_trn-doc
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найден документ &1"
                                        ,v-search-doc-code
                                        )
          .
          return . /* --->>>--- */
        end.

        define buffer reposition_doc-line for ub.doc-line.
        define query q_buf_doc-line for buf_doc-line scrolling .

        open query q_buf_doc-line
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code = buf_trn-doc.doc-code
          by buf_doc-line.line-num
        .

        case p-direction :
          when '0':U then do:
            assign
              v-forward-direction = true
            .
            get first q_buf_doc-line .
          end.
          when '1':U then do:
            assign
              v-forward-direction = false
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-first
            no-error .
            if available buf_goods
            then do:
              find first reposition_doc-line no-lock
                where reposition_doc-line.doc-code  = buf_trn-doc.doc-code
                  and reposition_doc-line.artic     = buf_goods.artic
                  and reposition_doc-line.prod-type = buf_goods.prod-type
                  and reposition_doc-line.prod-code = buf_goods.prod-code
              no-error .
              if available reposition_doc-line
              then do:
                reposition q_buf_doc-line to rowid rowid(reposition_doc-line) no-error .
                get next q_buf_doc-line .
                if not available buf_doc-line
                then do:
                  get first q_buf_doc-line .
                end.
                else do:
                  get prev q_buf_doc-line .
                  if not available buf_doc-line
                  then do:
                    assign
                      v-forward-direction = true
                    .
                    get first q_buf_doc-line .
                  end.
                end.
              end.
            end. /* if available buf_goods */
          end.
          when '2':U then do:
            assign
              v-forward-direction = true
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-last
            no-error .
            if available buf_goods
            then do:
              find first reposition_doc-line no-lock
                where reposition_doc-line.doc-code  = buf_trn-doc.doc-code
                  and reposition_doc-line.artic     = buf_goods.artic
                  and reposition_doc-line.prod-type = buf_goods.prod-type
                  and reposition_doc-line.prod-code = buf_goods.prod-code
              no-error .
              if available reposition_doc-line
              then do:
                reposition q_buf_doc-line to rowid rowid(reposition_doc-line) no-error .
                get next q_buf_doc-line .
                if not available buf_doc-line
                then do:
                  get first q_buf_doc-line .
                end.
                else do:
                  get next q_buf_doc-line .
                  if not available buf_doc-line
                  then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_buf_doc-line .
                  end.
                end.
              end.
            end. /* if available buf_goods */
          end.
          when '3':U then do:
            assign
              v-forward-direction = false
            .
            get last q_buf_doc-line .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-message = substitute("Неизвестное значение переменной p-direction &1"
                                          ,p-direction
                                          )
            .
            return . /* --->>>--- */
          end.
        end case.

        if not available buf_doc-line
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "В документе &1 нет ни одной строки." , v-search-doc-code )
          .
          return . /* --->>>--- */
        end.

        for each buf_temp-doc-line-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-line-list .
        end.

        _scan_cycle:
        do v-i = 1 to {&num-of-lines}
        :
          if available buf_doc-line
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_doc-line.artic
                and buf_goods.prod-type = buf_doc-line.prod-type
                and buf_goods.prod-code = buf_doc-line.prod-code
            no-error .
            if not available buf_goods
            then do:
              assign
                p-status        = '1':u
                p-message = substitute( 'Не найден товар &1 &2 &3 по строке в документе &4':u
                                            ,buf_ord-line-rcv.artic
                                            ,buf_ord-line-rcv.prod-type
                                            ,buf_ord-line-rcv.prod-code
                                            ,buf_doc-line.doc-code
                                            )
              .
              return . /* --->>>--- */
            end.
            create buf_temp-doc-line-list .
            assign
              buf_temp-doc-line-list.temp-order = ( if v-forward-direction = true then v-i else - v-i )
              buf_temp-doc-line-list.doc-line   = string( buf_doc-line.line-num )
              buf_temp-doc-line-list.artic      = buf_doc-line.artic
              buf_temp-doc-line-list.name       = buf_goods.gds-name
              buf_temp-doc-line-list.doc-qnty   = string( buf_doc-line.doc-qnty )
              buf_temp-doc-line-list.gds-code   = string( buf_goods.gds-code    )
              buf_temp-doc-line-list.unit-base  = buf_goods.unit-base
            .
          end. /* if available buf_ord-line-rcv */

          if v-forward-direction = true
          then do:
            get next q_buf_doc-line .
          end.
          else do:
            get prev q_buf_doc-line .
          end.

          if not available buf_doc-line
          then do:
            leave _scan_cycle .
          end.

        end. /* _scan_cycle */
      end. /* when 'ПН':u */
      when 'ОР':u
      then do:
        /* заявка в статусе разрешен */
/*        if lookup(p-doc-status, 'разрешено':u) = 0*/
/*        then do:*/
/*          assign*/
/*            p-status        = '1':u*/
/*            p-error-message = substitute( "Неизвестный статус заявки &1"*/
/*                                        , p-doc-status*/
/*                                        )*/
/*          .*/
/*          return . /* --->>>--- */*/
/*        end.*/

        find first buf_ord-doc no-lock
          where buf_ord-doc.doc-code = v-search-doc-code
        no-error .
        if not available buf_ord-doc
        then do:
          assign
            p-status        = '1':u
            p-message = substitute("Не найдена заявка &1"
                                  ,v-search-doc-code
                                  )
          .
          return . /* --->>>--- */
        end.


        define buffer reposition_ord-line for ub.ord-line.
        define buffer buf_ord-line        for ub.ord-line.

        define query q_ord-line for buf_ord-line scrolling .

        open query q_ord-line
          for each buf_ord-line no-lock
            where buf_ord-line.doc-code = buf_ord-doc.doc-code
          by buf_ord-line.line-num
        .
        case p-direction :
          when '0':U then do:
            assign
              v-forward-direction = true
            .
            get first q_ord-line .
          end.
          when '1':U then do:
            assign
              v-forward-direction = false
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-first
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line no-lock
                where reposition_ord-line.doc-code  = buf_ord-doc.doc-code
                  and reposition_ord-line.artic     = buf_goods.artic
                  and reposition_ord-line.prod-type = buf_goods.prod-type
                  and reposition_ord-line.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line
              then do:
                reposition q_ord-line to rowid rowid(reposition_ord-line) no-error .
                get next q_ord-line.
                if not available buf_ord-line
                then do:
                  get first q_ord-line.
                end.
                else do:
                  get prev q_ord-line.
                  if not available buf_ord-line
                  then do:
                    assign
                      v-forward-direction = true
                    .
                    get first q_ord-line.
                  end.
                end.
              end.
            end.
          end.
          when '2':U then do:
            assign
              v-forward-direction = true
            .
            find first buf_goods no-lock
              where buf_goods.gds-code = v-gds-code-last
            no-error .
            if available buf_goods
            then do:
              find first reposition_ord-line no-lock
                where reposition_ord-line.doc-code  = buf_ord-doc.doc-code
                  and reposition_ord-line.artic     = buf_goods.artic
                  and reposition_ord-line.prod-type = buf_goods.prod-type
                  and reposition_ord-line.prod-code = buf_goods.prod-code
              no-error.
              if available reposition_ord-line
              then do:
                reposition q_ord-line to rowid rowid(reposition_ord-line) no-error .
                get next q_ord-line .
                if not available buf_ord-line
                then do:
                  get first q_ord-line .
                end.
                else do:
                  get next q_ord-line .
                  if not available buf_ord-line
                  then do:
                    assign
                      v-forward-direction = false
                    .
                    get last q_ord-line .
                  end.
                end.
              end. /* if available reposition_ord-line */
            end. /* if available buf_goods */
          end.
          when '3':U then do:
            assign
              v-forward-direction = false
            .
            get last q_ord-line .
          end.
          otherwise do:
            assign
              p-status        = '1':u
              p-message = substitute("Неизвестное значение переменной p-direction &1"
                                    ,p-direction
                                    )
            .
            return . /* --->>>--- */
          end.
        end case. /* case p-direction */

        if not available buf_ord-line
        then do:
          assign
            p-status  = '1':u
            p-message = substitute( "В документе &1 нет ни одной строки." , v-search-doc-code )
          .
          return . /* --->>>--- */
        end.

        for each buf_temp-doc-line-list
        on error undo, return error return-value
        :
          delete buf_temp-doc-line-list .
        end.

        _scan_cycle:
        do v-i = 1 to {&num-of-lines}
        :
          if available buf_ord-line
          then do:
            find first buf_goods no-lock
              where buf_goods.artic     = buf_ord-line.artic
                and buf_goods.prod-type = buf_ord-line.prod-type
                and buf_goods.prod-code = buf_ord-line.prod-code
            no-error .
            if not available buf_goods
            then do:
              assign
                p-status        = '1':u
                p-message = substitute( 'Не найден товар &1 &2 &3 по строке в заявке &4':u
                                            ,buf_ord-line.artic
                                            ,buf_ord-line.prod-type
                                            ,buf_ord-line.prod-code
                                            ,buf_ord-line.doc-code
                                            )
              .
              return . /* --->>>--- */
            end.
            create buf_temp-doc-line-list .
            assign
              buf_temp-doc-line-list.temp-order = ( if v-forward-direction = true then v-i else - v-i )
              buf_temp-doc-line-list.doc-line   = string( buf_ord-line.line-num )
              buf_temp-doc-line-list.artic      = buf_ord-line.artic
              buf_temp-doc-line-list.name       = buf_goods.gds-name
              buf_temp-doc-line-list.doc-qnty   = string( buf_ord-line.qnty )
              buf_temp-doc-line-list.gds-code   = string( buf_goods.gds-code    )
              buf_temp-doc-line-list.unit-base  = buf_goods.unit-base
            .
          end. /* if available buf_ord-line-rcv */

          if v-forward-direction = true
          then do:
            get next q_ord-line .
          end.
          else do:
            get prev q_ord-line .
          end.

          if not available buf_ord-line
          then do:
            leave _scan_cycle .
          end.

        end. /* _scan_cycle */

      end. /* when 'ОР':u */
      otherwise do:
        assign
          p-status        = '1':u
          p-message = substitute("Неизвестный тип документа &1"
                                      ,p-doc-type
                                      )
        .
        return . /* --->>>--- */
      end.

    end case.

    open query q_buf_temp-doc-line-list
      for each buf_temp-doc-line-list
      by buf_temp-doc-line-list.temp-order
    .

    get first q_buf_temp-doc-line-list .

    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-01   = buf_temp-doc-line-list.doc-line
        p-artic-01      = buf_temp-doc-line-list.artic
        p-name-01       = buf_temp-doc-line-list.name
        p-doc-qnty-01   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-01   = buf_temp-doc-line-list.gds-code
        p-unit-base-01  = buf_temp-doc-line-list.unit-base
      .
    end.

    get next q_buf_temp-doc-line-list .

    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return . /* --->>>--- */
    end.

    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-02   = buf_temp-doc-line-list.doc-line
        p-artic-02      = buf_temp-doc-line-list.artic
        p-name-02       = buf_temp-doc-line-list.name
        p-doc-qnty-02   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-02   = buf_temp-doc-line-list.gds-code
        p-unit-base-02  = buf_temp-doc-line-list.unit-base
      .
    end.

    get next q_buf_temp-doc-line-list .

    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return . /* --->>>--- */
    end.

    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-03   = buf_temp-doc-line-list.doc-line
        p-artic-03      = buf_temp-doc-line-list.artic
        p-name-03       = buf_temp-doc-line-list.name
        p-doc-qnty-03   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-03   = buf_temp-doc-line-list.gds-code
        p-unit-base-03  = buf_temp-doc-line-list.unit-base
      .
    end.

    get next q_buf_temp-doc-line-list .

    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return . /* --->>>--- */
    end.

    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-04   = buf_temp-doc-line-list.doc-line
        p-artic-04      = buf_temp-doc-line-list.artic
        p-name-04       = buf_temp-doc-line-list.name
        p-doc-qnty-04   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-04   = buf_temp-doc-line-list.gds-code
        p-unit-base-04  = buf_temp-doc-line-list.unit-base
      .
    end.

    get next q_buf_temp-doc-line-list .

    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return . /* --->>>--- */
    end.

    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-05   = buf_temp-doc-line-list.doc-line
        p-artic-05      = buf_temp-doc-line-list.artic
        p-name-05       = buf_temp-doc-line-list.name
        p-doc-qnty-05   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-05   = buf_temp-doc-line-list.gds-code
        p-unit-base-05  = buf_temp-doc-line-list.unit-base
      .
    end.

    get next q_buf_temp-doc-line-list .

    if not available buf_temp-doc-line-list
    then do:
      assign
        p-status        = '0':U
        p-message = '':U
      .
      return . /* --->>>--- */
    end.

    if available buf_temp-doc-line-list
    then do:
      assign
        p-doc-line-06   = buf_temp-doc-line-list.doc-line
        p-artic-06      = buf_temp-doc-line-list.artic
        p-name-06       = buf_temp-doc-line-list.name
        p-doc-qnty-06   = buf_temp-doc-line-list.doc-qnty
        p-gds-code-06   = buf_temp-doc-line-list.gds-code
        p-unit-base-06  = buf_temp-doc-line-list.unit-base
      .
    end.

    assign
      p-status        = '0':U
      p-message = '':U
    .
    return . /* --->>>--- */



end.

end procedure. /* check-data */