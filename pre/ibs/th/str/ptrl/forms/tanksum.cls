using Progress.Lang.*.
using Progress.Windows.UserControl.
using ibs.th.str.* from propath.
block-level on error undo, throw.
class ibs.th.str.ptrl.forms.tanksum inherits UserControl:
  define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable maskedTextBoxDocQntySum as System.Windows.Forms.MaskedTextBox no-undo.
  define private variable maskedTextBoxCarVolSum as System.Windows.Forms.MaskedTextBox no-undo.
  define private variable maskedTextBoxTankVol as System.Windows.Forms.MaskedTextBox no-undo.
  define private variable maskedTextBoxTankWeightSum as System.Windows.Forms.MaskedTextBox no-undo.
  define private variable label39 as System.Windows.Forms.Label no-undo.
  define private variable label16 as System.Windows.Forms.Label no-undo.
  define private variable label15 as System.Windows.Forms.Label no-undo.
  define private variable label13 as System.Windows.Forms.Label no-undo.
  constructor public tanksum (  ):
    super().
    InitializeComponent().
    InitializeComponentCust().
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  method private void InitializeComponent(  ):
     this-object:label39 = new System.Windows.Forms.Label().
    this-object:label16 = new System.Windows.Forms.Label().
    this-object:label15 = new System.Windows.Forms.Label().
    this-object:label13 = new System.Windows.Forms.Label().
    this-object:maskedTextBoxDocQntySum = new System.Windows.Forms.MaskedTextBox().
    this-object:maskedTextBoxTankWeightSum = new System.Windows.Forms.MaskedTextBox().
    this-object:maskedTextBoxTankVol = new System.Windows.Forms.MaskedTextBox().
    this-object:maskedTextBoxCarVolSum = new System.Windows.Forms.MaskedTextBox().
    this-object:SuspendLayout().
    this-object:label39:Location = new System.Drawing.Point(239, 148).
    this-object:label39:Name = "label39".
    this-object:label39:Size = new System.Drawing.Size(117, 20).
    this-object:label39:TabIndex = 37.
    this-object:label39:Text = "Объем топлива, л:".
    this-object:label39:TextAlign = System.Drawing.ContentAlignment:TopRight.
    this-object:label39:UseCompatibleTextRendering = true.
    this-object:label16:Location = new System.Drawing.Point(189, 173).
    this-object:label16:Name = "label16".
    this-object:label16:Size = new System.Drawing.Size(167, 20).
    this-object:label16:TabIndex = 35.
    this-object:label16:Text = "Количество по документу, л:".
    this-object:label16:TextAlign = System.Drawing.ContentAlignment:TopRight.
    this-object:label16:UseCompatibleTextRendering = true.
    this-object:label15:Location = new System.Drawing.Point(239, 123).
    this-object:label15:Name = "label15".
    this-object:label15:Size = new System.Drawing.Size(117, 20).
    this-object:label15:TabIndex = 34.
    this-object:label15:Text = "Вес топлива, кг:".
    this-object:label15:TextAlign = System.Drawing.ContentAlignment:TopRight.
    this-object:label15:UseCompatibleTextRendering = true.
    this-object:label13:Location = new System.Drawing.Point(177, 94).
    this-object:label13:Name = "label13".
    this-object:label13:Size = new System.Drawing.Size(179, 28).
    this-object:label13:TabIndex = 32.
    this-object:label13:Text = "Объем по паспорту, л:".
    this-object:label13:TextAlign = System.Drawing.ContentAlignment:TopRight.
    this-object:label13:UseCompatibleTextRendering = true.
    this-object:maskedTextBoxDocQntySum:Enabled = false.
    this-object:maskedTextBoxDocQntySum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:maskedTextBoxDocQntySum:Location = new System.Drawing.Point(362, 171).
    this-object:maskedTextBoxDocQntySum:Name = "maskedTextBoxDocQntySum".
    this-object:maskedTextBoxDocQntySum:Size = new System.Drawing.Size(100, 20).
    this-object:maskedTextBoxDocQntySum:TabIndex = 33.
    this-object:maskedTextBoxTankWeightSum:Enabled = false.
    this-object:maskedTextBoxTankWeightSum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:maskedTextBoxTankWeightSum:Location = new System.Drawing.Point(362, 120).
    this-object:maskedTextBoxTankWeightSum:Name = "maskedTextBoxTankWeightSum".
    this-object:maskedTextBoxTankWeightSum:Size = new System.Drawing.Size(100, 20).
    this-object:maskedTextBoxTankWeightSum:TabIndex = 30.
    this-object:maskedTextBoxTankVol:Enabled = false.
    this-object:maskedTextBoxTankVol:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:maskedTextBoxTankVol:Location = new System.Drawing.Point(362, 146).
    this-object:maskedTextBoxTankVol:Name = "maskedTextBoxTankVol".
    this-object:maskedTextBoxTankVol:Size = new System.Drawing.Size(100, 20).
    this-object:maskedTextBoxTankVol:TabIndex = 31.
    this-object:maskedTextBoxCarVolSum:Enabled = false.
    this-object:maskedTextBoxCarVolSum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:maskedTextBoxCarVolSum:Location = new System.Drawing.Point(362, 94).
    this-object:maskedTextBoxCarVolSum:Name = "maskedTextBoxCarVolSum".
    this-object:maskedTextBoxCarVolSum:Size = new System.Drawing.Size(100, 20).
    this-object:maskedTextBoxCarVolSum:TabIndex = 29.
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:Controls:Add(this-object:label39).
    this-object:Controls:Add(this-object:label16).
    this-object:Controls:Add(this-object:label15).
    this-object:Controls:Add(this-object:maskedTextBoxDocQntySum).
    this-object:Controls:Add(this-object:label13).
    this-object:Controls:Add(this-object:maskedTextBoxTankWeightSum).
    this-object:Controls:Add(this-object:maskedTextBoxTankVol).
    this-object:Controls:Add(this-object:maskedTextBoxCarVolSum).
    this-object:Name = "tanksum".
    this-object:Size = new System.Drawing.Size(700, 820).
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.
  method private void InitializeComponentCust ():
    def var ii as int no-undo.
    InitializeComponentCust( maskedTextBoxDocQntySum).
    InitializeComponentCust( maskedTextBoxCarVolSum).
    InitializeComponentCust( maskedTextBoxTankVol).
    InitializeComponentCust( maskedTextBoxTankWeightSum).
  end.
  method private void InitializeComponentCust (imaskedTextBoxArr as System.Windows.Forms.MaskedTextBox):
      imaskedTextBoxArr:Enabled = false.
      imaskedTextBoxArr:BackColor = imaskedTextBoxArr:BackColor .
      imaskedTextBoxArr:ReadOnly = true.
  end.
  method public void SetData( infoSecs as InfoSectionsTotal ):
    infoSecs:CalculateTotal().
    maskedTextBoxTankWeightSum:Text = string_round (infoSecs:TankWeightTotal).
    maskedTextBoxDocQntySum:Text    = string_round (infoSecs:DocQntyTotal).
    maskedTextBoxTankVol:Text      = string_round (infoSecs:TankVolTotal).
    maskedTextBoxCarVolSum:Text     = string_round (infoSecs:CarVolTotal).
  end.
  method private char string_round (arg as decimal):
    def var str as char no-undo.
    str = string (round(arg, 3), "->>>,>>>,>>9.999").
    return str.
  end.
  destructor public tanksum ( ):
  end destructor.
end class.
