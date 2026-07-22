 
 /*------------------------------------------------------------------------
    File        : uc_Canon
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : mshavlov
    Created     : Mon Aug 06 11:46:45 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.UserControl.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.promo.uc_Canon INHERITS UserControl: 
    
    define private variable bindPromoCrit as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    define private variable label3 as System.Windows.Forms.Label no-undo.
    DEFINE PRIVATE VARIABLE textBox2 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE textBox1 AS System.Windows.Forms.TextBox NO-UNDO.
    DEFINE PRIVATE VARIABLE tableLayoutPanel3 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE label2 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.

    {ibs/th/ref/promo/promo_trg_heder.i &NotSetBind = yes}
    
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label3_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

    method Public VOID SetBind( ):
        bindPromocrit:Handle = m-promo-trg:getQuery("PromoCriterionOne").
        setDisable(m-promo-trg:modeview).
    end.
    method public VOID setDisable(input iModeView as logical  ):
        assign
            textBox1:enabled = not iModeview 
            textBox2:enabled = not iModeview
         .
    end. 

     method Public VOID LocalEvent(input iEvent as character, input iEventParam as character  ):

        if iEvent eq "CritOneLable"
        then do:
            if entry (1, iEventParam,"#") ne "?"
            then assign 
                label1:text    = entry (1, iEventParam,"#")
                label1:visible = yes
                textBox1:visible = yes
            .
            else assign 
                label1:visible      = no
                textBox1:visible    = no
            . 
            
            if     num-entries(iEventParam,"#") > 1 
               and entry (2, iEventParam,"#") ne "?"
            then assign 
                label2:text    = entry (2, iEventParam,"#")
                label2:visible = yes
                textBox2:visible = yes
            .
            else assign 
                label2:visible      = no
                textBox2:visible    = no
            .
            if     num-entries(iEventParam,"#") > 2 
               and entry (3, iEventParam,"#") ne "?"
            then assign 
                label3:text    = entry (3, iEventParam,"#")
                label3:visible = yes
            .
            else assign 
                label3:visible      = no
            .
        end. 
        if iEvent eq "CritOneLableCode" then do:
          label1:Visible = false .
          label2:Visible = true .
          label3:Visible = false .
          textBox1:Visible = false .
          textBox2:Visible = true .    
          label2:text = iEventParam .      
        end.
        if iEvent eq "NotOneLable" then do:
          label1:Visible = false .
          label2:Visible = false .
          label3:Visible = false .
          textBox1:Visible = false .
          textBox2:Visible = false .
        end.
        if iEvent eq "swapCritAndDiscont"
        then do:
            this-object:tableLayoutPanel3:Controls:Remove(this-object:textBox1).
            this-object:tableLayoutPanel3:Controls:Remove(this-object:textBox2).
            this-object:tableLayoutPanel3:Controls:Add(this-object:textBox2, 1, 0).
            this-object:tableLayoutPanel3:Controls:Add(this-object:textBox1, 3, 0).
        end.
        
    end. 
        
    CONSTRUCTOR PUBLIC uc_Canon (  ):
        
        
        SUPER().
        InitializeComponent().
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
    define variable tableDesc2 as Progress.Data.TableDesc no-undo.
    tableDesc2 = new Progress.Data.TableDesc("tt-PromoCriterion").
    this-object:tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel().
    this-object:label2 = new System.Windows.Forms.Label().
    this-object:textBox2 = new System.Windows.Forms.TextBox().
    this-object:bindPromoCrit = new Progress.Data.BindingSource(this-object:components).
    this-object:textBox1 = new System.Windows.Forms.TextBox().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:label3 = new System.Windows.Forms.Label().
    this-object:tableLayoutPanel3:SuspendLayout().
    cast(this-object:bindPromoCrit, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    /*  */
    /* tableLayoutPanel3 */
    /*  */
    this-object:tableLayoutPanel3:ColumnCount = 5.
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(32))).
    this-object:tableLayoutPanel3:Controls:Add(this-object:label2, 2, 0).
    this-object:tableLayoutPanel3:Controls:Add(this-object:textBox2, 3, 0).
    this-object:tableLayoutPanel3:Controls:Add(this-object:textBox1, 1, 0).
    this-object:tableLayoutPanel3:Controls:Add(this-object:label1, 0, 0).
    this-object:tableLayoutPanel3:Controls:Add(this-object:label3, 4, 0).
    this-object:tableLayoutPanel3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel3:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel3:Name = "tableLayoutPanel3".
    this-object:tableLayoutPanel3:RowCount = 1.
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(32))).
    this-object:tableLayoutPanel3:Size = new System.Drawing.Size(532, 32).
    this-object:tableLayoutPanel3:TabIndex = 2.
    /*  */
    /* label2 */
    /*  */
    this-object:label2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label2:Location = new System.Drawing.Point(253, 3).
    this-object:label2:Margin = new System.Windows.Forms.Padding(3, 3, 12, 3).
    this-object:label2:Name = "label2".
    this-object:label2:Size = new System.Drawing.Size(85, 26).
    this-object:label2:TabIndex = 1.
    this-object:label2:Text = "по".
    this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:label2:UseCompatibleTextRendering = true.
    /*  */
    /* textBox2 */
    /*  */
    this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoCrit, "discont", true)).
    this-object:textBox2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox2:Location = new System.Drawing.Point(353, 3).
    this-object:textBox2:Name = "textBox2".
    this-object:textBox2:Size = new System.Drawing.Size(144, 20).
    this-object:textBox2:TabIndex = 3.
    this-object:textBox2:TextChanged:Subscribe(this-object:textBox2_TextChanged).
    /*  */
    /* bindPromoCrit */
    /*  */
    this-object:bindPromoCrit:AutoUpdate = true.
    this-object:bindPromoCrit:MaxDataGuess = 0.
    this-object:bindPromoCrit:NoLOBs = false.
    this-object:bindPromoCrit:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar0 = new "Progress.Data.TableDesc[]"(0).
    tableDesc2:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 2 no-undo.
    arrayvar1[1] = new Progress.Data.ColumnPropDesc("discont", "знач. скидки", Progress.Data.DataType:DECIMAL).
    arrayvar1[2] = new Progress.Data.ColumnPropDesc("mincrit", "минимальное значение критери€", Progress.Data.DataType:DECIMAL).
    tableDesc2:Columns = arrayvar1.
    this-object:bindPromoCrit:TableSchema = tableDesc2.
    /*  */
    /* textBox1 */
    /*  */
    this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindPromoCrit, "mincrit", true)).
    this-object:textBox1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox1:Location = new System.Drawing.Point(103, 3).
    this-object:textBox1:Name = "textBox1".
    this-object:textBox1:Size = new System.Drawing.Size(144, 20).
    this-object:textBox1:TabIndex = 2.
    this-object:textBox1:TextChanged:Subscribe(this-object:textBox1_TextChanged).
    /*  */
    /* label1 */
    /*  */
    this-object:label1:Location = new System.Drawing.Point(3, 3).
    this-object:label1:Margin = new System.Windows.Forms.Padding(3, 3, 12, 3).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(85, 23).
    this-object:label1:TabIndex = 0.
    this-object:label1:Text = "ќт".
    this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* label3 */
    /*  */
    this-object:label3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label3:Location = new System.Drawing.Point(503, 0).
    this-object:label3:Name = "label3".
    this-object:label3:Size = new System.Drawing.Size(26, 32).
    this-object:label3:TabIndex = 4.
    this-object:label3:Text = "%".
    this-object:label3:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label3:UseCompatibleTextRendering = true.
    this-object:label3:Click:Subscribe(this-object:label3_Click).
    /*  */
    /* uc_Canon */
    /*  */
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:tableLayoutPanel3).
    this-object:Name = "uc_Canon".
    this-object:Size = new System.Drawing.Size(532, 32).
    this-object:tableLayoutPanel3:ResumeLayout(false).
    this-object:tableLayoutPanel3:PerformLayout().
    cast(this-object:bindPromoCrit, System.ComponentModel.ISupportInitialize):EndInit().
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
	method private void textBox1_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void textBox2_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

    DESTRUCTOR PUBLIC uc_Canon ( ):
        if valid-handle(bindPromocrit:handle)
        then
          bindPromocrit:Assign().
        bindPromocrit:Dispose().
    END DESTRUCTOR.

END CLASS.