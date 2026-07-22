 
/*------------------------------------------------------------------------
   File        : SDedit
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : eshklyar
   Created     : Thu Sep 26 16:45:41 MSK 2019
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.
using ibs.th.ref.code.SDedit_ from propath.
using ibs.th.ref.code.SDedit_ from propath.

block-level on error undo, throw.

class ibs.th.ref.code.SDedit_ inherits Form: 
  define public property vss-revision    as character no-undo init "$Revision:$":U get .
  define public property vss-author      as character no-undo init "$Author:$":U get.
  define public property vss-date        as character no-undo init "$Date:$":U get.
  define public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define public property vss-archive     as character no-undo init "$Archive:$":U get.
  define public property vss-description as character no-undo init "Справочник устройств" get.
  
  define public variable bindcode        as Progress.Data.BindingSource         no-undo.
  define private variable buttonOk        as System.Windows.Forms.Button         no-undo.
  define private variable buttonCancel    as System.Windows.Forms.Button         no-undo.
  define private variable components      as System.ComponentModel.IContainer    no-undo.
  define private variable dateTimePicker1 as System.Windows.Forms.DateTimePicker no-undo.
  define private variable dateTimePicker2 as System.Windows.Forms.DateTimePicker no-undo.
  define private variable label4          as System.Windows.Forms.Label          no-undo.
  define private variable textBox3        as System.Windows.Forms.TextBox        no-undo.
  define private variable textBox2        as System.Windows.Forms.TextBox        no-undo.
  define private variable textBox1        as System.Windows.Forms.TextBox        no-undo.
  define private variable label3          as System.Windows.Forms.Label          no-undo.
  define private variable label2          as System.Windows.Forms.Label          no-undo.
  define private variable label1          as System.Windows.Forms.Label          no-undo.
  define public  variable p-list          as character                           no-undo .
  
  define         variable McodeTrg        as class                               ibs.th.ref.code.code_trg NO-UNDO.    
  constructor public SDedit_ (iChange as character):
    
    super().
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
  method private void cancelButton_Click( input sender as System.Object, input e as System.EventArgs ):
		
    this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    this-object:Close ( ).

  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void Change_datetime( input sender as System.Object, input e as System.EventArgs ):
		
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
    tableDesc1 = new Progress.Data.TableDesc("Code").
    this-object:label3 = new System.Windows.Forms.Label().
    this-object:textBox3 = new System.Windows.Forms.TextBox().
    this-object:bindcode = new Progress.Data.BindingSource(this-object:components).
    this-object:label2 = new System.Windows.Forms.Label().
    this-object:textBox2 = new System.Windows.Forms.TextBox().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:textBox1 = new System.Windows.Forms.TextBox().
    this-object:buttonCancel = new System.Windows.Forms.Button().
    this-object:buttonOk = new System.Windows.Forms.Button().
    this-object:label4 = new System.Windows.Forms.Label().
    this-object:dateTimePicker2 = new System.Windows.Forms.DateTimePicker().
    this-object:dateTimePicker1 = new System.Windows.Forms.DateTimePicker().
    cast(this-object:bindcode, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    /*  */
    /* label3 */
    /*  */
    this-object:label3:Location = new System.Drawing.Point(11, 62).
    this-object:label3:Name = "label3".
    this-object:label3:Size = new System.Drawing.Size(100, 23).
    this-object:label3:TabIndex = 15.
    this-object:label3:Text = "Адрес".
    this-object:label3:UseCompatibleTextRendering = true.
    /*  */
    /* textBox3 */
    /*  */
    define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    this-object:textBox3:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:textBox3:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc1", true)).
    this-object:textBox3:Location = new System.Drawing.Point(121, 62).
    this-object:textBox3:Name = "textBox3".
    this-object:textBox3:Size = new System.Drawing.Size(375, 20).
    this-object:textBox3:TabIndex = 14.
    this-object:textBox3:Text = "___-___-___-___".
    this-object:textBox3:TextChanged:Subscribe(this-object:textBox3_TextChanged).
    /*  */
    /* bindcode */
    /*  */
    this-object:bindcode:MaxDataGuess = 0.
    this-object:bindcode:NoLOBs = false.
    this-object:bindcode:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar0 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 9 no-undo.
    arrayvar1[1] = new Progress.Data.ColumnPropDesc("code", "Код", Progress.Data.DataType:CHARACTER).
    arrayvar1[2] = new Progress.Data.ColumnPropDesc("CodeName", "Наименование", Progress.Data.DataType:CHARACTER).
    arrayvar1[3] = new Progress.Data.ColumnPropDesc("CodeValue", "Значение", Progress.Data.DataType:CHARACTER).
    arrayvar1[4] = new Progress.Data.ColumnPropDesc("parent", "?", Progress.Data.DataType:CHARACTER).
    arrayvar1[5] = new Progress.Data.ColumnPropDesc("procdel", "Процедура удаления", Progress.Data.DataType:CHARACTER).
    arrayvar1[6] = new Progress.Data.ColumnPropDesc("procedit", "процедура редактирования", Progress.Data.DataType:CHARACTER).
    arrayvar1[7] = new Progress.Data.ColumnPropDesc("procview", "Процедура просмотра", Progress.Data.DataType:CHARACTER).
    arrayvar1[8] = new Progress.Data.ColumnPropDesc("misc1", "ID", Progress.Data.DataType:CHARACTER).
    arrayvar1[9] = new Progress.Data.ColumnPropDesc("misc2", "Время", Progress.Data.DataType:CHARACTER).
    tableDesc1:Columns = arrayvar1.
    this-object:bindcode:TableSchema = tableDesc1.
    /*  */
    /* label2 */
    /*  */
    this-object:label2:Location = new System.Drawing.Point(11, 36).
    this-object:label2:Name = "label2".
    this-object:label2:Size = new System.Drawing.Size(100, 23).
    this-object:label2:TabIndex = 13.
    this-object:label2:Text = "Наименование".
    this-object:label2:UseCompatibleTextRendering = true.
    /*  */
    /* textBox2 */
    /*  */
    define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar1 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    this-object:textBox2:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:textBox2:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "CodeName", true)).
    this-object:textBox2:Location = new System.Drawing.Point(121, 36).
    this-object:textBox2:Name = "textBox2".
    this-object:textBox2:Size = new System.Drawing.Size(375, 20).
    this-object:textBox2:TabIndex = 12.
    /*  */
    /* label1 */
    /*  */
    this-object:label1:Location = new System.Drawing.Point(11, 10).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(100, 23).
    this-object:label1:TabIndex = 11.
    this-object:label1:Text = "Код".
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* textBox1 */
    /*  */
    define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar2 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
    this-object:textBox1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "code", true)).
    this-object:textBox1:Location = new System.Drawing.Point(121, 10).
    this-object:textBox1:Name = "textBox1".
    this-object:textBox1:Size = new System.Drawing.Size(375, 20).
    this-object:textBox1:TabIndex = 10.
    /*  */
    /* buttonCancel */
    /*  */
    define variable nestedvar3 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar3 = System.Windows.Forms.AnchorStyles:Top.
    this-object:buttonCancel:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    this-object:buttonCancel:Location = new System.Drawing.Point(421, 116).
    this-object:buttonCancel:Name = "buttonCancel".
    this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
    this-object:buttonCancel:TabIndex = 9.
    this-object:buttonCancel:Text = "Cancel".
    this-object:buttonCancel:UseCompatibleTextRendering = true.
    this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
    /*  */
    /* buttonOk */
    /*  */
    define variable nestedvar4 as System.Windows.Forms.AnchorStyles no-undo.
    nestedvar4 = System.Windows.Forms.AnchorStyles:Top.
    this-object:buttonOk:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar4, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    this-object:buttonOk:Location = new System.Drawing.Point(335, 116).
    this-object:buttonOk:Name = "buttonOk".
    this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
    this-object:buttonOk:TabIndex = 8.
    this-object:buttonOk:Text = "OK".
    this-object:buttonOk:UseCompatibleTextRendering = true.
    this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
    /*  */
    /* label4 */
    /*  */
    this-object:label4:Location = new System.Drawing.Point(11, 88).
    this-object:label4:Name = "label4".
    this-object:label4:Size = new System.Drawing.Size(100, 23).
    this-object:label4:TabIndex = 17.
    this-object:label4:Text = "Дата".
    this-object:label4:UseCompatibleTextRendering = true.
    this-object:label4:Visible = false.
    /*  */
    /* dateTimePicker2 */
    /*  */
    this-object:dateTimePicker2:DataBindings:Add(new System.Windows.Forms.Binding("Value", this-object:bindcode, "misc2", true, System.Windows.Forms.DataSourceUpdateMode:OnPropertyChanged)).
    this-object:dateTimePicker2:Format = System.Windows.Forms.DateTimePickerFormat:Short.
    this-object:dateTimePicker2:Location = new System.Drawing.Point(121, 87).
    this-object:dateTimePicker2:Name = "dateTimePicker2".
    this-object:dateTimePicker2:Size = new System.Drawing.Size(93, 20).
    this-object:dateTimePicker2:TabIndex = 19.
    this-object:dateTimePicker2:Value = Progress.Util.DateTimeHelper:Create(2019, 9, 29, 15, 34, 0, 0).
    this-object:dateTimePicker2:Visible = false.
    /*  */
    /* dateTimePicker1 */
    /*  */
    this-object:dateTimePicker1:Format = System.Windows.Forms.DateTimePickerFormat:Time.
    this-object:dateTimePicker1:Location = new System.Drawing.Point(221, 87).
    this-object:dateTimePicker1:Name = "dateTimePicker1".
    this-object:dateTimePicker1:ShowUpDown = true.
    this-object:dateTimePicker1:Size = new System.Drawing.Size(106, 20).
    this-object:dateTimePicker1:TabIndex = 20.
    this-object:dateTimePicker1:Visible = false.
    /*  */
    /* SDedit_ */
    /*  */
    this-object:ClientSize = new System.Drawing.Size(507, 160).
    this-object:Controls:Add(this-object:dateTimePicker1).
    this-object:Controls:Add(this-object:dateTimePicker2).
    this-object:Controls:Add(this-object:label4).
    this-object:Controls:Add(this-object:label3).
    this-object:Controls:Add(this-object:textBox3).
    this-object:Controls:Add(this-object:label2).
    this-object:Controls:Add(this-object:textBox2).
    this-object:Controls:Add(this-object:label1).
    this-object:Controls:Add(this-object:textBox1).
    this-object:Controls:Add(this-object:buttonCancel).
    this-object:Controls:Add(this-object:buttonOk).
    this-object:Name = "SDedit_".
    this-object:Text = "Справочник устройств".
    this-object:TextChanged:Subscribe(this-object:Change_datetime).
    cast(this-object:bindcode, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    {gbl\ed_date_cls.i this-object this-object:dateTimePicker2}
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void okButton_Click( input sender as System.Object, input e as System.EventArgs ):

/*    dateTimePicker2:Value = datetime(dateTimePicker2:Text + " " + dateTimePicker1:Text) .*/

    bindcode:Assign().
    
    if valid-object(McodeTrg)
      then
      McodeTrg:checkcode().
    this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
    this-object:Close ( ). 

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void textBox3_TextChanged( input sender as System.Object, input e as System.EventArgs ):
	
    return.

  end method.

  destructor public SDedit_ ( ):

  end destructor.

end class.