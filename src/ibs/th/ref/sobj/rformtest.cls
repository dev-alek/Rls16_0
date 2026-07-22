 
 /*------------------------------------------------------------------------
    File        : rformtest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Nady
    Created     : Mon Mar 23 02:22:36 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.ref.sobj.sUserFrame.

block-level on error undo, throw.

class ibs.th.ref.sobj.rformtest inherits sUserFrame: 
   
   define private variable components as System.ComponentModel.IContainer no-undo.
   define private variable MessUser as System.Windows.Forms.Label no-undo.

      
   constructor public rformtest (  ):
      
      
      super().
      namereport = "עוסעמגאÿ פמנלא.".
      procname   = "Old_proc".
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.

   end constructor.

   method private void InitializeComponent(  ):
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:MessUser = new System.Windows.Forms.Label().
      this-object:SuspendLayout().
      /*  */
      /* MessUser */
      /*  */
      this-object:MessUser:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(26.25), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:MessUser:Location = new System.Drawing.Point(17, 16).
      this-object:MessUser:Name = "MessUser".
      this-object:MessUser:Size = new System.Drawing.Size(263, 121).
      this-object:MessUser:TabIndex = 0.
      this-object:MessUser:Text = "Çהוסü המכזול בûעü פנאלו ןמכüחמגאעוכÿ".
      this-object:MessUser:UseCompatibleTextRendering = true.
      /*  */
      /* rformtest */
      /*  */
      this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
      this-object:Controls:Add(this-object:MessUser).
      this-object:Name = "rformtest".
      this-object:Size = new System.Drawing.Size(290, 156).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.

   destructor public rformtest ( ):

   end destructor.
   
  method override public void My-var ():
    message "method override public void My-var"
    view-as alert-box.
   end.
   
   
   

end class.