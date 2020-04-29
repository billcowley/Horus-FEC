function sim_out = ldpc4(HRA, sim_in, resfile, testmode, genie_Es, logging);
% RA LDPC Simulation, Bill 
% Call the CML routines and simulate one set of SNRs, AWGN BPSK channel
%
% HRA is the Repeat Accumulate parity check matrix 
% sim_in the input parameter structure
% sim_out contains BERs and other stats for each value of SNR
% resfile is the result file; testmode is for testing a C version of the 
% encoder with a specific file; genie_Es allows the decoder to use actual 
% Es/N0 for LLR scaling 
%
% This version may use prior information of some bits to improve decoding.
% Assume K1 (eg 20) bits are known with prob P1 eg (95% certainly) and
% that K2 bits with prob P2 eg 75%     In this simulation, the
% extra info will be passed via (eg) sim_in.app = [20 0.95  40 0.75]
% If required, simulate with the assumed known probability, plus the actual 
% known probability,   EG in the above, let the actual known prob of the 1st
% set of bits be 80% and the 2nd set of bits be 90% with this vector 
% [20 0.95 0.80   40 0.75 0.90]

if nargin<6, logging =0;   end 
if nargin<5, genie_Es =1;  end; 
if nargin<4, testmode =0;  end
estEsN0 = 0;


framesize = sim_in.framesize;
rate      = sim_in.rate;
mod_order = sim_in.mod_order;


Lim_Ferrs = sim_in.Lim_Ferrs;
Ntrials   = sim_in.Ntrials;
Esvec     = sim_in.Esvec;
deb       = sim_in.deb;


demod_type = 0;
decoder_type = 0;
max_iterations = 100;
code_param.bits_per_symbol = log2(mod_order);
bps = code_param.bits_per_symbol;

[H_rows, H_cols] = Mat2Hrows(HRA);
code_param.H_rows = H_rows;
code_param.H_cols = H_cols;
code_param.P_matrix = [];

code_param.data_bits_per_frame = length(code_param.H_cols) - length( code_param.P_matrix );

if (logging)
    fod = fopen('decode.log', 'w');
    fwrite(fod, 'Es estEs Its  secs \n');
end

app=0;
if isfield(sim_in, 'app'),
  if length(sim_in.app)>=4,  app =1;  end % set flag to use APP 
end 


for ne = 1:length(Esvec)
    Es = Esvec(ne);
    EsNo = 10^(Es/10);
    
    Terrs = 0;  Tbits =0;  Ferrs =0;
    for nn = 1: Ntrials
        
        data = round( rand( 1, code_param.data_bits_per_frame ) );
        codeword = LdpcEncode( data, code_param.H_rows, code_param.P_matrix );
        code_param.code_bits_per_frame = length( codeword );
        Nsymb = code_param.code_bits_per_frame/bps;
        
        if testmode==1
            f1 = fopen('dat_in2064.txt', 'w');
            for k=1:length(data);  fprintf(f1, '%u\n', data(k)); end
            fclose(f1);
            system('./ra_enc');
            
            load('dat_op2064.txt');
            pbits = codeword(length(data)+1:end);   %   print these to compare with C code
            dat_op2064(1:16)', pbits(1:16)
            differences_in_parity =  sum(abs(pbits - dat_op2064'))
            pause;
        end
        
        
        % modulate
        % s = Modulate( codeword, code_param.S_matrix );
        s= 1 - 2 * codeword;
        code_param.symbols_per_frame = length( s );
        
        
        % add noise
        variance = 1/(2*EsNo);
        noise = sqrt(variance)* randn(1,code_param.symbols_per_frame);
        %  +  j*randn(1,code_param.symbols_per_frame) );
        r = s + noise;
        
        % receiver processing
        Nr = length(r);
        % in the binary case the LLRs are just a scaled version of the rx samples ...
        % if the EsNo is known -- use the following
        if (genie_Es)
            input_decoder_c = 4 * EsNo * r;
        else
            r = r / mean(abs(r));       % scale for signal unity signal
            estvar = var(r-sign(r));
            estEsN0 = 1/(2* estvar);
            input_decoder_c = 4 * estEsN0 * r;
        end
        
        % adjust some LLRs if required, taking into account we may have
        % the wrong values for these special bits
        if app
          if length(sim_in.app)==4
            p1 = sim_in.app(2); p2 = sim_in.app(4);    % two classes for APP
            K1 = sim_in.app(1);  K2 = sim_in.app(3);    % numb of bits
            pa1 = p1;   pa2 = p2;  
          elseif length(sim_in.app)==6
            p1 = sim_in.app(2); p2 = sim_in.app(5);    % two classes for APP
            pa1 = sim_in.app(3); pa2 = sim_in.app(6); 
            K1 =  sim_in.app(1);  K2 = sim_in.app(4);
          else 
            error('APP vector is wromg length')
          end
          Hsize=size(HRA);
          if K1+K2> Hsize(1)
            error('too many known bits requested!')
          end 
                
          bb1 = 1:K1;   % first set of 'known' bits
          bb2 = K1+(1:K2);     % 2nd set of special bits
          % in the simulation we have access to the tx codeword
          % randomly make errors in these bits using actual known probs 
          err1 = sign((pa1>rand(size(bb1)))-1/2);    % error vectors +/- 1
          err2 = sign((pa2>rand(size(bb2)))-1/2);    % -1 is an error
            
          input_decoder_c(bb1) = input_decoder_c(bb1)+err1.*(1-2*codeword(bb1))*log(p1/(1-p1));
          input_decoder_c(bb2) = input_decoder_c(bb2)+err2.*(1-2*codeword(bb2))*log(p2/(1-p2));
        end
        
        
        if (logging)
            fprintf(fod, '%.1f %.1f ', Es, 10*log10(estEsN0));
        end
        
        
        [x_hat, PCcnt] = MpDecode( input_decoder_c, code_param.H_rows, code_param.H_cols, ...
            max_iterations, decoder_type, 1, 1);
        Niters = sum(PCcnt~=0);
        % detected_data = x_hat(max_iterations,:);
        detected_data = x_hat(Niters,:);
        error_positions = xor( detected_data(1:code_param.data_bits_per_frame), data );
        Nerrs = sum( error_positions);
        
        t = clock;   t =  fix(t(5)*60+t(6));
        if (logging)
            fprintf(fod, ' %3d  %4d\n', Niters, t);
        end
        
        if Nerrs>0, fprintf(1,'x'),  else fprintf(1,'.'),  end
        if (rem(nn, 50)==0),  fprintf(1,'\n'),  end
        
        if Nerrs>0,  Ferrs = Ferrs +1;  end
        Terrs = Terrs + Nerrs;
        Tbits = Tbits + code_param.data_bits_per_frame;
        
        if Ferrs > Lim_Ferrs, disp(['exit loop with #cw errors = ' ...
                num2str(Ferrs)]);  break,  end
    end
    
    TERvec(ne) = Terrs;
    FERvec(ne) = Ferrs;
    NCWvec(ne) = nn;
    BERvec(ne) = Terrs/ Tbits;
    Ebvec = Esvec - 10*log10(code_param.bits_per_symbol * rate);
    
    cparams= [code_param.data_bits_per_frame  code_param.symbols_per_frame ...
        code_param.code_bits_per_frame];
    
    sim_out.BERvec = BERvec;
    sim_out.Ebvec = Ebvec;
    sim_out.NCWvec   = NCWvec
    sim_out.FERvec = FERvec;
    sim_out.TERvec  = TERvec;
    sim_out.cpumins = cputime/60;
    sim_out.genie_Es = genie_Es;  
    
    if length(resfile)>0
        save(resfile,  'sim_in',  'sim_out',  'cparams');
        disp(['Saved results to ' resfile '  at Es =' num2str(Es) 'dB']);
    end
    
    
end
if (logging) fclose(fod); end;

