block-level on error undo, throw.
/*

Чистка БД. Финансовые док-ты и обязательства.

Автор: Ростовцев Александр
Дата создания: 08/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/08/25

*/

&scop Tables Финансовые док-ты и обязательства с историей
/*&scop Tables fin-ob ~    */
/*fin-connect ~            */
/*c-fin-connect ~          */
/*fin-ob-attr ~            */
/*fin-ob-tax ~             */
/*fin-ob-tax-attr ~        */
/*fin-gds-part ~           */
/*fin-gds-part-attr ~      */
/*fin-ob-trn ~             */
/*c-fin-ob ~               */
/*c-fin-ob-attr ~          */
/*c-fin-ob-tax ~           */
/*c-fin-gds-part ~         */
/*fin-ob-before ~          */
/*fin-ob-tax-before ~      */
/*fin-doc ~                */
/*fin-doc-attr ~           */
/*fin-doc-tax ~            */
/*fin-doc-tax-attr ~       */
/*fin-doc-obj ~            */
/*c-fin-doc ~              */
/*c-fin-doc-attr ~         */
/*c-fin-doc-tax ~          */
/*fin-statement ~          */
/*fin-statement-attr ~     */
/*fin-statement-line ~     */
/*fin-statement-line-attr ~*/
/*c-fin-statement ~        */
/*c-fin-statement-attr ~   */
/*c-fin-statement-line     */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 08/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00090000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/0009000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define variable is-del as logical   no-undo .

define buffer trn-doc             for ub.trn-doc.
define buffer fin-ob              for ub.fin-ob.
define buffer buf_fin-ob          for ub.fin-ob.
define buffer fin-ob-before       for ub.fin-ob-before.
define buffer buf_fin-ob-before   for ub.fin-ob-before.
define buffer fin-doc             for ub.fin-doc.
define buffer buf_fin-doc         for ub.fin-doc.
define buffer fin-statement       for ub.fin-statement.
define buffer buf_fin-statement   for ub.fin-statement.

DEFINE temp-table temp-del-yes no-undo
  field host-code  as integer
  field doc-code  as character
  field type  as integer
  INDEX pi IS PRIMARY host-code doc-code type
.

DEFINE temp-table temp-del-no no-undo
  field host-code  as integer
  field doc-code   as character
  field type       as integer
  INDEX pi IS PRIMARY host-code doc-code type
.

DEFINE temp-table temp-cur no-undo
  field host-code  as integer
  field doc-code  as character
  field type  as integer
  INDEX pi IS PRIMARY host-code doc-code type
.

on delete of ub.fin-ob             override do: end.
on delete of ub.fin-ob-before      override do: end.
on delete of ub.fin-doc            override do: end.
on delete of ub.fin-statement      override do: end.

for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
for each fin-ob no-lock where
         fin-ob.host-code = buf_clients.host-code
     and fin-ob.doc-date  < vardate-actual-docs
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  assign is-del = no .
  if fin-ob.fact-date < vardate-actual-docs then do:
    assign is-del = yes .
    if fin-ob.con-stat < 2 then
    do:
      if fin-ob.con-stat = 0 /* нет связей по платежам */ then
        assign is-del = yes .
      else assign is-del = no .
    end.
    else do:
      run CheckDel ( input fin-ob.host-code, input fin-ob.doc-code, input 0 , output is-del ) .
      if is-del = yes then do:
        for each temp-cur :
          find first temp-del-yes where
                     temp-del-yes.host-code = temp-cur.host-code and
                     temp-del-yes.doc-code  = temp-cur.doc-code  and
                     temp-del-yes.type      = temp-cur.type no-error .
          if not available temp-del-yes then do:
             create temp-del-yes.
             BUFFER-COPY temp-cur TO temp-del-yes no-error .
          end.
          delete temp-cur .
        end.
      end.
      else do:
        for each temp-cur :
          find first temp-del-no where
                     temp-del-no.host-code = temp-cur.host-code and
                     temp-del-no.doc-code  = temp-cur.doc-code  and
                     temp-del-no.type      = temp-cur.type no-error .
          if not available temp-del-no then do:
            create temp-del-no.
            BUFFER-COPY temp-cur TO temp-del-no no-error .
          end.
          delete temp-cur .
        end.
      end.
    end.
  end.
  if is-del then do:
    run cleanFinOb in this-procedure.
    { cleandb/delmainrec.i fin-ob}
  end.
