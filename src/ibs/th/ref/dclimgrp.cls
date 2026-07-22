 /*------------------------------------------------------------------------
    File        : dclimgrp
    Purpose     : Используется для ввода атрибута объекта "Климатическая группа"
    Syntax      : 
    Description : Ввод климатической группы и сезонов климатической группы
    Author(s)   : smolotkov
    Created     : Mon Sep 10 15:04:03 MSK 2018
    Notes       : 
  ----------------------------------------------------------------------*/
USING Progress.Windows.Form.
  
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.dclimgrp INHERITS Form : 

  DEFINE PRIVATE VARIABLE cbCliGrp AS System.Windows.Forms.ComboBox NO-UNDO.
  DEFINE PRIVATE VARIABLE cbSpring AS System.Windows.Forms.ComboBox NO-UNDO.
  DEFINE PRIVATE VARIABLE cbWinter AS System.Windows.Forms.ComboBox NO-UNDO.
  DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonOk AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonCancel AS System.Windows.Forms.Button NO-UNDO.
  DEFINE PRIVATE VARIABLE labCliGrp AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE labSpring AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE labWinter AS System.Windows.Forms.Label NO-UNDO.
    
    define public variable climGrp     as character no-undo .
    define public variable beginSummer as character no-undo .
    define public variable beginWinter as character no-undo .
    
  CONSTRUCTOR PUBLIC dclimgrp( ):
    SUPER().
    assign
      climGrp     = ""
      beginSummer = "" 
      beginWinter = ""
    .
    InitializeComponent ( ).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.    
  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC dclimgrp( ):
    IF VALID-OBJECT(components) THEN DO:
      CAST(components, System.IDisposable):Dispose().
    END.
  END DESTRUCTOR.  

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID cbSpring_SelectedIndexChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    define variable v-winter-ind as integer no-undo . // ind0 = feb, ind10=dec
    v-winter-ind = this-object:cbWinter:SelectedIndex + 1 . // => ind1=feb, ind11=dec
    if (this-object:cbSpring:SelectedIndex > v-winter-ind) then  
      this-object:cbWinter:SelectedIndex = this-object:cbSpring:SelectedIndex - 1 .
		RETURN.
	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID cbWinter_SelectedIndexChanged( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    define variable v-winter-ind as integer no-undo . // ind0 = feb, ind10=dec
    v-winter-ind = this-object:cbWinter:SelectedIndex + 1 . // => ind1=feb, ind11=dec
    if (this-object:cbSpring:SelectedIndex > v-winter-ind) then  
      this-object:cbSpring:SelectedIndex = this-object:cbWinter:SelectedIndex + 1 .
		RETURN.
	END METHOD.

  METHOD PRIVATE VOID okButton_Click (sender AS System.Object, e AS System.EventArgs):
    assign
      climGrp     = this-object:cbCliGrp:Text
      beginSummer = this-object:cbSpring:Text 
      beginWinter = this-object:cbWinter:Text
    .
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Ok.
    THIS-OBJECT:Close ( ). 
  END METHOD.

  METHOD PRIVATE VOID cancelButton_Click (sender AS System.Object, e AS System.EventArgs):
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    THIS-OBJECT:Close ( ).
  END METHOD.
    
  METHOD PRIVATE VOID InitializeComponent ( ):

    /* NOTE: The following method is automatically generated.
       
       We strongly suggest that the contents of this method only be modified using the 
       Visual Designer to avoid any incompatible modifications.
       
       Modifying the contents of this method using a code editor will invalidate any support for this file. */
    
    THIS-OBJECT:buttonOk = NEW System.Windows.Forms.Button().
    THIS-OBJECT:buttonCancel = NEW System.Windows.Forms.Button().
    THIS-OBJECT:cbCliGrp = NEW System.Windows.Forms.ComboBox().
    THIS-OBJECT:labCliGrp = NEW System.Windows.Forms.Label().
    THIS-OBJECT:labSpring = NEW System.Windows.Forms.Label().
    THIS-OBJECT:labWinter = NEW System.Windows.Forms.Label().
    THIS-OBJECT:cbSpring = NEW System.Windows.Forms.ComboBox().
    THIS-OBJECT:cbWinter = NEW System.Windows.Forms.ComboBox().
    THIS-OBJECT:SuspendLayout().
    /*  */
    /* buttonOk */
    /*  */
    DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
    THIS-OBJECT:buttonOk:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:buttonOk:Location = NEW System.Drawing.Point(135, 125).
    THIS-OBJECT:buttonOk:Name = "buttonOk".
    THIS-OBJECT:buttonOk:Size = NEW System.Drawing.Size(75, 23).
    THIS-OBJECT:buttonOk:TabIndex = 0.
    THIS-OBJECT:buttonOk:Text = "Ввод".
    THIS-OBJECT:buttonOk:UseCompatibleTextRendering = true.
    THIS-OBJECT:buttonOk:Click:Subscribe(THIS-OBJECT:okButton_Click).
    /*  */
    /* buttonCancel */
    /*  */
    DEFINE VARIABLE nestedvar1 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
    THIS-OBJECT:buttonCancel:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    THIS-OBJECT:buttonCancel:Location = NEW System.Drawing.Point(219, 125).
    THIS-OBJECT:buttonCancel:Name = "buttonCancel".
    THIS-OBJECT:buttonCancel:Size = NEW System.Drawing.Size(75, 23).
    THIS-OBJECT:buttonCancel:TabIndex = 1.
    THIS-OBJECT:buttonCancel:Text = "Отмена".
    THIS-OBJECT:buttonCancel:UseCompatibleTextRendering = true.
    THIS-OBJECT:buttonCancel:Click:Subscribe(THIS-OBJECT:cancelButton_Click).
    /*  */
    /* cbCliGrp */
    /*  */
    THIS-OBJECT:cbCliGrp:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
    THIS-OBJECT:cbCliGrp:FlatStyle = System.Windows.Forms.FlatStyle:System.
    THIS-OBJECT:cbCliGrp:FormattingEnabled = true.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar0 AS System.Object EXTENT 7 NO-UNDO.
    arrayvar0[1] = "1 (1)".
    arrayvar0[2] = "1 (2)".
    arrayvar0[3] = "2 (1)".
    arrayvar0[4] = "2 (2)".
    arrayvar0[5] = "2 (3)".
    arrayvar0[6] = "3 (1)".
    arrayvar0[7] = "3 (2)".
    THIS-OBJECT:cbCliGrp:Items:AddRange(arrayvar0).
    THIS-OBJECT:cbCliGrp:Location = NEW System.Drawing.Point(220, 12).
    THIS-OBJECT:cbCliGrp:Name = "cbCliGrp".
    THIS-OBJECT:cbCliGrp:Size = NEW System.Drawing.Size(67, 24).
    THIS-OBJECT:cbCliGrp:TabIndex = 2.
    /*  */
    /* labCliGrp */
    /*  */
    THIS-OBJECT:labCliGrp:Location = NEW System.Drawing.Point(48, 12).
    THIS-OBJECT:labCliGrp:Name = "labCliGrp".
    THIS-OBJECT:labCliGrp:Size = NEW System.Drawing.Size(166, 23).
    THIS-OBJECT:labCliGrp:TabIndex = 3.
    THIS-OBJECT:labCliGrp:Text = "Климатическая группа".
    THIS-OBJECT:labCliGrp:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    THIS-OBJECT:labCliGrp:UseCompatibleTextRendering = true.
    /*  */
    /* labSpring */
    /*  */
    THIS-OBJECT:labSpring:Location = NEW System.Drawing.Point(12, 42).
    THIS-OBJECT:labSpring:Name = "labSpring".
    THIS-OBJECT:labSpring:Size = NEW System.Drawing.Size(202, 23).
    THIS-OBJECT:labSpring:TabIndex = 4.
    THIS-OBJECT:labSpring:Text = "Начало весенне-летнего пер.".
    THIS-OBJECT:labSpring:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    THIS-OBJECT:labSpring:UseCompatibleTextRendering = true.
    /*  */
    /* labWinter */
    /*  */
    THIS-OBJECT:labWinter:Location = NEW System.Drawing.Point(12, 72).
    THIS-OBJECT:labWinter:Name = "labWinter".
    THIS-OBJECT:labWinter:Size = NEW System.Drawing.Size(202, 23).
    THIS-OBJECT:labWinter:TabIndex = 5.
    THIS-OBJECT:labWinter:Text = "Начало осенне-зимнего пер.".
    THIS-OBJECT:labWinter:TextAlign = System.Drawing.ContentAlignment:MiddleRight.
    THIS-OBJECT:labWinter:UseCompatibleTextRendering = true.
    /*  */
    /* cbSpring */
    /*  */
    THIS-OBJECT:cbSpring:CausesValidation = false.
    THIS-OBJECT:cbSpring:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
    THIS-OBJECT:cbSpring:FormattingEnabled = true.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar1 AS System.Object EXTENT 11 NO-UNDO.
    arrayvar1[1] = "01/01".
    arrayvar1[2] = "01/02".
    arrayvar1[3] = "01/03".
    arrayvar1[4] = "01/04".
    arrayvar1[5] = "01/05".
    arrayvar1[6] = "01/06".
    arrayvar1[7] = "01/07".
    arrayvar1[8] = "01/08".
    arrayvar1[9] = "01/09".
    arrayvar1[10] = "01/10".
    arrayvar1[11] = "01/11".
    THIS-OBJECT:cbSpring:Items:AddRange(arrayvar1).
    THIS-OBJECT:cbSpring:Location = NEW System.Drawing.Point(220, 42).
    THIS-OBJECT:cbSpring:Name = "cbSpring".
    THIS-OBJECT:cbSpring:Size = NEW System.Drawing.Size(67, 24).
    THIS-OBJECT:cbSpring:TabIndex = 4.
    THIS-OBJECT:cbSpring:SelectedIndexChanged:Subscribe(THIS-OBJECT:cbSpring_SelectedIndexChanged).
    /*  */
    /* cbWinter */
    /*  */
    THIS-OBJECT:cbWinter:CausesValidation = false.
    THIS-OBJECT:cbWinter:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
    THIS-OBJECT:cbWinter:FormattingEnabled = true.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    DEFINE VARIABLE arrayvar2 AS System.Object EXTENT 11 NO-UNDO.
    arrayvar2[1] = "01/02".
    arrayvar2[2] = "01/03".
    arrayvar2[3] = "01/04".
    arrayvar2[4] = "01/05".
    arrayvar2[5] = "01/06".
    arrayvar2[6] = "01/07".
    arrayvar2[7] = "01/08".
    arrayvar2[8] = "01/09".
    arrayvar2[9] = "01/10".
    arrayvar2[10] = "01/11".
    arrayvar2[11] = "01/12".
    THIS-OBJECT:cbWinter:Items:AddRange(arrayvar2).
    THIS-OBJECT:cbWinter:Location = NEW System.Drawing.Point(220, 72).
    THIS-OBJECT:cbWinter:Name = "cbWinter".
    THIS-OBJECT:cbWinter:Size = NEW System.Drawing.Size(67, 24).
    THIS-OBJECT:cbWinter:TabIndex = 6.
    THIS-OBJECT:cbWinter:SelectedIndexChanged:Subscribe(THIS-OBJECT:cbWinter_SelectedIndexChanged).
    /*  */
    /* dclimgrp */
    /*  */
    THIS-OBJECT:AcceptButton = THIS-OBJECT:buttonOk.
    THIS-OBJECT:CancelButton = THIS-OBJECT:buttonCancel.
    THIS-OBJECT:ClientSize = NEW System.Drawing.Size(308, 162).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:cbWinter).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:cbSpring).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:labWinter).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:labSpring).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:labCliGrp).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:cbCliGrp).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonCancel).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonOk).
    THIS-OBJECT:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
    THIS-OBJECT:MaximizeBox = false.
    THIS-OBJECT:MinimizeBox = false.
    THIS-OBJECT:Name = "dclimgrp".
    THIS-OBJECT:ShowInTaskbar = false.
    THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
    THIS-OBJECT:Text = "Климатическая группа".
    THIS-OBJECT:ResumeLayout(false).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.
  END METHOD. 
 
  METHOD PUBLIC VOID ShowModalDialog(  ):
    define variable v-ind1 as integer no-undo .
    define variable v-ind2 as integer no-undo .
    define variable v-ind3 as integer no-undo .
    
    if climGrp > "" then do :
      v-ind1 = max(0, this-object:cbCliGrp:FindStringExact(climGrp) ) .
    end .
    else v-ind1 = 0 .
    
    if beginSummer > "" then do :
      v-ind2 = this-object:cbSpring:FindStringExact(beginSummer) .
      if v-ind2 < 0 then v-ind2 = 3 .
    end .
    else v-ind2 = 3 .

    if beginWinter > "" then do :
      v-ind3 = this-object:cbWinter:FindStringExact(beginWinter) .
      if v-ind3 < 0 then v-ind3 = 8 .
    end .
    else v-ind3 = 8 .
    
    assign
      this-object:cbCliGrp:SelectedIndex = v-ind1
      this-object:cbSpring:SelectedIndex = v-ind2
      this-object:cbWinter:SelectedIndex = v-ind3
    .
    WAIT-FOR THIS-OBJECT:ShowDialog().

  END METHOD.


 
END CLASS.
