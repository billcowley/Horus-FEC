%Test LDPC codes.  Bill Cowley, from April 2016  
% default run type is RA codes (rtype=2), setup hfilename before running  
%         eg hfilename = 'H_128_384_23.mat'
% default EsNo range will be setup, unless specified beforehand; BPSK used. 
% setup a comment for this sim, in variable 'comment', or input when asked 
% default numb of codewords for each Es value is set by Ntrials
% APP info may be used helping decoder  eg app=[20 0.95  40 0.75]; see ldpc4.m 
%
% results are stored in .mat file ending in hfilename,  and may be plotted via 
% plot_ldpc4
%
% This simulation uses the Mat Valenti CML library, which must be installed!
% eg see http://www.iterativesolutions.com/Matlab.htm
% CML setup code below must be edited to suit your environment 



if exist('app')==1
    sim_in.app = app; 
    disp(['Using APP ' num2str(app)])
else 
    app =0; 
end 

if exist('rtype')~=1
    rtype =2;  
end 
if exist(hfilename)==2
    saved_hfilename = hfilename;
    disp('loading H file matrix ');
    load(hfilename)
    hfilename = saved_hfilename;
else
    error('** hfilename not setup')
end

if exist('Esvec')~=1 
    Esvec = -6:0.5:0;  
end

currentdir = pwd;
thiscomp = computer;


%%% edit the following as required for your PC
if strcmpi(thiscomp, 'MACI64')==1
   if exist('CMLSimulate')==0
        cd '/Users/bill/Current/Projects/DLR_FSO/Visit2013_FSO_GEO/cml'
        addpath '../'    % assume the source files stored here
        CmlStartup       % note that this is not in the cml path!
        disp('added MACI64 path and run CmlStartup')
    end
elseif isunix 
   if exist('LdpcEncode')==0, 
        cd '~/installs/CML'
        CmlStartup       % 
        disp('Setup for Linux and CmlStartup has been run')
	rmpath '/home/bill/installs/CML/mex/mexhelp'  % why is this needed? 
	% maybe different path order in octave cf matlab ? 
    end
else
    disp('CML not installed ?? ')
    quit
end

if exist('testmode')~=1, testmode = 0; end
cd(currentdir)
 
log = 1; 
if exist('Ntrials')==0, Ntrials = 5000,  end   
genie_Es=1;  

if exist('comment')==0
% example comment = 'Test K=128, with genie_Es';
sim_in.comment = input('please enter comment ', 's'); 
else 
    sim_in.comment = comment; 
end

disp(sim_in.comment);

sim_in.Esvec = Esvec; 

if rtype == 1
    % load('H800_200.mat'); 
    % load('H2064_516_sparse.mat');
    error('Not supported here!')
    HRA = full(HRA);
else
    HRA = H; 
    
end
[Nr Nc] = size(HRA);  

sim_in.rate = (Nc-Nr)/Nc;
sim_in.framesize = Nc;

sim_in.mod_order = 2;    % ideal BPSK 

sim_in.Lim_Ferrs= 100;   % exit this ES value after 100 decoder failures 
sim_in.Ntrials =  Ntrials;


if exist('deb')~=1, deb = 0; end
sim_in.deb =    deb;


dfilename = ['test_' hfilename]; 
if app
    dfilename = ['apptest_' hfilename]; 
end 

sim_out = ldpc4(HRA, sim_in, dfilename, testmode, genie_Es, log);

figure;  
semilogy(sim_out.Ebvec,  sim_out.BERvec)
xlabel('Eb/N0')
ylabel('BER')
title([sim_in.comment ' ' date ' using ' hfilename])
