
P.Vdc = 500;
P.Rs = 1.3;
P.Ld = 8.9e-3;
P.Lq = 17.2e-3;
P.phif = 0.1819;
P.p = 6;
P.B = 0.01;
P.J = 0.0206;
P.fs = 10e3;
P.Ts = 1/P.fs;


%%
P.wcp = 20;                 % rad/s
P.Kpp = 10;
P.wm_max = 1500*2*pi/60;    % rad/s

P.wcw = 20;
Kt = 1.5*P.p*P.phif;
P.Kpw = P.J*P.wcw/Kt;   % ≈ 0.2517
P.Kiw = P.B*P.wcw/Kt;   % ≈ 0.1222

P.wci = 2000;%rad/s
P.Kpd = P.Ld*P.wci;
P.Kpq = P.Lq*P.wci;
P.Kid = P.Rs*P.wci;
P.Kiq = P.Rs*P.wci;