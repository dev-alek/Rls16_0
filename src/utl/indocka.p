block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: indocka.p $
$Archive: utl/indocka.p $

Утилита импорта документов по датам

Автор: Суслов Алексей Юрьевич
Дата создания: 01/20/06
Author: Alexey Suslov
Creation date: 01/20/06

*/
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: indocka.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/indocka.p $":U .
define variable vss-description as character no-undo initial "Утилита импорта документов по датам":U .
{ cmp/str-glbl.i }
{ str/libbcrcn.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/lib-def.i  }
{ str/doc-code.i }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/cur-time.i }
{ trg/factord.i }
{ gbl/waitfram.i }
define input parameter parparentproc as   handle              no-undo.
define input parameter parobj-type   like ub.clients.obj-type no-undo.
define input parameter parobj-code   like ub.clients.obj-code no-undo.
define input parameter parfile-cli   as   character           no-undo.
define input parameter parfile-doc   as   character           no-undo.
define input parameter parstatus     as   integer             no-undo.
define input parameter paragnt       as   integer             no-undo.
define input parameter parboss       as   integer             no-undo.
define input parameter parwrkr       as   integer             no-undo.
define stream str-cli.
define stream str-cli-log.
define stream str-err.
define stream str-doc.
define stream str-doc-log.
{ gbl/getcntxt.i get }

define variable varfatal-error        as logical initial no no-undo.
define variable vartemp-str-cli       as character no-undo.
define variable vartemp-str-doc       as character no-undo.
define variable varln                 as integer   no-undo.
define variable varopen-err-cli       as logical initial no no-undo.
define variable varopen-err-doc       as logical initial no no-undo.
define variable varuser-action        as character no-undo.
define variable varprinted            as logical   no-undo.
define variable varfile-name-cli-log  as character no-undo.
define variable varfile-name-cli-err  as character no-undo.
define variable varfile-name-doc-log  as character no-undo.
define variable varfile-name-doc-err  as character no-undo.
define variable varobj-type           as character no-undo.
define variable varid-supp            as character no-undo.
define variable varobj-code           as integer   no-undo.
define variable varhost-code          as integer   no-undo.
define variable varcontract-code      as integer   no-undo.
define variable vardate               as date      no-undo.
define variable varprod-bc            as character no-undo.
define variable varqnty               as decimal   no-undo.
define variable varprice              as decimal   no-undo.
define variable varvat-pc             as decimal   no-undo.
define variable varresult             as character no-undo.
define variable vartype-bc            as character no-undo.
define variable varweight             as decimal   no-undo.
define variable vardb-num             as integer   no-undo.
define variable vartoday              as date      no-undo.
define variable vartime               as integer   no-undo.
define variable varuserid             as character no-undo.
define variable varday-end-fact-order as decimal   no-undo.
define variable vardoc-code           as character no-undo.
define variable varin-pay             as integer   no-undo.
define variable n-c                   like ub.gds-prt.node-code no-undo.
define variable varr-b                as character no-undo.
define variable varbase-rate          as decimal   no-undo.
define variable varbase-scale         as decimal   no-undo.
define variable varchg-inv            as logical   no-undo.
define variable varbc-pfx             as character no-undo.
define variable varbc-frmt            as character no-undo.
define variable varpar-type           as character no-undo.
define variable varend-new-line       as logical   no-undo.
define variable varcur-date           as date      no-undo.
define temp-table tt-id no-undo
field supp-type          as character
field supp-code          as integer
field id-supl-old-system as character
field contract-code      as integer
field ln                 as integer
index pi is unique primary ln
index supp supp-type supp-code contract-code
index id-supl-old-system is unique id-supl-old-system.

define temp-table tt-parts no-undo
field id-supl-old-system as character
field fact-date          as date
field b-code             as character
field qnty               as decimal
field price-cli          as decimal
field vat-pc             as decimal
field artic              as character
field prod-type          as character
field prod-code          as integer
field price-sale         as decimal
field ln                 as integer
index pi is unique primary ln.

define temp-table tt-result-doc no-undo
field supp-type          as character
field supp-code          as integer
field supp-name          as character
field contract-code      as integer
field fact-date          as date
field count-doc          as integer
index pi is unique primary supp-type supp-code contract-code fact-date count-doc
index fact-date fact-date
.

define temp-table tt-result no-undo
field supp-type          as character
field supp-code          as integer
field contract-code      as integer
field fact-date          as date
field artic              as character
field prod-type          as character
field prod-code          as integer
field vat-pc             as decimal
field price-cli          as decimal
field price-sale         as decimal
field count-doc          as integer
field total-qnty         as decimal
index pi is unique primary supp-type supp-code contract-code fact-date artic prod-type prod-code vat-pc price-cli count-doc
index count-doc supp-type supp-code contract-code fact-date artic prod-type prod-code count-doc.

