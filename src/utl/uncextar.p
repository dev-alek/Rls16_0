block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: uncextar.p $
$Archive: utl/uncextar.p $

Отчет по внешним артикулам

Автор: Хныкин Павел Андреевич
Дата создания: 11/18/08
Author: Pavel Khnykin
Creation date: 11/18/08

В файл выводится информация по внешним артикулам

Орг 200
артик поставщика - наш артикул1. наш артикул2, наш артикул 3,….
.
.
.
.
Орг201
артик поставщика - наш артикул1. наш артикул2, наш артикул 3,….

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: uncextar.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/uncextar.p $":U .
define variable vss-description as character no-undo init "Отчет по внешним артикулам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define stream sout.

define temp-table tt-ext-artic no-undo like ub.ext-artic
  field artic as character
.

define buffer buf_tt-ext-artic for tt-ext-artic.

define variable v-filename as character no-undo .
define variable v-log      as logical   no-undo .

do
on error undo, return error return-value
:
  run clear-tt in this-procedure .
  message
    "Выберите файл для выгрузки."
  view-as alert-box information.
  SYSTEM-DIALOG GET-FILE v-filename
                TITLE   "Файл"
                FILTERS "Все файлы (*.*)"    "*.*"
                USE-FILENAME
                ASK-OVERWRITE
                SAVE-AS
                UPDATE v-log.
  if v-log <> true
  then do:
    return.
  end.
  run fill-tt in this-procedure .
  run output-tt in this-procedure ( input v-filename ) .
  run clear-tt in this-procedure .
  message
    "Отчет сформирован."
  view-as alert-box information.
end.

/* ===================================================================== */
procedure fill-tt :
  define buffer buf_ext-artic for ub.ext-artic.
  define buffer buf_goods     for ub.goods.
do
on error undo, return error return-value
:
  run waitfram-show in this-procedure (input "Поиск внешних артикулов...").
  for each buf_ext-artic no-lock
    where buf_ext-artic.status_ <> {&deleted-status} ,
  first buf_goods no-lock
    where buf_goods.gds-code = buf_ext-artic.gds-code
  :
    create buf_tt-ext-artic.
    buffer-copy buf_ext-artic to buf_tt-ext-artic
    assign
      buf_tt-ext-artic.artic = buf_goods.artic
    .
  end.
  run waitfram-hide in this-procedure .
end.

end procedure. /* fill-tt */

/* ===================================================================== */
procedure clear-tt :

do
on error undo, return error return-value
:
  empty temp-table buf_tt-ext-artic.

end.

/* ===================================================================== */
end procedure. /* clear-tt */

procedure output-tt :
  define input  parameter p-filename as character no-undo .

  define variable v-str       as character no-undo .
do
on error undo, return error return-value
:
  output stream sout to value(p-filename).

  run waitfram-show in this-procedure (input "Вывод внешних артикулов в файл...").
  for each buf_tt-ext-artic
  break by buf_tt-ext-artic.cli-type
        by buf_tt-ext-artic.cli-code
        by buf_tt-ext-artic.ext-artic
        by buf_tt-ext-artic.artic
  :
    if( first-of(buf_tt-ext-artic.cli-type) or first-of(buf_tt-ext-artic.cli-code))
    then do:
      put stream sout unformatted substitute("&1 &2", buf_tt-ext-artic.cli-type , buf_tt-ext-artic.cli-code) skip.
    end.
    if(first-of(buf_tt-ext-artic.ext-artic))
    then do:
      assign
        v-str = substitute( "&1" , buf_tt-ext-artic.ext-artic)
      .
    end.

    assign
      v-str = v-str + ",":U + substitute("&1", buf_tt-ext-artic.artic)
    .

    if(last-of(buf_tt-ext-artic.ext-artic))
    then do:
      put stream sout unformatted v-str skip.
      assign
        v-str = ""
      .
    end.
  end.
  output stream sout close.
  run waitfram-hide in this-procedure .
end.

end procedure. /* output-tt */