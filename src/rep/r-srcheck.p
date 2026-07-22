block-level on error undo, throw.
/*
$Revision: $
$Author: EShklyar $ Shalanin Sergey
$Date: Вт авг 04 12:57:17 2020 +0300 $
$Workfile: r-srcheck.p $
$Archive: rep/r-srcheck.p $

Средний чек


Автор: Шаланин Сергей
Дата создания: 29/05/15
Author: Shalanin Sergey
Creation date: 29/05/15
*/

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 04 12:57:17 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-srcheck.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-srcheck.p $":U .
define variable vss-description as character no-undo init "Средний чек".
{ cmp/vssrevis.i }

define input parameter parparentproc as widget-handle no-undo .

define input parameter p-tog-raz        as logical no-undo.
define input parameter p-tog-uchet      as logical no-undo.
define input parameter p-tog-prod      as logical no-undo.

{ rep/r-pychk0.i defalgo }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i     }

define variable g#report-num as integer no-undo .
  { gbl/getcntxt.i def }
  
define temp-table temp-chk no-undo
    field gds-code like goods.gds-code 
    field gds-name like goods.gds-name 
    field unit like goods.unit-base  /*Единица измерения*/
    field qnty as decimal   /*Количество*/
    field sum-base as decimal /*Сумма со скидкой*/
    field sum-unbase as decimal /*Сумма без скидки*/
    field doc-qnty as integer  /*Количество чеков*/
    field pok-qnty as integer     /*Количество покупок*/
    field srchk-kol-tov as decimal  /*Средний чек по количеству товара*/
    field srchk-sum as decimal  /*Средний чек по сумме без скидок / Сумма */
    field srchk-uch as decimal  /*Средний чек по сумме без скидок / Участие*/
    field srchk-base-sum as decimal   /*Средний чек по сумме со скидками / Сумма*/
    field srchk-base-uch as decimal  /*Средний чек по сумме со скидками / Участие*/
    field srchk-kol-tov-pokup as decimal  /*Средний чек по количеству покупок товара / количество покупок*/
    field srchk-kol-tov-uch as decimal   /*Средний чек по количеству покупок товара / участие*/
    field grp-code like ub.goods.grp-code init 0 /* Группа родителя (применительно к Группе товаров) */
    field grp-lvl as integer        /* Уровень группы относительный. */
    field upper-code like gds-grp.upper-code /* Группа родительская(применительно к Группе товаров) */
    field obj-code as integer
    field obj-type as char
    field obj-name as char
  fields note_ as char
  fields sales-man-psn as integer
    INDEX tt is primary gds-code  obj-code obj-type
    index tt-grp  grp-lvl  obj-type obj-code grp-code sales-man-psn
    index i-gds gds-code obj-code obj-type grp-code
.

define temp-table help-chk no-undo
    field doc-code as char
    field group-chk as integer
    field obj-code as integer
    field obj-type as char
    index pi is primary unique  doc-code group-chk
    index i-grp group-chk
    .
define buffer prod-temp-chk for temp-chk.
define buffer obj-temp-chk for temp-chk. 
  
define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */

define variable v-report-name as character no-undo.         /* Наименование отчёта */
define variable v-choice-gds as character no-undo. /* Список выбранных товаров. Вывод - в шапке отчёта */
define variable v-choice-obj as character no-undo. /* Выбранный пользователем параметр "Выбор объекта" (в окне параметров). Вывод в шапке отчёта */


define variable v-cntxt-host-name-obj as character no-undo .
define variable tog-uchet-html as char.
define variable tog-raz-html as char.
define stream OutStr-html.

/* ************************  Function Implementations ***************** */
function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date) forward.

function fnc-convert-dot-to-colon returns character 
(input p-data as decimal, input p-accur as character) forward.

{ str/cspromo-chk.i  } /* функции для работы с промоакциями по НП */

/* ***************************  Main Block  *************************** */

