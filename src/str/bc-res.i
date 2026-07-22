/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Распознавание бар-кода

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05

Created by: Суслов А.Ю. 18.08.99
{1} - Тип обработки при считывании бар-кодов
         check      - только проверка
         processing - обработка данных
         all        - всё
   {2} - Вывод сообщений об ошибках
         log - пишем в log-файл (пример: все тот же несравненный s c a n . p)
         mes - при обработке будут выведены сообщения на экран
   {3} - заполняем таблицу ub-bc по товару "un-bc"

*/
def var mess as char no-undo.                                /* строка сообщения для log-файла */
&IF "{1}" = "check" OR "{1}" = "all"
&THEN
procedure check-code:
define input parameter parbar-str AS char no-undo.                 /* строка для чтения бар-кода из файла*/
define input parameter parprice   like ub.gds-dtl.price-base no-undo. /* Цена для распознования бар-кода    */
define input parameter parqnty    as dec no-undo. /*Только лишь для создания log файла*/
/*Иногда следует делать так, чтобы процедура работала а-ля отключили признаки*/
define input  parameter parg#doc-prt as logical no-undo.
define input  parameter parscales-pref as character no-undo.
define input  parameter parpgscales-pref as character no-undo.
define output parameter parplace   as log initial no no-undo.
define output parameter parb-c     as int no-undo.                  /* обрабатываемый бар-код             */
define output parameter parrate    as dec no-undo.                  /* коэффициент для единиц из бар-кода */
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
def buffer b-bar-code for ub.bar-code.                          /* вспомогательный буфер              */

ASSIGN mess = " Код: " + parbar-str + " количество: " + string (parqnty) + " ".
/*Иначе при повторном бар-коде на экран не может быть ничего выведено*/
{ str/bc-rcnz.i
  parparentproc
  parbar-str
  parprice
  v-cntxt-obj-type
  v-cntxt-obj-code
  yes
  no
  parscales-pref
  parpgscales-pref
  varresult
  vartype-bc
  varweight
  ub.bar-code
  ub.prod-bc
  ub.place
  no-error
}
if error-status:error then do:
  return error "Ошибка при разборе бар-кода: " + parbar-str.
end.
&if "{3}" = "un-bc" &then
  assign
    un-bc.type-bc = vartype-bc.
  if varresult = "place" then do:
    assign
      un-bc.pl-name = place.pl-name
      un-bc.loc1    = place.loc1
      un-bc.loc2    = place.loc2
      un-bc.loc3    = place.loc3
      un-bc.loc4    = place.loc4 .
  end.
&endif
if not available bar-code THEN DO:
   if add-sens = ? and available place
   then DO: parPlace = YES. RETURN. END.
   ELSE RETURN ERROR "Товар отсутствует в базе данных.".
END.
else do:
    assign  parb-c  = bar-code.b-code
            parrate = bar-code.cli-base-rate.
    find ub.goods where ub.goods.gds-code  = ub.bar-code.gds-code no-lock.
    &IF "{3}" = "un-bc"
    &THEN
       FIND FIRST ub.units WHERE ub.units.unit-name = ub.goods.unit-base NO-LOCK.
       FIND FIRST ub.clients WHERE ub.clients.obj-type = ub.goods.prod-type AND
                                ub.clients.obj-code = ub.goods.prod-code  NO-LOCK.
       ASSIGN un-bc.artic      = ub.goods.artic
              un-bc.prod-type  = ub.goods.prod-type
              un-bc.prod-code  = ub.goods.prod-code
              un-bc.prod-name  = ub.clients.obj-name
              un-bc.gds-name   = ub.goods.gds-name
              un-bc.unit-base  = ub.goods.unit-base
              un-bc.units-type = ub.units.type.

    &ENDIF
    find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.
    ASSIGN mess = mess + "Артикул: " + ub.goods.artic + " производитель: " + ub.goods.prod-type + " " + string (ub.goods.prod-code) + " " + ub.goods.gds-name + {&new-line} .
    /* если есть разбиение по признакам и шкала не пустая, а ссылка не на признак - то ошибка */
    if parg#doc-prt and gds-prt.node-name <> {&empty-scale} and
       can-find (first gds-prt where gds-prt.upper-code = bar-code.node-code) then
       RETURN ERROR "Ссылка не на подробный признак.".
    /* если нет разбиения по признакам и шкала не пустая, а ссылка не на корень, то переносим на корень */
    if not parg#doc-prt and gds-prt.node-name <> {&empty-scale} and
         bar-code.node-code <> gds-prt.node-code then do:
      /* ищем bar-code для корневого узла */
      find b-bar-code where recid (b-bar-code) = recid (bar-code) no-lock.
      find bar-code where bar-code.gds-code  = b-bar-code.gds-code
                      and bar-code.node-code = gds-prt.node-code          /* gds-prt - корень */
                      and bar-code.in-code   = b-bar-code.in-code
                      and bar-code.part-code = b-bar-code.part-code
                      and bar-code.unit-cli  = ub.goods.unit-base                    /* основная единица измерения */
                        no-lock.
      parb-c = bar-code.b-code.
      RETURN "Ссылка на подробный или узловой признак. Заменяем на код: " + STRING(bar-code.b-code).
    end.
