using Progress.Lang.*.
using Progress.Windows.Form.
block-level on error undo, throw.
class ibs.th.ref.sobj.rprev inherits Form:
   define private variable button1 as System.Windows.Forms.Button no-undo.
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable ReportPreview as System.Windows.Forms.TextBox no-undo.
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set(iarg as class ibs.th.ref.sobj.sParamObj ):
      ParamObj = iarg.
      Reportpreview:Text =                       ParamObj:ReportName   + "~r~n".
      if ParamObj:strShift ne "" then
      Reportpreview:Text = Reportpreview:Text  + ParamObj:strShift     + "~r~n".
      if ParamObj:strCurr ne "" then
      Reportpreview:Text = Reportpreview:Text  + ParamObj:strCurr      + "~r~n".
      if ParamObj:strCust ne "" then
      Reportpreview:Text = Reportpreview:Text  + ParamObj:strCust      + "~r~n".
      if ParamObj:strGoods ne "" then
      Reportpreview:Text = Reportpreview:Text  + ParamObj:strGoods     + "~r~n".
      if ParamObj:strSchet ne "" then
      Reportpreview:Text = Reportpreview:Text  + ParamObj:strSchet     + "~r~n".
      if ParamObj:strObj ne "" then
      Reportpreview:Text = Reportpreview:Text  + ParamObj:strObj       + "~r~n".
      Reportpreview:Text = Reportpreview:Text  + ParamObj:ReportHeader + "~r~n".
   end.
   constructor public rprev (  ):
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
        @VisualDesigner.
        method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
                this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
                return.
        end method.
   method private void InitializeComponent(  ):
      this-object:ReportPreview = new System.Windows.Forms.TextBox().
      this-object:button1 = new System.Windows.Forms.Button().
      this-object:SuspendLayout().
      this-object:ReportPreview:Location = new System.Drawing.Point(4, 3).
      this-object:ReportPreview:Multiline = true.
      this-object:ReportPreview:Name = "ReportPreview".
      this-object:ReportPreview:Size = new System.Drawing.Size(693, 414).
      this-object:ReportPreview:TabIndex = 0.
      this-object:ReportPreview:Text = "w~r~nw~r~n".
      this-object:button1:Location = new System.Drawing.Point(615, 438).
      this-object:button1:Name = "button1".
      this-object:button1:Size = new System.Drawing.Size(75, 23).
      this-object:button1:TabIndex = 1.
      this-object:button1:Text = "Ok".
      this-object:button1:UseCompatibleTextRendering = true.
      this-object:button1:UseVisualStyleBackColor = true.
      this-object:button1:Click:Subscribe(this-object:button1_Click).
      this-object:ClientSize = new System.Drawing.Size(702, 473).
      this-object:Controls:Add(this-object:button1).
      this-object:Controls:Add(this-object:ReportPreview).
      this-object:Name = "rprev".
      this-object:ShowIcon = false.
      this-object:Text = "rprev".
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   destructor public rprev ( ):
   end destructor.
end class.
