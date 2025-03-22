clearvars;
(addpath(genpath('instruments')));



lockin1 = sr830(8);

ID = lockin1.getID();
