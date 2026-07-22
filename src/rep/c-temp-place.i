define temp-table with-action no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical 
&if "{3}" = "update" &then
field f_update as logical
field f_can_update as logical
field f_parent as character
field f_visible as logical
field f_root as character
index iu f_update
index ivisible  f_visible
index iparent f_root f_parent
&endif
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange  
t_name
f_name

index imain uniq-key-rec
.