block-level on error undo, throw.
/*

$Revision: f5e72f13272f, 2363, rls $
$Author: druban $
$Date: Ср июн 10 21:13:42 2020 +0300 $
$Workfile: imd-all.p $
$Archive: utl/imd-all.p $

Драйвер импорта из внешнего текстового файла любой информации

Автор: Чернова Светлана Александровна
Дата создания: 01/10/07
Author: Svetlana Chernova
Creation date: 01/10/07

create: Суслов Алексей Юрьевич
Дата создания: 09/20/05

"ITEM: артикул;[код-производителя];;;              [[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]"
"SCALE:артикул;[код-производителя];признак;;       [[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];]"
"PART: артикул;[код-производителя];документ;партия;[[доп-бар-код]];<цена>;<количество>;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[ГТД][;[вес одного места];[количество мест];[срок годности];[цена производителя без НДС];[цена производителя с НДС]]"
"CODE: код;;;;                                     доп-бар-код;цена;количество;[едизм];[коэффициент];[скидка];[НДС];[НСП];[[включен/выключен(yes/no)]];[Тип маркировки]"

Автор : Андрей Исаков 12.05.98
*/
define input  parameter parparentproc as handle              no-undo.
define input  parameter InputMode     as char                no-undo. /* что импортируем: prod-bc, input-way-bill */
define input  parameter frame-title   as char                no-undo. /* заголовок фрейма и журнала */
define input  parameter dfc-recid      as recid no-undo .             /* recid на ДНЦ */
define input  parameter e-code        like ub.trn-doc.exch-code no-undo. /* код валюты поставщика для ПН */
define input  parameter pardoc-code   like ub.trn-doc.doc-code  no-undo. /* код создаваемого документа */
define input  parameter parcli-type   like ub.trn-doc.cli-type  no-undo. /*поставщик*/
define input  parameter parcli-code   like ub.trn-doc.cli-code  no-undo.
define input  parameter parhost-code  like ub.trn-doc.host-code no-undo.
define output parameter count-upd     as int init 0          no-undo. /* изменено */
define output parameter counter       as int init 0          no-undo. /* закачано */
define output parameter count-all     as int init 0          no-undo. /* просмотрено */
/*
message
'parparentproc '  parparentproc  skip
'InputMode     '  InputMode      skip
'frame-title   '  frame-title    skip
'dfc-recid     '  dfc-recid      skip
'e-code        '  e-code         skip
'pardoc-code   '  pardoc-code    skip
'parcli-type   '  parcli-type    skip
'parcli-code   '  parcli-code    skip
'parhost-code  '  parhost-code   skip .
 */

define variable vss-revision    as character no-undo initial "$Revision: f5e72f13272f, 2363, rls $":U .
define variable vss-author      as character no-undo initial "$Author: druban $":U .
define variable vss-date        as character no-undo initial "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: imd-all.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/imd-all.p $":U .
define variable vss-description as character no-undo initial "Драйвер импорта из внешнего текстового файла любой информации".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/is-num.i   }
{ str/lib-trn.i  }
{ str/hvrdtax.i  }
{ str/libbcrcn.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i def }
DEFINE BUFFER buf_price-doc-forming FOR ub.price-doc-forming.
{ ref/xobjgrp.i  }  /* список объектов  */
{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ ref/gdsoattr.i }
{ str/lastincs.i }
{ trg/check-bc.i }
{ cmp/strcodec.i }
define variable v-param-type      as character  no-undo.
define variable v-tth             as handle     no-undo.
define variable varis-petrolium   as logical    no-undo.
define variable varis-pieces      as logical    no-undo.
define variable v-sec as integer   no-undo .
define variable imp-save as integer   no-undo .


/* Параметры из секции ПЕРЕОЦЕНКА */
define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
      ) no-error .


&scop err-source ~
  if msg-line <> count-all then ~
    put stream err unformatted ~
    "------------------------------------------------------------------------------------" {&new-line} ~
    "Строка №: " count-all {&new-line}

&scop wrn-source ~
  if wrn-line <> count-all then ~
    put stream wrn unformatted ~
    "------------------------------------------------------------------------------------" {&new-line} ~
    "Строка №: " count-all {&new-line}

&scop put-source ~
  if msg-line <> count-all then do: ~
    put stream err unformatted ~
    source-string ~
    {&new-line}. ~
    msg-line = count-all. ~
  end.
&scop put-source-wrn ~
  if wrn-line <> count-all then do: ~
    put stream wrn unformatted ~
    source-string ~
    {&new-line}. ~
    wrn-line = count-all. ~
  end.

&scop err-put-beg ~
  {&err-source} ~
  " Артикул : "                      ub.goods.artic ~
  " Производитель : "                ub.goods.prod-type ~
  " "                                ub.goods.prod-code ~
  " Код товара : "                   ub.goods.gds-code ~
  " Основная единица измерения : "   ub.goods.unit-base {&new-line}
&scop wrn-put-beg ~
  {&wrn-source} ~
  " Артикул : "                      ub.goods.artic ~
  " Производитель : "                ub.goods.prod-type ~
  " "                                ub.goods.prod-code ~
  " Код товара : "                   ub.goods.gds-code ~
  " Основная единица измерения : "   ub.goods.unit-base {&new-line}

&scop err-put ~
  {&err-put-beg} ~
  {&new-line}. ~
  {&put-source} ~
  put stream err unformatted
&scop wrn-put ~
  {&wrn-put-beg} ~
  {&new-line}. ~
  {&put-source-wrn} ~
  put stream wrn unformatted


&scop err-bar-code ~
  {&err-put-beg} ~
  " Собственный код : "                     ub.bar-code.b-code ~
  " Единица измерения собственного кода : " ub.bar-code.unit-cli ~
  " коэффициент собственного кода : "        ub.bar-code.cli-base-rate ~
  {&new-line}. ~
  {&put-source} ~
  put stream err unformatted

&scop wrn-bar-code ~
  {&wrn-put-beg} ~
  " Собственный код : "                     ub.bar-code.b-code ~
  " Единица измерения собственного кода : " ub.bar-code.unit-cli ~
  " коэффициент собственного кода : "        ub.bar-code.cli-base-rate ~
  {&new-line}. ~
  {&put-source-wrn} ~
  put stream wrn unformatted

define shared stream inp.
define shared stream err.
define shared stream wrn.
define variable source-string  as char FORMAT "x(232)"      no-undo.
define variable text-string    as char FORMAT "x(232)"      no-undo.
define variable string-type    as char                      no-undo.
define variable i-artic         like ub.goods.artic            no-undo.
define variable i-artic-supp    like ub.cli-gds.cli-art        no-undo.
define variable i-code          like ub.prod-bc.b-str          no-undo.
define variable i-prod-code     like ub.goods.prod-code        no-undo.
define variable i-scale         like ub.gds-prt.f-name         no-undo.
define variable i-doc-code      like ub.parts.in-code          no-undo.
define variable i-part-code     like ub.parts.part-code        no-undo.
define variable i-prod-bc       like ub.prod-bc.b-str          no-undo.
define variable i-price         like ub.doc-line.price-cli     no-undo.
define variable i-qnty          like ub.doc-line.cli-qnty      no-undo.
define variable i-vat           like ub.doc-line.vat-pc        no-undo.
define variable i-slt           like ub.doc-line.vat-pc        no-undo.
define variable i-wt-brutto     like ub.doc-line.wt-brutto     no-undo.
define variable i-num-place     like ub.doc-line.num-place     no-undo.
define variable i-last-date     like ub.parts.last-date        no-undo.
define variable i-price-prod     as decimal   no-undo .
define variable i-price-prod-vat as decimal   no-undo .
define variable i-d-pcnt        like ub.price-doc-forming-gds.d-pcnt      no-undo.
define variable i-unit-cli      like ub.bar-code.unit-cli      no-undo.
define variable i-cli-base-rate like ub.bar-code.cli-base-rate no-undo.
define variable i-bc-on         as   logical                no-undo.
define variable i-cst-code      like ub.parts.cst-code         no-undo.
define variable local-code      like ub.goods.gds-code         no-undo.
define variable size           as dec                       no-undo. /* коэффициент из бар-кода */
define variable scale-level    as int                       no-undo. /* уровень шкалы */
define variable msg-line       as int init 0                no-undo. /* чтоб повторно не выводить номер и исходную строку в сообщениях */
define variable wrn-line       as int init 0                no-undo. /* чтоб повторно не выводить номер и исходную строку в сообщениях */

/* для режима prod-bc */
define variable par-bc-pfx     as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-pl-pfx     as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-bc-frmt    as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-pl-frmt    as char                      no-undo. /* для чтения параметра конфигурации */
define variable par-dif-pdbc   as logical                   no-undo. /* для чтения параметра конфигурации */
define variable par-dpl-off    as logical                   no-undo. /* для чтения параметра конфигурации */

