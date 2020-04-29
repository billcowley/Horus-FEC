# Horus-FEC
LDPC Channel Codes for the Horus Telemetry scheme of 2020

Files starting with H and ending in .mat are Repeat Accumulate (RA) LDPC parity
check matrices.  RA codes allow very easy encoding.  You can look at the code
structure (say) with: load 'H...filename.mat';   imagesc(H);
eg H_128_384_23.mat H matrix assumes 128 information bits, with total codeword
length of 384 bits, ie rate 1/3 code.

These matlab/octave routines simulate the given RA codes, asuming ideal BPSK,
for a range of Es/No values, using the CML encoder and decoder routines.

This code includes the option to use apriori information regarding certain
information bits.   For example suppose the  receiver knows a few bytes from
the transmitter, with very high probability (eg some fixed bits in the packet)
and the remaining information bits are unknown,  equiprobable, 0 or 1. For the
known bytes, their LLRs may be adjusted before decoding. Example plots
illustate the benefits of this APP knowledge. 

29th April 2020 
