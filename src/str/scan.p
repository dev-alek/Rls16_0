block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scan.p $
$Archive: str/scan.p $

Единая процедура работы с мобильным сканером

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

create: Суслов Алексей Юрьевич

заполнение документов
простановка факт количеств
привязка партий к складским местам

*/



define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter add-sens  as logical no-undo.  /* активна ли кнопка добавить в документе : yes / no - вызов из документа,? - вызов из гл. меню - привязка партий к складским местам */
define input  parameter p-doc-rec as recid no-undo .
define input  parameter p-name-file as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: scan.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/scan.p $":U .
define variable vss-description as character no-undo initial "Единая процедура работы с мобильным сканером":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/getcntxt.i def }
{ str/tt-tax.i   new }
{ str/libbcrcn.i     }
{ str/lib-trn.i      }
{ gbl/cur-time.i     }
{ gbl/waitfram.i noprocess }
{ str/trdcalib.i     }
{ gbl/getcntxt.i get }
{ str/anlz-bc.i  new }
{ gbl/getsect.i  def }

define buffer t-doc for ub.trn-doc.              /* буфер обрабатываемого документа */
define variable bar-str       as character no-undo.             /* строка для чтения бар-кода из файла              */
define variable pl-str        as character no-undo.             /* строка для складского места                      */
define variable qnty-str      as character no-undo.             /* строка количества по данному бар-коду со сканера */
define variable part-list     as character no-undo initial "".  /* список бар-кодов партий для привязки места       */
define variable b-c           as integer   no-undo.             /* обрабатываемый бар-код                           */
define variable rate          as decimal   no-undo.             /* коэффициент для единиц из бар-кода        */
define variable varplace      as logical   no-undo.
define variable is-err        as logical   no-undo initial no .
define variable v-num         as integer   no-undo.
define variable is-all        as logical   no-undo.
define variable i             as integer   no-undo.
define variable j             as integer   no-undo.
define variable v-user-action as character no-undo.
define variable v-printed     as logical   no-undo.
define variable varerr        as logical   no-undo.
define variable varanlz       as logical   no-undo.
define variable varlog        as logical   no-undo.
define variable varvalue      as character no-undo.
define variable vartype       as character no-undo.
define variable varline-file  as character no-undo.
define variable scan-txt      as character no-undo.             /* имя обрабатываемого файла со сканера (с расширением) */
define variable scan-name     as character no-undo.             /* имя обрабатываемого файла со сканера (без расширения) */
define variable g-type        as character no-undo init ?.      /* тип строк документа - товар / услуга */
define variable varnoapnd     as logical   no-undo .
define variable line-mode as character no-undo init ? .
define variable varis-petrolium as logical no-undo.
define variable varis-pieces as logical no-undo.
define variable v-silent as logical   no-undo init false .
define variable v-upperhandl as handle no-undo .
define variable v1 as character no-undo .
define variable v2 as character no-undo .
define variable v-pri-nakl- as logical   no-undo .
define variable v-first-del as logical   no-undo .

if num-entries(p-name-file, {&delim-par}) >= 2 then do:
  assign
    v1 = entry(1,p-name-file, {&delim-par})
    v2 = entry(2,p-name-file, {&delim-par})
    no-error
    .
   if error-status :error then
   assign
     v1 = p-name-file
     v2 = ?
   .
   v-upperhandl = widget-handle(v2) .
   p-name-file  = v1.
end.

find first t-doc no-lock where recid(t-doc) = p-doc-rec no-error .
/* p-doc-code  = ? Это добавление в складские места*/
{ str/sclspref.i }

/* Для запоминания старых значений doc-line и наката инкремента на шапку накладной */
define temp-table old-doc-line no-undo like ub.doc-line.

define stream cur.
define stream log.                                             /* журнал сообщений */
define stream ler.                                             /* журнал ошибок из журнала сообщений*/
define stream err.                                             /* журнал ошибок */

define buffer bb_doc-line for ub.doc-line.
define buffer bb_gds-prt  for ub.gds-prt.
define buffer bb_goods    for ub.goods.
define buffer bb_gds-dtl  for ub.gds-dtl.
define buffer bb_bar-code for ub.bar-code.

define temp-table tt-bar-code-doc no-undo
field b-c      as integer   /*бар-код  */
field scn-qnty as decimal   /*кол-во   */
index pi is primary b-c.

{ str/scr-neb.i }

