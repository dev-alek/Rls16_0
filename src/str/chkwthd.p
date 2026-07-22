block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkwthd.p $
$Archive: str/chkwthd.p $

Проверка партий при удалении документов МЦ закрытых на факт

Автор: Гридчина Полина Дмитриевна
Дата создания: 06/26/07
Author: Polina Gridchina
Creation date: 06/26/07

Input:

Output:

*/
define input parameter p-doc-code as char no-undo.
define input parameter p-file-name-err as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkwthd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkwthd.p $":U .
define variable vss-description as character no-undo init "Проверка партий при удалении документов МЦ".
{ cmp/vssrevis.i p-doc-code }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define variable v-flag-doc-err  as logical      no-undo.
define variable v-line-count    as integer      no-undo.
define buffer del_wth-parts   for wth-parts.
define buffer del_wth-doc     for wth-doc.
define buffer buf_wth-parts   for wth-parts.
define stream str-err .


mainBlock :
do on error undo, return error
:
  find first del_wth-doc where del_wth-doc.doc-code = p-doc-code
  exclusive-lock no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

    assign
    v-flag-doc-err = no
  .
  if not g#news and search(p-file-name-err) <> ?
  then do:
    os-delete value(p-file-name-err).
  end.
  assign
    v-line-count = 0
  .
  /*Ищем партии порожденные данным документом*/
  for each buf_wth-parts where buf_wth-parts.doc-code = p-doc-code
  no-lock
  :
    if buf_wth-parts.out-code = p-doc-code then next.  /*Отсеиваем самопорожденные*/
    if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) = 0 then do:  /*партия относится к документу*/
    v-flag-doc-err = yes.
      if not g#news
      then do:
        output stream str-err to value(p-file-name-err) append .
        put stream str-err unformatted
          substitute("Найден документ, в котором фигурируют партии удаляемого документа.{&new-line}Код МЦ &1{&new-line}Код серии &2{&new-line}Номер документа &3{&new-line}Диапазон &4 - &5 "
                    ,buf_wth-parts.wth-code        /* 1 */
                    ,buf_wth-parts.ser-code        /* 2 */
                    ,buf_wth-parts.out-code        /* 3 */
                    ,buf_wth-parts.fact-rangeFrom  /* 4 */
                    ,buf_wth-parts.fact-rangeTo    /* 5 */
                    ,{&new-line}
                    ) skip .
        output stream str-err close.
      end.
      else do:
        undo mainBlock, return error substitute("Найден документ, в котором фигурируют партии удаляемого документа.{&new-line}Код МЦ &1{&new-line}Код серии &2{&new-line}Номер документа &3{&new-line}Диапазон &4 - &5 "
                    ,buf_wth-parts.wth-code        /* 1 */
                    ,buf_wth-parts.ser-code        /* 2 */
                    ,buf_wth-parts.out-code        /* 3 */
                    ,buf_wth-parts.fact-rangeFrom  /* 4 */
                    ,buf_wth-parts.fact-rangeTo    /* 5 */
                    ,{&new-line}
                    ) .
      end.
    end.
  end.

  if v-flag-doc-err then return error 'Ошибка при удалении документа'.
/*  for each del_wth-parts where del_wth-parts.out-code = p-doc-code
  exclusive-lock on error undo, return error return-value
  :

  end.  */


end.