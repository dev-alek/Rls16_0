 
 /*------------------------------------------------------------------------
    File        : sShift_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Lastochka
    Created     : Sat May 02 21:11:38 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.sobj.sShift_trg: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   {cmp\r-page-pre.i}
   define property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.
   define property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   define property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   constructor public sShift_trg (  ):
      super ().
      
   end constructor.

   destructor public sShift_trg ( ):

   end destructor.
   
   method public void BtnShift (input-output pdate-start   as date,
                                input-output pshift-alone  as integer ):
       
      define variable v-doc-rec as recid no-undo.
      define variable rec-list-2 as character no-undo.
      define buffer buf_shift-obj for ub.shift-obj .
      define variable vSelectObject as character no-undo.
  
      vSelectObject =ParamObj:x-SelectObject.
      if  vSelectObject = {&obj-currency}
      then do:
         find first buf_shift-obj no-lock where
                    buf_shift-obj.shift-date = pdate-start and
                    buf_shift-obj.shift-num = pshift-alone and
                    buf_shift-obj.obj-type = ParamObj:my-cntxt-obj-type and
                    buf_shift-obj.obj-code = ParamObj:my-cntxt-obj-code no-error.
         if available buf_shift-obj 
         then
            rec-list-2 = string(recid(buf_shift-obj)).
      end.
      if  vSelectObject = {&obj-currency}
      then do:
         run str/sht-all.w
         (             input paramobj:my-handle 
                      ,input paramobj:my-cntxt-obj-type /*p-curr-obj-type*/
                      ,input paramobj:my-cntxt-obj-code /*p-curr-obj-code*/
                      ,input  "b-sel"
                      ,input "obj":U
                      ,input paramobj:my-cntxt-obj-type   /*p-obj-type*/
                      ,input paramobj:my-cntxt-obj-code   /*p-obj-code*/
                      ,input ParamObj:ReportProc
                      ,input-output rec-list-2 ).
      end.
      else do:
         run str/sht-all.w
         (             input paramobj:my-handle
                      ,input paramobj:my-cntxt-obj-type /*p-curr-obj-type*/
                      ,input paramobj:my-cntxt-obj-code /*p-curr-obj-code*/
                      ,input  "b-sel"
                      ,input "all":U
                      ,input '':U  /*p-obj-type*/
                      ,input 0     /*p-obj-code*/
                      ,input ParamObj:ReportProc
                      ,input-output rec-list-2 ).
      end.

      find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
      if available buf_shift-obj 
      then do:
         assign
            pdate-start  = buf_shift-obj.shift-date
            pshift-alone = buf_shift-obj.shift-num
         .
      end. 
   end.
   
   method public void BUTTON-Shift-Start(
                                    input-output pdate-start as date,
                                    input-output pshift-start as integer):

      define variable v-doc-rec as recid no-undo .
      define variable rec-list-2      as char no-undo.
      define buffer buf_shift-obj for ub.shift-obj .
      define variable vSelectObject as character no-undo.
  
      vSelectObject = ParamObj:x-SelectObject.
      if  vSelectObject = {&obj-currency} 
      then do:
         find first buf_shift-obj no-lock where
                    buf_shift-obj.shift-date = pdate-start and
                    buf_shift-obj.shift-num = pshift-start and
                    buf_shift-obj.obj-type = paramobj:my-cntxt-obj-type and
                    buf_shift-obj.obj-code = paramobj:my-cntxt-obj-code no-error.
         if available buf_shift-obj 
         then
            rec-list-2 = string(recid(buf_shift-obj)).
         end.
         if  vSelectObject = {&obj-currency}
         then do:
            run str/sht-all.w
            (             input paramobj:my-handle
                         ,input paramobj:my-cntxt-obj-type /*p-curr-obj-type*/
                         ,input paramobj:my-cntxt-obj-code /*p-curr-obj-code*/
                         ,input  "b-sel"
                         ,input "obj":U
                         ,input paramobj:my-cntxt-obj-type   /*p-obj-type*/
                         ,input paramobj:my-cntxt-obj-code   /*p-obj-code*/
                         ,input paramobj:ReportProc
                         ,input-output rec-list-2 ).
         end.
         else do:
            run str/sht-all.w
            (             input paramobj:my-handle
                         ,input paramobj:my-cntxt-obj-type /*p-curr-obj-type*/
                         ,input paramobj:my-cntxt-obj-code /*p-curr-obj-code*/
                         ,input  "b-sel"
                         ,input "all":U
                         ,input '':U  /*p-obj-type*/
                         ,input 0     /*p-obj-code*/
                         ,input paramobj:ReportProc
                         ,input-output rec-list-2 ).
         end.

         find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
         if available  buf_shift-obj 
         then do:
            assign
               pdate-start  = buf_shift-obj.shift-date
               pshift-start = buf_shift-obj.shift-num
            .
        
         
      end.
   end.
   
   method public void LEAVE_Shift-Start (iShift-Start as integer ): /* с */
      ParamObj:X-Shift-Start = iShift-Start.
      new-state ( "SHIFT-START="  + String(iShift-Start)).
   end.

   method public void BUTTON-Shift-end (input  iSelectObject as character,
                                        input-output pdate-end   as date,
                                        input-output pshift-end  as integer):
      define variable v-doc-rec as recid no-undo .
      define variable rec-list-2      as char no-undo.
      define buffer buf_shift-obj for ub.shift-obj .
      define variable vSelectObject as character no-undo.
  
      vSelectObject = stype:SelectObjectchar(iSelectObject).
      if  vSelectObject = {&obj-currency} 
      then do:
         find first buf_shift-obj no-lock where
                    buf_shift-obj.shift-date = pdate-end and
                    buf_shift-obj.shift-num = pshift-end and
                    buf_shift-obj.obj-type = paramobj:my-cntxt-obj-type and
                    buf_shift-obj.obj-code = paramobj:my-cntxt-obj-code no-error.
         if available buf_shift-obj 
         then
            rec-list-2 = string(recid(buf_shift-obj)).
      end.
      if  vSelectObject = {&obj-currency}
      then do:
         run str/sht-all.w
         (             input paramobj:my-handle
                      ,input paramobj:my-cntxt-obj-type /*p-curr-obj-type*/
                      ,input paramobj:my-cntxt-obj-code /*p-curr-obj-code*/
                      ,input  "b-sel"
                      ,input "obj":U
                      ,input paramobj:my-cntxt-obj-type   /*p-obj-type*/
                      ,input paramobj:my-cntxt-obj-code   /*p-obj-code*/
                      ,input paramobj:ReportProc
                      ,input-output rec-list-2 ).
      end.
      else do:
         run str/sht-all.w
         (             input paramobj:my-handle
                      ,input paramobj:my-cntxt-obj-type /*p-curr-obj-type*/
                      ,input paramobj:my-cntxt-obj-code /*p-curr-obj-code*/
                      ,input  "b-sel"
                      ,input "all":U
                      ,input '':U  /*p-obj-type*/
                      ,input 0     /*p-obj-code*/
                      ,input paramobj:ReportProc
                      ,input-output rec-list-2 ).
      end.

      find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
      if available buf_shift-obj 
      then do:
         assign
            pdate-end  = buf_shift-obj.shift-date
            pshift-end = buf_shift-obj.shift-num
         .
       

    end.
 end.

   method public  void set-end ( idateend as date, iShift-End as integer ): /* по */
      paramobj:x-date-end  = idateend.
      paramobj:X-Shift-End  = iShift-End.
      
   end.
    
   method public  void LEAVE_Shift-End ( iShift-End as integer ): /* по */
      paramobj:X-Shift-End  = iShift-End.
      new-state ( "SHIFT-END="  + String(iShift-End)).
   end.
   
   method public void LEAVE_Date-Alone (iDate-Alone as date): /* Дата */
      Set_Date-Start( iDate-Alone).
      set_Date-End ( iDate-Alone).
      set_Date-Alone ( iDate-Alone).
      new-state ("DATE-ALONE="  + String(iDATE-ALONE)).
   end.
   
   method public void LEAVE_Date-End (iDateStart as date, iDate-End as date): /* по */
      set_Date-End (iDate-End).
      verify-date (iDateStart,iDate-End) .
      new-state ("DATE-END="  + String(iDATE-END)).
   end.
   
   method public void set_Date-Alone ( iDate-Alone as date): /* по */
      ParamObj:X-Date-Alone       = iDate-Alone.
      
   end.
   
   method public void set_strShift ( itext as character ): 
      ParamObj:strShift       = itext.
   end.
   
   method public void set_Date-End ( iDate-End as date): /* по */
      ParamObj:X-Date-End       = iDate-End.
      
   end.
   
   method public void LEAVE_Date-Start(iDate-Start as date): /* с */
      Set_Date-Start( iDate-Start).
      new-state ("DATE-START="  + String(iDATE-START)).
   end.
   
    method public void Set_Date-Start(iDate-Start as date): /* с */
       ParamObj:X-Date-Start     = iDate-Start.
    end.
   
   method public character  verify-date(iDateStart as date, iDateEnd as date):
      if iDateEnd < iDateStart  
      then do:
         message "Интервал дат введен неверно !" view-as alert-box error title "О Ш И Б К А !!!".
         return error "Интервал дат введен неверно".
      end. 
