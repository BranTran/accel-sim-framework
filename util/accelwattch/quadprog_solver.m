%Copyright (c) 2018-2021, Vijay Kandiah, Junrui Pan, Mahmoud Khairy, Scott Peverelle, Timothy Rogers, Tor M. Aamodt, Nikos Hardavellas
%Northwestern University, Purdue University, The University of British Columbia
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are met:
%
%1. Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer;
%2. Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution;
%3. Neither the names of Northwestern University, Purdue University,
%   The University of British Columbia nor the names of their contributors
%  may be used to endorse or promote products derived from this software
%   without specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%POSSIBILITY OF SUCH DAMAGE.

input = csvread('accelwattch_volta_sass_sim.csv',1,1);
counters = 26;
A = input(:,1:counters-1); % change 30 to number of power counters if different
b = input(:,counters);
l = 0.1*ones(1,counters-1); % lower bounds
u = 1000*ones(1,counters-1); % upper bounds

M= zeros(1,counters-1);
N= [0];



C = zeros(10,counters-1);
D = zeros(10,1);
%These factors are calculated using McPAT per instruction energies * current AccelWattch scaling factors. They need to be changed after each iteration of the solver + simulator runs.
C(1,7)=1;
C(1,8)=-1.843582172; %INT <= FPU

C(2,8)=1;
C(2,9)=-0.999991619; %FPU <= DPU

C(3,7)=1;
C(3,10)=-1.000003101; %INT <= INT_MUL

C(4,11)=1;
C(4,16)=-1.063781571; %FP_MUL <= DP_MUL

C(5,11)=1;
C(5,12)=-5.587170605; %FP_MUL <= FP_SQRT

C(6,11)=1;
C(6,13)=-2.082920111; %FP_MUL <= FP_LG

C(7,11)=1;
C(7,14)=-1.767684722; %FP_MUL <= FP_SIN

C(8,11)=1;
C(8,15)=-1.438999757; %FP_MUL <= FP_EXP

C(9,11)=1;
C(9,17)=-75.07256801; %FP_MUL <= TENSOR

C(10,11)=1;
C(10,18)=-0.999997535; %FP_MUL <= TEXP

%The Idle_Core_power, static power, constant power components are already
%modeled prior to dynamic power quadprog optimization
l(counters-3)=1;
u(counters-3)=1;
l(counters-2)=1;
u(counters-2)=1;
l(counters-1)=1;
u(counters-1)=1;

result = quadprog(2*A'*A, -2*A'*b, C, D, [], [], l, u);
csvwrite('scaled_coefficients.csv', result);
