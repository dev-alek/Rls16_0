block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delnotcl.p $
$Archive: utl/delnotcl.p $

Удаление всех незакрытых документов

Автор: Суслов Алексей Юрьевич
Дата создания: 04/13/06
Author: Alexey Suslov
Creation date: 04/13/06


*/

define input parameter p-db-num like ub.db.db-num no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delnotcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delnotcl.p $":U .
define variable vss-description as character no-undo init "Удаление всех незакрытых документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
on delete of ub.rvs-doc   override do: end.
on delete of ub.rvs-line  override do: end.
on delete of ub.icnt-doc  override do: end.
on delete of ub.icnt-line override do: end.
on delete of ub.shift-obj override do: end.
on delete of ub.fbr-doc   override do: end.
on delete of ub.fbr-line  override do: end.
on delete of ub.trn-doc   override do: end.
do
on error undo, return error
:
  define variable lok       as logical  no-undo .
  define variable v-today   as date     no-undo.
  define variable v-time    as integer  no-undo.

  /* просматриваем все объекты данной БД */
  for each ub.clients no-lock
    where ub.clients.db-num = p-db-num
  on error undo, return error
  :
    /* складские документы не удаляем */
    /* переоценки не удаляем */
    /* сверки не удаляем */
    /* документы производства не удаляем */
    /* документы инвентаризации счетчиков ТРК не удаляем */

    for each ub.wth-doc exclusive-lock
      where ub.wth-doc.obj-type = ub.clients.obj-type
        and ub.wth-doc.obj-code = ub.clients.obj-code
        and ub.wth-doc.status_ <> {&fact}
    on error undo, return error
    :
      return error substitute
        ("ОШИБКА! Найдена не закрытый документ МЦ &1. Объект &2 &3"
        ,ub.wth-doc.doc-code
        ,ub.clients.obj-type
        ,ub.clients.obj-code
        ) .
    end.

    define variable v-fact-status-list as character no-undo .
    define variable ii as integer no-undo .
    define buffer buf_inkas for ub.inkas.
    v-fact-status-list = (if {&fact} < {&inquiry}
                          then ({&fact} + {&comma-char} + {&inquiry})
                          else ({&inquiry} + {&comma-char} + {&fact})).
    do ii = 0 to num-entries(v-fact-status-list):
      CASE ii:
        when 0 then do:
          find first buf_inkas no-lock
            where buf_inkas.obj-type = ub.clients.obj-type
              and buf_inkas.obj-code = ub.clients.obj-code
              and buf_inkas.status_ < entry(1, v-fact-status-list) no-error .
        end.
        when num-entries(v-fact-status-list) then do:
          find first buf_inkas no-lock
            where buf_inkas.obj-type = ub.clients.obj-type
              and buf_inkas.obj-code = ub.clients.obj-code
              and buf_inkas.status_ > entry(num-entries(v-fact-status-list), v-fact-status-list) no-error .
        end.
        otherwise do:
          find first buf_inkas no-lock
            where buf_inkas.obj-type = ub.clients.obj-type
              and buf_inkas.obj-code = ub.clients.obj-code
              and buf_inkas.status_ > entry(ii, v-fact-status-list)
              and buf_inkas.status_ < entry(ii + 1, v-fact-status-list)
              no-error .
        end.
      END CASE.
      if available buf_inkas then do:
        return error substitute
          ("ОШИБКА! Найдена не закрытая продажа &1. Объект &2 &3"
          ,buf_inkas.inkas-code
          ,ub.clients.obj-type
          ,ub.clients.obj-code
          ) .
      end.
    end.
  end.

  return .

end.