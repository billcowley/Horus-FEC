# Horus-FEC
LDPC Channel Codes for the Horus Telemetry scheme of 2020

Files starting with H and ending in .mat are Repeat Accumulate (RA) LDPC parity
check matrices.  RA codes allow very easy encoding.  You can look at the code
structure (say) with: load 'H...filename.mat';   imagesc(H);
eg file H_128_384_23.mat (H matrix) assumes 128 information bits, with total codeword
length of 384 bits, ie rate 1/3 code.

These matlab/octave routines simulate the given RA codes, asuming ideal BPSK,
for a range of Es/No values, using the CML encoder and decoder routines.

This code includes the option to use apriori information regarding certain
information bits.   For example suppose the  receiver knows a few bytes from
the transmitter, with very high probability (eg some fixed bits in the packet)
and the remaining information bits are unknown,  equiprobable, 0 or 1. For the
known bytes, their LLRs may be adjusted before decoding. 

Example plots illustate the benefits of this APP knowledge, for some short 
rate 1/3 codes, with 128 or 256 information bits.  This case assumed that 20 
bits are known with probability 0.99, and 30 bits with prob 0.75.   Another 
pair of figures shows what happens if bits are assumed well known but are actually 
not so well known. In this case, for the same K=128 code as above, the first 20 bits
were assumed known with to 0.99 probability, but the actual probability they were correct 
in the simulation was only 0.8.   This is not good - if we think the bits are correct, 
but they aren't, we lose all APP benefits.  

These sims were run on a RPI4 so the number of  trials is fairly low.  (Hence the 
plots are not very smooth at low error rates!)  
 
  

29th April 2020 