define variable varfile-scan   as logical                   no-undo.
define variable varcode-scan   as char                      no-undo.
define variable varqnty-scan   as char                      no-undo.
define variable varprice-scan  as char                      no-undo.

define variable v-host-code    like ub.sysconf.host-code  no-undo.
define variable v-obj-type     like ub.trn-doc.obj-type   no-undo.
define variable v-obj-code     like ub.trn-doc.obj-code   no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define variable vararticle-supplier as logical no-undo.
define variable varlog      as logical         no-undo.

define buffer other-goods for ub.goods.
define buffer goods-units for ub.units.
define buffer bf_clients  for ub.clients.
define buffer bf_cli-gds  for ub.cli-gds.
define buffer trouble-goods for ub.goods.

define variable pdf-id      like ub.price-doc-forming.pdf-id  no-undo.
define variable pdf-db      like ub.price-doc-forming.pdf-db  no-undo.
define variable plt-id      like ub.price-doc-forming.plt-id     no-undo.
define variable plt-db-num  like ub.price-doc-forming.plt-db-num no-undo.

{ str/sclspref.i }
def frame a
counter   label "Закачано"
count-upd label "Изменено"
count-all label "Просмотрено"
with side-labels view-as dialog-box.
view frame a.
case InputMode:
  when "prod-bc" then do:
    /* читаем все нужные параметры конфигурации */
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "", yes, output par-bc-pfx, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then do:
      message "Ошибка параметра bc-pfx."
              view-as alert-box error.
      hide frame a.
      return error.

    end.
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "", yes, output par-bc-frmt, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then do:
      message "Ошибка параметра bc-frmt."
              view-as alert-box error.
      hide frame a.
      return error.
    end.
    run gbl/conf-rd.p ("pl-pfx", "", "", 0, "", "", "", no, output par-pl-pfx, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then
      par-pl-pfx = ?. /* при выходе с ошибкой возвращает непонятно что */
    run gbl/conf-rd.p ("pl-frmt", "", "", 0, "", "", "", no, output par-pl-frmt, output par-type) no-error.
    if error-status:error or
      par-type <> "C":U then
      par-pl-frmt = ?. /* при выходе с ошибкой возвращает непонятно что */
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output par-dif-pdbc
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_dpl-off} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output par-dpl-off
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
  end.
  when "input-way-bill" then do:
    /* отключаем триггер, потому что документ неполноценный */
    on write of ub.trn-doc override do: end.
    clear-imp:
    do transaction
      on error undo clear-imp, return error
      on stop  undo clear-imp, return error :
      find ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-error.
      if available ub.trn-doc then do:
        run delete-trn-doc in this-procedure .
      end.

      create ub.trn-doc .
      assign
        ub.trn-doc.doc-code  = pardoc-code
        ub.trn-doc.cr-db-num = v-cntxt-db-num
        ub.trn-doc.doc-type  = {&income}
        ub.trn-doc.internal  = no
        ub.trn-doc.exch-code = e-code
        ub.trn-doc.obj-type = v-cntxt-obj-type
        ub.trn-doc.obj-code = v-cntxt-obj-code

      .
      assign
          v-obj-type = v-cntxt-obj-type
          v-obj-code = v-cntxt-obj-code
      .
    end.
  end.
  when "way-bill-delete" then do:
    /* удаление буферной накладной импорта */
    del-imp:
    do transaction
      on error undo del-imp, return error
      on stop  undo del-imp, return error :
      find ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-error.
      if available ub.trn-doc then do:
        run delete-trn-doc in this-procedure .
      end.
    end.
    return.
  end.
  when "overvalue" then do:
    find buf_price-doc-forming where recid( buf_price-doc-forming) = dfc-recid .

    assign
        pdf-id = buf_price-doc-forming.pdf-id
        pdf-db = buf_price-doc-forming.pdf-db
        plt-id      = buf_price-doc-forming.plt-id
        plt-db-num  = buf_price-doc-forming.plt-db-num
    .

  end.
  otherwise do:
    message
      "Неправильное значение параметра InputMode:" InputMode
      view-as alert-box error.
    hide frame a.
    return error.
  end.
end case.
frame a :title = frame-title.

put stream err unformatted fill ({&new-line}, 2) frame a :title fill ({&new-line}, 3).
assign varfile-scan = ?
       vararticle-supplier = no.
