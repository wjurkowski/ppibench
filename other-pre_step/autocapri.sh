#parse decoy and unify residues numbering
for x in model.*.pdb 
 do egrep -v ' P |O1P|O2P|O3P'  $x >${x%.pdb}"grp.pdb"
 pdb2gmx -ignh -ff G43b1 -f ${x%.pdb}"grp.pdb" -o ${x%.pdb}"_gmx.pdb" >&/dev/null
 rm -f *itp* *top* *pdb.* *grp.pdb
 done