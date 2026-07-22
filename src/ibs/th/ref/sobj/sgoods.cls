 
 /*------------------------------------------------------------------------
    File        : sGoods
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Mar 29 19:14:03 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.

block-level on error undo, throw.

class ibs.th.ref.sobj.sGoods inherits UserControl:
   {cmp\str-glbl.i class} 
   {cmp\r-page-pre.i}
   define private variable BtnGds as System.Windows.Forms.Button no-undo.
   define private variable BtnNode2 as System.Windows.Forms.Button no-undo.
   define private variable BtnKeepSpis as System.Windows.Forms.Button no-undo.
   define private variable BtnOne as System.Windows.Forms.Button no-undo.
   define private variable BtnProd as System.Windows.Forms.Button no-undo.
   define private variable BtnNode as System.Windows.Forms.Button no-undo.
   define private variable BtnProd2 as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable GoodsCount as System.Windows.Forms.TextBox no-undo.
   define private variable GoodsEditor as System.Windows.Forms.TextBox no-undo.
   define private variable radioButton6 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton5 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton4 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton3 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton2 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton1 as System.Windows.Forms.RadioButton no-undo.
   define private variable radioButton7 as System.Windows.Forms.RadioButton no-undo.
   define private variable TEXT2 as System.Windows.Forms.Label no-undo.
   define property mTrgLoc as class ibs.th.ref.sobj.sGoods_trg no-undo
   get.
   set.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set(iarg as ibs.th.ref.sobj.stype):
      stype = iarg.
      mTrgLoc:stype = iarg.
      radioButton1:text = iarg:SelectGoodLbl(1).
      radioButton2:text = iarg:SelectGoodLbl(2).
      radioButton3:text = iarg:SelectGoodLbl(3).
      radioButton4:text = iarg:SelectGoodLbl(4).
      radioButton5:text = iarg:SelectGoodLbl(5).
      radioButton6:text = iarg:SelectGoodLbl(6).
      radioButton7:text = iarg:SelectGoodLbl(7).
   end.
   
   define public property SelectGood as character  no-undo
   get:
      return if      radioButton1:checked 
             then    radioButton1:text
             else if radioButton2:checked 
             then    radioButton2:text
             else if radioButton3:checked 
             then    radioButton3:text
             else if radioButton4:checked 
             then    radioButton4:text
             else if radioButton5:checked 
             then    radioButton5:text
             else if radioButton6:checked 
             then    radioButton6:text
             else if radioButton7:checked 
             then    radioButton7:text
             else "".
   end.
   set (iarg as character  ):
      if      iarg eq radioButton1:text
      then            radioButton1:checked = yes .   
      else if iarg eq radioButton2:text
      then            radioButton2:checked = yes . 
      else if iarg eq radioButton3:text
      then            radioButton3:checked = yes . 
      else if iarg eq radioButton4:text
      then            radioButton4:checked = yes .
      else if iarg eq radioButton5:text
      then            radioButton5:checked = yes . 
      else if iarg eq radioButton6:text
      then            radioButton6:checked = yes . 
      else if iarg eq radioButton7:text
      then            radioButton7:checked = yes .
      else
         message "Нет поля " iarg
         view-as alert-box.  
   end.
   
   define public property SelectGood_disable as character  no-undo
   set (iarg as character  ):
      define variable varg as character  no-undo.
      define variable vi as integer no-undo.
      if iarg eq "*" then iarg = "". 
      do vi = 1 to 7:
         if lookup(string(vi),iarg) eq 0
         then do:
            varg = stype:SelectGoodLbl(vi)no-error.
            if      varg eq radioButton1:Text
            then            radioButton1:Enabled = no .   
            else if varg eq radioButton2:Text
            then            radioButton2:Enabled = no . 
            else if varg eq radioButton3:Text
            then            radioButton3:Enabled = no . 
            else if varg eq radioButton4:Text
            then            radioButton4:Enabled = no .
            else if varg eq radioButton5:Text
            then            radioButton5:Enabled = no . 
            else if varg eq radioButton6:Text
            then            radioButton6:Enabled = no . 
            else if varg eq radioButton7:Text
            then            radioButton7:Enabled = no .
         end.
      end.
   end.
   
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   
   set(iarg as ibs.th.ref.sobj.sParamObj):
      mTrgLoc:ParamObj = iarg.
   end.   
   
   define public property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set(iarg as ibs.th.ref.sobj.sParamForm):
      mTrgLoc:ParamForm = iarg.
      ParamForm = iarg.
   end.
   
   define property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
      
   constructor public sGoods (  ):
      
      
      super().
      mTrgLoc = new ibs.th.ref.sobj.sGoods_trg ().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnGds_Click( input sender as System.Object, input e as System.EventArgs ):
		CHOOSE_BUTTON-gds().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnKeepSpis_Click( input sender as System.Object, input e as System.EventArgs ):
		CHOOSE_BUTTON-keep-spis().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnNode2_Click( input sender as System.Object, input e as System.EventArgs ):
		choose_BUTTON-node-2().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnNode_Click( input sender as System.Object, input e as System.EventArgs ):
		choose_BUTTON-node().
		return.

	end method.

   
    

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void BtnProd2_Click( input sender as System.Object, input e as System.EventArgs ):
		choose_BUTTON-prod-2().
		return.

	end method.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:radioButton1 = new System.Windows.Forms.RadioButton().
      this-object:radioButton2 = new System.Windows.Forms.RadioButton().
      this-object:radioButton3 = new System.Windows.Forms.RadioButton().
      this-object:radioButton4 = new System.Windows.Forms.RadioButton().
      this-object:radioButton5 = new System.Windows.Forms.RadioButton().
      this-object:radioButton6 = new System.Windows.Forms.RadioButton().
      this-object:TEXT2 = new System.Windows.Forms.Label().
      this-object:BtnNode = new System.Windows.Forms.Button().
      this-object:BtnProd = new System.Windows.Forms.Button().
      this-object:BtnGds = new System.Windows.Forms.Button().
      this-object:BtnOne = new System.Windows.Forms.Button().
      this-object:BtnKeepSpis = new System.Windows.Forms.Button().
      this-object:BtnNode2 = new System.Windows.Forms.Button().
      this-object:radioButton7 = new System.Windows.Forms.RadioButton().
      this-object:BtnProd2 = new System.Windows.Forms.Button().
      this-object:GoodsEditor = new System.Windows.Forms.TextBox().
      this-object:GoodsCount = new System.Windows.Forms.TextBox().
      this-object:SuspendLayout().
      /*  */
      /* radioButton1 */
      /*  */
      this-object:radioButton1:Location = new System.Drawing.Point(3, 35).
      this-object:radioButton1:Name = "radioButton1".
      this-object:radioButton1:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton1:TabIndex = 0.
      this-object:radioButton1:TabStop = true.
      this-object:radioButton1:Text = "Все".
      this-object:radioButton1:UseCompatibleTextRendering = true.
      this-object:radioButton1:UseVisualStyleBackColor = true.
      this-object:radioButton1:CheckedChanged:Subscribe(this-object:radioButton1_CheckedChanged).
      /*  */
      /* radioButton2 */
      /*  */
      this-object:radioButton2:Location = new System.Drawing.Point(3, 65).
      this-object:radioButton2:Name = "radioButton2".
      this-object:radioButton2:Size = new System.Drawing.Size(118, 24).
      this-object:radioButton2:TabIndex = 1.
      this-object:radioButton2:TabStop = true.
      this-object:radioButton2:Text = "Группы товаров".
      this-object:radioButton2:UseCompatibleTextRendering = true.
      this-object:radioButton2:UseVisualStyleBackColor = true.
      this-object:radioButton2:CheckedChanged:Subscribe(this-object:radioButton2_CheckedChanged).
      /*  */
      /* radioButton3 */
      /*  */
      this-object:radioButton3:Location = new System.Drawing.Point(3, 95).
      this-object:radioButton3:Name = "radioButton3".
      this-object:radioButton3:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton3:TabIndex = 2.
      this-object:radioButton3:TabStop = true.
      this-object:radioButton3:Text = "Производители".
      this-object:radioButton3:UseCompatibleTextRendering = true.
      this-object:radioButton3:UseVisualStyleBackColor = true.
      this-object:radioButton3:CheckedChanged:Subscribe(this-object:radioButton3_CheckedChanged).
      /*  */
      /* radioButton4 */
      /*  */
      this-object:radioButton4:Location = new System.Drawing.Point(3, 125).
      this-object:radioButton4:Name = "radioButton4".
      this-object:radioButton4:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton4:TabIndex = 3.
      this-object:radioButton4:TabStop = true.
      this-object:radioButton4:Text = "Выборочно".
      this-object:radioButton4:UseCompatibleTextRendering = true.
      this-object:radioButton4:UseVisualStyleBackColor = true.
      this-object:radioButton4:CheckedChanged:Subscribe(this-object:radioButton4_CheckedChanged).
      /*  */
      /* radioButton5 */
      /*  */
      this-object:radioButton5:Location = new System.Drawing.Point(3, 155).
      this-object:radioButton5:Name = "radioButton5".
      this-object:radioButton5:Size = new System.Drawing.Size(104, 24).
      this-object:radioButton5:TabIndex = 4.
      this-object:radioButton5:TabStop = true.
      this-object:radioButton5:Text = "Один".
      this-object:radioButton5:UseCompatibleTextRendering = true.
      this-object:radioButton5:UseVisualStyleBackColor = true.
      this-object:radioButton5:CheckedChanged:Subscribe(this-object:radioButton5_CheckedChanged).
      /*  */
      /* radioButton6 */
      /*  */
      this-object:radioButton6:Location = new System.Drawing.Point(3, 185).
      this-object:radioButton6:Name = "radioButton6".
      this-object:radioButton6:Size = new System.Drawing.Size(135, 24).
      this-object:radioButton6:TabIndex = 5.
      this-object:radioButton6:TabStop = true.
      this-object:radioButton6:Text = "Хранимый список".
      this-object:radioButton6:UseCompatibleTextRendering = true.
      this-object:radioButton6:UseVisualStyleBackColor = true.
      this-object:radioButton6:CheckedChanged:Subscribe(this-object:radioButton6_CheckedChanged).
      /*  */
      /* TEXT2 */
      /*  */
      this-object:TEXT2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12)).
      this-object:TEXT2:Location = new System.Drawing.Point(40, 9).
      this-object:TEXT2:Name = "TEXT2".
      this-object:TEXT2:Size = new System.Drawing.Size(125, 23).
      this-object:TEXT2:TabIndex = 6.
      this-object:TEXT2:Text = "Выбор товаров".
      this-object:TEXT2:UseCompatibleTextRendering = true.
      /*  */
      /* BtnNode */
      /*  */
      this-object:BtnNode:Location = new System.Drawing.Point(173, 66).
      this-object:BtnNode:Name = "BtnNode".
      this-object:BtnNode:Size = new System.Drawing.Size(23, 23).
      this-object:BtnNode:TabIndex = 7.
      this-object:BtnNode:UseCompatibleTextRendering = true.
      this-object:BtnNode:UseVisualStyleBackColor = true.
      this-object:BtnNode:Click:Subscribe(this-object:BtnNode_Click).
      /*  */
      /* BtnProd */
      /*  */
      this-object:BtnProd:Location = new System.Drawing.Point(173, 96).
      this-object:BtnProd:Name = "BtnProd".
      this-object:BtnProd:Size = new System.Drawing.Size(23, 23).
      this-object:BtnProd:TabIndex = 8.
      this-object:BtnProd:UseCompatibleTextRendering = true.
      this-object:BtnProd:UseVisualStyleBackColor = true.
      /*  */
      /* BtnGds */
      /*  */
      this-object:BtnGds:Location = new System.Drawing.Point(173, 126).
      this-object:BtnGds:Name = "BtnGds".
      this-object:BtnGds:Size = new System.Drawing.Size(23, 23).
      this-object:BtnGds:TabIndex = 9.
      this-object:BtnGds:UseCompatibleTextRendering = true.
      this-object:BtnGds:UseVisualStyleBackColor = true.
      this-object:BtnGds:Click:Subscribe(this-object:BtnGds_Click).
      /*  */
      /* BtnOne */
      /*  */
      this-object:BtnOne:Location = new System.Drawing.Point(173, 156).
      this-object:BtnOne:Name = "BtnOne".
      this-object:BtnOne:Size = new System.Drawing.Size(23, 23).
      this-object:BtnOne:TabIndex = 10.
      this-object:BtnOne:UseCompatibleTextRendering = true.
      this-object:BtnOne:UseVisualStyleBackColor = true.
      /*  */
      /* BtnKeepSpis */
      /*  */
      this-object:BtnKeepSpis:Location = new System.Drawing.Point(173, 186).
      this-object:BtnKeepSpis:Name = "BtnKeepSpis".
      this-object:BtnKeepSpis:Size = new System.Drawing.Size(23, 23).
      this-object:BtnKeepSpis:TabIndex = 11.
      this-object:BtnKeepSpis:UseCompatibleTextRendering = true.
      this-object:BtnKeepSpis:UseVisualStyleBackColor = true.
      this-object:BtnKeepSpis:Click:Subscribe(this-object:BtnKeepSpis_Click).
      /*  */
      /* BtnNode2 */
      /*  */
      this-object:BtnNode2:Location = new System.Drawing.Point(40, 246).
      this-object:BtnNode2:Name = "BtnNode2".
      this-object:BtnNode2:Size = new System.Drawing.Size(23, 23).
      this-object:BtnNode2:TabIndex = 12.
      this-object:BtnNode2:UseCompatibleTextRendering = true.
      this-object:BtnNode2:UseVisualStyleBackColor = true.
      this-object:BtnNode2:Click:Subscribe(this-object:BtnNode2_Click).
      /*  */
      /* radioButton7 */
      /*  */
      this-object:radioButton7:Location = new System.Drawing.Point(4, 216).
      this-object:radioButton7:Name = "radioButton7".
      this-object:radioButton7:Size = new System.Drawing.Size(192, 24).
      this-object:radioButton7:TabIndex = 13.
      this-object:radioButton7:TabStop = true.
      this-object:radioButton7:Text = "Гр. товаров + Производители".
      this-object:radioButton7:UseCompatibleTextRendering = true.
      this-object:radioButton7:UseVisualStyleBackColor = true.
      this-object:radioButton7:CheckedChanged:Subscribe(this-object:radioButton7_CheckedChanged).
      /*  */
      /* BtnProd2 */
      /*  */
      this-object:BtnProd2:Location = new System.Drawing.Point(115, 246).
      this-object:BtnProd2:Name = "BtnProd2".
      this-object:BtnProd2:Size = new System.Drawing.Size(23, 23).
      this-object:BtnProd2:TabIndex = 14.
      this-object:BtnProd2:UseCompatibleTextRendering = true.
      this-object:BtnProd2:UseVisualStyleBackColor = true.
      this-object:BtnProd2:Click:Subscribe(this-object:BtnProd2_Click).
      /*  */
      /* GoodsEditor */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:GoodsEditor:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:GoodsEditor:Enabled = false.
      this-object:GoodsEditor:Location = new System.Drawing.Point(4, 298).
      this-object:GoodsEditor:Multiline = true.
      this-object:GoodsEditor:Name = "GoodsEditor".
      this-object:GoodsEditor:Size = new System.Drawing.Size(192, 23).
      this-object:GoodsEditor:TabIndex = 16.
      /*  */
      /* GoodsCount */
      /*  */
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:GoodsCount:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:GoodsCount:Enabled = false.
      this-object:GoodsCount:Location = new System.Drawing.Point(4, 272).
      this-object:GoodsCount:Name = "GoodsCount".
      this-object:GoodsCount:Size = new System.Drawing.Size(192, 20).
      this-object:GoodsCount:TabIndex = 17.
      /*  */
      /* sGoods */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:GoodsCount).
      this-object:Controls:Add(this-object:GoodsEditor).
      this-object:Controls:Add(this-object:BtnProd2).
      this-object:Controls:Add(this-object:radioButton7).
      this-object:Controls:Add(this-object:BtnNode2).
      this-object:Controls:Add(this-object:BtnKeepSpis).
      this-object:Controls:Add(this-object:BtnOne).
      this-object:Controls:Add(this-object:BtnGds).
      this-object:Controls:Add(this-object:BtnProd).
      this-object:Controls:Add(this-object:BtnNode).
      this-object:Controls:Add(this-object:TEXT2).
      this-object:Controls:Add(this-object:radioButton6).
      this-object:Controls:Add(this-object:radioButton5).
      this-object:Controls:Add(this-object:radioButton4).
      this-object:Controls:Add(this-object:radioButton3).
      this-object:Controls:Add(this-object:radioButton2).
      this-object:Controls:Add(this-object:radioButton1).
      this-object:Name = "sGoods".
      this-object:Size = new System.Drawing.Size(199, 324).
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   destructor public sGoods ( ):
      delete object mTrgLoc no-error.
   end destructor.
   
   method public void CHOOSE_BUTTON-gds ():
      /*define variable lns-cnt as integer no-undo.
      define variable s-notes as character no-undo.*/
      mTrgLoc:CHOOSE_BUTTON-gds (/*output lns-cnt,output s-notes*/).
      display-count-other () .
   end.
   
   method public void  choose_BUTTON-node (): /* BUTTON-node */
      mTrgLoc:choose_BUTTON-node().
      display-count-other().
   end.
   
   method public void choose_BUTTON-node-2 (): /* Button node 2 */
      if mTrgLoc:choose_BUTTON-node-2()
      then do:
         BtnNode2:BackColor = System.Drawing.SystemColors:Control .
      end.
      else do:
         BtnNode2:BackColor = System.Drawing.SystemColors:ControlDark .
      end.

      display-count-other ()  .
   end.
    
   method public void choose_BUTTON-prod():
      mTrgLoc:choose_BUTTON-prod(SelectGood).
      display-count-other ()  .
   end.
   
   method public logical choose_BUTTON-prod-2():
      define variable vflag as logical no-undo.
      vflag = mTrgLoc:choose_BUTTON-prod-2(SelectGood).
     /* if vflag 
      then RECT-node-2:bgcolor = 3 .
      else RECT-node-2:bgcolor = 8. */
      display-count-other ()  .
   end.
   
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton1_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton2_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton3_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton4_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton5_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton6_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void radioButton7_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		val-goods().
		return.

	end method.

   method public void value-changed_SelectGood ():
       val-goods () .
       mTrgLoc:value-changed_SelectGood(SelectGood).
       
   end.
    
   method private void Display-count (ilns-cnt as integer,i-notes as character ):
      if sType:SelectGoodInt(SelectGood) = {&g-spis} then do:
        assign
          goodscount:Text = '(Выбрано ' + string(ilns-cnt) + ' список)'
          GoodsEditor:Text = i-notes
          .
      end.
      else do:
         if ilns-cnt > 0
         then
            assign
               goodscount:Text = '(Выбрано ' + string(ilns-cnt) + ' товаров)'
               GoodsEditor:Text= i-notes
            .

         else
            assign
               goodscount:Text = ''
               GoodsEditor:Text = ''
            .
      end.
