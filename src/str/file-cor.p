block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: Пт июн 26 16:47:04 2020 +0300 $
$Workfile: file-cor.p $
$Archive: str/file-cor.p $

Сканирование из файла с форматом бар-код,цена в национальной валюте за базовую единицу измерения[,количество] в документ коррекция учетной цены

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/14/05

На один товар может быть несколько строк. Только в последней из них может быть не указано количество, что означает 'на все свободное количество'.

*/
define input  parameter parparentproc as   handle              no-undo.
define input  parameter pardoc-code   like ub.trn-doc.doc-code no-undo.
define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт июн 26 16:47:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: file-cor.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/file-cor.p $":U .
define variable vss-description as character no-undo init "Коррекция партий".
{ cmp/str-glbl.i }
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/libbcrcn.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i noprocess  }
{ gbl/cur-time.i }
{ str/hvrdtax.i  }
{ cmp/strcodec.i }
{ str/trdcalib.i }
{ trg/holdprts.i }
{ str/clcprtsl.i }

define buffer bf_trn-doc           for ub.trn-doc.
define buffer bf_bar-code          for ub.bar-code.
define buffer bf_prod-bc           for ub.prod-bc.
define buffer bf_place             for ub.place.
define buffer bf_goods             for ub.goods.
define buffer bf-free_parts        for ub.parts.
define buffer bf_doc-line          for ub.doc-line.
define buffer bf_contract          for ub.contract.
define buffer bf-new_parts         for ub.parts.
define buffer bf_parts-root        for ub.parts-root.
define buffer bf_gds-dtl           for ub.gds-dtl.
define buffer bf_units             for ub.units.
define buffer bf-have_parts        for ub.parts.
define buffer bf_parts-attr        for ub.parts-attr.
Define buffer bf_parts             for ub.parts.
define buffer bf_trn-doc-sum       for ub.trn-doc-sum.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
define buffer bf_doc-line-sum      for ub.doc-line-sum.
define buffer bf_inv-line          for ub.inv-line.
define buffer bf-in_inv-line       for ub.inv-line.
define buffer bf-in_doc-line       for ub.doc-line.
define temp-table tt-in no-undo
field ln  as integer
field str as character
index pi is unique primary ln.

define temp-table tt-goods-query no-undo
field ln        as   integer
field gds-code  like ub.goods.gds-code
field price     like ub.price-list.price-sale
field rsrv-qnty like ub.doc-line.fact-qnty
index pi is unique primary ln gds-code
index gds-code gds-code.

define temp-table tt-free-parts no-undo like ub.parts.

define stream scan-file.
define stream str-log.
define stream str-err.
define variable varlog          as   logical              no-undo.
define variable varvalue        as   character            no-undo.
define variable vartype         as   character            no-undo.
define variable varline-file    as   character            no-undo.
define variable varscan-txt     as   character            no-undo.
define variable varscan-name    as   character            no-undo.
define variable varuser-action  as   character            no-undo.
define variable varprinted      as   logical              no-undo.
define variable varerr          as   logical              no-undo.
define variable varfile-str     as   character            no-undo.
define variable varnum          as   integer              no-undo.
define variable vartime         as   integer              no-undo.
define variable varcode         as   character            no-undo.
define variable varprice        as   decimal              no-undo.
define variable varqnty         as   decimal              no-undo.
define variable varresult       as   character            no-undo.
define variable vartype-bc      as   character            no-undo.
define variable varweight       as   character            no-undo.
define variable varrec-line     as   recid                no-undo.
define variable varn-c          like ub.gds-prt.node-code no-undo.
define variable varunrsrv-qnty  as   decimal              no-undo.
define variable l-goods-twounit as   logical              no-undo.
define variable varfree-qnty    as   decimal              no-undo.
define variable vartext         as   character            no-undo.
define variable varis-rsrv      as   logical              no-undo.
define variable varpart-code    like ub.parts.part-code   no-undo.
define variable varis-petrolium as   logical              no-undo.
define variable varis-pieces    as   logical              no-undo.
define variable l-inv-on        as   logical              no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code exclusive-lock no-error.
if not available bf_trn-doc then do:
 return error substitute ("Не найден документ с номером .", pardoc-code).
end.
if bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price} then do:
  return error substitute ("Документ с номером &1 не является документом коррекции учетной цены.", pardoc-code).
end.
system-dialog get-file varscan-txt
  title "Выберите файл со сканера"
  update varlog.
if not varlog then do:
  return error.
