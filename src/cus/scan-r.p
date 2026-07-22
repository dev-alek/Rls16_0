block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scan-r.p $
$Archive: cus/scan-r.p $

Процедура работы с мобильным сканером для поставок

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

заполнение документов
простановка факт количеств и цен

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rcv-code   like ub.ord-doc-rcv.rcv-code no-undo.
define input parameter p-doc-code   like ub.ord-doc-rcv.doc-code no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scan-r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/scan-r.p $":U .
define variable vss-description as character no-undo init "Единая процедура работы с мобильным сканером".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ cus/ord-lib.i last-price }

define variable add-sens as logical init true  no-undo.
define variable bar-str as char no-undo.           /* строка для чтения бар-кода из файла              */
define variable pl-str as char no-undo.            /* строка для складского места                      */
define variable qnty-str as char no-undo.          /* строка количества по данному бар-коду со сканера */
define variable p-price as decimal   no-undo .
define variable part-list as char no-undo init "". /* список бар-кодов партий для привязки места       */
define variable b-c as int no-undo.                /* обрабатываемый бар-код                           */
define variable rate as dec no-undo.               /* коэффициент для единиц из бар-кода        */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.                  /* тип параметра конфигурации */
define variable varplace as logical no-undo.
define variable is-err as log initial no no-undo.

define buffer buf1_ord-line for ub.ord-line  .
define buffer buf_zakz_ord-line for  ub.ord-line  .
define variable v-cli-base-rate like ub.goods.cli-base-rate   no-undo .
define variable v-unit-cli      like ub.goods.unit-cli        no-undo .
define variable v-ord  as integer   no-undo .
define variable v-qnty as integer   no-undo .

/* Описание временных таблиц для разборщика бар-кодов */

{ str/anlz-bc.i new }

define stream cur.
define stream log.                                   /* журнал сообщений */
define stream err.                                   /* журнал ошибок */
define variable scan-txt as char no-undo.            /* имя обрабатываемого файла со сканера (с расширением) */
define variable scan-name as char no-undo.           /* имя обрабатываемого файла со сканера (без расширения) */
define variable g-type as char no-undo init ?.       /* тип строк документа - товар / услуга */
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.   /* буфер обрабатываемого документа */
define buffer buf_ord-line-rcv for ub.ord-line-rcv.  /* буфер обрабатываемого ctr-документа */
define variable is-all as log no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable varerr as logical no-undo.
define variable mess as char no-undo.         /* строка сообщения для log-файла */
define variable glog as logical no-undo .

define frame a
    i format ">>>>9"  label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".


/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   чтение файла сканера
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "workabout ms15" "*.dbs",
                 "workabout" "*.imp",
                 "Инвентаризация с кассы" "*.inv",
                 "Текстовые файлы" "*.txt",
                 "Все файлы" "*.*"
       update glog.
if not glog then return.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return.
end.
message "yes - переписать количество со сканера для всех товаров" skip
        "no - прибавить количество со сканера для всех товаров"   skip
        "cancel - спрашивать для каждого товара"
        view-as alert-box question buttons yes-no-cancel update is-all.

scan-name = entry (1, scan-txt, ".").

frame a:title = "Разбор файла : " + scan-txt.

output stream log to value (scan-name + ".log") append.
output stream err to value (scan-name + ".err") append.

put stream log unformatted "  " skip.
put stream log unformatted cur-time-string-sec() skip.

find first buf_ord-doc-rcv no-lock where
           buf_ord-doc-rcv.rcv-code = p-rcv-code and
           buf_ord-doc-rcv.doc-code = p-doc-code
           no-error.
if error-status :error then return error.

put stream log unformatted " " skip skip
        "Документ "     buf_ord-doc-rcv.rcv-code
                        buf_ord-doc-rcv.doc-code
        " Тип: "        buf_ord-doc-rcv.doc-type
        " Статус: "     buf_ord-doc-rcv.status_
        " ОК: " string (buf_ord-doc-rcv.flag_, "+/-")
                skip skip.
  /* установка типа документа =  товар  */
    g-type =  {&gds-goods} .