end.

for each fin-ob-before no-lock where
         fin-ob-before.host-code = buf_clients.host-code
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  if fin-ob-before.status_ = {&fin-fact} or fin-ob-before.doc-code <> ""  then
  do:
    find first trn-doc no-lock where trn-doc.doc-code = fin-ob-before.trn-doc-code no-error .
    if not available trn-doc then
    do:
      run cleanFinObBefore in this-procedure.
      { cleandb/delmainrec.i fin-ob-before}
    end.
  end.
end.

for each fin-doc no-lock where
         fin-doc.host-code = buf_clients.host-code
     and fin-doc.doc-date  < vardate-actual-docs
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  assign is-del = no .
  if fin-doc.fact-date < vardate-actual-docs then do:
    if fin-doc.con-stat < 2 then assign is-del = no .
    else do:
      find first temp-del-yes where 
                 temp-del-yes.host-code = fin-doc.host-code
              and temp-del-yes.doc-code  = string(fin-doc.fin-doc-code)
              and temp-del-yes.type      = 1
      no-error .
      if available temp-del-yes then is-del = yes .
    end.
  end.
  if is-del then do :
    run cleanFinDoc in this-procedure.
    { cleandb/delmainrec.i fin-doc}
  end.
end.

for each fin-statement no-lock where
         fin-statement.host-code = buf_clients.host-code
     and fin-statement.doc-date  < vardate-actual-docs
     and fin-statement.fact-date < vardate-actual-docs
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  run cleanFinStatement in this-procedure.
  { cleandb/delmainrec.i fin-statement}
end.  
end.  /* for first buf_clients */

{cleandb/setresval.i}
return vResult.


procedure CheckDel :
  do on error undo, return error return-value :
    define input  parameter p-host-code as integer   no-undo .
    define input  parameter p-doc-code  as character no-undo .
    define input  parameter p-type      as integer   no-undo .
    define output parameter p-is-del    as logical   no-undo .

    define buffer bf_fin-ob   for ub.fin-ob .
    define buffer bf_fin-doc  for ub.fin-doc .
    define buffer fin-connect for ub.fin-connect.
    
    assign p-is-del = yes .

    find first temp-cur where
      temp-cur.host-code = p-host-code and
      temp-cur.doc-code  = p-doc-code  and
      temp-cur.type      = p-type     no-error .
      if  not available  temp-cur then do:
          create temp-cur .
          assign
            temp-cur.host-code = p-host-code
            temp-cur.doc-code  = p-doc-code
            temp-cur.type      = p-type
          .
    end.
    find first temp-del-yes
      where temp-del-yes.host-code = p-host-code
        and temp-del-yes.doc-code  = p-doc-code
        and temp-del-yes.type      = p-type
    no-error .
    if available temp-del-yes then do:
      assign p-is-del = yes .
      return .
    end.

    find first temp-del-no
      where temp-del-no.host-code = p-host-code
        and temp-del-no.doc-code  = p-doc-code
        and temp-del-no.type      = p-type
    no-error .
    if available temp-del-no then do:
      assign p-is-del = no .
      return .
    end.

    if p-type = 0 then do: /* ФО */
      for each fin-connect no-lock
        where fin-connect.host-code   = p-host-code
          and fin-connect.fin-ob-code = p-doc-code
        :
        find first bf_fin-doc no-lock
          where bf_fin-doc.host-code    = fin-connect.host-code
            and bf_fin-doc.fin-doc-code = fin-connect.fin-doc-code
        no-error .
        if available bf_fin-doc then do:
          if ( bf_fin-doc.con-stat = 1  ) or bf_fin-doc.fact-date >= vardate-actual-docs then do:
            assign p-is-del = no .
            return  .
          end.
          else do:
            find first temp-cur where
                       temp-cur.host-code = p-host-code and
                       temp-cur.doc-code  = string(bf_fin-doc.fin-doc-code) and
                       temp-cur.type = 1
                       no-error .
                      if not available temp-cur then do:
                        run CheckDel ( input p-host-code, input bf_fin-doc.fin-doc-code, input 1 , output p-is-del ) .
                        if p-is-del = no then return .
                      end.
          end.
        end.
      end.
    end.
    else do: /* плат 1 */
      for each fin-connect no-lock
        where fin-connect.host-code   = p-host-code
          and fin-connect.fin-doc-code = integer (p-doc-code)
        :
        find first bf_fin-ob no-lock
          where bf_fin-ob.host-code = fin-connect.host-code
            and bf_fin-ob.doc-code  = fin-connect.fin-ob-code
        no-error .
        if available bf_fin-ob then do:
          if ( bf_fin-ob.con-stat = 1 and bf_fin-ob.fact-date < vardate-actual-docs ) or bf_fin-ob.fact-date >= vardate-actual-docs then do:
            assign p-is-del = no .
            return .
          end.
          else do:
            find first temp-cur where
                       temp-cur.host-code = p-host-code and
                       temp-cur.doc-code  = bf_fin-ob.doc-code and
                       temp-cur.type = 0
                       no-error .
                      if not available temp-cur then do:
                        run CheckDel ( input p-host-code, input bf_fin-ob.doc-code, input 0 , output p-is-del ) .
                        if p-is-del = no then return .
                      end.
          end.
        end.
      end.
    end.
  end.
