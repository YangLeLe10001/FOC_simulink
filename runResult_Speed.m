%%

wm      = logsout.get("wm").Values;
wm.Data = wm.Data*60/(2*pi);
wm_ref  = logsout.get("wm_ref");
wm_ref  = wm_ref{1}.Values;
wm_ref.Data = wm_ref.Data*60/(2*pi);
ew      = logsout.get("ew").Values;
ew.Data = ew.Data*60/(2*pi);

id      = logsout.get("id").Values;
id.Data     = squeeze(id.Data);
id_ref  = logsout.get("id_ref").Values;
id_ref.Data  = squeeze(id_ref.Data);

iq      = logsout.get("iq").Values;
iq.Data      = squeeze(iq.Data);
iq_ref  = logsout.get("iq_ref").Values;
iq_ref.Data  = squeeze(iq_ref.Data);

Te      = logsout.get("Te").Values;
TL      = logsout.get("TL").Values;

i_abc = logsout.get("i_abc").Values;
iabc = squeeze(i_abc.Data);
ia = iabc(1,:).';
ib = iabc(2,:).';
ic = iabc(3,:).';


D_abc = logsout.get("D_abc").Values;
Dabc = squeeze(D_abc.Data);
Da = Dabc(1,:).';
Db = Dabc(2,:).';
Dc = Dabc(3,:).';

%%

fig1 = figure("Name", "Speed Response");

