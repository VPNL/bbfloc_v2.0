You really just need to run RUNME_newexp.m in the new_exp folder, which will generate 6 unique bbfloc runs for your subject, the order depending on the expVersion you input.

**INPUT**
* participant's initials/number as string i.e. ('BR') 
* version of exp you want (as an integer): 1, 2, 3 
  NOTE: 
  * Version 1 run order: run1) Saxe, run2) static floc, run3) dynamic, run4) Saxe, run5) static floc, run6) dynamic
  * Version 2 run order: run1) dyna, run2) Saxe, run3) static floc, run4) dyna, run5) Saxe, run6) static floc
  * Version 3 run order: run1) static floc, run2) dyna, run3) Saxe, run4) static floc, run5) dyna, run6) Saxe
* user: user of laptop 

**OUTPUT**
* Generates participant's necessary data folders to run psychopy
* Generates 2 runs/CSV scripts for static condition: runtime (248s)
* Generates 2 runs/CSV scripts for dynamic condition: runtime (264s)
* Generates 2 runs/CSV scripts for Saxe condition: runtime (200s) 


