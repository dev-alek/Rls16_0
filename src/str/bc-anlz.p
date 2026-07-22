block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bc-anlz.p $
$Archive: str/bc-anlz.p $

Анализатор бар-кодов

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

create:  Суслов Алексей Юрьевич   7 Dec 1999

Описание:
На входе имеется файл с бар-кодами и алгоритм разбора
(первичный вариант под алгоритм инвентаризации).
На выходе shared temp-table, которая обрабатывается извне.

Параметры:
parworkmode    параметер режима обработки файлов  или чеков
parinformation Имя файла инвентаризации (если parworkmode = "file")  или номер чека или [номер чека,номер строки]
               или бар-код если ведется единичная обработка (если parworkmode = "code-...")
add-sens       активна ли кнопка добавить в документе : yes / no - вызов из документа,
               ? - вызов из гл. меню - привязка партий к складским местам
is-err         Если yes, то не все было гладко.
in-bc          таблица входящих строк из последнего загружаемого файла
               таблица описана в файле anlz-bc.i
*/

define input  parameter parparentproc  as handle    no-undo.
define input  parameter parworkmode    as character no-undo .
define input  parameter parinformation as character no-undo .
define input  parameter add-sens       as logical   no-undo .
define output parameter is-err         as logical   initial no no-undo.
/*таблица входящих строк из последнего загружаемого файла*/
{ str/anlz-bc.i    }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ str/tt-tax.i new }
{ str/lib-trn.i    }
{ str/libbcrcn.i   }
{ gbl/waitfram.i noprocess }
{ gbl/getcntxt.i def        }
{ gbl/getcntxt.i get        }
{ str/getctxtp.i def        }
{ str/getctxtp.i get        }
define buffer gds-bar-code   for ub.bar-code.
define buffer prt-bar-code   for ub.bar-code.
define buffer main-bar-code  for ub.bar-code.
define buffer gds-anlz-bc    for anlz-bc.
define buffer prt-anlz-bc    for anlz-bc.
define buffer parts-bc       for ub.parts.
define buffer gds-prt-parent for ub.gds-prt.
define buffer last-un-bc     for un-bc.
define buffer last-anlz-bc   for anlz-bc.
define buffer units-base     for ub.units.
define buffer bar-code-base  for ub.bar-code.
define buffer gds-prt-base   for ub.gds-prt.
define buffer buf_chk-doc    for ub.chk-doc.
define buffer bar-code for ub.bar-code.
define buffer goods    for ub.goods   .
define buffer units    for ub.units   .



define variable bar-str     as character no-undo.         /* строка для чтения бар-кода из файла              */
define variable pl-str      as character no-undo.         /* строка для складского места                      */
define variable qnty-str    as character no-undo.         /* строка количества по данному бар-коду со сканера */
define variable part-list   as character no-undo init "". /* список бар-кодов партий для привязки места       */
define variable b-c         as integer   no-undo.  /* обрабатываемый бар-код            */
define variable rate        as decimal   no-undo.  /* коэффициент для единиц из бар-кода*/
define variable discnt      as decimal   no-undo.  /*скидка*/
define variable flagplace   as logical   no-undo.  /*Если распознали складское место, а не бар-код*/
define variable conf-par    as character no-undo.  /* для чтения параметра конфигурации */
define variable par-type    as character no-undo.  /* тип параметра конфигурации */
define variable i-num       as integer   no-undo.
define variable u-num       as integer   no-undo.
define variable a-num       as integer   no-undo.
define variable varentity   as character no-undo.
define variable varzero-string as logical no-undo.
define stream scan-file.
{ str/sclspref.i }
{ str/bc-res.i check log un-bc}
run delete-in-bc.
if parworkmode = "code-add" or
   parworkmode = "code-update"
   then do:
   create   in-bc.
   assign   in-bc.bar-str = parinformation
            in-bc.nm      = 1.
   validate in-bc.
end.
if parworkmode = "chk-doc"
then do:
   run waitfram-show in this-procedure ("Разбор строк чека.").
end.
else do:
  run waitfram-show in this-procedure ("Разбор сканерного файла.").