view frame a.
input stream cur from value (scan-txt).
  /* разбор бар-кодов по файлу со сканера */
  input stream cur from value (scan-txt).
  run str/bc-anlz.p
     (input parparentproc,
      input "file",
      input scan-txt,
      input yes,
      output varerr,
      output table in-bc
      ) no-error.
  if error-status:error then do:
     message "Ошибка при обработке файла сканера." skip
             error-status:get-message(1)
        view-as alert-box error buttons ok.
     return error.
  end.
  if varerr = yes then is-err = yes.

  /*Запишем результат разбора в log-file*/
  for each in-bc:
      if in-bc.rez = "err" then do:
         put stream log unformatted in-bc.err-msg skip.
         put stream err unformatted in-bc.bar-str skip.
         assign is-err = yes.
      end.
      if in-bc.des <> "" and in-bc.des <> ? then put stream log unformatted in-bc.des.
  end.
  for each un-bc:
      if un-bc.rez = "err" then do:
         put stream log unformatted un-bc.err-msg skip.
         put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
         assign is-err = yes.
      end.
     /*if un-bc.des <> "" and un-bc.des <> ? then put stream log unformatted un-bc.des skip.*/
  end.
  i = 0 .
  j = 0 .
  for each main-bc:
    i = i + 1.
    disp i with frame a.
    find ub.bar-code where ub.bar-code.b-code = main-bc.b-c no-lock.
    find ub.goods where ub.goods.gds-code = ub.bar-code.gds-code no-lock.
      /*Установим переменные для обработки в процедуре*/
      assign bar-str  = string(main-bc.b-c)
             qnty-str = string(main-bc.scn-qnty)
             rate     = 1
             pl-str   = main-bc.scn-pl
             mess     = main-bc.des
             p-price  = decimal(main-bc.scn-pl)
             .
      run proc-code in this-procedure  ( input main-bc.nm
                                        ,input ""
                                        ) no-error.
      if error-status:error then do:
         assign is-err = yes.
      end.
  end.

message 'Просмотрено :' i skip
        'Обработано  :' j skip
        'Несовпадений по ассортименту:' v-ord  skip
        'Несовпадений по количеству:  ' v-qnty
        if v-ord > 0 or v-qnty  > 0 then "Подробнее см в СОСТОЯНИЕ ЗАКАЗА" else ""
        .

if is-err then
    message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
            "Смотрите log файл."
    view-as alert-box error buttons ok.


procedure proc-code :
define input  parameter n-pp   as integer no-undo .   /* строка для складского места               */
define input  parameter mode-proc as CHAR NO-UNDO.

define buffer b-bar-code for ub.bar-code.       /* вспомогательный буфер                     */
define buffer pc-goods   for ub.goods.

define variable mode-create      as logical no-undo.
define variable rec-old          as recid no-undo.
define variable varres           as logical         no-undo.
define variable var-code-temp    like ub.place.pl-code no-undo.
define variable g-log-char       as character no-undo.
define variable varprice-cli-old        like ub.ord-line-rcv.price-cli no-undo.
define variable varprice-rubl-old       like ub.ord-line-rcv.price-cli no-undo.
define variable varprice-base-old       like ub.ord-line-rcv.price-cli no-undo.
define variable varcli-qnty-old         like ub.ord-line-rcv.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.ord-line-rcv.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.ord-line-rcv.cli-qnty  no-undo.
define variable p-qnty                  like ub.ord-line-rcv.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.ord-line-rcv.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.ord-line-rcv.vat-pc    no-undo.
define variable varslt-pc-old           like ub.ord-line-rcv.vat-pc    no-undo.
define variable varroad-tax-old         like ub.ord-line-rcv.price-cli no-undo.
define variable varexcise-old           like ub.ord-line-rcv.price-cli no-undo.
define variable vartransport-rubl-old   like ub.ord-line-rcv.price-cli no-undo.
define variable varother-rubl-old       like ub.ord-line-rcv.price-cli no-undo.
define variable is-1 as logical no-undo .