end.
if entry (2, varscan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return error.
end.
{ str/tdat-val.i
    bf_trn-doc.doc-code
    {&trdcattr-scanfile}
    varvalue
    vartype
    no-error
}
if lookup (varscan-txt, varvalue) <> 0 then do:
  message "Файл с названием " varscan-txt " уже загружался в документ " bf_trn-doc.doc-code " ." skip
          "Продолжить?" view-as alert-box question buttons yes-no update varlog.
  if varlog <> yes then do:
    return error.
  end.
end.
else do:
  assign
    varline-file = varvalue + min (",", varvalue) + varscan-txt no-error.
  { str/tdat-wrt.i
      bf_trn-doc.doc-code
      {&trdcattr-scanfile}
      varline-file
      no-error
  }
end.
assign
  varscan-name = entry (1, varscan-txt, ".").
  { str/sclspref.i }
input  stream scan-file from value (varscan-txt).
output stream str-log   to   value (varscan-name + ".log").
output stream str-err   to   value (varscan-name + ".err").
put stream str-log unformatted "  " skip.
put stream str-log unformatted cur-time-string-sec() skip.
put stream str-log unformatted " " skip skip "Накладная: " bf_trn-doc.doc-code " Расширенный тип: " bf_trn-doc.ext-doc-type  " Статус: " bf_trn-doc.status_ + string (bf_trn-doc.flag_, "+/-") skip skip.
run waitfram-show in this-procedure ("Считывание файла : " + varscan-txt).
assign
  vartime = time
  varnum  = 0.
repeat :
  assign
    varfile-str = "":u.
  import stream scan-file unformatted varfile-str.
  if varfile-str <> "" and
     varfile-str <> ?  then do:
    assign
     varnum = varnum + 1.
    run waitfram-show in this-procedure (substitute("Загрузка файла. Всего считано &1. Время &2.", varnum, string (time - vartime, "hh:mm:ss"))).
    create tt-in.
    assign tt-in.ln  = varnum.
           tt-in.str = varfile-str.
    put stream str-log unformatted tt-in.ln ": Загружена строка " tt-in.str skip.
    release tt-in.
  end.
end.
run waitfram-show in this-procedure (substitute ("Разбор данных из файла : &1", varscan-txt)).
assign
  varnum = 0.
tt-in_cycle:
for each tt-in on error undo, return error return-value :
  assign
    varnum = varnum + 1.
  if num-entries(tt-in.str) < 2 or
     num-entries(tt-in.str) > 3 then do:
     put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln ". Неверное число параметров в строке " tt-in.str ". Должно быть 2 или 3 параметра в соответствии с форматом 'код,цена[,кол-во]'." skip.
     assign
       varerr = yes.
     next tt-in_cycle.
  end.
  assign
    varcode = entry (1, tt-in.str).
  assign
    varprice = decimal (entry (2, tt-in.str)) no-error.
  if error-status :error then do:
    put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln ". Неверный формат цены (2-ой параметр) " tt-in.str ". Он должен соответсвовать формату decimal." skip.
    assign
      varerr = yes.
    next tt-in_cycle.
  end.
  if num-entries (tt-in.str) = 3 then do:
    assign
      varqnty = decimal (entry (3, tt-in.str)) no-error.
    if error-status :error or varqnty = 0 then do:
      put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln ". Неверный формат количества (3-ий параметр) " tt-in.str ". Он должен соответсвовать формату decimal." skip.
      assign
        varerr = yes.
      next tt-in_cycle.
    end.
  end.
  else do:
    assign
      varqnty = ?.
  end.
  { str/bc-rcnz.i
    parparentproc
    varcode
    ?
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    no
    no
    varscales-pref
    varpgscales-pref
    varresult
    vartype-bc
    varweight
    bf_bar-code
    bf_prod-bc
    bf_place
    no-error
  }
  if error-status :error then do:
    put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln ". Код " varcode ": " return-value skip.
    assign
      varerr = yes.
    next tt-in_cycle.
  end.
  if not available bf_bar-code then do:
    put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln ". Не идентифицирован товар по коду " varcode "." skip.
    assign
      varerr = yes.
    next tt-in_cycle.
  end.
  find first bf_goods where bf_goods.gds-code = bf_bar-code.gds-code no-lock no-error.
  if not available bf_goods then do:
    put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln ". Не найден товар по коду " varcode ". Внутренний код товара из бар-кода " bf_bar-code.gds-code skip.
    assign
      varerr = yes.
    next tt-in_cycle.
  end.
  if varqnty <> ? then do:
    find first tt-goods-query where tt-goods-query.gds-code  = bf_goods.gds-code and
                                    tt-goods-query.rsrv-qnty = ?                 no-error.
    if available tt-goods-query then do:
      put stream str-err unformatted "Ошибка при разборе строки номер " tt-in.ln " . Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " . В строке явно указано количество " varqnty " .В уже считаной строке номер " tt-goods-query.ln " по этому товару не указано количество, т.е. она распространяется на все свободное количество. Такое определение строк в файле недопустимо. Пропускаем строку. " skip.
      assign
        varerr = yes.
      next tt-in_cycle.
    end.
  end.
  create tt-goods-query.
  assign
    tt-goods-query.ln         = tt-in.ln
    tt-goods-query.gds-code   = bf_goods.gds-code
    tt-goods-query.price      = varprice
    tt-goods-query.rsrv-qnty  = varqnty.
  release tt-goods-query.
  run waitfram-show in this-procedure (substitute("Разбор файла. Всего разобрано &1. Время &2.", varnum, string (time - vartime, "hh:mm:ss"))).
end.
assign
  varnum = 0.
tt-goods-query_cycle:
for each tt-goods-query on error undo, return error return-value :
  find first bf_goods where bf_goods.gds-code  = tt-goods-query.gds-code no-lock.
  find first bf_units where bf_units.unit-name = bf_goods.unit-base      no-lock.
  assign
    varnum = varnum + 1.
  find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                               bf_doc-line.artic     = bf_goods.artic      and
                               bf_doc-line.prod-type = bf_goods.prod-type  and
                               bf_doc-line.prod-code = bf_goods.prod-code  exclusive-lock no-error.
  if not available bf_doc-line then do:
    { str/chkgdsd.i recid(bf_trn-doc) recid(bf_goods) no-error }
    if error-status:error then do:
      put stream str-err unformatted "Ошибка при обработке строки " tt-goods-query.ln " " return-value skip.
      assign
        varerr = yes.
      undo, next tt-goods-query_cycle.
    end.
    { str/addcorln.i recid(bf_trn-doc) recid(bf_goods) varrec-line no-error }
    if error-status:error then do:
      put stream str-err unformatted "Ошибка при добавлении строки документа по строке " tt-goods-query.ln " " return-value skip.
      assign
        varerr = yes.
      undo, next tt-goods-query_cycle.
    end.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = bf_trn-doc.doc-code and
                               bf_doc-line.artic     = bf_goods.artic      and
                               bf_doc-line.prod-type = bf_goods.prod-type  and
                               bf_doc-line.prod-code = bf_goods.prod-code  .

  find first bf-free_parts where bf-free_parts.host-code     = bf_trn-doc.host-code     and
                                 bf-free_parts.supp-type     = bf_trn-doc.cli-type      and
                                 bf-free_parts.supp-code     = bf_trn-doc.cli-code      and
                                 bf-free_parts.status_       = no                       and
                                 bf-free_parts.obj-type      = bf_trn-doc.obj-type      and
                                 bf-free_parts.obj-code      = bf_trn-doc.obj-code      and
                                 bf-free_parts.rsrv-free     = yes                      and
                                 bf-free_parts.out-code      = {&free-code}             and
                                 bf-free_parts.prod-type     = bf_goods.prod-type       and
                                 bf-free_parts.prod-code     = bf_goods.prod-code       and
                                 bf-free_parts.artic         = bf_goods.artic           and
                                 bf-free_parts.contract-code = bf_trn-doc.contract-code no-lock no-error.
  if not available bf-free_parts then do:
    if bf_trn-doc.contract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = bf_trn-doc.host-code     and
                                   bf_contract.contract-code = bf_trn-doc.contract-code no-lock.
    end.
    put stream str-err unformatted "Ошибка при обработке строки " tt-goods-query.ln " "
            "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name "."
            "Объект: " bf_trn-doc.obj-type " " bf_trn-doc.obj-code
            "Поставщик " bf_trn-doc.cli-type " " bf_trn-doc.cli-code " " bf_trn-doc.cli-name " "
            (if available bf_contract then "Договор " + bf_contract.contract-prn-code else "")
            "Нет товара от поставщика в свободной зоне на объекте."
            "Пропускаем." skip.
    assign
      varerr = yes.
    undo, next tt-goods-query_cycle.
  end.
  { gbl/termnode.i bf_goods.prt-root varn-c }
  find first bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prt-code  = varn-c .
  assign
    varunrsrv-qnty = tt-goods-query.rsrv-qnty.
  /*резервируем по всей свободной зоне*/
  free_parts_cycle:
  for each bf-free_parts where bf-free_parts.host-code     = bf_trn-doc.host-code     and
                               bf-free_parts.supp-type     = bf_trn-doc.cli-type      and
                               bf-free_parts.supp-code     = bf_trn-doc.cli-code      and
                               bf-free_parts.status_       = no                       and
                               bf-free_parts.obj-type      = bf_trn-doc.obj-type      and
                               bf-free_parts.obj-code      = bf_trn-doc.obj-code      and
                               bf-free_parts.rsrv-free     = yes                      and
                               bf-free_parts.out-code      = {&free-code}             and
                               bf-free_parts.prod-type     = bf_doc-line.prod-type    and
                               bf-free_parts.prod-code     = bf_doc-line.prod-code    and
                               bf-free_parts.artic         = bf_doc-line.artic        and
                               bf-free_parts.contract-code = bf_trn-doc.contract-code on error undo, return error return-value :
    { gbl/gdsat.i bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code "'twounit=request':u"  l-goods-twounit no-error }
    if tt-goods-query.rsrv-qnty = ? then do:
      assign
        varfree-qnty = - bf-free_parts.fact-qnty.
    end.
    else do:
     if bf-free_parts.fact-qnty > varunrsrv-qnty then do:
        assign
          varfree-qnty = - varunrsrv-qnty.
      end.
      else do:
        assign
          varfree-qnty = - bf-free_parts.fact-qnty.
      end.
    end.

    { gbl/part-prc.i
      bf-free_parts
      bf_trn-doc
      yes
      bf-free_parts.in-code
      bf-free_parts.part-code
      0
      l-goods-twounit
      "'':u"
      varfree-qnty
      "true"
      vartext
      varis-rsrv
      no-error
    }
    if error-status:error then do:
      if tt-goods-query.rsrv-qnty = ? then do:
        assign
          varerr = yes.
        put stream str-err unformatted substitute ("Ошибка при проверке возможности резервирования партии &1", return-value) skip.
      end.
      undo, next free_parts_cycle.
    end.
    if varis-rsrv <> yes then do:
      if tt-goods-query.rsrv-qnty = ? then do:
        assign
          varerr = yes.
        put stream str-err unformatted substitute ("Нельзя резервировать партию &1 &2 &3 &4 &5 &6 &7", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name, bf-free_parts.in-code, bf-free_parts.part-code, vartext) skip.
      end.
      undo, next free_parts_cycle.
    end.
    /*После резервирования, буффер партии может уходить в расходную зону и быть недоступным*/
    for each tt-free-parts on error undo, return error return-value :
      delete tt-free-parts.
    end.
    create tt-free-parts.
    buffer-copy bf-free_parts to tt-free-parts.
    run trg/rsrv-dtl.p ( parparentproc,
                     {&rsrv-dtl_action_reserv}
             + "," + {&rsrv-dtl_rsrv-single-part}
             + "," + {&rsrv-dtl_rsrv-in-code}   + "=" + str-encode(bf-free_parts.in-code,   "", ",=":u)
             + "," + {&rsrv-dtl_rsrv-part-code} + "=" + str-encode(bf-free_parts.part-code, "", ",=":u)
            , buffer bf_gds-dtl, input-output varfree-qnty, input-output bf_doc-line.price-base, input-output bf_doc-line.price-rubl, -1, "") no-error.
    if error-status :error then do:
      if tt-goods-query.rsrv-qnty = ? then do:
        assign
          varerr = yes.
        put stream str-err unformatted substitute ("Ошибка при вызове процедуры rsrv-dtl &1 по партии &2 &3 &4 &5 &6 &7", return-value, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name, bf-free_parts.in-code, bf-free_parts.part-code) skip.
      end.
      undo, next free_parts_cycle.
    end.
    if varfree-qnty <> 0 then do:
      /*Создаем порожденную партию, на зарезервированное количество*/
      if lookup({&serial}, bf_units.type) > 0 then do:
        find first bf-have_parts where bf-have_parts.obj-type  = tt-free-parts.obj-type  and
                                       bf-have_parts.obj-code  = tt-free-parts.obj-code  and
                                       bf-have_parts.artic     = tt-free-parts.artic     and
                                       bf-have_parts.prod-type = tt-free-parts.prod-type and
                                       bf-have_parts.prod-code = tt-free-parts.prod-code and
                                       bf-have_parts.in-code   = tt-free-parts.out-code  and
                                       bf-have_parts.out-code  = tt-free-parts.out-code  and
                                       bf-have_parts.part-code = tt-free-parts.part-code no-lock no-error.

        if available bf-have_parts then do:
          put stream str-err unformatted substitute ("Товар &1 &2 &3 &4 - серийный. Делаем коррекцию учетной цены по партии с кодом &5. Но в документе уже есть порожденная партия этого товара с таким кодом, либо в данном процессе должны породиться две партии с таким кодом.", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name, bf-have_parts.part-code).
          undo, next free_parts_cycle.
        end.
        else do:
          assign
            varpart-code = tt-free-parts.part-code.
        end.
      end.
      else do:
        run holdprts-get-part-code in this-procedure ( input  bf_trn-doc.doc-code
                                                      ,output varpart-code
                                                      ) no-error .
        if error-status:error then do:
          undo, return error substitute ("Ошибка при получении кода партии &1.", return-value).
        end.
      end.
      create bf-new_parts .
      buffer-copy tt-free-parts
      except in-code
             out-code
             part-code
             rsrv-free
             status_
             qnty
             fact-qnty
             real-qnty
             cli-qnty
             price-rubl
             price-base
             road-tax-rubl
             road-tax-base
             transport-rubl
             transport-base
             other-rubl
             other-base
             price-cli
             cli-base-rate
             vat-type
             slt-type
             exch-code
             to bf-new_parts.
      assign
        bf-new_parts.in-code         = bf_trn-doc.doc-code
        bf-new_parts.out-code        = bf_trn-doc.doc-code
        bf-new_parts.part-code       = varpart-code
        bf-new_parts.rsrv-free       = ?
        bf-new_parts.status_         = no
        bf-new_parts.qnty            = - varfree-qnty
        bf-new_parts.fact-qnty       = - varfree-qnty
        bf-new_parts.real-qnty       = 0
        bf-new_parts.price-rubl      = tt-goods-query.price
        bf-new_parts.road-tax-rubl   = tt-free-parts.road-tax-rubl
        bf-new_parts.transport-rubl  = tt-free-parts.transport-rubl
        bf-new_parts.other-rubl      = tt-free-parts.other-rubl
        .
      find first bf_parts-attr where bf_parts-attr.in-code   = tt-free-parts.in-code   and
                                     bf_parts-attr.gds-code  = bf_goods.gds-code       and
                                     bf_parts-attr.part-code = tt-free-parts.part-code no-error.
      if available bf_parts-attr then do:
        assign
          bf-new_parts.price-base      = bf-new_parts.price-rubl     / bf_parts-attr.base-rate * bf_parts-attr.base-scale
          bf-new_parts.road-tax-base   = bf-new_parts.road-tax-rubl  / bf_parts-attr.base-rate * bf_parts-attr.base-scale
          bf-new_parts.transport-base  = bf-new_parts.transport-rubl / bf_parts-attr.base-rate * bf_parts-attr.base-scale
          bf-new_parts.other-base      = bf-new_parts.other-rubl     / bf_parts-attr.base-rate * bf_parts-attr.base-scale
          bf-new_parts.exch-code       = tt-free-parts.exch-code
          bf-new_parts.cli-base-rate   = tt-free-parts.cli-base-rate
          bf-new_parts.cli-qnty        = - varfree-qnty / tt-free-parts.cli-base-rate
          bf-new_parts.vat-type        = {&inc-vat}
          bf-new_parts.slt-type        = {&inc-slt}
          bf-new_parts.price-cli       = bf-new_parts.price-rubl * bf-new_parts.cli-base-rate / bf_parts-attr.exch-rate * bf_parts-attr.exch-scale
        .
      end.
      else do:
        assign
          bf-new_parts.price-base      = bf-new_parts.price-rubl     / tt-free-parts.price-rubl * tt-free-parts.price-base
          bf-new_parts.road-tax-base   = bf-new_parts.road-tax-rubl  / tt-free-parts.price-rubl * tt-free-parts.price-base
          bf-new_parts.transport-base  = bf-new_parts.transport-rubl / tt-free-parts.price-rubl * tt-free-parts.price-base
          bf-new_parts.other-base      = bf-new_parts.other-rubl     / tt-free-parts.price-rubl * tt-free-parts.price-base
          bf-new_parts.exch-code       = 0
          bf-new_parts.cli-base-rate   = 1
          bf-new_parts.cli-qnty        = - varfree-qnty
          bf-new_parts.vat-type        = {&inc-vat}
          bf-new_parts.slt-type        = {&inc-slt}
          bf-new_parts.price-cli       = bf-new_parts.price-rubl
        .
      end.
      /*Создаем связку между партиями*/
      find first bf_parts-root where
                 bf_parts-root.doc-code       = bf-new_parts.out-code
           and   bf_parts-root.in-code        = bf-new_parts.in-code
           and   bf_parts-root.gds-code       = bf_goods.gds-code
           and   bf_parts-root.part-code      = bf-new_parts.part-code
           and   bf_parts-root.orig-in-code   = bf-free_parts.in-code
           and   bf_parts-root.orig-gds-code  = bf_goods.gds-code
           and   bf_parts-root.orig-part-code = bf-free_parts.part-code no-error .
      if not available bf_parts-root then do:
        create bf_parts-root.
        assign
          bf_parts-root.doc-code       = bf-new_parts.out-code
          bf_parts-root.in-code        = bf-new_parts.in-code
          bf_parts-root.gds-code       = bf_goods.gds-code
          bf_parts-root.part-code      = bf-new_parts.part-code
          bf_parts-root.orig-in-code   = tt-free-parts.in-code
          bf_parts-root.orig-gds-code  = bf_goods.gds-code
          bf_parts-root.orig-part-code = tt-free-parts.part-code
        .
      end.
    end.
    else do: /*ничего не зарезервировалось*/
      if tt-goods-query.rsrv-qnty = ? then do:
        assign
          varerr = yes.
        put stream str-err unformatted substitute ("Ошибка при вызове процедуры rsrv-dtl &1 по партии &2 &3 &4 &5 &6 &7", return-value, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name, bf-free_parts.in-code, bf-free_parts.part-code) skip.
      end.
      undo, next free_parts_cycle.
    end.
    if tt-goods-query.rsrv-qnty <> ? then do:
      assign
        varunrsrv-qnty = varunrsrv-qnty + varfree-qnty.
      if varunrsrv-qnty = 0 then do:
        next tt-goods-query_cycle.
      end.
    end.
  end. /*free_parts_cycle*/
  if tt-goods-query.rsrv-qnty <> ? and
     varunrsrv-qnty           <  0 then do:
    undo, return error substitute ("Критическая ошибка. Заререзервировали большее количество &1, чем предпологалось &2.", tt-goods-query.rsrv-qnty - varunrsrv-qnty, tt-goods-query.rsrv-qnty).
  end.
  if tt-goods-query.rsrv-qnty <> ? and
     varunrsrv-qnty           >  0 then do:
    assign
      varerr = yes.
    put stream str-err unformatted substitute ("Не удалось зарезервировать все количество по строке &1. Товар &2 &3 &4 &5. Предпологалось &6. Зарезервировано &7.", tt-goods-query.ln, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name, tt-goods-query.rsrv-qnty, tt-goods-query.rsrv-qnty - varunrsrv-qnty) skip.
  end.
  run waitfram-show in this-procedure (substitute("Создание строк коррекции по данным из файла. Всего обработано &1. Время &2.", varnum, string (time - vartime, "hh:mm:ss"))).
end. /*goods-query_cycle*/
/*Удаляем пустые строки и рассчитываем суммы по строкам*/
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
  find first bf_parts where bf_parts.out-code  = bf_doc-line.doc-code  and
                            bf_parts.obj-type  = bf_trn-doc.obj-type   and
                            bf_parts.obj-code  = bf_trn-doc.obj-code   and
                            bf_parts.artic     = bf_doc-line.artic     and
                            bf_parts.prod-type = bf_doc-line.prod-type and
                            bf_parts.prod-code = bf_doc-line.prod-code no-error.
  if not available bf_parts then do:
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
      delete bf_gds-dtl.
    end.
    find first gds-obj where gds-obj.obj-type = bf_trn-doc.obj-type and
                             gds-obj.obj-code = bf_trn-doc.obj-code and
                             gds-obj.artic    = bf_doc-line.artic   and
                             gds-obj.prod-type = bf_doc-line.prod-type and
                             gds-obj.prod-code = bf_doc-line.prod-code.
    { gbl/gdsobjat.i
      bf_doc-line.obj-type
      bf_doc-line.obj-code
      bf_doc-line.artic
      bf_doc-line.prod-type
      bf_doc-line.prod-code
      "'inv-on=false'"
      l-inv-on
      no-error
    }
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка установки атрибута товара на объекте" skip
      "Документ" bf_doc-line.doc-code skip
      "Объект" bf_doc-line.obj-type bf_doc-line.obj-code skip
      "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
      "l-inv-on" l-inv-on skip
      view-as alert-box error .
      undo, return error .
    end.
    delete bf_doc-line.
  end.
  else do:
    find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                              bf_goods.prod-type = bf_doc-line.prod-type and
                              bf_goods.prod-code = bf_doc-line.prod-code no-lock.
    { str/is-petrl.i
      bf_doc-line.artic
      bf_doc-line.prod-type
      bf_doc-line.prod-code
      varis-petrolium
      varis-pieces
    }

    /*Удалим все старые суммы по строке*/
    for each bf_doc-line-sum where bf_doc-line-sum.doc-code  = bf_doc-line.doc-code  and
                                   bf_doc-line-sum.gds-code  = bf_goods.gds-code     exclusive-lock on error undo, return error return-value :
      delete bf_doc-line-sum.
    end.
    find last bf-in_doc-line where bf-in_doc-line.obj-type  = bf_trn-doc.obj-type   and
                                   bf-in_doc-line.obj-code  = bf_trn-doc.obj-code   and
                                   bf-in_doc-line.artic     = bf_doc-line.artic     and
                                   bf-in_doc-line.prod-type = bf_doc-line.prod-type and
                                   bf-in_doc-line.prod-code = bf_doc-line.prod-code and
                                   bf-in_doc-line.status_   = {&fact}               use-index fact-order no-lock no-error.
    if available bf-in_doc-line then do:
      find first bf-in_inv-line where bf-in_inv-line.doc-code  = bf-in_doc-line.doc-code  and
                                      bf-in_inv-line.artic     = bf-in_doc-line.artic     and
                                      bf-in_inv-line.prod-type = bf-in_doc-line.prod-type and
                                      bf-in_inv-line.prod-code = bf-in_doc-line.prod-code no-error.
    end.
    /*Заполним топливные характеристики строки*/
    if varis-petrolium  and
       not varis-pieces then do:
      assign
        bf_doc-line.doc-density  = bf-in_doc-line.fact-density
        bf_doc-line.fact-density = bf-in_doc-line.fact-density
        .
      create bf_inv-line.
      assign
        bf_inv-line.doc-code       = bf_doc-line.doc-code
        bf_inv-line.artic          = bf_doc-line.artic
        bf_inv-line.prod-type      = bf_doc-line.prod-type
        bf_inv-line.prod-code      = bf_doc-line.prod-code
        bf_inv-line.wast-cli-qnty  = 0
        bf_inv-line.after-cli-qnty = bf-in_inv-line.after-cli-qnty.
    end.
    /*Заполним дополнительные суммы излишек и недостач по партиям*/
    create bf-expp_doc-line-sum.
    assign
      bf-expp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
      bf-expp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-expp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
      bf-expp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
      bf-expp_doc-line-sum.gds-code     = bf_goods.gds-code
      bf-expp_doc-line-sum.sum-type     = {&sum-expense-parts}
    .
    create bf-incp_doc-line-sum.
    assign
      bf-incp_doc-line-sum.doc-code     = bf_trn-doc.doc-code
      bf-incp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type
      bf-incp_doc-line-sum.obj-type     = bf_trn-doc.obj-type
      bf-incp_doc-line-sum.obj-code     = bf_trn-doc.obj-code
      bf-incp_doc-line-sum.gds-code     = bf_goods.gds-code
      bf-incp_doc-line-sum.sum-type     = {&sum-income-parts}
    .
    for each bf_parts where bf_parts.out-code  = bf_trn-doc.doc-code and
                            bf_parts.obj-type  = bf_trn-doc.obj-type and
                            bf_parts.obj-code  = bf_trn-doc.obj-code and
                            bf_parts.artic     = bf_goods.artic      and
                            bf_parts.prod-type = bf_goods.prod-type  and
                            bf_parts.prod-code = bf_goods.prod-code  on error undo, return error return-value :
      for each tt-clcparts :
        delete tt-clcparts.
      end.
      create tt-clcparts.
      buffer-copy bf_parts to tt-clcparts.
      run clcprtsl_calc-parts in this-procedure
         (input recid(tt-clcparts),
          input no,
          input no,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?
         ).

      find first tt-allsum where tt-allsum.sum-type = {&sum-general}.
      if bf_parts.fact-qnty < 0 then do:
         assign
           bf-expp_doc-line-sum.fact-qnty           = bf-expp_doc-line-sum.fact-qnty            - tt-allsum.fact-qnty
           bf-expp_doc-line-sum.cost-sum-base       = bf-expp_doc-line-sum.cost-sum-base        - tt-allsum.sum-dsc-base-acc
           bf-expp_doc-line-sum.cost-sum-rubl       = bf-expp_doc-line-sum.cost-sum-rubl        - tt-allsum.sum-dsc-rubl-acc
           bf-expp_doc-line-sum.cost-vat-base       = bf-expp_doc-line-sum.cost-vat-base        - tt-allsum.vat-base-acc
           bf-expp_doc-line-sum.cost-vat-rubl       = bf-expp_doc-line-sum.cost-vat-rubl        - tt-allsum.vat-rubl-acc
           bf-expp_doc-line-sum.cost-slt-base       = bf-expp_doc-line-sum.cost-slt-base        - tt-allsum.slt-base-acc
           bf-expp_doc-line-sum.cost-slt-rubl       = bf-expp_doc-line-sum.cost-slt-rubl        - tt-allsum.slt-rubl-acc
           bf-expp_doc-line-sum.cost-road-tax-base  = bf-expp_doc-line-sum.cost-road-tax-base   - tt-allsum.road-tax-base-acc
           bf-expp_doc-line-sum.cost-road-tax-rubl  = bf-expp_doc-line-sum.cost-road-tax-rubl   - tt-allsum.road-tax-rubl-acc
           bf-expp_doc-line-sum.cost-excise-base    = bf-expp_doc-line-sum.cost-excise-base     - tt-allsum.excise-base-acc
           bf-expp_doc-line-sum.cost-excise-rubl    = bf-expp_doc-line-sum.cost-excise-rubl     - tt-allsum.excise-rubl-acc
           bf-expp_doc-line-sum.cost-transport-base = bf-expp_doc-line-sum.cost-transport-base  - tt-allsum.transport-base-acc
           bf-expp_doc-line-sum.cost-transport-rubl = bf-expp_doc-line-sum.cost-transport-rubl  - tt-allsum.transport-rubl-acc
           bf-expp_doc-line-sum.cost-other-base     = bf-expp_doc-line-sum.cost-other-base      - tt-allsum.other-base-acc
           bf-expp_doc-line-sum.cost-other-rubl     = bf-expp_doc-line-sum.cost-other-rubl      - tt-allsum.other-rubl-acc
         .
      end.
      else do:
         assign
           bf-incp_doc-line-sum.fact-qnty           = bf-incp_doc-line-sum.fact-qnty            + tt-allsum.fact-qnty
           bf-incp_doc-line-sum.cost-sum-base       = bf-incp_doc-line-sum.cost-sum-base        + tt-allsum.sum-dsc-base-acc
           bf-incp_doc-line-sum.cost-sum-rubl       = bf-incp_doc-line-sum.cost-sum-rubl        + tt-allsum.sum-dsc-rubl-acc
           bf-incp_doc-line-sum.cost-vat-base       = bf-incp_doc-line-sum.cost-vat-base        + tt-allsum.vat-base-acc
           bf-incp_doc-line-sum.cost-vat-rubl       = bf-incp_doc-line-sum.cost-vat-rubl        + tt-allsum.vat-rubl-acc
           bf-incp_doc-line-sum.cost-slt-base       = bf-incp_doc-line-sum.cost-slt-base        + tt-allsum.slt-base-acc
           bf-incp_doc-line-sum.cost-slt-rubl       = bf-incp_doc-line-sum.cost-slt-rubl        + tt-allsum.slt-rubl-acc
           bf-incp_doc-line-sum.cost-road-tax-base  = bf-incp_doc-line-sum.cost-road-tax-base   + tt-allsum.road-tax-base-acc
           bf-incp_doc-line-sum.cost-road-tax-rubl  = bf-incp_doc-line-sum.cost-road-tax-rubl   + tt-allsum.road-tax-rubl-acc
           bf-incp_doc-line-sum.cost-excise-base    = bf-incp_doc-line-sum.cost-excise-base     + tt-allsum.excise-base-acc
           bf-incp_doc-line-sum.cost-excise-rubl    = bf-incp_doc-line-sum.cost-excise-rubl     + tt-allsum.excise-rubl-acc
           bf-incp_doc-line-sum.cost-transport-base = bf-incp_doc-line-sum.cost-transport-base  + tt-allsum.transport-base-acc
           bf-incp_doc-line-sum.cost-transport-rubl = bf-incp_doc-line-sum.cost-transport-rubl  + tt-allsum.transport-rubl-acc
           bf-incp_doc-line-sum.cost-other-base     = bf-incp_doc-line-sum.cost-other-base      + tt-allsum.other-base-acc
           bf-incp_doc-line-sum.cost-other-rubl     = bf-incp_doc-line-sum.cost-other-rubl      + tt-allsum.other-rubl-acc
         .
      end.
    end. /*for each parts*/
  end.
end.
for each bf_trn-doc-sum where bf_trn-doc-sum.doc-code = bf_trn-doc.doc-code exclusive-lock on error undo, return error return-value :
  delete bf_trn-doc-sum.
end.
create bf-expp_trn-doc-sum.
assign
  bf-expp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
  bf-expp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
  bf-expp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
  bf-expp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
  bf-expp_trn-doc-sum.sum-type     = {&sum-expense-parts}.
{ str/tdat-val.i
    bf_trn-doc.doc-code
    {&trdcattr-addsum}
    varvalue
    vartype
}
if lookup( {&sum-expense-parts}, varvalue ) = 0 then do:
  { str/tdat-wrt.i
      bf_trn-doc.doc-code
      {&trdcattr-addsum}
      "( varvalue + min( varvalue, ',' ) + {&sum-expense-parts} )"
  }
end.
create bf-incp_trn-doc-sum.
assign
  bf-incp_trn-doc-sum.doc-code     = bf_trn-doc.doc-code
  bf-incp_trn-doc-sum.ext-doc-type = bf_trn-doc.ext-doc-type
  bf-incp_trn-doc-sum.obj-type     = bf_trn-doc.obj-type
  bf-incp_trn-doc-sum.obj-code     = bf_trn-doc.obj-code
  bf-incp_trn-doc-sum.sum-type     = {&sum-income-parts}.
for each bf-expp_doc-line-sum where bf-expp_doc-line-sum.doc-code     = bf_trn-doc.doc-code     and
                                    bf-expp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type and
                                    bf-expp_doc-line-sum.obj-type     = bf_trn-doc.obj-type     and
                                    bf-expp_doc-line-sum.obj-code     = bf_trn-doc.obj-code     and
                                    bf-expp_doc-line-sum.sum-type     = {&sum-expense-parts}    on error undo, return error return-value :
  assign
    bf-expp_trn-doc-sum.fact-qnty           = bf-expp_trn-doc-sum.fact-qnty           +  bf-expp_doc-line-sum.fact-qnty
    bf-expp_trn-doc-sum.cost-sum-base       = bf-expp_trn-doc-sum.cost-sum-base       +  bf-expp_doc-line-sum.cost-sum-base
    bf-expp_trn-doc-sum.cost-sum-rubl       = bf-expp_trn-doc-sum.cost-sum-rubl       +  bf-expp_doc-line-sum.cost-sum-rubl
    bf-expp_trn-doc-sum.cost-vat-base       = bf-expp_trn-doc-sum.cost-vat-base       +  bf-expp_doc-line-sum.cost-vat-base
    bf-expp_trn-doc-sum.cost-vat-rubl       = bf-expp_trn-doc-sum.cost-vat-rubl       +  bf-expp_doc-line-sum.cost-vat-rubl
    bf-expp_trn-doc-sum.cost-slt-base       = bf-expp_trn-doc-sum.cost-slt-base       +  bf-expp_doc-line-sum.cost-slt-base
    bf-expp_trn-doc-sum.cost-slt-rubl       = bf-expp_trn-doc-sum.cost-slt-rubl       +  bf-expp_doc-line-sum.cost-slt-rubl
    bf-expp_trn-doc-sum.cost-road-tax-base  = bf-expp_trn-doc-sum.cost-road-tax-base  +  bf-expp_doc-line-sum.cost-road-tax-base
    bf-expp_trn-doc-sum.cost-road-tax-rubl  = bf-expp_trn-doc-sum.cost-road-tax-rubl  +  bf-expp_doc-line-sum.cost-road-tax-rubl
    bf-expp_trn-doc-sum.cost-excise-base    = bf-expp_trn-doc-sum.cost-excise-base    +  bf-expp_doc-line-sum.cost-excise-base
    bf-expp_trn-doc-sum.cost-excise-rubl    = bf-expp_trn-doc-sum.cost-excise-rubl    +  bf-expp_doc-line-sum.cost-excise-rubl
    bf-expp_trn-doc-sum.cost-transport-base = bf-expp_trn-doc-sum.cost-transport-base +  bf-expp_doc-line-sum.cost-transport-base
    bf-expp_trn-doc-sum.cost-transport-rubl = bf-expp_trn-doc-sum.cost-transport-rubl +  bf-expp_doc-line-sum.cost-transport-rubl
    bf-expp_trn-doc-sum.cost-other-base     = bf-expp_trn-doc-sum.cost-other-base     +  bf-expp_doc-line-sum.cost-other-base
    bf-expp_trn-doc-sum.cost-other-rubl     = bf-expp_trn-doc-sum.cost-other-rubl     +  bf-expp_doc-line-sum.cost-other-rubl
  .
end.
for each bf-incp_doc-line-sum where bf-incp_doc-line-sum.doc-code     = bf_trn-doc.doc-code     and
                                    bf-incp_doc-line-sum.ext-doc-type = bf_trn-doc.ext-doc-type and
                                    bf-incp_doc-line-sum.obj-type     = bf_trn-doc.obj-type     and
                                    bf-incp_doc-line-sum.obj-code     = bf_trn-doc.obj-code     and
                                    bf-incp_doc-line-sum.sum-type     = {&sum-income-parts}     on error undo, return error return-value :
  assign
    bf-incp_trn-doc-sum.fact-qnty           = bf-incp_trn-doc-sum.fact-qnty           +  bf-incp_doc-line-sum.fact-qnty
    bf-incp_trn-doc-sum.cost-sum-base       = bf-incp_trn-doc-sum.cost-sum-base       +  bf-incp_doc-line-sum.cost-sum-base
    bf-incp_trn-doc-sum.cost-sum-rubl       = bf-incp_trn-doc-sum.cost-sum-rubl       +  bf-incp_doc-line-sum.cost-sum-rubl
    bf-incp_trn-doc-sum.cost-vat-base       = bf-incp_trn-doc-sum.cost-vat-base       +  bf-incp_doc-line-sum.cost-vat-base
    bf-incp_trn-doc-sum.cost-vat-rubl       = bf-incp_trn-doc-sum.cost-vat-rubl       +  bf-incp_doc-line-sum.cost-vat-rubl
    bf-incp_trn-doc-sum.cost-slt-base       = bf-incp_trn-doc-sum.cost-slt-base       +  bf-incp_doc-line-sum.cost-slt-base
    bf-incp_trn-doc-sum.cost-slt-rubl       = bf-incp_trn-doc-sum.cost-slt-rubl       +  bf-incp_doc-line-sum.cost-slt-rubl
    bf-incp_trn-doc-sum.cost-road-tax-base  = bf-incp_trn-doc-sum.cost-road-tax-base  +  bf-incp_doc-line-sum.cost-road-tax-base
    bf-incp_trn-doc-sum.cost-road-tax-rubl  = bf-incp_trn-doc-sum.cost-road-tax-rubl  +  bf-incp_doc-line-sum.cost-road-tax-rubl
    bf-incp_trn-doc-sum.cost-excise-base    = bf-incp_trn-doc-sum.cost-excise-base    +  bf-incp_doc-line-sum.cost-excise-base
    bf-incp_trn-doc-sum.cost-excise-rubl    = bf-incp_trn-doc-sum.cost-excise-rubl    +  bf-incp_doc-line-sum.cost-excise-rubl
    bf-incp_trn-doc-sum.cost-transport-base = bf-incp_trn-doc-sum.cost-transport-base +  bf-incp_doc-line-sum.cost-transport-base
    bf-incp_trn-doc-sum.cost-transport-rubl = bf-incp_trn-doc-sum.cost-transport-rubl +  bf-incp_doc-line-sum.cost-transport-rubl
    bf-incp_trn-doc-sum.cost-other-base     = bf-incp_trn-doc-sum.cost-other-base     +  bf-incp_doc-line-sum.cost-other-base
    bf-incp_trn-doc-sum.cost-other-rubl     = bf-incp_trn-doc-sum.cost-other-rubl     +  bf-incp_doc-line-sum.cost-other-rubl
  .
end.

run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc)) no-error.
if error-status:error then do:
  undo, return error substitute ("Ошибка при пересчете документа &1", return-value).
end.
run waitfram-hide in this-procedure no-error.
input  stream scan-file close.
output stream str-log   close.
output stream str-err   close.
if varerr then do:
  message "При обработке данных из файла произошли ошибки. Дополнительная информация об ошибках в файле " varscan-name + ".err" " ."
  view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки и замечания, возникшие при наполнении документа из файла"
    ,input  0
    ,input  varscan-name + ".err"
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
end.
end.