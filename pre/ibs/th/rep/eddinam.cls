using Progress.Lang.*.
using ibs.th.ref.sobj.sUserFrame.
block-level on error undo, throw.
class ibs.th.rep.eddinam inherits sUserFrame:
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable TogDet as System.Windows.Forms.CheckBox no-undo.
   define private variable TogOper as System.Windows.Forms.CheckBox no-undo.
   constructor public eddinam  (  ):
      super().
      namereport = "Движение денежных средств.".
      procname   = "Old_proc".
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   method private void InitializeComponent(  ):
      this-object:TogDet = new System.Windows.Forms.CheckBox().
      this-object:TogOper = new System.Windows.Forms.CheckBox().
      this-object:SuspendLayout().
      this-object:TogDet:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:TogDet:Location = new System.Drawing.Point(23, 13).
      this-object:TogDet:Name = "TogDet".
      this-object:TogDet:Size = new System.Drawing.Size(242, 24).
      this-object:TogDet:TabIndex = 0.
      this-object:TogDet:Text = "С детализацией по объектам".
      this-object:TogDet:UseCompatibleTextRendering = true.
      this-object:TogDet:UseVisualStyleBackColor = true.
      this-object:TogOper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:TogOper:Location = new System.Drawing.Point(23, 43).
      this-object:TogOper:Name = "TogOper".
      this-object:TogOper:Size = new System.Drawing.Size(150, 24).
      this-object:TogOper:TabIndex = 1.
      this-object:TogOper:Text = "Оперативный".
      this-object:TogOper:UseCompatibleTextRendering = true.
      this-object:TogOper:UseVisualStyleBackColor = true.
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:TogOper).
      this-object:Controls:Add(this-object:TogDet).
      this-object:Name = "eddinam".
      this-object:Size = new System.Drawing.Size(290, 156).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   destructor public eddinam  ( ):
   end destructor.
   method override public void My-var ():
      assign
         paramobj:ReportHeader = "С детализацией по объектам"
      .
   end.
   method override public void my-report ():
      run rep/r-ddinam.p
       (input paramobj
       ,input ''
       ,input integer('0':U)
       ,input 0
       ,input 0
       ,input ""
       ,input togdet:Checked
       ,input TOGoper:Checked
       ,input yes
       ,input yes
       ,input ''
         ) no-error.
   end.
   method override public void my-params (p-action as character):
   end method.
end class.
