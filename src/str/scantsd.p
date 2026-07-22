block-level on error undo, throw.
/*

$Revision: e5fbdeab5909, 1547, rls $
$Author: ASMorozov $
$Date: Tue Oct 09 19:01:47 2018 +0300 $
$Workfile: scantsd.p $
$Archive: str/scantsd.p $

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

{ibs/th/skt/ControlledClients/TSDTT.i}
/*define input  parameter parParentProc  as widget-handle no-undo.*/
define input  parameter v-num          as integer   no-undo.
define input  parameter add-sens  as logical no-undo.  /* активна ли кнопка добавить в документе : yes / no - вызов из документа,? - вызов из гл. меню - привязка партий к складским местам */
define input  parameter p-doc-rec as recid no-undo .
define input  parameter table for TempDocLineIsTSD .
define input  parameter p-action    as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: e5fbdeab5909, 1547, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo initial "$Date: Tue Oct 09 19:01:47 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: scantsd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/scantsd.p $":U .
define variable vss-description as character no-undo initial "Единая процедура работы с мобильным сканером":U .

define variable parParentProc  as widget-handle no-undo .

parParentProc = this-procedure.

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
{ str/anlz-bc.i  new }
{ cmp/gds-list.i gds-list def "new shared" }

define buffer t-doc for trn-doc.              /* буфер обрабатываемого документа */
define variable bar-str       as character no-undo.             /* строка для чтения бар-кода из файла              */
define variable pl-str        as character no-undo.             /* строка для складского места                      */
define variable qnty-str      as character no-undo.             /* строка количества по данному бар-коду со сканера */
define variable part-list     as character no-undo initial "".  /* список бар-кодов партий для привязки места       */
define variable b-c           as integer   no-undo.             /* обрабатываемый бар-код                           */
define variable rate          as decimal   no-undo.             /* коэффициент для единиц из бар-кода        */
define variable conf-par      as character no-undo.             /* для чтения параметра конфигурации */
define variable par-type      as character no-undo.             /* тип параметра конфигурации */
define variable varplace      as logical   no-undo.
define variable is-err        as logical   no-undo initial no .
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
define variable varnoapnd     as character no-undo.
define variable line-mode as character no-undo init ? .
define variable varis-petrolium as logical no-undo.
define variable varis-pieces as logical no-undo.
define variable v-silent as logical   no-undo init true .
define variable v-upperhandl as handle no-undo .
define variable v1 as character no-undo .
define variable v2 as character no-undo .
define variable v-pri-nakl- as logical   no-undo .
define variable v-first-del as logical   no-undo .
define variable vt-host-code as integer   no-undo .
define variable vt-obj-type as character no-undo .
define variable vt-obj-code      as integer   no-undo .
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .


find first t-doc no-lock where recid(t-doc) = p-doc-rec no-error .
assign
  vt-host-code          = t-doc.host-code
  vt-obj-type           = t-doc.obj-type
  vt-obj-code           = t-doc.obj-code
  v-cntxt-host-code-obj = t-doc.host-code
  v-cntxt-obj-code      = t-doc.obj-code
  v-cntxt-obj-type      = t-doc.obj-type
  v-cntxt-db-num        = t-doc.user-db-num
  v-cntxt-userid        = t-doc.user-name
  .
{ gbl/getcntxt.i get }
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
field alcmark  as character /*марка   */
index pi is primary b-c.

{ str/scr-neb.i }

define frame a
    i format ">>>>9" label "Просмотрено" space (20) skip
    j format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".
{ str/bc-res.i "all" "log" }
{ str/libbcrcn.i }

  assign
    v-pri-nakl- = false
    v-silent    = true
    v-first-del = false
  .

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

scan-name = "scantsd".

frame a :title = "Разбор таблицы бар-кодов".
{ gbl/conf-rd.i  "'noapndsc'"  0  "''"  0 "''" "''" "''"  no varnoapnd vartype no-error }
if varnoapnd = "yes":u then do:
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
run str/bc-anlz.p (parParentProc , "table", string(temp-table TempDocLineIsTSD:handle), yes, output varerr, output table in-bc) no-error.
if error-status:error then do:
   message "Ошибка при обработке файла." skip
           error-status:get-message(1)
      view-as alert-box error buttons ok.
   return error.
end.
if varerr = yes then is-err = yes.
/* Запишем результат разбора в log-file */
define variable vari    as integer no-undo.
define variable vartime as integer no-undo.
run waitfram-show in this-procedure ("Записываем результат разбора файла в log-файл.").
assign
  vari    = 0.
  vartime = time.
for each in-bc on error undo, return error return-value :
    assign
      vari = vari + 1.
    run waitfram-show in this-procedure (substitute("Записываем ошибки разбора в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
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
    run waitfram-show in this-procedure (substitute("Записываем ошибки разбора  в файлы. Всего проверено на ошибки &1. Время &2.", vari, string (time - vartime, "hh:mm:ss"))).
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
/*    run str/scr-neb.w (input parparentproc, input-output table tt-bar-code-ne, input scan-name, input no, input v-cntxt-obj-type, input v-cntxt-obj-code).*/
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
  find first tt-bar-code-doc where tt-bar-code-doc.b-c = anlz-bc.b-c. 
  run proc-code in this-procedure (input anlz-bc.scn-pl
                                  ,input (if anlz-bc.rez = "place" then "place" else if p-action = "rsvmarks" then p-action else "")
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
                                  ,input (if main-bc.rez = "place" then "place" else if p-action = "rsvmarks" then p-action else "")
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

run gbl/calc-trn.p (  this-procedure , recid(t-doc)) no-error .
if error-status :error then 
do:
  undo, return error substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value) .
end.
if t-doc.doc-type = {&inventory} then do:
  run str/clcsumga.p ( input t-doc.doc-code ).
  if error-status :error then 
  do:
    undo, return error substitute(" Ошибка пересчета документа &1 &2" , error-status :get-message(1)  , return-value) .
  end.
end.

if is-err then do:
    /*message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
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
    end.*/
end.

/* для подсовывания trn-clos  и прочим */
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

  do
  on error undo, return error return-value
  :
  { gbl/objdbnum.i
     vt-obj-type
     vt-obj-code
     p-cntxt-db-num-obj
     }

  assign
    p-cntxt-db-num          =  v-cntxt-db-num
    p-cntxt-userid          =  v-cntxt-userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  vt-obj-type
    p-cntxt-obj-code        =  vt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
 end procedure. /* mainmenu_getcntxt */
 
 procedure get-report-num :
/*------------------------------------------------------------------------------
  purpose:
  parameters:  <none>
  notes:
------------------------------------------------------------------------------*/
define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error return-value
  :
    run gbl/getrpnum.p (output p-report-num).
  end.

end procedure.

procedure get-db-num:
  
  define output parameter pDbNum as integer no-undo.
  
  pDbNum = v-cntxt-db-num.

end.

procedure get-userid:

  define output parameter pUserId as character no-undo.

  assign
    pUserId  = v-cntxt-userid
    .
  
end.