define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_clients  for ub.clients.
define buffer bf_contract for ub.contract.
define buffer bf_bar-code for ub.bar-code.
define buffer bf_prod-bc  for ub.prod-bc.
define buffer bf_place    for ub.place.
define buffer bf_goods    for ub.goods.
define buffer bf_obj-date for ub.obj-date.
define buffer bf_store    for ub.store.
define buffer bf_shop     for ub.shop.
define buffer bf_sysconf  for ub.sysconf.
do on error undo, return error return-value :
on write of ub.obj-date override do:
end.
{ gbl/hostcode.i parobj-type parobj-code varhost-code }
find first bf_sysconf where bf_sysconf.host-code = varhost-code no-lock.
{ gbl/curr-r-b.i varr-b }
run get-db-num in parparentproc (output vardb-num).
run get-userid in parparentproc (output varuserid).
case parobj-type :
  when {&stock} then do:
    find bf_store where bf_store.obj-code = parobj-code no-lock.
    assign
      varin-pay = bf_store.in-pay.
  end.
  when {&shop} then do:
    find bf_shop where bf_shop.obj-code = parobj-code no-lock.
    assign
      varin-pay = bf_shop.in-pay.
  end.
  otherwise do:
    message "Не верный тип объекта: " parobj-type view-as alert-box.
    return error.
  end.
end case.
{ gbl/curobjdt.i
  parobj-type
  parobj-code
  varcur-date
  no-error
}
if error-status:error or varcur-date = ? then do:
  message "Нет текущей даты на объекте " parobj-type " " parobj-code view-as alert-box.
  return error.
end.

{ gbl/conf-rd.i
  "'bc-frmt':u"
  "'':u"
  "'':u"
  0
  "'':u"
  "'':u"
  "'':u"
  yes
  varbc-frmt
  varpar-type
  no-error
}

{ gbl/conf-rd.i
  "'bc-pfx':u"
  "'':u"
  "'':u"
  0
  "'':u"
  "'':u"
  "'':u"
  yes
  varbc-pfx
  varpar-type
  no-error
}

{ str/sclspref.i }
run gbl/filnline.p (input  parfile-cli
               ,output varend-new-line).
if varend-new-line = no then do:
  output stream str-cli to value(parfile-cli) append.
  put stream str-cli unformatted skip(1).
  output stream str-cli close.
end.
input stream str-cli from value(parfile-cli).
assign
  varfile-name-cli-log = entry(1, parfile-cli, ".") + ".log"
  varfile-name-cli-err = entry(1, parfile-cli, ".") + ".err".
output stream str-cli-log to value(varfile-name-cli-log).
assign
  varln = 0.
