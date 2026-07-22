/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Форма редактированния справочника "Код ОКЕИ код ККТ"

Автор: Рукавишников Вадим
Дата создания: 27.04.2021
Author: Rukavishnikov Vadim
Creation date: 27.04.2021

*/

using Progress.Lang.*.
using Progress.Windows.Form.
using ibs.th.ref.code.okeikktedit_ from propath.
using System.Windows.Forms.* from assembly.

block-level on error undo, throw.

class ibs.th.ref.code.okeikktedit_ inherits Form: 
  {cmp/str-glbl.i class}
  
  define public variable bindcode         as Progress.Data.BindingSource         no-undo.
  define private variable btn_unit        as System.Windows.Forms.Button         no-undo.
  define private variable buttonOk        as System.Windows.Forms.Button         no-undo.
  define private variable buttonCancel    as System.Windows.Forms.Button         no-undo.
  define private variable components      as System.ComponentModel.IContainer    no-undo.
   define private variable mUnit as System.Windows.Forms.TextBox no-undo.
   define private variable mOKEI as System.Windows.Forms.MaskedTextBox no-undo.
   define private variable mKKT as System.Windows.Forms.MaskedTextBox no-undo.
  define private variable label3          as System.Windows.Forms.Label          no-undo.
  define private variable label2          as System.Windows.Forms.Label          no-undo.
  define private variable label1          as System.Windows.Forms.Label          no-undo.
  define public  variable p-list          as character                           no-undo .
  
  define         variable McodeTrg        as class                               ibs.th.ref.code.code_trg NO-UNDO.    
  
  define property parparentproc as handle no-undo
    private get.
    set(input iH as handle):
      parparentproc = ih.
    end.

  constructor public okeikktedit_ (iChange as character, iTrg as class ibs.th.ref.code.code_trg):
    super().
    InitializeComponent().

    McodeTrg = itrg.
    this-object:ComponentsCollection:ADD(this-object:components).
    Visual_form(iChange).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

  end constructor.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void btn_unit_Click( input sender as System.Object, input e as System.EventArgs ):
      define buffer units for units.
      define variable vRec as recid no-undo .
      do on error undo, return no-apply:

         run ref/units.w
               (input  parparentproc
               ,input  yes
               ,output vRec
               ).
         if vRec <> ? then do:
            find first units where recid(units) = vRec no-lock no-error.
            if avail units then do:
               this-object:mUnit:Text = units.unit-name.
               this-object:mUnit:focus().
            end.
         end.
      end.
      return.
	end method.

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
      define variable tableDesc2 as Progress.Data.TableDesc no-undo.
      tableDesc2 = new Progress.Data.TableDesc("Code").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable resources as Progress.Util.ResourceManager no-undo.
      resources = new Progress.Util.ResourceManager("ibs.th.ref.code.okeikktedit_").
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:mUnit = new System.Windows.Forms.TextBox().
      this-object:bindcode = new Progress.Data.BindingSource(this-object:components).
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:mKKT = new System.Windows.Forms.MaskedTextBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:mOKEI = new System.Windows.Forms.MaskedTextBox().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:btn_unit = new System.Windows.Forms.Button().
      cast(this-object:bindcode, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Location = new System.Drawing.Point(3, 93).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(74, 23).
      this-object:label3:TabIndex = 15.
      this-object:label3:Text = "ПФ ККТ".
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* mUnit */
      /*  */
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:mUnit:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:mUnit:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "misc1", true)).
      this-object:mUnit:Location = new System.Drawing.Point(83, 93).
      this-object:mUnit:Name = "mUnit".
      this-object:mUnit:Size = new System.Drawing.Size(203, 20).
      this-object:mUnit:TabIndex = 14.
      this-object:mUnit:TextChanged:Subscribe(this-object:textBox3_TextChanged).
      /*  */
      /* bindcode */
      /*  */
      this-object:bindcode:MaxDataGuess = 0.
      this-object:bindcode:NoLOBs = false.
      this-object:bindcode:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc2:ChildTables = arrayvar0.
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
      tableDesc2:Columns = arrayvar1.
      this-object:bindcode:TableSchema = tableDesc2.
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Location = new System.Drawing.Point(3, 67).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(75, 23).
      this-object:label2:TabIndex = 13.
      this-object:label2:Text = "Код ЕИ ККТ".
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* mKKT */
      /*  */
      define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar1 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:mKKT:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:mKKT:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "CodeName", true)).
      this-object:mKKT:Location = new System.Drawing.Point(83, 67).
      this-object:mKKT:Mask = "00000000".
      this-object:mKKT:Name = "mKKT".
      this-object:mKKT:ResetOnSpace = false.
      this-object:mKKT:Size = new System.Drawing.Size(203, 20).
      this-object:mKKT:TabIndex = 12.
      this-object:mKKT:ValidatingType = Progress.Util.TypeHelper:GetType("System.Int32").
      this-object:mKKT:TextChanged:Subscribe(this-object:mKKT_TextChanged).
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Location = new System.Drawing.Point(3, 41).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(75, 23).
      this-object:label1:TabIndex = 11.
      this-object:label1:Text = "Код ОКЕИ".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:label1:Click:Subscribe(this-object:label1_Click).
      /*  */
      /* mOKEI */
      /*  */
      define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar2 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:mOKEI:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:mOKEI:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindcode, "code", true)).
      this-object:mOKEI:Location = new System.Drawing.Point(83, 41).
      this-object:mOKEI:Mask = "00000000".
      this-object:mOKEI:Name = "mOKEI".
      this-object:mOKEI:ResetOnSpace = false.
      this-object:mOKEI:RightToLeft = System.Windows.Forms.RightToLeft:No.
      this-object:mOKEI:Size = new System.Drawing.Size(203, 20).
      this-object:mOKEI:TabIndex = 10.
      this-object:mOKEI:ValidatingType = Progress.Util.TypeHelper:GetType("System.Int32").
      this-object:mOKEI:TextChanged:Subscribe(this-object:mOKEI_TextChanged).
      /*  */
      /* buttonCancel */
      /*  */
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(86, 12).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 9.
      this-object:buttonCancel:Text = "Отмена".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      /*  */
      /* buttonOk */
      /*  */
      this-object:buttonOk:Location = new System.Drawing.Point(6, 12).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 8.
      this-object:buttonOk:Text = "Ввод".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      /*  */
      /* btn_unit */
      /*  */
      define variable nestedvar3 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar3 = System.Windows.Forms.AnchorStyles:Top.
      this-object:btn_unit:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar3, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:btn_unit:CausesValidation = false.
      this-object:btn_unit:Image = cast(resources:GetObject("btn_unit.Image"), System.Drawing.Image).
      this-object:btn_unit:Location = new System.Drawing.Point(292, 91).
      this-object:btn_unit:Name = "btn_unit".
      this-object:btn_unit:Size = new System.Drawing.Size(25, 23).
      this-object:btn_unit:TabIndex = 17.
      this-object:btn_unit:UseCompatibleTextRendering = true.
      this-object:btn_unit:UseVisualStyleBackColor = true.
      this-object:btn_unit:Click:Subscribe(this-object:btn_unit_Click).
      /*  */
      /* okeikktedit_ */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(329, 120).
      this-object:Controls:Add(this-object:btn_unit).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:mUnit).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:mKKT).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:mOKEI).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:Name = "okeikktedit_".
      this-object:Text = "Код ОКЕИ код ККТ".
      this-object:Load:Subscribe(this-object:okeikktedit__Load).
      this-object:TextChanged:Subscribe(this-object:Change_datetime).
      this-object:KeyPress:Subscribe(this-object:okeikktedit__KeyPress).
      cast(this-object:bindcode, System.ComponentModel.ISupportInitialize):EndInit().
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
	method private void mKKT_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		mKKT:text = replace(mKKT:text, " ", "").
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void mOKEI_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		mOKEI:text = replace(mOKEI:text, " ", "").
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void okeikktedit__KeyPress( input sender as System.Object, input e as System.Windows.Forms.KeyPressEventArgs ):
		
		return.

	end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public void Visual_form( input iChange AS character ):
    if iChange = {&lookup} 
    then assign 
       this-object:mUnit:Enabled     = false
       this-object:btn_unit:Visible  = false
       this-object:mKKT:Enabled      = false
       this-object:mOKEI:Enabled     = false
    .
    else if iChange = {&update} then 
       this-object:mOKEI:Enabled = false.
    return.
  end method .

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label1_Click( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void okButton_Click( input sender as System.Object, input e as System.EventArgs ):
    define buffer b-code for code.

    bindcode:Assign().
    if valid-object(McodeTrg)
      then
      McodeTrg:CheckCodeInt().
    this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
    this-object:Close ( ). 
  end method.

  
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void okeikktedit__Load( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void textBox3_TextChanged( input sender as System.Object, input e as System.EventArgs ):
	
    return.

  end method.

  destructor public okeikktedit_ ( ):

  end destructor.

end class.