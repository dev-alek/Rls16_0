 
 /*------------------------------------------------------------------------
    File        : sListF
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sat Apr 04 21:06:49 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.UserControl.

block-level on error undo, throw.

class ibs.th.ref.sobj.sListF inherits UserControl: 
   
   define private variable components as System.ComponentModel.IContainer no-undo.

   method public void op-br():
   end.
   
   method public void Save-table(): /*read-table */
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
      
      /* NOTE: The following method is automatically generated.
      
      We strongly suggest that the contents of this method only be modified using the
      Visual Designer to avoid any incompatible modifications.
      
      Modifying the contents of this method using a code editor will invalidate any support for this file. */
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