/* 20/VIII-2018
  /* Получение полного пути к исполняемому файлу просмотровщика отчётов RV.exe */
  v-full-path-RepView = search("exe\ReportViewer\reportviewer.exe") .
  if v-full-path-RepView = ? then do :
    message "Отсутствует программа просмотра отчёта." view-as alert-box error.
    return .
  end .
 
 
  run get-report-num in parParentProc(output g#report-num).

  v-file-name-rep-htm = substitute("&1&2&3.html", session:temp-directory, {&DF_Name}, g#report-num) .
 */
  /* Получение полного пути к отчёту html (input №Отчёта, output Полный_путь_имя_файла_отчHTML) */
  v-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name({&DF_Name}) .
  assign
    v-file-name-rep-htm = v-report-name + ".html"
  .
 
  /* Создание пустого файла (полный путь и имя файла) */
  output to value(v-file-name-rep-htm).
  output close.

 
run create-fill-tt-chk.


  v-report-name = "Отчет по среднему чеку".
  
  str1 = substitute(
    (if X-TOG-Shift then "С &1, смена №&2 по &3, смена №&4" else "За период с &1 по &3")
    , fnc-DD-MM-YYYY(X-Date-Start)
    , X-Shift-Start
    , fnc-DD-MM-YYYY(X-Date-End)
    , X-Shift-End
  ) .
    
  if X-selectGood = {&g-choice} or
     X-selectGood = {&g-spis}   or
     X-selectGood = {&g-one} then do:
    v-choice-gds = "По списку товаров: " + x-Goods-Editor.
    if length(v-choice-gds) > 115 then
      v-choice-gds = substring(v-choice-gds, 1, 115) + "..." .
  end.
  v-choice-gds = if length(str2) > 115 then ( substring(str2, 1, 115) + "..." ) else str2.

  str4 = replace(str4, chr(10), " "). /* Очищаем текст от служ. символов "Новая линия", пока просмотровщик RepView - не умеет передавать его в Excel */
  str4 = replace(str4, chr(13), " "). /* Очищаем текст от служ. символов "Перевод каретки". */
  str4 = replace(str4, chr(9),  " "). /* Очищаем текст от служ. символов "Табуляция" */
  str4 = trim(str4, " "). /* Экран от незначащих пробелов по краям названия. */
  str4 = replace(str4, "  ",  " "). /* грубая очистка от двойных пробелов */
  v-choice-obj = if length(str4) > 115 then ( substring(str4, 1, 115) + "..." ) else str4.

  tog-uchet-html = if p-tog-uchet then "Нет" else "Да"  .
  tog-raz-html   = if p-tog-raz   then "Да"  else "Нет" .

 run proc-create-HTML(       input v-file-name-rep-htm
                            ,input v-report-name
                            ,input str1
                            ,input v-choice-gds
                            ,input v-choice-obj
                            ,input tog-uchet-html
                            ,input tog-raz-html
                        ).
/*  run gbl/inidebug.p.*/
      run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
/*  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(v-file-name-rep-htm) .*/
/* 20/VIII-2018
  /* Только проверка, есть файл отчёта HTML или нет(тогда вывод сбщ-ош) */
  v-file-name-rep-htm = search(v-file-name-rep-htm) .
  if search(v-file-name-rep-htm) = ? then do:
    message "Не найден файл отчёта:" v-file-name-rep-htm view-as alert-box error.
  end.
  else do :
    /* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    /* Полный_путь_имя_файла_RV + " " + Полный_путь_имя_файла_отчHTML */
    os-command no-wait value(v-full-path-RepView + " true " + v-file-name-rep-htm).
  end .
*/

procedure chk-calc:
define input parameter p-obj-code as integer no-undo. 
define input parameter p-obj-type as character no-undo.
define input parameter p-doc-code as character no-undo.
define input parameter p-sales-man as integer no-undo.
define input parameter p-salesman-psn-code as integer no-undo.
define input parameter p-chk-type as integer no-undo.
define variable v-prod as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-grp-code as integer no-undo .
define variable v-grp-name like ub.goods.grp-name no-undo.
define variable v-found as logical no-undo.
define variable v-use-line as logical no-undo.
define variable ii-grp as integer no-undo.
define variable v-name         as char      no-undo.
define variable vSumUnBase as decimal no-undo.
define buffer buf_chk-gds-pay for ub.chk-gds-pay .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods    for ub.goods .
define buffer buf_person   for ub.person .
define buffer buf-qnty-temp-chk for temp-chk .


  /* итоговая запись по продавцу */
  /* если вынести суммирование doc-qnty по продавцу - то можно вынести и создание итоговой записи по нему */
  if p-tog-prod = yes then do:
    find first buf-qnty-temp-chk
         where buf-qnty-temp-chk.gds-code = 0 
           and buf-qnty-temp-chk.obj-code = p-obj-code
           and buf-qnty-temp-chk.obj-type = p-obj-type
// 23/VIII-2018
//           and buf-qnty-temp-chk.grp-code = p-sales-man
//           and buf-qnty-temp-chk.sales-man-psn = p-salesman-psn-code
           and buf-qnty-temp-chk.grp-code = p-salesman-psn-code
    use-index tt no-error .
    if not available buf-qnty-temp-chk then do:
      if p-sales-man <> 0 then do:
        run rep/get-psn.p (input p-salesman-psn-code, output v-name ).
        for first buf_person no-lock where buf_person.psn-code = p-salesman-psn-code : 
          v-name = v-name + '  ' + buf_person.name1 + ' ':U + buf_person.name2.
        end.
      end.
      else v-name = "Продавец не указан".
      create buf-qnty-temp-chk.
      assign
        buf-qnty-temp-chk.gds-code  = 0 
        buf-qnty-temp-chk.obj-code  = p-obj-code 
        buf-qnty-temp-chk.obj-type  = p-obj-type
// 23/VIII-2018                             
//        buf-qnty-temp-chk.grp-code  = p-sales-man 
//        buf-qnty-temp-chk.sales-man-psn = p-salesman-psn-code
        buf-qnty-temp-chk.grp-code  = p-salesman-psn-code
        buf-qnty-temp-chk.grp-lvl     = 1  // по продавцам - где используется ?
        buf-qnty-temp-chk.upper-code  = -2 // по продавцам - где используется ?
        buf-qnty-temp-chk.gds-name    = v-name
        buf-qnty-temp-chk.doc-qnty    = 0
      .
    end.
  end .

  v-prod = no.
   
  _chk:
  for each buf_chk-gds-pay no-lock
     where buf_chk-gds-pay.doc-code = p-doc-code 
       and buf_chk-gds-pay.algo-num = {&current-algo-1}
  break by buf_chk-gds-pay.b-code
        by buf_chk-gds-pay.line-num :
    /* каждый новый b-code увеличивает кол-во чеков, т.к. в пределах одного чека мы сгруппированы по b-code */
    /* каждый новый line-num увеличивает кол-во покупок, т.к. в пределах одного чека он показывает кол-во b-code в чеке */

    
    if first-of (buf_chk-gds-pay.b-code) then do :
      v-use-line = false .
            
      /* поиск записи о товаре */
      find first buf_bar-code no-lock
           where buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error .
      if available buf_bar-code then do :
        v-gds-code = buf_bar-code.gds-code .
        find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
        if available buf_goods then do:
          v-grp-code = buf_goods.grp-code .
        end .
        else v-grp-code = ? .
      end .
      else assign
        v-gds-code = ?
        v-grp-code = ?        
      .
      if v-grp-code = ? then next .
      /* v-grp-code = ? означает not available buf_goods;
         buf_goods используется при фильтре по выбранным товарам и при создании записи в temp-chk */
      
      /* фильтр по выбранным товарам или по группам товаров */ 
      case x-SelectGood: 
        when {&g-choice} or
        when {&g-spis} or
        when {&g-one} then do:
          find first gds-list
               where gds-list.artic     = buf_goods.artic
                 and gds-list.prod-type = buf_goods.prod-type
                 and gds-list.prod-code = buf_goods.prod-code no-error .
          if not available gds-list then next.
        end.
        when {&g-all} then . /* все товары */
        when {&g-grp} then do :
          assign
            v-grp-name = ""
            v-found = no
          .
          _ii-grp:
          do ii-grp = 1 to num-entries(buf_goods.grp-name, {&delim-grp}) - 1 :
            /* где {&delim-grp} = CHR(47) = "/". Фактически это уровни вложенности данной группы товаров */

             /* Вытаскиваем из полной цепочки - имя каждой группы для каждого уровня. Цепочка от корня до тек группы. */
            v-grp-name = v-grp-name + entry(ii-grp, buf_goods.grp-name, {&delim-grp}) + {&delim-grp} .
            if can-find(first tmp#grp where tmp#grp.grp-name = v-grp-name) then do:
              v-found = yes.
              leave _ii-grp.
            end.
          end. /* end_of_ii-grp */
          if not v-found then next _chk.
        end.
        otherwise next . /*не определён критерий отбора товаров*/
      end case.
                                                                                       
      v-use-line = true .
      /* из предыдущей версии исходных текстов следовало, что суммируется только количество чеков продажи */
      
      if (p-chk-type = {&bef-rcpt-sale}) then do :
      if not can-find (first help-chk where help-chk.doc-code  = buf_chk-gds-pay.doc-code
                                        and help-chk.group-chk = v-grp-code
                                        and help-chk.obj-code  = p-obj-code
                                        and help-chk.obj-type  = p-obj-type) then do:
        create help-chk.
        assign             
          help-chk.doc-code  = buf_chk-gds-pay.doc-code
          help-chk.group-chk = v-grp-code
          help-chk.obj-code  = p-obj-code
          help-chk.obj-type  = p-obj-type
        .
      end.
      end .  
      
      /* разделять по продавцам или нет */
      if p-tog-prod = yes then do:
        if not v-prod then assign
          buf-qnty-temp-chk.doc-qnty = buf-qnty-temp-chk.doc-qnty + 1 when (p-chk-type = {&bef-rcpt-sale})
          v-prod = yes 
        .
        find first temp-chk
             where temp-chk.gds-code = v-gds-code
               and temp-chk.obj-code = p-obj-code
               and temp-chk.obj-type = p-obj-type
// 23/VIII-2018               
//               and temp-chk.grp-code = p-sales-man
//               and temp-chk.sales-man-psn = p-salesman-psn-code
               and temp-chk.grp-code = p-salesman-psn-code
        use-index tt no-error .
        if not available temp-chk then do:
          create temp-chk.
          assign    
            temp-chk.gds-code = v-gds-code  
            temp-chk.obj-code = p-obj-code 
            temp-chk.obj-type = p-obj-type            
// 23/VIII-2018               
//            temp-chk.grp-code = p-sales-man 
//            temp-chk.sales-man-psn = p-salesman-psn-code
            temp-chk.grp-code = p-salesman-psn-code
            temp-chk.gds-name    = buf_goods.gds-name
            temp-chk.unit        = buf_goods.unit-base
            temp-chk.doc-qnty    = 0
          .
        end.
      end.
      else do:
        if not v-prod then assign
          obj-temp-chk.doc-qnty = obj-temp-chk.doc-qnty + 1 when (p-chk-type = {&bef-rcpt-sale})
          v-prod = yes 
        .  
        find first temp-chk
             where temp-chk.gds-code = v-gds-code  
               and temp-chk.obj-code = p-obj-code
               and temp-chk.obj-type = p-obj-type
        use-index tt no-error .        
        if not available temp-chk then do:
          create temp-chk.
          assign
            temp-chk.gds-code = v-gds-code
            temp-chk.obj-code = p-obj-code  
            temp-chk.obj-type = p-obj-type                  
            temp-chk.gds-name = buf_goods.gds-name
            temp-chk.unit     = buf_goods.unit-base
            temp-chk.grp-code = buf_goods.grp-code
            temp-chk.doc-qnty = 0
          .
        end.
      end.

      /* temp-chk.doc-qnty увеличивается много раз за чек: один раз по каждому товару в чеке */
      /* obj-temp-chk.doc-qnty не суммируется в отчёте по продавцам;
         obj-temp-chk.doc-qnty увеличивается в только один раз за чек для отчёта по группам;
         Если есть разбивка по продавцам то doc-qnty увеличивается в отдельном буффере, в разрезе продавцов */
      if p-chk-type = {&bef-rcpt-sale} then assign
        temp-chk.doc-qnty = temp-chk.doc-qnty + 1
      .
    end . /* end_of first_of b-code */
    if not v-use-line then next .
    
    if p-chk-type = {&bef-rcpt-sale} then do:
      if first-of(buf_chk-gds-pay.line-num) then assign 
        temp-chk.pok-qnty     = temp-chk.pok-qnty     + 1 
        obj-temp-chk.pok-qnty = obj-temp-chk.pok-qnty + 1
      .
    end .
      
    assign
      vSumUnBase = GetUnBaseSum(buf_chk-gds-pay.doc-code, buf_chk-gds-pay.line-num, buf_chk-gds-pay.eff-doc-qnty, buf_chk-gds-pay.price-base) 
      /* буффер temp-chk создан и спозиционирован в first-of_b-code */
      temp-chk.qnty       = temp-chk.qnty       + buf_chk-gds-pay.eff-doc-qnty
      temp-chk.sum-unbase = temp-chk.sum-unbase + vSumUnBase          
      temp-chk.sum-base   = temp-chk.sum-base   + buf_chk-gds-pay.tot-r-b
      /* буффер obj-temp-chk виден глобально и спозиционирован в вызывающей процедуре */
      obj-temp-chk.qnty       = obj-temp-chk.qnty       + buf_chk-gds-pay.eff-doc-qnty
      obj-temp-chk.sum-unbase = obj-temp-chk.sum-unbase + vSumUnBase 
      obj-temp-chk.sum-base   = obj-temp-chk.sum-base   + buf_chk-gds-pay.tot-r-b
    .

    /* обновление средних величин. Потом можно буде вынести за цикл и выполнить 1 раз после заполнения всех сумм */
    assign 
      temp-chk.srchk-kol-tov       = temp-chk.qnty       / temp-chk.doc-qnty
      temp-chk.srchk-sum           = temp-chk.sum-unbase / temp-chk.doc-qnty
      temp-chk.srchk-base-sum      = temp-chk.sum-base   / temp-chk.doc-qnty
      temp-chk.srchk-kol-tov-pokup = temp-chk.pok-qnty   / temp-chk.doc-qnty
    .
  end. /* end_of for_each chk-gds-pay */

end procedure. /* end_of chk-calc */


/* *********************** */
procedure create-fill-tt-chk:
define variable v-chk-type-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc .

  if not p-tog-raz then do:
    create obj-temp-chk.
    assign
      obj-temp-chk.obj-code = 0
      obj-temp-chk.obj-type = ''
      obj-temp-chk.gds-name = 'Итого по всем объектам'
      obj-temp-chk.upper-code = -1
      obj-temp-chk.grp-code   = 0
      v-obj-type = ''
      v-obj-code = 0
    . 
  end.

  v-chk-type-list = {&rcpt-sale} .
  if p-tog-uchet = no then v-chk-type-list = v-chk-type-list + "," + {&rcpt-return} . /* учитываем все типы продаж и возвратов */
     
  for each obj-list :
    do:
      run rep/rpychk0.p (input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?                    /*p-date-from*/
                        ,input ?                    /*p-date-to*/
                        ,input X-date-start         /*p-shift-date-from*/
                        ,input X-date-end           /*p-shift-date-to*/
                        ,input 0                 /*p-shift-num-start*/
                        ,input 99                /*p-shift-num-end*/
                        ,input ?                    /*p-inkas-code*/
      ) no-error.
      if error-status:error then do:
          message
            substitute( "*** Ошибка вызова rpychk0 по объекту &1 &2. &3. &4. &5."
                    , obj-list.obj-type
                    , obj-list.obj-code
                    , return-value
                    , error-status:get-message(1)
                    , error-status:get-message(2)
                    )
            view-as alert-box .
      end.
    end. /* end_of rep/rpychk0.p */

    if p-tog-raz then do:
      create obj-temp-chk.
      assign
        obj-temp-chk.obj-code = obj-list.obj-code
        obj-temp-chk.obj-type = obj-list.obj-type
        obj-temp-chk.gds-name = obj-list.obj-name
        obj-temp-chk.upper-code = -1
        obj-temp-chk.grp-code   = 0
        v-obj-type = obj-list.obj-type
        v-obj-code = obj-list.obj-code
      . 
    end.

    if x-TOG-Shift = yes then do:
      /* по индексу shift: obj-type, obj-code, shift-date, shift-num */    
      
      for each buf_chk-doc no-lock
         where buf_chk-doc.obj-type = obj-list.obj-type
           and buf_chk-doc.obj-code = obj-list.obj-code
           and buf_chk-doc.shift-date >= X-date-Start
           and buf_chk-doc.shift-date <= X-date-End
           and buf_chk-doc.out-code <> ? /* учтённые чеки */
           and can-do(v-chk-type-list, string(buf_chk-doc.chk-type))
      :
        if (buf_chk-doc.shift-date = X-date-Start)
       and (buf_chk-doc.shift-num < x-Shift-Start) then next. 
        if (buf_chk-doc.shift-date = X-date-End)
       and (buf_chk-doc.shift-num > x-Shift-End) then next. 
           
        run chk-calc in this-procedure
        ( input v-obj-code
        , input v-obj-type
        , input buf_chk-doc.doc-code
        , input buf_chk-doc.sales-man
        , input buf_chk-doc.salesman-psn-code
        , input buf_chk-doc.chk-type
        ) .
      end . /* end_of for_each chk_doc */ 

    end. /* if x-TOG-Shift = yes */
    else do: /* else if x-TOG-Shift = no */
      /* по индексу obj-date: obj-type, obj-code, chk-date */
          
      for each buf_chk-doc no-lock
         where buf_chk-doc.obj-type = obj-list.obj-type
           and buf_chk-doc.obj-code = obj-list.obj-code
           and buf_chk-doc.chk-date >= X-date-Start
           and buf_chk-doc.chk-date <= X-date-End
           and buf_chk-doc.out-code <> ? /* учтённые чеки */
           and can-do(v-chk-type-list, string(buf_chk-doc.chk-type))
      :
        run chk-calc in this-procedure
        ( input v-obj-code
        , input v-obj-type
        , input buf_chk-doc.doc-code
        , input buf_chk-doc.sales-man
        , input buf_chk-doc.salesman-psn-code
        , input buf_chk-doc.chk-type
        ) .
      end . /* end_of for_each chk_doc */
      
    end. /* else if x-TOG-Shift = no */

    if p-tog-raz = yes then do:
      /* Преобразование созданной выше chk-calc в таблицу с уровнями и итогами по каждому уровню. */
      if p-tog-prod = yes then run prod-level         ( input obj-list.obj-code, input obj-list.obj-type).
                          else run transform-tt-level ( input obj-list.obj-code, input obj-list.obj-type).
      assign 
        obj-temp-chk.srchk-uch         = 100 
        obj-temp-chk.srchk-base-uch    = 100
        obj-temp-chk.srchk-kol-tov-uch = 100
        obj-temp-chk.srchk-kol-tov       = obj-temp-chk.qnty       / obj-temp-chk.doc-qnty
        obj-temp-chk.srchk-sum           = obj-temp-chk.sum-unbase / obj-temp-chk.doc-qnty
        obj-temp-chk.srchk-base-sum      = obj-temp-chk.sum-base   / obj-temp-chk.doc-qnty
        obj-temp-chk.srchk-kol-tov-pokup = obj-temp-chk.pok-qnty   / obj-temp-chk.doc-qnty
      .
    end .       
  end. /* for each obj-list */ 

  if p-tog-raz = no then do:
    if p-tog-prod = yes then run prod-level        ( input 0, input '').
                        else run transform-tt-level( input 0, input '').
    assign 
      obj-temp-chk.srchk-uch         = 100 
      obj-temp-chk.srchk-base-uch    = 100
      obj-temp-chk.srchk-kol-tov-uch = 100
      obj-temp-chk.srchk-kol-tov       = obj-temp-chk.qnty       / obj-temp-chk.doc-qnty
      obj-temp-chk.srchk-sum           = obj-temp-chk.sum-unbase / obj-temp-chk.doc-qnty
      obj-temp-chk.srchk-base-sum      = obj-temp-chk.sum-base   / obj-temp-chk.doc-qnty
      obj-temp-chk.srchk-kol-tov-pokup = obj-temp-chk.pok-qnty   / obj-temp-chk.doc-qnty
    .
  end .

end procedure. /* create-fill-tt-chk */
    
procedure proc-create-HTML:   
define input parameter p-file-name-rep-htm as character no-undo.
define input parameter p-report-name as character no-undo.
define input parameter p-period-date as char no-undo. 
define input parameter v-choice-gds as char no-undo.
define input parameter v-choice-obj as char no-undo.
define input parameter tog-uchet-html as char no-undo.
define input parameter tog-raz-html as char no-undo.
 
    define buffer buf-html-temp-chk for temp-chk.

  /* v-cntxt-host-name-obj отображается в заголовке отчёта;
     надеемся, что все объекты в obj-list принадлежат одной фирме */
  for first obj-list :
    { gbl/hostname.i obj-list.obj-type obj-list.obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
  end .
  
  output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
  
  do:  /* Системная шапка HTML */
    put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
    '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
                '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
                '      htm' skip
                '      .rotate ' + chr(123) skip
                '        -webkit-transform: rotate(-90deg);' skip
                '        -moz-transform: rotate(-90deg);' skip
                '        -ms-transform: rotate(-90deg);' skip
                '        -o-transform: rotate(-90deg);' skip
                '        transform: rotate(-90deg);' skip

                
                '        -webkit-transform-origin: 50% 50%;' skip
                '        -moz-transform-origin: 50% 50%;' skip
                '        -ms-transform-origin: 50% 50%;' skip
                '        -o-transform-origin: 50% 50%;' skip
                '        transform-origin: 50% 50%;' skip


                '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
                '          ' + chr(125) skip
                '            th' + ' ' + chr(123) skip
                '            border: 1px black solid;' skip
                '            word-wrap: break-word;' skip
                '          ' + chr(125) skip
                '   </style>' skip
                '  </head>' skip
            .
    end. 
    
 do:  /* Параметры "глобальной" таблицы отчёта */
     put stream OutStr-html unformatted
         ' <body>' skip
         '   <table name="Лист1" fit_to_page="true" orientation="landscape" outline_below="false">' skip
         '     <thead>' skip
         '       <tr class="set_columns">' skip                          
         '         <td style="width: 60px; border: none;"></td>' skip    /*Код*/
         '         <td style="width: 200px; border: none;"></td>' skip      /*Наименование товара*/
         '         <td style="width: 78px; border: none;"></td>' skip    /* Единица измерения*/
         '         <td style="width: 78px; border: none;"></td>' skip   /*Количество*/
         '         <td style="width: 78px; border: none;"></td>' skip  /*Сумма без скидок*/
         '         <td style="width: 78px; border: none;"></td>' skip  /*Сумма со скидкой*/
         '         <td style="width: 78px; border: none;"></td>' skip  /*Количество чеков*/
         '         <td style="width: 78px; border: none;"></td>' skip  /*Количество покупок*/
         '         <td style="width: 78px; border: none;"></td>' skip   /*Средний чек по количеству товаров*/
         '         <td style="width: 68px; border: none;"></td>' skip    /*сумма*/
         '         <td style="width: 68px; border: none;"></td>' skip /*участие*/
              /*Средний чек по сумме без скидок*/
         '         <td style="width: 68px; border: none;"></td>' skip    /*сумма*/
         '         <td style="width: 68px; border: none;"></td>' skip  /*участие*/
             /*Средний чек по количеству покупок товара */
         '         <td style="width: 78px; border: none;"></td>' skip    /*количество покупок*/
         '         <td style="width: 68px; border: none;"></td>' skip /*участие*/
            
            
         '       </tr>' skip
         .
            
            end.
            /* Заполнение "глобальной" таблицы - блок шапки отчёта (часть отчёта, видимая как "не таблица") */
    do: /* b3 */
            put stream OutStr-html unformatted
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px; font-size: 14pt; font-weight: bold">Отчет по среднему чеку </td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">По фирме:  ' +    v-cntxt-host-name-obj    + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">' + v-choice-obj + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip             
            '       </tr>' skip
            
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">' + p-period-date + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
                     
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">' + v-choice-gds + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
                       
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">Возвраты:  ' +  tog-uchet-html  + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '       </tr>' skip
            
         
            '       <tr>' skip
            '         <td colspan="15" style="border: none; height: 14px">Раздельно по объектам:    '   + tog-raz-html '  </td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip                    
            '       </tr>' skip
                
                
                '     </thead>' skip
            . /* Точка для закрытия Put */
    end. /* b3 */
            
             do:  /* Шапка таблицы отчёта (видимой, как таблица) */
            put stream OutStr-html unformatted
            '     <tbody>' skip
             '       <tr style="height: 60px;">' skip
            '         <th  rowspan="2" style="background-color:#ffffcc; text-align: center;">Код</th>' skip
            '         <th  rowspan="2"   style="background-color:#ffffcc; text-align: center;">Наименование товара</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Единица измерения</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Количество</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Сумма без скидок</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Сумма со скидкой</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Количество чеков</th>' skip
            '         <th rowspan="2" style="background-color:#ffffcc; text-align: center;">Количество покупок</th>' skip
            '         <th rowspan="2"  style="background-color:#ffffcc; text-align: center;">Средний чек по количеству товаров</th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; text-align: center;">Средний чек по сумме без скидок</th>' skip
            '         <th  colspan="2" style="background-color:#ffffcc; text-align: center;">Средний чек по сумме со скидками</th>' skip                
            '         <th  colspan="2" style="background-color:#ffffcc; text-align: center;">Средний чек по кол-ву покупок товара </th>' skip
                   
            '</tr>'   skip    
               '       <tr style="height: 45px;">' skip
            '        <th style="background-color:#ffffcc; text-align: center;">Сумма</th>' skip 
            '         <th style="background-color:#ffffcc; text-align: center;">Участие (%)</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Сумма</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Участие (%)</th>' skip             
            '         <th style="background-color:#ffffcc; text-align: center;">Количество покупок</th>' skip
            '         <th style="background-color:#ffffcc; text-align: center;">Участие (%)</th>' skip
            '</tr>'skip


                     
                     '       <tr>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">1</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">2</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">3</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">4</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">5</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">6</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">7</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">8</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">9</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">10</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">11</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">12</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">13</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">14</th>' skip
                     '         <th num="" style="background-color:#ffffcc; text-align: center">15</th>' skip
                                              
                     '       </tr>' skip.
            
            
            
            
             output stream OutStr-html close.
    end. 
    
    
                                                                                                            
    do:    
        output stream OutStr-html to value(p-file-name-rep-htm) append convert target 'UTF-8'.
        /* 
        if p-tog-raz = no then 
        do:  
            run tt-print-line (input '', input 0, input 1 , input 2). /* Доформирование групп */
        end.
if p-tog-raz = yes then do:
    */
  
            
        find first buf-html-temp-chk no-lock no-error.
        if not error-status:error and available buf-html-temp-chk then
        do:
            
            for each buf-html-temp-chk where
                buf-html-temp-chk.grp-code = 0 and buf-html-temp-chk.upper-code = -1 and buf-html-temp-chk.gds-code = 0 no-lock
                by buf-html-temp-chk.obj-type by buf-html-temp-chk.obj-code
                :
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td colspan="3" style="display: yes; text-align: left; font-weight: bold">' +  buf-html-temp-chk.gds-name + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'  + if buf-html-temp-chk.qnty <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.qnty, "->>>>>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.sum-unbase <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.sum-unbase, "->>>>>>>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.sum-base <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.sum-base, "->>>>>>>>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.doc-qnty <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.doc-qnty, "->>>>>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.pok-qnty <> ? then fnc-convert-dot-to-colon( buf-html-temp-chk.pok-qnty, "->>>>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-kol-tov <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-kol-tov, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                                  
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-sum <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-uch <> ? then  fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-uch , "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
   
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if buf-html-temp-chk.srchk-base-sum <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-base-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if  buf-html-temp-chk.srchk-base-uch <> ?  then fnc-convert-dot-to-colon(  buf-html-temp-chk.srchk-base-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
          
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if  buf-html-temp-chk.srchk-kol-tov-pokup <> ?  then fnc-convert-dot-to-colon(  buf-html-temp-chk.srchk-kol-tov-pokup, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right; font-weight: bold">'   + if  buf-html-temp-chk.srchk-kol-tov-uch   <> ?  then fnc-convert-dot-to-colon( buf-html-temp-chk.srchk-kol-tov-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    .
                if p-tog-prod = yes then run tt-print-line (input buf-html-temp-chk.obj-type, input buf-html-temp-chk.obj-code, input -2 , input 2). /* Доформирование групп */
                if p-tog-prod = no then run tt-print-line (input buf-html-temp-chk.obj-type, input buf-html-temp-chk.obj-code, input 1 , input 2). /* Доформирование групп */
                
            end. 
 
        end.
   
        else /* Если отчёт пустой - выводим строку-пустышку */
        do:

            put stream OutStr-html unformatted
                '       <tr>' skip
                '         <td style="display: yes; text-align: center; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align: center; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip            
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '         <td style="display: yes; text-align:  right; font-weight: bold">'    '</td>' skip
                '       </tr>' skip
                . 
        end.
    end. /* b5 */
  /*  end.  */
          /* Заполнение подвала отчёта */
        do: 
                put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
                . /* Точка для закрытия Put */
        output stream OutStr-html close.
    end. 
    
end procedure. /* end_of proc-create-HTML */


/*define stream fhlp .*/
/******************************************************/
/* Трансформация плоской таблицы в таблицу с уровнями */
/* и с итогами для каждого уровня.                    */
procedure transform-tt-level  :
define input parameter v-obj-code as integer no-undo.
define input parameter v-obj-type as character no-undo.
define variable v-eff-doc-qnty as decimal   no-undo.
define variable v-object-sum   as decimal   no-undo.
define variable v-tot-r-b      as decimal   no-undo.
define variable v-pok-qnty     as integer   no-undo.
define variable v-gds-name     as character no-undo.
define variable v-cur-lvl      as integer   no-undo.
define variable v-upper-code   as integer   initial ? no-undo.
define variable v-find-grp-lvl  as integer no-undo.
define buffer buf_gds-grp     for ub.gds-grp .
define buffer buftt_temp-chk  for temp-chk .
define buffer buf2_help-chk   for help-chk .
define buffer buftt2_temp-chk for temp-chk .

  /* ? v-cur-lvl = 0. ? - да */
/*  
run gbl/inidebug.p .
define variable v-dsfile as character no-undo .
define variable v-hsfile as character no-undo .
v-dsfile = substitute("a1-&1-temp-chk.xml", v-cur-lvl).
temp-table temp-chk:WRITE-XML ( "FILE", v-dsfile, true, "UTF-8").
v-hsfile = substitute("a1-&1-help-chk.xml", v-cur-lvl).

define buffer b-help-chk for help-chk .
output stream fhlp to value(v-hsfile).
for each b-help-chk by b-help-chk.group-chk :
  put stream fhlp unformatted b-help-chk.group-chk " " b-help-chk.doc-code skip .
end .
output stream fhlp close .
*/
  do while v-upper-code <> 0:
    v-upper-code = 0.
    for each temp-chk
       where temp-chk.grp-lvl  = v-cur-lvl
         and temp-chk.obj-type = v-obj-type
         and temp-chk.obj-code = v-obj-code
         and temp-chk.upper-code <> -1
    use-index tt-grp
    break by temp-chk.grp-code :

      if first-of (temp-chk.grp-code) then do:
        assign
          v-eff-doc-qnty = 0 /* Количество */
          v-object-sum   = 0 /* Сумма без скидки */
          v-tot-r-b      = 0 /* Сумма со скидкой */
          v-pok-qnty     = 0 /* Количество покупок */
        .
        find first buf_gds-grp no-lock where buf_gds-grp.node-code = temp-chk.grp-code no-error.
        if available buf_gds-grp then assign
          v-upper-code = buf_gds-grp.upper-code
          v-gds-name   = buf_gds-grp.node-name
        .
        else v-gds-name = ''.
      end.
      
      assign
        v-eff-doc-qnty = v-eff-doc-qnty + temp-chk.qnty       /* Количество */
        v-object-sum   = v-object-sum   + temp-chk.sum-unbase /* Сумма без скидки */
        v-tot-r-b      = v-tot-r-b      + temp-chk.sum-base   /* Сумма со скидкой */
        v-pok-qnty     = v-pok-qnty     + temp-chk.pok-qnty   /* Количество покупок */
      .
      assign
        temp-chk.srchk-kol-tov-uch = temp-chk.pok-qnty   * 100 / obj-temp-chk.pok-qnty
        temp-chk.srchk-base-uch    = temp-chk.sum-base   * 100 / obj-temp-chk.sum-base
        temp-chk.srchk-uch         = temp-chk.sum-unbase * 100 / obj-temp-chk.sum-unbase
      .  
      if temp-chk.grp-lvl = 0 then assign
        temp-chk.upper-code = temp-chk.grp-code
      .
      else assign
        temp-chk.upper-code = v-upper-code
        temp-chk.gds-name   = v-gds-name
      .
       
      if last-of (temp-chk.grp-code) and v-upper-code <> 0 then do :
        v-find-grp-lvl = temp-chk.grp-lvl + 1 .
        find first buftt_temp-chk
             where buftt_temp-chk.grp-lvl  = v-find-grp-lvl
               and buftt_temp-chk.obj-type = v-obj-type 
               and buftt_temp-chk.obj-code = v-obj-code 
               and buftt_temp-chk.grp-code = temp-chk.upper-code no-error.
        if not available buftt_temp-chk then do:
          create buftt_temp-chk .
          assign
            buftt_temp-chk.grp-lvl  = v-find-grp-lvl  /* Уровень группы (относительный, как порядок следования групп: 1, 2, ...) */
            /* Наименование uруппы товаров */
            buftt_temp-chk.obj-type = v-obj-type
            buftt_temp-chk.obj-code = v-obj-code
            buftt_temp-chk.grp-code = temp-chk.upper-code /* Группа товара (как-бы заголовок для группы) */
            buftt_temp-chk.gds-name = v-gds-name
          .
        end.
        assign 
          buftt_temp-chk.qnty       = buftt_temp-chk.qnty       + v-eff-doc-qnty /* Количество */
          buftt_temp-chk.sum-unbase = buftt_temp-chk.sum-unbase + v-object-sum   /* Сумма без скидки */
          buftt_temp-chk.sum-base   = buftt_temp-chk.sum-base   + v-tot-r-b      /* Сумма со скидкой */
          buftt_temp-chk.pok-qnty   = buftt_temp-chk.pok-qnty   + v-pok-qnty     /* количество покупок*/
        .
        /* только создавать help-chk на родительскую группу с номерами своих чеков;
           не прибавлять суммирование количества чеков по каждой группе, а суммировать их отдельно,
           целиком по родительской группе, после того, как в неё будут добавлены все чеки */                               
        for each help-chk where help-chk.group-chk = temp-chk.grp-code
                            and help-chk.obj-code  = v-obj-code
                            and help-chk.obj-type  = v-obj-type:
/* 14/V-2018         buftt_temp-chk.doc-qnty = buftt_temp-chk.doc-qnty + 1.*/
          if not can-find (first buf2_help-chk where buf2_help-chk.doc-code  = help-chk.doc-code
                                                 and buf2_help-chk.group-chk = temp-chk.upper-code
                                                 and buf2_help-chk.obj-code  = v-obj-code
                                                 and buf2_help-chk.obj-type  = v-obj-type) then do:
            create buf2_help-chk.
            assign             
              buf2_help-chk.doc-code  = help-chk.doc-code
              buf2_help-chk.group-chk = temp-chk.upper-code
              buf2_help-chk.obj-code  = v-obj-code
              buf2_help-chk.obj-type  = v-obj-type
            .
          end.     
        end.
        buftt_temp-chk.doc-qnty = 0 .
        for each buf2_help-chk where buf2_help-chk.group-chk = temp-chk.upper-code
                                 and buf2_help-chk.obj-code  = v-obj-code
                                 and buf2_help-chk.obj-type  = v-obj-type :
          buftt_temp-chk.doc-qnty = buftt_temp-chk.doc-qnty + 1 .
        end .        
        assign
          buftt_temp-chk.srchk-kol-tov       = buftt_temp-chk.qnty       / buftt_temp-chk.doc-qnty
          buftt_temp-chk.srchk-sum           = buftt_temp-chk.sum-unbase / buftt_temp-chk.doc-qnty
          buftt_temp-chk.srchk-base-sum      = buftt_temp-chk.sum-base   / buftt_temp-chk.doc-qnty
          buftt_temp-chk.srchk-kol-tov-pokup = buftt_temp-chk.pok-qnty   / buftt_temp-chk.doc-qnty
        .
      end. /* end_of last-of_grp-code */
      
    end. /* temp-chk */
/*
v-dsfile = substitute("a2-&1-temp-chk.xml", v-cur-lvl).
temp-table temp-chk:WRITE-XML ( "FILE", v-dsfile, true, "UTF-8").
v-hsfile = substitute("a2-&1-help-chk.xml", v-cur-lvl).
output stream fhlp to value(v-hsfile).
for each b-help-chk by b-help-chk.group-chk :
  put stream fhlp unformatted b-help-chk.group-chk " " b-help-chk.doc-code skip .
end .
output stream fhlp close .
*/
    v-cur-lvl = v-cur-lvl + 1.
  end. /* do while */
 

  /* все записи о группах, кроме записи о магазине */      
  for each buftt2_temp-chk
     where buftt2_temp-chk.gds-code = 0 
       and buftt2_temp-chk.obj-code = v-obj-code 
       and buftt2_temp-chk.obj-type = v-obj-type 
       and buftt2_temp-chk.grp-code <> 0
       and buftt2_temp-chk.grp-lvl  > 1 :
    /* записи о группах, полученные с разных ветвей дерева:
       например, группа "Товары", полученная из группы бензина (третий уровень вложенности), и
       она же, полученная из группы напитков (пятый уровень вложенности) будет записана двумя записями,
       с одинаковыми grp-code и с разными grp-lvl.
       Уровень 0 = товары, уровень 1 = группа, в которой есть товар, начиная с уровня 2 возможны группы,
       полученные из разных ветвей дерева. Их складываем. */      
    if can-find (first buftt_temp-chk
                 where buftt_temp-chk.gds-code = 0
                   and buftt_temp-chk.obj-code = buftt2_temp-chk.obj-code 
                   and buftt_temp-chk.obj-type = buftt2_temp-chk.obj-type 
                   and buftt_temp-chk.grp-code = buftt2_temp-chk.grp-code
                   and buftt_temp-chk.grp-lvl  > 0
                   and buftt_temp-chk.grp-lvl <> buftt2_temp-chk.grp-lvl) then do :
      for each buftt_temp-chk
         where buftt_temp-chk.gds-code = 0
           and buftt_temp-chk.obj-code = buftt2_temp-chk.obj-code 
           and buftt_temp-chk.obj-type = buftt2_temp-chk.obj-type 
           and buftt_temp-chk.grp-code = buftt2_temp-chk.grp-code
           and buftt_temp-chk.grp-lvl  > 0
           and buftt_temp-chk.grp-lvl <> buftt2_temp-chk.grp-lvl :
        assign
          buftt2_temp-chk.qnty       = buftt_temp-chk.qnty       + buftt2_temp-chk.qnty       /* Количество */
          buftt2_temp-chk.sum-unbase = buftt_temp-chk.sum-unbase + buftt2_temp-chk.sum-unbase /* Сумма без скидки */
          buftt2_temp-chk.sum-base   = buftt_temp-chk.sum-base   + buftt2_temp-chk.sum-base   /* Сумма со скидкой */
/*        buftt2_temp-chk.doc-qnty   = buftt_temp-chk.doc-qnty   + buftt2_temp-chk.doc-qnty   /* Количество чеков */*/
          buftt2_temp-chk.pok-qnty   = buftt_temp-chk.pok-qnty   + buftt2_temp-chk.pok-qnty   /* количество покупок */
        .
        delete buftt_temp-chk.   
      end . /* end_of for_each_buftt_temp-chk */
      /* количество чеков суммируем заново, на случай если два товара из разных подгрупп одной группы попали в один чек */
      buftt2_temp-chk.doc-qnty = 0 . /* Количество чеков */
      for each help-chk where help-chk.group-chk = buftt2_temp-chk.grp-code
                          and help-chk.obj-code  = buftt2_temp-chk.obj-code
                          and help-chk.obj-type  = buftt2_temp-chk.obj-type:
        buftt2_temp-chk.doc-qnty = buftt2_temp-chk.doc-qnty + 1.
      end.
    end . /* end_of найдены группы с разных уровней */
  end.
/*
v-dsfile = substitute("a3-&1-temp-chk.xml", v-cur-lvl).
temp-table temp-chk:WRITE-XML ( "FILE", v-dsfile, true, "UTF-8").
v-hsfile = substitute("a3-&1-help-chk.xml", v-cur-lvl).
temp-table help-chk:WRITE-XML ( "FILE", v-hsfile, true, "UTF-8").
*/
end procedure. /* end_of transform-tt-level */


procedure tt-print-line:
/* Вывод линий таблицы с группировкой: 1) по имени группы товаров; 2) по уровню внутри группы */
    define input parameter v-obj-type as character no-undo.
    define input parameter v-obj-code as integer no-undo.
    define input parameter v-upper-code like ub.gds-grp.upper-code no-undo.
    define input parameter v-print-lvl as integer no-undo.
define variable v-display as character no-undo.  
    define buffer buf-grp_temp-chk for temp-chk.


 

/*              run  gbl/inidebug.p.*/

    for each buf-grp_temp-chk where
        buf-grp_temp-chk.upper-code = v-upper-code and
        buf-grp_temp-chk.obj-type = v-obj-type and
        buf-grp_temp-chk.obj-code = v-obj-code
        no-lock: 
          if v-print-lvl < 3 then /* Выводим в HTML определённые уровни(p-print-lvl) - счёт с единицы и далее (1-й и 2-й ... на подобие в Excel) */
        do:  /* Выводим инфо в Веб-браузер (делаем видимой) */
            v-display = "yes".
        end. /* Выводим инфо в Веб-браузер (делаем видимой) */
        else
        do:  /* НЕ выводим инфо в Веб-браузер (инфа есть, но делаем её НЕвидимой) */
            v-display = "none".
        end.
        do:
            if buf-grp_temp-chk.grp-lvl <> 0 then /* Условие когда выбраны ГРУППЫ ТОВАРОВ (Цель - печать жирным шрифтом) */
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(v-print-lvl) + '">' skip
/*                   '         <td style="display: yes; text-align: right; font-weight: bold">' +  string(buf-grp_temp-chk.gds-code) + '</td>' skip*/
                    '         <td colspan = "3" style="display: yes; text-align: left; font-weight: bold ; padding-left:  ' 
                    + string((v-print-lvl - 1) * 10) + 'px">'
                    + string(fill(" ", ((v-print-lvl - 2) * 4)))
                    + buf-grp_temp-chk.gds-name       + '</td>' skip
/*                  '         <td  style="display: yes; text-align: right; font-weight: bold">'  + buf-grp_temp-chk.unit +      '</td>'  skip*/
                    '         <td style="display: yes; text-align: right; font-weight: bold">'  + if buf-grp_temp-chk.qnty <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.qnty, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'  + if buf-grp_temp-chk.sum-unbase <> ? then fnc-convert-dot-to-colon(buf-grp_temp-chk.sum-unbase, "->>>>>>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'   + if buf-grp_temp-chk.sum-base <> ? then fnc-convert-dot-to-colon(buf-grp_temp-chk.sum-base, "->>>>>>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'    + if buf-grp_temp-chk.doc-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.doc-qnty, "->>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >' + if buf-grp_temp-chk.pok-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.pok-qnty, "->>>>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >' + if buf-grp_temp-chk.srchk-kol-tov <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-kol-tov, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                                  
                    '         <td style="display: yes; text-align: right; font-weight: bold" >' + if buf-grp_temp-chk.srchk-sum <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-sum, "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'    +  if buf-grp_temp-chk.srchk-uch  <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
   
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'     + if buf-grp_temp-chk.srchk-base-sum <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-base-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'        + if  buf-grp_temp-chk.srchk-base-uch <>?   then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-base-uch , "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
          
                    '         <td style="display: yes; text-align: right; font-weight: bold" >'    + if  buf-grp_temp-chk.srchk-kol-tov-pokup <> ?  then fnc-convert-dot-to-colon(  buf-grp_temp-chk.srchk-kol-tov-pokup, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '          <td style="display: yes; text-align:  right; font-weight: bold"  >'     +  if   buf-grp_temp-chk.srchk-kol-tov-uch   <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-kol-tov-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip 
                    '       </tr>' skip
                    . /* Точка для закрытия Put */
            
            end.
            else /* иначе - если более детальные уровни (v-print-lvl с 3-го и более), то формируем строки с такими уровнями в HTML, но на экран не выводим! */
            do:
                put stream OutStr-html unformatted
                    '       <tr level="' + string(v-print-lvl) + '">' skip
                    '         <td style="display: yes ;text-align: right">' +  fnc-convert-dot-to-colon(buf-grp_temp-chk.gds-code, "->>>>>>>>>999999") + '</td>' skip
                    '         <td num="0.00" style="display: yes;text-align: left;   padding-left: ' + string((v-print-lvl - 1) * 10) + 'px">'
                    + string(fill(" ", ((v-print-lvl - 2) * 4))) + buf-grp_temp-chk.gds-name
                    + '</td>' skip
                    '         <td  num="0.00" style="display: yes ;text-align: right">'  + buf-grp_temp-chk.unit +      '</td>'  skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.qnty <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.qnty, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right">'  + if buf-grp_temp-chk.sum-unbase <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.sum-unbase, "->>>>>>>>>9.99")   + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right">'   + if buf-grp_temp-chk.sum-base <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.sum-base, "->>>>>>>>>9.99")  + '</td>' else "?" + '</td>' skip
                    '         <td  style="display: yes ;text-align: right" >'    + if buf-grp_temp-chk.doc-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.doc-qnty, "->>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td  style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.pok-qnty <> ? then fnc-convert-dot-to-colon( buf-grp_temp-chk.pok-qnty, "->>>>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.srchk-kol-tov <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-kol-tov, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                                  
                    '         <td num="0.00" style="display: yes ;text-align: right" >' + if buf-grp_temp-chk.srchk-sum <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'  +  if buf-grp_temp-chk.srchk-uch  <> ?     then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-uch,  "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
   
                    '         <td num="0.00" style="display: yes ;text-align: right">'     + if buf-grp_temp-chk.srchk-base-sum <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-base-sum, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'      +  if buf-grp_temp-chk.srchk-base-uch  <> ?  then fnc-convert-dot-to-colon( buf-grp_temp-chk.srchk-base-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
          
                    '         <td num="0.00" style="display: yes ;text-align: right" >'     + if  buf-grp_temp-chk.srchk-kol-tov-pokup <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-kol-tov-pokup, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td num="0.00" style="display: yes ;text-align: right" >'  +  if buf-grp_temp-chk.srchk-kol-tov-uch  <> ?  then fnc-convert-dot-to-colon(buf-grp_temp-chk.srchk-kol-tov-uch, "->>>>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    . /* Точка для закрытия Put */
            end.
/*            output stream outstr-html close.*/
        end.
        if buf-grp_temp-chk.grp-lvl <> 0 then run tt-print-line (input v-obj-type, input v-obj-code, input buf-grp_temp-chk.grp-code, input v-print-lvl + 1 ).
            
    end.

end procedure.


procedure prod-level: 
define input parameter v-obj-code as integer no-undo.
define input parameter v-obj-type as character no-undo.

    define variable v-eff-doc-qnty as decimal   no-undo.
    define variable v-object-sum   as decimal   no-undo.
    define variable v-tot-r-b      as decimal   no-undo.
    define variable v-pok-qnty     as integer   no-undo.
    
  for each temp-chk
     where temp-chk.obj-type = v-obj-type
       and temp-chk.obj-code = v-obj-code
       and temp-chk.gds-code > 0
  break by temp-chk.grp-code : /* при разбивке по продавцам в grp-code лежит chk-doc.sales-man */
    if first-of (temp-chk.grp-code) then do:
      assign
        v-eff-doc-qnty = 0 /* Количество */
        v-object-sum   = 0 /* Сумма без скидки */
        v-tot-r-b      = 0 /* Сумма со скидкой */
        v-pok-qnty     = 0 /* Количество покупок*/
      .
    end.
    assign
      v-eff-doc-qnty = v-eff-doc-qnty + temp-chk.qnty       /* Количество */
      v-object-sum   = v-object-sum   + temp-chk.sum-unbase /* Сумма без скидки */
      v-tot-r-b      = v-tot-r-b      + temp-chk.sum-base   /* Сумма со скидкой */
      v-pok-qnty     = v-pok-qnty     + temp-chk.pok-qnty   /* Количество покупок*/
    .
    assign
      temp-chk.srchk-kol-tov-uch = temp-chk.pok-qnty   * 100 / obj-temp-chk.pok-qnty
      temp-chk.srchk-base-uch    = temp-chk.sum-base   * 100 / obj-temp-chk.sum-base
      temp-chk.srchk-uch         = temp-chk.sum-unbase * 100 / obj-temp-chk.sum-unbase
      temp-chk.upper-code        = temp-chk.grp-code
    .
    if last-of (temp-chk.grp-code) then do:
      find first prod-temp-chk
           where prod-temp-chk.gds-code = 0
             and prod-temp-chk.obj-code = temp-chk.obj-code
             and prod-temp-chk.obj-type = temp-chk.obj-type
             and prod-temp-chk.grp-code = temp-chk.grp-code
             and prod-temp-chk.grp-lvl  = 1       
      use-index tt no-error .
      /* запись обязательно есть: создавалась в chk-calc() по каждому продавцу, обнаруженному в chk-doc */
      if available prod-temp-chk then do:
        assign
          prod-temp-chk.qnty       = v-eff-doc-qnty /* Количество */         
          prod-temp-chk.sum-unbase = v-object-sum   /* Сумма без скидки */
          prod-temp-chk.sum-base   = v-tot-r-b      /* Сумма со скидкой */
          prod-temp-chk.pok-qnty   = v-pok-qnty     /* количество покупок*/
        .
        assign       
          prod-temp-chk.srchk-kol-tov       = prod-temp-chk.qnty       / prod-temp-chk.doc-qnty
          prod-temp-chk.srchk-sum           = prod-temp-chk.sum-unbase / prod-temp-chk.doc-qnty
          prod-temp-chk.srchk-base-sum      = prod-temp-chk.sum-base   / prod-temp-chk.doc-qnty
          prod-temp-chk.srchk-kol-tov-pokup = prod-temp-chk.pok-qnty   / prod-temp-chk.doc-qnty
        .
        assign
          prod-temp-chk.srchk-base-uch    = prod-temp-chk.sum-base   * 100 / obj-temp-chk.sum-base
          prod-temp-chk.srchk-kol-tov-uch = prod-temp-chk.pok-qnty   * 100 / obj-temp-chk.pok-qnty
          prod-temp-chk.srchk-uch         = prod-temp-chk.sum-unbase * 100 / obj-temp-chk.sum-unbase
        .
        obj-temp-chk.doc-qnty = obj-temp-chk.doc-qnty + prod-temp-chk.doc-qnty.      
      end.
    end. /* end_of last-of_grp-code */
  end. /* temp-chk */

end procedure. /* end_of prod-level */


function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.


function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character):
/* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */

    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
/*message "dbg-p-data = " p-data skip "p-accur = " p-accur view-as alert-box.*/
    p-data = round(p-data, 2). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).

    return v-str-result.

end function.
