 /*------------------------------------------------------------------------
    File        : frmcode
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Wed Jul 31 02:15:08 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class ibs.th.ref.code.frmcode inherits Form  final: 

   define private variable bindcode as Progress.Data.BindingSource no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
   define private variable label16 as System.Windows.Forms.Label no-undo.
   define private variable label15 as System.Windows.Forms.Label no-undo.
   define private variable label14 as System.Windows.Forms.Label no-undo.
   define private variable label13 as System.Windows.Forms.Label no-undo.
   define private variable label12 as System.Windows.Forms.Label no-undo.
   define private variable label11 as System.Windows.Forms.Label no-undo.
   define private variable label8 as System.Windows.Forms.Label no-undo.
   define private variable exportrec as System.Windows.Forms.CheckBox no-undo.
   define private variable textBox16 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox15 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox14 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox13 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox12 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox11 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox7 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox6 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox5 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox4 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox3 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox2 as System.Windows.Forms.TextBox no-undo.
   define private variable textBox1 as System.Windows.Forms.TextBox no-undo.
   define private variable label7 as System.Windows.Forms.Label no-undo.
   define private variable label6 as System.Windows.Forms.Label no-undo.
   define private variable label5 as System.Windows.Forms.Label no-undo.
   define private variable label4 as System.Windows.Forms.Label no-undo.
   define private variable label3 as System.Windows.Forms.Label no-undo.
   define private variable label2 as System.Windows.Forms.Label no-undo.
   define private variable label1 as System.Windows.Forms.Label no-undo.
   
   define variable McodeTrg as class ibs.th.ref.code.code_trg NO-UNDO.
   
   constructor public frmcode( ):
   
      super().
      InitializeComponent ( ).
      
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.
   
   constructor public frmcode(iQuery as handle,itrg as class ibs.th.ref.code.code_trg ):

      super().
      InitializeComponent ( ).
   
      bindcode:handle = iQuery.
      McodeTrg = itrg.
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.      

   end constructor.

   destructor public frmcode( ):

      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.

   end destructor.   

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void frmcode_Load( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label1_Click( input sender as System.Object, input e as System.EventArgs ):
		label4:visible   = not label4:visible.
      label5:visible   = label4:visible.
      label6:visible   = label4:visible.
      label7:visible   = label4:visible.
      label8:visible   = label4:visible.
      textBox4:visible = label4:visible.
      textBox5:visible = label4:visible.
      textBox6:visible = label4:visible.
      textBox7:visible = label4:visible.
      exportrec:visible = label4:visible.
		return.

	end method.

    method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      
      
      bindcode:Assign().
      if valid-object(McodeTrg)
      then
         McodeTrg:checkcode().
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
      define variable tableDesc3 as Progress.Data.TableDesc no-undo.
      tableDesc3 = new Progress.Data.TableDesc("Code").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:textBox1 = new System.Windows.Forms.TextBox().
      this-object:bindcode = new Progress.Data.BindingSource(this-object:components).
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:textBox2 = new System.Windows.Forms.TextBox().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:textBox3 = new System.Windows.Forms.TextBox().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:textBox4 = new System.Windows.Forms.TextBox().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:textBox5 = new System.Windows.Forms.TextBox().
      this-object:label6 = new System.Windows.Forms.Label().
      this-object:textBox6 = new System.Windows.Forms.TextBox().
      this-object:label7 = new System.Windows.Forms.Label().
      this-object:textBox7 = new System.Windows.Forms.TextBox().
      this-object:exportrec = new System.Windows.Forms.CheckBox().
      this-object:label8 = new System.Windows.Forms.Label().
      this-object:label13 = new System.Windows.Forms.Label().
      this-object:textBox13 = new System.Windows.Forms.TextBox().
      this-object:label12 = new System.Windows.Forms.Label().
      this-object:textBox12 = new System.Windows.Forms.TextBox().
      this-object:label11 = new System.Windows.Forms.Label().
      this-object:textBox11 = new System.Windows.Forms.TextBox().
      this-object:label16 = new System.Windows.Forms.Label().
      this-object:textBox16 = new System.Windows.Forms.TextBox().
      this-object:label15 = new System.Windows.Forms.Label().
      this-object:textBox15 = new System.Windows.Forms.TextBox().
      this-object:label14 = new System.Windows.Forms.Label().
      this-object:textBox14 = new System.Windows.Forms.TextBox().
      cast(this-object:bindcode, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      /*  */
      /* buttonOk */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = System.Windows.Forms.AnchorStyles:Top.
      this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonOk:Location = new System.Drawing.Point(494, 329).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "Ввод".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      /*  */
      /* buttonCancel */
      /*  */
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = System.Windows.Forms.AnchorStyles:Top.
      this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(575, 329).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Отмена".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      /*  */
      /* textBox1 */
      /*  */
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "code", true)).
      this-object:textBox1:Location = new System.Drawing.Point(134, 9).
      this-object:textBox1:Name = "textBox1".
      this-object:textBox1:Size = new System.Drawing.Size(516, 20).
      this-object:textBox1:TabIndex = 2.
      this-object:textBox1:TextChanged:Subscribe(this-object:textBox1_TextChanged).
      /*  */
      /* bindcode */
      /*  */
      this-object:bindcode:MaxDataGuess = 0.
      this-object:bindcode:NoLOBs = false.
      this-object:bindcode:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc3:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 14 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("code", "Код", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("CodeName", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("CodeValue", "Значение", Progress.Data.DataType:CHARACTER).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("parent", "?", Progress.Data.DataType:CHARACTER).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("procdel", "Процедура удаления", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("procedit", "процедура редактирования", Progress.Data.DataType:CHARACTER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("procview", "Процедура просмотра", Progress.Data.DataType:CHARACTER).
      arrayvar1[8] = new Progress.Data.ColumnPropDesc("export_", "Выгружать запись", Progress.Data.DataType:LOGICAL).
      arrayvar1[9] = new Progress.Data.ColumnPropDesc("misc1", "misc1", Progress.Data.DataType:CHARACTER).
      arrayvar1[10] = new Progress.Data.ColumnPropDesc("misc2", "misc2", Progress.Data.DataType:CHARACTER).
      arrayvar1[11] = new Progress.Data.ColumnPropDesc("misc3", "misc3", Progress.Data.DataType:CHARACTER).
      arrayvar1[12] = new Progress.Data.ColumnPropDesc("misc4", "misc4", Progress.Data.DataType:CHARACTER).
      arrayvar1[13] = new Progress.Data.ColumnPropDesc("misc5", "misc5", Progress.Data.DataType:CHARACTER).
      arrayvar1[14] = new Progress.Data.ColumnPropDesc("misc6", "misc6", Progress.Data.DataType:CHARACTER).
      tableDesc3:Columns = arrayvar1.
      this-object:bindcode:TableSchema = tableDesc3.
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Location = new System.Drawing.Point(6, 9).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(118, 23).
      this-object:label1:TabIndex = 3.
      this-object:label1:Text = "Код".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:label1:Click:Subscribe(this-object:label1_Click).
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Location = new System.Drawing.Point(6, 35).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(118, 23).
      this-object:label2:TabIndex = 5.
      this-object:label2:Text = "Наименование".
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* textBox2 */
      /*  */
      define variable nestedvar3 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar3 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox2:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "CodeName", true)).
      this-object:textBox2:Location = new System.Drawing.Point(134, 35).
      this-object:textBox2:Name = "textBox2".
      this-object:textBox2:Size = new System.Drawing.Size(516, 20).
      this-object:textBox2:TabIndex = 4.
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Location = new System.Drawing.Point(6, 61).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(118, 23).
      this-object:label3:TabIndex = 7.
      this-object:label3:Text = "Значение".
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* textBox3 */
      /*  */
      define variable nestedvar4 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar4 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox3:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar4, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox3:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "CodeValue", true)).
      this-object:textBox3:Location = new System.Drawing.Point(134, 61).
      this-object:textBox3:Name = "textBox3".
      this-object:textBox3:Size = new System.Drawing.Size(516, 20).
      this-object:textBox3:TabIndex = 6.
      /*  */
      /* label4 */
      /*  */
      this-object:label4:Location = new System.Drawing.Point(24, 385).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(100, 23).
      this-object:label4:TabIndex = 9.
      this-object:label4:Text = "Родитель".
      this-object:label4:UseCompatibleTextRendering = true.
      this-object:label4:Visible = false.
      /*  */
      /* textBox4 */
      /*  */
      define variable nestedvar5 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar5 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox4:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar5, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox4:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "parent", true)).
      this-object:textBox4:Location = new System.Drawing.Point(185, 385).
      this-object:textBox4:Name = "textBox4".
      this-object:textBox4:ReadOnly = true.
      this-object:textBox4:Size = new System.Drawing.Size(465, 20).
      this-object:textBox4:TabIndex = 8.
      this-object:textBox4:Visible = false.
      /*  */
      /* label5 */
      /*  */
      this-object:label5:Location = new System.Drawing.Point(24, 411).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(123, 23).
      this-object:label5:TabIndex = 11.
      this-object:label5:Text = "Процедура просмотра".
      this-object:label5:UseCompatibleTextRendering = true.
      this-object:label5:Visible = false.
      /*  */
      /* textBox5 */
      /*  */
      define variable nestedvar6 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar6 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox5:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar6, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox5:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "procview", true)).
      this-object:textBox5:Location = new System.Drawing.Point(185, 411).
      this-object:textBox5:Name = "textBox5".
      this-object:textBox5:Size = new System.Drawing.Size(465, 20).
      this-object:textBox5:TabIndex = 10.
      this-object:textBox5:Visible = false.
      /*  */
      /* label6 */
      /*  */
      this-object:label6:Location = new System.Drawing.Point(24, 437).
      this-object:label6:Name = "label6".
      this-object:label6:Size = new System.Drawing.Size(155, 23).
      this-object:label6:TabIndex = 13.
      this-object:label6:Text = "Процедура редактирования".
      this-object:label6:UseCompatibleTextRendering = true.
      this-object:label6:Visible = false.
      /*  */
      /* textBox6 */
      /*  */
      define variable nestedvar7 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar7 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox6:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar7, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox6:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "procedit", true)).
      this-object:textBox6:Location = new System.Drawing.Point(185, 437).
      this-object:textBox6:Name = "textBox6".
      this-object:textBox6:Size = new System.Drawing.Size(465, 20).
      this-object:textBox6:TabIndex = 12.
      this-object:textBox6:Visible = false.
      /*  */
      /* label7 */
      /*  */
      this-object:label7:Location = new System.Drawing.Point(24, 463).
      this-object:label7:Name = "label7".
      this-object:label7:Size = new System.Drawing.Size(143, 23).
      this-object:label7:TabIndex = 15.
      this-object:label7:Text = "Проедура удаления".
      this-object:label7:UseCompatibleTextRendering = true.
      this-object:label7:Visible = false.
      /*  */
      /* textBox7 */
      /*  */
      define variable nestedvar8 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar8 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox7:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar8, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox7:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "procdel", true)).
      this-object:textBox7:Location = new System.Drawing.Point(185, 463).
      this-object:textBox7:Name = "textBox7".
      this-object:textBox7:Size = new System.Drawing.Size(465, 20).
      this-object:textBox7:TabIndex = 14.
      this-object:textBox7:Visible = false.
      /*  */
      /* exportrec */
      /*  */
      this-object:exportrec:DataBindings:Add(new System.Windows.Forms.Binding("CheckState", this-object:bindcode, "export_", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
      this-object:exportrec:Location = new System.Drawing.Point(185, 490).
      this-object:exportrec:Name = "exportrec".
      this-object:exportrec:Size = new System.Drawing.Size(104, 24).
      this-object:exportrec:TabIndex = 16.
      this-object:exportrec:UseCompatibleTextRendering = true.
      this-object:exportrec:UseVisualStyleBackColor = true.
      this-object:exportrec:Visible = false.
      /*  */
      /* label8 */
      /*  */
      this-object:label8:Location = new System.Drawing.Point(24, 490).
      this-object:label8:Name = "label8".
      this-object:label8:Size = new System.Drawing.Size(143, 23).
      this-object:label8:TabIndex = 17.
      this-object:label8:Text = "Выгружать запись".
      this-object:label8:UseCompatibleTextRendering = true.
      this-object:label8:Visible = false.
      /*  */
      /* label13 */
      /*  */
      this-object:label13:Location = new System.Drawing.Point(6, 139).
      this-object:label13:Name = "label13".
      this-object:label13:Size = new System.Drawing.Size(118, 23).
      this-object:label13:TabIndex = 23.
      this-object:label13:Text = "misc3".
      this-object:label13:UseCompatibleTextRendering = true.
      this-object:label13:Visible = false.
      /*  */
      /* textBox13 */
      /*  */
      define variable nestedvar9 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar9 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox13:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar9, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox13:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc3", true)).
      this-object:textBox13:Location = new System.Drawing.Point(134, 139).
      this-object:textBox13:Name = "textBox13".
      this-object:textBox13:Size = new System.Drawing.Size(516, 20).
      this-object:textBox13:TabIndex = 22.
      this-object:textBox13:Visible = false.
      /*  */
      /* label12 */
      /*  */
      this-object:label12:Location = new System.Drawing.Point(6, 113).
      this-object:label12:Name = "label12".
      this-object:label12:Size = new System.Drawing.Size(118, 23).
      this-object:label12:TabIndex = 21.
      this-object:label12:Text = "misc2".
      this-object:label12:UseCompatibleTextRendering = true.
      this-object:label12:Visible = false.
      /*  */
      /* textBox12 */
      /*  */
      define variable nestedvar10 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar10 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox12:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar10, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox12:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc2", true)).
      this-object:textBox12:Location = new System.Drawing.Point(134, 113).
      this-object:textBox12:Name = "textBox12".
      this-object:textBox12:Size = new System.Drawing.Size(516, 20).
      this-object:textBox12:TabIndex = 20.
      this-object:textBox12:Visible = false.
      /*  */
      /* label11 */
      /*  */
      this-object:label11:Location = new System.Drawing.Point(6, 87).
      this-object:label11:Name = "label11".
      this-object:label11:Size = new System.Drawing.Size(118, 23).
      this-object:label11:TabIndex = 19.
      this-object:label11:Text = "misc1".
      this-object:label11:UseCompatibleTextRendering = true.
      this-object:label11:Visible = false.
      /*  */
      /* textBox11 */
      /*  */
      define variable nestedvar11 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar11 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox11:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar11, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox11:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc1", true)).
      this-object:textBox11:Location = new System.Drawing.Point(134, 87).
      this-object:textBox11:Name = "textBox11".
      this-object:textBox11:Size = new System.Drawing.Size(516, 20).
      this-object:textBox11:TabIndex = 18.
      this-object:textBox11:Visible = false.
      /*  */
      /* label16 */
      /*  */
      this-object:label16:Location = new System.Drawing.Point(6, 217).
      this-object:label16:Name = "label16".
      this-object:label16:Size = new System.Drawing.Size(118, 23).
      this-object:label16:TabIndex = 29.
      this-object:label16:Text = "misc6".
      this-object:label16:UseCompatibleTextRendering = true.
      this-object:label16:Visible = false.
      /*  */
      /* textBox16 */
      /*  */
      define variable nestedvar12 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar12 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox16:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar12, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox16:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc6", true)).
      this-object:textBox16:Location = new System.Drawing.Point(134, 217).
      this-object:textBox16:Name = "textBox16".
      this-object:textBox16:Size = new System.Drawing.Size(516, 20).
      this-object:textBox16:TabIndex = 28.
      this-object:textBox16:Visible = false.
      /*  */
      /* label15 */
      /*  */
      this-object:label15:Location = new System.Drawing.Point(6, 191).
      this-object:label15:Name = "label15".
      this-object:label15:Size = new System.Drawing.Size(118, 23).
      this-object:label15:TabIndex = 27.
      this-object:label15:Text = "misc5".
      this-object:label15:UseCompatibleTextRendering = true.
      this-object:label15:Visible = false.
      /*  */
      /* textBox15 */
      /*  */
      define variable nestedvar13 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar13 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox15:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar13, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox15:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc5", true)).
      this-object:textBox15:Location = new System.Drawing.Point(134, 191).
      this-object:textBox15:Name = "textBox15".
      this-object:textBox15:Size = new System.Drawing.Size(516, 20).
      this-object:textBox15:TabIndex = 26.
      this-object:textBox15:Visible = false.
      /*  */
      /* label14 */
      /*  */
      this-object:label14:Location = new System.Drawing.Point(6, 165).
      this-object:label14:Name = "label14".
      this-object:label14:Size = new System.Drawing.Size(118, 23).
      this-object:label14:TabIndex = 25.
      this-object:label14:Text = "misc4".
      this-object:label14:UseCompatibleTextRendering = true.
      this-object:label14:Visible = false.
      /*  */
      /* textBox14 */
      /*  */
      define variable nestedvar14 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar14 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:textBox14:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar14, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:textBox14:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc4", true)).
      this-object:textBox14:Location = new System.Drawing.Point(134, 165).
      this-object:textBox14:Name = "textBox14".
      this-object:textBox14:Size = new System.Drawing.Size(516, 20).
      this-object:textBox14:TabIndex = 24.
      this-object:textBox14:Visible = false.
      /*  */
      /* frmcode */
      /*  */
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(669, 364).
      this-object:Controls:Add(this-object:label16).
      this-object:Controls:Add(this-object:textBox16).
      this-object:Controls:Add(this-object:label15).
      this-object:Controls:Add(this-object:textBox15).
      this-object:Controls:Add(this-object:label14).
      this-object:Controls:Add(this-object:textBox14).
      this-object:Controls:Add(this-object:label13).
      this-object:Controls:Add(this-object:textBox13).
      this-object:Controls:Add(this-object:label12).
      this-object:Controls:Add(this-object:textBox12).
      this-object:Controls:Add(this-object:label11).
      this-object:Controls:Add(this-object:textBox11).
      this-object:Controls:Add(this-object:label8).
      this-object:Controls:Add(this-object:exportrec).
      this-object:Controls:Add(this-object:label7).
      this-object:Controls:Add(this-object:textBox7).
      this-object:Controls:Add(this-object:label6).
      this-object:Controls:Add(this-object:textBox6).
      this-object:Controls:Add(this-object:label5).
      this-object:Controls:Add(this-object:textBox5).
      this-object:Controls:Add(this-object:label4).
      this-object:Controls:Add(this-object:textBox4).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:textBox3).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:textBox2).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:textBox1).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "frmcode".
      this-object:Text = "Справочник".
      this-object:Load:Subscribe(this-object:frmcode_Load).
      cast(this-object:bindcode, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method. 
 
   method public void ShowModalDialog(  ):
      
      wait-for this-object:ShowDialog().

   end method.
   define variable VFirst as logical no-undo init yes.
   method public void setlable( inum as integer ,itext as character  ):
      if vfirst 
      then do:
         assign
            vfirst  = no
            label1  :visible = no
            textBox1:visible = no
            label2  :visible = no
            textBox2:visible = no
            label3  :visible = no
            textBox3:visible = no
            label11  :visible = no
            textBox11:visible = no
            label12  :visible = no
            textBox12:visible = no
            label13  :visible = no
            textBox13:visible = no
            label14  :visible = no
            textBox14:visible = no
            label15  :visible = no
            textBox15:visible = no
            label16  :visible = no
            textBox16:visible = no
            
         .
      end.
      if inum eq 1 
      then do:
         if itext eq ?
         then assign
            label1  :visible = no
            textBox1:visible = no
         .
         else  assign
            label1  :visible = yes
            textBox1:visible = yes
            label1  :text    = itext
         .
      end.
      else if inum eq 2 
      then do:
         if itext eq ?
         then assign
            label2  :visible = no
            textBox2:visible = no
         .
         else  assign
            label2  :visible = yes
            textBox2:visible = yes
            label2  :text    = itext
         .
      end.
      else if inum eq 3 
      then do:
         if itext eq ?
         then assign
            label3  :visible = no
            textBox3:visible = no
         .
         else  assign
            label3  :visible = yes
            textBox3:visible = yes
            label3  :text    = itext
         .
      end.
      else if inum eq 11 
      then do:
         if itext eq ?
         then assign
            label11  :visible = no
            textBox11:visible = no
         .
         else  assign
            label11  :visible = yes
            textBox11:visible = yes
            label11  :text    = itext
         .
      end.
      else if inum eq 12 
      then do:
         if itext eq ?
         then assign
            label12  :visible = no
            textBox12:visible = no
         .
         else  assign
            label12  :visible = yes
            textBox12:visible = yes
            label12  :text    = itext
         .
      end.
      else if inum eq 13 
      then do:
         if itext eq ?
         then assign
            label13  :visible = no
            textBox13:visible = no
         .
         else  assign
            label13  :visible = yes
            textBox13:visible = yes
            label13  :text    = itext
         .
      end.
      else if inum eq 14 
      then do:
         if itext eq ?
         then assign
            label14  :visible = no
            textBox14:visible = no
         .
         else  assign
            label14  :visible = yes
            textBox14:visible = yes
            label14  :text    = itext
         .
      end.
      else if inum eq 15 
      then do:
         if itext eq ?
         then assign
            label15  :visible = no
            textBox15:visible = no
         .
         else  assign
            label15  :visible = yes
            textBox15:visible = yes
            label15  :text    = itext
         .
      end.
      else if inum eq 16 
      then do:
         if itext eq ?
         then assign
            label16  :visible = no
            textBox16:visible = no
         .
         else  assign
            label16  :visible = yes
            textBox16:visible = yes
            label16  :text    = itext
         .
      end.
   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void textBox1_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

end class.
