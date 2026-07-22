/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с атрибутами внешней системы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(esysattr_i) = 0 &then

&glob esysattr_i


&if defined (include_attr-lib) = 0 &then
{ gbl/attr-lib.i }
&endif

&glob form-esys-attr '~
{&bef-attr-esys-ftp-ip}~
,{&bef-attr-esys-ftp-login}~
,{&bef-attr-esys-ftp-password}~
,{&bef-attr-esys-ftp-path}~
,{&bef-attr-esys-ftp-path-in}~
,{&bef-attr-esys-ftp-path-out}~
,{&bef-attr-esys-cert-sign}~
,{&bef-attr-esys-cert-sign-subject}~
,{&bef-attr-esys-cert-sign-issuer}~
,{&bef-attr-esys-cert-file-ext}~
,{&bef-attr-esys-cert-repository}~
,{&bef-attr-esys-AuthToken}~
,{&bef-attr-esys-AuthTokenDT}~
,{&bef-attr-esys-host-code}~
,{&bef-attr-esys-obj}~
,{&bef-attr-esys-user-id}~
,{&bef-attr-esys-server-addr}~
,{&bef-attr-esys-proxy-addr}~
,{&bef-attr-esys-proxy-login}~
,{&bef-attr-esys-proxy-pswd}~
,{&bef-attr-esys-proxy-ssl}~
,{&bef-attr-esys-AuthToken-send}~
,{&bef-attr-esys-mail-list}~
,{&bef-attr-esys-diadoc-user}~
,{&bef-attr-esys-diadoc-pwd}~
,{&bef-attr-esys-diadoc-key}~
,{&bef-attr-esys-diadoc-lastload}~
,{&bef-attr-esys-diadoc-ssl}~
':U

procedure ext-system-attr-code :

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
    &scop proc-name ext-system-attr-code
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

procedure ext-system-attr-tooltip :

  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-tooltip
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


procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-value
    {&run_proc_attr-lib}
      (input  p-esys-id
      ,input  p-db-num
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


procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-write
    {&run_proc_attr-lib}
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-exist
    {&run_proc_attr-lib}
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.

procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-delete
    {&run_proc_attr-lib}
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

end procedure.


procedure ext-system-attr-news :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-news           as logical   no-undo . /* ходит в новости */

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-news
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
procedure ext-system-attr-manual-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-manual-edit
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


procedure ext-system-attr-batch-edit :

  define input  parameter p-code           as character no-undo . /* код атрибута */
  define output parameter p-section-num    as integer no-undo .

  do
  on error undo, return error
  :
    &scop proc-name ext-system-attr-batch-edit
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

&endif

/* $Workfile$ e n d */