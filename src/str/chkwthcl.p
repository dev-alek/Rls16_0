block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkwthcl.p $
$Archive: str/chkwthcl.p $

Проверка партий при закрытии документа

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/18/07
Author: Polina Gridchina
Creation date: 09/18/07

Проверяет наличии номеров указанных в партиях в других зонах Если в своб зоне, клиентской или погашения то возвращаем ошибку
При наличии в зоне уничтожения - предупреждение

*/

define input parameter p-doc-code as char no-undo.
define input parameter p-file-name-err as char no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkwthcl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkwthcl.p $":U .
define variable vss-description as character no-undo init "Проверка партий при закрытии документа".


{ cmp/vssrevis.i p-doc-code }
{ cmp/trg-def.i  }
{ cmp/library.i  }

define variable v-flag-doc-err  as logical      no-undo.
define variable v-flag-doc-warning  as logical      no-undo.
define buffer cls_wth-parts   for ub.wth-parts.
define buffer cls_wth-doc     for ub.wth-doc.
define buffer parent_wth-doc  for ub.wth-doc.
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wealth      for ub.wealth.
define buffer buf_wth-ser     for ub.wth-ser.
define stream str-err .
define variable v-i    as integer      no-undo.
DEFINE VARIABLE v-EndDate AS date NO-UNDO.
DEFINE VARIABLE v-BegDate AS date NO-UNDO.

