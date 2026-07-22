using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.str.ptrl.forms.waitform inherits Form:
  define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable textBox1 as System.Windows.Forms.TextBox no-undo.
  constructor public waitform (  ):
    super().
    InitializeComponent().
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public waitform (input pText as character):
    super().
    InitializeComponent().
    this-object:textBox1:Text = pText .
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  method public void SetLabel(input pText as character) :
    this-object:textBox1:Text = pText .
  end method .
  method private void InitializeComponent(  ):
    this-object:textBox1 = new System.Windows.Forms.TextBox().
    this-object:SuspendLayout().
    this-object:textBox1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(10), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:textBox1:Location = new System.Drawing.Point(12, 12).
    this-object:textBox1:Multiline = true.
    this-object:textBox1:Name = "textBox1".
    this-object:textBox1:Size = new System.Drawing.Size(346, 54).
    this-object:textBox1:TabIndex = 0.
    this-object:textBox1:Text = "~r~n∆‰ËÚÂ...".
    this-object:textBox1:TextAlign = System.Windows.Forms.HorizontalAlignment:Center.
    this-object:AutoScaleMode = System.Windows.Forms.AutoScaleMode:None.
    this-object:ClientSize = new System.Drawing.Size(370, 78).
    this-object:Controls:Add(this-object:textBox1).
    this-object:Name = "waitform".
    this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
    this-object:Text = "".
    this-object:TopMost = true.
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.
  destructor public waitform ( ):
  end destructor.
end class.
