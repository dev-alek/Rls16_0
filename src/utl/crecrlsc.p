block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: crecrlsc.p $
$Archive: utl/crecrlsc.p $

отправка по новостям запроса значения seq s-sclc-code и создания, на его основе, диапазона локальных весовых кодов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crecrlsc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/crecrlsc.p $":U .
define variable vss-description as character no-undo init "отправка по новостям запроса значения seq s-sclc-code и создания, на его основе, диапазона локальных весовых кодов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }


on delete of ub.code-range override
do :
  define variable v-cmd     as character no-undo .
  define variable v-db-send as character no-undo .
  define buffer buf_db for ub.db .

  for each buf_db no-lock
    where buf_db.db-num > 0
  on error undo, return error :
    assign
      v-cmd = "dlcr" + {&delim-nws} + string(code-range.range-type) + {&delim-nws} + string(code-range.first-code)
    .
    if v-db-send = "":U then do:
      assign
        v-db-send = string( buf_db.db-num )
      .
    end.
    else do:
      assign
        v-db-send = v-db-send + {&delim-nws} + string( buf_db.db-num )
      .
    end.
  end.
  if v-db-send <> "":U then do:
    run nws/cr-route.p ( input {&send-cmd}, input v-cmd, input ?, input v-db-send ).
  end.
end.

