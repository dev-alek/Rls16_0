block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: expclia.p $
$Archive: utl/expclia.p $

Экспорт артикулов поставщиков из файла

Автор: Хныкин Павел Андреевич
Дата создания: 03/25/08
Author: Pavel Khnykin
Creation date: 03/25/08

*/
define input  parameter parparentproc   as handle     no-undo .
define input  parameter p-filename      as character  no-undo . /* полный путь к файлу */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: expclia.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/expclia.p $":U .
define variable vss-description as character no-undo init "Экспорт артикулов поставщиков из файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

&scop exp-delim ";":U

define temp-table tt-cli-art no-undo
  field cli-type  like ub.cli-gds.cli-type
  field cli-code  like ub.cli-gds.cli-code
  field host-code like ub.cli-gds.host-code
  field artic     like ub.cli-gds.artic
  field prod-type like ub.cli-gds.prod-type
  field prod-code like ub.cli-gds.prod-code
  field ext-artic like ub.cli-gds.cli-art
index pi is primary unique
  cli-type
  cli-code
  host-code
  artic
  prod-type
  prod-code
  ext-artic
.

define stream sout.

define buffer buf_cli-gds   for ub.cli-gds.
define buffer buf_ext-artic for ub.ext-artic.
define buffer buf_goods     for ub.goods.

define variable v-log           as logical   no-undo .
define variable v-full-filename as character no-undo .
define variable v-i             as integer   no-undo .
define variable v-cli-str       as character no-undo .
define variable v-cli-art       as character no-undo .

define frame exp-frame
  v-i                 format ">>>>>>>>9" label "Количество записей" skip
  v-cli-str           format "X(13)"     label "Поставщик"          skip
  v-cli-art           format "X(14)"     label "Артикул"
  with view-as dialog-box side-labels three-d
  title "Экспорт артикулов поставщиков в файл"
.

do on error undo, return error return-value
:

  message
    "Экспорт артикул поставщика в файл." skip (2)
    "Продолжить ?"
  view-as alert-box question buttons yes-no update v-log.
  if not v-log
  then do:
    return . /* --->>>--- */
  end.

  assign
    v-full-filename = search( p-filename )
  .
  if v-full-filename <> ?
  then do:
    message
      "Перезаписать файл " v-full-filename " ?"
    view-as alert-box question buttons OK-Cancel update v-log.
    if not v-log
    then do:
      return . /* --->>>--- */
    end.
  end.

  for each buf_ext-artic no-lock ,
    first buf_goods no-lock
        where buf_ext-artic.status_ = {&current-status}
          and buf_goods.gds-code = buf_ext-artic.gds-code
  :
    assign
      v-i       = v-i + 1
      v-cli-str = string(buf_ext-artic.cli-code, "999999999")  +  " "  +  trim(buf_ext-artic.cli-type)
      v-cli-art = buf_ext-artic.ext-artic
    .
    display
      v-i
      v-cli-art
      v-cli-str
    with frame exp-frame.
    pause 0.
    find first tt-cli-art no-lock
      where tt-cli-art.cli-type   = buf_ext-artic.cli-type
        and tt-cli-art.cli-code   = buf_ext-artic.cli-code
        and tt-cli-art.host-code  = 0
        and tt-cli-art.artic      = buf_goods.artic
        and tt-cli-art.prod-type  = buf_goods.prod-type
        and tt-cli-art.prod-code  = buf_goods.prod-code
        and tt-cli-art.ext-artic  = buf_ext-artic.ext-artic
    no-error .
    if not available tt-cli-art
    then do:
      create tt-cli-art.
      assign
        tt-cli-art.cli-type   = buf_ext-artic.cli-type
        tt-cli-art.cli-code   = buf_ext-artic.cli-code
        tt-cli-art.host-code  = 0
        tt-cli-art.artic      = buf_goods.artic
        tt-cli-art.prod-type  = buf_goods.prod-type
        tt-cli-art.prod-code  = buf_goods.prod-code
        tt-cli-art.ext-artic  = buf_ext-artic.ext-artic
      .
  end.
  end.

  output stream sout to value( p-filename ) .
  for each tt-cli-art :
    put stream sout unformatted
     tt-cli-art.cli-type                  + {&exp-delim} +
     trim(string(tt-cli-art.cli-code))    + {&exp-delim} +
     trim(string(tt-cli-art.host-code))   + {&exp-delim} +
     tt-cli-art.artic                     + {&exp-delim} +
     tt-cli-art.prod-type                 + {&exp-delim} +
     trim(string(tt-cli-art.prod-code))   + {&exp-delim} +
     tt-cli-art.ext-artic
    skip.
  end.




  output stream sout close.
  message
    "Экспорт завершен."
  view-as alert-box information.
end.