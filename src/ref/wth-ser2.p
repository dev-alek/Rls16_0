block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-ser2.p $
$Archive: ref/wth-ser2.p $

Процедура удаления\смены статуса серии МЦ

Автор: Гридчина Полина Дмитриевна
Дата создания: 05/15/07
Author: Polina Gridchina
Creation date: 05/15/07

Input:

Output:

*/
define input parameter p-rec as recid no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-stts like ub.wth-ser.stts no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-ser2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wth-ser2.p $":U .
define variable vss-description as character no-undo init "Процедура удаления\смены статуса серии МЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
 define buffer buf_wth-ser    for ub.wth-ser.
 define variable v-mess        as character no-undo .
 define variable v-old-stts    as integer      no-undo.

main-block: do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find  first buf_wth-ser where recid(buf_wth-ser) = p-rec exclusive-lock .
  v-old-stts = buf_wth-ser.stts.

  case p-stts:
    when 1 then do:
      if  buf_wth-ser.stts = 1 then do:
        v-mess =   'Запись уже имеет статус ' + {&deleted-stat_}.
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end case.

  assign buf_wth-ser.stts = p-stts.
  release buf_wth-ser no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при изменении статуса серии(маски) МЦ:&1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value
                         ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.

end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Серия МЦ: код &1-&2 &3&4"
                         , buf_wth-ser.ser-code
                         , buf_wth-ser.db-num
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.