file-line:
repeat on endkey undo, leave :
  disp count-upd counter count-all with frame a.
  do on endkey undo, leave:
    import stream  inp unformatted source-string no-error.
  end.
  if error-status:error then undo, leave.
  if source-string = "" then
    next file-line.
  count-all = count-all + 1.
  if source-string = "ARTICLE-SUPPLIER" then do:
    assign
      vararticle-supplier = yes.
    if parcli-type = ? and
       parcli-code = ? then do:
      message "Из данного интерфейса нельзя обрабатывать данные по артикулу поставщика."
      view-as alert-box error.
      return error.
    end.
    else do:
      find first bf_clients where bf_clients.obj-type = parcli-type and
                                  bf_clients.obj-code = parcli-code no-lock no-error.
      if not available bf_clients then do:
        message "Ведем импорт по артикулу поставщика." skip
                "Не найден поставщик " parcli-type parcli-code " ."
        view-as alert-box error.
        return error.
      end.
    end.
    next file-line.
  end.
  if varfile-scan = ?              and
     index (source-string, ",") > 0 then do:
     message "Формат строки " source-string " содержит запятую." skip
             "Будем разбирать все необработаные строки файла как формат сканера?"
     view-as alert-box question buttons yes-no update varlog.
     if varlog = yes then do:
          {&wrn-source} "Начиная со строки " + source-string + " разбираем данные по формату сканера." skip.
          assign varfile-scan = yes.
       end.
       else do:
          assign varfile-scan = no.
       end.
  end.
  if varfile-scan = yes then do:
     /*Преобразование файла сканера в файл импорта*/
     ASSIGN varcode-scan  = ENTRY(1, source-string, ",")
            varqnty-scan  = ENTRY(2, source-string, ",")
            varprice-scan = ENTRY(3, source-string, ",").
     {&wrn-source} "Строка " + source-string + " сконвертирована в CODE:" + varcode-scan + ";;;;;" + varprice-scan + ";" + varqnty-scan + ";;;;;;;" skip.
     source-string = "CODE:" + varcode-scan + ";;;;;" + varprice-scan + ";" + varqnty-scan + ";;;;;;;".
  end.
  else do:
     if index (source-string, ":") = 0 then do:
        {&err-source} "Не указан тип строки (ITEM,SCALE,PART,CODE) или отсутствует двоеточие. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
  end.
  /* разбиваем строку на тип и параметры */
  assign
    string-type     = substring (source-string, 1, index (source-string, ":") - 1)
    text-string     = substring (source-string, index (source-string, ":") + 1)
    i-artic-supp    = ""
    i-artic         = ""
    i-code          = ""
    i-prod-code     = 0
    i-scale         = ""
    i-doc-code      = ""
    i-part-code     = ""
    i-prod-bc       = ""
    i-price         = 0
    i-qnty          = 0
    i-unit-cli      = ""
    i-cli-base-rate = 1
    i-d-pcnt        = 0
    i-VAT           = 0
    i-SLT           = 0
    size            = 1
    i-bc-on         = ?
    i-cst-code      = ""
    i-wt-brutto     = 0
    i-num-place     = 0
    i-last-date     = ?
    i-price-prod     = 0
    i-price-prod-vat     = 0
    .

  if num-entries (text-string, ";") <> 14 and
     num-entries (text-string, ";") <> 16 and
     num-entries (text-string, ";") <> 17 and
     num-entries (text-string, ";") <> 18 and
     num-entries (text-string, ";") <> 19
     then do:
    {&err-source} "Неправильное число параметров: " string (num-entries (text-string, ";"))
                  " (должно быть 14,16,17,18 или 19). Пропускаем." {&new-line}.
    {&put-source}
    next file-line.
  end.
  if string-type = "CODE" then do:
    assign
      i-code = trim (entry (1, text-string, ";")).
  end.
  else do:
    if vararticle-supplier = yes then do:
      assign
        i-artic-supp =  trim (entry (1, text-string, ";")).
      find first bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
                                  bf_cli-gds.cli-code  = parcli-code  and
                                  bf_cli-gds.host-code = parhost-code and
                                  bf_cli-gds.cli-art   = i-artic-supp no-lock no-error.
      if not available bf_cli-gds then do:
        {&err-source} substitute ("Не найден артикул поставщика &1 по фирме &2 для поставщика &3 &4. Пропускаем.", i-artic-supp, parhost-code, parcli-type, parcli-code) {&new-line}.
        {&put-source}
        next file-line.
      end.
      assign
        i-artic     = bf_cli-gds.artic
        i-prod-code = bf_cli-gds.prod-code.
    end.
    else do:
      assign
        i-artic     = trim (entry (1, text-string, ";"))
        i-prod-code = integer (trim (entry (2, text-string, ";"))).
    end.
  end.
  assign
    i-scale         = trim    (entry (3, text-string, ";"))
    i-doc-code      = trim    (entry (3, text-string, ";"))
    i-part-code     = trim    (entry (4, text-string, ";"))
    i-prod-bc       = trim    (entry (5, text-string, ";"))
    i-price         = decimal (entry (6, text-string, ";"))
    i-qnty          = decimal (entry (7, text-string, ";"))
    i-unit-cli      =          entry (8, text-string, ";")
    i-cli-base-rate = decimal (entry (9, text-string, ";"))
    i-d-pcnt        = decimal (entry (10, text-string, ";"))
    i-VAT           = decimal (entry (11, text-string, ";"))
    i-SLT           = decimal (entry (12, text-string, ";"))
    .
    if entry (13, text-string, ";") = "yes" then do:
       assign i-bc-on = yes.
    end.
    else do:
       if entry (13, text-string, ";") = "no" then do:
          assign i-bc-on = no.
       end.
       else do:
         if lookup (InputMode, "prod-bc,all") > 0 then do:
            {&err-source} "Неверный параметр 13. Должен быть yes или no." {&new-line}.
            {&put-source}
            next file-line.
         end.
       end.
    end.
    assign i-cst-code = entry (14, text-string, ";").
    if num-entries (text-string, ";") = 16 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
      .
    end.

    if num-entries (text-string, ";") = 17 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
        i-last-date = date(entry (17, text-string, ";"))
      .
    end.
    if num-entries (text-string, ";") = 18 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
        i-last-date = date(entry (17, text-string, ";"))
        i-price-prod = decimal(entry (18, text-string, ";"))
      .
    end.
    if num-entries (text-string, ";") = 19 then do:
      assign
        i-wt-brutto = decimal(entry (15, text-string, ";"))
        i-num-place = decimal(entry (16, text-string, ";"))
        i-last-date = date(entry (17, text-string, ";"))
        i-price-prod = decimal(entry (18, text-string, ";"))
        i-price-prod-vat = decimal(entry (19, text-string, ";"))
      .
    end.



  /* проверяем корректность параметров */
  case string-type:
    when "ITEM" then do:
      if i-artic = "" then do:
        {&err-source} "Пустой артикул. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
      assign
        i-code = ""
        i-doc-code = ""
        i-part-code = ""
        .
    end.
    when "SCALE" then do:
      if i-artic = "" then do:
        {&err-source} "Пустой артикул. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
      if i-scale = "" then do:
        {&err-source} "Пустое название признака. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
      assign
        i-code = ""
        i-doc-code = ""
        i-part-code = ""
        .
    end.
    when "PART" then do:
      if i-artic = "" then do:
        {&err-source} "Пустой артикул. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
      i-code = "".
    end.
    when "CODE" then do:
      if i-code = "" then do:
        {&err-source} "Пустой код. Пропускаем." {&new-line}.
        {&put-source}
        next file-line.
      end.
      i-artic = "".
    end.
    otherwise do:
      {&err-source} "Неправильный тип строки (должно быть ITEM,SCALE,PART,CODE). Пропускаем." {&new-line}.
      {&put-source}
      next file-line.
    end.
  end case.

  release ub.goods.
  release ub.gds-prt.
  release ub.parts.

  /* ищем товар */
  if lookup (string-type, "ITEM,SCALE,PART") > 0 then do:
    if i-prod-code = 0 then do:
      /* ищем первый попавшийся неудаленный */
      FIND first ub.goods WHERE
                 ub.goods.artic = i-artic and
                 ub.goods.stts = 0 no-lock no-error.
      if available ub.goods then do:
        find first other-goods where
                   other-goods.artic = i-artic and
                   other-goods.stts  = 0       and
                   recid (other-goods) <> recid (goods) no-lock no-error.
        if available other-goods then do:
          {&err-put} "Производитель не указан. Есть больше одного включенного товара с этим артикулом. Взят первый подходящий." {&new-line}.
        end.
        find first other-goods where
                   other-goods.artic = i-artic and
                   recid (other-goods) <> recid (goods) no-lock no-error.
        if available other-goods then do:
          {&wrn-put} "Производитель не указан. Есть больше одного товара с этим артикулом. Взят первый неудаленный." {&new-line}.
        end.
      end.

      else do:
        /* ищем первый попавшийся удаленный */
        FIND first other-goods WHERE
                   other-goods.artic = i-artic no-lock no-error.
        if available other-goods then do:
          {&err-source} "Производитель не указан. Есть УДАЛЕННЫЙ товар с производителем : "
                        other-goods.prod-code " Название: " other-goods.gds-name " Пропускаем." {&new-line}.
          {&put-source}
          next file-line.
        end.
        /*нет ни одного товара с таким артикулом*/
        else do:
          {&err-source} "В справочнике товаров нет товара с артикулом : " i-artic " Пропускаем." {&new-line}.
          {&put-source}
          next file-line.
        end.
      end.
    end.
    else do:
      FIND first ub.goods WHERE
                 ub.goods.artic = i-artic and
                 ub.goods.prod-type = {&cmp} and
                 ub.goods.prod-code = i-prod-code NO-LOCK no-error.
      if not available ub.goods then do:
        FIND first ub.goods WHERE
                   ub.goods.artic = i-artic and
                   ub.goods.prod-type = {&prs} and
                   ub.goods.prod-code = i-prod-code NO-LOCK no-error.
        if available ub.goods then do:
        end.
        else do:
          {&err-source} "Товар с данными артикулом и кодом производителя (подразумевается организация) в БД отсутствует. Пропускаем." {&new-line}.
          {&put-source}
          next file-line.
        end.
      end.
      find first trouble-goods where trouble-goods.artic     =  ub.goods.artic     and
                                     trouble-goods.prod-code =  ub.goods.prod-code and
                                     trouble-goods.prod-type <> ub.goods.prod-type no-lock no-error.
      if available trouble-goods then do:
         {&err-source} "Есть товары с артикулом: " + ub.goods.artic + " кодом производителя: " + string(goods.prod-code) + " и типами производителя: " + ub.goods.prod-type + " и " + trouble-goods.prod-type + " Импорт невозможен. Пропускаем." {&new-line}.
         {&put-source}
         next file-line.
      end.
    end.
    /*Проверяем, что товар не является топливом*/
    { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      varis-petrolium
      varis-pieces
    }
    if varis-petrolium = yes and
       varis-pieces    = no  then do:
      {&err-source} "Товар " + ub.goods.artic + " " + ub.goods.prod-type + " " + string(goods.prod-code) + " является жидким топливом. Товар нельзя импортировать." + " Импорт невозможен. Пропускаем." {&new-line}.
      {&put-source}
      next file-line.
    end.

    /* находим узел шкалы, партию */
    if lookup (string-type, "ITEM,PART") > 0 then do:
      /* это не признак */
      FIND first ub.gds-prt WHERE
                 ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    end.
    if string-type = "SCALE" then do:
      /* это признак */
      find first  ub.gds-prt where
                  ub.gds-prt.prt-root = ub.goods.prt-root and
                  ub.gds-prt.is-term  = yes            and
                  ub.gds-prt.f-name   = i-scale        no-lock no-error.
      if not available ub.gds-prt then do:
        /*В беннетоне при переходе с одноуровневой шкалы на двухуровневую могли остаться товары привязанные к старой шкале.
          Их надо обслужить особо*/
        define variable varqnty-slash as integer no-undo.
        define variable varnum-symb   as integer no-undo.
        define variable vari-scale    like i-scale no-undo.
        assign varqnty-slash = 0.
        do varnum-symb = 1 to length(i-scale):
          if substring (i-scale, varnum-symb , 1) = "/" then do:
            assign
              varqnty-slash = varqnty-slash + 1.
          end.
        end.
        if varqnty-slash = 1 then do:
          assign
            vari-scale = substring (i-scale, r-index (i-scale, "/") + 1).
          find first  ub.gds-prt where
                  ub.gds-prt.prt-root = ub.goods.prt-root and
                  ub.gds-prt.is-term  = yes            and
                  ub.gds-prt.f-name   = vari-scale        no-lock no-error.
          if not available ub.gds-prt then do:
            {&err-put} "Узел шкалы не найден. Пропускаем." {&new-line}.
            next file-line.
          end.
          else do:
            {&err-put} "Узел шкалы не найден. Но НАЙДЕН для одноуровневой шкалы по нижнему уровню. Пропускаем." {&new-line}.
            next file-line.
          end.
        end.
        else do:
          {&err-put} "Узел шкалы не найден. Пропускаем." {&new-line}.
          next file-line.
        end.
      end.
    end.
  end.

  /* тип строки CODE - просто нужно найти собственный код */
  if string-type = "CODE" then do:
    /* ищем (бар-) код */
    { str/bc-rcnz.i
      parparentproc
      i-code
      ?
      v-cntxt-obj-type
      v-cntxt-obj-code
      yes
      no
      varscales-pref
      varpgscales-pref
      varresult
      vartype-bc
      varweight
      ub.bar-code
      ub.prod-bc
      ub.place
      no-error
    }
    if not available ub.bar-code then do:
      /* код не найден */
      {&err-source} "Код для поиска в БД отсутствует. Пропускаем." {&new-line}.
      {&put-source}
      next file-line.
    end.
    /* Существует противоречие между доп. едизмом (и коэффициентом) бар-кода и
       доп. едизмом (и, соответственно, коэффициентом), указанным в строке импорта.
       Принятое решение: едизм и коэффициент бар-кода будет использован только тогда, когда
       из строки взять нечего, т.е. когда едизм строки не указан
    */
    find first ub.goods   where ub.goods.gds-code    = ub.bar-code.gds-code no-lock.
    if i-unit-cli = "" then do:
      /* подставляем едизм и коэффициент из бар-кода */
      assign
        i-cli-base-rate = ub.bar-code.cli-base-rate
        i-unit-cli      = ub.bar-code.unit-cli
        .
      {&wrn-bar-code} "Не указаны единица измерения и коэффициент. Берем из собственного кода." {&new-line}.
    end.
    find first ub.gds-prt where ub.gds-prt.node-code = ub.bar-code.node-code no-lock.
    if InputMode = "input-way-bill" and
       ub.gds-prt.is-term <> yes       then do:
      {&err-source} "Код " i-code " не является кодом терминального признака. Пропускаем." {&new-line}.
      {&put-source}
      next file-line.
    end.
  end.

  /* находим едизм для ТОВАРА */
  find goods-units where
       goods-units.unit-name = ub.goods.unit-base no-lock.
  if i-unit-cli = "" then
    assign
      i-unit-cli = ub.goods.unit-base
      /* коэффициент восстанавливаем */
      i-cli-base-rate = 1
      .
  if v-obj-type = ? or
     v-obj-code = ? then do:
     assign
       v-obj-type = v-cntxt-obj-type
       v-obj-code = v-cntxt-obj-code.
  end.

  { gbl/hostcode.i v-obj-type v-obj-code v-host-code }

  /* формат файла изменился */
  /* теперь в импорте указывается код ставки налога */
  define variable v-vat-pc as decimal   no-undo .
  define variable v-slt-pc as decimal   no-undo .
  define variable v-today  as date      no-undo .

  /* определяем текущую дату на объекте */
  { gbl/curobjdt.i
    v-obj-type
    v-obj-code
    v-today
  }

  /* если код ставки налога равен 0 - то берется текущая ставка налога по товару */
  /* если она отлична от нуля       - то берется указанная ставка налога на текущую дату */
  assign
    v-vat-pc = ?
    v-slt-pc = ?
  .


  /* в зависимости от настройки магазина shop.inout-price */
  /* в документе импорта указывается абсолютное значение налога или код ставки */
  /* если (shop|store).inout-price = true,  то в файле абсолютные значения налога */
  /* если (shop|store).inout-price = false, то в файле заданы коды ставок налогов */

  define variable v-inout-price as logical   no-undo .

