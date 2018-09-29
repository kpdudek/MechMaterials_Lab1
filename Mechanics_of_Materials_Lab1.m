function Mechanics_of_Materials_Lab1
if fopen('steel_time.mat') == -1
    [steel_time,steel_force,steel_delta] = read_csv('Steel.csv');
    [Aluminum_time,Aluminum_force,Aluminum_delta] = read_csv('Aluminum.csv');
    [Acrylic_time,Acrylic_force,Acrylic_delta] = read_csv('Acrylic.csv');
    [Copper_time,Copper_force,Copper_delta] = read_csv('Copper.csv');
    save('Data.mat')
else
    load('Data.mat')
end

function [time,force,delta] = read_csv(file)
fid = fopen(file,'r');
force = [];
delta = [];
time = [];
counter = 1;

while ~feof(fid)
    if counter < 2
        line = fgetl(fid);
        counter = counter + 1;
    else
        line = fgetl(fid);
        
        [t,remain] = strtok(line,',');
        [elap,remain] = strtok(remain,',');
        [cycle,remain] = strtok(remain,',');
        [elap_cyc,remain] = strtok(remain,',');
        [step,remain] = strtok(remain,',');
        [tot_cyc,remain] = strtok(remain,',');
        [pos,remain] = strtok(remain,',');
        [load,remain] = strtok(remain,',');
        exten = erase(remain,',');
        
        force(end+1) = str2double(load);
        delta(end+1) = str2double(exten);
        time(end+1) = str2double(t);
    end
end
fclose(fid);
