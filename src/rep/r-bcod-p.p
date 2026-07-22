block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bcod-p.p $
$Archive: rep/r-bcod-p.p $

Баркод производитея к документу по перемещению товара

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

do
on error undo, return error
:
  define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
  define input parameter rec_id            as recid        no-undo .

  def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
  def var vss-author      as character no-undo init "$Author: expertek $":U .
  def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
  def var vss-workfile    as character no-undo init "$Workfile: r-bcod-p.p $":U .
  def var vss-archive     as character no-undo init "$Archive: rep/r-bcod-p.p $":U .
  def var vss-description as character no-undo init "Баркод производителя  к документу по перемещению товара".
  
  { cmp/vssrevis.i }
  { cmp/str-glbl.i  }
  { cmp/library.i  }
  { cmp/r-pril.i   }
  { gbl/cur-time.i }
  { rep/r-cost.i }
  { rep/r-sale.i }
  { gbl/paramls.i }

  /* для товаров */
  define temp-table tt-rec no-undo
    field id as int
    field code as int
    field artic as char
    field prod-name as char
    field prod-grp as char
    field unit as char
    field price as dec
    field count as dec
    field cost as dec
    field bcodes-by-prod as char
  .
  
  /* для шкал */
  define temp-table tt-rec-scale no-undo like tt-rec
    field rec-id as int
  .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#log as logical   no-undo .

  { rep/r-bcod-pxl.i }

  define buffer buf_clients  for clients.
  define buffer buf_trn-doc  for trn-doc .
  define buffer buf_doc-line for doc-line .
  define buffer buf_gds-dtl  for gds-dtl .
  define buffer buf_goods    for goods .

  def shared var sort-gr      as logical no-undo.
  def shared var sort-name    as logical no-undo.
  def shared var CostPrice    as logical no-undo.
  def shared var print-graft  as logical no-undo. /* вроде сортировка по артикулу */

  def var sym1  as char init ":"   no-undo.
  def var sym2  as char init ":"   no-undo.
  def var sym3  as char init ":"   no-undo.
  def var sym4  as char init ":"   no-undo.
  def var sym5  as char init ":"   no-undo.
  def var sym6  as char init ":"   no-undo.
  def var sym7  as char init ":"   no-undo.
  def var sym8  as char init ":"   no-undo.
  def var sym9  as char init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.

  def var v-doc-num          like trn-doc.doc-code     no-undo.
  def var v-doc-date         like trn-doc.doc-date    no-undo.
  def var v-single-line      as char      no-undo.
  def var v-obj-name         as char      no-undo.
  def var v-cli-name         as char      no-undo.
  def var v-income           as logical   no-undo.  /* yes - приход */
  def var num                as integer   no-undo .
  def var id                 as integer   no-undo .
  def var b-code             as integer   no-undo .
  def var artic              as character no-undo .
  def var gds-name           as character no-undo .
  def var unit-base          as character no-undo .
  def var zen1               as decimal   no-undo .
  def var qnty               as decimal   no-undo .
  def var sqnty              as character no-undo .
  def var sum1               as decimal   no-undo .
  def var list-b-code        as character no-undo .
  define variable v-root-node as integer   no-undo .
  define variable empty-scale as logical   no-undo .
  define variable all-qnty    as decimal   no-undo format "->>>>>9.<<<".
  define variable all-sum     as decimal   no-undo .
  define variable is-new      as logical   no-undo .
  define variable kg-flag     as logical   no-undo . /* если встречается хотя-бы один товар с единицами КГ, то выводить с тройной точностью */

  def var qh as handle no-undo. /* хэндл запроса */
  def var qstr as char no-undo init "FOR EACH tt-rec ". /* строка запроса */
  def var prev-grp as char no-undo. /* для разбиения по группам, не работает нормально break by через такой способ */

  function get-formated-count returns char (p-unit as char, p-count as dec) forward.

  run r-bcod-pxl-init.

  find first buf_trn-doc no-lock  where recid(buf_trn-doc) = rec_id .

  find first buf_clients no-lock
    where buf_clients.obj-type = buf_trn-doc.obj-type
      and buf_clients.obj-code = buf_trn-doc.obj-code
    .
  assign  v-obj-name = string(buf_clients.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ") ") .
  find first buf_clients no-lock
    where buf_clients.obj-type = buf_trn-doc.cli-type
      and buf_clients.obj-code = buf_trn-doc.cli-code
    no-error .
  if available buf_clients then assign v-cli-name = string(buf_clients.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ") ") .
  else assign v-cli-name = "" .

  def stream AktStr .

  define frame Akt
        sym1              column-label ":!:"                               format "X(1)"
        num               column-label "N !п/п"                            format ">>>9"
        sym2              column-label ":!:"                               format "X(1)"
        b-code            column-label "Код ! "                            format ">>>>>>>>9"
        sym3              column-label ":!:"                               format "X(1)"
        artic             column-label " Артикул! "                        format "X(16)"
        sym4              column-label ":!:"                               format "X(1)"
        gds-name          column-label "Название товара! "                 format "X(56)"
        sym5              column-label ":!:"                               format "X(1)"
        unit-base         column-label "Ед.!изм"                           format "X(4)"
        sym6              column-label ":!:"                               format "X(1)"
        zen1              column-label "Цена за ед.!"                      format "->>>>>>>9.99"
        sym7              column-label ":!:"                               format "X(1)"
        sqnty             column-label "Количество!"                       format "X(11)" /* "->>>>>9.<<<" */ 
        sym8              column-label ":!:"                               format "X(1)"
        sum1              column-label "Стоимость!()!"                     format "->>>>>9.99"
        sym9              column-label ":!:"                               format "X(1)"
        list-b-code       column-label "        БАР-КОДЫ по товару!"       format "X(40)"
        sym10             column-label ":!:"                               format "X(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Накладная с баркодами производителя " ) at 50 format "X(40)" v-doc-num format "X(10)" " от " v-doc-date format "99/99/9999"
        string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9" ) ) at 160 format "X(13)" skip
        v-single-line format "X(190)" at 1
    with width {&DOS_CW} down stream-io use-text .

  if PrintRubl then do:
    assign
      zen1:label  = "Цена ({&abbr_rub_allshift})"