/*  display goods-count Goods-Editor with frame {&FRAME-NAME} .*/
      mTrgLoc:set_GoodsEditor( GoodsEditor:Text).
   end .
   
   method public void choose_BUTTON-one ():
      mtrgloc:choose_BUTTON-one().
      display-count-other().
   end.

   method private void Display-count-OTHER ():
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable t-str as character no-undo.
define variable goods-count as character no-undo.
   mTrgLoc:set_SelectGood ( sType:SelectGoodInt( SelectGood )).
   mTrgLoc:selXSelectGood(output t-str,output goods-count).
   if length (t-str) > {&max-len-str} 
   then
      GoodsEditor:Text = substring(T-str ,1, {&max-len-str}) + /*  {&new-line} +*/ " выборка для просмотра обрезана - слишком много записей " .
   else
      GoodsEditor:text = T-str  .
   mTrgLoc:set_GoodsEditor(GoodsEditor:Text).

end .

 method private void display-goods () :
/*Обработка 2 параметра - ТОВАРЫ - как показывать блок с выбором товаров */
define buffer buf_clob-bind for ub.clob-bind  .
define variable v-temp-str  as character no-undo .
define variable J#          as integer   no-undo .
define variable L#          as integer   no-undo .
define variable RET#        as logical   no-undo .
define variable R#          as integer   no-undo .
 if  mTrgLoc:ParamForm:temp-param-goods ne ""
    then do:
 /*         disable TEXT-2 SelectGood BUTTON-gds button-keep-spis BUTTON-node BUTTON-prod BUTTON-node-2 BUTTON-prod-2 BUTTON-one Goods-count Goods-Editor  with frame {&FRAME-NAME} .
         hide TEXT-2 SelectGood  BUTTON-gds button-keep-spis  BUTTON-node BUTTON-prod  BUTTON-node-2 BUTTON-prod-2  BUTTON-one Goods-count Goods-Editor   in frame {&FRAME-NAME} .
         end.
    else do:  enable TEXT-2 with frame {&FRAME-NAME} .*/
    
     SelectGood_disable = mTrgLoc:ParamForm:temp-param-goods.
     SelectGood = stype:SelectGoodLbl(int(entry(1,mTrgLoc:ParamForm:temp-param-goods))).
            /*  lns-cnt = 0 .
              for each gds-list :
                  lns-cnt = lns-cnt + 1 .
              end.

              define variable v-i as integer   no-undo .
              s-notes =  "" .
              for each gds-list-hist :
                v-i = v-i + 1 .
                s-notes = s-notes + {&new-line} + gds-list-hist.hist-mode +  gds-list-hist.des .
                if v-i > 10 then do:
                  s-notes = s-notes + " ... " .
                  leave.
                end.
              end.

              if keep-spis <> "" then do:
                find first buf_clob-bind no-lock where
                          buf_clob-bind.field-name_ = keep-spis no-error .
                if available buf_clob-bind then do:
                  keep-spis = buf_clob-bind.field-name_ .
                  s-notes =  substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
              end.
              end.
*/
  Display-count-OTHER() .

    end.
