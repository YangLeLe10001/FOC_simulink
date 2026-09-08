clear;
clc;
close all;

run("Parameters.m");

simOut = sim('FOC.slx');

logsout = simOut.logsout;
disp(logsout.getElementNames);

%run("runResult_Speed.m");
run("runResult_Position.m");