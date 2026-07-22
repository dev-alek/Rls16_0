block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scan-n.p $
$Archive: cus/scan-n.p $

Процедура работы с мобильным сканером для заказов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

заполнение документов
простановка факт количеств

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-code   like ub.ord-doc.doc-code no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scan-n.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/scan-n.p $":U .
define variable vss-description as character no-undo init "Единая процедура работы с мобильным сканером".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ cus/ord-lib.i last-price }
{ cus/ord-lib.i create-ord-line }

define variable add-sens as logical init true  no-undo.
define variable bar-str as char no-undo.           /* строка для чтения бар-кода из файла              */
define variable pl-str as char no-undo.            /* строка для складского места                      */
define variable qnty-str as char no-undo.          /* строка количества по данному бар-коду со сканера */
define variable part-list as char no-undo init "". /* список бар-кодов партий для привязки места       */
define variable b-c as int no-undo.                /* обрабатываемый бар-код                           */
define variable rate as dec no-undo.               /* коэффициент для единиц из бар-кода        */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.                  /* тип параметра конфигурации */
define variable varplace as logical no-undo.
define variable is-err as log initial no no-undo.
define variable v-cli-base-rate like ub.goods.cli-base-rate no-undo.
define variable v-unit-cli like ub.goods.unit-cli no-undo.

define buffer sb-cli-gds  for ub.cli-gds   .
define buffer buf_doc-line for ub.doc-line  .

/* Описание временных таблиц для разборщика бар-кодов */

{ str/anlz-bc.i new }

def stream cur.
def stream log.                                                /* журнал сообщений */
def stream err.                                                /* журнал ошибок */
define variable scan-txt as char no-undo.                              /* имя обрабатываемого файла со сканера (с расширением) */
define variable scan-name as char no-undo.                             /* имя обрабатываемого файла со сканера (без расширения) */
define variable g-type as char no-undo init ?.                         /* тип строк документа - товар / услуга */
def  buffer buf_ord-doc  for ub.ord-doc.                                 /* буфер обрабатываемого документа */
def  buffer buf_ord-line for ub.ord-line.                                 /* буфер обрабатываемого ctr-документа */
define variable is-all as log no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable varerr as logical no-undo.
define variable mess as char no-undo.         /* строка сообщения для log-файла */
define variable glog as logical no-undo .

def frame a
    i format ">>>>9"  label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".

{ str/sclspref.i }

/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   чтение файла сканера
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "workabout ms15" "*.dbs",
                 "workabout" "*.imp",
                 "Инвентаризация с кассы" "*.inv",
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

find first buf_ord-doc where buf_ord-doc.doc-code = p-doc-code no-lock no-error.
     if error-status :error then return error.

  put stream log unformatted " " skip skip
        "Документ "     buf_ord-doc.doc-code
        " Тип: "        buf_ord-doc.doc-type
        " Статус: "     buf_ord-doc.status_
        " ОК: " string (buf_ord-doc.flag_, "+/-")
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
             mess     = main-bc.des.
      run proc-code in this-procedure ( input main-bc.nm
                                       ,input ""
                                       ,input varscales-pref
                                       ,input varpgscales-pref
                                       ) no-error.
      if error-status:error then do:
         assign is-err = yes.
      end.
  end.
message "Просмотрено :" i skip "Обработано :" j.
if is-err then
    message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
            "Смотрите log файл."
    view-as alert-box error buttons ok.




procedure proc-code :
define input parameter n-pp   as integer no-undo .   /* строка для складского места               */
DEFine INPUT PARAMeter mode-proc as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo .

define variable  pl-str as char no-undo.   /* строка для складского места               */

define buffer b-bar-code for ub.bar-code.       /* вспомогательный буфер                     */
define buffer pc-goods   for ub.goods.

DEFINE VARIABLE mode-create      as LOGICAL NO-UNDO.
DEFINE VARIABLE rec-old          as RECID NO-UNDO.
define variable varres           as logical         no-undo.
define variable var-code-temp    like ub.place.pl-code no-undo.
define variable g-log-char       as character no-undo.
define variable varprice-cli-old        like ub.ord-line.price-cli no-undo.
define variable varprice-rubl-old       like ub.ord-line.price-cli no-undo.
define variable varprice-base-old       like ub.ord-line.price-cli no-undo.
define variable varcli-qnty-old         like ub.ord-line.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.ord-line.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.ord-line.cli-qnty  no-undo.
define variable p-qnty                  like ub.ord-line.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.ord-line.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.ord-line.vat-pc    no-undo.
define variable varslt-pc-old           like ub.ord-line.vat-pc    no-undo.
define variable varroad-tax-old         like ub.ord-line.price-cli no-undo.
define variable varexcise-old           like ub.ord-line.price-cli no-undo.
define variable vartransport-rubl-old   like ub.ord-line.price-cli no-undo.
define variable varother-rubl-old       like ub.ord-line.price-cli no-undo.
define variable is-1 as logical no-undo .