end.
if parworkmode = "table" then do:
   run loadTempTable in this-procedure no-error.
   if error-status:error then
   do:
      message return-value view-as alert-box error buttons ok.
        run waitfram-hide in this-procedure.
      return error.
   end.
end.
if parworkmode = "file" then do:
   if search(parinformation) = ? then do:
      message "Не найден файл: " parinformation " с бар-кодами для анализа."
      view-as alert-box error buttons ok.
      run waitfram-hide in this-procedure.
      return error.

   end.
   run gbl/filnline.p (input parinformation, output varzero-string).
   if varzero-string <> true then do:
     message return-value skip
             "Файл " search(parinformation) view-as alert-box.
     return error.
   end.
   run loadnewfile in this-procedure.
end.
if parworkmode = "chk-doc"
then do:
  find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = entry(1, parinformation) no-error.
  if not available buf_chk-doc then do:
      message "Не найден чек: " parinformation " с бар-кодами для анализа."
      view-as alert-box error buttons ok.
      run waitfram-hide in this-procedure.
      return error.
   end.
   for each un-bc:
     assign un-bc.file-qnty = 0.
   end.
   run loadnewcheck in this-procedure.
end.

i-num = 0.

if parworkmode <> "undo" then do:
   if parworkmode = "chk-doc"then do:
      /*уже все объединили - а in-bc нам для чеков вообще не нужен*/
   end.
   else do:
     for each un-bc:
        assign un-bc.file-qnty = 0.
     end.
   end.
   for each in-bc where in-bc.bar-str <> "":U
   :
      run unitedcode.
   end.
   /*Новая запись при редактировании бар-кода будет добавляться с нулем*/
   if parworkmode = "code-update" then do:
      find last in-bc.
      find first un-bc where un-bc.bar-code = in-bc.bar-code no-error.
      if available un-bc then run add-un-bc.
   end.
   else
   for each un-bc where un-bc.file-qnty > 0 use-index file-qnty by un-bc.nm:
       run add-un-bc.
   end.
   for each anlz-bc:
    /*Заполняем информацию по бар-коду: entity и атрибуты партии(для объединенного бар-кода)*/
    find first bar-code     where bar-code.b-code         = anlz-bc.b-c       no-lock.
    find first goods        where goods.gds-code          = bar-code.gds-code no-lock.
    find first units        where units.unit-name         = bar-code.unit-cli no-lock.
    find first units-base   where units-base.unit-name    = goods.unit-base   no-lock.
    find first gds-prt-base where gds-prt-base.upper-code = goods.prt-root    no-lock.
    /*Ищем основной бар-код товара*/
    find first bar-code-base where bar-code-base.gds-code  = goods.gds-code         and
                                   bar-code-base.node-code = gds-prt-base.node-code and
                                   bar-code-base.part-code = ""                     and
                                   bar-code-base.in-code   = ""                     and
                                   bar-code-base.unit-cli  = goods.unit-base        no-lock.
    /*Ищем основной бар-код товара или признака*/
    find first main-bar-code where main-bar-code.gds-code  = bar-code.gds-code  and
                                   main-bar-code.node-code = bar-code.node-code and
                                   main-bar-code.part-code = ""                 and
                                   main-bar-code.in-code   = ""                 and
                                   main-bar-code.unit-cli  = goods.unit-base    no-lock.
    find gds-prt where gds-prt.node-code = bar-code.node-code no-lock.
    if not can-find(first gds-prt-parent where gds-prt-parent.node-code = gds-prt.upper-code no-lock) then
       assign varentity = {&goods}.
    else assign varentity = {&property}.
    if bar-code.in-code <> "" then do:
       find first parts-bc where parts-bc.artic     = goods.artic
                             and parts-bc.prod-type = goods.prod-type
                             and parts-bc.prod-code = goods.prod-code
                             and parts-bc.in-code   = bar-code.in-code
                             and parts-bc.part-code = bar-code.part-code no-lock no-error.
    end.
    if available parts-bc then assign varentity = {&part}.
    for each un-bc where un-bc.b-c = anlz-bc.b-c:
        if un-bc.entity <> {&stock-place} then un-bc.entity = varentity.
         assign un-bc.f-name         = gds-prt.f-name
                un-bc.in-code        = if available parts-bc then parts-bc.in-code   else ?
                un-bc.fact-date      = if available parts-bc then parts-bc.fact-date else ?
                un-bc.part-code      = if available parts-bc then parts-bc.part-code else ?
                un-bc.unit-name      = units.unit-name
                un-bc.long-name      = units.long-name
                un-bc.b-c-base       = bar-code-base.b-code
                un-bc.unit-name-base = units-base.unit-name
                un-bc.long-name-base = units-base.long-name.
    end.
    find first main-bc where main-bc.b-c = main-bar-code.b-code no-error.
    if not available main-bc then do:
       create main-bc.
       assign main-bc.nm     = anlz-bc.nm
              main-bc.b-c    = main-bar-code.b-code
              main-bc.scn-pl = anlz-bc.scn-pl
              main-bc.rez    = anlz-bc.rez.
    end.
    assign main-bc.scn-qnty = main-bc.scn-qnty + anlz-bc.scn-qnty
           main-bc.des      = main-bc.des + " | " + anlz-bc.des.
   end. /*each anlz-bc*/