mainBlock :
do on error undo, return error
:
  find first cls_wth-doc where cls_wth-doc.doc-code = p-doc-code
  exclusive-lock no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ"  skip
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
  output stream str-err to value(p-file-name-err) append .

  for each cls_wth-parts no-lock where cls_wth-parts.out-code = p-doc-code
  , first buf_wealth no-lock  where buf_wealth.wth-code  = cls_wth-parts.wth-code
  , first buf_wth-ser no-lock where buf_wth-ser.ser-code = cls_wth-parts.ser-code
                                and buf_wth-ser.db-num = cls_wth-parts.db-num  :

    if cls_wth-doc.ext-doc-type = {&WDEDT_Inc_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exch}
    then
    for each buf_wth-parts no-lock where buf_wth-parts.wth-code = cls_wth-parts.wth-code
                                     and buf_wth-parts.ser-code = cls_wth-parts.ser-code
                                     and buf_wth-parts.db-num   = cls_wth-parts.db-num
                                     and buf_wth-parts.out-code = {&free-code}
                                     and buf_wth-parts.fact-rangeFrom <= cls_wth-parts.fact-rangeTo
                                     and buf_wth-parts.fact-rangeTo >= cls_wth-parts.fact-rangeFrom
                                :
        v-flag-doc-err = yes.
        put stream str-err unformatted
          substitute("В свободной зоне существуют МЦ &1 (код &2) серии &3 (код серии &4-&5) с номерами &6-&7"
                    ,buf_wealth.wth-name           /* 1 */
                    ,buf_wth-parts.wth-code        /* 2 */
                    ,buf_wth-ser.series            /* 3 */
                    ,buf_wth-parts.ser-code        /* 4 */
                    ,buf_wth-parts.db-num          /* 5 */
                    ,(if buf_wth-parts.fact-rangeFrom > cls_wth-parts.fact-rangeFrom then buf_wth-parts.fact-rangeFrom else cls_wth-parts.fact-rangeFrom)  /* 6 */
                    ,( if buf_wth-parts.fact-rangeTo > cls_wth-parts.fact-rangeTo then cls_wth-parts.fact-rangeTo else  buf_wth-parts.fact-rangeTo)  /* 7 */
                    ) skip .

    end.
    if cls_wth-doc.ext-doc-type = {&WDEDT_Inc_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exch}
    then
    for each buf_wth-parts no-lock where buf_wth-parts.wth-code = cls_wth-parts.wth-code
                                     and buf_wth-parts.ser-code = cls_wth-parts.ser-code
                                     and buf_wth-parts.db-num   = cls_wth-parts.db-num
                                     and buf_wth-parts.out-code = {&cli-zone}
                                     and buf_wth-parts.fact-rangeFrom <= cls_wth-parts.fact-rangeTo
                                     and buf_wth-parts.fact-rangeTo >= cls_wth-parts.fact-rangeFrom
                                :
        v-flag-doc-err = yes.
        put stream str-err unformatted
          substitute("В зоне клиента существуют МЦ &1 (код &2) серии &3 (код серии &4-&5) с номерами &6-&7"
                    ,buf_wealth.wth-name           /* 1 */
                    ,buf_wth-parts.wth-code        /* 2 */
                    ,buf_wth-ser.series            /* 3 */
                    ,buf_wth-parts.ser-code        /* 4 */
                    ,buf_wth-parts.db-num          /* 5 */
                    ,(if buf_wth-parts.fact-rangeFrom > cls_wth-parts.fact-rangeFrom then buf_wth-parts.fact-rangeFrom else cls_wth-parts.fact-rangeFrom)  /* 6 */
                    ,( if buf_wth-parts.fact-rangeTo > cls_wth-parts.fact-rangeTo then cls_wth-parts.fact-rangeTo else  buf_wth-parts.fact-rangeTo)  /* 7 */

                    ) skip .


    end.
    if cls_wth-doc.ext-doc-type = {&WDEDT_Inc_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exch}
    then
    for each buf_wth-parts no-lock where buf_wth-parts.wth-code = cls_wth-parts.wth-code
                                     and buf_wth-parts.ser-code = cls_wth-parts.ser-code
                                     and buf_wth-parts.db-num   = cls_wth-parts.db-num
                                     and buf_wth-parts.in-code  = cls_wth-parts.in-code
                                     and buf_wth-parts.out-code = {&put-zone}
                                     and buf_wth-parts.fact-rangeFrom <= cls_wth-parts.fact-rangeTo
                                     and buf_wth-parts.fact-rangeTo >= cls_wth-parts.fact-rangeFrom
                                :
        v-flag-doc-err = yes.
        put stream str-err unformatted
          substitute("В зоне погашения существуют МЦ &1 (код &2) серии &3 (код серии &4-&5) с номерами &6-&7"
                    ,buf_wealth.wth-name           /* 1 */
                    ,buf_wth-parts.wth-code        /* 2 */
                    ,buf_wth-ser.series            /* 3 */
                    ,buf_wth-parts.ser-code        /* 4 */
                    ,buf_wth-parts.db-num          /* 5 */
                    ,(if buf_wth-parts.fact-rangeFrom > cls_wth-parts.fact-rangeFrom then buf_wth-parts.fact-rangeFrom else cls_wth-parts.fact-rangeFrom)  /* 6 */
                    ,( if buf_wth-parts.fact-rangeTo > cls_wth-parts.fact-rangeTo then cls_wth-parts.fact-rangeTo else  buf_wth-parts.fact-rangeTo)  /* 7 */

                    ) skip .


    end.
    if cls_wth-doc.ext-doc-type = {&WDEDT_Inc_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext}
    or cls_wth-doc.ext-doc-type = {&WDEDT_Exch}
    then
    for each buf_wth-parts no-lock where buf_wth-parts.wth-code = cls_wth-parts.wth-code
                                     and buf_wth-parts.ser-code = cls_wth-parts.ser-code
                                     and buf_wth-parts.db-num   = cls_wth-parts.db-num
                                     and buf_wth-parts.out-code = {&output-code}
                                     and buf_wth-parts.fact-rangeFrom <= cls_wth-parts.fact-rangeTo
                                     and buf_wth-parts.fact-rangeTo >= cls_wth-parts.fact-rangeFrom
                                :
        v-flag-doc-warning = yes.
        put stream str-err unformatted
          substitute("В зоне уничтожения существуют МЦ &1 (код &2) серии &3 (код серии &4-&5) с номерами &6-&7"
                    ,buf_wealth.wth-name           /* 1 */
                    ,buf_wth-parts.wth-code        /* 2 */
                    ,buf_wth-ser.series            /* 3 */
                    ,buf_wth-parts.ser-code        /* 4 */
                    ,buf_wth-parts.db-num          /* 5 */
                    ,(if buf_wth-parts.fact-rangeFrom > cls_wth-parts.fact-rangeFrom then buf_wth-parts.fact-rangeFrom else cls_wth-parts.fact-rangeFrom)  /* 6 */
                    ,(if buf_wth-parts.fact-rangeTo > cls_wth-parts.fact-rangeTo then cls_wth-parts.fact-rangeTo else  buf_wth-parts.fact-rangeTo)  /* 7 */
                    ) skip .

    end.
    if cls_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext}  or
    (cls_wth-parts.ext-doc-type  = {&WDEDT_Exch} and cls_wth-parts.type  = {&Exchange} ) then do:  /*при внешнем расходе проверяем на обязательность задания срока годности*/
        if buf_wth-ser.chk-bdt = 2 and buf_wth-ser.beg-dt <> ? then v-BegDate = buf_wth-ser.beg-dt.
        else  v-BegDate = cls_wth-parts.beg-dt.
        if buf_wth-ser.chk-edt = 2 and buf_wth-ser.end-dt <> ? then v-EndDate = buf_wth-ser.end-dt.
        else  v-EndDate = cls_wth-parts.end-dt.

      if (v-BegDate = ? and not buf_wth-ser.chk-bdt = 1)  or (v-EndDate = ? and not buf_wth-ser.chk-edt = 1)  then do:
          v-flag-doc-err = yes.
              put stream str-err unformatted
              substitute("Не указан срок действия партии МЦ &1 (код &2) серии &3 (код серии &4-&5) диапазон &6-&7"
                      ,buf_wealth.wth-name           /* 1 */
                      ,cls_wth-parts.wth-code        /* 2 */
                      ,buf_wth-ser.series            /* 3 */
                      ,cls_wth-parts.ser-code        /* 4 */
                      ,cls_wth-parts.db-num          /* 5 */
                      ,cls_wth-parts.fact-rangeFrom
                      ,cls_wth-parts.fact-rangeTo
                      ) skip .

      end.

      if not (v-BegDate = ? or v-EndDate = ?) and v-BegDate > v-EndDate   then do:
          v-flag-doc-err = yes.
              put stream str-err unformatted
              substitute("Не верно указан срок действия партии МЦ &1 (код &2) серии &3 (код серии &4-&5) диапазон &6-&7 период с &8 по &9"
                      ,buf_wealth.wth-name           /* 1 */
                      ,cls_wth-parts.wth-code        /* 2 */
                      ,buf_wth-ser.series            /* 3 */
                      ,cls_wth-parts.ser-code        /* 4 */
                      ,cls_wth-parts.db-num          /* 5 */
                      ,cls_wth-parts.fact-rangeFrom
                      ,cls_wth-parts.fact-rangeTo
                      ,v-BegDate
                      ,v-EndDate
                      ) skip .

      end.
      if cls_wth-parts.price-rubl = 0 OR cls_wth-parts.price-rubl = ? then do:
          v-flag-doc-err = yes.
              put stream str-err unformatted
              substitute("Не указана цена. Партия МЦ &1 (код &2) серии &3 (код серии &4-&5) диапазон &6-&7"
                      ,buf_wealth.wth-name           /* 1 */
                      ,cls_wth-parts.wth-code        /* 2 */
                      ,buf_wth-ser.series            /* 3 */
                      ,cls_wth-parts.ser-code        /* 4 */
                      ,cls_wth-parts.db-num          /* 5 */
                      ,cls_wth-parts.fact-rangeFrom
                      ,cls_wth-parts.fact-rangeTo
                      ) skip .

      end.
          /*  Проверяем, что не закрываем документ реализации с просроченными талонами  */
      if cls_wth-doc.ext-doc-type = {&WDEDT_Exp_Ext}   and
         cls_wth-doc.fact-date >  cls_wth-parts.end-dt then do:
          v-flag-doc-err = yes.
              put stream str-err unformatted
              substitute("Срок годности партии меньше даты закрытия документа. Партия МЦ &1 (код &2) серии &3  диапазон &4-&5, срок годности &6-&7. Дата документа: &8"
                      ,buf_wealth.wth-name           /* 1 */
                      ,cls_wth-parts.wth-code        /* 2 */
                      ,buf_wth-ser.series            /* 3 */
                      ,cls_wth-parts.fact-rangeFrom
                      ,cls_wth-parts.fact-rangeTo
                      ,cls_wth-parts.beg-dt
                      ,cls_wth-parts.end-dt
                      ,cls_wth-doc.fact-date
                      ) skip .
      end.

    end.
    /* При закрытии задним числом проверяем, что документ породивший партии не более поздней датой, чем текущий */
    if  cls_wth-doc.is-back-date = yes then do:
      find first parent_wth-doc no-lock where  parent_wth-doc.doc-code = cls_wth-parts.doc-code
      no-error.
      if available parent_wth-doc
      and  parent_wth-doc.fact-date > cls_wth-doc.fact-date then do:
          v-flag-doc-err = yes.
          put stream str-err unformatted
          substitute("Документ, породивший партию, закрыт более поздней датой (дата закрытия: &8). Партия МЦ &1 (код &2) серии &3 (код серии &4-&5) диапазон &6-&7."
                  ,buf_wealth.wth-name           /* 1 */
                  ,cls_wth-parts.wth-code        /* 2 */
                  ,buf_wth-ser.series            /* 3 */
                  ,cls_wth-parts.ser-code        /* 4 */
                  ,cls_wth-parts.db-num          /* 5 */
                  ,cls_wth-parts.fact-rangeFrom
                  ,cls_wth-parts.fact-rangeTo
                  ,parent_wth-doc.fact-date
                  ) skip .

      end.
    end.


  end.
  if v-flag-doc-err then return error .
  else  os-delete value(p-file-name-err).
  if v-flag-doc-warning then return 'warning'.
end.