{ cus/scan-tt.i }  /* просмотреть содержание ТТ таблиц */
    assign g-log-char = "yes".
    do transaction on error undo , leave:
       define variable tempmess as character no-undo.
       /*Запомним старое значение */

       find first buf_ord-line where buf_ord-line.artic = ub.goods.artic     and
                                 buf_ord-line.prod-type = ub.goods.prod-type and
                                 buf_ord-line.prod-code = ub.goods.prod-code and
                                 buf_ord-line.doc-code  = p-doc-code    no-error.
       if available buf_ord-line then do:
          assign
          mode-create = no
          varprice-cli-old       = buf_ord-line.price-cli
          varprice-rubl-old      = buf_ord-line.price-rubl
          varprice-base-old      = buf_ord-line.price-base
          varcli-qnty-old        = buf_ord-line.cli-qnty
          varcli-base-rate-old   = buf_ord-line.cli-base-rate
          varfact-qnty-old       = buf_ord-line.qnty
          varvat-pc-old          = buf_ord-line.vat-pc
          varslt-pc-old          = buf_ord-line.slt-pc
          varroad-tax-old        = buf_ord-line.road-tax
          varexcise-old          = buf_ord-line.excise
          vartransport-rubl-old  = buf_ord-line.transport-rubl
          varother-rubl-old      = buf_ord-line.other-rubl.
       end.
       else mode-create = yes.

  if is-all = true then p-qnty =  decimal(qnty-str) .
  if is-all = false then p-qnty =   decimal(qnty-str)  + varfact-qnty-old .
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
          if is-1 = true then p-qnty =  decimal(qnty-str) .
          if is-1 = false then p-qnty =   decimal(qnty-str)  + varfact-qnty-old .
  end.

  /* создадим линию заказа */

        find  first sb-cli-gds  where
              sb-cli-gds.cli-type  = buf_ord-doc.cli-type and
              sb-cli-gds.cli-code  = buf_ord-doc.cli-code and
              sb-cli-gds.host-code = buf_ord-doc.host-code  and
              sb-cli-gds.artic     = ub.goods.artic      and
              sb-cli-gds.prod-type = ub.goods.prod-type  and
              sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
        find first buf_doc-line no-lock where
                   buf_doc-line.doc-code  = sb-cli-gds.in-code and
                   buf_doc-line.artic     = sb-cli-gds.artic and
                   buf_doc-line.prod-type = sb-cli-gds.prod-type and
                   buf_doc-line.prod-code = sb-cli-gds.prod-code
                   no-error .
        if available buf_doc-line  then do:
            assign
              v-unit-cli        = buf_doc-line.unit-cli
              v-cli-base-rate   = buf_doc-line.cli-base-rate
              .
        end.
        else do:
          assign
            v-cli-base-rate = ub.goods.cli-base-rate
            v-unit-cli      = ub.goods.unit-cli
          .
        end.

   run create-ord-line (
        p-doc-code              , /* doc-code       */
        n-pp                    , /* line-num       */
        ub.goods.artic             , /* artic          */
        ub.goods.prod-code         , /* prod-code      */
        ub.goods.prod-type         , /* prod-type      */
        v-cli-base-rate         , /* cli-base-rate  */
        p-qnty                  , /* qnty           */
        v-unit-cli )              /* unit-cli       */
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

         if pl-str <> "" then run store-place in this-procedure  ( input pl-str
                                                                  ,input parscales-pref
                                                                  ,input parpgscales-pref
                                                                  ).

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


procedure store-place :
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   привязка партий по одной строке файла сканера к складскому месту
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
DEFine INPUT PARAMETER pl-str as CHAR NO-UNDO.
define input parameter parscales-pref as character no-undo.
define input parameter parpgscales-pref as character no-undo .

