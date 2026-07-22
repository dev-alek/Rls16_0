 
 /*------------------------------------------------------------------------
    File        : usertable
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : svvtm
    Created     : Tue Nov 19 21:04:13 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/
USING Progress.Lang.*.
using ibs.th.ref.sobj.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.sobj.usertable :
    
 { cmp/str-glbl.i class}
 { gbl/getcntxt.i def }
 { cmp/library.i class }
 { cmp/obj-list.i class } /* obj-list s*/
 {rep/tt-user.i} 

define variable v-user-table-name as character no-undo .
define variable v-user-table      as character no-undo .
define variable v-table           as character no-undo .
define buffer buf_tt-user-account2 for tt-user-account2  .

DEFINE VARIABLE mform  AS CLASS ibs.th.ref.sobj.userhist no-undo.
               
define property query_user-table as handle no-undo 
  public get.
  public set.
  
define property query_user-account as handle no-undo 
  public get.
  public set.                  
  
constructor public usertable (iform as class ibs.th.ref.sobj.userhist ):

super().
mform = iform.
  create query query_user-table.                    
               query_user-table:set-buffers(buffer tt-objects:HANDLE). 
               query_user-table:query-prepare("FOR EACH tt-objects BY tt-objects.name_ ").
               query_user-table:query-open.

  create query query_user-account.                    
               query_user-account:set-buffers(buffer tt-user-account:HANDLE). 
               query_user-account:query-prepare("FOR EACH tt-user-account BY tt-user-account.user_name ").
               query_user-account:query-open.
               
end constructor.

METHOD public void init_tt(): 

/* EMPTY TEMP-TABLE tt-user-account. */
mform:ParamObj:get-obj-list(output table obj-list).
for each user-obj  ,
      each ub.user-account no-lock where ub.user-account.user-id = user-obj.user-id:
         
         find first tt-user-account where tt-user-account.user-id_ = ub.user-account.user-id and tt-user-account.flg2 = yes  no-error.
            if  not AVAILABLE tt-user-account then do:  
            /*MESSAGE  user-account.last-name VIEW-AS ALERT-BOX. */                
            create tt-user-account .
            assign
            tt-user-account.db-num    = user-obj.db-num /* obj-code*/ 
            tt-user-account.user-id_  = ub.user-account.user-id
            tt-user-account.user_name = /*"ID: " + ub.user-account.user-id 
                              + " ФИО: " + */
                              user-account.last-name 
                              + " "      + user-account.first-name 
                              + " "      + user-account.second-name
            tt-user-account.flg2 = yes                     
            .
         end.
end.

 
if mform:ParamObj:x-SelectObject <> "firm" then do:
 
 for each tt-user-account  :
    find first obj-list where tt-user-account.db-num = obj-list.db-num no-error.
      if not AVAILABLE obj-list then 
         do:
            delete tt-user-account .
         end.
END.
END. 


 EMPTY TEMP-TABLE tt-objects.  
 
for each c-user-log no-lock 
    where c-user-log.corr-date >= mform:ParamObj:x-Date-Start and c-user-log.corr-date <= mform:ParamObj:x-Date-End 
    by c-user-log.head-table :
    v-table = c-user-log.head-table .
    if v-table begins "c-" and v-table <> {&table_c-usr-hist} and v-table <> {&table_c-plc-hist}  
     then  do:
         v-user-table = replace(v-table,"c-","").
     end.
     else v-user-table = v-table .    
     find first tt-objects where tt-objects.table_ = v-user-table and tt-objects.flg2 =  1 no-error .
     if not AVAILABLE (tt-objects) then 
        do:
           { gbl/tblnmusr.i
            v-user-table
            v-user-table-name
          } 
        create tt-objects .
            assign
            tt-objects.table_ = v-user-table 
            tt-objects.name_  = v-user-table-name 
            tt-objects.flg2 =  1  
            .
     end.
 
end. 

for each tt-objects  :
    find first tt-objects2 where tt-objects2.table_ = tt-objects.table_ and tt-objects2.flg = yes no-error .
    if AVAILABLE (tt-objects2) then  
    do:
            assign
            tt-objects.flg =  yes  
            .
     end.
end.

 empty TEMP-TABLE tt-objects2. 
  
for each tt-objects  :
     create tt-objects2 .
     buffer-copy tt-objects to tt-objects2 .
end.
            
END METHOD.
    
METHOD public void mark_user():
    tt-user-account.flg = not tt-user-account.flg .
END METHOD.

METHOD public void mark_user_all():
      for each tt-user-account  :
            /*tt-user-account.flg = not tt-user-account.flg . */
            tt-user-account.flg = yes .             
      end.
END METHOD.

METHOD public void mark_table():
    tt-objects.flg = not tt-objects.flg .
    for each tt-objects2 where tt-objects.table_ =  tt-objects2.table_ :    
    tt-objects2.flg = not tt-objects2.flg .
    end.

END METHOD.

METHOD public void mark_table_all():
    
    for each tt-objects  :    
    /*tt-objects.flg = not tt-objects.flg . */
    tt-objects.flg = yes.    
    end.
    
    for each tt-objects2  :    
    /* tt-objects2.flg = not tt-objects2.flg . */
    tt-objects2.flg = yes . 
    end. 
 
END METHOD.


METHOD public void my_report():
    
empty TEMP-TABLE tt-user-account2. 
for each tt-user-account  :
     create tt-user-account2 .
     buffer-copy tt-user-account to tt-user-account2 .
end.
 
find first tt-user-account where tt-user-account.flg = yes no-error. /* если нет помеченных записей, то все, 
                                                                       если есть помеченные, то отправляем только их*/
if AVAILABLE tt-user-account then do: 
  for each tt-user-account  :
      if   tt-user-account.flg = no then delete tt-user-account .
  end.
end.

empty TEMP-TABLE tt-objects2. 
for each tt-objects  :
     create tt-objects2 .
     buffer-copy tt-objects to tt-objects2 .
end.
       
find first tt-objects where tt-objects.flg = yes no-error.
if AVAILABLE tt-objects then do: 
   for each tt-objects  :
     if   tt-objects.flg = no then delete tt-objects .
   end.
end.

run rep/r-hist-sysadm.p 
         (input mform:ParamObj:my-handle,  
          input mform:ParamObj:x-Date-Start,
          input mform:ParamObj:x-Date-End,
          input table tt-user-account BY-REFERENCE,
          input table tt-objects      BY-REFERENCE ) .


empty TEMP-TABLE tt-user-account.
for each tt-user-account2:
     create tt-user-account .
     buffer-copy tt-user-account2 to tt-user-account .
end.

empty TEMP-TABLE tt-objects.
for each tt-objects2:
     create tt-objects.
     buffer-copy tt-objects2 to tt-objects .
end.

/* empty TEMP-TABLE tt-user-account2. */
            
END METHOD.

END CLASS.