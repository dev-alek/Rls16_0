/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами пакетов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 05/25/09
Author: Dmitry Ukhanov
Creation date: 05/25/09


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif

procedure pck-attr-code :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-type           as character no-undo . /* тип атрибута */
  define output parameter p-format         as character no-undo . /* формат атрибута */
  define output parameter p-label          as character no-undo . /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo . /* виден в броусе */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь */

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-code
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

procedure pck-attr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-tooltip
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure pck-attr-value :

  define input  parameter p-tbl-pck   as   character                   no-undo .
  define input  parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .
  define output parameter p-type      as   character                   no-undo .

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-value
    {&run_proc_attr-lib}
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-value
      , output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure pck-attr-write :

  define input parameter p-tbl-pck   as   character                   no-undo .
  define input parameter p-db-num    like ub.pck-rcvd-attr.db-num     no-undo .
  define input parameter p-pack-num  like ub.pck-rcvd-attr.pack-num   no-undo .
  define input parameter p-code      like ub.pck-rcvd-attr.attr-code  no-undo .
  define input parameter p-value     like ub.pck-rcvd-attr.attr-value no-undo .

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-write
    {&run_proc_attr-lib}
      ( input p-tbl-pck
      , input p-db-num
      , input p-pack-num
      , input p-code
      , input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure pck-attr-exist :

  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-exist
    {&run_proc_attr-lib}
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure pck-attr-delete :

  define input  parameter p-tbl-pck  as   character                   no-undo .
  define input  parameter p-db-num   like ub.pck-rcvd-attr.db-num     no-undo .
  define input  parameter p-pack-num like ub.pck-rcvd-attr.pack-num   no-undo .
  define input  parameter p-code     like ub.pck-rcvd-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-delete
    {&run_proc_attr-lib}
      ( input  p-tbl-pck
      , input  p-db-num
      , input  p-pack-num
      , input  p-code
      , output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure pck-attr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-news
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

/*секция pop-up меню при ручном редактировании */
procedure pck-attr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-manual-edit
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.


procedure pck-attr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name pck-attr-batch-edit
    {&run_proc_attr-lib}
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.

/* $Workfile$ e n d */