/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура закачки чеков в инвентаризацию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/05
Author: Bakhtadze Natalya
Creation date: 03/21/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure proc-main :
define input parameter p-status_ like ub.trn-doc.status_ no-undo .
define input parameter p-flag_ as logical no-undo .
define input parameter p-direction as integer no-undo .
define variable accum-chk-doc-tot-doc as decimal no-undo.
define variable v-add as logical no-undo .
define variable glog as logical no-undo .
define variable action as character no-undo .
define variable v-rc-ii as integer no-undo initial 1.
define variable v-rc-max as integer no-undo .
define variable v-first as logical no-undo init yes .
define variable recid-line as recid no-undo .
define variable pl-str        as character no-undo.             /* строка для складского места                      */
define variable conf-par      as character no-undo.             /* для чтения параметра конфигурации */
define variable par-type      as character no-undo.             /* тип параметра конфигурации */
define variable varplace      as logical   no-undo.
define variable is-err        as logical   no-undo initial no .
define variable v-num         as integer   no-undo.
define variable v-user-action as character no-undo.
define variable v-printed     as logical   no-undo.
define variable varerr        as logical   no-undo.
define variable varanlz       as logical   no-undo.
define variable varlog        as logical   no-undo.
define variable varvalue      as character no-undo.
define variable vartype       as character no-undo.
define variable varline-file  as character no-undo.
define variable scan-name     as character no-undo.             /* имя обрабатываемого файла со сканера (без расширения) */
define variable varnoapnd     as logical   no-undo .
define variable ii            as integer   no-undo.
define variable jj            as integer   no-undo.
define variable v-chk-type    as character no-undo .
define variable v-to-inc      as logical   no-undo .
define variable v-direction   as integer   no-undo .
define variable v-query-prepare as character no-undo .
define variable v-mode        as character no-undo .
define variable v-is-petrolium as logical no-undo.
define variable v-is-pieces as logical no-undo.

define buffer bb_doc-line for ub.doc-line.
define buffer bb_gds-prt  for ub.gds-prt.
define buffer bb_goods    for ub.goods.
define buffer bb_gds-dtl  for ub.gds-dtl.
define buffer bb_bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.

define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_tt-chk-gds for tt-chk-gds.

_main:
do
on error undo, return error return-value
:
  /*удалим контейнер для объединяющих бар-кодов*/

  for each in-bc on error undo _main, return error return-value :
    delete in-bc.
  end.
  for each un-bc on error undo _main, return error return-value :
    delete un-bc.
  end.
  for each main-bc on error undo _main, return error return-value :
    delete main-bc.
  end.
  for each anlz-bc on error undo _main, return error return-value :
    delete anlz-bc.
  end.
  /*обработка товарных строк*/
  scan-name = substitute("&1-чеки", t-doc.doc-code).

  find first ub.sysconf no-lock where
            ub.sysconf.host-code = t-doc.host-code .
  g-type = if t-doc.office then {&gds-office} else {&gds-goods}.

