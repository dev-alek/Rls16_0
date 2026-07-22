 
 /*------------------------------------------------------------------------
    File        : cashbookost
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Fri Nov 22 12:40:53 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.

block-level on error undo, throw.

class ibs.th.ref.ostcashbook inherits UserControl: 
   
   define private variable button1 as System.Windows.Forms.Button no-undo.
   define private variable changDataGridViewCheckBoxColumn as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
   define private variable cashbooknameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable bindOst as Progress.Data.BindingSource no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable fitog as System.Windows.Forms.TextBox no-undo.
   define private variable ostDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable label1 as System.Windows.Forms.Label no-undo.
   define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
   define private variable ostraschDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define public  variable trgOst as ibs.th.ref.ostcashbook_trg no-undo. 
   define variable mFLAG as logical no-undo .
   
   constructor public ostcashbook (  ):

      super().
      //mtrgOst = new ibs.th.ref.ostcashbook_trg().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.
   constructor public ostcashbook ( input itrgOst as ibs.th.ref.ostcashbook_trg):
      super().
      trgOst = itrgOst.
      mFLAG = trgOst:ChekSumm. 
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
	method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
		mFLAG = not mFLAG.
		button1:text = if not mFLAG then "Отметить все" else "Снять все".
		fitog:text = string(trgOst:cangCashbookall(mFLAG)).
		bindOst:RefreshAll().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void dataGridView1_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
		FITOG:text = string(trgOst:cangCashbook()).
		bindOst:Refresh().
		return.

	end method.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("tt-cashBookOst").
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:changDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:cashbooknameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:ostDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:ostraschDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:bindOst = new Progress.Data.BindingSource(this-object:components).
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:fitog = new System.Windows.Forms.TextBox().
      this-object:button1 = new System.Windows.Forms.Button().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindOst, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      /*  */
      /* dataGridView1 */
      /*  */
      this-object:dataGridView1:AllowUserToAddRows = false.
      this-object:dataGridView1:AllowUserToDeleteRows = false.
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:AutoGenerateColumns = false.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 4 no-undo.
      arrayvar0[1] = this-object:changDataGridViewCheckBoxColumn.
      arrayvar0[2] = this-object:cashbooknameDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:ostDataGridViewTextBoxColumn.
      arrayvar0[4] = this-object:ostraschDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar0).
      this-object:dataGridView1:DataSource = this-object:bindOst.
      this-object:dataGridView1:Location = new System.Drawing.Point(3, 32).
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:RowHeadersVisible = false.
      this-object:dataGridView1:Size = new System.Drawing.Size(510, 160).
      this-object:dataGridView1:TabIndex = 0.
      this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
      /*  */
      /* changDataGridViewCheckBoxColumn */
      /*  */
      this-object:changDataGridViewCheckBoxColumn:DataPropertyName = "chang".
      this-object:changDataGridViewCheckBoxColumn:HeaderText = "".
      this-object:changDataGridViewCheckBoxColumn:Name = "changDataGridViewCheckBoxColumn".
      this-object:changDataGridViewCheckBoxColumn:ReadOnly = true.
      this-object:changDataGridViewCheckBoxColumn:Width = 30.
      /*  */
      /* cashbooknameDataGridViewTextBoxColumn */
      /*  */
      this-object:cashbooknameDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:cashbooknameDataGridViewTextBoxColumn:DataPropertyName = "cashbookname".
      this-object:cashbooknameDataGridViewTextBoxColumn:HeaderText = "Кассовая книга".
      this-object:cashbooknameDataGridViewTextBoxColumn:Name = "cashbooknameDataGridViewTextBoxColumn".
      this-object:cashbooknameDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* ostDataGridViewTextBoxColumn */
      /*  */
      this-object:ostDataGridViewTextBoxColumn:DataPropertyName = "ost".
      this-object:ostDataGridViewTextBoxColumn:HeaderText = "Текущий остаток".
      this-object:ostDataGridViewTextBoxColumn:Name = "ostDataGridViewTextBoxColumn".
      this-object:ostDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* ostraschDataGridViewTextBoxColumn */
      /*  */
      this-object:ostraschDataGridViewTextBoxColumn:DataPropertyName = "ostrasch".
      this-object:ostraschDataGridViewTextBoxColumn:HeaderText = "Расчетный остаток".
      this-object:ostraschDataGridViewTextBoxColumn:Name = "ostraschDataGridViewTextBoxColumn".
      this-object:ostraschDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* bindOst */
      /*  */
      this-object:bindOst:AutoUpdate = true.
      this-object:bindOst:MaxDataGuess = 0.
      this-object:bindOst:NoLOBs = false.
      this-object:bindOst:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 4 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("chang", "", Progress.Data.DataType:LOGICAL).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("cashbookname", "Кассовая книга", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("ost", "Текущий остаток", Progress.Data.DataType:DECIMAL).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("ostrasch", "Расчетный остаток", Progress.Data.DataType:DECIMAL).
      tableDesc1:Columns = arrayvar2.
      this-object:bindOst:TableSchema = tableDesc1.
      /*  */
      /* label1 */
      /*  */
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:label1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:label1:Location = new System.Drawing.Point(307, 198).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(100, 29).
      this-object:label1:TabIndex = 1.
      this-object:label1:Text = "Итого".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:label1:Click:Subscribe(this-object:label1_Click).
      /*  */
      /* fitog */
      /*  */
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:fitog:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:fitog:Location = new System.Drawing.Point(413, 198).
      this-object:fitog:Name = "fitog".
      this-object:fitog:ReadOnly = true.
      this-object:fitog:Size = new System.Drawing.Size(100, 20).
      this-object:fitog:TabIndex = 2.
      /*  */
      /* button1 */
      /*  */
      this-object:button1:Location = new System.Drawing.Point(3, 3).
      this-object:button1:Name = "button1".
      this-object:button1:Size = new System.Drawing.Size(106, 23).
      this-object:button1:TabIndex = 3.
      this-object:button1:Text = "Отметить все".
      this-object:button1:UseCompatibleTextRendering = true.
      this-object:button1:UseVisualStyleBackColor = true.
      this-object:button1:Click:Subscribe(this-object:button1_Click).
      /*  */
      /* ostcashbook */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:button1).
      this-object:Controls:Add(this-object:fitog).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:dataGridView1).
      this-object:Name = "ostcashbook".
      this-object:Size = new System.Drawing.Size(516, 221).
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindOst, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label1_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.
	
	method public logical chekSumm( ):
      
      return trgOst:ChekSumm.

   end method.
   
   method public void setbin( ):
      
     bindOst:handle = trgOst:getQuery().
     fitog:text = string(trgOst:getsumost()).

   end method.

   destructor public ostcashbook ( ):

   end destructor.

end class.