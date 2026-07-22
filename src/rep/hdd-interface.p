/*

$Revision: 968516208b7e, 2374, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:42 2020 +0300 $
$Workfile: hdd-interface.p $
$Archive: rep/hdd-interface.p $

Результаты проверки HDD

Автор: Шкляр Елена 
Дата создания: 08/07/14
Author: Elena Shklyar
Creation date: 08/07/14

*/

using ibs.th.str.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 968516208b7e, 2374, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:42 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: hdd-interface.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/hdd-interface.p $":U .
define variable vss-description as character no-undo init "Результаты проверки HDD".
{ cmp/vssrevis.i }

define input parameter parparentproc    as widget-handle           no-undo.
define input parameter p-namePk as character no-undo .
define input parameter p-ModelDisk as character no-undo .
define input parameter p-status as integer no-undo .
define input parameter p-ProcDisk as integer no-undo .
define input parameter p-UserDisk as integer no-undo .
define input parameter p-Date     as date no-undo .
define input parameter p-Time     as integer no-undo .
define input parameter p-Time-end as integer no-undo .
define input parameter p-db-list  as character no-undo .
define input parameter p-ValueDisk  as decimal no-undo .
define input parameter p-TreshDisk  as decimal no-undo .
define input parameter p-Delta    as decimal no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }

define temp-table tt-devicePC no-undo
  field id          as integer
  field modeldevice like ub.devisPC.modeldevice
  field ModelPC     like ub.devisPC.ModelPC
  field namepc      like ub.devisPC.namepc
  field date_       as date
  field time_       as character
  field time_int    as integer
  field ProcDisk    as decimal
  field UserProc    as decimal
  field status_     as character
  field db-num      as integer 
  index pi id date_ time_int db-num.
  
define temp-table tt-devicePCAttr no-undo
  field id        as integer
  field name_     as character
  field value_    as decimal
  field tresh     as decimal
  field type_     as character
  field raw_value as character
  field date_     as date
  field time_     as integer
  field db-num    as integer
  index pi id db-num date_ time_
  .
        
define buffer buf_devisPC      for ub.devisPC .
define buffer buf_devisPCAttr  for ub.devisPC-attr .
define buffer bf_devisPCAttr   for ub.devisPC-attr .
define buffer bt_devisPCAttr   for ub.devisPC-attr .
define buffer buf_devisPC-attr for ub.devisPC-attr .
define variable v-ProcDisk   as decimal   no-undo .
define variable v-UserDisk   as decimal   no-undo .
define variable v-TestStatus as character no-undo .
define variable v-Date       as decimal   no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id         as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable ii                  as integer   no-undo .
define variable v-TimeST            as character no-undo .
define variable v-TimeST1           as character no-undo . 
define variable v-TimeST-attr       as character no-undo .
define variable v-TimeST1-attr      as character no-undo . 
define variable v-titul             as character no-undo .   
define variable v-color             as character no-undo .