end .
   
method private void val-goods  ():
   if mTrgLoc:ParamForm:temp-param-goods <> "" 
   then do:
      assign
         goodscount :text  = ''
         GoodsEditor:text  = ''
      .
      case sType:SelectGoodInt(SelectGood):
         when {&g-all} 
         then do:
            assign
               BtnGds:enabled      = no 
               BtnKeepSpis:enabled = no 
               BtnNode:enabled     = no
               BtnProd:enabled     = no 
               BtnOne:enabled      = no 
               BtnProd2:enabled    = no 
               BtnNode2:enabled    = no
               GoodsEditor:Text = " По всем товарам "
            .
            /*RECT-node:bgcolor = 8.
            RECT-node-2:bgcolor = 8.*/

         end.
         when {&g-grp} then do:
            assign
               BtnGds:enabled      = no 
               BtnKeepSpis:enabled = no 
               BtnProd:enabled     = no 
               BtnOne:enabled      = no 
               BtnProd2:enabled    = no 
               BtnNode2:enabled    = no
               BtnNode:enabled     = yes
            .
/*            RECT-node:bgcolor = 8.
            RECT-node-2:bgcolor = 8.*/

         end.
         when {&g-prod} then do:
            assign
               BtnGds:enabled      = no 
               BtnKeepSpis:enabled = no 
               BtnNode:enabled     = no
               BtnOne:enabled      = no 
               BtnProd2:enabled    = no 
               BtnNode2:enabled    = no
               BtnProd:enabled     = yes
            .
   /*    RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.*/

         end.
         when {&g-choice} then do:
            assign
               BtnGds:enabled      = no 
               BtnKeepSpis:enabled = no 
               BtnNode:enabled     = no
               BtnProd:enabled     = no 
               BtnOne:enabled      = no 
               BtnProd2:enabled    = no 
               BtnNode2:enabled    = no
               BtnGds:enabled      = yes
            .
       /* RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8. */

         end.
         when {&g-spis} then do:
            assign
               BtnGds:enabled      = no 
               BtnNode:enabled     = no
               BtnProd:enabled     = no 
               BtnOne:enabled      = no 
               BtnProd2:enabled    = no 
               BtnNode2:enabled    = no
               BtnKeepSpis:enabled = yes
            .
    /*   RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.*/

         end.
         when {&g-one} then do:
            assign
               BtnGds:enabled      = no 
               BtnKeepSpis:enabled = no 
               BtnNode:enabled     = no
               BtnProd:enabled     = no 
               BtnProd2:enabled    = no 
               BtnNode2:enabled    = no
               BtnOne:enabled      = yes
            . 
     /*  RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.*/
         end.
         when {&g-grp-prod} then do:
            assign
               BtnGds:enabled      = no 
               BtnKeepSpis:enabled = no 
               BtnNode:enabled     = no
               BtnProd:enabled     = no 
               BtnOne:enabled      = no 
               BtnProd2:enabled    = yes 
               BtnNode2:enabled    = yes
               BtnOne:enabled      = no
            .
         end.
      end case.
      goodscount:enabled  = yes.
      GoodsEditor:enabled = yes.
   end.
   else assign
      goodscount:enabled  = no
      GoodsEditor:enabled = no
   .  

