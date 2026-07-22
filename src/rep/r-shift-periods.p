
/*------------------------------------------------------------------------
    File        : r-shift-periods.p
    Purpose     : 

    Syntax      :

    Description : Отчет Контроль плотности НП

    Author(s)   : SSlivenko
    Created     : Fri Mar 28 14:51:38 MSK 2025
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

define temp-table tt-shift no-undo
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
.  
  
define temp-table tt-pl-gds no-undo
  field pl-code like ub.place.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.goods.gds-code
  field gds-name like ub.goods.gds-name
.

define input parameter parparentproc    as widget-handle  no-undo .
define input parameter table for tt-shift .
define input parameter table for tt-pl-gds .

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift-periods.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift-periods.p $":U .
define variable vss-description as character no-undo init "Отчет Контроль плотности НП".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }

define temp-table tt-shift-pl-gds no-undo
  field num as integer
  field shift-date like ub.shift-period.shift-date
  field shift-num like ub.shift-period.shift-num
  field shift-name like ub.shift-obj.shift-name
  field pl-code like ub.shift-period.pl-code
  field loc1 like ub.place.loc1
  field gds-code like ub.shift-period.gds-code
  field gds-name like ub.goods.gds-name
  field num-periods as integer
.

define temp-table tt-result no-undo
  field shift-date like ub.shift-period.shift-date
  field shift-num like ub.shift-period.shift-num
  field pl-code like ub.shift-period.pl-code
  field gds-code like ub.shift-period.gds-code
  field period-num like ub.shift-period.period-num
  field period-name like ub.shift-period.period-name
  field sales-density15 like ub.shift-period.sales-density15
  field control-density like ub.shift-period.control-density
  field delta-density like ub.shift-period.delta-density
.

function fDec2Str returns character
  (input idec as decimal,
   input iformat as char)
:
  define variable vdecstr as character no-undo.
  if idec = ? then
     vdecstr = "".
  else
     vdecstr = trim(string(idec, iformat)).

  return vdecstr.
end function .

define stream sOutStr-html.
define buffer buf_shift-period for ub.shift-period .

/* ***************************  Main Block  *************************** */
{ gbl/getcntxt.i get }

run fillTT .

run PrintRep .

procedure fillTT :
  define variable v-num as integer no-undo init 0 .
  
  for each tt-shift no-lock by tt-shift.shift-date by tt-shift.shift-num :
    for each buf_shift-period no-lock where buf_shift-period.shift-date = tt-shift.shift-date
                                        and buf_shift-period.shift-num = tt-shift.shift-num
    :
      find first tt-pl-gds no-lock where tt-pl-gds.pl-code = buf_shift-period.pl-code
                                     and tt-pl-gds.gds-code = buf_shift-period.gds-code
                                     no-error .
      if not available tt-pl-gds
      then next .
      
      find first tt-shift-pl-gds where tt-shift-pl-gds.shift-date = buf_shift-period.shift-date
                                   and tt-shift-pl-gds.shift-num  = buf_shift-period.shift-num
                                   and tt-shift-pl-gds.pl-code    = buf_shift-period.pl-code
                                   and tt-shift-pl-gds.gds-code   = buf_shift-period.gds-code
                                   no-error .
      if not available tt-shift-pl-gds
      then do :
        create tt-shift-pl-gds .
        assign
          v-num = v-num + 1
          tt-shift-pl-gds.num        = v-num
          tt-shift-pl-gds.shift-date = buf_shift-period.shift-date
          tt-shift-pl-gds.shift-num  = buf_shift-period.shift-num
          tt-shift-pl-gds.shift-name = tt-shift.shift-name
          tt-shift-pl-gds.pl-code    = buf_shift-period.pl-code
          tt-shift-pl-gds.loc1       = tt-pl-gds.loc1
          tt-shift-pl-gds.gds-code   = buf_shift-period.gds-code
          tt-shift-pl-gds.gds-name   = tt-pl-gds.gds-name
          tt-shift-pl-gds.num-periods = 0
        .
      end .
      assign tt-shift-pl-gds.num-periods = tt-shift-pl-gds.num-periods + 1 .
      
      create tt-result .
      assign
        tt-result.shift-date      = tt-shift-pl-gds.shift-date
        tt-result.shift-num       = tt-shift-pl-gds.shift-num
        tt-result.pl-code         = tt-shift-pl-gds.pl-code
        tt-result.gds-code        = tt-shift-pl-gds.gds-code
        tt-result.period-num      = buf_shift-period.period-num
        tt-result.period-name     = buf_shift-period.period-name
        tt-result.sales-density15 = buf_shift-period.sales-density15
        tt-result.control-density = buf_shift-period.control-density
        tt-result.delta-density   = buf_shift-period.delta-density
      .
      
    end .
  end .
