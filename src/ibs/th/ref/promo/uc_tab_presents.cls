 
 /*------------------------------------------------------------------------
    File        : uc_Tab_Presents
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mshavlov
    Created     : Fri Jul 27 17:32:04 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.UserControl.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.promo.uc_Tab_Presents INHERITS UserControl: 
     
    define private variable bindPromoActionOne as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE panel_SelectConditionItems AS System.Windows.Forms.Panel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel1 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE radioButton2 AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE radioButton1 AS System.Windows.Forms.RadioButton NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    define private variable typeCond as System.Windows.Forms.TextBox no-undo.
    {ibs/th/ref/promo/promoType.def ttTypeCond} 
    DEFINE VARIABLE ucMain7   AS ibs.th.ref.promo.uc_SelectsGCP   NO-UNDO.
    
    define private variable m-promo-type as class ibs.th.ref.promo.promoType no-undo.
         
   {ibs/th/ref/promo/promo_trg_heder.i &child_1 = ucMain7 &NotLocalEvent =yes }
    
    method Public VOID SetBind( ):
        typeCond:visible = true.
        bindPromoActionOne:handle = m-promo-trg:getQuery("promoActionOne4").
        Show_Panet_SelectConditonItem(1).
        typeCond:visible = false.
     end.
    
        
    CONSTRUCTOR PUBLIC uc_Tab_Presents (  ):
        
        
        SUPER().
        m-promo-type = new ibs.th.ref.promo.promoType().
        m-promo-type:TypeCondRefresh().
        m-promo-type:typeTable("TypeCond", output table ttTypeCond).
        InitializeComponent().
        ucMain7:PublicEvent("ViewGiftForAction", "").
        ucMain7:INIT_Panel(no, no, no, yes).
        THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
        CATCH e AS Progress.Lang.Error:
            UNDO, THROW e.
        END CATCH.

    END CONSTRUCTOR.

    METHOD PRIVATE VOID InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("tt-promoaction-one").
    this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
    this-object:panel_SelectConditionItems = new System.Windows.Forms.Panel().
    this-object:ucMain7 = new ibs.th.ref.promo.uc_SelectsGCP().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
    this-object:radioButton2 = new System.Windows.Forms.RadioButton().
    this-object:radioButton1 = new System.Windows.Forms.RadioButton().
    this-object:typeCond = new System.Windows.Forms.TextBox().
    this-object:bindPromoActionOne = new Progress.Data.BindingSource(this-object:components).
    this-object:tableLayoutPanel1:SuspendLayout().
    this-object:panel_SelectConditionItems:SuspendLayout().
    this-object:tableLayoutPanel2:SuspendLayout().
    cast(this-object:bindPromoActionOne, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    /*  */
    /* tableLayoutPanel1 */
    /*  */
    this-object:tableLayoutPanel1:ColumnCount = 1.
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Controls:Add(this-object:panel_SelectConditionItems, 0, 2).
    this-object:tableLayoutPanel1:Controls:Add(this-object:label1, 0, 0).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 1).
    this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
    this-object:tableLayoutPanel1:RowCount = 3.
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(30))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Size = new System.Drawing.Size(593, 483).
    this-object:tableLayoutPanel1:TabIndex = 0.
    /*  */
    /* panel_SelectConditionItems */
    /*  */
    this-object:panel_SelectConditionItems:Controls:Add(this-object:ucMain7).
    this-object:panel_SelectConditionItems:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:panel_SelectConditionItems:Location = new System.Drawing.Point(0, 60).
    this-object:panel_SelectConditionItems:Margin = new System.Windows.Forms.Padding(0).
    this-object:panel_SelectConditionItems:Name = "panel_SelectConditionItems".
    this-object:panel_SelectConditionItems:Size = new System.Drawing.Size(593, 423).
    this-object:panel_SelectConditionItems:TabIndex = 4.
    /*  */
    /* ucMain7 */
    /*  */
    this-object:ucMain7:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:ucMain7:Location = new System.Drawing.Point(0, 0).
    this-object:ucMain7:Name = "ucMain7".
    this-object:ucMain7:Size = new System.Drawing.Size(593, 423).
    this-object:ucMain7:TabIndex = 0.
    /*  */
    /* label1 */
    /*  */
    this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label1:Location = new System.Drawing.Point(3, 3).
    this-object:label1:Margin = new System.Windows.Forms.Padding(3).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(587, 24).
    this-object:label1:TabIndex = 1.
    this-object:label1:Text = "Выбор подарков".
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* tableLayoutPanel2 */
    /*  */
    this-object:tableLayoutPanel2:ColumnCount = 3.
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(140))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(140))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Controls:Add(this-object:radioButton2, 1, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:radioButton1, 0, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:typeCond, 2, 0).
    this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel2:Location = new System.Drawing.Point(0, 30).
    this-object:tableLayoutPanel2:Margin = new System.Windows.Forms.Padding(0).
    this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
    this-object:tableLayoutPanel2:RowCount = 1.
    this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Size = new System.Drawing.Size(593, 30).
    this-object:tableLayoutPanel2:TabIndex = 2.
    /*  */
    /* radioButton2 */
    /*  */
    this-object:radioButton2:Appearance = System.Windows.Forms.Appearance:Button.
    this-object:radioButton2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:radioButton2:Location = new System.Drawing.Point(143, 3).
    this-object:radioButton2:Name = "radioButton2".
    this-object:radioButton2:Size = new System.Drawing.Size(134, 24).
    this-object:radioButton2:TabIndex = 1.
    this-object:radioButton2:Text = "Детальные".
    this-object:radioButton2:UseCompatibleTextRendering = true.
    this-object:radioButton2:UseVisualStyleBackColor = true.
    /*  */
    /* radioButton1 */
    /*  */
    this-object:radioButton1:Appearance = System.Windows.Forms.Appearance:Button.
    this-object:radioButton1:Checked = true.
    this-object:radioButton1:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindPromoActionOne, "simpGiftFl", true)).
    this-object:radioButton1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:radioButton1:ForeColor = System.Drawing.Color:Green.
    this-object:radioButton1:Location = new System.Drawing.Point(3, 3).
    this-object:radioButton1:Name = "radioButton1".
    this-object:radioButton1:Size = new System.Drawing.Size(134, 24).
    this-object:radioButton1:TabIndex = 0.
    this-object:radioButton1:TabStop = true.
    this-object:radioButton1:Text = "Простые ".
    this-object:radioButton1:UseCompatibleTextRendering = true.
    this-object:radioButton1:UseVisualStyleBackColor = true.
    this-object:radioButton1:CheckedChanged:Subscribe(this-object:radioButton1_CheckedChanged).
    /*  */
    /* typeCond */
    /*  */
    this-object:typeCond:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoActionOne, "typecondlbl", true)).
    this-object:typeCond:Location = new System.Drawing.Point(283, 3).
    this-object:typeCond:Name = "typeCond".
    this-object:typeCond:Size = new System.Drawing.Size(100, 20).
    this-object:typeCond:TabIndex = 2.
    /*  */
    /* bindPromoActionOne */
    /*  */
    this-object:bindPromoActionOne:MaxDataGuess = 0.
    this-object:bindPromoActionOne:NoLOBs = false.
    this-object:bindPromoActionOne:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar0 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 2 no-undo.
    arrayvar1[1] = new Progress.Data.ColumnPropDesc("typecondlbl", "Вид условия", Progress.Data.DataType:CHARACTER).
    arrayvar1[2] = new Progress.Data.ColumnPropDesc("simpGiftFl", "simpGiftFl", Progress.Data.DataType:LOGICAL).
    tableDesc1:Columns = arrayvar1.
    this-object:bindPromoActionOne:TableSchema = tableDesc1.
    /*  */
    /* uc_Tab_Presents */
    /*  */
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:tableLayoutPanel1).
    this-object:Name = "uc_Tab_Presents".
    this-object:Size = new System.Drawing.Size(593, 483).
    this-object:tableLayoutPanel1:ResumeLayout(false).
    this-object:panel_SelectConditionItems:ResumeLayout(false).
    this-object:tableLayoutPanel2:ResumeLayout(false).
    this-object:tableLayoutPanel2:PerformLayout().
    cast(this-object:bindPromoActionOne, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
    END METHOD.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID radioButton1_CheckedChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		
        if radioButton1:Checked then do:
           radioButton1:ForeColor  = System.Drawing.Color:Green.
           radioButton2:ForeColor  = System.Drawing.Color:Black.
           Show_Panet_SelectConditonItem(1).
        end.
        else do:
           radioButton1:ForeColor  = System.Drawing.Color:Black.
           radioButton2:ForeColor  = System.Drawing.Color:Green.
           Show_Panet_SelectConditonItem(2).
        end.
		RETURN.

	END METHOD.
	
	METHOD public VOID Show_Panet_SelectConditonItem():
	    Show_Panet_SelectConditonItem(if radioButton1:checked then 1 else 2). 
	end.
	METHOD private VOID Show_Panet_SelectConditonItem( INPUT SelectItem AS int):
	    THIS-OBJECT:panel_SelectConditionItems:Controls:Clear().
	    clenObject().
	     typeCond:visible = true.
	       ucMain7 = NEW ibs.th.ref.promo.uc_SelectsGCP().
	    CASE SelectItem:
	    	    WHEN 1 then do:
	    	        ucMain7:PublicEvent("ViewGiftForAction", "").
	    	        ucMain7:INIT_Panel(no, no, no, yes).
	    	    END.
                
                WHEN 2 then do:
                    ucMain7:INIT_Panel(no, no, yes, yes).
                        
                    find first tttypeCond where tttypeCond.item eq typecond:Text no-lock no-error.
                    if available tttypeCond 
                    then do:
                    
                    if tttypeCond.code = 1 // "Количество по строке"  
                    then do:
                        ucMain7:PublicEvent("CritLable", "Количество, ед#Диапазон действия,ед#?").
                    end.
                    else if tttypeCond.code = 2 // "Сумма по строке"   
                    then do:
                        ucMain7:PublicEvent("CritLable", "Сумма, руб#Диапазон действия, Руб#?").
                    end.
                    else if tttypeCond.code = 3 // "Итог чека"  
                    then do:
                        ucMain7:PublicEvent("CritLable", "Сумма, руб#Диапазон действия, Руб#?").
                    end.
                    else
                        ucMain7:PublicEvent("CritLable", "Количество / сумма#Диапазон действия#?"). 
                end.    
                END.
                
         END.
         ucMain7:SetPromoTrg(m-promo-trg).
         ucMain7:Dock = System.Windows.Forms.DockStyle:Fill.
         THIS-OBJECT:panel_SelectConditionItems:Controls:Add(ucMain7).
         typeCond:visible = false.
	   RETURN.

    END METHOD.

    METHOD public void clenObject():
        if valid-object(ucMain7)            then delete object ucMain7.
    end.

    DESTRUCTOR PUBLIC uc_Tab_Presents ( ):
        if valid-handle(bindPromoActionOne:handle)
        then
           bindPromoActionOne:Assign().
        bindPromoActionOne:Dispose().
        clenObject().
        
    END DESTRUCTOR.

END CLASS.