end.
/*Для того, чтобы очищалась RETURN-VALUE*/
RETURN.
END PROCEDURE.
&ENDIF
&IF "{1}" = "processing" OR "{1}" = "all"
&THEN
procedure proc-code.
define input parameter pl-str as char no-undo.   /* строка для складского места               */
DEFine INPUT PARAMeter mode-proc as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo.
define buffer b-bar-code for ub.bar-code.       /* вспомогательный буфер                     */
DEFINE VARIABLE mode-create      as LOGICAL NO-UNDO.
DEFINE VARIABLE rec-old          as RECID NO-UNDO.
define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define buffer pc-goods for ub.goods.
define variable g-log-char as character no-undo.
define variable varprice-cli-old        like ub.doc-line.price-cli no-undo.
define variable varprice-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varprice-base-old       like ub.doc-line.price-cli no-undo.
define variable varcli-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.doc-line.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.doc-line.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varroad-tax-old         like ub.doc-line.price-cli no-undo.
define variable varexcise-old           like ub.doc-line.price-cli no-undo.
define variable vartransport-rubl-old   like ub.doc-line.price-cli no-undo.
define variable varother-rubl-old       like ub.doc-line.price-cli no-undo.
define variable lns-cnt                 as   integer               no-undo.
IF mode-proc = "PLACE" THEN DO:
    /* привязка ранее помещенных в список партий (только имеющихся в наличии) к складскому месту */
    do lns-cnt = 1 to num-entries (part-list):
      find ub.bar-code where ub.bar-code.b-code  = integer (entry (lns-cnt, part-list)) no-lock.
      find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
      RUN plgdsfnd (input  no,
                    input  v-cntxt-obj-type,
                    input  v-cntxt-obj-code,
                    input  pc-goods.gds-code,
                    output varres,
                    output var-code-temp) no-error.
     if varres = yes or error-status:error then do:
          &IF "{2}" = "log" &THEN
          put stream log unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
          put stream ler unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
          put stream err unformatted bar-str "," qnty-str "," pl-str skip.
          &ELSE
          MESSAGE "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      &endif
      end.
      else
      for each ub.parts where ub.parts.obj-type  = v-cntxt-obj-type
                       and ub.parts.obj-code  = v-cntxt-obj-code
                       and ub.parts.artic     = pc-goods.artic
                       and ub.parts.prod-type = pc-goods.prod-type
                       and ub.parts.prod-code = pc-goods.prod-code
                       and ub.parts.in-code   = ub.bar-code.in-code
                       and ub.parts.part-code = ub.bar-code.part-code
                       and ub.parts.rsrv-free = yes:
        ub.parts.pl-code = ub.place.pl-code.
        &IF "{2}" = "log" &THEN
        put stream log unformatted mess "Партия: код: " bar-code.b-code " артикул: " ub.parts.artic " номер: " ub.parts.part-code " Место: " ub.parts.pl-code " - успешно" skip.
        j = j + 1.
        disp j with frame a.
        &endif
      end.
    end.
    part-list = "".
