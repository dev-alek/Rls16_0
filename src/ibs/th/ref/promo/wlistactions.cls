/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
 
Список промо-акций

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
using Progress.Lang.*.
using Progress.Windows.Form.
USING System.Windows.Forms.Keys FROM ASSEMBLY.

block-level on error undo, throw.

class ibs.th.ref.promo.wListActions inherits Form: 
    { cmp/str-glbl.i class }
    
    define private variable begdateDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable begdateDataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable bindAction as Progress.Data.BindingSource no-undo.
    DEFINE PRIVATE VARIABLE button1 AS System.Windows.Forms.Button NO-UNDO.
    define private variable Chang as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
    define private variable changDataGridViewCheckBoxColumn as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
    DEFINE PRIVATE VARIABLE comboBox1 AS System.Windows.Forms.ComboBox NO-UNDO.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
    define private variable dataGridViewTextBoxColumn2 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    DEFINE PRIVATE VARIABLE dateTimePicker1 AS System.Windows.Forms.DateTimePicker NO-UNDO.
    define private variable enddateDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable dataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable extcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable enddateDataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable id as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable idDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    DEFINE PRIVATE VARIABLE label2 AS System.Windows.Forms.Label NO-UNDO.
    DEFINE PRIVATE VARIABLE label1 AS System.Windows.Forms.Label NO-UNDO.
    define private variable NameAction as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable nameActionDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable status_lbl as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable statuslblDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable tableLayoutPanel1 as System.Windows.Forms.TableLayoutPanel no-undo.

    DEFINE PRIVATE VARIABLE tableLayoutPanel2 AS System.Windows.Forms.TableLayoutPanel NO-UNDO.
    DEFINE PRIVATE VARIABLE toolSBtn_Copy AS System.Windows.Forms.ToolStripButton NO-UNDO.
    define private variable toolSBtn_Exit as System.Windows.Forms.ToolStripButton no-undo.
    DEFINE PRIVATE VARIABLE toolSBtn_History AS System.Windows.Forms.ToolStripButton NO-UNDO.
    DEFINE PRIVATE VARIABLE toolSBtn_Print AS System.Windows.Forms.ToolStripButton NO-UNDO.
    DEFINE PRIVATE VARIABLE toolSBtn_Star AS System.Windows.Forms.ToolStripButton NO-UNDO.
    DEFINE PRIVATE VARIABLE toolSBtn_Ok AS System.Windows.Forms.ToolStripButton NO-UNDO.
    DEFINE PRIVATE VARIABLE toolSBtn_Status AS System.Windows.Forms.ToolStripButton NO-UNDO.
    define private variable toolSBtn_View as System.Windows.Forms.ToolStripButton no-undo.
    define private variable toolSBtn_Main as System.Windows.Forms.ToolStripButton no-undo.
    define private variable toolSBtn_Edit as System.Windows.Forms.ToolStripButton no-undo.
    define private variable toolSBtn_Delete as System.Windows.Forms.ToolStripButton no-undo.
    define private variable toolSBtn_Add as System.Windows.Forms.ToolStripButton no-undo.
    define private variable toolStrip1 as System.Windows.Forms.ToolStrip no-undo.
    define variable vDeleteTRG as logical no-undo.
  /* --- для cmp/vssrevis.i --- */
    define variable vss-revision       as character no-undo init "$Revision$":U .
    define variable vss-author         as character no-undo init "$Author$":U .
    define variable vss-date           as character no-undo init "$Date$":U .
    define variable vss-workfile       as character no-undo init "$Workfile$":U .
    define variable vss-archive        as character no-undo init "$Archive$":U .
    define variable vss-description    as character no-undo init "Список промо-акций". 
  /* --- end_of для cmp/vssrevis.i --- */
  
  
  
  /* --- собственные переменные --- */
    define variable m-promo-trg   as class  ibs.th.ref.promo.promo_trg no-undo .
    define public variable oPromoActionSubs as class  ibs.th.ref.promo.promoActionSubs no-undo .
    define property parparentproc as handle no-undo
    set(iH as handle):
       if valid-object(m-promo-trg)
       then
          m-promo-trg:parparentproc = ih.
    end.
  /* --- end_of собственные переменные --- */
    define private variable m-promo-type as class ibs.th.ref.promo.promoType no-undo.
    {ibs/th/ref/promo/promoType.def ttStatus}
    
    
    //{ bge/ds-promo.i &ref }  
     //define query q-action for tt-promoaction scrolling.
    
     constructor public wListActions ():
          super().
          InitializeComponent().
          Visual_Columns(FALSE).
          this-object:ComponentsCollection:ADD(this-object:components).
          m-promo-trg = new ibs.th.ref.promo.promo_trg().
          vDeleteTRG = yes.
          //m-promo-trg:SetBrwPromoAction(this-object).
          prepareobj () .
    end.
    constructor public wListActions (
    input pPromoTrg as ibs.th.ref.promo.promo_trg
   // ,    input table tt-promoaction bind
    ):
        //method public void SetPromoTrg (input pPromoTrg as ibs.th.ref.promo.promo_trg ) :
        
        super().
        InitializeComponent().
        Visual_Columns(FALSE).
        this-object:ComponentsCollection:ADD(this-object:components).
        m-promo-trg = pPromoTrg.
       prepareobj ( ) .
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end constructor.
    
     
    /*method public void SetPromoBind (input table tt-promoaction bind ) :
     
    end method .
    */
    destructor public wListActions ( ):
        bindAction:Dispose().
        
      if     vDeleteTRG 
         and valid-object(m-promo-trg) 
      then 
         delete object m-promo-trg .
    end destructor.




	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
	    find first ttstatus where ttstatus.item eq comboBox1:text no-error.
		m-promo-trg:getListTable(date(dateTimePicker1:value),(if available ttstatus then ttstatus.code else ? )).
		define variable vha as handle no-undo.
        vha = m-promo-trg:getQuery("promoActionAll",yes).
        bindAction:handle = vha.
        bindAction:Refreshall().
        return.
		

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void dataGridView1_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
		m-promo-trg:changeRow(no).
        bindAction:Refresh().
        return.
		

	end method.

   METHOD PRIVATE VOID Init_comboBox1():
        define variable v-promo-type as class ibs.th.ref.promo.promotype no-undo.
        v-promo-type = new ibs.th.ref.promo.promoType().
        v-promo-type:Status_refresh().
        v-promo-type:typeTable("status_",output table ttStatus).
        for each ttStatus:
            comboBox1:Items:Add(ttStatus.item).
        end. 
        comboBox1:Items:Add("*").
        delete object v-promo-type.
    end.



	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void dataGridView1_CellContentDoubleClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
		
		m-promo-trg:viewOnePromo().
         bindAction:Refresh().
        return.

	end method.

  method public void prepareobj ( ) :
     find first ttstatus where ttstatus.item eq comboBox1:text no-error.
     m-promo-trg:getListTable(date(dateTimePicker1:value),(if available ttstatus then ttstatus.code else ? )).
     Init_comboBox1().  
     comboBox1:text = "Активная" .
     bindAction:handle = m-promo-trg:getQuery("promoActionStatus").
     
     //hQuery:query-open.
     // bindAction:handle:query-open.
       bindAction:RefreshAll().
            
     
     // после заполнения find first tt-promoaction здесь available 
  end method .
  
      method private void InitializeComponent(  ):
        
        /* NOTE: The following method is automatically generated.
        
        We strongly suggest that the contents of this method only be modified using the
        Visual Designer to avoid any incompatible modifications.
        
        Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("tt-promoaction").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.promo.wListActions").
      this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:changDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:nameActionDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:begdateDataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:enddateDataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:statuslblDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:idDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:extcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:bindAction = new Progress.Data.BindingSource(this-object:components).
      this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
      this-object:toolStrip1 = new System.Windows.Forms.ToolStrip().
      this-object:toolSBtn_Exit = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Ok = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Star = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Add = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Main = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_View = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Edit = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Copy = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Delete = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Status = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_Print = new System.Windows.Forms.ToolStripButton().
      this-object:toolSBtn_History = new System.Windows.Forms.ToolStripButton().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:dateTimePicker1 = new System.Windows.Forms.DateTimePicker().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:comboBox1 = new System.Windows.Forms.ComboBox().
      this-object:button1 = new System.Windows.Forms.Button().
      this-object:NameAction = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:Chang = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:dataGridViewTextBoxColumn2 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:begdateDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:enddateDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:status_lbl = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:id = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:tableLayoutPanel1:SuspendLayout().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindAction, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:tableLayoutPanel2:SuspendLayout().
      this-object:toolStrip1:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* tableLayoutPanel1 */
      /*  */
      this-object:tableLayoutPanel1:ColumnCount = 1.
      this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
      this-object:tableLayoutPanel1:Controls:Add(this-object:dataGridView1, 0, 1).
      this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 0).
      this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
      this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
      this-object:tableLayoutPanel1:RowCount = 2.
      this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(40))).
      this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
      this-object:tableLayoutPanel1:Size = new System.Drawing.Size(947, 427).
      this-object:tableLayoutPanel1:TabIndex = 0.
      /*  */
      /* dataGridView1 */
      /*  */
      this-object:dataGridView1:AllowUserToAddRows = false.
      this-object:dataGridView1:AllowUserToDeleteRows = false.
      this-object:dataGridView1:AllowUserToOrderColumns = true.
      this-object:dataGridView1:AutoGenerateColumns = false.
      this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 7 no-undo.
      arrayvar0[1] = this-object:changDataGridViewCheckBoxColumn.
      arrayvar0[2] = this-object:nameActionDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:begdateDataGridViewTextBoxColumn1.
      arrayvar0[4] = this-object:enddateDataGridViewTextBoxColumn1.
      arrayvar0[5] = this-object:statuslblDataGridViewTextBoxColumn.
      arrayvar0[6] = this-object:idDataGridViewTextBoxColumn.
      arrayvar0[7] = this-object:extcodeDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar0).
      this-object:dataGridView1:DataSource = this-object:bindAction.
      this-object:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:dataGridView1:Location = new System.Drawing.Point(3, 43).
      this-object:dataGridView1:MultiSelect = false.
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:ReadOnly = true.
      this-object:dataGridView1:SelectionMode = System.Windows.Forms.DataGridViewSelectionMode:FullRowSelect.
      this-object:dataGridView1:Size = new System.Drawing.Size(941, 381).
      this-object:dataGridView1:TabIndex = 0.
      this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
      this-object:dataGridView1:CellContentDoubleClick:Subscribe(this-object:dataGridView1_CellContentDoubleClick).
      /*  */
      /* changDataGridViewCheckBoxColumn */
      /*  */
      this-object:changDataGridViewCheckBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
      this-object:changDataGridViewCheckBoxColumn:DataPropertyName = "Chang".
      this-object:changDataGridViewCheckBoxColumn:HeaderText = "".
      this-object:changDataGridViewCheckBoxColumn:Name = "changDataGridViewCheckBoxColumn".
      this-object:changDataGridViewCheckBoxColumn:ReadOnly = true.
      this-object:changDataGridViewCheckBoxColumn:Width = 20.
      /*  */
      /* nameActionDataGridViewTextBoxColumn */
      /*  */
      this-object:nameActionDataGridViewTextBoxColumn:DataPropertyName = "nameAction".
      this-object:nameActionDataGridViewTextBoxColumn:HeaderText = "Наим. акции".
      this-object:nameActionDataGridViewTextBoxColumn:Name = "nameActionDataGridViewTextBoxColumn".
      this-object:nameActionDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* begdateDataGridViewTextBoxColumn1 */
      /*  */
      this-object:begdateDataGridViewTextBoxColumn1:DataPropertyName = "beg-date".
      this-object:begdateDataGridViewTextBoxColumn1:HeaderText = "Дата начала".
      this-object:begdateDataGridViewTextBoxColumn1:Name = "begdateDataGridViewTextBoxColumn1".
      this-object:begdateDataGridViewTextBoxColumn1:ReadOnly = true.
      /*  */
      /* enddateDataGridViewTextBoxColumn1 */
      /*  */
      this-object:enddateDataGridViewTextBoxColumn1:DataPropertyName = "end-date".
      this-object:enddateDataGridViewTextBoxColumn1:HeaderText = "Дата конца".
      this-object:enddateDataGridViewTextBoxColumn1:Name = "enddateDataGridViewTextBoxColumn1".
      this-object:enddateDataGridViewTextBoxColumn1:ReadOnly = true.
      /*  */
      /* statuslblDataGridViewTextBoxColumn */
      /*  */
      this-object:statuslblDataGridViewTextBoxColumn:DataPropertyName = "status_lbl".
      this-object:statuslblDataGridViewTextBoxColumn:HeaderText = "Статус".
      this-object:statuslblDataGridViewTextBoxColumn:Name = "statuslblDataGridViewTextBoxColumn".
      this-object:statuslblDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* idDataGridViewTextBoxColumn */
      /*  */
      this-object:idDataGridViewTextBoxColumn:DataPropertyName = "id".
      this-object:idDataGridViewTextBoxColumn:HeaderText = "id".
      this-object:idDataGridViewTextBoxColumn:Name = "idDataGridViewTextBoxColumn".
      this-object:idDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* extcodeDataGridViewTextBoxColumn */
      /*  */
      this-object:extcodeDataGridViewTextBoxColumn:DataPropertyName = "ext-code".
      this-object:extcodeDataGridViewTextBoxColumn:HeaderText = "Id во внеш.сист".
      this-object:extcodeDataGridViewTextBoxColumn:Name = "extcodeDataGridViewTextBoxColumn".
      this-object:extcodeDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* bindAction */
      /*  */
      this-object:bindAction:AutoSort = true.
      this-object:bindAction:AutoUpdate = true.
      this-object:bindAction:MaxDataGuess = 0.
      this-object:bindAction:NoLOBs = false.
      this-object:bindAction:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 7 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("status_lbl", "", Progress.Data.DataType:CHARACTER).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("Chang", "", Progress.Data.DataType:LOGICAL).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("beg-date", "Дата начала", Progress.Data.DataType:DATE).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("end-date", "Дата конца", Progress.Data.DataType:DATE).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("ext-code", "?", Progress.Data.DataType:CHARACTER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar2[7] = new Progress.Data.ColumnPropDesc("nameAction", "Наим. акции", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar2.
      this-object:bindAction:TableSchema = tableDesc1.
      /*  */
      /* tableLayoutPanel2 */
      /*  */
      this-object:tableLayoutPanel2:ColumnCount = 8.
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(350))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(66.6666565))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(50))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(60))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(150))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(35))).
      this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(33.3333397))).
      this-object:tableLayoutPanel2:Controls:Add(this-object:toolStrip1, 0, 0).
      this-object:tableLayoutPanel2:Controls:Add(this-object:label1, 2, 0).
      this-object:tableLayoutPanel2:Controls:Add(this-object:dateTimePicker1, 3, 0).
      this-object:tableLayoutPanel2:Controls:Add(this-object:label2, 4, 0).
      this-object:tableLayoutPanel2:Controls:Add(this-object:comboBox1, 5, 0).
      this-object:tableLayoutPanel2:Controls:Add(this-object:button1, 6, 0).
      this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:tableLayoutPanel2:Location = new System.Drawing.Point(3, 3).
      this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
      this-object:tableLayoutPanel2:RowCount = 1.
      this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
      this-object:tableLayoutPanel2:Size = new System.Drawing.Size(941, 34).
      this-object:tableLayoutPanel2:TabIndex = 3.
      /*  */
      /* toolStrip1 */
      /*  */
      this-object:toolStrip1:AutoSize = false.
      this-object:toolStrip1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:toolStrip1:ImageScalingSize = new System.Drawing.Size(32, 32).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.ToolStripItem extent 12 no-undo.
      arrayvar3[1] = this-object:toolSBtn_Exit.
      arrayvar3[2] = this-object:toolSBtn_Ok.
      arrayvar3[3] = this-object:toolSBtn_Star.
      arrayvar3[4] = this-object:toolSBtn_Add.
      arrayvar3[5] = this-object:toolSBtn_Main.
      arrayvar3[6] = this-object:toolSBtn_View.
      arrayvar3[7] = this-object:toolSBtn_Edit.
      arrayvar3[8] = this-object:toolSBtn_Copy.
      arrayvar3[9] = this-object:toolSBtn_Delete.
      arrayvar3[10] = this-object:toolSBtn_Status.
      arrayvar3[11] = this-object:toolSBtn_Print.
      arrayvar3[12] = this-object:toolSBtn_History.
      this-object:toolStrip1:Items:AddRange(arrayvar3).
      this-object:toolStrip1:Location = new System.Drawing.Point(0, 0).
      this-object:toolStrip1:Name = "toolStrip1".
      this-object:toolStrip1:Size = new System.Drawing.Size(350, 34).
      this-object:toolStrip1:TabIndex = 2.
      this-object:toolStrip1:Text = "toolStrip1".
      this-object:toolStrip1:DoubleClick:Subscribe(this-object:toolStrip1_DoubleClick).
      /*  */
      /* toolSBtn_Exit */
      /*  */
      this-object:toolSBtn_Exit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Exit:Image = cast(resources:GetObject("toolSBtn_Exit.Image"), System.Drawing.Image).
      this-object:toolSBtn_Exit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Exit:Name = "toolSBtn_Exit".
      this-object:toolSBtn_Exit:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Exit:Text = "Выход".
      this-object:toolSBtn_Exit:Click:Subscribe(this-object:toolSBtn_Exit_Click).
      /*  */
      /* toolSBtn_Ok */
      /*  */
      this-object:toolSBtn_Ok:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Ok:Image = cast(resources:GetObject("toolSBtn_Ok.Image"), System.Drawing.Image).
      this-object:toolSBtn_Ok:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Ok:Name = "toolSBtn_Ok".
      this-object:toolSBtn_Ok:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Ok:Text = "Выбор".
      this-object:toolSBtn_Ok:Visible = false.
      this-object:toolSBtn_Ok:Click:Subscribe(this-object:toolSBtn_Ok_Click).
      /*  */
      /* toolSBtn_Star */
      /*  */
      this-object:toolSBtn_Star:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Star:Image = cast(resources:GetObject("toolSBtn_Star.Image"), System.Drawing.Image).
      this-object:toolSBtn_Star:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Star:Name = "toolSBtn_Star".
      this-object:toolSBtn_Star:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Star:Text = "Выделить все".
      this-object:toolSBtn_Star:Visible = false.
      this-object:toolSBtn_Star:Click:Subscribe(this-object:toolSBtn_Star_Click).
      /*  */
      /* toolSBtn_Add */
      /*  */
      this-object:toolSBtn_Add:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Add:Image = cast(resources:GetObject("toolSBtn_Add.Image"), System.Drawing.Image).
      this-object:toolSBtn_Add:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Add:Name = "toolSBtn_Add".
      this-object:toolSBtn_Add:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Add:Text = "Создать Акцию".
      this-object:toolSBtn_Add:Click:Subscribe(this-object:toolSBtn_Add_Click).
      /*  */
      /* toolSBtn_Main */
      /*  */
      this-object:toolSBtn_Main:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Main:Image = cast(resources:GetObject("toolSBtn_Main.Image"), System.Drawing.Image).
      this-object:toolSBtn_Main:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Main:Name = "toolSBtn_Main".
      this-object:toolSBtn_Main:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Main:Text = "Главная".
      this-object:toolSBtn_Main:Visible = false.
      this-object:toolSBtn_Main:Click:Subscribe(this-object:toolSBtn_Main_Click).
      /*  */
      /* toolSBtn_View */
      /*  */
      this-object:toolSBtn_View:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_View:Image = cast(resources:GetObject("toolSBtn_View.Image"), System.Drawing.Image).
      this-object:toolSBtn_View:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_View:Name = "toolSBtn_View".
      this-object:toolSBtn_View:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_View:Text = "Просмотр Акции".
      this-object:toolSBtn_View:Click:Subscribe(this-object:toolSBtn_View_Click).
      /*  */
      /* toolSBtn_Edit */
      /*  */
      this-object:toolSBtn_Edit:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Edit:Image = cast(resources:GetObject("toolSBtn_Edit.Image"), System.Drawing.Image).
      this-object:toolSBtn_Edit:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Edit:Name = "toolSBtn_Edit".
      this-object:toolSBtn_Edit:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Edit:Text = "Редактировать Акцию".
      this-object:toolSBtn_Edit:Click:Subscribe(this-object:toolSBtn_Edit_Click).
      /*  */
      /* toolSBtn_Copy */
      /*  */
      this-object:toolSBtn_Copy:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Copy:Image = cast(resources:GetObject("toolSBtn_Copy.Image"), System.Drawing.Image).
      this-object:toolSBtn_Copy:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Copy:Name = "toolSBtn_Copy".
      this-object:toolSBtn_Copy:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Copy:Text = "Копировать".
      this-object:toolSBtn_Copy:Click:Subscribe(this-object:toolSBtn_Copy_Click).
      /*  */
      /* toolSBtn_Delete */
      /*  */
      this-object:toolSBtn_Delete:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Delete:Image = cast(resources:GetObject("toolSBtn_Delete.Image"), System.Drawing.Image).
      this-object:toolSBtn_Delete:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Delete:Name = "toolSBtn_Delete".
      this-object:toolSBtn_Delete:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Delete:Text = "Удалить Акцию".
      this-object:toolSBtn_Delete:Click:Subscribe(this-object:toolSBtn_Delete_Click).
      /*  */
      /* toolSBtn_Status */
      /*  */
      this-object:toolSBtn_Status:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Status:Image = cast(resources:GetObject("toolSBtn_Status.Image"), System.Drawing.Image).
      this-object:toolSBtn_Status:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Status:Name = "toolSBtn_Status".
      this-object:toolSBtn_Status:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Status:Text = "Изм.Статуса".
      this-object:toolSBtn_Status:Click:Subscribe(this-object:toolSBtn_Status_Click).
      /*  */
      /* toolSBtn_Print */
      /*  */
      this-object:toolSBtn_Print:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_Print:Image = cast(resources:GetObject("toolSBtn_Print.Image"), System.Drawing.Image).
      this-object:toolSBtn_Print:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_Print:Name = "toolSBtn_Print".
      this-object:toolSBtn_Print:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_Print:Text = "Печать".
      this-object:toolSBtn_Print:Click:Subscribe(this-object:toolSBtn_Print_Click).
      /*  */
      /* toolSBtn_History */
      /*  */
      this-object:toolSBtn_History:DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle:Image.
      this-object:toolSBtn_History:Image = cast(resources:GetObject("toolSBtn_History.Image"), System.Drawing.Image).
      this-object:toolSBtn_History:ImageTransparentColor = System.Drawing.Color:Magenta.
      this-object:toolSBtn_History:Name = "toolSBtn_History".
      this-object:toolSBtn_History:Size = new System.Drawing.Size(36, 31).
      this-object:toolSBtn_History:Text = "История".
      this-object:toolSBtn_History:Click:Subscribe(this-object:toolSBtn_History_Click).
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:label1:Location = new System.Drawing.Point(450, 0).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(44, 34).
      this-object:label1:TabIndex = 3.
      this-object:label1:Text = "Дата :".
      this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
      this-object:label1:UseCompatibleTextRendering = true.
      /*  */
      /* dateTimePicker1 */
      /*  */
      this-object:dateTimePicker1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:dateTimePicker1:Location = new System.Drawing.Point(500, 3).
      this-object:dateTimePicker1:Name = "dateTimePicker1".
      this-object:dateTimePicker1:Size = new System.Drawing.Size(144, 20).
      this-object:dateTimePicker1:TabIndex = 4.
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:label2:Location = new System.Drawing.Point(650, 0).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(54, 34).
      this-object:label2:TabIndex = 5.
      this-object:label2:Text = "Статус :".
      this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* comboBox1 */
      /*  */
      this-object:comboBox1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:comboBox1:FormattingEnabled = true.
      this-object:comboBox1:Location = new System.Drawing.Point(710, 3).
      this-object:comboBox1:Name = "comboBox1".
      this-object:comboBox1:Size = new System.Drawing.Size(144, 21).
      this-object:comboBox1:TabIndex = 6.
      /*  */
      /* button1 */
      /*  */
      this-object:button1:Image = cast(resources:GetObject("button1.Image"), System.Drawing.Image).
      this-object:button1:Location = new System.Drawing.Point(857, 0).
      this-object:button1:Margin = new System.Windows.Forms.Padding(0).
      this-object:button1:Name = "button1".
      this-object:button1:Size = new System.Drawing.Size(35, 34).
      this-object:button1:TabIndex = 7.
      this-object:button1:UseCompatibleTextRendering = true.
      this-object:button1:UseVisualStyleBackColor = true.
      this-object:button1:Click:Subscribe(this-object:button1_Click).
      /*  */
      /* NameAction */
      /*  */
      this-object:NameAction:DataPropertyName = "NameAction".
      this-object:NameAction:FillWeight = Progress.Util.CastUtil:ToSingle(300).
      this-object:NameAction:HeaderText = "Наименование акции".
      this-object:NameAction:Name = "NameAction".
      this-object:NameAction:Width = 407.
      /*  */
      /* dataGridViewTextBoxColumn1 */
      /*  */
      this-object:dataGridViewTextBoxColumn1:DataPropertyName = "NameAction".
      this-object:dataGridViewTextBoxColumn1:HeaderText = "NameAction".
      this-object:dataGridViewTextBoxColumn1:Name = "dataGridViewTextBoxColumn1".
      /*  */
      /* Chang */
      /*  */
      this-object:Chang:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
      this-object:Chang:DataPropertyName = "Chang".
      this-object:Chang:FillWeight = Progress.Util.CastUtil:ToSingle(40.6091385).
      this-object:Chang:HeaderText = "".
      this-object:Chang:Name = "Chang".
      this-object:Chang:Width = 20.
      /*  */
      /* dataGridViewTextBoxColumn2 */
      /*  */
      this-object:dataGridViewTextBoxColumn2:DataPropertyName = "nameAction".
      this-object:dataGridViewTextBoxColumn2:FillWeight = Progress.Util.CastUtil:ToSingle(101.9434814).
      this-object:dataGridViewTextBoxColumn2:HeaderText = "Наименование".
      this-object:dataGridViewTextBoxColumn2:Name = "dataGridViewTextBoxColumn2".
      this-object:dataGridViewTextBoxColumn2:Width = 138.
      /*  */
      /* begdateDataGridViewTextBoxColumn */
      /*  */
      this-object:begdateDataGridViewTextBoxColumn:DataPropertyName = "beg-date".
      this-object:begdateDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(122.1251755).
      this-object:begdateDataGridViewTextBoxColumn:HeaderText = "Дата начала".
      this-object:begdateDataGridViewTextBoxColumn:Name = "begdateDataGridViewTextBoxColumn".
      this-object:begdateDataGridViewTextBoxColumn:Width = 166.
      /*  */
      /* enddateDataGridViewTextBoxColumn */
      /*  */
      this-object:enddateDataGridViewTextBoxColumn:DataPropertyName = "end-date".
      this-object:enddateDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(122.1251755).
      this-object:enddateDataGridViewTextBoxColumn:HeaderText = "Дата окончания".
      this-object:enddateDataGridViewTextBoxColumn:Name = "enddateDataGridViewTextBoxColumn".
      this-object:enddateDataGridViewTextBoxColumn:Width = 166.
      /*  */
      /* status_lbl */
      /*  */
      this-object:status_lbl:DataPropertyName = "status_lbl".
      this-object:status_lbl:FillWeight = Progress.Util.CastUtil:ToSingle(101.9434814).
      this-object:status_lbl:HeaderText = "Статус".
      this-object:status_lbl:Name = "status_lbl".
      this-object:status_lbl:Width = 138.
      /*  */
      /* id */
      /*  */
      this-object:id:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
      this-object:id:DataPropertyName = "id".
      this-object:id:FillWeight = Progress.Util.CastUtil:ToSingle(91.456604).
      this-object:id:HeaderText = "id".
      this-object:id:Name = "id".
      this-object:id:Width = 50.
      /*  */
      /* wListActions */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(947, 427).
      this-object:Controls:Add(this-object:tableLayoutPanel1).
      this-object:Name = "wListActions".
      this-object:Text = "Список акций".
      this-object:tableLayoutPanel1:ResumeLayout(false).
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindAction, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:tableLayoutPanel2:ResumeLayout(false).
      this-object:toolStrip1:ResumeLayout(false).
      this-object:toolStrip1:PerformLayout().
      this-object:ResumeLayout(false).
      {gbl\ed_date_cls.i this-object:dateTimePicker1 This-object}
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void toolSBtn_Copy_Click( input sender as System.Object, input e as System.EventArgs ):
		 m-promo-trg:copyOnePromo() . 
     bindAction:handle:query-open.
     bindAction:Refresh().
		return.

	end method.

    /*------------------------------------------------------------------------------
     Purpose: Резерв!
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void toolSBtn_Main_Click( input sender as System.Object, input e as System.EventArgs ):
        
        return.

    end method.

	/*------------------------------------------------------------------------------
     Purpose: вызвать в _trg метод создания и запуска формы редактирования с экземпляром класса редактируемой записи на входе
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void toolSBtn_Add_Click( input sender as System.Object, input e as System.EventArgs ):
		
    /* текущая строка data-grid автоматом позиционирует буффер по строке temp-table;
       позиционируется буффер, рамположенный в _trg по экземпляру таблицы tt-promoaction из _trg;
       записи в локальном экземпляре таблицы tt-promoaction отсутствуют
    */
      addaction().
      return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void toolSBtn_Status_Click( input sender as System.Object, input e as System.EventArgs ):
		m-promo-trg:editOnePromoStatus().
		bindAction:Refresh().
		return.

	end method.

    method private void Addaction():
        
    /* текущая строка data-grid автоматом позиционирует буффер по строке temp-table;
       позиционируется буффер, рамположенный в _trg по экземпляру таблицы tt-promoaction из _trg;
       записи в локальном экземпляре таблицы tt-promoaction отсутствуют
    */
    m-promo-trg:addOnePromo() . 
      /* получает созданную запись. Либо он её получит, либо мы его рефрешим.
        добавть запись - assignItem()
      */
      bindAction:handle:query-open.
      bindAction:Refreshall().
      bindAction:position = 100000 . // пока в конец списка
      return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void toolSBtn_Edit_Click( input sender as System.Object, input e as System.EventArgs ):
	    m-promo-trg:editOnePromo(). 
	   // bindAction:handle:query-open().
	    bindAction:Refresh().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID toolSBtn_Ok_Click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		bindAction:Assign().
		oPromoActionSubs = m-promo-trg:ReturnSubsPromoAction(). 
		Close().
		RETURN.

	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void toolSBtn_Star_Click( input sender as System.Object, input e as System.EventArgs ):
	  define variable vPos as integer no-undo.
	  vPos = bindAction:position.
		m-promo-trg:changeRow(yes).
		bindAction:Refreshall().
		bindAction:position = vPos.
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void toolSBtn_View_Click( input sender as System.Object, input e as System.EventArgs ):
		 m-promo-trg:viewOnePromo().
		 bindAction:Refresh().
		return.

	end method.
    
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void toolSBtn_Delete_Click( input sender as System.Object, input e as System.EventArgs ):
        define variable vPos as integer no-undo.
        vPos = bindAction:position.
        m-promo-trg:DelOnePromo().
        bindAction:handle:query-open().
        bindAction:Refreshall().
        bindAction:position = vPos.
        return.

    end method.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    @VisualDesigner.
    method private void toolSBtn_Exit_Click( input sender as System.Object, input e as System.EventArgs ):
        Close().
        return.

    end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void toolSBtn_Print_Click( input sender as System.Object, input e as System.EventArgs ):
    m-promo-trg:printPromoActionList() .
    return.
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void toolSBtn_History_Click( input sender as System.Object, input e as System.EventArgs ):
    m-promo-trg:histOnePromo() .
    return.
  end method.



	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID toolStrip1_DoubleClick( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
		Visual_Columns(NOT THIS-OBJECT:dataGridView1:Columns[6]:Visible).
		RETURN.

	END METHOD.


    METHOD PUBLIC VOID Visual_Buttons(INPUT sender AS LOGICAL): 
        
        assign
            THIS-OBJECT:toolSBtn_Add:Visible                = not sender
            THIS-OBJECT:toolSBtn_Edit:Visible               = not sender
            THIS-OBJECT:toolSBtn_Add:Visible                = not sender
            THIS-OBJECT:toolSBtn_Delete:Visible             = not sender
            THIS-OBJECT:toolSBtn_Ok:Visible                 =     sender
            THIS-OBJECT:toolSBtn_Star:Visible               =     sender
            THIS-OBJECT:toolSBtn_Copy:Visible               = not sender
            THIS-OBJECT:toolSBtn_Status:Visible             = not sender
            THIS-OBJECT:toolSBtn_Print:Visible              = not sender
            THIS-OBJECT:toolSBtn_History:Visible            = not sender
            THIS-OBJECT:dataGridView1:Columns[0]:Visible    =     sender
        .
        

    END METHOD.
    METHOD PUBLIC VOID Visual_Columns(INPUT sender AS LOGICAL): 
        
        assign
            THIS-OBJECT:dataGridView1:Columns[6]:Visible = sender.
            THIS-OBJECT:dataGridView1:Columns[5]:Visible = sender.
        .
        

    END METHOD.

end class.