end procedure. /* CheckDel */

procedure cleanFinOb:
    define buffer fin-connect         for ub.fin-connect  .
    define buffer c-fin-connect       for ub.c-fin-connect.
    on delete of ub.fin-connect override do: end.
    on delete of ub.c-fin-connect override do: end.
  
    for each fin-connect no-lock
       where fin-connect.host-code   = fin-ob.host-code
         and fin-connect.fin-ob-code = fin-ob.doc-code
    :
      for each c-fin-connect no-lock
         where c-fin-connect.host-code    = fin-connect.host-code
           and c-fin-connect.connect-code = fin-connect.connect-code
      :
        delete fin-connect.
        vDeleted = vDeleted + 1.
      end.
      delete fin-connect.
      vDeleted = vDeleted + 1.
    end.
    {cleandb/dellinkrec.i
      fin-ob-attr
      "where fin-ob-attr.host-code = fin-ob.host-code
         and fin-ob-attr.doc-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      fin-ob-tax
      "where fin-ob-tax.host-code = fin-ob.host-code
         and fin-ob-tax.doc-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      fin-ob-tax-attr
      "where fin-ob-tax-attr.host-code = fin-ob.host-code
         and fin-ob-tax-attr.doc-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      fin-gds-part
      "where fin-gds-part.host-code = fin-ob.host-code
         and fin-gds-part.fin-ob-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      fin-gds-part-attr
      "where fin-gds-part-attr.host-code = fin-ob.host-code
         and fin-gds-part-attr.fin-ob-code  = fin-ob.doc-code"
    }

    define buffer fin-ob-trn          for ub.fin-ob-trn.
    on delete of ub.fin-ob-trn override do: end.
    for each fin-ob-trn no-lock
       where fin-ob-trn.host-code = fin-ob.host-code
         and fin-ob-trn.doc-code  = fin-ob.doc-code
    :
      find first trn-doc no-lock where trn-doc.doc-code = fin-ob-trn.trn-doc-code no-error .
      if available trn-doc then next .

      delete fin-ob-trn.
      vDeleted = vDeleted + 1.
    end.

    {cleandb/dellinkrec.i
      c-fin-ob
      "where c-fin-ob.host-code = fin-ob.host-code
         and c-fin-ob.doc-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      c-fin-ob-attr
      "where c-fin-ob-attr.host-code = fin-ob.host-code
         and c-fin-ob-attr.doc-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      c-fin-ob-tax
      "where c-fin-ob-tax.host-code = fin-ob.host-code
         and c-fin-ob-tax.doc-code  = fin-ob.doc-code"
    }
    {cleandb/dellinkrec.i
      c-fin-gds-part
      "where c-fin-gds-part.host-code = fin-ob.host-code
         and c-fin-gds-part.fin-ob-code  = fin-ob.doc-code"
    }