repeat :
  import stream str-cli unformatted vartemp-str-cli.
  assign
    varln = varln + 1.
  put stream str-cli-log unformatted "Считана строка " vartemp-str-cli " № " varln.
  if vartemp-str-cli <> "":u then do:
    if num-entries(vartemp-str-cli,";") <> 4 and
       num-entries(vartemp-str-cli,";") <> 3 then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " количество параметров согласно формату 'Тип;Код;ID_поставщика;Договор' должен состоять из 4 или 3-х позиций. В строке " vartemp-str-cli " их " num-entries(vartemp-str-cli,";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varobj-type = TRIM(entry(1, vartemp-str-cli, ";"), '"').
    if varobj-type <> {&cmp} and
       varobj-type <> {&prs} then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " первый параметр согласно формату 'Тип;Код;ID_поставщика;Договор' должен быть 'орг' или 'чел'. В строке " vartemp-str-cli " он " varobj-type skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varobj-code = integer(entry(2, vartemp-str-cli, ";")) no-error.
    if error-status:error then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " второй параметр согласно формату 'Тип;Код;ID_поставщика;Договор' должен быть целым числом. В строке " vartemp-str-cli " он " entry(2, vartemp-str-cli, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    if entry(4, vartemp-str-cli, ";") <> "":u then do:
      assign
        varcontract-code = integer(entry(4, vartemp-str-cli, ";")) no-error.
      if error-status:error then do:
        if varopen-err-cli <> yes then do:
          output stream str-err to value(varfile-name-cli-err).
          assign
            varopen-err-cli = yes.
        end.
        put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln " четвертый параметр согласно формату 'Тип;Код;ID_поставщика;Договор' должен быть целым числом. В строке " vartemp-str-cli " он " entry(4, vartemp-str-cli, ";") skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    else do:
      assign
        varcontract-code = 0.
    end.
    assign
      varid-supp = entry(3, vartemp-str-cli, ";").
    find first tt-id where tt-id.id-supl-old-system = varid-supp  no-error.
    if available tt-id then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". Уже есть строка № " tt-id.ln " где ID_поставщика " tt-id.id-supl-old-system " ." skip.
      assign
        varfatal-error = yes.
      next.
    end.
    find first bf_clients where bf_clients.obj-type = varobj-type and
                                bf_clients.obj-code = varobj-code no-lock no-error.
    if not available bf_clients then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". В справочнике нет клиента у которого тип " varobj-type " код " varobj-code skip.
      assign
        varfatal-error = yes.
      next.
    end.
    if varcontract-code <> 0 then do:
      find first bf_contract where bf_contract.host-code     = varhost-code     and
                                   bf_contract.contract-code = varcontract-code no-lock no-error.
      if not available bf_contract then do:
        if varopen-err-cli <> yes then do:
          output stream str-err to value(varfile-name-cli-err).
          assign
            varopen-err-cli = yes.
        end.
        put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln ". Объект " parobj-type " " parobj-code ".Фирма объекта " varhost-code " Нет договора с внутренним номером " varcontract-code " на данной фирме." skip.
        assign
          varfatal-error = yes.
        next.
      end.
      if bf_contract.cli-type <> bf_clients.obj-type or
         bf_contract.cli-code <> bf_clients.obj-code then do:
        if varopen-err-cli <> yes then do:
          output stream str-err to value(varfile-name-cli-err).
          assign
            varopen-err-cli = yes.
        end.
        put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln ". Объект " parobj-type " " parobj-code ".Фирма объекта " varhost-code " Договор с внутренним номером " entry(4, vartemp-str-cli, ";") " по поставщику. " bf_contract.cli-type " " bf_contract.cli-code " , но в строке указан поставщик " bf_clients.obj-type " " bf_clients.obj-code skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    create tt-id.
    assign
      tt-id.supp-type          = bf_clients.obj-type
      tt-id.supp-code          = bf_clients.obj-code
      tt-id.id-supl-old-system = varid-supp
      tt-id.contract-code      = varcontract-code
      tt-id.ln                 = varln
    no-error.
    if error-status:error then do:
      if varopen-err-cli <> yes then do:
        output stream str-err to value(varfile-name-cli-err).
        assign
          varopen-err-cli = yes.
      end.
      put stream str-cli-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". Ошибка при создании временной таблицы по поставщикам: " return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    put stream str-cli-log unformatted ". Считанная строка корректна. " skip.
  end.
end.

input  stream str-cli     close.
output stream str-cli-log close.
if varopen-err-cli = yes then do:
  output stream str-err close.
end.
if varfatal-error then do:
  message
    "Ошибка при импорте файла поставщиков." skip
    "Документы не загружались." skip
    view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки при импорте файла поставщиков"
    ,input  0
    ,input  varfile-name-cli-err
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
  return error.
end.
run gbl/filnline.p (input  parfile-doc
               ,output varend-new-line).
if varend-new-line = no then do:
  output stream str-doc to value(parfile-doc) append.
  put stream str-doc unformatted skip(1).
  output stream str-doc close.
end.
input stream str-doc from value(parfile-doc).
assign
  varfile-name-doc-log = entry(1, parfile-doc, ".") + ".log"
  varfile-name-doc-err = entry(1, parfile-doc, ".") + ".err".
output stream str-doc-log to value(varfile-name-doc-log).
assign
  varln = 0.
repeat :
  import stream str-doc unformatted vartemp-str-doc.
  assign
    varln = varln + 1.
  put stream str-doc-log unformatted "Считана строка " vartemp-str-doc " № " varln.
  if vartemp-str-doc <> "":u then do:
    if num-entries(vartemp-str-doc,";") <> 6 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " количество параметров согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен состоять из 6 позиций. В строке " vartemp-str-doc " их " num-entries(vartemp-str-doc,";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varid-supp = entry (1, vartemp-str-doc, ";").
    find first tt-id where tt-id.id-supl-old-system = varid-supp no-error.
    if not available tt-id then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " В строке указан ID_поставщика " varid-supp " такого идентификатора не было в файле идентификации поставщиков." skip.
      assign
        varfatal-error = yes.
      next.
    end.
    if entry(2, vartemp-str-doc, ";") = "":u then do:
      assign
        vardate = varcur-date.
      put stream str-doc-log unformatted ". Дата в строке не установлена. Устанавливаем текущую дату " vardate " .".
    end.
    else do:
      assign
       vardate = date(entry(2, vartemp-str-doc, ";")) no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln " второй параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть датой. В строке " vartemp-str-doc " он " entry(2, vartemp-str-doc, ";") skip.
        assign
          varfatal-error = yes.
        next.
      end.
      if vardate > varcur-date then do:
        if error-status:error then do:
          if varopen-err-doc <> yes then do:
            output stream str-err to value(varfile-name-doc-err).
            assign
              varopen-err-doc = yes.
          end.
          put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
          put stream str-err unformatted "Строка № " varln " Дата в файле " vardate " больше текущей даты объекта " varcur-date " ." skip.
          assign
            varfatal-error = yes.
          next.
        end.
      end.
    end.
    assign
      varprod-bc = entry(3, vartemp-str-doc, ";").
    if substring (varprod-bc, 1, length(varbc-pfx)) = varbc-pfx then do:
      if length (varprod-bc) = 13 and
         varbc-frmt = "EAN13":u or
         length (varprod-bc) = 8 and
         varbc-frmt = "EAN8":u then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " varln " Префикс штрих-кода является префиксом собственных бар-кодов. Строка " vartemp-str-doc " . Префикс " varbc-pfx skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    if lookup (substring (varprod-bc, 1, 2), varscales-pref) > 0 and
       length (varprod-bc) = 13                                 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " Префикс штрих-кода является префиксом весовых бар-кодов. Строка " vartemp-str-doc " . Префикс " varbc-pfx skip.
      assign
        varfatal-error = yes.
      next.
    end.
    define variable v-ii as integer no-undo .
    do v-ii = 1 to num-entries(varpgscales-pref):
      entry(v-ii, varpgscales-pref) = substring(entry(v-ii, varpgscales-pref), 1, 2).
    end.
    if lookup (substring (varprod-bc, 1, 2), varpgscales-pref) > 0 and
       length (varprod-bc) = 13                                 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " Префикс штрих-кода является префиксом штучных кодов для весов. Строка " vartemp-str-doc " . Префикс " varbc-pfx skip.
      assign
        varfatal-error = yes.
      next.
    end.

    { str/bc-rcnz.i
      parparentproc
      varprod-bc
      ?
      parobj-type
      parobj-code
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
    if not available bf_bar-code then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " в системе нет штрих-кода " varprod-bc  skip.
      assign
        varfatal-error = yes.
      next.
    end.
    find first bf_goods where bf_goods.gds-code = bf_bar-code.gds-code no-lock.
    assign
      varqnty = decimal(entry(4, vartemp-str-doc, ";")) no-error.
    if error-status:error or varqnty <= 0 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " четвертый параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть decimal и быть больше нуля. В строке " vartemp-str-doc " он " entry(4, vartemp-str-doc, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varprice = decimal(entry(5, vartemp-str-doc, ";")) no-error.
    if error-status:error or varprice <= 0 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " пятый параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть decimal и быть больше нуля. В строке " vartemp-str-doc " он " entry(5, vartemp-str-doc, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      varvat-pc = decimal(entry(6, vartemp-str-doc, ";")) no-error.
    if error-status:error or varvat-pc < 0 or varvat-pc >= 100 then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln " шестой параметр согласно формату 'ID_поставщика;Дата_партии;Штрих-код;Кол-во;Цена;Ставка_НДС' должен быть decimal, больше нуля и меньше ста. В строке " vartemp-str-doc " он " entry(4, vartemp-str-doc, ";") skip.
      assign
        varfatal-error = yes.
      next.
    end.
    create tt-parts.
    assign
      tt-parts.id-supl-old-system = varid-supp
      tt-parts.fact-date          = vardate
      tt-parts.b-code             = varprod-bc
      tt-parts.qnty               = varqnty
      tt-parts.vat-pc             = varvat-pc
      tt-parts.artic              = bf_goods.artic
      tt-parts.prod-type          = bf_goods.prod-type
      tt-parts.prod-code          = bf_goods.prod-code
      tt-parts.price-cli          = varprice
      tt-parts.price-sale         = varprice
      tt-parts.ln                 = varln       no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted ". Считанная строка имеет ошибки. " skip.
      put stream str-err unformatted "Строка № " varln ". Ошибка при создании временной таблицы по документам: " return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    put stream str-doc-log unformatted ". Считанная строка разобрана." skip.
  end.
end.
input  stream str-doc     close.
if varopen-err-doc = yes then do:
  output stream str-doc-log close.
  output stream str-err     close.
end.
if varfatal-error then do:
  message
    "Ошибка при импорте данных по документам." skip
    "Накладные в системе не создавались." skip
    view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки при импорте данных по документам"
    ,input  0
    ,input  varfile-name-doc-err
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
  return error.
end.
for each tt-parts use-index pi on error undo, return error return-value :
  find first tt-id where tt-id.id-supl-old-system    = tt-parts.id-supl-old-system.
  find first tt-result where tt-result.supp-type     = tt-id.supp-type     and
                             tt-result.supp-code     = tt-id.supp-code     and
                             tt-result.contract-code = tt-id.contract-code and
                             tt-result.fact-date     = tt-parts.fact-date  and
                             tt-result.artic         = tt-parts.artic      and
                             tt-result.prod-type     = tt-parts.prod-type  and
                             tt-result.prod-code     = tt-parts.prod-code  and
                             tt-result.vat-pc        = tt-parts.vat-pc     and
                             tt-result.price-cli     = tt-parts.price-cli  no-error.
  if available tt-result then do:
    assign
      tt-result.total-qnty = tt-result.total-qnty + tt-parts.qnty.
  end.
  else do:
    /*Есть документы по этому товару за этот день, но с другой ценой*/
    find first tt-result where tt-result.supp-type     = tt-id.supp-type     and
                               tt-result.supp-code     = tt-id.supp-code     and
                               tt-result.contract-code = tt-id.contract-code and
                               tt-result.fact-date     = tt-parts.fact-date  and
                               tt-result.artic         = tt-parts.artic      and
                               tt-result.prod-type     = tt-parts.prod-type  and
                               tt-result.prod-code     = tt-parts.prod-code  no-error.
    if available tt-result then do:
      find last tt-result where tt-result.supp-type     = tt-id.supp-type     and
                                tt-result.supp-code     = tt-id.supp-code     and
                                tt-result.contract-code = tt-id.contract-code and
                                tt-result.fact-date     = tt-parts.fact-date  and
                                tt-result.artic         = tt-parts.artic      and
                                tt-result.prod-type     = tt-parts.prod-type  and
                                tt-result.prod-code     = tt-parts.prod-code  use-index count-doc.
      find first tt-result-doc where tt-result-doc.supp-type     = tt-id.supp-type         and
                                     tt-result-doc.supp-code     = tt-id.supp-code         and
                                     tt-result-doc.contract-code = tt-id.contract-code     and
                                     tt-result-doc.fact-date     = tt-parts.fact-date      and
                                     tt-result-doc.count-doc     = tt-result.count-doc + 1 no-error.
      if not available tt-result-doc then do:
        find first bf_clients where bf_clients.obj-type = tt-id.supp-type and
                                    bf_clients.obj-code = tt-id.supp-code no-lock.
        create tt-result-doc.
        assign
          tt-result-doc.supp-type     = tt-id.supp-type
          tt-result-doc.supp-code     = tt-id.supp-code
          tt-result-doc.supp-name     = bf_clients.obj-name
          tt-result-doc.contract-code = tt-id.contract-code
          tt-result-doc.fact-date     = tt-parts.fact-date
          tt-result-doc.count-doc     = tt-result.count-doc + 1 no-error
        .
        if error-status:error then do:
          if varopen-err-doc <> yes then do:
            output stream str-err to value(varfile-name-doc-err).
            assign
              varopen-err-doc = yes.
          end.
          put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
          put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по шапкам документов: " return-value error-status:get-message(1) skip.
          assign
            varfatal-error = yes.
          next.
        end.
      end.
      create tt-result.
      assign
        tt-result.supp-type      = tt-result-doc.supp-type
        tt-result.supp-code      = tt-result-doc.supp-code
        tt-result.contract-code  = tt-result-doc.contract-code
        tt-result.fact-date      = tt-parts.fact-date
        tt-result.artic          = tt-parts.artic
        tt-result.prod-type      = tt-parts.prod-type
        tt-result.prod-code      = tt-parts.prod-code
        tt-result.vat-pc         = tt-parts.vat-pc
        tt-result.price-cli      = tt-parts.price-cli
        tt-result.count-doc      = tt-result-doc.count-doc
        tt-result.total-qnty     = tt-parts.qnty
        tt-result.price-sale     = tt-parts.price-sale
        no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по документам: " return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    else do:
      find first tt-result-doc where tt-result-doc.supp-type     = tt-id.supp-type     and
                                     tt-result-doc.supp-code     = tt-id.supp-code     and
                                     tt-result-doc.contract-code = tt-id.contract-code and
                                     tt-result-doc.fact-date     = tt-parts.fact-date  and
                                     tt-result-doc.count-doc     = 1                   no-error.
      if not available tt-result-doc then do:
        find first bf_clients where bf_clients.obj-type = tt-id.supp-type and
                                    bf_clients.obj-code = tt-id.supp-code no-lock.
        create tt-result-doc.
        assign
          tt-result-doc.supp-type     = tt-id.supp-type
          tt-result-doc.supp-code     = tt-id.supp-code
          tt-result-doc.supp-name     = bf_clients.obj-name
          tt-result-doc.contract-code = tt-id.contract-code
          tt-result-doc.fact-date     = tt-parts.fact-date
          tt-result-doc.count-doc     = 1 no-error
        .
        if error-status:error then do:
          if varopen-err-doc <> yes then do:
            output stream str-err to value(varfile-name-doc-err).
            assign
              varopen-err-doc = yes.
          end.
          put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
          put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по шапкам документов: " return-value error-status:get-message(1) skip.
          assign
            varfatal-error = yes.
          next.
        end.
      end.
      create tt-result.
      assign
        tt-result.supp-type      = tt-result-doc.supp-type
        tt-result.supp-code      = tt-result-doc.supp-code
        tt-result.contract-code  = tt-result-doc.contract-code
        tt-result.fact-date      = tt-parts.fact-date
        tt-result.artic          = tt-parts.artic
        tt-result.prod-type      = tt-parts.prod-type
        tt-result.prod-code      = tt-parts.prod-code
        tt-result.vat-pc         = tt-parts.vat-pc
        tt-result.price-cli      = tt-parts.price-cli
        tt-result.count-doc      = 1
        tt-result.total-qnty     = tt-parts.qnty
        tt-result.price-sale     = tt-parts.price-sale no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "Строка № " tt-parts.ln " имеет ошибки. " skip.
        put stream str-err unformatted "Строка № " tt-parts.ln ". Ошибка при создании результирующей временной таблицы по документам: " return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
  end.
  put stream str-doc-log unformatted "Строка № " tt-parts.ln " сохранена во временные таблицы. " skip.
end.
do transaction on error undo, return error return-value :
  for each tt-result-doc on error undo, return error return-value :
    { gbl/baserate.i varhost-code tt-result-doc.fact-date varbase-rate varbase-scale no-error }
    if error-status :error then do:
       if varopen-err-doc <> yes then do:
         output stream str-err to value(varfile-name-doc-err).
         assign
           varopen-err-doc = yes.
       end.
       put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
       put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc ". Ошибка при поиске курса базовой валюты за дату." " " return-value " " error-status:get-message(1) skip.
       assign
         varfatal-error = yes.
       next.
    end.
    if varbase-rate  = ? or
       varbase-rate  = 0 or
       varbase-scale = ? or
       varbase-scale = 0 then do:
       if varopen-err-doc <> yes then do:
         output stream str-err to value(varfile-name-doc-err).
         assign
           varopen-err-doc = yes.
       end.
       put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
       put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc ". Неверный курс базовой валюты." skip.
       assign
         varfatal-error = yes.
       next.
    end.
    /*Создаем дату по объекту*/
    find first bf_obj-date where bf_obj-date.obj-type = parobj-type             and
                                 bf_obj-date.obj-code = parobj-code             and
                                 bf_obj-date.sys-date = tt-result-doc.fact-date no-lock no-error.
    if not available bf_obj-date then do:
      run cur-time in this-procedure ( output vartoday
                                     , output vartime
                                     ).
      run factord-end-day in this-procedure
        (input  tt-result-doc.fact-date
        ,output varday-end-fact-order
        ) no-error .
      if error-status :error
      or varday-end-fact-order = ?
      or varday-end-fact-order = 0 then do:
         if varopen-err-doc <> yes then do:
           output stream str-err to value(varfile-name-doc-err).
           assign
             varopen-err-doc = yes.
         end.
         put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
         put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc ". Ошибка при определении фактического номера даты на объекте. Объект" parobj-type " " parobj-code " " return-value " " error-status:get-message(1) skip.
         assign
           varfatal-error = yes.
         next.
      end.
      create bf_obj-date.
      assign
        bf_obj-date.obj-type   = parobj-type
        bf_obj-date.obj-code   = parobj-code
        bf_obj-date.sys-date   = tt-result-doc.fact-date
        bf_obj-date.open-id    = varuserid
        bf_obj-date.open-date  = vartoday
        bf_obj-date.open-time  = vartime
        bf_obj-date.close-id   = varuserid
        bf_obj-date.close-date = vartoday
        bf_obj-date.close-time = vartime
        bf_obj-date.fact-order = varday-end-fact-order
        bf_obj-date.host-code  = varhost-code
        bf_obj-date.status_    = {&objdt-closed}
        no-error
      .
      if error-status:error then do:
         if varopen-err-doc <> yes then do:
           output stream str-err to value(varfile-name-doc-err).
           assign
             varopen-err-doc = yes.
         end.
         put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
         put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  ". Ошибка при создании даты на объекте : " return-value error-status:get-message(1) skip.
         assign
           varfatal-error = yes.
         next.
      end.
      release bf_obj-date no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  ". Ошибка при создании даты на объекте : " return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    /*Создаем документ*/
    run doc-code in this-procedure
      (input  "main":u,
       input  parobj-type,
       input  parobj-code,
       input  ?,
       output vardoc-code) no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при генерации номера документа." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    { str/crtrndoc.i
      ?
      ?
      varbase-rate
      varbase-scale
      tt-result-doc.supp-code
      tt-result-doc.supp-type
      tt-result-doc.supp-name
      vardb-num
      varuserid
      "''"
      vardoc-code
      tt-result-doc.fact-date
      {&income}
      false
      varhost-code
      no
      parobj-code
      parobj-type
      no
      varin-pay
      "'Документ создан утилитой по загрузке внешних данных'"
      no
      "{&no-slt}"
      {&wayb}
      "{&inc-vat}"
      {&TDEDT_Pri_Vnesh}
      {&repayment-code}
      no-error
    }
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  " Ошибка при создания шапки документа. " return-value " " error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code exclusive-lock.
    assign
      bf_trn-doc.agnt          = paragnt
      bf_trn-doc.boss          = parboss
      bf_trn-doc.wrkr          = parwrkr
      bf_trn-doc.contract-code = tt-result-doc.contract-code
      bf_trn-doc.exch-code     = 0
      bf_trn-doc.exch-rate     = 1
      bf_trn-doc.exch-scale    = 1
      bf_trn-doc.fact-date     = tt-result-doc.fact-date
      bf_trn-doc.fact-time     = 24 * 60 * 60 - 1
      bf_trn-doc.is-back-date  = (tt-result-doc.fact-date < vartoday)
      bf_trn-doc.print-rubl    = yes
      bf_trn-doc.user-db-num   = vardb-num
      bf_trn-doc.user-name     = varuserid
     no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при создания шапки документа, добавление полей." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    for each lib-trn_ret-doc       on error undo, return error return-value : delete lib-trn_ret-doc      . end.
    for each lib-trn_ret-line      on error undo, return error return-value : delete lib-trn_ret-line     . end.
    for each lib-trn_ret-line-attr on error undo, return error return-value : delete lib-trn_ret-line-attr. end.
    for each lib-trn_ret-dtl       on error undo, return error return-value : delete lib-trn_ret-dtl      . end.
    for each lib-trn_ret-parts     on error undo, return error return-value : delete lib-trn_ret-parts    . end.
    create lib-trn_ret-doc.
    buffer-copy bf_trn-doc to lib-trn_ret-doc no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при копировании документа во временную таблицу." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    for each tt-result where tt-result.supp-type     = tt-result-doc.supp-type     and
                             tt-result.supp-code     = tt-result-doc.supp-code     and
                             tt-result.contract-code = tt-result-doc.contract-code and
                             tt-result.fact-date     = tt-result-doc.fact-date     and
                             tt-result.count-doc     = tt-result-doc.count-doc     on error undo, return error return-value :
      find first bf_goods where bf_goods.artic     = tt-result.artic     and
                                bf_goods.prod-type = tt-result.prod-type and
                                bf_goods.prod-code = tt-result.prod-code no-lock.
      { gbl/termnode.i bf_goods.prt-root n-c }
      create lib-trn_ret-line.
      assign
        lib-trn_ret-line.fact-qnty      = tt-result.total-qnty
        lib-trn_ret-line.price-rubl     = tt-result.price-cli
        lib-trn_ret-line.price-base     = tt-result.price-cli / bf_trn-doc.base-rate * bf_trn-doc.base-scale
        lib-trn_ret-line.price-cli      = tt-result.price-cli
        lib-trn_ret-line.unit-cli       = bf_goods.unit-base
        lib-trn_ret-line.cli-qnty       = tt-result.total-qnty
        lib-trn_ret-line.doc-qnty       = tt-result.total-qnty
        lib-trn_ret-line.obj-type       = bf_trn-doc.obj-type
        lib-trn_ret-line.obj-code       = bf_trn-doc.obj-code
        lib-trn_ret-line.prod-type      = tt-result.prod-type
        lib-trn_ret-line.prod-code      = tt-result.prod-code
        lib-trn_ret-line.artic          = tt-result.artic
        lib-trn_ret-line.doc-code       = bf_trn-doc.doc-code
        lib-trn_ret-line.cli-base-rate  = 1
        lib-trn_ret-line.prt-root       = bf_goods.prt-root
        lib-trn_ret-line.prt-OK         = yes
        lib-trn_ret-line.VAT-pc         = tt-result.vat-pc
        lib-trn_ret-line.status_        = bf_trn-doc.status_
        lib-trn_ret-line.SLT-pc         = 0
        lib-trn_ret-line.line-num       = 0
        lib-trn_ret-line.wt-brutto      = 0
        lib-trn_ret-line.num-place      = 0
        lib-trn_ret-line.road-tax       = 0
        lib-trn_ret-line.excise         = 0
        lib-trn_ret-line.doc-density    = 1
        lib-trn_ret-line.fact-density   = 1
        lib-trn_ret-line.temperature    = 0
        lib-trn_ret-line.transport-base = 0
        lib-trn_ret-line.transport-rubl = 0
        lib-trn_ret-line.other-base     = 0
        lib-trn_ret-line.other-rubl     = 0
        lib-trn_ret-line.ext-doc-type   = bf_trn-doc.ext-doc-type
        lib-trn_ret-line.fact-order     = bf_trn-doc.fact-order
        lib-trn_ret-line.cons-vat-pc    = bf_sysconf.cons-vat-pc
        lib-trn_ret-line.cons-slt-pc    = 0
        no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " Ошибка при создании временной таблицы строк." return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      create lib-trn_ret-parts.
      assign
        lib-trn_ret-parts.prod-type      = tt-result.prod-type
        lib-trn_ret-parts.prod-code      = tt-result.prod-code
        lib-trn_ret-parts.artic          = tt-result.artic
        lib-trn_ret-parts.in-code        = bf_trn-doc.doc-code
        lib-trn_ret-parts.out-code       = bf_trn-doc.doc-code
        lib-trn_ret-parts.price-base     = tt-result.price-cli / bf_trn-doc.base-rate * bf_trn-doc.base-scale
        lib-trn_ret-parts.price-rubl     = tt-result.price-cli
        lib-trn_ret-parts.qnty           = tt-result.total-qnty
        lib-trn_ret-parts.obj-type       = bf_trn-doc.obj-type
        lib-trn_ret-parts.obj-code       = bf_trn-doc.obj-code
        lib-trn_ret-parts.fact-date      = bf_trn-doc.fact-date
        lib-trn_ret-parts.fact-num       = bf_trn-doc.fact-num
        lib-trn_ret-parts.VAT-pc         = tt-result.vat-pc
        lib-trn_ret-parts.part-code      = ""
        lib-trn_ret-parts.PS             = "Партия создана утилитой по загрузке информации из внешней системы"
        lib-trn_ret-parts.pay-code       = bf_trn-doc.pay-code
        lib-trn_ret-parts.status_        = no
        lib-trn_ret-parts.fact-qnty      = tt-result.total-qnty
        lib-trn_ret-parts.supp-type      = bf_trn-doc.cli-type
        lib-trn_ret-parts.supp-code      = bf_trn-doc.cli-code
        lib-trn_ret-parts.rsrv-free      = ?
        lib-trn_ret-parts.doc-type       = bf_trn-doc.doc-type
        lib-trn_ret-parts.cli-qnty       = tt-result.total-qnty
        lib-trn_ret-parts.pl-code        = ?
        lib-trn_ret-parts.VAT-type       = {&inc-vat}
        lib-trn_ret-parts.exch-code      = 0
        lib-trn_ret-parts.price-cli      = tt-result.price-cli
        lib-trn_ret-parts.cli-base-rate  = 1
        lib-trn_ret-parts.SLT-pc         = 0
        lib-trn_ret-parts.host-code      = bf_trn-doc.host-code
        lib-trn_ret-parts.is-supp        = yes
        lib-trn_ret-parts.SLT-type       = {&without-slt}
        lib-trn_ret-parts.cst-code       = ""
        lib-trn_ret-parts.last-date      = ?
        lib-trn_ret-parts.road-tax-base  = 0
        lib-trn_ret-parts.road-tax-rubl  = 0
        lib-trn_ret-parts.transport-base = 0
        lib-trn_ret-parts.transport-rubl = 0
        lib-trn_ret-parts.other-base     = 0
        lib-trn_ret-parts.other-rubl     = 0
        lib-trn_ret-parts.purch-code     = bf_trn-doc.purch-code
        lib-trn_ret-parts.contract-code  = bf_trn-doc.contract-code
      no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " Ошибка при создании временной таблицы партий." return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      create lib-trn_ret-dtl.
      assign
        lib-trn_ret-dtl.prod-type   = tt-result.prod-type
        lib-trn_ret-dtl.prod-code   = tt-result.prod-code
        lib-trn_ret-dtl.artic       = tt-result.artic
        lib-trn_ret-dtl.obj-type    = bf_trn-doc.obj-type
        lib-trn_ret-dtl.obj-code    = bf_trn-doc.obj-code
        lib-trn_ret-dtl.prt-code    = n-c
        lib-trn_ret-dtl.fact-qnty   = tt-result.total-qnty
        lib-trn_ret-dtl.doc-qnty    = tt-result.total-qnty
        lib-trn_ret-dtl.doc-code    = bf_trn-doc.doc-code
        lib-trn_ret-dtl.price-rubl  = (if varr-b = "rubl":u then tt-result.price-sale else tt-result.price-sale * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
        lib-trn_ret-dtl.price-base  = (if varr-b = "base":u then tt-result.price-sale else tt-result.price-sale / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
        lib-trn_ret-dtl.discnt-rubl = 0
        lib-trn_ret-dtl.discnt-base = 0
        lib-trn_ret-dtl.discnt-pc   = 0
        lib-trn_ret-dtl.discnt-type = yes
        lib-trn_ret-dtl.ov          = yes
        lib-trn_ret-dtl.cur-base    = tt-result.price-sale
      no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСД " tt-result.supp-type " " tt-result.supp-code " " tt-result.contract-code " " tt-result.fact-date " " tt-result.count-doc " " tt-result.artic " " tt-result.prod-type " " tt-result.prod-code " " tt-result.vat-pc " " tt-result.price-cli " " tt-result.price-sale " " tt-result.total-qnty " Ошибка при создании временной таблицы признаков." return-value error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
    end.
    { str/copy-in.i
      parparentproc
      recid(bf_trn-doc)
      lib-trn_ret-doc
      lib-trn_ret-line
      lib-trn_ret-line-attr
      lib-trn_ret-dtl
      lib-trn_ret-parts
      no
      yes
      yes
      yes
      this-procedure
      no-error
    }
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при запуске процедуры copy-in." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    assign
      bf_trn-doc.tot-cli = bf_trn-doc.tot-rubl.
    run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc)) no-error.
    if error-status:error then do:
      if varopen-err-doc <> yes then do:
        output stream str-err to value(varfile-name-doc-err).
        assign
          varopen-err-doc = yes.
      end.
      put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
      put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  "Ошибка при пересчете шапки документа." return-value error-status:get-message(1) skip.
      assign
        varfatal-error = yes.
      next.
    end.
    put stream str-doc-log unformatted "Cоздан документ " bf_trn-doc.doc-code " по результирующей строка шапки документа " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  skip.
    if parstatus > 0 then do:
      run str/trn-stat.p (input  parparentproc,
                      input this-procedure  ,
                      input  {&close-doc},
                      input  bf_trn-doc.doc-code,
                      input  no,
                      input  vardb-num,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  no,
                      output varchg-inv,
                      output table gds-list) no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  " Ошибка при закрытии документа до накл+. " return-value " " error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      put stream str-doc-log unformatted "Документ " bf_trn-doc.doc-code " закрыт до накл+. РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  skip.
    end.
    if parstatus > 1 then do:
      run str/trn-stat.p (input  parparentproc,
                      input this-procedure ,
                      input  {&close-doc},
                      input  bf_trn-doc.doc-code,
                      input  no,
                      input  vardb-num,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  ?,
                      input  no,
                      output varchg-inv,
                      output table gds-list) no-error.
      if error-status:error then do:
        if varopen-err-doc <> yes then do:
          output stream str-err to value(varfile-name-doc-err).
          assign
            varopen-err-doc = yes.
        end.
        put stream str-doc-log unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc " имеет ошибки при создании документов. " skip.
        put stream str-err unformatted "РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  " Ошибка при закрытии документа до факт. " return-value " " error-status:get-message(1) skip.
        assign
          varfatal-error = yes.
        next.
      end.
      put stream str-doc-log unformatted "Документ " bf_trn-doc.doc-code " закрыт до факт. РСШД " tt-result-doc.supp-type " " tt-result-doc.supp-code " " tt-result-doc.contract-code " " tt-result-doc.fact-date " " tt-result-doc.count-doc  skip.
    end.
  end.
  output stream str-doc-log close.
  if varfatal-error then do:
    output stream str-err close.
    message
    "Ошибка при создании документов в IBS Trade House." skip
    "Все загруженные документы откатываются." skip
    view-as alert-box error.
    run gbl/prnfilen.w
     (input  "Ошибки при создании документов в IBS Trade House."
     ,input  0
     ,input  varfile-name-doc-err
     ,input  7
     ,output varuser-action
     ,output varprinted
     ).
    return error.
  end.
end.
end.