END. /*Привязка к складским местам*/
ELSE DO:
  if add-sens = ? then part-list = if part-list = "" then string (b-c) else part-list + "," + string (b-c).
  else do:
    if ub.goods.gds-type <> {&gds-goods} and (t-doc.doc-type <> {&expense} or t-doc.internal) then do:
      &IF "{2}" = "log" &THEN
      put stream log unformatted "***" mess "Услуга не соответствует типу данной накладной" skip.
      put stream ler unformatted "***" mess "Услуга не соответствует типу данной накладной" skip.
      put stream err unformatted bar-str "," qnty-str skip.
      &ELSE
      MESSAGE "Услуга не соответствует типу данной накладной."
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      &endif
      return error.
    end.
    if g-type = ? then g-type = ub.goods.gds-type.
    if g-type <> ub.goods.gds-type then do:
      &IF "{2}" = "log" &THEN
      put stream log unformatted "***" mess "Тип товара не соответствует типу данной накладной" skip.
      put stream ler unformatted "***" mess "Тип товара не соответствует типу данной накладной" skip.
      put stream err unformatted bar-str ","  qnty-str skip.
      &else
      MESSAGE "Тип товара не соответствует типу данной накладной."
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      &endif
      return error.
    end.
    assign g-log-char = "yes".
    do transaction on error undo , leave:
       define variable tempmess as character no-undo.
       define buffer bf_doc-line for ub.doc-line.
       /*Запомним старое значение */
       find first ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                                 ub.doc-line.artic     = ub.goods.artic     and
                                 ub.doc-line.prod-type = ub.goods.prod-type and
                                 ub.doc-line.prod-code = ub.goods.prod-code no-error.
       if available ub.doc-line then do:
          assign
          mode-create = no
          varprice-cli-old       = ub.doc-line.price-cli
          varprice-rubl-old      = ub.doc-line.price-rubl
          varprice-base-old      = ub.doc-line.price-base
          varcli-qnty-old        = ub.doc-line.cli-qnty
          varcli-base-rate-old   = ub.doc-line.cli-base-rate
          varfact-qnty-old       = ub.doc-line.fact-qnty
          vardoc-qnty-old        = ub.doc-line.doc-qnty
          varvat-pc-old          = ub.doc-line.vat-pc
          varslt-pc-old          = ub.doc-line.slt-pc
          varroad-tax-old        = ub.doc-line.road-tax
          varexcise-old          = ub.doc-line.excise
          vartransport-rubl-old  = ub.doc-line.transport-rubl
          varother-rubl-old      = ub.doc-line.other-rubl.
       end.
       else mode-create = yes.
       { str/copy-scn.i
         parparentproc
         recid(t-doc)
         bar-code.b-code
         "decimal(qnty-str) * rate"
         is-all
         add-sens
         line-mode
         tempmess
         g-log-char
         no-error
       }
       assign
       mess = mess + tempmess.
       if error-status:error then do:
         assign
         mess = mess + return-value.
         &IF "{2}" = "log" &THEN
         put stream err unformatted bar-str "," qnty-str skip.
         put stream log unformatted "***" mess " - ошибка" skip.
         put stream ler unformatted "***" mess " - ошибка" skip.
         &else
         MESSAGE "Ошибка"
           VIEW-AS ALERT-BOX ERROR BUTTONS OK.
         &endif
         return error.
       end.
       else do:
         &IF "{2}" = "log" &THEN
         put stream log unformatted mess " - успешно" skip.
         &endif
         if pl-str <> "" then run store-place in this-procedure ( input pl-str
                                                                 ,input parscales-pref
                                                                 ,input parpgscales-pref
                                                                 ).
         &IF "{2}" = "log" &THEN
         j = j + 1.
         disp j with frame a.
         &endif
       end.
       find first ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code  and
                                 ub.doc-line.artic     = ub.goods.artic     and
                                 ub.doc-line.prod-type = ub.goods.prod-type and
                                 ub.doc-line.prod-code = ub.goods.prod-code no-error.
       /*Пересчет шапки приходной накладной*/
       if t-doc.doc-type = {&income} then do:
         if mode-create then do:
            { str/clcintrn.i
              parparentproc
               recid(doc-line)
               t-doc.doc-code
               ub.doc-line.artic
               ub.doc-line.prod-type
               ub.doc-line.prod-code
               0
               0
               0
               0
               0
               0
               0
               0
               0
               0
               0
               0
               0
              "'create'"
              "''"
              no-error
            }
            if error-status:error then return error return-value.
         end.
         else do:
            { str/clcintrn.i
              parparentproc
              recid(doc-line)
              ub.doc-line.doc-code
              ub.doc-line.artic
              ub.doc-line.prod-type
              ub.doc-line.prod-code
              varprice-cli-old
              varprice-rubl-old
              varprice-base-old
              varcli-qnty-old
              varcli-base-rate-old
              varfact-qnty-old
              vardoc-qnty-old
              varvat-pc-old
              varslt-pc-old
              varroad-tax-old
              varexcise-old
              vartransport-rubl-old
              varother-rubl-old
              "'update'"
              "''"
              no-error
            }
            if error-status:error then return error return-value.
         end.
       end.
    end. /*transaction*/
    if substring(g-log-char, 1, 4) = "qnty" then do:
       &IF "{2}" = "log" &THEN
          put stream err unformatted bar-str "," ENTRY(2, g-log-char, "=") skip.
          put stream log unformatted "***" mess " - не все количество зарезервировано" skip.
          put stream ler unformatted "***" mess " - не все количество зарезервировано" skip.
       &ENDIF
    end.
  end.
