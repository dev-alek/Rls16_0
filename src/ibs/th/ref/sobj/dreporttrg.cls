 
 /*------------------------------------------------------------------------
    File        : dReportTrg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Mon Mar 30 21:42:31 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.ref.sobj.sSchet from propath.
using ibs.th.ref.sobj.userhist from propath.
block-level on error undo, throw.

class ibs.th.ref.sobj.dReportTrg: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define public variable  parParentProc   as widget-handle no-undo.
   define public variable  procname        as character no-undo . /* имя процедуры на 2 закладке  */
   define public variable  namereport      as character no-undo . /* имя процедуры на 2 закладке  */
   define public variable  param-date      as integer   no-undo . /* Дата  1 2 3 */
   define public variable  param-goods     as character no-undo . /* Товары */
   define public variable  param-obj       as character no-undo . /* Объекты */
   define public variable  param-pay       as character no-undo . /* Цены */
   define public variable  param-pay-hide  as character no-undo . /* Цены - какие цены не паказывать*/
   define public variable  param-alon      as logical   no-undo . /* 1 закладка*/
   define public variable  d-report-handle as widget-handle no-undo. /* handel source-proce */ 
   define stream ForExcel.
   define stream str-export.
   {cmp\str-glbl.i class}
   { cmp/library.i class}
   { gbl/attr-lib.i class}
   {gbl\cur-time.i class}
   {cmp\obj-list.i local}
   { gbl/getsect.i def}
   define public variable mUserframe as ibs.th.ref.sobj.sUserFrame no-undo.
   define public variable mShift    as class ibs.th.ref.sobj.sShift no-undo.
   define public variable mGoods    as class ibs.th.ref.sobj.sGoods no-undo.
   define public variable mObj      as class ibs.th.ref.sobj.sobj no-undo.
   define public variable mSchet    as class ibs.th.ref.sobj.sSchet no-undo.
   define public variable mCurrency as class ibs.th.ref.sobj.sCurrency no-undo.
   define public variable mCustomer as class ibs.th.ref.sobj.sCustomer no-undo.
   define public variable mFormat   as class ibs.th.ref.sobj.sFormat no-undo.
   define public variable mListF   as class ibs.th.ref.sobj.slistf no-undo.
   
   define variable mParamObj  as class ibs.th.ref.sobj.sParamObj  no-undo.
   define variable mParamForm as class ibs.th.ref.sobj.sParamForm no-undo.

   define variable mType      as class ibs.th.ref.sobj.stype      no-undo.
   define variable userhist      as class ibs.th.ref.sobj.userhist      no-undo.
   
   
   define public property mDReport as class ibs.th.ref.sobj.dreport no-undo
   get.
   set(iarg as  class ibs.th.ref.sobj.dreport):
      assign
         mDReport   = iarg.
         mUserframe = mDReport:mUserframe.
         mUserframe:paramobj = mParamObj.
         mUserframe:paramForm = mParamForm.
         
         
         mShift     = mDReport:mShift.
         mShift:paramobj = mParamObj.
         mShift:paramForm = mParamForm.
         mShift:stype     = mtype.
         mShift:mtrgGLb   = this-object.
         
         mGoods     = mDReport:mGoods.
         mGoods:paramobj = mParamObj.
         mGoods:paramForm = mParamForm.
         mGoods:stype     = mtype.
         mGoods:mtrgGLb   = this-object.
         
         mObj           = mDReport:mObj.
         mObj:paramobj  = mParamObj.
         mObj:paramForm = mParamForm.
         mObj:stype     = mtype.
         mObj:mtrgGLb   = this-object.
         
         mSchet     = mDReport:mSchet.
         mSchet:paramobj  = mParamObj.
         mSchet:paramForm = mParamForm.
         mSchet:stype     = mtype.
         mSchet:mtrgGLb   = this-object.
         
         mCurrency  = mDReport:mCurrency.
         mCurrency:paramobj  = mParamObj.
         mCurrency:paramForm = mParamForm.
         mCurrency:stype     = mtype.
         mCurrency:mtrgGLb   = this-object.
         
         mCustomer  = mDReport:mCustomer.
         mCustomer:paramobj  = mParamObj.
         mCustomer:paramForm = mParamForm.
         mCustomer:stype     = mtype.
         mCustomer:mtrgGLb   = this-object.
         
/*         mFormat    = mDReport:mFormat.*/
         mListF     = mDReport:mListF.
      
      
   end.
   define public variable  temp-param-obj-type     as character    no-undo .
   define public variable  temp-param-schet-mode     as character    no-undo .
   define public variable  all-object     as logical    no-undo .
   
   {cmp\r-page-pre.i}
   {cmp\r-pril.i class}
   
   define public property  param-universal as character  
   get.   set.
   {rep/opclexcl.i mParamObj: my- }
   constructor public dReportTrg (  ):
      super ().
      mParamObj  = new ibs.th.ref.sobj.sParamObj().
      mParamForm = new ibs.th.ref.sobj.sParamForm().
      mType      = new ibs.th.ref.sobj.stype ().
   end constructor.

   destructor public dReportTrg ( ):
      delete object mParamObj  no-error.
      delete object mParamForm no-error.
      delete object mtype      no-error.
   end destructor.
  
   method public logical canselForm():
      return mDReport:canselForm(). 
   end.
   
   method public void local-apply-layout():
      /* ????? */
      mShift:local-apply-layout(mParamObj).
      mGoods:local-apply-layout(mParamObj).
      mObj:local-apply-layout(mParamObj).
      mCurrency:local-apply-layout(mParamObj).
      /* Контрагенты */
      mCustomer:local-apply-layout(mParamObj).
      
      /* Счета */
      mSchet:local-apply-layout(mParamObj).
      