define frame a
    i format ">>>>9" label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".
{ str/bc-res.i "all" "log" }
{ str/libbcrcn.i }
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   чтение файла сканера
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
if p-name-file = ? then do:
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "WorkAbout MS15"         "*.dbs",
               "WorkAbout"              "*.imp",
               "Инвентаризация с кассы" "*.inv",
               "Все файлы"               "*.*"
       update varlog.
if not varlog then return error.
end.
else do:
  scan-txt = p-name-file.
end.
if entry (2, scan-txt, ".") = "log" then do:
  message "Файл с расширением '.log' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "ler" then do:
  message "Файл с расширением '.ler' не может быть обработан. Переименуйте его.".
  return error.
end.

{ str/tdat-val.i
    t-doc.doc-code
    {&trdcattr-scanfile}
    varvalue
    vartype
    no-error
}
if lookup (scan-txt, varvalue) <> 0 then do:
  message "Файл с названием " scan-txt " уже загружался в документ " t-doc.doc-code " ." skip
          "Продолжить?" view-as alert-box question buttons yes-no update varlog.
  if varlog <> yes then do:
    return error.
  end.
end.
else do:
  assign
    varline-file = varvalue + min (",", varvalue) + scan-txt no-error.
  { str/tdat-wrt.i
      t-doc.doc-code
      {&trdcattr-scanfile}
      varline-file
      no-error
  }
end.


  assign
    v-pri-nakl- = false
    v-silent    = false
    v-first-del = false
  .
  run cb_is-silent in v-upperhandl (output v-silent )  no-error .
  if v-silent then do:
     v-num = 1.
  end.
  else do:
    if t-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
      and t-doc.status_  = {&wayb}
      and t-doc.flag_    = no
    then do:
      assign
        v-pri-nakl- = true
      .
    end.
    run gbl/d-askw.w
      ( input "Вопрос"
      , input "Выберите режим работы для обработки файла." + {&new-line}
      , input "|^"
      , input "Переписать|Прибавить|Спрашивать|"
             + (if v-pri-nakl- = true then "Обнулить|" else "":U)
             + "Отмена"
      , input "Переписать количество со сканера для всех товаров|"
            + "Прибавить количество со сканера для всех товаров|"
            + "Cпрашивать для каждого товара|"
            + (if v-pri-nakl- = true then "Удалить все строки и загрузить со сканера|" else "":U)
            + "Отменить"
      , input 1
      , input (if v-pri-nakl- = true then 5 else 4 )
      , output v-num
      ).
  end.

  case v-num :
    when 1 then do:
      assign is-all = yes.
    end.
    when 2 then do:
      assign is-all = no.
    end.
    when 3 then do:
      assign is-all = ?.
    end.
    when 4 then do:
      if v-pri-nakl- = true then do:
        assign
          is-all = yes
          v-first-del = true
        .
      end.
      else do:
        return error.
      end.
    end.
    otherwise do:
      return error.
    end.
  end case.

scan-name = entry (1, scan-txt, ".").

frame a :title = "Разбор файла : " + scan-txt.