do
  on error undo, return error return-value
  :

  if p-db-list = "" then p-db-list = string(v-cntxp-db-num) .      
  do ii = 1 to num-entries (p-db-list, {&comma-char}):
    for each buf_devisPC no-lock where buf_devisPC.DB-num = integer(entry(ii, p-db-list, {&comma-char})):
      if buf_devisPC.namepc begins p-namePk and buf_devisPC.modeldevice begins p-ModelDisk then 
      do:
        next_:
        for each buf_devisPCAttr no-lock where buf_devisPCAttr.id = buf_devisPC.id and buf_devisPCAttr.db-num = buf_devisPC.db-num and buf_devisPCAttr.date >= p-Date:
          if buf_devisPCAttr.time_ < p-Time then next next_.
          if buf_devisPCAttr.time_ > p-Time-end then next next_.  
          if buf_devisPCattr.attr-code ="ProcDisk" or buf_devisPCattr.attr-code = "UserProc" or buf_devisPCattr.attr-code = "testStatus" then 
          do: 
            v-ProcDisk = 0 .
            v-UserDisk = 0 .
            v-TestStatus = "" .
            if buf_devisPCAttr.attr-code = "ProcDisk" then 
            do:
              v-ProcDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
            end.
            if buf_devisPCAttr.attr-code = "UserProc" then 
            do:
              v-UserDisk = decimal(entry(1,buf_devisPCAttr.attr-value,"%")) .
            end.  
            if buf_devisPCAttr.attr-code = "TestStatus" then 
            do:
              v-TestStatus = buf_devisPCAttr.attr-value .
            end.  
            find first tt-devicePC exclusive-lock where tt-devicePC.id = buf_devisPC.id and tt-devicePC.modeldevice = buf_devisPC.modeldevice
              and tt-devicePC.ModelPC     = buf_devisPC.ModelPC and 
              tt-devicePC.namepc      = buf_devisPC.namepc and
              tt-devicePC.date_       = buf_devisPCAttr.date and 
              tt-devicePC.db-num      = buf_devisPC.DB-num and
              tt-devicePC.time_int  = buf_devisPCAttr.time_
              no-error .
            if not available (tt-devicePC) then 
            do: 
              create tt-devicePC .
              assign
                tt-devicePC.id          = buf_devisPC.id
                tt-devicePC.modeldevice = buf_devisPC.modeldevice
                tt-devicePC.ModelPC     = buf_devisPC.ModelPC
                tt-devicePC.namepc      = buf_devisPC.namepc
                tt-devicePC.date_       = buf_devisPCAttr.date
                tt-devicePC.time_int    = buf_devisPCAttr.time_
                tt-devicePC.db-num      = buf_devisPC.DB-num
                tt-devicePC.time_       = string(truncate (buf_devisPCattr.time_ / 3600, 0)) + ":" + string((buf_devisPCattr.time_ modulo 3600) / 60,"99") + ":" + string((buf_devisPCattr.time_ modulo 3600) / 360,"99")
                .
            end.
            if v-ProcDisk <> 0 then tt-devicePC.ProcDisk    = v-ProcDisk .
            if v-UserDisk <> 0 then tt-devicePC.UserProc    = v-UserDisk .
            if v-TestStatus <> "" then tt-devicePC.status_  = v-TestStatus .
          end.
          else 
          do:
            find first tt-devicePCAttr where           tt-devicePCAttr.id        = buf_devisPCattr.id and
              tt-devicePCAttr.name_     = buf_devisPCattr.attr-code and
              tt-devicePCAttr.raw_value = buf_devisPCattr.attr-Raw-value and
              tt-devicePCAttr.tresh     = decimal(buf_devisPCattr.tresh) and
              tt-devicePCAttr.value_    = decimal(buf_devisPCattr.attr-value) and
              tt-devicePCAttr.type_     = buf_devisPCattr.type and
              tt-devicePCAttr.date_     = buf_devisPCattr.date and
              tt-devicePCAttr.db-num    = buf_devisPC.DB-num and
              tt-devicePCAttr.time_     = buf_devisPCattr.time_ no-error .
          
            if not available (tt-devicePCAttr) then 
            do:
              create tt-devicePCAttr .
              assign
                tt-devicePCAttr.id        = buf_devisPCattr.id
                tt-devicePCAttr.name_     = buf_devisPCattr.attr-code
                tt-devicePCAttr.raw_value = buf_devisPCattr.attr-Raw-value
                tt-devicePCAttr.tresh     = decimal(buf_devisPCattr.tresh)
                tt-devicePCAttr.value_    = decimal(buf_devisPCattr.attr-value)
                tt-devicePCAttr.type_     = buf_devisPCattr.type 
                tt-devicePCAttr.db-num    = buf_devisPC.DB-num
                tt-devicePCAttr.date_     = buf_devisPCattr.date
                tt-devicePCAttr.time_     = buf_devisPCattr.time_ 
                .  
            end.
          end.  
        end.
      end. 

    end.
  end.
  if p-ProcDisk > 0 then 
  do:
    for each tt-devicePC exclusive-lock where tt-devicePC.ProcDisk < p-ProcDisk:
      delete tt-devicePC .
    end.  
  end.   
  if p-UserDisk > 0 then 
  do:
    for each tt-devicePC exclusive-lock where tt-devicePC.UserProc < p-UserDisk:
      delete tt-devicePC .
    end.  
  end.  
    case p-status:
    when 0 then 
    do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Пройдена":
          delete tt-devicePC .
        end.  
    end.
    when 1 then 
      do:
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ <> "Не пройдена":
          delete tt-devicePC .
        end.  
    end.
    when 2 then do:  
        for each tt-devicePC exclusive-lock where tt-devicePC.status_ = "Пройдена" or tt-devicePC.status_ = "Не пройдена":
          delete tt-devicePC .
        end.  
      end.  
    end case .
  if p-ValueDisk > 0 then 
  do:
    for each tt-devicePCAttr where tt-devicePCAttr.value_ < p-ValueDisk:
      delete tt-devicePCAttr .
    end.  
  end.  
  if p-TreshDisk > 0 then 
  do:
    for each tt-devicePCAttr where tt-devicePCAttr.tresh < p-TreshDisk:
      delete tt-devicePCAttr .
    end.  
  end.  
  if p-Delta > 0 then 
  do:
    for each tt-devicePCAttr where abs(tt-devicePCAttr.value_ - tt-devicePCAttr.tresh) > p-Delta:
      delete tt-devicePCAttr .
    end.  
  end.  
      
  
  for each tt-devicePC:
    find first tt-devicePCAttr where tt-devicePCAttr.id = tt-devicePC.id and tt-devicePCAttr.db-num = tt-devicePC.db-num and tt-devicePCAttr.date_ = tt-devicePC.date_ and tt-devicePCAttr.time_ = tt-devicePC.time_int no-error .
    if not available (tt-devicePCAttr) then 
    do:
      if tt-devicePC.status_ = "не закончена" then do:
        create tt-devicePCAttr.
        assign
        tt-devicePCAttr.date_ = tt-devicePC.date_
        tt-devicePCAttr.time_ = tt-devicePC.time_int
        tt-devicePCAttr.db-num  = tt-devicePC.db-num
        tt-devicePCAttr.id = tt-devicePC.id
        .
      end.  
      else do:
      delete tt-devicePC .
      end.
    end.
  end.

  /*печать*/
  run get-report-num (output p-report-id).
    
  v-file-name-rep-htm = session:temp-directory + string(p-report-id) + ".html".   
           
  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
                        
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    .
                        
                        
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 80px;"></td>' skip
    '<td style="width: 170px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 50px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '<td style="width: 70px;"></td>' skip
    '</tr>' skip
    '<tr><td colspan="14" style="text-align: center;">Результаты проверки HDD</td></tr>'
    .
                        
  put stream OutStr-html unformatted
    '<TR><TD colspan="14"></TD></TR>' skip
    '</thead>' skip
    '<tbody>' skip
    .
  put stream OutStr-html unformatted
    '<TR>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">АЗК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Дата теста</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Время теста</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Имя ПК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Модель ПК</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Модель диска</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Процент заполнения</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Использование системного раздела</TD>' skip
    '<TD text_wrap="true" rowspan="2" style="text-align: center;">Статус проверки</TD>' skip
    '<TD text_wrap="true" colspan="5" style="text-align: center;">Атрибуты диска</TD>' skip
    '</TR>' skip .
    
  put stream OutStr-html unformatted  
    '<TR>' skip 
    '<TD text_wrap="true" style="text-align: center;">Название</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Value</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Thresh</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Тип</TD>' skip
    '<TD text_wrap="true" style="text-align: center;">Raw_value</TD>' skip
    '</TR>'skip       
    .
  for each tt-devicePC:
    if tt-devicePC.ProcDisk = 100 or tt-devicePC.UserProc = 100 or tt-devicePC.status_ <> "Пройдена" then v-color = "red" .
    else v-color = "white" .
    
    put stream OutStr-html unformatted
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string(tt-devicePC.db-num) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string(tt-devicePC.date_) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string(tt-devicePC.time_) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.namepc) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.ModelPC) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.modeldevice) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.ProcDisk) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.UserProc) + '</TD>' skip
      '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePC.status_) + '</TD>' skip
      .                     
    for each tt-devicePCAttr no-lock where tt-devicePCAttr.id = tt-devicePC.id and tt-devicePCAttr.db-num = tt-devicePC.db-num and tt-devicePCAttr.date_ = tt-devicePC.date_ 
    and tt-devicePCAttr.time_ = tt-devicePC.time_int break by tt-devicePCAttr.id :
      if tt-devicePCAttr.value_ <= tt-devicePCAttr.tresh then v-color = "red" .
      else v-color = "white" .   
      if first-of (tt-devicePCAttr.id ) then 
      do:      
        put stream OutStr-html unformatted
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.name_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.value_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.tresh) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.type_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.raw_value) + '</TD>' skip
          '</tr>'                          
          .
      end.
      else 
      do:
        put stream OutStr-html unformatted
          '<TR>' skip
          '<TD text_wrap="true" colspan="9" style="text-align: center;"></TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.name_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.value_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.tresh) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.type_) + '</TD>' skip
          '<TD text_wrap="true" style="text-align: center; background-color:' + v-color + ';">' + string (tt-devicePCAttr.raw_value) + '</TD>' skip
          '</tr>'                          
          .                           
      end.  
    end.  
  end.
  put stream OutStr-html unformatted
    '</tbody>' skip
    '<tfoot>' skip.
                            
  put stream OutStr-html unformatted
    '</tfoot>' skip
    '</table>' skip
    '</body>' skip
    '</html>' skip
    .
                            
  output stream OutStr-html close.     
                                                                                                                
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-htm
    ).

end.



PROCEDURE get-report-num :
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

END PROCEDURE.