/*RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .*/
/*run take-var in this-procedure .*/
  
 /* if ref_date-end <> '':U then do:
    if not valid-handle(mi-ed_date-end-handle) then do:
      create menu-item mi-ed_date-end-handle
      assign
      label = entry(1, ref_date-end, {&delim-par})
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-end-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.

  if ref_date-alone <> '':U then do:
    if not valid-handle(mi-ed_date-alone-handle) then do:
      create menu-item mi-ed_date-alone-handle
      assign
      label = entry(1, ref_date-alone, {&delim-par})
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-alone-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.
  if ref_date-start <> '':U then do:
    if not valid-handle(mi-ed_date-start-handle) then do:
      create menu-item mi-ed_date-start-handle
      assign
      label = entry(1, ref_date-start, {&delim-par})
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-start-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.
*/

      if mparamobj:params-only-mode  = {&lookup} then do:
         mDReport:togexcel:enabled = no.
         mDReport:toglisthist:enabled = no.
      end.      
   end.
    
   method public void Assign-frame(  ):
      /* ????? */
      mShift:Assign-frame(  ).
      mParamObj:Make-Excel =  mDReport:TogExcel:checked .
      mParamObj:Print-List-Hist = mDReport:TogListHist:checked .
      mGoods:Assign-frame().
      mObj:Assign-frame().
      mCurrency:Assign-frame().
      /* Контрагенты */
      mCustomer:Assign-frame().
      /* Счета */
      mSchet:Assign-frame().
/*

run set-attribute-list in THIS-PROCEDURE (
{&KEEP-spis}  + "=" + string(keep-spis) + "," +
{&RADIO-CUSTOMER}  + "=" + string(RADIO-CUSTOMER) + "," +
{&RADIO-SCHET}     + "=" + string(RADIO-SCHET)    + "," +
{&EX-CURR-CODE}     + "=" + string(v-curr-code)
 ) .
*/      
      return.
   end method.
   

method private void local-pre-initialize ():

/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
  define variable v-ok    as logical   no-undo .

   cur-time  (output v-today
             ,output v-time
             ).

   if mParamForm:init-date-start = date("") or mParamForm:init-date-start = ? then mParamForm:init-date-start  = v-today .
   if mParamForm:init-date-end = date("") or mParamForm:init-date-end = ? then  mParamForm:init-date-end    = v-today .
   if mParamForm:init-date-alone = date("") or mParamForm:init-date-alone = ? then  mParamForm:init-date-alone  = v-today.
   if mParamForm:init-shift-alone = ? then mParamForm:init-shift-alone = 0 .
   if mParamForm:init-shift-start = ? then mParamForm:init-shift-start = 0 .
   if mParamForm:init-shift-end   = ? then mParamForm:init-shift-end   = 0 .