define variable varres        as logical         no-undo.
define variable var-code-temp like ub.place.pl-code no-undo.
define buffer pc-goods for ub.goods.
/*

   Распознавание любых кодов и бар-кодов :

     Ищется собственный числовой код с той же единицей измерения, что и исходный код.

     Если не найден собственный код, ищется место хранения.

   1 - строка с любым кодом или бар-кодом (доп., своим и т.д.)

   2 - название буфера ub.bar-code для поиска, если пустой - ub.bar-code
   3 - название буфера ub.prod-bc  для поиска, если пустой - ub.prod-bc
   4 - название буфера ub.place    для поиска, если пустой - ub.place

   5 - выражение - цена, если не пустой, то это вызов из продажи
   6 - если un-bc, то пишем в таблицу un-bc данные анализа

*/
define variable bc-frmt as character no-undo .
define variable bc-pfx  as character no-undo .
define variable pl-frmt as character no-undo .
define variable pl-pfx  as character no-undo .
define variable str-gen as character no-undo.  /* сгенеренный доп. бар-код      */
define variable src-gen-int as integer no-undo.

define variable rid_    as recid no-undo.  /* для поиска повторных бар-кодов */

release ub.prod-bc.
release ub.bar-code.
release ub.place.
define variable v-ii as integer no-undo .
do v-ii = 1 to num-entries(parpgscales-pref):
  entry(v-ii, parpgscales-pref) = substring(entry(v-ii, parpgscales-pref), 1, 2).
end.
if (lookup (substr (pl-str, 1, 2), parscales-pref) > 0
or lookup (substr (pl-str, 1, 2), parpgscales-pref) > 0
)
and
   length (pl-str) = 13 then do:
  /* весовой бар-код EAN-13 */
  /* выделяем весовой код и ищем */
  find first ub.prod-bc where
             ub.prod-bc.b-str = string (int (substr (pl-str, 3, 5)), "99999") and
             ub.prod-bc.bc-on = yes no-lock no-error.

end.
/* ищем доп БК таким, как он есть */
if not available ub.prod-bc then
  find first ub.prod-bc where
             ub.prod-bc.b-str = pl-str and
             ub.prod-bc.bc-on = yes no-lock no-error.
if not available ub.prod-bc and
   length (pl-str) < 5 then
  /* любой код короче 5 считаем весовым и дополняем слева нулями */
  find first ub.prod-bc where
             ub.prod-bc.b-str = string (int (pl-str), "99999") and
             ub.prod-bc.bc-on = yes no-lock no-error.
if available ub.prod-bc then DO:
  /* найден включенный дополнительный бар-код */
  rid_ = recid (prod-bc).

end.
else
  rid_ = ?.
if (rid_ <> ?          and
    ub.prod-bc.b-str = pl-str) or rid_ = ? then do:
  /* ищем повторный для ИСХОДНОГО, если не было дополнения слева нулями или вырезания из весового БК
     если весовой код был найден после дополнения или вырезания, повторные показаны НЕ БУДУТ ! */
  /*ВЕСОВОЙ НЕ МОЖЕТ БЫТЬ ВЫКЛЮЧЕН*/
  find first ub.prod-bc where
             ub.prod-bc.b-str = pl-str and
             recid (ub.prod-bc) <> rid_ no-lock no-error.
  if available ub.prod-bc then do:
    /* есть повторные или 1 выключенный - требуем подтверждения */
    if rid_ = ? then do:
       rid_ = recid (prod-bc).

    end.
    /* выбор правильного или отказ */
    run ref/bc-rcnz.w (input parparentproc,
                   input buf_ord-doc.obj-type,
                   input buf_ord-doc.obj-code,
                   input pl-str,
                   input  0,
                   input "choose",
                   input-output rid_).
    /* bc-rcnz.w может вернуть ?, если не подходит ни один из повторных */
  end.
  find ub.prod-bc where
       recid (ub.prod-bc) = rid_ no-lock no-error.

end.
if available ub.prod-bc then do:
  find ub.bar-code where
       ub.bar-code.b-code = ub.prod-bc.b-code no-lock.
end.
else do:
  /* доп БК не найден - ищем основной */
  { gbl/conf-rd.i "'bc-frmt'" "''" "''" 0 "''" "''" "''" yes bc-frmt par-type no-error }
  { gbl/conf-rd.i "'bc-pfx'"  "''" "''" 0 "''" "''" "''" yes bc-pfx  par-type no-error }

  if not error-status:error and
     par-type = "C":U and
     lookup (bc-frmt, "EAN8,EAN13") > 0 then do:
    /* формат из настроек прочитан */
    if length (pl-str) = 13 and
       bc-frmt = "EAN13" or
       length (pl-str) = 8 and
       bc-frmt = "EAN8" then do:
      if par-type = "C":U     and
         length (bc-pfx) <= 3 then do:

        /* префикс из настроек прочитан - макс длина не может быть больше 3, т.к. локал. код 9 разрядов */
        if substr (pl-str, 1, length (bc-pfx)) = bc-pfx then
          /* префиксы совпадают - это собственный бар-код - вырезаем локальный код */
          pl-str = substr (pl-str, length (bc-pfx) + 1, length (pl-str) - length (bc-pfx) - 1).
      end.
      else
        message "Ошибка параметра bc-pfx - нет префикса для собственных бар-кодов."
                view-as alert-box error.
    end.
  end.
  else
    message "Ошибка параметра bc-frmt - нет формата для собственных бар-кодов."
            view-as alert-box error.

  if length (pl-str) < 10 or
     length (pl-str) = 10 and
     pl-str <= "2147483647" then do:
    /* исходная строка влезает в integer - пробуем его искать как локальный код;
       ищем в другом буфере, т.к. нам нужен на выходе {&bar-code} с основным едизмом */
    find ub.bar-code where
         ub.bar-code.b-code = int (pl-str) no-lock no-error.
    if available ub.bar-code then do:

    end.
  end.