end.
&IF "{2}" = "log" &THEN
os-delete value (scan-txt).
&ENDIF
end procedure.
procedure store-place:
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   привязка партий по одной строке файла сканера к складскому месту
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
DEFine INPUT PARAMETER pl-str as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo.

define variable pl-c as int no-undo.
define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define buffer pc-goods for ub.goods.
{ str/bc-rcnz.i
  parparentproc
  pl-str
  ?
  v-cntxt-obj-type
  v-cntxt-obj-code
  yes
  no
  parscales-pref
  parpgscales-pref
  varresult
  vartype-bc
  varweight
  ub.bar-code
  ub.prod-bc
  ub.place
  no-error
}
if error-status:error then do:
  return error "Ошибка при разборе бар-кода: " + pl-str.
end.
if available place then do:
  find ub.bar-code where ub.bar-code.b-code  = b-c no-lock.
  find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
  RUN plgdsfnd (input  no,
                input  v-cntxt-obj-type,
                input  v-cntxt-obj-code,
                input  pc-goods.gds-code,
                output varres,
                output var-code-temp) no-error.
  if varres = yes or error-status:error then do:
      &IF "{2}" = "log" &THEN
      put stream log unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
      put stream ler unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "  skip.
      put stream err unformatted bar-str "," qnty-str "," pl-str skip.
      &ELSE
      MESSAGE "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " v-cntxt-obj-type " " v-cntxt-obj-code " "
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      &endif
  end.
  else
  for each ub.parts where ub.parts.obj-type  = v-cntxt-obj-type
                   and ub.parts.obj-code  = v-cntxt-obj-code
                   and ub.parts.artic     = pc-goods.artic
                   and ub.parts.prod-type = pc-goods.prod-type
                   and ub.parts.prod-code = pc-goods.prod-code
                   and ub.parts.in-code   = ub.bar-code.in-code
                   and ub.parts.part-code = ub.bar-code.part-code:
    if ub.parts.rsrv-free or
       ub.parts.out-code = t-doc.doc-code then ub.parts.pl-code = ub.place.pl-code.
  end.
end.
end procedure.
{ str/plgdsfnd.i  parparentproc }
&ENDIF
/* $Workfile$ e n d */