plot(wm_ref.Time, wm_ref.Data, "--", "LineWidth", 1.5);
hold on;
plot(wm.Time, wm.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Speed (rpm)");
title("Speed Response");

legend("Reference Speed", "Actual Speed", ...
    "Location", "best");

xlim([0 15]);

%
fig2 = figure("Name", "Speed Error");

plot(ew.Time, ew.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Speed Error (rpm)");
title("Speed Tracking Error");

yline(0, "--");
xlim([0 15]);

%
fig3 = figure("Name", "dq Current Response");

plot(id_ref.Time, id_ref.Data, "--", "LineWidth", 1.3);
hold on;

plot(id.Time, id.Data, "LineWidth", 1.5);
plot(iq_ref.Time, iq_ref.Data, "--", "LineWidth", 1.3);
plot(iq.Time, iq.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Current (A)");
title("dq-axis Current Response");

legend("i_d^*", "i_d", "i_q^*", "i_q", ...
    "Location", "best");

xlim([0 15]);

%
fig4 = figure("Name", "Torque Response");

plot(Te.Time, Te.Data, "LineWidth", 1.5);
hold on;

plot(TL.Time, TL.Data, "--", "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Torque (N·m)");
title("Electromagnetic and Load Torque");

legend("Electromagnetic Torque T_e", ...
       "Load Torque T_L", ...
       "Location", "best");

xlim([0 15]);

%
fig5 = figure("Name", "Three-Phase Currents");

t1 = 12.00;
t2 = 12.05;
t12= (i_abc.Time >= t1) & (i_abc.Time <= t2);

plot(i_abc.Time(t12), ia(t12), "LineWidth", 1.0);
hold on;

plot(i_abc.Time(t12), ib(t12), "LineWidth", 1.0);
plot(i_abc.Time(t12), ic(t12), "LineWidth", 1.0);

grid on;
box on;

xlabel("Time (s)");
ylabel("Phase Current (A)");
title("Three-Phase Stator Currents");

legend("i_a", "i_b", "i_c", ...
    "Location", "best");

xlim([t1 t2]);

%
fig6 = figure("Name", "SVPWM Duty Cycles");

t1 = 12.00;
t2 = 12.05;
t12 = (D_abc.Time >= t1) & (D_abc.Time <= t2);

plot(D_abc.Time(t12), Da(t12), "LineWidth", 1.0);
hold on;

plot(D_abc.Time(t12), Db(t12), "LineWidth", 1.0);
plot(D_abc.Time(t12), Dc(t12), "LineWidth", 1.0);

grid on;
box on;

xlabel("Time (s)");
ylabel("Duty Cycle");
title("SVPWM Duty Cycles");

legend("D_a", "D_b", "D_c", ...
    "Location", "best");

xlim([t1 t2]);
ylim([0 1]);

%%

outputFolder = fullfile(pwd, "Result", "Speed");

exportgraphics(fig1, ...
    fullfile(outputFolder, "01_Speed_Response.png"), ...
    "Resolution", 300);

exportgraphics(fig2, ...
    fullfile(outputFolder, "02_Speed_Error.png"), ...
    "Resolution", 300);

exportgraphics(fig3, ...
    fullfile(outputFolder, "03_dq_Current_Response.png"), ...
    "Resolution", 300);

exportgraphics(fig4, ...
    fullfile(outputFolder, "04_Torque_Response.png"), ...
    "Resolution", 300);

exportgraphics(fig5, ...
    fullfile(outputFolder, "05_Three_Phase_Currents.png"), ...
    "Resolution", 300);

exportgraphics(fig6, ...
    fullfile(outputFolder, "06_SVPWM_Duty_Cycles.png"), ...
    "Resolution", 300);

%%
% Speed Performance Metrics

t = wm.Time;
speed = wm.Data;
speed_ref = wm_ref.Data;

iq_data = iq.Data;
Te_data = Te.Data;

%
% 0-5 s: startup to 1000 rpm
idx_start = (t >= 0) & (t < 5);

target_start = 1000;
initial_start = 0;
step_start = target_start-initial_start;

peak_start = max(speed(idx_start));

overshoot_start = max(0, ...
(peak_start-target_start)/step_start*100);

tol_start = 0.02*step_start;
idx_start_all = find(idx_start);

settling_start = NaN;

for k = idx_start_all'
    if all(abs(speed(k:find(t<5,1,"last"))-target_start) <= tol_start)
        settling_start = t(k);
        break;
    end
end

%
% 5-10 s: 1000 -> 1500 rpm
idx_step = (t >= 5) & (t < 10);

initial_step = 1000;
target_step = 1500;
step_size = target_step-initial_step;

peak_step = max(speed(idx_step));

overshoot_step = max(0, ...
(peak_step-target_step)/step_size*100);

tol_step = 0.02*step_size;
idx_step_all = find(idx_step);

settling_step = NaN;

for k = idx_step_all'
    if all(abs(speed(k:find(t<10,1,"last"))-target_step) <= tol_step)
        settling_step = t(k)-5;
        break;
    end
end

%
% 10-15 s: 2 N·m load disturbance
idx_load = (t >= 10);

min_speed_load = min(speed(idx_load));
speed_drop = target_step-min_speed_load;

tol_load = 0.02*target_step;
idx_load_all = find(idx_load);

recovery_time = NaN;

for k = idx_load_all'
    if all(abs(speed(k:end)-target_step) <= tol_load)
        recovery_time = t(k)-10;
        break;
    end
end

%
% Final steady-state values
idx_final = (t >= 14);

final_speed = mean(speed(idx_final));
final_speed_error = mean(speed_ref(idx_final)-speed(idx_final));

peak_iq = max(abs(iq_data));
loaded_iq = mean(iq_data(idx_final));

peak_Te = max(abs(Te_data));
loaded_Te = mean(Te_data(idx_final));

%
SpeedMetrics = table( ...
peak_start, ...
overshoot_start, ...
settling_start, ...
peak_step, ...
overshoot_step, ...
settling_step, ...
min_speed_load, ...
speed_drop, ...
recovery_time, ...
final_speed, ...
final_speed_error, ...
peak_iq, ...
loaded_iq, ...
peak_Te, ...
loaded_Te, ...
'VariableNames', { ...
'Startup_Peak_rpm', ...
'Startup_Overshoot_pct', ...
'Startup_SettlingTime_s', ...
'Step_Peak_rpm', ...
'Step_Overshoot_pct', ...
'Step_SettlingTime_s', ...
'Load_MinSpeed_rpm', ...
'Load_SpeedDrop_rpm', ...
'Load_RecoveryTime_s', ...
'Final_Speed_rpm', ...
'Final_SpeedError_rpm', ...
'Peak_iq_A', ...
'Loaded_iq_A', ...
'Peak_Te_Nm', ...
'Loaded_Te_Nm'});

disp(" ");
disp("========== SPEED CONTROL METRICS ==========");
disp(SpeedMetrics);

writetable(SpeedMetrics, ...
fullfile(outputFolder, "Speed_Metrics.csv"));