 
 /*------------------------------------------------------------------------
    File        : sParam
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sat Apr 04 12:23:09 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.sobj.sParamObj: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   {cmp\str-glbl.i class}
   { cmp\library.i class}
   {cmp\obj-list.i class} /* obj-list s*/
   {rep\par-actu.i} /* param-to-export  */
   {rep\par-actu.i method} /* create-param-to-export */
   { cmp\gds-list.i gds-list def}
   { cmp\gds-list.i gds-list method}
   {cmp\tmpgrp.i class} 
   {cmp\gcli.i class}
   {cmp\customer-list.i class}
    
   define public property  my-handle         as handle  no-undo
   get.
   set(iarg as handle):
      my-handle = iarg.
   end.
   define public property d-report-handle as handle  no-undo
   get. set. 
   define public property parParentProc     as handle  no-undo
   get:
      return this-object:my-handle.
   end.
   set(iarg as handle):
      my-handle = iarg.
      setMyhandle().
   end.
   
   define public variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
   define public variable x-Date-End       as date format "99/99/9999":u   no-undo .
   define public variable x-Date-Start     as date format "99/99/9999":u   no-undo .
   define public variable x-Shift-Alone    as integer format ">9":u         no-undo .
   define public variable x-Shift-End      as integer format ">9":u         no-undo .
   define public variable x-Shift-Start    as integer format ">9":u         no-undo .
   define public variable x-TOG-Shift      as logical  no-undo . /* "Смены" initial yes */
   define public variable x-Radio-Task     as integer  no-undo . /* "Тип задания даты 1 2 3 4 */
   define public variable x-SelectObject   as character                          no-undo .
   define public variable x-Goods-Editor   as character                          no-undo .
      define public variable x-SelectGood     as integer                      no-undo .
   
   
   define public variable x-SET_PAY_TYPE   as integer  no-undo .
   define public variable x-SET_val_TYPE   as integer  no-undo . /*  "{&abbr_rub}", 1, "вал", 2 */
   
   
   define public variable my-cntxt-db-num        as integer   no-undo . /* текущая БД            */
   define public variable my-cntxt-userid        as character no-undo . /* текущий пользователь  */
   define public variable my-cntxt-level         as character no-undo . /* уровень контекста     */
   define public variable my-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */
   define public variable my-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */
   define public variable my-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */
   define public variable my-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */
   define public variable my-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */
   define public variable my-base-type           as character no-undo .
   define public variable my-base-code as integer   no-undo .
   define public variable my-g#report-num as integer   no-undo .
   define public variable my-g#gds-engl as logical   no-undo .
   define public variable my-v-exch-rate  as decimal   no-undo .
   define public variable my-v-exch-scale as decimal   no-undo .
   define public variable my-cntxt-host-name-obj as character no-undo .
   
   define public variable  Show-Crsa         as logical  no-undo init false.    /* чекбокс по продажныи ценам   */
   define public variable  Show-Cost         as logical  no-undo init false.    /* чекбокс по учетным ценам     */
   define public variable  Show-Sale         as logical  no-undo init false.    /* чекбокс по цена документов   */
   
   define public variable x-text-Obj   as character  no-undo . /*x-text-1 */
   define public variable x-text-Goods as character  no-undo . /*x-text-2 */
   define public variable x-text-Shift as character  no-undo . /*x-text-3 */
   define public variable x-text-Curr  as character  no-undo . /*x-text-4 */
   define public variable x-text-Cust  as character  no-undo . /*  text-5 */
   define public variable strShift   as character  no-undo. /* str1 */
   define public variable strGoods   as character  no-undo. /* str2 */
   define public variable strCurr    as character  no-undo. /* str3 */
   define public variable strObj     as character  no-undo. /* str4 */
   define public variable strCust    as character  no-undo. /* str4 */
   define public variable strSchet   as character  no-undo. /* str4 */
   
   define public variable  Print-List-Hist   as logical no-undo init false. /* печать истории формирования списков */
   
   define public variable Make-Excel     as logical  no-undo init false. /* Делать или нет экспорт в Excel */
   define public variable Make-Excel-com as logical  no-undo init false. /* Делать или нет экспорт в Excel через com */
   
   define public variable parent-handle  as handle no-undo .
   define public variable params-only-mode as character no-undo .  /* Для работы RUM  - просмотр или корректировка параметров отчета */
   define public variable place-call       as character no-undo .   /* Для работы RUM - особое место вызова*/
   
   define public variable ReportProc as character no-undo.
   define public variable ReportName as character no-undo.
   define public variable ReportPageWidth  as integer no-undo.   /* Ширина отчета в символах */
   define public variable ReportPageHeight as integer no-undo.  /* Высота отчета в символах */
   define public variable Use-column   as logical extent {&xlMaxCols} no-undo .
   
   define public variable fin-schet-recid    as character no-undo.
   
   define public variable ReportHeader as character  no-undo.
   define public variable ch#ExcelApplication as com-handle no-undo .
   define public variable ch#Workbook         as com-handle no-undo .
   define public variable ch#Worksheet        as com-handle no-undo .
   define public variable Num#Str#            as integer no-undo.
   define public variable Number-List  as integer no-undo init 1.
   define public variable v-excel-file as character no-undo .
   {cmp\r-sheetf.i }
   {cmp\r-sheetf.i class}
   define public property sheet-num as integer 
   get:
      define variable vsheet-num as integer no-undo.
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf 
      then
         vsheet-num = buf_sheetf.sheet-num.
      return vsheet-num.
   end.
   method private void setMyhandle():
      { rep/rep-bt.i   class   }
      assign
         my-cntxt-db-num = v-cntxt-db-num
         my-cntxt-userid = v-cntxt-userid
         my-cntxt-level = v-cntxt-level
         my-cntxt-host-code-obj = v-cntxt-host-code-obj
         my-cntxt-obj-type = v-cntxt-obj-type
         my-cntxt-obj-code = v-cntxt-obj-code
         my-cntxt-db-num-obj = v-cntxt-db-num-obj
         my-cntxt-is-admin = v-cntxt-is-admin
         my-base-type  = base-type 
         my-base-code = base-code
         my-g#report-num = g#report-num
         my-g#gds-engl = g#gds-engl
         my-v-exch-rate = vv-exch-rate
         my-v-exch-scale = vv-exch-scale
         my-cntxt-host-name-obj = v-cntxt-host-name-obj
      .
   end method.
   
   method public logical  avail_obj-list (iobj-type as character ,iobj-code as integer ):
      define buffer obj-list for obj-list.
      return can-find (first obj-list where obj-list.obj-type = iobj-type
                                        and obj-list.obj-code = iobj-code).
   end method.
   
   method public character get-obj-List-text():
      define variable otext as character no-undo.
      define buffer cli-obj   for ub.clients . 
      for each Obj-list :
          find cli-obj where cli-obj.obj-type = obj-list.obj-type  and
                             cli-obj.obj-code = obj-list.obj-code no-lock .
          if length(otext) <= {&max-len-str} 
          then
             otext = otext + {&new-line} + "     " + cli-obj.obj-name  + ' ' + obj-list.obj-type.
      end.
      return otext.
   end method.
   
   method public integer  get-count-gds-list():
      define variable lns-cnt as integer no-undo.
      for each gds-list :
         lns-cnt = lns-cnt + 1 .
      end.
      return lns-cnt.
   end method.
   
   method public character get-custumer-text():
      define variable oStr as character no-undo.
      block-cust:
      for each g#customer:
         if length (oStr) >= 10000 
         then do:
            oStr = oStr + '...' .
            leave block-cust.
         end.
         else oStr = oStr + {&new-line} + "     " + g#customer.obj-name .
      end.
      return oStr.
   end method.
   
   method public void  CheckAndUpNameObjList():
      define variable L#obj-code like obj-list.obj-code no-undo.
      define variable l#obj-type like obj-list.obj-type no-undo.
      define buffer obj-list   for obj-list .
      define buffer o-clients  for ub.clients.
      /* Проверка нет ли двойных записей в obj-list */
      assign
         L#obj-code=0
         l#obj-type=""
      .

      for each obj-list  by obj-list.obj-code by obj-list.obj-type :
         

         if obj-list.obj-code = L#obj-code and
            obj-list.obj-type = l#obj-type then  do:
            delete obj-list.
         end.
         else do:
            find first  o-clients where
                     o-clients.obj-code = obj-list.obj-code and
                     o-clients.obj-type = obj-list.obj-type  no-lock no-error .
            assign 
               obj-list.obj-name = if avail o-clients then  o-clients.obj-name else ""
               l#obj-code = obj-list.obj-code
               l#obj-type = obj-list.obj-type   
            .
         end.
      end.
   end method.
   
   method public character  get-s-notes():
      define variable v-i as integer   no-undo .
      define variable s-notes as character no-undo.
      
      for each gds-list-hist :
         v-i = v-i + 1 .
         s-notes = s-notes + {&new-line} + gds-list-hist.hist-mode +  gds-list-hist.des .
         if v-i > 10 then do:
            s-notes = s-notes + " ... " .
            leave.
         end.
      end.
   end method.
   
   method public void make-6-gds-list () :
      define buffer buf-goods for ub.goods.
      if X-SelectGood = {&g-grp-prod} then do:
      /*  run set-cursor in adm-broker-hdl ("WAIT").*/
      /* создание списка */
         for each gds-list  :
            delete gds-list.
         end.

         for each g#cli no-lock :
            for each tmp#grp no-lock :
               for each buf-goods where
                  buf-goods.prod-type = g#cli.obj-type and
                  buf-goods.prod-code = g#cli.obj-code and
                  ( trim(buf-goods.grp-name)  begins trim(tmp#grp.grp-name) )
               no-lock :
                  if not can-find(first gds-list where gds-list.gds-code= buf-goods.gds-code) 
                  then  do:
                     create gds-list.
                     buffer-copy buf-goods to gds-list  no-error  .
                  end.
               end.
            end.
         end.
   /*    run set-cursor in adm-broker-hdl ("").*/
      end.
   end method. 
   
   constructor public sParamObj (  ):
      super ().
      
   end constructor.

   destructor public sParamObj ( ):

   end destructor.

end class.