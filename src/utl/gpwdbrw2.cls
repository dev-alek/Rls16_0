/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Браузер записей техпроливов 

Автор: Сергей Палагин
Дата создания: 21/10/18
Author: Sergey Palagin
Creation date: 21/10/18

*/
 
using Progress.Lang.*.
using Progress.Windows.Form.
using System.Windows.Forms.* from assembly.
using utl.*.

block-level on error undo, throw.

class utl.gpwdbrw2 inherits Form: 
    
   define private variable btnReport as System.Windows.Forms.Button no-undo.
   define private variable btnFilter as System.Windows.Forms.Button no-undo.
   define private variable btnView       as System.Windows.Forms.Button       no-undo.
   define private variable btnAdd        as System.Windows.Forms.Button       no-undo.
   define private variable btnExit       as System.Windows.Forms.Button       no-undo.
   define private variable components    as System.ComponentModel.IContainer  no-undo.
   define private variable dataGridView1 as System.Windows.Forms.DataGridView no-undo.
   define private variable dataGridViewTextBoxColumn1 as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable fdateDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable fDetailsDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable fTimeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable fHostNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable fUserDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable Id as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable panel1        as System.Windows.Forms.Panel        no-undo.
   define private variable pbsTechPwd    as Progress.Data.BindingSource       no-undo.
   define private variable statusStrip1  as System.Windows.Forms.StatusStrip  no-undo.

   define public property DataProvider as utl.gpwdbrw-data2 no-undo 
   get.
   set. 

   define public property Filter as utl.gpwdbrw-filter no-undo 
   get.
   set. 

   constructor public gpwdbrw2():
        
        
      super().
      InitializeComponent().
        
      this-object:ComponentsCollection:ADD(this-object:components).
      Inits().
   end constructor.
   
       
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btnAdd_Click( input sender as System.Object, input e as System.EventArgs ):
		
      define variable vFrm as class gpwdfrm2 no-undo.
		
      vFrm = gpwdfrm2:GetObject("Add",new tech-prol-pwd())no-error.
      if error-status:error
      then
         return.
		
      wait-for vFrm:ShowDialog().
      
      DataProvider:RefreshQuery(this-object:Filter).
		
      return.

   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnFilter_Click( input sender as System.Object, input e as System.EventArgs ):

      define variable vFrm as class utl.gpwdbrw_flt no-undo.
      def var vDialogResult as class System.Windows.Forms.DialogResult no-undo.
      vFrm = utl.gpwdbrw_flt:GetObject(this-object:Filter).
      
      wait-for vFrm:ShowDialog() set vDialogResult.
      
      if vDialogResult = System.Windows.Forms.DialogResult:ok then
         DataProvider:RefreshQuery(this-object:Filter).
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btnReport_Click( input sender as System.Object, input e as System.EventArgs ):
		
		DataProvider:Report(this-object:Filter).
		return.

	end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btnView_Click( input sender as System.Object, input e as System.EventArgs ):

      define variable vFrm as class gpwdfrm2 no-undo.
      
      define variable vEntity as class tech-prol-pwd no-undo.
      define variable vRepository as class repoPwd2 no-undo.
      
      if valid-object(dataGridView1:CurrentRow) then
      do:
         assign
            vEntity = new tech-prol-pwd()
            vEntity:id = int64(string(dataGridView1:CurrentRow:Cells[0]:Value))
            vRepository = new repoPwd2(vEntity)
         .
   
         vRepository:Refresh().
            
         vFrm = gpwdfrm2:GetObject("View",vEntity).
         
         wait-for vFrm:ShowDialog().
      end.		
      return.

   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void dataGridView1_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void gpwdbrw_Load( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/

   method public void Inits():
      
      assign
         DataProvider = new gpwdbrw-data2()
         this-object:Filter = utl.gpwdbrw-filter:GetObject()
      .
      
      DataProvider:RefreshTT(this-object:Filter).  
      pbsTechPwd:Handle = DataProvider:GetQuery().
      DataGridView1:Columns[0]:Visible = false.
      
      return.
      
   end method.
   
   method public void Wait ( ):
      
      wait-for this-object:ShowDialog().
   end method.

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   @VisualDesigner.
   method private void btnExit_Click( input sender as System.Object, input e as System.EventArgs ):
      this-object:Close().
      return.

   end method.



   method private void InitializeComponent(  ):
        
      /* NOTE: The following method is automatically generated.
        
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
        
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable dataGridViewCellStyle1 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle1 = new System.Windows.Forms.DataGridViewCellStyle().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable dataGridViewCellStyle2 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle2 = new System.Windows.Forms.DataGridViewCellStyle().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable dataGridViewCellStyle3 as System.Windows.Forms.DataGridViewCellStyle no-undo.
      dataGridViewCellStyle3 = new System.Windows.Forms.DataGridViewCellStyle().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("ttPwd").
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:btnReport = new System.Windows.Forms.Button().
      this-object:btnFilter = new System.Windows.Forms.Button().
      this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
      this-object:Id = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:dataGridViewTextBoxColumn1 = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:fTimeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:fHostNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:fUserDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:fDetailsDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:pbsTechPwd = new Progress.Data.BindingSource(this-object:components).
      this-object:statusStrip1 = new System.Windows.Forms.StatusStrip().
      this-object:btnView = new System.Windows.Forms.Button().
      this-object:btnAdd = new System.Windows.Forms.Button().
      this-object:btnExit = new System.Windows.Forms.Button().
      this-object:panel1:SuspendLayout().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:pbsTechPwd, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      /*  */
      /* panel1 */
      /*  */
      this-object:panel1:AutoSize = true.
      this-object:panel1:Controls:Add(this-object:btnReport).
      this-object:panel1:Controls:Add(this-object:btnFilter).
      this-object:panel1:Controls:Add(this-object:dataGridView1).
      this-object:panel1:Controls:Add(this-object:statusStrip1).
      this-object:panel1:Controls:Add(this-object:btnView).
      this-object:panel1:Controls:Add(this-object:btnAdd).
      this-object:panel1:Controls:Add(this-object:btnExit).
      this-object:panel1:Dock = System.Windows.Forms.DockStyle:Fill.
      this-object:panel1:Location = new System.Drawing.Point(0, 0).
      this-object:panel1:Name = "panel1".
      this-object:panel1:Size = new System.Drawing.Size(926, 471).
      this-object:panel1:TabIndex = 0.
      /*  */
      /* btnReport */
      /*  */
      this-object:btnReport:Location = new System.Drawing.Point(396, 12).
      this-object:btnReport:Name = "btnReport".
      this-object:btnReport:Size = new System.Drawing.Size(75, 23).
      this-object:btnReport:TabIndex = 6.
      this-object:btnReport:Text = "Отчет".
      this-object:btnReport:UseCompatibleTextRendering = true.
      this-object:btnReport:UseVisualStyleBackColor = true.
      this-object:btnReport:Click:Subscribe(this-object:btnReport_Click).
      /*  */
      /* btnFilter */
      /*  */
      this-object:btnFilter:Location = new System.Drawing.Point(294, 12).
      this-object:btnFilter:Name = "btnFilter".
      this-object:btnFilter:Size = new System.Drawing.Size(75, 23).
      this-object:btnFilter:TabIndex = 5.
      this-object:btnFilter:Text = "Фильтр".
      this-object:btnFilter:UseCompatibleTextRendering = true.
      this-object:btnFilter:UseVisualStyleBackColor = true.
      this-object:btnFilter:Click:Subscribe(this-object:btnFilter_Click).
      /*  */
      /* dataGridView1 */
      /*  */
      this-object:dataGridView1:AllowUserToAddRows = false.
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:dataGridView1:AutoGenerateColumns = false.
      dataGridViewCellStyle1:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
      dataGridViewCellStyle1:BackColor = System.Drawing.SystemColors:Control.
      dataGridViewCellStyle1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      dataGridViewCellStyle1:ForeColor = System.Drawing.SystemColors:WindowText.
      dataGridViewCellStyle1:SelectionBackColor = System.Drawing.SystemColors:Highlight.
      dataGridViewCellStyle1:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
      dataGridViewCellStyle1:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
      this-object:dataGridView1:ColumnHeadersDefaultCellStyle = dataGridViewCellStyle1.
      this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 6 no-undo.
      arrayvar0[1] = this-object:Id.
      arrayvar0[2] = this-object:dataGridViewTextBoxColumn1.
      arrayvar0[3] = this-object:fTimeDataGridViewTextBoxColumn.
      arrayvar0[4] = this-object:fHostNameDataGridViewTextBoxColumn.
      arrayvar0[5] = this-object:fUserDataGridViewTextBoxColumn.
      arrayvar0[6] = this-object:fDetailsDataGridViewTextBoxColumn.
      this-object:dataGridView1:Columns:AddRange(arrayvar0).
      this-object:dataGridView1:DataSource = this-object:pbsTechPwd.
      dataGridViewCellStyle2:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
      dataGridViewCellStyle2:BackColor = System.Drawing.SystemColors:Window.
      dataGridViewCellStyle2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      dataGridViewCellStyle2:ForeColor = System.Drawing.SystemColors:ControlText.
      dataGridViewCellStyle2:SelectionBackColor = System.Drawing.SystemColors:Highlight.
      dataGridViewCellStyle2:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
      dataGridViewCellStyle2:WrapMode = System.Windows.Forms.DataGridViewTriState:False.
      this-object:dataGridView1:DefaultCellStyle = dataGridViewCellStyle2.
      this-object:dataGridView1:Location = new System.Drawing.Point(12, 70).
      this-object:dataGridView1:MultiSelect = false.
      this-object:dataGridView1:Name = "dataGridView1".
      this-object:dataGridView1:ReadOnly = true.
      dataGridViewCellStyle3:Alignment = System.Windows.Forms.DataGridViewContentAlignment:MiddleLeft.
      dataGridViewCellStyle3:BackColor = System.Drawing.SystemColors:Control.
      dataGridViewCellStyle3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      dataGridViewCellStyle3:ForeColor = System.Drawing.SystemColors:WindowText.
      dataGridViewCellStyle3:SelectionBackColor = System.Drawing.SystemColors:Highlight.
      dataGridViewCellStyle3:SelectionForeColor = System.Drawing.SystemColors:HighlightText.
      dataGridViewCellStyle3:WrapMode = System.Windows.Forms.DataGridViewTriState:True.
      this-object:dataGridView1:RowHeadersDefaultCellStyle = dataGridViewCellStyle3.
      this-object:dataGridView1:Size = new System.Drawing.Size(902, 367).
      this-object:dataGridView1:TabIndex = 4.
      this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
      /*  */
      /* Id */
      /*  */
      this-object:Id:DataPropertyName = "Id".
      this-object:Id:HeaderText = "Id".
      this-object:Id:Name = "Id".
      this-object:Id:ReadOnly = true.
      /*  */
      /* dataGridViewTextBoxColumn1 */
      /*  */
      this-object:dataGridViewTextBoxColumn1:DataPropertyName = "fDate".
      this-object:dataGridViewTextBoxColumn1:HeaderText = "Дата".
      this-object:dataGridViewTextBoxColumn1:Name = "dataGridViewTextBoxColumn1".
      this-object:dataGridViewTextBoxColumn1:ReadOnly = true.
      /*  */
      /* fTimeDataGridViewTextBoxColumn */
      /*  */
      this-object:fTimeDataGridViewTextBoxColumn:DataPropertyName = "fTime".
      this-object:fTimeDataGridViewTextBoxColumn:HeaderText = "Время".
      this-object:fTimeDataGridViewTextBoxColumn:Name = "fTimeDataGridViewTextBoxColumn".
      this-object:fTimeDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* fHostNameDataGridViewTextBoxColumn */
      /*  */
      this-object:fHostNameDataGridViewTextBoxColumn:DataPropertyName = "fHostName".
      this-object:fHostNameDataGridViewTextBoxColumn:HeaderText = "Хост".
      this-object:fHostNameDataGridViewTextBoxColumn:Name = "fHostNameDataGridViewTextBoxColumn".
      this-object:fHostNameDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* fUserDataGridViewTextBoxColumn */
      /*  */
      this-object:fUserDataGridViewTextBoxColumn:DataPropertyName = "fUser".
      this-object:fUserDataGridViewTextBoxColumn:HeaderText = "Пользователь".
      this-object:fUserDataGridViewTextBoxColumn:Name = "fUserDataGridViewTextBoxColumn".
      this-object:fUserDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* fDetailsDataGridViewTextBoxColumn */
      /*  */
      this-object:fDetailsDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:fDetailsDataGridViewTextBoxColumn:DataPropertyName = "fDetails".
      this-object:fDetailsDataGridViewTextBoxColumn:HeaderText = "Детали".
      this-object:fDetailsDataGridViewTextBoxColumn:Name = "fDetailsDataGridViewTextBoxColumn".
      this-object:fDetailsDataGridViewTextBoxColumn:ReadOnly = true.
      /*  */
      /* pbsTechPwd */
      /*  */
      this-object:pbsTechPwd:MaxDataGuess = 0.
      this-object:pbsTechPwd:NoLOBs = false.
      this-object:pbsTechPwd:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 6 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("fDate", "Дата", Progress.Data.DataType:DATE).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("fTime", "Время", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("fHostName", "Хост", Progress.Data.DataType:CHARACTER).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("fUser", "Пользователь", Progress.Data.DataType:CHARACTER).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("fDetails", "Детали", Progress.Data.DataType:CHARACTER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("Id", "Ид", Progress.Data.DataType:INT64).
      tableDesc1:Columns = arrayvar2.
      this-object:pbsTechPwd:TableSchema = tableDesc1.
      /*  */
      /* statusStrip1 */
      /*  */
      this-object:statusStrip1:Location = new System.Drawing.Point(0, 449).
      this-object:statusStrip1:Name = "statusStrip1".
      this-object:statusStrip1:Size = new System.Drawing.Size(926, 22).
      this-object:statusStrip1:TabIndex = 3.
      this-object:statusStrip1:Text = "statusStrip1".
      /*  */
      /* btnView */
      /*  */
      this-object:btnView:Location = new System.Drawing.Point(174, 12).
      this-object:btnView:Name = "btnView".
      this-object:btnView:Size = new System.Drawing.Size(75, 23).
      this-object:btnView:TabIndex = 2.
      this-object:btnView:Text = "Просмотр".
      this-object:btnView:UseCompatibleTextRendering = true.
      this-object:btnView:UseVisualStyleBackColor = true.
      this-object:btnView:Click:Subscribe(this-object:btnView_Click).
      /*  */
      /* btnAdd */
      /*  */
      this-object:btnAdd:Location = new System.Drawing.Point(93, 12).
      this-object:btnAdd:Name = "btnAdd".
      this-object:btnAdd:Size = new System.Drawing.Size(75, 23).
      this-object:btnAdd:TabIndex = 1.
      this-object:btnAdd:Text = "Добавить".
      this-object:btnAdd:UseCompatibleTextRendering = true.
      this-object:btnAdd:UseVisualStyleBackColor = true.
      this-object:btnAdd:Click:Subscribe(this-object:btnAdd_Click).
      /*  */
      /* btnExit */
      /*  */
      this-object:btnExit:Location = new System.Drawing.Point(12, 12).
      this-object:btnExit:Name = "btnExit".
      this-object:btnExit:Size = new System.Drawing.Size(75, 23).
      this-object:btnExit:TabIndex = 0.
      this-object:btnExit:Text = "Выход".
      this-object:btnExit:UseCompatibleTextRendering = true.
      this-object:btnExit:UseVisualStyleBackColor = true.
      this-object:btnExit:Click:Subscribe(this-object:btnExit_Click).
      /*  */
      /* gpwdbrw */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(926, 471).
      this-object:Controls:Add(this-object:panel1).
      this-object:Name = "gpwdbrw".
      this-object:Text = "Журнал генерации паролей для технологического пролива".
      this-object:Load:Subscribe(this-object:gpwdbrw_Load).
      this-object:panel1:ResumeLayout(false).
      this-object:panel1:PerformLayout().
      cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:pbsTechPwd, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   method public static gpwdbrw2 GetObject():
      
      return new gpwdbrw2().
      
   end method.

   method public void DisposeForm():
      
      DataProvider:Dispose().
      
   end method.

   destructor public gpwdbrw2 ( ):
      DataProvider:Dispose().
   end destructor.

end class.