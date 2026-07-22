block-level on error undo, throw.
using ibs.th.str.alcohol.*.
TRIGGER PROCEDURE FOR WRITE OF ub.trn-doc OLD BUFFER old-doc .
define variable vss-revision    as character no-undo initial "$Revision: c96af91888ad, 3081, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/08/05 16:16:26 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: trn-docw.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: trg/trn-docw.p $":U .
define variable vss-description as character no-undo initial "Триггер на запись документа":U .
define variable chg-qnty      as   decimal no-undo .
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
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4',ub.trn-doc.doc-code,ub.trn-doc.ext-doc-type,ub.trn-doc.status_,ub.trn-doc.flag_)
    .
end procedure.
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
end procedure.
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsobjcl :
  define input parameter p-gds-obj-recid    as recid no-undo .
  define input parameter p-update-fact-qnty as logical   no-undo .
  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl: расчет записи товар на объекте ".
  define buffer buf_parts for ub.parts .
  define variable v-total-avrg-base as decimal no-undo .
  define variable v-total-avrg-rubl as decimal no-undo .
  define variable v-total-avrg-qnty as decimal no-undo .
  define variable v-parts-avrg-qnty as decimal no-undo .
  define variable v-total-fact-base as decimal no-undo .
  define variable v-total-fact-rubl as decimal no-undo .
  define variable v-total-fact-qnty as decimal no-undo .
  define variable v-parts-fact-qnty as decimal   no-undo .
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_prt-obj for ub.prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_gds-obj exclusive-lock
      where recid(buf_gds-obj) = p-gds-obj-recid
      no-error .
    if not available buf_gds-obj
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена запись товар на объекте" skip
        "Код записи (recid)" p-gds-obj-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      v-total-avrg-base = 0
      v-total-avrg-rubl = 0
      v-total-avrg-qnty = 0
      v-total-fact-base = 0
      v-total-fact-rubl = 0
      v-total-fact-qnty = 0
    .
    for each buf_parts no-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
        and buf_parts.in-code   <> buf_parts.out-code
        and buf_parts.doc-type  <> 'акт':U
    on error undo, return error return-value
    :
      assign
        v-parts-avrg-qnty = 0
        v-parts-fact-qnty = 0
      .
      if buf_parts.out-code = 'free-zone':U
      then do:
        if buf_parts.fact-qnty > 0
        then do:
          assign
            v-parts-avrg-qnty = buf_parts.qnty
          .
        end.
        assign
          v-parts-fact-qnty = buf_parts.qnty
        .
      end.
      else do:
        assign
          v-parts-avrg-qnty = abs(buf_parts.qnty)
          v-parts-fact-qnty = abs(buf_parts.qnty)
        .
      end.
      assign
        v-total-avrg-base = v-total-avrg-base
                          + (buf_parts.price-base * v-parts-avrg-qnty)
        v-total-avrg-rubl = v-total-avrg-rubl
                          + (buf_parts.price-rubl * v-parts-avrg-qnty)
        v-total-avrg-qnty = v-total-avrg-qnty
                          + v-parts-avrg-qnty
        v-total-fact-base = v-total-fact-base
                          + (buf_parts.price-base * v-parts-fact-qnty)
        v-total-fact-rubl = v-total-fact-rubl
                          + (buf_parts.price-rubl * v-parts-fact-qnty)
        v-total-fact-qnty = v-total-fact-qnty
                          + v-parts-fact-qnty
      .
    end.
    if v-total-avrg-qnty < 0
    or v-total-avrg-qnty = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Количество положительных партий в свободной зоне не может быть отрицательным или неопределенным" + chr(10)
        + "v-total-avrg-qnty " + (if v-total-avrg-qnty <> ? then string(v-total-avrg-qnty) else "?")
        .
    end.
    if v-total-fact-base = ?
    or v-total-fact-rubl = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Сумма учетных цен по товару на объекте не может иметь неопределенное значение" + chr(10)
        + "v-total-fact-base " + (if v-total-fact-base <> ? then string(v-total-fact-base) else "?") + chr(10)
        + "v-total-fact-rubl " + (if v-total-fact-rubl <> ? then string(v-total-fact-rubl) else "?") + chr(10)
        .
    end.
    assign
      buf_gds-obj.avrg-qnty = v-total-avrg-qnty
      buf_gds-obj.fact-base = v-total-fact-base
      buf_gds-obj.fact-rubl = v-total-fact-rubl
    .
    if p-update-fact-qnty
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров"
        "В данной версии обновление фактического количества не реализовано" skip
        "p-update-fact-qnty" p-update-fact-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_gds-obj.fact-qnty <> v-total-fact-qnty
    then do:
      undo, return error
        vss-description + chr(10)
        + "Не совпадает общее количество по партиям и фактическое количество по товару на объекте" + chr(10)
        + "buf_gds-obj.fact-qnty " + (if buf_gds-obj.fact-qnty <> ? then string(buf_gds-obj.fact-qnty) else "?") + chr(10)
        + "v-total-fact-qnty "     + (if v-total-fact-qnty     <> ? then string(v-total-fact-qnty)     else "?") + chr(10)
        .
    end.
    if v-total-avrg-qnty > 0
    then do:
      assign
        buf_gds-obj.avrg-base = v-total-avrg-base / v-total-avrg-qnty
        buf_gds-obj.avrg-rubl = v-total-avrg-rubl / v-total-avrg-qnty
      .
    end.
    else do:
      if  buf_gds-obj.last-base > 0
      and buf_gds-obj.last-rubl > 0
      then do:
        assign
          buf_gds-obj.avrg-base = buf_gds-obj.last-base
          buf_gds-obj.avrg-rubl = buf_gds-obj.last-rubl
        .
      end.
    end.
    define variable v-total-sale-fact-qnty as decimal   no-undo .
    define variable v-total-fact-sale      as decimal   no-undo .
    assign
      v-total-sale-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = buf_gds-obj.obj-type
        and buf_prt-obj.obj-code  = buf_gds-obj.obj-code
        and buf_prt-obj.artic     = buf_gds-obj.artic
        and buf_prt-obj.prod-type = buf_gds-obj.prod-type
        and buf_prt-obj.prod-code = buf_gds-obj.prod-code
        and buf_prt-obj.is-term   = true
    on error undo, return error return-value
    :
      assign
        v-total-sale-fact-qnty  = v-total-sale-fact-qnty
                                + buf_prt-obj.fact-qnty
        v-total-fact-sale       = v-total-fact-sale
                                + buf_prt-obj.fact-qnty * buf_prt-obj.price-sale
      .
    end.
    if v-total-fact-sale = ?
    then do:
      undo, return error
        vss-description + chr(10)
        + "Сумма продажных цен по товару на объекте не может иметь неопределенное значение" + chr(10)
        + "v-total-fact-sale " + (if v-total-fact-sale <> ? then string(v-total-fact-sale) else "?") + chr(10)
        .
    end.
    if buf_gds-obj.fact-qnty <> v-total-sale-fact-qnty
    then do:
      undo, return error
        vss-description + chr(10)
        + "Не совпадает общее количество по признакам и фактическое количество по товару на объекте" + chr(10)
        + "buf_gds-obj.fact-qnty "  + (if buf_gds-obj.fact-qnty <> ?  then string(buf_gds-obj.fact-qnty)  else "?") + chr(10)
        + "v-total-sale-fact-qnty " + (if v-total-sale-fact-qnty <> ? then string(v-total-sale-fact-qnty) else "?") + chr(10)
        .
    end.
    assign
      buf_gds-obj.fact-sale = v-total-fact-sale
    .
  end.
