/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение ставок налогов на текущий момент

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

input  parameter parartic      артикул товара
input  parameter parprod-type  произ
input  parameter parprod-code  водитель
input  parameter parunit-base  единица по основному бар-коду
input  parameter parnode-code  элемент шкалы для поиска продажной цены по шкале, если ?, то на корень
input  parameter parunits-type units.type по товару
input  parameter parrec-id     recid товара, если кто-то из предидущих четырех параметров заданы как ?
input  parameter paris-log     пишем в log, вместо return error -> return "error"
input  parameter rdtaxcdvalue  код дорожного налога
input  parameter vattaxcdvalue код НДС
input  parameter exctaxcdvalue код акциза
input  parameter only-check    когда выходящие результаты не важны, кроме ошибки,
                               но нужно проверить товары например с дорожным налогом
                               вернется временная таблица с кодами ставок индивид налогов (см ниже)
                               и значения индивидуальных
input parameter  parhost-code   код фирмы
input parameter  parobj-type   тип объекта
input parameter  parobj-code   код объекта
input parameter  parroad-tax   дорожный налог
input parameter  parexcise     акциз
output temp-table  tt-tax   таблица с налогами, чтобы ее объявить в
                            основной программе достаточно сказать { str/tt-tax.i new}
                            если привязка налог-товар не найдена  (налог индивид или просто ошибка)
                            то tt-tax.rate-code = ?

  field tax-code   like tax.tax-code
  field rate-value like tax-rate-value.rate-value.
output parameter parerr-mes    список ошибок для log-файла
input-output parameter parprice-sale продажная цена

*/

define temp-table  tt-tax no-undo
  field tax-code    like ub.tax.tax-code
  field individual  like ub.tax.individual
  field tax-name    like ub.tax.tax-name format "x(12)" column-label "Налог"
  field rate-code   like ub.tax-rate.rate-code
  field rate-name   like ub.tax-rate.rate-name format "x(12)"
  field tax-type    like ub.tax.tax-type
  field rate-value  like ub.tax-rate-value.rate-value
  field tax-rate-gds-rc  as recid
  field to-cashdesk like ub.tax.to-cashdesk

  index tax-code is unique primary tax-code
  .

&SCOP return-error if paris-log then do: ~
                      parerr-mes = parerr-mes + varmes. ~
                      return "error". ~
                  end. ~
                  else do: ~
                        message varmes view-as alert-box error. ~
                        return error. ~
                  end.

