define variable Mext-sys as integer no-undo init ?.
define variable mdb-num-local as integer no-undo.
run gbl/getdbnum.p (output mdb-num-local).
{&CommentStartNoClass}
method private integer   getextsys
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function  getExtSys returns integer 
{utl\comment.i} */
():
   define buffer ext-system      for ext-system.
   define buffer ext-system-attr for ext-system-attr.
   Mext-sys = ?.
   block-sys-obj:
   for each ext-system where ext-system.esys-type eq {&bef-openxml-type-is_diadoc}
                         and ext-system.db-num    eq mdb-num-local
   no-lock:
       find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                    and ext-system-attr.esys-id eq ext-system.esys-id
                                    and ext-system-attr.esya-attr-code eq {&attr-esys-obj}
                                    
       no-lock no-error.
       if     available ext-system-attr
          and           ext-system-attr.esya-attr-value eq v-cntxt-obj-type + string(v-cntxt-obj-code)
       then do:
          Mext-sys = ext-system-attr.esys-id.
          leave block-sys-obj.
       end.                            
   end.
   if Mext-sys eq ? 
   then do:
      block-sys-host:
      for each ext-system where ext-system.esys-type eq {&bef-openxml-type-is_diadoc}
                            and ext-system.db-num    eq mdb-num-local
      no-lock:
          find first ext-system-attr where ext-system-attr.db-num  eq ext-system.db-num
                                       and ext-system-attr.esys-id eq ext-system.esys-id
                                       and ext-system-attr.esya-attr-code eq {&attr-esys-host-code}
                                       
          no-lock no-error.
          if     available ext-system-attr
             and           ext-system-attr.esya-attr-value eq string(v-cntxt-host-code-obj)
          then do:
             Mext-sys = ext-system-attr.esys-id.
             leave block-sys-host.
          end.                            
      end.
   end.
   return Mext-sys.
end.  

{&CommentStartNoClass}
method private character  getextattr
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function  getExtAttr returns character
{utl\comment.i} */
(input icode as character ):
   define variable oValue as character no-undo.
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.
   get-key-value section "ProxyServ" key icode value oValue.
   if oValue eq ?
   then do:
   
      if Mext-sys eq ?
      then
         getExtSys ().  
      find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                      and ext-system.esys-id eq Mext-sys no-error.
      if available ext-system
      then do:
      &scop proc-name ext-system-attr-value
       {&run_proc_attr-lib}
         (ext-system.esys-id,
          mdb-num-local,
          icode,
          output oValue,
          output vtype) no-error.
       end.
   end.
  
   return if oValue eq ? then "" else oValue .
end.

{&CommentStartNoClass}
method private character  Setextattr
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function  SetExtAttr returns character
{utl\comment.i} */
(input icode   as character,
 input iValue  as character):
   define variable vtype as character no-undo.
   define buffer ext-system for ext-system.  
   if Mext-sys eq ?
   then
      getExtSys ().  
   find first ext-system no-lock where ext-system.db-num  eq mdb-num-local
                                   and ext-system.esys-id eq Mext-sys no-error.
   if available ext-system
   then do:
   &scop proc-name ext-system-attr-write
    {&run_proc_attr-lib}
      (ext-system.esys-id,
       mdb-num-local,
       icode,
       iValue) no-error.
    end.
    
/*   return oValue.*/
end.