/*   return error "не правильные значения".*/
   end.
   
   method public  void LEAVE_Shift-Alone(iShift-Alone as integer ): /* смена */
      set_Shift-Alone(iShift-Alone).
      set_Shift-end  (iShift-Alone).
      set_Shift-start(iShift-alone).
      new-state ("SHIFT-ALONE="  + String(iSHIFT-Alone)).
   end.
   
   method public  void set_Shift-Alone(iShift-Alone as integer ): /* смена */
      Paramobj:X-Shift-Alone   = iShift-Alone.
   end.
   
   method public  void set_Shift-end(iShift-end as integer ): /* смена */
      ParamObj:X-Shift-End     = iShift-end.
   end.
   
   method public  void set_Shift-start(iShift-start as integer ): /* смена */
      ParamObj:X-Shift-start     = iShift-start.
   end.
   
   method public  void verify-shift(idate as date,iShift as integer, iflag as logical ) :

      define buffer buf_shift-obj for ub.shift-obj .
      find first buf_Shift-obj where buf_Shift-obj.shift-num  = iShift
                                 and buf_Shift-obj.shift-date = idate
      no-lock no-error.
       
      if    not available buf_Shift-obj
         or (iflag and not ParamObj:avail_obj-list( buf_shift-obj.obj-type,buf_shift-obj.obj-code ) )
      then do:
         message "Нет смены " ishift idate " !" 
            view-as alert-box error title "О Ш И Б К А !!!".
         return error.
      end.
      else do:
         ParamObj:x-tog-shift = true .
      end.

   end method.
   
   method public logical avail_shift-obj ():
      define buffer buf_shift-obj for ub.shift-obj .
      return can-find(first buf_shift-obj where
                            buf_shift-obj.obj-code = ParamObj:my-cntxt-obj-code and
                            buf_shift-obj.obj-type = ParamObj:my-cntxt-obj-type no-lock ).
   end.
   
   method public void  VALUE-CHANGED_TOG-Shift (itog-shift as logical):
      set_tog-shift (not itog-shift = false).
      new-state ("TOG-SHIFT ="  + String(itog-shift)).
   end .
   
   method public void  set_TOG-Shift (itog-shift as logical):
       ParamObj:x-tog-shift   = itog-shift .
   end .
   
   method public void VALUE-CHANGE_RADIO-task (iRADIO-task as character  ):
      set_RADIO-task(iRADIO-task).
      define variable vRADIO-task as integer  no-undo.
  
      vRADIO-task = stype:SelectObjectInt(iRADIO-task).
      new-state ( "RADIO-TASK="  + String(vRADIO-task)).
   end. 
   method public void set_RADIO-task (iRADIO-task as character  ): 
      define variable vRADIO-task as integer  no-undo.
  
      vRADIO-task = stype:SelectObjectInt(iRADIO-task).
      ParamObj:X-RADIO-task       = vRADIO-task.
      
   end.
   
   method private void new-state(istate as character ):
   end.
    
end class.