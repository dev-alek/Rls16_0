/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_clntattr) = 0 &then
&glob include_clntattr yes
&endif

&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif

procedure clntattr-code :

  define input  parameter p-code           as character no-undo . /* код атрибута                           */
  define output parameter p-type           as character no-undo . /* тип атрибута                           */
  define output parameter p-format         as character no-undo . /* формат атрибута                        */
  define output parameter p-label          as character no-undo . /* лэйбл атрибута                         */
  define output parameter p-user-can-edit  as logical   no-undo . /* пользователь может изменять в браузере */
  define output parameter p-output-display as logical   no-undo . /* виден в браузере                       */
  define output parameter p-other          as character no-undo . /* еще чего - нибудь                      */

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-code
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

procedure clntattr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-tooltip
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

procedure clntattr-value :

  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-value
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure clntattr-write :

  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-write
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure clntattr-exist :

  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-exist
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure clntattr-delete :

  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-delete
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .  /*  obj-type */
  define input  parameter p-obj-code as integer   no-undo .  /*  obj-code */
  define input  parameter p-code     as character no-undo .  /* код атрибута */
  define input  parameter p-bh       as handle no-undo .     /* буфер поле которого заполним */


  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-copy-to
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure clntattr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    &scop proc-name clntattr-news
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

procedure clntattr-get-archive-attr :

  define output parameter p-archive-attr-list as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-get-archive-attr
    {&run_proc_attr-lib}
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-get-archive-attr */

procedure clntattr-get-auto-author-attr :

  define output parameter p-archive-attr-list as character no-undo .

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-get-auto-author-attr
    {&run_proc_attr-lib}
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-get-auto-author-attr */


procedure clntattr-get-archive-by-type :

  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .

  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".

  do
  on error undo, return error return-value
  :
    &scop proc-name clntattr-get-archive-by-type
    {&run_proc_attr-lib}
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-get-archive-attr */

procedure clntattr-vat-register :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-vat-register
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-vat-register */


procedure clntattr-requisite-alc-decl :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-requisite-alc-decl
    {&run_proc_attr-lib}
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-requisite-alc-decl */



procedure clntattr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-manual-edit
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


procedure clntattr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-batch-edit
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

&if "{1}" = "interface" &then
procedure clntattr-tank-farm-for :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-tank-farm-for
    {&run_proc_attr-lib}
      (input {2}
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-tank-farm-for */

procedure clntattr-auto-tank-for :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-auto-tank-for
    {&run_proc_attr-lib}
      (input {2}
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-auto-tank-for */

procedure clntattr-owner-code :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-owner-code
    {&run_proc_attr-lib}
      (input {2}
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-auto-tank-for */

procedure clntattr-cli-for-close-fo :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-cli-for-close-fo
    {&run_proc_attr-lib}
      (input {2}
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-auto-tank-for */


procedure clntattr-cli-clim-grp :

  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .

  do
  on error undo, return error
  :
    &scop proc-name clntattr-cli-clim-grp
    {&run_proc_attr-lib}
      (input {2}
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure. /* clntattr-cli-clim-grp */

procedure clntattr-main-accholder :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .

do
on error undo, return error
:
  &scop proc-name clntattr-main-accholder
  {&run_proc_attr-lib}
    (input  {2}
    ,input  p-obj-type
    ,input  p-obj-code
    ,input-output p-value
    ,output p-setted
    ) no-error .
  if error-status :error
  then do:
    message error-status:get-message(1) view-as alert-box .
    undo, return error return-value .
  end.
end.
end procedure.

procedure clntattr-veto-man-doc :
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .

do
on error undo, return error
:

  &scop proc-name clntattr-veto-man-doc
  {&run_proc_attr-lib}
    (input  {2}
    ,input  p-obj-type
    ,input  p-obj-code
    ,input-output p-value
    ,output p-setted
    ) no-error .
  if error-status :error
  then do:
    message error-status:get-message(1) view-as alert-box .
    undo, return error return-value .
  end.
end.
end procedure.


&endif

/* $Workfile$ e n d */