/*      sum1:label  = "Стоимость ({&abbr_rub_allshift})"*/
    .
    define frame Akt
    sum1              column-label "Стоимость!({&abbr_rub_allshift})" format "->>>>>9.99".
  end.
  else do:
    assign
      zen1:label  = "Цена (Б.Вал)"
      /*sum1:label  = "Стоимость (Б.Вал)"*/
    .
    define frame Akt
    sum1              column-label "Стоимость!(Б.Вал)" format "->>>>>9.99".
  end.

  { gbl/working.i }

  assign
    v-doc-num  = buf_trn-doc.doc-code
    v-doc-date = buf_trn-doc.doc-date
    v-single-line = fill("-", 234)
    v-income = ( if buf_trn-doc.doc-type = {&income} or buf_trn-doc.doc-type = {&return} then yes else no )
    num = 0
  .

  { cmp/open-out.i stream AktStr " " {&LS_PS_A4}}

  put stream AktStr space(25) string( "Накладная с баркодами производителя N " + v-doc-num + " от " + string(v-doc-date,"99/99/9999") ) format "x(190)"    skip(1) .

  put stream AktStr space(5) "Отправитель : " (if v-income = yes then v-cli-name else v-obj-name )    format "X(60)"  skip
                    space(5) "Покупатель  : " (if v-income = yes then v-obj-name else v-cli-name )    format "X(60)"  skip(2)
                    space(5) "Примечание  : " (if not( buf_trn-doc.PS BEGinS "@" ) then buf_trn-doc.PS else "")     format "X(160)"  skip
                    .

  form header
            v-single-line format "X(190)" at 1 skip
            "Продолжение - на следующей странице" at 30 skip
            with frame Bottomframe width {&DOS_CW_2} page-bottom no-labels no-box .
  view stream aktstr frame bottomframe .


/*======================== Шапка сформирована ==========================*/

