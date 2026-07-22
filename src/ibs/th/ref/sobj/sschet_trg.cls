 
 /*------------------------------------------------------------------------
    File        : sSchet_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Thu Oct 29 16:22:04 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.sobj.sSchet_trg:
   {cmp\str-glbl.i class} 
   {cmp\r-page-pre.i}
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.   
   
   define public property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   
   define variable schet-list as character no-undo.
   define variable m-curr-code               as integer   no-undo .
   define variable m-curr-abbr               as character no-undo .

   method public void initschet ():
      define buffer buf_fin-schet for ub.fin-schet.
      if     ParamForm:temp-param-schet-init <> "" 
         and ParamForm:temp-param-schet-init <> ? 
      then do:
         find first buf_fin-schet no-lock where
                    buf_fin-schet.code-schet = integer (ParamForm:temp-param-schet-init) and
                    buf_fin-schet.host-code  = ParamObj:my-cntxt-host-code-obj no-error .
         if available buf_fin-schet 
         then
            schet-list = string(recid(buf_fin-schet)).
      end.
   end.
   
   method public character  getschettext ():
      
      define buffer buf_fin-schet for ub.fin-schet.
      define variable vtext as character no-undo.
      define variable v-iii as integer no-undo .
      if schet-list <> ""
      then do:
         if schet-list begins "curr-code="
         then 
            vtext =m-curr-abbr.
         else
         repeat v-iii = 1 to num-entries(schet-list) :
            find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (entry(v-iii,schet-list))   no-error .
            if available buf_fin-schet then
               vtext  = vtext  + string( buf_fin-schet.code-schet) + ", " .
         end.
      end.
      return vtext.
   end.
   
   method public void  CHOOSE_BUTTON-schet():

      define variable v-status_ as character  no-undo init {&current-status}.
      /* выборочно  */
      schet-list = "" .
      run ref/finschts.w
       (   input ParamObj:my-handle,
           input ParamObj:my-cntxt-host-code-obj,
           input "b-mark,b-sel",
           input ParamForm:temp-param-schet-mode,
           input ?,
           input ?,
           input 0,
           input ParamObj:my-cntxt-host-code-obj ,
           input 0,
           input-output v-status_,
           input-output schet-list).

      ParamObj:fin-schet-recid =  schet-list .
   end.
   
   method public void  CHOOSE_BUTTON-schet-one():

      /*  один   */
      define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
      define buffer buf_fin-schet for ub.fin-schet.
      schet-list          = "" .
      if     ParamForm:temp-param-schet-init <> "" 
         and ParamForm:temp-param-schet-init <> ? 
      then do:
         find first buf_fin-schet no-lock where
                    buf_fin-schet.code-schet = integer (ParamForm:temp-param-schet-init) and
                    buf_fin-schet.host-code  = ParamObj:my-cntxt-host-code-obj no-error .
         if available buf_fin-schet 
         then
            assign
               schet-list = string(recid(buf_fin-schet))
               v-status_ = buf_fin-schet.status_
            .
      end.
      run ref/finschts.w
       (   input ParamObj:my-handle,
           input ParamObj:my-cntxt-host-code-obj,
           input "b-sel",
           input ParamForm:temp-param-schet-mode,
           input ?,
           input ?,
           input 0,
           input ParamObj:my-cntxt-host-code-obj ,
           input 0,
           input-output v-status_,
           input-output schet-list).
      if num-entries(schet-list) > 1 then do:
         schet-list = "".
         ParamObj:fin-schet-recid =  schet-list.
         message "Можно выбрать только один счет !!!" view-as alert-box .
         return .
      end.
      ParamObj:fin-schet-recid =  schet-list .
      find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (schet-list)   no-error .
      
      define variable v-code-schet as integer no-undo .
      if available buf_Fin-schet then do:
         v-code-schet = buf_fin-schet.code-schet.
      end.
      if     ParamForm:ref_date-start <> '':u
         and entry(2, ParamForm:ref_date-start, {&delim-par}) = "finsttms":U 
      then do:
         entry(3, ParamForm:ref_date-start, {&delim-par}) = "code-schet-start".
         entry(4, ParamForm:ref_date-start, {&delim-par}) = string(v-code-schet).
      end.
      if     ParamForm:ref_date-end <> '':u
         and entry(2, ParamForm:ref_date-end, {&delim-par}) = "finsttms":U 
      then do:
         entry(3, ParamForm:ref_date-end, {&delim-par}) = "code-schet-end".
         entry(4, ParamForm:ref_date-end, {&delim-par}) = string(v-code-schet).
      end.
      if     ParamForm:ref_date-alone <> '':u
         and entry(2, ParamForm:ref_date-alone, {&delim-par}) = "finsttms":U 
      then do:
         entry(3, ParamForm:ref_date-alone, {&delim-par}) = "code-schet-end1".
         entry(4, ParamForm:ref_date-alone, {&delim-par}) = string(v-code-schet).
      end.
   end.
   
   method public void CHOOSE_BUTTON-schet-val():
      define variable ref-rec as recid no-undo.
      define buffer buf_currency for ub.currency .
