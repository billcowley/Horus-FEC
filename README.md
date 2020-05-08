# Horus-FEC
LDPC Channel Codes for the Horus Telemetry scheme of 2020

Files starting with H and ending in .mat are Repeat Accumulate (RA) LDPC parity
check matrices.  RA codes allow very easy encoding.  You can look at the code
structure (say) with: load 'H...filename.mat';   imagesc(H);
eg file H_128_384_23.mat (H matrix) assumes 128 information bits, with total codeword
length of 384 bits, ie rate 1/3 code.

These matlab/octave routines simulate the given RA codes, asuming ideal BPSK,
for a range of Es/No values, using the CML encoder and decoder routines. 

### Using Prior Information 
This code includes the option to use apriori information regarding certain
information bits.   For example suppose the  receiver knows a few bytes from
the transmitter, with very high probability (eg some fixed bits in the packet)
and the remaining information bits are unknown,  equiprobable, 0 or 1. For the
known bytes, their LLRs may be adjusted before decoding. 

Example plots (.eps files) illustate the benefits of this APP knowledge, for some short 
rate 1/3 codes, with 128 or 256 information bits.  This case assumed that 20 
bits are known with probability 0.99, and 30 bits with prob 0.75.   Another 
pair of figures shows what happens if bits are assumed well known but are actually 
not so well known. In this case, for the same K=128 code as above, the first 20 bits
were assumed known with to 0.99 probability, but the actual probability they were correct 
in the simulation was only 0.8.   This is not good - if we think the bits are correct, 
but they aren't, we lose all APP benefits.  

The sims above were run on a RPI4 so the number of  trials is fairly low.  (Hence the 
plots are not very smooth at low error rates!)  The .mat files starting with test.... or apptest... are 
simulation results from test_ldpc4.m, which can be plotted with plot_ldpc4.m
 
  
### K=128 Examples 
Files xxx_k128_summary.png shows some results with more trials (Ntrials=30000) for K=128 codes.  
As expected the rate 1/4 codes (solid plots) have the best performance versus Eb/N0. Two examples are shown: 
without APP, the H_128_512_222 case (blue)  has slightly better BER at low Eb, but shows an error floor. 
The green plot is a slightly different H matrix, whose performance is very slightly worse at (say) 2 dB, but 
has no error floor.  The magenta plot shows how prior information can improve its performance.  

For comparison, plots of the K=128 rate 1/3 code considered above, plus a K=128, rate 1/2 are also shown.  Note 
the rate 1/3 case (we used above) has an error floor.  

### K=256 Examples 
Files xxx_k256_summary.png illustrate results for K=256 parity check matrices listed in the figure legends.  For example, 
two rate 1/4 codes are shown (dashed) and once again, one is better at lower SNRs, but suffers from an error floor.  The rate 1/3 code (blue) performs quite well, with no error floor.  The black curve is a rate 1/2 code.  These simulations all used Ntrials=30000, with standard decoding  (i.e. no prior information about information bit distributions).  

8th May, 2020
