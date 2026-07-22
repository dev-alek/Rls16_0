/*
Создание тригеров для формы и datatimepiker
{gbl\ed_date_cls.i this-object} включает тригера alt+ctrl+  на форме
{gbl\ed_date_cls.i this-object:dateTimePicker1 dateTimePicker2} включает тригера ctrl+  на dateTimePicker1 и dateTimePicker2
{gbl\ed_date_cls.i this-object:dateTimePicker1 This-object this-object:dateTimePicker2} включает тригера alt+ctrl+  на форме
                                                              и включает тригера ctrl+  на dateTimePicker1 и dateTimePicker2
Данный инклюдник надо вставлять только один раз перед блоком catch e as Progress.Lang.Error в методе InitializeComponent

Пример:
method private void InitializeComponent ( ):
   
   ...
   
   {gbl\ed_date_cls.i this-object:dateTimePicker1 This-object this-object:dateTimePicker2}
   catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
end method.
                                                            
$Revision$
$Author$
$Date$
$Workfile$
$Archive$
*/
&if "{1}" ne "this-object" &then
/*
триггер обработки клавиш на datatimepiker
*/
&endif
&if "{1}" ne "this-object" &then

{1}:KeyDown:Subscribe(this-object:date_KeyDown).
&endif 

&if "{2}" ne "" &then
&SCOPED-DEFINE  gdate_KeyDown yes
{gbl\ed_date_cls.i {2} {3} {4} {5} {6} {7} {8} {9} {10} {11} {12} {13} {14} }
&UNDEFINE gdate_KeyDown
&endif

&if "{1}" eq "this-object" &then
/*
триггер обработки клавиш на форме
*/
{cmp\showinf.i class }
&endif

&if defined(gdate_KeyDown) eq 0 &then 
&glob gdate_KeyDown yes 
catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
end method.

method private void date_KeyDown( input sender as System.Object, input e as System.Windows.Forms.KeyEventArgs ):
   define variable vdate as System.Windows.Forms.DateTimePicker no-undo.
   define variable v-curr-sv-date as date no-undo .
   define variable v-new-sv-date  as date no-undo .
    
   if   e:KeyCode = System.Windows.Forms.Keys:D and e:Control  
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      run gbl/getcurdt.p
         (output v-curr-sv-date
      ) .
      vdate:value = v-curr-sv-date.
          
   end.
   else if   e:KeyCode = System.Windows.Forms.Keys:B and e:Control  
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      
      v-curr-sv-date = vdate:value .
      if v-curr-sv-date = ?
      then do:
         run gbl/getcurdt.p
            (output v-curr-sv-date
         ) .
      end.
      if v-curr-sv-date <> ?
      then do:
         assign
            v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
            vdate:value = v-new-sv-date
         .
      end.
   end.
   else if   e:KeyCode = System.Windows.Forms.Keys:E and e:Control  
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      v-curr-sv-date = vdate:value.
      if v-curr-sv-date = ?
      then do:
         run gbl/getcurdt.p
            (output v-curr-sv-date
         ) .
      end.
      if v-curr-sv-date <> ?
      then do:
         run gbl/lastdate.p
            (input  v-curr-sv-date
            ,output v-new-sv-date
         ).
         vdate:value = v-new-sv-date.
      end.
   end.
   else if   e:KeyCode = System.Windows.Forms.Keys:F and e:Control  
   then do:
      vdate = cast(sender ,System.Windows.Forms.DateTimePicker).
      define variable v-description   as character no-undo .
      define variable v-ok            as logical no-undo.
/*      v-description = vdate:*/

      v-curr-sv-date = vdate:value.
      if v-curr-sv-date = ?
      then do:
         run gbl/getcurdt.p
            (output v-curr-sv-date
         ) .
      end.
      if v-curr-sv-date <> ?
      then do:
         run gbl/d-inpday.w
            (input ?                     /* h-callback    */
            ,input "Выбор даты"          /* p-title       */
            ,input v-description         /* p-description */
            ,input ""                    /* p-mode        */
            ,input-output v-curr-sv-date /* p-date        */
            ,output v-ok                 /* p-ok          */
         ).
         if v-ok = true
         then do:
            vdate:value = v-curr-sv-date .
         end.
      end.
   end.
end method.

method private void End_date_KeyDown(): 

&endif