end.
else run undo-qnty.
run waitfram-hide in this-procedure.

{ str/read-str.i }
procedure loadTempTable:
  define variable vTime   as integer   no-undo.
  define variable vWhere  as character no-undo.
  define variable hTable  as handle  no-undo.
  define variable hBuffer as handle  no-undo.
  define variable hQuery  as handle  no-undo.

  assign
    vTime = TIME
    hTable = handle(parinformation)
    vWhere = substitute("FOR EACH &1", hTable:name)
  no-error.
  if error-status:error or not valid-handle(hTable) then
    return error "Ошибка при чтении таблицы строк документа".

  create buffer hBuffer for table hTable.
  create query  hQuery.
  hQuery:set-buffers(hBuffer).
  hQuery:query-prepare(vWhere).
  hQuery:query-open().
  hQuery:get-first().
  repeat while not hQuery:query-off-end:
    assign
      bar-str = ""
      i-num = i-num + 1
    .
    run waitfram-show in this-procedure (substitute("Разбор записей с бар-кодами. Всего считано &1. Время &2.", i-num, string (time - vTime, "hh:mm:ss"))).
    create in-bc.
    assign 
      in-bc.nm       = i-num
      in-bc.bar-str  = substitute(
                         "&1,&2", 
                         hBuffer:buffer-field("b-code"):buffer-value,
                         hBuffer:buffer-field("fact-qnty"):buffer-value)
    .
    hQuery:GET-NEXT().
  end.
  hQuery:query-close().
  delete object hQuery.
end procedure.

procedure loadnewfile:
define variable vartime as integer no-undo.
input stream scan-file from value (parinformation).
assign
  vartime = TIME.
repeat:
  assign
    bar-str = "".
  import stream scan-file unformatted bar-str.
  i-num = i-num + 1.
  run waitfram-show in this-procedure (substitute("Разбор сканерного файла. Всего считано &1. Время &2.", i-num, string (time - vartime, "hh:mm:ss"))).
  create in-bc.
  assign in-bc.nm       = i-num.
         in-bc.bar-str  = bar-str.
end.
end procedure.

procedure loadnewcheck:
define variable vartime as integer no-undo.
define buffer buf_chk-gds for ub.chk-gds.
define variable v-doc-code as character no-undo .
define variable v-line-num as integer no-undo .
define variable qnty-dec as decimal no-undo .
define variable v-chk-gds-type-bc as character no-undo .
assign
vartime = TIME
v-doc-code = entry(1, parinformation)
v-line-num = (if num-entries(parinformation) > 1
              then integer(entry(2, parinformation))
              else 0)
.
for each buf_chk-gds where
        buf_chk-gds.doc-code = v-doc-code
