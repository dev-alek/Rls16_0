block-level on error undo, throw.
/*

$Revision: 8c1a0fd433e1, 1120, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: imp-kan3.p $
$Archive: cus/imp-kan3.p $

Импорт  в документ ДНЦ для КАН

Автор: Чернова Светлана Александровна
Дата создания: 05/20/09
Author: Svetlana Chernova
Creation date: 05/20/09


*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter file-name     as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8c1a0fd433e1, 1120, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-kan3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/imp-kan3.p $":U .
define variable vss-description as character no-undo init "Импорт  в документ ДНЦ для КАН".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i def}
{ ref/xobjgrp.i  }
{ str/hvrdtax.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
define buffer buf_price-doc-forming for ub.price-doc-forming  .
{ str/alt-calc.i "func"  }
{ str/alt-calc.i "proc" "''"  "''"  }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ str/lastincs.i }
{ ref/gdsoattr.i }
{ ref/obji-ad.i  }
/* { ref/typl-ad.i  } 25/X-2017 использование процедур type-price-list-add() и type-price-list-delete() отсутствует */
{ gbl/waitfram.i }


define buffer buf_goods    for ub.goods .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds.
define stream imp.
define stream err.

define variable text-string     as     character no-undo .
define variable i-doc-num       like   ub.price-doc-forming.pdf-id     no-undo .
define variable i-doc-db-num    as integer   no-undo .
define variable loc-ref-list    as     character no-undo .
define variable i-price         like ub.price-list.price-sale     no-undo.
define variable i-d-pcnt        like ub.price-list.d-pcnt      no-undo.
define variable impc as integer No-UNDO.
define variable imp-save as integer No-UNDO.
define variable v-b-code as integer no-undo .

define variable i-artic as char no-undo.
define variable i-scale as char no-undo.


/*******************************************************************/
/* выбираем переоценку */
{ gbl/getcntxt.i get }
for each x_obj-group : delete x_obj-group . end.
run str/docsprls.w ( parparentproc , "all" , ? , ? , "b-sel" , input-output loc-ref-list ) .
if loc-ref-list = '' then do:
  message
  "ДНЦ не выбран."
  view-as alert-box error.
  return error.
end.
find first  buf_price-doc-forming exclusive-lock where recid (buf_price-doc-forming) = integer(loc-ref-list).
if buf_price-doc-forming.stts <> int({&pdf-new}) then do:
  message
  "Статус ДНЦ должен быть 'новый'."
  view-as alert-box error.
  return error.
end.

define buffer buf_price-list-type for ub.price-list-type  .

find first  buf_price-list-type no-lock where
            buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id and
            buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
            if error-status :error or buf_price-list-type.stts = int({&pdf-delete})  then do:
              message
              "Статус ТПЛ удален, или нет доступа."
              return-value error-status :get-message(1)
              view-as alert-box error.
              return error.
            end.

  run metod-gop-obj in this-procedure (
      v-cntxt-db-num ,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      )  .

i-doc-num = buf_price-doc-forming.pdf-id.
i-doc-db-num = buf_price-doc-forming.pdf-db .
define variable l-ok as logical   no-undo .
run chec-par in this-procedure (output l-ok , input v-cntxt-host-code-obj, input v-cntxt-obj-type,input v-cntxt-obj-code ) no-error .

input stream imp from value (file-name) .
repeat:
  text-string = "".
  IMPORT stream imp UNFORMATTED text-string NO-ERROR.
  if trim(text-string) = "" then leave.
  impc          = impc + 1.

  if num-entries (text-string, ";") <> 11 then do:
    OUTPUT stream Err TO value ("Imp_Price.err") append.
    put stream Err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " Неправильное число параметров в строке, должно быть 10, в конце строки должен стоять знак ;" skip.
    export stream  Err text-string .
    output stream Err close.
    next.
  end.

  assign
  i-artic = ENTRY( 1, text-string, ";")
  i-price = dec(ENTRY( 7, text-string, ";"))
  .

  /*  Выделяем из товара шкалу -  31.001-AB-101-0034
          где: 31.001-AB  -  товар
                101/0034   - шкала       */

  i-scale  = "/".
  overlay ( i-artic, r-index(i-artic, "-"), 1) = i-scale no-error .
  i-scale = substring( i-artic, r-index(i-artic, "-") + 1 ) no-error .
  i-artic = substring( i-artic, 1, r-index(i-artic, "-") - 1 ) no-error .

  display
  impc  label "Прочитано"
  imp-save label "Сохранено"
  i-artic format "x(10)" label "Артикул"
  text-string format "x(40)" label "Строка файла"
  with frame ff view-as dialog-box
  title substitute(": Импорт товаров из файла в ДНЦ &1-&2" , i-doc-num , i-doc-db-num ) .
  pause 0.

  find first buf_goods no-lock where
             buf_goods.artic = i-artic no-error.
  if not available buf_goods then do:
    OUTPUT stream Err TO value ("Imp_Price.err") append.
    put stream Err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " Товар не найден в справочнике товаров" skip.
    export stream  Err text-string .
    output stream Err close.
    next.
  end.

  { gbl/gdsbcode.i
    buf_goods.gds-code
    ?
    v-b-code
    no-error
  }
  if error-status:error then do:
    OUTPUT stream Err TO value ("Imp_Price.err") append.
    put stream Err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " У товара нет собственного Бар-Кода" skip.
    export stream  Err text-string .
    output stream Err close.
    next.
  end.


  if i-price <= 0 or i-price = ? then do:
    OUTPUT stream Err TO value ("Imp_Price.err") append.
    put stream Err unformatted
    string(today, "99/99/9999") " "
    string(time, "HH:MM")
    " У товара  цена не задана" skip.
    export stream err text-string .
    output stream err close.
    next.
  end.

  find first buf_price-doc-forming-gds exclusive-lock where
              buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
         and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
         and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
         and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
         and  buf_price-doc-forming-gds.b-code     = v-b-code no-error .
  if available buf_price-doc-forming-gds then do:
     delete buf_price-doc-forming-gds.
  end.
          imp-save = imp-save + 1 .
          run prcreate-new-price-doc-forming-gds in this-procedure (
              input recid ( buf_price-doc-forming )
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input par-pr-notls
            , input par-pr-altex
            , input par-pr-sclex
            , input imp-save
            , input buf_goods.gds-code
            , input i-price  /* цена */
            ) no-error.
            if error-status :error then do:
                imp-save = imp-save - 1 .
                output stream err to value ("Imp_Price.err") append.
                put stream err unformatted
                    string(today, "99/99/9999") " "
                    string(time, "HH:MM")
                    substitute("Товар &1 нельзя добавить в ДНЦ &2 &3" , buf_goods.artic, return-value, error-status :get-message(1)  )
                    skip.
                export stream err text-string .
                output stream err close.
            end.
end.  /*    repeat:   */
input stream imp close.

message
substitute("Импорт из файла &1 закончен, прочитано &2,  создано строк в ДНЦ &3&4" +
         "Все строки из файла которые не удалось импортировать можно посмотреть в файле Imp_Price.err "
         , file-name
         , impc
         , imp-save
         , {&new-line})
view-as alert-box  INFORMATION.