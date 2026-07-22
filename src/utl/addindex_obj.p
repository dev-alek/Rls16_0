block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: addindex_obj.p $
$Archive: utl/addindex_obj.p $

Добавление индексов по    Host-code obj-type obj-code

Автор: Чернова Светлана Александровна
Дата создания: 12/12/08
Author: Svetlana Chernova
Creation date: 12/12/08

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: addindex_obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/addindex_obj.p $":U .
define variable vss-description as character no-undo init "Все таблицы с Host-code obj-type obj-code".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
define buffer buf-_Field for ub._Field  .

define temp-table temp-t no-undo
field nametable as character
field namefield as character
field namefield2 as character
index pi nametable namefield
.

define temp-table temp-i no-undo
field nametable as character
field namefield as character
field nameindex as character
index pi nametable namefield nameindex
.

define stream outstrim.
output stream outstrim to value("c:\ttable.df") .

 run proc-obj.
 run proc-host.
 run proc-host-other.
 run proc-obj-other.


 /* run proc-cli. */
output stream outstrim close.


/*-----------------------------------------------------------------------------------------------------*/
procedure proc-obj :

  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.

define buffer buf1_Field for ub._Field  .

for each _File no-lock :
   find first _Field no-lock of _File
        where _Field._Field-Name = 'obj-type'
        no-error .

   find first buf1_Field no-lock of _File
        where buf1_Field._Field-Name = 'obj-code'
        no-error .

    if available _Field and available  buf1_Field then do:
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .

          for each _index no-lock of _file  :
            for each  _index-field no-lock of _index  :
                find first buf-_field no-lock of _index-field no-error .
                if buf-_Field._Field-Name = 'obj-type' then do:
                    create temp-i .
                      assign
                        temp-i.nametable = _File._File-Name
                        temp-i.namefield = _Field._Field-Name
                        temp-i.nameindex = _index._index-name
                      .
                    leave.
                end.
                else do:
                    leave.
                end.
            end.
          end.
   end.
   end.

/*--- df---*/
for each temp-t where
         not can-find ( first temp-i where temp-i.nametable = temp-t.nametable ) :

    put stream outstrim unformatted
      substitute('ADD INDEX &2auto_obj&2 ON &2&1&2' , temp-t.nametable , {&double-quote}) skip
      substitute('AREA &1Schema Area&1' , {&double-quote} ) skip
      'INDEX-FIELD "obj-type" ASCENDING' skip
      'INDEX-FIELD "obj-code" ASCENDING' skip " " skip .
end.

  end.

end procedure. /* proc-obj */


procedure proc-host :

  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.

for each _File no-lock :
   find first _Field no-lock of _File
        where _Field._Field-Name = 'host-code'
        no-error .


    if available _Field  then do:
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .

          for each _Index of _File no-lock  :
            for each  _Index-Field no-lock of _Index  :
                find first buf-_Field no-lock of _Index-field no-error .
                    if available buf-_Field then do:
                        if buf-_Field._Field-Name = 'host-code' then do:
                            create temp-i .
                              assign
                                temp-i.nametable = _File._File-Name
                                temp-i.namefield = _Field._Field-Name
                                temp-i.nameindex = _index._index-name
                              .
                            leave.
                        end.
                        else do:
                            leave.
                        end.
                    end.
            end.
          end.
   end.
   end.

/*--- df---*/
for each temp-t where
         not can-find ( first temp-i where temp-i.nametable = temp-t.nametable ) :

    put stream outstrim unformatted
       substitute('ADD INDEX &2auto_host&2 ON &2&1&2' , temp-t.nametable , {&double-quote}) skip
       substitute('AREA &1Schema Area&1' , {&double-quote} ) skip
      'INDEX-FIELD "host-code" ASCENDING' skip " " skip .
end.

  end.

end procedure. /* proc-host */


procedure proc-host-other :

  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.

for each _File no-lock ,
   first _Field no-lock of _File
        where _Field._Field-Name <> 'host-code'
        and  index(_Field._Field-Name , 'host-code') > 0
   :
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .

          for each _Index of _File no-lock  :
            for each  _Index-Field no-lock of _Index  :
                find first buf-_Field no-lock where
                           buf-_Field._Field-Name = _Field._Field-Name
                of _Index-field no-error .
                    if available buf-_Field then do:
                        if buf-_Field._Field-Name <> 'host-code' and
                           index (buf-_Field._Field-Name, 'host-code' ) > 0
                        then do:
                            create temp-i .
                              assign
                                temp-i.nametable = _File._File-Name
                                temp-i.namefield =  buf-_Field._Field-Name
                                temp-i.nameindex = _index._index-name
                              .
                            leave.
                        end.
                        else do:
                            leave.
                        end.
                    end.
            end.
          end.

   end.

  /*--- df---*/
  for each temp-t where
          not can-find ( first temp-i where
              temp-i.nametable = temp-t.nametable and
              temp-i.namefield = temp-t.namefield )
              :
      put stream outstrim unformatted
        substitute('ADD INDEX &2auto_host_oth&2 ON &2&1&2' , temp-t.nametable , {&double-quote}) skip
        substitute('AREA &1Schema Area&1' , {&double-quote} ) skip
        substitute('INDEX-FIELD &2&1&2 ASCENDING ' ,temp-t.namefield, {&double-quote} )  skip " " skip .
  end.