by buf_chk-gds.doc-code
by buf_chk-gds.line-num :
  run waitfram-show in this-procedure ( substitute("Разбор чека. Всего считано &1. Время &2.", i-num, string (time - vartime, "hh:mm:ss"))).
  if buf_chk-gds.is-err = yes then do:
    if v-line-num > 0 and buf_chk-gds.line-num <> v-line-num then next.
    assign
    v-chk-gds-type-bc = if buf_chk-gds.b-code > 0
                        then 'b-code':U
                        else 'src-code':U
    bar-str = (if v-chk-gds-type-bc = 'b-code':U
                then string(buf_chk-gds.b-code)
                else buf_chk-gds.src-code )
    qnty-dec = (if v-chk-gds-type-bc = 'b-code':U
                then buf_chk-gds.src-qnty
                else buf_chk-gds.doc-qnty )
    pl-str    = '':U /*пока*/
    .
    find first un-bc where
             un-bc.bar-code = bar-str no-error.
    if not available un-bc
    or add-sens = ?
    or (parworkmode = "chk-doc"
        and
        un-bc.type-bc <> v-chk-gds-type-bc)
    then do:
      find last last-un-bc no-error.
      create un-bc.
      assign
      un-bc.nm       = if available last-un-bc
                       then (last-un-bc.nm + 1)
                       else 1
      un-bc.bar-code = bar-str
      un-bc.type-bc = v-chk-gds-type-bc
      .
    end.
    assign
    un-bc.file-qnty = un-bc.file-qnty + qnty-dec
    un-bc.scn-qnty  = un-bc.scn-qnty  + qnty-dec
    un-bc.scn-pl    = if un-bc.scn-pl <> ""
                      and un-bc.scn-pl <> ?
                      then un-bc.scn-pl
                      else pl-str
    .
    if buf_chk-gds.b-code > 0 then do:
      buf_chk-gds.is-err = no.
    end.
  end.
end.
end procedure.



procedure unitedcode:
bar-str = in-bc.bar-str.
run read-str no-error.
if error-status:error then do:
   /*Закрываем строку таблицы входящего файла*/
   assign in-bc.bar-code = ?
          in-bc.rez      = "err"
          in-bc.err-msg  = return-value.
      assign is-err = yes.
      next.
end.
find first un-bc where un-bc.bar-code = bar-str no-error.
/*Если привязка партий к складскому месту, то не объединяем одинаковые коды*/
if not available un-bc or add-sens = ? then do:
   find last last-un-bc no-error.
   create un-bc.
   assign un-bc.nm       = if available last-un-bc then last-un-bc.nm + 1 else 1
          un-bc.bar-code = bar-str.
          in-bc.des      = in-bc.des + "Код: " + bar-str + " помещен в таблицу с количеством: " + qnty-str + {&new-line} .
end.
else assign in-bc.des = in-bc.des + "Код: " + bar-str + " найден в таблице. Количество: " + string(un-bc.scn-qnty) + " увеличено на: " + qnty-str + {&new-line} .
assign
 un-bc.file-qnty = if parworkmode = "code-update" then un-bc.file-qnty else un-bc.file-qnty + decimal(qnty-str)
 un-bc.scn-qnty  = if parworkmode = "code-update" then un-bc.scn-qnty  else un-bc.scn-qnty  + decimal(qnty-str)
 un-bc.scn-pl    = if un-bc.scn-pl <> "" and un-bc.scn-pl <> ? then un-bc.scn-pl else pl-str
 in-bc.bar-code  = un-bc.bar-code.
return.
end procedure.

procedure delete-in-bc:
 for each in-bc:
    delete in-bc.
 end.
end.

procedure undo-qnty:
  for each un-bc:
     find first anlz-bc where anlz-bc.b-c = un-bc.b-c no-error.
     if available anlz-bc then do:
        assign anlz-bc.scn-qnty = anlz-bc.scn-qnty - un-bc.rate * un-bc.file-qnty
               anlz-bc.des      = anlz-bc.des + " Откат кол-во:" + string(un-bc.rate * un-bc.file-qnty) + ".".
        if anlz-bc.scn-qnty = 0 then delete anlz-bc.
     end.
     assign un-bc.scn-qnty = un-bc.scn-qnty - un-bc.file-qnty
            un-bc.file-qnty = 0.
     if un-bc.scn-qnty = 0 then delete un-bc.
  end.
end.