{ cus/scan-tt.i }  /* просмотреть содержание ТТ таблиц */
    assign g-log-char = "yes".
    do transaction on error undo , leave:
       define variable tempmess as character no-undo.
       /*Запомним старое значение */
       find first buf_ord-line-rcv no-lock where
                  buf_ord-line-rcv.artic = ub.goods.artic         and
                  buf_ord-line-rcv.prod-type = ub.goods.prod-type and
                  buf_ord-line-rcv.prod-code = ub.goods.prod-code and
                  buf_ord-line-rcv.rcv-code  = p-rcv-code    and
                  buf_ord-line-rcv.doc-code  = p-doc-code
                  no-error.
       if available buf_ord-line-rcv then do:
          assign
          mode-create = no
          varprice-cli-old       = buf_ord-line-rcv.price-cli
          varprice-rubl-old      = buf_ord-line-rcv.price-rubl
          varprice-base-old      = buf_ord-line-rcv.price-base
          varcli-qnty-old        = buf_ord-line-rcv.cli-qnty
          varcli-base-rate-old   = buf_ord-line-rcv.cli-base-rate
          varfact-qnty-old       = buf_ord-line-rcv.qnty
          varvat-pc-old          = buf_ord-line-rcv.vat-pc
          varslt-pc-old          = buf_ord-line-rcv.slt-pc
          varroad-tax-old        = buf_ord-line-rcv.road-tax
          varexcise-old          = buf_ord-line-rcv.excise
          vartransport-rubl-old  = buf_ord-line-rcv.transport-rubl
          varother-rubl-old      = buf_ord-line-rcv.other-rubl.
       end.
       else mode-create = yes.

  if is-all = true  then p-qnty =  decimal(qnty-str) .
  if is-all = false then p-qnty =  decimal(qnty-str)  + varfact-qnty-old .
  if is-all = ? then do:
      message "ТОВАР "
              ub.goods.artic
              ub.goods.prod-type
              ub.goods.prod-code  skip
              ub.goods.gds-name   skip  " "
              skip
              "YES - переписать количество со сканера товара = " decimal(qnty-str) skip
              "NO - прибавить количество со сканера для товара = " decimal(qnty-str)  + varfact-qnty-old  skip
              view-as alert-box question buttons yes-no update is-1.
          if is-1 = true then p-qnty  =  decimal(qnty-str) .
          if is-1 = false then p-qnty =   decimal(qnty-str)  + varfact-qnty-old .
  end.


  find first buf1_ord-line no-lock where
             buf1_ord-line.doc-code   = p-doc-code and
             buf1_ord-line.artic      = ub.goods.artic    and
             buf1_ord-line.prod-type  = ub.goods.prod-type  and
             buf1_ord-line.prod-code  = ub.goods.prod-code no-error .
  if available buf1_ord-line then do:
     if buf1_ord-line.qnty  <> p-qnty then do:
          v-qnty = v-qnty + 1.
          put stream err unformatted bar-str "," ub.goods.gds-name
        " по заказу " buf1_ord-line.qnty " по поставке " p-qnty skip.
     end.
  end.
  else do:
    v-ord = v-ord + 1.
    put stream err unformatted bar-str "," ub.goods.gds-name " нет в заказе " skip.
  end.

  find first buf_zakz_ord-line no-lock where
             buf_zakz_ord-line.doc-code  = p-doc-code and
             buf_zakz_ord-line.artic     = ub.goods.artic and
             buf_zakz_ord-line.prod-code = ub.goods.prod-code and
             buf_zakz_ord-line.prod-type = ub.goods.prod-type
             no-error .

    if available buf_zakz_ord-line then do:
       assign
         v-cli-base-rate = buf_zakz_ord-line.cli-base-rate
         v-unit-cli      = buf_zakz_ord-line.unit-cli
         .
    end.
    else do:
      assign
        v-cli-base-rate = ub.goods.cli-base-rate
        v-unit-cli      = ub.goods.unit-cli
        .
    end.


  /* создадим линию поставки */
   run create-ord-line-rcv (
        p-rcv-code       , /* rcv-code       */
        p-doc-code       , /* doc-code       */
        n-pp             , /* line-num       */
        ub.goods.artic      , /* artic          */
        ub.goods.prod-code  , /* prod-code      */
        ub.goods.prod-type  , /* prod-type      */
        v-cli-base-rate  , /* cli-base-rate  */
        p-qnty           , /* qnty           */
        v-unit-cli       , /* unit-cli       */
        p-price )
        .
       assign
       mess = mess + tempmess.
       if error-status:error then do:
         assign
         mess = mess + return-value.

         put stream err unformatted bar-str "," qnty-str skip.
         put stream log unformatted "***" mess " - ошибка" skip.

         return error.
       end.
       else do:

         put stream log unformatted mess " - успешно" skip.

         j = j + 1.
         disp j with frame a.

       end.
       /*Пересчет шапки приходной накладной*/
    if substring(g-log-char, 1, 4) = "qnty" then do:

          put stream err unformatted bar-str "," ENTRY(2, g-log-char, "=") skip.
          put stream log unformatted "***" mess " - не все количество зарезервировано" skip.

    end.
  end.