/*  { gbl/objat.i*/
/*    v-obj-type*/
/*    v-obj-code*/
/*    "'inout-price=request'"*/
/*    v-inout-price*/
/*    no-error*/
/*  }*/
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop .

  case v-obj-type :
    when {&stock}
    then do:
      find buf_store no-lock
        where buf_store.obj-code = v-obj-code
        no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_store.inout-price
      .
    end.
    when {&shop}
    then do:
      find buf_shop no-lock
        where buf_shop.obj-code = v-obj-code
        no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_shop.inout-price
      .
    end.
  end.

  if v-inout-price = true
  then do:
    if i-VAT = 0
    then do:
      /* в файле абсолютные значения налога */
      /* налог не задан */
      /* берем текущее значение налога */
      { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-host-code v-obj-type v-obj-code v-vat-pc no-error }
    end.
    else do:
      assign
        v-vat-pc = i-VAT
      .
    end.
  end.
  else do:
    { gbl/pftaxval.i ? {&vat-tax-code} i-VAT v-today v-host-code v-obj-type v-obj-code v-vat-pc no-error }
  end.

  if v-inout-price = true
  then do:
    if i-SLT = 0
    then do:
      { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} ? v-host-code v-obj-type v-obj-code v-slt-pc no-error }
    end.
    else do:
      assign
        v-slt-pc = i-SLT
      .
    end.
  end.
  else do:
    { gbl/pftaxval.i ? {&slt-tax-code} i-SLT v-today v-host-code v-obj-type v-obj-code v-slt-pc no-error }
  end.
  if lookup (InputMode, "input-way-bill,all") > 0 then do:
    if v-vat-pc = ?
    then do:
      {&err-put} substitute("Получено неопреледенное значение НДС. Код ставки НДС &1. Пропускаем.", i-vat) {&new-line}.
      next file-line.
    end.

    if v-slt-pc = ?
    then do:
      {&err-put} substitute("Получено неопреледенное значение НП. Код ставки НП &1. Пропускаем.", i-slt) {&new-line}.
      next file-line.
    end.
  end.

  /* проверяем тип строки */
  if lookup ({&pieces}, goods-units.type) > 0 and
     i-cli-base-rate <> truncate (i-cli-base-rate, 0) then do:
    {&err-put} "Для штучного товара коэффициент должен быть целым числом. Пропускаем." {&new-line}.
    next file-line.
  end.
  /* В связи с появлением в ПМС глобальных весовых бар-кодов начинаем экспортировать их
     во внешнюю приходную накладную*/
  if lookup ({&weight}, goods-units.type)  > 0 and
     not lookup (string-type, "ITEM,PART") > 0 and
     inputmode <> "input-way-bill"            then do:
    {&err-put} "Товар весовой : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." {&new-line}.
    next file-line.
  end.
  if lookup ({&serial}, goods-units.type) > 0 and
     not lookup (string-type, "ITEM,PART") > 0 then do:
    {&err-put} "Товар серийный : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." {&new-line}.
    next file-line.
  end.
  if lookup ({&petrolium}, goods-units.type) > 0 and
     lookup ({&divisional}, goods-units.type) > 0 and
     ub.goods.gds-type = {&gds-goods} then do:
    /* дробный (разливной) бензин */
    if not lookup (string-type, "ITEM") > 0 then do:
      {&err-put} "Товар топливный : Тип строки должен быть ITEM, либо CODE для товара. Пропускаем." {&new-line}.
      next file-line.
    end.
    if i-unit-cli <> ub.goods.unit-base then do:
      {&err-put} "Товар топливный : Единица измерения должна совпадать с основной. Пропускаем." {&new-line}.
      next file-line.
    end.
  end.

  /* находим едизм, указанный в бар-коде (входном файле) */
  find ub.units where ub.units.unit-name = i-unit-cli no-lock no-error.
  if not available ub.units then do:
    {&err-put} "Единица измерения отсутствует в справочнике. Пропускаем." {&new-line}.
    next file-line.
  end.

  /* проверяем коэффициент */
  if i-cli-base-rate <= 0 then do:
    {&err-put} "Коэффициент должен быть больше 0. Пропускаем." {&new-line}.
    next file-line.
  end.
  if i-cli-base-rate = ? then do:
    {&err-put} "Коэффициент не должен иметь неопределенное значение. Пропускаем." {&new-line}.
    next file-line.
  end.
  if i-unit-cli <> ub.goods.unit-base and
     i-cli-base-rate = 1 then do:
    {&err-put} "Единица измерения не совпадает с основной - а коэффициент 1! Пропускаем. " {&new-line}.
    next file-line.
  end.
  if i-unit-cli = ub.goods.unit-base and
     i-cli-base-rate <> 1 then do:
    {&err-put} "Единица измерения совпадает с основной. Коэффициент должен быть равен 1. Пропускаем." {&new-line}.
    next file-line.
  end.

  /* находим или создаем собственный код, на который должен ссылаться доп. БК */
  run get-bar-code no-error.
  if error-status:error then
    next file-line.

  /* проверяем скидку */
  if  i-cli-base-rate = 1 and
      i-d-pcnt <> 0 then do:
    {&err-put} "Коэффициент равен 1. Скидка должна быть равна 0. Пропускаем." {&new-line}.
    next file-line.
  end.
  if i-cli-base-rate > 1 and
      i-d-pcnt < 0 then do:
    {&err-put} "Коэффициент больше 1. Скидка должна быть больше или равна 0. Пропускаем." {&new-line}.
    next file-line.
  end.
  if i-cli-base-rate < 1 and
      i-d-pcnt > 0 then do:
    {&err-put} "Коэффициент меньше 1. Скидка должна быть меньше или равна 0. Пропускаем." {&new-line}.
    next file-line.
  end.

  /* проверяем цену */
  if  i-price < 0 then do:
    {&err-put} "Цена неправильная. Пропускаем." {&new-line}.
    next file-line.
  end.

  /* вызываем процедуру импорта для конкретного режима */
  if lookup (InputMode, "prod-bc,all") > 0 then do:
    run imp-prod-bc no-error.
    if error-status:error then do:
      {&err-put} SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-prod-bc &1 &2 &3",
                            return-value,
                            error-status:get-message(1),
                            error-status:get-message(2))  + {&new-line}.
      next file-line.
    end.
  end.
  if lookup (InputMode, "input-way-bill,all") > 0 then do:
    if i-price = ? or
       i-price = 0 then do:
      {&err-put} "Цена неправильная. Пропускаем." {&new-line}.
      next file-line.
    end.
    run imp-input-way-bill no-error.
    if error-status:error then do:
       {&err-put} SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-input-way-bill &1 &2 &3",
                                                    return-value,
                                                    error-status:get-message(1),
                                                    error-status:get-message(2))  + {&new-line}.
       next file-line.
     end.
  end.
  if lookup (InputMode, "overvalue,all") > 0 then do:
    if  i-price = ? or
        i-price = 0 then do:
      {&err-put} "Цена неправильная. Пропускаем." {&new-line}.
      next file-line.
    end.

    run imp-overvalue no-error.
    if error-status:error then do:
      {&err-put} SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-overvalue &1 &2 &3",
                                                return-value,
                                                error-status:get-message(1),
                                                error-status:get-message(2))  + {&new-line}.
      next file-line.
   end.
  end.
