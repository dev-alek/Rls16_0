/*

$Revision: 3cf06c882ecc, 131, rls $
$Author: DSolomko $
$Date: Thu Feb 13 13:48:38 2014 +0400 $
$Workfile: r-rnk-oss.p $
$Archive: rep/r-rnk-oss.p $



Автор: Соломко Дмитрий Владимирович
Дата создания: 18/12/13
Author: Alexey Demin
Creation date: 18/12/13
*/



using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
block-level on error undo, throw.


define variable vss-revision    as character no-undo init "$Revision: 3cf06c882ecc, 131, rls $":U .
define variable vss-author      as character no-undo init "$Author $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 13 13:48:38 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-rnk-oss.p $":U .
define variable vss-description as character no-undo init "Сверка транзакций ОСС (Кубаньнефтепродукт))".

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ str/lib-trn.i      }
{ trg/factord.i      }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-pychk0.i defalgo    }
{ rep/hva-rep-etc.i  }
{ gbl/waitfram.i     }



define variable g#report-num as integer   no-undo .

run get-report-num  in my-handle ( output g#report-num ).
def stream ListStream .
{ cmp/open-out.i stream ListStream }




  
if x-TOG-Shift then do: 
/* Выбрана галка СМЕНЫ в интерфейсе */ 
      for each obj-list
          :
          for each ub.chk-doc 
          where  ub.chk-doc.obj-type = obj-list.obj-type 
          and   ub.chk-doc.obj-code = obj-list.obj-code
          and   (ub.chk-doc.shift-date > x-Date-Start or 
          (ub.chk-doc.shift-date = x-Date-Start and ub.chk-doc.shift-num >= x-Shift-Start))
          and   (ub.chk-doc.shift-date < x-Date-End or 
          (ub.chk-doc.shift-date = x-Date-End and ub.chk-doc.shift-num <= x-Shift-End))     
               :    
               for each ub.chk-pay-attr 
                   where   ub.chk-pay-attr.doc-code = ub.chk-doc.doc-code
                   and     ub.chk-pay-attr.attr-code ="RTA_RefundExport" 
                   :
                   PUT  stream ListStream UNFORMATTED  ub.chk-pay-attr.attr-value skip .                           
                   end.                                                      
           end. 
      end.
end.
else do:
/*Не выбрана галка СМЕНЫ в интерфейсе */    
    for each obj-list
        : 
        for each ub.chk-doc 
        where  ub.chk-doc.obj-type = obj-list.obj-type 
        and   ub.chk-doc.obj-code = obj-list.obj-code
        and   ub.chk-doc.chk-date >= x-Date-Start
        and   ub.chk-doc.chk-date <= x-Date-End 
            :    
            for each ub.chk-pay-attr 
            where   ub.chk-pay-attr.doc-code = ub.chk-doc.doc-code
            and     ub.chk-pay-attr.attr-code ="RTA_RefundExport" 
                :
                PUT  stream ListStream UNFORMATTED  ub.chk-pay-attr.attr-value skip .                           
            end.                                                      
        end.                     
    end.
end.                  
                   
  


output stream ListStream close .   


define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 0 .

run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .