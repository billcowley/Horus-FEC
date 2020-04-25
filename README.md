# Horus-FEC
LDPC Channel Codes for the Horus Telemetry scheme of 2020

Files starting with H and ending in .mat are Repeat Accumulate (RA) LDPC parity
check matrices.  RA codes allow very easy encoding.  You can look at the code
structure (say) with: load 'H...filename.mat';   imagesc(H);

H_128_384_23.mat assumes 128 information bits, with total codeword length of 384
bits, ie rate 1/3 code.

TBC
/Bill 