END.
hide frame a .

procedure get-bar-code:
/*--------------------------------------------------------------------------
    поиск собственного бар-кода для товара, признака, партии
    с заданной единицей измерени

    при отсутствии создание такого бар-кода
    коэффициент инициируется в только в случае создания кода
--------------------------------------------------------------------------*/
define variable s-in-code   like ub.parts.in-code   no-undo.
define variable s-part-code like ub.parts.part-code no-undo.
define variable new-bar-code as log              no-undo.

  assign
    s-in-code   = ""
    s-part-code = ""
    .
find-create-bc:
do transaction
on error undo find-create-bc, return error
on stop  undo find-create-bc, return error:
  { gbl/barcodcr.i
    ub.goods.gds-code
    ub.gds-prt.node-code
    s-part-code
    s-in-code
    i-unit-cli
    i-cli-base-rate
    new-bar-code
    ub.bar-code
    no-error
  }
  if error-status:error then do:
    {&err-bar-code} "Ошибка при поиске / создании собственного кода. Пропускаем." {&new-line}.
    undo find-create-bc, return error.
  end.
  if new-bar-code then do:
    {&wrn-bar-code} "Создан собственный код с единицей измерения из входного файла." {&new-line}.
  end.
  if ub.bar-code.cli-base-rate <> i-cli-base-rate then do:
    {&err-bar-code} "Коэффициент в собственном коде не совпадает с указанным в файле. Пропускаем." {&new-line}.
    undo find-create-bc, return error.
  end.
  
  
end.
end procedure.

/*==========================================================================
      ПРОЦЕДУРЫ ИМПОРТА
==========================================================================*/

procedure imp-prod-bc:
/*--------------------------------------------------------------------------
    импорт доп. БК
--------------------------------------------------------------------------*/
def buffer same-prod-bc  for ub.prod-bc.
def buffer same-bar-code for ub.bar-code.
def buffer same-goods    for ub.goods.
define buffer buf_prod-bc-attr for prod-bc-attr.
define variable vMarkType as integer no-undo.
vMarkType = int(i-cst-code)no-error.
tr:
do on error undo tr, return error SUBSTITUTE("Ошибка при импорте доп. бар-кода &1 &2 &3 ", i-prod-bc, error-status:get-message(1), error-status:get-message(2)):
if  length (i-prod-bc) > 13 /* длинный доп. БК */ and
    not is-numeral (i-prod-bc,
                    "letter,digit") or
    length (i-prod-bc) <= 13 /* EAN или другой не длинный доп. БК */ and
    not is-numeral (i-prod-bc,
                    "digit") then do:
  {&err-put} "Доп. БК содержит пробелы или недопустимые символы. Пропускаем." {&new-line}.
  return.
end.
if  i-prod-bc begins par-bc-pfx and
    (length (i-prod-bc) = 13 and
    par-bc-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-bc-frmt = "EAN8") or
    (i-prod-bc begins par-pl-pfx and
    par-pl-pfx <> ? and
    par-pl-frmt <> ?) and
    (length (i-prod-bc) = 13 and
    par-pl-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-pl-frmt = "EAN8") then do:
  {&err-put} "Доп. БК имеет префикс, зарезервированный для собственных товарных (складских мест) бар-кодов. Пропускаем." {&new-line}.
  return.
end.
/* проверка длины кода и специальных случаев (топливо, вес) */
if length (i-prod-bc) < 6 then do:
  /* короткий код - товар должен быть топливным или весовым */
  if (lookup ({&petrolium}, goods-units.type) > 0 and
      lookup ({&divisional}, goods-units.type) > 0 or
      lookup ({&weight}, goods-units.type) > 0) and
      ub.goods.gds-type = {&gds-goods} then do:
    /* дробный (разливной) бензин или весовой товар */
    if  lookup ({&petrolium}, goods-units.type) > 0 and
        lookup ({&divisional}, goods-units.type) > 0 then do:
      /* топливный разливной товар:
      - запрещено добавлять собственные коды
      - запрещено добавлять бар-коды признаков и партий
      - запрещено добавлять доп. бар-коды
      - можно добавлять доп. топливный (2 разрядный, разновидность весового, только добавляется вручную)
      - доп. топливный можно добавлять только один
      */
      if  lookup ({&petrolium}, ub.units.type) > 0 and
          lookup ({&divisional}, ub.units.type) > 0 then do:
        /* топливный код */
        if length (i-prod-bc) > 2 then do:
          {&err-put} "Топливный код: " + i-prod-bc + " не должен быть длиннее 2 разрядов. Пропускаем." {&new-line}.
          return.
        end.
        /* проверяем, что топливный код - единственный */
        find first  ub.prod-bc where
                    ub.prod-bc.b-code = ub.bar-code.b-code and
                    ub.prod-bc.b-str <> i-prod-bc no-lock no-error.
        if available ub.prod-bc then do:
          {&err-put} "Товар топливный. Уже есть топливный код у этого товара: " ub.prod-bc.b-str
                     " Он должен быть только один. Пропускаем." {&new-line}.
          return.
        end.
      end.
      else do:
        /* НЕтопливный код */
        {&err-put} "Товар топливный. Можно импортировать только топливный код (с дробно-топливной единицей измерения). Пропускаем." {&new-line}.
        return.
      end.
    end.  /*бензин*/
/*    if lookup ({&weight}, goods-units.type) > 0 then do:
      /*ВЕСОВЫЕ КОДЫ НЕ ИМПОРТИРУЮТСЯ*/
      {&err-put} "Код  " + i-prod-bc + " - весовой. Весовые коды не импортируются. Пропускаем доп.бар-код." {&new-line}.
      return.
    end.*/
  end.
  else do:
    /* нетопливный и невесовой товар - короткий код */
    {&err-put} "Код короче 6 разрядов  " + i-prod-bc + " может соответствовать только весовому или дробному топливному товару. Пропускаем." {&new-line}.
    return.
  end.
end.
else do:
  /* длинный код > 6 */
  if  lookup ({&petrolium}, ub.units.type) > 0 and
      lookup ({&divisional}, ub.units.type) > 0 or
      lookup ({&weight}, ub.units.type) > 0 then do:
    {&err-put} "Весовой или топливный код  " + i-prod-bc + " не может быть длиннее 5 разрядов. Пропускаем." {&new-line}.
    return.
  end.
end.
/* проверяем наличие такого доп. БК для той же привязки (товара, признака, партии) */
find first  same-prod-bc where
            same-prod-bc.b-str  = i-prod-bc and
            same-prod-bc.b-code = bar-code.b-code no-lock no-error.
