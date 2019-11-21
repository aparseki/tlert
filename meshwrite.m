%% MESH DESIGN [meshwrite.m]
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%
% Creates partial input file for gmsh.  Then run file into gmsh, and use
% other scripts to convert for R2.  Objective is to streamline mesh
% creation for profiles with topography.
%
% Step 1: Create a the "Survey Input" text file (see below for details)
%
% Step 2: Run this script to create the base input file for GMSH. Note that
% user input is needed for the FILE LOCATION... and MESH SIZE... cells
% below. These are marked with <> and are the only places user input is
% needed.
%
% Step 3: Launch GMSH and open the file saved as {outname}.  Go to
% Modules>Geometry>Elementary entities>Add and chose: Plane Surface. Using
% the cursor on screen, click the edges of your background until all
% background edges are red.  Press "e," then immediately click on edges of
% the foreground until the whole polygon is outlined in red and press "e"
% again. Next, "q" to abort. Finally go to "Mesh" and press "2D." If all
% went well, this should show the triangular mesh on the screen now.
% File>Save as... *.msh format. (See J. Robinson guide for details) You
% must define PhysicalGroups>Surfaces for it to work.
%
% Step 4: Run the "convert2d_msh.m" script. Locate the *.msh file that you
% just generated and let the script do it's thing.  It will automatically
% save a "mesh.dat" file in the same directory that ths script is located.
% You now need to move this converted mesh file into the R2 executable
% directory.
%
% A.Parsekian, 28 May, 2015
%
% Note: "convert2d_msh.m" requires "ccw.m" to run, also provided by J.
% Robinson - D. Thayer 3 June, 2015
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% <> FILE LOCATION AND OUTPUT NAME
wkdir = ''; % set your working directory; blank will use whatever directory this script is in
topog = 'dcew_temp_elev.txt'; % input the filename for "SURVEY INPUT" (see below)
outname = 'dcew'; % chose an output name for the *.geo file.
%% <> MESH SIZE AND GEOMETRY PARAMS
FrgDisc = 4; %distance that foreground discritization extends [normally do not change]
FrgDiscD = 20; % foreground discritization depth
MaxD = 200; %max surface distance
MaxDepth = 200; % max Neuman depth, to be added to FrgDiscD

%% ~~~[No user input needed below this point]~~~ %%
%% SURVEY INPUT
% reqires a text file that has two columns. Col 1 is the position in x of
% each electrode and Col 2 is the position in y (elevation, height) of each
% electrode. This assumes you are working with a streight line of
% electrodes. They must be sequential starting withe elx #1. There may only
% be exactly as many rows as the number of electrodes in your survey.
% Will be saved in the same directory that wkdir is set to be. All
% units meters.

sf = load([wkdir topog]); %survey file
[elx,~] = size(sf);
CharLen = (sf(2,1)-sf(1,1))*.8;  %decrease the multiplier for finer mesh cells

%% START WRITING FILE
% A header
time = num2str(fix(clock)); % just getting the clock time
fid = fopen([wkdir outname '.geo'], 'w');
fprintf (fid, ['// Gmsh project created on: ' time '\n']);
fprintf (fid, ['cl1=' num2str(CharLen) ';\n']);

%electrode positions
for i = 1:elx
    fprintf (fid, ['Point(' num2str(i) ') = {' num2str(sf(i,1)) ', ' num2str(sf(i,2)) ', 0, cl1};\n' ]);
end

%ctr = elx; % start co
% foreground discritization ends
fprintf (fid, ['Translate{' num2str(FrgDisc) ', 0, 0} {Duplicata { Point {' num2str(elx) '}; } }\n' ]);
fprintf (fid, ['Translate{' num2str(-FrgDisc) ', 0, 0} {Duplicata { Point {' num2str(1) '}; } }\n' ]);

% Neumann boundary (background)
fprintf (fid, ['pt1[] = Translate{' num2str(MaxD) ', 0, 0} {Duplicata { Point {' num2str(elx) '}; } };\n']);
fprintf (fid, ['pt2[] = Translate{' num2str(-MaxD) ', 0, 0} {Duplicata { Point {' num2str(1) '}; } };\n']);

% Foreground discritization depth
fprintf (fid, ['Translate{0, ' num2str(-FrgDiscD) ', 0} {Duplicata { Point {' num2str(elx+2) '}; } }\n']);
fprintf (fid, ['Translate{0, ' num2str(-FrgDiscD) ', 0} {Duplicata { Point {' num2str(elx+1) '}; } }\n']);

% Depth extent of Neuman boundary
fprintf (fid, ['pt3[] = Translate{0, ' num2str(-(MaxDepth+FrgDiscD)) ', 0} {Duplicata { Point {' num2str(elx+4) '}; } };\n']);
fprintf (fid, ['pt4[] = Translate{0, ' num2str(-(MaxDepth+FrgDiscD)) ', 0} {Duplicata { Point {' num2str(elx+3) '}; } };\n']);

fprintf (fid, ['Characteristic Length {pt1[0], pt2[0], pt3[0], pt4[0]}=cl1*150;\n']); %May change the '150' here for background discritization size

for i = 1:elx
    fprintf (fid, ['Translate{0, ' num2str(-FrgDiscD) ', 0} {Duplicata { Point {' num2str(i) '}; } }\n']);
end

%Background Lines
ctr = 1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+1) ', ' num2str(elx+3) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+2) ', ' num2str(elx+4) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+4) ', ' num2str(elx+7) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+8) ', ' num2str(elx+7) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+8) ', ' num2str(elx+3) '};\n']); ctr = ctr+1;

%Foreground Lines
xs = 1:elx-1;
ys = 2:elx;

for i= 1:elx-1;
    fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(xs(i)) ', ' num2str(ys(i)) '};\n']); ctr = ctr+1;
end

xs = (elx+9):(elx*2+7);
ys = [xs(2:end) xs(end)+1];

for i= 1:elx-1;
    fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(xs(i)) ', ' num2str(ys(i)) '};\n']); ctr = ctr+1;
end

fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx) ', ' num2str(elx+1) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+1) ', ' num2str(elx+6) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(ys(end)) ', ' num2str(elx+6) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+5) ', ' num2str(elx+9) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+2) ', ' num2str(1) '};\n']); ctr = ctr+1;
fprintf (fid, ['Line(' num2str(ctr) ') = {' num2str(elx+2) ', ' num2str(elx+5) '};\n']); ctr = ctr+1;

fclose(fid);

disp('your GEO file has been written')

clear all