/*---S-------  Строки для документа --------------*/

 /* загоняем все во временную таблицу для экономии кода */
  for each buf_doc-line no-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
    , first buf_goods no-lock
      where buf_goods.artic      = buf_doc-line.artic
        and buf_goods.prod-type  = buf_doc-line.prod-type
        and buf_goods.prod-code  = buf_doc-line.prod-code
        :
    run create-line.
  end.
  
  /*
   Создаем запрос т.к. если использовать обычный foreach, то придется много запросов однообразных писать.
   А тут просто дописываем в строчку по чему сортировать и получиться быстрее и меньше
  */
   
  /* стандартная сортировка, если не поставлена не одна галочка сортировки */
  if not sort-gr and not sort-name and not print-graft then
    qstr = qstr + "by code".
    
  if sort-name then
    qstr = qstr + "by prod-name ".
  if sort-gr then
    qstr = qstr + "by prod-grp ".
  if print-graft then
    qstr = qstr + "by artic ".
    
  /* создаем запрос и настраиваем */
  create query qh.
  qh:SET-BUFFERS(buffer tt-rec:handle).
  qh:QUERY-PREPARE(qstr).
  qh:QUERY-OPEN ().
  
  /* проходим в цикле по результату, указатели на записи выставляются у буферов, которые мы добавили при настройки запроса */
  repeat:
      qh:GET-NEXT ().
      if qh:QUERY-OFF-END then leave.
      /* если включена сортировка по группам и начинается новая, то пишем заголовок у каждой новой группы */
      if sort-gr and prev-grp <> tt-rec.prod-grp then do:
        run print-grp.
        prev-grp = tt-rec.prod-grp.
      end.
      run write-line.
      
  end.
    
  delete object qh.

  /*---S------- Выводим Итого для таблицы ---------------*/
  put stream aktstr v-single-line format "X(190)" skip.

  display stream aktstr
    sym1   "ИТОГО"  @ gds-name
    sym7   get-formated-count((if kg-flag then "кг" else ""), all-qnty) @ sqnty
    sym8   all-sum  @ sum1
    sym9
    sym10
  with frame Akt .
  down stream aktstr with frame akt .

  put stream aktstr v-single-line format "X(190)" skip.

  hide stream AktStr frame Bottomframe .
  output stream AktStr close.

  run write-excel-vars.
  run r-bcod-pxl-close.

  { gbl/stopwork.i }

  { rep/q-print.i 8}

end.

function get-formated-count returns char (p-unit as char, p-count as dec):
    def var retval as char no-undo.
    if p-unit = "кг" then
        retval = string(p-count, "->>>>>9.999").
    else
        retval = string(p-count, "->>>>>>>>>9").
    
    return retval.
end.

/* получаем линию с баркодами, но вмещаем сколько указывается по длине */
function get-bcode returns char(input-output num as int, len as int, bcodes as char):
    def var nums as int no-undo.
    def var i as int no-undo.
    def var str as char no-undo.
    def var tempstr as char no-undo.
    def var fflag as logical no-undo init true.

    nums = num-entries(bcodes).
    if num = -1 then return "".

    do i = num to nums:
        tempstr = str + (if not fflag then ", " else "") + entry(i, bcodes).
        fflag = false.
        
        if length(tempstr) <= len then do:
            str = tempstr.
        end.
        else do:
            if i = nums then
                num = -1.
            else
                num = i.
            return str.
        end.
    end.
    
    num = -1.
    return str.
end.