end procedure .

procedure PrintRep :
  define variable vReportId     as character no-undo.
  define variable vFileNameRep  as character no-undo.
  define variable vStr          as character no-undo.
  define variable vI            as integer   no-undo.
  
  define variable v-period      as character no-undo .
  define variable v-firm-name   as character no-undo .
  define variable v-obj-name    as character no-undo .
  define variable v-print-date  as character no-undo .
  
  define variable v-today as date    no-undo .
  define variable v-time  as integer no-undo .
  
  define buffer buf_clients for ub.clients .

  do on error undo, return error return-value:
    run get-report-num(output vReportId).
    vFileNameRep = session:temp-directory + string(vReportId) + ".html".
    
    v-period = "Смены: " .
    
    for each tt-shift by tt-shift.shift-date by tt-shift.shift-num :
      v-period = v-period + string(tt-shift.shift-num) + " (" + tt-shift.shift-name + ") от " + string(tt-shift.shift-date, "99.99.9999") + ", " .
    end .
    v-period = trim(v-period, ", ") .
    
    find first buf_clients no-lock where buf_clients.obj-type = {&cmp}
                                     and buf_clients.obj-code = v-cntxt-host-code-obj
                                     no-error .
    if available buf_clients
    then do :
      v-firm-name = buf_clients.obj-name .
    end .
    
    find first buf_clients no-lock where buf_clients.obj-type = v-cntxt-obj-type
                                     and buf_clients.obj-code = v-cntxt-obj-code
                                     no-error .
    if available buf_clients
    then do :
      v-obj-name = "Выбор объекта: " + buf_clients.obj-name .
    end .
    
    run cur-time in this-procedure (
      output v-today
      , output v-time
      ).
    v-print-date = "Дата печати: " + string (v-today,"99.99.9999") + ", время: " + string(truncate (v-time / 3600, 0)) + ":" + string((v-time modulo 3600) / 60,"99")  + ":" + string((v-time modulo 3600) / 360,"99").     
    

    output stream sOutStr-html to value(vFileNameRep) convert target 'UTF-8'.
    put stream sOutStr-html unformatted
      { rep/htmlhead.i }
    .
    
    put stream sOutStr-html unformatted
      '<body>' skip
      '<TABLE name="1" outline_below="true" fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">' skip
      '<thead>' skip
      '<TR class="set_columns">' skip
        '<TD style="width:  70px;"></TD>' skip            /*  1    */
        '<TD style="width:  70px;"></TD>' skip            /*  2    */
        '<TD style="width:  70px;"></TD>' skip            /*  3    */
        '<TD style="width:  90px;"></TD>' skip            /*  4    */
        '<TD style="width:  80px;"></TD>' skip            /*  5    */
        '<TD style="width: 180px;"></TD>' skip            /*  6    */
        '<TD style="width: 140px;"></TD>' skip            /*  7    */
        '<TD style="width: 140px;"></TD>' skip            /*  8    */
        '<TD style="width: 140px;"></TD>' skip            /*  9    */
      '</TR>' skip
    .
    
    put stream sOutStr-html unformatted
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + 'Отчёт Контроль плотности НП' + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-period + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-firm-name + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-obj-name + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + v-print-date + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9">&nbsp;</TD>' skip
      '</TR>' skip
    .
    put stream sOutStr-html unformatted
      '<TR>' skip
        '<TD colspan="9" style="font-weight: bold;">' + 'Примечания к отчёту:' + '</TD>'skip
      '</TR>' skip
      '<TR>' skip
        '<TD colspan="9">' + 'В отчет выводятся отклонения плотности НП за период по каждому резервуару НП.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Отклонение рассчитывается при сравнении значения P_реализ15 с P_контр.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Расхождение значения по плотности НП не должно превышать 1,7 кг/м3 между значением P_реализ15 по сравнению с P_контр.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Расхождение значения по плотности НП 1,7 кг/м3 для отчета конвертировано в 0,0017 г/см3.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Чеки, сформированные во время прихода НП, не учитываются ни в одном из периодов.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'Для сообщающихся резервуаров НП в отчет выводится только «Главный» резервуар.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'При учете чеков реализации НП задним числом (включение в закрытую смену), данные этих чеков не оказывают влияние на расчет значений НП по периодам и формирование отчета.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">&nbsp;</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'P_реализ15 - плотность реализации НП, приведенная к 15 С, за период в представленной смене.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">' + 'P_контр - контрольная плотность НП в резервуаре за период в представленной смене.' + '</TD>' skip
      '</TR>'skip
      '<TR>' skip
        '<TD colspan="9">&nbsp;</TD>' skip
      '</TR>'skip
      
      '</thead>' skip
    .
    
    put stream sOutStr-html unformatted
      '<tbody>' skip
      '<TR>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">№ п/п</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Дата смены</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Порядок и номер смены</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">№ Резервуара</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Наименование топлива</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Период в смене</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Плотность реализации НП за период, г/см3 (приведенная к 15 С)</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Контрольная плотность НП за период, г/см3 (приведенная к 15 С)</TH>' skip
      '<TH text_wrap="true" rowspan="5" style="text-align: center; font-weight: bold; background-color: silver;">Отклонение по плотности НП за период, г/см3 (1.9 = 1.7 – 1.8)</TH>' skip
      '</TR>' skip 
      
      '<TR >'skip
      '</TR>'skip
      
      '<TR >'skip
      '</TR>'skip
      
      '<TR >'skip
      '</TR>'skip
      
      '<TR >'skip
      '</TR>'skip
      
      '<TR >'skip
      '<TH style="text-align: center; font-weight:bold; ">1.1</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.2</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.3</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.4</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.5</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.6</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.7</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.8</TH>'   skip
      '<TH style="text-align: center; font-weight:bold; ">1.9</TH>'   skip
      '</TR>'skip    
    .
    
    for each tt-shift-pl-gds by tt-shift-pl-gds.num :
      put stream sOutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.num) + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.shift-date, "99.99.9999") + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.shift-num) + " (" + tt-shift-pl-gds.shift-name + ")" + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.loc1) + '</TD>' skip
        '<TD text_wrap="true" rowspan="' + string(tt-shift-pl-gds.num-periods) + '" style="text-align: center;">' + string(tt-shift-pl-gds.gds-name) + '</TD>' skip
      .
      for each tt-result where tt-result.shift-date = tt-shift-pl-gds.shift-date
                           and tt-result.shift-num  = tt-shift-pl-gds.shift-num
                           and tt-result.pl-code    = tt-shift-pl-gds.pl-code
                           and tt-result.gds-code   = tt-shift-pl-gds.gds-code
                           break by tt-result.pl-code by tt-result.gds-code
                           by tt-result.period-num
      :
        if not (first-of(tt-result.pl-code) and first-of(tt-result.gds-code))
        then do :
          put stream sOutStr-html unformatted
            '<TR>' skip
          .
        end .
        put stream sOutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center;">' + string(tt-result.period-name) + '</TD>' skip
          '<TD num="#,####0.0000" val="' + fDec2Str(tt-result.sales-density15, "-9.9999") + '" text_wrap="true" style="text-align: center;">' + fDec2Str(tt-result.sales-density15, "-9.9999") + '</TD>' skip
          '<TD num="#,####0.0000" val="' + fDec2Str(tt-result.control-density, "-9.9999") + '" text_wrap="true" style="text-align: center;">' + fDec2Str(tt-result.control-density, "-9.9999") + '</TD>' skip
          '<TD num="#,####0.0000" val="' + fDec2Str(tt-result.delta-density, "-9.9999") + '" text_wrap="true" style="text-align: center; color: ' + (if abs(tt-result.delta-density) > 0.0017 then "red" else "black") + ';">' + fDec2Str(tt-result.delta-density, "-9.9999") + '</TD>' skip
          '</TR>' skip.
        .
      end .
    end .
    
    put stream sOutStr-html unformatted
      '</tbody>' skip
      '</table>' skip
      '</body>' skip
      '</html>' skip
    .
                              
    output stream sOutStr-html close. 
    
    run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input vFileNameRep
    ).

  end .
end procedure .

procedure get-report-num :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

end procedure .