end.
/* Складские места */
if not available ub.bar-code then do:
  { gbl/conf-rd.i "'pl-frmt'" "''" "''" 0 "''" "''" "''" no pl-frmt par-type no-error }
  if not error-status:error and
     par-type = "C":U and
     lookup (pl-frmt, "EAN8,EAN13") > 0 then do:
    /* формат из настроек прочитан */
    if length (pl-str) = 13 and
       pl-frmt = "EAN13" or
       length (pl-str) = 8 and
       pl-frmt = "EAN8" then do:
      /* формат знакомый */
      { gbl/conf-rd.i "'pl-pfx'" "''" "''" 0 "''" "''" "''" no pl-pfx par-type no-error}
      if not error-status:error and
         par-type = "C":U then do:
        /* префикс из настроек прочитан */
        if substr (pl-str, 1, length (pl-pfx)) = pl-pfx then
          /* префиксы совпадают - это бар-код складского места - вырезаем локальный код */
          pl-str = substr (pl-str, length (pl-pfx) + 1, length (pl-str) - length (pl-pfx) - 1).
      end.
    end.
  end.
  if length (pl-str) < 10 or
     length (pl-str) = 10 and
     pl-str <= "2147483647" then do:
    /* исходная строка влезает в integer - пробуем его искать как локальный код */
    find ub.place where
         ub.place.obj-type = buf_ord-doc.obj-type and
         ub.place.obj-code = buf_ord-doc.obj-code and
         ub.place.pl-code = int (pl-str) no-lock no-error.

  end.