procedure write-line :
  def var bcode-ind as int no-undo init 1. /* текущий индекс дополнительного бар-кода */  
  def var bcodes as char no-undo.
  def var bcode as char no-undo.
  
  find first tt-rec-scale where tt-rec-scale.rec-id = tt-rec.id no-error.

  /* пишем товар без шкал */
  if not avail tt-rec-scale then do:      
      num = num + 1.
      bcodes = tt-rec.bcodes-by-prod.
      tt-rec.bcodes-by-prod = get-bcode(input-output bcode-ind, 40, bcodes).
      
      disp stream aktstr
        sym1
        num @ num
        sym2
        tt-rec.code @ b-code
        sym3
        tt-rec.artic @ artic
        sym4
        tt-rec.prod-name @ gds-name
        sym5
        tt-rec.unit @ unit-base
        sym6
        tt-rec.price @ zen1
        sym7
        get-formated-count(tt-rec.unit, tt-rec.count) @ sqnty
        sym8
        tt-rec.cost @ sum1
        sym9
        tt-rec.bcodes-by-prod @ list-b-code
        sym10
      with frame akt.      
      down stream aktstr with frame akt .
           
      run r-bcod-pxl-write-line-data(
        {&r-bcod-pxl-excel-out-type-normal},
        num,
        tt-rec.code,
        tt-rec.artic,
        tt-rec.prod-name,
        tt-rec.unit,
        tt-rec.price,
        get-formated-count(tt-rec.unit, tt-rec.count),
        tt-rec.cost,
        tt-rec.bcodes-by-prod
      ).
      
      do while true:
          bcode = get-bcode(input-output bcode-ind, 40, bcodes).
          if bcode = "" then leave.
          
          disp stream aktstr
          sym9        
          bcode @ list-b-code
          sym10
          with frame akt.      
          down stream aktstr with frame akt .
          
          run r-bcod-pxl-write-line-data(
            {&r-bcod-pxl-excel-out-type-bcode},
            0,
            0,
            "",
            "",
            "",
            0,
            0,
            0,
            bcode
          ).
      end.
  end.  
  else do:
    /* товар со шкалами */
    disp stream aktstr
        sym1
        sym2  tt-rec.code @ b-code
        sym3  tt-rec.artic @ artic
        sym4  tt-rec.prod-name @ gds-name
        sym5  tt-rec.unit @ unit-base
        sym6
        sym7
        sym8
        sym9
        sym10
    with frame akt.    
    down stream aktstr with frame akt .
    
    run r-bcod-pxl-write-line-data(
      {&r-bcod-pxl-excel-out-type-scale-head},
      -1,
      tt-rec.code,
      tt-rec.artic,
      tt-rec.prod-name,
      tt-rec.unit,
      -1,
      -1,
      -1,
      ""
    ).
  end.
    
  if avail tt-rec-scale then do:
      
      for each tt-rec-scale
        where tt-rec-scale.rec-id = tt-rec.id
          by tt-rec-scale.bcode:
                  
        num = num + 1.
        bcode-ind = 1.
        bcodes = tt-rec-scale.bcodes-by-prod.
        tt-rec-scale.bcodes-by-prod = get-bcode(input-output bcode-ind, 40, bcodes).
        
        display stream aktstr
            sym1  num @ num
            sym2  tt-rec-scale.code @ b-code
            sym3
            sym4  tt-rec-scale.prod-name  @ gds-name
            sym5
            sym6  tt-rec-scale.price @ zen1
            sym7  get-formated-count(tt-rec.unit, tt-rec-scale.count) @ sqnty
            sym8  tt-rec-scale.cost @ sum1
            sym9  tt-rec-scale.bcodes-by-prod  @ list-b-code
            sym10
        with frame akt.
        down stream aktstr with frame akt .
        
        run r-bcod-pxl-write-line-data(
          {&r-bcod-pxl-excel-out-type-scale-line},
          num,
          tt-rec-scale.code,
          "",
          tt-rec-scale.prod-name,
          "",
          tt-rec-scale.price,
          get-formated-count(tt-rec.unit, tt-rec-scale.count),
          tt-rec-scale.cost,
          tt-rec-scale.bcodes-by-prod
        ).
        
      do while true:
          bcode = get-bcode(input-output bcode-ind, 40, bcodes).
          if bcode = "" then leave.
          
          disp stream aktstr
          sym9        
          bcode @ list-b-code
          sym10
          with frame akt.      
          down stream aktstr with frame akt .
          
          run r-bcod-pxl-write-line-data(
            {&r-bcod-pxl-excel-out-type-bcode},
            0,
            0,
            "",
            "",
            "",
            0,
            0,
            0,
            bcode
          ).
      end.
    end.
  end.
end.

