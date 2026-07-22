block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: checknakl.p $
$Archive: str/checknakl.p $

Проверка незакрытых накладных

Автор: Шкляр Елена
Дата создания: 10/06/06
Author: Elena Shklyar
Creation date: 10/06/06



*/
using ibs.th.str.utd.sts.*.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-silent  as logical         no-undo .
define input parameter p-obj-type   as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-shift-date as date no-undo .
define input parameter p-shift-num like ub.shift-obj.shift-num no-undo .
define input parameter p-shift-name like ub.shift-obj.shift-name no-undo .
define output parameter p-cancel    as logical no-undo initial true.


define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: checknakl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/checknakl.p $":U .
define variable vss-description as character no-undo initial "Проверка незакрытых накладных":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-calc.i }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ ref/gds-attr.i }
{ gbl/prn-lib.i     }
{ rep/html-conv.i }
{ str/is-sug.i }
{ str/trdcalib.i }
{ str/placelib.i }

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }

define variable v-host-name as character no-undo .
define variable p-host-code as integer   no-undo .
define variable v-doc-num   as character no-undo .
define stream Out-Stream.
define stream OutStr-html.
define VARIABLE p-report-id          as character no-undo .
define variable v-file-name-rep-htm  as character no-undo .

define variable v-value-character    as character no-undo .
define variable v-value-date         as date      no-undo .
define variable v-value-integer      as integer   no-undo .
define variable v-value-logical      as logical   no-undo .
define variable v-param-type         as character no-undo .
define variable v-tth                as handle    no-undo .
define variable jj                   as integer   no-undo .
define variable v-date-end           as date      no-undo .
define variable v-mes                as character no-undo .
define variable v-DocumenNumber      as character no-undo .
define variable v-DocumenNumber-fact as character no-undo .
define variable v-file-name          as character no-undo .
define variable v-doc-code           as character no-undo .
  
{ gbl/objsrv.i }

v-date-end = p-shift-date - 35 .

define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_utd      for ub.utd .
define buffer buf_doc-attr for ub.doc-attr .
define buffer bf_doc-attr  for ub.doc-attr .

for each buf_utd exclusive-lock where buf_utd.obj-code = p-obj-code 
   and buf_utd.obj-type = p-obj-type
   and buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB
   and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB
   and buf_utd.DocumentDate <= p-shift-date
   and buf_utd.DocumentDate >= v-date-end:
   if buf_utd.doc-code = "" then 
   do: 
      run schet-factur(input buf_utd.DocumentNumber, 
                       input buf_utd.DocumentDate, 
                       output v-doc-code) no-error .
      if v-doc-code <> "" then buf_utd.doc-code = v-doc-code .
      else 
      do:
         if v-DocumenNumber = "" then v-DocumenNumber = buf_utd.DocumentNumber .
         else v-DocumenNumber = v-DocumenNumber + "; " + buf_utd.DocumentNumber .
      end.
   end. 
   else 
   do:
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_utd.doc-code no-error .
      if not available (buf_trn-doc) then 
      do:
         run schet-factur(input buf_utd.DocumentNumber, 
                          input buf_utd.DocumentDate, 
                          output v-doc-code) no-error.
         if v-doc-code <> "" then buf_utd.doc-code = v-doc-code .
         else 
         do:
            if v-DocumenNumber = "" then v-DocumenNumber = buf_utd.DocumentNumber .
            else v-DocumenNumber = v-DocumenNumber + "; " + buf_utd.DocumentNumber .
         end.   
      end.
      else 
      do:   
         find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_utd.doc-code 
            and buf_trn-doc.status_ = {&fact} no-error .
         if not available (buf_trn-doc) then 
         do:
               if v-DocumenNumber-fact = "" then v-DocumenNumber-fact = buf_utd.DocumentNumber .
               else v-DocumenNumber-fact = v-DocumenNumber-fact + "; " + buf_utd.DocumentNumber .     
         end.    
      end.
   end.    
end.

if v-DocumenNumber <> "" or v-DocumenNumber-fact <> "" then 
do:
   if v-DocumenNumber <> "" and v-DocumenNumber-fact <> "" then 
   do:
      message "Через ЭДО получен(ы) закрытый(е) УПД " skip
         "" skip
         v-DocumenNumber + "," skip
         "Необходимо создать по УПД накладную(ые) и закрыть до статуса Факт." skip
         "" skip
         v-DocumenNumber-fact + "," skip
         "Накладную(ые) нужно закрыть до статуса Факт." skip
         "" skip
         "Продолжить закрытие смены?" skip
         view-as alert-box question buttons yes-no update p-cancel.
      v-mes = "Через ЭДО получен(ы) закрытый(е) УПД " + {&new-line} + {&new-line} +
         v-DocumenNumber + ", необходимо создать по УПД накладную(ые) и закрыть до статуса Факт." + {&new-line} + {&new-line} +
         v-DocumenNumber-fact + ", накладную(ые) нужно закрыть до статуса Факт." .
   end.
   else 
   do:
      if v-DocumenNumber <> "" then 
      do:
         message "Через ЭДО получен(ы) закрытый(е) УПД " skip
            "" skip
            v-DocumenNumber + "," skip
            "" skip
            "Необходимо создать по УПД накладную(ые) и закрыть до статуса Факт." skip
            "" skip
            "Продолжить закрытие смены?" skip
            view-as alert-box question buttons yes-no update p-cancel.
         v-mes = "Через ЭДО получен(ы) закрытый(е) УПД " + {&new-line} + {&new-line} + 
            v-DocumenNumber + ", необходимо создать по УПД накладную(ые) и закрыть до статуса Факт." .
      end.
      else 
      do:
         message "Через ЭДО получен(ы) закрытый(е) УПД " skip
            "" skip
            v-DocumenNumber-fact + "," skip
            "" skip
            "Необходимо накладную(ые) закрыть до статуса Факт." skip
            "" skip
            "Продолжить закрытие смены?" skip
            view-as alert-box question buttons yes-no update p-cancel.
         v-mes = "Через ЭДО получен(ы) закрытый(е) УПД " + {&new-line} + {&new-line} +
            v-DocumenNumber-fact + ", накладную(ые) нужно закрыть до статуса Факт." .            
      end.   
                 
    end.    
    
    v-file-name = "UTD-doc_" + string(p-shift-num) + ".txt". 
    output to value(v-file-name) .
    export v-mes .
    output close .     
end.      
                      
procedure schet-factur:
   define input parameter p-DocumentNumber as character no-undo .
   define input parameter p-DocumentDate as date no-undo .
   define output parameter p-doc-code as character no-undo .

   find first buf_doc-attr no-lock where buf_doc-attr.attr-code = {&trdcattr-nsf} and
      buf_doc-attr.attr-value = p-DocumentNumber no-error .
   if available (buf_doc-attr) then 
   do:
      find first bf_doc-attr no-lock where bf_doc-attr.attr-code = {&trdcattr-dsf} and
         bf_doc-attr.attr-value = string(p-DocumentDate,"99/99/9999") and
         bf_doc-attr.doc-code = buf_doc-attr.doc-code no-error .
      if available (bf_doc-attr) then 
      do:
         p-doc-code = bf_doc-attr.doc-code .
      end.                                        
   end.                                                      

      
end procedure .                              