end.
IF not available ub.bar-code and
   not available ub.place    THEN DO:

   assign src-gen-int = integer (pl-str) no-error.
   if not error-status:error then do:
        /*


Тело процедуры формирования бар-кода


{1} - bc - для формирования собственного бар-кода, pl - для бар-кода складского места
{2} - переменная - строка для бар-кода
{3} - переменная - сгенерированый бар-код
{4} - без message
*/
  define variable tmp-str  as character no-undo.
  define variable tmp-num  as character no-undo.
  define variable i        as integer   no-undo.
  define variable sum      as integer   no-undo.
  define variable len-code as integer   no-undo.
  define variable varcont  as logical   initial yes no-undo.

  /* состыковка префикса и внутреннего кода */
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str = string( src-gen-int, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str = string( src-gen-int, "9999999" )
      .
    end.
    OTHERWISE DO:

          assign str-gen     = ""
                 varcont = no.

    END.
  END CASE.
  if varcont = yes then do:
    if integer( substring( tmp-str, 1, length( bc-pfx ) ) ) <> 0
    then do:

         assign str-gen     = ""
                varcont = no.

    end.
    else do:
      assign
        str-gen = bc-pfx + substring( tmp-str, length( bc-pfx ) + 1, length( tmp-str ) - length( bc-pfx ) )
        len-code    = length( str-gen )
      .

      /* подсчет контрольной суммы */
      define variable v-sum-char as character no-undo .
      assign
        sum = 0
      .
      do i = 1 to len-code by 2
      :
        assign
          v-sum-char = substr(str-gen, len-code - i + 1, 1)
        .
        if v-sum-char < "0"
        or v-sum-char > "9"
        then do:

             assign str-gen     = ""
                    varcont = no.

        end.
        assign
          sum = sum + integer(v-sum-char)
        .
      end.
      if varcont = yes then do:
        assign
          sum = sum * 3
        .
        do i = 2 to len-code by 2
        :
          assign
            v-sum-char = substr(str-gen, len-code - i + 1, 1)
          .

          if v-sum-char < "0"
          or v-sum-char > "9"
          then do:

               assign str-gen     = ""
                      varcont = no.

          end.
          assign
            sum = sum + integer(v-sum-char)
          .
        end.
        if varcont = yes then do:
           if sum mod 10 = 0 then do:
             assign
               str-gen = str-gen + '0'
             .
           end.
           else do:
             assign
               str-gen = str-gen + string(10 - sum mod 10)
             .
           end.
        end.
      end. /*varcont = yes*/
    end.
  end. /*varcont = yes*/

      if str-gen <> ""          then do:
         find first ub.prod-bc where
                    ub.prod-bc.b-str = str-gen and
                    ub.prod-bc.bc-on = yes     no-lock no-error.
         if available ub.prod-bc then do:
            find ub.bar-code where ub.bar-code.b-code = ub.prod-bc.b-code no-lock.
         end.
      end.
   end.
END.

if available ub.place then do:
  find ub.bar-code where ub.bar-code.b-code  = b-c no-lock.
  find first pc-goods where pc-goods.gds-code  = ub.bar-code.gds-code no-lock.
  run plgdsfnd (input  no,
                input  buf_ord-doc.obj-type,
                input  buf_ord-doc.obj-code,
                input  pc-goods.gds-code,
                output varres,
                output var-code-temp) no-error.
  if varres = yes or error-status:error then do:

      put stream log unformatted "***" mess "Нельзя перемещать партии товара по складским местам "
          pc-goods.artic " " pc-goods.prod-type " " pc-goods.prod-code
          " по объкту " buf_ord-doc.obj-type " " buf_ord-doc.obj-code " "  skip.
      put stream err unformatted bar-str "," qnty-str "," pl-str skip.

  end.
  else
end.
end procedure.
/*
Определение складского места для партии

Входные параметры:

p-chk-and-chs   задает режим работы процедуры
                true  - проверка того, что товар резервируется по складским местам
                        и выбор складского места
                false - только проверка
p-obj-type      тип объекта
p-obj-code      код объекта
p-gds-code      уникальный код товара

Возвращаемые параметры:

p-reserv-pl-code
   true  - товар резервируется по складским местам
   false - товар не резервируется по складским местам

p-pl-code
   0 - товар не резервируется по складским местам или не выбрано складское место
   если p-pl-code <> 0 то это код складского места,
                       по которому необходимо резервировать товар

Также программа может вернуть ошибку - это означает, что необходимо отказаться от
резервирования.
В этом случае RETURN-VALUE будет содержать описание ошибки.

*/

procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo.
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo.
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo.
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo.
  define output parameter p-reserv-pl-code as   logical             no-undo.
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo.

  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .

  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    no-error .
  if not available buf_goods then do:
    return error "Не найден товар. Первичный бар-код " + string(p-gds-code) .
  end.

{ gbl/gdsobjat.i
p-obj-type
p-obj-code
buf_goods.artic
buf_goods.prod-type
buf_goods.prod-code
'place-rsrv=request'
p-reserv-pl-code
no-error
}
if error-status :error then do:
  return error "Ошибка при запросе атрибута place-rsrv товара на объекте " .
end.

  if p-reserv-pl-code = false then do:
    /* товар не резервируется по складским местам */
    return .
  end.

  /* Если только проверка, то закончили */
  if p-chk-and-chs <> yes then do:
    return . /* --->>>--- */
  end.

  find first buf_pl-gds no-lock
    where buf_pl-gds.obj-type = p-obj-type
      and buf_pl-gds.obj-code = p-obj-code
      and buf_pl-gds.gds-code = p-gds-code
    no-error .
  if not available buf_pl-gds then do:
    return error "К товару не привязано ни одного места хранения" .
  end.

  /* проверяем, существует ли более чем одно складское место */
  find first buf_second_pl-gds no-lock
    where buf_second_pl-gds.obj-type = p-obj-type
      and buf_second_pl-gds.obj-code = p-obj-code
      and buf_second_pl-gds.gds-code = p-gds-code
      and recid(buf_second_pl-gds) <> recid(buf_pl-gds)
    no-error .
  if not available buf_second_pl-gds then do:
    /* возвращаем */
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    /* существует более чем одно складское место */
    /* пользователь должен выбрать складское место */
    run str/plgdssel.p
      (input  parparentproc
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-gds-code
      ,output p-pl-code
      ) no-error .
    if error-status :error then do:
      return error
        "Ошибка при вызове программы plgdssel.p" + chr(10)
        + error-status :get-message(1) + chr(10)
        + return-value + chr(10) .
    end.
    if p-pl-code = ?
    or p-pl-code = 0 then do:
      return error
        "Не выбрано место хранения " + chr(10) .

    end.
  end.
END PROCEDURE.