end procedure.

procedure cleanFinObBefore:
  {cleandb/dellinkrec.i 
    fin-ob-tax-before  
    " where fin-ob-tax-before.host-code   = fin-ob-before.host-code
        and fin-ob-tax-before.before-code = fin-ob-before.before-code"
  }
end procedure.

procedure cleanFinDoc:
  {cleandb/dellinkrec.i 
    fin-doc-attr  
    "where fin-doc-attr.host-code    = fin-doc.host-code
       and fin-doc-attr.fin-doc-code = fin-doc.fin-doc-code
  }
  {cleandb/dellinkrec.i 
    fin-doc-tax  
    "where fin-doc-tax.host-code    = fin-doc.host-code
       and fin-doc-tax.fin-doc-code = fin-doc.fin-doc-code
  }
  {cleandb/dellinkrec.i 
    fin-doc-tax-attr  
    "where fin-doc-tax-attr.host-code    = fin-doc.host-code
       and fin-doc-tax-attr.fin-doc-code = fin-doc.fin-doc-code
  }
  {cleandb/dellinkrec.i 
    fin-doc-obj  
    "where fin-doc-obj.host-code    = fin-doc.host-code
       and fin-doc-obj.fin-doc-code = fin-doc.fin-doc-code
  }
  {cleandb/dellinkrec.i 
    c-fin-doc  
    "where c-fin-doc.host-code    = fin-doc.host-code
       and c-fin-doc.fin-doc-code = fin-doc.fin-doc-code
  }
  {cleandb/dellinkrec.i 
    c-fin-doc-attr  
    "where c-fin-doc-attr.host-code    = fin-doc.host-code
       and c-fin-doc-attr.fin-doc-code = fin-doc.fin-doc-code
  }
  {cleandb/dellinkrec.i 
    c-fin-doc-tax  
    "where c-fin-doc-tax.host-code    = fin-doc.host-code
       and c-fin-doc-tax.fin-doc-code = fin-doc.fin-doc-code
  }
end procedure.

procedure cleanFinStatement:
  {cleandb/dellinkrec.i 
    fin-statement-attr  
    "where fin-statement-attr.host-code = fin-statement.host-code
       and fin-statement-attr.sttm-code = fin-statement.sttm-code
  }
  {cleandb/dellinkrec.i 
    fin-statement-line  
    "where fin-statement-line.host-code = fin-statement.host-code
       and fin-statement-line.sttm-code = fin-statement.sttm-code
  }
  {cleandb/dellinkrec.i 
    fin-statement-line-attr  
    "where fin-statement-line-attr.host-code = fin-statement.host-code
       and fin-statement-line-attr.sttm-code = fin-statement.sttm-code
  }
  {cleandb/dellinkrec.i 
    c-fin-statement  
    "where c-fin-statement.host-code = fin-statement.host-code
       and c-fin-statement.sttm-code = fin-statement.sttm-code
  }
  {cleandb/dellinkrec.i 
    c-fin-statement-attr  
    "where c-fin-statement-attr.host-code = fin-statement.host-code
       and c-fin-statement-attr.sttm-code = fin-statement.sttm-code
  }
  {cleandb/dellinkrec.i 
    c-fin-statement-line  
    "where c-fin-statement-line.host-code = fin-statement.host-code
       and c-fin-statement-line.sttm-code = fin-statement.sttm-code
  }
end procedure.