procedure create-line :
  do
  on error undo, return error return-value
  :
    define variable new-list as character no-undo .

    { gbl/gdsbcode.i  buf_goods.gds-code  ?  b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
      undo, return error .
    end.

    { gbl/rootnode.i   buf_goods.artic   buf_goods.prod-type   buf_goods.prod-code  v-root-node }
    { gbl/prtat.i v-root-node  "'empty-scale=request'"  empty-scale }

    define variable v1-sum-rubl as decimal   no-undo .
    define variable v1-sum-base as decimal   no-undo .
    define variable v2-sum-rubl as decimal   no-undo .
    define variable v2-sum-base as decimal   no-undo .
    define variable tmp         as decimal   no-undo .

    run r-cost in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic , input buf_doc-line.prod-type
                                   , input buf_doc-line.prod-code  , output tmp     , output tmp    , output tmp
                                   , output v1-sum-base      , output v1-sum-rubl   , output tmp    , output tmp
                                   , output tmp   , output tmp   , output tmp       , output tmp    , output tmp
                                   , output tmp   , output tmp   , output tmp       , output tmp    , output tmp ).
    run r-sale in this-procedure ( input buf_doc-line.doc-code   , input buf_doc-line.artic   , input buf_doc-line.prod-type
                                   , input buf_doc-line.prod-code  , output tmp     , output tmp    , output tmp
                                   , output v2-sum-base      , output v2-sum-rubl   , output tmp    , output tmp
                                   , output tmp      , output tmp   , output tmp    , output tmp    , output tmp
                                   , output tmp      , output tmp   , output tmp    , output tmp    , output tmp ).


    if CostPrice then do:
      if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
         buf_doc-line.ext-doc-type = {&TDEDT_Pri_Prvo}  or buf_doc-line.ext-doc-type = {&TDEDT_Spi_Prvo} then do:
        if PrintRubl then assign zen1 = v2-sum-rubl / buf_doc-line.fact-qnty .
        else                     zen1 = v2-sum-base / buf_doc-line.fact-qnty .
      end.
      else do:
        if PrintRubl then assign zen1 = v1-sum-rubl / buf_doc-line.fact-qnty .
        else                     zen1 = v1-sum-base / buf_doc-line.fact-qnty .
      end.
    end.
    else do:
      if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
         buf_doc-line.ext-doc-type = {&TDEDT_Pri_Prvo}  or buf_doc-line.ext-doc-type = {&TDEDT_Spi_Prvo} then do:
        if PrintRubl then assign zen1 = v1-sum-rubl / buf_doc-line.fact-qnty .
        else                     zen1 = v1-sum-base / buf_doc-line.fact-qnty .
      end.
      else do:
        if PrintRubl then assign zen1 = v2-sum-rubl / buf_doc-line.fact-qnty .
        else                     zen1 = v2-sum-base / buf_doc-line.fact-qnty .
      end.
    end.

    if zen1 < 0 then assign zen1 = - zen1 .

    id = id + 1.
    create tt-rec.
    tt-rec.id = id.
      
    if buf_goods.unit-base = "кг" then
      kg-flag = true.

    if empty-scale then do:
      assign
        all-qnty = all-qnty + buf_doc-line.fact-qnty
        all-sum  = all-sum  + buf_doc-line.fact-qnty * zen1
      .
        
      run b-code-lst in this-procedure .

      id = id + 1.
      assign
        tt-rec.id = id
        tt-rec.code = b-code
        tt-rec.artic = buf_goods.artic
        tt-rec.prod-name = buf_goods.gds-name
        tt-rec.prod-grp = buf_goods.grp-name
        tt-rec.unit = buf_goods.unit-base
        tt-rec.price = zen1
        tt-rec.count = buf_doc-line.fact-qnty
        tt-rec.cost = (buf_doc-line.fact-qnty * zen1)
        tt-rec.bcodes-by-prod = list-b-code
      .
    end.
    else do:
      
      assign
        tt-rec.code = b-code
        tt-rec.artic = buf_goods.artic
        tt-rec.prod-name = buf_goods.gds-name
        tt-rec.prod-grp = buf_goods.grp-name
        tt-rec.unit = buf_goods.unit-base
      .
    end.

    if empty-scale = no then do: /* шкала */
      for each buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
        :
        { gbl/gdsbcode.i  buf_goods.gds-code  buf_gds-dtl.prt-code  b-code  no-error }
        if error-status :error then do:
          message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" buf_goods.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
          view-as alert-box error .
          undo, return error .
        end.

        if CostPrice then do:
          if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
            buf_doc-line.ext-doc-type = {&TDEDT_Pri_Prvo}  or buf_doc-line.ext-doc-type = {&TDEDT_Spi_Prvo} then do:
            if PrintRubl then assign zen1 = buf_gds-dtl.price-rubl .
            else                     zen1 = buf_gds-dtl.price-base .
          end.
        end.
        else do:
          if buf_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
             buf_doc-line.ext-doc-type = {&TDEDT_Pri_Prvo}  or buf_doc-line.ext-doc-type = {&TDEDT_Spi_Prvo} then do:
          end.
          else do:
            if PrintRubl then assign zen1 = buf_gds-dtl.price-rubl .
            else                     zen1 = buf_gds-dtl.price-base .
          end.
        end.