do
on error undo, return error :

  define temp-table tmp-c-range no-undo like ub.code-range .
  define temp-table curr-seq-value no-undo
    field db-num    like ub.db.db-num
    field seq-value as   integer
    index pi db-num
    .
  define variable g#loq         as   logical               no-undo .
  define variable db-wait       as   character             no-undo .
  define variable max-seq-value as   integer               no-undo .
  define variable ind           as   integer               no-undo .
  define variable v-cmd     as character no-undo .
  define variable v-db-send as character no-undo .

  define stream info .

  define buffer buf_code-range  for ub.code-range .
  define buffer buf_db for ub.db .

  find first ub.sys-ctrl no-lock.
  if ub.sys-ctrl.db-num <> 0 then do:
    message "Запуск утилиты возможен только в ГБД."
            view-as alert-box ERROR.
    return error.
  end.
  if can-find( first ub.code-range where ub.code-range.range-type = {&loc-sc-code} no-lock ) then do:
    message "БД уже содержит диапазон(ы) локальных весовых кодов." skip
            "Запуск утилиты невозможен."
            view-as alert-box ERROR.
    return error.
  end.

  if can-find( first ub.db where ub.db.db-num > 0 no-lock ) then do:
    for each ub.rep
      where ub.rep.doc-num = -27091997
    on error undo, return error :
      find curr-seq-value where curr-seq-value.db-num = ub.rep.gr no-error.
      if available curr-seq-value then do:
        if ub.rep.num <= curr-seq-value.seq-value then do:
          next.
        end.
      end.
      else do:
        create curr-seq-value.
      end.
      assign
        curr-seq-value.db-num    = ub.rep.gr
        curr-seq-value.seq-value = ub.rep.num
        .
    end.
  end.
  else do:
    message "Вы действительно ходите начать процедуру создания начального диапазона локальных весовых кодов?"
            view-as alert-box QUESTION buttons YES-NO update g#loq.
    if not g#loq then do:
      return.
    end.
    create curr-seq-value.
    assign
      curr-seq-value.db-num    = 0
      curr-seq-value.seq-value = current-value( s-sclc-code, {&db-name_schema} )
      .
  end.

  assign
    max-seq-value = 0
    db-wait = ""
  .
  for each buf_db no-lock
     where buf_db.db-num >= 0
  on error undo, return error :
    if max-seq-value <> ? then do:
      find curr-seq-value where curr-seq-value.db-num = buf_db.db-num no-lock no-error.
    end.
    if not available curr-seq-value then do:
      assign
        max-seq-value = ?
        db-wait       = db-wait + " " + string( buf_db.db-num )
      .
    end.
    else do:
      if curr-seq-value.seq-value > max-seq-value then do:
        assign
          max-seq-value = curr-seq-value.seq-value
        .
      end.
    end.
  end.

  if can-find( first curr-seq-value no-lock ) then do:
    if max-seq-value = ? then do:
      message "Еще не собрана информация из УБД" db-wait skip
              "Дождаться сбора информации и запустить эту утилиту позже?"
              view-as alert-box QUESTION buttons YES-NO update g#loq.
      if g#loq then do:
        return.
      end.
      else do:
        run clear-temp-table.
      end.
    end.
    else do: /* создание диапозона */

      assign
        ind = 999
      .
      do while max-seq-value >= ind :
        assign
          ind = ind + 1000
        .
      end.
      assign
        max-seq-value = ind
      .

      output stream info to "del-cdrg.inf" append page-size 0 .
      put stream info unformatted cur-time-string-sec() skip .
      output stream info close .

      for each ub.code-range
        where ub.code-range.first-code >= 100
          and ub.code-range.last-code  <= 100000
      on error undo, return error
      :
        if lookup( ub.code-range.range-type, {&grp-bcode} ) <> 0 then do:
          output stream info to "del-cdrg.inf" append page-size 0 .
          put stream info unformatted "code-range delete:" skip .
          export stream info ub.code-range .
          output stream info close .
          delete ub.code-range.
        end.
      end.

      for each ub.code-range
        where ub.code-range.first-code < 100
          and ub.code-range.last-code  <= 100000
      on error undo, return error
      :
        if lookup( ub.code-range.range-type, {&grp-bcode} ) <> 0 then do:
          create tmp-c-range.
          buffer-copy ub.code-range to tmp-c-range .
          delete ub.code-range.
        end.
      end.
      for each tmp-c-range
      on error undo, return error
      :
        output stream info to "del-cdrg.inf" append page-size 0 .
        put stream info unformatted "code-range.last-code -> 99 :" skip .
        create buf_code-range.
        buffer-copy tmp-c-range to buf_code-range
          assign
            buf_code-range.range-type = {&loc-pt-code}
            buf_code-range.last-code  = 99
        .
        if buf_code-range.db-num = -1
           or buf_code-range.stts <> "f"
        then do:
          run str/callnews.p
            (input "code-range"
            ,input (buffer buf_code-range:handle)
            ).
        end.
        export stream info tmp-c-range .
        output stream info close .
        delete tmp-c-range.
      end.

      for each ub.code-range
        where ub.code-range.first-code < 100000
          and ub.code-range.last-code  > 100000
      on error undo, return error
      :
        if lookup( ub.code-range.range-type, {&grp-bcode} ) <> 0 then do:
          create tmp-c-range.
          buffer-copy ub.code-range to tmp-c-range .
          delete ub.code-range.
        end.
      end.
      for each tmp-c-range
      on error undo, return error
      :
        output stream info to "del-cdrg.inf" append page-size 0 .
        put stream info unformatted "code-range.first-code -> 100000 :" skip.
        create buf_code-range.
        buffer-copy tmp-c-range to buf_code-range
          assign
            buf_code-range.first-code = 100000
        .
        if buf_code-range.db-num = -1
           or buf_code-range.stts <> "f"
        then do:
          run str/callnews.p
            (input "code-range"
            ,input (buffer buf_code-range:handle)
            ).
        end.
        export stream info tmp-c-range .
        output stream info close .
        if tmp-c-range.first-code < 100 then do:
          output stream info to "del-cdrg.inf" append page-size 0 .
          put stream info unformatted "create code-range:" skip.
          create buf_code-range.
          assign
            buf_code-range.range-type = {&loc-pt-code}
            buf_code-range.PS         = "auto"
            buf_code-range.beg-date   = today
            buf_code-range.first-code = 1
            buf_code-range.last-code  = 99
            buf_code-range.db-num     = 0
            buf_code-range.stts       = "u":U
          .
          export stream info buf_code-range .
          output stream info close .
          run str/callnews.p
            (input "code-range"
            ,input (buffer buf_code-range:handle)
            ).
        end.
        delete tmp-c-range.
      end.

      create ub.code-range.
      assign
        ub.code-range.range-type = {&loc-sc-code}
        ub.code-range.PS         = "локальный весовой код"
        ub.code-range.beg-date   = today
        ub.code-range.first-code = 100
        ub.code-range.last-code  = max-seq-value
        ub.code-range.db-num     = 0
        ub.code-range.stts       = "a":U
      .

      run str/callnews.p
        (input "code-range"
        ,input (buffer ub.code-range:handle)
        ).

      release ub.code-range.


      run clear-temp-table.

      for each ub.rep
        where ub.rep.doc-num = -27091997
      on error undo, return error :
        delete ub.rep.
      end.

      message "Начальный диапазон локальных весовых кодов создан."
              view-as alert-box information.

      return.
    end.
  end.


  if not can-find( first curr-seq-value no-lock ) then do:
    message "Вы действительно ходите начать процедуру создания начального диапазона локальных весовых кодов?"
            view-as alert-box QUESTION buttons YES-NO update g#loq.
    if not g#loq then do:
      return.
    end.

    for each buf_db no-lock
      where buf_db.db-num >= 0
    on error undo, return error :
      assign
        v-cmd = "get-seq" + {&delim-nws} + "s-sclc-code" + {&delim-nws} + ""
      .
      if v-db-send = "":U then do:
        assign
          v-db-send = string( buf_db.db-num )
        .
      end.
      else do:
        assign
          v-db-send = v-db-send + {&delim-nws} + string( buf_db.db-num )
        .
      end.
    end.
    if v-db-send <> "":U then do:
      run nws/cr-route.p ( input {&send-cmd}, input v-cmd, input ?, input v-db-send ).
    end.

    create ub.rep.
    assign
      ub.rep.doc-num = -27091997
      ub.rep.gr      = 0
      ub.rep.num     = current-value( s-sclc-code, {&db-name_schema} )
    .
    message "Процедура создания начального диапазона локальных весовых кодов начата" skip
            "Необходимо обменяться новостями со всеми УБД." skip
            "После обмена запустите эти утилиты повторно."
            view-as alert-box information.
  end.
  run clear-temp-table.

end.

procedure clear-temp-table:
  for each curr-seq-value
  on error undo, return error :
    delete curr-seq-value.
  end.
end procedure.