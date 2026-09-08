%%
theta_m      = logsout.get("theta_m").Values;
theta_m.Data = squeeze(theta_m.Data);
theta_ref      = logsout.get("theta_ref").Values;
theta_ref.Data = squeeze(theta_ref.Data);
etheta      = logsout.get("etheta").Values;
etheta.Data = squeeze(etheta.Data);

wm      = logsout.get("wm").Values;
wm.Data = wm.Data*60/(2*pi);
wm_ref_pos      = logsout.get("wm_ref");
wm_ref_pos      = wm_ref_pos{2}.Values;
wm_ref_pos.Data = wm_ref_pos.Data*60/(2*pi);

iq      = logsout.get("iq").Values;
iq.Data = squeeze(iq.Data);
iq_ref      = logsout.get("iq_ref").Values;
iq_ref.Data = squeeze(iq_ref.Data);

Te      = logsout.get("Te").Values;
TL      = logsout.get("TL").Values;

%%
fig1 = figure("Name", "Position Response");

plot(theta_ref.Time, theta_ref.Data, "--", "LineWidth", 1.5);
hold on;
plot(theta_m.Time, theta_m.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Position (rad)");
title("Position Response");

legend("Reference Position", "Actual Position", ...
"Location", "best");

xlim([0 15]);

%
fig2 = figure("Name", "Position Error");

plot(etheta.Time, etheta.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Position Error (rad)");
title("Position Tracking Error");

yline(0, "--");
xlim([0 15]);

%
fig3 = figure("Name", "Position-Mode Speed Response");

plot(wm_ref_pos.Time, wm_ref_pos.Data, "--", "LineWidth", 1.5);
hold on;
plot(wm.Time, wm.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Speed (rpm)");
title("Position-Mode Speed Response");

legend("Reference Speed", "Actual Speed", ...
"Location", "best");

xlim([0 15]);

%
fig4 = figure("Name", "Position-Mode Torque Response");

plot(Te.Time, Te.Data, "LineWidth", 1.5);
hold on;

plot(TL.Time, TL.Data, "--", "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Torque (N·m)");
title("Position-Mode Electromagnetic and Load Torque");

legend("Electromagnetic Torque T_e", ...
"Load Torque T_L", ...
"Location", "best");

xlim([0 15]);

%
fig5 = figure("Name", "Position-Mode q-axis Current Response");

plot(iq_ref.Time, iq_ref.Data, "--", "LineWidth", 1.3);
hold on;
plot(iq.Time, iq.Data, "LineWidth", 1.5);

grid on;
box on;

xlabel("Time (s)");
ylabel("Current (A)");
title("Position-Mode q-axis Current Response");

legend("i_q^*", "i_q", ...
"Location", "best");

xlim([0 15]);

%%
outputFolder = fullfile(pwd, "Result", "Position");

exportgraphics(fig1, ...
fullfile(outputFolder, "01_Position_Response.png"), ...
"Resolution", 300);

exportgraphics(fig2, ...
fullfile(outputFolder, "02_Position_Error.png"), ...
"Resolution", 300);

exportgraphics(fig3, ...
fullfile(outputFolder, "03_Position_Mode_Speed.png"), ...
"Resolution", 300);

exportgraphics(fig4, ...
fullfile(outputFolder, "04_Position_Mode_Torque.png"), ...
"Resolution", 300);

exportgraphics(fig5, ...
fullfile(outputFolder, "05_Position_Mode_iq.png"), ...
"Resolution", 300);

%%
% Position Performance Metrics

t = theta_m.Time;
theta = theta_m.Data;
theta_ref_data = theta_ref.Data;

speed_pos = wm.Data;
iq_data = iq.Data;
Te_data = Te.Data;

%
% 0-5 s: 0 -> 2pi
idx_pos1 = (t >= 0) & (t < 5);

initial_pos1 = 0;
target_pos1 = 2*pi;
step_pos1 = target_pos1-initial_pos1;

peak_pos1 = max(theta(idx_pos1));

overshoot_pos1 = max(0, ...
(peak_pos1-target_pos1)/step_pos1*100);

tol_pos1 = 0.02*step_pos1;
idx_pos1_all = find(idx_pos1);

settling_pos1 = NaN;

for k = idx_pos1_all'
    if all(abs(theta(k:find(t<5,1,"last"))-target_pos1) <= tol_pos1)
        settling_pos1 = t(k);
        break;
    end
end

%
% 5-10 s: 2pi -> 4pi
idx_pos2 = (t >= 5) & (t < 10);

initial_pos2 = 2*pi;
target_pos2 = 4*pi;
step_pos2 = target_pos2-initial_pos2;

peak_pos2 = max(theta(idx_pos2));

overshoot_pos2 = max(0, ...
(peak_pos2-target_pos2)/step_pos2*100);

tol_pos2 = 0.02*step_pos2;
idx_pos2_all = find(idx_pos2);

settling_pos2 = NaN;

for k = idx_pos2_all'
    if all(abs(theta(k:find(t<10,1,"last"))-target_pos2) <= tol_pos2)
        settling_pos2 = t(k)-5;
        break;
    end
end

%
% 10-15 s: 2 N·m load disturbance
idx_load = (t >= 10);

min_position_load = min(theta(idx_load));
max_position_deviation = target_pos2-min_position_load;

tol_load = 0.02*target_pos2;
idx_load_all = find(idx_load);

position_recovery_time = NaN;

for k = idx_load_all'
    if all(abs(theta(k:end)-target_pos2) <= tol_load)
        position_recovery_time = t(k)-10;
        break;
    end
end

%
% Final steady-state values
idx_final = (t >= 14);

final_position = mean(theta(idx_final));
final_position_error = mean(theta_ref_data(idx_final)-theta(idx_final));

peak_speed = max(abs(speed_pos));
peak_iq = max(abs(iq_data));
peak_Te = max(abs(Te_data));

%
PositionMetrics = table( ...
peak_pos1, ...
overshoot_pos1, ...
settling_pos1, ...
peak_pos2, ...
overshoot_pos2, ...
settling_pos2, ...
min_position_load, ...
max_position_deviation, ...
position_recovery_time, ...
final_position, ...
final_position_error, ...
peak_speed, ...
peak_iq, ...
peak_Te, ...
'VariableNames', { ...
'First_Peak_rad', ...
'First_Overshoot_pct', ...
'First_SettlingTime_s', ...
'Second_Peak_rad', ...
'Second_Overshoot_pct', ...
'Second_SettlingTime_s', ...
'Load_MinPosition_rad', ...
'Load_MaxDeviation_rad', ...
'Load_RecoveryTime_s', ...
'Final_Position_rad', ...
'Final_PositionError_rad', ...
'Peak_Speed_rpm', ...
'Peak_iq_A', ...
'Peak_Te_Nm'});

disp(" ");
disp("========== POSITION CONTROL METRICS ==========");
disp(PositionMetrics);

writetable(PositionMetrics, ...
fullfile(outputFolder, "Position_Metrics.csv"));