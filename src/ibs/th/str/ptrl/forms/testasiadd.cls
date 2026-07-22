 
 /*------------------------------------------------------------------------
    File        : TestAsiAdd
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : user
    Created     : Tue Mar 26 15:17:09 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

block-level on error undo, throw.

class ibs.th.str.ptrl.forms.TestAsiAdd inherits Form: 
  
  define private variable bOk as System.Windows.Forms.Button no-undo.
  define private variable bCancel as System.Windows.Forms.Button no-undo.
  define private variable cb3 as System.Windows.Forms.CheckBox no-undo.
  define private variable cb2 as System.Windows.Forms.CheckBox no-undo.
  define private variable cb1 as System.Windows.Forms.CheckBox no-undo.
  define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable label2 as System.Windows.Forms.Label no-undo.
  define private variable label1 as System.Windows.Forms.Label no-undo.
  define private variable panel1 as System.Windows.Forms.Panel no-undo.
  define private variable groupBox1 as System.Windows.Forms.GroupBox no-undo.
  define private variable rb3 as System.Windows.Forms.RadioButton no-undo.
  define private variable rb2 as System.Windows.Forms.RadioButton no-undo.
  define private variable rb1 as System.Windows.Forms.RadioButton no-undo.
  
  define public property pType as character
  get.
  private set.
  
  define public property pFull as logical
  get.
  private set.

    
  constructor public TestAsiAdd ():
    
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
	method private void bCancel_Click( input sender as System.Object, input e as System.EventArgs ):
		
		this-object:Close().
    return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void bOk_Click( input sender as System.Object, input e as System.EventArgs ):
		
		pType = "" .
		
		case true :
		  when this-object:rb1:Checked
		  then do :
		    pType = "test-asi_dens-place" .
		    pFull = this-object:cb1:Checked .
		  end .
		  when this-object:rb2:Checked
      then do :
        pType = "test-asi_dens-pump" .
        pFull = this-object:cb2:Checked .
      end .
      when this-object:rb3:Checked
      then do :
        pType = "test-asi_mass" .
        pFull = this-object:cb3:Checked .
      end .
		end case .
		
		this-object:Close().
		return.

	end method.

  method private void InitializeComponent(  ):
    
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable resources as Progress.Util.ResourceManager no-undo.
    resources = new Progress.Util.ResourceManager("ibs.th.str.ptrl.forms.TestAsiAdd").
    this-object:bOk = new System.Windows.Forms.Button().
    this-object:bCancel = new System.Windows.Forms.Button().
    this-object:groupBox1 = new System.Windows.Forms.GroupBox().
    this-object:cb3 = new System.Windows.Forms.CheckBox().
    this-object:cb2 = new System.Windows.Forms.CheckBox().
    this-object:cb1 = new System.Windows.Forms.CheckBox().
    this-object:panel1 = new System.Windows.Forms.Panel().
    this-object:rb3 = new System.Windows.Forms.RadioButton().
    this-object:rb2 = new System.Windows.Forms.RadioButton().
    this-object:rb1 = new System.Windows.Forms.RadioButton().
    this-object:label1 = new System.Windows.Forms.Label().
    this-object:label2 = new System.Windows.Forms.Label().
    this-object:groupBox1:SuspendLayout().
    this-object:panel1:SuspendLayout().
    this-object:SuspendLayout().
    /*  */
    /* bOk */
    /*  */
    this-object:bOk:Location = new System.Drawing.Point(12, 12).
    this-object:bOk:Name = "bOk".
    this-object:bOk:Size = new System.Drawing.Size(75, 23).
    this-object:bOk:TabIndex = 0.
    this-object:bOk:Text = "Ввод".
    this-object:bOk:UseCompatibleTextRendering = true.
    this-object:bOk:UseVisualStyleBackColor = true.
    this-object:bOk:Click:Subscribe(this-object:bOk_Click).
    /*  */
    /* bCancel */
    /*  */
    this-object:bCancel:Location = new System.Drawing.Point(93, 12).
    this-object:bCancel:Name = "bCancel".
    this-object:bCancel:Size = new System.Drawing.Size(75, 23).
    this-object:bCancel:TabIndex = 1.
    this-object:bCancel:Text = "Отмена".
    this-object:bCancel:UseCompatibleTextRendering = true.
    this-object:bCancel:UseVisualStyleBackColor = true.
    this-object:bCancel:Click:Subscribe(this-object:bCancel_Click).
    /*  */
    /* groupBox1 */
    /*  */
    this-object:groupBox1:Controls:Add(this-object:label2).
    this-object:groupBox1:Controls:Add(this-object:label1).
    this-object:groupBox1:Controls:Add(this-object:cb3).
    this-object:groupBox1:Controls:Add(this-object:cb2).
    this-object:groupBox1:Controls:Add(this-object:cb1).
    this-object:groupBox1:Controls:Add(this-object:panel1).
    this-object:groupBox1:Location = new System.Drawing.Point(4, 41).
    this-object:groupBox1:Name = "groupBox1".
    this-object:groupBox1:Size = new System.Drawing.Size(458, 176).
    this-object:groupBox1:TabIndex = 2.
    this-object:groupBox1:TabStop = false.
    this-object:groupBox1:UseCompatibleTextRendering = true.
    /*  */
    /* cb3 */
    /*  */
    this-object:cb3:Checked = true.
    this-object:cb3:CheckState = System.Windows.Forms.CheckState:Checked.
    this-object:cb3:Location = new System.Drawing.Point(352, 129).
    this-object:cb3:Name = "cb3".
    this-object:cb3:Size = new System.Drawing.Size(70, 24).
    this-object:cb3:TabIndex = 3.
    this-object:cb3:Text = "полный".
    this-object:cb3:UseCompatibleTextRendering = true.
    this-object:cb3:UseVisualStyleBackColor = true.
    /*  */
    /* cb2 */
    /*  */
    this-object:cb2:Checked = true.
    this-object:cb2:CheckState = System.Windows.Forms.CheckState:Checked.
    this-object:cb2:Location = new System.Drawing.Point(352, 85).
    this-object:cb2:Name = "cb2".
    this-object:cb2:Size = new System.Drawing.Size(70, 24).
    this-object:cb2:TabIndex = 2.
    this-object:cb2:Text = "полный".
    this-object:cb2:UseCompatibleTextRendering = true.
    this-object:cb2:UseVisualStyleBackColor = true.
    /*  */
    /* cb1 */
    /*  */
    this-object:cb1:Checked = true.
    this-object:cb1:CheckState = System.Windows.Forms.CheckState:Checked.
    this-object:cb1:Location = new System.Drawing.Point(352, 34).
    this-object:cb1:Name = "cb1".
    this-object:cb1:Size = new System.Drawing.Size(70, 24).
    this-object:cb1:TabIndex = 1.
    this-object:cb1:Text = "полный".
    this-object:cb1:UseCompatibleTextRendering = true.
    this-object:cb1:UseVisualStyleBackColor = true.
    /*  */
    /* panel1 */
    /*  */
    this-object:panel1:Controls:Add(this-object:rb3).
    this-object:panel1:Controls:Add(this-object:rb2).
    this-object:panel1:Controls:Add(this-object:rb1).
    this-object:panel1:Location = new System.Drawing.Point(0, 19).
    this-object:panel1:Name = "panel1".
    this-object:panel1:Size = new System.Drawing.Size(319, 151).
    this-object:panel1:TabIndex = 0.
    /*  */
    /* rb3 */
    /*  */
    this-object:rb3:Location = new System.Drawing.Point(10, 105).
    this-object:rb3:Name = "rb3".
    this-object:rb3:Size = new System.Drawing.Size(294, 32).
    this-object:rb3:TabIndex = 2.
    this-object:rb3:Text = "Проверка корректности работы АСИ по массе НП".
    this-object:rb3:UseCompatibleTextRendering = true.
    this-object:rb3:UseVisualStyleBackColor = true.
    /*  */
    /* rb2 */
    /*  */
    this-object:rb2:Location = new System.Drawing.Point(10, 55).
    this-object:rb2:Name = "rb2".
    this-object:rb2:Size = new System.Drawing.Size(294, 44).
    this-object:rb2:TabIndex = 1.
    this-object:rb2:Text = "Проверка корректности работы канала плотности НП АСИ резервуара (отбор пробы через ТРК)".
    this-object:rb2:UseCompatibleTextRendering = true.
    this-object:rb2:UseVisualStyleBackColor = true.
    /*  */
    /* rb1 */
    /*  */
    this-object:rb1:Checked = true.
    this-object:rb1:Location = new System.Drawing.Point(10, 3).
    this-object:rb1:Name = "rb1".
    this-object:rb1:Size = new System.Drawing.Size(294, 46).
    this-object:rb1:TabIndex = 0.
    this-object:rb1:TabStop = true.
    this-object:rb1:Text = "Проверка корректности работы канала плотности НП АСИ резервуара (отбор пробы/замер в резервуаре)".
    this-object:rb1:UseCompatibleTextRendering = true.
    this-object:rb1:UseVisualStyleBackColor = true.
    /*  */
    /* label1 */
    /*  */
    this-object:label1:Location = new System.Drawing.Point(-3, 111).
    this-object:label1:Name = "label1".
    this-object:label1:Size = new System.Drawing.Size(439, 19).
    this-object:label1:TabIndex = 5.
    this-object:label1:Text = "________________________________________________________________________________________".
    this-object:label1:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label1:UseCompatibleTextRendering = true.
    /*  */
    /* label2 */
    /*  */
    this-object:label2:Location = new System.Drawing.Point(-3, 63).
    this-object:label2:Name = "label2".
    this-object:label2:Size = new System.Drawing.Size(439, 19).
    this-object:label2:TabIndex = 6.
    this-object:label2:Text = "________________________________________________________________________________________".
    this-object:label2:TextAlign = System.Drawing.ContentAlignment:MiddleCenter.
    this-object:label2:UseCompatibleTextRendering = true.
    /*  */
    /* TestAsiAdd */
    /*  */
    this-object:ClientSize = new System.Drawing.Size(465, 229).
    this-object:Controls:Add(this-object:groupBox1).
    this-object:Controls:Add(this-object:bCancel).
    this-object:Controls:Add(this-object:bOk).
    this-object:Icon = cast(resources:GetObject("$this.Icon"), System.Drawing.Icon).
    this-object:Name = "TestAsiAdd".
    this-object:Text = "Документ проверки корректности работы АСИ в резервуаре".
    this-object:groupBox1:ResumeLayout(false).
    this-object:panel1:ResumeLayout(false).
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.

  destructor public TestAsiAdd ( ):

  end destructor.

end class.