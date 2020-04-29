%plot_ldpc4.m --- plot the results from test_ldpc4.m 
% define dfilename before running, containing simulation results
% set variable 'col' for line colour and type eg col='g--'

load(dfilename)
set(0,'DefaultTextInterpreter','none'); 

if exist('col')~=1
    col = 'b'
end

figure(10);  
semilogy(sim_out.Ebvec,  sim_out.BERvec, col)
xlabel('Eb/N0')
ylabel('BER')
title([sim_in.comment ' ' date ' using ' dfilename])
grid on;   hold on 

figure(11);  
semilogy(sim_out.Ebvec,  sim_out.FERvec ./ sim_out.NCWvec, col)
xlabel('Eb/N0')
ylabel('FER')
title([sim_in.comment ' ' date ' using ' dfilename])
grid on;   hold on 

