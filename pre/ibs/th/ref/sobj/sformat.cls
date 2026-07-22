using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class ibs.th.ref.sobj.sFormat inherits UserControl:
   define private variable button3 as System.Windows.Forms.Button no-undo.
   define private variable button2 as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable lFontType as System.Windows.Forms.TextBox no-undo.
   define private variable lFontSize as System.Windows.Forms.TextBox no-undo.
   define private variable lFontNum as System.Windows.Forms.TextBox no-undo.
   define private variable lName as System.Windows.Forms.TextBox no-undo.
   define private variable lHeight as System.Windows.Forms.NumericUpDown no-undo.
   define private variable numericUpDown2 as System.Windows.Forms.NumericUpDown no-undo.
   define private variable rFont as System.Windows.Forms.Button no-undo.
   define private variable lFontName as System.Windows.Forms.TextBox no-undo.
   define private variable panel1 as System.Windows.Forms.Panel no-undo.
   define private variable label2 as System.Windows.Forms.Label no-undo.
   define private variable label1 as System.Windows.Forms.Label no-undo.
   method public void get-var ():
   end.
   constructor public sFormat (  ):
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   method private void InitializeComponent(  ):
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:lFontNum = new System.Windows.Forms.TextBox().
      this-object:rFont = new System.Windows.Forms.Button().
      this-object:lFontName = new System.Windows.Forms.TextBox().
      this-object:lFontSize = new System.Windows.Forms.TextBox().
      this-object:lFontType = new System.Windows.Forms.TextBox().
      this-object:panel1 = new System.Windows.Forms.Panel().
      this-object:button3 = new System.Windows.Forms.Button().
      this-object:button2 = new System.Windows.Forms.Button().
      this-object:numericUpDown2 = new System.Windows.Forms.NumericUpDown().
      this-object:lHeight = new System.Windows.Forms.NumericUpDown().
      this-object:lName = new System.Windows.Forms.TextBox().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:panel1:SuspendLayout().
      cast(this-object:numericUpDown2, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:lHeight, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label1:Location = new System.Drawing.Point(3, 9).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(45, 23).
      this-object:label1:TabIndex = 0.
      this-object:label1:Text = "Ўрифт".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:lFontNum:Enabled = false.
      this-object:lFontNum:Location = new System.Drawing.Point(55, 9).
      this-object:lFontNum:Name = "lFontNum".
      this-object:lFontNum:Size = new System.Drawing.Size(100, 20).
      this-object:lFontNum:TabIndex = 1.
      this-object:rFont:Location = new System.Drawing.Point(161, 9).
      this-object:rFont:Name = "rFont".
      this-object:rFont:Size = new System.Drawing.Size(20, 20).
      this-object:rFont:TabIndex = 2.
      this-object:rFont:UseCompatibleTextRendering = true.
      this-object:rFont:UseVisualStyleBackColor = true.
      this-object:lFontName:Enabled = false.
      this-object:lFontName:Location = new System.Drawing.Point(3, 35).
      this-object:lFontName:Name = "lFontName".
      this-object:lFontName:Size = new System.Drawing.Size(178, 20).
      this-object:lFontName:TabIndex = 3.
      this-object:lFontSize:Enabled = false.
      this-object:lFontSize:Location = new System.Drawing.Point(4, 62).
      this-object:lFontSize:Name = "lFontSize".
      this-object:lFontSize:Size = new System.Drawing.Size(177, 20).
      this-object:lFontSize:TabIndex = 4.
      this-object:lFontType:Enabled = false.
      this-object:lFontType:Location = new System.Drawing.Point(4, 89).
      this-object:lFontType:Name = "lFontType".
      this-object:lFontType:Size = new System.Drawing.Size(177, 20).
      this-object:lFontType:TabIndex = 5.
      this-object:panel1:BorderStyle = System.Windows.Forms.BorderStyle:Fixed3D.
      this-object:panel1:Controls:Add(this-object:button3).
      this-object:panel1:Controls:Add(this-object:button2).
      this-object:panel1:Controls:Add(this-object:numericUpDown2).
      this-object:panel1:Controls:Add(this-object:lHeight).
      this-object:panel1:Controls:Add(this-object:lName).
      this-object:panel1:Controls:Add(this-object:label2).
      this-object:panel1:Location = new System.Drawing.Point(4, 115).
      this-object:panel1:Name = "panel1".
      this-object:panel1:Size = new System.Drawing.Size(176, 184).
      this-object:panel1:TabIndex = 6.
      this-object:button3:Location = new System.Drawing.Point(37, 109).
      this-object:button3:Name = "button3".
      this-object:button3:Size = new System.Drawing.Size(27, 20).
      this-object:button3:TabIndex = 5.
      this-object:button3:Text = "A3".
      this-object:button3:UseCompatibleTextRendering = true.
      this-object:button3:UseVisualStyleBackColor = true.
      this-object:button2:Location = new System.Drawing.Point(4, 109).
      this-object:button2:Name = "button2".
      this-object:button2:Size = new System.Drawing.Size(27, 20).
      this-object:button2:TabIndex = 4.
      this-object:button2:Text = "A4".
      this-object:button2:UseCompatibleTextRendering = true.
      this-object:button2:UseVisualStyleBackColor = true.
      this-object:numericUpDown2:Location = new System.Drawing.Point(72, 111).
      this-object:numericUpDown2:Name = "numericUpDown2".
      this-object:numericUpDown2:Size = new System.Drawing.Size(77, 20).
      this-object:numericUpDown2:TabIndex = 3.
      this-object:lHeight:Location = new System.Drawing.Point(17, 59).
      this-object:lHeight:Name = "lHeight".
      this-object:lHeight:Size = new System.Drawing.Size(49, 20).
      this-object:lHeight:TabIndex = 2.
      this-object:lName:Enabled = false.
      this-object:lName:Location = new System.Drawing.Point(72, 45).
      this-object:lName:Multiline = true.
      this-object:lName:Name = "lName".
      this-object:lName:Size = new System.Drawing.Size(77, 48).
      this-object:lName:TabIndex = 1.
      this-object:lName:TextAlign = System.Windows.Forms.HorizontalAlignment:Center.
      this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label2:Location = new System.Drawing.Point(4, 4).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(165, 23).
      this-object:label2:TabIndex = 0.
      this-object:label2:Text = "‘ормат страницы".
      this-object:label2:UseCompatibleTextRendering = true.
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:panel1).
      this-object:Controls:Add(this-object:lFontType).
      this-object:Controls:Add(this-object:lFontSize).
      this-object:Controls:Add(this-object:lFontName).
      this-object:Controls:Add(this-object:rFont).
      this-object:Controls:Add(this-object:lFontNum).
      this-object:Controls:Add(this-object:label1).
      this-object:Name = "sFormat".
      this-object:Size = new System.Drawing.Size(186, 303).
      this-object:panel1:ResumeLayout(false).
      this-object:panel1:PerformLayout().
      cast(this-object:numericUpDown2, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:lHeight, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   destructor public sFormat ( ):
   end destructor.
end class.
