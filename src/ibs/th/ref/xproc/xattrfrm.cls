 /*------------------------------------------------------------------------
    File        : xattrFrm
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Nov 08 13:20:25 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class ibs.th.ref.xproc.xattrFrm inherits Form : 
   {cmp\str-glbl.i class}
   define private variable bindattr as Progress.Data.BindingSource no-undo.
   define private variable Accuracyl as System.Windows.Forms.Label no-undo.
   define private variable Accuracyf as System.Windows.Forms.NumericUpDown no-undo.
   define private variable ClableF as System.Windows.Forms.TextBox no-undo.
   define private variable CLableL as System.Windows.Forms.Label no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   define private variable descF as System.Windows.Forms.TextBox no-undo.
   define private variable Hiddenf as System.Windows.Forms.CheckBox no-undo.
   define private variable labelF as System.Windows.Forms.TextBox no-undo.
   define private variable labelL as System.Windows.Forms.Label no-undo.
   define private variable listvalue as System.Windows.Forms.CheckBox no-undo.
   define private variable NameL as System.Windows.Forms.Label no-undo.
   define private variable NameF as System.Windows.Forms.TextBox no-undo.
   define private variable MandatoryF as System.Windows.Forms.CheckBox no-undo.
   define private variable InitialL as System.Windows.Forms.Label no-undo.
   define private variable InitialF as System.Windows.Forms.TextBox no-undo.
   define private variable DomenCodeL as System.Windows.Forms.Label no-undo.
   define private variable DomenCodeF as System.Windows.Forms.TextBox no-undo.
   define private variable DescL as System.Windows.Forms.Label no-undo.
   define private variable DataTypeL as System.Windows.Forms.Label no-undo.
   define private variable DataTypeF as System.Windows.Forms.ComboBox no-undo.
   define private variable DataFormatL as System.Windows.Forms.Label no-undo.
   define private variable DataFormatF as System.Windows.Forms.TextBox no-undo.
   define private variable Constant as System.Windows.Forms.CheckBox no-undo.
   define private variable XattrCodeF as System.Windows.Forms.TextBox no-undo.
   define private variable ValidationL as System.Windows.Forms.Label no-undo.
   define private variable ValidationF as System.Windows.Forms.TextBox no-undo.
   define private variable OverridableF as System.Windows.Forms.CheckBox no-undo.
   define private variable OrderL as System.Windows.Forms.Label no-undo.
   define private variable OrderF as System.Windows.Forms.NumericUpDown no-undo.
   define private variable XattrCodeL as System.Windows.Forms.Label no-undo.
   define variable mtrg as ibs.th.ref.xproc.xattr_trg  no-undo.
   define variable mtrgCr as logical no-undo.
   
   constructor public xattrFrm( ):
   
      super().
      mtrg = new ibs.th.ref.xproc.xattr_trg ().
      mtrgCr = yes.
      InitializeComponent ( ).
      DataTypeF:Items:Add({&ABL-datatype-character}).
      DataTypeF:Items:Add({&ABL-datatype-Integer}).
      DataTypeF:Items:Add({&ABL-datatype-Decimal}).
      DataTypeF:Items:Add({&ABL-datatype-Logical}).
      DataTypeF:Items:Add({&ABL-datatype-date}).
      lockField(no).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.

   constructor public XattrFrm(itrg as ibs.th.ref.xproc.xattr_trg ):
      
      super().
      
      mtrg = itrg.
     
      InitializeComponent ( ).
      DataTypeF:Items:Add({&ABL-datatype-character}).
      DataTypeF:Items:Add({&ABL-datatype-Integer}).
      DataTypeF:Items:Add({&ABL-datatype-Decimal}).
      DataTypeF:Items:Add({&ABL-datatype-Logical}).
      DataTypeF:Items:Add({&ABL-datatype-date}).
      
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.
   destructor public xattrFrm( ):
      if mtrgCr
      then 
         delete object mtrg.
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.

   end destructor.   


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void DataTypeF_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		SetFormat().
		ChangeDataType().
		return.

	end method.


	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void GroupObjCodel_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      bindattr:Assign().
      this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
      this-object:Close ( ). 
   end method.

   method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
   end method.
    
   method private void InitializeComponent ( ):

      /* NOTE: The following method is automatically generated.
         
         We strongly suggest that the contents of this method only be modified using the 
         Visual Designer to avoid any incompatible modifications.
         
         Modifying the contents of this method using a code editor will invalidate any support for this file. */
      
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("Xattr").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:bindattr = new Progress.Data.BindingSource(this-object:components).
      this-object:XattrCodeL = new System.Windows.Forms.Label().
      this-object:XattrCodeF = new System.Windows.Forms.TextBox().
      this-object:Accuracyf = new System.Windows.Forms.NumericUpDown().
      this-object:Constant = new System.Windows.Forms.CheckBox().
      this-object:Accuracyl = new System.Windows.Forms.Label().
      this-object:DataFormatF = new System.Windows.Forms.TextBox().
      this-object:DataFormatL = new System.Windows.Forms.Label().
      this-object:descF = new System.Windows.Forms.TextBox().
      this-object:DescL = new System.Windows.Forms.Label().
      this-object:DataTypeF = new System.Windows.Forms.ComboBox().
      this-object:DataTypeL = new System.Windows.Forms.Label().
      this-object:DomenCodeF = new System.Windows.Forms.TextBox().
      this-object:DomenCodeL = new System.Windows.Forms.Label().
      this-object:InitialF = new System.Windows.Forms.TextBox().
      this-object:InitialL = new System.Windows.Forms.Label().
      this-object:Hiddenf = new System.Windows.Forms.CheckBox().
      this-object:NameF = new System.Windows.Forms.TextBox().
      this-object:NameL = new System.Windows.Forms.Label().
      this-object:MandatoryF = new System.Windows.Forms.CheckBox().
      this-object:ValidationF = new System.Windows.Forms.TextBox().
      this-object:OrderF = new System.Windows.Forms.NumericUpDown().
      this-object:OrderL = new System.Windows.Forms.Label().
      this-object:OverridableF = new System.Windows.Forms.CheckBox().
      this-object:ValidationL = new System.Windows.Forms.Label().
      this-object:ClableF = new System.Windows.Forms.TextBox().
      this-object:CLableL = new System.Windows.Forms.Label().
      this-object:labelF = new System.Windows.Forms.TextBox().
      this-object:labelL = new System.Windows.Forms.Label().
      this-object:listvalue = new System.Windows.Forms.CheckBox().
      cast(this-object:bindattr, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:Accuracyf, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:OrderF, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      /*  */
      /* buttonOk */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonOk:Location = new System.Drawing.Point(438, 430).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "OK".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      /*  */
      /* buttonCancel */
      /*  */
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
      this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(522, 430).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Cancel".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      /*  */
      /* bindattr */
      /*  */
      this-object:bindattr:MaxDataGuess = 0.
      this-object:bindattr:NoLOBs = false.
      this-object:bindattr:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 17 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("Accuracy", "Точность", Progress.Data.DataType:INTEGER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("Constant", "Неизменяемый", Progress.Data.DataType:LOGICAL).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("Data-Format", "Формат реквизита", Progress.Data.DataType:CHARACTER).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("Data-Type", "Тип реквизита", Progress.Data.DataType:CHARACTER).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("Description", "Описание", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("Domain-Code", "Домен", Progress.Data.DataType:CHARACTER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("Hidden", "Скрытый", Progress.Data.DataType:LOGICAL).
      arrayvar1[8] = new Progress.Data.ColumnPropDesc("Initial", "Нач. значение", Progress.Data.DataType:CHARACTER).
      arrayvar1[9] = new Progress.Data.ColumnPropDesc("Mandatory", "Обязателен", Progress.Data.DataType:LOGICAL).
      arrayvar1[10] = new Progress.Data.ColumnPropDesc("Name", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar1[11] = new Progress.Data.ColumnPropDesc("order", "Номер", Progress.Data.DataType:INTEGER).
      arrayvar1[12] = new Progress.Data.ColumnPropDesc("Overridable", "Переопределяемый", Progress.Data.DataType:LOGICAL).
      arrayvar1[13] = new Progress.Data.ColumnPropDesc("Validation", "Валидация", Progress.Data.DataType:CHARACTER).
      arrayvar1[14] = new Progress.Data.ColumnPropDesc("xattr-clabel", "МЕТКА", Progress.Data.DataType:CHARACTER).
      arrayvar1[15] = new Progress.Data.ColumnPropDesc("Xattr-Code", "Код реквизита", Progress.Data.DataType:CHARACTER).
      arrayvar1[16] = new Progress.Data.ColumnPropDesc("xattr-label", "Метка", Progress.Data.DataType:CHARACTER).
      arrayvar1[17] = new Progress.Data.ColumnPropDesc("ListValue", "Список", Progress.Data.DataType:LOGICAL).
      tableDesc1:Columns = arrayvar1.
      this-object:bindattr:TableSchema = tableDesc1.
      /*  */
      /* XattrCodeL */
      /*  */
      this-object:XattrCodeL:Location = new System.Drawing.Point(13, 13).
      this-object:XattrCodeL:Name = "XattrCodeL".
      this-object:XattrCodeL:Size = new System.Drawing.Size(100, 23).
      this-object:XattrCodeL:TabIndex = 2.
      this-object:XattrCodeL:Text = "Код".
      this-object:XattrCodeL:UseCompatibleTextRendering = true.
      this-object:XattrCodeL:Click:Subscribe(this-object:GroupObjCodel_Click).
      /*  */
      /* XattrCodeF */
      /*  */
      this-object:XattrCodeF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Xattr-Code", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:XattrCodeF:Location = new System.Drawing.Point(119, 10).
      this-object:XattrCodeF:Name = "XattrCodeF".
      this-object:XattrCodeF:Size = new System.Drawing.Size(160, 20).
      this-object:XattrCodeF:TabIndex = 3.
      /*  */
      /* Accuracyf */
      /*  */
      this-object:Accuracyf:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindattr, "Accuracy", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:Accuracyf:Location = new System.Drawing.Point(439, 127).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
      define variable arrayvar2 as INTEGER extent 4 no-undo.
      arrayvar2[1] = 10.
      arrayvar2[2] = 0.
      arrayvar2[3] = 0.
      arrayvar2[4] = 0.
      this-object:Accuracyf:Maximum = Progress.Util.DecimalHelper:Create(arrayvar2).
      this-object:Accuracyf:Name = "Accuracyf".
      this-object:Accuracyf:Size = new System.Drawing.Size(120, 20).
      this-object:Accuracyf:TabIndex = 4.
      /*  */
      /* Constant */
      /*  */
      this-object:Constant:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindattr, "Constant", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:Constant:Location = new System.Drawing.Point(119, 59).
      this-object:Constant:Name = "Constant".
      this-object:Constant:Size = new System.Drawing.Size(150, 24).
      this-object:Constant:TabIndex = 5.
      this-object:Constant:Text = "Неизменяемый".
      this-object:Constant:UseCompatibleTextRendering = true.
      this-object:Constant:UseVisualStyleBackColor = true.
      /*  */
      /* Accuracyl */
      /*  */
      this-object:Accuracyl:Location = new System.Drawing.Point(346, 129).
      this-object:Accuracyl:Name = "Accuracyl".
      this-object:Accuracyl:Size = new System.Drawing.Size(70, 23).
      this-object:Accuracyl:TabIndex = 6.
      this-object:Accuracyl:Text = "Точность".
      this-object:Accuracyl:UseCompatibleTextRendering = true.
      /*  */
      /* DataFormatF */
      /*  */
      this-object:DataFormatF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Data-Format", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:DataFormatF:Location = new System.Drawing.Point(119, 156).
      this-object:DataFormatF:Name = "DataFormatF".
      this-object:DataFormatF:Size = new System.Drawing.Size(208, 20).
      this-object:DataFormatF:TabIndex = 7.
      /*  */
      /* DataFormatL */
      /*  */
      this-object:DataFormatL:Location = new System.Drawing.Point(13, 162).
      this-object:DataFormatL:Name = "DataFormatL".
      this-object:DataFormatL:Size = new System.Drawing.Size(100, 23).
      this-object:DataFormatL:TabIndex = 8.
      this-object:DataFormatL:Text = "Формат".
      this-object:DataFormatL:UseCompatibleTextRendering = true.
      /*  */
      /* descF */
      /*  */
      this-object:descF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Description", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:descF:Location = new System.Drawing.Point(119, 266).
      this-object:descF:Multiline = true.
      this-object:descF:Name = "descF".
      this-object:descF:Size = new System.Drawing.Size(481, 71).
      this-object:descF:TabIndex = 9.
      /*  */
      /* DescL */
      /*  */
      this-object:DescL:Location = new System.Drawing.Point(12, 266).
      this-object:DescL:Name = "DescL".
      this-object:DescL:Size = new System.Drawing.Size(100, 23).
      this-object:DescL:TabIndex = 10.
      this-object:DescL:Text = "Описание".
      this-object:DescL:UseCompatibleTextRendering = true.
      /*  */
      /* DataTypeF */
      /*  */
      this-object:DataTypeF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Data-Type", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:DataTypeF:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:DataTypeF:FormattingEnabled = true.
      this-object:DataTypeF:Location = new System.Drawing.Point(119, 126).
      this-object:DataTypeF:Name = "DataTypeF".
      this-object:DataTypeF:Size = new System.Drawing.Size(208, 21).
      this-object:DataTypeF:TabIndex = 11.
      this-object:DataTypeF:TextChanged:Subscribe(this-object:DataTypeF_TextChanged).
      /*  */
      /* DataTypeL */
      /*  */
      this-object:DataTypeL:Location = new System.Drawing.Point(13, 132).
      this-object:DataTypeL:Name = "DataTypeL".
      this-object:DataTypeL:Size = new System.Drawing.Size(100, 23).
      this-object:DataTypeL:TabIndex = 12.
      this-object:DataTypeL:Text = "Тип данных".
      this-object:DataTypeL:UseCompatibleTextRendering = true.
      /*  */
      /* DomenCodeF */
      /*  */
      this-object:DomenCodeF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Domain-Code", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:DomenCodeF:Location = new System.Drawing.Point(119, 208).
      this-object:DomenCodeF:Name = "DomenCodeF".
      this-object:DomenCodeF:Size = new System.Drawing.Size(481, 20).
      this-object:DomenCodeF:TabIndex = 13.
      /*  */
      /* DomenCodeL */
      /*  */
      this-object:DomenCodeL:Location = new System.Drawing.Point(13, 214).
      this-object:DomenCodeL:Name = "DomenCodeL".
      this-object:DomenCodeL:Size = new System.Drawing.Size(100, 23).
      this-object:DomenCodeL:TabIndex = 14.
      this-object:DomenCodeL:Text = "Домен".
      this-object:DomenCodeL:UseCompatibleTextRendering = true.
      /*  */
      /* InitialF */
      /*  */
      this-object:InitialF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Initial", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:InitialF:Location = new System.Drawing.Point(119, 182).
      this-object:InitialF:Name = "InitialF".
      this-object:InitialF:Size = new System.Drawing.Size(481, 20).
      this-object:InitialF:TabIndex = 15.
      /*  */
      /* InitialL */
      /*  */
      this-object:InitialL:Location = new System.Drawing.Point(13, 185).
      this-object:InitialL:Name = "InitialL".
      this-object:InitialL:Size = new System.Drawing.Size(100, 23).
      this-object:InitialL:TabIndex = 16.
      this-object:InitialL:Text = "Начальное значение".
      this-object:InitialL:UseCompatibleTextRendering = true.
      /*  */
      /* Hiddenf */
      /*  */
      this-object:Hiddenf:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindattr, "Hidden", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:Hiddenf:Location = new System.Drawing.Point(291, 59).
      this-object:Hiddenf:Name = "Hiddenf".
      this-object:Hiddenf:Size = new System.Drawing.Size(104, 24).
      this-object:Hiddenf:TabIndex = 17.
      this-object:Hiddenf:Text = "Скрытый".
      this-object:Hiddenf:UseCompatibleTextRendering = true.
      this-object:Hiddenf:UseVisualStyleBackColor = true.
      /*  */
      /* NameF */
      /*  */
      this-object:NameF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Name", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:NameF:Location = new System.Drawing.Point(119, 33).
      this-object:NameF:Name = "NameF".
      this-object:NameF:Size = new System.Drawing.Size(428, 20).
      this-object:NameF:TabIndex = 18.
      /*  */
      /* NameL */
      /*  */
      this-object:NameL:Location = new System.Drawing.Point(13, 36).
      this-object:NameL:Name = "NameL".
      this-object:NameL:Size = new System.Drawing.Size(100, 23).
      this-object:NameL:TabIndex = 19.
      this-object:NameL:Text = "Наименование".
      this-object:NameL:UseCompatibleTextRendering = true.
      /*  */
      /* MandatoryF */
      /*  */
      this-object:MandatoryF:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindattr, "Mandatory", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:MandatoryF:Location = new System.Drawing.Point(291, 96).
      this-object:MandatoryF:Name = "MandatoryF".
      this-object:MandatoryF:Size = new System.Drawing.Size(104, 24).
      this-object:MandatoryF:TabIndex = 20.
      this-object:MandatoryF:Text = "Обязательный".
      this-object:MandatoryF:UseCompatibleTextRendering = true.
      this-object:MandatoryF:UseVisualStyleBackColor = true.
      /*  */
      /* ValidationF */
      /*  */
      this-object:ValidationF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "Validation", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:ValidationF:Location = new System.Drawing.Point(119, 237).
      this-object:ValidationF:Name = "ValidationF".
      this-object:ValidationF:Size = new System.Drawing.Size(481, 20).
      this-object:ValidationF:TabIndex = 21.
      /*  */
      /* OrderF */
      /*  */
      this-object:OrderF:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindattr, "order", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:OrderF:Location = new System.Drawing.Point(119, 352).
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true", Type="System.Int32").
      define variable arrayvar3 as INTEGER extent 4 no-undo.
      arrayvar3[1] = 10000.
      arrayvar3[2] = 0.
      arrayvar3[3] = 0.
      arrayvar3[4] = 0.
      this-object:OrderF:Maximum = Progress.Util.DecimalHelper:Create(arrayvar3).
      this-object:OrderF:Name = "OrderF".
      this-object:OrderF:Size = new System.Drawing.Size(120, 20).
      this-object:OrderF:TabIndex = 22.
      /*  */
      /* OrderL */
      /*  */
      this-object:OrderL:Location = new System.Drawing.Point(12, 357).
      this-object:OrderL:Name = "OrderL".
      this-object:OrderL:Size = new System.Drawing.Size(100, 23).
      this-object:OrderL:TabIndex = 23.
      this-object:OrderL:Text = "Порядковый номер".
      this-object:OrderL:UseCompatibleTextRendering = true.
      /*  */
      /* OverridableF */
      /*  */
      this-object:OverridableF:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindattr, "Overridable", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:OverridableF:Location = new System.Drawing.Point(119, 96).
      this-object:OverridableF:Name = "OverridableF".
      this-object:OverridableF:Size = new System.Drawing.Size(130, 24).
      this-object:OverridableF:TabIndex = 24.
      this-object:OverridableF:Text = "Переопределяемый".
      this-object:OverridableF:UseCompatibleTextRendering = true.
      this-object:OverridableF:UseVisualStyleBackColor = true.
      /*  */
      /* ValidationL */
      /*  */
      this-object:ValidationL:Location = new System.Drawing.Point(13, 243).
      this-object:ValidationL:Name = "ValidationL".
      this-object:ValidationL:Size = new System.Drawing.Size(100, 23).
      this-object:ValidationL:TabIndex = 25.
      this-object:ValidationL:Text = "Валидация".
      this-object:ValidationL:UseCompatibleTextRendering = true.
      /*  */
      /* ClableF */
      /*  */
      this-object:ClableF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "xattr-clabel", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:ClableF:Location = new System.Drawing.Point(119, 391).
      this-object:ClableF:Name = "ClableF".
      this-object:ClableF:Size = new System.Drawing.Size(191, 20).
      this-object:ClableF:TabIndex = 26.
      /*  */
      /* CLableL */
      /*  */
      this-object:CLableL:Location = new System.Drawing.Point(12, 397).
      this-object:CLableL:Name = "CLableL".
      this-object:CLableL:Size = new System.Drawing.Size(100, 23).
      this-object:CLableL:TabIndex = 27.
      this-object:CLableL:Text = "Метка браузера".
      this-object:CLableL:UseCompatibleTextRendering = true.
      /*  */
      /* labelF */
      /*  */
      this-object:labelF:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindattr, "xattr-label", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:labelF:Location = new System.Drawing.Point(405, 388).
      this-object:labelF:Name = "labelF".
      this-object:labelF:Size = new System.Drawing.Size(195, 20).
      this-object:labelF:TabIndex = 28.
      /*  */
      /* labelL */
      /*  */
      this-object:labelL:Location = new System.Drawing.Point(316, 388).
      this-object:labelL:Name = "labelL".
      this-object:labelL:Size = new System.Drawing.Size(83, 23).
      this-object:labelL:TabIndex = 29.
      this-object:labelL:Text = "Метка формы".
      this-object:labelL:UseCompatibleTextRendering = true.
      /*  */
      /* listvalue */
      /*  */
      this-object:listvalue:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindattr, "ListValue", true)).
      this-object:listvalue:Location = new System.Drawing.Point(346, 152).
      this-object:listvalue:Name = "listvalue".
      this-object:listvalue:Size = new System.Drawing.Size(104, 24).
      this-object:listvalue:TabIndex = 30.
      this-object:listvalue:Text = "Список".
      this-object:listvalue:UseCompatibleTextRendering = true.
      this-object:listvalue:UseVisualStyleBackColor = true.
      /*  */
      /* xattrFrm */
      /*  */
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(611, 467).
      this-object:Controls:Add(this-object:listvalue).
      this-object:Controls:Add(this-object:labelL).
      this-object:Controls:Add(this-object:labelF).
      this-object:Controls:Add(this-object:CLableL).
      this-object:Controls:Add(this-object:ClableF).
      this-object:Controls:Add(this-object:ValidationL).
      this-object:Controls:Add(this-object:OverridableF).
      this-object:Controls:Add(this-object:OrderL).
      this-object:Controls:Add(this-object:OrderF).
      this-object:Controls:Add(this-object:NameL).
      this-object:Controls:Add(this-object:ValidationF).
      this-object:Controls:Add(this-object:InitialL).
      this-object:Controls:Add(this-object:MandatoryF).
      this-object:Controls:Add(this-object:DomenCodeL).
      this-object:Controls:Add(this-object:InitialF).
      this-object:Controls:Add(this-object:DomenCodeF).
      this-object:Controls:Add(this-object:Hiddenf).
      this-object:Controls:Add(this-object:DataTypeF).
      this-object:Controls:Add(this-object:NameF).
      this-object:Controls:Add(this-object:descF).
      this-object:Controls:Add(this-object:DataTypeL).
      this-object:Controls:Add(this-object:DataFormatF).
      this-object:Controls:Add(this-object:DescL).
      this-object:Controls:Add(this-object:Accuracyl).
      this-object:Controls:Add(this-object:DataFormatL).
      this-object:Controls:Add(this-object:Accuracyf).
      this-object:Controls:Add(this-object:XattrCodeF).
      this-object:Controls:Add(this-object:XattrCodeL).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:Constant).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "xattrFrm".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Описание атрибута".
      cast(this-object:bindattr, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:Accuracyf, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:OrderF, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method. 
 
   method public void ShowModalDialog(ihandle as handle  ):
      bindattr:handle = ihandle.
      wait-for this-object:ShowDialog().

   end method.
   
   method private void ChangeDataType():
      if DataTypeF:text eq {&ABL-datatype-decimal}
      then
         assign
            Accuracyf:visible = yes
            Accuracyl:visible = yes
         .
      else
         assign
            Accuracyf:visible = no
            Accuracyl:visible = no
         .
      if DataTypeF:text eq {&ABL-datatype-character}
      then
         assign
            listvalue:visible   = yes
            ValidationF:visible = yes
            Validationl:visible = yes
         .
      else do:
         listvalue:visible   = no.
         if DataTypeF:text eq {&ABL-datatype-logical}
         then
           assign
               ValidationF:visible = no
               ValidationL:visible = no
         .
         else
            assign
               ValidationF:visible = yes
               ValidationL:visible = yes
         .
      end.
   end.
   
   method private void SetFormat():
      DataFormatF:text =   if DataTypeF:text eq {&ABL-datatype-decimal}
                           then ">>,>>>,>>>,>>9.99"  
                           else if DataTypeF:text eq {&ABL-datatype-date}
                           then "99/99/9999" 
                           else if DataTypeF:text eq {&ABL-datatype-integer}
                           then ">>>>>>>>9" 
                           else if DataTypeF:text eq {&ABL-datatype-logical}
                           then "Да/Нет"
                           else "X(12)".
         
      
   end.
   
   method private void lockField(ienable as logical):
      buttonOk:enabled = ienable.
      XattrCodeF:enabled = ienable.
      NameF:enabled = ienable.
      Constant:enabled = ienable.
      OverridableF:enabled = ienable.
      Hiddenf:enabled = ienable.
      MandatoryF:enabled = ienable.
      DataTypeF:enabled = ienable.
      Accuracyf:enabled = ienable.
      DataFormatF:enabled = ienable.
      InitialF:enabled = ienable.
      DomenCodeF:enabled = ienable.
      ValidationF:enabled = ienable.
      descF:enabled = ienable.
      OrderF:enabled = ienable.
      ClableF:enabled = ienable.
      labelf:enabled = ienable.
      listvalue:enabled = ienable.
      
   end.
 
end class.