end procedure .
procedure gdsobjcl-calc-goods :
  define input parameter p-artic     like ub.goods.artic     no-undo .
  define input parameter p-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-prod-code like ub.goods.prod-code no-undo .
  define variable vss-description as character no-undo init "$Workfile$ gdsobjcl-calc-goods".
  do
  on error undo, return error return-value
  :
    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_prt-obj for ub.prt-obj .
    do
    on error undo, return error return-value
    :
      for each buf_prt-obj
        where buf_prt-obj.artic     = p-artic
          and buf_prt-obj.prod-type = p-prod-type
          and buf_prt-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjup in g#library
  (buffer buf_prt-obj
  ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект "  + string(buf_prt-obj.obj-type) + " " + string(buf_prt-obj.obj-code) + chr(10)
            + "артикул " + string(buf_prt-obj.artic) + " " + string(buf_prt-obj.prod-type) + " " + string(buf_prt-obj.prod-code) + chr(10)
            + "признак " + string(buf_prt-obj.prt-code) + chr(10)
            + return-value .
        end.
      end.
      for each buf_gds-obj
        where buf_gds-obj.artic     = p-artic
          and buf_gds-obj.prod-type = p-prod-type
          and buf_gds-obj.prod-code = p-prod-code
      on error undo, return error return-value
      :
        run gdsobjcl in this-procedure
          (input recid(buf_gds-obj)
          ,input false
          ) no-error .
        if error-status :error
        then do:
          undo, return error
            "объект " + string(buf_gds-obj.obj-type) + " " + string(buf_gds-obj.obj-code) + chr(10)
            + return-value .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cust_prc :
  define parameter buffer buf_trn-doc  for ub.trn-doc  .
  define parameter buffer buf_doc-line for ub.doc-line .
  define input  parameter l-custvalue  as logical no-undo .
  def buffer l-d-l      for ub.doc-line.
  def buffer bf-parts   for ub.parts.
  define variable    lOK        as logical no-undo .
  define variable parnum-place  like ub.doc-line.num-place no-undo.
  define variable parwt-brutto  like ub.doc-line.wt-brutto no-undo.
  if l-custvalue then do:
    if  buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = no
    then do:
      find first bf-parts where bf-parts.obj-type  = buf_trn-doc.obj-type   and
                                bf-parts.obj-code  = buf_trn-doc.obj-code   and
                                bf-parts.prod-type = buf_doc-line.prod-type and
                                bf-parts.prod-code = buf_doc-line.prod-code and
                                bf-parts.artic     = buf_doc-line.artic     and
                                bf-parts.out-code  = buf_trn-doc.doc-code   and
                                bf-parts.cst-code <> ?                      and
                                bf-parts.cst-code <> ""                     no-lock no-error.
      if available bf-parts then do:
         find first bf-parts where bf-parts.obj-type  = buf_trn-doc.obj-type   and
                                   bf-parts.obj-code  = buf_trn-doc.obj-code   and
                                   bf-parts.prod-type = buf_doc-line.prod-type and
                                   bf-parts.prod-code = buf_doc-line.prod-code and
                                   bf-parts.artic     = buf_doc-line.artic     and
                                   bf-parts.out-code  = buf_trn-doc.doc-code   and
                                   (bf-parts.cst-code = ? or bf-parts.cst-code = "") no-lock no-error.
         if available bf-parts then do:
            message
             "Не определен номер ГТД в партии товара" skip
             "Документ" buf_trn-doc.doc-code skip
             "Артикул"  buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
             "Код партии" bf-parts.part-code skip
             view-as alert-box error .
           undo, return error return-value .
         end.
         if buf_doc-line.num-place = 0
         or buf_doc-line.num-place = ?
         then do:
           message
             "Не задано количество мест товара" skip
             "Документ" buf_trn-doc.doc-code skip
             "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
             view-as alert-box error .
           undo, return error return-value .
         end.
         if buf_doc-line.wt-brutto = 0
         or buf_doc-line.wt-brutto = ?
         then do:
           message
             "Не заведен вес брутто товара" skip
             "Документ" buf_trn-doc.doc-code skip
             "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
             view-as alert-box error .
           undo, return error return-value .
         end.
      end.
    end.
    else do:
      if  buf_trn-doc.doc-type <> 'инв':U
      and (   buf_doc-line.wt-brutto = 0
          or buf_doc-line.wt-brutto = ?
          or buf_doc-line.num-place = 0
          or buf_doc-line.num-place = ?)
      then do:
        find last l-d-l no-lock
          where l-d-l.artic     = buf_doc-line.artic
            and l-d-l.prod-type = buf_doc-line.prod-type
            and l-d-l.prod-code = buf_doc-line.prod-code
            and l-d-l.obj-type  = buf_doc-line.obj-type
            and l-d-l.obj-code  = buf_doc-line.obj-code
            and l-d-l.status_   = 'факт':U
            and l-d-l.num-place <> 0
            and l-d-l.num-place <> ?
            and l-d-l.wt-brutto <> 0
            and l-d-l.wt-brutto <> ?
            and recid(l-d-l)    <> recid(buf_doc-line)
          use-index fact-order
          no-error.
        if not available l-d-l then do:
          assign
            lOK = no
          .
          message
            "Не найдено ни одного веса товара:" buf_doc-line.artic " на объекте." skip
            "Будете задавать вручную?" skip
            view-as alert-box question buttons yes-no update lok.
          if lOK = yes then do:
            run str/set-wt.w
              (input  buf_doc-line.artic
              ,input  buf_doc-line.prod-type
              ,input  buf_doc-line.prod-code
              ,output parnum-place
              ,output parwt-brutto
              ) no-error.
            if error-status :error
            or parnum-place = 0
            or parnum-place = ?
            or parwt-brutto = 0
            or parwt-brutto = ?
            then do:
              message "Без указания веса и кол-ва мест нельзя закрыть накладную."
                view-as alert-box error buttons ok.
              undo, return error return-value .
            end.
            else do:
              do transaction
              on error undo, return error return-value
              :
                assign
                  buf_doc-line.num-place = parnum-place
                  buf_doc-line.wt-brutto = parwt-brutto
                .
              end.
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
        else do:
          do transaction
          on error undo, return error return-value
          :
            assign
              buf_doc-line.num-place = l-d-l.num-place * buf_doc-line.fact-qnty / l-d-l.fact-qnty
              buf_doc-line.wt-brutto = l-d-l.wt-brutto * buf_doc-line.fact-qnty / l-d-l.fact-qnty
            .
          end.
        end.
      end.
    end.
  end.
  else do:
    if buf_doc-line.num-place <> 0
    or buf_doc-line.wt-brutto <> 0
    then do:
      do transaction
      on error undo, return error return-value
      :
        assign
          buf_doc-line.num-place = 0
          buf_doc-line.wt-brutto = 0
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-trndocrs-gds-dtl-rsrv no-undo
  field prt-code         like ub.gds-dtl.prt-code
  field rsrv-qnty        like ub.gds-dtl.fact-qnty
  field rsrv-out-qnty    like ub.gds-dtl.fact-qnty
  index xpk is primary unique prt-code
.
define temp-table temp-trndocrs-pl-gds-rsrv no-undo
  field pl-code          like ub.pl-gds.pl-code
  field rsrv-qnty        like ub.pl-gds.free-qnty
  field cli-rsrv-qnty    like ub.pl-gds.cli-free-qnty
  field rsrv-out-qnty    like ub.pl-gds.fact-qnty
  field before-free-qnty like ub.pl-gds.fact-qnty
  field before-out-qnty  like ub.pl-gds.fact-qnty
  field after-free-qnty  like ub.pl-gds.fact-qnty
  field after-out-qnty   like ub.pl-gds.fact-qnty
  field fact-qnty        like ub.pl-gds.fact-qnty
  field cli-qnty         like ub.pl-gds.cli-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  index xpk is primary unique pl-code
.
procedure trndocrs-gds-dtl-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-clear :
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-accum :
  define input parameter p-pl-code       like ub.pl-gds.pl-code       no-undo .
  define input parameter p-rsrv-qnty     like ub.pl-gds.free-qnty     no-undo .
  define input parameter p-cli-rsrv-qnty like ub.pl-gds.cli-free-qnty no-undo .
  define input parameter p-fact-qnty     like ub.pl-gds.fact-qnty     no-undo .
  define input parameter p-cli-fact-qnty like ub.pl-gds.cli-fact-qnty no-undo .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-pl-gds-rsrv
      where buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      no-error .
    if not available buf_temp-trndocrs-pl-gds-rsrv then do:
      create buf_temp-trndocrs-pl-gds-rsrv .
      assign
        buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      .
    end.
    assign
      buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     = buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     + p-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty + p-cli-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     = buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     + p-fact-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty + p-cli-fact-qnty
    .
  end.
end procedure.
procedure trndocrs-gds-dtl-accum :
  define input parameter p-prt-code   like ub.gds-dtl.prt-code   no-undo .
  define input parameter p-rsrv-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv  for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-gds-dtl-rsrv
      where buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      no-error .
    if not available buf_temp-trndocrs-gds-dtl-rsrv then do:
      create buf_temp-trndocrs-gds-dtl-rsrv .
      assign
        buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      .
    end.
    assign
      buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty = buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
                                             + p-rsrv-qnty
    .
  end.
end procedure.
procedure trndocrs-pl-gds-request :
  define input parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define input parameter p-field-accum            as character no-undo .
  define variable vss-description as character no-undo init "trndocrs-pl-gds-request: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    if lookup(p-field-accum, "before,after":u ) = 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка задания входных параметров параметров" skip
        "Неизвестное значение параметра" skip
        "p-field-accum" p-field-accum skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case p-field-accum :
      when "before":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty = 0
            buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty  = 0
          .
        end.
      end.
      when "after":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty  = 0
            buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty   = 0
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка задания входных параметров параметров" skip
          "Неизвестное значение параметра" skip
          "p-field-accum" p-field-accum skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define buffer buf_parts for ub.parts.
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      find first buf_temp-trndocrs-pl-gds-rsrv
        where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        no-error .
      if not available buf_temp-trndocrs-pl-gds-rsrv then do:
        create buf_temp-trndocrs-pl-gds-rsrv .
        assign
          buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        .
      end.
      if can-do('при,рас,спи':U, p-doc-type)
      or (p-doc-type = 'инв':U
          and buf_parts.fact-qnty < 0)
      then do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info5 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info5 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-calc-rsrv :
  define variable vss-description as character no-undo init "trndocrs-pl-gds-calc-rsrv: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
      .
    end.
  end.
end procedure.
procedure trndocrs-need-rsrv :
  define input  parameter p-doc-type     like ub.trn-doc.doc-type no-undo .
  define input  parameter p-artic        like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type    like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code    like ub.doc-line.prod-code no-undo .
  define output parameter p-need-rsrv    as logical   no-undo .
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    if buf_goods.gds-type = 'т':U
    and ( p-doc-type = 'рас':U
          or p-doc-type = 'спи':U
        )
    then do:
      assign
        p-need-rsrv = true
      .
    end.
    else do:
      assign
        p-need-rsrv = false
      .
    end.
  end.
end procedure.
procedure trndocrs-need-create-doc-pl :
  define input  parameter p-extended-doc-type  as character no-undo .
  define input  parameter p-news               as logical   no-undo .
  define input  parameter p-sale-auto          as logical   no-undo .
  define output parameter p-need-create-doc-pl as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  not p-news
    and p-extended-doc-type <> 'ie':U
    and p-extended-doc-type <> 'es':U
    and p-extended-doc-type <> 'rs':U
    and not p-sale-auto
    then do:
      assign
        p-need-create-doc-pl = true
      .
    end.
    else do:
      assign
        p-need-create-doc-pl = false
      .
    end.
  end.
end procedure.
procedure trndocrs-validate :
  define input parameter p-place-rsrv as logical no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define variable v-total-gds-dtl-rsrv-qnty as decimal no-undo .
  define variable v-total-pl-gds-rsrv-qnty as decimal no-undo .
  assign
    v-total-gds-dtl-rsrv-qnty = 0
    v-total-pl-gds-rsrv-qnty  = 0
  .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-gds-dtl-rsrv-qnty = v-total-gds-dtl-rsrv-qnty
                                  + buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
      .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-pl-gds-rsrv-qnty = v-total-pl-gds-rsrv-qnty
                                 + buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
      .
    end.
    if round(v-total-gds-dtl-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при резервировании свободных количеств" skip
        "Запрошено резервирование:" skip
        "По товару" p-chg-qnty skip
        "По признакам" v-total-gds-dtl-rsrv-qnty skip
        "По складским местам" v-total-pl-gds-rsrv-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-place-rsrv then do:
      if round(v-total-pl-gds-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка при резервировании свободных количеств" skip
          "Запрошено резервирование:" skip
          "По товару" p-chg-qnty skip
          "По признакам" v-total-gds-dtl-rsrv-qnty skip
          "По складским местам" v-total-pl-gds-rsrv-qnty skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure trndocrs :
  define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
  define input parameter p-obj-type   like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code   like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic      like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_db         for ub.db .
  define buffer buf_gds-obj    for ub.gds-obj .
  define buffer buf_prt-obj    for ub.prt-obj .
  define buffer buf_gds-prt    for ub.gds-prt .
  define buffer buf_goods      for ub.goods .
  define buffer buf_pl-gds     for ub.pl-gds .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define variable v-node-code   like ub.gds-prt.node-code no-undo .
  define variable v-curr-db-num like ub.db.db-num         no-undo .
  define variable v-cmd         as   character            no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при поиске товара на объекте" skip
        "p-obj-type"  p-obj-type  skip
        "p-obj-code"  p-obj-code  skip
        "p-artic"     p-artic     skip
        "p-prod-type" p-prod-type skip
        "p-prod-code" p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find current buf_gds-obj exclusive-lock .
    run trndocrs-validate in this-procedure
      (input buf_gds-obj.place-rsrv
      ,input p-chg-qnty
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Противоречивые данные для резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      buf_gds-obj.free-qnty   = buf_gds-obj.free-qnty - p-chg-qnty
      buf_gds-obj.on-line-rest = buf_gds-obj.free-qnty
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
    find first buf_db no-lock
      where buf_db.db-num = v-curr-db-num
      .
    if buf_db.db-num <> 0
      and buf_db.on-line-rest = true
    then do:
      assign
        v-cmd = "command":U + chr(1)
                + "create":U + chr(1)
                + "on-line-rest":U + chr(1)
                + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
      .
      run nws/cr-route.p
        ( input 'send-cmd':U
          ,input v-cmd
          ,input ?
          ,input "0":U
        ).
    end.
    if buf_gds-obj.place-rsrv = true then do:
      for each buf_temp-trndocrs-pl-gds-rsrv
      on error undo, return error return-value
      :
        find first buf_goods no-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info5 skip
            "Не найдена товар" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_pl-gds exclusive-lock
          where buf_pl-gds.obj-type = p-obj-type
            and buf_pl-gds.obj-code = p-obj-code
            and buf_pl-gds.gds-code = buf_goods.gds-code
            and buf_pl-gds.pl-code  = buf_temp-trndocrs-pl-gds-rsrv.pl-code
          no-error .
        if not available buf_pl-gds then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info5 skip
            "Не найдена привязка товара к складскому месту" skip
            "Код товара" buf_temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          buf_pl-gds.free-qnty     = buf_pl-gds.free-qnty     - buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty
        .
        if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
          and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
        then do:
          assign
            buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_temp-trndocrs-gds-dtl-rsrv.prt-code
  ,output v-node-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка при определении первого терминального признака" skip
          "prt-code" buf_temp-trndocrs-gds-dtl-rsrv.prt-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = v-node-code
        .
      do while available buf_gds-prt
      on error undo, return error return-value
      :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  )  .
        find current buf_prt-obj exclusive-lock .
        assign
          buf_prt-obj.free-qnty = buf_prt-obj.free-qnty - buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
        .
        assign
          v-node-code = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          no-error .
      end.
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure trndocgs :
  define input  parameter p-doc-code      like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic         like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type     like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code     like ub.doc-line.prod-code no-undo .
  define input  parameter p-root-node     like ub.prt-obj.prt-code  no-undo .
  define input  parameter p-news          as logical no-undo .
  define input  parameter p-trn-doc-close as logical   no-undo .
  define input  parameter p-update-host   as logical no-undo .
  define buffer buf_db       for ub.db .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl .
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_prt-obj  for ub.prt-obj .
  define buffer buf_goods    for ub.goods .
  define buffer buf_gds-prt  for ub.gds-prt .
  define buffer buf_pl-gds   for ub.pl-gds .
  define buffer buf_doc-pl   for ub.doc-pl .
  define variable v-obj-type      like ub.gds-obj.obj-type  no-undo .
  define variable v-obj-code      like ub.gds-obj.obj-code  no-undo .
  define variable curr-node       like ub.gds-prt.node-code no-undo .
  define variable l-need-rsrv     as logical                no-undo .
  define variable l-goods-twounit as logical                no-undo .
  define variable v-cmd           as character              no-undo .
  define variable v-curr-db-num   like ub.db.db-num         no-undo .
  define variable v-update-sign   as decimal   no-undo .
  define variable v-doc-sign      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    if p-trn-doc-close = true
    then do:
      assign
        v-update-sign = 1.0
      .
    end.
    else do:
      assign
        v-update-sign = -1.0
      .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Товар" p-artic p-prod-code p-prod-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_doc-line.fact-order = ?
    or buf_doc-line.fact-order = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не задан логический номер строки документа" skip
        "Документ" buf_doc-line.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "Логический номер документа" buf_doc-line.fact-order skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    assign
      v-obj-type  = buf_doc-line.obj-type
      v-obj-code  = buf_doc-line.obj-code
    .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  p-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании информации о товаре на фирме" skip
        error-status :get-message(1) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find current buf_gds-obj exclusive-lock .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > buf_trn-doc.fact-date then do:
  assign
    buf_gds-obj.first-doc  = buf_trn-doc.fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < buf_trn-doc.fact-date then do:
  assign
    buf_gds-obj.last-doc   = buf_trn-doc.fact-date
  .
end.
    if p-trn-doc-close = true
    then do:
      run trndocrs-need-rsrv in this-procedure
        (input  buf_trn-doc.doc-type
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output l-need-rsrv
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры trndocrs-need-rsrv" skip
          "Документ" buf_trn-doc.doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      assign
        l-need-rsrv = false
      .
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        'twounit=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run trndocrs-clear in this-procedure
      .
    if buf_goods.gds-type = 'т':U
    then do:
      define variable v-change-qnty        as decimal no-undo .
      define variable v-change-base-total  as decimal no-undo .
      define variable v-change-rubl-total  as decimal no-undo .
      define variable v-total-qnty         as decimal no-undo .
      define variable v-total-cli-qnty     as decimal no-undo .
      define variable v-total-base-total   as decimal no-undo .
      define variable v-total-rubl-total   as decimal no-undo .
      define variable v-return-qnty        as decimal no-undo .
      define variable v-return-base-total  as decimal no-undo .
      define variable v-return-rubl-total  as decimal no-undo .
      define variable v-expense-qnty       as decimal no-undo .
      define variable v-expense-base-total as decimal no-undo .
      define variable v-expense-rubl-total as decimal no-undo .
      define variable v-total-rsrv-qnty    as decimal no-undo .
      run tdparts in this-procedure
        (input  buf_trn-doc.host-code
        ,input  buf_trn-doc.doc-type
        ,input  buf_trn-doc.internal
        ,input  buf_trn-doc.discnt-type
        ,input  buf_trn-doc.doc-code
        ,input  buf_doc-line.obj-type
        ,input  buf_doc-line.obj-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,input  l-need-rsrv
        ,input  buf_gds-obj.place-rsrv
        ,input  l-goods-twounit
        ,output v-change-qnty
        ,output v-change-base-total
        ,output v-change-rubl-total
        ,output v-total-qnty
        ,output v-total-cli-qnty
        ,output v-total-base-total
        ,output v-total-rubl-total
        ,output v-return-qnty
        ,output v-return-base-total
        ,output v-return-rubl-total
        ,output v-expense-qnty
        ,output v-expense-base-total
        ,output v-expense-rubl-total
        ,output v-total-rsrv-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивных партий" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    else do:
      assign
        v-total-qnty       = (if buf_trn-doc.doc-type = 'рас':U
                              or buf_trn-doc.doc-type = 'спи':U
                              then - buf_doc-line.fact-qnty
                              else   buf_doc-line.fact-qnty
                             )
        v-total-rsrv-qnty  = 0
        v-total-base-total = buf_doc-line.price-base * v-total-qnty
        v-total-rubl-total = buf_doc-line.price-rubl * v-total-qnty
      .
      if l-goods-twounit
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Услуга не может учитываться по двум единицам измерения" skip
          "Документ" buf_trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define variable v-gds-dtl-qnty        as decimal no-undo .
    define variable v-gds-dtl-rsrv-qnty   as decimal no-undo .
    for each buf_gds-dtl
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            v-gds-dtl-qnty      = buf_gds-dtl.fact-qnty
            v-gds-dtl-rsrv-qnty = buf_gds-dtl.doc-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-gds-dtl-qnty      = - buf_gds-dtl.fact-qnty
            v-gds-dtl-rsrv-qnty = - buf_gds-dtl.doc-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            v-gds-dtl-qnty = buf_gds-dtl.doc-qnty
            v-gds-dtl-rsrv-qnty = 0
          .
        end.
      end.
      if l-need-rsrv
      then do:
        run trndocrs-gds-dtl-accum in this-procedure
          (input buf_gds-dtl.prt-code
          ,input v-gds-dtl-rsrv-qnty
                * v-update-sign
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-gds-dtl-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output curr-node
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно найти терминальный признак" skip
          "prt-code" buf_gds-dtl.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = curr-node
        .
      do while available buf_gds-prt:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  buf_gds-dtl.artic
  ,input  buf_gds-dtl.prod-type
  ,input  buf_gds-dtl.prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании признака на объекте" skip
            "obj-type"  buf_gds-dtl.obj-type skip
            "obj-code"  buf_gds-dtl.obj-code skip
            "artic"     buf_gds-dtl.artic skip
            "prod-type" buf_gds-dtl.prod-type skip
            "prod-code" buf_gds-dtl.prod-code skip
            "node-code" buf_gds-prt.node-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find current buf_prt-obj exclusive-lock .
        if buf_goods.gds-type = 'т':U
        then do:
          find first doc-fbr-gds no-lock where (doc-fbr-gds.out-code = buf_doc-line.doc-code or
                                                doc-fbr-gds.out-code = replace(buf_doc-line.doc-code, "=", "-") )
                                           and doc-fbr-gds.gds-code = buf_goods.gds-code
                                           no-error .
          if available doc-fbr-gds
          then do :
            assign
              buf_prt-obj.fact-qnty = buf_prt-obj.fact-qnty + v-gds-dtl-rsrv-qnty
                                                            * v-update-sign
              buf_prt-obj.free-qnty = buf_prt-obj.free-qnty + v-gds-dtl-rsrv-qnty
                                                            * v-update-sign
            .
          end.
          else do :
            assign
              buf_prt-obj.fact-qnty = buf_prt-obj.fact-qnty + v-gds-dtl-qnty
                                                            * v-update-sign
              buf_prt-obj.free-qnty = buf_prt-obj.free-qnty + v-gds-dtl-qnty
                                                            * v-update-sign
            .
          end.
        end.
        assign
          curr-node = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = curr-node
          no-error.
      end.
    end.
    if l-need-rsrv
    then do:
      run trndocrs in this-procedure
        (input p-doc-code
        ,input v-obj-type
        ,input v-obj-code
        ,input p-artic
        ,input p-prod-type
        ,input p-prod-code
        ,input v-total-rsrv-qnty
              * v-update-sign
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при изменении зарезервированных количеств trndocrs" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if buf_goods.gds-type = 'т':U
    then do:
      define variable v-old-fact-qnty            as decimal   no-undo .
      define variable v-old-fact-cli-qnty        as decimal   no-undo .
      define variable v-old-pl-gds-fact-qnty     as decimal   no-undo .
      define variable v-old-pl-gds-free-qnty     as decimal   no-undo .
      define variable v-old-pl-gds-cli-qnty      as decimal   no-undo .
      define variable v-old-pl-gds-cli-fact-qnty as decimal   no-undo .
      define variable v-old-pl-gds-cli-free-qnty as decimal   no-undo .
      define variable v-old-fact-base            as decimal   no-undo .
      define variable v-old-fact-rubl            as decimal   no-undo .
      define variable v-old-fact-sale            as decimal   no-undo .
      assign
        v-old-fact-qnty     = buf_gds-obj.fact-qnty
        v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
        v-old-fact-base     = buf_gds-obj.fact-base
        v-old-fact-rubl     = buf_gds-obj.fact-rubl
        v-old-fact-sale     = buf_gds-obj.fact-sale
      .
      assign
        buf_gds-obj.fact-qnty     = buf_gds-obj.fact-qnty     + v-total-qnty
                                                              * v-update-sign
        buf_gds-obj.free-qnty     = buf_gds-obj.free-qnty     + v-total-qnty
                                                              * v-update-sign
        buf_gds-obj.fact-base     = buf_gds-obj.fact-base     + v-total-base-total
                                                              * v-update-sign
        buf_gds-obj.fact-rubl     = buf_gds-obj.fact-rubl     + v-total-rubl-total
                                                              * v-update-sign
        buf_gds-obj.on-line-rest  = buf_gds-obj.free-qnty
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
      find first buf_db no-lock
        where buf_db.db-num = v-curr-db-num
        .
      if buf_db.db-num <> 0
        and buf_db.on-line-rest = true
      then do:
        assign
          v-cmd = "command":U + chr(1)
                  + "create":U + chr(1)
                  + "on-line-rest":U + chr(1)
                  + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                  + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                  + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                  + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                  + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                  + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
        .
        run nws/cr-route.p
          ( input 'send-cmd':U
           ,input v-cmd
           ,input ?
           ,input "0":U
          ).
      end.
      if l-goods-twounit
      then do:
        assign
          buf_gds-obj.fact-cli-qnty = buf_gds-obj.fact-cli-qnty + v-total-cli-qnty
                                                                * v-update-sign
        .
      end.
      run gdsobjcl in this-procedure
        (input recid(buf_gds-obj)
        ,input false
        ) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при расчете суммы остатка в учетных и продажных ценах по объекту" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip
          "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box.
        undo, return error return-value .
      end.
      define variable p-action-type as character no-undo .
      if p-trn-doc-close = true
      then do:
        assign
          p-action-type = 'close':U
        .
      end.
      else do:
        assign
          p-action-type = 'delete':U
        .
      end.
      if buf_gds-obj.place-rsrv = true then do:
        for each buf_doc-pl no-lock
          where buf_doc-pl.obj-type = v-obj-type
            and buf_doc-pl.obj-code = v-obj-code
            and buf_doc-pl.out-code = p-doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          find first buf_pl-gds exclusive-lock
            where buf_pl-gds.obj-type = buf_doc-pl.obj-type
              and buf_pl-gds.obj-code = buf_doc-pl.obj-code
              and buf_pl-gds.gds-code = buf_doc-pl.gds-code
              and buf_pl-gds.pl-code  = buf_doc-pl.pl-code
            no-error .
          if not available buf_pl-gds  then do:
            if p-news = true then do:
              create buf_pl-gds .
              assign
                buf_pl-gds.obj-type = buf_doc-pl.obj-type
                buf_pl-gds.obj-code = buf_doc-pl.obj-code
                buf_pl-gds.gds-code = buf_doc-pl.gds-code
                buf_pl-gds.pl-code  = buf_doc-pl.pl-code
              .
            end.
            else do:
              message
                vss-workfile vss-revision vss-description skip
                "Не найдена привязка товара к складскому месту" skip
                "Документ" buf_doc-pl.out-code skip
                "Объект" buf_doc-pl.obj-type buf_doc-pl.obj-code skip
                "Складское место" buf_doc-pl.pl-code skip
                "Код товара" buf_doc-pl.gds-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          if buf_trn-doc.doc-type = 'рас':U
            or buf_trn-doc.doc-type = 'спи':U
          then do:
            assign
              v-doc-sign = -1.0
            .
          end.
          else do:
            assign
              v-doc-sign = 1.0
            .
          end.
          assign
            v-old-pl-gds-fact-qnty     = buf_pl-gds.fact-qnty
            v-old-pl-gds-free-qnty     = buf_pl-gds.free-qnty
            v-old-pl-gds-cli-qnty      = buf_pl-gds.cli-qnty
            v-old-pl-gds-cli-fact-qnty = buf_pl-gds.cli-fact-qnty
            v-old-pl-gds-cli-free-qnty = buf_pl-gds.cli-free-qnty
            buf_pl-gds.fact-qnty       = buf_pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-update-sign * v-doc-sign
            buf_pl-gds.free-qnty       = buf_pl-gds.free-qnty     + buf_doc-pl.fact-qnty     * v-update-sign * v-doc-sign
            buf_pl-gds.cli-qnty        = buf_pl-gds.cli-qnty      + buf_doc-pl.cli-qnty      * v-update-sign * v-doc-sign
            buf_pl-gds.cli-fact-qnty   = buf_pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-update-sign * v-doc-sign
            buf_pl-gds.cli-free-qnty   = buf_pl-gds.cli-free-qnty + buf_doc-pl.cli-fact-qnty * v-update-sign * v-doc-sign
          .
          if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
            and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
          then do:
            assign
              buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
            .
          end.
          if buf_pl-gds.fact-qnty < 0.0 then do:
              message
                vss-workfile vss-revision vss-description skip
                "Фактическое количество в резервуаре после закрытия станет меньше нуля: " buf_pl-gds.fact-qnty skip
                "Документ" p-doc-code skip
                "Объект" v-obj-type v-obj-code skip
                "Место хранения" buf_doc-pl.pl-code skip
                "Код товара" buf_goods.gds-code skip
                view-as alert-box error .
              undo, return error return-value .
          end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run plgohist in g#library
  (input  buf_pl-gds.obj-type
  ,input  buf_pl-gds.obj-code
  ,input  buf_pl-gds.pl-code
  ,input  buf_pl-gds.gds-code
  ,input  p-action-type
  ,input  buf_pl-gds.fact-qnty
  ,input  buf_pl-gds.cli-qnty
  ,input  buf_pl-gds.free-qnty
  ,input  buf_pl-gds.cli-fact-qnty
  ,input  buf_pl-gds.cli-free-qnty
  ,input  v-old-pl-gds-fact-qnty
  ,input  v-old-pl-gds-cli-qnty
  ,input  v-old-pl-gds-free-qnty
  ,input  v-old-pl-gds-cli-fact-qnty
  ,input  v-old-pl-gds-cli-free-qnty
  ,input  'trn-doc':U
  ,input  buf_trn-doc.doc-code
  ,input  buf_trn-doc.fact-date
  ,input  buf_trn-doc.user-db-num
  ,input  buf_trn-doc.user-name
  ,input  buf_trn-doc.sys-date
  ,input  buf_trn-doc.sys-time-int
  ,input  buf_trn-doc.sys-time
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при создании истории по товару на складском месте" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      define variable v-corr-date   as date      no-undo .
      define variable v-corr-time   as integer   no-undo .
      run cur-time in this-procedure
        (output v-corr-date
        ,output v-corr-time
        ) .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  p-action-type
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'trn-doc':U
  ,input  buf_trn-doc.doc-code
  ,input  buf_trn-doc.fact-date
  ,input  buf_trn-doc.user-db-num
  ,input  buf_trn-doc.user-name
  ,input  buf_trn-doc.sys-date
  ,input  buf_trn-doc.sys-time-int
  ,input  buf_trn-doc.sys-time
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при создании истории по товару на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if buf_goods.gds-type = 'т':U
    then do:
      if buf_trn-doc.doc-type = 'при':U
      and buf_doc-line.fact-qnty <> 0
      then do:
        if p-trn-doc-close = true
        then do:
          if buf_gds-obj.in-date = ?
          or buf_gds-obj.in-date <= buf_trn-doc.fact-date
          then do:
            assign
              buf_gds-obj.last-base = buf_doc-line.price-base
              buf_gds-obj.last-rubl = buf_doc-line.price-rubl
              buf_gds-obj.in-code   = buf_trn-doc.doc-code
              buf_gds-obj.in-date   = buf_trn-doc.fact-date
            .
          end.
        end.
        else do:
          define buffer income_buf_doc-line for ub.doc-line .
          define buffer income_buf_trn-doc for ub.trn-doc .
          for each income_buf_doc-line no-lock
            where income_buf_doc-line.obj-type     = buf_doc-line.obj-type
              and income_buf_doc-line.obj-code     = buf_doc-line.obj-code
              and income_buf_doc-line.artic        = buf_doc-line.artic
              and income_buf_doc-line.prod-type    = buf_doc-line.prod-type
              and income_buf_doc-line.prod-code    = buf_doc-line.prod-code
              and income_buf_doc-line.status_      = 'факт':U
              and income_buf_doc-line.doc-code    <> buf_doc-line.doc-code
          ,first income_buf_trn-doc no-lock
             where income_buf_trn-doc.doc-code = income_buf_doc-line.doc-code
               and income_buf_trn-doc.doc-type = 'при':U
          by income_buf_doc-line.fact-order descending
          on error undo, return error return-value
          :
            assign
              buf_gds-obj.last-base = income_buf_doc-line.price-base
              buf_gds-obj.last-rubl = income_buf_doc-line.price-rubl
              buf_gds-obj.in-code   = income_buf_trn-doc.doc-code
              buf_gds-obj.in-date   = income_buf_trn-doc.fact-date
            .
            leave .
          end.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tdparts :
  define input parameter  p-trn-doc-host-code   like ub.trn-doc.host-code   no-undo .
  define input parameter  p-trn-doc-doc-type    like ub.trn-doc.doc-type    no-undo .
  define input parameter  p-trn-doc-internal    like ub.trn-doc.internal    no-undo .
  define input parameter  p-trn-doc-discnt-type like ub.trn-doc.discnt-type no-undo .
  define input parameter  p-trn-doc-doc-code    like ub.trn-doc.doc-code    no-undo .
  define input parameter  p-obj-type            like ub.doc-line.obj-type   no-undo .
  define input parameter  p-obj-code            like ub.doc-line.obj-code   no-undo .
  define input parameter  p-artic               like ub.doc-line.artic      no-undo .
  define input parameter  p-prod-type           like ub.doc-line.prod-type  no-undo .
  define input parameter  p-prod-code           like ub.doc-line.prod-code  no-undo .
  define input parameter  p-need-rsrv           as logical no-undo .
  define input parameter  p-place-rsrv          as logical no-undo .
  define input parameter  p-goods-twounit       as logical no-undo .
  define output parameter p-change-qnty         like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-change-base-total   like ub.gds-obj.avrg-base no-undo .
  define output parameter p-change-rubl-total   like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-total-qnty          like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-total-cli-qnty      like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-total-base-total    like ub.gds-obj.avrg-base no-undo .
  define output parameter p-total-rubl-total    like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-return-qnty         like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-return-base-total   like ub.gds-obj.avrg-base no-undo .
  define output parameter p-return-rubl-total   like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-expense-qnty        like ub.gds-obj.fact-qnty no-undo .
  define output parameter p-expense-base-total  like ub.gds-obj.avrg-base no-undo .
  define output parameter p-expense-rubl-total  like ub.gds-obj.avrg-rubl no-undo .
  define output parameter p-total-rsrv-qnty     like ub.gds-obj.fact-qnty no-undo .
  define variable vss-description as character no-undo initial "tdparts: Сбор информации по партиям".
  define buffer archive_parts                 for ub.parts .
  define buffer check_archive_parts           for ub.parts .
  define buffer buf_goods                     for ub.goods .
  define buffer buf_doc-pl                    for ub.doc-pl .
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  define variable v-change-price-base as decimal no-undo .
  define variable v-change-price-rubl as decimal no-undo .
  define variable v-change-qnty       as decimal no-undo .
  define variable v-rsrv-qnty         as decimal no-undo .
  define variable v-change-cli-qnty   as decimal no-undo .
  define variable v-pl-change-qnty    as decimal no-undo .
  define variable v-cli-change-qnty   as decimal no-undo .
  define variable v-cli-rsrv-qnty     as decimal no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-change-qnty        = 0
      p-change-base-total  = 0
      p-change-rubl-total  = 0
      p-total-qnty         = 0
      p-total-cli-qnty     = 0
      p-total-base-total   = 0
      p-total-rubl-total   = 0
      p-return-qnty        = 0
      p-return-base-total  = 0
      p-return-rubl-total  = 0
      p-expense-qnty       = 0
      p-expense-base-total = 0
      p-expense-rubl-total = 0
      p-total-rsrv-qnty    = 0
    .
    define variable v-prihod  as logical no-undo .
    define variable v-vozvrat as logical no-undo .
    assign
      v-prihod = false
    .
    if (p-trn-doc-doc-type = 'при':U
          and( p-trn-doc-internal = no
            or
            (p-trn-doc-internal = yes
                and p-trn-doc-discnt-type = 'прво':U
            )
          )
      )
    then do:
      assign
        v-prihod = true
      .
    end.
    for each archive_parts no-lock
      where archive_parts.out-code  = p-trn-doc-doc-code
        and archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      assign
        v-change-qnty = archive_parts.fact-qnty
        v-rsrv-qnty   = archive_parts.qnty
      .
      if p-goods-twounit = true
      then do:
        if archive_parts.fact-qnty = 0
        then do:
          assign
            v-change-cli-qnty = 0
          .
        end.
        else do:
          if archive_parts.fact-qnty = archive_parts.qnty
          then do:
            assign
              v-change-cli-qnty = archive_parts.cli-qnty
            .
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              "Фактическое количество не совпадает с количеством по документу" skip
              "Документ" archive_parts.out-code skip
              "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        assign
          v-change-cli-qnty = archive_parts.fact-qnty / archive_parts.cli-base-rate
        .
      end.
      if p-trn-doc-doc-type = 'рас':U
      or p-trn-doc-doc-type = 'спи':U
      then do:
        assign
          v-change-qnty     = - v-change-qnty
          v-rsrv-qnty       = - v-rsrv-qnty
          v-change-cli-qnty = - v-change-cli-qnty
        .
      end.
      if p-place-rsrv = true then do:
        run trndocrs-pl-gds-accum in this-procedure
          (input archive_parts.pl-code
          ,input (if p-need-rsrv = true then v-rsrv-qnty else 0.0)
          ,input 0.0
          ,input v-change-qnty
          ,input 0.0
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      assign
        v-change-price-base = archive_parts.price-base * v-change-qnty
        v-change-price-rubl = archive_parts.price-rubl * v-change-qnty
      .
      assign
        p-total-qnty       = p-total-qnty       + v-change-qnty
        p-total-cli-qnty   = p-total-cli-qnty   + v-change-cli-qnty
        p-total-base-total = p-total-base-total + v-change-price-base
        p-total-rubl-total = p-total-rubl-total + v-change-price-rubl
        p-total-rsrv-qnty  = p-total-rsrv-qnty  + v-rsrv-qnty
      .
      if v-change-qnty > 0
      then do:
        assign
          p-return-qnty        = p-return-qnty        + v-change-qnty
          p-return-base-total  = p-return-base-total  + v-change-price-base
          p-return-rubl-total  = p-return-rubl-total  + v-change-price-rubl
        .
      end.
      else do:
        assign
          p-expense-qnty       = p-expense-qnty       + v-change-qnty
          p-expense-base-total = p-expense-base-total + v-change-price-base
          p-expense-rubl-total = p-expense-rubl-total + v-change-price-rubl
        .
      end.
      assign
        v-vozvrat = false
      .
      if p-trn-doc-doc-type = 'возврат':U
      or (p-trn-doc-doc-type = 'инв':U
          and archive_parts.fact-qnty > 0
         )
      then do:
        assign
          v-vozvrat = true
        .
      end.
      if  v-prihod  <> true
      and v-vozvrat <> true
      and archive_parts.in-code = archive_parts.out-code
      then do:
        next.
      end.
      if v-vozvrat = true
      then do:
        find first check_archive_parts no-lock
          where check_archive_parts.obj-type   = archive_parts.obj-type
            and check_archive_parts.obj-code   = archive_parts.obj-code
            and check_archive_parts.artic      = archive_parts.artic
            and check_archive_parts.prod-type  = archive_parts.prod-type
            and check_archive_parts.prod-code  = archive_parts.prod-code
            and check_archive_parts.in-code    = archive_parts.in-code
            and check_archive_parts.out-code   = 'free-zone':U
            and check_archive_parts.part-code  = archive_parts.part-code
          no-error .
        if not available check_archive_parts
        or check_archive_parts.fact-qnty <= 0
        then do:
          next.
        end.
      end.
      assign
        p-change-qnty       = p-change-qnty       + v-change-qnty
        p-change-base-total = p-change-base-total + v-change-price-base
        p-change-rubl-total = p-change-rubl-total + v-change-price-rubl
      .
    end.
    if p-place-rsrv = true then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        .
      for each buf_doc-pl no-lock
        where buf_doc-pl.obj-type = p-obj-type
          and buf_doc-pl.obj-code = p-obj-code
          and buf_doc-pl.out-code = p-trn-doc-doc-code
          and buf_doc-pl.gds-code = buf_goods.gds-code
      on error undo, return error return-value
      :
        assign
          v-pl-change-qnty  = buf_doc-pl.fact-qnty
          v-cli-change-qnty = buf_doc-pl.cli-fact-qnty
          v-cli-rsrv-qnty   = (if p-need-rsrv = true then buf_doc-pl.cli-doc-qnty else 0.0)
        .
        if p-trn-doc-doc-type = 'рас':U
        or p-trn-doc-doc-type = 'спи':U
        then do:
          assign
            v-pl-change-qnty  = - v-pl-change-qnty
            v-cli-change-qnty = - v-cli-change-qnty
            v-cli-rsrv-qnty   = - v-cli-rsrv-qnty
          .
        end.
        run trndocrs-pl-gds-accum in this-procedure
          (input buf_doc-pl.pl-code
          ,input 0.0
          ,input v-cli-rsrv-qnty
          ,input 0.0
          ,input v-cli-change-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_temp-trndocrs-pl-gds-rsrv
          where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_doc-pl.pl-code
          .
        if v-pl-change-qnty <> buf_temp-trndocrs-pl-gds-rsrv.fact-qnty
          and v-pl-change-qnty <> 0.00
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Количество по партиям не совпадает с количеством по складским местам." skip
            substitute( "Документ: &1", p-trn-doc-doc-code ) skip
            substitute( "Товар: &1", buf_goods.gds-code )  skip
            substitute( "Место хранения: &1", buf_doc-pl.pl-code )  skip
            substitute( "Количество по партиям: &1 (&2)",  buf_temp-trndocrs-pl-gds-rsrv.fact-qnty , buf_goods.unit-base ) skip
            substitute( "Количество по местам хр.: &1 (&2)", buf_doc-pl.fact-qnty, buf_goods.unit-base ) skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partrqst :
  define input  parameter p-doc-code                   like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type                   like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code                   like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                      like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type                  like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code                  like ub.doc-line.prod-code no-undo .
  define output parameter p-total-parts-qnty           like ub.parts.qnty         no-undo .
  define output parameter p-total-parts-fact-qnty      like ub.parts.fact-qnty    no-undo .
  define output parameter p-total-parts-cli-qnty       like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-fact-cli-qnty  like ub.parts.cli-qnty     no-undo .
  define output parameter p-total-parts-price-cli      as decimal                 no-undo .
  define output parameter p-total-parts-price-base     as decimal                 no-undo .
  define output parameter p-total-parts-price-rubl     as decimal                 no-undo .
  define output parameter p-total-parts-transport-base as decimal                 no-undo .
  define output parameter p-total-parts-transport-rubl as decimal                 no-undo .
  define output parameter p-total-parts-other-base     as decimal                 no-undo .
  define output parameter p-total-parts-other-rubl     as decimal                 no-undo .
  define variable vss-description as character no-undo init "partrqst: Суммарная информация по всем зарезервированным партиям строки документа".
  do
  on error undo, return error return-value
  :
    assign
      p-total-parts-qnty           = 0
      p-total-parts-fact-qnty      = 0
      p-total-parts-cli-qnty       = 0
      p-total-parts-fact-cli-qnty  = 0
      p-total-parts-price-cli      = 0
      p-total-parts-price-base     = 0
      p-total-parts-price-rubl     = 0
      p-total-parts-transport-base = 0
      p-total-parts-transport-rubl = 0
      p-total-parts-other-base     = 0
      p-total-parts-other-rubl     = 0
    .
    define buffer buf_parts for ub.parts .
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      define variable v-parts-fact-multiplier as decimal   no-undo .
      assign
        v-parts-fact-multiplier = 1
      .
      if buf_parts.qnty <> 0 then do:
        assign
          v-parts-fact-multiplier = buf_parts.fact-qnty / buf_parts.qnty
        .
      end.
      assign
        p-total-parts-qnty            = p-total-parts-qnty       + buf_parts.qnty
        p-total-parts-fact-qnty       = p-total-parts-fact-qnty  + buf_parts.fact-qnty
        p-total-parts-cli-qnty        = p-total-parts-cli-qnty   + buf_parts.cli-qnty
        p-total-parts-fact-cli-qnty   = p-total-parts-fact-cli-qnty
                                      + buf_parts.cli-qnty * v-parts-fact-multiplier
        p-total-parts-price-cli       = p-total-parts-price-cli  + buf_parts.cli-qnty  * buf_parts.price-cli
        p-total-parts-price-base      = p-total-parts-price-base + buf_parts.fact-qnty * buf_parts.price-base
        p-total-parts-price-rubl      = p-total-parts-price-rubl + buf_parts.fact-qnty * buf_parts.price-rubl
        p-total-parts-transport-base  = p-total-parts-transport-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-base <> ?
                                          then buf_parts.transport-base
                                          else 0
                                          )
        p-total-parts-transport-rubl  = p-total-parts-transport-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.transport-rubl <> ?
                                          then buf_parts.transport-rubl
                                          else 0
                                          )
        p-total-parts-other-base      = p-total-parts-other-base
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-base <> ?
                                          then buf_parts.other-base
                                          else 0
                                          )
        p-total-parts-other-rubl      = p-total-parts-other-rubl
                                      + buf_parts.fact-qnty
                                        * (if   buf_parts.other-rubl <> ?
                                          then buf_parts.other-rubl
                                          else 0
                                          )
      .
    end.
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info19 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info19, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info19, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info19, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info19 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info19, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info19 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info19, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info19, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info19, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info19, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info19, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info19 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info19 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info19, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info19, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info19 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info19 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info19, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure partcopy :
  define input parameter  p-free-output-copy as logical   no-undo .
  define input parameter  p-out-code         like ub.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf_parts          for ub.parts .
  define input parameter  p-mark             as character no-undo .
  define variable vss-description as character no-undo init "partcopy-01: процедура копирования партии".
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable part-key-rec      as character no-undo .
  define variable orig-part-key-rec as character no-undo .
  define variable del-part-key-rec  as character no-undo .
  define variable objMarks as class excisemarks  no-undo .
  define variable v-parent-mark-sts as integer   no-undo .
  define variable v-mark-sts-list   as character no-undo .
  define variable oMarkSts as class ibs.th.str.marking.sts.mark .
  oMarkSts = objSrv:Env:Marking:Sts:Mark.
  define buffer buf_gen-attr for ub.gen-attr .
  define buffer buf1_gen-attr for ub.gen-attr .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-childs for ub.marking .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer orig_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines-childs for ub.marking-lines .
  define buffer buf_marking-pack for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_goods for ub.goods .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer pri_trn-doc for ub.trn-doc .
  define buffer buf_chk-doc for ub.chk-doc .
  do
  on error undo, return error return-value
  :
    if p-free-output-copy = true
    then do:
      if  p-out-code <> 'free-zone':U
      and p-out-code <> 'out-zone':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info22 skip
          "Ошибка задания входных параметров процедуры partcopy" skip
          "p-free-output-copy" p-free-output-copy skip
          "p-out-code" p-out-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    if buf_orig_parts.out-code <> p-out-code
    then do:
      find first buf_parts exclusive-lock
        where buf_parts.obj-type  = buf_orig_parts.obj-type
          and buf_parts.obj-code  = buf_orig_parts.obj-code
          and buf_parts.artic     = buf_orig_parts.artic
          and buf_parts.prod-type = buf_orig_parts.prod-type
          and buf_parts.prod-code = buf_orig_parts.prod-code
          and buf_parts.in-code   = buf_orig_parts.in-code
          and buf_parts.out-code  = p-out-code
          and buf_parts.part-code = buf_orig_parts.part-code
        no-error.
      if not available buf_parts
      then do:
        define variable v-rsrv-free as logical   no-undo .
        if p-out-code = 'free-zone':U
        or p-out-code = 'out-zone':U
        then do:
          assign
            v-rsrv-free =
       (if p-out-code = 'free-zone':U then yes else no)
          .
        end.
        else do:
          assign
            v-rsrv-free = ?
          .
        end.
        create buf_parts .
        buffer-copy buf_orig_parts to buf_parts
        assign
          buf_parts.out-code  = p-out-code
          buf_parts.status_   = no
          buf_parts.rsrv-free = v-rsrv-free
          buf_parts.qnty      = 0
          buf_parts.fact-qnty = 0
          buf_parts.real-qnty = 0
          buf_parts.cli-qnty  = 0
        .
        validate buf_parts .
      end.
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_orig_parts:handle)
                                        ,output orig-part-key-rec).
      run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
            and ub.gen-attr.p-key =  orig-part-key-rec:
          if not valid-object (objMarks)
            then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
            if p-out-code = 'free-zone':U
            and (entry(7,orig-part-key-rec,chr(3)) = entry(8,orig-part-key-rec,chr(3)) )
             then
            do:
                objMarks:CrFreeMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
                if objMarks:StatusErr
                    then
                do:
                    message objMarks:ReturnMsg view-as alert-box error.
                    delete object objMarks no-error.
                    undo, return error.
                end.
            end.
          if (entry(7,orig-part-key-rec,chr(3)) <> entry(8,orig-part-key-rec,chr(3)) ) then
          do:
              if p-mark <> "" then do:
              if p-out-code = 'free-zone':U then do:
                objMarks:RezervMarkForParts(buffer buf_parts, buffer buf_orig_parts, p-mark) .
              end.
              else do:
                objMarks:RezervMarkForParts(buffer buf_orig_parts, buffer buf_parts, p-mark) .
              end.
              if objMarks:StatusErr
                then
              do:
                message objMarks:ReturnMsg view-as alert-box error.
                delete object objMarks no-error.
                undo, return error.
              end.
            end.
          end.
          if p-out-code = 'out-zone':U then
          do:
              objMarks:CrOutMarkForParts(buffer buf_orig_parts, buffer buf_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
          end.
      end.
      delete object objMarks no-error.
      if p-mark = "news" then return .
      find first pri_trn-doc no-lock where pri_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-out-code no-error.
      if not available buf_trn-doc
      then
         find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_orig_parts.out-code no-error .
      if (
          p-out-code = 'free-zone':U
          and buf_orig_parts.in-code = buf_orig_parts.out-code
         )
      or
         (
          p-out-code = 'free-zone':U
          and available pri_trn-doc
          and (pri_trn-doc.ext-doc-type = 'iv':U or pri_trn-doc.ext-doc-type = 'rv':U)
         )
      or
         (
          available buf_trn-doc
          and p-out-code = buf_trn-doc.doc-code
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'vt':U
         )
      or
         (
          p-mark = ""
          and available buf_trn-doc
          and p-out-code = 'free-zone':U
          and buf_trn-doc.ext-doc-type = 'rs':U
         )
      then do :
        find first ub.goods no-lock where ub.goods.artic = buf_parts.artic
          and ub.goods.prod-type = buf_parts.prod-type
          and ub.goods.prod-code = buf_parts.prod-code.
        def buffer buf_orig_ml for ub.marking-lines.
        for each buf_orig_ml where buf_orig_ml.gds-code = ub.goods.gds-code
          and buf_orig_ml.obj-type = buf_orig_parts.obj-type
          and buf_orig_ml.obj-code = buf_orig_parts.obj-code
          and buf_orig_ml.in-code = buf_orig_parts.in-code
          and buf_orig_ml.out-code = buf_orig_parts.out-code
          and buf_orig_ml.part-code = buf_orig_parts.part-code
          and buf_orig_ml.prt-code = buf_orig_parts.prt-code:
          if available pri_trn-doc
          and pri_trn-doc.ext-doc-type = 'iv':U
          and buf_orig_ml.sts <> objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
          then do :
            for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark :
              assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
            end .
            next .
          end .
          find first ub.marking-lines no-lock where ub.marking-lines.mark     = buf_orig_ml.mark
                                                and ub.marking-lines.gds-code = buf_orig_ml.gds-code
                                                and ub.marking-lines.obj-type = buf_orig_ml.obj-type
                                                and ub.marking-lines.obj-code = buf_orig_ml.obj-code
                                                and ub.marking-lines.in-code  = buf_orig_ml.in-code
                                                and ub.marking-lines.out-code = p-out-code
                                                and ub.marking-lines.part-code = buf_orig_ml.part-code
                                                and ub.marking-lines.prt-code = buf_orig_ml.prt-code
                                                no-error .
          if not available ub.marking-lines
          then do :
            create ub.marking-lines.
            buffer-copy buf_orig_ml to ub.marking-lines
            assign
              ub.marking-lines.out-code  = p-out-code
              ub.marking-lines.fact-order = pri_trn-doc.fact-order when available pri_trn-doc
            .
            validate ub.marking-lines.
          end .
          if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U then do:
          for first buf_marking exclusive-lock where buf_marking.mark = buf_orig_ml.mark
            and not (buf_marking.sts = oMarkSts:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U):
            if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB and
               not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) and
               not can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) and
               buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
            then do:
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              validate buf_marking.
            end.
          end .
        end .
        end.
      end .
      define variable v-doc-type  as character no-undo .
      define variable   v-status    as character no-undo .
      define variable v-fact-qnty   as  decimal no-undo .
      define variable ii    as integer no-undo .
      find first buf_goods no-lock where buf_goods.artic = buf_orig_parts.artic
                                     and buf_goods.prod-type = buf_orig_parts.prod-type
                                     and buf_goods.prod-code = buf_orig_parts.prod-code
                                     .
      if available pri_trn-doc
      and pri_trn-doc.ext-doc-type = 'rs':U
      then do :
        if p-mark <> ""
        then do :
        end .
        else do :
        end .
      end .
      else do :
        if buf_orig_parts.in-code <> buf_orig_parts.out-code
        and p-mark <> ""
        then do :
          if p-out-code = 'free-zone':U
          then do:
              if chg-qnty < 0
              then do :
                find first orig_marking-lines no-lock where orig_marking-lines.mark       = p-mark
                                                        and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                        and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                        and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                        and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                        and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                        and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                        and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                        no-error .
                if available orig_marking-lines
                then do :
                  find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                         and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                         and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                         and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                         and buf_marking-lines.in-code    = buf_parts.in-code
                                                         and buf_marking-lines.out-code   = buf_parts.out-code
                                                         and buf_marking-lines.part-code  = buf_parts.part-code
                                                         and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                         no-error .
                  if not available buf_marking-lines
                  then do :
                    create buf_marking-lines .
                    assign
                      buf_marking-lines.mark       = p-mark
                      buf_marking-lines.doc-level  = orig_marking-lines.doc-level
                      buf_marking-lines.gds-code   = buf_goods.gds-code
                      buf_marking-lines.obj-type   = buf_parts.obj-type
                      buf_marking-lines.obj-code   = buf_parts.obj-code
                      buf_marking-lines.in-code    = buf_parts.in-code
                      buf_marking-lines.out-code   = buf_parts.out-code
                      buf_marking-lines.part-code  = buf_parts.part-code
                      buf_marking-lines.prt-code   = buf_parts.prt-code
                    .
                    validate buf_marking-lines.
                  end .
                  for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                    assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                    for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                      for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                      and buf_chk-doc.out-code = buf_orig_parts.out-code
                                                      :
                        assign buf_marking-chk.sts = 0 .
                        validate buf_marking-chk.
                      end .
                    end .
                    if buf_marking.unit-ext <> "UNIT" or
                       (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                    then do :
                      run addChildMarkingLines in this-procedure (
                        buf_marking.mark,
                        objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB,
                        buffer buf_marking-lines,
                        buffer buf_parts,
                        buffer orig_marking-lines,
                        buffer buf_orig_parts,
                        buffer buf_goods
                      ).
                    end .
                  end.
                  find current orig_marking-lines exclusive-lock .
                  delete orig_marking-lines .
                end .
              end .
          end.
          else do:
            find first orig_marking-lines exclusive-lock where orig_marking-lines.mark       = p-mark
                                                           and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                           and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                           and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                           and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                           and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                           and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                           and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                           no-error .
              find first buf_marking-lines no-lock where  buf_marking-lines.mark       = p-mark
                                                      and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                      and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                      and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                      and buf_marking-lines.in-code    = buf_parts.in-code
                                                      and buf_marking-lines.out-code   = buf_parts.out-code
                                                      and buf_marking-lines.part-code  = buf_parts.part-code
                                                      and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available buf_marking-lines
              then do :
                create buf_marking-lines .
                assign
                  buf_marking-lines.mark       = p-mark
                  buf_marking-lines.doc-level  = 1
                  buf_marking-lines.gds-code   = buf_goods.gds-code
                  buf_marking-lines.obj-type   = buf_parts.obj-type
                  buf_marking-lines.obj-code   = buf_parts.obj-code
                  buf_marking-lines.in-code    = buf_parts.in-code
                  buf_marking-lines.out-code   = buf_parts.out-code
                  buf_marking-lines.part-code  = buf_parts.part-code
                  buf_marking-lines.prt-code   = buf_parts.prt-code
                  buf_marking-lines.sts        = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                .
                validate buf_marking-lines.
              end .
              for first buf_marking exclusive-lock where buf_marking.mark = p-mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
                validate buf_marking.
                for first buf_marking-childs exclusive-lock where
                          buf_marking-childs.mark = buf_marking.mark-parent:
                  buf_marking-childs.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB .
                  validate buf_marking-childs.
                end.
                for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                  for first buf_chk-doc no-lock where buf_chk-doc.doc-code = buf_marking-chk.doc-code
                                                  and buf_chk-doc.out-code = buf_parts.out-code
                                                  :
                    if buf_marking-chk.sts <> 2 then
                    do:
                       assign buf_marking-chk.sts = 1 .
                       validate buf_marking-chk.
                    end.
                  end .
                end .
                if buf_marking.unit-ext <> "UNIT" or
                   (buf_marking.unit-ext = ? and buf_marking.box-qnty > 1)
                then do :
                  run addChildMarkingLines in this-procedure (
                    buf_marking.mark,
                    buf_marking.sts,
                    buffer buf_marking-lines,
                    buffer buf_parts,
                    buffer orig_marking-lines,
                    buffer buf_orig_parts,
                    buffer buf_goods
                  ).
                end .
              end.
              if available orig_marking-lines then
                delete orig_marking-lines .
          end.
        end.
      end .
      if p-out-code = 'out-zone':U
      and trim(p-mark) = ""
      then do :
        for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                              and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                              and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                              and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                              and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                              and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                              and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                              :
          find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                  and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                  and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                  and buf_marking-lines.out-code   = p-out-code
                                                  no-error .
          if available buf_marking-lines
          then do :
            find current buf_marking-lines exclusive-lock .
            delete buf_marking-lines .
            for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
              if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
                validate buf_marking.
              end.
            end .
          end .
          else do :
            if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_parts.out-code <> 'out-zone':U then do:
            create buf_marking-lines .
            assign
              buf_marking-lines.mark       = orig_marking-lines.mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
              buf_marking-lines.prt-code   = buf_parts.prt-code
            .
            validate buf_marking-lines.
            if buf_parts.out-code <> buf_parts.in-code
            and buf_parts.out-code <> 'free-zone':U
            and buf_parts.out-code <> 'out-zone':U
            then do :
              find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
              if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
            end .
            end.
          end .
          release buf_marking-lines no-error .
        end.
      end .
      if p-mark <> "" and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U
      then do:
        for each orig_marking-lines no-lock where orig_marking-lines.mark         = p-mark
                                                and orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = buf_orig_parts.obj-type
                                                and orig_marking-lines.obj-code   = buf_orig_parts.obj-code
                                                and orig_marking-lines.in-code    = buf_orig_parts.in-code
                                                and orig_marking-lines.out-code   = buf_orig_parts.out-code
                                                and orig_marking-lines.part-code  = buf_orig_parts.part-code
                                                and orig_marking-lines.prt-code   = buf_orig_parts.prt-code
                                                .
          find first buf_marking-lines no-lock where buf_marking-lines.mark       = p-mark
                                                 and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                 and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                 and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                 and buf_marking-lines.in-code    = buf_parts.in-code
                                                 and buf_marking-lines.out-code   = buf_orig_parts.out-code
                                                 and buf_marking-lines.part-code  = buf_parts.part-code
                                                 no-error .
          for each ub.marking where ub.marking.mark = buf_marking-lines.mark:
            if p-out-code = 'free-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:FreeZone:KeyIntDB.
            if p-out-code = 'out-zone':U and not ub.marking.sts = oMarkSts:MarkError:KeyIntDB
              then assign ub.marking.sts = oMarkSts:OutZone:KeyIntDB.
            validate ub.marking.
          end.
          run partcopy-to-childs-mark (buffer buf_marking-lines, buffer orig_marking-lines, input buf_parts.out-code, oMarkSts).
          if available (buf_marking-lines)
          then do:
            assign
              buf_marking-lines.mark       = p-mark
              buf_marking-lines.doc-level  = orig_marking-lines.doc-level
              buf_marking-lines.gds-code   = buf_goods.gds-code
              buf_marking-lines.obj-type   = buf_parts.obj-type
              buf_marking-lines.obj-code   = buf_parts.obj-code
              buf_marking-lines.in-code    = buf_parts.in-code
              buf_marking-lines.out-code   = buf_parts.out-code
              buf_marking-lines.part-code  = buf_parts.part-code
            .
            validate buf_marking-lines.
          end.
        end.
      end.
    end.
    else do:
      find first buf_parts exclusive-lock
        where recid(buf_parts) = recid(buf_orig_parts)
        .
    end.
    if p-out-code = 'free-zone':U
    or p-out-code = 'out-zone':U
    then do:
      if buf_parts.rsrv-free <>
       (if buf_parts.out-code = 'free-zone':U then yes else no)
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info22 skip
          "Ошибка типа резерва партии" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code  skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Резерв" buf_parts.out-code skip
          "Статус" buf_parts.status_ skip
          "Тип резерва" buf_parts.rsrv-free skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure partcopy-to-childs-mark :
  define parameter buffer buf_ml for ub.marking-lines .
  define parameter buffer buf_orig-ml for ub.marking-lines .
  define input parameter p-out-code as character no-undo .
  define input parameter THMarkSts as class ibs.th.str.marking.sts.mark no-undo .
  define buffer buf_ml-childs for ub.marking-lines .
  for each ub.marking where ub.marking.mark-parent = buf_ml.mark:
    if p-out-code = 'free-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:FreeZone:KeyIntDB.
    if p-out-code = 'out-zone':U and not ub.marking.sts = THMarkSts:MarkError:KeyIntDB
      then assign ub.marking.sts = THMarkSts:OutZone:KeyIntDB.
    for each buf_ml-childs exclusive-lock where buf_ml-childs.mark = ub.marking.mark
      and buf_ml-childs.obj-type  = buf_orig-ml.obj-type
      and buf_ml-childs.obj-code  = buf_orig-ml.obj-code
      and buf_ml-childs.in-code   = buf_orig-ml.in-code
      and buf_ml-childs.out-code  = buf_orig-ml.out-code
      and buf_ml-childs.part-code = buf_orig-ml.part-code
      and buf_ml-childs.prt-code  = buf_orig-ml.prt-code
      :
      assign
        buf_ml-childs.out-code  = p-out-code
      .
      run partcopy-to-childs-mark (buffer buf_ml-childs, buffer buf_orig-ml, input p-out-code, input THMarkSts).
    end.
  end.
end.
procedure partcopy-update-parts :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-parts-01: процедура обработки партий при закрытии документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code     as character no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_goods no-lock where buf_goods.artic = p-artic
                                   and buf_goods.prod-type = p-prod-type
                                   and buf_goods.prod-code = p-prod-code
                                   no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define query partcopy-select-parts for archive_parts .
    open query partcopy-select-parts preselect each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
      .
    get first partcopy-select-parts .
    if buf_trn-doc.doc-type = 'при':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        if can-do('рас,спи':U, buf_trn-doc.doc-type)
        or (buf_trn-doc.doc-type = 'инв':U
            and archive_parts.fact-qnty < 0)
        then do:
          assign
            v-rsrv-code = 'out-zone':U
          .
        end.
        else do:
          assign
            v-rsrv-code = 'free-zone':U
          .
        end.
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.in-code = p-doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          run partcopy in this-procedure
            (input  true
            ,input  v-rsrv-code
            ,buffer archive_parts
            ,buffer buf_parts
            ,input  ""
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info22 skip
              "Ошибка при создании партии" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Резерв" v-rsrv-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty     + archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
            .
            case buf_trn-doc.ext-doc-type :
              when 'ie':U
              then do:
                if archive_parts.cli-qnty <> truncate(archive_parts.cli-qnty, 0 )
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info22 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              when 'iv':U
              then do:
                if archive_parts.cli-qnty <> 1
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info22 skip
                    "Клиентское количество для товара," skip
                    "который учитывается по двум единицам измерения" skip
                    "должно равняться единице" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" archive_parts.in-code archive_parts.part-code skip
                    "Количество по документу" archive_parts.qnty skip
                    "Фактическое количество" archive_parts.fact-qnty skip
                    "Клиентское количество" archive_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Товар учитывается по двум единицам измерения" skip
                  "Для приходов разрешен только внешний приход или приход перемещение" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type archive_parts.prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        else do :
          if buf_trn-doc.ext-doc-type = 'iv':U
          then
          for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                and orig_marking-lines.in-code    = archive_parts.in-code
                                                and orig_marking-lines.out-code   = archive_parts.out-code
                                                and orig_marking-lines.part-code  = archive_parts.part-code,
          first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB .
          end .
        end .
        get next partcopy-select-parts .
      end.
    end.
    if buf_trn-doc.doc-type = 'рас':U
    or buf_trn-doc.doc-type = 'спи':U
    or buf_trn-doc.doc-type = 'возврат':U
    or buf_trn-doc.doc-type = 'инв':U
    then do:
      do while available archive_parts
      on error undo, return error return-value
      :
        assign
          archive_parts.status_   = yes
          archive_parts.rsrv-free = ?
        .
        if archive_parts.fact-qnty <> archive_parts.qnty
        then do:
          define variable v-is-hold as logical   no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info22
              "Ошибка при определении типа документа hold-doc.i" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if buf_trn-doc.ext-doc-type = 'vt':U
          or (buf_trn-doc.ext-doc-type = 're':U and v-is-hold = true)
          or buf_trn-doc.ext-doc-type = 'ap':U
          or buf_trn-doc.ext-doc-type = 'pc':U
          or buf_trn-doc.ext-doc-type = 'mp':U
          or  buf_trn-doc.ext-doc-type = 'vp':U
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info22 skip
              "Фактическое количество не может отличаться от количества по документу" skip
              "для документов инвентаризации, внутреннего возврата и автоматического возврата между фирмами" skip
              "Документ" p-doc-code skip
              "Объект" p-obj-type p-obj-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Партия" archive_parts.in-code archive_parts.part-code skip
              "Количество по документу" archive_parts.qnty skip
              "Фактическое количество" archive_parts.fact-qnty skip
              "Клиентское количество" archive_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
          if archive_parts.in-code <> archive_parts.out-code
          then do:
            if can-do('рас,спи':U,buf_trn-doc.doc-type)
            or (buf_trn-doc.doc-type = 'инв':U
                and archive_parts.fact-qnty < 0)
            then do:
              assign
                v-rsrv-code = 'free-zone':U
              .
            end.
            else do:
              assign
                v-rsrv-code = 'out-zone':U
              .
            end.
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при создании партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + (archive_parts.qnty - archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              if archive_parts.cli-qnty <> 1
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться единице" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + archive_parts.cli-qnty
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
          end.
          if  available buf_parts
          and buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            delete buf_parts .
          end.
        end.
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            archive_parts.fact-num  = buf_trn-doc.fact-num
            archive_parts.fact-date = buf_trn-doc.fact-date
            archive_parts.doc-type  = buf_trn-doc.doc-type
          .
        end.
        if archive_parts.fact-qnty <> 0
        then do:
          if can-do('рас,спи':U, buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22
                "Ошибка при определении типа документа hold-doc.i" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              v-rsrv-code = 'out-zone':U
            .
            if buf_trn-doc.ext-doc-type  = 'ep':U
            or (buf_trn-doc.ext-doc-type = 'ap':U )
            or (buf_trn-doc.ext-doc-type = 'pc':U )
            then do:
              assign
                v-rsrv-code = ""
              .
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end .
            end.
          end.
          else do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          if v-rsrv-code <> ""
          then do:
            run partcopy in this-procedure
              (input  true
              ,input  v-rsrv-code
              ,buffer archive_parts
              ,buffer buf_parts
              ,input  ""
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при создании партии" skip
                "Документ" buf_trn-doc.doc-code skip
                "Объект" archive_parts.obj-type archive_parts.obj-code skip
                "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Резерв" v-rsrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.qnty      = buf_parts.qnty + abs(archive_parts.fact-qnty)
              buf_parts.fact-qnty = buf_parts.qnty
            .
            if v-goods-twounit = true
            then do:
              define variable v-qnty-sign as integer   no-undo .
              assign
                v-qnty-sign = 1
              .
              if  buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
              then do:
                assign
                  v-qnty-sign = - 1
                .
              end.
              if archive_parts.cli-qnty <> v-qnty-sign
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Клиентское количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться" v-qnty-sign skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              if archive_parts.fact-qnty = archive_parts.qnty
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.cli-qnty + abs(archive_parts.cli-qnty)
                .
              end.
              else do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Фактическое количество для товара," skip
                  "который учитывается по двум единицам измерения" skip
                  "должно равняться нулю или количеству по документу" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            else do:
              if buf_parts.cli-base-rate <> 0
              then do:
                assign
                  buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                .
              end.
              else do:
                assign
                  buf_parts.cli-qnty = 0
                .
              end.
            end.
            if  buf_parts.qnty      = 0
            and buf_parts.fact-qnty = 0
            then do:
              if v-goods-twounit = true
              then do:
                if buf_parts.cli-qnty <> 0
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    vss-include-info22 skip
                    "Ошибка при удалении партии" skip
                    "Документ" p-doc-code skip
                    "Объект" p-obj-type p-obj-code skip
                    "Артикул" p-artic p-prod-type p-prod-code skip
                    "Партия" buf_parts.in-code buf_parts.part-code skip
                    "Резерв" buf_parts.out-code skip
                    "qnty" buf_parts.qnty skip
                    "fact-qnty" buf_parts.fact-qnty skip
                    "cli-qnty" buf_parts.cli-qnty skip
                    view-as alert-box error .
                  undo, return error .
                end.
              end.
              delete buf_parts .
            end.
          end.
        end.
        if  ( archive_parts.in-code = buf_trn-doc.doc-code
        and archive_parts.supp-type =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
        and archive_parts.supp-code =
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
        )
        or buf_trn-doc.ext-doc-type = 'rv':U
        then do:
          if can-do('рас,спи':U,buf_trn-doc.doc-type)
          or (buf_trn-doc.doc-type = 'инв':U
              and archive_parts.fact-qnty < 0
            )
          then do:
            assign
              v-rsrv-code = 'free-zone':U
            .
          end.
          else do:
            assign
              v-rsrv-code = 'out-zone':U
            .
          end.
          if not v-izlcstpr
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Резерв" v-rsrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
              assign
                buf_parts.qnty      = buf_parts.qnty - abs(archive_parts.fact-qnty)
                buf_parts.fact-qnty = buf_parts.qnty
              .
              if buf_trn-doc.ext-doc-type = 'rv':U
              then
              for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                                    and orig_marking-lines.obj-type   = archive_parts.obj-type
                                                    and orig_marking-lines.obj-code   = archive_parts.obj-code
                                                    and orig_marking-lines.in-code    = archive_parts.in-code
                                                    and orig_marking-lines.out-code   = archive_parts.out-code
                                                    and orig_marking-lines.part-code  = archive_parts.part-code
                                                    and orig_marking-lines.prt-code   = archive_parts.prt-code,
              first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
                if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                then
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              end .
              if v-goods-twounit = true
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Запрещено порождение партий," skip
                  "который учитывается по двум единицам измерения" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Количество по документу" archive_parts.qnty skip
                  "Фактическое количество" archive_parts.fact-qnty skip
                  "Клиентское количество" archive_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
              else do:
                if buf_parts.cli-base-rate <> 0
                then do:
                  assign
                    buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
                  .
                end.
                else do:
                  assign
                    buf_parts.cli-qnty = 0
                  .
                end.
              end.
          end.
        end.
        get next partcopy-select-parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-parts-delete :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-obj-type  like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code  like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable objMarks as class excisemarks no-undo.
  define variable vss-description as character no-undo init "partcopy-update-parts-delete-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer archive_parts  for ub.parts .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-attr for ub.parts-attr .
  define variable v-rsrv-code as character no-undo .
  define variable v-unrv-code as character no-undo .
  define variable v-need-rsrv as logical   no-undo .
  define variable v-need-unrv as logical   no-undo .
  define variable v-rsrv-sign as integer   no-undo .
  define variable v-unrv-sign as integer   no-undo .
  define variable v-goods-twounit as logical   no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date      as date no-undo .
  define variable v-value-decimal   as decimal no-undo .
  define variable v-value-integer   as integer no-undo .
  define variable v-izlcstpr        as logical no-undo .
  define variable v-tth             as handle no-undo .
  define variable v-type            as character no-undo .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer del_marking-lines for ub.marking-lines .
  define buffer free_marking-lines for ub.marking-lines .
  define buffer buf_marking for ub.marking .
  define buffer buf_marking-chk for ub.marking-chk .
  define buffer buf_chk-doc for ub.chk-doc .
  define variable part-key-rec as character no-undo .
  define variable part-key-rec_arhive   as character no-undo .
  define buffer buf1_gen-attr for ub.gen-attr .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    then do :
        delete object v-tth no-error.
        run adm/shattri.p (
           input "get":U
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "izlcstpr"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-izlcstpr
          ,output v-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          delete object v-tth no-error.
        if error-status:error then do:
          v-izlcstpr = false .
        end.
    end.
    else do :
        v-izlcstpr = false .
    end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-gds-code as integer   no-undo .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
    for each archive_parts
      where archive_parts.obj-type  = p-obj-type
        and archive_parts.obj-code  = p-obj-code
        and archive_parts.artic     = p-artic
        and archive_parts.prod-type = p-prod-type
        and archive_parts.prod-code = p-prod-code
        and archive_parts.out-code  = p-doc-code
    on error undo, return error return-value
    :
      if archive_parts.fact-qnty <> 0
      then do:
        define variable v-create-part as logical   no-undo .
        define variable v-old-return  as logical   no-undo .
        assign
          v-create-part = false
          v-old-return  = false
        .
        if archive_parts.in-code = buf_trn-doc.doc-code
        then do:
          assign
            v-create-part = true
          .
          if archive_parts.supp-type <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-type else buf_trn-doc.obj-type )
          or archive_parts.supp-code <>
        ( if buf_trn-doc.doc-type = 'при':U then buf_trn-doc.cli-code else buf_trn-doc.obj-code )
          then do:
            assign
              v-old-return = true
            .
          end.
        end.
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info22
            "Ошибка при определении типа документа hold-doc.i" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partcond in g#library
  (input  buf_trn-doc.ext-doc-type
  ,input  v-is-hold
  ,input  archive_parts.fact-qnty
  ,input  v-create-part
  ,input  v-old-return
  ,output v-rsrv-code
  ,output v-unrv-code
  ,output v-need-rsrv
  ,output v-need-unrv
  ,output v-rsrv-sign
  ,output v-unrv-sign
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info22
            "Ошибка при определении параметров резервирования партии" skip
            "Документ" p-doc-code skip
            "Объект" p-obj-type p-obj-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-izlcstpr and archive_parts.fact-qnty > 0 then v-need-unrv = false .
        if v-need-rsrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-rsrv-code and v-rsrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-rsrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-rsrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            define variable v-fact-num as integer   no-undo .
            define variable v-doc-type as character no-undo .
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-rsrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines exclusive-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                            and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                            and free_marking-lines.obj-type   = buf_parts.obj-type
                                                            and free_marking-lines.obj-code   = buf_parts.obj-code
                                                            and free_marking-lines.in-code    = buf_parts.in-code
                                                            and free_marking-lines.out-code   = buf_parts.out-code
                                                            and free_marking-lines.part-code  = buf_parts.part-code
                                                            and free_marking-lines.prt-code   = buf_parts.prt-code
                                                            no-error .
              if available free_marking-lines
              then do :
                delete free_marking-lines .
              end .
              if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB and
                 not can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts))
              then do:
                buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB .
              end.
            end .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-rsrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer archive_parts:handle)
                                        ,output part-key-rec_arhive).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                                  and ub.gen-attr.p-key =  part-key-rec
            :
              if not valid-object (objMarks)
                then objMarks = new excisemarks (buf_parts.obj-type, buf_parts.obj-code).
              objMarks:DelMarkForParts(buffer buf_parts, buffer archive_parts, ub.gen-attr.attr-code) .
              if objMarks:StatusErr
                  then
              do:
                  message objMarks:ReturnMsg view-as alert-box error.
                  delete object objMarks no-error.
                  undo, return error.
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            delete buf_parts .
          end.
        end.
        delete object objMarks no-error.
        if v-need-unrv = true
        then do:
          release buf_parts no-error .
          if archive_parts.out-code <> v-unrv-code and v-unrv-sign = -1 and v-izlcstpr
          then do:
              find first buf_parts exclusive-lock
                where buf_parts.obj-type  = archive_parts.obj-type
                  and buf_parts.obj-code  = archive_parts.obj-code
                  and buf_parts.artic     = archive_parts.artic
                  and buf_parts.prod-type = archive_parts.prod-type
                  and buf_parts.prod-code = archive_parts.prod-code
                  and buf_parts.in-code   = archive_parts.out-code
                  and buf_parts.out-code  = v-unrv-code
                  and buf_parts.part-code = archive_parts.part-code
                no-error.
          end .
          if not available  buf_parts
          then do :
              run partcopy in this-procedure
                (input  true
                ,input  v-unrv-code
                ,buffer archive_parts
                ,buffer buf_parts
                ,input  ""
                ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при создании партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" archive_parts.in-code archive_parts.part-code skip
                  "Необходимо резервировать" v-need-rsrv skip
                  "Резерв" v-rsrv-code skip
                  "Необходимо снятие резервов" v-need-unrv skip
                  "Снятие резервов" v-unrv-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo, return error .
              end.
          end.
          if new(buf_parts)
          then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при определении кода товара" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            find first buf_parts-attr no-lock
              where buf_parts-attr.in-code   = buf_parts.in-code
                and buf_parts-attr.gds-code  = v-gds-code
                and buf_parts-attr.part-code = buf_parts.part-code
              no-error .
            if not available buf_parts-attr
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Не найден атрибут партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            run factord-to-fact-num in this-procedure
              (input  buf_parts-attr.fact-order
              ,output v-fact-num
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при определении порядкового номера партии" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnextdt in g#library
  (input  buf_parts-attr.ext-doc-type
  ,output v-doc-type
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info22 skip
                "Ошибка при определении типа документа" skip
                "Документ" p-doc-code skip
                "Объект" p-obj-type p-obj-code skip
                "Артикул" p-artic p-prod-type p-prod-code skip
                "Код товара" v-gds-code skip
                "Партия" archive_parts.in-code archive_parts.part-code skip
                "Необходимо резервировать" v-need-rsrv skip
                "Резерв" v-rsrv-code skip
                "Необходимо снятие резервов" v-need-unrv skip
                "Снятие резервов" v-unrv-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            assign
              buf_parts.fact-date = buf_parts-attr.fact-date
              buf_parts.fact-num  = v-fact-num
              buf_parts.doc-type  = v-doc-type
            .
          end.
          assign
            buf_parts.qnty      = buf_parts.qnty  + v-unrv-sign * archive_parts.fact-qnty
            buf_parts.fact-qnty = buf_parts.qnty
          .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-gds-code
  ) no-error .
          if buf_parts.out-code = 'free-zone':U
          then
          for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                      and buf_marking-lines.obj-type = archive_parts.obj-type
                                                      and buf_marking-lines.obj-code = archive_parts.obj-code
                                                      and buf_marking-lines.in-code  = archive_parts.in-code
                                                      and buf_marking-lines.out-code = archive_parts.out-code
                                                      and buf_marking-lines.part-code = archive_parts.part-code
                                                      and buf_marking-lines.prt-code = archive_parts.prt-code:
            for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
              find first free_marking-lines no-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                      and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                      and free_marking-lines.obj-type   = buf_parts.obj-type
                                                      and free_marking-lines.obj-code   = buf_parts.obj-code
                                                      and free_marking-lines.in-code    = buf_parts.in-code
                                                      and free_marking-lines.out-code   = buf_parts.out-code
                                                      and free_marking-lines.part-code  = buf_parts.part-code
                                                      and free_marking-lines.prt-code   = buf_parts.prt-code
                                                      no-error .
              if not available free_marking-lines
              then do :
                create free_marking-lines .
                assign
                  free_marking-lines.mark       = buf_marking-lines.mark
                  free_marking-lines.doc-level  = buf_marking-lines.doc-level
                  free_marking-lines.gds-code   = buf_marking-lines.gds-code
                  free_marking-lines.obj-type   = buf_parts.obj-type
                  free_marking-lines.obj-code   = buf_parts.obj-code
                  free_marking-lines.in-code    = buf_parts.in-code
                  free_marking-lines.out-code   = buf_parts.out-code
                  free_marking-lines.part-code  = buf_parts.part-code
                  free_marking-lines.prt-code   = buf_parts.prt-code
                .
              end .
              if avail buf_trn-doc and buf_trn-doc.doc-type <> 'инв':U and buf_trn-doc.doc-type <> 'спи':U and
                 not (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'vt':U)
                then assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
              if buf_trn-doc.ext-doc-type = 'es':U
              then do :
                assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB .
              end .
              for each buf_marking-chk exclusive-lock where buf_marking-chk.mark begins buf_marking.mark :
                assign buf_marking-chk.sts = 0 .
              end .
            end .
            delete buf_marking-lines .
          end.
          if v-goods-twounit = true
          then do:
            assign
              buf_parts.cli-qnty = buf_parts.cli-qnty + v-unrv-sign * archive_parts.cli-qnty
            .
          end.
          else do:
            if buf_parts.cli-base-rate <> 0
            then do:
              assign
                buf_parts.cli-qnty = buf_parts.fact-qnty / buf_parts.cli-base-rate
              .
            end.
            else do:
              assign
                buf_parts.cli-qnty = 0
              .
            end.
          end.
          if  buf_parts.qnty      = 0
          and buf_parts.fact-qnty = 0
          then do:
            if v-goods-twounit = true
            then do:
              if buf_parts.cli-qnty <> 0
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  vss-include-info22 skip
                  "Ошибка при удалении партии" skip
                  "Документ" p-doc-code skip
                  "Объект" p-obj-type p-obj-code skip
                  "Артикул" p-artic p-prod-type p-prod-code skip
                  "Партия" buf_parts.in-code buf_parts.part-code skip
                  "Резерв" buf_parts.out-code skip
                  "qnty" buf_parts.qnty skip
                  "fact-qnty" buf_parts.fact-qnty skip
                  "cli-qnty" buf_parts.cli-qnty skip
                  view-as alert-box error .
                undo, return error .
              end.
            end.
            for each del_marking-lines exclusive-lock where del_marking-lines.gds-code = v-gds-code
                                                        and del_marking-lines.obj-type = buf_parts.obj-type
                                                        and del_marking-lines.obj-code = buf_parts.obj-code
                                                        and del_marking-lines.in-code = buf_parts.in-code
                                                        and del_marking-lines.out-code = buf_parts.out-code
                                                        and del_marking-lines.part-code = buf_parts.part-code
                                                        and del_marking-lines.prt-code = buf_parts.prt-code:
              delete del_marking-lines .
            end.
            run gen-key-rec IN THIS-PROCEDURE (  input 'parts':U
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
            for each ub.gen-attr no-lock where ub.gen-attr.table-name = 'excise-mark':U
                                     and ub.gen-attr.p-key =  part-key-rec
            :
              find first buf1_gen-attr no-lock where recid (buf1_gen-attr) = recid (ub.gen-attr).
              find current buf1_gen-attr exclusive-lock.
              delete buf1_gen-attr .
            end.
            delete buf_parts .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure partcopy-rsrv-parts :
  define input  parameter p-doc-code-rowid as rowid no-undo .
  define input  parameter p-parts-rowid    as rowid no-undo .
  define input  parameter p-rsrv-direction as logical   no-undo .
  define input  parameter p-goods-twounit  as logical   no-undo .
  define input  parameter p-is-hold        as logical   no-undo .
  define variable vss-description as character no-undo init "partcopy-rsrv-parts-01: процедура обработки партий при удалении документа".
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer archive_parts for ub.parts .
  define buffer buf_parts   for ub.parts .
  define buffer orig_marking-lines for ub.marking-lines .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .
  define buffer buf_goods for ub.goods .
  define variable v-rsrv-code as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where rowid(buf_trn-doc) = p-doc-code-rowid
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find first archive_parts
      where rowid(archive_parts) = p-parts-rowid
      no-error .
    if not available archive_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров" skip
        "Не найдена партия" skip
        "Документ" string(p-doc-code-rowid) skip
        "Партия" string(p-parts-rowid) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  archive_parts.out-code <> archive_parts.in-code
    and archive_parts.qnty <> 0
    and (buf_trn-doc.doc-type = 'при':U and buf_trn-doc.internal = yes ) = false
    and (buf_trn-doc.doc-type = 'возврат':U and p-is-hold = true  ) = false
    then do:
      assign
        v-rsrv-code =
        ( if (lookup(buf_trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (buf_trn-doc.doc-type = 'инв':U and archive_parts.qnty < 0)
      then 'free-zone':U
      else 'out-zone':U )
      .
      run partcopy in this-procedure
        (input  true
        ,input  v-rsrv-code
        ,buffer archive_parts
        ,buffer buf_parts
        ,input  "news"
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info22 skip
          "Ошибка при создании партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Объект" archive_parts.obj-type archive_parts.obj-code skip
          "Артикул" archive_parts.artic archive_parts.prod-type archive_parts.prod-code skip
          "Партия" archive_parts.in-code archive_parts.part-code skip
          "Количество" archive_parts.qnty skip
          "Резерв" v-rsrv-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty     - abs(archive_parts.qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        buf_parts.fact-qnty = buf_parts.qnty
      .
      find first buf_goods no-lock where buf_goods.artic = archive_parts.artic
                                     and buf_goods.prod-type = archive_parts.prod-type
                                     and buf_goods.prod-code = archive_parts.prod-code
                                     .
      for each orig_marking-lines no-lock where orig_marking-lines.gds-code   = buf_goods.gds-code
                                            and orig_marking-lines.obj-type   = archive_parts.obj-type
                                            and orig_marking-lines.obj-code   = archive_parts.obj-code
                                            and orig_marking-lines.in-code    = archive_parts.in-code
                                            and orig_marking-lines.out-code   = archive_parts.out-code
                                            and orig_marking-lines.part-code  = archive_parts.part-code
                                            and orig_marking-lines.prt-code   = archive_parts.prt-code
                                            :
        find first buf_marking-lines no-lock where  buf_marking-lines.mark       = orig_marking-lines.mark
                                                and buf_marking-lines.gds-code   = buf_goods.gds-code
                                                and buf_marking-lines.obj-type   = buf_parts.obj-type
                                                and buf_marking-lines.obj-code   = buf_parts.obj-code
                                                and buf_marking-lines.in-code    = buf_parts.in-code
                                                and buf_marking-lines.out-code   = buf_parts.out-code
                                                and buf_marking-lines.part-code  = buf_parts.part-code
                                                and buf_marking-lines.prt-code   = buf_parts.prt-code
                                                no-error .
        if available buf_marking-lines
        then do :
          find current buf_marking-lines exclusive-lock .
          delete buf_marking-lines .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB .
          end .
        end .
        else do :
          create buf_marking-lines .
          assign
            buf_marking-lines.mark       = orig_marking-lines.mark
            buf_marking-lines.doc-level  = orig_marking-lines.doc-level
            buf_marking-lines.gds-code   = buf_goods.gds-code
            buf_marking-lines.obj-type   = buf_parts.obj-type
            buf_marking-lines.obj-code   = buf_parts.obj-code
            buf_marking-lines.in-code    = buf_parts.in-code
            buf_marking-lines.out-code   = buf_parts.out-code
            buf_marking-lines.part-code  = buf_parts.part-code
            buf_marking-lines.prt-code   = buf_parts.prt-code
          .
          if buf_parts.out-code <> buf_parts.in-code
          and buf_parts.out-code <> 'free-zone':U
          and buf_parts.out-code <> 'out-zone':U
          then do :
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code no-error .
            if available buf_trn-doc then buf_marking-lines.fact-order = buf_trn-doc.fact-order .
          end .
          for first buf_marking exclusive-lock where buf_marking.mark = orig_marking-lines.mark :
            assign
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB when buf_parts.out-code = 'free-zone':U
              buf_marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB when buf_parts.out-code = 'out-zone':U
            .
          end .
        end .
        release buf_marking-lines no-error .
      end.
      if p-goods-twounit = true
      then do:
        assign
          buf_parts.cli-qnty = buf_parts.cli-qnty - abs(archive_parts.cli-qnty)
                                                  * (if p-rsrv-direction = true
                                                    then 1
                                                    else -1
                                                    )
        .
      end.
      if  buf_parts.qnty      = 0
      and buf_parts.fact-qnty = 0
      then do:
        if p-goods-twounit = true
        then do:
          if buf_parts.cli-qnty <> 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info22 skip
              "Ошибка при удалении партии" skip
              "Документ" buf_trn-doc.doc-code skip
              "Объект" buf_parts.obj-type buf_parts.obj-code skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "Партия" buf_parts.in-code buf_parts.part-code skip
              "Резерв" buf_parts.out-code skip
              "qnty" buf_parts.qnty skip
              "fact-qnty" buf_parts.fact-qnty skip
              "cli-qnty" buf_parts.cli-qnty skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
        delete buf_parts .
      end.
    end.
  end.
end procedure.
procedure partcopy-update-doc-line-tot-fact :
  define input  parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic     like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code like ub.doc-line.prod-code no-undo .
  define variable vss-description as character no-undo init "partcopy-update-doc-line-tot-fact-01: процедура обновления средней учетной цены в строке документа".
    define variable v-total-parts-qnty           like ub.parts.qnty      no-undo .   define variable v-total-parts-fact-qnty      like ub.parts.fact-qnty no-undo .   define variable v-total-parts-cli-qnty       like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-fact-cli-qnty  like ub.parts.cli-qnty  no-undo .   define variable v-total-parts-price-cli      as decimal no-undo .   define variable v-total-parts-price-base     as decimal no-undo .   define variable v-total-parts-price-rubl     as decimal no-undo .   define variable v-total-parts-transport-base as decimal no-undo .   define variable v-total-parts-transport-rubl as decimal no-undo .   define variable v-total-parts-other-base     as decimal no-undo .   define variable v-total-parts-other-rubl     as decimal no-undo .
  define buffer buf_doc-line for ub.doc-line .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line exclusive-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run partrqst in this-procedure
      (input buf_doc-line.doc-code
      ,input buf_doc-line.obj-type
      ,input buf_doc-line.obj-code
      ,input buf_doc-line.artic
      ,input buf_doc-line.prod-type
      ,input buf_doc-line.prod-code
            ,output v-total-parts-qnty   ,output v-total-parts-fact-qnty   ,output v-total-parts-cli-qnty   ,output v-total-parts-fact-cli-qnty   ,output v-total-parts-price-cli   ,output v-total-parts-price-base   ,output v-total-parts-price-rubl   ,output v-total-parts-transport-base   ,output v-total-parts-transport-rubl   ,output v-total-parts-other-base   ,output v-total-parts-other-rubl
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка при сборе информации по партиям" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-total-parts-fact-qnty <> 0
    then do:
      assign
        buf_doc-line.price-base      = v-total-parts-price-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.price-rubl      = v-total-parts-price-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-base  = v-total-parts-transport-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.transport-rubl  = v-total-parts-transport-rubl
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-base      = v-total-parts-other-base
                                     / v-total-parts-fact-qnty
        buf_doc-line.other-rubl      = v-total-parts-other-rubl
                                     / v-total-parts-fact-qnty
      .
    end.
    else do:
    end.
  end.
end procedure.
procedure partcopy-change-purch-code :
  define input parameter  p-in-code          like ub.parts.in-code no-undo .
  define input parameter  p-dest-purch-code  like ub.parts.purch-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf1_parts         for ub.parts .
  define parameter buffer buf2_parts         for ub.parts .
  define variable vss-description as character no-undo init "partcopy-change-purch-code01: процедура копирования партии при смене purch-code".
  define variable var-out-code  like ub.parts.out-code no-undo .
  define variable var-part-code like ub.parts.part-code no-undo .
  define buffer buf_goods        for ub.goods .
  define buffer buf_parts-root   for ub.parts-root.
  define buffer buf_trn-doc      for ub.trn-doc.
  define buffer buf-orig_trn-doc for ub.trn-doc.
  define buffer buf_units        for ub.units .
  do
  on error undo, return error return-value
  :
    if buf_orig_parts.out-code = p-in-code
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info22 skip
        "Ошибка задания входных параметров процедуры partcopy" skip
        "buf_orig_parts.out-code" buf_orig_parts.out-code skip
        "p-in-code" p-in-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-in-code
      .
    find first buf-orig_trn-doc where buf-orig_trn-doc.doc-code = buf_orig_parts.out-code.
    find first buf_goods no-lock
      where buf_goods.artic = buf_orig_parts.artic
        and buf_goods.prod-type = buf_orig_parts.prod-type
        and buf_goods.prod-code = buf_orig_parts.prod-code
      .
    find first buf_units where buf_units.unit-name = buf_goods.unit-base no-lock.
    find first buf1_parts exclusive-lock
      where buf1_parts.obj-type  = buf_orig_parts.obj-type
        and buf1_parts.obj-code  = buf_orig_parts.obj-code
        and buf1_parts.artic     = buf_orig_parts.artic
        and buf1_parts.prod-type = buf_orig_parts.prod-type
        and buf1_parts.prod-code = buf_orig_parts.prod-code
        and buf1_parts.in-code   = buf_orig_parts.in-code
        and buf1_parts.out-code  = p-in-code
        and buf1_parts.part-code = buf_orig_parts.part-code
      no-error.
    if not available buf1_parts
    then do:
      create buf1_parts .
      buffer-copy buf_orig_parts to buf1_parts
      assign
        buf1_parts.in-code    = buf_orig_parts.in-code
        buf1_parts.out-code   = p-in-code
        buf1_parts.status_    = no
        buf1_parts.qnty       = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.fact-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.fact-qnty else - buf_orig_parts.fact-qnty )
        buf1_parts.cli-qnty   = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then buf_orig_parts.cli-qnty  else - buf_orig_parts.cli-qnty  )
        buf1_parts.purch-code = buf_orig_parts.purch-code
        buf1_parts.rsrv-free  = ?
        buf1_parts.status_    = yes
      .
      validate buf1_parts .
    end.
    if  lookup('сер':U, buf_units.type) > 0
    then do:
       var-part-code = buf_orig_parts.part-code.
    end.
    else do:
        run holdprts-get-part-code in this-procedure
          (input  p-in-code
          ,output var-part-code
          ) no-error .
        if error-status :error
        then dO:
          undo, return error return-value.
        end.
    end.
    find first buf2_parts exclusive-lock
      where buf2_parts.obj-type  = buf_orig_parts.obj-type
        and buf2_parts.obj-code  = buf_orig_parts.obj-code
        and buf2_parts.artic     = buf_orig_parts.artic
        and buf2_parts.prod-type = buf_orig_parts.prod-type
        and buf2_parts.prod-code = buf_orig_parts.prod-code
        and buf2_parts.in-code   = p-in-code
        and buf2_parts.out-code  = p-in-code
        and buf2_parts.part-code = var-part-code
      no-error.
    if not available buf2_parts
    then do:
      create buf2_parts .
      buffer-copy buf_orig_parts to buf2_parts
      assign
        buf2_parts.in-code   = p-in-code
        buf2_parts.out-code  = p-in-code
        buf2_parts.qnty      = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.fact-qnty = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.fact-qnty else buf_orig_parts.fact-qnty )
        buf2_parts.cli-qnty  = (if buf-orig_trn-doc.ext-doc-type = 'mp':U then - buf_orig_parts.cli-qnty  else buf_orig_parts.cli-qnty  )
        buf2_parts.purch-code = p-dest-purch-code
        buf2_parts.part-code  = var-part-code
        buf2_parts.rsrv-free  = ?
        buf2_parts.status_    = yes
      .
      validate buf2_parts .
    end.
    assign
      buf_orig_parts.in-code    = p-in-code
      buf_orig_parts.part-code  = buf2_parts.part-code
      buf_orig_parts.purch-code = buf2_parts.purch-code
    .
    find first buf_parts-root
      where buf_parts-root.doc-code       = p-in-code
        and buf_parts-root.in-code        = p-in-code
        and buf_parts-root.gds-code       = buf_goods.gds-code
        and buf_parts-root.part-code      = buf2_parts.part-code
        and buf_parts-root.orig-in-code   = buf1_parts.in-code
        and buf_parts-root.orig-gds-code  = buf_goods.gds-code
        and buf_parts-root.orig-part-code = buf1_parts.part-code
      no-error .
    if not available buf_parts-root
    then do:
      create buf_parts-root.
      assign
      buf_parts-root.doc-code       = p-in-code
      buf_parts-root.in-code        = p-in-code
      buf_parts-root.gds-code       = buf_goods.gds-code
      buf_parts-root.part-code      = buf2_parts.part-code
      buf_parts-root.orig-in-code   = buf1_parts.in-code
      buf_parts-root.orig-gds-code  = buf_goods.gds-code
      buf_parts-root.orig-part-code = buf1_parts.part-code
      .
    end.
  end.
end procedure.
procedure addChildMarkingLines:
  define input parameter iMark as character no-undo.
  define input parameter iSts  as integer   no-undo.
  define parameter buffer buf_marking-lines  for ub.marking-lines.
  define parameter buffer buf_parts          for ub.parts.
  define parameter buffer orig_marking-lines for ub.marking-lines.
  define parameter buffer buf_orig_parts     for ub.parts.
  define parameter buffer buf_goods          for ub.goods.
  define buffer buf_marking-childs        for ub.marking.
  define buffer buf_marking-lines-childs  for ub.marking-lines.
  define buffer buf_marking-chk           for ub.marking-chk.
  define buffer buf_chk-doc               for ub.chk-doc.
  define buffer orig_marking-lines-childs for ub.marking-lines.
  for each buf_marking-childs exclusive-lock where
           buf_marking-childs.mark-parent = iMark :
      find first buf_marking-lines-childs no-lock where
                 buf_marking-lines-childs.mark       = buf_marking-childs.mark
             and buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
             and buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
             and buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
             and buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
             and buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
             and buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
             and buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
      no-error .
      if not available buf_marking-lines-childs then
      do:
        create buf_marking-lines-childs .
        assign
          buf_marking-lines-childs.mark       = buf_marking-childs.mark
          buf_marking-lines-childs.gds-code   = buf_marking-lines.gds-code
          buf_marking-lines-childs.obj-type   = buf_marking-lines.obj-type
          buf_marking-lines-childs.obj-code   = buf_marking-lines.obj-code
          buf_marking-lines-childs.in-code    = buf_marking-lines.in-code
          buf_marking-lines-childs.out-code   = buf_marking-lines.out-code
          buf_marking-lines-childs.part-code  = buf_marking-lines.part-code
          buf_marking-lines-childs.prt-code   = buf_marking-lines.prt-code
          buf_marking-lines-childs.fact-order = buf_marking-lines.fact-order
          buf_marking-lines-childs.doc-level  = buf_marking-lines.doc-level + 1
        .
        validate buf_marking-childs.
      end .
      buf_marking-childs.sts = iSts .
      for each buf_marking-chk exclusive-lock where
               buf_marking-chk.mark begins buf_marking-childs.mark
      :
        for first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = buf_marking-chk.doc-code
              and buf_chk-doc.out-code = buf_parts.out-code
        :
          buf_marking-chk.sts = 0 .
          validate buf_marking-chk.
        end .
      end .
      if available orig_marking-lines
      then do :
        find first orig_marking-lines-childs exclusive-lock where
                   orig_marking-lines-childs.mark       = buf_marking-childs.mark
               and orig_marking-lines-childs.gds-code   = buf_goods.gds-code
               and orig_marking-lines-childs.obj-type   = buf_orig_parts.obj-type
               and orig_marking-lines-childs.obj-code   = buf_orig_parts.obj-code
               and orig_marking-lines-childs.in-code    = buf_orig_parts.in-code
               and orig_marking-lines-childs.out-code   = buf_orig_parts.out-code
               and orig_marking-lines-childs.part-code  = buf_orig_parts.part-code
               and orig_marking-lines-childs.prt-code   = buf_orig_parts.prt-code
        no-error .
        if available orig_marking-lines-childs then
          delete orig_marking-lines-childs .
      end.
      run addChildMarkingLines in this-procedure (
        buf_marking-childs.mark,
        iSts,
        buffer buf_marking-lines,
        buffer buf_parts,
        buffer orig_marking-lines,
        buffer buf_orig_parts,
        buffer buf_goods
      ).
  end .
end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-cli :
  do
  on error undo, return error return-value
  :
    define input parameter p-trn-doc-recid as recid no-undo .
    define variable vss-description as character no-undo init "$Workfile$ Установка признаков клиента при закрытии документов" .
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_clients for ub.clients .
    define variable v-cons-pay like ub.trn-doc.pay-code no-undo .
    find first buf_trn-doc no-lock
      where recid(buf_trn-doc) = p-trn-doc-recid
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Код записи документ (recid)" p-trn-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-at-value as character no-undo .
    define variable v-at-type  as character no-undo .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objatext in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'cons-pay=request':u
  ,output v-at-value
  ,output v-at-type
  ) no-error .
    if error-status :error
    or v-at-type <> 'I':U then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении расширенного атрибута объекта" skip
        "Документ" buf_trn-doc.doc-code skip
        "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-cons-pay = integer(v-at-value)
    .
    define variable l-sup as logical no-undo .
    define variable l-buy as logical no-undo .
    assign
      l-sup = (lookup(buf_trn-doc.ext-doc-type, 'ie':U ) > 0)
      l-buy = (lookup(buf_trn-doc.ext-doc-type, 'ee':U ) > 0)
    .
    if l-sup = true
    or l-buy = true
    then do:
      find buf_clients no-lock
        where buf_clients.obj-type = buf_trn-doc.cli-type
          and buf_clients.obj-code = buf_trn-doc.cli-code
        no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден контрагент" skip
          "Документ" buf_trn-doc.cli-type buf_trn-doc.cli-code skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable l-gds  as logical   no-undo .
      define variable l-cons as logical   no-undo .
      define variable l-serv as logical   no-undo .
      assign
        l-gds  = false
        l-cons = false
        l-serv = false
      .
      if buf_trn-doc.office = true then do:
        assign
          l-serv = true
        .
      end.
      else do:
        if buf_trn-doc.purch-code = v-cons-pay then do:
          assign
            l-cons = true
          .
        end.
        else do:
          assign
            l-gds = true
          .
        end.
      end.
      if l-sup then do:
        if (l-gds  = true and (buf_clients.sup-gds  <> true) )
        or (l-cons = true and (buf_clients.sup-cons <> true) )
        or (l-serv = true and (buf_clients.sup-serv <> true) )
        then
        do transaction
        on error undo, return error return-value
        :
          find current buf_clients exclusive-lock .
          run clientsh_write-clients-proc in this-procedure  (
                                                       buffer buf_clients
                                                      ,input (if g#news then 'db':U else 'trn-doc':U)
                                                      ,input (if g#news then string(g#news-source-db) else buf_trn-doc.doc-code)
                                                      ) .
          assign
            buf_clients.sup-gds  = buf_clients.sup-gds  or l-gds
            buf_clients.sup-cons = buf_clients.sup-cons or l-cons
            buf_clients.sup-serv = buf_clients.sup-serv or l-serv
          .
        end.
      end.
      if l-buy then do:
        if (l-gds  = true and (buf_clients.buy-gds  <> true) )
        or (l-cons = true and (buf_clients.buy-cons <> true) )
        or (l-serv = true and (buf_clients.buy-serv <> true) )
        then
        do transaction
        on error undo, return error return-value
        :
          find current buf_clients exclusive-lock .
          run clientsh_write-clients-proc in this-procedure  (
                                                       buffer buf_clients
                                                      ,input (if g#news then 'db':U else 'trn-doc':U)
                                                      ,input (if g#news then string(g#news-source-db) else buf_trn-doc.doc-code)
                                                      ) .
          assign
            buf_clients.buy-gds  = buf_clients.buy-gds  or l-gds
            buf_clients.buy-cons = buf_clients.buy-cons or l-cons
            buf_clients.buy-serv = buf_clients.buy-serv or l-serv
          .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure trnbccr :
  define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
  define variable vss-description as character no-undo init "trnbccr: Создание бар-кодов партий" .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_parts    for ub.parts .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .
  define variable v-root-node       as integer   no-undo .
  define variable l-create-bar-code as logical   no-undo .
  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.status_ <> 'факт':U then do:
      message
        vss-workfile vss-revision vss-description skip
        "Документ имеет статус отличный от статуса" 'факт':U skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_parts
      where buf_parts.out-code = buf_trn-doc.doc-code
        and buf_parts.in-code  = buf_parts.out-code
    on error undo, return error
    :
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,output v-root-node
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака" skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_parts.obj-type
  ,input  buf_parts.obj-code
  ,input  buf_parts.artic
  ,input  buf_parts.prod-type
  ,input  buf_parts.prod-code
  ,input  'create-bar-code=request':u
  ,output l-create-bar-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении признака товара на объекте" skip
          "Объект" buf_parts.obj-type buf_parts.obj-code skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Запрашиваемый атрибут" "cash-parts=request":u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if l-create-bar-code then do:
        define variable v-bar-code-is-new as logical no-undo .
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  v-root-node
  ,input  buf_parts.part-code
  ,input  buf_parts.in-code
  ,input  buf_goods.unit-base
  ,input  ?
  ,output v-bar-code-is-new
  ,buffer buf_bar-code
  ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании бар-кода партии" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
end procedure.
def var vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
procedure chkprice:
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_doc-line for ub.doc-line.
define buffer bf_gds-dtl  for ub.gds-dtl.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define buffer bf_parts    for ub.parts.
define variable varroad-taxname as character no-undo.
define variable varexcisename   as character no-undo.
define variable varr-b          as character no-undo.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
run tax-name ('rdt':U,   output varroad-taxname).
run tax-name ('exc':U, output varexcisename).
do on error undo, return error return-value:
   find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
    if not available bf_trn-doc then
        return error SUBSTITUTE("Не найден документ с номером &1 (файл chkprice.i).", pardoc-code).
   if bf_trn-doc.status_ = 'запрос':U then return.
   for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code,
       first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock :
     if bf_trn-doc.doc-type <> 'инв':U then do:
       if bf_doc-line.doc-qnty = 0 and bf_doc-line.fact-qnty = 0 then next.
                                          if bf_doc-line.price-cli < 0 or bf_doc-line.price-cli = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена поставщика",                                        bf_doc-line.price-cli,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.price-rubl < 0 or bf_doc-line.price-rubl = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "учетная цена в рублях",                                        bf_doc-line.price-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.price-base < 0 or bf_doc-line.price-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "учетная цена в базовой валюте",                                        bf_doc-line.price-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.road-tax < 0 or bf_doc-line.road-tax = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         varroad-taxname,                                        bf_doc-line.road-tax,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.excise < 0 or bf_doc-line.excise = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         varexcisename,                                        bf_doc-line.excise,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.transport-base < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "транспортные расходы в базовой валюте",                                        bf_doc-line.transport-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.transport-rubl < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "транспортные расходы в рублях",                                        bf_doc-line.transport-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.other-base < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "прочие расходы в базовой валюте",                                        bf_doc-line.other-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.other-rubl < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "прочие расходы в рублях",                                        bf_doc-line.other-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
    end.
    else do:
       if bf_doc-line.fact-qnty = 0 then next.
                                          if bf_doc-line.price-cli = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена поставщика",                                        bf_doc-line.price-cli,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.price-rubl = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "учетная цена в рублях",                                        bf_doc-line.price-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.price-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "учетная цена в базовой валюте",                                        bf_doc-line.price-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.road-tax = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         varroad-taxname,                                        bf_doc-line.road-tax,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.excise = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         varexcisename,                                        bf_doc-line.excise,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
    end.
                                if bf_doc-line.vat-pc < 0 or bf_doc-line.vat-pc = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "ставка НДС",                                        bf_doc-line.vat-pc,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
                            if bf_doc-line.slt-pc < 0 or bf_doc-line.slt-pc = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "ставка НП",                                        bf_doc-line.slt-pc,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                          + " >>.".
       for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                                 bf_gds-dtl.artic     = bf_doc-line.artic     and
                                 bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                                 bf_gds-dtl.prod-code = bf_doc-line.prod-code ,
                                 first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code:
           if bf_trn-doc.doc-type <> 'инв':U then do:
             if bf_gds-dtl.doc-qnty = 0 and bf_gds-dtl.fact-qnty = 0 then next.
           end.
           else do:
             if bf_gds-dtl.doc-qnty = 0 then next.
           end.
                                                       if bf_gds-dtl.cur-base < 0 or bf_gds-dtl.cur-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "текущая продажная цена",                                        bf_gds-dtl.cur-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                            if bf_gds-dtl.discnt-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "скидка в базовой валюте",                                        bf_gds-dtl.discnt-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                            if bf_gds-dtl.discnt-rubl = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "скидка в рублях",                                        bf_gds-dtl.discnt-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                            if bf_gds-dtl.discnt-pc = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "процент скидки",                                        bf_gds-dtl.discnt-pc,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                            if bf_gds-dtl.price-base < 0 or bf_gds-dtl.price-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена по документу в базовой валюте",                                        bf_gds-dtl.price-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                            if bf_gds-dtl.price-rubl < 0 or bf_gds-dtl.price-rubl = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена по документу в рублях",                                        bf_gds-dtl.price-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
           if varr-b = "rubl":u then do:
                                                        if bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax < 0 or bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена по документу в рублях без учета скидки и компоненты " + varroad-taxname + " ",                                        bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                                        if bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale < 0 or bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена по документу в базовой валюте без учета скидки и компоненты " + varroad-taxname + " ",                                        bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
           end.
           else do:
                                                        if bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale < 0 or bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена по документу в рублях без учета скидки и компоненты " + varroad-taxname + " ",                                        bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
                                                        if bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax < 0 or bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена по документу в базовой валюте без учета скидки и компоненты " + varroad-taxname + " ",                                        bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + (if bf_gds-prt.node-name <> '_Пустая шкала':U and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "") + " >>.".
           end.
       end.
       for each bf_parts where bf_parts.out-code  = bf_trn-doc.doc-code   and
                               bf_parts.obj-type  = bf_trn-doc.obj-type   and
                               bf_parts.obj-code  = bf_trn-doc.obj-code   and
                               bf_parts.artic     = bf_doc-line.artic     and
                               bf_parts.prod-type = bf_doc-line.prod-type and
                               bf_parts.prod-code = bf_doc-line.prod-code :
                                                       if bf_parts.price-cli < 0 or bf_parts.price-cli = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена поставщика в партии",                                        bf_parts.price-cli,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.price-rubl < 0 or bf_parts.price-rubl = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "учетная цена в рублях в партии",                                        bf_parts.price-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.price-base < 0 or bf_parts.price-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "учетная цена в базовой валюте в партии",                                        bf_parts.price-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.vat-pc < 0 or bf_parts.vat-pc = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "ставка НДС в партии",                                        bf_parts.vat-pc,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.slt-pc < 0 or bf_parts.slt-pc = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "ставка НП в партии",                                        bf_parts.slt-pc,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.road-tax-base < 0 or bf_parts.road-tax-base = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         varroad-taxname + " в базовой валюте в партии",                                        bf_parts.road-tax-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.road-tax-rubl < 0 or bf_parts.road-tax-rubl = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         varroad-taxname + " в рублях в партии",                                        bf_parts.road-tax-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.transport-base < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "транспортные расходы в базовой валюте в партии",                                        bf_parts.transport-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.transport-rubl < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "транспортные расходы в рублях в партии",                                        bf_parts.transport-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.other-base < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "прочие расходы в базовой валюте в партии",                                        bf_parts.other-base,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.other-rubl < 0 then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "прочие расходы в рублях в партии",                                        bf_parts.other-rubl,                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.price-rubl - bf_parts.road-tax-rubl - (if bf_parts.transport-rubl <> ? then bf_parts.transport-rubl else 0) - (if bf_parts.other-rubl <> ? then bf_parts.other-rubl else 0) < 0 or bf_parts.price-rubl - bf_parts.road-tax-rubl - (if bf_parts.transport-rubl <> ? then bf_parts.transport-rubl else 0) - (if bf_parts.other-rubl <> ? then bf_parts.other-rubl else 0) = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена в рублях за вычетом компоненты " + varroad-taxname + " и всех расходов в партии",                                        bf_parts.price-rubl - bf_parts.road-tax-rubl - (if bf_parts.transport-rubl <> ? then bf_parts.transport-rubl else 0) - (if bf_parts.other-rubl <> ? then bf_parts.other-rubl else 0),                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
                                            if bf_parts.price-base - bf_parts.road-tax-base - (if bf_parts.transport-base <> ? then bf_parts.transport-base else 0) - (if bf_parts.other-base <> ? then bf_parts.other-base else 0) < 0 or bf_parts.price-base - bf_parts.road-tax-base - (if bf_parts.transport-base <> ? then bf_parts.transport-base else 0) - (if bf_parts.other-base <> ? then bf_parts.other-base else 0) = ? then                             return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10",                                         "цена в валюте за вычетом компоненты " + varroad-taxname + " и всех расходов в партии",                                        bf_parts.price-base - bf_parts.road-tax-base - (if bf_parts.transport-base <> ? then bf_parts.transport-base else 0) - (if bf_parts.other-base <> ? then bf_parts.other-base else 0),                                        bf_trn-doc.doc-code,                                         bf_trn-doc.ext-doc-type,                                         bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code),                                         bf_goods.artic,                                         bf_goods.prod-type,                                         bf_goods.prod-code,                                         bf_goods.gds-name )                                         + " код партии " + string(bf_parts.part-code) + " " + " >>.".
       end.
   end.
end.
end.
procedure chksltpc :
  do
  on error undo, return error
  :
    define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
    define variable loc#cash-pay like ub.sysconf.cash-pay no-undo.
    define buffer buf_trn-doc  for ub.trn-doc.
    define buffer buf_sysconf  for ub.sysconf.
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_parts    for ub.parts.
    define buffer buf_store    for ub.store.
    define buffer buf_shop     for ub.shop.
    def var v-have-slt-pc   as logical                  no-undo.
    def var v-host-code     like ub.sysconf.host-code   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = pardoc-code
      no-error
      .
    if not available buf_trn-doc then do:
      return error "Ошибка задания входных параметров" + chr(10)
        + "Не найден документ с номером " + pardoc-code
        .
    end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      .
    assign
      loc#cash-pay  = buf_sysconf.cash-pay
    .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_st-sltyn in g#lib-trn3
(
 input  recid(buf_trn-doc)
,input  loc#cash-pay
,output v-have-slt-pc
)
.
    if v-have-slt-pc = no then do:
       if buf_trn-doc.ext-doc-type = 'ep':U then do:
          for each buf_doc-line no-lock
           where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          on error undo, return error
          :
            for each buf_parts where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                     buf_parts.obj-type  = buf_doc-line.obj-type  and
                                     buf_parts.obj-code  = buf_doc-line.obj-code  and
                                     buf_parts.artic     = buf_doc-line.artic     and
                                     buf_parts.prod-type = buf_doc-line.prod-type and
                                     buf_parts.prod-code = buf_doc-line.prod-code:
               if buf_parts.slt-pc <> buf_doc-line.slt-pc then do:
                  return error
                  "В строке документа возврата поставщику " + buf_trn-doc.doc-code +
                  " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
                  " установлен налог с продаж " + string(buf_doc-line.slt-pc) + ", отличный от налога с продаж " + string(buf_parts.slt-pc) + " в партии с кодом " + (buf_parts.part-code) + " .".
               end.
            end.
          end.
       end.
       else do:
         for each buf_doc-line no-lock
           where buf_doc-line.doc-code =  buf_trn-doc.doc-code
             and buf_doc-line.slt-pc   <> 0
         on error undo, return error
         :
            return error
             "В строке документа " + buf_trn-doc.doc-code +
             " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
             " установлен налог с продаж " + string(buf_doc-line.slt-pc) + ", отличный от 0." +
             " Установка налога с продаж в данном документе недопустима.".
         end.
      end.
    end.
  end.
end procedure.
procedure chkvatpc :
do
on error undo, return error return-value
:
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_parts    for ub.parts.
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = pardoc-code
    no-error
    .
  if not available buf_trn-doc then do:
    return error "Ошибка задания входных параметров" + chr(10)
      + "Не найден документ с номером " + pardoc-code
      .
  end.
  if buf_trn-doc.ext-doc-type = 'ie':U and
     buf_trn-doc.vat-type     = 'без':U     then do:
    for each buf_doc-line no-lock
         where buf_doc-line.doc-code =  buf_trn-doc.doc-code
    on error undo, return error return-value
    :
       if buf_doc-line.vat-pc <> 0 then do:
         return error
          "В строке документа " + buf_trn-doc.doc-code +
          " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
          " установлен НДС " + string(buf_doc-line.vat-pc) + ", отличный от 0." +
          " Установка НДС в данном документе с типом НДС - <без> недопустима.".
       end.
       for each buf_parts where buf_parts.out-code  = buf_trn-doc.doc-code   and
                                buf_parts.obj-type  = buf_doc-line.obj-type  and
                                buf_parts.obj-code  = buf_doc-line.obj-code  and
                                buf_parts.artic     = buf_doc-line.artic     and
                                buf_parts.prod-type = buf_doc-line.prod-type and
                                buf_parts.prod-code = buf_doc-line.prod-code on error undo, return error return-value :
          if buf_parts.vat-pc <> 0 then do:
             return error
             "В строке документа " + buf_trn-doc.doc-code +
             " товар " + string(buf_doc-line.artic) + " " + buf_doc-line.prod-type + " " + string(buf_doc-line.prod-code) +
             " установлен НДС отличный от 0 в партии с кодом " + (buf_parts.part-code) + " . Это недопустимо для документа с типом НДС - без.".
          end.
       end.
    end.
  end.
end.
end procedure.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prl-vat:
  define input parameter parrecid as recid no-undo.
    define output parameter price-rubl-with-tax-saleprl    like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-with-tax-saleprl    like ub.doc-line.price-base no-undo.
    define output parameter price-rubl-without-tax-saleprl like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-without-tax-saleprl like ub.doc-line.price-base no-undo.
    define output parameter vat-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter vat-base-buyerprl              like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-buyerprl              like ub.doc-line.price-rubl no-undo.
    define output parameter slt-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter slt-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter road-tax-base-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter road-tax-rubl-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter excise-base-saleprl            like ub.doc-line.price-base no-undo.
    define output parameter excise-rubl-saleprl            like ub.doc-line.price-rubl no-undo.
    define output parameter discnt-base-saleprl            like ub.gds-dtl.discnt-base no-undo.
    define output parameter discnt-rubl-saleprl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlprl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlprl for ub.gds-dtl.
    define buffer out-vatp_partsprl       for ub.parts.
    define buffer out-vatp_sysconfprl     for ub.sysconf.
    define buffer out-vatp_doc-lineprl    for ub.doc-line.
    define buffer out-vatp_goodsprl       for ub.goods.
    define buffer out-vatp_trn-docprl     for ub.trn-doc.
    define buffer out-vatp_doc-attrprl    for ub.doc-attr.
    define variable varprice-base-consprl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consprl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeprl         as   character                           no-undo.
    define variable varfrm-cnsvprl              as   character                           no-undo.
    define variable varroot-nodeprl             as   integer                             no-undo.
    define variable varempty-scaleprl           as   logical                             no-undo.
    define variable varis-cons-parts-haveprl    as   logical                             no-undo.
    define variable varsum-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlprl        as   logical                             no-undo.
    define variable varcurprlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurprldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbprl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltprl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoprl  for ub.trn-doc .
    define buffer   in-vatp-partsoprl    for ub.parts   .
    define buffer   in-vatp-docoprl      for ub.trn-doc .
    define buffer   in-vatp-goodsoprl    for ub.goods   .
    define buffer   in-vatp-sysconfoprl  for ub.sysconf .
    define buffer   in-vatp_doc-attroprl for ub.doc-attr.
    define variable in-vatp-have-vat-sltoprl       as   logical initial yes    no-undo.
    define variable vat-pc-locoprl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboprl                  as   character              no-undo.
    define variable slt-pc-locoprl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoprl              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoprl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoprl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoprl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoprl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoprl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoprl  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoprl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoprl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoprl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoprl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoprl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoprl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoprl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoprl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoprl             as   character              no-undo.
    define variable varinvatp-typeoprl             as   character              no-undo.
  define buffer bf_price-list for ub.price-list.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts      for ub.parts.
  define variable varbase-rate   like ub.trn-doc.base-rate     no-undo.
  define variable varbase-scale  like ub.trn-doc.base-scale    no-undo.
  define variable varroad-tax    like ub.price-list.road-tax   no-undo.
  define variable varexcise      like ub.price-list.excise     no-undo.
  define variable varvat-pc      like ub.doc-line.vat-pc       no-undo.
  define variable varslt-pc      like ub.doc-line.slt-pc       no-undo.
  define variable varprice-base  like ub.price-list.price-sale no-undo.
  define variable varprice-rubl  like ub.price-list.price-sale no-undo.
  define variable vardiscnt-base like ub.price-list.price-sale no-undo.
  define variable vardiscnt-rubl like ub.price-list.price-sale no-undo.
  define variable v-host-code    like ub.sysconf.host-code     no-undo.
  define variable vardoc-num     like ub.price-list.doc-num    no-undo.
  define variable vardoc-code    like ub.price-list.doc-num    no-undo.
  define variable varobj-type    like ub.price-list.obj-type   no-undo.
  define variable varobj-code    like ub.price-list.obj-code   no-undo.
  define variable varartic       like ub.price-list.artic      no-undo.
  define variable varprod-type   like ub.price-list.prod-type  no-undo.
  define variable varprod-code   like ub.price-list.prod-code  no-undo.
  define variable varfact-qnty   like ub.price-list.doc-qnty   no-undo.
  define variable varcons-vat-pc like ub.doc-line.vat-pc       no-undo.
  define variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define variable vardoc-qnty     like ub.price-list.doc-qnty no-undo.
  define variable vardoc-type     as   character              no-undo.
  do
  on error undo, return error "Ошибка при вызове процедуры prl-vat."
  :
    find first bf_price-list no-lock
      where recid(bf_price-list) = parrecid
      no-error .
    if not available bf_price-list
    then do:
      return error "Ошибка во входящих параметрах prl-vat.i" .
    end.
    find first bf_goods no-lock
      where bf_goods.artic     = bf_price-list.artic
        and bf_goods.prod-type = bf_price-list.prod-type
        and bf_goods.prod-code = bf_price-list.prod-code
      no-error .
    if not available bf_goods
    then do:
      undo, return error substitute("Не найден товар &1 &2 &3 для переоценки с кодом &4",bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code,parrecid).
    end.
    assign
      varvat-pc = bf_price-list.vat-pc
      varslt-pc = bf_price-list.slt-pc
    .
    if varvat-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НДС",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    if varslt-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НП",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    assign
      varbase-rate   = 1
      varbase-scale  = 1
      varroad-tax    = bf_price-list.road-tax
      varexcise      = bf_price-list.excise
      varprice-base  = bf_price-list.price-sale
      varprice-rubl  = bf_price-list.price-sale
      vardiscnt-base = 0
      vardiscnt-rubl = 0
    .
    assign
      varfact-qnty = 0
    .
    for each bf_parts no-lock
      where bf_parts.out-code   = bf_price-list.doc-num
        and bf_parts.obj-type   = bf_price-list.obj-type
        and bf_parts.obj-code   = bf_price-list.obj-code
        and bf_parts.artic      = bf_price-list.artic
        and bf_parts.prod-type  = bf_price-list.prod-type
        and bf_parts.prod-code  = bf_price-list.prod-code
    :
      assign
        varfact-qnty = varfact-qnty + bf_parts.fact-qnty
      .
    end.
    assign
      vardoc-num   = bf_price-list.doc-num
      vardoc-code  = bf_price-list.doc-num
      varobj-type  = bf_price-list.obj-type
      varobj-code  = bf_price-list.obj-code
      varartic     = bf_price-list.artic
      varprod-type = bf_price-list.prod-type
      varprod-code = bf_price-list.prod-code
      vardoc-qnty  = varfact-qnty
      varext-doc-type = 'ot':U
    .
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_price-list.obj-type
  ,input  bf_price-list.obj-code
  ,output v-host-code
  )  .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = v-host-code
      .
    if bf_sysconf.cons-vat-pc = ?
    then do:
      return error "Не задан консигнационный НДС по фирме." .
    end.
    else do:
      assign
        varcons-vat-pc = bf_sysconf.cons-vat-pc
      .
    end.
if varext-doc-type = 'ot':U or
   varext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltprl = yes.
end.
else do:
  find first out-vatp_doc-attrprl no-lock
    where out-vatp_doc-attrprl.doc-code  = vardoc-code
      and out-vatp_doc-attrprl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrprl then do:
    assign
      out-vatp-have-vat-sltprl = yes.
  end.
  else do:
     out-vatp-have-vat-sltprl = no.
  end.
end.
find first out-vatp_goodsprl where out-vatp_goodsprl.artic     = varartic     and
                                   out-vatp_goodsprl.prod-type = varprod-type and
                                   out-vatp_goodsprl.prod-code = varprod-code no-lock.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  varartic
  ,input  varprod-type
  ,input  varprod-code
  ,output varroot-nodeprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" varartic varprod-type varprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeprl
  ,input  'empty-scale=request'
  ,output varempty-scaleprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" varartic varprod-type varprod-code skip
    "Признак" varroot-nodeprl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbprl
  )  .
if varoutvprbprl = "base":u then do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax / varbase-rate * varbase-scale)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   / varbase-rate * varbase-scale)
  .
end.
if varoutvprbprl = "rubl":u then do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * varbase-rate / varbase-scale)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * varbase-rate / varbase-scale) .
end.
assign
  varis-cons-parts-haveprl =  no.
assign
  varfact-qntyprl       = 0
  varcons-qntyprl       = 0
  varprice-base-consprl = 0
  varprice-rubl-consprl = 0.
find first out-vatp_doc-lineprl where
           out-vatp_doc-lineprl.doc-code   = vardoc-num
       and out-vatp_doc-lineprl.artic      = varartic
       and out-vatp_doc-lineprl.prod-type  = varprod-type
       and out-vatp_doc-lineprl.prod-code  = varprod-code no-lock no-error.
if available out-vatp_doc-lineprl           and
  (out-vatp_doc-lineprl.status_ = 'запрос':U or out-vatp_goodsprl.gds-type = 'у':U) then do:
  assign
    varfact-qntyprl = out-vatp_doc-lineprl.fact-qnty.
end.
else do:
  for each out-vatp_partsprl where out-vatp_partsprl.out-code   = vardoc-num
                               and out-vatp_partsprl.obj-type   = varobj-type
                               and out-vatp_partsprl.obj-code   = varobj-code
                               and out-vatp_partsprl.artic      = varartic
                               and out-vatp_partsprl.prod-type  = varprod-type
                               and out-vatp_partsprl.prod-code  = varprod-code no-lock :
    if out-vatp_partsprl.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoprl = out-vatp_partsprl.price-rubl
  price-base-with-tax-locoprl = out-vatp_partsprl.price-base
.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboprl
  )  .
  if out-vatp_partsprl.out-code = 'free-zone':U     or
     out-vatp_partsprl.out-code = 'out-zone':U   or
     out-vatp_partsprl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoprl = yes.
  end.
  else do:
    find first in-vatp_doc-attroprl no-lock
      where in-vatp_doc-attroprl.doc-code  = out-vatp_partsprl.out-code
        and in-vatp_doc-attroprl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroprl then do:
      assign
        in-vatp-have-vat-sltoprl = yes.
    end.
    else do:
         in-vatp-have-vat-sltoprl = no.
    end.
  end.
  assign
   price-cli-with-tax-locoprl = out-vatp_partsprl.price-cli
   cli-base-rateoprl          = out-vatp_partsprl.cli-base-rate.
  ASSIGN   road-tax-base-locoprl  = (if out-vatp_partsprl.road-tax-base  = ? then 0 else out-vatp_partsprl.road-tax-base)
           road-tax-rubl-locoprl  = (if out-vatp_partsprl.road-tax-rubl  = ? then 0 else out-vatp_partsprl.road-tax-rubl).
  ASSIGN  transport-base-locoprl = (if out-vatp_partsprl.transport-base = ? then 0 else out-vatp_partsprl.transport-base)
          transport-rubl-locoprl = (if out-vatp_partsprl.transport-rubl = ? then 0 else out-vatp_partsprl.transport-rubl)
          other-base-locoprl     = (if out-vatp_partsprl.other-base     = ? then 0 else out-vatp_partsprl.other-base)
          other-rubl-locoprl     = (if out-vatp_partsprl.other-rubl     = ? then 0 else out-vatp_partsprl.other-rubl)
          vat-pc-locoprl         = (if out-vatp_partsprl.vat-pc         = ? then 0 else out-vatp_partsprl.vat-pc)
          slt-pc-locoprl         = (if out-vatp_partsprl.slt-pc         = ? then 0 else out-vatp_partsprl.slt-pc).
          ASSIGN   slt-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
    ASSIGN   slt-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
  assign
    exch-rate-cli-locoprl = (out-vatp_partsprl.price-rubl - transport-rubl-locoprl - other-rubl-locoprl - road-tax-rubl-locoprl - (if out-vatp_partsprl.vat-type <> 'в т. ч.':U then vat-rubl-locoprl else 0) - (if out-vatp_partsprl.slt-type <> 'в т. ч.':U then slt-rubl-locoprl else 0)) / out-vatp_partsprl.price-cli .
  assign
    slt-cli-locoprl        = slt-rubl-locoprl       / exch-rate-cli-locoprl
    vat-cli-locoprl        = vat-rubl-locoprl       / exch-rate-cli-locoprl
    road-tax-cli-locoprl   = road-tax-rubl-locoprl  / exch-rate-cli-locoprl
    transport-cli-locoprl  = 0
    other-cli-locoprl      = 0
  .
ASSIGN
          price-base-without-tax-locoprl = price-base-with-tax-locoprl - vat-base-locoprl - slt-base-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))
    price-rubl-without-tax-locoprl = price-rubl-with-tax-locoprl - vat-rubl-locoprl - slt-rubl-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))
.
      assign
        varprice-base-consprl = varprice-base-consprl + (price-base-with-tax-locoprl - (if road-tax-base-locoprl = ? then 0 else road-tax-base-locoprl))* out-vatp_partsprl.fact-qnty
        varprice-rubl-consprl = varprice-rubl-consprl + (price-rubl-with-tax-locoprl - (if road-tax-rubl-locoprl = ? then 0 else road-tax-rubl-locoprl))* out-vatp_partsprl.fact-qnty.
      assign
        varis-cons-parts-haveprl = yes
        varcons-qntyprl          = varcons-qntyprl + out-vatp_partsprl.fact-qnty.
    end.
    assign
      varfact-qntyprl = varfact-qntyprl + out-vatp_partsprl.fact-qnty.
  end.
end.
assign
  varprice-base-consprl = varprice-base-consprl / varcons-qntyprl
  varprice-rubl-consprl = varprice-rubl-consprl / varcons-qntyprl.
if varprice-base-consprl = ? then do:
  assign
    varprice-base-consprl = 0.
end.
if varprice-rubl-consprl = ? then do:
  assign
    varprice-rubl-consprl = 0.
end.
assign
    slt-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-base-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-base-saleprl            = vardiscnt-base
  price-base-with-tax-saleprl    = (varprice-base - vardiscnt-base)
    slt-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-rubl-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-rubl-saleprl            = vardiscnt-rubl
  price-rubl-with-tax-saleprl    = (varprice-rubl - vardiscnt-rubl)
  .
if vardoc-type = 'инв':U then do:
  assign
    varfact-qntyprl = vardoc-qnty.
end.
else do:
  assign
    varfact-qntyprl = varfact-qnty.
end.
if varis-cons-parts-haveprl = no then do:
  assign
        vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
        vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc).
end.
else do:
  if vardoc-type = 'инв':U then do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
  else do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-base-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-rubl-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
end.
assign
price-base-without-tax-saleprl = price-base-with-tax-saleprl - vat-base-saleprl - slt-base-saleprl - road-tax-base-saleprl
price-rubl-without-tax-saleprl = price-rubl-with-tax-saleprl - vat-rubl-saleprl - slt-rubl-saleprl - road-tax-rubl-saleprl.
  end.
end procedure.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-crsa :
  define input parameter  p-doc-code       like ub.doc-line.doc-code  no-undo .
  define input parameter  p-artic          like ub.doc-line.artic     no-undo .
  define input parameter  p-prod-type      like ub.doc-line.prod-type no-undo .
  define input parameter  p-prod-code      like ub.doc-line.prod-code no-undo .
  define input  parameter p-curr-r-b       as character no-undo .
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo initial "r-crsa-01: суммы товара в текущих продажных ценах на момент закрытия документа".
  define buffer buf_gds-dtl  for ub.gds-dtl .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_trn-doc  for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info47 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info47 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-gds-dtl-fact-qnty       as decimal   no-undo .
    define variable v-total-gds-dtl-fact-qnty as decimal   no-undo .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> 'инв':U then do:
        if buf_trn-doc.doc-type = 'при':U
        or buf_trn-doc.doc-type = 'возврат':U
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.
      assign
        v-total-gds-dtl-fact-qnty = v-total-gds-dtl-fact-qnty
                                  + v-gds-dtl-fact-qnty
      .
      define variable v-gds-code      as integer   no-undo .
      define variable v-prt-b-code    like ub.bar-code.b-code no-undo .
      define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении кода товара" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  buf_gds-dtl.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара" v-gds-code  skip
          "Код признака" buf_gds-dtl.prt-code skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable parrecid-prl as recid     no-undo .
    define  variable price-rubl-with-tax-sale-prl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale-prl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale-prl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale-prl like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale-prl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale-prl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer-prl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer-prl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale-prl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale-prl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale-prl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale-prl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale-prl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale-prl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale-prl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale-prl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl-prl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl-prl for ub.gds-dtl.
    define buffer out-vatp_parts-prl       for ub.parts.
    define buffer out-vatp_sysconf-prl     for ub.sysconf.
    define buffer out-vatp_doc-line-prl    for ub.doc-line.
    define buffer out-vatp_goods-prl       for ub.goods.
    define buffer out-vatp_trn-doc-prl     for ub.trn-doc.
    define buffer out-vatp_doc-attr-prl    for ub.doc-attr.
    define variable varprice-base-cons-prl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons-prl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type-prl         as   character                           no-undo.
    define variable varfrm-cnsv-prl              as   character                           no-undo.
    define variable varroot-node-prl             as   integer                             no-undo.
    define variable varempty-scale-prl           as   logical                             no-undo.
    define variable varis-cons-parts-have-prl    as   logical                             no-undo.
    define variable varsum-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp-prl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp-prl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp-prl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp-prl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty-prl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty-prl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl-prl        as   logical                             no-undo.
    define variable varcur-prlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-prlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcur-prldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-prldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb-prl               as   character                           no-undo.
    define variable out-vatp-have-vat-slt-prl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco-prl  for ub.trn-doc .
    define buffer   in-vatp-partso-prl    for ub.parts   .
    define buffer   in-vatp-doco-prl      for ub.trn-doc .
    define buffer   in-vatp-goodso-prl    for ub.goods   .
    define buffer   in-vatp-sysconfo-prl  for ub.sysconf .
    define buffer   in-vatp_doc-attro-prl for ub.doc-attr.
    define variable in-vatp-have-vat-slto-prl       as   logical initial yes    no-undo.
    define variable vat-pc-loco-prl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo-prl                  as   character              no-undo.
    define variable slt-pc-loco-prl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo-prl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco-prl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco-prl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco-prl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco-prl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco-prl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco-prl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco-prl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco-prl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco-prl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco-prl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco-prl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco-prl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco-prl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco-prl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco-prl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco-prl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco-prl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco-prl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco-prl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco-prl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco-prl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco-prl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo-prl             as   character              no-undo.
    define variable varinvatp-typeo-prl             as   character              no-undo.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  buf_trn-doc.fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при поиске строки переоценки для бар-кода" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Объект" buf_trn-doc.obj-type buf_trn-doc.obj-code skip
          "Бар-код" v-prt-b-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ? then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Документ" p-doc-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      define variable v-fact-qnty         as decimal   no-undo .
      define variable v-cur-base          as decimal   no-undo .
      define variable v-cur-VAT-base      as decimal   no-undo .
      define variable v-cur-SLT-base      as decimal   no-undo .
      define variable v-cur-road-tax-base as decimal   no-undo .
      define variable v-cur-excise-base   as decimal   no-undo .
      assign
        v-fact-qnty         = v-fact-qnty
                            + v-gds-dtl-fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                               then price-base-with-tax-sale-prl
                               else price-rubl-with-tax-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                               then vat-base-sale-prl
                               else vat-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                               then slt-base-sale-prl
                               else slt-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                               then road-tax-base-sale-prl
                               else road-tax-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                               then excise-base-sale-prl
                               else excise-rubl-sale-prl
                              )
                            * v-gds-dtl-fact-qnty
      .
    end.
    assign
      p-fact-qnty = v-fact-qnty
    .
    define variable v-base-rate                 like ub.curr-accnt.exch-rate no-undo .
    define variable v-base-scale                like ub.curr-accnt.exch-scale no-undo .
  assign
    v-base-rate  = buf_trn-doc.base-rate
    v-base-scale = buf_trn-doc.base-scale
  .
    if p-curr-r-b = 'base':U then do:
      assign
        p-sum-base       = v-cur-base
        p-sum-rubl       = v-cur-base     * v-base-rate / v-base-scale
        p-vat-base       = v-cur-VAT-base
        p-vat-rubl       = v-cur-VAT-base * v-base-rate / v-base-scale
        p-slt-base       = v-cur-SLT-base
        p-slt-rubl       = v-cur-SLT-base * v-base-rate / v-base-scale
        p-road-tax-base  = v-cur-road-tax-base
        p-road-tax-rubl  = v-cur-road-tax-base * v-base-rate / v-base-scale
        p-excise-base    = v-cur-excise-base
        p-excise-rubl    = v-cur-excise-base * v-base-rate / v-base-scale
        p-transport-base = 0
        p-transport-rubl = 0
        p-other-base     = 0
        p-other-rubl     = 0
      .
    end.
    else do:
      assign
        p-sum-base       = v-cur-base     / v-base-rate * v-base-scale
        p-sum-rubl       = v-cur-base
        p-vat-base       = v-cur-VAT-base / v-base-rate * v-base-scale
        p-vat-rubl       = v-cur-VAT-base
        p-slt-base       = v-cur-SLT-base / v-base-rate * v-base-scale
        p-slt-rubl       = v-cur-SLT-base
        p-road-tax-base  = v-cur-road-tax-base / v-base-rate * v-base-scale
        p-road-tax-rubl  = v-cur-road-tax-base
        p-excise-base    = v-cur-excise-base / v-base-rate * v-base-scale
        p-excise-rubl    = v-cur-excise-base
        p-transport-base = 0
        p-transport-rubl = 0
        p-other-base     = 0
        p-other-rubl     = 0
      .
    end.
  end.
end procedure.
define variable vss-include-info50 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure r-sale :
  define input parameter  p-doc-code          like ub.doc-line.doc-code          no-undo .
  define input parameter  p-artic             like ub.doc-line.artic             no-undo .
  define input parameter  p-prod-type         like ub.doc-line.prod-type         no-undo .
  define input parameter  p-prod-code         like ub.doc-line.prod-code         no-undo .
  define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
  define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
  define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
  define output parameter p-sum-base          like ub.ot-line.sum-base        no-undo .
  define output parameter p-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
  define output parameter p-vat-base          like ub.ot-line.vat-base        no-undo .
  define output parameter p-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
  define output parameter p-slt-base          like ub.ot-line.slt-base        no-undo .
  define output parameter p-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
  define output parameter p-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
  define output parameter p-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
  define output parameter p-transport-base    like ub.ot-line.transport-base  no-undo .
  define output parameter p-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
  define output parameter p-other-base        like ub.ot-line.other-base      no-undo .
  define output parameter p-other-rubl        like ub.ot-line.other-rubl      no-undo .
  define output parameter p-excise-base       like ub.ot-line.excise-base     no-undo .
  define output parameter p-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
  define variable vss-description as character no-undo initial "r-sale-01: обработка продажных цен товара".
  do
  on error undo, return error
  :
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define buffer buf_gds-dtl  for ub.gds-dtl .
    define buffer buf_goods    for ub.goods .
    define buffer buf_trn-doc  for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info51 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_doc-line.doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info51 skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
        if buf_trn-doc.doc-type <> 'инв':U
        then do:
            if buf_trn-doc.doc-type = 'при':U
            or buf_trn-doc.doc-type = 'возврат':U
            then do:
                assign
                    v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
                .
            end.
            else do:
                assign
                    v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
                .
            end.
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
            .
        end.
        if v-gds-dtl-fact-qnty <> 0
        then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
            ASSIGN
                p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
                p-sum-base            = p-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
                p-sum-rubl            = p-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
                p-vat-base            = p-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
                p-vat-rubl            = p-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
                p-slt-base            = p-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
                p-slt-rubl            = p-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
                p-road-tax-base       = p-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
                p-road-tax-rubl       = p-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
                p-excise-base         = p-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
                p-excise-rubl         = p-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
                p-other-base          = p-other-base    + discnt-base-sale          * v-gds-dtl-fact-qnty
                p-other-rubl          = p-other-rubl    + discnt-rubl-sale          * v-gds-dtl-fact-qnty
            .
        end.
    end.
    assign
        p-transport-base      = 0
        p-transport-rubl      = 0
        p-vat-pc              = buf_doc-line.vat-pc
        p-slt-pc              = buf_doc-line.slt-pc
    .
  end.
  if p-fact-qnty      = ?
  or p-vat-pc         = ?
  or p-slt-pc         = ?
  or p-sum-base       = ?
  or p-sum-rubl       = ?
  or p-vat-base       = ?
  or p-vat-rubl       = ?
  or p-slt-base       = ?
  or p-slt-rubl       = ?
  or p-road-tax-base  = ?
  or p-road-tax-rubl  = ?
  or p-transport-base = ?
  or p-transport-rubl = ?
  or p-other-base     = ?
  or p-other-rubl     = ?
  or p-excise-base    = ?
  or p-excise-rubl    = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info51 skip
      "Получены неопределенные значения" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "fact-qnty     " p-fact-qnty      skip
      "vat-pc        " p-vat-pc         skip
      "slt-pc        " p-slt-pc         skip
      "sum-base      " p-sum-base       skip
      "sum-rubl      " p-sum-rubl       skip
      "vat-base      " p-vat-base       skip
      "vat-rubl      " p-vat-rubl       skip
      "slt-base      " p-slt-base       skip
      "slt-rubl      " p-slt-rubl       skip
      "road-tax-base " p-road-tax-base  skip
      "road-tax-rubl " p-road-tax-rubl  skip
      "transport-base" p-transport-base skip
      "transport-rubl" p-transport-rubl skip
      "other-base    " p-other-base     skip
      "other-rubl    " p-other-rubl     skip
      "excise-base   " p-excise-base    skip
      "excise-rubl   " p-excise-rubl    skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure chkzero :
  define input  parameter p-doc-code like ub.trn-doc.doc-code no-undo .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-artic     like ub.doc-line.artic     no-undo .
  define variable v-prod-type like ub.doc-line.prod-type no-undo .
  define variable v-prod-code like ub.doc-line.prod-code no-undo .
  define variable v-fact-qnty      as decimal   no-undo .
  define variable v-vat-pc         as decimal   no-undo .
  define variable v-slt-pc         as decimal   no-undo .
  define variable v-sum-base       as decimal   no-undo .
  define variable v-sum-rubl       as decimal   no-undo .
  define variable v-vat-base       as decimal   no-undo .
  define variable v-vat-rubl       as decimal   no-undo .
  define variable v-slt-base       as decimal   no-undo .
  define variable v-slt-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-excise-base    as decimal   no-undo .
  define variable v-excise-rubl    as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_trn-doc.doc-type <> 'инв':U
    then do:
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = p-doc-code
          and buf_doc-line.fact-qnty = 0
      on error undo, return error
      :
        assign
          v-artic     = buf_doc-line.artic
          v-prod-type = buf_doc-line.prod-type
          v-prod-code = buf_doc-line.prod-code
        .
        run r-sale in this-procedure
          (input  p-doc-code
          ,input  v-artic
          ,input  v-prod-type
          ,input  v-prod-code
          ,output v-fact-qnty
          ,output v-vat-pc
          ,output v-slt-pc
          ,output v-sum-base
          ,output v-sum-rubl
          ,output v-vat-base
          ,output v-vat-rubl
          ,output v-slt-base
          ,output v-slt-rubl
          ,output v-road-tax-base
          ,output v-road-tax-rubl
          ,output v-transport-base
          ,output v-transport-rubl
          ,output v-other-base
          ,output v-other-rubl
          ,output v-excise-base
          ,output v-excise-rubl
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете сумм по документу" skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-vat-base       <> 0
        or v-vat-rubl       <> 0
        or v-slt-base       <> 0
        or v-slt-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            "При нулевом количестве по строке получены ненулевые суммы" skip
            "Тип суммы: Цены по документу" skip
            "v-sum-base"        v-sum-base       skip
            "v-sum-rubl"        v-sum-rubl       skip
            "v-vat-base"        v-vat-base       skip
            "v-vat-rubl"        v-vat-rubl       skip
            "v-slt-base"        v-slt-base       skip
            "v-slt-rubl"        v-slt-rubl       skip
            "v-road-tax-base"   v-road-tax-base  skip
            "v-road-tax-rubl"   v-road-tax-rubl  skip
            "v-excise-base"     v-excise-base    skip
            "v-excise-rubl"     v-excise-rubl    skip
            "v-transport-base"  v-transport-base skip
            "v-transport-rubl"  v-transport-rubl skip
            "v-other-base"      v-other-base     skip
            "v-other-rubl"      v-other-rubl     skip
            view-as alert-box error .
          undo, return error .
        end.
        define variable v-curr-r-b as character no-undo .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
        run r-crsa in this-procedure
          (input  p-doc-code
          ,input  v-artic
          ,input  v-prod-type
          ,input  v-prod-code
          ,input  v-curr-r-b
          ,output v-fact-qnty
          ,output v-vat-pc
          ,output v-slt-pc
          ,output v-sum-base
          ,output v-sum-rubl
          ,output v-vat-base
          ,output v-vat-rubl
          ,output v-slt-base
          ,output v-slt-rubl
          ,output v-road-tax-base
          ,output v-road-tax-rubl
          ,output v-transport-base
          ,output v-transport-rubl
          ,output v-other-base
          ,output v-other-rubl
          ,output v-excise-base
          ,output v-excise-rubl
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при расчете сумм по документу" skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-sum-base       <> 0
        or v-sum-rubl       <> 0
        or v-vat-base       <> 0
        or v-vat-rubl       <> 0
        or v-slt-base       <> 0
        or v-slt-rubl       <> 0
        or v-road-tax-base  <> 0
        or v-road-tax-rubl  <> 0
        or v-excise-base    <> 0
        or v-excise-rubl    <> 0
        or v-transport-base <> 0
        or v-transport-rubl <> 0
        or v-other-base     <> 0
        or v-other-rubl     <> 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Документ" p-doc-code skip
            "Артикул" v-artic v-prod-type v-prod-code skip
            "При нулевом количестве по строке получены ненулевые суммы" skip
            "Тип суммы: Текущие продажные цены" skip
            "v-sum-base"        v-sum-base       skip
            "v-sum-rubl"        v-sum-rubl       skip
            "v-vat-base"        v-vat-base       skip
            "v-vat-rubl"        v-vat-rubl       skip
            "v-slt-base"        v-slt-base       skip
            "v-slt-rubl"        v-slt-rubl       skip
            "v-road-tax-base"   v-road-tax-base  skip
            "v-road-tax-rubl"   v-road-tax-rubl  skip
            "v-excise-base"     v-excise-base    skip
            "v-excise-rubl"     v-excise-rubl    skip
            "v-transport-base"  v-transport-base skip
            "v-transport-rubl"  v-transport-rubl skip
            "v-other-base"      v-other-base     skip
            "v-other-rubl"      v-other-rubl     skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$":U .
procedure lggdstrn :
  define input  parameter parext-doc-type         like ub.trn-doc.ext-doc-type         no-undo.
  define input  parameter pardoc-office           as   logical                         no-undo.
  define input  parameter parpurch-code           like ub.trn-doc.purch-code           no-undo.
  define input  parameter pargds-office           as   logical                         no-undo.
  define input  parameter pargds-pl-reserv        as   logical                         no-undo.
  define input  parameter pargds-is-twounit       as   logical                         no-undo.
  define input  parameter pargds-is-serial        as   logical                         no-undo.
  define input  parameter pargds-artic            like ub.goods.artic                  no-undo.
  define input  parameter pargds-prod-type        like ub.goods.prod-type              no-undo.
  define input  parameter pargds-prod-code        like ub.goods.prod-code              no-undo.
  define input  parameter pardoc-code             like ub.trn-doc.doc-code             no-undo.
  define output parameter pargds-is-legal         as   logical                         no-undo.
  define variable is-hold as logical no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  pardoc-code
  ,output is-hold
  ) no-error .
    if error-status :error or is-hold = ? then do: assign is-hold = no. end.
    assign
      pargds-is-legal = no
    .
    if  pargds-office
    and parext-doc-type <> 'ee':U
    and parext-doc-type <> 'es':U
    and parext-doc-type <> 're':U
    and parext-doc-type <> 'rs':U
    and parext-doc-type <> 'wm':U
    and parext-doc-type <> 'we':U
    then do:
      return error substitute( 'Услуга &2 &3 &4 недопустима в данном типе документа (&1 "&5").'
                             , entry( lookup( parext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
                             , pargds-artic
                             , pargds-prod-type
                             , pargds-prod-code
                             , pardoc-code      ).
    end.
    if parext-doc-type <> 'ee':U then do:
    if pardoc-office <> pargds-office
    then do:
      if pardoc-office = yes
      then do:
        return error substitute( 'В документе "&1" уже есть услуги. Добавление товаров в документ недопустимо.'
                               , pardoc-code ).
      end.
      else do:
        return error substitute( 'В документе "&1" уже есть товары. Добавление услуг в документ недопустимо.'
                               , pardoc-code ).
      end.
      end.
    end.
    if pargds-pl-reserv = yes
    then do:
      if parpurch-code = 3 then do:
        return error substitute( 'Товар &1 &2 &3 резервируется по складским местам. '
                               + 'Он не может быть принят на ответственное хранение ("&4").'
                               , pargds-artic
                               , pargds-prod-type
                               , pargds-prod-code
                               , pardoc-code      ).
      end.
    end.
    if pargds-is-serial = yes
    then do:
      if is-hold = yes
      then do:
        return error substitute( 'Серийный товар &1 &2 &3 не может быть в документе межфирменного перемещения "&4".'
                               , pargds-artic
                               , pargds-prod-type
                               , pargds-prod-code
                               , pardoc-code      ).
      end.
    end.
    if pargds-is-twounit = yes
    then do:
      if is-hold = yes
      then do:
        return error substitute( '&1 &2 &3 : Товар, измеряющийся в двух единицах измерения, не может быть '
                               + 'в документе межфирменного перемещения "&4".'
                               , pargds-artic
                               , pargds-prod-type
                               , pargds-prod-code
                               , pardoc-code      ).
      end.
    end.
    assign
      pargds-is-legal = yes
    .
  end.
end procedure.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure clientsh_write-clients-proc  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-source-type like ub.c-cli-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-cli-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
  do
  on error undo, return error
  :
    if not available buf_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен контрагент" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      define variable v-subject as character no-undo .
      case buf_clients.obj-type:
        when 'орг':U then v-subject =  'firm':U.
        when 'чел':U then v-subject =  'person':U.
        when 'маг':U then v-subject =  'shop':U.
        when 'скл':U then v-subject =  'store':U.
      end case.
      v-send = integer('0':U).
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  v-subject
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-clients.
    buffer-copy buf_clients to buf_c-clients
    assign
    buf_c-clients.obj-code           = buf_clients.obj-code
    buf_c-clients.obj-type           = buf_clients.obj-type
    buf_c-clients.chip-num           = next-value (s-cli-chip, ub)
    buf_c-clients.corr-time          = v-time
    buf_c-clients.corr-user-db-num   = g#db-num
    buf_c-clients.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                              then (chr(4) +  'ВС':U)
                                              else g#userid)
                                        )
    buf_c-clients.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-clients to buf_c-cli-hist
    assign
    buf_c-cli-hist.action =  integer('2':U)
    buf_c-cli-hist.subject = 'clients':U
    buf_c-cli-hist.host-code = (if buf_clients.obj-type = 'орг':U
                                and
                                can-find(first ub.sysconf no-lock where
                                                  ub.sysconf.host-code = buf_clients.obj-code)
                                then buf_clients.obj-code
                                else 0)
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = p-source-type
    buf_c-cli-hist.source-ref = p-source-ref
    .
  end.
end procedure.
define new global shared variable g#libtfarh as handle no-undo .
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable num_rec          as integer   no-undo .
define variable num_gds          as integer   no-undo .
define variable v-start-time     as int64     no-undo .
define variable v-current-time   as character no-undo .
define variable v-current-action as character no-undo .
define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable v-price-base               like ub.doc-line.price-base no-undo.
define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable p-error as logical   no-undo .
define variable v-message as character no-undo .
define variable v-event-code as character no-undo .
define variable par-is-pharm as character no-undo .
define variable v-varsum     as decimal no-undo .
define variable v-is-bge as character no-undo.
define variable v-bge-incr-last-shift-date as character no-undo.
define variable v-bge-incr-last-shift-num as character no-undo.
define variable v-type as character no-undo.
define variable loc#in-ov as logical no-undo.
define variable v-not-close-news as logical no-undo .
define variable v-document-date        as date      no-undo .
define variable l-is-custm             as logical   no-undo initial false .
define variable v-is-hold              as logical   no-undo .
define variable v-need-send            as logical   no-undo initial false .
define variable v-description-doc-type as character no-undo .
define variable loc#obj-active  as logical no-undo.
define variable loc#side-active as logical no-undo.
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-min-ass-exist  as logical   no-undo init false .
define variable v-sale-auto                as   logical                no-undo.
define variable v-trdcattr-value           as   character              no-undo .
define variable v-trdcattr-type            as   character              no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-new-trn-doc       as logical   no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define buffer buf_goods       for ub.goods .
define buffer buf_es_trn-doc  for ub.trn-doc.
define buffer buf_doc-line    for ub.doc-line .
define buffer buf_inv-line    for ub.inv-line .
define buffer buf_gds-dtl     for ub.gds-dtl .
define buffer buf_parts       for ub.parts .
define buffer buf-obj_clients for ub.clients .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_previous-shift-obj for ub.shift-obj.
assign
  v-description-doc-type = ub.trn-doc.doc-type
                         + " " + string(ub.trn-doc.internal, "внут/внеш")
.
def frame a
  ub.trn-doc.doc-code                           label "Документ"             skip
  v-description-doc-type                        label "Тип документа"        skip
  v-current-action       format "x(40)":U    no-label                        skip
  num_rec                format ">>>>>>>9":U    label "Обработано артикулов" skip
  buf_doc-line.artic                            label "Текущий артикул"      skip
  num_gds                format ">>>>>>>9":U    label "Обработано признаков" skip
  v-current-time         format "x(8)":U        label "Время"                skip
with view-as dialog-box side-labels three-d
     title "Обработка документа"
  .
MAIN-BLOCK:
do transaction
on error   undo main-block, return error substitute('trn-docw error main-block,&1', return-value )
on end-key undo main-block, return error substitute('trn-docw end-key main-block,&1', return-value )
:
  assign
    v-new-trn-doc = new(ub.trn-doc)
  .
do :
  if ub.trn-doc.ext-doc-type = ""
  or ub.trn-doc.ext-doc-type = ?
  then do:
    v-message = "Не задан расширенный тип документа" .
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      v-message skip
      "Документ" ub.trn-doc.doc-code skip
      "Тип документа" ub.trn-doc.ext-doc-type skip
      "doc-type" ub.trn-doc.doc-type skip
      "internal" ub.trn-doc.internal skip
      "discnt-type" ub.trn-doc.discnt-type skip
      "ret-supp" ub.trn-doc.ret-supp skip
      "pay-code" ub.trn-doc.pay-code skip
      view-as alert-box error .
    undo main-block, return error v-message .
  end.
  if v-new-trn-doc = false
  and ub.trn-doc.ext-doc-type <> old-doc.ext-doc-type
  and not (old-doc.ext-doc-type = 'iv':U or ub.trn-doc.ext-doc-type = 'iv':U)
  then do:
    v-message = "Расширенный тип документа нельзя менять" .
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      v-message skip
      "Документ" ub.trn-doc.doc-code skip
      "Новый тип документа" ub.trn-doc.ext-doc-type skip
      "Старый тип документа" old-doc.ext-doc-type skip
      "doc-type" ub.trn-doc.doc-type skip
      "internal" ub.trn-doc.internal skip
      "discnt-type" ub.trn-doc.discnt-type skip
      "ret-supp" ub.trn-doc.ret-supp skip
      "pay-code" ub.trn-doc.pay-code skip
      view-as alert-box error .
    undo, return error v-message .
  end.
  else do:
    if old-doc.ext-doc-type <> ub.trn-doc.ext-doc-type then do:
      for each buf_doc-line exclusive-lock where
               buf_doc-line.doc-code = ub.trn-doc.doc-code
      :
        buf_doc-line.ext-doc-type = ub.trn-doc.ext-doc-type.
      end.
    end.
  end.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chkextdt in g#library
  (buffer ub.trn-doc
  ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при проверке типа документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    if g#news = false and g#esys = false and g#auto = false then
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
end .
  run init-local-vars in this-procedure no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при инициализации глобальных переменных.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    if g#news = false and g#esys = false and g#auto = false then
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
  define variable custvalue     as character initial ? no-undo.
  define variable custtype      as character initial ? no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output custvalue
  ,output custtype
  ) no-error .
  if error-status :error then do:
  end.
  else do:
    assign
      l-is-custm = can-do("yes,true", custvalue)
    .
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  ub.trn-doc.host-code
  ,input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-pharm
  ,output par-type
  ) no-error .
  .
if par-is-pharm <> "yes"  then par-is-pharm = "no" .
else do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
define variable v-o-pharm    as character no-undo .
define variable v-o-var-type as character no-undo .
  run clntattr-value in this-procedure
    ( input   ub.trn-doc.obj-type ,
      input   ub.trn-doc.obj-code ,
      input  'pharm':U,
      output v-o-pharm    ,
      output v-o-var-type )
     no-error .
  if v-o-pharm <> "yes":u or error-status :error then do:
     par-is-pharm = "no"  .
  end.
end.
  run trg/chkdocnm.p
    (input ub.trn-doc.doc-code
    ,input 'trn-doc':U
    ,input recid(ub.trn-doc)
    ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при проверке уникальности кода документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    if g#news = false and g#esys = false and g#auto = false then
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
  if v-new-trn-doc = true then do:
   assign
      ub.trn-doc.real-date-create = today
      ub.trn-doc.real-time-create = time
   .
  end.
  find first ub.clients no-lock
    where ub.clients.obj-type = ub.trn-doc.cli-type
      and ub.clients.obj-code = ub.trn-doc.cli-code
    no-error .
  if  v-new-trn-doc = true
  then do:
    define variable v-vid-action  as integer    no-undo.
    define variable v-vid-param   as longchar   no-undo.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
    v-vid-action = 55 .
    v-vid-param = "Initiator=" + v-initiator + chr(4) +
                  "SHOP_NUM=" + string(ub.trn-doc.obj-code) + chr(4) +
                  "DocNum=" + string(ub.trn-doc.doc-code) + chr(4) +
                  "DocType=" + string(ub.trn-doc.doc-type) + chr(4) +
                  "RESULT=0" + chr(4) +
                  "Description=".
    run trg/userlog.p (
          input 'create':U
        , input 'trn-doc':U
        , input ( buffer ub.trn-doc :handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.
  end.
  if not available ub.clients
  then do:
    if  v-new-trn-doc = true
    and g#news = false
    and ub.trn-doc.cli-type = ?
    and ub.trn-doc.cli-code = ?
    then do:
      return .
    end.
    else do:
      if g#news = false and g#esys = false and g#auto = false then
      message
        vss-workfile vss-revision vss-description skip
        "Указан неправильный контрагент" skip
        "Документ" ub.trn-doc.doc-code skip
        "Контрагент" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
        "Документ новый" v-new-trn-doc skip
        "Новости" g#news skip
        view-as alert-box error .
      return error return-value .
    end.
  end.
  assign
    ub.trn-doc.cli-name = ub.clients.obj-name
  .
  define buffer trn-doc_clients for ub.clients .
  find first trn-doc_clients no-lock
    where trn-doc_clients.obj-type = ub.trn-doc.obj-type
      and trn-doc_clients.obj-code = ub.trn-doc.obj-code
    no-error .
  if not available trn-doc_clients
  then do:
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      "Не найден объект" skip
      "Документ" ub.trn-doc.doc-type skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if trn-doc_clients.db-num = g#db-num
  then do:
    assign
      loc#side-active = loc#obj-active
    .
  end.
  else do:
    assign
      loc#side-active = not loc#obj-active
    .
  end.
  if not g#news or v-not-close-news
  then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.trn-doc.user-db-num
  ,output ub.trn-doc.user-name
  ,output ub.trn-doc.sys-date
  ,output ub.trn-doc.sys-time
  ,output ub.trn-doc.sys-time-int
  )  .
    if old-doc.fact-order > 0 and old-doc.fact-date <> trn-doc.fact-date then
    do:
      run factord in this-procedure
        (input  ub.trn-doc.fact-date
        ,input  ub.trn-doc.fact-time
        ,input  ub.trn-doc.fact-num
        ,input  ub.trn-doc.shift-date
        ,input  ub.trn-doc.shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-date"               ub.trn-doc.fact-date   skip
          "fact-time"               ub.trn-doc.fact-time   skip
          "fact-num"                ub.trn-doc.fact-num    skip
          "shift-date"              ub.trn-doc.shift-date  skip
          "shift-num"               ub.trn-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        ub.trn-doc.fact-order = v-fact-order
      .
    end.
  end.
  if ub.trn-doc.status_ = 'касс':U
  then do:
    return .
  end.
  if  ub.trn-doc.status_ = old-doc.status_
  and ub.trn-doc.flag_   = old-doc.flag_
  then do:
    if ub.trn-doc.status_ = 'факт':U and
      (ub.trn-doc.buyer-fo-date <> old-doc.buyer-fo-date  or
       ub.trn-doc.cr-fo-buyer   <> old-doc.cr-fo-buyer    or
       ub.trn-doc.need-buyer    <> old-doc.need-buyer    ) then  do:
       run trn-doc-cmd-chance-h-fo ( input ub.trn-doc.doc-code ) .
    end.
    if ub.trn-doc.status_ = 'факт':U and
      (ub.trn-doc.factur-date    <> old-doc.factur-date  or
       ub.trn-doc.cr-factur      <> old-doc.cr-factur    or
       ub.trn-doc.need-factur    <> old-doc.need-factur   ) then  do:
       run trn-doc-cmd-chance-h-factur ( input ub.trn-doc.doc-code ) .
    end.
    return .
  end.
  define variable l-need-check-inv as logical no-undo initial false .
  define variable v-old-can-edit-inv-on as character no-undo .
  if available old-doc
  then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnat in g#library
  (input  old-doc.doc-type
  ,input  old-doc.internal
  ,input  old-doc.discnt-type
  ,input  old-doc.status_
  ,input  old-doc.flag_
  ,input  old-doc.ext-doc-type
  ,input  'can-change-status-inv-on=request'
  ,output v-old-can-edit-inv-on
  ) no-error .
    if error-status :error
    then do:
      if g#news = false and g#esys = false and g#auto = false then
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признак складского документа (old-doc)" skip
        "Документ" ub.trn-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  else do:
    assign
      v-old-can-edit-inv-on = "true":u
    .
  end.
  define variable v-new-can-edit-inv-on as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnat in g#library
  (input  ub.trn-doc.doc-type
  ,input  ub.trn-doc.internal
  ,input  ub.trn-doc.discnt-type
  ,input  ub.trn-doc.status_
  ,input  ub.trn-doc.flag_
  ,input  ub.trn-doc.ext-doc-type
  ,input  'can-change-status-inv-on=request'
  ,output v-new-can-edit-inv-on
  ) no-error .
  if error-status :error
  then do:
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно запросить признак складского документа (trn-doc)" skip
      "Документ" ub.trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  if not g#news
  then do:
    if v-new-can-edit-inv-on <> "true":u
    or v-old-can-edit-inv-on <> "true":u
    or ub.trn-doc.status_ = 'факт':U
    or (ub.trn-doc.doc-type    = 'инв':U
        and ( ub.trn-doc.status_ = 'разрешен':U
              or ub.trn-doc.status_ = 'нередакт':U
             )
        and ub.trn-doc.flag_   = true
        )
    then do:
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = ub.trn-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'invMultDevice' and ub.inv-doc-attr.attr-value = string(true) no-error .
      if not available (ub.inv-doc-attr) then l-need-check-inv = true .
    end.
    if not new ub.trn-doc
    and old-doc.doc-type     = 'инв':U
    and
       (   ( old-doc.status_ = 'разрешен':U or old-doc.status_ = 'нередакт':U )
       and old-doc.flag_        = true
       and old-doc.ext-doc-type = 'vt':U or
           old-doc.status_      = 'накл':U
       and old-doc.flag_        = false
       and old-doc.ext-doc-type = 'ap':U or
           old-doc.status_      = 'накл':U
       and old-doc.flag_        = false
       and old-doc.ext-doc-type = 'vp':U
       )
    then do:
      assign
        l-need-check-inv = false
      .
    end.
  end.
  if  not new ub.trn-doc
  and old-doc.status_    = 'факт':U
  and ub.trn-doc.status_ <> 'факт':U
  then do:
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      "Изменение статуса документа невозможно" skip
      "Документ" ub.trn-doc.doc-code skip
      "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
      "Документ закрыт до статуса" 'факт':U skip
      "Нельзя изменить статус документа на" ub.trn-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.
  define buffer buf_sale-doc for ub.sale-doc.
  if not g#news
  and ub.trn-doc.out-code <> '':U
  and LOOKUP(ub.trn-doc.ext-doc-type, 'we,we,we,we,ee':U) > 0 then do:
    find first buf_sale-doc no-lock  where
             buf_sale-doc.doc-code = ub.trn-doc.doc-code
         and buf_sale-doc.inkas-code = ub.trn-doc.out-code no-error .
    if available buf_sale-doc
    and buf_sale-doc.order > 0 then do:
      v-sale-auto = yes.
    end.
  end.
  if ub.trn-doc.status_ = 'факт':U
  then do:
    if  ub.trn-doc.fact-num = 0
    and
        ( ub.trn-doc.ext-doc-type = 'es':U
         or ub.trn-doc.ext-doc-type = 'rs':U
        )
    and ub.trn-doc.obj-type <> 'маг':U
    then do:
      if g#news = false and g#esys = false and g#auto = false then
      message
        vss-workfile vss-revision vss-description skip
        "Продажа через магазин может быть закрыта только на объекте типа магазин" skip
        "Документ" ub.trn-doc.doc-code skip
        "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
        view-as alert-box error .
      undo main-block, return error return-value .
    end.
    if not g#news and not g#esys
    then do:
      if ub.trn-doc.fact-date = ? and ub.trn-doc.ext-doc-type = 'eo':U then do :
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output ub.trn-doc.fact-date
  )  .
      end.
      run gbl/chk-date.p
        (input ub.trn-doc.obj-type
        ,input ub.trn-doc.obj-code
        ,input ub.trn-doc.fact-date
        ,input ub.trn-doc.fact-time
        ,input ub.trn-doc.shift-date
        ,input ub.trn-doc.shift-num
        ,input yes
        ) no-error .
      if error-status :error
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при установке дат, времен, смен в документе (trn-doc)." skip
            "Документ" ub.trn-doc.doc-code skip
            "fact-date"  ub.trn-doc.fact-date  skip
            "fact-time"  ub.trn-doc.fact-time  skip
            "shift-date" ub.trn-doc.shift-date skip
            "shift-num"  ub.trn-doc.shift-num  skip
          error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
        undo main-block, return error return-value .
      end.
    end.
    assign
      v-document-date = ub.trn-doc.fact-date
    .
    if v-document-date = ?
    then do:
      assign
        v-message = substitute( "&1. Не задана фактическая дата документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
  else do:
    assign
      v-document-date = ?
    .
  end.
  if ub.trn-doc.status_ = 'факт':U and not g#news
  then do:
if (valid-handle(g#libtfarh) <> true) then do:   run str/libtfarh.p persistent no-error .   if error-status :error or (valid-handle(g#libtfarh) <> true) then do:     message       "Error starting libtfarh.p" skip       g#libtfarh skip       g#libtfarh :type skip       g#libtfarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libtfarh_latrncnt in g#libtfarh
(input  ub.trn-doc.doc-code
) no-error.
    if error-status :error then do:
      return error substitute ("&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2)).
    end.
  end.
  if ub.trn-doc.status_ = 'факт':U
  then do:
    if g#news
    then do:
      if ub.trn-doc.fact-num = ?
      or ub.trn-doc.fact-num = 0
      then do:
        assign
          v-message = substitute( "&1. fact-num не задан в складском документе.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
      if ub.trn-doc.fact-order = ?
      or ub.trn-doc.fact-order = 0
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "fact-order не задан в складском документе" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-order" ub.trn-doc.fact-order skip
          view-as alert-box error .
        undo main-block, return error return-value .
      end.
    end.
    if not g#news or v-not-close-news
    then do:
      if ub.trn-doc.fact-num > 0
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-num" ub.trn-doc.fact-num skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if ub.trn-doc.fact-order > 0
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-order" ub.trn-doc.fact-order skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        ub.trn-doc.fact-num = next-value (s-trn-fact, ub)
      .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "Документ" ub.trn-doc.doc-code skip
          "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error return-value .
      end.
      run factord in this-procedure
        (input  ub.trn-doc.fact-date
        ,input  ub.trn-doc.fact-time
        ,input  ub.trn-doc.fact-num
        ,input  ub.trn-doc.shift-date
        ,input  ub.trn-doc.shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-date"               ub.trn-doc.fact-date   skip
          "fact-time"               ub.trn-doc.fact-time   skip
          "fact-num"                ub.trn-doc.fact-num    skip
          "shift-date"              ub.trn-doc.shift-date  skip
          "shift-num"               ub.trn-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        ub.trn-doc.fact-order = v-fact-order
      .
    end.
  end.
  if ub.trn-doc.status_ = 'запрос':U
  then do:
    run process-inquiry in this-procedure no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при обработке документа запроса.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    return .
  end.
  run trg/lock-gds.p
    (input ub.trn-doc.doc-code
    ,input l-need-check-inv
    ,input no
    ,input (if ub.trn-doc.is-back-date = yes
            then 0
            else ub.trn-doc.fact-order)
    ,input (if ub.trn-doc.is-back-date = yes
            then 0
            else ub.trn-doc.fact-order)
    ,input (ub.trn-doc.status_ = 'факт':U)
    ,input g#news
    ) no-error .
  if error-status :error
  then do:
    assign
      v-message = substitute( "&1. Не удалось наложить блокировку на все товары принадлежащие документу.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    if g#news = false and g#esys = false and g#auto = false then
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
  if  ub.trn-doc.is-back-date
  and ub.trn-doc.status_ = 'факт':U
  and not g#news
  then do:
    run check-close-back-date in this-procedure no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Недопустимо закрытие данного документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
  if  ub.trn-doc.doc-type = 'инв':U
  and not g#news
  then do:
    define variable l-old-inv-on as logical no-undo init false .
    define variable l-new-inv-on as logical no-undo init false .
    if  ( old-doc.status_    = 'разрешен':U
          or old-doc.status_ = 'нередакт':U
        )
    and old-doc.flag_        = true
    and old-doc.ext-doc-type = 'vt':U
    then do:
      assign
        l-old-inv-on = true
      .
    end.
    if  old-doc.status_      = 'накл':U
    and old-doc.flag_        = false
    and old-doc.ext-doc-type = 'ap':U
    then do:
      assign
        l-old-inv-on = true
      .
    end.
    if  old-doc.status_      = 'накл':U
    and old-doc.flag_        = false
    and old-doc.ext-doc-type = 'vp':U
    then do:
      assign
        l-old-inv-on = true
      .
    end.
    if  ( ub.trn-doc.status_    = 'разрешен':U
          or ub.trn-doc.status_ = 'нередакт':U
        )
    and ub.trn-doc.flag_        = true
    and ub.trn-doc.ext-doc-type = 'vt':U
    then do:
      assign
        l-new-inv-on = true
      .
    end.
    if l-new-inv-on <> l-old-inv-on
    then do:
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = ub.trn-doc.doc-code
      on error undo main-block, return error return-value
      :
        define variable l-inv-on as logical no-undo .
        define variable v-inv-on-attr as character no-undo .
        assign
          v-inv-on-attr = "inv-on=" + (if l-new-inv-on then "true" else "false")
        .
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = ub.trn-doc.doc-code and
          ub.inv-doc-attr.attr-code = "invMultDevice" and
          ub.inv-doc-attr.attr-value = string(true) no-error .
        if available(ub.inv-doc-attr) then return .
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  v-inv-on-attr
  ,output l-inv-on
  ) no-error .
        if error-status :error
        then do:
          if g#news = false and g#esys = false and g#auto = false then
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка установки атрибута товара на объекте" skip
            "Документ" ub.trn-doc.doc-code skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "l-new-inv-on" l-new-inv-on skip
            view-as alert-box error .
          undo main-block, return error return-value .
        end.
      end.
    end.
  end.
  if  ub.trn-doc.status_ = 'разрешен':U
  and ub.trn-doc.flag_   = no
  then do:
    return .
  end.
  assign
    v-start-time = etime
  .
  assign
    v-current-action = "Обработка товара."
  .
  view frame a.
  display
    ub.trn-doc.doc-code
    v-description-doc-type
    with frame a.
  define variable v-host-code like ub.trn-doc.host-code no-undo .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      "Ошика при определении кода фирмы для объекта" skip
      "Документ" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.
  if ub.trn-doc.host-code <> v-host-code
  then do:
    if g#news = false and g#esys = false and g#auto = false then
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Документ" ub.trn-doc.doc-code skip
      "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
      "Объект"  ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Фирма"   ub.trn-doc.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.
  if not g#news or v-not-close-news
  then do:
    assign
      ub.trn-doc.ov        = no
    .
    if ub.trn-doc.status_ = 'разрешен':U
      or ub.trn-doc.status_ = 'нередакт':U
    then do:
      assign
        ub.trn-doc.creid = g#userid
      .
    end.
    if ub.trn-doc.creid = ""
    then do:
      assign
        ub.trn-doc.creid = g#userid
      .
    end.
  end.
  run show-action in this-procedure
    (input "Обновляем суммы по документу"
    ).
  run update-doc-sum in this-procedure
    (input ub.trn-doc.doc-code
    ,input ub.trn-doc.fact-order
    ) no-error .
  if error-status :error
  then do:
    assign
      v-message = substitute( "&1. Ошибка при обработке сумм по документу.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    if g#news = false and g#esys = false and g#auto = false then
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
  run show-action in this-procedure
    (input "Обработка строк документа"
    ).
  for each buf_doc-line exclusive-lock
    where buf_doc-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error return-value
  :
    run process-line in this-procedure no-error .
    if error-status :error
    then do:
      if g#news = false and g#esys = false and g#auto = false then
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error return-value .
    end.
  end.
  if  not g#news
  and ub.trn-doc.status_ = 'факт':U
  then do:
    run show-action in this-procedure
      (input "Создание атрибутов партий"
      ).
    run trg/prtatrcr.p
      (input ub.trn-doc.doc-code
      ,input false
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при создании атрибутов партий.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
  if  ub.trn-doc.status_  = 'факт':U
  and lookup(ub.trn-doc.doc-type, 'рас,при':U) > 0
  and ub.trn-doc.internal = yes
  and ub.trn-doc.discnt-type <> 'прво':U
  and ub.trn-doc.ext-doc-type <> 'io':U
  then do:
    run show-action in this-procedure
      (input "Создание внутренних перемещений"
      ).
    run trg/trndocmv.p
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при создании документа внутреннего прихода/возврата.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
  define variable hold-value as character no-undo .
  define variable hold-type  as character no-undo.
  define variable v-holding as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output hold-value
  ,output hold-type
  ) no-error .
  if  ( not error-status :error )
  and hold-value = "yes"
  then do:
    assign
      v-holding = true
    .
  end.
  else do:
    assign
      v-holding = false
    .
  end.
  if v-holding = true
  then do:
    if  ub.trn-doc.status_  = 'факт':U
    and (ub.trn-doc.ext-doc-type = 'ee':U or
         ub.trn-doc.ext-doc-type = 'ep':U or
         ub.trn-doc.ext-doc-type = 'ie':U)
    then do:
      run show-action in this-procedure
        (input "Создание межфирм. перемещений"
        ).
      run trg/trndocmh.p
        (input ub.trn-doc.doc-code
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Ошибка при создании документа межфирменного прихода/возврата.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.
  end.
  if ub.trn-doc.status_  = 'факт':U
  then do:
    run show-action in this-procedure
      (input "Обработка архивных партий"
      ).
    run update-archive-parts-on-fact-close in this-procedure no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при обработке архивных партий документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    if g#news = false then do:
      run show-action in this-procedure
        (input "Расчет шапки накладной"
        ).
      run str/calc-hd.p
        (input ub.trn-doc.doc-code
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Ошибка при расчете шапки документа.&2Информация об ошибке выведена в файл calc-hd.err&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
if (valid-handle(g#libtfarh) <> true) then do:   run str/libtfarh.p persistent no-error .   if error-status :error or (valid-handle(g#libtfarh) <> true) then do:     message       "Error starting libtfarh.p" skip       g#libtfarh skip       g#libtfarh :type skip       g#libtfarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libtfarh_catrncnt in g#libtfarh
(input  ub.trn-doc.doc-code
) no-error.
      if error-status :error then do:
        return error substitute ("&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2)).
      end.
    end.
    run show-action in this-procedure
      (input "Проверка целостности документа"
      ).
    run validate-trn-doc in this-procedure no-error .
    if error-status :error
    then do:
      undo main-block, return error return-value .
    end.
    if ub.trn-doc.is-back-date = true
    then do:
      run show-action in this-procedure
        (input "Пересчет топливных остатков в последующих документах"
        ).
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_reclcptr in g#lib-trn3
( input (buffer ub.trn-doc:handle)
 ,input ?
 ,input 1.0
 ,input ub.trn-doc.ext-doc-type
 ,input dynamic-next-value('s-corr-chip':U,'ub':U)
) no-error .
      if error-status :error then do:
        assign
          v-message = substitute( "&1. Ошибка пересчета факт. кол-ва топлива в последующих документах.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error
      then do:
        if g#news = false and g#esys = false and g#auto = false then
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "Документ" ub.trn-doc.doc-code skip
          "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error return-value .
      end.
  if l-shift-on then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-bge':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output v-is-bge
  ,output par-type
  ) no-error .
      if v-is-bge = 'yes' or v-is-bge = 'true' then do:
        run clntattr-value(ub.trn-doc.obj-type,
                           ub.trn-doc.obj-code,
                           'bge-incr-last-shift-date':U,
                           output v-bge-incr-last-shift-date,
                           output v-type).
        run clntattr-value(ub.trn-doc.obj-type,
                           ub.trn-doc.obj-code,
                           'bge-incr-last-shift-num':U,
                           output v-bge-incr-last-shift-num,
                           output v-type).
        if ub.trn-doc.shift-date < date(v-bge-incr-last-shift-date)
         or (ub.trn-doc.shift-date = date(v-bge-incr-last-shift-date)
           and ub.trn-doc.shift-num <= integer(v-bge-incr-last-shift-num)) then do:
          find last buf_previous-shift-obj where buf_previous-shift-obj.obj-type = ub.trn-doc.obj-type
                                             and buf_previous-shift-obj.obj-code = ub.trn-doc.obj-code
                                             and ((buf_previous-shift-obj.shift-date = ub.trn-doc.shift-date
                                                   and buf_previous-shift-obj.shift-num < ub.trn-doc.shift-num)
                                                  or buf_previous-shift-obj.shift-date < ub.trn-doc.shift-date)
                                                  use-index pi no-lock no-error.
          if not available(buf_previous-shift-obj) then do:
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                              'bge-incr-last-shift-date':U,
                               string(ub.trn-doc.shift-date)).
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                               'bge-incr-last-shift-num':U,
                               '0').
          end.
          else do:
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                              'bge-incr-last-shift-date':U,
                               string(buf_previous-shift-obj.shift-date)).
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                               'bge-incr-last-shift-num':U,
                               string(buf_previous-shift-obj.shift-num)).
          end.
        end.
      end.
    end.
  end.
  if  ( ub.trn-doc.status_ = 'накл':U and ub.trn-doc.flag_ = false ) and
        ( old-doc.flag_ = true or
          old-doc.status_ = 'разрешен':U )then  do:
        run nws/cmd-del.p
          ( input "trn-doc":U
          , input ( buffer ub.trn-doc :handle )
          , input "":U
          ) no-error .
        if error-status :error then do:
          return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( 1 ) ).
        end.
  end.
  if  (ub.trn-doc.status_ = 'накл':U      and ub.trn-doc.flag_ = true )
      or (ub.trn-doc.status_ = 'разрешен':U and ub.trn-doc.flag_ = true )
      or (ub.trn-doc.status_ = 'нередакт':U and ub.trn-doc.flag_ = true )
      or (ub.trn-doc.status_ = 'готов':U)
      or (ub.trn-doc.status_ = 'отказ':U)
      or (ub.trn-doc.status_ = 'факт':U)
  then do:
    run show-action in this-procedure
      (input "Проверка целостности документа"
      ).
    run trg/chktdcpl.p
      ( input ub.trn-doc.doc-code
      ) no-error.
    if error-status :error then do:
      assign
        v-message = substitute('&1 &2 &3':U, vss-workfile, vss-revision, vss-description) + chr(10)
                  + "Ошибка при проверке целостности топливных товаров" + chr(10)
                  + substitute('Документ &1':U, ub.trn-doc.doc-code)  + chr(10)
                  + substitute('&1':U, return-value)  + chr(10)
                  + substitute('&1':U, error-status :get-message(1))  + chr(10)
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    if g#news = false then do:
      assign
        v-need-send = true
      .
    end.
    else do:
      if g#db-num = 0
      then do:
        case ub.trn-doc.ext-doc-type :
          when 'iv':U
          or when 'rv':U
          then do:
            find first buf-obj_clients no-lock
              where buf-obj_clients.obj-type = ub.trn-doc.cli-type
                and buf-obj_clients.obj-code = ub.trn-doc.cli-code
              no-error .
            if not available buf-obj_clients
            then do:
              undo main-block, return error substitute( "&1. Не найден объект контрагента.&2Документ &3 (&4)&2Объект &5 &6"
                                                        , vss-workfile
                                                        , chr(10)
                                                        , ub.trn-doc.doc-code
                                                        , ub.trn-doc.ext-doc-type
                                                        , ub.trn-doc.cli-type
                                                        , ub.trn-doc.cli-code
                                                        ).
            end.
            if trn-doc_clients.db-num <> 0
              and trn-doc_clients.db-num <> g#news-source-db
              and buf-obj_clients.db-num <> 0
              and trn-doc_clients.db-num <> buf-obj_clients.db-num
            then do:
              assign
                v-need-send = true
              .
            end.
          end.
          when 'ie':U
          or when 're':U
          then do:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  ub.trn-doc.doc-code
  ,output v-is-hold
  )  .
            if v-is-hold = true
            then do:
              find first buf-obj_clients no-lock
                where buf-obj_clients.obj-type = ub.trn-doc.hold-obj-type
                  and buf-obj_clients.obj-code = ub.trn-doc.hold-obj-code
                no-error .
              if not available buf-obj_clients
              then do:
                undo main-block, return error substitute( "&1. Не найден объект контрагента.&2Документ &3 (&4)&2Объект &5 &6"
                                                          , vss-workfile
                                                          , chr(10)
                                                          , ub.trn-doc.doc-code
                                                          , ub.trn-doc.ext-doc-type
                                                          , ub.trn-doc.hold-obj-type
                                                          , ub.trn-doc.hold-obj-code
                                                          ).
              end.
              if trn-doc_clients.db-num <> 0
                and trn-doc_clients.db-num <> g#news-source-db
                and buf-obj_clients.db-num <> 0
                and trn-doc_clients.db-num <> buf-obj_clients.db-num
              then do:
                assign
                  v-need-send = true
                .
              end.
            end.
          end.
        end case.
      end.
    end.
    if v-need-send = true then do:
      run trg/trn-docv.p
        ( input ub.trn-doc.doc-code
        , output p-error
        , output v-message
        ) .
      if p-error = true then do:
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
      run show-action in this-procedure
        (input "Отправка документа в новости"
        ).
      run str/callnews.p
        (input 'trn-doc':U
        ,input (buffer ub.trn-doc:handle)
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Невозможно маршрутизировать документ для отправки в СПН.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
      if ub.trn-doc.ext-doc-type = 'ev':U or ub.trn-doc.ext-doc-type = 'iv':U then do:
       for each ub.marking-lines exclusive-lock where ub.marking-lines.out-code = ub.trn-doc.doc-code
                                                  and ub.marking-lines.obj-code = ub.trn-doc.obj-code
                                                  and ub.marking-lines.obj-type = ub.trn-doc.obj-type:
          for each ub.marking exclusive-lock where ub.marking.mark = ub.marking-lines.mark:
            find first ub.clients where ub.clients.obj-type = ub.trn-doc.obj-type and ub.clients.obj-code = ub.trn-doc.obj-code.
            run nws/cr-route.p
              ( input 'send-tbl':U,
                input 'marking':U, input (buffer ub.marking:handle), input string (ub.clients.db-num) ) no-error.
          end.
        end.
      end.
    end.
  end.
  if  g#news = false
  and ub.trn-doc.status_ = 'факт':U
  then do:
    run show-action in this-procedure
      (input "Создание бар-кодов для порожденных партий"
      ).
    run trnbccr in this-procedure
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при создании бар-кодов партий.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_trn-doc':U
  ,input  buffer old-doc:handle
  ,input  buffer ub.trn-doc:handle
  ,input ''
  ,input ''
  ) no-error .
  if error-status:error
  then do:
    v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,chr(10)
                          , error-status:get-message(1)
                          , return-value ).
    if g#news = false and g#esys = false and g#auto = false then
      message
      v-message
      view-as alert-box error .
    undo main-block,  return error v-message.
  end.
  if g#news
  and g#db-num = 0
  and ub.trn-doc.status_ = 'факт':U
  then do :
    if ub.trn-doc.ext-doc-type = 'vt':U
    or ub.trn-doc.ext-doc-type = 'wm':U
    or ub.trn-doc.ext-doc-type = 'we':U
    then do :
      run show-action in this-procedure
      (input "Создание документов Вывода из оборота (ОСУ) для отправки в ГИС МТ"
      ).
      run str/create-LK_RECEIPT.p (input ub.trn-doc.doc-code) .
    end .
  end .
  run show-action in this-procedure
    (input "Передача остатков товара через новости"
    ).
  run trg/prtobrem.p
    (input true
    ,input ub.trn-doc.doc-code
    ,input false
    ) no-error .
  if error-status :error
  then do:
    assign
      v-message = substitute( "&1. Ошибка при передаче остатков товара через СПН.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    if g#news = false and g#esys = false and g#auto = false then
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
  if ub.trn-doc.status_ = 'факт':U
  then do:
    run show-action in this-procedure
      (input "Регистрируем номер документа в архивах"
      ).
    run trg/nu_arh.p
      (input ub.trn-doc.doc-code
      ,input 'trn-doc':U
      ,input ub.trn-doc.obj-type
      ,input ub.trn-doc.obj-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при вызове процедуры nu_arh.p.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    run trg/nu_ahsp.p
      (input ub.trn-doc.doc-code
      ,input 'trn-doc':U
      ,input ub.trn-doc.obj-type
      ,input ub.trn-doc.obj-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при вызове процедуры nu_ahsp.p.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    run trg/nu_aht.p
      (input ub.trn-doc.doc-code
      ,input 'trn-doc':U
      ,input ub.trn-doc.obj-type
      ,input ub.trn-doc.obj-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при вызове процедуры nu_aht.p.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    if  g#db-num = 0
    and v-holding = true
    then do:
      run trg/nu_hold.p
        (input ub.trn-doc.doc-code
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Ошибка при вызове процедуры nu_hold.p.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.
    if ub.trn-doc.is-back-date
    then do:
      run show-action in this-procedure
        (input "Закрытие документа задним числом"
        ).
      define buffer calc-arh-lock_batchprocess for ub.batchprocess .
      run gbl/lock-prc.p
        (input 'btpr':U
        ,input ub.trn-doc.obj-code
        ,input 0
        ,input 0
        ,input ub.trn-doc.obj-type
        ,input ""
        ,input ""
        ,input "Объект,,, ,,,Расчет складского архива по товарам"
        ,input false
        ,buffer calc-arh-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + chr(10)
                    + "В данный момент рассчитывается складской архив по товарам" + chr(10)
                    + "Невозможно закрыть документ задним числом"  + chr(10)
                    + substitute('&1':u, return-value)
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo, return error v-message .
      end.
      define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .
      run gbl/lock-prc.p
        (input 'ahsp':U
        ,input ub.trn-doc.obj-code
        ,input 0
        ,input 0
        ,input ub.trn-doc.obj-type
        ,input ""
        ,input ""
        ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
        ,input false
        ,buffer calc-supp-arh-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + chr(10)
                    + "В данный момент рассчитывается складской архив по поставщикам" + chr(10)
                    + "Невозможно закрыть документ задним числом"  + chr(10)
                    + substitute('&1':u, return-value)
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo, return error v-message .
      end.
      define buffer calc-aht-lock_batchprocess for ub.batchprocess .
      run gbl/lock-prc.p
        (input 'ahtb':U
        ,input ub.trn-doc.obj-code
        ,input 0
        ,input 0
        ,input ub.trn-doc.obj-type
        ,input ""
        ,input ""
        ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
        ,input false
        ,buffer calc-aht-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + chr(10)
                    + "В данный момент рассчитывается складской архив по типам приобретения" + chr(10)
                    + "Невозможно закрыть документ задним числом"  + chr(10)
                    + substitute('&1':u, return-value)
        .
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo, return error v-message .
      end.
      run show-action in this-procedure
        (input "Закрытие задним числом. Отметка переоценок, требующих перерасчета"
        ).
      run trg/mark-prc.p
        (input  ub.trn-doc.doc-code
        ,input  ub.trn-doc.fact-order
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          assign
            v-message = substitute( "&1. Закрытие документа задним числом.&2Ошибка при отметке переоценок, требующих перерасчета.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
          .
        end.
        else do:
          assign
            v-message = substitute( "&1. Документ &3 не может быть закрыт задним числом.&2", vss-workfile, chr(10), ub.trn-doc.doc-code ).
          .
        end.
        if g#news = false and g#esys = false and g#auto = false then
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.
    run show-action in this-procedure
      (input "Обновление остатков по поставщику на фирме"
      ).
    run trg/trn-supp.p
      (input  ub.trn-doc.doc-code
      ,input  true
      ,input  true
      ,input  true
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при обновлении остатков по поставщику на фирме.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    run show-action in this-procedure
      (input "Установка признаков клиента"
      ).
    RUN set-cli in this-procedure
      (input recid(ub.trn-doc)
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при установке признаков клиента.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false and g#esys = false and g#auto = false then
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    if old-doc.status_ <> 'факт':U and old-doc.ext-doc-type = 'iv':U then do:
      assign
        ub.trn-doc.creid = g#userid
      .
      if g#db-num = 0 then do:
          run str/inqivdel.p ( input ub.trn-doc.doc-code ) no-error  .
          if error-status :error then do:
          end.
      end.
    end.
    run show-action in this-procedure
      (input "Обработка документа завершена"
      ).
  end.
  if g#oxml = true   then do:
    run str/calloxml.p (
          input 'update':U
        , input 'trn-doc':U
        , input ( buffer ub.trn-doc:handle )
    ) no-error.
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при отправке записи в систему OpenXML.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      undo main-block, return error v-message .
    end.
  end.
end.
procedure validate-trn-doc :
  define variable v-curr-r-b as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    run chksltpc in this-procedure
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке соответсвия типов налога с продаж и процентов ставок.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.
    run chkvatpc in this-procedure
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке соответсвия типа НДС и процентов ставок.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.
    run chkprice in this-procedure
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке цен документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.
    run chkzero in this-procedure
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке нулевых строк документа.&2Документ &3&2&4&2&5", vss-workfile, chr(10), ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.
    define variable l-doc-prt as logical no-undo .
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  'doc-prt=request'
  ,output l-doc-prt
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Документ" ub.trn-doc.doc-code skip
        "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
        "Запрашивался атрибут" "doc-prt=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if ub.trn-doc.ext-doc-type = 'ie':U
    or ub.trn-doc.ext-doc-type = 'im':U
    then do:
      if  ub.trn-doc.vat-type <> 'в т. ч.':U
      and ub.trn-doc.vat-type <> 'нет':U
      and ub.trn-doc.vat-type <> 'без':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестной значение поля тип НДС" skip
          "Документ" ub.trn-doc.doc-code skip
          "Тип НДС" ub.trn-doc.vat-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if  ub.trn-doc.slt-type <> 'в т. ч.':U
      and ub.trn-doc.slt-type <> 'нет':U
      and ub.trn-doc.slt-type <> 'без':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестной значение поля тип НП" skip
          "Документ" ub.trn-doc.doc-code skip
          "Тип НП" ub.trn-doc.slt-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    for each buf_parts no-lock
      where buf_parts.out-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      if buf_parts.status_ <> yes
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту остались зависшие резервы."  skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "buf_parts.status_" buf_parts.status_ skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_parts.obj-type <> ub.trn-doc.obj-type
      or buf_parts.obj-code <> ub.trn-doc.obj-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту имеются партии с неправильной ссылкой на объект." skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "buf_parts.obj-type" buf_parts.obj-type skip
          "buf_parts.obj-code" buf_parts.obj-code skip
          "ub.trn-doc.obj-type" ub.trn-doc.obj-type skip
          "ub.trn-doc.obj-code" ub.trn-doc.obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = ub.trn-doc.doc-code
          and buf_doc-line.artic     = buf_parts.artic
          and buf_doc-line.prod-type = buf_parts.prod-type
          and buf_doc-line.prod-code = buf_parts.prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту остались зависшие резервы." skip
          "Не найден doc-line." skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_parts.purch-code = ?
      or lookup(string(buf_parts.purch-code), '1,2,3,4':U ) = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип приобретения партии" skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Тип приобретения" buf_parts.purch-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      find first buf_doc-line
        where buf_doc-line.doc-code  = ub.trn-doc.doc-code
          and buf_doc-line.artic     = buf_gds-dtl.artic
          and buf_doc-line.prod-type = buf_gds-dtl.prod-type
          and buf_doc-line.prod-code = buf_gds-dtl.prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту остались зависшие признаки." skip
          "Не найден doc-line." skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define variable v-parts-fact-qnty   as decimal no-undo .
    define variable v-parts-qnty        as decimal no-undo .
    define variable v-parts-cli-qnty    as decimal no-undo .
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define variable v-gds-dtl-doc-qnty  as decimal no-undo .
    define variable l-has-gds-dtl       as logical no-undo .
    define variable l-empty-scale       as logical no-undo .
    define variable l-goods-twounit     as logical no-undo .
    define variable v-root-node         like ub.gds-prt.node-code no-undo .
    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      if  buf_doc-line.obj-type <> ub.trn-doc.obj-type
      and buf_doc-line.obj-code <> ub.trn-doc.obj-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает объект в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Объект документа" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
          "Объект строки" buf_doc-line.obj-type buf_doc-line.obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_doc-line.fact-order <> ub.trn-doc.fact-order
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает логический номер в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Логический номер документа" ub.trn-doc.fact-order skip
          "Логический номер строки" buf_doc-line.fact-order skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_doc-line.status_ <> ub.trn-doc.status_
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает статус в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Статус документа" ub.trn-doc.status_ skip
          "Статус строки" buf_doc-line.status_ skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_doc-line.ext-doc-type <> ub.trn-doc.ext-doc-type
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает расширенный тип документа в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Расширенный тип строки" buf_doc-line.ext-doc-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      assign
        v-parts-fact-qnty   = 0
        v-parts-qnty        = 0
        v-parts-cli-qnty    = 0
        v-gds-dtl-fact-qnty = 0
        v-gds-dtl-doc-qnty  = 0
        l-has-gds-dtl       = false
      .
      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        .
      define variable v-gds-goods      as logical   no-undo .
      define variable v-gds-pl-reserv  as logical   no-undo .
      define variable v-gds-is-twounit as logical   no-undo .
      define variable v-gds-is-serial  as logical   no-undo .
      define variable v-gds-is-legal   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'gds-goods=request':u
  ,output v-gds-goods
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Атрибут" 'gds-goods=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request':u
  ,output v-gds-pl-reserv
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара на объекте" skip
          "Атрибут" 'place-rsrv=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'twounit=request':u
  ,output v-gds-is-twounit
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Атрибут" 'twounit=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'serial=request':u
  ,output v-gds-is-serial
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Атрибут" 'serial=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      run lggdstrn in this-procedure
        (  input ub.trn-doc.ext-doc-type
        ,  input ub.trn-doc.office
        ,  input ub.trn-doc.purch-code
        ,  input (v-gds-goods <> true)
        ,  input v-gds-pl-reserv
        ,  input v-gds-is-twounit
        ,  input v-gds-is-serial
        ,  input buf_goods.artic
        ,  input buf_goods.prod-type
        ,  input buf_goods.prod-code
        ,  input ub.trn-doc.doc-code
        , output v-gds-is-legal
        ) no-error .
      if error-status :error
      or v-gds-is-legal <> true
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не прошла проверка допустимости включения товара в документ" skip
          "Документ" ub.trn-doc.doc-code skip
          "Товар" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута признака" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Признак" v-root-node skip
          "Запрашивался атрибут" "empty-scale=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_goods.cost-calc <> 'FIFO':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Товар имеет метод учета отличный от" 'FIFO':U skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Метод расчета" buf_goods.cost-calc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_doc-line.vat-pc < 0
      or buf_doc-line.vat-pc >= 100
      or buf_doc-line.vat-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Строка документа имеет недопустмиый НДС" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "НДС" buf_doc-line.vat-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_doc-line.slt-pc < 0
      or buf_doc-line.slt-pc >= 100
      or buf_doc-line.slt-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Строка документа имеет недопустмиый НП" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "НП" buf_doc-line.vat-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if buf_goods.gds-type = 'т':U
      then do:
        for each buf_parts no-lock
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.out-code  = buf_doc-line.doc-code
        on error undo, return error return-value
        :
          if ub.trn-doc.doc-type <> 'инв':U
          then do:
            if buf_parts.fact-qnty < 0
            or buf_parts.qnty < 0
            or buf_parts.cli-qnty < 0
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "При закрытии документа по факту имеются партии с отрицательными количествами." skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "parts.fact-qnty" buf_parts.fact-qnty skip
                "parts.qnty" buf_parts.qnty skip
                "parts.cli-qnty" buf_parts.cli-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          define variable v-is-petrol-trn  as logical   no-undo.
          define variable v-is-pieces      as logical   no-undo.
          if old-doc.ext-doc-type = 'iv':U
          then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_parts.artic
  ,  input buf_parts.prod-type
  ,  input buf_parts.prod-code
  , output v-is-petrol-trn
  , output v-is-pieces
  ) .
            if not v-is-petrol-trn
            then do:
              find current buf_parts exclusive-lock.
              buf_parts.cli-qnty = buf_parts.qnty.
              find current buf_parts no-lock.
            end.
          end.
          assign
            v-parts-fact-qnty = v-parts-fact-qnty + buf_parts.fact-qnty
            v-parts-qnty      = v-parts-qnty      + buf_parts.qnty
            v-parts-cli-qnty  = v-parts-cli-qnty  + buf_parts.cli-qnty
          .
          if buf_parts.doc-type <> ub.trn-doc.doc-type
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Неправильный тип партии" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "ub.trn-doc.doc-type" ub.trn-doc.doc-type skip
              "buf_parts.doc-type" buf_parts.doc-type skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if buf_parts.host-code <> ub.trn-doc.host-code
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Код фирмы партии не совпадает с кодом фирмы документа" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "buf_parts.host-code" buf_parts.host-code skip
              "ub.trn-doc.host-code" ub.trn-doc.host-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if buf_parts.fact-num <> ub.trn-doc.fact-num
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Фактический номер партии не совпадает с фактическим номером документа" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "buf_parts.fact-num" buf_parts.fact-num skip
              "ub.trn-doc.fact-num" ub.trn-doc.fact-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if buf_parts.fact-date <> ub.trn-doc.fact-date
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Дата партии не совпадает с датой фактического закрытия документа" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "buf_parts.fact-date" buf_parts.fact-date skip
              "ub.trn-doc.fact-date" ub.trn-doc.fact-date skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if ub.trn-doc.ext-doc-type = 'ie':U
          then do:
            if buf_parts.VAT-pc <> buf_doc-line.VAT-pc
            or buf_parts.SLT-pc <> buf_doc-line.SLT-pc
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Отличаются параметры порожденной партии от строки документа" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_parts.VAT-pc"           buf_parts.VAT-pc           skip
                "buf_parts.SLT-pc"           buf_parts.SLT-pc           skip
                "buf_doc-line.VAT-pc"        buf_doc-line.VAT-pc        skip
                "buf_doc-line.SLT-pc"        buf_doc-line.SLT-pc        skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            if l-goods-twounit = false
            then do:
              if buf_parts.cli-base-rate <> buf_doc-line.cli-base-rate
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Отличаются параметры порожденной партии от строки документа" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  "buf_parts.cli-base-rate"    buf_parts.cli-base-rate    skip
                  "buf_doc-line.cli-base-rate" buf_doc-line.cli-base-rate skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
            if buf_parts.exch-code <> ub.trn-doc.exch-code
            or buf_parts.pay-code  <> ub.trn-doc.pay-code
            or buf_parts.VAT-type  <> ub.trn-doc.vat-type
            or buf_parts.SLT-type  <> ub.trn-doc.slt-type
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Отличаются параметры порожденной партии от строки документа" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_parts.exch-code"   buf_parts.exch-code   skip
                "buf_parts.pay-code"    buf_parts.pay-code    skip
                "buf_parts.VAT-type"    buf_parts.VAT-type    skip
                "buf_parts.SLT-type"    buf_parts.SLT-type    skip
                "ub.trn-doc.exch-code" ub.trn-doc.exch-code skip
                "ub.trn-doc.pay-code"  ub.trn-doc.pay-code  skip
                "ub.trn-doc.vat-type"  ub.trn-doc.vat-type  skip
                "ub.trn-doc.slt-type"  ub.trn-doc.slt-type  skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            define variable v-curr-road-tax as decimal   no-undo .
            v-curr-road-tax = if v-curr-r-b = 'base':U then buf_parts.road-tax-base else buf_parts.road-tax-rubl .
            if v-curr-road-tax <> buf_doc-line.road-tax
            then do:
                define variable v-road-tax-name as character no-undo .
                run tax-name in this-procedure
                  (input 'rdt':U
                  ,output v-road-tax-name
                  ) .
                message
                  vss-workfile vss-revision vss-description skip
                  "Различается" v-road-tax-name "по приходу и по расходу" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  "buf_parts.road-tax-base"  buf_parts.road-tax-base skip
                  "buf_parts.road-tax-rubl"  buf_parts.road-tax-rubl skip
                  "buf_doc-line.road-tax"      buf_doc-line.road-tax skip
                  view-as alert-box error .
                undo, return error return-value .
            end.
            define variable v-parts-artic          like ub.parts.artic           no-undo .
            define variable v-parts-prod-type      like ub.parts.prod-type       no-undo .
            define variable v-parts-prod-code      like ub.parts.prod-code       no-undo .
            define variable v-parts-other-base     like ub.parts.other-base      no-undo .
            define variable v-parts-other-rubl     like ub.parts.other-rubl      no-undo .
            define variable v-parts-transport-base like ub.parts.transport-base  no-undo .
            define variable v-parts-transport-rubl like ub.parts.transport-rubl  no-undo .
            define variable v-parts-SLT-PC         like ub.parts.SLT-PC          no-undo .
            define variable v-parts-VAT-PC         like ub.parts.VAT-PC          no-undo .
            define variable v-parts-price-cli      like ub.parts.price-cli       no-undo .
            define variable v-parts-cli-base-rate  like ub.parts.cli-base-rate   no-undo .
            assign
              v-parts-artic          = buf_parts.artic
              v-parts-prod-type      = buf_parts.prod-type
              v-parts-prod-code      = buf_parts.prod-code
              v-parts-other-base     = buf_parts.other-base
              v-parts-other-rubl     = buf_parts.other-rubl
              v-parts-transport-base = buf_parts.transport-base
              v-parts-transport-rubl = buf_parts.transport-rubl
              v-parts-SLT-PC         = buf_parts.SLT-PC
              v-parts-VAT-PC         = buf_parts.VAT-PC
              v-parts-price-cli      = buf_parts.price-cli
              v-parts-cli-base-rate  = buf_parts.cli-base-rate
            .
            if v-parts-vat-pc < 0
            or v-parts-vat-pc >= 100
            or v-parts-vat-pc = ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Неправильный НДС в партии товара" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "НДС" v-parts-vat-pc skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Неправильный НДС в партии товара".
            end.
            if v-parts-slt-pc < 0
            or v-parts-slt-pc >= 100
            or v-parts-slt-pc = ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Неправильный НП в партии товара" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "НП" v-parts-slt-pc skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Неправильный НП в партии товара".
            end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   ub.trn-doc.doc-code
  ,input   ub.trn-doc.base-rate
  ,input   ub.trn-doc.base-scale
  ,input   ub.trn-doc.exch-rate
  ,input   ub.trn-doc.exch-scale
  ,input   ub.trn-doc.vat-type
  ,input   ub.trn-doc.slt-type
  ,input   v-parts-artic
  ,input   v-parts-prod-type
  ,input   v-parts-prod-code
  ,input   v-parts-price-cli
  ,input   v-parts-cli-base-rate
  ,input   buf_parts.price-rubl
  ,input   v-parts-vat-pc
  ,input   v-parts-slt-pc
  ,input   v-curr-road-tax
  ,input   v-parts-transport-rubl
  ,input   v-parts-other-rubl
  ,output  v-price-cli
  ,output  v-price-cli-unit-base
  ,output  v-price-road-tax
  ,output  v-price-other-exp
  ,output  v-price-transport-exp
  ,output  v-price-without-abs
  ,output  v-price-slt
  ,output  v-price-no-slt
  ,output  v-price-vat
  ,output  v-price-no-vat-slt
  ,output  v-price-rubl
  ,output  v-price-road-tax-rubl
  ,output  v-price-other-exp-rubl
  ,output  v-price-transport-exp-rubl
  ,output  v-price-without-abs-rubl
  ,output  v-price-slt-rubl
  ,output  v-price-no-slt-rubl
  ,output  v-price-vat-rubl
  ,output  v-price-no-vat-slt-rubl
  ,output  v-price-base
  ,output  v-price-road-tax-base
  ,output  v-price-other-exp-base
  ,output  v-price-transport-exp-base
  ,output  v-price-without-abs-base
  ,output  v-price-slt-base
  ,output  v-price-no-slt-base
  ,output  v-price-vat-base
  ,output  v-price-no-vat-slt-base
  ) no-error.
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при перерасчете линии документа" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Ошибка при пересчете линии документа" .
            end.
            assign
              v-parts-price-cli  = v-price-cli
            .
                                    if abs(buf_parts.price-base - v-price-base) > 0.0000001
            or abs(buf_parts.price-rubl - v-price-rubl) > 0.0000001
            then do:
              v-message = substitute( "Несоответсвие учетной цены и цены поставщика. Артикул &1 &2 &3",
                                      buf_parts.artic, buf_parts.prod-type, buf_parts.prod-code ) .
              message
                vss-workfile vss-revision vss-description skip
                "Документ" ub.trn-doc.doc-code
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "buf_parts.part-code"       buf_parts.part-code       skip
                "" skip
"Поле"           chr(9) chr(9) "Отлич."                                           chr(9) "Партия"                 chr(9) "Должно быть значение"  skip
"price-base"                   chr(9) buf_parts.price-base     <> v-price-base           chr(9) buf_parts.price-base     chr(9) truncate(v-price-base, 7) skip
"price-rubl "                  chr(9) buf_parts.price-rubl     <> v-price-rubl           chr(9) buf_parts.price-rubl     chr(9) truncate(v-price-rubl, 7) skip
"other-base"                   chr(9) buf_parts.other-base     <> v-parts-other-base     chr(9) buf_parts.other-base     chr(9) v-parts-other-base      skip
"other-rubl "                  chr(9) buf_parts.other-rubl     <> v-parts-other-rubl     chr(9) buf_parts.other-rubl     chr(9) v-parts-other-rubl      skip
"transport-base"               chr(9) buf_parts.transport-base <> v-parts-transport-base chr(9) buf_parts.transport-base chr(9) v-parts-transport-base  skip
"transport-rubl"               chr(9) buf_parts.transport-rubl <> v-parts-transport-rubl chr(9) buf_parts.transport-rubl chr(9) v-parts-transport-rubl  skip
"SLT-PC"         chr(9) chr(9) buf_parts.SLT-PC         <> v-parts-SLT-PC         chr(9) buf_parts.SLT-PC         chr(9) v-parts-SLT-PC          skip
"VAT-PC"         chr(9) chr(9) buf_parts.VAT-PC         <> v-parts-VAT-PC         chr(9) buf_parts.VAT-PC         chr(9) v-parts-VAT-PC          skip
"price-cli"      chr(9) chr(9) buf_parts.price-cli      <> v-parts-price-cli      chr(9) buf_parts.price-cli      chr(9) v-parts-price-cli       skip
"cli-base-rate"                chr(9) buf_parts.cli-base-rate  <> v-parts-cli-base-rate  chr(9) buf_parts.cli-base-rate  chr(9) v-parts-cli-base-rate   skip
              view-as alert-box error .
              undo, return error v-message .
            end.
            if buf_parts.supp-code <> ub.trn-doc.cli-code
            or buf_parts.supp-type <> ub.trn-doc.cli-type
            or buf_parts.is-supp   <> true
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Отличаются параметры порожденной партии документа внешнего прихода" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_parts.supp-code"  buf_parts.supp-code  skip
                "buf_parts.supp-type"  buf_parts.supp-type  skip
                "buf_parts.is-supp"    buf_parts.is-supp    skip
                "ub.trn-doc.cli-code" ub.trn-doc.cli-code skip
                "ub.trn-doc.cli-type" ub.trn-doc.cli-type skip
                view-as alert-box error .
              undo, return error return-value .
            end.
            define variable v-test-parts-qnty like ub.parts.qnty no-undo .
            assign
              v-test-parts-qnty = buf_parts.cli-qnty * buf_parts.cli-base-rate
            .
            if (buf_parts.cli-base-rate = 1
                and buf_parts.qnty <> v-test-parts-qnty
              )
            or (buf_parts.cli-base-rate <> 1
                and abs(buf_parts.qnty - v-test-parts-qnty) > 0.1
              )
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Количество по ТТН не соответсвует количеству по документу" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.part-code skip
                "buf_parts.qnty" buf_parts.qnty skip
                "buf_parts.cli-qnty * buf_parts.cli-base-rate" v-test-parts-qnty skip
                "buf_parts.cli-qnty" buf_parts.cli-qnty skip
                "buf_parts.cli-base-rate" buf_parts.cli-base-rate skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          else do:
            if buf_parts.in-code = buf_parts.out-code
            then do:
              if buf_parts.supp-type <>
        ( if ub.trn-doc.doc-type = 'при':U then ub.trn-doc.cli-type else ub.trn-doc.obj-type )
              or buf_parts.supp-code <>
        ( if ub.trn-doc.doc-type = 'при':U then ub.trn-doc.cli-code else ub.trn-doc.obj-code )
              then do:
                if ub.trn-doc.ext-doc-type = 'ap':U
                or ub.trn-doc.ext-doc-type = 'pc':U
                or ub.trn-doc.ext-doc-type = 'mp':U
                then do:
                end.
                else do:
                  if (ub.trn-doc.doc-type = 'возврат':U
                    and ub.trn-doc.internal = false
                    )
                  or (ub.trn-doc.ext-doc-type = 'vt':U
                    and buf_parts.fact-qnty > 0 )
                  or (ub.trn-doc.ext-doc-type = 'vp':U
                    and buf_parts.fact-qnty > 0 )
                  then do:
                    if  buf_parts.supp-type <> 'чел':U
                    and buf_parts.supp-type <> 'орг':U
                    then do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "Поставщиком порожденной партии старого возврата может быть только человек или организация" skip
                        "Документ" ub.trn-doc.doc-code skip
                        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                        "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                        "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                    if buf_parts.is-supp = false
                    then do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "У партии старого возврата должен быть установлен признак от поставщика" skip
                        "Документ" ub.trn-doc.doc-code skip
                        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                        "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                        "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                        "is-supp" buf_parts.is-supp skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                  end.
                  else do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Поставщиком порожденной партии может быть только объект документа" skip
                      "Документ" ub.trn-doc.doc-code skip
                      "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                      "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                      "Объект документа" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
                      "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                end.
              end.
              else do:
                if buf_parts.is-supp = true
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "У порожденной партии должен быть установлен признак, что она порождена" skip
                    "Документ" ub.trn-doc.doc-code skip
                    "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                    "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                    "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                    "is-supp" buf_parts.is-supp skip
                    view-as alert-box error .
                  undo, return error return-value .
                end.
              end.
              define variable v-is-hold as logical   no-undo .
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  ub.trn-doc.doc-code
  ,output v-is-hold
  ) no-error .
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа документа" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
              if ub.trn-doc.ext-doc-type  = 'ep':U
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Партии не могут порождаться документами:" skip
                  "  " "расход внешний возврат поставщику" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Межфирменный" v-is-hold skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
         end.
            if g#news = false
            then do:
              if buf_parts.price-base = 0
              or buf_parts.price-rubl = 0
              then do:
                define variable v-parameter-name as character no-undo .
                define variable conf-par as character no-undo .
                define variable par-type as character no-undo .
                define variable v-prcshfc0 as character no-undo .
                define variable v-prdocfc0 as character no-undo .
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ub.trn-doc.obj-type
  ,input ub.trn-doc.obj-code
  ,input 'rezerv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
                for each thbjattr_thbj-attr :
                  if thbjattr_thbj-attr.prop-code = 'prcshfc0'  then  v-prcshfc0  = string(thbjattr_thbj-attr.property-value-logical).
                  if thbjattr_thbj-attr.prop-code = 'prdocfc0'  then  v-prdocfc0  = string(thbjattr_thbj-attr.property-value-logical).
                end.
                if ub.trn-doc.discnt-type = 'касс':U
                then do:
                  assign
                    v-parameter-name = "prcshfc0"
                    conf-par = v-prcshfc0
                  .
                end.
                else do:
                  assign
                    v-parameter-name = "prdocfc0"
                    conf-par = v-prdocfc0
                  .
                end.
                if can-do( "true,yes", conf-par )
                then do:
                end.
                else do:
                  message
                    "Документ" ub.trn-doc.doc-code skip
                    "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                    "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                    "Порожденная партия имеет нулевую учетную цену" skip
                    "buf_parts.in-code"          buf_parts.in-code skip
                    "buf_parts.part-code"        buf_parts.part-code skip
                    "buf_parts.price-base"       buf_parts.price-base skip
                    "buf_parts.price-rubl"       buf_parts.price-rubl skip
                    "Откорректируйте цену партии" skip
                    view-as alert-box information .
                  undo, return error return-value .
                end.
              end.
         end.
          define variable v-reason       as character no-undo .
          define variable l-process-part as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run part-prc in g#library
  (buffer buf_parts
  ,buffer ub.trn-doc
  ,input  false
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  false
  ,input  '':u
  ,input  0
  ,input  false
  ,output v-reason
  ,output l-process-part
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении возможности резервирования партии" skip
              "Документ" buf_doc-line.doc-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if l-process-part <> true
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Контроль правильности резервирования порожденных партий" skip
              "Партия ошибочно зарезервирована за документом" skip
              "Документ" buf_doc-line.doc-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              v-reason skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      for each buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtcheck in g#library
  (input l-doc-prt
  ,input buf_gds-dtl.prt-code
  ,input v-root-node
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "В документе используется недопустимый признак" skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
            "На объекте разрешены признаки" l-doc-prt skip
            "Код признака" buf_gds-dtl.prt-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if ub.trn-doc.doc-type <> 'инв':U
        then do:
          if buf_gds-dtl.fact-qnty < 0
          or buf_gds-dtl.doc-qnty  < 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеются партии с отрицательными количествами." skip
              "Документ" ub.trn-doc.doc-code skip
              "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
              "gds-dtl.fact-qnty" buf_gds-dtl.fact-qnty skip
              "gds-dtl.doc-qnty" buf_gds-dtl.doc-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        assign
          v-gds-dtl-fact-qnty = v-gds-dtl-fact-qnty + buf_gds-dtl.fact-qnty
          v-gds-dtl-doc-qnty  = v-gds-dtl-doc-qnty  + buf_gds-dtl.doc-qnty
        .
        if buf_gds-dtl.doc-qnty <> 0
        then do:
          assign
            l-has-gds-dtl = true
          .
        end.
        if  not g#news
        and buf_goods.negative-rest <> true
        and ub.trn-doc.discnt-type <> 'касс':U
        then do:
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  buf_gds-dtl.obj-type
  ,input  buf_gds-dtl.obj-code
  ,input  buf_gds-dtl.artic
  ,input  buf_gds-dtl.prod-type
  ,input  buf_gds-dtl.prod-code
  ,input  buf_gds-dtl.prt-code
  ,buffer ub.prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно найти признак на объекте" skip
              "Документ" buf_gds-dtl.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул"  buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          if ub.prt-obj.fact-qnty < 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Отрицательное количество по признаку на объекте не допустимо" skip
              "Документ" buf_gds-dtl.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
              "buf_gds-dtl.fact-qnty" buf_gds-dtl.fact-qnty skip
              "ub.prt-obj.fact-qnty" ub.prt-obj.fact-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      if buf_goods.gds-type = 'т':U
      then do:
        if  ub.trn-doc.doc-type = 'при':U
        and ub.trn-doc.internal = false
        then do:
          if l-empty-scale
          or v-parts-cli-qnty <> 0
          then do:
            if      buf_doc-line.cli-qnty <> v-parts-cli-qnty and
               abs( buf_doc-line.cli-qnty  - v-parts-cli-qnty ) > 0.001
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "При закрытии документа по факту имеется несоответствие строки документа" skip
                "с количеством по партиям (количество по ТТН)." skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "  " "buf_doc-line.cli-qnty" buf_doc-line.cli-qnty skip
                "  " "v-parts-cli-qnty"  v-parts-cli-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          if buf_doc-line.cli-base-rate = 1
          then do:
            if buf_doc-line.doc-qnty <> buf_doc-line.cli-qnty
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "В строке накладной количество по ТТН не соответсвует количеству по документу" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_doc-line.doc-qnty"      buf_doc-line.doc-qnty      skip
                "buf_doc-line.cli-qnty"      buf_doc-line.cli-qnty      skip
                "buf_doc-line.cli-base-rate" buf_doc-line.cli-base-rate skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
        if ub.trn-doc.doc-type <> 'инв':U
        then do:
          if ub.trn-doc.doc-type = 'при':U
          and ub.trn-doc.internal = false
          and not l-empty-scale
          then do:
            if v-parts-qnty <> 0
            then do:
              if      buf_doc-line.doc-qnty <> v-parts-qnty and
                 abs( buf_doc-line.doc-qnty  - v-parts-qnty ) > 0.001
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "При закрытии документа по факту имеется несоответствие строки документа" skip
                  "с количеством по партиям (количество по документу)." skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                  "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
                  "v-parts-qnty" v-parts-qnty skip
                  "Закрытие документа невозможно." skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
          end.
          else do:
            if      buf_doc-line.doc-qnty <> v-parts-qnty and
               abs( buf_doc-line.doc-qnty  - v-parts-qnty ) > 0.001
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "При закрытии документа по факту имеется несоответствие строки документа" skip
                "с количеством по партиям (количество по документу)." skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
                "v-parts-qnty" v-parts-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
        find first doc-fbr-gds no-lock where (doc-fbr-gds.out-code = buf_doc-line.doc-code or
                                              doc-fbr-gds.out-code = replace(buf_doc-line.doc-code, "=", "-") )
                                         and doc-fbr-gds.gds-code = buf_goods.gds-code
                                         no-error .
        if available doc-fbr-gds
        then do :
          if      buf_doc-line.doc-qnty <> v-parts-fact-qnty and
             abs( buf_doc-line.doc-qnty  - v-parts-fact-qnty ) > 0.001
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеется несоответствие строки (Производство) документа" skip
              "с количеством по партиям (фактическое количество)." skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
              "v-parts-fact-qnty" v-parts-fact-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        else do :
          if      buf_doc-line.fact-qnty <> v-parts-fact-qnty and
             abs( buf_doc-line.fact-qnty  - v-parts-fact-qnty ) > 0.001
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеется несоответствие строки документа" skip
              "с количеством по партиям (фактическое количество)." skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "buf_doc-line.fact-qnty" buf_doc-line.fact-qnty skip
              "v-parts-fact-qnty" v-parts-fact-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      if ub.trn-doc.doc-type <> 'инв':U
      then do:
        if ub.trn-doc.doc-type = 'при':U
        and ub.trn-doc.internal = false
        and not l-empty-scale
        then do:
        end.
        else do:
          if buf_doc-line.doc-qnty <> v-gds-dtl-doc-qnty
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеется несоответствие строки документа" skip
              "с количеством по признакам (количество по документу)." skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
              "v-gds-dtl-doc-qnty" v-gds-dtl-doc-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        if buf_doc-line.fact-qnty <> v-gds-dtl-fact-qnty
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "При закрытии документа по факту имеется несоответствие строки документа" skip
            "с количеством по признакам (фактическое количество)." skip
            "Документ" ub.trn-doc.doc-code skip
            "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "buf_doc-line.fact-qnty" buf_doc-line.fact-qnty skip
            "v-gds-dtl-fact-qnty" v-gds-dtl-fact-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        if  l-empty-scale
        and l-has-gds-dtl
        and buf_doc-line.doc-qnty <> v-gds-dtl-fact-qnty
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "При закрытии документа по факту имеются несоответствие строки документа" skip
            "с количеством по признакам (количество по документу)." skip
            "Документ" ub.trn-doc.doc-code skip
            "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
            "v-gds-dtl-fact-qnty" v-gds-dtl-fact-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if buf_doc-line.fact-qnty <> v-gds-dtl-doc-qnty
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "При закрытии документа по факту имеются несоответствие строки документа" skip
            "с количеством по признакам (фактическое количество)." skip
            "Документ" ub.trn-doc.doc-code skip
            "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "buf_doc-line.fact-qnty" buf_doc-line.fact-qnty skip
            "v-gds-dtl-doc-qnty" v-gds-dtl-doc-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure .
procedure process-line :
  do
  on error undo, return error return-value
  :
    define variable v-root-node like ub.gds-prt.node-code no-undo .
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.
    define variable return-AssMin   as logical   no-undo .
    define variable return-igt      as character no-undo .
    define variable gdop-min-stock  as decimal   no-undo .
    define variable grop-max-stock  as decimal   no-undo .
    define variable grop-level-always-presence  as decimal   no-undo .
    define variable grop-min-order as decimal   no-undo .
    def buffer buf_parts for ub.parts .
    assign
      num_rec   = num_rec + 1
    .
    if num_rec mod 10 = 0
    then do:
      assign
        v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
      .
      display
        num_rec buf_doc-line.artic num_gds v-current-time v-current-action
        with frame a.
    end.
    assign
      buf_doc-line.fact-order   = ub.trn-doc.fact-order
      buf_doc-line.status_      = ub.trn-doc.status_
      buf_doc-line.ext-doc-type = ub.trn-doc.ext-doc-type
    .
    find first buf_inv-line exclusive-lock
      where buf_inv-line.doc-code  = buf_doc-line.doc-code
        and buf_inv-line.artic     = buf_doc-line.artic
        and buf_inv-line.prod-type = buf_doc-line.prod-type
        and buf_inv-line.prod-code = buf_doc-line.prod-code
      no-error.
    if available buf_inv-line then do:
      assign
        buf_inv-line.fact-order   = ub.trn-doc.fact-order
        buf_inv-line.status_      = ub.trn-doc.status_
        buf_inv-line.host-code    = ub.trn-doc.host-code
        buf_inv-line.obj-type     = ub.trn-doc.obj-type
        buf_inv-line.obj-code     = ub.trn-doc.obj-code
        buf_inv-line.ext-doc-type = ub.trn-doc.ext-doc-type
      .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "" (if g#db-num = 0
            then "Если товар был переименован," + chr(10)
               + "необходимо принять новости в УБД и переформировать пакеты"
            else ""
          ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code  = buf_goods.gds-code and
               buf_gds-obj.obj-type  = ub.trn-doc.obj-type and
               buf_gds-obj.obj-code  = ub.trn-doc.obj-code and
               buf_gds-obj.cash-parts = true no-error .
    if available buf_gds-obj then do:
       if par-is-pharm = "yes"   then do:
          buf_doc-line.is-parts = yes .
          run create-price-cash-parts in this-procedure (
                input buf_doc-line.doc-code
              , input buf_goods.gds-code
              , input buf_goods.artic
              , input buf_goods.prod-type
              , input buf_goods.prod-code
              ) no-error .
              if error-status :error  and  return-value = "no-bar-code-parts" then do:
                 buf_doc-line.is-parts = no .
              end.
              if error-status :error  and  return-value <> "no-bar-code-parts" then do:
               message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "Ошибка"
                view-as alert-box error
              .
              end.
       end.
    end.
    if  ub.trn-doc.ext-doc-type = 'ie':U then do:
      if buf_doc-line.unit-cli = "" or buf_doc-line.unit-cli = ? then do:
         buf_doc-line.unit-cli = buf_goods.unit-cli.
      end.
    end.
    if lookup (ub.trn-doc.ext-doc-type,
              'ee':U + "," +
              'ev':U ) <> 0  and
              ((old-doc.status_ = 'накл':U and ub.trn-doc.flag_ = true ) or
                ub.trn-doc.status_ = 'факт':U )
    then do:
      var-ok-assort-pol = true .
      if not (ub.trn-doc.cli-type = 'орг':U or ub.trn-doc.cli-type = 'чел':U) then do:
         v-event-code = substitute("cli_&1-" ,ub.trn-doc.ext-doc-type ) .
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  ub.trn-doc.cli-type
  ,input  ub.trn-doc.cli-code
  ,input  if g#news then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
        end.
        else do:
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  ub.trn-doc.doc-code
  ,output v-is-hold
  )  .
         if v-is-hold then do:
          v-event-code = substitute("cli_mf_&1-" ,ub.trn-doc.ext-doc-type ) .
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  ub.trn-doc.hold-obj-type
  ,input  ub.trn-doc.hold-obj-code
  ,input  if (g#news and not v-not-close-news) then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
          end.
        end.
       if var-ok-assort-pol = false then do:
         if not g#news then do:
            undo, return error var-mess-assort-pol .
         end.
       end.
    end.
    if lookup (ub.trn-doc.ext-doc-type,
              'vt':U + "," +
              'vp':U + "," +
              'we':U + "," +
              'wm':U + ","  +
              'es':U + ","+
              're':U + "," +
              'ep':U + ","  +
              'pc':U + ","  +
              'mp':U + ","  +
              'ap':U   + "," +
              'rv':U  + "," +
              'eo':U  + "," +
              'io':U ) = 0  and
              ((old-doc.status_ = 'накл':U    and ub.trn-doc.flag_ = true ))
    then do:
      var-ok-assort-pol = true .
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  ub.trn-doc.doc-code
  ,output v-is-hold
  )  .
         if v-is-hold then do:
            v-event-code = substitute("mf_&1-" ,ub.trn-doc.ext-doc-type ) .
         end.
         else do:
            v-event-code = substitute("&1-" ,ub.trn-doc.ext-doc-type ) .
         end.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  if (g#news and not v-not-close-news) then false else true
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
       if var-ok-assort-pol = false then do:
          if not g#news then do:
             undo, return error var-mess-assort-pol .
          end.
       end.
    end.
    if ub.trn-doc.status_ = 'факт':U then do:
      if v-min-ass-exist = false then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ch-amin in g#lib-trn3
( input ub.trn-doc.obj-type
, input ub.trn-doc.obj-code
, input buf_goods.gds-code
, input if g#news or g#auto then false else true
, output v-min-ass-exist
) .
         end.
    end.
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if ub.trn-doc.doc-type <> "рас" then do:
    if (ub.trn-doc.office and buf_goods.gds-type <> 'у':U)
    or (not ub.trn-doc.office and buf_goods.gds-type <> 'т':U)
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип: товар / услуги" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Тип документа, ub.trn-doc.office" ub.trn-doc.office skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Тип товара, buf_goods.gds-type" buf_goods.gds-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    end.
    if buf_doc-line.doc-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задано количество по документу" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_doc-line.fact-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задано фактическое количество" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_doc-line.price-base = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задана базовая учетная цена " skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "buf_doc-line.price-base" buf_doc-line.price-base skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if buf_doc-line.price-rubl = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задана рублевая учетная цена" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "buf_doc-line.price-rubl" buf_doc-line.price-rubl skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable v-process-goods as logical   no-undo .
    if  ub.trn-doc.status_      =  'факт':U
    then do:
      assign
        v-process-goods = true
      .
      if  ub.trn-doc.ext-doc-type = 'pc':U
      and ub.trn-doc.closed       = true
      and loc#side-active = true
      then do:
        assign
          v-process-goods = false
        .
      end.
    end.
    else do:
      assign
        v-process-goods = false
      .
    end.
    if v-process-goods
    then do:
      if ub.trn-doc.doc-type = 'при':U and loc#in-ov
      then do:
        define variable l-in-ov as logical no-undo .
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'in-ov=true'
  ,output l-in-ov
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно установить признак in-ov" skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      if buf_goods.gds-type = 'т':U
      then do:
        run cust_prc in this-procedure
          (buffer ub.trn-doc
          ,buffer buf_doc-line
          ,input  l-is-custm
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры cust_prc" skip
              "Документ" ub.trn-doc.doc-code skip
              error-status :get-message(1) skip
              return-value skip
            view-as alert-box error .
          end.
          undo, return error return-value .
        end.
        run partcopy-update-parts in this-procedure
          (input buf_doc-line.doc-code
          ,input buf_doc-line.obj-type
          ,input buf_doc-line.obj-code
          ,input buf_doc-line.artic
          ,input buf_doc-line.prod-type
          ,input buf_doc-line.prod-code
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры partcopy-update-parts" skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        if not g#news and not v-not-close-news
        then do:
          if  ub.trn-doc.ext-doc-type <> 'ie':U
          and ub.trn-doc.ext-doc-type <> 'im':U
          then do:
            run partcopy-update-doc-line-tot-fact
              (input buf_doc-line.doc-code
              ,input buf_doc-line.artic
              ,input buf_doc-line.prod-type
              ,input buf_doc-line.prod-code
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры partcopy-update-doc-line-tot-fact" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
      end.
      for each buf_gds-dtl
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :
        assign
          num_gds = num_gds + 1
        .
        if not g#news and not v-not-close-news
        then do:
          define variable v-prt-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output v-prt-b-code
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении бар-кода признака" skip
              "Документ" ub.trn-doc.doc-code skip
              "Код товара" buf_goods.gds-code  skip
              "Код признака" buf_gds-dtl.prt-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          define variable v-doc-num    like ub.price-list.doc-num    no-undo .
          define variable v-price-sale like ub.price-list.price-sale no-undo .
          define variable v-road-tax   like ub.price-list.road-tax   no-undo .
          define variable v-excise     like ub.price-list.excise     no-undo .
          if buf_doc-line.is-parts = yes
          or can-find (first buf_gds-obj
                   where buf_gds-obj.gds-code  = buf_goods.gds-code
                     and buf_gds-obj.obj-type  = ub.trn-doc.obj-type
                     and buf_gds-obj.obj-code  = ub.trn-doc.obj-code
                     and buf_gds-obj.cash-parts = true)
          then do:
              for each buf_parts no-lock
              where buf_parts.out-code  = buf_doc-line.doc-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
              :
              find first buf_bar-code no-lock
                   where buf_bar-code.gds-code  = buf_goods.gds-code
                     and buf_bar-code.in-code   = buf_parts.in-code
                     and buf_bar-code.part-code = buf_parts.part-code
                     no-error .
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_parts.obj-type
  ,input  buf_parts.obj-code
  ,input  buf_bar-code.b-code
  ,input  0
  ,input  ub.trn-doc.fact-order
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
                  if error-status :error
                  then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Ошибка при определении цены партии" skip
                      "Документ" ub.trn-doc.doc-code skip
                      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
                      "Код товара" buf_goods.gds-code skip
                      "Бар-код партии" buf_bar-code.b-code skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                  assign v-varsum = v-varsum + v-price-sale * buf_parts.fact-qnty.
              end.
              assign v-price-sale = v-varsum / buf_gds-dtl.fact-qnty .
          end.
          else do:
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  ub.trn-doc.fact-order
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении цены бар-кода" skip
                "Документ" ub.trn-doc.doc-code skip
                "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
                "Код товара" buf_goods.gds-code skip
                "Бар-код" v-prt-b-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          if v-price-sale = ?
          then do:
            assign
              v-price-sale = 0
              v-road-tax   = 0
              v-excise     = 0
            .
          end.
          assign
            buf_gds-dtl.cur-base = v-price-sale
          .
          define variable v-curr-r-b as character no-undo .
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
          if v-curr-r-b = 'base':U
          then do:
            if buf_gds-dtl.cur-base <> buf_gds-dtl.price-base
            then do:
              assign
                buf_gds-dtl.ov = yes
                ub.trn-doc.ov = yes
              .
            end.
            else do:
              assign
                buf_gds-dtl.ov = no
              .
            end.
          end.
          else do:
            if buf_gds-dtl.cur-base <> buf_gds-dtl.price-rubl
            then do:
              assign
                buf_gds-dtl.ov = yes
                ub.trn-doc.ov = yes
              .
            end.
            else do:
              assign
                buf_gds-dtl.ov = no
              .
            end.
          end.
        end.
      end.
      run trndocgs in this-procedure
        (input buf_doc-line.doc-code
        ,input buf_doc-line.artic
        ,input buf_doc-line.prod-type
        ,input buf_doc-line.prod-code
        ,input v-root-node
        ,input g#news
        ,input true
        ,input true
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивов по строке" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Логический номер документа" buf_doc-line.fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure .
procedure init-local-vars :
  do
  on error undo, return error return-value
  :
    if ub.trn-doc.obj-type = 'скл':U
    then do:
      find first ub.store no-lock
        where ub.store.obj-code = ub.trn-doc.obj-code
        .
      assign
        loc#obj-active  = ub.store.active
        loc#in-ov = ub.store.in-ov
      .
    end.
    else do:
      find first ub.shop no-lock
        where ub.shop.obj-code = ub.trn-doc.obj-code
        .
      assign
        loc#obj-active  = yes
        loc#in-ov = ub.shop.in-ov
      .
    end.
  end.
end procedure.
procedure update-archive-parts-on-fact-close :
  do
  on error undo, return error return-value
  :
    for each buf_doc-line
      where buf_doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      for each buf_parts
        where buf_parts.out-code  = ub.trn-doc.doc-code
          and buf_parts.obj-type  = ub.trn-doc.obj-type
          and buf_parts.obj-code  = ub.trn-doc.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :
        assign
          buf_parts.fact-num  = ub.trn-doc.fact-num
          buf_parts.fact-date = ub.trn-doc.fact-date
          buf_parts.doc-type  = ub.trn-doc.doc-type
        .
      end.
    end.
  end.
end procedure.
procedure show-action :
  do
  on error undo, return error return-value
  :
    define input parameter p-action as character no-undo .
    assign
      v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
      v-current-action = p-action
    .
    display
      v-current-time v-current-action
      with frame a.
  end.
end procedure.
procedure process-inquiry :
  do
  on error undo, return error return-value
  :
    run show-action in this-procedure
      (input "Поиск не снятых резервов"
      ).
    for each buf_parts no-lock
      where buf_parts.out-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      message
        vss-workfile vss-revision vss-description skip
        "Найдены не снятые резервы" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
        "Присвоение статуса запрос невозможно" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if  g#news
    and g#db-num            = 0
    and ub.trn-doc.status_  = 'запрос':U
    and ub.trn-doc.flag_    = true
    and ub.trn-doc.doc-type = 'при':U
    and ub.trn-doc.internal = true
    then do:
      run trg/trn-docv.p (input ub.trn-doc.doc-code , output p-error , output v-message ) .
      if p-error = true then do:
        undo, return error v-message .
      end.
      run show-action in this-procedure
        (input "Отправка документа в новости"
        ).
      run str/callnews.p
        (input "trn-doc"
        ,input (buffer ub.trn-doc:handle)
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать ub.trn-doc для отправки в новости" skip
          "Документ" ub.trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if  g#news = false
    and (ub.trn-doc.status_ = 'запрос':U
         and ub.trn-doc.flag_ = true
        )
    then do:
      run show-action in this-procedure
        (input "Отправка запроса в новости"
        ).
      run str/callnews.p
        (input "trn-doc"
        ,input (buffer ub.trn-doc:handle)
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать trn-doc для отправки в новости" skip
          "Документ" ub.trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure update-doc-sum :
  define input  parameter p-doc-code   as character no-undo .
  define input  parameter p-fact-order as decimal   no-undo .
  define buffer buf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer buf_doc-line-sum for ub.doc-line-sum.
  do
  on error undo, return error return-value
  :
    for each buf_trn-doc-sum exclusive-lock
      where buf_trn-doc-sum.doc-code = p-doc-code
    on error undo, return error return-value
    :
      assign
        buf_trn-doc-sum.fact-order = p-fact-order
      .
    end.
    for each buf_doc-line-sum exclusive-lock
      where buf_doc-line-sum.doc-code = p-doc-code
    on error undo, return error return-value
    :
      assign
        buf_doc-line-sum.fact-order = p-fact-order
      .
    end.
  end.
end procedure.
procedure check-close-back-date :
  do
  on error undo, return error return-value
  :
  end.
end procedure.
procedure trn-doc-cmd-chance-h-fo :
define input  parameter p-doc-code as character no-undo .
  do
  on error undo, return error return-value
  :
    if  not g#news  and g#db-num <> 0 then do:
        run trg/cmd-trnf.p ( input p-doc-code , "fo", "0") no-error .
        if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "cmd-trnf.p"
          view-as alert-box error
        .
        return error return-value .
        end.
    end.
  end.
end procedure.
procedure trn-doc-cmd-chance-h-factur :
define input  parameter p-doc-code as character no-undo .
  do
  on error undo, return error return-value
  :
    if  not g#news  and g#db-num <> 0 then do:
        run trg/cmd-trnf.p ( input p-doc-code , "factur", "0") no-error .
        if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "cmd-trnf.p"
          view-as alert-box error
        .
        return error return-value .
        end.
    end.
  end.
end procedure.
procedure create-price-cash-parts :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-artic    as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define variable v-value  as decimal   no-undo .
define variable v-doc-num    like ub.price-list.doc-num    no-undo .
define variable v-price-sale like ub.price-list.price-sale no-undo .
define variable v-road-tax   like ub.price-list.road-tax   no-undo .
define variable v-excise     like ub.price-list.excise     no-undo .
define variable v-b-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define buffer buf_parts   for ub.parts  .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-price-target as character no-undo .
define variable v-price-target-type as character no-undo .
  do
  on error undo, return error return-value
  :
find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = p-doc-code no-error .
    for each buf_parts no-lock where
             buf_parts.out-code  = p-doc-code  and
             buf_parts.obj-type  = buf_trn-doc.obj-type  and
             buf_parts.obj-code  = buf_trn-doc.obj-code  and
             buf_parts.artic     = p-artic     and
             buf_parts.prod-type = p-prod-type and
             buf_parts.prod-code = p-prod-code :
            run lineattr-value-parts (
                 input p-doc-code
                ,input p-gds-code
                ,input buf_parts.part-code
                ,input buf_parts.in-code
                ,input 'parts_price-sale':U
                ,output v-value ) .
          if v-value = 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output v-b-code
  ) no-error .
              if error-status :error  or v-b-code = 0 then return error "no-bar-code-parts".
              v-obj-type = buf_trn-doc.obj-type .
              v-obj-code = buf_trn-doc.obj-code .
               if buf_trn-doc.ext-doc-type = 'iv':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'price-target':U ,
                       output v-price-target ,
                       output v-price-target-type )  .
                    if v-price-target <> "yes"  then do:
                       v-obj-type = buf_trn-doc.cli-type .
                       v-obj-code = buf_trn-doc.cli-code .
                    end.
                 end.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
            run lineattr-write-parts (
                input p-doc-code
                ,input p-gds-code
                ,input buf_parts.part-code
                ,input buf_parts.in-code
                ,input 'parts_price-sale':U
                ,input v-price-sale
                ) no-error .
          end.
  end.
  end.
end procedure.