/* os-delete value (scan-txt). */
end procedure.



procedure create-ord-line-rcv :
define input parameter  p-rcv-code       like ub.ord-doc-rcv.rcv-code         no-undo .
define input parameter  p-doc-code       like ub.ord-doc-rcv.doc-code         no-undo .
define input parameter  p-line-num       like ub.ord-line-rcv.line-num        no-undo .
define input parameter  p-artic          like ub.ord-line-rcv.artic           no-undo .
define input parameter  p-prod-code      like ub.ord-line-rcv.prod-code       no-undo .
define input parameter  p-prod-type      like ub.ord-line-rcv.prod-type       no-undo .
define input parameter  p-cli-base-rate  like ub.ord-line-rcv.cli-base-rate   no-undo .
define input parameter  p-qnty           as decimal   no-undo .
define input parameter  p-unit-cli       like ub.ord-line-rcv.unit-cli        no-undo .
define input parameter  p-price          as decimal   no-undo .

define variable p-cli-qnty               as decimal   no-undo .

define buffer bbb_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer tt-goods for ub.goods .
define buffer buf_ord-doc for ub.ord-doc  .

 do
 on error undo, return error return-value
 :

 find first buf_ord-doc no-lock where
            buf_ord-doc.doc-code = ub.ord-line-rcv.doc-code no-error .

 find first bbb_ord-doc-rcv no-lock where
            bbb_ord-doc-rcv.rcv-code = p-rcv-code and
            bbb_ord-doc-rcv.doc-code = p-doc-code
            no-error .
 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.

 find first tt-goods where
      tt-goods.artic             =   p-artic          and
      tt-goods.prod-code         =   p-prod-code      and
      tt-goods.prod-type         =   p-prod-type      no-lock no-error .

 if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
              error-status :get-message(1)
              view-as alert-box error .
              undo, return error.
 end.
