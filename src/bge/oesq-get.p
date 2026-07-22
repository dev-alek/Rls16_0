block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oesq-get.p $
$Archive: bge/oesq-get.p $

Получить sequence из атрибутов текущей базы для выгрузки в Oracle Retail

Автор: Хныкин Павел Андреевич
Дата создания: 01/26/09
Author: Pavel Khnykin
Creation date: 01/26/09

*/

define output parameter p-ora-exp-seq as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oesq-get.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oesq-get.p $":U .
define variable vss-description as character no-undo init "Получить sequence из атрибутов текущей базы для выгрузки в Oracle Retail".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/db-attr.i  }

define buffer buf_sys-ctrl for ub.sys-ctrl.

define variable v-db-attr-exist as logical   no-undo .
define variable v-db-attr-value as character no-undo .
define variable v-db-attr-type  as character no-undo .
define variable v-ora-exp-seq   as integer   no-undo .

do for
  buf_sys-ctrl
on error undo, return error return-value
:
  find first buf_sys-ctrl no-lock no-error .
  if not available buf_sys-ctrl
  then do:
    undo , return error "Не найдена запись sys-ctrl!" .
  end.

  run db-attr-exist in this-procedure ( input buf_sys-ctrl.db-num
                                      , input {&attr-ora-exp-seq}
                                      , output v-db-attr-exist
                                      ) no-error.
  if error-status :error
  then do:
    undo , return error substitute( "Ошибка при определении атрибута номера выгрузки Oracle Retail &1 для БД &2"
                                  , {&attr-ora-exp-seq}
                                  , buf_sys-ctrl.db-num
                                  ).
  end.
  if v-db-attr-exist = no
  then do:
    assign
      v-db-attr-value = "1":U
    .
    run db-attr-write in this-procedure ( input buf_sys-ctrl.db-num
                                        , input {&attr-ora-exp-seq}
                                        , input v-db-attr-value
                                        ) no-error .
    if error-status :error
    then do:
      undo , return error substitute( "Ошибка инициализации параметра номера выгрузки Oracle Retail &1 для БД &2, значение параметра &3"
                                    , {&attr-ora-exp-seq}
                                    , buf_sys-ctrl.db-num
                                    , v-db-attr-value
                                    ).
    end.
  end.
  else do:
    run db-attr-value in this-procedure ( input buf_sys-ctrl.db-num
                                        , input {&attr-ora-exp-seq}
                                        , output v-db-attr-value
                                        , output v-db-attr-type
                                        ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "Ошибка чтения параметра номера выгрузки Oracle Retail &1 для БД &2"
                                   , {&attr-ora-exp-seq}
                                   , buf_sys-ctrl.db-num
                                   ).
    end.
  end.

  assign
    v-ora-exp-seq = int(v-db-attr-value)
  no-error .
  if error-status :error
  then do:
    undo, return error substitute( "Ошибка преобразования параметра номера выгрузки Oracle Retail &1 к числу.&2&3"
                                  , {&attr-ora-exp-seq}
                                  , {&new-line}
                                  , error-status :get-message(1)
                                  ).
  end.
  assign
    p-ora-exp-seq = v-ora-exp-seq
    v-ora-exp-seq = v-ora-exp-seq + 1
  .
  run bge/oesq-set.p ( input v-ora-exp-seq ) .
end.