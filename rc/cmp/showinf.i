/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Показать информацию о текущем модуле

*/
&if "{1}" eq "class" 
&then
this-object:KeyPreview = true.
this-object:KeyDown:Subscribe(this-object:obj_KeyDown).

catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
end method.
&endif

&if "{1}" ne "class" 
&then
procedure proc-alt-shift-f2:
&else
method void proc-alt-shift-f2 ():
&endif   
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.

&if "{1}" eq "class" 
&then
method void proc-alt-shift-f3 ():
   define variable vdebugalert   as logical no-undo .
   assign
      vdebugalert = session:debug-alert
      session:debug-alert = yes
   .
message program-name( 1 ) skip( 1 )
          vss-revision                  skip( 0 )
          vss-author                    skip( 0 )
          vss-date                      skip( 0 )
          vss-workfile                  skip( 0 )
          vss-archive                   skip( 1 )
          vss-description               skip( 1 )
  view-as alert-box title "Текущая программа".
  
  session:debug-alert = vdebugalert.
  
&else
procedure proc-alt-shift-f3:
   
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
&endif
end.

define variable v-inform-launched as logical no-undo initial false .

&if "{1}" eq "class" 
&then
method void proc-alt-shift-f4 ():
&else
procedure proc-alt-shift-f4:
  
  define variable v-action as character no-undo .

  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
&endif
end.


&if "{1}" eq "class" 
&then
method void proc-alt-f1 ():

&else
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
&endif 
end .


&if "{1}" eq "class" 
&then

method private void obj_KeyDown( input sender as System.Object, input e as System.Windows.Forms.KeyEventArgs ):
      if   e:KeyCode = System.Windows.Forms.Keys:F3 and e:Shift and e:Alt 
      then do:
          proc-alt-shift-f3 ().
      end.
      else if   e:KeyCode = System.Windows.Forms.Keys:F2 and e:Shift and e:Alt 
      then do:
          proc-alt-shift-f2 ().
      end.     
/*      return.*/
end method.
method private void End_obj_KeyDown(): 

&else
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.


on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.

on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.

on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.

&endif


/* $Workfile$   E n d */
