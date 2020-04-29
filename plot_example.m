% example of plotting some results on same figure 

dfilename = 'test_H_128_384_23.mat'
col = 'b'
plot_ldpc4
dfilename = 'apptest_H_128_384_23.mat'
col = 'k'
plot_ldpc4

dfilename = 'apptest_badAPP_H_128_384_23.mat'
col = 'r'
plot_ldpc4
figure(11)
legend('no APP', 'good APP', 'bad APP')

print -depsc2 fer_128_APPs.eps
figure(10)
legend('no APP', 'good APP', 'bad APP')
print -depsc2 ber_128_APPs.eps

  
  
  
