/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка цен в документе

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
Дата создания: 09/26/05

ПРИ ВКЛЮЧЕНИИ В ФАЙЛ НЕ ЗАБУДЬ ВКЛЮЧИТЬ tax-name.i
*/
&SCOP error-line        if &if "~{&chk-minus~}" = "yes" &then ~{&expr~} < 0 &endif &if "~{&chk-undef~}" = "yes" &then &if "~{&chk-minus~}" = "yes" &then or &endif ~{&expr~} = ? &endif then  ~
                           return error SUBSTITUTE("Ошибка в << &1 : &2 . Документ &3. Расширенный тип &4. Объект &5. Товар &6 &7 &8 &9 &10", ~
                                        ~{&label~},~
                                        ~{&expr~},~
                                        bf_trn-doc.doc-code, ~
                                        bf_trn-doc.ext-doc-type, ~
                                        bf_trn-doc.obj-type + " " + string(bf_trn-doc.obj-code), ~
                                        bf_goods.artic, ~
                                        bf_goods.prod-type, ~
                                        bf_goods.prod-code, ~
                                        bf_goods.gds-name ) ~
                                        ~{&add-mes~} + " >>.".

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
{ gbl/curr-r-b.i varr-b }
run tax-name ({&road-tax},   output varroad-taxname).
run tax-name ({&excise-tax}, output varexcisename).
do on error undo, return error return-value:
   find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
    if not available bf_trn-doc then
        return error SUBSTITUTE("Не найден документ с номером &1 (файл chkprice.i).", pardoc-code).
   if bf_trn-doc.status_ = {&inquiry} then return.
   for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code,
       first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock :

     if bf_trn-doc.doc-type <> {&inventory} then do:
       if bf_doc-line.doc-qnty = 0 and bf_doc-line.fact-qnty = 0 then next.
       &scop chk-minus yes
       &scop add-mes
       &scop chk-undef yes
       &scop expr      bf_doc-line.price-cli
       &scop label     "цена поставщика"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.price-rubl
       &scop label     "учетная цена в {&abbr_rublyah}"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.price-base
       &scop label     "учетная цена в базовой валюте"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.road-tax
       &scop label     varroad-taxname
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.excise
       &scop label     varexcisename
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.transport-base
       &scop label     "транспортные расходы в базовой валюте"
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.transport-rubl
       &scop label     "транспортные расходы в {&abbr_rublyah}"
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.other-base
       &scop label     "прочие расходы в базовой валюте"
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.other-rubl
       &scop label     "прочие расходы в {&abbr_rublyah}"
       {&error-line}
    end.
    else do:
       if bf_doc-line.fact-qnty = 0 then next.
       &scop chk-minus no
       &scop add-mes
       &scop chk-undef yes
       &scop expr      bf_doc-line.price-cli
       &scop label     "цена поставщика"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.price-rubl
       &scop label     "учетная цена в {&abbr_rublyah}"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.price-base
       &scop label     "учетная цена в базовой валюте"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.road-tax
       &scop label     varroad-taxname
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.excise
       &scop label     varexcisename
       {&error-line}
       /*
       &scop chk-undef no
       &scop expr      bf_doc-line.transport-base
       &scop label     "транспортные расходы в базовой валюте"
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.transport-rubl
       &scop label     "транспортные расходы в {&abbr_rublyah}"
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.other-base
       &scop label     "прочие расходы в базовой валюте"
       {&error-line}
       &scop chk-undef no
       &scop expr      bf_doc-line.other-rubl
       &scop label     "прочие расходы в {&abbr_rublyah}"
       {&error-line}
       */
    end.
    &scop chk-minus yes
       &scop chk-undef yes
       &scop expr      bf_doc-line.vat-pc
       &scop label     "ставка НДС"
       {&error-line}
       &scop chk-undef yes
       &scop expr      bf_doc-line.slt-pc
       &scop label     "ставка НП"
       {&error-line}
       for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                                 bf_gds-dtl.artic     = bf_doc-line.artic     and
                                 bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                                 bf_gds-dtl.prod-code = bf_doc-line.prod-code ,
                                 first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code:
           if bf_trn-doc.doc-type <> {&inventory} then do:
             if bf_gds-dtl.doc-qnty = 0 and bf_gds-dtl.fact-qnty = 0 then next.
           end.
           else do:
             if bf_gds-dtl.doc-qnty = 0 then next.
           end.
           &scop add-mes   + (if bf_gds-prt.node-name <> {&empty-scale} and bf_gds-prt.upper-code <> bf_goods.prt-root then  ' - ' + bf_gds-prt.f-name else "")
           &scop chk-undef yes
           &scop expr      bf_gds-dtl.cur-base
           &scop label     "текущая продажная цена"
           {&error-line}