end.

   method private void CHOOSE_BUTTON-keep-spis():
      define variable sNote as character no-undo.
      define variable lns-cnt as integer  no-undo.
      mTrgLoc:CHOOSE_BUTTON-keep-spis(output lns-cnt,output sNote).
      display-count (lns-cnt,sNote) .
      display-count-other ().
   end.
   
   method public void Assign-frame():
      mTrgLoc:set_GoodsEditor(GoodsEditor:Text).
      mTrgLoc:set_SelectGood(sType:SelectGoodInt( SelectGood )).
      mTrgLoc:set_TextLb(TEXT2:Text).
      mTrgLoc:Assign-frame().
   end.
   
   method public void local-apply-layout(iparamObj as class ibs.th.ref.sobj.sParamObj):
      GoodsEditor:Text = iparamObj:X-Goods-Editor.
      if iparamObj:X-SelectGood ne 0
      then
         SelectGood   = stype:SelectGoodlbl(iparamObj:X-SelectGood).
      display-goods () .
      val-goods () .
      if paramform:temp-param-goods <> "" 
      then do:
         display-count-other () .
      end.
      else
         goodseditor:visible = no.
/*         lns-cnt = get-count-gds-list().*/
      if iparamObj:params-only-mode  = {&lookup} 
      then
         SelectGood_disable = "*".
   end method .

   method public character  AssignParam ():
       
   end method.

end class.