end.

end procedure. /* proc-host */



procedure proc-obj-other :

  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.

define buffer buf2_Field for ub._Field  .
define variable v-pole1 as character no-undo .
define variable v-pole2 as character no-undo .

for each _File no-lock ,
   first _Field no-lock of _File
        where _Field._Field-Name <> 'obj-type'
        and  index(_Field._Field-Name , 'obj-type') > 0
   :

      v-pole1 = _Field._Field-Name .
      v-pole2 = REPLACE ( v-pole1 ,'obj-type' ,'obj-code') .
       find first buf2_Field where buf2_Field._Field-Name = v-pole2
                  of _File no-error .
          if available  buf2_Field then do:
            message  v-pole1  v-pole2 view-as alert-box .
            next.
        end.


       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
          temp-t.namefield2 = v-pole2
        .


          for each _Index of _File no-lock  :
            for each  _Index-Field no-lock of _Index  :
                find first buf-_Field no-lock where
                           buf-_Field._Field-Name = _Field._Field-Name
                of _Index-field no-error .
                    if available buf-_Field then do:
                        if buf-_Field._Field-Name <> 'obj-type' and
                           index (buf-_Field._Field-Name, 'obj-type' ) > 0
                        then do:
                            create temp-i .
                              assign
                                temp-i.nametable = _File._File-Name
                                temp-i.namefield =  buf-_Field._Field-Name
                                temp-i.nameindex = _index._index-name
                              .
                            leave.
                        end.
                        else do:
                            leave.
                        end.
                    end.
            end.
          end.
   end.

  /*--- df---*/
  for each temp-t where
          not can-find ( first temp-i where
              temp-i.nametable = temp-t.nametable and
              temp-i.namefield = temp-t.namefield )
              :
      put stream outstrim unformatted
        substitute('ADD INDEX &2auto_obj_oth&2 ON &2&1&2' , temp-t.nametable , {&double-quote}) skip
        substitute('AREA &1Schema Area&1' , {&double-quote} ) skip
        substitute('INDEX-FIELD &2&1&2 ASCENDING ' ,temp-t.namefield, {&double-quote} )  skip
        substitute('INDEX-FIELD &2&1&2 ASCENDING ' ,temp-t.namefield2, {&double-quote} )  skip " " skip .
  end.
end.

end procedure. /* proc-obj-other */


/*-----------------------------------------------------------------------------------------------------*/
procedure proc-cli :

  do
  on error undo, return error return-value
  :
empty temp-table temp-i.
empty temp-table temp-t.

define buffer buf1_Field for ub._Field  .

for each _File no-lock :
   find first _Field no-lock of _File
        where _Field._Field-Name = 'cli-type'
        no-error .

   find first buf1_Field no-lock of _File
        where buf1_Field._Field-Name = 'cli-code'
        no-error .

    if available _Field and available  buf1_Field then do:
       create temp-t .
        assign
          temp-t.nametable = _File._File-Name
          temp-t.namefield = _Field._Field-Name
        .

          for each _index no-lock of _file  :
            for each  _index-field no-lock of _index  :
                find first buf-_field no-lock of _index-field no-error .
                if buf-_Field._Field-Name = 'cli-type' then do:
                    create temp-i .
                      assign
                        temp-i.nametable = _File._File-Name
                        temp-i.namefield = _Field._Field-Name
                        temp-i.nameindex = _index._index-name
                      .
                    leave.
                end.
                else do:
                    leave.
                end.
            end.
          end.
   end.
   end.

/*--- df---*/
for each temp-t where
         not can-find ( first temp-i where temp-i.nametable = temp-t.nametable ) :
    put stream outstrim unformatted
      substitute('ADD INDEX &2auto_cli&2 ON &2&1&2' , temp-t.nametable , {&double-quote}) skip
      substitute('AREA &1Schema Area&1' , {&double-quote} ) skip
      'INDEX-FIELD "cli-type" ASCENDING' skip
      'INDEX-FIELD "cli-code" ASCENDING' skip " " skip .
end.

  end.

end procedure. /* proc-cli */