if available same-prod-bc then do trans:
  find current  same-prod-bc  exclusive-lock no-error.
  if available same-prod-bc
  then do:
     if i-bc-on eq yes
     then do:
         find first prod-bc where
                   prod-bc.b-str = i-prod-bc and
                   prod-bc.bc-on = yes       exclusive-lock no-error.
         if available prod-bc
         then do:
            {&wrn-put} "В БД уже есть такой доп. БК для товара: код : " prod-bc.b-code 
                         ", он включен. Добавляемый код тоже включен. ВЫключаем уже имеющийся в базе код. Добавляемый оставляем включенным." {&new-line}. 
            prod-bc.bc-on = no.
         end.
     end.
     same-prod-bc.bc-on = i-bc-on. /* Установим переданое значение  */
  end.
  if vMarkType eq 1 
  then
     same-prod-bc.bc-on-type = {&gtin}.
  else
     same-prod-bc.bc-on-type = "".
  find first buf_prod-bc-attr
     where
            buf_prod-bc-attr.b-str  = i-prod-bc
        and buf_prod-bc-attr.b-code = same-prod-bc.b-code 
        and buf_prod-bc-attr.attr-code = {&mark}
       /* buf_prod-bc-attr.attr-value = "yes" */
     no-lock no-error.
     
  if vMarkType eq 2 
  then do:
     if available buf_prod-bc-attr
     then do:
        if buf_prod-bc-attr.attr-value = "yes"
        then do:
           find current buf_prod-bc-attr exclusive-lock no-error.
            
           if available buf_prod-bc-attr
           then do:
              buf_prod-bc-attr.attr-value = "yes". 
           end.
           else do: /* очень маловероятный случай */ 
             create buf_prod-bc-attr.
             assign
                buf_prod-bc-attr.b-str  = i-prod-bc
                buf_prod-bc-attr.b-code = same-prod-bc.b-code  
                buf_prod-bc-attr.attr-code = {&mark}
                buf_prod-bc-attr.attr-value = "yes"
             .
           end.
        end.
     end.
     else do:
        create buf_prod-bc-attr.
        assign
           buf_prod-bc-attr.b-str  = i-prod-bc
           buf_prod-bc-attr.b-code = same-prod-bc.b-code  
           buf_prod-bc-attr.attr-code = {&mark}
           buf_prod-bc-attr.attr-value = "yes"
        .
     end.
  end.
  else if available buf_prod-bc-attr
  then do:
     find current buf_prod-bc-attr exclusive-lock no-error
       . 
     if available buf_prod-bc-attr
     then 
        delete buf_prod-bc-attr.
  end.   