end.

   
method public void SetVar 
(
     /* output temp-str as char no-undo,
      output temp-param-date as int no-undo,
      output  temp-param-date-type-period as character no-undo,
      output  temp-param-goods as char,    /* Товары */
      output  temp-param-obj as char,      /* Объекты */
      output  temp-param-Pay as char,      /* Цены */
      output  temp-param-Pay-hide as char, /* Цены */
      output  temp-param-obj-type as char, /* Типы объектов - all stok shop*/
      output  temp-param-alon as log,      /* 1 закладка*/
      output  temp-param-customer as character no-undo , /* контрагенты */
      output  temp-param-customer-type as character no-undo , /* контрагенты */
      output  temp-param-schet        as character no-undo ,
      output  temp-param-schet-hide   as character no-undo ,
      output  temp-param-schet-init   as character no-undo ,
      output  temp-param-schet-mode   as character no-undo ,
      output  all-object            as logical   no-undo*/ 
):
   
   define variable customer-yes as logical init false no-undo .
   define variable customer-name as character init "" no-undo .
   define variable customer-type as character init "" no-undo .
   define variable schet-yes  as logical init false no-undo .
   define variable schet-name as character init "" no-undo .
   define variable schet-hide as character init "" no-undo .
   define variable schet-init as character init "" no-undo .
   define variable ed_date-ref as character no-undo .

   define variable Jv as integer no-undo.
   define variable v-ii as integer no-undo .
   define variable plase-cost as integer no-undo .
   define variable plase-crsa as integer no-undo .
   define variable plase-sale as integer no-undo .
   define variable radio-period as character   no-undo .
   define variable v-nn3 as integer no-undo.
       
   param-universal = param-universal + ",".
   temp-param-obj-type  = "".
   all-object = false .
   mParamObj:parParentProc = parParentProc.
   assign temp-param-schet-mode = {&company} .
   v-nn3 = num-entries(param-universal).
   repeat Jv = 1 to v-nn3:
      case entry(Jv,param-universal ) :
        when  "all":U or
        when  "shop":U or
        when  "stok":U then temp-param-obj-type    =  entry(Jv,param-universal ).
        when   string({&Excel-yes})             then mParamObj:Make-Excel       = true.
        when   string({&Excel-yes-com})         then mParamObj:Make-Excel-com   = true.
        when   string({&Arc-aht-yes})           then mParamForm:Verify-Arc-aht   = true.
        when   string({&Arc-ot-yes})            then mParamForm:Verify-Arc-ot    = true.
        when   string({&Arc-stk-yes})           then mParamForm:Verify-Arc-stk   = true.
        when   string({&Arc-supp-yes})          then mParamForm:Verify-Arc-supp  = true.
        when   string({&Arc-hold-yes})          then mParamForm:Verify-Arc-hold  = true.
        when   string({&Arc-strong-yes})        then mParamForm:Verify-Arc-strong  = true.
        when   string({&send-check})            then mParamForm:Verify-send-check = true.
        when   string({&Show-Crsa})             then mParamObj:Show-Crsa = true.
        when   string({&show-cost})             then mParamObj:show-cost = true.
        when   string({&show-sale})             then mParamObj:show-sale = true.
        when   string({&format-folder})         then mParamForm:format-folder = true.
        when  string({&customer-yes})          then customer-yes = true.
        when  string({&schet-yes})             then schet-yes = true.
        when  string({&hide-schet-all-firm})   then schet-hide = schet-hide + string( {&schet-all-firm}   ) + "," .  /* то что нужно задисаблить*/
        when  string({&hide-schet-firm})       then schet-hide = schet-hide + string( {&schet-firm}       ) + "," .  /* то что нужно задисаблить*/
        when  string({&hide-schet-choice})     then schet-hide = schet-hide + string( {&schet-choice}     ) + "," .  /* то что нужно задисаблить*/
        when  string({&hide-schet-one})        then schet-hide = schet-hide + string( {&schet-one}        ) + "," .  /* то что нужно задисаблить*/
        when  string({&hide-schet-rubl})       then schet-hide = schet-hide + string( {&schet-rubl}       ) + "," .  /* то что нужно задисаблить*/
        when  string({&hide-schet-no-rubl})    then schet-hide = schet-hide + string( {&schet-no-rubl}    ) + "," .  /* то что нужно задисаблить*/
        when  string({&hide-schet-choice-val}) then schet-hide = schet-hide + string( {&schet-choice-val} ) + "," .  /* то что нужно задисаблить*/
        when  "X-OWN-CMP":U then temp-param-schet-mode = "company-host":U .  /* для счетов - выборка только нашей фирмы "company-host":U или всех {&company} */
        when  string({&Print-List-Hist-yes})    then mParamObj:Print-List-Hist   = true.
        when  string({&Arc-fin-yes})            then mParamForm:verify-arc-fin    = true.
    end case.
    
   if trim(entry(Jv,param-universal)) begins "name-sale" then  mParamForm:name-sale-price = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "X-DATE-START"      then  mParamForm:init-DATE-START  = date(entry(2,entry(Jv,param-universal ),"="))  .
   if caps(trim(entry(Jv,param-universal))) begins "X-DATE-END"        then  mParamForm:init-DATE-END    = date(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-DATE-ALONE"      then  mParamForm:init-DATE-ALONE  = date(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SHIFT-ALONE"     then  mParamForm:init-Shift-ALONE = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SHIFT-START"     then  mParamForm:init-Shift-Start = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SHIFT-END"       then  mParamForm:init-Shift-End   = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-CUSTOMER-NAME"   then  customer-name    = entry(2,entry(Jv,param-universal ),"=") . /* имя блока выбор контрагента */
   if caps(trim(entry(Jv,param-universal))) begins "X-CUSTOMER-TYPE"   then  customer-type    = entry(2,entry(Jv,param-universal ),"=") . /* фильтр для справочника контрагента */
   if caps(trim(entry(Jv,param-universal))) begins "X-SCHET-NAME"      then  schet-name       = entry(2,entry(Jv,param-universal ),"=") .    /* имя блока выбор счета */
   if caps(trim(entry(Jv,param-universal))) begins "X-SCHET-INIT"      then  schet-init       = entry(2,entry(Jv,param-universal ),"=") .    /* начальное значение счета */
   if caps(trim(entry(Jv,param-universal))) begins "X-SET_PAY_TYPE"    then  mParamForm:init-SET_PAY_TYPE = int(entry(2,entry(Jv,param-universal ),"=")) .    /* начальное значение типа цены прод\ учетная \документа */
   if caps(trim(entry(Jv,param-universal))) begins "X-SET_VAL_TYPE"    then  mParamForm:init-SET_VAL_TYPE = int(entry(2,entry(Jv,param-universal ),"=")) .    /* начальное значение типа валюты */
   if caps(trim(entry(Jv,param-universal))) begins "ED_DATE-REF="      then  ed_date-ref       = entry(2,entry(Jv,param-universal ),"=") .    /* строка для установки справочника привызове универсального триггера на дату ed_date */
   if caps(trim(entry(Jv,param-universal))) begins "parent-handle="    then  mParamObj:parent-handle     = widget-handle(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "all-object"        then  mParamForm:all-object        = true  .
   if caps(trim(entry(Jv,param-universal))) begins "params-only="      then  mParamForm:params-only       = logical(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "params-only-mode=" then  mParamObj:params-only-mode  = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "call="             then  mParamObj:place-call        = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "radio-period="     then  radio-period      = entry(2,entry(Jv,param-universal ),"=") .
 end.
    mDReport:TogExcel:checked =mParamObj:Make-Excel  .
    mDReport:TogListHist:checked = mParamObj:Print-List-Hist  .
      
      local-pre-initialize ().

      if mParamForm:params-only then do:
         if     mParamObj:params-only-mode  = "{&lookup}" 
            or  mParamObj:params-only-mode  =  {&lookup} 
         then do:
            mParamObj:params-only-mode  = {&lookup}.
            mDReport:params-only-mode_lookup(yes).
         end.
         else
            mDReport:params-only-mode_lookup(no).
      end.
      if customer-yes = true then do:
         if trim(customer-name) = "" then mParamForm:temp-param-customer =  "Выбор контрагента" .
                                     else mParamForm:temp-param-customer =  customer-name .
         mParamForm:temp-param-customer-type =  customer-type .
      end.
      else
         assign
            mParamForm:temp-param-customer =  ""
            mParamForm:temp-param-customer-type =  ""
         .

      if schet-yes = true then do:
         if trim(schet-name) = "" then mParamForm:temp-param-schet =  "Выбор счета" .
                                  else mParamForm:temp-param-schet =  schet-name .
         mParamForm:temp-param-schet-hide =  schet-hide .
         mParamForm:temp-param-schet-init =  schet-init .
      end.
      else do:
         assign
            mParamForm:temp-param-schet =  ""
            mParamForm:temp-param-schet-hide = ""
            mParamForm:temp-param-schet-init = ""
         .
      end.
      if ed_date-ref <> '':U 
      then do:
         do v-ii = 1 to num-entries(ed_date-ref, ';'):
            if entry(1, entry(v-ii, ed_date-ref, ';'), {&delim-key}) = 'X-DATE-START':U 
            then
               mParamForm:ref_date-start = entry(2, entry(v-ii, ed_date-ref, ';'), {&delim-key}).
            
            if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-END':U 
            then
               mParamForm:ref_date-end = entry(2, entry(v-ii, ed_date-ref, ';'), {&delim-key}).
            
            if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-ALONE':U 
            then
               mParamForm:ref_date-alone = entry(2, entry(v-ii, ed_date-ref, ';'), {&delim-key}).
      
         end.
      end.
      mParamForm:temp-param-date     = param-date .
      mParamForm:temp-param-goods    = param-goods.
      mParamForm:temp-param-obj      = param-obj.
      mParamForm:temp-param-pay      = param-pay.
      mParamForm:temp-param-pay-hide = param-pay-hide.
      mParamForm:temp-param-alon     = param-alon.
      if mParamForm:temp-param-date = 9 
      then do:
         mParamForm:temp-param-date-type-period = radio-period.
         if    mParamForm:temp-param-date-type-period = ? 
            or mParamForm:temp-param-date-type-period = "" 
         then 
            mParamForm:temp-param-date-type-period = {&period-type-yesterday}.
      end.

      mParamForm:temp-str =  mParamObj:ReportHeader.
      define variable vLog as logical no-undo.
      vLog= true .
      /* Проверка прав на учетные цены */
      if    mParamObj:show-cost = true
         or lookup( "{&p-cost}" , mParamForm:temp-param-pay ) > 0
      then do:
         { gbl/chk-actg.i
            mParamObj:my-cntxt-db-num
            mParamObj:my-cntxt-userid
            {&action-head-code-main}
            "'actn_reports_lookup-cost':U"
            {&cntxt-object}
            mParamObj:my-cntxt-host-code-obj
            mParamObj:my-cntxt-obj-type
            mParamObj:my-cntxt-obj-code
            0
            0
            0
            true
            vLog
         }
         if not vlog
         then do:
            assign
               mParamObj:show-cost  = false
               plase-cost = index (mParamForm:temp-param-Pay , "{&p-cost}" )
               substring(mParamForm:temp-param-Pay,plase-cost) = "0"
            no-error .
         end.
      end.

      /* Проверка прав на продажные цены */
      if    mParamObj:show-crsa = true
         or lookup( "{&p-crsa}" , mParamForm:temp-param-pay ) > 0
      then do:
         { gbl/chk-actg.i
            mParamObj:my-cntxt-db-num
            mParamObj:my-cntxt-userid
            {&action-head-code-main}
            "'actn_reports_lookup-crsa':U"
            {&cntxt-object}
            mParamObj:my-cntxt-host-code-obj
            mParamObj:my-cntxt-obj-type
            mParamObj:my-cntxt-obj-code
            0
            0
            0
            no
            vlog
         }
         if not vlog
         then do:
            /* Если прав нет то .....*/
            assign
               mParamObj:show-crsa  = false
               plase-crsa = index (mParamForm:temp-param-pay , "{&p-crsa}" )
               substring(mParamForm:temp-param-pay,plase-crsa) = "0"
            no-error.
         end.
      end.

      /* Проверка прав на цены документа */
      if    mParamObj:show-sale = true
         or lookup( "{&p-sale}" , mParamForm:temp-param-pay ) > 0
      then do:
         { gbl/chk-actg.i
            mParamObj:my-cntxt-db-num
            mParamObj:my-cntxt-userid
            {&action-head-code-main}
            "'actn_reports_lookup-sale':U"
            {&cntxt-object}
            mParamObj:my-cntxt-host-code-obj
            mParamObj:my-cntxt-obj-type
            mParamObj:my-cntxt-obj-code
            0
            0
            0
            no
            vlog
         }
         if not vlog
         then do:
            /* Если прав нет то .....*/
            assign
               mParamObj:show-sale  = false
               plase-sale = index (mParamForm:temp-param-pay , "{&p-sale}" )
               substring(mParamForm:temp-param-pay,plase-sale) = "0"
            no-error .
         end.
      end.

      initilize-page-3 () .
      
      define variable vObjVis as logical no-undo.
      define variable vCurrVis as logical no-undo.
      define variable vCustVis as logical no-undo.
      define variable vShctvis as logical no-undo.
      define variable vshftVis as logical no-undo.
      define variable vGoodVis as logical no-undo.
      Vobjvis = mParamForm:temp-param-obj ne "".
      vCurrVis = mParamForm:temp-param-pay ne "" or  mParamForm:temp-param-pay-hide ne "".
      vCustVis = mparamform:temp-param-customer ne "".
      vShctvis = mParamForm:temp-param-schet ne "".
      vshftVis = mparamForm:temp-param-date ne 0.
      vGoodVis = mparamForm:temp-param-goods ne "".
      mObj:visible      = Vobjvis.
      mCurrency:visible = vCurrVis .
      mCustomer:visible = vCustVis.
      mSchet:visible    = vShctvis.
      mShift:visible    =  vshftVis.
      mGoods:visible    =  vGoodVis.
      mdreport:splitContainer5:Panel2Collapsed = not vCurrVis.
      mdreport:splitContainer3:Panel2Collapsed = not vShctvis.
      
      mdreport:splitContainer1:Panel2Collapsed = not vCustVis.
      mdreport:splitContainer2:Panel1Collapsed = not vGoodVis.
      if not vshftVis and not vCurrVis
      then do:
         mdreport:splitContainer5:visible = no.
         mdreport:splitContainer1:Dock = System.Windows.Forms.DockStyle:fill.
      end.
      
end method .
 
method private void  initilize-page-3 ():
   define variable temp-str- as character no-undo .
   define variable temp-i as integer no-undo .
   define variable  l-ind as integer no-undo .
   define variable v-nn as integer no-undo.
   define variable v-nn2 as integer no-undo.
   find first ubflt.usr-flt no-lock where
         ubflt.usr-flt.user-name  = mParamObj:my-cntxt-userid and
         ubflt.usr-flt.call-point = mParamObj:ReportProc  no-error .

   if available ubflt.usr-flt 
   then  do:
      v-nn = num-entries( ubflt.usr-flt.list_) .

      repeat l-ind = 1 to v-nn :
         if entry(1,entry(l-ind, ubflt.usr-flt.list_),"=")  = "ReportPageHeight":U 
         then do:
            mParamObj:ReportPageHeight = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
            if error-status :error  then message "qq1" .
         end.

         if entry(1,entry(l-ind,ubflt.usr-flt.list_),"=")  = "ReportPageWidth":U 
         then do:
            mParamObj:ReportPageWidth = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
            if error-status :error  then message "qq2" .
         end.

         if entry(1,entry(l-ind, ubflt.usr-flt.list_ ),"=")  = "Use-Column":U 
         then do :
            temp-str- = entry( 2 , entry(l-ind, ubflt.usr-flt.list_)  ,"=" ) no-error .
            if error-status :error  then message "qq3" .
            v-nn2 = num-entries ( temp-str- , ";") .
            repeat temp-i = 1 to v-nn2:
               if temp-i <= 50 
               then
                  mParamObj:use-column[temp-i] = ( if trim(entry(temp-i,temp-str-,";")) = "true" then true else false) .
            end.
         end.

                    

      end.
   end.
   else
      assign 
         mParamObj:ReportPageHeight = 0 
         mParamObj:ReportPageWidth  = 0
      .
    mDReport:mlistf:op-br() no-error.
    


end method.
   
   method public void FormRun () :
      FormRun(procname).
   end method.
   
   method public void FormRun (iClass as character) :
      
      mDReport = new ibs.th.ref.sobj.dreport (input iClass, input this-object). 
      
      local-initialize ().
      
      wait-for System.Windows.Forms.Application:Run ( mDReport ) .
  
      define variable v-err-msg as character no-undo .  
      catch exAppErrors as class Progress.Lang.AppError :
         v-err-msg = exAppErrors:ReturnValue .
         if v-err-msg > "" then . else do :
            v-err-msg = exAppErrors:GetMessage(1) . 
            if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
         end .
         message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
      end catch .
    
      catch exProErrors as class Progress.Lang.ProError :
         v-err-msg = exProErrors:GetMessage(1) . 
         if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
         message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
      end catch .
    
      catch exAnyErrors as class Progress.Lang.Error:
         v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
         message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
      end catch .
  
      finally: 
         if valid-object(mDReport) then delete object mDReport no-error .
      end finally.  
    
   end method .
 
   method public void blbt
   ():
      AssignParam().
      Assign-frame().


      if not param-alon
      then do:
        /*if format-folder
        then do:
           run get-var-2 in h_format no-error.
           { rep/link-err.i 2}
        end.*/
         mUserframe:my-var().
    
      end.
      define variable mform as class ibs.th.ref.sobj.rprev no-undo.

      mform = new ibs.th.ref.sobj.rprev ().
      mform:ParamObj = mParamObj.
      wait-for mform:ShowDialog() .
  
      define variable v-err-msg as character no-undo .  
      catch exAppErrors as class Progress.Lang.AppError :
         v-err-msg = exAppErrors:ReturnValue .
         if v-err-msg > "" then . else do :
            v-err-msg = exAppErrors:GetMessage(1) . 
            if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
         end .
         message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
      end catch .
    
      catch exProErrors as class Progress.Lang.ProError :
         v-err-msg = exProErrors:GetMessage(1) . 
         if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
         message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
      end catch .
    
      catch exAnyErrors as class Progress.Lang.Error:
         v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
         message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
      end catch .
  
      finally: 
         if valid-object(mform) then delete object mform no-error .
      end finally.  
    
  
   end.
   
   method public void bOk    ():
      if mparamform:params-only 
      then do:
         proc-save-param-RUM() no-error.
         if error-status :error 
         then do:
            return .
         end.
      end.
      else do:
         run trg/userlog.p (
             input "report":U
           , input namereport + {&delim-key} + procname 
           , input ?
           , input ?
           , input ""
          ) no-error.
          if error-status :error
          then do:
              message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
          end.    
   

         print-report() no-error .
         if error-status :error
         then do:
            return .
         end.
         return no-apply .
      end.
       
   end method.
  
    
   method private void local-initialize-s ():
/* ??????   */
/*      DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.*/
/*      ASSIGN parParentProc = my-handle.*/
/* do with frame {&frame-name}:*/

/*  end. /* do with frame */*/
/*{ gbl/basecode.i   v-cntxt-host-code-obj base-code }*/
/*run take-var in this-procedure .*/

/*   SetVar().*/
  /* Dispatch standard ADM method.                             */
/*  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .*/
   local-apply-layout().
   Assign-frame().
  /* Code placed here will execute AFTER standard behavior.    */
      
      mobj:local-initialize(mparamobj).
      mCurrency:local-initialize(mparamobj).
      mSchet:local-initialize(mparamobj).
      if mparamobj:Make-Excel 
      then do:
         mDReport:TOGExcel:checked = true .
         mDReport:TOGExcel:Enabled = no.
         mDReport:TOGExcel:visible = yes.
      end.
      else do:
/*         mDReport:TOG-Excel:checked = true .*/
         mDReport:TOGExcel:Enabled = no.
         mDReport:TOGExcel:visible = no.
      end.
      if mparamobj:Print-List-Hist 
      then do:
         mDReport:TOGListhist:checked = true .
         mDReport:TOGListhist:Enabled = yes.
         mDReport:TOGListhist:visible = yes.
      end.
      else do:
         mDReport:TOGListhist:Enabled = no.
         mDReport:TOGListhist:visible = no.
      end.

  
   end method.
   
   
method private void local-initialize ():
   define variable par-type  as character no-undo .   /* тип параметра конфигурации */
   define variable p-actuate as logical   no-undo .
   define variable vreport-num as integer  no-undo.
   run get-report-num   in parParentProc(output vreport-num).
   mParamObj:my-g#report-num = vreport-num.
   mParamObj:my-handle = parParentProc.
   setVar().
   local-initialize-s().
/*run dispatch in THIS-PROCEDURE ( input 'initialize':U ) .*/
   assign 
      mParamObj:ReportName = if mUserframe:namereport ne "" then mUserframe:namereport else  namereport 
      mParamObj:ReportProc = if mUserframe:procname   ne "" then mUserframe:procname   else  procname
   .
   mDReport:Text  = trim(namereport).
   if mParamForm:params-only then do:
      if mParamObj:params-only-mode  = {&lookup} then do:
         mDReport:Text  = substitute("Просмотр ПАРАМЕТРОВ отчета:  &1" ,  trim( mParamObj:ReportName ) ) .
      end.
      else do:
         mDReport:Text  = substitute("Задание ПАРАМЕТРОВ отчета:  &1" ,  trim( mParamObj:ReportName ) ) .
      end.
   end.

   { gbl/getsect.i run "''" 0 {&attr-report-glob} }
   for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'actuate'  then p-actuate   = thbjattr_thbj-attr.property-value-logical .
   end.

   if p-actuate
   then do:
      if param-Alon = false
      then do: /* если есть 2 и более закладок */
/*         run select-page in this-procedure ( 2 ) no-error.*/
/*         run select-page in this-procedure ( 1 ) no-error.*/
          make-btn    ().
      end.
   end.
  /* else do:
     run select-page in this-procedure
       (input 1
       ) no-error .
   end.*/

   if mParamForm:params-only  then do:
/*      if mParamForm:param-Alon = false
      then do: /* если есть 2 и более закладок */
          run select-page in this-procedure ( 2 ) no-error.
      end.
    /*888*/
      run select-page in this-procedure ( 1 ) no-error .*/
      mUserframe:my-params ( input "get" ) no-error .
      local-apply-layout ().
  end.



end .

method private void make-btn ():
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
   mDReport:b_ach:Visible = mUserframe:report-to-ach (yes).
       /* есть ли выброс в АКЧУэйт  */
   /* message error-status :get-message(1) . */
  /* if not error-status :error
   then do:
        create button b_ach
        assign row = 1
        column = 23
        height-chars = 1
        width-chars  = 15
        label = "Actuate"
        tooltip = "выполнение отчета при помощи внешней программы"
        frame = frame {&frame-name}:handle
        sensitive = true
        visible = true
        triggers:
              on choose persistent run make-ach.
        end triggers.
   end.
*/

  end.  /* do */
end .


METHOD public void my_select():
AssignParam ().    
Assign-frame().    
end.


method private void AssignParam ():
   define variable vtext as character no-undo.
   /* проверка правильности интервала дат */
   vtext = mShift:AssignParam() no-error.
   if error-status :error
   then do:
      undo, return error vtext .
   end.

  /* проверка правильности объекта (что он выбран) */
   vtext = mObj:AssignParam() no-error.
   if error-status :error
   then do:
      undo, return error vtext .
   end.
 
   vtext = mGoods:AssignParam() no-error.
   if error-status :error
   then do:
      undo, return error vtext .
   end. 
   
   mparamObj:make-6-gds-list().
   
   
   
/* должны быть еще проверки */
end.
{rep/par-actu.i}
method public void make-ach ():
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
   do
   on error undo, return error return-value
   :
      mUserframe:my-var().  /* есть ли выброс в АКЧУэйт  */
      AssignParam().
      mUserframe:report-to-ach (no ) .  /* есть ли выброс в АКЧУэйт  */
      mParamObj:get-param-to-export(output table param-to-export ).
      if error-status :error = true then return error .

      define variable exp-name as character no-undo .
  /* создается временный командный файл для выполнения команды */

      run gbl/_tmpfile.p ( "t", ".par", output exp-name) .
/*
  message "параметры запуска в файле " exp-name
  .
*/

      output STREAM str-export TO  VALUE(exp-name).

      for each param-to-export :
         export stream str-export param-to-export .
      end.

      output STREAM str-export CLOSE.

      define variable res as integer no-undo .
      define variable name-exe as character no-undo .

      assign
         file-info:file-name = "exe/run-act.bat".
         name-exe = file-info:full-pathname
      no-error .
      if error-status :error then return error .

      run gbl/syn.p ( input name-exe , input  exp-name , input  "Запуск " + name-exe , output res ).
      if  res > 0 
      then do:
         message  "Ошибка  при выполнении команды в ОС "  res .
      end.

   end.  /* do */
end method.

method private void  return-var () :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  mListF:Save-table() no-error.
  mFormat:get-var() no-error.
  mUserframe:my-var() no-error.

end method.
method private void select-page(inum as integer ):
   
end.

method private void proc-save-param-RUM () :
/* -----------------------------------------------------------
  Purpose: СОХРАНЕНИЕ параметров отчета в БД по ПРАВИЛАМ RUM
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  

  /* считывание всех переменных с экрана */
  AssignParam().
  Assign-frame().

  /* составление списка товаров по производителям и группам */
  

   if param-alon = false   
   then do:
      initilize-page-3 () .
      return-var () .
      if   (   mParamObj:reportpageheight = 0  
            or mParamObj:reportpagewidth = 0
            )
         and mParamForm:format-folder
      then do:
         /* выбрать страницу 3 (формат)*/
         select-page(3) .
         undo, return error return-value .
      end.
   end.
   mUserframe:my-var () no-error.
   if error-status:error then
   do:
      case return-value:
         when 'First-page':U then  do:
            return error.
         end.
         when 'Second-page':U then  do:
            message "Проверьте правильность заполнения формы!".
            select-page ( 2 ).
            return  error .
         end.
         when 'format-page' then do:
            message "Необходимо сходить на закладку <Формат...> !".
            select-page ( 3 ).
            return error.
         end.
         otherwise  do:
            message "Необходимо сходить на закладку <Продолжение...> !".
            select-page ( 2 ).
            return error.
         end.
      end case.
   end.
  

   mUserframe:my-params ( input "set" ) no-error .
   if error-status:error then
   do:
      case return-value:
         when 'First-page':U then  do:
            return error.
         end.
         when 'Second-page':U then  do:
            message "Проверьте правильность заполнения формы!".
            select-page ( 2 ).
            return  error .
         end.
         when 'format-page' then do:
            message "Необходимо сходить на закладку <Формат...> !".
            select-page ( 3 ).
            return error.
         end.
         otherwise  do:
            message "Необходимо сходить на закладку <Продолжение...> !".
            select-page ( 2 ).
            return error.
         end.
      end case.
   end.


end method.

  
method private void print-report ():
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

   define variable choice             as logical   no-undo .
   define variable v-total-archive-ok as logical   no-undo .
   define variable v-archive-ok       as logical init true  no-undo .
   define variable v-comment          as character no-undo .
   define variable v-can-print        as logical   no-undo .
   define variable temp-date      as date no-undo.
   define variable temp-shift     as integer no-undo .
   define variable v-date-start as date      no-undo .
   define variable v-date-end   as date      no-undo .
   define variable spis-obj     as character no-undo .

  /* считывание всех переменных с экрана */
   AssignParam()  .
   Assign-frame().

   v-total-archive-ok = true.

  /* Проверка наличия финансовых архивов */
   if mParamForm:verify-arc-fin = true 
   then do: 
      define variable p-status       as integer   no-undo .
      define variable p-cut-date     as date      no-undo .
      define variable p-cut-fin-date as date      no-undo .
      { gbl/cutd-db.i mParamObj:my-cntxt-db-num p-status p-cut-date p-cut-fin-date no-error }
      if param-date = 1
      then do:
         assign
            v-date-start = mParamObj:x-date-alone
            v-date-end   = mParamObj:x-date-alone
        .
      end.
      else do:
        assign
          v-date-start = mParamObj:x-date-start
          v-date-end   = mParamObj:x-date-end
        .
      end.

      if p-cut-date <> ? and ( v-date-start < p-cut-date  or v-date-end < p-cut-date) 
      then do:  /* было обрезание */
         message
            "ВНИМАНИЕ!" skip
            "БД была обрезана на " string(p-cut-fin-date, "99/99/9999")  skip
            "Данные в отчете будут не корректны." skip
            "Продолжить формирование отчета?" skip
         view-as alert-box question
            buttons yes-no
            title "Финансовые архивы"
            update choice .

         if choice = false
         then do:
            assign
               v-total-archive-ok = false
            .
            undo, return error return-value .
         end.
         else do:
            if param-date = 1 
            then do:
               v-date-end = p-cut-fin-date .
            end .
            else do:
               v-date-start = p-cut-fin-date .
               v-date-end   = p-cut-fin-date .
            end.

            v-total-archive-ok = true .
         end.
      end.
   end.

   /* Проверка наличия межфирменных архивов */
   if mParamForm:verify-arc-hold = true
   then do:
      if param-date = 1
      then do:
         assign
            temp-date = mParamObj:x-date-alone
         .
      end.
      else do:
         TEMP-DATE = mParamObj:x-Date-End .
      end.

      run trg/bt_hold.p
         (input  temp-date      /* p-last-date         */
         ,input  true           /* p-check-act         */
         ,input  mParamObj:my-cntxt-db-num /* p-check-act-db-num  */
         ,input  mParamObj:my-cntxt-userid /* p-check-act-user-id */
         ) no-error .
      if error-status :error
      then do:
         message
            "ВНИМАНИЕ!" skip
            "Межфирменные архивы" skip
            return-value skip
            "Данные по выбранному периоду могут быть неполными или некорректными."
            "Продолжить формирование отчета?" skip
         view-as alert-box question buttons yes-no update choice .
         if choice = false
         then do:
            v-total-archive-ok = false.
         end.
         else do:
            v-total-archive-ok = true.
         end.
      end.
   end.

   if    mParamForm:verify-arc-ot   = true
      or mParamForm:verify-arc-stk  = true
      or mParamForm:verify-arc-aht  = true
      or mParamForm:verify-arc-supp = true
   then do:

      if    mParamForm:verify-arc-ot = true
        and mParamForm:verify-arc-stk <> true
      then do:
         mParamForm:verify-arc-stk = true.
      end.

      spis-obj = "" .
      v-total-archive-ok  = true .
      mParamObj:get-obj-list(output table  obj-list).
      for each obj-list no-lock :
         if param-date = 1
         then do:
            assign
               v-date-start = mParamObj:x-date-alone
               v-date-end   = mParamObj:x-date-alone
            .
         end.
         else do:
            assign
               v-date-start = mParamObj:x-date-start
               v-date-end   = mParamObj:x-date-end
            .
         end.

         run rep/chk-ahz.p
            (input        obj-list.obj-type            /* p-obj-type          */
            ,input        obj-list.obj-code            /* p-obj-code          */
            ,input        mParamForm:verify-arc-ot     /* p-verify-detail     */
            ,input        mParamForm:verify-arc-stk    /* p-verify-arh        */
            ,input        mParamForm:verify-arc-supp   /* p-verify-ahsp       */
            ,input        mParamForm:verify-arc-aht    /* p-verify-aht        */
            ,input        true                         /* p-check-act         */
            ,input        mParamObj:my-cntxt-db-num    /* p-check-act-db-num  */
            ,input        mParamObj:my-cntxt-userid    /* p-check-act-user-id */
            ,input-output v-date-start                 /* p-date-start        */
            ,input-output v-date-end                   /* p-date-end          */
            ,output       v-archive-ok                 /* p-archive-ok        */
            ,output       v-comment                    /* p-comment           */
            ,output       v-can-print                  /* p-can-print         */
         ) .
         if v-archive-ok = false
         then do:
            if     v-can-print = false 
               or  mParamForm:verify-arc-strong  = true
            then do:
               message
                  "ВНИМАНИЕ !!!" skip
                  "Отчет не может быть сформирован!" skip
                  "На запрошенную дату нет архивов или они сжаты" skip
                  v-comment skip
               view-as alert-box information .

               select-page (1).
            
               undo, return error return-value .
            end.
            else do:     /* можно печатать */
               assign
                  v-total-archive-ok = false
                  spis-obj =  spis-obj + substitute("&1&2," , obj-list.obj-type , obj-list.obj-code)  /* Кривые объекты*/
               .
            end.
         end.
      end.

      spis-obj = trim(spis-obj, ',') .

      if v-total-archive-ok = false
      then do:
         define variable v-period-description as character no-undo .

         if param-date = 1
         then do:
            assign
               v-period-description = substitute("на конец дня &1"
                                           ,string(mParamObj:x-date-end, '99/99/9999':u)
                                           )
            .
         end.
         else do:
            assign
               v-period-description = substitute("с начала дня &1 по конец дня &2"
                                           ,string(mParamObj:x-date-start, '99/99/9999':u)
                                           ,string(mParamObj:x-date-end,   '99/99/9999':u)
                                           )
            .
         end.

         message
            "ВНИМАНИЕ!" skip
            v-comment skip
            spis-obj skip
            "" skip

            "Данные по выбранному периоду" v-period-description "могут быть неполными или некорректными." skip
            "Продолжить формирование отчета?" skip
         view-as alert-box question buttons yes-no update choice .
         if choice = false
         then do:
            v-archive-ok = false.
            return.
         end.
         else do:
            v-total-archive-ok = true.
         end.
      end.
   end.

   if v-total-archive-ok = true
   then do:
      if param-alon = false
      then do:
         initilize-page-3 ().
         return-var () .
         if    (mParamObj:reportpageheight = 0  or mParamObj:reportpagewidth = 0)
            and mParamForm:format-folder
         then do:
            select-page (3) no-error .
            /* message "Задайте значения для размера страницы отчета !". */
            undo, return error return-value .
         end.
      end.
      mUserframe:my-var () no-error.
      if error-status:error 
      then do:
         case return-value:
            when 'First-page':U 
            then  do: 
               return .
            end.
            when 'Second-page':U then  do:
                message "Проверьте правильность заполнения формы!".
                select-page ( 2 ).
                return.
            end.
            when 'format-page' then do:
               message "Необходимо сходить на закладку <Формат...> !".
               select-page( 3 ).
               return no-apply.
            end.
            otherwise  do:
               message "Необходимо сходить на закладку <Продолжение...> !".
               select-page  ( 2 ).
               return no-apply.
            end.

         end case.
      end.
   end.

   if v-archive-ok = false and
        (  mParamForm:verify-arc-ot   = true
        or mParamForm:verify-arc-stk  = true
        or mParamForm:verify-arc-aht  = true
        or mParamForm:verify-arc-supp = true )

   then do:
      assign
         mParamObj:reportheader = mParamObj:reportheader + {&new-line}
                     + "Архивы рассчитаны не полностью. Информация в отчете может быть неполной или некорректной."
                     + {&new-line} +
                     (if spis-obj <> "" then substitute("Не корректная информация об архивах на объектах: &1" ,spis-obj ) else "")

      .
   end.

/*   G#rep-updflds = mParamObj:ReportName + " " + str1 .*/
   mParamObj:d-report-handle = d-report-handle .
    /* вызов отчета */
   if param-Alon
   then do:
      openforexcel () .
      if num-entries (trim(procname), " " ) > 1  
      then do:
         define variable p-proc-par1 as character no-undo .
         define variable p-proc-par2 as character no-undo .

         assign
            p-proc-par1 = entry(1, procname, " ")
            p-proc-par2 = entry(2, procname, " ")
         .

         run value ( p-proc-par1 )
            (input p-proc-par2,
             input mparamObj ).
      end.
      else do:
         run value ( procname ) (input mparamObj). /* если закладка одна */
      end.

      CloseForExcel () .
   end.
   else do:
/*      OpenForExcel ().*/
      mUserframe:my-report () no-error .  /* вызов отчета с параметрами*/
      if error-status:error 
      then do:
         case return-value:
            when 'First-page':U 
            then  do: 
               return .
            end.
            when 'Second-page':U then  do:
                message "Проверьте правильность заполнения формы!".
                select-page ( 2 ).
                return.
            end.
            when 'format-page' then do:
               message "Необходимо сходить на закладку <Формат...> !".
               select-page( 3 ).
               return no-apply.
            end.
            otherwise  do:
               message "Необходимо сходить на закладку <Продолжение...> !".
               select-page  ( 2 ).
               return no-apply.
            end.

         end case.
      end.
      CloseForExcel().
   end.
/*      run set-cursor in adm-broker-hdl ("").*/
   
   run prg-bar_delete-progress-bar in mParamObj:d-report-handle .
   mParamObj:d-report-handle = ? .
   
end .
   
   method public void VALUE-CHANGED_TOG-Excel(iTogExcel as logical) /* Есть экспорт в Excel */
   :
      mParamObj:Make-Excel = iTogExcel.
      new-state ( "TOG-EXCEL ="  + String(iTogExcel)).
   end.
   
   method public void  VALUE-CHANGED_TOG-list-hist(iTog-list-hist as logical) /* Печать истории формир. списков */
   :
      mParamObj:print-list-hist = iTog-list-hist.
      new-state ("TOG-list-hist ="  + String(iTog-list-hist)).
   end.
   
   method private void new-state(istate as character ):
   end.
   
   method public void setparam(
         iparParentProc  as handle,
         iprocname       as character , /* имя процедуры на 2 закладке  */
         inamereport     as character , /* имя процедуры на 2 закладке  */
         iparam-date     as integer   , /* Дата  1 2 3 */
         iparam-goods    as character , /* Товары */
         iparam-obj      as character , /* Объекты */
         iparam-pay      as character , /* Цены */
         iparam-pay-hide as character , /* Цены - какие цены не паказывать*/
         iparam-universal as character , /* многое другое см документ vss Использование d-report*/
         iparam-alon     as logical    /* 1 закладка*/):
      assign
         parParentProc     = iparParentProc 
         procname          = iprocname
         namereport        = inamereport
         param-date        = iparam-date
         param-goods       = iparam-goods
         param-obj         = iparam-obj
         param-pay         = iparam-pay
         param-pay-hide    = iparam-pay-hide
         param-universal   = iparam-universal
         param-alon        = iparam-alon
      .
      
   end.
  /* 
   
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-param-RUM W-Win
procedure proc-save-param-RUM :
/* -----------------------------------------------------------
  Purpose: СОХРАНЕНИЕ параметров отчета в БД по ПРАВИЛАМ RUM
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* проверка правильности интервала дат */
  run verify-date in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  /* проверка правильности объекта (что он выбран) */

  run verify-obj in h_main no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  /* считывание всех переменных с экрана */
  run assign-frame in h_main .

  /* составление списка товаров по производителям и группам */
  run make-6-gds-list in h_main .

  if param-alon = false   then do:
    run initilize-page-3 in this-procedure .
    run return-var in this-procedure .
    if  (reportpageheight = 0  or reportpagewidth = 0)
    and format-folder
    then do:
      run get-var-2 in h_format no-error.
      if (reportpageheight = 0  or reportpagewidth = 0)
      then do:
        run select-page in this-procedure
          (input 3
          ) no-error .
        undo, return error return-value .
      end.
    end.
    run my-var in h_special no-error.
    if error-status:error then
     do:
        case return-value:
            when 'First-page':U then  do:
                return error.
            end.
            when 'Second-page':U then  do:
                  message "Проверьте правильность заполнения формы!".
                  run select-page in this-procedure ( 2 ).
                  return  error .
            end.
            when 'format-page' then do:
                  message "Необходимо сходить на закладку <Формат...> !".
                  run select-page in this-procedure ( 3 ).
                  return error.
            end.
            otherwise  do:
                message "Необходимо сходить на закладку <Продолжение...> !".
                run select-page in this-procedure ( 2 ).
                return error.
            end.
        end case.
     end.
  end.

  run my-params in h_special ( input "set" ) no-error .
  { rep/link-err.i }


end procedure.
    */

end class.

   

  
