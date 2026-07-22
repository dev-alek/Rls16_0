 
 /*------------------------------------------------------------------------
    File        : sGoods_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Lastochka
    Created     : Sun May 10 22:26:09 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.
 
class ibs.th.ref.sobj.sGoods_trg: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   {cmp\str-glbl.i class}
    {cmp\r-page-pre.i}
   define variable vss-revision    as character no-undo initial "$Revision$":U .
   define variable vss-author      as character no-undo initial "$Author$":U .
   define variable vss-date        as character no-undo initial "$Date$":U .
   define variable vss-workfile    as character no-undo initial "$Workfile$":U .
   define variable vss-archive     as character no-undo initial "$Archive$":U .
   define variable vss-description as character no-undo init "Форма выбора товаров". 

   define property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.
   define property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   define property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   define variable keep-spis as character no-undo.

   method public void CHOOSE_BUTTON-gds (/*output lns-cnt as integer ,output s-notes as char */): /* BUTTON-gds */

      if not Paramform:params-only then do:
         ParamObj:empty-gds-list().
      end.

      run str/gds-list.w ( input ParamObj:my-handle, input ParamObj:my-cntxt-host-code-obj, input ParamObj:my-cntxt-obj-type, input ParamObj:my-cntxt-obj-code ).
      ParamObj:get-glob-gds-list().
      ParamObj:get-glob-gds-list-hist().
      /*
      lns-cnt = ParamObj:get-count-gds-list() .
      s-notes =  ParamObj:get-s-notes() .
  
*/
 
   end.

   method public void  choose_BUTTON-node (): /* BUTTON-node */
     define variable vgdsgrp_recids as character no-undo.
     vgdsgrp_recids = ParamForm:gdsgrp_recids.
      run ref/gds-grp.w
      (             input ParamObj:my-handle
                   ,input "b-sel,b-mark"
                   ,input ParamObj:my-cntxt-obj-type
                   ,input ParamObj:my-cntxt-obj-code
                   ,input-output vgdsgrp_recids ).
      ParamForm:gdsgrp_recids = vgdsgrp_recids.
   end.
   
   method public logical choose_BUTTON-node-2 (): /* Button node 2 */
      define variable vgdsgrp_recids as character no-undo.
      vgdsgrp_recids = ParamForm:gdsgrp_recids.
      run ref/gds-grp.w
      (              input ParamObj:my-handle
                    ,input "b-sel,b-mark"
                    ,input ParamObj:my-cntxt-obj-type
                    ,input ParamObj:my-cntxt-obj-code
                    ,input-output vgdsgrp_recids ).
      ParamForm:gdsgrp_recids = vgdsgrp_recids.
      return num-entries(ParamForm:gdsgrp_recids) > 0 .
   end.

   method public logical set_SelectGood (iSelectGood as integer ):
      paramobj:x-SelectGood = iSelectGood.
   end method.

   method public logical set_GoodsEditor (iGoodsEditor as character  ):
      paramobj:x-Goods-Editor = iGoodsEditor.
   end method.
      
   method public logical set_TextLb (itext as character ):
      paramobj:x-text-Goods = itext.
   end method.
   
   method public logical selXSelectGood (output t-str as character,output goods-count as character ):

      define variable grp_name    as char. /*inc*/
      define buffer buf_gds-grp for ub.gds-grp .
      
      define variable my-c as int no-undo.
      define variable lns-cnt as integer no-undo.
      if paramform:temp-param-goods <> "" 
      then do:
         case paramobj:x-SelectGood :
            when {&g-all} then t-str = " По всем товарам ".
            when {&g-grp} then do:
               t-str = " По группам " + ParamObj:create_tmp#grp(ParamForm:gdsgrp_recids ) .
                 
               if num-entries( ParamForm:gdsgrp_recids ) > 0 then
                   goods-count = "выбрано " + string(num-entries( ParamForm:gdsgrp_recids )) + " групп " .
                   else goods-count = "НЕ выбрано !!!".
               end.
            when {&g-prod} then do:
               t-str = ''.
               t-str = " По производителям " + Paramobj:Get_text_g#cli(output my-c) .
               if my-c > 0 
               then
                  goods-count = "выбрано " + String(my-c) .
               else 
                  goods-count = "НЕ выбрано !!!".
            end.
            when {&g-choice} then do:
               lns-cnt = Paramobj:get-gds-list-count().
               if lns-cnt ne 0 then do:
                  t-str = " По списку товаров " +  Paramobj:get-gds-list-note().
                  goods-count = "выбрано " + String(lns-cnt) .
               end.
               else assign goods-count = "НЕ выбрано !!!" t-str = "" .
            end.
            when  {&g-spis}  then do:
               lns-cnt = Paramobj:get-gds-list-count().
               if  keep-spis <> "" then do:
                  t-str = Paramobj:get-gds-list-note().
                  goods-count = "выбрано списков : " + String(lns-cnt) .
               end.
               else assign goods-count = "НЕ выбрано !!!" t-str = "" lns-cnt = 0 .
            end.
            when {&g-one} then do:
               if Paramobj:get-gds-list-one() ne  ? 
               then assign t-str = " " +  Paramobj:get-gds-list-one() goods-count = "выбран 1 товар".
               else assign t-str = ""                                 goods-count = "НЕ выбрано !!!" lns-cnt = 0 .
            end.
            when {&g-grp-prod} then do:
               t-str = " По группам "  + Paramobj:create_tmp#grp(Paramform:gdsgrp_recids).
               t-str = t-str + {&new-line} +  " По производителям " + Paramobj:Get_text_g#cli(output my-c).
               if num-entries( Paramform:gdsgrp_recids ) > 0  and my-c > 0 then do:
                  goods-count = "выбрано " + string(num-entries( Paramform:gdsgrp_recids )) + " групп "
                      + string(my-c) + " производителей " .
               end.
               else goods-count = "НЕ выбрано !!!".
            end.
         end case.
      end.
   end.
   
   

   method public void choose_BUTTON-one (): /* Button one */
      define variable ri-list         as char no-undo .
      define buffer buf_goods for ub.goods .
      run ref/gds-ref.p
          ( paramobj:my-handle
            ,'b-sel'
            ,?             /*p-stat */
            ,?             /*p-list  */
            ,?             /*p-cond  */
            ,?             /*p-rec   */
            ,?             /*p-grp   */
            ,?             /*p-cli-type */
            ,?             /*p-cli-code  */
            ,paramobj:my-cntxt-obj-type    /*p-obj-type  */
            ,paramobj:my-cntxt-obj-code     /*p-obj-code  */
            ,?             /*p-other     */
            , output ri-list) .
      paramobj:create-gds-list(ri-list).
   end.

   method public void choose_BUTTON-prod (iSelectGood as char): /* BUTTON-prod */
      define variable v-ind as integer   no-undo .
      define buffer cli-prod for ub.clients .
      define variable cli-grp_recids as character no-undo .
      define variable vSelectGood as integer  no-undo.
      vSelectGood = sType:SelectGoodInt(iSelectGood).
      if vSelectGood = {&g-prod} 
      then do:
         run ref/cli-all.w
            (  paramobj:my-handle
               , "b-sel,b-mark"
                , {&pro}
                 , {&all}
                , {&current}
                , ?
                , ",,,,,,NO,,"
                , ?
              , output cli-grp_recids ) no-error .
         if error-status :error then
            message vss-workfile vss-revision vss-description skip
                        error-status :get-message(1) skip
                        "Ошибка вызова cli-all.w"
                        view-as alert-box error .

         paramobj:create_g#cli(cli-grp_recids).
      end.
      else do:
         paramobj:empty-g#cli().
         cli-grp_recids = "" .
      end.
   end.


   method public logical choose_BUTTON-prod-2 (iSelectGood as char): /* Button prod 2 */
      define buffer cli-prod for ub.clients .
      define variable v-ind          as integer   no-undo .
      define variable cli-grp_recids as character no-undo .
      define variable vSelectGood    as integer   no-undo.
      
      vSelectGood = sType:SelectGoodInt(iSelectGood).
      if vSelectGood = {&g-grp-prod} 
      then do:
         run ref/cli-all.w
            (  paramobj:my-handle
            ,  "b-sel,b-mark"
            ,  {&pro}
            ,  {&all}
            ,  {&current}
            ,  ?
            ,  ",,,,,,NO,,"
            , ?
            , output cli-grp_recids ) .

         paramobj:create_g#cli(cli-grp_recids).


      end.
      else do:
         paramobj:empty-g#cli().
      end.
      return cli-grp_recids ne "".
   end.

   method public void CHOOSE_BUTTON-keep-spis(output lns-cnt as integer , output s-notes as character ):
      define variable keep-spis as character no-undo.
      ParamObj:empty-gds-list().
      keep-spis = "".
      
      define buffer buf_clob-bind for ub.clob-bind  .
      define variable v-rid-list as character no-undo .
      
      run ref/clobbnds.w ( input ParamObj:my-handle
                    ,input ParamObj:parent-handle
                    ,input 'b-sel' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input ""
                    ,input {&lob-res-list}
                    ,input 'gds-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
      find first buf_clob-bind no-lock where
            recid(buf_clob-bind) = integer(v-rid-list) no-error .
      if available buf_clob-bind then do:
         keep-spis = buf_clob-bind.field-name_ .
         lns-cnt = 1 .
         s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
      end.
      else do:
         keep-spis = "".
         lns-cnt = 0 .
         s-notes = " " .
      end.
      new-state ("KEEP-SPIS="  + string(keep-spis)).
   end.
   
   method public void value-changed_SelectGood (iSelectGood as character ):
      define variable vSelectGood    as integer   no-undo.
      vSelectGood = sType:SelectGoodInt(iSelectGood).
      new-state ("SELECTGOOD="  + String(vSelectGood)).
   end.

   method public void Assign-frame():
      define variable t-str as character no-undo.
      define variable goods-count as character no-undo.
      if ParamForm:temp-param-goods = ""   
      then ParamObj:strGoods = " ".
      else do:
         selXSelectGood(output t-str, output goods-count).
         ParamObj:strGoods = paramobj:x-text-Goods + ": "  + t-str .        /*товар*/.
      end.
   end.

   method private void new-state(istate as character ):
   end.
   
   constructor public sGoods_trg (  ):
      super ().
      
   end constructor.

   destructor public sGoods_trg ( ):

   end destructor.

end class.