/*        if PrintRubl then assign zen1 = buf_gds-dtl.price-rubl .*/
/*        else                     zen1 = buf_gds-dtl.price-base .*/

        run b-code-lst in this-procedure .

        find first gds-prt where gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .

        assign
          all-qnty = all-qnty + buf_gds-dtl.fact-qnty
          all-sum  = all-sum  + buf_gds-dtl.fact-qnty * zen1
        .
  
        create tt-rec-scale.
        assign
            tt-rec-scale.rec-id = tt-rec.id
            tt-rec-scale.code = b-code
            tt-rec-scale.prod-name = ('  '+ gds-prt.f-name)
            tt-rec-scale.prod-grp = buf_goods.grp-name
            tt-rec-scale.price = zen1
            tt-rec-scale.count = buf_gds-dtl.fact-qnty
            tt-rec-scale.cost = (buf_gds-dtl.fact-qnty * zen1)
            tt-rec-scale.bcodes-by-prod = list-b-code
        .
      end.
    end.

  end.
end procedure. /* print-line */

procedure print-grp :
  do
  on error undo, return error return-value
  :
    def var grp-name as char no-undo.
    grp-name = "    " + tt-rec.prod-grp.
    
    display stream aktstr
      sym1
      grp-name @ gds-name
      sym10
    with frame Akt .
    down stream aktstr with frame akt .
    run r-bcod-pxl-write-line-data(
      {&r-bcod-pxl-excel-out-type-group},
      -1,
      -1,
      "",
      grp-name,
      "",
      -1,
      -1,
      -1,
      ""
    ).
  end.
end procedure. /* print-grp */

procedure write-excel-vars:
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .

    run cur-time in this-procedure
      (output v-date
      ,output v-time
    ).
    
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_sender},
        (if v-income = yes then v-cli-name else v-obj-name )
    ).
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_buyer},
        (if v-income = yes then v-obj-name else v-cli-name )
    ).
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_note},
        (if not( buf_trn-doc.PS BEGinS "@" ) then buf_trn-doc.PS else "")
    ).
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_count},
        get-formated-count((if kg-flag then "кг" else ""), all-qnty)
    ).
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_cost},
        string(all-sum)
    ).
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_head_info},
        string(v-doc-num, "X(10)") + " от " + string(v-doc-date, "99/99/9999")
    ).
    run r-bcod-pxl-write-cell-data(
        {&r-bcod-pxl-h_date_print},
        (string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U))
    ).
end.

procedure b-code-lst :
  do
  on error undo, return error return-value
  :
      assign
        is-new = yes
        list-b-code = ""
      .
      for each prod-bc no-lock where prod-bc.b-code = b-code :
        if is-new then do:
          assign is-new = no .
          if prod-bc.bc-on then assign list-b-code = "* " + prod-bc.b-str .
          else assign list-b-code = prod-bc.b-str .
        end.
        else do:
          if prod-bc.bc-on then assign list-b-code = list-b-code + "," +  "* " + prod-bc.b-str .
          else assign list-b-code = list-b-code + "," + prod-bc.b-str .
        end.
        if length(list-b-code) > 30000 then do:
          message vss-workfile vss-revision vss-description skip "Слишком много баркодов производителя! Список будет выводиться неполностью." skip  "Код товара " buf_goods.gds-code " Артикул товара " buf_goods.artic skip
          view-as alert-box error .
          leave.
        end.
      end.
  end.
end procedure. /* b-code-lst */
