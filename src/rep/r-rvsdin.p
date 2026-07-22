block-level on error undo, throw.
/*

$Revision: f90014024f0a, 3393, rls $
$Author: ARostovtsev $
$Date: 2023/06/07 13:19:21 $
$Workfile: r-rvsdin.p $
$Archive: rep/r-rvsdin.p $

Отчет Динамика показаний уровнемера

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/15/10
Author: Dmitry Ukhanov
Creation date: 07/15/10

*/

define variable vss-revision    as character no-undo init "$Revision: f90014024f0a, 3393, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/06/07 13:19:21 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-rvsdin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rvsdin.p $":U .
define variable vss-description as character no-undo init "Отчет Динамика показаний уровнемера".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ trg/factord.i  }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
  define stream Out-Stream.
  define stream OutStr-html.

  define VARIABLE p-report-id         as character no-undo .
  define variable v-file-name-rep-htm as character no-undo .
  define VARIABLE v-attr-value        as character no-undo .
  define variable v-obj-type          as character no-undo .
  define variable v-obj-code          as integer   no-undo .

  define variable v-gds-count as integer no-undo .
  define variable v-pl-count  as integer no-undo .
  
  define buffer buf_shift-obj for ub.shift-obj .
  define buffer buf_rvs-doc   for ub.rvs-doc .
  define buffer buf_rvs-line  for ub.rvs-line .
  define buffer buf_goods     for ub.goods .

  define variable g#report-num as integer   no-undo .

  define variable last-fo      as decimal   no-undo init 0.
  define variable prev-fo      as decimal   no-undo init 0.
  
  define variable ii           as integer   no-undo .
  
  define variable v-rvs-type   as character no-undo .
  define variable v-rvs-count  as integer   no-undo .
  define variable v-max-count  as integer   no-undo .
  define variable v-ind        as integer   no-undo .

  define temp-table tt_places no-undo
    field rvs-count as integer
    field rvs-code  like ub.rvs-line.rvs-code
    field gds-code  like ub.rvs-line.gds-code
    field gds-name  like ub.goods.gds-name
    field pl-code   like ub.rvs-line.pl-code
    field qnty      like ub.rvs-line.measure-qnty
    field level     like ub.rvs-line.level-petrol
    field density   like ub.rvs-line.density
    field temp      like ub.rvs-line.temperature
    index pi is unique primary rvs-code gds-code pl-code
    index gds-pl               gds-code pl-code
    index gds-pl-c             rvs-code gds-code rvs-count
    .
  
  define temp-table tt_shapka no-undo
    field pl-code  like ub.rvs-line.pl-code
    field gds-code like ub.rvs-line.gds-code
    field gds-name like ub.goods.gds-name
    field ii       as integer
    index pi is unique primary pl-code gds-code ii
    .
  
  define temp-table tt_goods no-undo
    field gds-code  like ub.rvs-line.gds-code
    field gds-name  like ub.goods.gds-name
    field col-count as integer
    .
  
  define buffer buf_tt_places for tt_places .
  define buffer bf_tt_places  for tt_places .
  define buffer buf_tt_shapka for tt_shapka .
  
  
  define stream out-stream.

  for each tt_places
    :
    delete tt_places.
  end.

  /* только текущий объект */
  find first obj-list no-lock
    no-error .
  if not available obj-list then 
  do:
    message
      "Не определен объект для формирования отчета"
      view-as alert-box information .
    return error.
  end.

  find first gds-list no-lock
    no-error .
  if not available gds-list then 
  do:
    message
      "Не определен товар для формирования отчета"
      view-as alert-box information .
    return error.
  end.

  run get-report-num in my-handle
    ( output g#report-num
    ).

  { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

/*  run factord-max-fact-order in this-procedure        */
/*    ( output last-fo ).                               */
/*                                                      */
/*  find first buf_shift-obj share-lock                 */
/*    where buf_shift-obj.obj-type   = obj-list.obj-type*/
/*    and buf_shift-obj.obj-code   = obj-list.obj-code  */
/*    and buf_shift-obj.shift-date = x-date-end         */
/*    and buf_shift-obj.shift-num  <= x-shift-end       */
/*    no-error.                                         */
/*  if available buf_shift-obj then                     */
/*  do:                                                 */
/*    if buf_shift-obj.status_  = {&sht-closed} then    */
/*    do:                                               */
/*      assign                                          */
/*        last-fo = buf_shift-obj.fact-order            */
/*        .                                             */
/*    end.                                              */
/*  end.                                                */
/*  else do:                                            */
/*  find last buf_shift-obj share-lock                  */
/*    where buf_shift-obj.obj-type   = obj-list.obj-type*/
/*    and buf_shift-obj.obj-code   = obj-list.obj-code  */
/*    and buf_shift-obj.shift-date < x-date-end         */
/*/*    and buf_shift-obj.shift-num  = x-shift-end*/    */
/*    no-error.                                         */
/*  if available buf_shift-obj then                     */
/*  do:                                                 */
/*    if buf_shift-obj.status_  = {&sht-closed} then    */
/*    do:                                               */
/*      assign                                          */
/*        last-fo = buf_shift-obj.fact-order            */
/*        .                                             */
/*    end.                                              */
/*  end.                                                */
/*  end.                                                */
/*                                                      */
/*  find last buf_shift-obj share-lock                  */
/*    where buf_shift-obj.obj-type = obj-list.obj-type  */
/*    and buf_shift-obj.obj-code = obj-list.obj-code    */
/*    and buf_shift-obj.status_  = {&sht-closed}        */
/*    and ( ( buf_shift-obj.shift-date = x-date-start   */
/*    and buf_shift-obj.shift-num < x-shift-start       */
/*    )                                                 */
/*    or buf_shift-obj.shift-date < x-date-start        */
/*    )                                                 */
/*    use-index pi no-error.                            */
/*  if available buf_shift-obj then                     */
/*  do:                                                 */
/*    assign                                            */
/*      prev-fo = buf_shift-obj.fact-order              */
/*      .                                               */
/*  end.                                                */
empty temp-table tt_goods .
empty temp-table tt_places .
empty temp-table tt_shapka .

   for each gds-list no-lock:
      for each buf_rvs-doc no-lock
         where buf_rvs-doc.obj-type   =  obj-list.obj-type
         and buf_rvs-doc.obj-code   =  obj-list.obj-code
         and buf_rvs-doc.status_    =  {&fact}
         and buf_rvs-doc.shift-date >=  x-date-start
         and buf_rvs-doc.shift-date <= x-date-end:
         if buf_rvs-doc.shift-date = x-date-Start and buf_rvs-doc.shift-num < x-Shift-Start then next .
         if buf_rvs-doc.shift-date = x-date-End   and buf_rvs-doc.shift-num > x-Shift-End then next .
      
         for each buf_rvs-line no-lock
            where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
            and buf_rvs-line.gds-code = gds-list.gds-code,
            first buf_goods no-lock where buf_goods.gds-code = buf_rvs-line.gds-code
            break by buf_rvs-doc.fact-order by buf_rvs-line.gds-code by buf_rvs-line.pl-code
            :
            find first tt_places no-lock
               where tt_places.rvs-code = buf_rvs-line.rvs-code
               and tt_places.gds-code = buf_rvs-line.gds-code
               and tt_places.pl-code  = buf_rvs-line.pl-code
               no-error .
            if not available tt_places then 
            do:
               create tt_places .
               assign
                  tt_places.rvs-code = buf_rvs-line.rvs-code
                  tt_places.gds-code = buf_rvs-line.gds-code
                  tt_places.gds-name = buf_goods.gds-name
                  tt_places.pl-code  = buf_rvs-line.pl-code
                  tt_places.qnty     = buf_rvs-line.measure-qnty
                  tt_places.level    = buf_rvs-line.level-petrol
                  tt_places.density  = buf_rvs-line.density
                  tt_places.temp     = buf_rvs-line.temperature     
                  .
            end.
         end.
      end.
   end.

  for each tt_places by tt_places.gds-code:
    find first tt_shapka where tt_shapka.pl-code = tt_places.pl-code no-error .
    if not AVAILABLE tt_shapka then 
    do:
      
      v-gds-count = v-gds-count + 1 .
      create tt_shapka .
      assign
        tt_shapka.pl-code  = tt_places.pl-code 
        tt_shapka.gds-code = tt_places.gds-code
        tt_shapka.gds-name = tt_places.gds-name
        tt_shapka.ii       = v-gds-count
        .
    end.  
  end.     
    
  for each tt_shapka break by tt_shapka.ii:
    if last-of(tt_shapka.ii) then 
    do:
      v-max-count = tt_shapka.ii .
    end.   
  end.  
  
  /*печать*/
  run get-report-num (output p-report-id).
    
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
                        
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
{ rep/htmlhead.i }
    .
                        
  put stream OutStr-html unformatted
    '<body>' skip
    /*Первая таблица*/
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .      
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 64px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
      
    .
  do ii = 1 to v-max-count :
    put stream OutStr-html unformatted
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 80px;"></td>' skip
      .
  end.  
  put stream OutStr-html unformatted
    '</tr>' skip 
    '</thead>' skip
    '<tbody>' skip  .
  
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td rowspan="2" style="width: 64px;">Дата</td>' skip
    '<td rowspan="2" style="width: 64px;">Время</td>' skip
    '<td text_wrap="true" rowspan="2" style="width: 80px;">Номер сверки</td>' skip
    '<td text_wrap="true" rowspan="2" style="width: 80px;">Тип сверки</td>' skip
    .
    
  for each tt_shapka break by tt_shapka.ii
    :
    v-pl-count = 0.
    for each buf_tt_shapka where buf_tt_shapka.gds-code = tt_shapka.gds-code:
      v-pl-count = v-pl-count + 4 .
      find FIRST tt_goods where tt_goods.gds-code = tt_shapka.gds-code no-error .
      if not AVAILABLE (tt_goods) then 
      do:
        create tt_goods .
        assign
          tt_goods.gds-code  = tt_shapka.gds-code 
          tt_goods.gds-name  = tt_shapka.gds-name
          tt_goods.col-count = v-pl-count
          .
      end.
      else tt_goods.col-count = v-pl-count .
    end.
  end.

  for each tt_goods :
    put stream OutStr-html unformatted
      '<td colspan="' + string(tt_goods.col-count) + '" style="width: 64px; text-align: center;">' + tt_goods.gds-name + " " + string(tt_goods.gds-code) + '</td>' skip
      .   
  end. 

  put stream OutStr-html unformatted
    '</tr>' skip   
    '<tr>' skip .
  
  for each tt_shapka break by tt_shapka.ii :
    put stream OutStr-html unformatted
      '<td text_wrap="true" style="width: 64px;">Уровень. ' + string(tt_shapka.pl-code) + '</td>' skip
      '<td text_wrap="true" style="width: 64px;">Объем. ' + string(tt_shapka.pl-code) + '</td>' skip
      '<td text_wrap="true" style="width: 64px;">Температура. ' + string(tt_shapka.pl-code) + '</td>' skip
      '<td text_wrap="true" style="width: 64px;">Плотность. ' + string(tt_shapka.pl-code) + '</td>' skip
      .
  end.
  put stream OutStr-html unformatted
    '</tr>' skip .  

  /* for each gds-list no-lock:*/
  for each buf_rvs-doc no-lock
    where buf_rvs-doc.obj-type   =  obj-list.obj-type
    and buf_rvs-doc.obj-code   =  obj-list.obj-code
    and buf_rvs-doc.status_    =  {&fact}
    and buf_rvs-doc.shift-date >=  x-date-Start
    and buf_rvs-doc.shift-date <= x-date-End
   :
         if buf_rvs-doc.shift-date = x-date-Start and buf_rvs-doc.shift-num < x-Shift-Start then next .
         if buf_rvs-doc.shift-date = x-date-End   and buf_rvs-doc.shift-num > x-Shift-End then next .
    case buf_rvs-doc.rvs-type:
      when {&rvs-after-doc} then 
        do:
          assign
            v-rvs-type = "после приема"
            .
        end.
      when {&rvs-before-doc} then 
        do:
          assign
            v-rvs-type = "до приема"
            .
        end.
      when {&rvs-shift} then 
        do:
          assign
            v-rvs-type = "смена"
            .
        end.
      when {&rvs-control} then 
        do:
          assign
            v-rvs-type = "контроль"
            .
          if buf_rvs-doc.is-full = true then 
          do:
            assign
              v-rvs-type = substitute( "&1 (п)", v-rvs-type )
              .
          end.
        end.
    end case.


    put stream OutStr-html unformatted
      '<tr>' skip
      '<td style="width: 64px;">' + string(buf_rvs-doc.fact-date, "99/99/99") + '</td>' skip
      '<td style="width: 64px;">' + string( buf_rvs-doc.fact-time, "HH:MM:SS" ) + '</td>' skip
      '<td style="width: 64px;">' + buf_rvs-doc.rvs-code + '</td>' skip
      '<td text_wrap="true" style="width: 64px;">' + v-rvs-type + '</td>' skip
      .
    for each tt_shapka no-lock break by tt_shapka.ii:
      find first tt_places no-lock where tt_places.rvs-code = buf_rvs-doc.rvs-code and tt_places.pl-code = tt_shapka.pl-code no-error .

      if AVAILABLE (tt_places) then 
      do:
        put stream OutStr-html unformatted
          '<td num="0.000" val="' + fnc-convert-dot-to-colon(tt_places.level,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt_places.level,"->>>>>>>>>>>9.999",3) + '</TD>' skip
          '<td num="0.000" val="' + fnc-convert-dot-to-colon(tt_places.qnty,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt_places.qnty,"->>>>>>>>>>>9.999",3) + '</TD>' skip
          '<td num="0.000" val="' + fnc-convert-dot-to-colon(tt_places.temp,"->>>>>>>>>>>9.999",3) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt_places.temp,"->>>>>>>>>>>9.999",3) + '</TD>' skip
          '<td num="0.0000" val="' + fnc-convert-dot-to-colon(tt_places.density,"->>>>>>>>>>>9.9999",4) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt_places.density,"->>>>>>>>>>>9.9999",4) + '</TD>' skip
          .
      end.
      else 
      do:

        put stream OutStr-html unformatted
          '<td num="0.000" style="text-align: right;"></TD>' skip
          '<td num="0.000" style="text-align: right;"></TD>' skip
          '<td num="0" style="text-align: right;"></TD>' skip
          '<td num="0.0000" style="text-align: right;"></TD>' skip
          .
      end.

    end.
    put stream OutStr-html unformatted
      '</tr>' skip .  
  end. /*for each buf_rvs-doc no-lock*/

  for each tt_places
    :
    delete tt_places.
  end.
  
  put stream OutStr-html unformatted
    '</tbody>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.     

    run prn-lib-reportviewer in this-procedure (
        input this-procedure
        ,input v-file-name-rep-htm
        ,input "" 
        ) no-error.
    if error-status:error then
    do:
        message return-value view-as alert-box.
        return .
    end.
      
end.

PROCEDURE get-report-num :

    define output parameter p-report-num as integer no-undo .

    do
        on error undo, return error return-value
        :
        run gbl/getrpnum.p (output p-report-num).
    end.

END PROCEDURE.