block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthrd.p $
$Archive: rep/r-wthrd.p $

Реестр документов движения серийных МЦ

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/22/06
Author: Michael Kochetkov
Creation date: 03/22/06

*/

define input parameter p-rs-wth-pl       as integer   no-undo .
define input parameter p-wth-pl-list     as character no-undo .
define input parameter p-doc-type-list   as character no-undo .
define input parameter p-rs-date         as integer   no-undo .
define input parameter p-is-detal        as logical   no-undo .
define input parameter is-range          as logical   no-undo .
define input parameter p-dtFrom          as date      no-undo.
define input parameter p-DtEnd           as date      no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthrd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthrd.p $":U .
define variable vss-description as character no-undo init "Реестр документов движения серийных МЦ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ str/wthcalib.i  }

do on error undo, return error :

  DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
  ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).


{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

{ rep/f-fdec.i }   /* Функции для форматирования полей для передачи в EXcel         */
{ gbl/paramls.i }
{ rep/mcrexcel.i }

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .


  DEFINE temp-table temp-nom no-undo
    field   name     as character
    field   code     as integer
    field   wth-code as integer
    field   wth-name as character
    field   sum          as decimal     /*эти поля для подсчета итоговых сумм по номиналам*/
    field   qnty         as decimal
    INDEX pi  IS PRIMARY   wth-code code
  .

  DEFINE temp-table temp-nom-doc no-undo
    field   sum          as decimal
    field   qnty         as decimal
    field   code         as integer
    field   wth-code     as integer
    field   doc-code     as character
    INDEX pi  IS PRIMARY   doc-code code wth-code
    INDEX pi1              code wth-code
  .


DEFINE temp-table temp-doc no-undo
    field   sum          as decimal
    field   qnty         as decimal
    field   dat          as date
    field   dat-sf       as character
    field   num-sf       as character
    field   doc-code     as character
    field   cli-name     as character
    field   doc-type     as character
    INDEX pi  IS PRIMARY   doc-code
    INDEX pi1              doc-type
  .

  define variable ii as integer initial 0  no-undo .
  define variable Counter1               as integer   no-undo .
  define variable num-line               as integer   no-undo .
  define variable str-doc-type           as character no-undo .
  define variable str                    as character no-undo .

  define variable v-sum        as decimal   no-undo .
  define variable v-qnty       as decimal   no-undo .

  define variable v-doc-code  as character no-undo .
  define variable v-doc-date  as character no-undo .
  define variable v-attr-type as character no-undo .

  define variable ed-wth-pl as char no-undo.
  define variable v-i        as integer      no-undo.
  define variable v-dat-sf   as date      no-undo.

  assign  Counter1 = 0 .
  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */


  define buffer buf_clients  for ub.clients .
  define buffer buf_wth-doc  for ub.wth-doc .
  define buffer buf_wth-line for ub.wth-line .
  define buffer buf_wth-dtl  for ub.wth-dtl .
  define buffer buf_wealth   for ub.wealth .
  define buffer buf_wth-place for ub.wth-place .
  define buffer buf_wth-par  for ub.wth-par .
  define buffer buf_wth-doc-attr for ub.wth-doc-attr.
  define buffer buf_wth-parts  for ub.wth-parts .

  define variable is-cli as logical   no-undo .
  find first G#CUSTOMER no-error .
  if not available G#CUSTOMER then do: /* все поставщики  */
    assign is-cli = no .
  end.
  else do:
    assign is-cli = yes .
  end.


  if p-rs-date = 1 then do: /* выборка по фактической дате */
    for each buf_wth-doc no-lock
      where buf_wth-doc.host-code = v-cntxt-host-code-obj
        and buf_wth-doc.fact-date >= x-date-start
        and buf_wth-doc.fact-date <= x-date-end
        and buf_wth-doc.status_ = {&fact}
      :
      run FillTemp in this-procedure .
    end.
  end.
  else do: /* по дате счета-фактуры */
    do ii = 0 to (x-date-end - x-date-start)  :
      assign str = string(x-date-start + ii,"99/99/9999") .
      for each buf_wth-doc-attr no-lock where buf_wth-doc-attr.attr-code =  {&wthcattr-dsf}  and buf_wth-doc-attr.attr-value = str :
        find first buf_wth-doc no-lock where buf_wth-doc.doc-code = buf_wth-doc-attr.doc-code .
        run FillTemp in this-procedure .
      end.
      assign str = string(x-date-start + ii,"99/99/99") .
      for each buf_wth-doc-attr no-lock where buf_wth-doc-attr.attr-code = {&wthcattr-dsf}  and buf_wth-doc-attr.attr-value = str :
        find first buf_wth-doc no-lock where buf_wth-doc.doc-code = buf_wth-doc-attr.doc-code .
        run FillTemp in this-procedure .
      end.

    end.
  end.

  { gbl/working.i }

  /* macr_excel - для экселя */
  assign
    make-excel = yes
    v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .

  assign num-line = 1 .

  for each temp-doc break by temp-doc.doc-type :
    if first-of(temp-doc.doc-type) then do:
      assign
        str-doc-type = entry( lookup ( temp-doc.doc-type , {&WDEDT_List} ), {&WDEDT_List-full} )
        v-sum  = 0
        v-qnty = 0
      .
      for each temp-nom :
        temp-nom.qnty = 0.
        temp-nom.sum = 0.
      end.
      run macr_excel_char (str-doc-type, v-row, 1) .
      assign v-row = v-row + 1 .
    end.
    run is-page in this-procedure .

    assign v-col =  1 .

    run macr_excel_char ( string(num-line), v-row, v-col) .       assign v-col = v-col + 1 .
    run macr_excel_date ( temp-doc.dat - date(1, 1, 1900) + 2, v-row, v-col) .   assign v-col = v-col + 1 .
    run macr_excel_char ( temp-doc.doc-code, v-row, v-col) .      assign v-col = v-col + 1 .
    if  temp-doc.dat-sf > '':U then do:
      v-dat-sf = date(temp-doc.dat-sf) no-error.
      if v-dat-sf = ? then do:
        run macr_excel_char ( temp-doc.dat-sf, v-row, v-col) .        assign v-col = v-col + 1 .
      end.
      else do:
        run macr_excel_date ( v-dat-sf - date(1, 1, 1900) + 2, v-row, v-col) .   assign v-col = v-col + 1 .
      end.
    end.
    else do:
        assign v-col = v-col + 1 .
    end.
    run macr_excel_char ( temp-doc.num-sf, v-row, v-col) .        assign v-col = v-col + 1 .
    run macr_excel_char ( temp-doc.cli-name, v-row, v-col) .      assign v-col = v-col + 1 .
    if p-is-detal then do:
      for each temp-nom :
        find first temp-nom-doc
          where temp-nom-doc.doc-code = temp-doc.doc-code
            and temp-nom-doc.wth-code = temp-nom.wth-code
            and temp-nom-doc.code     = temp-nom.code
        no-error .
        if available temp-nom-doc then do:
          run macr_excel_sum  ( temp-nom-doc.qnty, v-row, v-col, 3) .       assign v-col = v-col + 1 .
          run macr_excel_sum  ( temp-nom-doc.sum,  v-row, v-col, 2) .       assign v-col = v-col + 1 .
          temp-nom.qnty = temp-nom.qnty +  temp-nom-doc.qnty.
          temp-nom.sum = temp-nom.sum +  temp-nom-doc.sum.
        end.
        else do:
          run macr_excel_sum  ( 0, v-row, v-col, 3) .       assign v-col = v-col + 1 .
          run macr_excel_sum  ( 0, v-row, v-col, 2) .       assign v-col = v-col + 1 .
        end.
      end.
    end.
    run macr_excel_sum  ( temp-doc.qnty, v-row, v-col, 3) .       assign v-col = v-col + 1 .
    run macr_excel_sum  ( temp-doc.sum,  v-row, v-col, 2) .
    assign
      v-qnty = v-qnty + temp-doc.qnty
      v-sum  = v-sum  + temp-doc.sum
      num-line = num-line + 1
      v-row = v-row + 1
    .

    if last-of(temp-doc.doc-type)  then do:
      run macr_excel_char ( string("Итого по " + str-doc-type), v-row, 1) .
      v-col = 7.
      if p-is-detal then do:
         for each temp-nom :
          run macr_excel_sum  ( temp-nom.qnty, v-row, v-col, 3) .       assign v-col = v-col + 1 .
          run macr_excel_sum  ( temp-nom.sum,  v-row, v-col, 2) .       assign v-col = v-col + 1 .
         end.
      end.
      assign v-col = v-col + 1 .
      run macr_excel_sum  ( v-qnty, v-row, v-col - 1, 3) .
      run macr_excel_sum  ( v-sum,  v-row, v-col, 2) .
      assign v-row = v-row + 1 .
    end.
  end.

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexcel.p (v-file-name ).
end.



procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    assign
      v-row = 1
      v-col = 1
    .

    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-cntxt-host-code-obj no-error .
    run macr_excel_char ( buf_clients.obj-name , v-row, 1) .
    assign v-row = v-row + 1 .

    run macr_excel_char ("Реестр документов движения серийных МЦ", v-row, 2) .
    run macr_cell_format ( 11, yes, no, ?, v-row, 2, v-row, 2) .
    assign v-row = v-row + 1 .

    run macr_excel_char ("За период с " + string(x-date-start,"99/99/9999") + " по " + string(x-date-end,"99/99/9999"), v-row, 1) .
    assign v-row = v-row + 1 .
    ed-wth-pl = '':U.
    if p-rs-wth-pl = 2 then do v-i = 1 to num-entries(p-wth-pl-list) :
      find first buf_wth-place where RECID(buf_wth-place) = integer( entry( v-i, p-wth-pl-list, {&comma-char} ) ) no-lock no-error .
      if available buf_wth-place then do:
        assign
          ed-wth-pl = (if ed-wth-pl > "" then ed-wth-pl + ',':U else "":U ) + buf_wth-place.w-p-name
      .
      end.
    end.
    if length(ed-wth-pl) >= 200 then ed-wth-pl = substring(ed-wth-pl,1,200) + '...'.
    run macr_excel_char ("Места хранения: " + if p-rs-wth-pl = 1 then "ВСЕ" else ed-wth-pl , v-row, 1) .
    assign v-row = v-row + 1 .

    if is-cli = no then do:
      run macr_excel_char ("Котрагенты: ВСЕ", v-row, 1) .
    end.
    else do:
      define variable c-name as character no-undo .
      assign c-name = "" .
      for each G#CUSTOMER :
        if c-name = "" then assign c-name = G#CUSTOMER.obj-name .
        else                assign c-name = c-name + ", " + G#CUSTOMER.obj-name .
      end.
      if length(c-name) >= 200 then c-name = substring(c-name,1,200) + '...'.
      run macr_excel_char ("Котрагенты: " + c-name, v-row, 1) .
    end.
    assign v-row = v-row + 1 .
    if is-range then do:
     run macr_excel_char ( substitute("Диапазон начала срока годности  &1 - &2",p-dtFrom,p-DtEnd), v-row, 1).
     assign v-row = v-row + 1 .
    end.
    run macr_excel_char ("№ п.п.", v-row, v-col) .
    run macr_cell_size (10,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Дата вып.", v-row, v-col) .
    run macr_cell_size (12,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("№ док-та", v-row, v-col) .
    run macr_cell_size (12,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Дата сч.-ф.", v-row, v-col) .
    run macr_cell_size (12,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("№ сч.-ф.", v-row, v-col) .
    run macr_cell_size (12,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    run macr_excel_char ("Контрагент", v-row, v-col) .
    run macr_cell_size (40,?, v-row, v-col, ?, ?).              assign v-col = v-col + 1 .
    if p-is-detal then do:
      for each temp-nom :
        run macr_excel_char (string(temp-nom.wth-name + " " + temp-nom.name), v-row, v-col) .
        run macr_cell_merge ( v-row, v-col, v-row, v-col + 1) .
        run macr_excel_char ("Кол-во", v-row + 1, v-col) .
        run macr_cell_size (16,?, v-row , v-col, ?, ?).          assign v-col = v-col + 1 .
        run macr_excel_char ("Сумма", v-row + 1, v-col) .
        run macr_cell_size (16,?, v-row , v-col, ?, ?).          assign v-col = v-col + 1 .
      end.
    end.
    run macr_excel_char ("Итого", v-row, v-col) .
    run macr_excel_char ("Кол-во", v-row + 1, v-col) .
    run macr_cell_size (16,?, v-row + 1, v-col, ?, ?).          assign v-col = v-col + 1 .
    run macr_excel_char ("Сумма", v-row + 1, v-col) .
    run macr_cell_size (16,?, v-row + 1, v-col, ?, ?).

    run macr_cell_bordur ( v-row, 1, v-row + 1, v-col) .
    run macr_cell_format ( 10, yes, no, 35, v-row + 1, 1, v-row, v-col) .
/*    do ii = 1 to 5 :*/
/*      run macr_cell_merge ( v-row , ii, v-row + 1 , ii ) .*/
/*    end.*/
    do ii = 6 to v-col - 1 :
      run macr_cell_merge ( v-row , ii, v-row , ii + 1 ) .
      assign ii = ii + 1 .
    end.

    assign
      v-row = v-row + 2
      v-col = 1
    .
  end.
end procedure. /* PutColumnTitulExcel */


procedure is-page :
  do
  on error undo, return error return-value
  :
    if  ( v-row ) >= 63000 then do:
      Output stream Macr_Excel  close .
      run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name ) .
      run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
      output stream  Macr_Excel to value(v-file-name) .
      assign
        v-ind = v-ind + 1
        v-row = 2
      .
      run PutColumnTitulExcel in this-procedure .
    end.
  end.
end procedure. /* is-page */



procedure FillTemp :
  do on error undo, return error return-value :

    /* проверяем контрагента */
    if is-cli then do:
      find first G#CUSTOMER where G#CUSTOMER.obj-type = buf_wth-doc.cli-type and G#CUSTOMER.obj-code = buf_wth-doc.cli-code no-error .
      if not available G#CUSTOMER then return .
    end.
    /* проверяем тип док-та */
    if lookup( buf_wth-doc.ext-doc-type , p-doc-type-list) = 0  then return .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    define variable v-sum  as decimal   no-undo .
    define variable v-qnty as decimal   no-undo .
    assign
      v-sum  = 0
      v-qnty = 0
    .

    for each buf_wth-line no-lock where buf_wth-line.doc-code = buf_wth-doc.doc-code :
      /* проверяем места хранения */
      if p-rs-wth-pl = 2 then do:
        find first buf_wth-place no-lock where buf_wth-place.host-code = buf_wth-doc.host-code
                                           and buf_wth-place.obj-type = buf_wth-doc.obj-type
                                           and  buf_wth-place.obj-code = buf_wth-doc.obj-code
                                           and  buf_wth-place.w-p-code = buf_wth-line.w-p-code
                                           no-error .
        if not available buf_wth-place or lookup( string(recid(buf_wth-place)) , p-wth-pl-list) = 0  then next .
      end.

      /* проверяем серийность */
      find first buf_wealth no-lock where buf_wealth.wth-code = buf_wth-line.wth-code .
      if buf_wealth.is-ser = 0 then next .
      /*Если проверка по сроку годности, то сцммы заполняем потом по партиям*/
      if  not is-range then assign
        v-sum  = v-sum  + buf_wth-line.sum-gds-rubl
        v-qnty = v-qnty + buf_wth-line.fact-sum
      .
      if p-is-detal and ( buf_wth-line.sum-gds-rubl <> 0 or buf_wth-line.fact-sum <> 0 ) then do: /* нужна детализация по номиналам */
        for each buf_wth-dtl no-lock
          where buf_wth-dtl.doc-code = buf_wth-line.doc-code
            and buf_wth-dtl.wth-code = buf_wth-line.wth-code
            and buf_wth-dtl.w-p-code = buf_wth-line.w-p-code
        :
          find first temp-nom-doc
            where temp-nom-doc.doc-code = buf_wth-doc.doc-code
              and temp-nom-doc.code     = buf_wth-dtl.par-code
              and temp-nom-doc.wth-code = buf_wth-dtl.wth-code
          no-error .
          if not available temp-nom-doc then do:
            create temp-nom-doc .
            assign
              temp-nom-doc.code     = buf_wth-dtl.par-code
              temp-nom-doc.wth-code = buf_wth-dtl.wth-code
              temp-nom-doc.doc-code = buf_wth-doc.doc-code
            .
          end.
          if  not is-range then assign
            temp-nom-doc.sum  = temp-nom-doc.sum  + buf_wth-dtl.sum-gds-rubl
            temp-nom-doc.qnty = temp-nom-doc.qnty + buf_wth-dtl.fact-sum
          .
        end.
      end.
      for each buf_wth-parts no-lock  where  buf_wth-parts.out-code = buf_wth-doc.doc-code
                                        and  buf_wth-parts.wth-code = buf_wth-line.wth-code
                                        and buf_wth-parts.w-p-code = buf_wth-line.w-p-code:
        if buf_wth-parts.beg-dt >= p-dtFrom and buf_wth-parts.beg-dt <= p-dtEnd then do:  /*начало срока годности попадатет в указанный период*/
          assign
             v-sum  = v-sum  + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
             v-qnty = v-qnty + buf_wth-parts.fact-qnty.
          find first temp-nom-doc
            where temp-nom-doc.doc-code = buf_wth-doc.doc-code
              and temp-nom-doc.code     = buf_wth-parts.par-code
              and temp-nom-doc.wth-code = buf_wth-parts.wth-code
          no-error.
          if available temp-nom-doc then do:
          assign
            temp-nom-doc.sum  = temp-nom-doc.sum  + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
            temp-nom-doc.qnty = temp-nom-doc.qnty + buf_wth-parts.fact-qnty .
          end.
        end.
      end.  /*each parts*/
    end.
    if v-sum <> 0 or v-qnty <> 0 then do: /* добавлям документ */
      find first buf_clients no-lock where buf_clients.obj-type = buf_wth-doc.cli-type and buf_clients.obj-code = buf_wth-doc.cli-code no-error .

      create temp-doc .
      assign
        temp-doc.doc-code = buf_wth-doc.doc-code
       /* temp-doc.dat      = buf_wth-doc.doc-date    */
        temp-doc.dat      = buf_wth-doc.fact-date
        temp-doc.doc-type = buf_wth-doc.ext-doc-type
        temp-doc.cli-name = buf_clients.obj-name
        temp-doc.sum      = v-sum
        temp-doc.qnty     = v-qnty
      .
      { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-nsf}   temp-doc.num-sf  v-attr-type }
      { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-dsf}   temp-doc.dat-sf  v-attr-type }
      /* проверяем список номиналов */
      if p-is-detal then do:
        for each temp-nom-doc where temp-nom-doc.doc-code = buf_wth-doc.doc-code :
          find first temp-nom where temp-nom.code = temp-nom-doc.code and temp-nom.wth-code = temp-nom-doc.wth-code  no-error .
          if not available temp-nom then do:
            find first buf_wth-par no-lock where buf_wth-par.wth-code = temp-nom-doc.wth-code and buf_wth-par.par-code = temp-nom-doc.code .
            find first buf_wealth no-lock where buf_wealth.wth-code = temp-nom-doc.wth-code .
            create temp-nom .
            assign
              temp-nom.code     = temp-nom-doc.code
              temp-nom.wth-code = temp-nom-doc.wth-code
              temp-nom.name     = substitute("&1 &2",buf_wth-par.par-val, buf_wth-par.par-unit)
              temp-nom.wth-name = buf_wealth.wth-name
            .
          end.
        end.
      end.
    end.
  end.
end procedure. /* FillTemp */