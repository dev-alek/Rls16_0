using Progress.Lang.*.
using Progress.Windows.UserControl.
block-level on error undo, throw.
class ibs.th.ref.sobj.sUserFrame inherits UserControl:
   define private variable components as System.ComponentModel.IContainer no-undo.
   define property mTrgGlb as class ibs.th.ref.sobj.dReportTrg no-undo
   get.
   set.
   define public property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.
   define public property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   constructor public sUserFrame (  ):
      super().
      InitializeComponent().
      this-object:ComponentsCollection:ADD(this-object:components).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end constructor.
   method private void InitializeComponent(  ):
      this-object:SuspendLayout().
      this-object:Name = "sUserFrame".
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
   destructor public sUserFrame ( ):
   end destructor.
   define public variable namereport as character no-undo.
   define public variable procname   as character no-undo.
   method public void My-var ():  end.
   method public void my-params (iType as character ): end.
   method public logical report-to-ach (itest as logical ):
      if itest
      then
         return no.
   end.
   method public character  verify-date():
   end.
   method public void my-report ( ): end.
   method public void my-secected ( ): end.
end class.