&scop chk-minus no
           &scop chk-undef yes
           &scop expr      bf_gds-dtl.discnt-base
           &scop label     "скидка в базовой валюте"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_gds-dtl.discnt-rubl
           &scop label     "скидка в {&abbr_rublyah}"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_gds-dtl.discnt-pc
           &scop label     "процент скидки"
           {&error-line}
&scop chk-minus yes
           &scop chk-undef yes
           &scop expr      bf_gds-dtl.price-base
           &scop label     "цена по документу в базовой валюте"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_gds-dtl.price-rubl
           &scop label     "цена по документу в {&abbr_rublyah}"
           {&error-line}
           if varr-b = "rubl":u then do:
              &scop chk-undef yes
              &scop expr      bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax
              &scop label     "цена по документу в {&abbr_rublyah} без учета скидки и компоненты " + varroad-taxname + " "
              {&error-line}
              &scop chk-undef yes
              &scop expr      bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale
              &scop label     "цена по документу в базовой валюте без учета скидки и компоненты " + varroad-taxname + " "
              {&error-line}
           end.
           else do:
              &scop chk-undef yes
              &scop expr      bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale
              &scop label     "цена по документу в {&abbr_rublyah} без учета скидки и компоненты " + varroad-taxname + " "
              {&error-line}
              &scop chk-undef yes
              &scop expr      bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - bf_doc-line.road-tax
              &scop label     "цена по документу в базовой валюте без учета скидки и компоненты " + varroad-taxname + " "
              {&error-line}
           end.
       end. /*each bf_gds-dtl*/
       for each bf_parts where bf_parts.out-code  = bf_trn-doc.doc-code   and
                               bf_parts.obj-type  = bf_trn-doc.obj-type   and
                               bf_parts.obj-code  = bf_trn-doc.obj-code   and
                               bf_parts.artic     = bf_doc-line.artic     and
                               bf_parts.prod-type = bf_doc-line.prod-type and
                               bf_parts.prod-code = bf_doc-line.prod-code :
           &scop add-mes   + " код партии " + string(bf_parts.part-code) + " "
           &scop chk-undef yes
           &scop expr      bf_parts.price-cli
           &scop label     "цена поставщика в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.price-rubl
           &scop label     "учетная цена в {&abbr_rublyah} в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.price-base
           &scop label     "учетная цена в базовой валюте в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.vat-pc
           &scop label     "ставка НДС в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.slt-pc
           &scop label     "ставка НП в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.road-tax-base
           &scop label     varroad-taxname + " в базовой валюте в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.road-tax-rubl
           &scop label     varroad-taxname + " в {&abbr_rublyah} в партии"
           {&error-line}
           &scop chk-undef no
           &scop expr      bf_parts.transport-base
           &scop label     "транспортные расходы в базовой валюте в партии"
           {&error-line}
           &scop chk-undef no
           &scop expr      bf_parts.transport-rubl
           &scop label     "транспортные расходы в {&abbr_rublyah} в партии"
           {&error-line}
           &scop chk-undef no
           &scop expr      bf_parts.other-base
           &scop label     "прочие расходы в базовой валюте в партии"
           {&error-line}
           &scop chk-undef no
           &scop expr      bf_parts.other-rubl
           &scop label     "прочие расходы в {&abbr_rublyah} в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.price-rubl - bf_parts.road-tax-rubl - (if bf_parts.transport-rubl <> ? then bf_parts.transport-rubl else 0) - (if bf_parts.other-rubl <> ? then bf_parts.other-rubl else 0)
           &scop label     "цена в {&abbr_rublyah} за вычетом компоненты " + varroad-taxname + " и всех расходов в партии"
           {&error-line}
           &scop chk-undef yes
           &scop expr      bf_parts.price-base - bf_parts.road-tax-base - (if bf_parts.transport-base <> ? then bf_parts.transport-base else 0) - (if bf_parts.other-base <> ? then bf_parts.other-base else 0)
           &scop label     "цена в валюте за вычетом компоненты " + varroad-taxname + " и всех расходов в партии"
           {&error-line}
       end. /*bf_parts*/
   end. /*each bf_doc-line*/
end. /*do*/
end. /*chkprice.i*/