{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'noapndsc' then varnoapnd = thbjattr_thbj-attr.property-value-logical  .
end.

  if varnoapnd  then do:
    output stream log to value (scan-name + ".log").
    output stream err to value (scan-name + ".err").
    output stream ler to value (scan-name + ".ler").
  end.
  else do:
    output stream log to value (scan-name + ".log") append.
    output stream err to value (scan-name + ".err") append.
    output stream ler to value (scan-name + ".ler") append.
  end.
  put stream log unformatted "  " skip.
  put stream log unformatted cur-time-string-sec() skip.
  put stream ler unformatted "  " skip.
  put stream ler unformatted cur-time-string-sec() skip.
  if add-sens = ? then
    put stream log unformatted " " skip skip "Привязка партий к складским местам.  Объект : " v-cntxt-obj-type " " string (v-cntxt-obj-code) skip skip.
  else do:
    put stream log unformatted " " skip skip "Накладная: " t-doc.doc-code
          " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " p-status_ " ОК: " string (p-flag_, "+/-") skip skip.
    put stream ler unformatted " " skip skip "Накладная: " t-doc.doc-code
          " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " p-status_ " ОК: " string (p-flag_, "+/-") skip skip.
    /* установка типа документа товар / услуга */
    find first buf_doc-line where
              buf_doc-line.doc-code = t-doc.doc-code no-lock no-error.
    if available buf_doc-line then do:
      find first buf_goods where
               buf_goods.artic = buf_doc-line.artic
           and buf_goods.prod-type = buf_doc-line.prod-type
           and buf_goods.prod-code = buf_doc-line.prod-code no-lock.
      g-type =  buf_goods.gds-type.
    end.
  end.
  if p-status_  = {&permitted} and
    add-sens       = ?            then do:
    return.
  end.
  if p-status_  = {&permitted}
    or (p-status_ = {&permitted}
        and p-flag_ = yes
        and p-direction = 1
        ) /*перевод статуса*/
    then do:
    put stream log unformatted " " skip skip "!!! Инвентаризация: " t-doc.doc-code
          " подсчет суммарных количеств для одинаковых кодов." skip skip.
  end.
  assign
  accum-chk-doc-tot-doc = 0
  v-rc-max = (if p-rid-list <> '':U then num-entries(p-rid-list) else 1)
  v-rc-ii = (if p-rid-list <> '':U
             then (if available X_chk-doc
                   then lookup(string(recid(X_chk-doc)), p-rid-list)
                   else v-rc-ii)
             else v-rc-ii)
  .
  if (p-status_ = {&permitted}
  and p-direction = -1)
  then do:
    ASSIGN
    v-query-prepare = substitute("for each X_chk-doc no-lock where X_chk-doc.out-code = '&1'":U, t-doc.doc-code).
    assign
    glog = QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare) No-error.
    IF not glog
    THEN DO:
      undo, return error substitute("Ошибка при построении запроса по чекам инвентаризации:&1&2&1&3"
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
    END.
    assign
    glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
    IF not glog
    THEN DO:
      undo, return error substitute("Ошибка при открытии запроса по чекам инвентаризации:&1&2&1&3"
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
    END.
    ASSIGN
    glog = QUERY query-chk-doc:GET-FIRST(no-LOCK) NO-ERROR.
    IF not glog THEN DO:
      RETURN.
    END.
    ASSIGN
    glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
    do while locked (X_chk-doc ) and available X_chk-doc:
      glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
    end.
  end.
  c-d:
  DO WHILE available X_chk-doc or (p-rid-list <> '':U and  v-rc-ii <= v-rc-max) or action = "next"
  on error undo c-d, NEXT c-d
  on stop undo c-d, NEXT c-d:
    action = '':U.
    if not v-first then do:
      if p-rid-list = "":U then do:
        ASSIGN
        glog = QUERY query-chk-doc:GET-next(no-LOCK) NO-ERROR.
        if available X_chk-doc then do:
          ASSIGN
          glog = QUERY query-chk-doc:GET-current(exclusive-LOCK, no-wait) NO-ERROR.
          /*GET NEXT query-chk-doc EXCLUSIVE-LOCK No-WAIT .*/
          if locked(X_chk-doc) then do:
            error-status:error = no.
            action = "next".
            next c-d.
          end.
        end.
      end.
      else do:
        assign
        v-rc-ii = v-rc-ii + 1.
        _v-rc:
        do while v-rc-ii <= v-rc-max:
          find first X_chk-doc exclusive-lock where
                    recid(X_chk-doc) = integer(entry(v-rc-ii, p-rid-list))  no-error  NO-WAIT.
          if locked X_chk-doc or not available X_chk-doc then do:
            assign
            v-rc-ii = v-rc-ii + 1.
            next _v-rc.
          end.
          else LEAVE _v-rc.
        end.
        if v-rc-ii > v-rc-max then release X_chk-doc.
      end.
      if (not available X_chk-doc and action = '':U)
      or (p-rid-list <> "":U and v-rc-ii > v-rc-max) then LEAVE c-d.
    end. /*if not v-first then do:*/
    if v-first then v-first = no.
    if lookup(string(X_chk-doc.chk-type), {&inventory-receipt-codes}) = 0 then next c-d.
    if X_chk-doc.out-code = ? then do:
      /*
      if cas-shft then do:
        if t-doc.doc-date <> X_chk-doc.shift-date OR t-doc.shift-num <> X_chk-doc.shift-num then do:
          NEXT c-d .    /* пропускаем, если не та дата */
        end.
      end. /*cas-shft*/
      else do:
        if p-day-only then do:
          if t-doc.doc-date <> X_chk-doc.shift-date then do:
            NEXT c-d .
          end.
          /* пропускаем, если не та дата */
        end.
        else do:
          if X_chk-doc.shift-date > t-doc.shift-date
          /*и не установлен фильтр и не выборочно*/
          and p-rid-list = "":U
          then do:
            NEXT c-d .
          end.
          /* пропускаем, если не та дата */
        end.
      end. /*not cas-shft*/
      */
      assign
      v-chk-type = replace(X_chk-doc.office, '0', '':U)
      v-chk-type = replace(v-chk-type, {&comma-char} + {&comma-char}, {&comma-char})
      v-chk-type = trim(v-chk-type, {&comma-char})
      .
      if (v-chk-type <> g-type or v-chk-type = ?)
      then do:
        NEXT c-d .
      end.
      if  v-chk-type <> g-type
      and v-chk-type <> '':U then do:
        NEXT c-d .
      end.
      assign
      p-ii = p-ii + 1
      .
      if p-ii < 10
      or (p-ii < 1000 and chk-amount modulo 10 = 0)
      or (p-ii < 10000 and chk-amount modulo 100 = 0)
      then do:
        run display-chk in p-call-handle ( input chk-amount).
      end.
    end. /*если еще не включен*/
    if entry(1, X_chk-doc.doc-num, {&delim-par}) = t-doc.doc-code then do:
      run display-message in p-call-handle ( input substitute("Чек &1 уже был обсчитан&2" +
                                                                 "Если в нем остались необсчитанные товары,&2" +
                                                                 "Их может обсчитать потоварно"
                                                                 , X_chk-doc.doc-code
                                                                 , {&new-line})).
    end.
    if X_chk-doc.out-code = ?
    then do:
      assign
      v-to-inc = yes.
    end.
    else do:
      assign
      v-to-inc = no.
    end.
    if X_chk-doc.out-code = t-doc.doc-code
    and p-status_ = {&permitted}
    and p-flag_ = yes
    and p-direction = 1
    and p-chk-gds-rid-list = '':U
    then do:
      assign
      v-direction = p-direction.
    end.
    else do:
      assign
      v-direction = 0.
    end.
    _one-check:
    do
    on error undo _one-check, leave _one-check
    on stop undo _one-check, leave _one-check
    :
      _buf_chk-gds:
      FOR EACH buf_chk-gds WHERE buf_chk-gds.doc-code = X_chk-doc.doc-code
      on error undo _one-check, LEAVE _one-check
      on stop undo _one-check, leave _one-check
      :
        if p-chk-gds-rid-list <> "":U
        and lookup(string(recid(buf_chk-gds)), p-chk-gds-rid-list) = 0 then next _buf_Chk-gds.
        if p-chk-gds-rid-list <> "":U then do:
          if p-status_ = {&permitted}
          and p-flag_ = yes
          and p-direction = 1
          then do:
            assign
            v-direction = p-direction.
          end.
          else do:
            assign
            v-direction = 0.
          end.
        end.
        assign
        buf_chk-gds.is-error = (if buf_chk-gds.out-code = ?
                                then yes
                                else (if p-status_ = {&permitted}
                                      and p-flag_ = yes
                                      and p-direction = -1
                                      then yes
                                      else buf_chk-gds.is-error)
                               )
        buf_chk-gds.out-code = (if buf_chk-gds.out-code = ?
                                then t-doc.doc-code
                                else buf_chk-gds.out-code)
        .
        if buf_chk-gds.doc-qnty = 0 then do:
          buf_chk-gds.is-err = no.
          NEXT _Buf_chk-gds.
        end.
        if buf_chk-gds.is-error = no then do:
          NEXT _Buf_chk-gds.
        end.
        if p-status_ = {&wayb}
        and p-flag_ <> yes
        then do:
          /*добавляем строку*/
          FIND FIRST buf_bar-code WHERE
                   buf_bar-code.b-code = buf_chk-gds.b-code NO-LOCK NO-ERROR.
          if not avail buf_bar-code then do:
            next _buf_chk-gds.
          end.
          FIND FIRST buf_goods WHERE
                    buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK.
          { str/adinvlin.i
            parparentproc
            t-doc.doc-code
            buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            recid-line
            no-error
          }
          if error-status:error then do:
            buf_chk-gds.is-err = yes.
          end.
          find first buf_doc-line where recid(buf_doc-line) = recid-line exclusive-lock.
          buf_doc-line.prt-OK = ?.   /* пометка, что запись нужна и значение на начало инв-и */
          buf_chk-gds.is-err = yes.
        end.
        assign
        buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type) + {&delim-par} + {&TDEDT_Inv}
        .
        /*чек уже включен - пересчитываем ошибочные*/
        if not v-to-inc
        and p-direction = 1
        then do:
          create buf_tt-chk-gds.
          buffer-copy buf_chk-gds to buf_tt-chk-gds.
          release buf_tt-chk-gds.
        end.
      END . /*FOR EACH chk-gds*/
      if not v-to-inc
      and p-direction = 1
      and not can-find(first tt-chk-gds) then do:
        leave _one-check.
      end.
      /*история*/
      if v-to-inc then do:
        for each buf_c-chk-doc where
                buf_c-chk-doc.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-doc.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-gds where
                buf_c-chk-gds.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-gds.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-discnt where
                buf_c-chk-discnt.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-discnt.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-pay where
                buf_c-chk-pay.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-pay.out-code = t-doc.doc-code
          .
        end.
        for each buf_c-chk-doc-attr where
                buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code:
          assign
          buf_c-chk-doc-attr.out-code = t-doc.doc-code
          .
        end.
        /*чек в целом*/
        assign
        X_chk-doc.out-code = t-doc.doc-code
        chk-amount = chk-amount + 1
        accum-chk-doc-tot-doc = accum-chk-doc-tot-doc  + X_chk-doc.tot-doc
        .
      end.
      if p-status_ = {&wayb}
      and p-flag_   <> yes then do:
      end. /*в статусе накл*/
      if (p-status_ = {&permitted}
      and p-flag_ = yes
      and p-direction = 1) /*перевод статуса*/
      or p-status_ = {&permitted} /*включение в статусе permitted или пересчет*/
      then do:
        find first tt-chk-gds no-error.
        /*разберемся с количеством*/
        repeat while v-to-inc
        or v-direction = 1
        or can-find (first tt-chk-gds)
        :
          find first tt-chk-gds no-error.
          if p-chk-gds-rid-list <> '':U then do:
            for each un-bc on error undo _main, return error return-value :
              delete un-bc.
            end.
            for each anlz-bc on error undo _main, return error return-value :
              delete anlz-bc.
            end.
          end.
          run str/bc-anlz.p (
                         input parparentproc
                        ,input "chk-doc"    /*parworkmode*/
                        ,input  (if v-to-inc or (v-direction = 1 and not available tt-chk-gds)
                                then X_chk-doc.doc-code
                                else (X_chk-doc.doc-code + {&comma-char} + string(tt-chk-gds.line-num))
                                )
                        ,input yes
                        ,output varerr
                        ,output table in-bc ) no-error .
          if error-status:error then do:
          end.
          if varerr = yes then is-err = yes.
          if available tt-chk-gds then delete tt-chk-gds.
          find first tt-chk-gds no-error .
          if v-to-inc then v-to-inc = no.
          if v-direction = 1 then v-direction = 0.
          if p-chk-gds-rid-list <> '':U then do:
            define variable vari    as integer no-undo.
            define variable vartime as integer no-undo.
            for each un-bc on error undo, return error return-value :
                assign
                  vari = vari + 1.
                run display-message in p-call-handle ( INPUT substitute("Записываем ошибки разбора чека инвентаризации в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
                if un-bc.rez = "err" then do:
                  put stream log unformatted un-bc.err-msg skip.
                  put stream ler unformatted un-bc.err-msg skip.
                  put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
                  assign is-err = yes.
                end.
            end.
            run waitfram-hide in this-procedure.
          end.
        end. /*repeat*/
      end. /*в статусе разр*/
      assign
      p-ii-ok = p-ii-ok + 1
      .
    end. /*doe - one-ch*/
    if p-status_ = {&permitted}
    and p-chk-gds-rid-list = '':U then do:
      entry(1, X_chk-doc.doc-num, {&delim-par}) = t-doc.doc-code.
    end.
    if p-status_ = {&permitted}
    and p-direction = - 1
    and p-chk-gds-rid-list = '':U then do:
      entry(1, X_chk-doc.doc-num, {&delim-par}) = '':U.
    end.
  END. /* do _c-d*/
  /*Запишем результат разбора в log-file*/
  run display-message in p-call-handle ( input "Записываем результат разбора чека инвентаризации файла в log-файл.").
  assign
    vari    = 0.
    vartime = time.
  if p-chk-gds-rid-list = '':U then do:
    for each un-bc on error undo, return error return-value :
        assign
          vari = vari + 1.
        run waitfram-show in this-procedure (substitute("Записываем ошибки разбора чека инвентаризации в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
        if un-bc.rez = "err" then do:
          put stream log unformatted un-bc.err-msg skip.
          put stream ler unformatted un-bc.err-msg skip.
          put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
          assign is-err = yes.
        end.
    end.
  end.
  run waitfram-hide in this-procedure.
  _main-bc:
  for each main-bc on error undo, return error return-value :
    assign
    ii = i
    ii = ii + 1
    i = ii
    .
    run display-processed in p-call-handle ( input ii).
    find first ub.bar-code where ub.bar-code.b-code   = main-bc.b-c        no-lock.
    find first ub.goods    where ub.goods.gds-code    = ub.bar-code.gds-code  no-lock.
    find first ub.gds-prt  where ub.gds-prt.node-code = ub.bar-code.node-code no-lock.
    { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      v-is-petrolium
      v-is-pieces
    }
    if v-is-petrolium = yes and
      v-is-pieces    = no  then do:
      message "Товар " goods.artic " " goods.prod-type " " goods.prod-code " является жидким топливом." skip
              "Товар нельзя добавить из чека."
      view-as alert-box error.
      put stream log unformatted "Бар-код " bar-code.b-code " принадлежит жидкому топливу - нельзя добавить из чека." skip.
      put stream ler unformatted "Бар-код " bar-code.b-code " принадлежит жидкому топливу - нельзя добавить из чека." skip.
      put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
      assign is-err = yes.
      next.
    end.
    if gds-prt.is-term <> yes then do:
      put stream log unformatted "Бар-код " bar-code.b-code " не является кодом терминального признака." skip.
      put stream ler unformatted "Бар-код " bar-code.b-code " не является кодом терминального признака." skip.
      put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
      assign is-err = yes.
      next.
    end.
    /*Установим переменные для обработки в процедуре*/
    assign bar-str  = string(main-bc.b-c)
          qnty-str = string(main-bc.scn-qnty)
          rate     = 1
          pl-str   = main-bc.scn-pl
          mess     = main-bc.des.

    find first buf_doc-line no-lock where
              buf_doc-line.artic = goods.artic
          and buf_doc-line.prod-type = goods.prod-type
          and buf_doc-line.prod-code = goods.prod-code
          and buf_doc-line.doc-code = t-doc.doc-code
          no-error.
    /*
    по требованию Гаврилковой - теперьл будем ругаться если пытались добавить бар-код которого нет в документе и нельзя создать
    например в статусе разр
    if not available buf_Doc-line then do:
      next _main-bc.
    end.
    */
    run proc-code in this-procedure ( input main-bc.scn-pl
                                      ,input (if main-bc.rez = "place" then "place" else "")
                                      ,input varscales-pref
                                      ,input varpgscales-pref
                                      ) no-error.
    if error-status:error then do:
      assign is-err = yes.
    end.
    else do:
      assign
      jj = j
      jj = jj + 1
      j = jj
      .
      run display-processed-ok in p-call-handle ( input jj).
    end.
  end. /*for each main-bc*/
  output stream log close.
  output stream err close.
  output stream ler close.
  if is-err then do:
      message "Во время загрузки чеков:" scan-txt "обнаружены ошибки." skip
              "Смотрите ler файл."
      view-as alert-box error buttons ok.
      if search (scan-name + ".ler") <> ? then do:
        run gbl/prnfilen.w (
           input  substitute("Ошибки, обнаруженные во время загрузки чеков")
          ,input  0
          ,input  scan-name + ".ler"
          ,input  7
          ,output v-user-action
          ,output v-printed
          ).
      end.
  end.
  run display-chk in p-call-handle ( input chk-amount ).
end. /*doe*/
end procedure. /* proc-main */




/* $Workfile$ e n d */