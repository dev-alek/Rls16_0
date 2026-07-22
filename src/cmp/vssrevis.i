/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Позволяет запрашивать информацию о текущей версии файла

Автор: Перваков Михаил Сергеевич
Дата создания: 01/01/01
Author: Mikhail Pervakov
Creation date: 01/01/01

Позволяет регистрировать запуск программ и выдавать информацию о параметрах запуска
Данный файл необходимо вставлять в составе блока, описывающего процедуру
сразу после определения параметров вызова процедуры
Пример:
  def var vss-revision    as character no-undo init "$Revision$":u .
  def var vss-author      as character no-undo init "$Author$":u .
  def var vss-date        as character no-undo init "$Date$":u .
  def var vss-workfile    as character no-undo init "$Workfile$":u .
  def var vss-archive     as character no-undo init "$Archive$":u .
  def var vss-description as character no-undo init "" .
  { cmp/vssrevis.i }
*/
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure. /* vss-get-info */
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
  &if "{1}" <> "" &then
    assign
      p-vss-parameters = {1}
    .
  &endif
end procedure. /* vss-get-parameters */

define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .

procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure. /* vss-logevent */

assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
/* $Workfile$ e n d */