/*      v-curr-abbr =  "" .*/
      
      run ref/currency.w ( ParamObj:my-handle, "b-sel", input-output ref-rec ).
      if ref-rec = ? then do:
         assign
            schet-list= ""
            m-curr-abbr =  "" .
            m-curr-code = ?.
         return.
      end.
      else do:
         find first buf_currency where recid( buf_currency ) = ref-rec no-lock.
         assign
            m-curr-code = buf_currency.curr-code
            schet-list = "curr-code=" + string(buf_currency.curr-code)
            m-curr-abbr = buf_currency.curr-abbr
         .
      end.
   end.
   
   method private void new-state(istate as character ):
   end.
   
   method public void select-Radio-schet (iRadio-schet as character ):
      define variable vRadioSchet as integer no-undo.
      do
      on error undo, return error return-value
      :
         vRadioSchet = stype:RadioSchetInt(iRadio-schet).
         new-state("RADIO-SCHET="  + string(vRadioSchet)) .
         case vRadioSchet:
            when {&schet-all-firm}
            or
            when {&schet-firm}
            or
            when {&schet-choice}
            or
            when {&schet-no-rubl}
            or
            /*пока еще не нажата клавиша выбора счета*/
            when {&schet-one}
            then do:
               if     ParamForm:ref_date-start <> '':u
                  and entry(2, ParamForm:ref_date-start, {&delim-par}) = "finsttms":U 
               then do:
                  entry(3, ParamForm:ref_date-start, {&delim-par}) = "ext-type-stat-start".
                  entry(4, ParamForm:ref_date-start, {&delim-par}) = "".
               end.
               if     ParamForm:ref_date-end <> '':u
                  and entry(2, ParamForm:ref_date-end, {&delim-par}) = "finsttms":U 
               then do:
                  entry(3, ParamForm:ref_date-end, {&delim-par}) = "ext-type-stat-end".
                  entry(4, ParamForm:ref_date-end, {&delim-par}) = "".
               end.
               if     ParamForm:ref_date-alone <> '':u
                  and entry(2, ParamForm:ref_date-alone, {&delim-par}) = "finsttms":U 
               then do:
                  entry(3, ParamForm:ref_date-alone, {&delim-par}) = "ext-type-stat-start".
                  entry(4, ParamForm:ref_date-alone, {&delim-par}) = "".
               end.
            end.
           /* when {&schet-one}
            then do:
            end.*/
            when {&schet-rubl}
            or 
            when {&schet-choice-val}
            then do:
               if     ParamForm:ref_date-start <> '':u
                  and entry(2, ParamForm:ref_date-start, {&delim-par}) = "finsttms":U 
               then do:
                  entry(3, ParamForm:ref_date-start, {&delim-par}) = "currency-start".
                  if vradioschet = {&schet-rubl} 
                  then  do:
                     entry(4, ParamForm:ref_date-start, {&delim-par}) = "0".
                  end.
                  else do:
                     entry(4, ParamForm:ref_date-start, {&delim-par}) = entry(2, schet-list, "=").
                  end.
               end.
               if     ParamForm:ref_date-end <> '':u
                  and entry(2, ParamForm:ref_date-end, {&delim-par}) = "finsttms":U 
               then do:
                  entry(3, ParamForm:ref_date-end, {&delim-par}) = "currency-end".
                  if vradioschet = {&schet-rubl} 
                  then  do:
                     entry(4, ParamForm:ref_date-end, {&delim-par}) = "0".
                  end.
                  else do:
                     entry(4, ParamForm:ref_date-end, {&delim-par}) = entry(2, schet-list, "=").
                  end.
               end.
               if     ParamForm:ref_date-alone <> '':u
                  and entry(2, ParamForm:ref_date-alone, {&delim-par}) = "finsttms":U 
               then do:
                  entry(3, ParamForm:ref_date-alone, {&delim-par}) = "currency-end1".
                  if vradioschet = {&schet-rubl} 
                  then  do:
                     entry(4, ParamForm:ref_date-alone, {&delim-par}) = "0".
                  end.
                  else do:
                     entry(4, ParamForm:ref_date-alone, {&delim-par}) = entry(2, schet-list, "=").
                  end.
               end.
            end.
         end case.
      end.  /* do */
   end.
   
   method public void Assign-frame(itext as character ):
      define variable t-str as character no-undo.
      ParamObj:fin-schet-recid =  schet-list.
      if ParamForm:temp-param-schet <> "" 
      then do:
         paramobj:strSchet = itext.
      end.
   end method.
   
end class.