{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'noapndsc' then varnoapnd = thbjattr_thbj-attr.property-value-logical  .
end.

if varnoapnd then do:
  output stream log to value (scan-name + ".log").
  output stream err to value (scan-name + ".err").
  output stream ler to value (scan-name + ".ler").
end.
else do:
  output stream log to value (scan-name + ".log") append.
  output stream err to value (scan-name + ".err") append.
  output stream ler to value (scan-name + ".ler") append.
end.

put stream log unformatted "  " skip.
put stream log unformatted cur-time-string-sec() skip.
put stream ler unformatted "  " skip.
put stream ler unformatted cur-time-string-sec() skip.
if add-sens = ? then
  put stream log unformatted " " skip skip "Привязка партий к складским местам.  Объект : " v-cntxt-obj-type " " string (v-cntxt-obj-code) skip skip.
else do:
  put stream log unformatted " " skip skip "Накладная: " t-doc.doc-code
        " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " t-doc.status_ " ОК: " string (t-doc.flag_, "+/-") skip skip.
  put stream ler unformatted " " skip skip "Накладная: " t-doc.doc-code
        " Тип: " t-doc.doc-type string (t-doc.internal, "внутр/внешн") " Статус: " t-doc.status_ " ОК: " string (t-doc.flag_, "+/-") skip skip.
  /* установка типа документа товар / услуга */
  find first doc-line where doc-line.doc-code = t-doc.doc-code no-lock no-error.
  if available doc-line then do:
    find goods where goods.artic = doc-line.artic
                 and goods.prod-type = doc-line.prod-type
                 and goods.prod-code = doc-line.prod-code no-lock.
    g-type =  goods.gds-type.
  end.
end.
view frame a.
input stream cur from value (scan-txt).
if t-doc.doc-type = {&inventory} and
   t-doc.status_  = {&permitted} and
   add-sens       = ?            then do:
  return.
end.
if t-doc.doc-type = {&inventory} and
   t-doc.status_  = {&permitted} then do:
  put stream log unformatted " " skip skip "!!! Инвентаризация: " t-doc.doc-code
        " подсчет суммарных количеств для одинаковых кодов." skip skip.
end.
else do:
  put stream log unformatted " " skip skip "!!! Складской документ: " t-doc.doc-code
        " подсчет суммарных количеств для одинаковых кодов." skip skip.
end.
/*удалим контейнер для объединяющих бар-кодов*/
for each un-bc on error undo, return error return-value :
    delete un-bc.
end.
run str/bc-anlz.p (parParentProc , "file", scan-txt, yes, output varerr, output table in-bc) no-error.
if error-status:error then do:
   message "Ошибка при обработке файла сканера." skip
           error-status:get-message(1)
      view-as alert-box error buttons ok.
   return error.
end.
if varerr = yes then is-err = yes.
/* Запишем результат разбора в log-file */
define variable vari    as integer no-undo.
define variable vartime as integer no-undo.
run waitfram-show in this-procedure ("Записываем результат разбора сканерного файла в log-файл.").
assign
  vari    = 0.
  vartime = time.
for each in-bc on error undo, return error return-value :
    assign
      vari = vari + 1.
    run waitfram-show in this-procedure (substitute("Записываем ошибки разбора сканерного файла в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
    if in-bc.rez = "err" then do:
       put stream log unformatted in-bc.err-msg skip.
       put stream ler unformatted in-bc.err-msg skip.
       put stream err unformatted in-bc.bar-str skip.
       assign is-err = yes.
    end.
    if in-bc.des <> "" and in-bc.des <> ? then put stream log unformatted in-bc.des.
end.
for each un-bc on error undo, return error return-value :
    assign
      vari = vari + 1.
    run waitfram-show in this-procedure (substitute("Записываем ошибки разбора сканерного файла в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
    if un-bc.rez = "err" then do:
       put stream log unformatted un-bc.err-msg skip.
       put stream ler unformatted un-bc.err-msg skip.
       put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
       assign is-err = yes.
    end.
end.

if v-first-del = true then do:
  for each bb_doc-line
    where bb_doc-line.doc-code = t-doc.doc-code
  on error undo, return error return-value
  :
    delete bb_doc-line .
  end.
end.

if t-doc.doc-type = {&income}
  and t-doc.status_  = {&wayb}
  and t-doc.flag_    = yes
then do:
  run waitfram-show in this-procedure ("Строим таблицу сравнения по загруженой информации из файла.").
  for each bb_doc-line where bb_doc-line.doc-code = t-doc.doc-code no-lock on error undo, return error return-value :
    find first bb_goods where bb_goods.artic     = bb_doc-line.artic     and
                              bb_goods.prod-type = bb_doc-line.prod-type and
                              bb_goods.prod-code = bb_doc-line.prod-code no-lock.
    find first bb_gds-prt where bb_gds-prt.upper-code = bb_goods.prt-root no-lock.
    if bb_gds-prt.node-name = {&empty-scale} then do:
      find first bb_bar-code where bb_bar-code.gds-code  = bb_goods.gds-code    and
                                   bb_bar-code.node-code = bb_gds-prt.node-code and
                                   bb_bar-code.part-code = ""                   and
                                   bb_bar-code.in-code   = ""                   and
                                   bb_bar-code.unit-cli  = bb_goods.unit-base   no-lock.
      create tt-bar-code-doc.
      assign
        tt-bar-code-doc.b-c      = bb_bar-code.b-code
        tt-bar-code-doc.scn-qnty = bb_doc-line.doc-qnty.
      create tt-bar-code-ne.
      assign
        tt-bar-code-ne.nm            = 0
        tt-bar-code-ne.mark          = "d"
        tt-bar-code-ne.b-c           = bb_bar-code.b-code
        tt-bar-code-ne.scn-qnty-doc  = bb_doc-line.doc-qnty
        tt-bar-code-ne.scn-qnty-file = 0
        tt-bar-code-ne.artic         = bb_goods.artic
        tt-bar-code-ne.prod-type     = bb_goods.prod-type
        tt-bar-code-ne.prod-code     = bb_goods.prod-code
        tt-bar-code-ne.gds-name      = bb_goods.gds-name
        tt-bar-code-ne.node-name     = "--------------------"
        tt-bar-code-ne.in-code       = ""
        tt-bar-code-ne.part-code     = "".
    end.
    else do:
      for each bb_gds-dtl where bb_gds-dtl.doc-code  = bb_doc-line.doc-code  and
                                bb_gds-dtl.artic     = bb_doc-line.artic     and
                                bb_gds-dtl.prod-type = bb_doc-line.prod-type and
                                bb_gds-dtl.prod-code = bb_doc-line.prod-code no-lock on error undo, return error return-value :
         find first bb_gds-prt where bb_gds-prt.node-code = bb_gds-dtl.prt-code no-lock.
         find first bb_bar-code where bb_bar-code.gds-code  = bb_goods.gds-code    and
                                      bb_bar-code.node-code = bb_gds-prt.node-code and
                                      bb_bar-code.part-code = ""                   and
                                      bb_bar-code.in-code   = ""                   and
                                      bb_bar-code.unit-cli  = bb_goods.unit-base   no-lock.
         create tt-bar-code-doc.
         assign
           tt-bar-code-doc.b-c      = bb_bar-code.b-code
           tt-bar-code-doc.scn-qnty = bb_doc-line.doc-qnty.
         create tt-bar-code-ne.
         assign
           tt-bar-code-ne.nm            = 0
           tt-bar-code-ne.mark          = "d"
           tt-bar-code-ne.b-c           = bb_bar-code.b-code
           tt-bar-code-ne.scn-qnty-doc  = bb_gds-dtl.doc-qnty
           tt-bar-code-ne.scn-qnty-file = 0
           tt-bar-code-ne.artic         = bb_goods.artic
           tt-bar-code-ne.prod-type     = bb_goods.prod-type
           tt-bar-code-ne.prod-code     = bb_goods.prod-code
           tt-bar-code-ne.gds-name      = bb_goods.gds-name
           tt-bar-code-ne.node-name     = bb_gds-prt.node-name
           tt-bar-code-ne.in-code       = ""
           tt-bar-code-ne.part-code     = "".
      end.
    end.
  end.
  assign
    varanlz = yes.
  for each main-bc on error undo, return error return-value :
    if main-bc.scn-pl <> "" then do:
      assign
        varanlz = no.
    end.
    find first bb_bar-code where bb_bar-code.b-code = main-bc.b-c no-lock.
    if bb_bar-code.in-code   <> "" or
       bb_bar-code.part-code <> "" then do:
       message "В файле экспорте есть бар-код, cоответствующий бар-коду партии " bb_bar-code.b-code " ." skip
               "По данному бар-коду невозможно произвести сравнительный анализ. Он будет выведен отдельной строкой в таблицу анализа."
       view-as alert-box.
    end.
    find first tt-bar-code-ne where tt-bar-code-ne.b-c = bb_bar-code.b-code no-error.
    if not available tt-bar-code-ne then do:
      find first bb_goods where bb_goods.gds-code = bb_bar-code.gds-code no-lock.
      find first bb_gds-prt where bb_gds-prt.upper-code = bb_goods.prt-root no-lock.
      create tt-bar-code-ne.
      if bb_gds-prt.node-name = {&empty-scale} then do:
        assign
          tt-bar-code-ne.nm            = -1
          tt-bar-code-ne.mark          = (if bb_bar-code.in-code <> "" or bb_bar-code.part-code <> "" then "?" else "f")
          tt-bar-code-ne.b-c           = bb_bar-code.b-code
          tt-bar-code-ne.scn-qnty-doc  = 0
          tt-bar-code-ne.scn-qnty-file = main-bc.scn-qnty
          tt-bar-code-ne.artic         = bb_goods.artic
          tt-bar-code-ne.prod-type     = bb_goods.prod-type
          tt-bar-code-ne.prod-code     = bb_goods.prod-code
          tt-bar-code-ne.gds-name      = bb_goods.gds-name
          tt-bar-code-ne.node-name     = "------------------"
          tt-bar-code-ne.in-code       = bb_bar-code.in-code
          tt-bar-code-ne.part-code     = bb_bar-code.part-code.
      end.
      else do:
        find first bb_gds-prt where bb_gds-prt.node-code = bb_bar-code.node-code no-lock.
        assign
          tt-bar-code-ne.nm            = main-bc.nm
          tt-bar-code-ne.mark          = (if bb_bar-code.in-code <> "" or bb_bar-code.part-code <> "" then "?" else "f")
          tt-bar-code-ne.b-c           = bb_bar-code.b-code
          tt-bar-code-ne.scn-qnty-doc  = 0
          tt-bar-code-ne.scn-qnty-file = main-bc.scn-qnty
          tt-bar-code-ne.artic         = bb_goods.artic
          tt-bar-code-ne.prod-type     = bb_goods.prod-type
          tt-bar-code-ne.prod-code     = bb_goods.prod-code
          tt-bar-code-ne.gds-name      = bb_goods.gds-name
          tt-bar-code-ne.node-name     = bb_gds-prt.node-name
          tt-bar-code-ne.in-code       = bb_bar-code.in-code
          tt-bar-code-ne.part-code     = bb_bar-code.part-code.
      end.
    end.
    else do:
      assign
        tt-bar-code-ne.nm            = main-bc.nm
        tt-bar-code-ne.mark          = (if tt-bar-code-ne.scn-qnty-doc = main-bc.scn-qnty then "" else (if tt-bar-code-ne.scn-qnty-doc > main-bc.scn-qnty then "<" else ">"))
        tt-bar-code-ne.scn-qnty-file = main-bc.scn-qnty.
    end.
  end.
  if varanlz = yes then do:
    run str/scr-neb.w (input parparentproc, input-output table tt-bar-code-ne, input scan-name, input no, input v-cntxt-obj-type, input v-cntxt-obj-code).
  end.
end.
run waitfram-hide in this-procedure.
assign
  i    = 0
  j    = 0
  .

define buffer buf_gds-obj for ub.gds-obj  .
find first buf_gds-obj no-lock where
           buf_gds-obj.obj-type = t-doc.obj-type and
           buf_gds-obj.obj-code = t-doc.obj-code and
           buf_gds-obj.gds-code = goods.gds-code no-error .

if available buf_gds-obj and buf_gds-obj.cash-parts then do:
for each anlz-bc on error undo, return error return-value :
  i = i + 1.
  display i with frame a.
  find first bar-code where bar-code.b-code   = anlz-bc.b-c        no-lock.
  find first goods    where goods.gds-code    = bar-code.gds-code  no-lock.
  /*Установим переменные для обработки в процедуре*/
  assign bar-str  = string( anlz-bc.b-c)
         qnty-str = string( anlz-bc.scn-qnty)
         rate     = 1
         pl-str   = anlz-bc.scn-pl
         mess     = anlz-bc.des.
  run proc-code in this-procedure (input anlz-bc.scn-pl
                                  ,input (if anlz-bc.rez = "place" then "place" else "")
                                  ,input varscales-pref
                                  ,input varpgscales-pref
                                  ) no-error.
  if error-status:error then do:
     assign is-err = yes.
  end.
  else do:
    assign
      j = j + 1.
    display j with frame a.
  end.
end.

end.
else do:
for each main-bc on error undo, return error return-value :
  i = i + 1.
  display i with frame a.
  find first bar-code where bar-code.b-code   = main-bc.b-c        no-lock.
  find first goods    where goods.gds-code    = bar-code.gds-code  no-lock.
  { str/is-petrl.i
    goods.artic
    goods.prod-type
    goods.prod-code
    varis-petrolium
    varis-pieces
  }

  find first gds-prt  where gds-prt.node-code = bar-code.node-code no-lock.
  if gds-prt.is-term <> yes then do:
    put stream log unformatted "Бар-код " bar-code.b-code " не является кодом терминального признака." skip.
    put stream ler unformatted "Бар-код " bar-code.b-code " не является кодом терминального признака." skip.
    put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
    assign is-err = yes.
    next.
  end.
  /*Установим переменные для обработки в процедуре*/
  assign bar-str  = string(main-bc.b-c)
         qnty-str = string(main-bc.scn-qnty)
         rate     = 1
         pl-str   = main-bc.scn-pl
         mess     = main-bc.des.
  run proc-code in this-procedure (input main-bc.scn-pl
                                  ,input (if main-bc.rez = "place" then "place" else "")
                                  ,input varscales-pref
                                  ,input varpgscales-pref
                                  ) no-error.
  if error-status:error then do:
     assign is-err = yes.
  end.
  else do:
    assign
      j = j + 1.
    display j with frame a.
  end.
end.
end.

output stream log close.
output stream err close.
output stream ler close.
output stream cur close.
if is-err then do:
    message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
            "Смотрите ler файл."
    view-as alert-box error buttons ok.
    if search (scan-name + ".ler") <> ? then do:
      run gbl/prnfilen.w
        (input  substitute("Ошибки, обнаруженные во время загрузки файла &1", scan-txt)
        ,input  0
        ,input  scan-name + ".ler"
        ,input  7
        ,output v-user-action
        ,output v-printed
        ).
    end.
end.