procedure add-un-bc:
define variable v-chk-gds-type-bc as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
  if parworkmode = "chk-doc" then do:
    assign
    v-chk-gds-type-bc = un-bc.type-bc
    un-bc.type-bc = '':U
    .
  end.
  run check-code in this-procedure (
                  input un-bc.bar-code   /*строка бар-кода*/
                  ,input 0                /*цена*/
                  ,input un-bc.scn-qnty   /*кол-во по входящему бар-коду*/
                  ,input ?                /*включены ли признаки на объекте*/
                  ,input varscales-pref
                  ,input varpgscales-pref
                  ,output flagplace /*распознали складское место, а не бар-код товара или партии*/
                  ,output b-c       /*основной бар-код товара или признака в зависимости от включенности признаков*/
                  ,output rate       /*кол-во по основному бар-коду*/
                  ) no-error.
 if error-status:error then do:
     assign un-bc.b-c     = ?
            un-bc.rez     = "err"
            un-bc.err-msg = mess + " " + if return-value <> "" then return-value else "Ошибка из процедуры проверки бар-кода."
            un-bc.type-bc = un-bc.type-bc + un-bc.err-msg.
        assign is-err = yes.
   if parworkmode = "chk-doc"
    and v-chk-gds-type-bc = 'b-code' then do:
      for each buf_chk-gds where
              buf_chk-gds.doc-code = entry(1, parinformation)
          and buf_chk-gds.b-code = integer(un-bc.bar-code)
      on error undo, return error:
        assign
        buf_chk-gds.is-error = yes
        .
      end.
    end. /*if parworkmode = "chk-doc" then do:*/
    next.
 end.
 if parworkmode = "chk-doc"
   and v-chk-gds-type-bc = 'src-code' then do:
     for each buf_chk-gds where
            buf_chk-gds.doc-code = entry(1, parinformation)
        and buf_chk-gds.b-code = 0
        and buf_chk-gds.src-code = un-bc.bar-code
    on error undo, return error:
      assign
      buf_chk-gds.is-error = no
      .
     end.
   end. /*if parworkmode = "chk-doc" then do:*/
 find first anlz-bc where anlz-bc.b-c = b-c no-error.
 /*Если привязка к складским местам, то не объединяем коды*/
 if not available anlz-bc or add-sens = ? then do:
    find last last-anlz-bc no-error.
    create anlz-bc.
    assign anlz-bc.nm  = if available last-anlz-bc then last-anlz-bc.nm + 1 else 1
           anlz-bc.b-c = b-c
           anlz-bc.rez = if flagplace = yes then "place" else "" .
 end.
 assign anlz-bc.scn-qnty = anlz-bc.scn-qnty + rate * un-bc.file-qnty
        anlz-bc.scn-pl   = if anlz-bc.scn-pl = "" or anlz-bc.scn-pl = ? then un-bc.scn-pl else anlz-bc.scn-pl
        anlz-bc.des      = anlz-bc.des + mess
        un-bc.des        = mess
        un-bc.b-c        = b-c
        un-bc.rate       = rate.
 /*Если это бар-код партии, то проверяем не было ли бар-кода по товару,
   если бар-код товара, то проверяем не было ли бар-кода партий.*/
 find first bar-code where bar-code.b-code = b-c no-lock.
 if bar-code.in-code <> "" then do:
    /*Если уже имеется бар-код по любому из признаков*/
    for each gds-bar-code where gds-bar-code.gds-code  = bar-code.gds-code  and
                                gds-bar-code.in-code   = "" no-lock,
        first gds-anlz-bc where gds-anlz-bc.b-c = gds-bar-code.b-code
        :
        assign gds-anlz-bc.rez = "wrn"
               gds-anlz-bc.err-msg = gds-anlz-bc.err-msg +
               "По данному бар-коду партии есть товар в данном файле. При инвентаризации с заменой возможны проблемы.".
        leave.
    end.
 end.
 else do:
    /*Если уже имеется бар-код по какой-либо партии данного товара*/
    for each prt-bar-code where prt-bar-code.gds-code  =  bar-code.gds-code  and
                                prt-bar-code.in-code  <>  ""                 use-index prt-parts
                                no-lock,
       first prt-anlz-bc where prt-anlz-bc.b-c = prt-bar-code.b-code
       :
       assign anlz-bc.rez = "wrn"
              anlz-bc.err-msg = anlz-bc.err-msg +
              "По данному товару есть бар-код партии в данном файле. При инвентаризации с заменой возможны проблемы.".
       leave.
    end.
 end.
end procedure.