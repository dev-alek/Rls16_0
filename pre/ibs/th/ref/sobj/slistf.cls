using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class ibs.th.ref.sobj.sListF inherits UserControl:
   define private variable components as System.ComponentModel.IContainer no-undo.
   method public void op-br():
   end.
   method public void Save-table():
   end.
   constructor public sListF (  ):
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   method private void InitializeComponent(  ):
      this-object:SuspendLayout().
      this-object:Name = "sListF".
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   destructor public sListF ( ):
   end destructor.
end class.
