 
 /*------------------------------------------------------------------------
    File        : uc_SelectsGCP
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mshavlov
    Created     : Tue Jul 31 13:16:49 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.UserControl.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.promo.uc_SelectsGCP INHERITS UserControl: 
    
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_Canon1 AS ibs.th.ref.promo.uc_Canon NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_Present1 AS ibs.th.ref.promo.uc_Presents NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_Goods1 AS ibs.th.ref.promo.uc_Goods NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_Goods2 AS ibs.th.ref.promo.uc_Goods NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_Conditions1 AS ibs.th.ref.promo.uc_Conditions NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_Mess1 AS ibs.th.ref.promo.uc_Mess NO-UNDO.

    {ibs/th/ref/promo/promo_trg_heder.i 
                                        &child_1         = uc_Goods1
                                        &child_2         = uc_Goods2
                                        &child_3         = uc_Conditions1
                                        &child_4         = uc_Present1
                                        &child_5         = uc_Canon1 // начала должны создаться условия если их нет
                                        &child_6         = uc_Mess1  // а потом сообщения или подарки
                                        
                                        
                                        &NotLocalEvent = yes                                     
} 
        
    CONSTRUCTOR PUBLIC uc_SelectsGCP (  ):
        
        
        SUPER().
        InitializeComponent().
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        uc_Goods1:pCrit = yes.
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.

    END CONSTRUCTOR.

    method Public VOID SetBind( ):
/*uc_Goods1:Visible = IsIndGoods.
        uc_Goods2:Visible = IsGoods.
        uc_Present1:Visible = IsPresents.
        uc_Conditions1:Visible = IsConditions.*/
        if uc_Canon1:Visible 
        then
           uc_Canon1:SetBind().
        if uc_Mess1:Visible
        then  
           uc_Mess1:SetBind().
    end.
           
    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
        this-object:uc_Goods1 = new ibs.th.ref.promo.uc_Goods().
        this-object:uc_Goods2 = new ibs.th.ref.promo.uc_Goods().
        this-object:uc_Conditions1 = new ibs.th.ref.promo.uc_Conditions().
        this-object:uc_Present1 = new ibs.th.ref.promo.uc_Presents().
        this-object:uc_Mess1 = new ibs.th.ref.promo.uc_Mess().
        this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
        this-object:uc_Canon1 = new ibs.th.ref.promo.uc_Canon().
        this-object:tableLayoutPanel1:SuspendLayout().
        this-object:tableLayoutPanel2:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* tableLayoutPanel1 */
        /*  */
        this-object:tableLayoutPanel1:ColumnCount = 5.
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle()).
        this-object:tableLayoutPanel1:Controls:Add(this-object:uc_Goods1, 0, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:uc_Goods2, 1, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:uc_Conditions1, 2, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:uc_Present1, 3, 0).
        this-object:tableLayoutPanel1:Controls:Add(this-object:uc_Mess1, 4, 0).
        this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel1:Location = new System.Drawing.Point(3, 38).
        this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
        this-object:tableLayoutPanel1:RowCount = 1.
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:Size = new System.Drawing.Size(1405, 304).
        this-object:tableLayoutPanel1:TabIndex = 0.
        /*  */
        /* uc_Goods1 */
        /*  */
        this-object:uc_Goods1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uc_Goods1:Location = new System.Drawing.Point(0, 0).
        this-object:uc_Goods1:Margin = new System.Windows.Forms.Padding(0).
        this-object:uc_Goods1:Name = "uc_Goods1".
        this-object:uc_Goods1:Size = new System.Drawing.Size(301, 304).
        this-object:uc_Goods1:TabIndex = 0.
        this-object:uc_Goods1:Load:Subscribe(this-object:uc_Goods1_Load).
        /*  */
        /* uc_Goods2 */
        /*  */
        this-object:uc_Goods2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uc_Goods2:Location = new System.Drawing.Point(301, 0).
        this-object:uc_Goods2:Margin = new System.Windows.Forms.Padding(0).
        this-object:uc_Goods2:Name = "uc_Goods2".
        this-object:uc_Goods2:Size = new System.Drawing.Size(301, 304).
        this-object:uc_Goods2:TabIndex = 1.
        /*  */
        /* uc_Conditions1 */
        /*  */
        this-object:uc_Conditions1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uc_Conditions1:Location = new System.Drawing.Point(602, 0).
        this-object:uc_Conditions1:Margin = new System.Windows.Forms.Padding(0).
        this-object:uc_Conditions1:Name = "uc_Conditions1".
        this-object:uc_Conditions1:Size = new System.Drawing.Size(301, 304).
        this-object:uc_Conditions1:TabIndex = 2.
        this-object:uc_Conditions1:Load:Subscribe(this-object:uc_Conditions1_Load).
        /*  */
        /* uc_Present1 */
        /*  */
        this-object:uc_Present1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uc_Present1:Location = new System.Drawing.Point(903, 0).
        this-object:uc_Present1:Margin = new System.Windows.Forms.Padding(0).
        this-object:uc_Present1:Name = "uc_Present1".
        this-object:uc_Present1:Size = new System.Drawing.Size(301, 304).
        this-object:uc_Present1:TabIndex = 3.
        /*  */
        /* uc_Mess1 */
        /*  */
        this-object:uc_Mess1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:uc_Mess1:Location = new System.Drawing.Point(1204, 0).
        this-object:uc_Mess1:Margin = new System.Windows.Forms.Padding(0).
        this-object:uc_Mess1:Name = "uc_Mess1".
        this-object:uc_Mess1:Size = new System.Drawing.Size(304, 304).
        this-object:uc_Mess1:TabIndex = 4.
        /*  */
        /* tableLayoutPanel2 */
        /*  */
        this-object:tableLayoutPanel2:ColumnCount = 1.
        this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel2:Controls:Add(this-object:tableLayoutPanel1, 0, 1).
        this-object:tableLayoutPanel2:Controls:Add(this-object:uc_Canon1, 0, 0).
        this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel2:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
        this-object:tableLayoutPanel2:RowCount = 2.
        this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(35))).
        this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel2:Size = new System.Drawing.Size(1411, 345).
        this-object:tableLayoutPanel2:TabIndex = 1.
        /*  */
        /* uc_Canon1 */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = System.Windows.Forms.AnchorStyles:Top.
        this-object:uc_Canon1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:uc_Canon1:Location = new System.Drawing.Point(879, 3).
        this-object:uc_Canon1:Name = "uc_Canon1".
        this-object:uc_Canon1:Size = new System.Drawing.Size(529, 29).
        this-object:uc_Canon1:TabIndex = 1.
        /*  */
        /* uc_SelectsGCP */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        this-object:Controls:Add(this-object:tableLayoutPanel2).
        this-object:Name = "uc_SelectsGCP".
        this-object:Size = new System.Drawing.Size(1411, 345).
        this-object:tableLayoutPanel1:ResumeLayout(false).
        this-object:tableLayoutPanel2:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    END METHOD.

    DESTRUCTOR PUBLIC uc_SelectsGCP ( ):
        delete object uc_Goods1.
        delete object uc_Goods2.
        delete object uc_Present1.
        delete object uc_Conditions1.
        delete object uc_mess1.
        delete object uc_Canon1.

    END DESTRUCTOR.
    METHOD PUBLIC VOID INIT_Visa():
        assign
            uc_Goods1:pPromovisa = yes.
            
        .
        INIT_Panel(yes,no,no,yes,no,yes).
    end method.
    METHOD PUBLIC VOID INIT_BarCode(input metod_calc as integer):
      if metod_calc = 5 then 
      do:
        assign
          uc_Goods1:pPromoBarCodeFix = yes.
        .
      end.
      else 
      do:
        assign
          uc_Goods1:pPromoBarCode = yes.
        .       
      end. 
      INIT_Panel(yes,no,no,no,no,yes).
    end method.    
    METHOD PUBLIC VOID INIT_GoodsFix(input metod_calc as integer):
      if metod_calc = 5 then do:
        assign
          uc_Goods1:pPromoGoodsFix = yes.
        .        
      end.
      else do:
        assign
          uc_Goods1:pPromoGoodsApplFix = yes.
        .
        end.
      INIT_Panel(yes,no,no,no,no,yes).
    end method.
    METHOD PUBLIC VOID INIT_Promoset():
      INIT_Promoset(0).
    end method.  
    METHOD PUBLIC VOID INIT_Promoset(input method_calc as integer):
      if method_calc = 5 then do:
        assign
            uc_Goods1:pPromoSetFix   = yes
            uc_Goods2:pPromoSetGoods = yes
        .
      end.
      else do:
        assign
            uc_Goods1:pPromoSet      = yes
            uc_Goods2:pPromoSetGoods = yes
        .
      end.
        INIT_Panel(yes,yes,no,no,no,yes).
    end method.    
    METHOD PUBLIC VOID INIT_Panel(INPUT IsIndGoods as LOGICAL,INPUT IsGoods as LOGICAL, INPUT IsConditions as LOGICAL, INPUT IsPresents as LOGICAL):
        INIT_Panel(IsIndGoods, IsGoods, IsConditions, IsPresents,no,no).  
    end method.
    METHOD PUBLIC VOID INIT_Panel(INPUT IsIndGoods as LOGICAL,INPUT IsGoods as LOGICAL, INPUT IsConditions as LOGICAL, INPUT IsPresents as LOGICAL, INPUT IsMess as LOGICAL, input isCritOne as logical):
        
        uc_Goods1:Visible = IsIndGoods.
        uc_Goods2:Visible = IsGoods.
        uc_Present1:Visible = IsPresents.
        uc_Conditions1:Visible = IsConditions.
        uc_Mess1:Visible = IsMess.
        uc_Canon1:Visible = isCritOne.
        
        define variable vMax   as integer no-undo.
        define variable vWidth as integer no-undo.
        define variable vCount as integer no-undo.
        
        vMax = (if IsIndGoods    then 1 else 0)
             + (if IsGoods       then 1 else 0)
             + (if IsPresents    then 1 else 0)
             + (if IsConditions  then 1 else 0)
             + (if IsMess        then 1 else 0).
        vWidth = 100 / vMax.
            
        vCount = vCount +  1.
        if vCount eq vMax then vWidth = 100 - (vMax - 1)* integer (100 / vMax) .
        if   not IsIndGoods 
        then THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]:Width = 0.    
        else THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]= NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(vWidth)).
        
        vCount = vCount +  1.
        if vCount eq vMax then vWidth = 100 - (vMax - 1)* integer (100 / vMax) .
        if   not IsGoods 
        then THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]:Width = 0.    
        else THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]= NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(vWidth)).
        
        vCount = vCount +  1.
        if vCount eq vMax then vWidth = 100 - (vMax - 1)* integer (100 / vMax) .
        if   not IsConditions 
        then THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]:Width = 0.    
        else THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]= NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(vWidth)).
         
        vCount = vCount +  1.
        if vCount eq vMax then vWidth = 100 - (vMax - 1)* integer (100 / vMax) .
        if   not IsPresents 
        then THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]:Width = 0.    
        else THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]= NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(vWidth)).
        
         vCount = vCount +  1.
        if vCount eq vMax then vWidth = 100 - (vMax - 1)* integer (100 / vMax) .
        if   not IsMess 
        then THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]:Width = 0.    
        else THIS-OBJECT:tableLayoutPanel1:ColumnStyles[vCount - 1]= NEW System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(vWidth)).
        
        
        
        
       /* this-object:uc_Goods2:TabIndex = if IsIndGoods then 2 else 1.
        this-object:uc_Conditions1:TabIndex = if IsIndGoods then 1 else 3.
        if not IsIndGoods then do:
        this-object:uc_Goods2:Location = new System.Drawing.Point(301, 0).  
        this-object:uc_Conditions1:Location = new System.Drawing.Point(602, 0).
        end.
        else do:
        this-object:uc_Goods2:Location = new System.Drawing.Point(602, 0).  
        this-object:uc_Conditions1:Location = new System.Drawing.Point(301, 0).
        end.   
         */             
    END METHOD.
    METHOD PUBLIC VOID INIT_Panel(INPUT IsIndGoods as LOGICAL):
        INIT_Panel(IsIndGoods,uc_Goods2:Visible,uc_Conditions1:Visible,uc_Present1:Visible,uc_Mess1:Visible,uc_Canon1:Visible).
    END METHOD.    

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void uc_Conditions1_Load( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void uc_Goods1_Load( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

END CLASS.