end.
else do:
    /*
    Добавление бар-кодов через import.
    
    |---------------|-----|--------------|---------------|-------------------|
    | Уже имеется в |Dpl- |  Добавляемый |     Статус    |    Статус         |
    |     базе      | off |  код включен |  старого кода | добавляемого      |
    |  включенный   |     |              |  после импорта| кода после импорта|
    |      код      |     |              |               |                   |
    --------------------------------------------------------------------------
    |      Yes      | Yes |      Yes     |       No      |      No           |
    --------------------------------------------------------------------------
    |      Yes      | Yes |      No      |      Yes      |      No           |
    --------------------------------------------------------------------------
    |      Yes      | No  |      Yes     |       No      |     Yes           |
    --------------------------------------------------------------------------
    |      Yes      | No  |      No      |      Yes      |      No           |
    --------------------------------------------------------------------------
    |      No       | Yes |      Yes     |       No      |     Yes           |
    --------------------------------------------------------------------------
    |      No       | Yes |      No      |       No      |      No           |
    --------------------------------------------------------------------------
    |      No       | No  |      Yes     |       No      |     Yes           |
    --------------------------------------------------------------------------
    |      No       | No  |      No      |       No      |      No           |
    --------------------------------------------------------------------------
    */
    /* ищем повторный включенный */
    find first same-prod-bc where
               same-prod-bc.b-str = i-prod-bc and
               same-prod-bc.bc-on = yes       no-lock no-error.
    if available same-prod-bc then do:
      /* есть повторный включенный */
      find same-bar-code where
           same-bar-code.b-code = same-prod-bc.b-code no-lock.
      find same-goods where
           same-goods.gds-code = same-bar-code.gds-code no-lock.
      if  same-goods.prod-type = goods.prod-type AND
          same-goods.prod-code = goods.prod-code AND
          par-dif-pdbc = yes /* запрет повторных доп. БК для одного производителя */ then do:
        {&err-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
                   ", он включен и соответствует тому же производителю. Пропускаем в соответствии с настройкой." {&new-line}.
        return.
      end.
      if par-dpl-off = yes then do:
        if i-bc-on = no then do:
          {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он включен. Добавляемый код вЫключен. Таким его и добавляем." {&new-line}.
        end.
        else do:
          {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он включен. Добавляемый код тоже включен. Добавляем его вЫключеным в соответствии с настройкой." {&new-line}.
          assign
            i-bc-on = no.
          
          do transaction on error undo, return error return-value:
            find current same-prod-bc exclusive-lock.
            if same-prod-bc.bc-on-type eq {&gtin}
            then
               delete same-prod-bc.
            else
            assign
              same-prod-bc.bc-on = no.
          end.
          if available same-prod-bc
          then do:
          {&wrn-put} "Имевшийся в БД доп. БК (см. предыдущее сообщение) для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", который был включен, вЫключаем в соответствии с настройкой" {&new-line}.
          end.
       end.
      end.
      else do:
        if i-bc-on = yes then do:
          {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он включен. Добавляемый код тоже включен. ВЫключаем уже имеющийся в базе код. Добавляемый оставляем включенным." {&new-line}.
          do transaction on error undo, return error return-value :
            find current same-prod-bc exclusive-lock.
            if same-prod-bc.bc-on-type eq {&gtin}
            then
               delete same-prod-bc.
            else
                assign
                  same-prod-bc.bc-on = no.
          end.
          if available same-prod-bc
          then do: 
              {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                         ", он включен. Добавляемый код выключен. Добавляем код без изменений." {&new-line}.
           end.
           else do: 
              {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                         ". Переносим." {&new-line}.
           end. 
        end.
      end.
    end.
    else do:
      find first same-prod-bc where
                 same-prod-bc.b-str = i-prod-bc and
                 recid (same-prod-bc) <> recid (prod-bc) no-lock no-error.
      if available same-prod-bc then do:
        /* есть повторный выключенный */
        find  same-bar-code where
              same-bar-code.b-code = same-prod-bc.b-code no-lock.
        find same-goods where
             same-goods.gds-code = same-bar-code.gds-code no-lock.
        if  same-goods.prod-type = goods.prod-type AND
            same-goods.prod-code = goods.prod-code AND
            par-dif-pdbc = yes /* запрет повторных доп. БК для одного производителя */ then do:
          {&err-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
                     ", он выключен и соответствует тому же производителю. Пропускаем в соответствии с настройкой dif-pdbc." {&new-line}.
          return.
        end.
        if i-bc-on = yes then do:
            do transaction on error undo, return error return-value:
            find current same-prod-bc exclusive-lock.
            if same-prod-bc.bc-on-type eq {&gtin}
            then
               delete same-prod-bc.
            else
            assign
              same-prod-bc.bc-on = no.
          end.
          if available same-prod-bc
          then 
              {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                         ", он выключен. Добавляемый код включен. Добавляем код без изменений." {&new-line}.
                         
        end.
        else do:
            if same-prod-bc.bc-on-type eq {&gtin}
            then do transaction on error undo, return error return-value:
            find current same-prod-bc exclusive-lock.
            
               delete same-prod-bc.
            
             end.
          if available same-prod-bc
          then 
          {&wrn-put} "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                     ", он выключен. Добавляемый код вЫключен. Добавляем код без изменений." {&new-line}.
        end.
      end.
    end.
    if i-cst-code eq "1" and length (i-prod-bc) ne 14
    then do:
        {&err-put} " GTIN должен быть 14 символов. Импортированный GTIN: " i-prod-bc   {&new-line}.
        return.
    end.
    do transaction on error undo, return error return-value :
      define variable rid as recid no-undo .
      rid = ?.
  run trg/prod-bc2.p (
                      input  parparentproc
                      ,input yes /*p-silent*/
                      ,input par-dif-pdbc /* dif-pdbc */
                      ,input ? /*pbc-veto*/
                      ,input no /*send-ref*/
                      ,input if i-cst-code eq "1" then {&gtin} else (if lookup ({&weight}, goods-units.type) > 0 then {&loc-sc-code} else '') /*cdrg-type*/
                      ,input ""
                      ,buffer goods
                      ,input bar-code.b-code
                      ,input i-cst-code eq "2"
                      ,input-output i-prod-bc
                      ,output rid
                      ) no-error.
      if error-status :error
      then do:
          {&err-put} "Ошибка при импорте доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code {&new-line}
                     error-status:get-message(1) {&new-line} return-value  {&new-line}.
          return.
    
      end.
      else if rid = ? then do:
          {&err-put} "Невозможно импортировать доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code {&new-line}
                     error-status:get-message(1) {&new-line} return-value  {&new-line}.
          return.
      end.
      else do :
          find first  prod-bc where recid(prod-bc) eq rid
          exclusive-lock no-error.
          if available prod-bc
          then do:
             prod-bc.bc-on = i-bc-on. /* Установим переданое значение  */
          end.
      end.
    end.
end.
assign
  counter = counter + 1.
end.
end procedure.


procedure imp-input-way-bill:
/*--------------------------------------------------------------------------
    импорт внешней ПН
--------------------------------------------------------------------------*/
define variable n-c like ub.gds-prt.node-code no-undo.
define buffer bf_doc-line-attr for ub.doc-line-attr.

find ub.doc-line where
     ub.doc-line.doc-code  = ub.trn-doc.doc-code and
     ub.doc-line.artic     = ub.goods.artic and
     ub.doc-line.prod-code = ub.goods.prod-code and
     ub.doc-line.prod-type = ub.goods.prod-type no-error.
if available ub.doc-line then do:
  /* прибавляем к имеющейся строке */
  if ub.doc-line.unit-cli      = i-unit-cli and
     ub.doc-line.cli-base-rate = i-cli-base-rate then
    /* едизм пост-ка тот же, коэф тоже - нет проблем */
    assign
      ub.doc-line.cli-qnty      = ub.doc-line.cli-qnty + i-qnty
      ub.doc-line.price-cli     = i-price
      ub.doc-line.unit-cli      = i-unit-cli
      ub.doc-line.cli-base-rate = i-cli-base-rate
      .
  else do:
    /* другой едизм пост-ка - нужно пересчитывать кол-ва */
    if ub.doc-line.cli-base-rate = i-cli-base-rate then do:
      {&wrn-put} "Единица измерения поставщика в строке ПН: " ub.doc-line.unit-cli
                 " Не совпадает с импортируемой. Заменяем на: " i-unit-cli {&new-line}.
      ub.doc-line.unit-cli = i-unit-cli.
    end.
    else do:
      {&wrn-put} "Коэффициент в строке ПН: " ub.doc-line.cli-base-rate
                 " Не совпадает с импортируемым. Заменяем единицу измерения поставщика на основную: " ub.goods.unit-base
                 " и пересчитываем количества поставщика." {&new-line}.
      assign
        ub.doc-line.unit-cli      = ub.goods.unit-base
        ub.doc-line.cli-qnty      = ub.doc-line.cli-qnty * ub.doc-line.cli-base-rate +
                                 i-qnty * i-cli-base-rate
        ub.doc-line.cli-base-rate = 1
        ub.doc-line.price-cli     = i-price / i-cli-base-rate
        .
    end.
  end.
end.
else do:
  /* создаем новую строку */
  { str/crdoclin.i
    ub.trn-doc.doc-code
    ub.goods.artic
    ub.goods.prod-type
    ub.goods.prod-code
    "''"
    0
    "''"
    "''"
    ub.goods.prt-root
    0
    0
    0
    no-error
  }
  if error-status:error then do:
      {&err-put} SUBSTITUTE("Ошибка при вызове процедуры crdoclin &1 &2 &3",
                            return-value,
                            error-status:get-message(1),
                            error-status:get-message(2))  + {&new-line}.
      return error.
  end.

  find first ub.doc-line where ub.doc-line.doc-code  = ub.trn-doc.doc-code and
                            ub.doc-line.artic     = ub.goods.artic      and
                            ub.doc-line.prod-type = ub.goods.prod-type  and
                            ub.doc-line.prod-code = ub.goods.prod-code .

  assign
    ub.doc-line.cli-qnty      = 0
    ub.doc-line.doc-qnty      = 0
    ub.doc-line.fact-qnty     = 0
    ub.doc-line.price-cli     = i-price
    ub.doc-line.unit-cli      = i-unit-cli
    ub.doc-line.cli-base-rate = i-cli-base-rate
    ub.doc-line.cli-qnty      = i-qnty
    ub.doc-line.wt-brutto     = i-wt-brutto
    ub.doc-line.num-place     = i-num-place
    .
end.
/* ставки налогов берем всегда из последней строки */
assign
  ub.doc-line.VAT-pc        = v-VAT-pc
  ub.doc-line.SLT-pc        = v-SLT-pc
  .
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = ub.doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = ub.goods.gds-code    and
                                  bf_doc-line-attr.attr-code = "last-date"        no-error.
if not available bf_doc-line-attr and i-last-date <> ? then do:
   create bf_doc-line-attr.
   assign
     bf_doc-line-attr.doc-code   = ub.doc-line.doc-code
     bf_doc-line-attr.gds-code   = ub.goods.gds-code
     bf_doc-line-attr.attr-code  = "last-date"
     bf_doc-line-attr.attr-value = string(i-last-date)
   .
end.
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = ub.doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = ub.goods.gds-code    and
                                  bf_doc-line-attr.attr-code = "cst-code"        no-error.
if not available bf_doc-line-attr then do:
   create bf_doc-line-attr.
   assign
   bf_doc-line-attr.doc-code   = ub.doc-line.doc-code
   bf_doc-line-attr.gds-code   = ub.goods.gds-code
   bf_doc-line-attr.attr-code  = "cst-code"
   bf_doc-line-attr.attr-value = i-cst-code.
end.
else do:
  if i-cst-code <> "" then do:
   assign
     bf_doc-line-attr.attr-value = i-cst-code
   .
   end.

end.

find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = goods.gds-code    and
                                  bf_doc-line-attr.attr-code = {&lineattr-price-prod}    no-error.
if not available bf_doc-line-attr and i-price-prod <> 0 then do:
   create bf_doc-line-attr.
   assign
     bf_doc-line-attr.doc-code   = doc-line.doc-code
     bf_doc-line-attr.gds-code   = goods.gds-code
     bf_doc-line-attr.attr-code  = {&lineattr-price-prod}
     bf_doc-line-attr.attr-value = string(i-price-prod)
   .
end.
else do:
  if  available bf_doc-line-attr and i-price-prod <> 0 then do:
    assign
      bf_doc-line-attr.attr-value = string(i-price-prod)
    .
   end.
end.

find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = goods.gds-code    and
                                  bf_doc-line-attr.attr-code = {&lineattr-price-prod-vat}    no-error.
if not available bf_doc-line-attr and i-price-prod-vat <> 0 then do:
   create bf_doc-line-attr.
   assign
     bf_doc-line-attr.doc-code   = doc-line.doc-code
     bf_doc-line-attr.gds-code   = goods.gds-code
     bf_doc-line-attr.attr-code  = {&lineattr-price-prod-vat}
     bf_doc-line-attr.attr-value = string(i-price-prod-vat)
   .
end.
else do:
  if  available bf_doc-line-attr and i-price-prod-vat <> 0 then do:
    assign
      bf_doc-line-attr.attr-value = string(i-price-prod-vat)
    .
   end.
end.


/* при наличии шкалы нужно создавать gds-dtl на явно указанный либо 1 терминальный
   признак, потому что возможна смесь строк по признакам и корневому для одного товара */
if string-type = "SCALE" OR
   string-type = "CODE"  then do:
  /* явно задан признак - он найден выше - пишем в него */
  n-c = ub.gds-prt.node-code.
end.

if string-type = "ITEM" then do:
  /* признак явно не указан - берем 1 терминальный */
  find first ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root
       use-index level no-lock no-error.
  do while true:
    n-c = ub.gds-prt.node-code.
    find first ub.gds-prt where ub.gds-prt.upper-code = n-c
         use-index level no-lock no-error.
    if not available ub.gds-prt then
      leave.
  end.

end.


find ub.gds-dtl where
     ub.gds-dtl.doc-code  = ub.trn-doc.doc-code and
     ub.gds-dtl.artic     = ub.goods.artic and
     ub.gds-dtl.prod-code = ub.goods.prod-code and
     ub.gds-dtl.prod-type = ub.goods.prod-type and
     ub.gds-dtl.prt-code  = n-c no-error.
if not available ub.gds-dtl then do:
  assign counter = counter + 1.
  create ub.gds-dtl .
  assign
    ub.gds-dtl.obj-type      = ub.trn-doc.obj-type
    ub.gds-dtl.obj-code      = ub.trn-doc.obj-code
    ub.gds-dtl.doc-code      = ub.trn-doc.doc-code
    ub.gds-dtl.artic         = ub.goods.artic
    ub.gds-dtl.prod-code     = ub.goods.prod-code
    ub.gds-dtl.prod-type     = ub.goods.prod-type
    ub.gds-dtl.prt-code      = n-c
  .
end.

assign
  ub.doc-line.obj-type      = v-obj-type
  ub.doc-line.obj-code      = v-obj-code
  ub.doc-line.doc-qnty      = ub.doc-line.doc-qnty + (i-qnty * i-cli-base-rate)
  ub.doc-line.fact-qnty     = ub.doc-line.doc-qnty
  ub.doc-line.cli-base-rate = ub.doc-line.doc-qnty / ub.doc-line.cli-qnty
  ub.gds-dtl.doc-qnty       = ub.gds-dtl.doc-qnty + (i-qnty * i-cli-base-rate)
  ub.gds-dtl.fact-qnty      = ub.gds-dtl.doc-qnty
  count-upd              = count-upd + 1
  .
if string-type = "PART" then do:
  /* Создание партий */
  create ub.parts .
  buffer-copy   ub.doc-line  EXCEPT status_ to ub.parts
  assign
    ub.parts.out-code  = ub.doc-line.doc-code
    ub.parts.part-code = i-part-code
    ub.parts.cst-code  = i-cst-code
    ub.parts.last-date = i-last-date
    ub.parts.cli-qnty  = i-qnty
    ub.parts.qnty      = i-qnty * ub.doc-line.cli-base-rate
    ub.parts.fact-qnty = ub.parts.qnty
    ub.parts.dop       = substitute("&1;&2" ,i-price-prod,i-price-prod-vat )
  .

end.
for each ub.gds-dtl exclusive-lock where
        ub.gds-dtl.doc-code  = ub.trn-doc.doc-code and
        ub.gds-dtl.obj-type  = ub.trn-doc.obj-type and
        ub.gds-dtl.obj-code  = ub.trn-doc.obj-code and
        ub.gds-dtl.doc-code  = ub.trn-doc.doc-code and
        ub.gds-dtl.artic     = ub.goods.artic      and
        ub.gds-dtl.prod-code = ub.goods.prod-code  and
        ub.gds-dtl.prod-type = ub.goods.prod-type
        :
  find first ub.gds-prt no-lock  where ub.gds-prt.node-code = ub.gds-dtl.prt-code no-error .
  if not available ub.gds-prt then do:
    delete ub.gds-dtl .
  end.
end.

end procedure.

procedure imp-overvalue:
/*--------------------------------------------------------------------------
    импорт 1 строки ДНЦ
--------------------------------------------------------------------------*/
define variable v-price like ub.price-list.price-sale no-undo.
define variable v-bar-code as integer no-undo.
define variable  main-b-code  as integer   no-undo .

define buffer main_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer bf_bar-code for ub.bar-code  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .

find ub.price-doc-forming-gds where
     ub.price-doc-forming-gds.plt-id     = plt-id         and
     ub.price-doc-forming-gds.plt-db-num = plt-db-num     and
     ub.price-doc-forming-gds.pdf-id     = pdf-id         and
     ub.price-doc-forming-gds.pdf-db     = pdf-db         and
     ub.price-doc-forming-gds.b-code     = ub.bar-code.b-code no-error.

if available ub.price-doc-forming-gds then do:
  {&wrn-put} "Уже есть в данной переоценке. Цена: " ub.price-doc-forming-gds.price-sale-doc " Скидка: " ub.price-doc-forming-gds.d-pcnt " Заменяем цену, скидку." {&new-line}.
  count-upd = count-upd + 1.
end.
  define buffer buf_goods for ub.goods .
  find first buf_goods no-lock
    where buf_goods.gds-code = ub.bar-code.gds-code
    .

  assign
    counter = counter + 1
  .

  v-price    = i-price .
  v-bar-code = ub.bar-code.b-code  .

  /*
  ,input  {&pr-calc-no}
  ,input  i-d-pcnt
 */

     find first bf_bar-code where bf_bar-code.b-code = v-bar-code
     no-lock no-error.
     if not available bf_bar-code then do:
          {&err-put} SUBSTITUTE("Отсутствует БК для товара с bar-code: &1 &2 &3",
                    return-value,
                     v-bar-code,
                     error-status:get-message(1))  + {&new-line}.
         return .

     end.
     find first buf_goods where buf_goods.gds-code = bf_bar-code.gds-code  no-lock no-error.

     if not available buf_goods then do:
          {&err-put} SUBSTITUTE("Отсутствует товар с gds-code: &1 &2 &3",
                    bf_bar-code.gds-code ,
                    return-value,
                    error-status:get-message(1))  + {&new-line}.
     end.

    { gbl/gdsbcode.i
      buf_goods.gds-code
      ?
      main-b-code }

      find first buf_price-doc-forming-gds exclusive-lock where
                 buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
            and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
            and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
            and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
            and  buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
      if available buf_price-doc-forming-gds then do:
        delete buf_price-doc-forming-gds.
      end.
      imp-save = imp-save + 1 .
      if buf_goods.unit-base = bf_bar-code.unit-cli then do: /* ++++++++++++++++++++++ОСНОВНОЙ КОД */
          find first buf_price-doc-forming-gds exclusive-lock where
                     buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
                and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
                and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
                and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
                and  buf_price-doc-forming-gds.b-code     = main-b-code no-error .
          if not available buf_price-doc-forming-gds then do:
          run prcreate-new-price-doc-forming-gds in this-procedure (
              input recid ( buf_price-doc-forming )
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input par-pr-notls
            , input par-pr-altex
            , input par-pr-sclex
            , input imp-save
            , input buf_goods.gds-code
            , input v-price  /* цена */
            ) no-error.
            if error-status :error then do:
                {&err-put} SUBSTITUTE("prcreate-new-price-doc-forming-gds: &1 &2",
                          return-value,
                          error-status:get-message(1))  + {&new-line}.

            end.
            end.
            if main-b-code  <>  bf_bar-code.b-code then do:
                find first buf_price-doc-forming-gds exclusive-lock where
                          buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                          buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                          buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                          buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                          buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
                if available buf_price-doc-forming-gds then do:
                  delete buf_price-doc-forming-gds .
                end.
                imp-save = imp-save + 1.
                v-sec =  v-sec + 1 .

                  run create-line-pdf-mpl-lib (
                      input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input imp-save
                      ,input bf_bar-code.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input v-price
                      ,input ""
                      ,input 0
                      ,input-output v-sec ) no-error .
            end.
        end.
        else do: /* неосновной код */
        /* если нет основного */

        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code no-error .
        if not available main_price-doc-forming-gds then do:
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = v-cntxt-obj-type  and
                   buf_gds-obj.obj-code = v-cntxt-obj-code  and
                   buf_gds-obj.gds-code = buf_goods.gds-code     no-error .

        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input imp-save
          , input buf_goods.gds-code
          , input ( if available buf_gds-obj and buf_gds-obj.price-sale <> 0 then buf_gds-obj.price-sale else v-price / bf_bar-code.cli-base-rate )
          ) no-error.
          if error-status :error then do:
                {&err-put} SUBSTITUTE("Создание основного кода для неосновному: &1 &2",
                          return-value,
                          error-status:get-message(1))  + {&new-line}.
          end.
         /* +++++++++++ */
        end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
        if available buf_price-doc-forming-gds then do:
           delete buf_price-doc-forming-gds .
        end.
        imp-save = imp-save + 1.
        v-sec =  v-sec + 1 .
        run create-line-pdf-mpl-lib (
             input buf_price-doc-forming.plt-db-num
            ,input buf_price-doc-forming.plt-id
            ,input buf_price-doc-forming.pdf-db
            ,input buf_price-doc-forming.pdf-id
            ,input imp-save
            ,input bf_bar-code.b-code
            ,input buf_goods.artic
            ,input buf_goods.prod-type
            ,input buf_goods.prod-code
            ,input ""
            ,input 0
            ,input v-price
            ,input ""
            ,input 0
            ,input-output v-sec ) no-error .
            if error-status :error then do:
                {&err-put} SUBSTITUTE("неосновной код: &1 &2",
                          return-value,
                          error-status:get-message(1))  + {&new-line}.

            end.
        /* Подправим скидку по неосновному коду */
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code
                   no-error .

        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code
                   no-error .

        if available buf_price-doc-forming-gds then do:
           buf_price-doc-forming-gds.d-pcnt =
           (( (main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) - v-price  ) * 100) /
             ( main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) no-error .

        end.
        end. /* НЕОСНОВНОЙ  */

end procedure.


procedure delete-trn-doc :

  do
  on error undo, return error
  :
    for each ub.doc-line
      where ub.doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error
    :
      delete ub.doc-line .
    end.
    for each ub.gds-dtl
      where ub.gds-dtl.doc-code = ub.trn-doc.doc-code
    on error undo, return error
    :
      delete ub.gds-dtl .
    end.
    delete ub.trn-doc .
  end.

end procedure. /* delete-trn-doc */