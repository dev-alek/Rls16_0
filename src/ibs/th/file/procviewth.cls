 
 /*------------------------------------------------------------------------
    File        : ProcViewth
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Thu Jan 03 03:42:33 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

block-level on error undo, throw.

class ibs.th.file.ProcViewth inherits Form: 
    
    define private variable bindProc as Progress.Data.BindingSource no-undo.
    define private variable button1 as System.Windows.Forms.Button no-undo.
    define private variable button3 as System.Windows.Forms.Button no-undo.
    define private variable button2 as System.Windows.Forms.Button no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable olditemDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable itemDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable fpidDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable fmaxitemDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable fmaxDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable procDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable numDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
    define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
    define private variable mAsyncHelper as class ibs.th.file.AsyncHelperth no-undo.
    define private variable timer1 as System.Windows.Forms.Timer no-undo.
    define public property MWorkDir as character no-undo
    get.
    set (arg as char):
      
      MWorkDir = arg.
      refreshgrid().
      
    end.    
    constructor public ProcViewth (  ):
        
        
        super().
        mAsyncHelper = new ibs.th.file.AsyncHelperth().
        InitializeComponent().
        this-object:ComponentsCollection:ADD(this-object:components).
        bindProc:handle = mAsyncHelper:getqueryttrun().
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
	    refreshgrid().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
		mAsyncHelper:Stopprc(MWorkDir).
		refreshgrid().
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void button3_Click( input sender as System.Object, input e as System.EventArgs ):
		mAsyncHelper:termprc(MWorkDir).
		refreshgrid().
		return.

	end method.

    method private void refreshgrid( ):
        bindProc:Handle:query-close().
        mAsyncHelper:creatTTForProc(MWorkDir).
        bindProc:Handle:query-open().
        bindProc:RefreshAll().
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
        tableDesc1 = new Progress.Data.TableDesc("ttRun").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("ibs.th.file.ProcViewth").
        this-object:bindProc = new Progress.Data.BindingSource(this-object:components).
        this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
        this-object:procDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:itemDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:olditemDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:fmaxitemDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:fpidDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:numDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:fmaxDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:button1 = new System.Windows.Forms.Button().
        this-object:button2 = new System.Windows.Forms.Button().
        this-object:button3 = new System.Windows.Forms.Button().
        this-object:timer1 = new System.Windows.Forms.Timer(this-object:components).
        cast(this-object:bindProc, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:SuspendLayout().
        /*  */
        /* bindProc */
        /*  */
        this-object:bindProc:MaxDataGuess = 0.
        this-object:bindProc:NoLOBs = false.
        this-object:bindProc:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar0 = new "Progress.Data.TableDesc[]"(0).
        tableDesc1:ChildTables = arrayvar0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 7 no-undo.
        arrayvar1[1] = new Progress.Data.ColumnPropDesc("proc", "Код процесса", Progress.Data.DataType:CHARACTER).
        arrayvar1[2] = new Progress.Data.ColumnPropDesc("num", "Номер процесса", Progress.Data.DataType:INTEGER).
        arrayvar1[3] = new Progress.Data.ColumnPropDesc("item", "Обработано объектов", Progress.Data.DataType:INTEGER).
        arrayvar1[4] = new Progress.Data.ColumnPropDesc("olditem", "Обработано объектов на предыдущем шаге", Progress.Data.DataType:INTEGER).
        arrayvar1[5] = new Progress.Data.ColumnPropDesc("fmaxitem", "Всего объекьтов для обработки", Progress.Data.DataType:INTEGER).
        arrayvar1[6] = new Progress.Data.ColumnPropDesc("fpid", "pid", Progress.Data.DataType:INTEGER).
        arrayvar1[7] = new Progress.Data.ColumnPropDesc("fmax", "Всего процессов", Progress.Data.DataType:INTEGER).
        tableDesc1:Columns = arrayvar1.
        this-object:bindProc:TableSchema = tableDesc1.
        /*  */
        /* dataGridView1 */
        /*  */
        this-object:dataGridView1:AllowUserToAddRows = false.
        this-object:dataGridView1:AllowUserToDeleteRows = false.
        this-object:dataGridView1:AllowUserToResizeColumns = false.
        resources:ApplyResources(this-object:dataGridView1, "dataGridView1").
        this-object:dataGridView1:AutoGenerateColumns = false.
        this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as System.Windows.Forms.DataGridViewColumn extent 7 no-undo.
        arrayvar2[1] = this-object:procDataGridViewTextBoxColumn.
        arrayvar2[2] = this-object:itemDataGridViewTextBoxColumn.
        arrayvar2[3] = this-object:olditemDataGridViewTextBoxColumn.
        arrayvar2[4] = this-object:fmaxitemDataGridViewTextBoxColumn.
        arrayvar2[5] = this-object:fpidDataGridViewTextBoxColumn.
        arrayvar2[6] = this-object:numDataGridViewTextBoxColumn.
        arrayvar2[7] = this-object:fmaxDataGridViewTextBoxColumn.
        this-object:dataGridView1:Columns:AddRange(arrayvar2).
        this-object:dataGridView1:DataSource = this-object:bindProc.
        this-object:dataGridView1:EnableHeadersVisualStyles = false.
        this-object:dataGridView1:MultiSelect = false.
        this-object:dataGridView1:Name = "dataGridView1".
        this-object:dataGridView1:ReadOnly = true.
        this-object:dataGridView1:RowHeadersVisible = false.
        /*  */
        /* procDataGridViewTextBoxColumn */
        /*  */
        this-object:procDataGridViewTextBoxColumn:DataPropertyName = "proc".
        resources:ApplyResources(this-object:procDataGridViewTextBoxColumn, "procDataGridViewTextBoxColumn").
        this-object:procDataGridViewTextBoxColumn:Name = "procDataGridViewTextBoxColumn".
        this-object:procDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* itemDataGridViewTextBoxColumn */
        /*  */
        this-object:itemDataGridViewTextBoxColumn:DataPropertyName = "item".
        resources:ApplyResources(this-object:itemDataGridViewTextBoxColumn, "itemDataGridViewTextBoxColumn").
        this-object:itemDataGridViewTextBoxColumn:Name = "itemDataGridViewTextBoxColumn".
        this-object:itemDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* olditemDataGridViewTextBoxColumn */
        /*  */
        this-object:olditemDataGridViewTextBoxColumn:DataPropertyName = "olditem".
        resources:ApplyResources(this-object:olditemDataGridViewTextBoxColumn, "olditemDataGridViewTextBoxColumn").
        this-object:olditemDataGridViewTextBoxColumn:Name = "olditemDataGridViewTextBoxColumn".
        this-object:olditemDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* fmaxitemDataGridViewTextBoxColumn */
        /*  */
        this-object:fmaxitemDataGridViewTextBoxColumn:DataPropertyName = "fmaxitem".
        resources:ApplyResources(this-object:fmaxitemDataGridViewTextBoxColumn, "fmaxitemDataGridViewTextBoxColumn").
        this-object:fmaxitemDataGridViewTextBoxColumn:Name = "fmaxitemDataGridViewTextBoxColumn".
        this-object:fmaxitemDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* fpidDataGridViewTextBoxColumn */
        /*  */
        this-object:fpidDataGridViewTextBoxColumn:DataPropertyName = "fpid".
        resources:ApplyResources(this-object:fpidDataGridViewTextBoxColumn, "fpidDataGridViewTextBoxColumn").
        this-object:fpidDataGridViewTextBoxColumn:Name = "fpidDataGridViewTextBoxColumn".
        this-object:fpidDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* numDataGridViewTextBoxColumn */
        /*  */
        this-object:numDataGridViewTextBoxColumn:DataPropertyName = "num".
        resources:ApplyResources(this-object:numDataGridViewTextBoxColumn, "numDataGridViewTextBoxColumn").
        this-object:numDataGridViewTextBoxColumn:Name = "numDataGridViewTextBoxColumn".
        this-object:numDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* fmaxDataGridViewTextBoxColumn */
        /*  */
        this-object:fmaxDataGridViewTextBoxColumn:DataPropertyName = "fmax".
        resources:ApplyResources(this-object:fmaxDataGridViewTextBoxColumn, "fmaxDataGridViewTextBoxColumn").
        this-object:fmaxDataGridViewTextBoxColumn:Name = "fmaxDataGridViewTextBoxColumn".
        this-object:fmaxDataGridViewTextBoxColumn:ReadOnly = true.
        /*  */
        /* button1 */
        /*  */
        resources:ApplyResources(this-object:button1, "button1").
        this-object:button1:Name = "button1".
        this-object:button1:UseCompatibleTextRendering = true.
        this-object:button1:UseVisualStyleBackColor = true.
        this-object:button1:Click:Subscribe(this-object:button1_Click).
        /*  */
        /* button2 */
        /*  */
        resources:ApplyResources(this-object:button2, "button2").
        this-object:button2:Name = "button2".
        this-object:button2:UseCompatibleTextRendering = true.
        this-object:button2:UseVisualStyleBackColor = true.
        this-object:button2:Click:Subscribe(this-object:button2_Click).
        /*  */
        /* button3 */
        /*  */
        resources:ApplyResources(this-object:button3, "button3").
        this-object:button3:Name = "button3".
        this-object:button3:UseCompatibleTextRendering = true.
        this-object:button3:UseVisualStyleBackColor = true.
        this-object:button3:Click:Subscribe(this-object:button3_Click).
        /*  */
        /* timer1 */
        /*  */
        this-object:timer1:Enabled = true.
        this-object:timer1:Interval = 10000.
        this-object:timer1:Tick:Subscribe(this-object:timer1_Tick).
        /*  */
        /* ProcView */
        /*  */
        resources:ApplyResources(this-object, "$this").
        this-object:Controls:Add(this-object:button3).
        this-object:Controls:Add(this-object:button2).
        this-object:Controls:Add(this-object:button1).
        this-object:Controls:Add(this-object:dataGridView1).
        this-object:Name = "ProcViewth".
        cast(this-object:bindProc, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
    end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void timer1_Tick( input sender as System.Object, input e as System.EventArgs ):
		refreshgrid().
		return.

	end method.

    destructor public ProcViewth ( ):
       delete object mAsyncHelper.
    end destructor.

end class.