procedure tax-val :

  define input  parameter       parartic      like ub.doc-line.artic     no-undo.
  define input  parameter       parprod-type  like ub.doc-line.prod-type no-undo.
  define input  parameter       parprod-code  like ub.doc-line.prod-code no-undo.
  define input  parameter       parunit-base  like ub.goods.unit-base    no-undo.
  define input  parameter       parnode-code  like ub.gds-prt.node-code  no-undo.
  define input  parameter       parunits-type like ub.units.type         no-undo.
  define input  parameter       parrec-id     as recid                   no-undo.
  define input  parameter       paris-log     as logical                 no-undo.
  define input  parameter       rdtaxcdvalue  as integer                 no-undo.
  define input  parameter       vattaxcdvalue as integer                 no-undo.
  define input  parameter       exctaxcdvalue as integer                 no-undo.
  define input  parameter       only-check    as logical                 no-undo.
  define input  parameter       parhost-code  like ub.sysconf.host-code  no-undo.
  define input  parameter       parobj-type   like ub.clients.obj-type   no-undo.
  define input  parameter       parobj-code   like ub.clients.obj-code   no-undo.
  define input  parameter       parroad-tax   like ub.doc-line.road-tax  no-undo.
  define input  parameter       parexcise     like ub.doc-line.excise    no-undo.
  define output parameter       parerr-mes    as character               no-undo.
  define input-output parameter parprice-sale like ub.price-list.price-sale no-undo.

  do
  on error undo, return error return-value
  :

    { str/get-pr.i def }

    define buffer buf_tax          for ub.tax .
    define buffer buf_tax-rate     for ub.tax-rate .
    define buffer buf_tax-units    for ub.tax-units .
    define buffer buf_tax-rate-gds for ub.tax-rate-gds .
    define buffer buf_goods        for ub.goods .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_units        for ub.units .
    define buffer buf_shop         for ub.shop .
    define buffer buf_store        for ub.store .
    define buffer buf_gds-prt      for ub.gds-prt .
    define buffer buf_tt-tax       for tt-tax .

    /*Локальные переменные*/
    define variable varrate-value    as decimal   initial ? no-undo.
    define variable pr-list-recid    as recid     initial ? no-undo.
    define variable varmes           as character no-undo.
    define variable varfactorrtvalue as char      initial ? no-undo.
    define variable varfactorrttype  as char      initial ? no-undo.
    define variable is-petrolium     as logical no-undo.
    define variable is-pieces        as logical no-undo.
    define variable vargds-code      like ub.goods.gds-code no-undo.
    define variable pargds-code      like ub.goods.gds-code no-undo.
    define variable var-fact-order   as decimal no-undo .
    define variable currate-code     like buf_tax-rate.rate-code no-undo .
    define variable currate-name     like buf_tax-rate.rate-name no-undo .
    define variable currate-gds-rc   as recid no-undo .
    define variable v-today          as date no-undo .
    define variable v-time           as integer no-undo .

    for each buf_tt-tax:
      delete buf_tt-tax.
    end.

    run cur-time in this-procedure(output v-today, output v-time).
    run factord-end-day in this-procedure (input v-today, output var-fact-order).

    if parartic     = ?
    or parprod-type = ?
    or parprod-code = ?
    or parunit-base = ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = parrec-id
        no-error .
    end.
    else do:
      find first buf_goods no-lock
        where buf_goods.artic = parartic
          and buf_goods.prod-type = parprod-type
          and buf_goods.prod-code = parprod-code
        no-error .
    end.
    if not available buf_goods then do:
      assign varmes = "Ошибка при поиске товара. Программа tax-val.i" + {&new-line} .
      {&return-error}
    end.
    assign
      parartic     = buf_goods.artic
      parprod-type = buf_goods.prod-type
      parprod-code = buf_goods.prod-code
      parunit-base = buf_goods.unit-base
      pargds-code  = buf_goods.gds-code
    .

    if parunits-type = ?
    then do:
      find buf_units no-lock
        where buf_units.unit-name = parunit-base
        no-error .
      if not available buf_units then do:
        assign
          varmes =  varmes + "Ошибка при поиске единицы измерения. Программа tax-val.i" + {&new-line}
        .
        {&return-error}
      end.
      assign
        parunits-type = buf_units.type
      .
    end.

    if parhost-code = ?
    or parhost-code = 0
    then do:
      { gbl/hostcode.i
        parobj-type
        abs(parobj-code)
        parhost-code
        no-error
      }
      if error-status :error then do:
        assign
          varmes =  varmes + substitute("Ошибка при определении фирмы для объекта &1 &2. Программа tax-val.i"
            ,string(parobj-type)
            ,string(parobj-code)
            ) + {&new-line}
        .
        {&return-error}
      end.
    end.

    /*Если к товару не привязан дорожный налог, это не индивидуальный налог
      и только проверка, то ничего делать не надо*/
    assign
      vargds-code = buf_goods.gds-code
    .
    for each buf_tax-units no-lock
      where LOOKUP(buf_tax-units.type, parunits-type) > 0
    ,first buf_tax no-lock
      where buf_tax.tax-code = buf_tax-units.tax-code
    :
      find first buf_tt-tax where
                 buf_tt-tax.tax-code = buf_tax.tax-code no-error .
      if not available buf_tt-tax then do:
        create buf_tt-tax .
      end.
      assign
        buf_tt-tax.tax-code = buf_tax.tax-code
      .
      if buf_tax.individual = false then do:
        assign
          currate-gds-rc = ?
        .
        _tax-rate-gds:
        for each buf_tax-rate-gds no-lock where
                buf_tax-rate-gds.gds-code = pargds-code and
                buf_tax-rate-gds.tax-code = buf_tax.tax-code,
        first buf_tax-rate where
              buf_tax-rate.tax-code  = buf_tax-rate-gds.tax-code and
              buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code no-lock
        by buf_tax-rate-gds.host-code
        by buf_tax-rate-gds.obj-type
        by buf_tax-rate-gds.obj-code
        by buf_tax-rate-gds.fact-order
        :
          if buf_tax-rate-gds.fact-order > var-fact-order then do:
            next _tax-rate-gds.
          end.
          if buf_tax-rate-gds.host-code = 0 or
            ((buf_tax-rate-gds.host-code = parhost-code) or
            (buf_tax-rate-gds.obj-type = parobj-type AND
            buf_tax-rate-gds.obj-code = parobj-code))
          then do:
            assign
            currate-code = buf_tax-rate.rate-code
            currate-name = buf_tax-rate.rate-name
            currate-gds-rc = recid(buf_tax-rate)
            .
          end.
          else do:
            next _tax-rate-gds.
          end. /*if buf_tax-rate-gds */
        end. /*FOR EACH buf_tax-rate-gds*/
        if currate-gds-rc = ? then do:
          assign varmes = "Не найдена ставка налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          {&new-line}.
          {&return-error}
        end.
      end. /*NOT individual*/
      assign
        buf_tt-tax.rate-code   = currate-code
        buf_tt-tax.individual  = buf_tax.individual
        buf_tt-tax.tax-name    = buf_tax.tax-name
        buf_tt-tax.rate-name   = currate-name
        buf_tt-tax.tax-type    = buf_tax.tax-type
        buf_tt-tax.to-cashdesk = buf_tax.to-cashdesk
        buf_tt-tax.tax-rate-gds-rc  = currate-gds-rc
      .
    end.

    if parprice-sale = ?
    or parexcise     = ?
    or parroad-tax   = ?
    then do:
      if parnode-code = ? then do:
          FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
          parnode-code = buf_gds-prt.node-code.
      end.
      { str/get-pr.i calc parobj-type parobj-code vargds-code parnode-code }
      assign
        parprice-sale = gp-price-sale
        parexcise     = gp-excise
        parroad-tax   = gp-road-tax
      .
    end.

    if only-check then do:
      return .
    end.

    /*а теперь значения найдем*/

    for each buf_tt-tax no-lock
    on error undo, return error
    :
      if buf_tt-tax.tax-rate-gds-rc = ? then NEXT.
      if not buf_tt-tax.individual then do:
        { gbl/pftaxval.i ? buf_tt-tax.tax-code buf_tt-tax.rate-code ? parhost-code parobj-type parobj-code varrate-value no-error }
        if error-status:error or varrate-value = ? then do:
          assign varmes = "Не найдена величина ставки налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name + " " + string(buf_tt-tax.rate-code) +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          " фирма: " + string(parhost-code) +
                          " объект: " + parobj-type + " " + string(parobj-code) + {&new-line}.
          {&return-error}
        end.
        assign
        buf_tt-tax.rate-value  = varrate-value
        .
      end. /*not individual*/
      else do: /*not individual*/
        if not avail buf_gds-prt then
        FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
        { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          is-petrolium
          is-pieces
          no-error
        }
        if (is-petrolium  and not is-pieces) and buf_goods.gds-type = {&gds-goods} then do:
          /*разливное топливо*/
          find FIRST buf_prod-bc where
                      buf_prod-bc.b-code     = buf_goods.gds-code     and
                      buf_prod-bc.bc-on = yes no-lock no-error.

          if not available buf_prod-bc then do:
            assign varmes = "Не найден ДОП.бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            {&return-error}
          end.
        end.
        else do: /*не разливное топливо, а что-то другое!!! */
          find buf_bar-code where
                buf_bar-code.gds-code  = vargds-code     and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.part-code = ""           and
                buf_bar-code.in-code   = ""           and
                buf_bar-code.unit-cli  = parunit-base  no-lock no-error.

          if not available buf_bar-code then do:
            assign varmes = "Не найден бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            {&return-error}
          end.
        end.
        if buf_tt-tax.tax-code = rdtaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = {&gds-goods}
                                then integer(buf_prod-bc.b-str) 
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parroad-tax
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
        if buf_tt-tax.tax-code = exctaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = {&gds-goods}
                                then integer(buf_prod-bc.b-str) 
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parexcise
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.

        /* if error-status:error then do:
        assign varmes = "~n" + "Ошибка при сохранении " + buf_prod-bc.b-str . 
            {&return-error}
        end.*/

      end. /* individual*/
    end. /*for each buf_tt-tax*/
  end.

end procedure. /* tax-val */