find first ub.ord-line-rcv where
           ub.ord-line-rcv.artic     = tt-goods.artic     and
           ub.ord-line-rcv.prod-type = tt-goods.prod-type and
           ub.ord-line-rcv.prod-code = tt-goods.prod-code and
           ub.ord-line-rcv.rcv-code  = p-rcv-code   and
           ub.ord-line-rcv.doc-code  = p-doc-code
           exclusive-lock    no-error.
      if not available ub.ord-line-rcv then do:
        create  ub.ord-line-rcv.
      end.
      assign
        ub.ord-line-rcv.gds-code       = tt-goods.gds-code
        ub.ord-line-rcv.doc-code       = p-doc-code
        ub.ord-line-rcv.rcv-code       = p-rcv-code
        ub.ord-line-rcv.line-num       = p-line-num
        ub.ord-line-rcv.artic          = p-artic
        ub.ord-line-rcv.prod-code      = p-prod-code
        ub.ord-line-rcv.prod-type      = p-prod-type
        ub.ord-line-rcv.cli-base-rate  = p-cli-base-rate
        ub.ord-line-rcv.qnty           = p-qnty
        ub.ord-line-rcv.cli-qnty       = ub.ord-line-rcv.qnty  / ub.ord-line-rcv.cli-base-rate
        ub.ord-line-rcv.unit-cli       = p-unit-cli
    .
/* цены */
     if p-price <> 0 then do:
        assign
          ub.ord-line-rcv.price-rubl =  p-price
          ub.ord-line-rcv.price-base =  ub.ord-line-rcv.price-rubl / bbb_ord-doc-rcv.base-rate * bbb_ord-doc-rcv.base-scale
          ub.ord-line-rcv.price-cli  =  ( p-price * ub.ord-line-rcv.cli-base-rate) / (bbb_ord-doc-rcv.exch-rate * bbb_ord-doc-rcv.exch-scale)
        .
     end.
     else do:
       /* если не со сканера, то из заказа */
      find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = ub.ord-line-rcv.doc-code no-error .

       if available buf_ord-doc then do:
       find first ub.ord-line no-lock where
                  ub.ord-line.doc-code   = ub.ord-line-rcv.doc-code and
                  ub.ord-line.artic      = tt-goods.artic    and
                  ub.ord-line.prod-type  = tt-goods.prod-type  and
                  ub.ord-line.prod-code  = tt-goods.prod-code no-error .
                  if available ub.ord-line then do:
                     assign
                      ub.ord-line-rcv.price-rubl = ub.ord-line.price-rubl
                      ub.ord-line-rcv.price-base = ub.ord-line.price-base
                      ub.ord-line-rcv.price-cli  = ub.ord-line.price-cli
                     .
                  end.
                  else do:
                    /* не нашли в заказе */
                    run last-price (
                          input  buf_ord-doc.host-code ,
                          input  tt-goods.artic ,
                          input  tt-goods.prod-type ,
                          input  tt-goods.prod-code ,
                          input  buf_ord-doc.cli-code  ,
                          input  buf_ord-doc.cli-type  ,
                          input  ub.ord-line-rcv.cli-base-rate ,
                          input  buf_ord-doc.exch-code ,
                          output ub.ord-line-rcv.price-base ,
                          output ub.ord-line-rcv.price-rubl ,
                          output ub.ord-line-rcv.price-cli  )
                    no-error  .
                    if error-status :error then message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "Ошибка поиска последней цены"
                      view-as alert-box error
                    .
                  end.
       end.
     end.
/* Налоги текущие на сейчас */
{ gbl/pftxvalg.i   tt-goods.gds-code  {&vat-tax-code}  ?  bbb_ord-doc-rcv.host-code  bbb_ord-doc-rcv.obj-type  bbb_ord-doc-rcv.obj-code  ub.ord-line-rcv.vat-pc  no-error }
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  assign
     ub.ord-line-rcv.sum-rubl = ub.ord-line-rcv.qnty * ub.ord-line-rcv.price-rubl
     ub.ord-line-rcv.sum-base = ub.ord-line-rcv.qnty * ub.ord-line-rcv.price-base
     ub.ord-line-rcv.sum-cli  = ub.ord-line-rcv.cli-qnty * ub.ord-line-rcv.price-cli
     .
 end. /* do */
end procedure. /* create-ord-line-rcv */